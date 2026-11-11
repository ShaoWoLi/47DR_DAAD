classdef AWGScopeApp < handle
    % MATLAB desktop AWG/scope. Hardware operations run in a private Vivado.
    properties (SetAccess=private)
        Root
        Figure
        UI=struct
        Bridge
        Timer
        Raw=[]
        Tx=[]
        Rx=[]
        Connected=false
        Busy=false
        Uploaded=false
        Status=struct
        LastError=''
        LastCapture=''
        InitProcess=[]
        InitLog=''
        UartSocket=[]
        UartInput=[]
    end
    properties
        ShowAlerts=true
    end
    properties (Access=private)
        Messages={}
        AfterDisconnect=''
        WaitReady=[]
        LastReadyPoll=[]
        Closing=false
        UartBuffer=uint8([])
    end
    methods
        function obj=AWGScopeApp(varargin)
            obj.Root=fileparts(fileparts(mfilename('fullpath')));
            addpath(fullfile(obj.Root,'matlab'));
            if ~isfolder(fullfile(obj.Root,'app_data','sessions')), mkdir(fullfile(obj.Root,'app_data','sessions')); end
            if ~isfolder(fullfile(obj.Root,'app_data','captures')), mkdir(fullfile(obj.Root,'app_data','captures')); end
            obj.Bridge=AWGBridge(obj.Root);
            obj.buildUI;
            cfgPath=fullfile(obj.Root,'app_data','settings.json');
            if isfile(cfgPath)
                try
                    cfg=jsondecode(fileread(cfgPath)); names=fieldnames(cfg);
                    for k=1:numel(names)
                        if isfield(obj.UI,['cfg_' names{k}]), obj.UI.(['cfg_' names{k}]).Value=cfg.(names{k}); end
                    end
                    if ~isfield(cfg,'uart_host')
                        if strcmp(obj.UI.cfg_mode.Value,'remote')
                            address=obj.UI.cfg_server.Value; colon=find(address==':',1,'last');
                            if ~isempty(colon), address=address(1:colon-1); end
                            obj.UI.cfg_uart_host.Value=address;
                        else
                            obj.UI.cfg_uart_host.Value='localhost';
                        end
                    end
                catch, obj.log('连接设置未能读取，已使用默认值。'); end
            end
            obj.Timer=timer('ExecutionMode','fixedSpacing','Period',0.4,'BusyMode','drop', ...
                'TimerFcn',@(~,~) obj.tick,'ErrorFcn',@(~,e) obj.timerError(e));
            start(obj.Timer);
            obj.log('已启动。首次上板：导入波形 → 初始化板卡 → 下载/播放 → 捕获。');
            obj.log('可先点击“离线接收演示”；该数据为模拟数据，不会连接板卡。');
            obj.updateControls;
            if ~isempty(varargin), obj.Figure.Visible=varargin{1}; else, obj.Figure.Visible='on'; end
        end
        function importWave(obj,path,variable)
            if nargin<3, variable=''; end
            [wave,fs,units,label]=AWGScopeApp.readWave(path,variable);
            obj.setWave(wave,fs,units,label);
        end
        function setWave(obj,wave,fs,units,label,mask)
            if nargin<5, label='MATLAB waveform'; end
            validateattributes(wave,{'numeric'},{'2d','finite','nonempty'});
            if isvector(wave), wave=wave(:); end
            assert(size(wave,2)<=8,'数据列数最多8列，每列一个物理通道。');
            assert(size(wave,1)>=4,'波形至少需要4点。');
            obj.Raw=double(wave); obj.Uploaded=false; obj.Tx=[];
            obj.UI.source.Text=label;
            obj.UI.fs.Value=fs/1e6; obj.UI.units.Value=units;
            % Preserve the full imported record. Invalid lengths must be
            % reported, rather than silently selecting a shorter prefix.
            obj.UI.count.Limits=[1 max(65536,size(wave,1))];
            obj.UI.first.Value=1; obj.UI.count.Value=size(wave,1);
            if nargin<6
                currentMask=obj.readChannelMask(obj.UI.dacButtons);
                currentCount=sum(bitget(uint8(currentMask),1:8));
                if size(wave,2)>1 && currentCount~=size(wave,2)
                    mask=2^size(wave,2)-1;
                else
                    mask=currentMask;
                end
            end
            obj.syncChannelButtons(mask);
            obj.prepareTx;
            obj.UI.view.Value='tx'; obj.render;
            obj.log(sprintf('已导入 %d 点 × %d 通道；选择 %d 点用于循环播放。', ...
                size(wave,1),size(wave,2),obj.UI.count.Value));
        end
        function demoTx(obj)
            Fs=9e9; n=(0:9215)';
            mask=obj.readChannelMask(obj.UI.dacButtons);
            assert(mask~=0,'请至少选择一个DAC通道。');
            wave=0.25*cos(2*pi*100e6/Fs*n);
            obj.setWave(wave,Fs,'normalized', ...
                sprintf('演示发射：%s 实数单音 / 9 GS/s',obj.channelNames(mask,'DAC')),mask);
        end
        function demoRx(obj)
            obj.loadCapture(fullfile(obj.Root,'sim','demo','capture.csv'));
        end
        function prepareTx(obj)
            obj.Uploaded=false; obj.Tx=[];
            assert(~isempty(obj.Raw),'请先导入波形。');
            inputFs=obj.UI.fs.Value*1e6;
            assert(isfinite(inputFs) && abs(inputFs-9e9)<=1, ...
                '上位机不进行重采样；请先在MATLAB中将波形重采样到9 GS/s后再导入。');
            first=obj.UI.first.Value; n=obj.UI.count.Value; mask=obj.readChannelMask(obj.UI.dacButtons);
            validateattributes(first,{'numeric'},{'scalar','integer','positive'});
            validateattributes(n,{'numeric'},{'scalar','integer','>=',4,'<=',65536});
            assert(mask~=0,'请至少选择一个DAC通道。');
            assert(mod(n,32)==0 && first+n-1<=size(obj.Raw,1), ...
                '播放区间点数必须是32的倍数，且不能超出导入数据。');
            assert(isreal(obj.Raw),'当前9 GS/s直连DAC模式要求实数波形；复数IQ请先在MATLAB中转换为实数波形。');
            selected=find(bitget(uint8(mask),1:8));
            source=obj.Raw(first:first+n-1,:);
            assert(size(source,2)==1 || size(source,2)==numel(selected), ...
                '波形列数应为1（复制到所有已选DAC）或与已选DAC通道数相同（按按钮顺序对应）。');
            wave=zeros(n,8);
            if size(source,2)==1
                wave(:,selected)=repmat(source,1,numel(selected));
            else
                wave(:,selected)=source;
            end
            if strcmp(obj.UI.units.Value,'codes')
                assert(all(wave(:)>=-32768 & wave(:)<=32767), ...
                    '16 bit码值必须在[-32768,32767]内。');
                wave=wave/32768;
            end
            enabled=logical(bitget(uint8(mask),1:8)); wave(:,~enabled)=0;
            if obj.UI.normalize.Value
                peak=max(abs(wave(:))); if peak>0, wave=wave*(obj.UI.amplitude.Value/peak); end
            end
            assert(all(abs(wave(:))<=1),'实数波形超过[-1,1]，请开启归一化或修正源数据。');
            assert(all(abs(wave(:))<=1),'实数波形超过[-1,1]，请开启归一化或降低幅度。');
            obj.Tx=struct('iq',wave,'Fs',9e9,'ncoHz',0, ...
                'channelMask',mask,'metadata',struct('synthetic',false,'ducEnabled',false, ...
                'sampleFormat','real-int16','inputFs',inputFs,'inputSamples',n, ...
                'outputSamples',n,'centerHz',0));
            obj.UI.selection.Text=sprintf('DAC 9 GS/s直接发送 · %d点/通道 · %s', ...
                n,obj.channelNames(mask,'DAC'));
            obj.updateControls;
        end
        function loadCapture(obj,path)
            [~,~,ext]=fileparts(path);
            if strcmpi(ext,'.mat')
                data=load(path);
                if isfield(data,'metadata') && isfield(data.metadata,'format') && ...
                        strcmp(data.metadata.format,'47dr-raw-adc-v1')
                    assert(isfield(data,'iq') && isfield(data,'Fs') && isfield(data,'channelMask'), ...
                        '原始ADC MAT缺少数据、采样率或通道掩码。');
                    validateattributes(data.iq,{'numeric'},{'2d'});
                    validateattributes(data.Fs,{'numeric'},{'scalar','finite','positive'});
                    validateattributes(data.channelMask,{'numeric'},{'scalar','integer','>=',1,'<=',255});
                    assert(size(data.iq,2)==8 && data.Fs==5e9,'原始ADC MAT格式或采样率不匹配。');
                    selected=bitget(uint8(data.channelMask),1:8)>0;
                    assert(all(isfinite(data.iq(:,selected)),'all') && ...
                        all(isnan(data.iq(:,~selected)),'all'),'原始ADC MAT通道内容与掩码不匹配。');
                    obj.Rx=data;
                    obj.LastCapture=path; obj.UI.view.Value='rx'; obj.UI.offset.Value=1;
                    obj.render; obj.updateControls; obj.log(['原始ADC数据已载入：' path]);
                    return
                end
                assert(isfield(data,'iq') && isfield(data,'Fs') && isfield(data,'status') && isfield(data,'beatCounter'), ...
                    '请选择awg_import_ila/上位机保存的接收MAT。');
                % Recheck continuity and status when loading an existing MAT.
                assert(isfield(data,'channelMask') && isfield(data,'ncoHz'),'接收MAT缺少通道/频率信息。');
                validateattributes(data.channelMask,{'numeric'},{'scalar','integer','>=',1,'<=',255});
                assert(size(data.iq,2)==8 && size(data.iq,1)==4*numel(data.status),'接收MAT长度错误。');
                assert(numel(data.status)>=2 && numel(data.beatCounter)==numel(data.status),'接收MAT状态长度错误。');
                assert(all(mod(diff(double(data.beatCounter)),2^32)==1),'接收MAT拍计数不连续。');
                assert(isa(data.status,'uint64'),'接收状态须为uint64。');
                valid=uint64(0);
                for ch=1:8, if bitget(uint8(data.channelMask),ch), valid=bitor(valid,bitshift(uint64(3),2*(ch-1))); end, end
                assert(all(bitand(data.status,valid)==valid) && all(bitget(data.status,43)) && ...
                    all(bitand(bitshift(data.status,-32),uint64(255))==0),'接收MAT包含无效采集状态。');
                validateattributes(data.iq,{'double'},{'finite','2d'});
                validateattributes(data.Fs,{'numeric'},{'scalar','finite','positive'});
                validateattributes(data.ncoHz,{'numeric'},{'scalar','finite'});
                if isfield(data,'metadata') && isfield(data.metadata,'capture_beats')
                    assert(numel(data.status)==data.metadata.capture_beats,'接收MAT为不完整捕获。');
                end
                if ~isfield(data,'metadata'), data.metadata=struct; end
                obj.Rx=data;
            else
                sidecar=[path(1:end-4) '.json'];
                if isfile(sidecar)
                    meta=jsondecode(fileread(sidecar));
                else
                    meta=struct;
                end
                if isfield(meta,'format') && strcmp(meta.format,'47dr-raw-adc-v1')
                    raw=readmatrix(path); mask=double(meta.channel_mask);
                    validateattributes(raw,{'numeric'},{'2d','finite'});
                    validateattributes(meta.samples,{'numeric'},{'scalar','integer','positive'});
                    validateattributes(mask,{'numeric'},{'scalar','integer','>=',1,'<=',255});
                    ch=find(bitget(uint8(mask),1:8));
                    assert(size(raw,1)==meta.samples && size(raw,2)==numel(ch) && meta.fs_hz==5e9, ...
                        '原始ADC CSV行数、列数或采样率与元数据不符。');
                    iq=nan(size(raw,1),8); iq(:,ch)=raw;
                    obj.Rx=struct('iq',iq,'Fs',double(meta.fs_hz),'ncoHz',0, ...
                        'channelMask',mask,'metadata',meta);
                else
                    obj.Rx=awg_import_ila(path);
                end
            end
            obj.LastCapture=path; obj.UI.view.Value='rx'; obj.UI.offset.Value=1;
            obj.render; obj.updateControls;
            obj.log(['接收数据已载入：' path]);
        end
        function saveCapture(obj,path)
            assert(~isempty(obj.Rx),'尚无接收数据。');
            rx=obj.Rx; save(path,'-struct','rx','-v7');
            obj.log(['已保存接收MAT：' path]);
        end
        function connect(obj,entryScript)
            assert(~obj.Busy && ~obj.Connected,'当前正在执行任务或已经连接。');
            obj.LastError='';
            cfg=obj.settings;
            obj.Busy=true; obj.updateControls; obj.log('启动后台Vivado并连接JTAG，请稍候…');
            if nargin<2, obj.Bridge.start(cfg); else, obj.Bridge.start(cfg,entryScript); end
        end
        function connectUART(obj)
            assert(isempty(obj.UartSocket),'UART日志已经连接。');
            host=strtrim(obj.UI.cfg_uart_host.Value);
            port=obj.UI.cfg_uart_port.Value;
            validateattributes(port,{'numeric'},{'scalar','integer','>=',1,'<=',65535});
            socket=java.net.Socket;
            socket.connect(java.net.InetSocketAddress(host,int32(port)),int32(3000));
            socket.setTcpNoDelay(true);
            obj.UartSocket=socket; obj.UartInput=socket.getInputStream(); obj.UartBuffer=uint8([]);
            obj.log(sprintf('UART日志TCP已连接：%s:%d（只读）',host,port));
            obj.updateControls;
        end
        function disconnectUART(obj)
            obj.closeUART;
            obj.log('UART日志TCP已断开。'); obj.updateControls;
        end
        function consumeUARTBytes(obj,bytes)
            bytes=uint8(bytes(:).');
            if isempty(bytes), return; end
            obj.UartBuffer=[obj.UartBuffer bytes];
            newlinePositions=find(obj.UartBuffer==10);
            if isempty(newlinePositions)
                if numel(obj.UartBuffer)>16384
                    obj.UartBuffer=obj.UartBuffer(end-4095:end);
                    obj.log('UART单行超过16 KiB，已截断前部内容。');
                end
                return
            end
            last=0;
            for k=1:numel(newlinePositions)
                stopAt=newlinePositions(k)-1;
                line=obj.UartBuffer(last+1:stopAt);
                if ~isempty(line) && line(end)==13, line(end)=[]; end
                if ~isempty(line), obj.log(['PS UART  ' native2unicode(line,'UTF-8')]); end
                last=newlinePositions(k);
            end
            obj.UartBuffer=obj.UartBuffer(last+1:end);
        end
        function initialize(obj)
            assert(~obj.Busy,'请等待当前任务结束。');
            obj.LastError='';
            if obj.Connected
                obj.AfterDisconnect='initialize'; obj.send('disconnect'); return;
            end
            cfg=obj.settings;
            assert(isfile(cfg.xsct),'XSCT路径无效，请在连接设置中修改。');
            package=fullfile(obj.Root,'hardware','dac9g_opt1');
            assert(isfile(fullfile(package,'rf_awg_scope_v1.bit')) && ...
                isfile(fullfile(package,'rf_awg_scope_v1.ltx')) && ...
                isfile(fullfile(package,'psu_init.tcl')),'9G候选硬件包不完整。');
            assert(isfile(fullfile(package,'rf_awg_init.elf')), ...
                '9G候选缺少匹配的 rf_awg_init.elf；已阻止初始化，避免误用旧版ELF。');
            assert(isfile(fullfile(package,'init_protocol.txt')), ...
                '9G硬件包缺少 init_protocol.txt；请使用包含时钟准备握手的完整初始化包。');
            obj.InitLog=fullfile(obj.Root,'app_data',['initialize_' datestr(now,'yyyymmdd_HHMMSS') '.log']);
            initArgs={fullfile(obj.Root,'scripts','program.tcl'),'-server',cfg.server};
            obj.InitProcess=AWGBridge.launch(cfg.xsct,initArgs,obj.InitLog,obj.Root);
            obj.Busy=true; obj.updateControls;
            modeText='实验室电脑本地'; if strcmp(cfg.mode,'remote'), modeText='远程实验室电脑'; end
            obj.log(['[' modeText '] 正在复位PS并准备LMK时钟，随后下载bit、执行RFDC/MTS初始化；完成后自动连接。HW server=' cfg.server]);
        end
        function send(obj,action)
            assert(obj.Connected && ~obj.Busy,'请先连接板卡并等待当前任务结束。');
            obj.LastError='';
            fields=struct;
            if any(strcmp(action,{'load','run'}))
                obj.prepareTx;
                folder=fullfile(obj.Root,'app_data','waveforms',char(java.util.UUID.randomUUID));
                awg_export_real(obj.Tx.iq,folder,obj.Tx.channelMask);
                fields.directory=folder;
                obj.log(['下载文件：' folder '（默认逐字读回校验）']);
            end
            if any(strcmp(action,{'capture','run'}))
                rxMask=obj.readChannelMask(obj.UI.adcButtons);
                assert(rxMask~=0,'请至少选择一个ADC通道。');
                fields.capture=fullfile(obj.Root,'app_data','captures',[char(java.util.UUID.randomUUID) '.csv']);
                fields.mask=rxMask; fields.trigger=obj.UI.trigger.Value;
            end
            if strcmp(action,'start'), assert(obj.Uploaded,'请先下载当前波形。'); end
            obj.Bridge.send(action,fields); obj.Busy=true; obj.updateControls;
            obj.log(['已提交：' action]);
        end
        function render(obj)
            if strcmp(obj.UI.view.Value,'tx'), data=obj.Tx; label='发射预览'; else, data=obj.Rx; label='ADC接收'; end
            if isempty(data)
                cla(obj.UI.time); cla(obj.UI.spectrum); obj.UI.facts.Text='请导入发射波形或接收记录。'; return;
            end
            channels=find(bitget(uint8(data.channelMask),1:8))-1;
            obj.UI.channel.Items=arrayfun(@(v) sprintf('CH%d',v),channels,'UniformOutput',false);
            values=arrayfun(@num2str,channels,'UniformOutput',false);
            previous=obj.UI.channel.Value;
            obj.UI.channel.ItemsData=values;
            if ~ismember(previous,values), obj.UI.channel.Value=values{1}; else, obj.UI.channel.Value=previous; end
            ch=str2double(obj.UI.channel.Value); n=size(data.iq,1);
            obj.UI.offset.Limits=[1 max(2,n-3)];
            first=min(max(1,round(obj.UI.offset.Value)),n-3); obj.UI.offset.Value=first;
            count=min(str2double(obj.UI.span.Value),n-first+1); idx=first:first+count-1;
            z=data.iq(:,ch+1); w=0.5-0.5*cos(2*pi*(0:n-1)'/(n-1));
            f=(-floor(n/2):ceil(n/2)-1)'*data.Fs/n;
            isTx=strcmp(obj.UI.view.Value,'tx');
            scale=32768; if isTx, scale=1; end
            spectrum=20*log10(max(abs(fftshift(fft(z.*w)))/sum(w)/scale,1e-15));
            t=(idx-1)/data.Fs*1e6;
            % Reused axes can retain manual zoom limits from a prior ADC view.
            % Restore autoscaling so normalized TX samples remain visible.
            obj.UI.time.XLimMode='auto'; obj.UI.time.YLimMode='auto';
            obj.UI.spectrum.XLimMode='auto'; obj.UI.spectrum.YLimMode='auto';
            plot(obj.UI.time,t,real(z(idx)),'Color',[0.05 .52 .62],'LineWidth',1);
            if isTx
                legend(obj.UI.time,{'实数 DAC 样点'},'Location','northeast');
                ylabel(obj.UI.time,'归一化 DAC 振幅');
            elseif isfield(data,'metadata') && isfield(data.metadata,'format') && ...
                    strcmp(data.metadata.format,'47dr-raw-adc-v1')
                legend(obj.UI.time,{'ADC原始实数样点'},'Location','northeast');
                ylabel(obj.UI.time,'16 bit ADC 原始数字码值');
            else
                hold(obj.UI.time,'on');
                plot(obj.UI.time,t,imag(z(idx)),'Color',[.88 .38 .12],'LineWidth',1);
                plot(obj.UI.time,t,abs(z(idx)),'Color',[.53 .37 .76],'LineWidth',1); hold(obj.UI.time,'off');
                legend(obj.UI.time,{'ADC I','ADC Q','IQ包络'},'Location','northeast','Orientation','horizontal');
                ylabel(obj.UI.time,'16 bit ADC 数字码值');
            end
            xlabel(obj.UI.time,'时间 / μs'); grid(obj.UI.time,'on');
            synthetic=isfield(data,'metadata') && isfield(data.metadata,'synthetic') && data.metadata.synthetic;
            if synthetic, label=[label ' · 模拟数据']; end
            title(obj.UI.time,sprintf('%s · CH%d',label,ch));
            shift=0; axisLabel='复基带频率 / MHz';
            if isTx
                axisLabel='实数 DAC 频率 / MHz';
            elseif ~(isfield(data,'metadata') && isfield(data.metadata,'format') && ...
                    strcmp(data.metadata.format,'47dr-raw-adc-v1')) && obj.UI.rf.Value
                shift=data.ncoHz; axisLabel='估计射频频率 / MHz（方向需实测确认）';
            elseif isfield(data,'metadata') && isfield(data.metadata,'format') && ...
                    strcmp(data.metadata.format,'47dr-raw-adc-v1')
                axisLabel='ADC输入频率 / MHz';
            end
            plot(obj.UI.spectrum,(f+shift)/1e6,spectrum,'Color',[.05 .52 .62],'LineWidth',1);
            grid(obj.UI.spectrum,'on'); xlabel(obj.UI.spectrum,axisLabel);
            if isTx, ylabel(obj.UI.spectrum,'dB / DAC 满量程');
            else, ylabel(obj.UI.spectrum,'dB / ADC 数字满量程'); end
            ylim(obj.UI.spectrum,[-140 5]);
            title(obj.UI.spectrum,'完整记录频谱 · Hann窗 · 双边FFT');
            [~,peak]=max(spectrum);
            fsText=sprintf('%.2f MS/s',data.Fs/1e6);
            if data.Fs>=1e9, fsText=sprintf('%.3f GS/s',data.Fs/1e9); end
            obj.UI.facts.Text=sprintf('%s  |  Fs %s  |  %d点/通道  |  %.3f μs  |  FFT间隔 %.3f kHz  |  峰值 %.6f MHz', ...
                label,fsText,n,n/data.Fs*1e6,data.Fs/n/1e3,f(peak)/1e6);
        end
        function tick(obj)
            if obj.Closing || ~isvalid(obj.Figure), return; end
            try
                obj.pollUART;
                if ~isempty(obj.InitProcess)
                    if ~obj.InitProcess.isAlive
                        code=obj.InitProcess.exitValue; obj.InitProcess=[]; obj.Busy=false;
                        assert(code==0,'初始化进程失败，请检查日志：%s',obj.InitLog);
                        obj.log(['初始化脚本完成：' obj.InitLog]);
                        obj.WaitReady=[]; obj.LastReadyPoll=[]; obj.connect;
                    end
                    return
                end
                [ready,response,action]=obj.Bridge.poll;
                if ready
                    obj.Busy=false;
                    obj.applyResponse(response,action);
                end
                progressPath=fullfile(obj.Bridge.Session,'progress.txt');
                if obj.Busy && isfile(progressPath)
                    try
                        p=AWGBridge.readFields(progressPath);
                        phase='写入RAM'; if strcmp(p.phase,'verify'), phase='读回校验'; end
                        if strcmp(p.phase,'capture')
                            obj.UI.footer.Text=sprintf('读取ADC RAM · %s · %s / %s 点（后台JTAG传输中）', ...
                                p.channel,p.done,p.total);
                        else
                            obj.UI.footer.Text=sprintf('%s · CH%s · %s / %s 点（后台JTAG传输中）', ...
                                phase,p.channel,p.done,p.total);
                        end
                    catch
                        % The bridge atomically replaces this advisory status file.
                        % Skip a transient Windows sharing violation and retry next tick.
                    end
                end
                if obj.Connected && ~obj.Busy && ~isempty(obj.WaitReady)
                    if isfield(obj.Status,'ps_ready') && strcmp(obj.Status.ps_ready,'1')
                        obj.WaitReady=[]; obj.log('RF初始化完成，PS ready=1，可以下载和播放。');
                    elseif toc(obj.WaitReady)>120
                        session=obj.Bridge.Session;
                        ready=obj.fieldOr(obj.Status,'ps_ready','?');
                        fault=obj.fieldOr(obj.Status,'fault','?');
                        channels=obj.fieldOr(obj.Status,'fault_channels','?');
                        stage=obj.fieldOr(obj.Status,'init_stage','?');
                        obj.WaitReady=[];
                        obj.log(sprintf('等待RF ready超时（ps_ready=%s, fault=%s, fault_channels=%s, init_stage=%s）；请查看PS串口、%s及%s。', ...
                            ready,fault,channels,stage,obj.InitLog,fullfile(session,'vivado.log')));
                    elseif toc(obj.LastReadyPoll)>2
                        obj.LastReadyPoll=tic; obj.send('status');
                    end
                end
            catch err, obj.fail(err); end
        end
        function applyResponse(obj,response,action)
            stateFields={'running','busy','ps_ready','fault','command_result','init_stage','fault_channels','length_beats','channel_mask'};
            for k=1:numel(stateFields)
                if isfield(response,stateFields{k}), obj.Status.(stateFields{k})=response.(stateFields{k}); end
            end
            if ~isfield(response,'ok') || ~strcmp(response.ok,'1')
                obj.Uploaded=false;
                if strcmp(action,'connect') || isempty(action) || isempty(obj.Bridge.Process) || ~obj.Bridge.Process.isAlive
                    obj.Connected=false; obj.Bridge.terminate;
                end
                if isfield(response,'message'), error('%s',response.message); else, error('后台响应格式错误。'); end
            end
            switch action
                case 'connect'
                    obj.Connected=true; obj.Uploaded=false;
                    if ~isempty(obj.InitLog)
                        obj.WaitReady=tic; obj.LastReadyPoll=tic;
                    end
                    obj.log('JTAG已连接，已自动关联本工程LTX并识别AWG1。');
                case {'load','run'}
                    obj.Uploaded=true;
                case 'disconnect'
                    obj.Connected=false; obj.Uploaded=false; obj.WaitReady=[];
                    obj.Bridge.terminate;
                    obj.log('JTAG连接已释放；断开连接不改变现有DAC播放。');
            end
            if isfield(response,'capture')
                obj.loadCapture(response.capture);
                obj.saveCapture([response.capture(1:end-4) '.mat']);
            end
            obj.updateControls;
            if strcmp(action,'disconnect') && strcmp(obj.AfterDisconnect,'initialize')
                obj.AfterDisconnect=''; obj.initialize;
            end
        end
        function fail(obj,err)
            obj.LastError=err.message; obj.Busy=false; obj.Uploaded=false;
            obj.log(['错误：' err.message]); obj.updateControls;
            if obj.ShowAlerts && isvalid(obj.Figure), uialert(obj.Figure,err.message,'操作未完成'); end
        end
        function delete(obj)
            obj.Closing=true;
            try, stop(obj.Timer); delete(obj.Timer); catch, end
            obj.closeUART;
            try, delete(obj.Bridge); catch, end
            AWGBridge.killProcess(obj.InitProcess);
            try, delete(obj.Figure); catch, end
        end
    end
    methods (Access=private)
        function mask=readChannelMask(~,buttons)
            mask=0;
            for ch=0:7
                if buttons{ch+1}.Value, mask=mask+2^ch; end
            end
        end
        function syncChannelButtons(obj,mask)
            validateattributes(mask,{'numeric'},{'scalar','integer','>=',1,'<=',255});
            for ch=0:7
                selected=bitget(uint8(mask),ch+1)~=0;
                obj.UI.dacButtons{ch+1}.Value=selected;
                obj.UI.adcButtons{ch+1}.Value=selected;
            end
            obj.paintChannelButtons(obj.UI.dacButtons);
            obj.paintChannelButtons(obj.UI.adcButtons);
        end
        function paintChannelButtons(~,buttons)
            selectedColor=[46 130 149]/255;
            idleColor=[233 242 244]/255;
            for k=1:numel(buttons)
                if buttons{k}.Value
                    buttons{k}.BackgroundColor=selectedColor;
                    buttons{k}.FontColor=[1 1 1];
                else
                    buttons{k}.BackgroundColor=idleColor;
                    buttons{k}.FontColor=[.18 .28 .32];
                end
            end
        end
        function names=channelNames(~,mask,prefix)
            channels=find(bitget(uint8(mask),1:8))-1;
            labels=arrayfun(@(ch) sprintf('%s%d',prefix,ch),channels,'UniformOutput',false);
            names=strjoin(labels,'、');
        end
        function dacChannelChanged(obj,ch)
            obj.UI.adcButtons{ch+1}.Value=obj.UI.dacButtons{ch+1}.Value;
            mask=obj.readChannelMask(obj.UI.dacButtons);
            if mask==0
                obj.UI.dacButtons{ch+1}.Value=true;
                obj.UI.adcButtons{ch+1}.Value=true;
                mask=2^ch;
            end
            obj.paintChannelButtons(obj.UI.dacButtons);
            obj.paintChannelButtons(obj.UI.adcButtons);
            if isempty(obj.Raw)
                obj.UI.selection.Text=sprintf('已选 %s；请选择波形或生成测试信号。',obj.channelNames(mask,'DAC'));
                obj.updateControls;
                return
            end
            obj.prepareTx;
            obj.UI.view.Value='tx'; obj.render;
        end
        function adcChannelChanged(obj,ch)
            if obj.readChannelMask(obj.UI.adcButtons)==0
                obj.UI.adcButtons{ch+1}.Value=true;
                obj.log('至少保留一个ADC采集通道。');
            end
            obj.paintChannelButtons(obj.UI.adcButtons);
            obj.updateControls;
        end
        function buildUI(obj)
            bg=[.95 .97 .98]; ink=[.12 .20 .28]; accent=[.03 .42 .51];
            obj.Figure=uifigure('Name','47DR AWG / I/Q 示波器','Position',[70 60 1440 920], ...
                'Visible','off','Color',bg,'CloseRequestFcn',@(~,~) obj.closeRequest);
            main=uigridlayout(obj.Figure,[4 1],'RowHeight',{56,'1x',128,24},'Padding',[16 10 16 8],'RowSpacing',10);
            header=uigridlayout(main,[1 3],'ColumnWidth',{300,'1x',340},'Padding',[4 0 4 0]);
            uilabel(header,'Text','47DR  /  AWG + SCOPE','FontSize',23,'FontWeight','bold','FontColor',ink);
            uilabel(header,'Text','MATLAB 波形收发与离线分析','FontSize',16,'FontColor',accent);
            obj.UI.state=uilabel(header,'Text','● 离线 · 尚未连接板卡','HorizontalAlignment','right','FontWeight','bold','FontSize',14);
            body=uigridlayout(main,[1 2],'ColumnWidth',{380,'1x'},'Padding',[0 0 0 0],'ColumnSpacing',14);
            tabs=uitabgroup(body);
            waveTab=uitab(tabs,'Title','收发操作'); parameterTab=uitab(tabs,'Title','发射参数'); configTab=uitab(tabs,'Title','连接设置');
            left=uigridlayout(waveTab,[16 2],'ColumnWidth',{'1x','1x'}, ...
                'RowHeight',{32,42,42,26,58,36,36,36,36,26,58,32,36,34,48,'1x'}, ...
                'Padding',[12 10 12 10],'RowSpacing',7,'Scrollable','on');
            obj.UI.import=uibutton(left,'Text','导入发射 MAT / CSV','ButtonPushedFcn',@(~,~) obj.guard(@() obj.chooseWave));
            obj.UI.demoTx=uibutton(left,'Text','生成单路测试波形','ButtonPushedFcn',@(~,~) obj.guard(@() obj.demoTx));
            obj.UI.openRx=uibutton(left,'Text','导入接收 CSV / MAT','ButtonPushedFcn',@(~,~) obj.guard(@() obj.chooseCapture));
            obj.UI.demoRx=uibutton(left,'Text','离线接收演示','ButtonPushedFcn',@(~,~) obj.guard(@() obj.demoRx));
            obj.UI.source=uilabel(left,'Text','尚未导入发射数据','WordWrap','on','FontColor',ink); obj.span(obj.UI.source,3);
            l=uilabel(left,'Text','发射 · 通道选择','FontWeight','bold'); obj.span(l,4);
            txChannels=uigridlayout(left,[2 4],'ColumnWidth',{'1x','1x','1x','1x'}, ...
                'RowHeight',{24,24},'Padding',[0 0 0 0],'ColumnSpacing',4,'RowSpacing',4);
            txChannels.Layout.Row=5; txChannels.Layout.Column=[1 2];
            obj.UI.dacButtons=cell(1,8);
            for ch=0:7
                channel=ch;
                button=uibutton(txChannels,'state','Text',sprintf('DAC%d',channel),'Value',channel==0, ...
                    'FontWeight','bold','Tooltip',sprintf('选择DAC%d输出；选中时自动选择ADC%d',channel,channel), ...
                    'ValueChangedFcn',@(~,~) obj.guard(@() obj.dacChannelChanged(channel)));
                button.Layout.Row=floor(channel/4)+1; button.Layout.Column=mod(channel,4)+1;
                obj.UI.dacButtons{channel+1}=button;
            end
            obj.paintChannelButtons(obj.UI.dacButtons);
            obj.UI.selection=uilabel(left,'Text','选择DAC通道后导入波形或生成测试信号','WordWrap','on'); obj.span(obj.UI.selection,6);
            params=uigridlayout(parameterTab,[10 2],'ColumnWidth',{'1x','1x'}, ...
                'RowHeight',{34,34,34,34,34,34,60,64,54,'1x'},'Padding',[12 16 12 10],'RowSpacing',12);
            uilabel(params,'Text','源采样率 / MS/s（必须9000）'); obj.UI.fs=uieditfield(params,'numeric','Value',9000,'Limits',[eps 9000],'ValueDisplayFormat','%.3f');
            uilabel(params,'Text','源数据单位'); obj.UI.units=uidropdown(params,'Items',{'归一化实数','16 bit 码值'},'ItemsData',{'normalized','codes'});
            uilabel(params,'Text','源起始样点（从1计）'); obj.UI.first=uieditfield(params,'numeric','Value',1,'Limits',[1 Inf],'RoundFractionalValues','on');
            uilabel(params,'Text','源播放点数（32的倍数）'); obj.UI.count=uieditfield(params,'numeric','Value',1024,'Limits',[1 65536],'RoundFractionalValues','on');
            obj.UI.normalize=uicheckbox(params,'Text','归一化到实数峰值','Value',true);
            obj.UI.amplitude=uieditfield(params,'numeric','Value',0.25,'Limits',[0.001 1]);
            l=uilabel(params,'Text','上位机不重采样：请先在MATLAB中重采样到9 GS/s，再导入实数波形；不做上变频。','WordWrap','on'); obj.span(l,7);
            l=uilabel(params,'Text','MAT：N×C实数矩阵，每列一个DAC通道；CSV/TXT：每列一个实数通道。文件含Fs时自动读取，否则按界面采样率。','WordWrap','on'); obj.span(l,8);
            l=uilabel(params,'Text','每路DAC RAM上限65536个9 GS/s实数样点（128 KiB）；播放区间点数必须为32的倍数，不截尾、不补零。','WordWrap','on'); obj.span(l,9);
            obj.UI.download=uibutton(left,'Text','下载（停播并校验）','ButtonPushedFcn',@(~,~) obj.guard(@() obj.send('load')));
            obj.UI.download.Layout.Row=7;
            obj.UI.run=uibutton(left,'Text','一键下载并采集','BackgroundColor',accent,'FontColor',[1 1 1], ...
                'ButtonPushedFcn',@(~,~) obj.guard(@() obj.send('run')));
            obj.UI.run.Layout.Row=7;
            obj.UI.start=uibutton(left,'Text','▶ 开始循环播放','ButtonPushedFcn',@(~,~) obj.guard(@() obj.send('start')));
            obj.UI.start.Layout.Row=8;
            obj.UI.stop=uibutton(left,'Text','■ 停止播放','ButtonPushedFcn',@(~,~) obj.guard(@() obj.send('stop')));
            obj.UI.stop.Layout.Row=8;
            obj.UI.clear=uibutton(left,'Text','清除DAC故障','ButtonPushedFcn',@(~,~) obj.guard(@() obj.send('clear')));
            obj.UI.clear.Layout.Row=9;
            obj.UI.refresh=uibutton(left,'Text','刷新板卡状态','ButtonPushedFcn',@(~,~) obj.guard(@() obj.send('status')));
            obj.UI.refresh.Layout.Row=9;
            l=uilabel(left,'Text','ADC捕获 · 5 GS/s 原始实数样点 RAM · 通道选择','FontWeight','bold'); obj.span(l,10);
            rxChannels=uigridlayout(left,[2 4],'ColumnWidth',{'1x','1x','1x','1x'}, ...
                'RowHeight',{24,24},'Padding',[0 0 0 0],'ColumnSpacing',4,'RowSpacing',4);
            rxChannels.Layout.Row=11; rxChannels.Layout.Column=[1 2];
            obj.UI.adcButtons=cell(1,8);
            for ch=0:7
                channel=ch;
                button=uibutton(rxChannels,'state','Text',sprintf('ADC%d',channel),'Value',channel==0, ...
                    'FontWeight','bold','Tooltip',sprintf('选择ADC%d采集；对应DAC%d选中时会自动勾选',channel,channel), ...
                    'ValueChangedFcn',@(~,~) obj.guard(@() obj.adcChannelChanged(channel)));
                button.Layout.Row=floor(channel/4)+1; button.Layout.Column=mod(channel,4)+1;
                obj.UI.adcButtons{channel+1}=button;
            end
            obj.paintChannelButtons(obj.UI.adcButtons);
            uilabel(left,'Text','捕获触发方式'); obj.UI.trigger=uidropdown(left,'Items',{'播放中手动触发','重新启动播放时触发'},'ItemsData',{'manual','start'});
            obj.UI.trigger.Layout.Row=12;
            obj.UI.capture=uibutton(left,'Text','采集并显示','BackgroundColor',accent,'FontColor',[1 1 1], ...
                'ButtonPushedFcn',@(~,~) obj.guard(@() obj.send('capture')));
            obj.UI.capture.Layout.Row=13;
            obj.UI.save=uibutton(left,'Text','保存接收 MAT','ButtonPushedFcn',@(~,~) obj.guard(@() obj.chooseSave));
            obj.UI.save.Layout.Row=13;
            obj.UI.workspace=uibutton(left,'Text','接收数据送入工作区','ButtonPushedFcn',@(~,~) obj.guard(@() obj.toWorkspace)); obj.span(obj.UI.workspace,14);
            l=uilabel(left,'Text','DAC通道勾选后会自动勾选同编号ADC；ADC通道也可独立调整。ADC每个已选通道当前固定采集65520点。','WordWrap','on','FontColor',[.4 .45 .5]); obj.span(l,15);
            settings=uigridlayout(configTab,[20 2],'ColumnWidth',{125,'1x'}, ...
                'RowHeight',{34,30,50,30,50,30,30,30,30,30,30,30,38,38,38,38,50,40,34,34},'Scrollable','on','Padding',[12 10 12 10]);
            obj.UI.cfg_mode_label=uilabel(settings,'Text','运行模式');
            obj.UI.cfg_mode=uidropdown(settings,'Items',{'实验室电脑本地','远程控制实验室电脑'}, ...
                'ItemsData',{'local','remote'},'Value','local', ...
                'ValueChangedFcn',@(~,~) obj.guard(@() obj.modeChanged));
            obj.UI.cfg_mode_label.Layout.Row=1; obj.UI.cfg_mode_label.Layout.Column=1;
            obj.UI.cfg_mode.Layout.Row=1; obj.UI.cfg_mode.Layout.Column=2;
            uilabel(settings,'Text','Vivado路径'); obj.UI.browseVivado=uibutton(settings,'Text','选择 vivado.bat','ButtonPushedFcn',@(~,~) obj.browseTool('vivado'));
            obj.UI.cfg_vivado=uieditfield(settings,'Value','E:\AMDDesignTools\2025.2\Vivado\bin\vivado.bat'); obj.span(obj.UI.cfg_vivado,3);
            uilabel(settings,'Text','XSCT路径'); obj.UI.browseXsct=uibutton(settings,'Text','选择 xsct.bat','ButtonPushedFcn',@(~,~) obj.browseTool('xsct'));
            obj.UI.cfg_xsct=uieditfield(settings,'Value','E:\AMDDesignTools\2025.2\Vitis\bin\xsct.bat'); obj.span(obj.UI.cfg_xsct,5);
            for entry={'server','target','device','axi'}
                name=entry{1}; text=struct('server','HW server','target','JTAG目标','device','器件名称','axi','AXI名称');
                uilabel(settings,'Text',text.(name));
                value=''; if strcmp(name,'server'), value='localhost:3121'; end
                obj.UI.(['cfg_' name])=uieditfield(settings,'Value',value);
            end
            uilabel(settings,'Text','UART TCP主机'); obj.UI.cfg_uart_host=uieditfield(settings,'Value','localhost');
            uilabel(settings,'Text','UART TCP端口'); obj.UI.cfg_uart_port=uieditfield(settings,'numeric','Value',5001,'Limits',[1 65535],'RoundFractionalValues','on');
            obj.UI.uartConnect=uibutton(settings,'Text','连接 UART 日志','ButtonPushedFcn',@(~,~) obj.guardUART(@() obj.connectUART));
            obj.UI.uartDisconnect=uibutton(settings,'Text','断开 UART 日志','ButtonPushedFcn',@(~,~) obj.disconnectUART); 
            obj.UI.saveSettings=uibutton(settings,'Text','保存连接设置','ButtonPushedFcn',@(~,~) obj.guard(@() obj.settings)); obj.span(obj.UI.saveSettings,13);
            obj.UI.initialize=uibutton(settings,'Text','① 初始化板卡（复位 / bit / ELF）','ButtonPushedFcn',@(~,~) obj.guard(@() obj.initialize)); obj.span(obj.UI.initialize,14);
            obj.UI.connect=uibutton(settings,'Text','② 连接已初始化板卡','ButtonPushedFcn',@(~,~) obj.guard(@() obj.connect)); obj.span(obj.UI.connect,15);
            obj.UI.disconnect=uibutton(settings,'Text','释放JTAG连接（不会停止DAC）','ButtonPushedFcn',@(~,~) obj.guard(@() obj.send('disconnect'))); obj.span(obj.UI.disconnect,16);
            l=uilabel(settings,'Text','UART TCP仅接收PS串口输出；实验室电脑需先启动 scripts\\Start_UART_Bridge.cmd，并允许指定端口通过受控网络访问。','WordWrap','on'); obj.span(l,17);
            l=uilabel(settings,'Text','单板可将目标/器件/AXI留空。初始化后自动连接并等待RF ready；串口日志和JTAG是两条独立连接。','WordWrap','on'); obj.span(l,18);
            plots=uigridlayout(body,[4 1],'RowHeight',{38,44,'1x','1x'},'Padding',[8 4 8 4],'RowSpacing',8,'BackgroundColor',[1 1 1]);
            controls=uigridlayout(plots,[1 6],'ColumnWidth',{125,85,90,80,'1x',170},'Padding',[0 0 0 0]);
            obj.UI.view=uidropdown(controls,'Items',{'发射预览','ADC接收'},'ItemsData',{'tx','rx'},'ValueChangedFcn',@(~,~) obj.guard(@() obj.render));
            obj.UI.channel=uidropdown(controls,'Items',{'CH0'},'ItemsData',{'0'},'ValueChangedFcn',@(~,~) obj.guard(@() obj.render));
            obj.UI.span=uidropdown(controls,'Items',{'256','1024','4096','16384','32768'},'Value','1024','ValueChangedFcn',@(~,~) obj.guard(@() obj.render));
            uilabel(controls,'Text','窗口位置');
            obj.UI.offset=uislider(controls,'Limits',[1 2],'Value',1,'MajorTicks',[],'MinorTicks',[], 'ValueChangedFcn',@(~,~) obj.guard(@() obj.render));
            obj.UI.rf=uicheckbox(controls,'Text','射频频轴（估计）','ValueChangedFcn',@(~,~) obj.guard(@() obj.render));
            obj.UI.facts=uilabel(plots,'Text','请导入发射波形或点击离线接收演示。','WordWrap','on','FontColor',accent);
            obj.UI.time=uiaxes(plots); obj.UI.spectrum=uiaxes(plots);
            for ax=[obj.UI.time,obj.UI.spectrum], ax.Box='on'; ax.FontSize=12; ax.Color=[.99 .995 1]; end
            obj.UI.log=uitextarea(main,'Editable','off','FontName','Consolas','FontSize',11,'BackgroundColor',[.1 .16 .21],'FontColor',[.79 .89 .93]);
            obj.UI.footer=uilabel(main,'Text','DAC 9 GS/s · No DUC · 实数样点 · ADC 5 GS/s ILA视图', ...
                'FontColor',[.35 .4 .45]);
            for key={'fs','units','first','count','normalize','amplitude'}
                obj.UI.(key{1}).ValueChangedFcn=@(~,~) obj.guard(@() obj.changeWave);
            end
        end
        function changeWave(obj)
            obj.prepareTx; obj.UI.view.Value='tx'; obj.render;
        end
        function chooseWave(obj)
            [name,folder]=uigetfile({'*.mat;*.csv;*.txt','MATLAB / I-Q CSV (*.mat,*.csv,*.txt)'},'导入发射波形');
            if isequal(name,0), return; end
            obj.importWave(fullfile(folder,name));
        end
        function chooseCapture(obj)
            [name,folder]=uigetfile({'*.csv;*.mat','接收记录 (*.csv,*.mat)'},'导入接收记录',fullfile(obj.Root,'app_data','captures'));
            if ~isequal(name,0), obj.loadCapture(fullfile(folder,name)); end
        end
        function chooseSave(obj)
            [name,folder]=uiputfile('*.mat','保存接收数据',fullfile(obj.Root,'app_data','captures','capture.mat'));
            if ~isequal(name,0), obj.saveCapture(fullfile(folder,name)); end
        end
        function toWorkspace(obj)
            assert(~isempty(obj.Rx),'尚无接收数据。'); assignin('base','rx',obj.Rx);
            obj.log('接收数据已写入MATLAB工作区变量 rx；rx.iq(:,1)对应CH0。');
        end
        function cfg=settings(obj)
            cfg=struct;
            cfg.mode=strtrim(obj.UI.cfg_mode.Value);
            for name={'vivado','xsct','server','target','device','axi'}, cfg.(name{1})=strtrim(obj.UI.(['cfg_' name{1}]).Value); end
            cfg.uart_host=strtrim(obj.UI.cfg_uart_host.Value); cfg.uart_port=obj.UI.cfg_uart_port.Value;
            assert(any(strcmp(cfg.mode,{'local','remote'})),'运行模式必须是 local 或 remote。');
            assert(~isempty(cfg.server),'HW server不能为空。');
            assert(~isempty(cfg.uart_host),'UART TCP主机不能为空。');
            if strcmp(cfg.mode,'remote')
                assert(~startsWith(lower(cfg.server),'localhost') && ~startsWith(lower(cfg.server),'127.0.0.1'), ...
                    '远程模式的 HW server 不能填写 localhost；请输入实验室电脑地址，例如 100.x.x.x:3121。');
            else
                assert(startsWith(lower(cfg.server),'localhost') || startsWith(lower(cfg.server),'127.0.0.1'), ...
                    '本地模式应连接本机 HW server（通常为 localhost:3121）。');
            end
            f=fopen(fullfile(obj.Root,'app_data','settings.json'),'wt'); assert(f>=0,'无法保存设置。');
            cleanup=onCleanup(@() fclose(f)); fprintf(f,'%s',jsonencode(cfg));
        end
        function browseTool(obj,name)
            [file,folder]=uigetfile('*.bat',['选择 ' name '.bat']);
            if ~isequal(file,0), obj.UI.(['cfg_' name]).Value=fullfile(folder,file); end
        end
        function modeChanged(obj)
            mode=obj.UI.cfg_mode.Value;
            server=strtrim(obj.UI.cfg_server.Value);
            if strcmp(mode,'local')
                if isempty(server) || strcmpi(server,'lab-host:3121') || startsWith(lower(server),'100.')
                    obj.UI.cfg_server.Value='localhost:3121';
                end
                uartHost=strtrim(obj.UI.cfg_uart_host.Value);
                if isempty(uartHost) || strcmpi(uartHost,'lab-host') || startsWith(uartHost,'100.')
                    obj.UI.cfg_uart_host.Value='localhost';
                end
                obj.log('连接模式：实验室电脑本地。MATLAB/Vivado 与开发板在同一台实验室电脑，HW server=localhost:3121。');
            else
                if isempty(server) || startsWith(lower(server),'localhost') || startsWith(lower(server),'127.')
                    obj.UI.cfg_server.Value='lab-host:3121';
                end
                uartHost=strtrim(obj.UI.cfg_uart_host.Value);
                if isempty(uartHost) || strcmpi(uartHost,'localhost') || startsWith(uartHost,'127.')
                    address=obj.UI.cfg_server.Value; colon=find(address==':',1,'last');
                    if ~isempty(colon), address=address(1:colon-1); end
                    obj.UI.cfg_uart_host.Value=address;
                end
                obj.log('连接模式：远程控制实验室电脑。请将 HW server 改为实验室电脑地址，例如 100.x.x.x:3121。');
            end
        end
        function updateControls(obj)
            if isempty(obj.Figure) || ~isvalid(obj.Figure), return; end
            obj.UI.connect.Enable=obj.on(~obj.Busy && ~obj.Connected);
            obj.UI.initialize.Enable=obj.on(~obj.Busy);
            obj.UI.disconnect.Enable=obj.on(~obj.Busy && obj.Connected);
            ready=isfield(obj.Status,'ps_ready') && strcmp(obj.Status.ps_ready,'1');
            running=isfield(obj.Status,'running') && strcmp(obj.Status.running,'1');
            fault=isfield(obj.Status,'fault') && strcmp(obj.Status.fault,'1');
            for key={'download','run'}, obj.UI.(key{1}).Enable=obj.on(obj.Connected && ready && ~obj.Busy && ~isempty(obj.Tx)); end
            obj.UI.start.Enable=obj.on(obj.Connected && ready && ~obj.Busy && obj.Uploaded && ~running && ~fault);
            obj.UI.stop.Enable=obj.on(obj.Connected && ready && ~obj.Busy);
            obj.UI.clear.Enable=obj.on(obj.Connected && ready && ~obj.Busy && ~running);
            obj.UI.capture.Enable=obj.on(obj.Connected && ready && ~obj.Busy);
            obj.UI.refresh.Enable=obj.on(obj.Connected && ~obj.Busy);
            obj.UI.save.Enable=obj.on(~isempty(obj.Rx) && ~obj.Busy);
            obj.UI.workspace.Enable=obj.UI.save.Enable;
            for key={'import','demoTx','openRx','demoRx','fs','units','first','count','normalize','amplitude','trigger','browseVivado','browseXsct','saveSettings'}
                obj.UI.(key{1}).Enable=obj.on(~obj.Busy);
            end
            for k=1:8
                obj.UI.dacButtons{k}.Enable=obj.on(~obj.Busy);
                obj.UI.adcButtons{k}.Enable=obj.on(~obj.Busy);
            end
            for key={'vivado','xsct','server','target','device','axi'}, obj.UI.(['cfg_' key{1}]).Editable=obj.on(~obj.Busy && ~obj.Connected); end
            obj.UI.cfg_uart_host.Editable=obj.on(isempty(obj.UartSocket)); obj.UI.cfg_uart_port.Editable=obj.on(isempty(obj.UartSocket));
            obj.UI.uartConnect.Enable=obj.on(isempty(obj.UartSocket)); obj.UI.uartDisconnect.Enable=obj.on(~isempty(obj.UartSocket));
            obj.UI.cfg_mode.Enable=obj.on(~obj.Busy && ~obj.Connected);
            if obj.Busy
                obj.UI.state.Text='● 正在执行任务 · 界面可继续查看波形'; obj.UI.state.FontColor=[.67 .37 .06];
            elseif obj.Connected
                obj.UI.state.Text=sprintf('● 已连接 · ready=%d · 播放=%d · 故障=%d',ready,running,fault);
                obj.UI.state.FontColor=[.02 .46 .35]; if fault, obj.UI.state.FontColor=[.75 .17 .13]; end
            else
                obj.UI.state.Text='● 离线 · 尚未连接板卡'; obj.UI.state.FontColor=[.35 .4 .45];
            end
            if ~obj.Busy
                obj.UI.footer.Text='DAC 9 GS/s · ADC 5 GS/s raw · MATLAB处理 · JTAG RAM传输';
            end
        end
        function log(obj,message)
            obj.Messages{end+1}=[datestr(now,'HH:MM:SS') '  ' message];
            if numel(obj.Messages)>160, obj.Messages=obj.Messages(end-159:end); end
            if isfield(obj.UI,'log') && isvalid(obj.UI.log), obj.UI.log.Value=obj.Messages; scroll(obj.UI.log,'bottom'); end
        end
        function guard(obj,callback)
            try, callback(); catch err, obj.fail(err); end
        end
        function timerError(obj,event)
            try, obj.log(['界面轮询异常：' event.Data.Message]); catch, end
        end
        function closeRequest(obj)
            if obj.Busy
                answer=uiconfirm(obj.Figure,'后台任务尚未结束。关闭会中断JTAG操作，DAC状态需重新检查。', ...
                    '关闭上位机','Options',{'继续等待','关闭并释放连接'},'DefaultOption',1,'CancelOption',1);
                if ~strcmp(answer,'关闭并释放连接'), return; end
            elseif obj.Connected
                answer=uiconfirm(obj.Figure,'关闭上位机不会停止DAC。建议先点击“停止播放”。', ...
                    '关闭上位机','Options',{'返回界面','关闭并释放连接'},'DefaultOption',1,'CancelOption',1);
                if ~strcmp(answer,'关闭并释放连接'), return; end
            end
            delete(obj);
        end
        function pollUART(obj)
            if isempty(obj.UartSocket), return; end
            try
                if ~obj.UartSocket.isConnected || obj.UartSocket.isClosed
                    obj.closeUART; obj.log('UART TCP连接已关闭。'); obj.updateControls; return
                end
                available=obj.UartInput.available(); count=min(double(available),8192);
                if count<=0, return; end
                bytes=zeros(1,count,'uint8'); actual=0;
                for k=1:count
                    value=obj.UartInput.read(); if value<0, break; end
                    actual=actual+1; bytes(actual)=uint8(value);
                end
                if actual>0, obj.consumeUARTBytes(bytes(1:actual)); end
            catch err
                obj.closeUART;
                obj.log(['UART TCP读取失败，JTAG任务不受影响：' err.message]);
                obj.updateControls;
            end
        end
        function guardUART(obj,callback)
            try, callback(); catch err
                obj.log(['UART TCP连接失败（不影响JTAG）：' err.message]);
                obj.closeUART; obj.updateControls;
            end
        end
        function closeUART(obj)
            try, if ~isempty(obj.UartInput), obj.UartInput.close(); end, catch, end
            try, if ~isempty(obj.UartSocket), obj.UartSocket.close(); end, catch, end
            obj.UartInput=[]; obj.UartSocket=[]; obj.UartBuffer=uint8([]);
        end
    end
    methods (Static)
        function value=fieldOr(data,name,fallback)
            value=fallback;
            if isfield(data,name), value=data.(name); end
        end
        function [wave,fs,units,label]=readWave(path,variable)
            if nargin<2, variable=''; end
            fs=9e9; units='normalized'; label=path;
            [~,~,ext]=fileparts(path);
            if strcmpi(ext,'.mat')
                data=load(path); names=fieldnames(data); candidates={};
                for k=1:numel(names)
                    v=data.(names{k});
                    if isnumeric(v) && ismatrix(v) && numel(v)>=4 && (isvector(v) || size(v,2)<=8)
                        candidates{end+1}=names{k}; %#ok<AGROW>
                    end
                end
                paired=isfield(data,'I') && isfield(data,'Q') && isnumeric(data.I) && isnumeric(data.Q) && isequal(size(data.I),size(data.Q));
                if paired, candidates{end+1}='[I+jQ]'; end
                if isempty(variable)
                    if ismember('waveform',candidates), variable='waveform';
                    elseif ismember('samples',candidates), variable='samples';
                    elseif ismember('x',candidates), variable='x';
                    elseif ismember('iq',candidates), variable='iq';
                    elseif numel(candidates)==1, variable=candidates{1};
                    else
                        assert(~isempty(candidates),'MAT中没有可用的波形矩阵。');
                        [index,ok]=listdlg('ListString',candidates,'SelectionMode','single','PromptString','选择波形变量（列对应通道）');
                        assert(ok,'已取消波形导入。'); variable=candidates{index};
                    end
                end
                assert(ismember(variable,candidates),'指定变量不是可用波形。');
                if strcmp(variable,'[I+jQ]'), wave=complex(double(data.I),double(data.Q));
                else, wave=data.(variable); end
                if isinteger(wave) || (isfield(data,'I') && isa(data.I,'int16') && strcmp(variable,'iq')) || strcmp(variable,'[I+jQ]') && isinteger(data.I)
                    units='codes';
                end
                if isfield(data,'Fs'), fs=double(data.Fs);
                elseif isfield(data,'fs'), fs=double(data.fs); end
                label=[path ' :: ' variable];
            else
                assert(any(strcmpi(ext,{'.csv','.txt'})),'仅支持MAT或数值CSV/TXT。');
                raw=readmatrix(path); assert(~isempty(raw) && all(isfinite(raw(:))),'CSV须为纯数值，不得包含空值。');
                wave=raw; label=[path ' :: 实数DAC通道'];
                sidecar=[path(1:end-4) '.json'];
                if isfile(sidecar)
                    meta=jsondecode(fileread(sidecar));
                    if isfield(meta,'fs_hz'), fs=double(meta.fs_hz);
                    elseif isfield(meta,'Fs'), fs=double(meta.Fs); end
                end
            end
            validateattributes(fs,{'numeric'},{'scalar','finite','positive'});
        end
        function span(component,row)
            component.Layout.Row=row; component.Layout.Column=[1 2];
        end
        function value=on(condition)
            if condition, value='on'; else, value='off'; end
        end
    end
end

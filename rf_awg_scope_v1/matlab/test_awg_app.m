function test_awg_app
% GUI + production IPC/dispatch with all Vivado hardware APIs mocked.
% No board is opened, programmed or accessed by this test.
root=fileparts(fileparts(mfilename('fullpath'))); addpath(fullfile(root,'matlab'));
fixture=fullfile(root,'sim','matlab_fixtures');
settingsPath=fullfile(root,'app_data','settings.json'); oldSettings='';
if isfile(settingsPath), oldSettings=fileread(settingsPath); end
app=AWGScopeApp('off'); app.ShowAlerts=false;
cleanup=onCleanup(@() restoreSettings(app,settingsPath,oldSettings));
% Keep the regression independent of an imported machine-specific settings.json.
if isfile('E:\AMDDesignTools\2025.2\Vivado\bin\vivado.bat')
    app.UI.cfg_vivado.Value='E:\AMDDesignTools\2025.2\Vivado\bin\vivado.bat';
    app.UI.cfg_xsct.Value='E:\AMDDesignTools\2025.2\Vitis\bin\xsct.bat';
end
for key={'target','device','axi'}, app.UI.(['cfg_' key{1}]).Value=''; end
app.UI.cfg_mode.Value='local'; app.UI.cfg_server.Value='localhost:3121';
assert(strcmp(app.UI.start.Enable,'off') && strcmp(app.UI.capture.Enable,'off'));
app.demoTx;
assert(size(app.Tx.iq,1)==9216 && app.Tx.channelMask==1);
assert(isreal(app.Tx.iq) && max(abs(imag(app.Tx.iq(:))))==0);
assert(app.Tx.Fs==9e9 && app.Tx.metadata.ducEnabled==false);
assert(app.Tx.metadata.inputFs==9e9 && app.Tx.metadata.outputSamples==9216);
assert(app.UI.dacButtons{1}.Value && app.UI.adcButtons{1}.Value);
assert(max(abs(app.UI.dacButtons{1}.BackgroundColor-[46 130 149]/255))<1e-12 && ...
    max(abs(app.UI.adcButtons{1}.BackgroundColor-[46 130 149]/255))<1e-12, ...
    'Selected DAC/ADC buttons must use the requested teal color.');
assert(max(abs(app.UI.dacButtons{2}.BackgroundColor-[233 242 244]/255))<1e-12, ...
    'Unselected channel buttons must retain the pale idle color.');
assert(numel(app.UI.time.Children)==1,'TX preview must show one real DAC trace, not I/Q.');
assert(strcmp(app.UI.time.YLabel.String,'归一化 DAC 振幅'));
assert(strcmp(app.UI.spectrum.XLabel.String,'实数 DAC 频率 / MHz'));
% Generate through the actual button for every selectable physical DAC.
reference=app.Tx.iq(:,1);
for ch=0:7
    for k=1:8, app.UI.dacButtons{k}.Value=false; end
    app.UI.dacButtons{ch+1}.Value=true;
    feval(app.UI.dacButtons{ch+1}.ValueChangedFcn,[],[]);
    assert(app.UI.adcButtons{ch+1}.Value,'Selecting DACx must automatically select matching ADCx.');
    feval(app.UI.demoTx.ButtonPushedFcn,[],[]);
    assert(isempty(app.LastError),app.LastError);
    assert(app.Tx.channelMask==2^ch);
    assert(isequal(size(app.Tx.iq),[9216 8]) && max(abs(app.Tx.iq(:,ch+1)-reference))<1e-12);
    others=setdiff(1:8,ch+1);
    assert(all(app.Tx.iq(:,others)==0,'all'),'Test tone leaked into another DAC channel.');
    assert(strcmp(app.UI.channel.Value,num2str(ch)) && contains(app.UI.source.Text,sprintf('DAC%d',ch)));
    assert(app.Tx.Fs==9e9 && mod(size(app.Tx.iq,1),32)==0 && ~app.Uploaded);
    assert(app.UI.adcButtons{ch+1}.Value,'The paired ADC button must remain selected.');
end
for k=1:8, app.UI.dacButtons{k}.Value=false; end
app.UI.dacButtons{1}.Value=true; app.UI.dacButtons{3}.Value=true;
feval(app.UI.dacButtons{3}.ValueChangedFcn,[],[]); app.demoTx;
assert(app.Tx.channelMask==5 && app.UI.adcButtons{1}.Value && app.UI.adcButtons{3}.Value);
assert(isequal(app.Tx.iq(:,1),app.Tx.iq(:,3)),'Single test tone should fan out to each selected DAC.');
app.UI.dacButtons{1}.Value=false; feval(app.UI.dacButtons{1}.ValueChangedFcn,[],[]);
assert(~app.UI.adcButtons{1}.Value && app.UI.adcButtons{3}.Value, ...
    'Deselecting a DAC must deselect its paired ADC while keeping other lanes selected.');
app.UI.adcButtons{8}.Value=true; feval(app.UI.adcButtons{8}.ValueChangedFcn,[],[]);
assert(app.UI.adcButtons{8}.Value && app.Tx.channelMask==4, ...
    'ADC selection must be independently adjustable after DAC/ADC auto-pairing.');
% A previous ADC view or user zoom can leave manual limits that hide a
% normalized DAC waveform even though its spectrum is nonzero.
for k=1:8, app.UI.dacButtons{k}.Value=false; end
app.UI.dacButtons{5}.Value=true; app.demoTx;
app.UI.time.XLim=[0 0.16]; app.UI.time.YLim=[-3500 3500];
app.UI.spectrum.XLim=[-4000 4000]; app.UI.spectrum.YLim=[-140 5];
app.render;
assert(max(abs(app.UI.time.Children(1).YData))>0.2, ...
    'CH4 TX preview must show the generated time-domain tone after stale zoom limits.');
assert(app.UI.time.YLim(1)>-1 && app.UI.time.YLim(2)<1, ...
    'TX time axis must autoscale to normalized amplitude after render.');
drawnow; exportapp(app.Figure,fullfile(fixture,'app_test_channel_preview.png'));
app.UI.dacButtons{1}.Value=true; app.demoTx;
expectError(@() app.setWave(ones(70000,2),9e9,'normalized','long-record rejection test'));
assert(size(app.Raw,1)==70000 && app.UI.count.Value==70000 && isempty(app.Tx));
% The user can explicitly choose a valid interval after rejection.
app.UI.count.Value=4096; app.prepareTx;
assert(size(app.Tx.iq,1)==4096 && app.Tx.channelMask==17);
for count=[33 48]
    expectError(@() app.setWave(zeros(count,1),9e9,'normalized','invalid full record'));
    assert(app.UI.count.Value==count && size(app.Raw,1)==count && isempty(app.Tx));
end
% Actual MAT import and pure numeric CSV import, with known real rate and units.
Fs=9e9; t=(0:127)'/Fs; waveform=[0.1*cos(2*pi*100e6*t),0.1*sin(2*pi*100e6*t)];
path=fullfile(fixture,'app_input.mat'); save(path,'waveform','Fs');
for k=1:8, app.UI.dacButtons{k}.Value=false; end
app.UI.dacButtons{1}.Value=true; app.UI.dacButtons{2}.Value=true;
app.importWave(path);
assert(size(app.Raw,1)==128 && size(app.Tx.iq,1)==128 && app.Tx.channelMask==3);
csvPath=fullfile(fixture,'app_input.csv'); writematrix(waveform,csvPath);
[wave,fs]=AWGScopeApp.readWave(csvPath); assert(isequal(size(wave),[128 2]) && fs==9e9);
assert(max(abs(wave-waveform),[],'all')<1e-12);
app.UI.fs.Value=4000; expectError(@() app.prepareTx); assert(isempty(app.Tx));
app.UI.fs.Value=9000;
app.UI.fs.Value=562.5; app.UI.count.Value=32; expectError(@() app.prepareTx);
app.UI.fs.Value=9000; app.UI.count.Value=48; expectError(@() app.prepareTx);
app.UI.count.Value=32; app.prepareTx;
app.demoRx;
savePath=fullfile(fixture,'app_capture.mat'); app.saveCapture(savePath); app.loadCapture(savePath);
assert(isequal(size(app.Rx.iq),[16384 8]));
app.UI.channel.Value='7'; app.UI.rf.Value=true; app.render;
assert(contains(app.UI.facts.Text,'CH') || contains(app.UI.facts.Text,'Fs'));
app.UI.channel.Value='0'; app.UI.rf.Value=false; app.render;
drawnow; exportapp(app.Figure,fullfile(fixture,'app_preview.png'));
% UTF-8 and Tcl metacharacters must survive IPC as data, with no execution.
ipc=fullfile(fixture,'app_ipc.txt');
special=struct('path','E:/中文 folder/[expr 1+1]/$abc;{}.mat','empty','');
AWGBridge.writeFields(ipc,special); assert(isequal(AWGBridge.readFields(ipc),special));
% Launch real Vivado process but replace every hardware API by mocks.
app.UI.cfg_mode.Value='local'; app.UI.cfg_server.Value='localhost:3121';
app.UI.cfg_uart_host.Value='localhost'; app.UI.cfg_uart_port.Value=5001;
feval(app.UI.saveSettings.ButtonPushedFcn,[],[]);
savedCfg=jsondecode(fileread(settingsPath));
assert(strcmp(savedCfg.uart_host,'localhost') && savedCfg.uart_port==5001);
app.consumeUARTBytes(uint8([uint8('boot: RF init') 13 10 uint8('ready') 10]));
assert(any(contains(app.UI.log.Value,'PS UART  boot: RF init')) && any(contains(app.UI.log.Value,'PS UART  ready')));
app.connect(fullfile(root,'sim','mock_gui_entry.tcl'));
waitIdle(app,90); assert(app.Connected && strcmp(app.Status.ps_ready,'1'),app.LastError);
localCfg=AWGBridge.readFields(fullfile(app.Bridge.Session,'config.txt'));
assert(strcmp(localCfg.mode,'local') && strcmp(localCfg.server,'localhost:3121'));
app.send('disconnect'); waitIdle(app,15); assert(~app.Connected,app.LastError);
app.UI.cfg_mode.Value='remote'; app.UI.cfg_server.Value='192.0.2.1:3121';
app.connect(fullfile(root,'sim','mock_gui_entry.tcl'));
waitIdle(app,90); assert(app.Connected && strcmp(app.Status.ps_ready,'1'),app.LastError);
bridgeCfg=AWGBridge.readFields(fullfile(app.Bridge.Session,'config.txt'));
assert(strcmp(bridgeCfg.mode,'remote') && strcmp(bridgeCfg.server,'192.0.2.1:3121'));
% The actual parameter callback must report the alignment error and disable
% hardware actions even while connected and RF-ready.
app.UI.fs.Value=9000; app.UI.count.Value=48;
feval(app.UI.count.ValueChangedFcn,[],[]);
assert(contains(app.LastError,'32的倍数') && any(contains(app.UI.log.Value,'32的倍数')));
assert(isempty(app.Tx) && ~app.Uploaded && app.UI.count.Value==48);
assert(strcmp(app.UI.download.Enable,'off') && strcmp(app.UI.run.Enable,'off') && strcmp(app.UI.start.Enable,'off'));
app.UI.fs.Value=9000; app.UI.count.Value=32; app.prepareTx;
app.send('load'); waitIdle(app,60);
assert(app.Uploaded && strcmp(app.UI.start.Enable,'on'),app.LastError);
assert(str2double(app.Status.length_beats)==size(app.Tx.iq,1)/32, ...
    'Playback length must count 512-bit RAM words (32 samples each).');
progress=AWGBridge.readFields(fullfile(app.Bridge.Session,'progress.txt'));
assert(strcmp(progress.phase,'verify') && strcmp(progress.done,'32'));
% This path reaches Tcl and actual file I/O, not just a MATLAB roundtrip.
specialFolder=fullfile(root,'app_data','waveforms','中文 path [value] $not_command;{}');
awg_export_real(app.Tx.iq,specialFolder,1);
app.Bridge.send('load',struct('directory',specialFolder));
waitPending(app,30);
app.send('start'); waitIdle(app,15); assert(strcmp(app.Status.running,'1'),app.LastError);
for k=1:8, app.UI.adcButtons{k}.Value=false; end
app.UI.adcButtons{1}.Value=true;
app.send('capture'); waitIdle(app,30);
assert(isfile(app.LastCapture) && isfile(strrep(app.LastCapture,'.csv','.mat')),app.LastError);
assert(isequal(size(app.Rx.iq),[48 8]) && app.Rx.Fs==5e9 && app.Rx.channelMask==1);
assert(app.Rx.metadata.synthetic,'Mock capture must remain labelled synthetic.');
assert(strcmp(app.Rx.metadata.format,'47dr-raw-adc-v1'));
assert(isequal(app.Rx.iq(1:4,1),[-24;-23;-22;-21]));
assert(isnan(app.Rx.iq(1,2)),'Uncaptured ADC channels must stay unavailable.');
app.loadCapture(strrep(app.LastCapture,'.csv','.mat'));
assert(isequal(app.Rx.iq(1:4,1),[-24;-23;-22;-21]) && app.Rx.Fs==5e9);
app.send('stop'); waitIdle(app,15); assert(strcmp(app.Status.running,'0'),app.LastError);
app.send('run'); waitIdle(app,60); assert(strcmp(app.Status.running,'1') && app.Uploaded,app.LastError);
app.send('stop'); waitIdle(app,15);
% A request that fails after reaching Vivado must return an error, preserve
% actual status, and invalidate the current upload. No arbitrary Tcl is run.
app.Bridge.send('not_a_command');
waitBridgeError(app,15);
assert(~app.Uploaded && strcmp(app.UI.start.Enable,'off'));
app.send('disconnect'); waitIdle(app,15); assert(~app.Connected && isempty(app.Bridge.Process));
assert(strcmp(app.UI.start.Enable,'off'));
% Selection failures exercise the real startup error path, using fake targets.
app.UI.cfg_device.Value='missing_test_device';
app.connect(fullfile(root,'sim','mock_gui_entry.tcl'));
waitBridgeError(app,60);
assert(~app.Connected && isempty(app.Bridge.Process));
app.UI.cfg_device.Value='';
assert(isfile(fullfile(root,'hardware','dac9g_opt1','rf_awg_init.elf')), ...
    'The packaged 9G candidate must include its matching initialization ELF.');
fprintf('PASS: CH0-CH7 single-channel test generation/masks/preview/isolation, MATLAB GUI imports/plots/MAT, parameter rejection, UTF-8 IPC and backend operations (mock hardware only).\n');
end
function waitBridgeError(app,seconds)
started=tic;
while isempty(app.LastError) && toc(started)<seconds, drawnow; pause(0.1); end
assert(~isempty(app.LastError),'Expected backend error was not reported.');
end
function waitPending(app,seconds)
started=tic;
while ~isempty(app.Bridge.Pending) && toc(started)<seconds, drawnow; pause(0.1); end
assert(isempty(app.Bridge.Pending) && isempty(app.LastError),'IPC path failed: %s',app.LastError);
end
function waitIdle(app,seconds)
started=tic;
while app.Busy && toc(started)<seconds, drawnow; pause(0.1); end
assert(~app.Busy,'Application operation timed out.');
assert(isempty(app.LastError),app.LastError);
end
function expectError(callback)
failed=false; try, callback(); catch, failed=true; end
assert(failed,'Invalid parameter was accepted.');
end
function restoreSettings(app,path,text)
delete(app);
if isempty(text)
    if isfile(path), delete(path); end
else
    fid=fopen(path,'wt'); fprintf(fid,'%s',text); fclose(fid);
end
end

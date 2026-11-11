# MATLAB 发射与接收处理

> 当前9G候选发射配置为“MATLAB侧将实数波形重采样到9 GS/s → 上位机原样下载实数DAC样点”。上位机不执行重采样，不做1.5 GHz数字上变频，RFDC DUC/mixer保持旁路。MATLAB脚本仍可使用 `awg_resample_real` 与 `awg_export_real`；每路最多65536个最终实数点（128 KiB）。接收端通过上位机从候选 ADC RAM/JTAG 窗口取回5 GS/s原始实数样点，CSV/MAT及离线处理说明见 `GUI_README.md`。旧 `awg_import_ila` 仅用于读取旧 I/Q ILA记录。

推荐 MATLAB 作为数据处理入口。现已提供按钮式上位机：打开 `launch_awg_scope.m` 点击运行，或双击工程根目录的 `Start_AWG_Scope.cmd`。使用方法见 [上位机说明](GUI_README.md)。界面封装导入、初始化、下载、播放、捕获及绘图，日常使用无需复制脚本。下文保留函数接口供算法开发。

## 1. MATLAB 生成发射数据

```matlab
root=fileparts(fileparts(which('awg_resample_real')));
addpath(fullfile(root,'matlab'));
Fs=4e9; N=4096;
n=(0:N-1)';
wave=zeros(N,8);             % 每列对应一个DAC物理通道的实数波形
wave(:,1)=0.25*cos(2*pi*100e6/Fs*n);
real9g=awg_resample_real(wave,Fs,9e9);
tx=awg_export_real(real9g,fullfile(root,'waveforms','my_matlab_wave'),1);
```

将 `wave` 换成自己的实数波形即可。源采样率可以是不高于9 GS/s的值，MATLAB用周期带限插值生成9 GS/s实数样点；上位机源点数须为4的倍数，理论输出点数 `Nout = Nin * 9e9 / Fsin` 必须是整数、是32的倍数并落在32～65536点，否则报错。导入默认选择完整记录，不会自动缩短；可手动选择有效区间。RAM每字512 bit，即32个16-bit样点；RFDC端每拍256 bit，即16点。下载脚本按 `样点数/32` 配置播放字数。重采样保持精确9 GS/s时间间隔，不截尾、不补零、不改变整帧时长凑点数；循环边界需自行检查。不要把复数IQ直接送入当前单路实数DAC路径；如果需要IQ调制，应另行定义实数化/上变频方案。`awg_export_real` 量化为int16，每行HEX打包两个连续实数样点，低16位为较早样点。

掩码 `1` 只启用 CH0；`255` 启用全部 8 路。GUI中DAC0～DAC7按钮负责生成发送掩码，选择DAC通道会自动选中同编号ADC；ADC按钮仍可独立调整。测试按钮生成一路9216点、9 GS/s实数单音；用户可将其复制到已选的多个DAC通道。导入GUI的数据必须已经重采样到9 GS/s。自定义周期应自行保证首尾衔接，否则循环边界会产生额外频谱。输出目录含 `ch0.hex`～`ch7.hex`、`waveform.meta`、`waveform.mat`；MAT 保存实际量化后的发射参考，便于后续接收比较。

## 2. Vivado 下载和采集

按工程主 README 初始化板卡，关联本次 bit/ltx，等待串口 READY。在 Vivado Tcl Console 输入：

```tcl
source E:/47dr_ADDA/rf_awg_scope_v1/scripts/awg_hw.tcl
awg::attach
awg::load E:/47dr_ADDA/rf_awg_scope_v1/waveforms/my_matlab_wave
awg::start
awg::capture E:/47dr_ADDA/rf_awg_scope_v1/captures/matlab_rx.csv manual {} 1
```

最后的 `1` 是接收校验掩码；要检查全部 ADC 通道改为 `255`。接收掩码可与发送掩码不同。原始 CSV 与同名 JSON 一起保留，JSON 提供采样率、NCO、记录深度等参数。

## 3. MATLAB 接收、显示和处理

```matlab
root=fileparts(fileparts(which('awg_resample_real')));
addpath(fullfile(root,'matlab'));
rx=awg_import_ila(fullfile(root,'captures','matlab_rx.csv'), ...
                  fullfile(root,'captures','matlab_rx.mat'));
result=awg_plot(rx,0);           % 物理CH0，通道参数编号0～7
z=rx.iq(:,1);                    % ADC整数码值，以double复数保存
zNormalized=rx.iqNormalized(:,1); % z/32768，数字满量程归一化
Fs=rx.Fs;
% 后续在这里调用自己的同步、滤波、信道估计和离线解调代码。
```

`rx.I/Q` 为 `N×8 int16`；`rx.iq` 为 `N×8 double` 复数矩阵。每拍四个时间样点已按连续顺序展开。`rx.t` 是相对记录起点的秒时间轴；`rx.beatCounter` 是 uint32 原始拍计数；`rx.status` 是 uint64 状态，`rx.metadata` 保留原始 JSON。再次使用时可直接 `rx=load('matlab_rx.mat')`。

`awg_plot(rx,0,1,1024)` 显示 CH0 从第1点开始的1024点时域；FFT 使用完整记录和 Hann 窗。频谱为复基带双边频谱，幅度相对于16 bit数字满量程，不是已标定的伏特或 dBm。接收数据是 RFDC 下变频/抽取后的 I/Q，不能重建滤掉的带外成分。

导入器按字符串读取宽探针，每次最多转换16 bit，避免512 bit转double丢精度。支持 HEX、BIN、无符号十进制，负数宽探针需在 ILA 中导出为 HEX。检查连续拍计数、32 bit回绕、选中通道的 I/Q valid、PS ready、DAC fault和捕获深度；失败时拒绝返回有效记录。

## 无板卡测试

```matlab
root=fileparts(fileparts(which('awg_resample_real')));
addpath(fullfile(root,'matlab'));
test_awg_matlab
demo_rx
```

`test_awg_matlab` 是测试函数，其内部的 `root` 等变量不会出现在命令窗口工作区。`demo_rx` 会根据自身文件位置查找演示数据，不依赖工作区中的 `root`；运行后工作区保留 `rx` 和频谱结果 `result`，同时打开波形窗口。

演示 CSV 为模拟数据。测试覆盖 MATLAB/Python 发射HEX逐字一致、8路解包、不同进制精度、异常记录拒绝、MAT保存读取及绘图。用户实际调制解调算法未作假设，直接接入 `iq` 与 `rx.iq` 即可。

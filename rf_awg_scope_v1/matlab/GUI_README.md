# MATLAB 上位机

## 启动

Windows 双击工程根目录的 `Start_AWG_Scope.cmd`。启动器会先查找 PATH，再搜索常见磁盘上的 MATLAB 安装目录；如果仍找不到 MATLAB，可将其加入 PATH，或按提示编辑启动器中的查找位置。

已经打开 MATLAB 时，在“当前文件夹”浏览到本目录，打开 `launch_awg_scope.m`，点击“运行”。之后均使用界面按钮，不需要复制 MATLAB 或 Tcl 命令。

主程序为可维护的 `AWGScopeApp.m`，使用 MATLAB 的 uifigure/uiaxes。无需 App Designer、Python、Parallel Computing Toolbox 或 Instrument Control Toolbox。已在 Windows + MATLAB R2025b + Vivado 2025.2 上验证。尚未打包为独立 EXE；没有 MATLAB 的电脑暂不能直接运行。

## 第一次使用

1. 没有板卡时，点击“离线接收演示”，预览8路模拟采集的时域和频谱。页面会标注模拟数据。
2. 在“连接设置”选择运行模式并确认 Vivado 和 XSCT 路径。两种模式都由当前运行 MATLAB 的电脑启动 Vivado/XSCT；实验室电脑提供连接开发板的硬件服务。
   - “实验室电脑本地”：MATLAB 正运行在实验室电脑，HW server 使用 `localhost:3121`。
   - “远程控制实验室电脑”：MATLAB 运行在另一台电脑，HW server 填实验室电脑可达地址，例如 Tailscale IP `100.x.x.x:3121`。
   其他名称留空；多目标时按日志提示填写完整名称。
3. 连接好JTAG、串口、板卡供电和模拟回环，选择JTAG启动模式。回环应采用适当衰减，电平按实际器件指标确定。
4. 点击“初始化板卡（复位 / bit / ELF）”。此操作依次执行 PS 复位及初始化、运行匹配 ELF 配置并锁定 LMK 时钟、下载本工程 bit、恢复 ELF 执行 RFDC 配置及 ADC/DAC MTS；随后自动连接同一个 HW server 并等待 RF ready。初始化脚本每次会先清除上一次运行留下的握手标志。远程模式下 XSCT 和 Vivado 都使用设置中的实验室 HW server 地址。
5. 如果板卡已运行本工程且初始化完成，直接点击“连接已初始化板卡”。上位机会自动关联本次LTX、识别AWG1和读取状态。
6. 等待右上角 `ready=1`。若未就绪，检查PS串口、RF时钟和界面日志给出的初始化日志文件。单独重新下载bit后需要重新运行匹配的初始化程序。

请先释放其他Vivado/Vitis对同一目标的调试连接，避免JTAG占用。GUI使用独立后台Vivado实例，连接/下载可用1～3分钟或更长，后台日志保存在 `app_data/sessions`。初始化日志保存在 `app_data/initialize_*.log`。

远程模式要求实验室电脑连接开发板并运行 Xilinx `hw_server`，其 TCP 3121 端口需允许本地电脑通过 Tailscale/受控网络访问；不要将其暴露到公网。若要在 MATLAB 中查看 PS UART 文本日志：实验室电脑运行 `scripts/Start_UART_Bridge.cmd`，输入连接开发板的 COM 口，并将监听地址设为实验室电脑的 Tailscale IP；本机上位机“连接设置”中填写实验室电脑地址和 TCP 5001，再点击“连接 UART 日志”。先连 UART，再执行板卡初始化，日志区即可看到初始化输出。UART 桥只转发串口输出，不向板卡发送命令；`ps_ready` 仍由 JTAG 状态寄存器读取，UART 与 JTAG 是独立链路。本地模式使用 `localhost:5001`，仍需启动同一桥接程序。

桥接程序使用 Windows PowerShell 和 .NET 串口库，默认 115200/8N1、TCP 5001、单客户端。只允许实验室受控网络或 Tailscale 访问该端口；不要将其开放到公网。串口打开失败时，先确认 COM 号正确且没有其他终端占用。

## 导入自己的发射数据

点击“导入发射 MAT / CSV”。

| 格式 | 数据约定 |
|---|---|
| MAT | 数值变量 `waveform`、`samples`、`x` 或 `iq`，N×C实数矩阵，C=1～8；列1对应CH0。复数矩阵会被拒绝，避免无定义的IQ到单路DAC转换 |
| CSV/TXT | 每列表示一个实数DAC通道，最多8列；纯数值文件。可用同名JSON提供 `fs_hz` |

MAT中的 `Fs` 或 `fs` 字段单位为Hz。无采样率字段或CSV没有JSON时，界面默认按9 GS/s解释。上位机不执行重采样，导入数据必须已经由用户在MATLAB中重采样到9 GS/s；采样率不等于9 GS/s时会报错。不做数字上变频。

在“发射参数”可调整：

- 源数据单位：归一化实数，或16 bit码值。整型MAT和本工程导出的 `waveform.mat` 可自动识别；CSV及其他double码值需要手动选择。
- 源起始样点及播放点数：在9 GS/s数据中选择播放区间，区间点数必须是32～65536的32倍数，否则报错并禁用下载；每路RAM为128 KiB。导入默认选择完整记录，不会自动缩短，可手动选择有效区间。
- 实数峰值归一化：默认启用，缩放到0.25；取消后保留源相对数字幅度，超过范围会报错。
- DAC通道按钮：可多选DAC0～DAC7，按钮选择直接生成发送掩码。MAT/CSV每列按已选DAC按钮从小到大对应；单列波形会复制到所有已选DAC通道。选中DAC时自动勾选同编号ADC。
- ADC通道按钮：可多选ADC0～ADC7，直接决定采集掩码；DAC与ADC默认一一对应，但ADC选择可单独调整。

波形循环首尾衔接由用户控制。上位机按9 GS/s直接下载导入的实数样点，不做重采样；No-DUC RFDC不再插值、混频或设置NCO。修改源数据、通道或参数后，“开始循环播放”将禁用，需重新下载。更改显示通道、窗口和频轴不影响硬件播放。

当前发布版RAM每次读512 bit（32个16-bit样点），gearbox拆成两个256-bit RFDC拍（每拍16点）。因此播放长度寄存器按 `最终样点数/32` 设置。重采样在精确的9 GS/s时间网格上进行，理论输出点数为 `源播放点数 × 9e9 / 源Fs`，必须是32～65536之间的整数且为32的倍数。不满足时直接报错，不截尾、不补零、不通过改变整帧时长凑点数。例如48点@9 GS/s报错；128点@4 GS/s得到288点，允许下载。循环首尾衔接仍需用户保证。

## 按钮操作

测试DAC时，先点击“收发操作”中需要的DAC按钮，再点击“生成单路测试波形”。上位机生成9216点、9 GS/s的100 MHz实数单音；选中多个DAC时，同一单音会复制到各已选通道。选择DAC会自动勾选对应ADC，之后仍可单独修改ADC按钮。导入MAT/CSV时，每列对应已选DAC按钮从小到大的顺序；单列可复制到多个已选通道。导入数据和所选播放区间必须为9 GS/s且点数为32的倍数。

例如DAC CH2连接到ADC CH2，点击DAC2会自动勾选ADC2；如果实际连线是DAC CH2到ADC CH0，则在ADC按钮组中取消ADC2并勾选ADC0。发射和接收通道可以分别多选。

2026-11-10修正ADC采集状态判断：`state=2` 表示已完成（done=1、busy=0），旧上位机误将busy当done而超时。新的采集程序要求ADC RAM接口版本0x00020001；提示 `requires the updated FPGA bitstream` 时，须使用配套硬件包重新初始化。旧bit同时存在RAM地址单位错误，不能只更新上位机后继续用旧bit导出数据。修复与验证记录见 `logs/adc_capture_fix_20261110.md`。

| 按钮 | 行为 |
|---|---|
| 下载（停播并校验） | 自动导出MATLAB波形文件、停止旧播放、写RAM、逐字读回校验；成功后配置长度/掩码，保持停止 |
| 开始循环播放 | 播放已成功下载的当前波形 |
| 停止播放 | 请求停止并排空DAC数据 |
| 一键下载并采集 | 完成下载校验；手动模式先开始播放，随后采集；重启模式在采集命令后重新启动播放 |
| 采集并显示 | 触发 ADC 原始 RAM 捕获，轮询完成并通过 JTAG 读回所选通道，自动导出 CSV/JSON、保存 MAT 并刷新曲线 |
| 清除DAC故障 | 停止后清除锁存故障；恢复ready后可重新下载/启动 |
| 刷新板卡状态 | 读取ready、播放、命令和故障状态；顶栏显示最近读取的状态，不是连续采样状态监视器 |
| 保存接收MAT | 保存完整接收结构，供离线解调 |
| 接收数据送入工作区 | 将结构体写入MATLAB基础工作区变量 `rx`，`rx.iq(:,1)`是CH0 |

接收界面适配9G候选的5 GS/s raw ADC RAM格式：每个 ADC 通道显示一条有符号16-bit实数样点曲线；频谱按5 GS/s采样率计算，不应用RFDC NCO频移。每路最多65,520点，捕获通过 `0x91000000` JTAG RAM窗口读回。CSV的同名JSON记录格式、采样率、通道掩码和点数；MAT包含 `rx.iq`（N×8，未选通道为NaN）、`rx.Fs=5e9`、`rx.channelMask` 和 `rx.metadata`，可直接供MATLAB离线分析。旧版 I/Q ILA CSV/MAT仍可导入查看。初始化按钮使用 `hardware/dac9g_opt1` 中配套的 bit、LTX、PS init 脚本、`rf_awg_init.elf` 和 `init_protocol.txt`；2026-11-09 修复版已连续两次完成板上初始化，ADC/DAC MTS、AWG READY、CONFIG_DONE 和 JTAG PS ready 均通过。完整 GUI 收发及射频回环仍待验证。目标采集仍是有限长度记录，不是实时连续示波器。

raw ADC接收曲线在完成状态和捕获点数通过检查后更新；旧I/Q记录仍按拍计数、valid、PS ready、故障和记录深度校验。失败时保留原记录并在日志说明原因。图上可选择“发射预览/ADC接收”、通道、显示点数和窗口位置；FFT始终使用完整记录和Hann窗。raw ADC频谱为输入端实数频谱，不做数字下变频或NCO频移。

## 文件和连接生命周期

自动导出文件在 `app_data/waveforms`，采集原始CSV/JSON和恢复MAT在 `app_data/captures`，各次任务使用独立目录/文件名。连接设置保存在 `app_data/settings.json`。日志区给出路径；原始数据保留，不自动删除。

后台任务通过定时器轮询和原子文件交换运行；下载期间页脚显示写RAM/读回进度，界面仍可查看曲线。同一时刻只提交一个板卡任务。遇到连接错误释放本程序连接并禁用播放；下载/捕获失败时，当前下载资格作废，需要重新下载。若执行中断，必须刷新并确认硬件状态。

**释放JTAG或关闭程序不会自动停止DAC循环播放。** 先点击“停止播放”，再释放连接或关闭。关闭时会提示；强制结束进程可能中断下载，不能据此认为DAC已经停止。

## 验证情况

`test_awg_app`在真实MATLAB和真实Vivado后台进程间执行生产文件协议及任务循环，硬件API全部替换为模拟接口；覆盖导入、参数检查、绘图、MAT保存、UTF-8路径、下载读回、播放/停止、触发采集、一键流程、错误返回和目标选择失败。`sim/matlab_fixtures/app_preview.png`为真实UI导出的预览。详细日志见 `logs/matlab_app_tests.log`。

2026-11-09 已通过远程 hw_server 完成修复版硬件的连续两次完整初始化：`INIT_STAGE_FULL=99`、`CONFIG_DONE=1`、`ps_ready=1`、`fault=0`、`fault_channels=0`。对应包为 `hardware/dac9g_opt1`，最终时序 WNS 0.000 ns、TNS 0、WHS +0.008 ns、THS 0；详见 `logs/initialization_fix_20261109.md`。本次没有进行完整 GUI 收发、射频回环或断电冷启动测试；`board_tested=true` 仅表示初始化实测通过。旧 `output` 目录中的文件不适用于本候选。已有窗口请关闭后重新启动，以加载本次 MATLAB 修改。

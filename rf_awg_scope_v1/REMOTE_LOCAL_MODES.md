# 本地模式与远程模式

本工程的 MATLAB 上位机在“连接设置”中提供两种模式。两种模式使用同一个 FPGA bit、LTX、ELF、PS 初始化脚本和波形协议；区别只有 MATLAB/Vivado 连接的 HW server 地址。

## 实验室电脑本地模式

把开发板 JTAG 连接到运行 MATLAB 的实验室电脑，在该电脑启动 Xilinx `hw_server`。设置：

```text
运行模式：实验室电脑本地
HW server：localhost:3121
```

点击“初始化板卡”时，本机 XSCT 按以下顺序执行：复位 PS、执行匹配的 `psu_init.tcl`、下载 bit、运行 `rf_awg_init.elf`。初始化结束后，本机后台 Vivado 通过本机 HW server 连接 JTAG AXI/ILA。波形文件和 MATLAB 图形都在实验室电脑上。

## 远程控制实验室电脑模式

实验室电脑只负责连接开发板并运行 `hw_server`；MATLAB 上位机运行在另一台电脑。本地电脑仍需要安装与工程相容的 Vivado/Vitis，因为 MATLAB 会在本地启动 Vivado/XSCT 客户端；客户端通过网络连接实验室电脑的 HW server。

实验室电脑：

1. 连接 JTAG、板卡电源和必要的时钟/串口。
2. 启动 Xilinx `hw_server`，监听 TCP 3121。
3. 通过 Tailscale 或实验室受控网络允许本地电脑访问 TCP 3121。不要将端口暴露到公网。

本地 MATLAB 设置：

```text
运行模式：远程控制实验室电脑
HW server：<实验室电脑可达地址>:3121
```

点击“初始化板卡”时，`program.tcl` 会自动执行 `connect -url tcp:<地址>:3121`；初始化完成后，后台 Vivado 使用同一地址连接硬件。不要让本地 MATLAB 同时连接另一台 HW server，也不要让两个 Vivado/Vitis 会话同时控制同一块板卡。

## 使用顺序

1. 先确认 FPGA bit、LTX、ELF 和 `psu_init.tcl` 来自同一版本工程。
2. 先释放其他 Vivado/Vitis/JTAG 会话。
3. 在连接设置选择模式并保存；远程模式先用 `Test-NetConnection <实验室地址> -Port 3121` 检查端口。
4. 点击“初始化板卡”，等待 PS 串口出现 `AWG READY`，并等待界面显示 `ready=1`。
5. 导入或生成 MATLAB 波形，点击下载、播放和采集。采集数据通过 JTAG/ILA 返回当前 MATLAB 电脑。
6. 长记录改用板载 DDR/DMA 采集服务时，连接模式不变；只替换采集后端，ILA 继续用于短记录诊断。

## 串口日志

HW server 的 3121 端口只承载 JTAG，不承载 PS UART。若需要远程查看 UART，应在实验室电脑另起串口 TCP bridge，并使用单独端口（例如 5001）；不能把 UART 客户端连接到 3121。UART 只用于观察 `AWG READY` 和初始化错误，`ps_ready` 仍由 JTAG 状态寄存器读取。

本工程提供 `scripts/Start_UART_Bridge.cmd`。在实验室电脑启动后输入开发板对应的 COM 口，并建议把监听地址设为实验室电脑的 Tailscale IP。上位机“连接设置”填写同一 IP、TCP 5001，先点“连接 UART 日志”，再初始化板卡。实验室电脑防火墙需允许受控网络访问 TCP 5001；桥接器为只读单客户端服务，115200/8N1。若 MATLAB 也运行在实验室电脑，可填 `localhost`。串口桥不接收客户端数据，不控制复位或初始化。

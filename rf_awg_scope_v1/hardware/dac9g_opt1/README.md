# 9 GS/s DAC / 5 GS/s ADC：ADC 采集修复并完成上板验证的匹配包

2026-11-10 发布。保留八路及现有 RAM/数据格式。RFDC DAC 插值 x1、ADC 抽取 x1、mixer bypass；全四个 ADC tile 与全四个 DAC tile 的 MTS 均启用。此次版本同时修复 ADC RAM 状态解释和 JTAG 地址步长，并已在实验室板卡上完成采集验证。

## 必须成套使用

`rf_awg_scope_v1.bit`、同名 `.ltx`/`.xsa`、`rf_awg_init.elf`、`psu_init.tcl`、`init_protocol.txt`。ELF 使用完全相同 XSA 生成的 A53 standalone BSP 构建。协议文件中的地址来自最终 ELF 的符号表，不能从其他版本复制。

| 文件 | SHA256 |
|---|---|
| bit | `7b21389fed0c0d3ae71631b1f1131679c740d08284239fc2d9555d09fb3f16d6` |
| XSA | `db6318c140a7b3a296b7917b052d177eace45f6f7195db2908e59a0887f5fe1b` |
| ELF | `321dfd6d2129c4b39fc169cce36420b032e674a645e243ce6e077deca61a8b9d` |

当前发布文件的哈希以 `build_manifest.json` 为准。

全部文件的字节数及哈希见 `build_manifest.json`；XSA 内嵌 bit 与独立 bit 相同。

## 初始化流程

上位机按钮仍调用工程 `scripts/program.tcl`，本地和远程模式共用同一流程：

1. 复位并初始化 PS，下载 ELF；A53 停止时清除旧的 ready/ack 握手标志。
2. 启动 ELF，配置并锁定 LMK；PS 输出 `AWG CLOCK READY`。
3. JTAG 读到本次 `CLK1` 后暂停 A53，再下载匹配 PL，解除隔离/复位。
4. JTAG 写入并读回 `PLOK`，恢复 A53；PS 执行 RFDC 配置及 ADC/DAC MTS。
5. 全部检查成功后才置 `CONFIG_DONE=1`、`ps_ready=1` 并输出 `AWG READY`。

不要沿用先下载 PL、再运行会复位 LMK 的旧初始化顺序。LMK 的 PL_CLK 驱动 ADC MMCM；中途复位时钟源会影响其启动。

ADC fabric：LMK PL_CLK 200 MHz 经独立 MMCM 产生约 416.666667 MHz；DAC fabric：RFDC `clk_dac2` 经独立 MMCM 产生 562.5 MHz。SYSREF 分别同步到两个 fabric 域；MTS 时 LMK `0x139=0x03`，成功后 `0x139=0x02`。`0x16A` 的 SYSREF_REQ_EN 位不是 continuous/pulsed 模式选择位。

DAC RAM侧为512 bit/281.25 MHz，每字32个16-bit实数样点，gearbox分两拍送往256 bit/562.5 MHz的RFDC。当前播放器以完整RAM字为单位循环，最终记录长度须为32的倍数（32～65536点），`0x9020000C` 长度寄存器填 `最终样点数/32`（1～2048）。2026-11-10上位机/下载脚本已按此修正；没有更改本硬件包的bit/XSA/ELF。

## ADC 采集修复

ADC RAM 状态寄存器的 `state=2` 表示 `done=1,busy=0`，是成功完成，不是超时。上位机现在只在 `(state & 2) != 0` 且 `(state & 1) == 0` 时结束等待。ADC RAM 的 JTAG 地址按 32-bit word 计数，768-bit entry 对应 24 个 32-bit word；旧版按 48 个 word 读取会造成地址错位。本包的 ADC RAM ABI 为 `0x00020001`，上位机会拒绝旧 ABI。

实际板卡验证：DAC CH2 回环到 ADC CH2（掩码 `4`），捕获 `65520` 个 ADC 样点，状态为 `2`，`ps_ready=1`、`fault=0`、`fault_channels=0`。MATLAB 成功导入 CSV/MAT、显示时域和 5 GS/s 频谱，FFT 峰值约 `99.587912 MHz`，零数据比例为 `0%`。证据见工程根目录的 `logs/verify_adc_capture_fix_20261110.log`、`app_data/captures/adc_ch2_capfix_20261110.csv` 和 `hardware_validation.json`。

## 验证范围

- 最终脚本连续两次完整初始化成功（run3、run4）；两次 ADC/DAC 各四 tile MTS 成功、RAM 完整阶段 99、CONFIG_DONE=1、JTAG ps_ready=1、fault=0、fault_channels=0。
- 两次 DAC latency 均为 288；ADC latency 均为 104。各 ADC tile 的 DelayOffset 可以不同，这是本次 MTS 的补偿值，不应要求它们相等。
- 最终时序：WNS 0.000 ns、TNS 0、WHS +0.008 ns、THS 0、WPWS +0.089 ns；setup/hold/pulse-width 违例端点为 0。DRC 0 errors、13 warnings，bus-skew 审核无违例。报告随包保留，不能把 timing pass 表述为零告警。
- `board_tested=true` 的范围为初始化和 CH2 回环采集；尚未进行断电冷启动、全通道 GUI 流程和外部仪器测频。采样率来自配置和 PLL 回读。

成功日志：`app_data/init_stable_sequence_run4_20261109.log` 和 `logs/verify_9g_stable_ready_run4_console_20261109.log`。详细修复经过见 `logs/initialization_fix_20261109.md`。以上路径相对于工程根目录。

修复前默认包完整保留于 `hardware/archive_dac9g_before_init_fix_20261109`。新旧硬件包和初始化脚本需配套使用，不能仅回退单个 ELF。

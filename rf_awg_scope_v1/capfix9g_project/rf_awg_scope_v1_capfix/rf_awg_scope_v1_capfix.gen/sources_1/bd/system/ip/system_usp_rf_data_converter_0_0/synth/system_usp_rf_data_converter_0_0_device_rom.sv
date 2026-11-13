//----------------------------------------------------------------------------
// Title : ROM for tile configuration
// Project : Ultrascale+ RF Data Converter Subsystem
//----------------------------------------------------------------------------
//
// (c) Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// (c) Copyright 2022-2026 Advanced Micro Devices, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of AMD and is protected under U.S. and international copyright
// and other intellectual property laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// AMD, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND AMD HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) AMD shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or AMD had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// AMD products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of AMD products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


`timescale 1ps/1ps

module system_usp_rf_data_converter_0_0_device_rom (
    aux_clk,
    data_index,
    data_out,
    addr_out,
    tile_out
  );

    input aux_clk;

    input [10:0] data_index;

    output [15:0] data_out;
    output [10:0] addr_out;
    output [2:0]  tile_out;

    reg [29:0] data;

    // The 30-bit data in the array follows the format below:
    // 29:27 |  26:24  |    23:16    |    15:0
    // Tile  |  Slice  | DRP Address |  DRP Data

    (* rom_style = "distributed" *) reg [29:0] data_array [0:506] = '{
       30'h07230000,  // Clock Network Control 0 (ADC0)
       30'h07240008,  // Clock Network Control 1 (ADC0)
       30'h07226028,  // Clock Distribution Control (ADC0)
       30'h070c0000,  // PLL Output Divide (ADC0)
       30'h072c0025,  // CLK_DIV (ADC0)
       30'h07280280,  // SYSREF Distribution (ADC0)
       30'h072df0fe,  // HSCOM_PWR_MASK (ADC0)
       30'h07310062,  // CLOCK_DETECT_CTRL0 (ADC0)
       30'h07320032,  // CLOCK_DETECT_CTRL1 (ADC0)
       30'h07300000,  // FIFO_START (ADC0)
       30'h00020c08,  // ADC00 Data Width
       30'h00100003,  // ADC00 Decimation Config
       30'h00110001,  // ADC00 Decimation Mode
       30'h00200000,  // ADC00 Mixer Config 0
       30'h00210924,  // ADC00 Mixer Config 1
       30'h003a0020,  // ADC00 Switch Matrix Config
       30'h007101d1,  // ADC00 RX MC Config 0
       30'h00780002,  // ADC00 DSA Control
       30'h005181c3,  // ADC00 TI_DCB_CTRL0
       30'h0055d44a,  // ADC00 TI_TIME_SKEW_CTRL0
       30'h005a0001,  // ADC00 TI_TIME_SKEW_CTRL5
       30'h001d001c,  // ADC00 CAL_FREEZE_MASK
       30'h00450091,  // ADC00_SIG_DET_CTRL
       30'h00460148,  // ADC00_SIG_DET_THRESHOLD_LEVEL0
       30'h0047012c,  // ADC00_SIG_DET_THRESHOLD_LEVEL0_CNT_ON
       30'h0048012c,  // ADC00_SIG_DET_THRESHOLD_LEVEL0_CNT_OFF
       30'h0006000c,  // ADC00 FABRIC_DEBUG
       30'h01020c08,  // ADC01 Data Width
       30'h01100003,  // ADC01 Decimation Config
       30'h01110001,  // ADC01 Decimation Mode
       30'h01200000,  // ADC01 Mixer Config 0
       30'h01210924,  // ADC01 Mixer Config 1
       30'h013a0024,  // ADC01 Switch Matrix Config
       30'h017101d9,  // ADC01 RX MC Config 0
       30'h01780002,  // ADC01 DSA Control
       30'h015181c7,  // ADC01 TI_DCB_CTRL0
       30'h0155d44a,  // ADC01 TI_TIME_SKEW_CTRL0
       30'h015a0001,  // ADC01 TI_TIME_SKEW_CTRL5
       30'h011d001c,  // ADC01 CAL_FREEZE_MASK
       30'h01450091,  // ADC01_SIG_DET_CTRL
       30'h01460148,  // ADC01_SIG_DET_THRESHOLD_LEVEL0
       30'h0147012c,  // ADC01_SIG_DET_THRESHOLD_LEVEL0_CNT_ON
       30'h0148012c,  // ADC01_SIG_DET_THRESHOLD_LEVEL0_CNT_OFF
       30'h0106000c,  // ADC01 FABRIC_DEBUG
       30'h02020c08,  // ADC02 Data Width
       30'h02100003,  // ADC02 Decimation Config
       30'h02110001,  // ADC02 Decimation Mode
       30'h02200000,  // ADC02 Mixer Config 0
       30'h02210924,  // ADC02 Mixer Config 1
       30'h023a0028,  // ADC02 Switch Matrix Config
       30'h027101d1,  // ADC02 RX MC Config 0
       30'h02780002,  // ADC02 DSA Control
       30'h025181c3,  // ADC02 TI_DCB_CTRL0
       30'h0255d44a,  // ADC02 TI_TIME_SKEW_CTRL0
       30'h025a0001,  // ADC02 TI_TIME_SKEW_CTRL5
       30'h021d001c,  // ADC02 CAL_FREEZE_MASK
       30'h02450091,  // ADC02_SIG_DET_CTRL
       30'h02460148,  // ADC02_SIG_DET_THRESHOLD_LEVEL0
       30'h0247012c,  // ADC02_SIG_DET_THRESHOLD_LEVEL0_CNT_ON
       30'h0248012c,  // ADC02_SIG_DET_THRESHOLD_LEVEL0_CNT_OFF
       30'h0206000c,  // ADC02 FABRIC_DEBUG
       30'h03020c08,  // ADC03 Data Width
       30'h03100003,  // ADC03 Decimation Config
       30'h03110001,  // ADC03 Decimation Mode
       30'h03200000,  // ADC03 Mixer Config 0
       30'h03210924,  // ADC03 Mixer Config 1
       30'h033a002c,  // ADC03 Switch Matrix Config
       30'h037101d9,  // ADC03 RX MC Config 0
       30'h03780002,  // ADC03 DSA Control
       30'h035181c7,  // ADC03 TI_DCB_CTRL0
       30'h0355d44a,  // ADC03 TI_TIME_SKEW_CTRL0
       30'h035a0001,  // ADC03 TI_TIME_SKEW_CTRL5
       30'h031d001c,  // ADC03 CAL_FREEZE_MASK
       30'h03450091,  // ADC03_SIG_DET_CTRL
       30'h03460148,  // ADC03_SIG_DET_THRESHOLD_LEVEL0
       30'h0347012c,  // ADC03_SIG_DET_THRESHOLD_LEVEL0_CNT_ON
       30'h0348012c,  // ADC03_SIG_DET_THRESHOLD_LEVEL0_CNT_OFF
       30'h0306000c,  // ADC03 FABRIC_DEBUG
       30'h0f230000,  // Clock Network Control 0 (ADC1)
       30'h0f240028,  // Clock Network Control 1 (ADC1)
       30'h0f22aca0,  // Clock Distribution Control (ADC1)
       30'h0f170030,  // PLL FB Div (ADC1)
       30'h0f0c0040,  // PLL Output Divide (ADC1)
       30'h0f100010,  // PLL Ref clock divide (ADC1)
       30'h0f000080,  // PLL SDM CONFIG0 (ADC1)
       30'h0f060111,  // PLL SDM seed (ADC1)
       30'h0f070011,  // PLL SDM seed setup (ADC1)
       30'h0f0e0d37,  // PLL ChargePump setup (ADC1)
       30'h0f0f2080,  // PLL temprature sensor control (ADC1)
       30'h0f12ffff,  // PLL ChargePump setup (ADC1)
       30'h0f137f9a,  // PLL loop filter setup (ADC1)
       30'h0f140006,  // PLL loop filter setup (ADC1)
       30'h0f155800,  // PLL VCO setup (ADC1)
       30'h0f160008,  // PLL VCO setup (ADC1)
       30'h0f0a7a21,  // PLL Coarse Frequency setup (ADC1)
       30'h0f0b7008,  // PLL Coarse Frequency setup (ADC1)
       30'h0f11002d,  // PLL Voltage Regulator setup (ADC1)
       30'h0f2c0022,  // CLK_DIV (ADC1)
       30'h0f280600,  // SYSREF Distribution (ADC1)
       30'h0f2dfffc,  // HSCOM_PWR_MASK (ADC1)
       30'h0f310062,  // CLOCK_DETECT_CTRL0 (ADC1)
       30'h0f320032,  // CLOCK_DETECT_CTRL1 (ADC1)
       30'h0f300000,  // FIFO_START (ADC1)
       30'h08020c08,  // ADC10 Data Width
       30'h08100003,  // ADC10 Decimation Config
       30'h08110001,  // ADC10 Decimation Mode
       30'h08200000,  // ADC10 Mixer Config 0
       30'h08210924,  // ADC10 Mixer Config 1
       30'h083a0020,  // ADC10 Switch Matrix Config
       30'h087101d1,  // ADC10 RX MC Config 0
       30'h08780002,  // ADC10 DSA Control
       30'h085181c3,  // ADC10 TI_DCB_CTRL0
       30'h0855d44a,  // ADC10 TI_TIME_SKEW_CTRL0
       30'h085a0001,  // ADC10 TI_TIME_SKEW_CTRL5
       30'h081d001c,  // ADC10 CAL_FREEZE_MASK
       30'h08450091,  // ADC10_SIG_DET_CTRL
       30'h08460148,  // ADC10_SIG_DET_THRESHOLD_LEVEL0
       30'h0847012c,  // ADC10_SIG_DET_THRESHOLD_LEVEL0_CNT_ON
       30'h0848012c,  // ADC10_SIG_DET_THRESHOLD_LEVEL0_CNT_OFF
       30'h0806000c,  // ADC10 FABRIC_DEBUG
       30'h09020c08,  // ADC11 Data Width
       30'h09100003,  // ADC11 Decimation Config
       30'h09110001,  // ADC11 Decimation Mode
       30'h09200000,  // ADC11 Mixer Config 0
       30'h09210924,  // ADC11 Mixer Config 1
       30'h093a0024,  // ADC11 Switch Matrix Config
       30'h097101d9,  // ADC11 RX MC Config 0
       30'h09780002,  // ADC11 DSA Control
       30'h095181c7,  // ADC11 TI_DCB_CTRL0
       30'h0955d44a,  // ADC11 TI_TIME_SKEW_CTRL0
       30'h095a0001,  // ADC11 TI_TIME_SKEW_CTRL5
       30'h091d001c,  // ADC11 CAL_FREEZE_MASK
       30'h09450091,  // ADC11_SIG_DET_CTRL
       30'h09460148,  // ADC11_SIG_DET_THRESHOLD_LEVEL0
       30'h0947012c,  // ADC11_SIG_DET_THRESHOLD_LEVEL0_CNT_ON
       30'h0948012c,  // ADC11_SIG_DET_THRESHOLD_LEVEL0_CNT_OFF
       30'h0906000c,  // ADC11 FABRIC_DEBUG
       30'h0a020c08,  // ADC12 Data Width
       30'h0a100003,  // ADC12 Decimation Config
       30'h0a110001,  // ADC12 Decimation Mode
       30'h0a200000,  // ADC12 Mixer Config 0
       30'h0a210924,  // ADC12 Mixer Config 1
       30'h0a3a0028,  // ADC12 Switch Matrix Config
       30'h0a7101d1,  // ADC12 RX MC Config 0
       30'h0a780002,  // ADC12 DSA Control
       30'h0a5181c3,  // ADC12 TI_DCB_CTRL0
       30'h0a55d44a,  // ADC12 TI_TIME_SKEW_CTRL0
       30'h0a5a0001,  // ADC12 TI_TIME_SKEW_CTRL5
       30'h0a1d001c,  // ADC12 CAL_FREEZE_MASK
       30'h0a450091,  // ADC12_SIG_DET_CTRL
       30'h0a460148,  // ADC12_SIG_DET_THRESHOLD_LEVEL0
       30'h0a47012c,  // ADC12_SIG_DET_THRESHOLD_LEVEL0_CNT_ON
       30'h0a48012c,  // ADC12_SIG_DET_THRESHOLD_LEVEL0_CNT_OFF
       30'h0a06000c,  // ADC12 FABRIC_DEBUG
       30'h0b020c08,  // ADC13 Data Width
       30'h0b100003,  // ADC13 Decimation Config
       30'h0b110001,  // ADC13 Decimation Mode
       30'h0b200000,  // ADC13 Mixer Config 0
       30'h0b210924,  // ADC13 Mixer Config 1
       30'h0b3a002c,  // ADC13 Switch Matrix Config
       30'h0b7101d9,  // ADC13 RX MC Config 0
       30'h0b780002,  // ADC13 DSA Control
       30'h0b5181c7,  // ADC13 TI_DCB_CTRL0
       30'h0b55d44a,  // ADC13 TI_TIME_SKEW_CTRL0
       30'h0b5a0001,  // ADC13 TI_TIME_SKEW_CTRL5
       30'h0b1d001c,  // ADC13 CAL_FREEZE_MASK
       30'h0b450091,  // ADC13_SIG_DET_CTRL
       30'h0b460148,  // ADC13_SIG_DET_THRESHOLD_LEVEL0
       30'h0b47012c,  // ADC13_SIG_DET_THRESHOLD_LEVEL0_CNT_ON
       30'h0b48012c,  // ADC13_SIG_DET_THRESHOLD_LEVEL0_CNT_OFF
       30'h0b06000c,  // ADC13 FABRIC_DEBUG
       30'h17230000,  // Clock Network Control 0 (ADC2)
       30'h17240008,  // Clock Network Control 1 (ADC2)
       30'h1722a228,  // Clock Distribution Control (ADC2)
       30'h170c0000,  // PLL Output Divide (ADC2)
       30'h172c0025,  // CLK_DIV (ADC2)
       30'h17288880,  // SYSREF Distribution (ADC2)
       30'h172df0fe,  // HSCOM_PWR_MASK (ADC2)
       30'h17310062,  // CLOCK_DETECT_CTRL0 (ADC2)
       30'h17320032,  // CLOCK_DETECT_CTRL1 (ADC2)
       30'h17300000,  // FIFO_START (ADC2)
       30'h10020c08,  // ADC20 Data Width
       30'h10100003,  // ADC20 Decimation Config
       30'h10110001,  // ADC20 Decimation Mode
       30'h10200000,  // ADC20 Mixer Config 0
       30'h10210924,  // ADC20 Mixer Config 1
       30'h103a0020,  // ADC20 Switch Matrix Config
       30'h107101d1,  // ADC20 RX MC Config 0
       30'h10780002,  // ADC20 DSA Control
       30'h105181c3,  // ADC20 TI_DCB_CTRL0
       30'h1055d44a,  // ADC20 TI_TIME_SKEW_CTRL0
       30'h105a0001,  // ADC20 TI_TIME_SKEW_CTRL5
       30'h101d001c,  // ADC20 CAL_FREEZE_MASK
       30'h10450091,  // ADC20_SIG_DET_CTRL
       30'h10460148,  // ADC20_SIG_DET_THRESHOLD_LEVEL0
       30'h1047012c,  // ADC20_SIG_DET_THRESHOLD_LEVEL0_CNT_ON
       30'h1048012c,  // ADC20_SIG_DET_THRESHOLD_LEVEL0_CNT_OFF
       30'h1006000c,  // ADC20 FABRIC_DEBUG
       30'h11020c08,  // ADC21 Data Width
       30'h11100003,  // ADC21 Decimation Config
       30'h11110001,  // ADC21 Decimation Mode
       30'h11200000,  // ADC21 Mixer Config 0
       30'h11210924,  // ADC21 Mixer Config 1
       30'h113a0024,  // ADC21 Switch Matrix Config
       30'h117101d9,  // ADC21 RX MC Config 0
       30'h11780002,  // ADC21 DSA Control
       30'h115181c7,  // ADC21 TI_DCB_CTRL0
       30'h1155d44a,  // ADC21 TI_TIME_SKEW_CTRL0
       30'h115a0001,  // ADC21 TI_TIME_SKEW_CTRL5
       30'h111d001c,  // ADC21 CAL_FREEZE_MASK
       30'h11450091,  // ADC21_SIG_DET_CTRL
       30'h11460148,  // ADC21_SIG_DET_THRESHOLD_LEVEL0
       30'h1147012c,  // ADC21_SIG_DET_THRESHOLD_LEVEL0_CNT_ON
       30'h1148012c,  // ADC21_SIG_DET_THRESHOLD_LEVEL0_CNT_OFF
       30'h1106000c,  // ADC21 FABRIC_DEBUG
       30'h12020c08,  // ADC22 Data Width
       30'h12100003,  // ADC22 Decimation Config
       30'h12110001,  // ADC22 Decimation Mode
       30'h12200000,  // ADC22 Mixer Config 0
       30'h12210924,  // ADC22 Mixer Config 1
       30'h123a0028,  // ADC22 Switch Matrix Config
       30'h127101d1,  // ADC22 RX MC Config 0
       30'h12780002,  // ADC22 DSA Control
       30'h125181c3,  // ADC22 TI_DCB_CTRL0
       30'h1255d44a,  // ADC22 TI_TIME_SKEW_CTRL0
       30'h125a0001,  // ADC22 TI_TIME_SKEW_CTRL5
       30'h121d001c,  // ADC22 CAL_FREEZE_MASK
       30'h12450091,  // ADC22_SIG_DET_CTRL
       30'h12460148,  // ADC22_SIG_DET_THRESHOLD_LEVEL0
       30'h1247012c,  // ADC22_SIG_DET_THRESHOLD_LEVEL0_CNT_ON
       30'h1248012c,  // ADC22_SIG_DET_THRESHOLD_LEVEL0_CNT_OFF
       30'h1206000c,  // ADC22 FABRIC_DEBUG
       30'h13020c08,  // ADC23 Data Width
       30'h13100003,  // ADC23 Decimation Config
       30'h13110001,  // ADC23 Decimation Mode
       30'h13200000,  // ADC23 Mixer Config 0
       30'h13210924,  // ADC23 Mixer Config 1
       30'h133a002c,  // ADC23 Switch Matrix Config
       30'h137101d9,  // ADC23 RX MC Config 0
       30'h13780002,  // ADC23 DSA Control
       30'h135181c7,  // ADC23 TI_DCB_CTRL0
       30'h1355d44a,  // ADC23 TI_TIME_SKEW_CTRL0
       30'h135a0001,  // ADC23 TI_TIME_SKEW_CTRL5
       30'h131d001c,  // ADC23 CAL_FREEZE_MASK
       30'h13450091,  // ADC23_SIG_DET_CTRL
       30'h13460148,  // ADC23_SIG_DET_THRESHOLD_LEVEL0
       30'h1347012c,  // ADC23_SIG_DET_THRESHOLD_LEVEL0_CNT_ON
       30'h1348012c,  // ADC23_SIG_DET_THRESHOLD_LEVEL0_CNT_OFF
       30'h1306000c,  // ADC23 FABRIC_DEBUG
       30'h1f230000,  // Clock Network Control 0 (ADC3)
       30'h1f240008,  // Clock Network Control 1 (ADC3)
       30'h1f222060,  // Clock Distribution Control (ADC3)
       30'h1f0c0000,  // PLL Output Divide (ADC3)
       30'h1f2c0025,  // CLK_DIV (ADC3)
       30'h1f280700,  // SYSREF Distribution (ADC3)
       30'h1f2df0fe,  // HSCOM_PWR_MASK (ADC3)
       30'h1f310062,  // CLOCK_DETECT_CTRL0 (ADC3)
       30'h1f320032,  // CLOCK_DETECT_CTRL1 (ADC3)
       30'h1f300000,  // FIFO_START (ADC3)
       30'h18020c08,  // ADC30 Data Width
       30'h18100003,  // ADC30 Decimation Config
       30'h18110001,  // ADC30 Decimation Mode
       30'h18200000,  // ADC30 Mixer Config 0
       30'h18210924,  // ADC30 Mixer Config 1
       30'h183a0020,  // ADC30 Switch Matrix Config
       30'h187101d1,  // ADC30 RX MC Config 0
       30'h18780002,  // ADC30 DSA Control
       30'h185181c3,  // ADC30 TI_DCB_CTRL0
       30'h1855d44a,  // ADC30 TI_TIME_SKEW_CTRL0
       30'h185a0001,  // ADC30 TI_TIME_SKEW_CTRL5
       30'h181d001c,  // ADC30 CAL_FREEZE_MASK
       30'h18450091,  // ADC30_SIG_DET_CTRL
       30'h18460148,  // ADC30_SIG_DET_THRESHOLD_LEVEL0
       30'h1847012c,  // ADC30_SIG_DET_THRESHOLD_LEVEL0_CNT_ON
       30'h1848012c,  // ADC30_SIG_DET_THRESHOLD_LEVEL0_CNT_OFF
       30'h1806000c,  // ADC30 FABRIC_DEBUG
       30'h19020c08,  // ADC31 Data Width
       30'h19100003,  // ADC31 Decimation Config
       30'h19110001,  // ADC31 Decimation Mode
       30'h19200000,  // ADC31 Mixer Config 0
       30'h19210924,  // ADC31 Mixer Config 1
       30'h193a0024,  // ADC31 Switch Matrix Config
       30'h197101d9,  // ADC31 RX MC Config 0
       30'h19780002,  // ADC31 DSA Control
       30'h195181c7,  // ADC31 TI_DCB_CTRL0
       30'h1955d44a,  // ADC31 TI_TIME_SKEW_CTRL0
       30'h195a0001,  // ADC31 TI_TIME_SKEW_CTRL5
       30'h191d001c,  // ADC31 CAL_FREEZE_MASK
       30'h19450091,  // ADC31_SIG_DET_CTRL
       30'h19460148,  // ADC31_SIG_DET_THRESHOLD_LEVEL0
       30'h1947012c,  // ADC31_SIG_DET_THRESHOLD_LEVEL0_CNT_ON
       30'h1948012c,  // ADC31_SIG_DET_THRESHOLD_LEVEL0_CNT_OFF
       30'h1906000c,  // ADC31 FABRIC_DEBUG
       30'h1a020c08,  // ADC32 Data Width
       30'h1a100003,  // ADC32 Decimation Config
       30'h1a110001,  // ADC32 Decimation Mode
       30'h1a200000,  // ADC32 Mixer Config 0
       30'h1a210924,  // ADC32 Mixer Config 1
       30'h1a3a0028,  // ADC32 Switch Matrix Config
       30'h1a7101d1,  // ADC32 RX MC Config 0
       30'h1a780002,  // ADC32 DSA Control
       30'h1a5181c3,  // ADC32 TI_DCB_CTRL0
       30'h1a55d44a,  // ADC32 TI_TIME_SKEW_CTRL0
       30'h1a5a0001,  // ADC32 TI_TIME_SKEW_CTRL5
       30'h1a1d001c,  // ADC32 CAL_FREEZE_MASK
       30'h1a450091,  // ADC32_SIG_DET_CTRL
       30'h1a460148,  // ADC32_SIG_DET_THRESHOLD_LEVEL0
       30'h1a47012c,  // ADC32_SIG_DET_THRESHOLD_LEVEL0_CNT_ON
       30'h1a48012c,  // ADC32_SIG_DET_THRESHOLD_LEVEL0_CNT_OFF
       30'h1a06000c,  // ADC32 FABRIC_DEBUG
       30'h1b020c08,  // ADC33 Data Width
       30'h1b100003,  // ADC33 Decimation Config
       30'h1b110001,  // ADC33 Decimation Mode
       30'h1b200000,  // ADC33 Mixer Config 0
       30'h1b210924,  // ADC33 Mixer Config 1
       30'h1b3a002c,  // ADC33 Switch Matrix Config
       30'h1b7101d9,  // ADC33 RX MC Config 0
       30'h1b780002,  // ADC33 DSA Control
       30'h1b5181c7,  // ADC33 TI_DCB_CTRL0
       30'h1b55d44a,  // ADC33 TI_TIME_SKEW_CTRL0
       30'h1b5a0001,  // ADC33 TI_TIME_SKEW_CTRL5
       30'h1b1d001c,  // ADC33 CAL_FREEZE_MASK
       30'h1b450091,  // ADC33_SIG_DET_CTRL
       30'h1b460148,  // ADC33_SIG_DET_THRESHOLD_LEVEL0
       30'h1b47012c,  // ADC33_SIG_DET_THRESHOLD_LEVEL0_CNT_ON
       30'h1b48012c,  // ADC33_SIG_DET_THRESHOLD_LEVEL0_CNT_OFF
       30'h1b06000c,  // ADC33 FABRIC_DEBUG
       30'h27230000,  // Clock Network Control 0 (DAC0)
       30'h27240008,  // Clock Network Control 1 (DAC0)
       30'h27226028,  // Clock Distribution Control (DAC0)
       30'h270c0000,  // PLL Output Divide (DAC0)
       30'h272c0022,  // CLK_DIV (DAC0)
       30'h2728ca80,  // SYSREF Distribution (DAC0)
       30'h272df0fe,  // HSCOM_PWR_MASK (DAC0)
       30'h273103e6,  // CLOCK_DETECT_CTRL0 (DAC0)
       30'h273204e1,  // CLOCK_DETECT_CTRL1 (DAC0)
       30'h20021010,  // DAC00 Data Width
       30'h20100001,  // DAC00 Interpolation Control
       30'h20110000,  // DAC00 Interpolation Data
       30'h20200000,  // DAC00 Mixer Config 0
       30'h20210924,  // DAC00 Mixer Config 1
       30'h20300001,  // DAC00 Inv Sinc Filter
       30'h20310040,  // DAC00 Multiband Config
       30'h20600009,  // DAC00 Decoder Control
       30'h20610001,  // DAC00 Decoder Clock Enable
       30'h2071a000,  // DAC00 MC_CONFIG0
       30'h2073aa53,  // DAC00 MC_CONFIG2
       30'h20746a45,  // DAC00 MC_CONFIG3
       30'h20660001,  // DAC00 VOP_CTRL
       30'h200d0003,  // DAC00 DATAPATH
       30'h20040000,  // DAC00 FIFO_START
       30'h20070010,  // DAC00 FABRIC_DEBUG
       30'h22021010,  // DAC02 Data Width
       30'h22100001,  // DAC02 Interpolation Control
       30'h22110000,  // DAC02 Interpolation Data
       30'h22200000,  // DAC02 Mixer Config 0
       30'h22210924,  // DAC02 Mixer Config 1
       30'h22300001,  // DAC02 Inv Sinc Filter
       30'h22310040,  // DAC02 Multiband Config
       30'h22600009,  // DAC02 Decoder Control
       30'h22610001,  // DAC02 Decoder Clock Enable
       30'h2271a000,  // DAC02 MC_CONFIG0
       30'h2273aa53,  // DAC02 MC_CONFIG2
       30'h22746a45,  // DAC02 MC_CONFIG3
       30'h22660001,  // DAC02 VOP_CTRL
       30'h220d0003,  // DAC02 DATAPATH
       30'h22040000,  // DAC02 FIFO_START
       30'h22070010,  // DAC02 FABRIC_DEBUG
       30'h2f230000,  // Clock Network Control 0 (DAC1)
       30'h2f240008,  // Clock Network Control 1 (DAC1)
       30'h2f2260a0,  // Clock Distribution Control (DAC1)
       30'h2f0c0000,  // PLL Output Divide (DAC1)
       30'h2f2c0022,  // CLK_DIV (DAC1)
       30'h2f282400,  // SYSREF Distribution (DAC1)
       30'h2f2df0fe,  // HSCOM_PWR_MASK (DAC1)
       30'h2f3103e6,  // CLOCK_DETECT_CTRL0 (DAC1)
       30'h2f3204e1,  // CLOCK_DETECT_CTRL1 (DAC1)
       30'h28021010,  // DAC10 Data Width
       30'h28100001,  // DAC10 Interpolation Control
       30'h28110000,  // DAC10 Interpolation Data
       30'h28200000,  // DAC10 Mixer Config 0
       30'h28210924,  // DAC10 Mixer Config 1
       30'h28300001,  // DAC10 Inv Sinc Filter
       30'h28310040,  // DAC10 Multiband Config
       30'h28600009,  // DAC10 Decoder Control
       30'h28610001,  // DAC10 Decoder Clock Enable
       30'h2871a000,  // DAC10 MC_CONFIG0
       30'h2873aa53,  // DAC10 MC_CONFIG2
       30'h28746a45,  // DAC10 MC_CONFIG3
       30'h28660001,  // DAC10 VOP_CTRL
       30'h280d0003,  // DAC10 DATAPATH
       30'h28040000,  // DAC10 FIFO_START
       30'h28070010,  // DAC10 FABRIC_DEBUG
       30'h2a021010,  // DAC12 Data Width
       30'h2a100001,  // DAC12 Interpolation Control
       30'h2a110000,  // DAC12 Interpolation Data
       30'h2a200000,  // DAC12 Mixer Config 0
       30'h2a210924,  // DAC12 Mixer Config 1
       30'h2a300001,  // DAC12 Inv Sinc Filter
       30'h2a310040,  // DAC12 Multiband Config
       30'h2a600009,  // DAC12 Decoder Control
       30'h2a610001,  // DAC12 Decoder Clock Enable
       30'h2a71a000,  // DAC12 MC_CONFIG0
       30'h2a73aa53,  // DAC12 MC_CONFIG2
       30'h2a746a45,  // DAC12 MC_CONFIG3
       30'h2a660001,  // DAC12 VOP_CTRL
       30'h2a0d0003,  // DAC12 DATAPATH
       30'h2a040000,  // DAC12 FIFO_START
       30'h2a070010,  // DAC12 FABRIC_DEBUG
       30'h37230000,  // Clock Network Control 0 (DAC2)
       30'h37240028,  // Clock Network Control 1 (DAC2)
       30'h3722ab28,  // Clock Distribution Control (DAC2)
       30'h3717002b,  // PLL FB Div (DAC2)
       30'h370c0400,  // PLL Output Divide (DAC2)
       30'h37100010,  // PLL Ref clock divide (DAC2)
       30'h37000080,  // PLL SDM CONFIG0 (DAC2)
       30'h37060111,  // PLL SDM seed (DAC2)
       30'h37070011,  // PLL SDM seed setup (DAC2)
       30'h370e0d07,  // PLL ChargePump setup (DAC2)
       30'h370f2080,  // PLL temprature sensor control (DAC2)
       30'h3712ffff,  // PLL ChargePump setup (DAC2)
       30'h37137fe2,  // PLL loop filter setup (DAC2)
       30'h37140006,  // PLL loop filter setup (DAC2)
       30'h37155f03,  // PLL VCO setup (DAC2)
       30'h37160008,  // PLL VCO setup (DAC2)
       30'h370a7a21,  // PLL Coarse Frequency setup (DAC2)
       30'h370b7008,  // PLL Coarse Frequency setup (DAC2)
       30'h3711002d,  // PLL Voltage Regulator setup (DAC2)
       30'h372c0022,  // CLK_DIV (DAC2)
       30'h37280980,  // SYSREF Distribution (DAC2)
       30'h372dfffc,  // HSCOM_PWR_MASK (DAC2)
       30'h373103e6,  // CLOCK_DETECT_CTRL0 (DAC2)
       30'h373204e1,  // CLOCK_DETECT_CTRL1 (DAC2)
       30'h30021010,  // DAC20 Data Width
       30'h30100001,  // DAC20 Interpolation Control
       30'h30110000,  // DAC20 Interpolation Data
       30'h30200000,  // DAC20 Mixer Config 0
       30'h30210924,  // DAC20 Mixer Config 1
       30'h30300001,  // DAC20 Inv Sinc Filter
       30'h30310040,  // DAC20 Multiband Config
       30'h30600009,  // DAC20 Decoder Control
       30'h30610001,  // DAC20 Decoder Clock Enable
       30'h3071a000,  // DAC20 MC_CONFIG0
       30'h3073aa53,  // DAC20 MC_CONFIG2
       30'h30746a45,  // DAC20 MC_CONFIG3
       30'h30660001,  // DAC20 VOP_CTRL
       30'h300d0003,  // DAC20 DATAPATH
       30'h30040000,  // DAC20 FIFO_START
       30'h30070010,  // DAC20 FABRIC_DEBUG
       30'h32021010,  // DAC22 Data Width
       30'h32100001,  // DAC22 Interpolation Control
       30'h32110000,  // DAC22 Interpolation Data
       30'h32200000,  // DAC22 Mixer Config 0
       30'h32210924,  // DAC22 Mixer Config 1
       30'h32300001,  // DAC22 Inv Sinc Filter
       30'h32310040,  // DAC22 Multiband Config
       30'h32600009,  // DAC22 Decoder Control
       30'h32610001,  // DAC22 Decoder Clock Enable
       30'h3271a000,  // DAC22 MC_CONFIG0
       30'h3273aa53,  // DAC22 MC_CONFIG2
       30'h32746a45,  // DAC22 MC_CONFIG3
       30'h32660001,  // DAC22 VOP_CTRL
       30'h320d0003,  // DAC22 DATAPATH
       30'h32040000,  // DAC22 FIFO_START
       30'h32070010,  // DAC22 FABRIC_DEBUG
       30'h3f230000,  // Clock Network Control 0 (DAC3)
       30'h3f240008,  // Clock Network Control 1 (DAC3)
       30'h3f222020,  // Clock Distribution Control (DAC3)
       30'h3f0c0000,  // PLL Output Divide (DAC3)
       30'h3f2c0022,  // CLK_DIV (DAC3)
       30'h3f280100,  // SYSREF Distribution (DAC3)
       30'h3f2df0fe,  // HSCOM_PWR_MASK (DAC3)
       30'h3f3103e6,  // CLOCK_DETECT_CTRL0 (DAC3)
       30'h3f3204e1,  // CLOCK_DETECT_CTRL1 (DAC3)
       30'h38021010,  // DAC30 Data Width
       30'h38100001,  // DAC30 Interpolation Control
       30'h38110000,  // DAC30 Interpolation Data
       30'h38200000,  // DAC30 Mixer Config 0
       30'h38210924,  // DAC30 Mixer Config 1
       30'h38300001,  // DAC30 Inv Sinc Filter
       30'h38310040,  // DAC30 Multiband Config
       30'h38600009,  // DAC30 Decoder Control
       30'h38610001,  // DAC30 Decoder Clock Enable
       30'h3871a000,  // DAC30 MC_CONFIG0
       30'h3873aa53,  // DAC30 MC_CONFIG2
       30'h38746a45,  // DAC30 MC_CONFIG3
       30'h38660001,  // DAC30 VOP_CTRL
       30'h380d0003,  // DAC30 DATAPATH
       30'h38040000,  // DAC30 FIFO_START
       30'h38070010,  // DAC30 FABRIC_DEBUG
       30'h3a021010,  // DAC32 Data Width
       30'h3a100001,  // DAC32 Interpolation Control
       30'h3a110000,  // DAC32 Interpolation Data
       30'h3a200000,  // DAC32 Mixer Config 0
       30'h3a210924,  // DAC32 Mixer Config 1
       30'h3a300001,  // DAC32 Inv Sinc Filter
       30'h3a310040,  // DAC32 Multiband Config
       30'h3a600009,  // DAC32 Decoder Control
       30'h3a610001,  // DAC32 Decoder Clock Enable
       30'h3a71a000,  // DAC32 MC_CONFIG0
       30'h3a73aa53,  // DAC32 MC_CONFIG2
       30'h3a746a45,  // DAC32 MC_CONFIG3
       30'h3a660001,  // DAC32 VOP_CTRL
       30'h3a0d0003,  // DAC32 DATAPATH
       30'h3a040000,  // DAC32 FIFO_START
       30'h3a070010,  // DAC32 FABRIC_DEBUG
       30'h00000000};

    //-------------------------------------------------------------------------
    // Output the tile number, address and data for the DRP writes
    // depending on the data_index input
    //-------------------------------------------------------------------------
    always @(posedge aux_clk)
    begin
      data <= data_array[data_index];
    end

    assign data_out = data[15:0];
    assign addr_out = data[26:16];
    assign tile_out = data[29:27];

endmodule

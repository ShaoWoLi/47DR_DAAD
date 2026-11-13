-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
-- -------------------------------------------------------------------------------
-- This file contains confidential and proprietary information
-- of AMD and is protected under U.S. and international copyright
-- and other intellectual property laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- AMD, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND AMD HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) AMD shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or AMD had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- AMD products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of AMD products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
--
-- DO NOT MODIFY THIS FILE.

-- MODULE VLNV: amd.com:blockdesign:system:1.0

-- The following code must appear in the VHDL architecture header.

-- COMP_TAG     ------ Begin cut for COMPONENT Declaration ------
COMPONENT system
  PORT (
    adc1_clk_clk_n : IN STD_LOGIC;
    adc1_clk_clk_p : IN STD_LOGIC;
    dac2_clk_clk_n : IN STD_LOGIC;
    dac2_clk_clk_p : IN STD_LOGIC;
    vin0_01_v_n : IN STD_LOGIC;
    vin0_01_v_p : IN STD_LOGIC;
    vin0_23_v_n : IN STD_LOGIC;
    vin0_23_v_p : IN STD_LOGIC;
    vin1_01_v_n : IN STD_LOGIC;
    vin1_01_v_p : IN STD_LOGIC;
    vin1_23_v_n : IN STD_LOGIC;
    vin1_23_v_p : IN STD_LOGIC;
    vin2_01_v_n : IN STD_LOGIC;
    vin2_01_v_p : IN STD_LOGIC;
    vin2_23_v_n : IN STD_LOGIC;
    vin2_23_v_p : IN STD_LOGIC;
    vin3_01_v_n : IN STD_LOGIC;
    vin3_01_v_p : IN STD_LOGIC;
    vin3_23_v_n : IN STD_LOGIC;
    vin3_23_v_p : IN STD_LOGIC;
    vout00_v_n : OUT STD_LOGIC;
    vout00_v_p : OUT STD_LOGIC;
    vout02_v_n : OUT STD_LOGIC;
    vout02_v_p : OUT STD_LOGIC;
    vout10_v_n : OUT STD_LOGIC;
    vout10_v_p : OUT STD_LOGIC;
    vout12_v_n : OUT STD_LOGIC;
    vout12_v_p : OUT STD_LOGIC;
    vout20_v_n : OUT STD_LOGIC;
    vout20_v_p : OUT STD_LOGIC;
    vout22_v_n : OUT STD_LOGIC;
    vout22_v_p : OUT STD_LOGIC;
    vout30_v_n : OUT STD_LOGIC;
    vout30_v_p : OUT STD_LOGIC;
    vout32_v_n : OUT STD_LOGIC;
    vout32_v_p : OUT STD_LOGIC;
    sysref_in_diff_n : IN STD_LOGIC;
    sysref_in_diff_p : IN STD_LOGIC;
    data_clk : OUT STD_LOGIC;
    user_sysref_adc_0 : IN STD_LOGIC;
    user_sysref_dac_0 : IN STD_LOGIC;
    up_wreq : OUT STD_LOGIC;
    up_waddr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    up_wdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    up_rreq : OUT STD_LOGIC;
    up_raddr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    up_wack : IN STD_LOGIC;
    up_rdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    up_rack : IN STD_LOGIC;
    fclk_100m : OUT STD_LOGIC;
    pl_resetn0 : OUT STD_LOGIC;
    rf_resetn : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    host_resetn : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    adc_capture_clk : OUT STD_LOGIC;
    adc_axis_resetn : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    m00_axis_tdata : OUT STD_LOGIC_VECTOR(191 DOWNTO 0);
    m00_axis_tvalid : OUT STD_LOGIC;
    m00_axis_tready : IN STD_LOGIC;
    m02_axis_tdata : OUT STD_LOGIC_VECTOR(191 DOWNTO 0);
    m02_axis_tvalid : OUT STD_LOGIC;
    m02_axis_tready : IN STD_LOGIC;
    m10_axis_tdata : OUT STD_LOGIC_VECTOR(191 DOWNTO 0);
    m10_axis_tvalid : OUT STD_LOGIC;
    m10_axis_tready : IN STD_LOGIC;
    m12_axis_tdata : OUT STD_LOGIC_VECTOR(191 DOWNTO 0);
    m12_axis_tvalid : OUT STD_LOGIC;
    m12_axis_tready : IN STD_LOGIC;
    m20_axis_tdata : OUT STD_LOGIC_VECTOR(191 DOWNTO 0);
    m20_axis_tvalid : OUT STD_LOGIC;
    m20_axis_tready : IN STD_LOGIC;
    m22_axis_tdata : OUT STD_LOGIC_VECTOR(191 DOWNTO 0);
    m22_axis_tvalid : OUT STD_LOGIC;
    m22_axis_tready : IN STD_LOGIC;
    m30_axis_tdata : OUT STD_LOGIC_VECTOR(191 DOWNTO 0);
    m30_axis_tvalid : OUT STD_LOGIC;
    m30_axis_tready : IN STD_LOGIC;
    m32_axis_tdata : OUT STD_LOGIC_VECTOR(191 DOWNTO 0);
    m32_axis_tvalid : OUT STD_LOGIC;
    m32_axis_tready : IN STD_LOGIC;
    s00_axis_tdata : IN STD_LOGIC_VECTOR(255 DOWNTO 0);
    s00_axis_tvalid : IN STD_LOGIC;
    s00_axis_tready : OUT STD_LOGIC;
    s02_axis_tdata : IN STD_LOGIC_VECTOR(255 DOWNTO 0);
    s02_axis_tvalid : IN STD_LOGIC;
    s02_axis_tready : OUT STD_LOGIC;
    s10_axis_tdata : IN STD_LOGIC_VECTOR(255 DOWNTO 0);
    s10_axis_tvalid : IN STD_LOGIC;
    s10_axis_tready : OUT STD_LOGIC;
    s12_axis_tdata : IN STD_LOGIC_VECTOR(255 DOWNTO 0);
    s12_axis_tvalid : IN STD_LOGIC;
    s12_axis_tready : OUT STD_LOGIC;
    s20_axis_tdata : IN STD_LOGIC_VECTOR(255 DOWNTO 0);
    s20_axis_tvalid : IN STD_LOGIC;
    s20_axis_tready : OUT STD_LOGIC;
    s22_axis_tdata : IN STD_LOGIC_VECTOR(255 DOWNTO 0);
    s22_axis_tvalid : IN STD_LOGIC;
    s22_axis_tready : OUT STD_LOGIC;
    s30_axis_tdata : IN STD_LOGIC_VECTOR(255 DOWNTO 0);
    s30_axis_tvalid : IN STD_LOGIC;
    s30_axis_tready : OUT STD_LOGIC;
    s32_axis_tdata : IN STD_LOGIC_VECTOR(255 DOWNTO 0);
    s32_axis_tvalid : IN STD_LOGIC;
    s32_axis_tready : OUT STD_LOGIC;
    adc_fabric_ref : IN STD_LOGIC
  );
END COMPONENT;
-- COMP_TAG_END ------  End cut for COMPONENT Declaration  ------

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

-- INST_TAG     ------ Begin cut for INSTANTIATION Template ------
your_instance_name : system
  PORT MAP (
    adc1_clk_clk_n => adc1_clk_clk_n,
    adc1_clk_clk_p => adc1_clk_clk_p,
    dac2_clk_clk_n => dac2_clk_clk_n,
    dac2_clk_clk_p => dac2_clk_clk_p,
    vin0_01_v_n => vin0_01_v_n,
    vin0_01_v_p => vin0_01_v_p,
    vin0_23_v_n => vin0_23_v_n,
    vin0_23_v_p => vin0_23_v_p,
    vin1_01_v_n => vin1_01_v_n,
    vin1_01_v_p => vin1_01_v_p,
    vin1_23_v_n => vin1_23_v_n,
    vin1_23_v_p => vin1_23_v_p,
    vin2_01_v_n => vin2_01_v_n,
    vin2_01_v_p => vin2_01_v_p,
    vin2_23_v_n => vin2_23_v_n,
    vin2_23_v_p => vin2_23_v_p,
    vin3_01_v_n => vin3_01_v_n,
    vin3_01_v_p => vin3_01_v_p,
    vin3_23_v_n => vin3_23_v_n,
    vin3_23_v_p => vin3_23_v_p,
    vout00_v_n => vout00_v_n,
    vout00_v_p => vout00_v_p,
    vout02_v_n => vout02_v_n,
    vout02_v_p => vout02_v_p,
    vout10_v_n => vout10_v_n,
    vout10_v_p => vout10_v_p,
    vout12_v_n => vout12_v_n,
    vout12_v_p => vout12_v_p,
    vout20_v_n => vout20_v_n,
    vout20_v_p => vout20_v_p,
    vout22_v_n => vout22_v_n,
    vout22_v_p => vout22_v_p,
    vout30_v_n => vout30_v_n,
    vout30_v_p => vout30_v_p,
    vout32_v_n => vout32_v_n,
    vout32_v_p => vout32_v_p,
    sysref_in_diff_n => sysref_in_diff_n,
    sysref_in_diff_p => sysref_in_diff_p,
    data_clk => data_clk,
    user_sysref_adc_0 => user_sysref_adc_0,
    user_sysref_dac_0 => user_sysref_dac_0,
    up_wreq => up_wreq,
    up_waddr => up_waddr,
    up_wdata => up_wdata,
    up_rreq => up_rreq,
    up_raddr => up_raddr,
    up_wack => up_wack,
    up_rdata => up_rdata,
    up_rack => up_rack,
    fclk_100m => fclk_100m,
    pl_resetn0 => pl_resetn0,
    rf_resetn => rf_resetn,
    host_resetn => host_resetn,
    adc_capture_clk => adc_capture_clk,
    adc_axis_resetn => adc_axis_resetn,
    m00_axis_tdata => m00_axis_tdata,
    m00_axis_tvalid => m00_axis_tvalid,
    m00_axis_tready => m00_axis_tready,
    m02_axis_tdata => m02_axis_tdata,
    m02_axis_tvalid => m02_axis_tvalid,
    m02_axis_tready => m02_axis_tready,
    m10_axis_tdata => m10_axis_tdata,
    m10_axis_tvalid => m10_axis_tvalid,
    m10_axis_tready => m10_axis_tready,
    m12_axis_tdata => m12_axis_tdata,
    m12_axis_tvalid => m12_axis_tvalid,
    m12_axis_tready => m12_axis_tready,
    m20_axis_tdata => m20_axis_tdata,
    m20_axis_tvalid => m20_axis_tvalid,
    m20_axis_tready => m20_axis_tready,
    m22_axis_tdata => m22_axis_tdata,
    m22_axis_tvalid => m22_axis_tvalid,
    m22_axis_tready => m22_axis_tready,
    m30_axis_tdata => m30_axis_tdata,
    m30_axis_tvalid => m30_axis_tvalid,
    m30_axis_tready => m30_axis_tready,
    m32_axis_tdata => m32_axis_tdata,
    m32_axis_tvalid => m32_axis_tvalid,
    m32_axis_tready => m32_axis_tready,
    s00_axis_tdata => s00_axis_tdata,
    s00_axis_tvalid => s00_axis_tvalid,
    s00_axis_tready => s00_axis_tready,
    s02_axis_tdata => s02_axis_tdata,
    s02_axis_tvalid => s02_axis_tvalid,
    s02_axis_tready => s02_axis_tready,
    s10_axis_tdata => s10_axis_tdata,
    s10_axis_tvalid => s10_axis_tvalid,
    s10_axis_tready => s10_axis_tready,
    s12_axis_tdata => s12_axis_tdata,
    s12_axis_tvalid => s12_axis_tvalid,
    s12_axis_tready => s12_axis_tready,
    s20_axis_tdata => s20_axis_tdata,
    s20_axis_tvalid => s20_axis_tvalid,
    s20_axis_tready => s20_axis_tready,
    s22_axis_tdata => s22_axis_tdata,
    s22_axis_tvalid => s22_axis_tvalid,
    s22_axis_tready => s22_axis_tready,
    s30_axis_tdata => s30_axis_tdata,
    s30_axis_tvalid => s30_axis_tvalid,
    s30_axis_tready => s30_axis_tready,
    s32_axis_tdata => s32_axis_tdata,
    s32_axis_tvalid => s32_axis_tvalid,
    s32_axis_tready => s32_axis_tready,
    adc_fabric_ref => adc_fabric_ref
  );
-- INST_TAG_END ------  End cut for INSTANTIATION Template  ------

-- You must compile the wrapper file system.vhd when simulating
-- the module, system. When compiling the wrapper file, be sure to
-- reference the VHDL simulation library.

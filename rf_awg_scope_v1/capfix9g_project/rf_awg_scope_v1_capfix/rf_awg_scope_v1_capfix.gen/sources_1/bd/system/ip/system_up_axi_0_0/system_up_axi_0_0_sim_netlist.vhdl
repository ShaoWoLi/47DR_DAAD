-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025
-- Date        : Mon Nov  9 18:33:33 2026
-- Host        : DESKTOP-R1144H2 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim
--               e:/47dr_ADDA/stable9g/rf_awg_scope_v1_mts.gen/sources_1/bd/system/ip/system_up_axi_0_0/system_up_axi_0_0_sim_netlist.vhdl
-- Design      : system_up_axi_0_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xczu47dr-fsve1156-2-i
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity system_up_axi_0_0_up_axi is
  port (
    up_axi_rvalid_int_reg_0 : out STD_LOGIC;
    up_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    up_waddr : out STD_LOGIC_VECTOR ( 15 downto 0 );
    up_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    up_raddr : out STD_LOGIC_VECTOR ( 15 downto 0 );
    up_wreq : out STD_LOGIC;
    up_axi_bvalid : out STD_LOGIC;
    up_rreq : out STD_LOGIC;
    up_axi_awready : out STD_LOGIC;
    up_axi_wready : out STD_LOGIC;
    up_axi_arready : out STD_LOGIC;
    up_wack : in STD_LOGIC;
    up_axi_wvalid : in STD_LOGIC;
    up_axi_awvalid : in STD_LOGIC;
    up_rstn : in STD_LOGIC;
    up_axi_arvalid : in STD_LOGIC;
    up_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    up_axi_rready : in STD_LOGIC;
    up_clk : in STD_LOGIC;
    up_axi_awaddr : in STD_LOGIC_VECTOR ( 15 downto 0 );
    up_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    up_axi_araddr : in STD_LOGIC_VECTOR ( 15 downto 0 );
    up_rack : in STD_LOGIC;
    up_axi_bready : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of system_up_axi_0_0_up_axi : entity is "up_axi";
end system_up_axi_0_0_up_axi;

architecture STRUCTURE of system_up_axi_0_0_up_axi is
  signal p_0_in : STD_LOGIC;
  signal p_0_in6_in : STD_LOGIC;
  signal p_0_in7_in : STD_LOGIC;
  signal p_1_in : STD_LOGIC;
  signal p_1_in_0 : STD_LOGIC;
  signal p_2_in : STD_LOGIC_VECTOR ( 4 downto 1 );
  signal p_5_in : STD_LOGIC;
  signal \^up_axi_arready\ : STD_LOGIC;
  signal up_axi_arready_int_i_1_n_0 : STD_LOGIC;
  signal up_axi_arready_int_i_2_n_0 : STD_LOGIC;
  signal \^up_axi_awready\ : STD_LOGIC;
  signal up_axi_awready_int_i_2_n_0 : STD_LOGIC;
  signal \^up_axi_bvalid\ : STD_LOGIC;
  signal up_axi_bvalid_int_i_1_n_0 : STD_LOGIC;
  signal \up_axi_rdata_int[31]_i_1_n_0\ : STD_LOGIC;
  signal up_axi_rvalid_int_i_1_n_0 : STD_LOGIC;
  signal \^up_axi_rvalid_int_reg_0\ : STD_LOGIC;
  signal \^up_axi_wready\ : STD_LOGIC;
  signal up_axi_wready_int_i_1_n_0 : STD_LOGIC;
  signal up_rack_d : STD_LOGIC;
  signal up_rack_s : STD_LOGIC;
  signal \up_rcount[0]_i_1_n_0\ : STD_LOGIC;
  signal \up_rcount[1]_i_1_n_0\ : STD_LOGIC;
  signal \up_rcount[2]_i_1_n_0\ : STD_LOGIC;
  signal \up_rcount[3]_i_1_n_0\ : STD_LOGIC;
  signal \up_rcount[4]_i_1_n_0\ : STD_LOGIC;
  signal \up_rcount[4]_i_2_n_0\ : STD_LOGIC;
  signal \up_rcount_reg_n_0_[0]\ : STD_LOGIC;
  signal \up_rcount_reg_n_0_[1]\ : STD_LOGIC;
  signal \up_rcount_reg_n_0_[2]\ : STD_LOGIC;
  signal \up_rcount_reg_n_0_[3]\ : STD_LOGIC;
  signal up_rdata_d : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal \up_rdata_d[0]_i_1_n_0\ : STD_LOGIC;
  signal \up_rdata_d[10]_i_1_n_0\ : STD_LOGIC;
  signal \up_rdata_d[11]_i_1_n_0\ : STD_LOGIC;
  signal \up_rdata_d[12]_i_1_n_0\ : STD_LOGIC;
  signal \up_rdata_d[14]_i_1_n_0\ : STD_LOGIC;
  signal \up_rdata_d[15]_i_1_n_0\ : STD_LOGIC;
  signal \up_rdata_d[16]_i_1_n_0\ : STD_LOGIC;
  signal \up_rdata_d[18]_i_1_n_0\ : STD_LOGIC;
  signal \up_rdata_d[19]_i_1_n_0\ : STD_LOGIC;
  signal \up_rdata_d[21]_i_1_n_0\ : STD_LOGIC;
  signal \up_rdata_d[23]_i_1_n_0\ : STD_LOGIC;
  signal \up_rdata_d[25]_i_1_n_0\ : STD_LOGIC;
  signal \up_rdata_d[26]_i_1_n_0\ : STD_LOGIC;
  signal \up_rdata_d[27]_i_1_n_0\ : STD_LOGIC;
  signal \up_rdata_d[28]_i_1_n_0\ : STD_LOGIC;
  signal \up_rdata_d[29]_i_1_n_0\ : STD_LOGIC;
  signal \up_rdata_d[2]_i_1_n_0\ : STD_LOGIC;
  signal \up_rdata_d[30]_i_1_n_0\ : STD_LOGIC;
  signal \up_rdata_d[31]_i_1_n_0\ : STD_LOGIC;
  signal \up_rdata_d[3]_i_1_n_0\ : STD_LOGIC;
  signal \up_rdata_d[5]_i_1_n_0\ : STD_LOGIC;
  signal \up_rdata_d[7]_i_1_n_0\ : STD_LOGIC;
  signal \up_rdata_d[9]_i_1_n_0\ : STD_LOGIC;
  signal \^up_rreq\ : STD_LOGIC;
  signal up_rreq_int_i_1_n_0 : STD_LOGIC;
  signal up_rsel_inv_i_1_n_0 : STD_LOGIC;
  signal up_wack_d : STD_LOGIC;
  signal up_wack_s : STD_LOGIC;
  signal \up_wcount[0]_i_1_n_0\ : STD_LOGIC;
  signal \up_wcount[2]_i_1_n_0\ : STD_LOGIC;
  signal \up_wcount_reg_n_0_[0]\ : STD_LOGIC;
  signal \up_wcount_reg_n_0_[1]\ : STD_LOGIC;
  signal \up_wcount_reg_n_0_[2]\ : STD_LOGIC;
  signal \up_wcount_reg_n_0_[3]\ : STD_LOGIC;
  signal \^up_wreq\ : STD_LOGIC;
  signal up_wreq_int_i_1_n_0 : STD_LOGIC;
  signal up_wsel_inv_i_1_n_0 : STD_LOGIC;
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of up_axi_awready_int_i_2 : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of up_axi_wready_int_i_1 : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \up_rcount[1]_i_1\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \up_rcount[2]_i_1\ : label is "soft_lutpair1";
  attribute inverted : string;
  attribute inverted of up_rsel_reg_inv : label is "yes";
  attribute SOFT_HLUTNM of \up_wcount[1]_i_1\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \up_wcount[2]_i_1\ : label is "soft_lutpair0";
  attribute inverted of up_wsel_reg_inv : label is "yes";
begin
  up_axi_arready <= \^up_axi_arready\;
  up_axi_awready <= \^up_axi_awready\;
  up_axi_bvalid <= \^up_axi_bvalid\;
  up_axi_rvalid_int_reg_0 <= \^up_axi_rvalid_int_reg_0\;
  up_axi_wready <= \^up_axi_wready\;
  up_rreq <= \^up_rreq\;
  up_wreq <= \^up_wreq\;
up_axi_arready_int_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"5540"
    )
        port map (
      I0 => \^up_axi_arready\,
      I1 => up_rack,
      I2 => p_0_in6_in,
      I3 => up_axi_arready_int_i_2_n_0,
      O => up_axi_arready_int_i_1_n_0
    );
up_axi_arready_int_i_2: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => \up_rcount_reg_n_0_[0]\,
      I1 => \up_rcount_reg_n_0_[1]\,
      I2 => \up_rcount_reg_n_0_[2]\,
      I3 => \up_rcount_reg_n_0_[3]\,
      I4 => p_0_in6_in,
      O => up_axi_arready_int_i_2_n_0
    );
up_axi_arready_int_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => up_axi_arready_int_i_1_n_0,
      Q => \^up_axi_arready\,
      R => p_0_in
    );
up_axi_awready_int_i_1: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => up_rstn,
      O => p_0_in
    );
up_axi_awready_int_i_2: unisim.vcomponents.LUT2
    generic map(
      INIT => X"4"
    )
        port map (
      I0 => \^up_axi_awready\,
      I1 => up_wack_s,
      O => up_axi_awready_int_i_2_n_0
    );
up_axi_awready_int_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => up_axi_awready_int_i_2_n_0,
      Q => \^up_axi_awready\,
      R => p_0_in
    );
up_axi_bvalid_int_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0C88"
    )
        port map (
      I0 => up_wack_d,
      I1 => up_rstn,
      I2 => up_axi_bready,
      I3 => \^up_axi_bvalid\,
      O => up_axi_bvalid_int_i_1_n_0
    );
up_axi_bvalid_int_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => up_axi_bvalid_int_i_1_n_0,
      Q => \^up_axi_bvalid\,
      R => '0'
    );
\up_axi_rdata_int[31]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"8F"
    )
        port map (
      I0 => up_axi_rready,
      I1 => \^up_axi_rvalid_int_reg_0\,
      I2 => up_rstn,
      O => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(0),
      Q => up_axi_rdata(0),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[10]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(10),
      Q => up_axi_rdata(10),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[11]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(11),
      Q => up_axi_rdata(11),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[12]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(12),
      Q => up_axi_rdata(12),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[13]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(13),
      Q => up_axi_rdata(13),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[14]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(14),
      Q => up_axi_rdata(14),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[15]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(15),
      Q => up_axi_rdata(15),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[16]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(16),
      Q => up_axi_rdata(16),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[17]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(17),
      Q => up_axi_rdata(17),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[18]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(18),
      Q => up_axi_rdata(18),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[19]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(19),
      Q => up_axi_rdata(19),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(1),
      Q => up_axi_rdata(1),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[20]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(20),
      Q => up_axi_rdata(20),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[21]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(21),
      Q => up_axi_rdata(21),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[22]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(22),
      Q => up_axi_rdata(22),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[23]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(23),
      Q => up_axi_rdata(23),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[24]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(24),
      Q => up_axi_rdata(24),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[25]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(25),
      Q => up_axi_rdata(25),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[26]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(26),
      Q => up_axi_rdata(26),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[27]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(27),
      Q => up_axi_rdata(27),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[28]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(28),
      Q => up_axi_rdata(28),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[29]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(29),
      Q => up_axi_rdata(29),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(2),
      Q => up_axi_rdata(2),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[30]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(30),
      Q => up_axi_rdata(30),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[31]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(31),
      Q => up_axi_rdata(31),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(3),
      Q => up_axi_rdata(3),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[4]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(4),
      Q => up_axi_rdata(4),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[5]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(5),
      Q => up_axi_rdata(5),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[6]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(6),
      Q => up_axi_rdata(6),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[7]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(7),
      Q => up_axi_rdata(7),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[8]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(8),
      Q => up_axi_rdata(8),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
\up_axi_rdata_int_reg[9]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => up_rack_d,
      D => up_rdata_d(9),
      Q => up_axi_rdata(9),
      R => \up_axi_rdata_int[31]_i_1_n_0\
    );
up_axi_rvalid_int_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"08C8"
    )
        port map (
      I0 => up_rack_d,
      I1 => up_rstn,
      I2 => \^up_axi_rvalid_int_reg_0\,
      I3 => up_axi_rready,
      O => up_axi_rvalid_int_i_1_n_0
    );
up_axi_rvalid_int_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => up_axi_rvalid_int_i_1_n_0,
      Q => \^up_axi_rvalid_int_reg_0\,
      R => '0'
    );
up_axi_wready_int_i_1: unisim.vcomponents.LUT2
    generic map(
      INIT => X"4"
    )
        port map (
      I0 => \^up_axi_wready\,
      I1 => up_wack_s,
      O => up_axi_wready_int_i_1_n_0
    );
up_axi_wready_int_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => up_axi_wready_int_i_1_n_0,
      Q => \^up_axi_wready\,
      R => p_0_in
    );
up_rack_d_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"C888888888888888"
    )
        port map (
      I0 => up_rack,
      I1 => p_0_in6_in,
      I2 => \up_rcount_reg_n_0_[0]\,
      I3 => \up_rcount_reg_n_0_[1]\,
      I4 => \up_rcount_reg_n_0_[2]\,
      I5 => \up_rcount_reg_n_0_[3]\,
      O => up_rack_s
    );
up_rack_d_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => up_rack_s,
      Q => up_rack_d,
      R => p_0_in
    );
\up_raddr_int_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_1_in_0,
      D => up_axi_araddr(0),
      Q => up_raddr(0),
      R => p_0_in
    );
\up_raddr_int_reg[10]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_1_in_0,
      D => up_axi_araddr(10),
      Q => up_raddr(10),
      R => p_0_in
    );
\up_raddr_int_reg[11]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_1_in_0,
      D => up_axi_araddr(11),
      Q => up_raddr(11),
      R => p_0_in
    );
\up_raddr_int_reg[12]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_1_in_0,
      D => up_axi_araddr(12),
      Q => up_raddr(12),
      R => p_0_in
    );
\up_raddr_int_reg[13]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_1_in_0,
      D => up_axi_araddr(13),
      Q => up_raddr(13),
      R => p_0_in
    );
\up_raddr_int_reg[14]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_1_in_0,
      D => up_axi_araddr(14),
      Q => up_raddr(14),
      R => p_0_in
    );
\up_raddr_int_reg[15]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_1_in_0,
      D => up_axi_araddr(15),
      Q => up_raddr(15),
      R => p_0_in
    );
\up_raddr_int_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_1_in_0,
      D => up_axi_araddr(1),
      Q => up_raddr(1),
      R => p_0_in
    );
\up_raddr_int_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_1_in_0,
      D => up_axi_araddr(2),
      Q => up_raddr(2),
      R => p_0_in
    );
\up_raddr_int_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_1_in_0,
      D => up_axi_araddr(3),
      Q => up_raddr(3),
      R => p_0_in
    );
\up_raddr_int_reg[4]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_1_in_0,
      D => up_axi_araddr(4),
      Q => up_raddr(4),
      R => p_0_in
    );
\up_raddr_int_reg[5]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_1_in_0,
      D => up_axi_araddr(5),
      Q => up_raddr(5),
      R => p_0_in
    );
\up_raddr_int_reg[6]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_1_in_0,
      D => up_axi_araddr(6),
      Q => up_raddr(6),
      R => p_0_in
    );
\up_raddr_int_reg[7]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_1_in_0,
      D => up_axi_araddr(7),
      Q => up_raddr(7),
      R => p_0_in
    );
\up_raddr_int_reg[8]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_1_in_0,
      D => up_axi_araddr(8),
      Q => up_raddr(8),
      R => p_0_in
    );
\up_raddr_int_reg[9]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_1_in_0,
      D => up_axi_araddr(9),
      Q => up_raddr(9),
      R => p_0_in
    );
\up_rcount[0]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"04"
    )
        port map (
      I0 => up_rack,
      I1 => p_0_in6_in,
      I2 => \up_rcount_reg_n_0_[0]\,
      O => \up_rcount[0]_i_1_n_0\
    );
\up_rcount[1]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"1400"
    )
        port map (
      I0 => up_rack,
      I1 => \up_rcount_reg_n_0_[0]\,
      I2 => \up_rcount_reg_n_0_[1]\,
      I3 => p_0_in6_in,
      O => \up_rcount[1]_i_1_n_0\
    );
\up_rcount[2]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"14440000"
    )
        port map (
      I0 => up_rack,
      I1 => \up_rcount_reg_n_0_[2]\,
      I2 => \up_rcount_reg_n_0_[1]\,
      I3 => \up_rcount_reg_n_0_[0]\,
      I4 => p_0_in6_in,
      O => \up_rcount[2]_i_1_n_0\
    );
\up_rcount[3]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"1444444400000000"
    )
        port map (
      I0 => up_rack,
      I1 => \up_rcount_reg_n_0_[3]\,
      I2 => \up_rcount_reg_n_0_[0]\,
      I3 => \up_rcount_reg_n_0_[1]\,
      I4 => \up_rcount_reg_n_0_[2]\,
      I5 => p_0_in6_in,
      O => \up_rcount[3]_i_1_n_0\
    );
\up_rcount[4]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => p_0_in6_in,
      I1 => \^up_rreq\,
      O => \up_rcount[4]_i_1_n_0\
    );
\up_rcount[4]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000FFFF7FFFFFFF"
    )
        port map (
      I0 => \up_rcount_reg_n_0_[3]\,
      I1 => \up_rcount_reg_n_0_[2]\,
      I2 => \up_rcount_reg_n_0_[1]\,
      I3 => \up_rcount_reg_n_0_[0]\,
      I4 => p_0_in6_in,
      I5 => up_rack,
      O => \up_rcount[4]_i_2_n_0\
    );
\up_rcount_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => \up_rcount[4]_i_1_n_0\,
      D => \up_rcount[0]_i_1_n_0\,
      Q => \up_rcount_reg_n_0_[0]\,
      R => p_0_in
    );
\up_rcount_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => \up_rcount[4]_i_1_n_0\,
      D => \up_rcount[1]_i_1_n_0\,
      Q => \up_rcount_reg_n_0_[1]\,
      R => p_0_in
    );
\up_rcount_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => \up_rcount[4]_i_1_n_0\,
      D => \up_rcount[2]_i_1_n_0\,
      Q => \up_rcount_reg_n_0_[2]\,
      R => p_0_in
    );
\up_rcount_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => \up_rcount[4]_i_1_n_0\,
      D => \up_rcount[3]_i_1_n_0\,
      Q => \up_rcount_reg_n_0_[3]\,
      R => p_0_in
    );
\up_rcount_reg[4]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => \up_rcount[4]_i_1_n_0\,
      D => \up_rcount[4]_i_2_n_0\,
      Q => p_0_in6_in,
      R => p_0_in
    );
\up_rdata_d[0]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"EAAAAAAAAAAAAAAA"
    )
        port map (
      I0 => up_rdata(0),
      I1 => p_0_in6_in,
      I2 => \up_rcount_reg_n_0_[3]\,
      I3 => \up_rcount_reg_n_0_[2]\,
      I4 => \up_rcount_reg_n_0_[1]\,
      I5 => \up_rcount_reg_n_0_[0]\,
      O => \up_rdata_d[0]_i_1_n_0\
    );
\up_rdata_d[10]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"EAAAAAAAAAAAAAAA"
    )
        port map (
      I0 => up_rdata(10),
      I1 => p_0_in6_in,
      I2 => \up_rcount_reg_n_0_[3]\,
      I3 => \up_rcount_reg_n_0_[2]\,
      I4 => \up_rcount_reg_n_0_[1]\,
      I5 => \up_rcount_reg_n_0_[0]\,
      O => \up_rdata_d[10]_i_1_n_0\
    );
\up_rdata_d[11]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"EAAAAAAAAAAAAAAA"
    )
        port map (
      I0 => up_rdata(11),
      I1 => p_0_in6_in,
      I2 => \up_rcount_reg_n_0_[3]\,
      I3 => \up_rcount_reg_n_0_[2]\,
      I4 => \up_rcount_reg_n_0_[1]\,
      I5 => \up_rcount_reg_n_0_[0]\,
      O => \up_rdata_d[11]_i_1_n_0\
    );
\up_rdata_d[12]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"EAAAAAAAAAAAAAAA"
    )
        port map (
      I0 => up_rdata(12),
      I1 => p_0_in6_in,
      I2 => \up_rcount_reg_n_0_[3]\,
      I3 => \up_rcount_reg_n_0_[2]\,
      I4 => \up_rcount_reg_n_0_[1]\,
      I5 => \up_rcount_reg_n_0_[0]\,
      O => \up_rdata_d[12]_i_1_n_0\
    );
\up_rdata_d[14]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"EAAAAAAAAAAAAAAA"
    )
        port map (
      I0 => up_rdata(14),
      I1 => p_0_in6_in,
      I2 => \up_rcount_reg_n_0_[3]\,
      I3 => \up_rcount_reg_n_0_[2]\,
      I4 => \up_rcount_reg_n_0_[1]\,
      I5 => \up_rcount_reg_n_0_[0]\,
      O => \up_rdata_d[14]_i_1_n_0\
    );
\up_rdata_d[15]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"EAAAAAAAAAAAAAAA"
    )
        port map (
      I0 => up_rdata(15),
      I1 => p_0_in6_in,
      I2 => \up_rcount_reg_n_0_[3]\,
      I3 => \up_rcount_reg_n_0_[2]\,
      I4 => \up_rcount_reg_n_0_[1]\,
      I5 => \up_rcount_reg_n_0_[0]\,
      O => \up_rdata_d[15]_i_1_n_0\
    );
\up_rdata_d[16]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"EAAAAAAAAAAAAAAA"
    )
        port map (
      I0 => up_rdata(16),
      I1 => p_0_in6_in,
      I2 => \up_rcount_reg_n_0_[3]\,
      I3 => \up_rcount_reg_n_0_[2]\,
      I4 => \up_rcount_reg_n_0_[1]\,
      I5 => \up_rcount_reg_n_0_[0]\,
      O => \up_rdata_d[16]_i_1_n_0\
    );
\up_rdata_d[18]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"EAAAAAAAAAAAAAAA"
    )
        port map (
      I0 => up_rdata(18),
      I1 => p_0_in6_in,
      I2 => \up_rcount_reg_n_0_[3]\,
      I3 => \up_rcount_reg_n_0_[2]\,
      I4 => \up_rcount_reg_n_0_[1]\,
      I5 => \up_rcount_reg_n_0_[0]\,
      O => \up_rdata_d[18]_i_1_n_0\
    );
\up_rdata_d[19]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"EAAAAAAAAAAAAAAA"
    )
        port map (
      I0 => up_rdata(19),
      I1 => p_0_in6_in,
      I2 => \up_rcount_reg_n_0_[3]\,
      I3 => \up_rcount_reg_n_0_[2]\,
      I4 => \up_rcount_reg_n_0_[1]\,
      I5 => \up_rcount_reg_n_0_[0]\,
      O => \up_rdata_d[19]_i_1_n_0\
    );
\up_rdata_d[21]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"EAAAAAAAAAAAAAAA"
    )
        port map (
      I0 => up_rdata(21),
      I1 => p_0_in6_in,
      I2 => \up_rcount_reg_n_0_[3]\,
      I3 => \up_rcount_reg_n_0_[2]\,
      I4 => \up_rcount_reg_n_0_[1]\,
      I5 => \up_rcount_reg_n_0_[0]\,
      O => \up_rdata_d[21]_i_1_n_0\
    );
\up_rdata_d[23]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"EAAAAAAAAAAAAAAA"
    )
        port map (
      I0 => up_rdata(23),
      I1 => p_0_in6_in,
      I2 => \up_rcount_reg_n_0_[3]\,
      I3 => \up_rcount_reg_n_0_[2]\,
      I4 => \up_rcount_reg_n_0_[1]\,
      I5 => \up_rcount_reg_n_0_[0]\,
      O => \up_rdata_d[23]_i_1_n_0\
    );
\up_rdata_d[25]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"EAAAAAAAAAAAAAAA"
    )
        port map (
      I0 => up_rdata(25),
      I1 => p_0_in6_in,
      I2 => \up_rcount_reg_n_0_[3]\,
      I3 => \up_rcount_reg_n_0_[2]\,
      I4 => \up_rcount_reg_n_0_[1]\,
      I5 => \up_rcount_reg_n_0_[0]\,
      O => \up_rdata_d[25]_i_1_n_0\
    );
\up_rdata_d[26]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"EAAAAAAAAAAAAAAA"
    )
        port map (
      I0 => up_rdata(26),
      I1 => p_0_in6_in,
      I2 => \up_rcount_reg_n_0_[3]\,
      I3 => \up_rcount_reg_n_0_[2]\,
      I4 => \up_rcount_reg_n_0_[1]\,
      I5 => \up_rcount_reg_n_0_[0]\,
      O => \up_rdata_d[26]_i_1_n_0\
    );
\up_rdata_d[27]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"EAAAAAAAAAAAAAAA"
    )
        port map (
      I0 => up_rdata(27),
      I1 => p_0_in6_in,
      I2 => \up_rcount_reg_n_0_[3]\,
      I3 => \up_rcount_reg_n_0_[2]\,
      I4 => \up_rcount_reg_n_0_[1]\,
      I5 => \up_rcount_reg_n_0_[0]\,
      O => \up_rdata_d[27]_i_1_n_0\
    );
\up_rdata_d[28]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"EAAAAAAAAAAAAAAA"
    )
        port map (
      I0 => up_rdata(28),
      I1 => p_0_in6_in,
      I2 => \up_rcount_reg_n_0_[3]\,
      I3 => \up_rcount_reg_n_0_[2]\,
      I4 => \up_rcount_reg_n_0_[1]\,
      I5 => \up_rcount_reg_n_0_[0]\,
      O => \up_rdata_d[28]_i_1_n_0\
    );
\up_rdata_d[29]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"80000000FFFFFFFF"
    )
        port map (
      I0 => p_0_in6_in,
      I1 => \up_rcount_reg_n_0_[3]\,
      I2 => \up_rcount_reg_n_0_[2]\,
      I3 => \up_rcount_reg_n_0_[1]\,
      I4 => \up_rcount_reg_n_0_[0]\,
      I5 => up_rstn,
      O => \up_rdata_d[29]_i_1_n_0\
    );
\up_rdata_d[2]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"EAAAAAAAAAAAAAAA"
    )
        port map (
      I0 => up_rdata(2),
      I1 => p_0_in6_in,
      I2 => \up_rcount_reg_n_0_[3]\,
      I3 => \up_rcount_reg_n_0_[2]\,
      I4 => \up_rcount_reg_n_0_[1]\,
      I5 => \up_rcount_reg_n_0_[0]\,
      O => \up_rdata_d[2]_i_1_n_0\
    );
\up_rdata_d[30]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"EAAAAAAAAAAAAAAA"
    )
        port map (
      I0 => up_rdata(30),
      I1 => p_0_in6_in,
      I2 => \up_rcount_reg_n_0_[3]\,
      I3 => \up_rcount_reg_n_0_[2]\,
      I4 => \up_rcount_reg_n_0_[1]\,
      I5 => \up_rcount_reg_n_0_[0]\,
      O => \up_rdata_d[30]_i_1_n_0\
    );
\up_rdata_d[31]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"EAAAAAAAAAAAAAAA"
    )
        port map (
      I0 => up_rdata(31),
      I1 => p_0_in6_in,
      I2 => \up_rcount_reg_n_0_[3]\,
      I3 => \up_rcount_reg_n_0_[2]\,
      I4 => \up_rcount_reg_n_0_[1]\,
      I5 => \up_rcount_reg_n_0_[0]\,
      O => \up_rdata_d[31]_i_1_n_0\
    );
\up_rdata_d[3]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"EAAAAAAAAAAAAAAA"
    )
        port map (
      I0 => up_rdata(3),
      I1 => p_0_in6_in,
      I2 => \up_rcount_reg_n_0_[3]\,
      I3 => \up_rcount_reg_n_0_[2]\,
      I4 => \up_rcount_reg_n_0_[1]\,
      I5 => \up_rcount_reg_n_0_[0]\,
      O => \up_rdata_d[3]_i_1_n_0\
    );
\up_rdata_d[5]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"EAAAAAAAAAAAAAAA"
    )
        port map (
      I0 => up_rdata(5),
      I1 => p_0_in6_in,
      I2 => \up_rcount_reg_n_0_[3]\,
      I3 => \up_rcount_reg_n_0_[2]\,
      I4 => \up_rcount_reg_n_0_[1]\,
      I5 => \up_rcount_reg_n_0_[0]\,
      O => \up_rdata_d[5]_i_1_n_0\
    );
\up_rdata_d[7]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"EAAAAAAAAAAAAAAA"
    )
        port map (
      I0 => up_rdata(7),
      I1 => p_0_in6_in,
      I2 => \up_rcount_reg_n_0_[3]\,
      I3 => \up_rcount_reg_n_0_[2]\,
      I4 => \up_rcount_reg_n_0_[1]\,
      I5 => \up_rcount_reg_n_0_[0]\,
      O => \up_rdata_d[7]_i_1_n_0\
    );
\up_rdata_d[9]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"EAAAAAAAAAAAAAAA"
    )
        port map (
      I0 => up_rdata(9),
      I1 => p_0_in6_in,
      I2 => \up_rcount_reg_n_0_[3]\,
      I3 => \up_rcount_reg_n_0_[2]\,
      I4 => \up_rcount_reg_n_0_[1]\,
      I5 => \up_rcount_reg_n_0_[0]\,
      O => \up_rdata_d[9]_i_1_n_0\
    );
\up_rdata_d_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => \up_rdata_d[0]_i_1_n_0\,
      Q => up_rdata_d(0),
      R => p_0_in
    );
\up_rdata_d_reg[10]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => \up_rdata_d[10]_i_1_n_0\,
      Q => up_rdata_d(10),
      R => p_0_in
    );
\up_rdata_d_reg[11]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => \up_rdata_d[11]_i_1_n_0\,
      Q => up_rdata_d(11),
      R => p_0_in
    );
\up_rdata_d_reg[12]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => \up_rdata_d[12]_i_1_n_0\,
      Q => up_rdata_d(12),
      R => p_0_in
    );
\up_rdata_d_reg[13]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => up_rdata(13),
      Q => up_rdata_d(13),
      R => \up_rdata_d[29]_i_1_n_0\
    );
\up_rdata_d_reg[14]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => \up_rdata_d[14]_i_1_n_0\,
      Q => up_rdata_d(14),
      R => p_0_in
    );
\up_rdata_d_reg[15]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => \up_rdata_d[15]_i_1_n_0\,
      Q => up_rdata_d(15),
      R => p_0_in
    );
\up_rdata_d_reg[16]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => \up_rdata_d[16]_i_1_n_0\,
      Q => up_rdata_d(16),
      R => p_0_in
    );
\up_rdata_d_reg[17]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => up_rdata(17),
      Q => up_rdata_d(17),
      R => \up_rdata_d[29]_i_1_n_0\
    );
\up_rdata_d_reg[18]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => \up_rdata_d[18]_i_1_n_0\,
      Q => up_rdata_d(18),
      R => p_0_in
    );
\up_rdata_d_reg[19]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => \up_rdata_d[19]_i_1_n_0\,
      Q => up_rdata_d(19),
      R => p_0_in
    );
\up_rdata_d_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => up_rdata(1),
      Q => up_rdata_d(1),
      R => \up_rdata_d[29]_i_1_n_0\
    );
\up_rdata_d_reg[20]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => up_rdata(20),
      Q => up_rdata_d(20),
      R => \up_rdata_d[29]_i_1_n_0\
    );
\up_rdata_d_reg[21]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => \up_rdata_d[21]_i_1_n_0\,
      Q => up_rdata_d(21),
      R => p_0_in
    );
\up_rdata_d_reg[22]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => up_rdata(22),
      Q => up_rdata_d(22),
      R => \up_rdata_d[29]_i_1_n_0\
    );
\up_rdata_d_reg[23]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => \up_rdata_d[23]_i_1_n_0\,
      Q => up_rdata_d(23),
      R => p_0_in
    );
\up_rdata_d_reg[24]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => up_rdata(24),
      Q => up_rdata_d(24),
      R => \up_rdata_d[29]_i_1_n_0\
    );
\up_rdata_d_reg[25]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => \up_rdata_d[25]_i_1_n_0\,
      Q => up_rdata_d(25),
      R => p_0_in
    );
\up_rdata_d_reg[26]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => \up_rdata_d[26]_i_1_n_0\,
      Q => up_rdata_d(26),
      R => p_0_in
    );
\up_rdata_d_reg[27]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => \up_rdata_d[27]_i_1_n_0\,
      Q => up_rdata_d(27),
      R => p_0_in
    );
\up_rdata_d_reg[28]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => \up_rdata_d[28]_i_1_n_0\,
      Q => up_rdata_d(28),
      R => p_0_in
    );
\up_rdata_d_reg[29]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => up_rdata(29),
      Q => up_rdata_d(29),
      R => \up_rdata_d[29]_i_1_n_0\
    );
\up_rdata_d_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => \up_rdata_d[2]_i_1_n_0\,
      Q => up_rdata_d(2),
      R => p_0_in
    );
\up_rdata_d_reg[30]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => \up_rdata_d[30]_i_1_n_0\,
      Q => up_rdata_d(30),
      R => p_0_in
    );
\up_rdata_d_reg[31]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => \up_rdata_d[31]_i_1_n_0\,
      Q => up_rdata_d(31),
      R => p_0_in
    );
\up_rdata_d_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => \up_rdata_d[3]_i_1_n_0\,
      Q => up_rdata_d(3),
      R => p_0_in
    );
\up_rdata_d_reg[4]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => up_rdata(4),
      Q => up_rdata_d(4),
      R => \up_rdata_d[29]_i_1_n_0\
    );
\up_rdata_d_reg[5]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => \up_rdata_d[5]_i_1_n_0\,
      Q => up_rdata_d(5),
      R => p_0_in
    );
\up_rdata_d_reg[6]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => up_rdata(6),
      Q => up_rdata_d(6),
      R => \up_rdata_d[29]_i_1_n_0\
    );
\up_rdata_d_reg[7]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => \up_rdata_d[7]_i_1_n_0\,
      Q => up_rdata_d(7),
      R => p_0_in
    );
\up_rdata_d_reg[8]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => up_rdata(8),
      Q => up_rdata_d(8),
      R => \up_rdata_d[29]_i_1_n_0\
    );
\up_rdata_d_reg[9]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => \up_rdata_d[9]_i_1_n_0\,
      Q => up_rdata_d(9),
      R => p_0_in
    );
up_rreq_int_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"80"
    )
        port map (
      I0 => p_1_in_0,
      I1 => up_axi_arvalid,
      I2 => up_rstn,
      O => up_rreq_int_i_1_n_0
    );
up_rreq_int_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => up_rreq_int_i_1_n_0,
      Q => \^up_rreq\,
      R => '0'
    );
up_rsel_inv_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"55C0"
    )
        port map (
      I0 => up_axi_arvalid,
      I1 => up_axi_rready,
      I2 => \^up_axi_rvalid_int_reg_0\,
      I3 => p_1_in_0,
      O => up_rsel_inv_i_1_n_0
    );
up_rsel_reg_inv: unisim.vcomponents.FDSE
    generic map(
      INIT => '1'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => up_rsel_inv_i_1_n_0,
      Q => p_1_in_0,
      S => p_0_in
    );
up_wack_d_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFF000080000000"
    )
        port map (
      I0 => \up_wcount_reg_n_0_[3]\,
      I1 => \up_wcount_reg_n_0_[2]\,
      I2 => \up_wcount_reg_n_0_[1]\,
      I3 => \up_wcount_reg_n_0_[0]\,
      I4 => p_0_in7_in,
      I5 => up_wack,
      O => up_wack_s
    );
up_wack_d_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => up_wack_s,
      Q => up_wack_d,
      R => p_0_in
    );
\up_waddr_int_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_awaddr(0),
      Q => up_waddr(0),
      R => p_0_in
    );
\up_waddr_int_reg[10]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_awaddr(10),
      Q => up_waddr(10),
      R => p_0_in
    );
\up_waddr_int_reg[11]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_awaddr(11),
      Q => up_waddr(11),
      R => p_0_in
    );
\up_waddr_int_reg[12]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_awaddr(12),
      Q => up_waddr(12),
      R => p_0_in
    );
\up_waddr_int_reg[13]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_awaddr(13),
      Q => up_waddr(13),
      R => p_0_in
    );
\up_waddr_int_reg[14]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_awaddr(14),
      Q => up_waddr(14),
      R => p_0_in
    );
\up_waddr_int_reg[15]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_awaddr(15),
      Q => up_waddr(15),
      R => p_0_in
    );
\up_waddr_int_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_awaddr(1),
      Q => up_waddr(1),
      R => p_0_in
    );
\up_waddr_int_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_awaddr(2),
      Q => up_waddr(2),
      R => p_0_in
    );
\up_waddr_int_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_awaddr(3),
      Q => up_waddr(3),
      R => p_0_in
    );
\up_waddr_int_reg[4]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_awaddr(4),
      Q => up_waddr(4),
      R => p_0_in
    );
\up_waddr_int_reg[5]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_awaddr(5),
      Q => up_waddr(5),
      R => p_0_in
    );
\up_waddr_int_reg[6]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_awaddr(6),
      Q => up_waddr(6),
      R => p_0_in
    );
\up_waddr_int_reg[7]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_awaddr(7),
      Q => up_waddr(7),
      R => p_0_in
    );
\up_waddr_int_reg[8]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_awaddr(8),
      Q => up_waddr(8),
      R => p_0_in
    );
\up_waddr_int_reg[9]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_awaddr(9),
      Q => up_waddr(9),
      R => p_0_in
    );
\up_wcount[0]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"04"
    )
        port map (
      I0 => up_wack,
      I1 => p_0_in7_in,
      I2 => \up_wcount_reg_n_0_[0]\,
      O => \up_wcount[0]_i_1_n_0\
    );
\up_wcount[1]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"1400"
    )
        port map (
      I0 => up_wack,
      I1 => \up_wcount_reg_n_0_[0]\,
      I2 => \up_wcount_reg_n_0_[1]\,
      I3 => p_0_in7_in,
      O => p_2_in(1)
    );
\up_wcount[2]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"14440000"
    )
        port map (
      I0 => up_wack,
      I1 => \up_wcount_reg_n_0_[2]\,
      I2 => \up_wcount_reg_n_0_[1]\,
      I3 => \up_wcount_reg_n_0_[0]\,
      I4 => p_0_in7_in,
      O => \up_wcount[2]_i_1_n_0\
    );
\up_wcount[3]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"1444444400000000"
    )
        port map (
      I0 => up_wack,
      I1 => \up_wcount_reg_n_0_[3]\,
      I2 => \up_wcount_reg_n_0_[0]\,
      I3 => \up_wcount_reg_n_0_[1]\,
      I4 => \up_wcount_reg_n_0_[2]\,
      I5 => p_0_in7_in,
      O => p_2_in(3)
    );
\up_wcount[4]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => p_0_in7_in,
      I1 => \^up_wreq\,
      O => p_1_in
    );
\up_wcount[4]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"3777777777777777"
    )
        port map (
      I0 => up_wack,
      I1 => p_0_in7_in,
      I2 => \up_wcount_reg_n_0_[0]\,
      I3 => \up_wcount_reg_n_0_[1]\,
      I4 => \up_wcount_reg_n_0_[2]\,
      I5 => \up_wcount_reg_n_0_[3]\,
      O => p_2_in(4)
    );
\up_wcount_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_1_in,
      D => \up_wcount[0]_i_1_n_0\,
      Q => \up_wcount_reg_n_0_[0]\,
      R => p_0_in
    );
\up_wcount_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_1_in,
      D => p_2_in(1),
      Q => \up_wcount_reg_n_0_[1]\,
      R => p_0_in
    );
\up_wcount_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_1_in,
      D => \up_wcount[2]_i_1_n_0\,
      Q => \up_wcount_reg_n_0_[2]\,
      R => p_0_in
    );
\up_wcount_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_1_in,
      D => p_2_in(3),
      Q => \up_wcount_reg_n_0_[3]\,
      R => p_0_in
    );
\up_wcount_reg[4]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_1_in,
      D => p_2_in(4),
      Q => p_0_in7_in,
      R => p_0_in
    );
\up_wdata_int_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(0),
      Q => up_wdata(0),
      R => p_0_in
    );
\up_wdata_int_reg[10]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(10),
      Q => up_wdata(10),
      R => p_0_in
    );
\up_wdata_int_reg[11]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(11),
      Q => up_wdata(11),
      R => p_0_in
    );
\up_wdata_int_reg[12]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(12),
      Q => up_wdata(12),
      R => p_0_in
    );
\up_wdata_int_reg[13]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(13),
      Q => up_wdata(13),
      R => p_0_in
    );
\up_wdata_int_reg[14]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(14),
      Q => up_wdata(14),
      R => p_0_in
    );
\up_wdata_int_reg[15]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(15),
      Q => up_wdata(15),
      R => p_0_in
    );
\up_wdata_int_reg[16]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(16),
      Q => up_wdata(16),
      R => p_0_in
    );
\up_wdata_int_reg[17]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(17),
      Q => up_wdata(17),
      R => p_0_in
    );
\up_wdata_int_reg[18]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(18),
      Q => up_wdata(18),
      R => p_0_in
    );
\up_wdata_int_reg[19]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(19),
      Q => up_wdata(19),
      R => p_0_in
    );
\up_wdata_int_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(1),
      Q => up_wdata(1),
      R => p_0_in
    );
\up_wdata_int_reg[20]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(20),
      Q => up_wdata(20),
      R => p_0_in
    );
\up_wdata_int_reg[21]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(21),
      Q => up_wdata(21),
      R => p_0_in
    );
\up_wdata_int_reg[22]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(22),
      Q => up_wdata(22),
      R => p_0_in
    );
\up_wdata_int_reg[23]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(23),
      Q => up_wdata(23),
      R => p_0_in
    );
\up_wdata_int_reg[24]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(24),
      Q => up_wdata(24),
      R => p_0_in
    );
\up_wdata_int_reg[25]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(25),
      Q => up_wdata(25),
      R => p_0_in
    );
\up_wdata_int_reg[26]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(26),
      Q => up_wdata(26),
      R => p_0_in
    );
\up_wdata_int_reg[27]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(27),
      Q => up_wdata(27),
      R => p_0_in
    );
\up_wdata_int_reg[28]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(28),
      Q => up_wdata(28),
      R => p_0_in
    );
\up_wdata_int_reg[29]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(29),
      Q => up_wdata(29),
      R => p_0_in
    );
\up_wdata_int_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(2),
      Q => up_wdata(2),
      R => p_0_in
    );
\up_wdata_int_reg[30]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(30),
      Q => up_wdata(30),
      R => p_0_in
    );
\up_wdata_int_reg[31]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(31),
      Q => up_wdata(31),
      R => p_0_in
    );
\up_wdata_int_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(3),
      Q => up_wdata(3),
      R => p_0_in
    );
\up_wdata_int_reg[4]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(4),
      Q => up_wdata(4),
      R => p_0_in
    );
\up_wdata_int_reg[5]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(5),
      Q => up_wdata(5),
      R => p_0_in
    );
\up_wdata_int_reg[6]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(6),
      Q => up_wdata(6),
      R => p_0_in
    );
\up_wdata_int_reg[7]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(7),
      Q => up_wdata(7),
      R => p_0_in
    );
\up_wdata_int_reg[8]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(8),
      Q => up_wdata(8),
      R => p_0_in
    );
\up_wdata_int_reg[9]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => p_5_in,
      D => up_axi_wdata(9),
      Q => up_wdata(9),
      R => p_0_in
    );
up_wreq_int_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => p_5_in,
      I1 => up_axi_wvalid,
      I2 => up_axi_awvalid,
      I3 => up_rstn,
      O => up_wreq_int_i_1_n_0
    );
up_wreq_int_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => up_wreq_int_i_1_n_0,
      Q => \^up_wreq\,
      R => '0'
    );
up_wsel_inv_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"7777F000"
    )
        port map (
      I0 => up_axi_awvalid,
      I1 => up_axi_wvalid,
      I2 => up_axi_bready,
      I3 => \^up_axi_bvalid\,
      I4 => p_5_in,
      O => up_wsel_inv_i_1_n_0
    );
up_wsel_reg_inv: unisim.vcomponents.FDSE
    generic map(
      INIT => '1'
    )
        port map (
      C => up_clk,
      CE => '1',
      D => up_wsel_inv_i_1_n_0,
      Q => p_5_in,
      S => p_0_in
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity system_up_axi_0_0 is
  port (
    up_rstn : in STD_LOGIC;
    up_clk : in STD_LOGIC;
    up_axi_awvalid : in STD_LOGIC;
    up_axi_awaddr : in STD_LOGIC_VECTOR ( 15 downto 0 );
    up_axi_awready : out STD_LOGIC;
    up_axi_wvalid : in STD_LOGIC;
    up_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    up_axi_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    up_axi_wready : out STD_LOGIC;
    up_axi_bvalid : out STD_LOGIC;
    up_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    up_axi_bready : in STD_LOGIC;
    up_axi_arvalid : in STD_LOGIC;
    up_axi_araddr : in STD_LOGIC_VECTOR ( 15 downto 0 );
    up_axi_arready : out STD_LOGIC;
    up_axi_rvalid : out STD_LOGIC;
    up_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    up_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    up_axi_rready : in STD_LOGIC;
    up_wreq : out STD_LOGIC;
    up_waddr : out STD_LOGIC_VECTOR ( 15 downto 0 );
    up_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    up_wack : in STD_LOGIC;
    up_rreq : out STD_LOGIC;
    up_raddr : out STD_LOGIC_VECTOR ( 15 downto 0 );
    up_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    up_rack : in STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of system_up_axi_0_0 : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of system_up_axi_0_0 : entity is "system_up_axi_0_0,up_axi,{}";
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of system_up_axi_0_0 : entity is "yes";
  attribute IP_DEFINITION_SOURCE : string;
  attribute IP_DEFINITION_SOURCE of system_up_axi_0_0 : entity is "module_ref";
  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of system_up_axi_0_0 : entity is "up_axi,Vivado 2025.2";
end system_up_axi_0_0;

architecture STRUCTURE of system_up_axi_0_0 is
  signal \<const0>\ : STD_LOGIC;
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of up_axi_arready : signal is "xilinx.com:interface:aximm:1.0 up_axi ARREADY";
  attribute X_INTERFACE_INFO of up_axi_arvalid : signal is "xilinx.com:interface:aximm:1.0 up_axi ARVALID";
  attribute X_INTERFACE_INFO of up_axi_awready : signal is "xilinx.com:interface:aximm:1.0 up_axi AWREADY";
  attribute X_INTERFACE_INFO of up_axi_awvalid : signal is "xilinx.com:interface:aximm:1.0 up_axi AWVALID";
  attribute X_INTERFACE_MODE : string;
  attribute X_INTERFACE_MODE of up_axi_awvalid : signal is "slave";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of up_axi_awvalid : signal is "XIL_INTERFACENAME up_axi, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 99999001, ID_WIDTH 0, ADDR_WIDTH 16, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.0, CLK_DOMAIN system_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of up_axi_bready : signal is "xilinx.com:interface:aximm:1.0 up_axi BREADY";
  attribute X_INTERFACE_INFO of up_axi_bvalid : signal is "xilinx.com:interface:aximm:1.0 up_axi BVALID";
  attribute X_INTERFACE_INFO of up_axi_rready : signal is "xilinx.com:interface:aximm:1.0 up_axi RREADY";
  attribute X_INTERFACE_INFO of up_axi_rvalid : signal is "xilinx.com:interface:aximm:1.0 up_axi RVALID";
  attribute X_INTERFACE_INFO of up_axi_wready : signal is "xilinx.com:interface:aximm:1.0 up_axi WREADY";
  attribute X_INTERFACE_INFO of up_axi_wvalid : signal is "xilinx.com:interface:aximm:1.0 up_axi WVALID";
  attribute X_INTERFACE_INFO of up_clk : signal is "xilinx.com:signal:clock:1.0 up_clk CLK";
  attribute X_INTERFACE_MODE of up_clk : signal is "slave";
  attribute X_INTERFACE_PARAMETER of up_clk : signal is "XIL_INTERFACENAME up_clk, ASSOCIATED_RESET up_rstn, FREQ_HZ 99999001, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN system_zynq_ultra_ps_e_0_0_pl_clk0, ASSOCIATED_BUSIF up_axi, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of up_rstn : signal is "xilinx.com:signal:reset:1.0 up_rstn RST";
  attribute X_INTERFACE_MODE of up_rstn : signal is "slave";
  attribute X_INTERFACE_PARAMETER of up_rstn : signal is "XIL_INTERFACENAME up_rstn, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of up_axi_araddr : signal is "xilinx.com:interface:aximm:1.0 up_axi ARADDR";
  attribute X_INTERFACE_INFO of up_axi_awaddr : signal is "xilinx.com:interface:aximm:1.0 up_axi AWADDR";
  attribute X_INTERFACE_INFO of up_axi_bresp : signal is "xilinx.com:interface:aximm:1.0 up_axi BRESP";
  attribute X_INTERFACE_INFO of up_axi_rdata : signal is "xilinx.com:interface:aximm:1.0 up_axi RDATA";
  attribute X_INTERFACE_INFO of up_axi_rresp : signal is "xilinx.com:interface:aximm:1.0 up_axi RRESP";
  attribute X_INTERFACE_INFO of up_axi_wdata : signal is "xilinx.com:interface:aximm:1.0 up_axi WDATA";
  attribute X_INTERFACE_INFO of up_axi_wstrb : signal is "xilinx.com:interface:aximm:1.0 up_axi WSTRB";
begin
  up_axi_bresp(1) <= \<const0>\;
  up_axi_bresp(0) <= \<const0>\;
  up_axi_rresp(1) <= \<const0>\;
  up_axi_rresp(0) <= \<const0>\;
GND: unisim.vcomponents.GND
     port map (
      G => \<const0>\
    );
inst: entity work.system_up_axi_0_0_up_axi
     port map (
      up_axi_araddr(15 downto 0) => up_axi_araddr(15 downto 0),
      up_axi_arready => up_axi_arready,
      up_axi_arvalid => up_axi_arvalid,
      up_axi_awaddr(15 downto 0) => up_axi_awaddr(15 downto 0),
      up_axi_awready => up_axi_awready,
      up_axi_awvalid => up_axi_awvalid,
      up_axi_bready => up_axi_bready,
      up_axi_bvalid => up_axi_bvalid,
      up_axi_rdata(31 downto 0) => up_axi_rdata(31 downto 0),
      up_axi_rready => up_axi_rready,
      up_axi_rvalid_int_reg_0 => up_axi_rvalid,
      up_axi_wdata(31 downto 0) => up_axi_wdata(31 downto 0),
      up_axi_wready => up_axi_wready,
      up_axi_wvalid => up_axi_wvalid,
      up_clk => up_clk,
      up_rack => up_rack,
      up_raddr(15 downto 0) => up_raddr(15 downto 0),
      up_rdata(31 downto 0) => up_rdata(31 downto 0),
      up_rreq => up_rreq,
      up_rstn => up_rstn,
      up_wack => up_wack,
      up_waddr(15 downto 0) => up_waddr(15 downto 0),
      up_wdata(31 downto 0) => up_wdata(31 downto 0),
      up_wreq => up_wreq
    );
end STRUCTURE;

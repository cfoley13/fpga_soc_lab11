--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
--Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2025.2 (lin64) Build 6299465 Fri Nov 14 12:34:56 MST 2025
--Date        : Fri Mar 27 01:03:56 2026
--Host        : cachyos-x8664 running 64-bit CachyOS
--Command     : generate_target radio_bd.bd
--Design      : radio_bd
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity radio_bd is
  port (
    dds_fake_adc_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    dds_fake_adc_tvalid : in STD_LOGIC;
    dds_tuner_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    dds_tuner_tvalid : in STD_LOGIC;
    imag_data : out STD_LOGIC_VECTOR ( 15 downto 0 );
    real_data : out STD_LOGIC_VECTOR ( 15 downto 0 );
    resetn : in STD_LOGIC;
    sys_clk : in STD_LOGIC;
    tdata_valid : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  attribute core_generation_info : string;
  attribute core_generation_info of radio_bd : entity is "radio_bd,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=radio_bd,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=17,numReposBlks=17,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=Hierarchical}";
  attribute hw_handoff : string;
  attribute hw_handoff of radio_bd : entity is "radio_bd.hwdef";
end radio_bd;

architecture STRUCTURE of radio_bd is
  component radio_bd_cmpy_0_0 is
  port (
    aclk : in STD_LOGIC;
    s_axis_a_tvalid : in STD_LOGIC;
    s_axis_a_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_b_tvalid : in STD_LOGIC;
    s_axis_b_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_dout_tvalid : out STD_LOGIC;
    m_axis_dout_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  end component radio_bd_cmpy_0_0;
  component radio_bd_real_filter_1_0 is
  port (
    aresetn : in STD_LOGIC;
    aclk : in STD_LOGIC;
    s_axis_data_tvalid : in STD_LOGIC;
    s_axis_data_tready : out STD_LOGIC;
    s_axis_data_tdata : in STD_LOGIC_VECTOR ( 15 downto 0 );
    m_axis_data_tvalid : out STD_LOGIC;
    m_axis_data_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  end component radio_bd_real_filter_1_0;
  component radio_bd_imag_filter_1_0 is
  port (
    aresetn : in STD_LOGIC;
    aclk : in STD_LOGIC;
    s_axis_data_tvalid : in STD_LOGIC;
    s_axis_data_tready : out STD_LOGIC;
    s_axis_data_tdata : in STD_LOGIC_VECTOR ( 15 downto 0 );
    m_axis_data_tvalid : out STD_LOGIC;
    m_axis_data_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  end component radio_bd_imag_filter_1_0;
  component radio_bd_real_filter_2_0 is
  port (
    aresetn : in STD_LOGIC;
    aclk : in STD_LOGIC;
    s_axis_data_tvalid : in STD_LOGIC;
    s_axis_data_tready : out STD_LOGIC;
    s_axis_data_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_data_tvalid : out STD_LOGIC;
    m_axis_data_tdata : out STD_LOGIC_VECTOR ( 15 downto 0 )
  );
  end component radio_bd_real_filter_2_0;
  component radio_bd_imag_filter_2_0 is
  port (
    aresetn : in STD_LOGIC;
    aclk : in STD_LOGIC;
    s_axis_data_tvalid : in STD_LOGIC;
    s_axis_data_tready : out STD_LOGIC;
    s_axis_data_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_data_tvalid : out STD_LOGIC;
    m_axis_data_tdata : out STD_LOGIC_VECTOR ( 15 downto 0 )
  );
  end component radio_bd_imag_filter_2_0;
  component radio_bd_dds_compiler_1_0 is
  port (
    aclk : in STD_LOGIC;
    aresetn : in STD_LOGIC;
    s_axis_config_tvalid : in STD_LOGIC;
    s_axis_config_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_data_tvalid : out STD_LOGIC;
    m_axis_data_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_phase_tvalid : out STD_LOGIC;
    m_axis_phase_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  end component radio_bd_dds_compiler_1_0;
  signal cmpy_0_m_axis_dout_tdata : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal cmpy_0_m_axis_dout_tvalid : STD_LOGIC;
  signal dds_compiler_0_M_AXIS_DATA_TDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal dds_compiler_0_M_AXIS_DATA_TVALID : STD_LOGIC;
  signal ilconstant_0_dout : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal ilconstant_1_dout : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal imag_filter_1_M_AXIS_DATA_TDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal imag_filter_1_M_AXIS_DATA_TVALID : STD_LOGIC;
  signal imag_filter_2_m_axis_data_tdata : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal imag_filter_2_m_axis_data_tvalid : STD_LOGIC;
  signal imag_slice_Dout : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal real_filter_1_M_AXIS_DATA_TDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal real_filter_1_M_AXIS_DATA_TVALID : STD_LOGIC;
  signal real_filter_2_m_axis_data_tdata : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal real_filter_2_m_axis_data_tvalid : STD_LOGIC;
  signal real_slice_Dout : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal slice_imag2_Dout : STD_LOGIC_VECTOR ( 0 to 0 );
  signal slice_imag_Dout : STD_LOGIC_VECTOR ( 8 downto 0 );
  signal slice_real2_Dout : STD_LOGIC_VECTOR ( 0 to 0 );
  signal slice_real_Dout : STD_LOGIC_VECTOR ( 8 downto 0 );
  signal NLW_dds_compiler_1_m_axis_phase_tvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_dds_compiler_1_m_axis_phase_tdata_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_imag_filter_1_s_axis_data_tready_UNCONNECTED : STD_LOGIC;
  signal NLW_imag_filter_2_s_axis_data_tready_UNCONNECTED : STD_LOGIC;
  signal NLW_real_filter_1_s_axis_data_tready_UNCONNECTED : STD_LOGIC;
  signal NLW_real_filter_2_s_axis_data_tready_UNCONNECTED : STD_LOGIC;
  attribute x_interface_info : string;
  attribute x_interface_info of dds_fake_adc_tvalid : signal is "xilinx.com:interface:axis:1.0 dds_fake_adc TVALID";
  attribute x_interface_info of dds_tuner_tvalid : signal is "xilinx.com:interface:axis:1.0 dds_tuner TVALID";
  attribute x_interface_info of resetn : signal is "xilinx.com:signal:reset:1.0 RST.RESETN RST";
  attribute x_interface_parameter : string;
  attribute x_interface_parameter of resetn : signal is "XIL_INTERFACENAME RST.RESETN, INSERT_VIP 0, POLARITY ACTIVE_LOW";
  attribute x_interface_info of sys_clk : signal is "xilinx.com:signal:clock:1.0 CLK.SYS_CLK CLK";
  attribute x_interface_parameter of sys_clk : signal is "XIL_INTERFACENAME CLK.SYS_CLK, ASSOCIATED_BUSIF dds_fake_adc:dds_tuner, ASSOCIATED_RESET resetn, CLK_DOMAIN radio_bd_aclk_0, FREQ_HZ 125000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0";
  attribute x_interface_info of dds_fake_adc_tdata : signal is "xilinx.com:interface:axis:1.0 dds_fake_adc TDATA";
  attribute x_interface_mode : string;
  attribute x_interface_mode of dds_fake_adc_tdata : signal is "Slave";
  attribute x_interface_parameter of dds_fake_adc_tdata : signal is "XIL_INTERFACENAME dds_fake_adc, CLK_DOMAIN radio_bd_aclk_0, FREQ_HZ 125000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 0, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0";
  attribute x_interface_info of dds_tuner_tdata : signal is "xilinx.com:interface:axis:1.0 dds_tuner TDATA";
  attribute x_interface_mode of dds_tuner_tdata : signal is "Slave";
  attribute x_interface_parameter of dds_tuner_tdata : signal is "XIL_INTERFACENAME dds_tuner, CLK_DOMAIN radio_bd_aclk_0, FREQ_HZ 125000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 0, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0";
begin
cmpy_0: component radio_bd_cmpy_0_0
     port map (
      aclk => sys_clk,
      m_axis_dout_tdata(31 downto 0) => cmpy_0_m_axis_dout_tdata(31 downto 0),
      m_axis_dout_tvalid => cmpy_0_m_axis_dout_tvalid,
      s_axis_a_tdata(31 downto 0) => dds_fake_adc_tdata(31 downto 0),
      s_axis_a_tvalid => dds_fake_adc_tvalid,
      s_axis_b_tdata(31 downto 0) => dds_compiler_0_M_AXIS_DATA_TDATA(31 downto 0),
      s_axis_b_tvalid => dds_compiler_0_M_AXIS_DATA_TVALID
    );
dds_compiler_1: component radio_bd_dds_compiler_1_0
     port map (
      aclk => sys_clk,
      aresetn => resetn,
      m_axis_data_tdata(31 downto 0) => dds_compiler_0_M_AXIS_DATA_TDATA(31 downto 0),
      m_axis_data_tvalid => dds_compiler_0_M_AXIS_DATA_TVALID,
      m_axis_phase_tdata(31 downto 0) => NLW_dds_compiler_1_m_axis_phase_tdata_UNCONNECTED(31 downto 0),
      m_axis_phase_tvalid => NLW_dds_compiler_1_m_axis_phase_tvalid_UNCONNECTED,
      s_axis_config_tdata(31 downto 0) => dds_tuner_tdata(31 downto 0),
      s_axis_config_tvalid => dds_tuner_tvalid
    );
  ilconstant_0_dout <= B"000000";
  ilconstant_1_dout <= B"000000";
  tdata_valid <= (0 to 0 => real_filter_2_m_axis_data_tvalid) and (0 to 0 => imag_filter_2_m_axis_data_tvalid);
imag_filter_1: component radio_bd_imag_filter_1_0
     port map (
      aclk => sys_clk,
      aresetn => resetn,
      m_axis_data_tdata(31 downto 0) => imag_filter_1_M_AXIS_DATA_TDATA(31 downto 0),
      m_axis_data_tvalid => imag_filter_1_M_AXIS_DATA_TVALID,
      s_axis_data_tdata(15 downto 0) => imag_slice_Dout(15 downto 0),
      s_axis_data_tready => NLW_imag_filter_1_s_axis_data_tready_UNCONNECTED,
      s_axis_data_tvalid => cmpy_0_m_axis_dout_tvalid
    );
imag_filter_2: component radio_bd_imag_filter_2_0
     port map (
      aclk => sys_clk,
      aresetn => resetn,
      m_axis_data_tdata(15 downto 0) => imag_filter_2_m_axis_data_tdata(15 downto 0),
      m_axis_data_tvalid => imag_filter_2_m_axis_data_tvalid,
      s_axis_data_tdata(31 downto 0) => imag_filter_1_M_AXIS_DATA_TDATA(31 downto 0),
      s_axis_data_tready => NLW_imag_filter_2_s_axis_data_tready_UNCONNECTED,
      s_axis_data_tvalid => imag_filter_1_M_AXIS_DATA_TVALID
    );
  imag_data <= slice_imag2_Dout & slice_imag_Dout & ilconstant_0_dout;
  imag_slice_Dout <= cmpy_0_m_axis_dout_tdata(15 downto 0);
real_filter_1: component radio_bd_real_filter_1_0
     port map (
      aclk => sys_clk,
      aresetn => resetn,
      m_axis_data_tdata(31 downto 0) => real_filter_1_M_AXIS_DATA_TDATA(31 downto 0),
      m_axis_data_tvalid => real_filter_1_M_AXIS_DATA_TVALID,
      s_axis_data_tdata(15 downto 0) => real_slice_Dout(15 downto 0),
      s_axis_data_tready => NLW_real_filter_1_s_axis_data_tready_UNCONNECTED,
      s_axis_data_tvalid => cmpy_0_m_axis_dout_tvalid
    );
real_filter_2: component radio_bd_real_filter_2_0
     port map (
      aclk => sys_clk,
      aresetn => resetn,
      m_axis_data_tdata(15 downto 0) => real_filter_2_m_axis_data_tdata(15 downto 0),
      m_axis_data_tvalid => real_filter_2_m_axis_data_tvalid,
      s_axis_data_tdata(31 downto 0) => real_filter_1_M_AXIS_DATA_TDATA(31 downto 0),
      s_axis_data_tready => NLW_real_filter_2_s_axis_data_tready_UNCONNECTED,
      s_axis_data_tvalid => real_filter_1_M_AXIS_DATA_TVALID
    );
  real_data <= slice_real2_Dout & slice_real_Dout & ilconstant_1_dout;
  real_slice_Dout <= cmpy_0_m_axis_dout_tdata(31 downto 16);
  slice_imag_Dout <= imag_filter_2_m_axis_data_tdata(8 downto 0);
  slice_imag2_Dout <= imag_filter_2_m_axis_data_tdata(0 downto 0);
  slice_real_Dout <= real_filter_2_m_axis_data_tdata(8 downto 0);
  slice_real2_Dout <= real_filter_2_m_axis_data_tdata(0 downto 0);
end STRUCTURE;

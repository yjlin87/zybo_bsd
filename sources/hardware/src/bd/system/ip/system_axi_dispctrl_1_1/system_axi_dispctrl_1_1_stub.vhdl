-- Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2016.4 (lin64) Build 1733598 Wed Dec 14 22:35:42 MST 2016
-- Date        : Wed Aug 30 19:25:52 2017
-- Host        : linux-2fny.suse running 64-bit openSUSE Leap 42.1 (x86_64)
-- Command     : write_vhdl -force -mode synth_stub
--               /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_axi_dispctrl_1_1/system_axi_dispctrl_1_1_stub.vhdl
-- Design      : system_axi_dispctrl_1_1
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z010clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity system_axi_dispctrl_1_1 is
  Port ( 
    REF_CLK_I : in STD_LOGIC;
    PXL_CLK_O : out STD_LOGIC;
    PXL_CLK_5X_O : out STD_LOGIC;
    LOCKED_O : out STD_LOGIC;
    FSYNC_O : out STD_LOGIC;
    HSYNC_O : out STD_LOGIC;
    VSYNC_O : out STD_LOGIC;
    DE_O : out STD_LOGIC;
    RED_O : out STD_LOGIC_VECTOR ( 7 downto 0 );
    GREEN_O : out STD_LOGIC_VECTOR ( 7 downto 0 );
    BLUE_O : out STD_LOGIC_VECTOR ( 7 downto 0 );
    DEBUG_O : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_aclk : in STD_LOGIC;
    s_axi_aresetn : in STD_LOGIC;
    s_axi_awaddr : in STD_LOGIC_VECTOR ( 5 downto 0 );
    s_axi_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_awvalid : in STD_LOGIC;
    s_axi_awready : out STD_LOGIC;
    s_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_wvalid : in STD_LOGIC;
    s_axi_wready : out STD_LOGIC;
    s_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_bvalid : out STD_LOGIC;
    s_axi_bready : in STD_LOGIC;
    s_axi_araddr : in STD_LOGIC_VECTOR ( 5 downto 0 );
    s_axi_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_arvalid : in STD_LOGIC;
    s_axi_arready : out STD_LOGIC;
    s_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_rvalid : out STD_LOGIC;
    s_axi_rready : in STD_LOGIC;
    s_axis_mm2s_aclk : in STD_LOGIC;
    s_axis_mm2s_aresetn : in STD_LOGIC;
    s_axis_mm2s_tready : out STD_LOGIC;
    s_axis_mm2s_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_mm2s_tstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axis_mm2s_tlast : in STD_LOGIC;
    s_axis_mm2s_tvalid : in STD_LOGIC
  );

end system_axi_dispctrl_1_1;

architecture stub of system_axi_dispctrl_1_1 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "REF_CLK_I,PXL_CLK_O,PXL_CLK_5X_O,LOCKED_O,FSYNC_O,HSYNC_O,VSYNC_O,DE_O,RED_O[7:0],GREEN_O[7:0],BLUE_O[7:0],DEBUG_O[31:0],s_axi_aclk,s_axi_aresetn,s_axi_awaddr[5:0],s_axi_awprot[2:0],s_axi_awvalid,s_axi_awready,s_axi_wdata[31:0],s_axi_wstrb[3:0],s_axi_wvalid,s_axi_wready,s_axi_bresp[1:0],s_axi_bvalid,s_axi_bready,s_axi_araddr[5:0],s_axi_arprot[2:0],s_axi_arvalid,s_axi_arready,s_axi_rdata[31:0],s_axi_rresp[1:0],s_axi_rvalid,s_axi_rready,s_axis_mm2s_aclk,s_axis_mm2s_aresetn,s_axis_mm2s_tready,s_axis_mm2s_tdata[31:0],s_axis_mm2s_tstrb[3:0],s_axis_mm2s_tlast,s_axis_mm2s_tvalid";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "axi_dispctrl_v1_0,Vivado 2016.4";
begin
end;

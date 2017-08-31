-- Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2016.4 (lin64) Build 1733598 Wed Dec 14 22:35:42 MST 2016
-- Date        : Wed Aug 30 19:24:28 2017
-- Host        : linux-2fny.suse running 64-bit openSUSE Leap 42.1 (x86_64)
-- Command     : write_vhdl -force -mode funcsim
--               /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_xlconstant_0_2/system_xlconstant_0_2_sim_netlist.vhdl
-- Design      : system_xlconstant_0_2
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7z010clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity system_xlconstant_0_2 is
  port (
    dout : out STD_LOGIC_VECTOR ( 5 downto 0 )
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of system_xlconstant_0_2 : entity is true;
  attribute downgradeipidentifiedwarnings : string;
  attribute downgradeipidentifiedwarnings of system_xlconstant_0_2 : entity is "yes";
end system_xlconstant_0_2;

architecture STRUCTURE of system_xlconstant_0_2 is
  signal \<const0>\ : STD_LOGIC;
begin
  dout(5) <= \<const0>\;
  dout(4) <= \<const0>\;
  dout(3) <= \<const0>\;
  dout(2) <= \<const0>\;
  dout(1) <= \<const0>\;
  dout(0) <= \<const0>\;
GND: unisim.vcomponents.GND
     port map (
      G => \<const0>\
    );
end STRUCTURE;

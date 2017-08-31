-- Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2016.4 (lin64) Build 1733598 Wed Dec 14 22:35:42 MST 2016
-- Date        : Wed Aug 30 19:24:28 2017
-- Host        : linux-2fny.suse running 64-bit openSUSE Leap 42.1 (x86_64)
-- Command     : write_vhdl -force -mode synth_stub
--               /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_xlconstant_0_2/system_xlconstant_0_2_stub.vhdl
-- Design      : system_xlconstant_0_2
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z010clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity system_xlconstant_0_2 is
  Port ( 
    dout : out STD_LOGIC_VECTOR ( 5 downto 0 )
  );

end system_xlconstant_0_2;

architecture stub of system_xlconstant_0_2 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "dout[5:0]";
begin
end;

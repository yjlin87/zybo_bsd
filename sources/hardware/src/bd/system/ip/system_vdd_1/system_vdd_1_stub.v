// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.4 (lin64) Build 1733598 Wed Dec 14 22:35:42 MST 2016
// Date        : Wed Aug 30 19:24:28 2017
// Host        : linux-2fny.suse running 64-bit openSUSE Leap 42.1 (x86_64)
// Command     : write_verilog -force -mode synth_stub
//               /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_vdd_1/system_vdd_1_stub.v
// Design      : system_vdd_1
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module system_vdd_1(dout)
/* synthesis syn_black_box black_box_pad_pin="dout[0:0]" */;
  output [0:0]dout;
endmodule

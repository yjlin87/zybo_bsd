// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.4 (lin64) Build 1733598 Wed Dec 14 22:35:42 MST 2016
// Date        : Wed Aug 30 19:25:36 2017
// Host        : linux-2fny.suse running 64-bit openSUSE Leap 42.1 (x86_64)
// Command     : write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ system_hdmi_tx_0_0_stub.v
// Design      : system_hdmi_tx_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "hdmi_tx,Vivado 2016.4" *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix(PXLCLK_I, PXLCLK_5X_I, LOCKED_I, RST_I, VGA_HS, 
  VGA_VS, VGA_DE, VGA_R, VGA_G, VGA_B, HDMI_CLK_P, HDMI_CLK_N, HDMI_D2_P, HDMI_D2_N, HDMI_D1_P, 
  HDMI_D1_N, HDMI_D0_P, HDMI_D0_N)
/* synthesis syn_black_box black_box_pad_pin="PXLCLK_I,PXLCLK_5X_I,LOCKED_I,RST_I,VGA_HS,VGA_VS,VGA_DE,VGA_R[7:0],VGA_G[7:0],VGA_B[7:0],HDMI_CLK_P,HDMI_CLK_N,HDMI_D2_P,HDMI_D2_N,HDMI_D1_P,HDMI_D1_N,HDMI_D0_P,HDMI_D0_N" */;
  input PXLCLK_I;
  input PXLCLK_5X_I;
  input LOCKED_I;
  input RST_I;
  input VGA_HS;
  input VGA_VS;
  input VGA_DE;
  input [7:0]VGA_R;
  input [7:0]VGA_G;
  input [7:0]VGA_B;
  output HDMI_CLK_P;
  output HDMI_CLK_N;
  output HDMI_D2_P;
  output HDMI_D2_N;
  output HDMI_D1_P;
  output HDMI_D1_N;
  output HDMI_D0_P;
  output HDMI_D0_N;
endmodule

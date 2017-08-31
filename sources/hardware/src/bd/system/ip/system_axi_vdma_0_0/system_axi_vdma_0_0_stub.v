// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.4 (lin64) Build 1733598 Wed Dec 14 22:35:42 MST 2016
// Date        : Wed Aug 30 19:29:58 2017
// Host        : linux-2fny.suse running 64-bit openSUSE Leap 42.1 (x86_64)
// Command     : write_verilog -force -mode synth_stub
//               /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_axi_vdma_0_0/system_axi_vdma_0_0_stub.v
// Design      : system_axi_vdma_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "axi_vdma,Vivado 2016.4" *)
module system_axi_vdma_0_0(s_axi_lite_aclk, m_axi_mm2s_aclk, 
  m_axis_mm2s_aclk, axi_resetn, s_axi_lite_awvalid, s_axi_lite_awready, s_axi_lite_awaddr, 
  s_axi_lite_wvalid, s_axi_lite_wready, s_axi_lite_wdata, s_axi_lite_bresp, 
  s_axi_lite_bvalid, s_axi_lite_bready, s_axi_lite_arvalid, s_axi_lite_arready, 
  s_axi_lite_araddr, s_axi_lite_rvalid, s_axi_lite_rready, s_axi_lite_rdata, 
  s_axi_lite_rresp, mm2s_fsync, mm2s_frame_ptr_in, mm2s_frame_ptr_out, mm2s_buffer_empty, 
  mm2s_buffer_almost_empty, mm2s_fsync_out, mm2s_prmtr_update, m_axi_mm2s_araddr, 
  m_axi_mm2s_arlen, m_axi_mm2s_arsize, m_axi_mm2s_arburst, m_axi_mm2s_arprot, 
  m_axi_mm2s_arcache, m_axi_mm2s_arvalid, m_axi_mm2s_arready, m_axi_mm2s_rdata, 
  m_axi_mm2s_rresp, m_axi_mm2s_rlast, m_axi_mm2s_rvalid, m_axi_mm2s_rready, 
  mm2s_prmry_reset_out_n, m_axis_mm2s_tdata, m_axis_mm2s_tkeep, m_axis_mm2s_tuser, 
  m_axis_mm2s_tvalid, m_axis_mm2s_tready, m_axis_mm2s_tlast, mm2s_introut, axi_vdma_tstvec)
/* synthesis syn_black_box black_box_pad_pin="s_axi_lite_aclk,m_axi_mm2s_aclk,m_axis_mm2s_aclk,axi_resetn,s_axi_lite_awvalid,s_axi_lite_awready,s_axi_lite_awaddr[8:0],s_axi_lite_wvalid,s_axi_lite_wready,s_axi_lite_wdata[31:0],s_axi_lite_bresp[1:0],s_axi_lite_bvalid,s_axi_lite_bready,s_axi_lite_arvalid,s_axi_lite_arready,s_axi_lite_araddr[8:0],s_axi_lite_rvalid,s_axi_lite_rready,s_axi_lite_rdata[31:0],s_axi_lite_rresp[1:0],mm2s_fsync,mm2s_frame_ptr_in[5:0],mm2s_frame_ptr_out[5:0],mm2s_buffer_empty,mm2s_buffer_almost_empty,mm2s_fsync_out,mm2s_prmtr_update,m_axi_mm2s_araddr[31:0],m_axi_mm2s_arlen[7:0],m_axi_mm2s_arsize[2:0],m_axi_mm2s_arburst[1:0],m_axi_mm2s_arprot[2:0],m_axi_mm2s_arcache[3:0],m_axi_mm2s_arvalid,m_axi_mm2s_arready,m_axi_mm2s_rdata[63:0],m_axi_mm2s_rresp[1:0],m_axi_mm2s_rlast,m_axi_mm2s_rvalid,m_axi_mm2s_rready,mm2s_prmry_reset_out_n,m_axis_mm2s_tdata[31:0],m_axis_mm2s_tkeep[3:0],m_axis_mm2s_tuser[0:0],m_axis_mm2s_tvalid,m_axis_mm2s_tready,m_axis_mm2s_tlast,mm2s_introut,axi_vdma_tstvec[63:0]" */;
  input s_axi_lite_aclk;
  input m_axi_mm2s_aclk;
  input m_axis_mm2s_aclk;
  input axi_resetn;
  input s_axi_lite_awvalid;
  output s_axi_lite_awready;
  input [8:0]s_axi_lite_awaddr;
  input s_axi_lite_wvalid;
  output s_axi_lite_wready;
  input [31:0]s_axi_lite_wdata;
  output [1:0]s_axi_lite_bresp;
  output s_axi_lite_bvalid;
  input s_axi_lite_bready;
  input s_axi_lite_arvalid;
  output s_axi_lite_arready;
  input [8:0]s_axi_lite_araddr;
  output s_axi_lite_rvalid;
  input s_axi_lite_rready;
  output [31:0]s_axi_lite_rdata;
  output [1:0]s_axi_lite_rresp;
  input mm2s_fsync;
  input [5:0]mm2s_frame_ptr_in;
  output [5:0]mm2s_frame_ptr_out;
  output mm2s_buffer_empty;
  output mm2s_buffer_almost_empty;
  output mm2s_fsync_out;
  output mm2s_prmtr_update;
  output [31:0]m_axi_mm2s_araddr;
  output [7:0]m_axi_mm2s_arlen;
  output [2:0]m_axi_mm2s_arsize;
  output [1:0]m_axi_mm2s_arburst;
  output [2:0]m_axi_mm2s_arprot;
  output [3:0]m_axi_mm2s_arcache;
  output m_axi_mm2s_arvalid;
  input m_axi_mm2s_arready;
  input [63:0]m_axi_mm2s_rdata;
  input [1:0]m_axi_mm2s_rresp;
  input m_axi_mm2s_rlast;
  input m_axi_mm2s_rvalid;
  output m_axi_mm2s_rready;
  output mm2s_prmry_reset_out_n;
  output [31:0]m_axis_mm2s_tdata;
  output [3:0]m_axis_mm2s_tkeep;
  output [0:0]m_axis_mm2s_tuser;
  output m_axis_mm2s_tvalid;
  input m_axis_mm2s_tready;
  output m_axis_mm2s_tlast;
  output mm2s_introut;
  output [63:0]axi_vdma_tstvec;
endmodule

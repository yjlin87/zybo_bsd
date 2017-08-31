proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000

start_step init_design
set ACTIVE_STEP init_design
set rc [catch {
  create_msg_db init_design.pb
  create_project -in_memory -part xc7z010clg400-1
  set_property board_part digilentinc.com:zybo:part0:1.0 [current_project]
  set_property design_mode GateLvl [current_fileset]
  set_param project.singleFileAddWarning.threshold 0
  set_property webtalk.parent_dir /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/proj/zybo_bsd.cache/wt [current_project]
  set_property parent.project_path /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/proj/zybo_bsd.xpr [current_project]
  set_property ip_repo_paths /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/repo [current_project]
  set_property ip_output_repo /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/repo/cache [current_project]
  set_property ip_cache_permissions {read write} [current_project]
  set_property XPM_LIBRARIES {XPM_CDC XPM_MEMORY} [current_project]
  add_files -quiet /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/proj/zybo_bsd.runs/synth_1/system_wrapper.dcp
  add_files -quiet /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_BTNs_4Bits_0/system_BTNs_4Bits_0.dcp
  set_property netlist_only true [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_BTNs_4Bits_0/system_BTNs_4Bits_0.dcp]
  add_files -quiet /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_LEDs_4Bits_1/system_LEDs_4Bits_1.dcp
  set_property netlist_only true [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_LEDs_4Bits_1/system_LEDs_4Bits_1.dcp]
  add_files -quiet /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_SWs_4Bits_2/system_SWs_4Bits_2.dcp
  set_property netlist_only true [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_SWs_4Bits_2/system_SWs_4Bits_2.dcp]
  add_files -quiet /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_axi_dispctrl_0_0/system_axi_dispctrl_0_0.dcp
  set_property netlist_only true [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_axi_dispctrl_0_0/system_axi_dispctrl_0_0.dcp]
  add_files -quiet /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_axi_dispctrl_1_1/system_axi_dispctrl_1_1.dcp
  set_property netlist_only true [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_axi_dispctrl_1_1/system_axi_dispctrl_1_1.dcp]
  add_files -quiet /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_axi_i2s_adi_1_0/system_axi_i2s_adi_1_0.dcp
  set_property netlist_only true [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_axi_i2s_adi_1_0/system_axi_i2s_adi_1_0.dcp]
  add_files -quiet /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_axi_vdma_0_0/system_axi_vdma_0_0.dcp
  set_property netlist_only true [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_axi_vdma_0_0/system_axi_vdma_0_0.dcp]
  add_files -quiet /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_axi_vdma_1_1/system_axi_vdma_1_1.dcp
  set_property netlist_only true [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_axi_vdma_1_1/system_axi_vdma_1_1.dcp]
  add_files -quiet /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_ground_0/system_ground_0.dcp
  set_property netlist_only true [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_ground_0/system_ground_0.dcp]
  add_files -quiet /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_hdmi_tx_0_0/system_hdmi_tx_0_0.dcp
  set_property netlist_only true [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_hdmi_tx_0_0/system_hdmi_tx_0_0.dcp]
  add_files -quiet /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_processing_system7_0_0/system_processing_system7_0_0.dcp
  set_property netlist_only true [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_processing_system7_0_0/system_processing_system7_0_0.dcp]
  add_files -quiet /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_vdd_1/system_vdd_1.dcp
  set_property netlist_only true [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_vdd_1/system_vdd_1.dcp]
  add_files -quiet /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_xlconstant_0_2/system_xlconstant_0_2.dcp
  set_property netlist_only true [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_xlconstant_0_2/system_xlconstant_0_2.dcp]
  add_files -quiet /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_rst_ps7_0_100M_3/system_rst_ps7_0_100M_3.dcp
  set_property netlist_only true [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_rst_ps7_0_100M_3/system_rst_ps7_0_100M_3.dcp]
  add_files -quiet /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_xbar_2/system_xbar_2.dcp
  set_property netlist_only true [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_xbar_2/system_xbar_2.dcp]
  add_files -quiet /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_rst_ps7_0_150M_3/system_rst_ps7_0_150M_3.dcp
  set_property netlist_only true [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_rst_ps7_0_150M_3/system_rst_ps7_0_150M_3.dcp]
  add_files -quiet /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_xbar_3/system_xbar_3.dcp
  set_property netlist_only true [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_xbar_3/system_xbar_3.dcp]
  add_files -quiet /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_auto_pc_1/system_auto_pc_1.dcp
  set_property netlist_only true [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_auto_pc_1/system_auto_pc_1.dcp]
  add_files -quiet /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_auto_pc_2/system_auto_pc_2.dcp
  set_property netlist_only true [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_auto_pc_2/system_auto_pc_2.dcp]
  read_xdc -prop_thru_buffers -ref system_BTNs_4Bits_0 -cells U0 /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_BTNs_4Bits_0/system_BTNs_4Bits_0_board.xdc
  set_property processing_order EARLY [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_BTNs_4Bits_0/system_BTNs_4Bits_0_board.xdc]
  read_xdc -ref system_BTNs_4Bits_0 -cells U0 /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_BTNs_4Bits_0/system_BTNs_4Bits_0.xdc
  set_property processing_order EARLY [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_BTNs_4Bits_0/system_BTNs_4Bits_0.xdc]
  read_xdc -prop_thru_buffers -ref system_LEDs_4Bits_1 -cells U0 /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_LEDs_4Bits_1/system_LEDs_4Bits_1_board.xdc
  set_property processing_order EARLY [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_LEDs_4Bits_1/system_LEDs_4Bits_1_board.xdc]
  read_xdc -ref system_LEDs_4Bits_1 -cells U0 /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_LEDs_4Bits_1/system_LEDs_4Bits_1.xdc
  set_property processing_order EARLY [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_LEDs_4Bits_1/system_LEDs_4Bits_1.xdc]
  read_xdc -prop_thru_buffers -ref system_SWs_4Bits_2 -cells U0 /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_SWs_4Bits_2/system_SWs_4Bits_2_board.xdc
  set_property processing_order EARLY [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_SWs_4Bits_2/system_SWs_4Bits_2_board.xdc]
  read_xdc -ref system_SWs_4Bits_2 -cells U0 /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_SWs_4Bits_2/system_SWs_4Bits_2.xdc
  set_property processing_order EARLY [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_SWs_4Bits_2/system_SWs_4Bits_2.xdc]
  read_xdc -ref system_axi_vdma_0_0 -cells U0 /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_axi_vdma_0_0/system_axi_vdma_0_0.xdc
  set_property processing_order EARLY [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_axi_vdma_0_0/system_axi_vdma_0_0.xdc]
  read_xdc -ref system_axi_vdma_1_1 -cells U0 /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_axi_vdma_1_1/system_axi_vdma_1_1.xdc
  set_property processing_order EARLY [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_axi_vdma_1_1/system_axi_vdma_1_1.xdc]
  read_xdc -ref system_processing_system7_0_0 -cells inst /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_processing_system7_0_0/system_processing_system7_0_0.xdc
  set_property processing_order EARLY [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_processing_system7_0_0/system_processing_system7_0_0.xdc]
  read_xdc -prop_thru_buffers -ref system_rst_ps7_0_100M_3 -cells U0 /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_rst_ps7_0_100M_3/system_rst_ps7_0_100M_3_board.xdc
  set_property processing_order EARLY [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_rst_ps7_0_100M_3/system_rst_ps7_0_100M_3_board.xdc]
  read_xdc -ref system_rst_ps7_0_100M_3 -cells U0 /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_rst_ps7_0_100M_3/system_rst_ps7_0_100M_3.xdc
  set_property processing_order EARLY [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_rst_ps7_0_100M_3/system_rst_ps7_0_100M_3.xdc]
  read_xdc -prop_thru_buffers -ref system_rst_ps7_0_150M_3 -cells U0 /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_rst_ps7_0_150M_3/system_rst_ps7_0_150M_3_board.xdc
  set_property processing_order EARLY [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_rst_ps7_0_150M_3/system_rst_ps7_0_150M_3_board.xdc]
  read_xdc -ref system_rst_ps7_0_150M_3 -cells U0 /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_rst_ps7_0_150M_3/system_rst_ps7_0_150M_3.xdc
  set_property processing_order EARLY [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_rst_ps7_0_150M_3/system_rst_ps7_0_150M_3.xdc]
  read_xdc /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/constraints/base.xdc
  read_xdc -ref system_axi_vdma_0_0 -cells U0 /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_axi_vdma_0_0/system_axi_vdma_0_0_clocks.xdc
  set_property processing_order LATE [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_axi_vdma_0_0/system_axi_vdma_0_0_clocks.xdc]
  read_xdc -ref system_axi_vdma_1_1 -cells U0 /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_axi_vdma_1_1/system_axi_vdma_1_1_clocks.xdc
  set_property processing_order LATE [get_files /mnt/workspace/znsoc/Projects/zybo_bsd/sources/hardware/src/bd/system/ip/system_axi_vdma_1_1/system_axi_vdma_1_1_clocks.xdc]
  link_design -top system_wrapper -part xc7z010clg400-1
  write_hwdef -file system_wrapper.hwdef
  close_msg_db -file init_design.pb
} RESULT]
if {$rc} {
  step_failed init_design
  return -code error $RESULT
} else {
  end_step init_design
  unset ACTIVE_STEP 
}

start_step opt_design
set ACTIVE_STEP opt_design
set rc [catch {
  create_msg_db opt_design.pb
  opt_design -directive RuntimeOptimized
  write_checkpoint -force system_wrapper_opt.dcp
  catch { report_drc -file system_wrapper_drc_opted.rpt }
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
  unset ACTIVE_STEP 
}

start_step place_design
set ACTIVE_STEP place_design
set rc [catch {
  create_msg_db place_design.pb
  implement_debug_core 
  place_design -directive RuntimeOptimized
  write_checkpoint -force system_wrapper_placed.dcp
  catch { report_io -file system_wrapper_io_placed.rpt }
  catch { report_utilization -file system_wrapper_utilization_placed.rpt -pb system_wrapper_utilization_placed.pb }
  catch { report_control_sets -verbose -file system_wrapper_control_sets_placed.rpt }
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
  unset ACTIVE_STEP 
}

start_step route_design
set ACTIVE_STEP route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design -directive RuntimeOptimized
  write_checkpoint -force system_wrapper_routed.dcp
  catch { report_drc -file system_wrapper_drc_routed.rpt -pb system_wrapper_drc_routed.pb -rpx system_wrapper_drc_routed.rpx }
  catch { report_methodology -file system_wrapper_methodology_drc_routed.rpt -rpx system_wrapper_methodology_drc_routed.rpx }
  catch { report_timing_summary -warn_on_violation -max_paths 10 -file system_wrapper_timing_summary_routed.rpt -rpx system_wrapper_timing_summary_routed.rpx }
  catch { report_power -file system_wrapper_power_routed.rpt -pb system_wrapper_power_summary_routed.pb -rpx system_wrapper_power_routed.rpx }
  catch { report_route_status -file system_wrapper_route_status.rpt -pb system_wrapper_route_status.pb }
  catch { report_clock_utilization -file system_wrapper_clock_utilization_routed.rpt }
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  write_checkpoint -force system_wrapper_routed_error.dcp
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
  unset ACTIVE_STEP 
}

start_step write_bitstream
set ACTIVE_STEP write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
  set_property XPM_LIBRARIES {XPM_CDC XPM_MEMORY} [current_project]
  catch { write_mem_info -force system_wrapper.mmi }
  write_bitstream -force -no_partial_bitfile system_wrapper.bit 
  catch { write_sysdef -hwdef system_wrapper.hwdef -bitfile system_wrapper.bit -meminfo system_wrapper.mmi -file system_wrapper.sysdef }
  catch {write_debug_probes -quiet -force debug_nets}
  close_msg_db -file write_bitstream.pb
} RESULT]
if {$rc} {
  step_failed write_bitstream
  return -code error $RESULT
} else {
  end_step write_bitstream
  unset ACTIVE_STEP 
}


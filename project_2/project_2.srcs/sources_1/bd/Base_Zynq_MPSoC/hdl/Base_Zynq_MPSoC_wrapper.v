//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.1 (lin64) Build 2552052 Fri May 24 14:47:09 MDT 2019
//Date        : Mon Jun  5 12:04:20 2023
//Host        : i80r7node2 running 64-bit CentOS Linux release 7.9.2009 (Core)
//Command     : generate_target Base_Zynq_MPSoC_wrapper.bd
//Design      : Base_Zynq_MPSoC_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module Base_Zynq_MPSoC_wrapper
   (Vp_Vn_0_v_n,
    Vp_Vn_0_v_p,
    dip_switch_4bits_tri_i,
    led_4bits_tri_o,
    push_button_4bits_tri_i,
    pwm_out_0);
  input Vp_Vn_0_v_n;
  input Vp_Vn_0_v_p;
  input [3:0]dip_switch_4bits_tri_i;
  output [3:0]led_4bits_tri_o;
  input [3:0]push_button_4bits_tri_i;
  output [0:0]pwm_out_0;

  wire Vp_Vn_0_v_n;
  wire Vp_Vn_0_v_p;
  wire [3:0]dip_switch_4bits_tri_i;
  wire [3:0]led_4bits_tri_o;
  wire [3:0]push_button_4bits_tri_i;
  wire [0:0]pwm_out_0;

  Base_Zynq_MPSoC Base_Zynq_MPSoC_i
       (.Vp_Vn_0_v_n(Vp_Vn_0_v_n),
        .Vp_Vn_0_v_p(Vp_Vn_0_v_p),
        .dip_switch_4bits_tri_i(dip_switch_4bits_tri_i),
        .led_4bits_tri_o(led_4bits_tri_o),
        .push_button_4bits_tri_i(push_button_4bits_tri_i),
        .pwm_out_0(pwm_out_0));
endmodule

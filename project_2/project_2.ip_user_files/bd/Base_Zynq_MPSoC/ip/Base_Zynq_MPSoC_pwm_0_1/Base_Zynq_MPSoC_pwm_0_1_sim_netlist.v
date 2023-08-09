// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Tue Apr 28 17:07:14 2020
// Host        : DESKTOP-G3QMJB5 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               C:/Users/Carina/KIT/ma_ck/zcu104_src_fixed/project_2/project_2.srcs/sources_1/bd/Base_Zynq_MPSoC/ip/Base_Zynq_MPSoC_pwm_0_1/Base_Zynq_MPSoC_pwm_0_1_sim_netlist.v
// Design      : Base_Zynq_MPSoC_pwm_0_1
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu7ev-ffvc1156-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "Base_Zynq_MPSoC_pwm_0_1,pwm,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* IP_DEFINITION_SOURCE = "module_ref" *) 
(* X_CORE_INFO = "pwm,Vivado 2019.1" *) 
(* NotValidForBitStream *)
module Base_Zynq_MPSoC_pwm_0_1
   (clk,
    reset_n,
    duty_ena,
    pwm_out,
    pwm_n_out);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clk, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN Base_Zynq_MPSoC_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0" *) input clk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 reset_n RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME reset_n, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input reset_n;
  input [8:0]duty_ena;
  output [0:0]pwm_out;
  output [0:0]pwm_n_out;

  wire clk;
  wire [8:0]duty_ena;
  wire [0:0]pwm_n_out;
  wire [0:0]pwm_out;
  wire reset_n;

  Base_Zynq_MPSoC_pwm_0_1_pwm inst
       (.clk(clk),
        .duty_ena(duty_ena),
        .pwm_n_out(pwm_n_out),
        .pwm_out(pwm_out),
        .reset_n(reset_n));
endmodule

(* ORIG_REF_NAME = "pwm" *) 
module Base_Zynq_MPSoC_pwm_0_1_pwm
   (pwm_out,
    pwm_n_out,
    clk,
    duty_ena,
    reset_n);
  output [0:0]pwm_out;
  output [0:0]pwm_n_out;
  input clk;
  input [8:0]duty_ena;
  input reset_n;

  wire clk;
  wire \count[0]0_carry__0_n_0 ;
  wire \count[0]0_carry__0_n_1 ;
  wire \count[0]0_carry__0_n_2 ;
  wire \count[0]0_carry__0_n_3 ;
  wire \count[0]0_carry__0_n_4 ;
  wire \count[0]0_carry__0_n_5 ;
  wire \count[0]0_carry__0_n_6 ;
  wire \count[0]0_carry__0_n_7 ;
  wire \count[0]0_carry__1_n_4 ;
  wire \count[0]0_carry__1_n_5 ;
  wire \count[0]0_carry__1_n_6 ;
  wire \count[0]0_carry__1_n_7 ;
  wire \count[0]0_carry_n_0 ;
  wire \count[0]0_carry_n_1 ;
  wire \count[0]0_carry_n_2 ;
  wire \count[0]0_carry_n_3 ;
  wire \count[0]0_carry_n_4 ;
  wire \count[0]0_carry_n_5 ;
  wire \count[0]0_carry_n_6 ;
  wire \count[0]0_carry_n_7 ;
  wire \count[0][21]_i_2_n_0 ;
  wire \count[0][21]_i_3_n_0 ;
  wire \count[0][21]_i_4_n_0 ;
  wire \count[0][21]_i_5_n_0 ;
  wire \count[0][21]_i_6_n_0 ;
  wire \count[0][21]_i_7_n_0 ;
  wire \count[0][21]_i_8_n_0 ;
  wire [21:0]\count[0]_0 ;
  wire [21:0]\count_reg[0] ;
  wire [21:1]data0;
  wire [8:0]duty_ena;
  wire half_duty_new0;
  wire half_duty_new2_n_100;
  wire half_duty_new2_n_101;
  wire half_duty_new2_n_102;
  wire half_duty_new2_n_103;
  wire half_duty_new2_n_104;
  wire half_duty_new2_n_105;
  wire half_duty_new2_n_58;
  wire half_duty_new2_n_59;
  wire half_duty_new2_n_60;
  wire half_duty_new2_n_61;
  wire half_duty_new2_n_62;
  wire half_duty_new2_n_63;
  wire half_duty_new2_n_64;
  wire half_duty_new2_n_65;
  wire half_duty_new2_n_66;
  wire half_duty_new2_n_67;
  wire half_duty_new2_n_68;
  wire half_duty_new2_n_69;
  wire half_duty_new2_n_70;
  wire half_duty_new2_n_71;
  wire half_duty_new2_n_72;
  wire half_duty_new2_n_73;
  wire half_duty_new2_n_74;
  wire half_duty_new2_n_75;
  wire half_duty_new2_n_97;
  wire half_duty_new2_n_98;
  wire half_duty_new2_n_99;
  wire [20:0]half_duty_new_reg;
  wire \half_duty_reg[0]0 ;
  wire \half_duty_reg_n_0_[0][0] ;
  wire \half_duty_reg_n_0_[0][10] ;
  wire \half_duty_reg_n_0_[0][11] ;
  wire \half_duty_reg_n_0_[0][12] ;
  wire \half_duty_reg_n_0_[0][13] ;
  wire \half_duty_reg_n_0_[0][14] ;
  wire \half_duty_reg_n_0_[0][15] ;
  wire \half_duty_reg_n_0_[0][16] ;
  wire \half_duty_reg_n_0_[0][17] ;
  wire \half_duty_reg_n_0_[0][18] ;
  wire \half_duty_reg_n_0_[0][19] ;
  wire \half_duty_reg_n_0_[0][1] ;
  wire \half_duty_reg_n_0_[0][20] ;
  wire \half_duty_reg_n_0_[0][2] ;
  wire \half_duty_reg_n_0_[0][3] ;
  wire \half_duty_reg_n_0_[0][4] ;
  wire \half_duty_reg_n_0_[0][5] ;
  wire \half_duty_reg_n_0_[0][6] ;
  wire \half_duty_reg_n_0_[0][7] ;
  wire \half_duty_reg_n_0_[0][8] ;
  wire \half_duty_reg_n_0_[0][9] ;
  wire p_0_in;
  wire [0:0]pwm_n_out;
  wire [0:0]pwm_out;
  wire pwm_out0;
  wire pwm_out0_carry_i_10_n_0;
  wire pwm_out0_carry_i_10_n_1;
  wire pwm_out0_carry_i_10_n_2;
  wire pwm_out0_carry_i_10_n_3;
  wire pwm_out0_carry_i_10_n_4;
  wire pwm_out0_carry_i_10_n_5;
  wire pwm_out0_carry_i_10_n_6;
  wire pwm_out0_carry_i_10_n_7;
  wire pwm_out0_carry_i_11_n_0;
  wire pwm_out0_carry_i_11_n_1;
  wire pwm_out0_carry_i_11_n_2;
  wire pwm_out0_carry_i_11_n_3;
  wire pwm_out0_carry_i_11_n_4;
  wire pwm_out0_carry_i_11_n_5;
  wire pwm_out0_carry_i_11_n_6;
  wire pwm_out0_carry_i_11_n_7;
  wire pwm_out0_carry_i_12_n_0;
  wire pwm_out0_carry_i_13_n_0;
  wire pwm_out0_carry_i_14_n_0;
  wire pwm_out0_carry_i_15_n_0;
  wire pwm_out0_carry_i_16_n_0;
  wire pwm_out0_carry_i_17_n_0;
  wire pwm_out0_carry_i_18_n_0;
  wire pwm_out0_carry_i_19_n_0;
  wire pwm_out0_carry_i_1_n_0;
  wire pwm_out0_carry_i_20_n_0;
  wire pwm_out0_carry_i_21_n_0;
  wire pwm_out0_carry_i_22_n_0;
  wire pwm_out0_carry_i_23_n_0;
  wire pwm_out0_carry_i_24_n_0;
  wire pwm_out0_carry_i_25_n_0;
  wire pwm_out0_carry_i_26_n_0;
  wire pwm_out0_carry_i_27_n_0;
  wire pwm_out0_carry_i_28_n_0;
  wire pwm_out0_carry_i_29_n_0;
  wire pwm_out0_carry_i_2_n_0;
  wire pwm_out0_carry_i_30_n_0;
  wire pwm_out0_carry_i_31_n_0;
  wire pwm_out0_carry_i_32_n_0;
  wire pwm_out0_carry_i_3_n_0;
  wire pwm_out0_carry_i_4_n_0;
  wire pwm_out0_carry_i_5_n_0;
  wire pwm_out0_carry_i_6_n_0;
  wire pwm_out0_carry_i_7_n_0;
  wire pwm_out0_carry_i_8_n_0;
  wire pwm_out0_carry_i_9_n_5;
  wire pwm_out0_carry_i_9_n_6;
  wire pwm_out0_carry_i_9_n_7;
  wire pwm_out0_carry_n_1;
  wire pwm_out0_carry_n_2;
  wire pwm_out0_carry_n_3;
  wire pwm_out0_carry_n_4;
  wire pwm_out0_carry_n_5;
  wire pwm_out0_carry_n_6;
  wire pwm_out0_carry_n_7;
  wire [21:1]pwm_out1;
  wire pwm_out10_out;
  wire pwm_out1_carry_i_1_n_0;
  wire pwm_out1_carry_i_2_n_0;
  wire pwm_out1_carry_i_3_n_0;
  wire pwm_out1_carry_i_4_n_0;
  wire pwm_out1_carry_i_5_n_0;
  wire pwm_out1_carry_i_6_n_0;
  wire pwm_out1_carry_i_7_n_0;
  wire pwm_out1_carry_i_8_n_0;
  wire pwm_out1_carry_n_1;
  wire pwm_out1_carry_n_2;
  wire pwm_out1_carry_n_3;
  wire pwm_out1_carry_n_4;
  wire pwm_out1_carry_n_5;
  wire pwm_out1_carry_n_6;
  wire pwm_out1_carry_n_7;
  wire \pwm_out[0]_i_1_n_0 ;
  wire \pwm_out[0]_i_2_n_0 ;
  wire reset_n;
  wire [7:4]\NLW_count[0]0_carry__1_CO_UNCONNECTED ;
  wire [7:5]\NLW_count[0]0_carry__1_O_UNCONNECTED ;
  wire NLW_half_duty_new2_CARRYCASCOUT_UNCONNECTED;
  wire NLW_half_duty_new2_MULTSIGNOUT_UNCONNECTED;
  wire NLW_half_duty_new2_OVERFLOW_UNCONNECTED;
  wire NLW_half_duty_new2_PATTERNBDETECT_UNCONNECTED;
  wire NLW_half_duty_new2_PATTERNDETECT_UNCONNECTED;
  wire NLW_half_duty_new2_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_half_duty_new2_ACOUT_UNCONNECTED;
  wire [17:0]NLW_half_duty_new2_BCOUT_UNCONNECTED;
  wire [3:0]NLW_half_duty_new2_CARRYOUT_UNCONNECTED;
  wire [47:0]NLW_half_duty_new2_PCOUT_UNCONNECTED;
  wire [7:0]NLW_half_duty_new2_XOROUT_UNCONNECTED;
  wire [7:0]NLW_pwm_out0_carry_O_UNCONNECTED;
  wire [7:3]NLW_pwm_out0_carry_i_9_CO_UNCONNECTED;
  wire [7:4]NLW_pwm_out0_carry_i_9_O_UNCONNECTED;
  wire [7:0]NLW_pwm_out1_carry_O_UNCONNECTED;

  CARRY8 \count[0]0_carry 
       (.CI(\count_reg[0] [0]),
        .CI_TOP(1'b0),
        .CO({\count[0]0_carry_n_0 ,\count[0]0_carry_n_1 ,\count[0]0_carry_n_2 ,\count[0]0_carry_n_3 ,\count[0]0_carry_n_4 ,\count[0]0_carry_n_5 ,\count[0]0_carry_n_6 ,\count[0]0_carry_n_7 }),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .O(data0[8:1]),
        .S(\count_reg[0] [8:1]));
  CARRY8 \count[0]0_carry__0 
       (.CI(\count[0]0_carry_n_0 ),
        .CI_TOP(1'b0),
        .CO({\count[0]0_carry__0_n_0 ,\count[0]0_carry__0_n_1 ,\count[0]0_carry__0_n_2 ,\count[0]0_carry__0_n_3 ,\count[0]0_carry__0_n_4 ,\count[0]0_carry__0_n_5 ,\count[0]0_carry__0_n_6 ,\count[0]0_carry__0_n_7 }),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .O(data0[16:9]),
        .S(\count_reg[0] [16:9]));
  CARRY8 \count[0]0_carry__1 
       (.CI(\count[0]0_carry__0_n_0 ),
        .CI_TOP(1'b0),
        .CO({\NLW_count[0]0_carry__1_CO_UNCONNECTED [7:4],\count[0]0_carry__1_n_4 ,\count[0]0_carry__1_n_5 ,\count[0]0_carry__1_n_6 ,\count[0]0_carry__1_n_7 }),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .O({\NLW_count[0]0_carry__1_O_UNCONNECTED [7:5],data0[21:17]}),
        .S({1'b0,1'b0,1'b0,\count_reg[0] [21:17]}));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT1 #(
    .INIT(2'h1)) 
    \count[0][0]_i_1 
       (.I0(\count_reg[0] [0]),
        .O(\count[0]_0 [0]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \count[0][10]_i_1 
       (.I0(\count[0][21]_i_2_n_0 ),
        .I1(data0[10]),
        .O(\count[0]_0 [10]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \count[0][11]_i_1 
       (.I0(\count[0][21]_i_2_n_0 ),
        .I1(data0[11]),
        .O(\count[0]_0 [11]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \count[0][12]_i_1 
       (.I0(\count[0][21]_i_2_n_0 ),
        .I1(data0[12]),
        .O(\count[0]_0 [12]));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \count[0][13]_i_1 
       (.I0(\count[0][21]_i_2_n_0 ),
        .I1(data0[13]),
        .O(\count[0]_0 [13]));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \count[0][14]_i_1 
       (.I0(\count[0][21]_i_2_n_0 ),
        .I1(data0[14]),
        .O(\count[0]_0 [14]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \count[0][15]_i_1 
       (.I0(\count[0][21]_i_2_n_0 ),
        .I1(data0[15]),
        .O(\count[0]_0 [15]));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \count[0][16]_i_1 
       (.I0(\count[0][21]_i_2_n_0 ),
        .I1(data0[16]),
        .O(\count[0]_0 [16]));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \count[0][17]_i_1 
       (.I0(\count[0][21]_i_2_n_0 ),
        .I1(data0[17]),
        .O(\count[0]_0 [17]));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \count[0][18]_i_1 
       (.I0(\count[0][21]_i_2_n_0 ),
        .I1(data0[18]),
        .O(\count[0]_0 [18]));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \count[0][19]_i_1 
       (.I0(\count[0][21]_i_2_n_0 ),
        .I1(data0[19]),
        .O(\count[0]_0 [19]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \count[0][1]_i_1 
       (.I0(\count[0][21]_i_2_n_0 ),
        .I1(data0[1]),
        .O(\count[0]_0 [1]));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \count[0][20]_i_1 
       (.I0(\count[0][21]_i_2_n_0 ),
        .I1(data0[20]),
        .O(\count[0]_0 [20]));
  LUT2 #(
    .INIT(4'h8)) 
    \count[0][21]_i_1 
       (.I0(\count[0][21]_i_2_n_0 ),
        .I1(data0[21]),
        .O(\count[0]_0 [21]));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFFFFFE)) 
    \count[0][21]_i_2 
       (.I0(\count[0][21]_i_3_n_0 ),
        .I1(\count[0][21]_i_4_n_0 ),
        .I2(\count[0][21]_i_5_n_0 ),
        .I3(\count[0][21]_i_6_n_0 ),
        .I4(\count[0][21]_i_7_n_0 ),
        .I5(\count[0][21]_i_8_n_0 ),
        .O(\count[0][21]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h7F)) 
    \count[0][21]_i_3 
       (.I0(\count_reg[0] [11]),
        .I1(\count_reg[0] [10]),
        .I2(\count_reg[0] [9]),
        .O(\count[0][21]_i_3_n_0 ));
  LUT3 #(
    .INIT(8'hFD)) 
    \count[0][21]_i_4 
       (.I0(\count_reg[0] [13]),
        .I1(\count_reg[0] [14]),
        .I2(\count_reg[0] [12]),
        .O(\count[0][21]_i_4_n_0 ));
  LUT3 #(
    .INIT(8'hFE)) 
    \count[0][21]_i_5 
       (.I0(\count_reg[0] [5]),
        .I1(\count_reg[0] [4]),
        .I2(\count_reg[0] [3]),
        .O(\count[0][21]_i_5_n_0 ));
  LUT3 #(
    .INIT(8'hFD)) 
    \count[0][21]_i_6 
       (.I0(\count_reg[0] [8]),
        .I1(\count_reg[0] [7]),
        .I2(\count_reg[0] [6]),
        .O(\count[0][21]_i_6_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT4 #(
    .INIT(16'h7FFF)) 
    \count[0][21]_i_7 
       (.I0(\count_reg[0] [21]),
        .I1(\count_reg[0] [0]),
        .I2(\count_reg[0] [2]),
        .I3(\count_reg[0] [1]),
        .O(\count[0][21]_i_7_n_0 ));
  LUT6 #(
    .INIT(64'hFFFF7FFFFFFFFFFF)) 
    \count[0][21]_i_8 
       (.I0(\count_reg[0] [15]),
        .I1(\count_reg[0] [16]),
        .I2(\count_reg[0] [17]),
        .I3(\count_reg[0] [18]),
        .I4(\count_reg[0] [20]),
        .I5(\count_reg[0] [19]),
        .O(\count[0][21]_i_8_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \count[0][2]_i_1 
       (.I0(\count[0][21]_i_2_n_0 ),
        .I1(data0[2]),
        .O(\count[0]_0 [2]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \count[0][3]_i_1 
       (.I0(\count[0][21]_i_2_n_0 ),
        .I1(data0[3]),
        .O(\count[0]_0 [3]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \count[0][4]_i_1 
       (.I0(\count[0][21]_i_2_n_0 ),
        .I1(data0[4]),
        .O(\count[0]_0 [4]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \count[0][5]_i_1 
       (.I0(\count[0][21]_i_2_n_0 ),
        .I1(data0[5]),
        .O(\count[0]_0 [5]));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \count[0][6]_i_1 
       (.I0(\count[0][21]_i_2_n_0 ),
        .I1(data0[6]),
        .O(\count[0]_0 [6]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \count[0][7]_i_1 
       (.I0(\count[0][21]_i_2_n_0 ),
        .I1(data0[7]),
        .O(\count[0]_0 [7]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \count[0][8]_i_1 
       (.I0(\count[0][21]_i_2_n_0 ),
        .I1(data0[8]),
        .O(\count[0]_0 [8]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \count[0][9]_i_1 
       (.I0(\count[0][21]_i_2_n_0 ),
        .I1(data0[9]),
        .O(\count[0]_0 [9]));
  FDCE #(
    .INIT(1'b0)) 
    \count_reg[0][0] 
       (.C(clk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(\count[0]_0 [0]),
        .Q(\count_reg[0] [0]));
  FDCE #(
    .INIT(1'b0)) 
    \count_reg[0][10] 
       (.C(clk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(\count[0]_0 [10]),
        .Q(\count_reg[0] [10]));
  FDCE #(
    .INIT(1'b0)) 
    \count_reg[0][11] 
       (.C(clk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(\count[0]_0 [11]),
        .Q(\count_reg[0] [11]));
  FDCE #(
    .INIT(1'b0)) 
    \count_reg[0][12] 
       (.C(clk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(\count[0]_0 [12]),
        .Q(\count_reg[0] [12]));
  FDCE #(
    .INIT(1'b0)) 
    \count_reg[0][13] 
       (.C(clk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(\count[0]_0 [13]),
        .Q(\count_reg[0] [13]));
  FDCE #(
    .INIT(1'b0)) 
    \count_reg[0][14] 
       (.C(clk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(\count[0]_0 [14]),
        .Q(\count_reg[0] [14]));
  FDCE #(
    .INIT(1'b0)) 
    \count_reg[0][15] 
       (.C(clk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(\count[0]_0 [15]),
        .Q(\count_reg[0] [15]));
  FDCE #(
    .INIT(1'b0)) 
    \count_reg[0][16] 
       (.C(clk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(\count[0]_0 [16]),
        .Q(\count_reg[0] [16]));
  FDCE #(
    .INIT(1'b0)) 
    \count_reg[0][17] 
       (.C(clk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(\count[0]_0 [17]),
        .Q(\count_reg[0] [17]));
  FDCE #(
    .INIT(1'b0)) 
    \count_reg[0][18] 
       (.C(clk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(\count[0]_0 [18]),
        .Q(\count_reg[0] [18]));
  FDCE #(
    .INIT(1'b0)) 
    \count_reg[0][19] 
       (.C(clk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(\count[0]_0 [19]),
        .Q(\count_reg[0] [19]));
  FDCE #(
    .INIT(1'b0)) 
    \count_reg[0][1] 
       (.C(clk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(\count[0]_0 [1]),
        .Q(\count_reg[0] [1]));
  FDCE #(
    .INIT(1'b0)) 
    \count_reg[0][20] 
       (.C(clk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(\count[0]_0 [20]),
        .Q(\count_reg[0] [20]));
  FDCE #(
    .INIT(1'b0)) 
    \count_reg[0][21] 
       (.C(clk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(\count[0]_0 [21]),
        .Q(\count_reg[0] [21]));
  FDCE #(
    .INIT(1'b0)) 
    \count_reg[0][2] 
       (.C(clk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(\count[0]_0 [2]),
        .Q(\count_reg[0] [2]));
  FDCE #(
    .INIT(1'b0)) 
    \count_reg[0][3] 
       (.C(clk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(\count[0]_0 [3]),
        .Q(\count_reg[0] [3]));
  FDCE #(
    .INIT(1'b0)) 
    \count_reg[0][4] 
       (.C(clk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(\count[0]_0 [4]),
        .Q(\count_reg[0] [4]));
  FDCE #(
    .INIT(1'b0)) 
    \count_reg[0][5] 
       (.C(clk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(\count[0]_0 [5]),
        .Q(\count_reg[0] [5]));
  FDCE #(
    .INIT(1'b0)) 
    \count_reg[0][6] 
       (.C(clk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(\count[0]_0 [6]),
        .Q(\count_reg[0] [6]));
  FDCE #(
    .INIT(1'b0)) 
    \count_reg[0][7] 
       (.C(clk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(\count[0]_0 [7]),
        .Q(\count_reg[0] [7]));
  FDCE #(
    .INIT(1'b0)) 
    \count_reg[0][8] 
       (.C(clk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(\count[0]_0 [8]),
        .Q(\count_reg[0] [8]));
  FDCE #(
    .INIT(1'b0)) 
    \count_reg[0][9] 
       (.C(clk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(\count[0]_0 [9]),
        .Q(\count_reg[0] [9]));
  LUT2 #(
    .INIT(4'h2)) 
    \half_duty[0][20]_i_1 
       (.I0(reset_n),
        .I1(\count[0][21]_i_2_n_0 ),
        .O(\half_duty_reg[0]0 ));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-12 {cell *THIS*}}" *) 
  DSP48E2 #(
    .ACASCREG(0),
    .ADREG(1),
    .ALUMODEREG(0),
    .AMULTSEL("A"),
    .AREG(0),
    .AUTORESET_PATDET("NO_RESET"),
    .AUTORESET_PRIORITY("RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(0),
    .BMULTSEL("B"),
    .BREG(0),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREADDINSEL("A"),
    .PREG(1),
    .RND(48'h000000000000),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48"),
    .USE_WIDEXOR("FALSE"),
    .XORSIMD("XOR24_48_96")) 
    half_duty_new2
       (.A({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b1,1'b1,1'b1,1'b0,1'b1,1'b0,1'b1,1'b1,1'b1,1'b1,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_half_duty_new2_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,duty_ena[7:0]}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_half_duty_new2_BCOUT_UNCONNECTED[17:0]),
        .C({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_half_duty_new2_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_half_duty_new2_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(1'b0),
        .CEA2(1'b0),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(1'b0),
        .CEB2(1'b0),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(half_duty_new0),
        .CLK(clk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_half_duty_new2_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_half_duty_new2_OVERFLOW_UNCONNECTED),
        .P({half_duty_new2_n_58,half_duty_new2_n_59,half_duty_new2_n_60,half_duty_new2_n_61,half_duty_new2_n_62,half_duty_new2_n_63,half_duty_new2_n_64,half_duty_new2_n_65,half_duty_new2_n_66,half_duty_new2_n_67,half_duty_new2_n_68,half_duty_new2_n_69,half_duty_new2_n_70,half_duty_new2_n_71,half_duty_new2_n_72,half_duty_new2_n_73,half_duty_new2_n_74,half_duty_new2_n_75,half_duty_new_reg,half_duty_new2_n_97,half_duty_new2_n_98,half_duty_new2_n_99,half_duty_new2_n_100,half_duty_new2_n_101,half_duty_new2_n_102,half_duty_new2_n_103,half_duty_new2_n_104,half_duty_new2_n_105}),
        .PATTERNBDETECT(NLW_half_duty_new2_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_half_duty_new2_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_half_duty_new2_PCOUT_UNCONNECTED[47:0]),
        .RSTA(1'b0),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(1'b0),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(1'b0),
        .UNDERFLOW(NLW_half_duty_new2_UNDERFLOW_UNCONNECTED),
        .XOROUT(NLW_half_duty_new2_XOROUT_UNCONNECTED[7:0]));
  LUT2 #(
    .INIT(4'h8)) 
    half_duty_new2_i_1
       (.I0(reset_n),
        .I1(duty_ena[8]),
        .O(half_duty_new0));
  FDRE #(
    .INIT(1'b0)) 
    \half_duty_reg[0][0] 
       (.C(clk),
        .CE(\half_duty_reg[0]0 ),
        .D(half_duty_new_reg[0]),
        .Q(\half_duty_reg_n_0_[0][0] ),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \half_duty_reg[0][10] 
       (.C(clk),
        .CE(\half_duty_reg[0]0 ),
        .D(half_duty_new_reg[10]),
        .Q(\half_duty_reg_n_0_[0][10] ),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \half_duty_reg[0][11] 
       (.C(clk),
        .CE(\half_duty_reg[0]0 ),
        .D(half_duty_new_reg[11]),
        .Q(\half_duty_reg_n_0_[0][11] ),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \half_duty_reg[0][12] 
       (.C(clk),
        .CE(\half_duty_reg[0]0 ),
        .D(half_duty_new_reg[12]),
        .Q(\half_duty_reg_n_0_[0][12] ),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \half_duty_reg[0][13] 
       (.C(clk),
        .CE(\half_duty_reg[0]0 ),
        .D(half_duty_new_reg[13]),
        .Q(\half_duty_reg_n_0_[0][13] ),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \half_duty_reg[0][14] 
       (.C(clk),
        .CE(\half_duty_reg[0]0 ),
        .D(half_duty_new_reg[14]),
        .Q(\half_duty_reg_n_0_[0][14] ),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \half_duty_reg[0][15] 
       (.C(clk),
        .CE(\half_duty_reg[0]0 ),
        .D(half_duty_new_reg[15]),
        .Q(\half_duty_reg_n_0_[0][15] ),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \half_duty_reg[0][16] 
       (.C(clk),
        .CE(\half_duty_reg[0]0 ),
        .D(half_duty_new_reg[16]),
        .Q(\half_duty_reg_n_0_[0][16] ),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \half_duty_reg[0][17] 
       (.C(clk),
        .CE(\half_duty_reg[0]0 ),
        .D(half_duty_new_reg[17]),
        .Q(\half_duty_reg_n_0_[0][17] ),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \half_duty_reg[0][18] 
       (.C(clk),
        .CE(\half_duty_reg[0]0 ),
        .D(half_duty_new_reg[18]),
        .Q(\half_duty_reg_n_0_[0][18] ),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \half_duty_reg[0][19] 
       (.C(clk),
        .CE(\half_duty_reg[0]0 ),
        .D(half_duty_new_reg[19]),
        .Q(\half_duty_reg_n_0_[0][19] ),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \half_duty_reg[0][1] 
       (.C(clk),
        .CE(\half_duty_reg[0]0 ),
        .D(half_duty_new_reg[1]),
        .Q(\half_duty_reg_n_0_[0][1] ),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \half_duty_reg[0][20] 
       (.C(clk),
        .CE(\half_duty_reg[0]0 ),
        .D(half_duty_new_reg[20]),
        .Q(\half_duty_reg_n_0_[0][20] ),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \half_duty_reg[0][2] 
       (.C(clk),
        .CE(\half_duty_reg[0]0 ),
        .D(half_duty_new_reg[2]),
        .Q(\half_duty_reg_n_0_[0][2] ),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \half_duty_reg[0][3] 
       (.C(clk),
        .CE(\half_duty_reg[0]0 ),
        .D(half_duty_new_reg[3]),
        .Q(\half_duty_reg_n_0_[0][3] ),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \half_duty_reg[0][4] 
       (.C(clk),
        .CE(\half_duty_reg[0]0 ),
        .D(half_duty_new_reg[4]),
        .Q(\half_duty_reg_n_0_[0][4] ),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \half_duty_reg[0][5] 
       (.C(clk),
        .CE(\half_duty_reg[0]0 ),
        .D(half_duty_new_reg[5]),
        .Q(\half_duty_reg_n_0_[0][5] ),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \half_duty_reg[0][6] 
       (.C(clk),
        .CE(\half_duty_reg[0]0 ),
        .D(half_duty_new_reg[6]),
        .Q(\half_duty_reg_n_0_[0][6] ),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \half_duty_reg[0][7] 
       (.C(clk),
        .CE(\half_duty_reg[0]0 ),
        .D(half_duty_new_reg[7]),
        .Q(\half_duty_reg_n_0_[0][7] ),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \half_duty_reg[0][8] 
       (.C(clk),
        .CE(\half_duty_reg[0]0 ),
        .D(half_duty_new_reg[8]),
        .Q(\half_duty_reg_n_0_[0][8] ),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \half_duty_reg[0][9] 
       (.C(clk),
        .CE(\half_duty_reg[0]0 ),
        .D(half_duty_new_reg[9]),
        .Q(\half_duty_reg_n_0_[0][9] ),
        .R(1'b0));
  FDCE \pwm_n_out_reg[0] 
       (.C(clk),
        .CE(\pwm_out[0]_i_1_n_0 ),
        .CLR(p_0_in),
        .D(pwm_out10_out),
        .Q(pwm_n_out));
  CARRY8 pwm_out0_carry
       (.CI(1'b1),
        .CI_TOP(1'b0),
        .CO({pwm_out0,pwm_out0_carry_n_1,pwm_out0_carry_n_2,pwm_out0_carry_n_3,pwm_out0_carry_n_4,pwm_out0_carry_n_5,pwm_out0_carry_n_6,pwm_out0_carry_n_7}),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .O(NLW_pwm_out0_carry_O_UNCONNECTED[7:0]),
        .S({pwm_out0_carry_i_1_n_0,pwm_out0_carry_i_2_n_0,pwm_out0_carry_i_3_n_0,pwm_out0_carry_i_4_n_0,pwm_out0_carry_i_5_n_0,pwm_out0_carry_i_6_n_0,pwm_out0_carry_i_7_n_0,pwm_out0_carry_i_8_n_0}));
  LUT2 #(
    .INIT(4'h9)) 
    pwm_out0_carry_i_1
       (.I0(pwm_out1[21]),
        .I1(\count_reg[0] [21]),
        .O(pwm_out0_carry_i_1_n_0));
  CARRY8 pwm_out0_carry_i_10
       (.CI(pwm_out0_carry_i_11_n_0),
        .CI_TOP(1'b0),
        .CO({pwm_out0_carry_i_10_n_0,pwm_out0_carry_i_10_n_1,pwm_out0_carry_i_10_n_2,pwm_out0_carry_i_10_n_3,pwm_out0_carry_i_10_n_4,pwm_out0_carry_i_10_n_5,pwm_out0_carry_i_10_n_6,pwm_out0_carry_i_10_n_7}),
        .DI({pwm_out0_carry_i_16_n_0,pwm_out0_carry_i_17_n_0,1'b0,pwm_out0_carry_i_18_n_0,1'b0,pwm_out0_carry_i_19_n_0,pwm_out0_carry_i_20_n_0,pwm_out0_carry_i_21_n_0}),
        .O(pwm_out1[16:9]),
        .S({\half_duty_reg_n_0_[0][16] ,\half_duty_reg_n_0_[0][15] ,pwm_out0_carry_i_22_n_0,\half_duty_reg_n_0_[0][13] ,pwm_out0_carry_i_23_n_0,\half_duty_reg_n_0_[0][11] ,\half_duty_reg_n_0_[0][10] ,\half_duty_reg_n_0_[0][9] }));
  CARRY8 pwm_out0_carry_i_11
       (.CI(pwm_out0_carry_i_24_n_0),
        .CI_TOP(1'b0),
        .CO({pwm_out0_carry_i_11_n_0,pwm_out0_carry_i_11_n_1,pwm_out0_carry_i_11_n_2,pwm_out0_carry_i_11_n_3,pwm_out0_carry_i_11_n_4,pwm_out0_carry_i_11_n_5,pwm_out0_carry_i_11_n_6,pwm_out0_carry_i_11_n_7}),
        .DI({pwm_out0_carry_i_25_n_0,1'b0,1'b0,1'b0,1'b0,pwm_out0_carry_i_26_n_0,1'b0,1'b0}),
        .O(pwm_out1[8:1]),
        .S({\half_duty_reg_n_0_[0][8] ,pwm_out0_carry_i_27_n_0,pwm_out0_carry_i_28_n_0,pwm_out0_carry_i_29_n_0,pwm_out0_carry_i_30_n_0,\half_duty_reg_n_0_[0][3] ,pwm_out0_carry_i_31_n_0,pwm_out0_carry_i_32_n_0}));
  LUT1 #(
    .INIT(2'h1)) 
    pwm_out0_carry_i_12
       (.I0(\half_duty_reg_n_0_[0][19] ),
        .O(pwm_out0_carry_i_12_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    pwm_out0_carry_i_13
       (.I0(\half_duty_reg_n_0_[0][18] ),
        .O(pwm_out0_carry_i_13_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    pwm_out0_carry_i_14
       (.I0(\half_duty_reg_n_0_[0][17] ),
        .O(pwm_out0_carry_i_14_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    pwm_out0_carry_i_15
       (.I0(\half_duty_reg_n_0_[0][20] ),
        .O(pwm_out0_carry_i_15_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    pwm_out0_carry_i_16
       (.I0(\half_duty_reg_n_0_[0][16] ),
        .O(pwm_out0_carry_i_16_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    pwm_out0_carry_i_17
       (.I0(\half_duty_reg_n_0_[0][15] ),
        .O(pwm_out0_carry_i_17_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    pwm_out0_carry_i_18
       (.I0(\half_duty_reg_n_0_[0][13] ),
        .O(pwm_out0_carry_i_18_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    pwm_out0_carry_i_19
       (.I0(\half_duty_reg_n_0_[0][11] ),
        .O(pwm_out0_carry_i_19_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    pwm_out0_carry_i_2
       (.I0(pwm_out1[20]),
        .I1(\count_reg[0] [20]),
        .I2(pwm_out1[19]),
        .I3(\count_reg[0] [19]),
        .I4(\count_reg[0] [18]),
        .I5(pwm_out1[18]),
        .O(pwm_out0_carry_i_2_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    pwm_out0_carry_i_20
       (.I0(\half_duty_reg_n_0_[0][10] ),
        .O(pwm_out0_carry_i_20_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    pwm_out0_carry_i_21
       (.I0(\half_duty_reg_n_0_[0][9] ),
        .O(pwm_out0_carry_i_21_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    pwm_out0_carry_i_22
       (.I0(\half_duty_reg_n_0_[0][14] ),
        .O(pwm_out0_carry_i_22_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    pwm_out0_carry_i_23
       (.I0(\half_duty_reg_n_0_[0][12] ),
        .O(pwm_out0_carry_i_23_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    pwm_out0_carry_i_24
       (.I0(\half_duty_reg_n_0_[0][0] ),
        .O(pwm_out0_carry_i_24_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    pwm_out0_carry_i_25
       (.I0(\half_duty_reg_n_0_[0][8] ),
        .O(pwm_out0_carry_i_25_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    pwm_out0_carry_i_26
       (.I0(\half_duty_reg_n_0_[0][3] ),
        .O(pwm_out0_carry_i_26_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    pwm_out0_carry_i_27
       (.I0(\half_duty_reg_n_0_[0][7] ),
        .O(pwm_out0_carry_i_27_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    pwm_out0_carry_i_28
       (.I0(\half_duty_reg_n_0_[0][6] ),
        .O(pwm_out0_carry_i_28_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    pwm_out0_carry_i_29
       (.I0(\half_duty_reg_n_0_[0][5] ),
        .O(pwm_out0_carry_i_29_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    pwm_out0_carry_i_3
       (.I0(pwm_out1[17]),
        .I1(\count_reg[0] [17]),
        .I2(pwm_out1[16]),
        .I3(\count_reg[0] [16]),
        .I4(\count_reg[0] [15]),
        .I5(pwm_out1[15]),
        .O(pwm_out0_carry_i_3_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    pwm_out0_carry_i_30
       (.I0(\half_duty_reg_n_0_[0][4] ),
        .O(pwm_out0_carry_i_30_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    pwm_out0_carry_i_31
       (.I0(\half_duty_reg_n_0_[0][2] ),
        .O(pwm_out0_carry_i_31_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    pwm_out0_carry_i_32
       (.I0(\half_duty_reg_n_0_[0][1] ),
        .O(pwm_out0_carry_i_32_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    pwm_out0_carry_i_4
       (.I0(pwm_out1[14]),
        .I1(\count_reg[0] [14]),
        .I2(pwm_out1[13]),
        .I3(\count_reg[0] [13]),
        .I4(\count_reg[0] [12]),
        .I5(pwm_out1[12]),
        .O(pwm_out0_carry_i_4_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    pwm_out0_carry_i_5
       (.I0(pwm_out1[11]),
        .I1(\count_reg[0] [11]),
        .I2(pwm_out1[10]),
        .I3(\count_reg[0] [10]),
        .I4(\count_reg[0] [9]),
        .I5(pwm_out1[9]),
        .O(pwm_out0_carry_i_5_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    pwm_out0_carry_i_6
       (.I0(pwm_out1[8]),
        .I1(\count_reg[0] [8]),
        .I2(pwm_out1[7]),
        .I3(\count_reg[0] [7]),
        .I4(\count_reg[0] [6]),
        .I5(pwm_out1[6]),
        .O(pwm_out0_carry_i_6_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    pwm_out0_carry_i_7
       (.I0(pwm_out1[5]),
        .I1(\count_reg[0] [5]),
        .I2(pwm_out1[4]),
        .I3(\count_reg[0] [4]),
        .I4(\count_reg[0] [3]),
        .I5(pwm_out1[3]),
        .O(pwm_out0_carry_i_7_n_0));
  LUT6 #(
    .INIT(64'h8200008241000041)) 
    pwm_out0_carry_i_8
       (.I0(\count_reg[0] [1]),
        .I1(\count_reg[0] [2]),
        .I2(pwm_out1[2]),
        .I3(\count_reg[0] [0]),
        .I4(\half_duty_reg_n_0_[0][0] ),
        .I5(pwm_out1[1]),
        .O(pwm_out0_carry_i_8_n_0));
  CARRY8 pwm_out0_carry_i_9
       (.CI(pwm_out0_carry_i_10_n_0),
        .CI_TOP(1'b0),
        .CO({NLW_pwm_out0_carry_i_9_CO_UNCONNECTED[7:5],pwm_out1[21],NLW_pwm_out0_carry_i_9_CO_UNCONNECTED[3],pwm_out0_carry_i_9_n_5,pwm_out0_carry_i_9_n_6,pwm_out0_carry_i_9_n_7}),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,pwm_out0_carry_i_12_n_0,pwm_out0_carry_i_13_n_0,pwm_out0_carry_i_14_n_0}),
        .O({NLW_pwm_out0_carry_i_9_O_UNCONNECTED[7:4],pwm_out1[20:17]}),
        .S({1'b0,1'b0,1'b0,1'b1,pwm_out0_carry_i_15_n_0,\half_duty_reg_n_0_[0][19] ,\half_duty_reg_n_0_[0][18] ,\half_duty_reg_n_0_[0][17] }));
  CARRY8 pwm_out1_carry
       (.CI(1'b1),
        .CI_TOP(1'b0),
        .CO({pwm_out10_out,pwm_out1_carry_n_1,pwm_out1_carry_n_2,pwm_out1_carry_n_3,pwm_out1_carry_n_4,pwm_out1_carry_n_5,pwm_out1_carry_n_6,pwm_out1_carry_n_7}),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .O(NLW_pwm_out1_carry_O_UNCONNECTED[7:0]),
        .S({pwm_out1_carry_i_1_n_0,pwm_out1_carry_i_2_n_0,pwm_out1_carry_i_3_n_0,pwm_out1_carry_i_4_n_0,pwm_out1_carry_i_5_n_0,pwm_out1_carry_i_6_n_0,pwm_out1_carry_i_7_n_0,pwm_out1_carry_i_8_n_0}));
  LUT1 #(
    .INIT(2'h1)) 
    pwm_out1_carry_i_1
       (.I0(\count_reg[0] [21]),
        .O(pwm_out1_carry_i_1_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    pwm_out1_carry_i_2
       (.I0(\half_duty_reg_n_0_[0][20] ),
        .I1(\count_reg[0] [20]),
        .I2(\half_duty_reg_n_0_[0][19] ),
        .I3(\count_reg[0] [19]),
        .I4(\count_reg[0] [18]),
        .I5(\half_duty_reg_n_0_[0][18] ),
        .O(pwm_out1_carry_i_2_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    pwm_out1_carry_i_3
       (.I0(\half_duty_reg_n_0_[0][17] ),
        .I1(\count_reg[0] [17]),
        .I2(\half_duty_reg_n_0_[0][16] ),
        .I3(\count_reg[0] [16]),
        .I4(\count_reg[0] [15]),
        .I5(\half_duty_reg_n_0_[0][15] ),
        .O(pwm_out1_carry_i_3_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    pwm_out1_carry_i_4
       (.I0(\half_duty_reg_n_0_[0][14] ),
        .I1(\count_reg[0] [14]),
        .I2(\half_duty_reg_n_0_[0][13] ),
        .I3(\count_reg[0] [13]),
        .I4(\count_reg[0] [12]),
        .I5(\half_duty_reg_n_0_[0][12] ),
        .O(pwm_out1_carry_i_4_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    pwm_out1_carry_i_5
       (.I0(\half_duty_reg_n_0_[0][11] ),
        .I1(\count_reg[0] [11]),
        .I2(\half_duty_reg_n_0_[0][10] ),
        .I3(\count_reg[0] [10]),
        .I4(\count_reg[0] [9]),
        .I5(\half_duty_reg_n_0_[0][9] ),
        .O(pwm_out1_carry_i_5_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    pwm_out1_carry_i_6
       (.I0(\half_duty_reg_n_0_[0][8] ),
        .I1(\count_reg[0] [8]),
        .I2(\half_duty_reg_n_0_[0][7] ),
        .I3(\count_reg[0] [7]),
        .I4(\count_reg[0] [6]),
        .I5(\half_duty_reg_n_0_[0][6] ),
        .O(pwm_out1_carry_i_6_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    pwm_out1_carry_i_7
       (.I0(\half_duty_reg_n_0_[0][5] ),
        .I1(\count_reg[0] [5]),
        .I2(\half_duty_reg_n_0_[0][4] ),
        .I3(\count_reg[0] [4]),
        .I4(\count_reg[0] [3]),
        .I5(\half_duty_reg_n_0_[0][3] ),
        .O(pwm_out1_carry_i_7_n_0));
  LUT6 #(
    .INIT(64'h8200008241000041)) 
    pwm_out1_carry_i_8
       (.I0(\count_reg[0] [1]),
        .I1(\count_reg[0] [2]),
        .I2(\half_duty_reg_n_0_[0][2] ),
        .I3(\count_reg[0] [0]),
        .I4(\half_duty_reg_n_0_[0][0] ),
        .I5(\half_duty_reg_n_0_[0][1] ),
        .O(pwm_out1_carry_i_8_n_0));
  LUT2 #(
    .INIT(4'hE)) 
    \pwm_out[0]_i_1 
       (.I0(pwm_out10_out),
        .I1(pwm_out0),
        .O(\pwm_out[0]_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \pwm_out[0]_i_2 
       (.I0(pwm_out0),
        .I1(pwm_out10_out),
        .O(\pwm_out[0]_i_2_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \pwm_out[0]_i_3 
       (.I0(reset_n),
        .O(p_0_in));
  FDCE \pwm_out_reg[0] 
       (.C(clk),
        .CE(\pwm_out[0]_i_1_n_0 ),
        .CLR(p_0_in),
        .D(\pwm_out[0]_i_2_n_0 ),
        .Q(pwm_out));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif


Q
Command: %s
53*	vivadotcl2 
place_design2default:defaultZ4-113h px� 
�
@Attempting to get a license for feature '%s' and/or device '%s'
308*common2"
Implementation2default:default2
xczu7ev2default:defaultZ17-347h px� 
�
0Got license for feature '%s' and/or device '%s'
310*common2"
Implementation2default:default2
xczu7ev2default:defaultZ17-349h px� 
P
Running DRC with %s threads
24*drc2
82default:defaultZ23-27h px� 
V
DRC finished with %s
79*	vivadotcl2
0 Errors2default:defaultZ4-198h px� 
e
BPlease refer to the DRC report (report_drc) for more information.
80*	vivadotclZ4-199h px� 
p
,Running DRC as a precondition to command %s
22*	vivadotcl2 
place_design2default:defaultZ4-22h px� 
P
Running DRC with %s threads
24*drc2
82default:defaultZ23-27h px� 
V
DRC finished with %s
79*	vivadotcl2
0 Errors2default:defaultZ4-198h px� 
e
BPlease refer to the DRC report (report_drc) for more information.
80*	vivadotclZ4-199h px� 
U

Starting %s Task
103*constraints2
Placer2default:defaultZ18-103h px� 
}
BMultithreading enabled for place_design using a maximum of %s CPUs12*	placeflow2
82default:defaultZ30-611h px� 
v

Phase %s%s
101*constraints2
1 2default:default2)
Placer Initialization2default:defaultZ18-101h px� 
�

Phase %s%s
101*constraints2
1.1 2default:default29
%Placer Initialization Netlist Sorting2default:defaultZ18-101h px� 
�
r%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s ; free physical = %s ; free virtual = %s
480*common2.
Netlist sorting complete. 2default:default2
00:00:00.052default:default2
00:00:00.062default:default2
6737.5942default:default2
0.0002default:default2
64292default:default2
249002default:defaultZ17-722h px� 
Z
EPhase 1.1 Placer Initialization Netlist Sorting | Checksum: c35f7a74
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:00:00.11 ; elapsed = 00:00:00.11 . Memory (MB): peak = 6737.594 ; gain = 0.000 ; free physical = 6429 ; free virtual = 249002default:defaulth px� 
�
r%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s ; free physical = %s ; free virtual = %s
480*common2.
Netlist sorting complete. 2default:default2
00:00:00.052default:default2
00:00:00.052default:default2
6737.5942default:default2
0.0002default:default2
64302default:default2
249012default:defaultZ17-722h px� 
�

Phase %s%s
101*constraints2
1.2 2default:default2F
2IO Placement/ Clock Placement/ Build Placer Device2default:defaultZ18-101h px� 
E
%Done setting XDC timing constraints.
35*timingZ38-35h px� 
g
RPhase 1.2 IO Placement/ Clock Placement/ Build Placer Device | Checksum: 984b4544
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:01:17 ; elapsed = 00:00:22 . Memory (MB): peak = 6737.594 ; gain = 0.000 ; free physical = 5819 ; free virtual = 242912default:defaulth px� 
}

Phase %s%s
101*constraints2
1.3 2default:default2.
Build Placer Netlist Model2default:defaultZ18-101h px� 
P
;Phase 1.3 Build Placer Netlist Model | Checksum: 158e9740e
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:03:07 ; elapsed = 00:01:16 . Memory (MB): peak = 6789.621 ; gain = 52.027 ; free physical = 5495 ; free virtual = 239682default:defaulth px� 
z

Phase %s%s
101*constraints2
1.4 2default:default2+
Constrain Clocks/Macros2default:defaultZ18-101h px� 
M
8Phase 1.4 Constrain Clocks/Macros | Checksum: 158e9740e
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:03:07 ; elapsed = 00:01:16 . Memory (MB): peak = 6789.621 ; gain = 52.027 ; free physical = 5501 ; free virtual = 239742default:defaulth px� 
I
4Phase 1 Placer Initialization | Checksum: 158e9740e
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:03:08 ; elapsed = 00:01:18 . Memory (MB): peak = 6789.621 ; gain = 52.027 ; free physical = 5503 ; free virtual = 239762default:defaulth px� 
q

Phase %s%s
101*constraints2
2 2default:default2$
Global Placement2default:defaultZ18-101h px� 
p

Phase %s%s
101*constraints2
2.1 2default:default2!
Floorplanning2default:defaultZ18-101h px� 
B
-Phase 2.1 Floorplanning | Checksum: c75f2e7c
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:05:50 ; elapsed = 00:02:22 . Memory (MB): peak = 6869.656 ; gain = 132.062 ; free physical = 5345 ; free virtual = 238202default:defaulth px� 
x

Phase %s%s
101*constraints2
2.2 2default:default2)
Global Placement Core2default:defaultZ18-101h px� 
�

Phase %s%s
101*constraints2
2.2.1 2default:default20
Physical Synthesis In Placer2default:defaultZ18-101h px� 
K
)No high fanout nets found in the design.
65*physynthZ32-65h px� 
�
$Optimized %s %s. Created %s new %s.
216*physynth2
02default:default2
net2default:default2
02default:default2
instance2default:defaultZ32-232h px� 
�
aEnd %s Pass. Optimized %s %s. Created %s new %s, deleted %s existing %s and moved %s existing %s
415*physynth2
12default:default2
02default:default2
net or cell2default:default2
02default:default2
cell2default:default2
02default:default2
cell2default:default2
02default:default2
cell2default:defaultZ32-775h px� 
�
0No setup violation found.  %s was not performed.344*physynth2-
DSP Register Optimization2default:defaultZ32-670h px� 
�
0No setup violation found.  %s was not performed.344*physynth2/
Shift Register Optimization2default:defaultZ32-670h px� 
�
0No setup violation found.  %s was not performed.344*physynth2.
BRAM Register Optimization2default:defaultZ32-670h px� 
R
.No candidate nets found for HD net replication521*physynthZ32-949h px� 
�
aEnd %s Pass. Optimized %s %s. Created %s new %s, deleted %s existing %s and moved %s existing %s
415*physynth2
12default:default2
02default:default2
net or cell2default:default2
02default:default2
cell2default:default2
02default:default2
cell2default:default2
02default:default2
cell2default:defaultZ32-775h px� 
�
r%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s ; free physical = %s ; free virtual = %s
480*common2.
Netlist sorting complete. 2default:default2
00:00:00.052default:default2
00:00:00.052default:default2
6869.6562default:default2
0.0002default:default2
53402default:default2
238252default:defaultZ17-722h px� 
B
-
Summary of Physical Synthesis Optimizations
*commonh px� 
B
-============================================
*commonh px� 


*commonh px� 


*commonh px� 
�
�----------------------------------------------------------------------------------------------------------------------------------------
*commonh px� 
�
�|  Optimization                  |  Added Cells  |  Removed Cells  |  Optimized Cells/Nets  |  Dont Touch  |  Iterations  |  Elapsed   |
----------------------------------------------------------------------------------------------------------------------------------------
*commonh px� 
�
�|  Very High Fanout              |            0  |              0  |                     0  |           0  |           1  |  00:00:01  |
|  DSP Register                  |            0  |              0  |                     0  |           0  |           0  |  00:00:00  |
|  Shift Register                |            0  |              0  |                     0  |           0  |           0  |  00:00:00  |
|  BRAM Register                 |            0  |              0  |                     0  |           0  |           0  |  00:00:00  |
|  HD Interface Net Replication  |            0  |              0  |                     0  |           0  |           1  |  00:00:00  |
|  Total                         |            0  |              0  |                     0  |           0  |           2  |  00:00:01  |
----------------------------------------------------------------------------------------------------------------------------------------
*commonh px� 


*commonh px� 


*commonh px� 
T
?Phase 2.2.1 Physical Synthesis In Placer | Checksum: 1e49617c5
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:09:50 ; elapsed = 00:04:34 . Memory (MB): peak = 6869.656 ; gain = 132.062 ; free physical = 5336 ; free virtual = 238222default:defaulth px� 
K
6Phase 2.2 Global Placement Core | Checksum: 1295c60eb
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:10:27 ; elapsed = 00:04:53 . Memory (MB): peak = 6869.656 ; gain = 132.062 ; free physical = 5332 ; free virtual = 238192default:defaulth px� 
D
/Phase 2 Global Placement | Checksum: 1295c60eb
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:10:28 ; elapsed = 00:04:53 . Memory (MB): peak = 6869.656 ; gain = 132.062 ; free physical = 5401 ; free virtual = 238882default:defaulth px� 
q

Phase %s%s
101*constraints2
3 2default:default2$
Detail Placement2default:defaultZ18-101h px� 
}

Phase %s%s
101*constraints2
3.1 2default:default2.
Commit Multi Column Macros2default:defaultZ18-101h px� 
P
;Phase 3.1 Commit Multi Column Macros | Checksum: 195a2100e
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:10:42 ; elapsed = 00:04:59 . Memory (MB): peak = 6869.656 ; gain = 132.062 ; free physical = 5299 ; free virtual = 237872default:defaulth px� 


Phase %s%s
101*constraints2
3.2 2default:default20
Commit Most Macros & LUTRAMs2default:defaultZ18-101h px� 
Q
<Phase 3.2 Commit Most Macros & LUTRAMs | Checksum: c7062fba
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:11:29 ; elapsed = 00:05:11 . Memory (MB): peak = 6869.656 ; gain = 132.062 ; free physical = 5046 ; free virtual = 235462default:defaulth px� 
y

Phase %s%s
101*constraints2
3.3 2default:default2*
Area Swap Optimization2default:defaultZ18-101h px� 
K
6Phase 3.3 Area Swap Optimization | Checksum: ee723ea4
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:11:32 ; elapsed = 00:05:13 . Memory (MB): peak = 6869.656 ; gain = 132.062 ; free physical = 4993 ; free virtual = 234922default:defaulth px� 
y

Phase %s%s
101*constraints2
3.4 2default:default2*
Small Shape Clustering2default:defaultZ18-101h px� 
L
7Phase 3.4 Small Shape Clustering | Checksum: 1066f9a4d
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:11:58 ; elapsed = 00:05:25 . Memory (MB): peak = 6869.656 ; gain = 132.062 ; free physical = 4866 ; free virtual = 233662default:defaulth px� 


Phase %s%s
101*constraints2
3.5 2default:default20
Flow Legalize Slice Clusters2default:defaultZ18-101h px� 
Q
<Phase 3.5 Flow Legalize Slice Clusters | Checksum: e20206bd
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:12:01 ; elapsed = 00:05:26 . Memory (MB): peak = 6869.656 ; gain = 132.062 ; free physical = 4864 ; free virtual = 233642default:defaulth px� 
r

Phase %s%s
101*constraints2
3.6 2default:default2#
Slice Area Swap2default:defaultZ18-101h px� 
E
0Phase 3.6 Slice Area Swap | Checksum: 122f0cd3c
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:12:45 ; elapsed = 00:05:45 . Memory (MB): peak = 6869.656 ; gain = 132.062 ; free physical = 4846 ; free virtual = 233462default:defaulth px� 
x

Phase %s%s
101*constraints2
3.7 2default:default2)
Commit Slice Clusters2default:defaultZ18-101h px� 
J
5Phase 3.7 Commit Slice Clusters | Checksum: ae79efc4
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:13:27 ; elapsed = 00:05:59 . Memory (MB): peak = 6869.656 ; gain = 132.062 ; free physical = 4888 ; free virtual = 233892default:defaulth px� 
u

Phase %s%s
101*constraints2
3.8 2default:default2&
Re-assign LUT pins2default:defaultZ18-101h px� 
G
2Phase 3.8 Re-assign LUT pins | Checksum: 96d0805d
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:13:40 ; elapsed = 00:06:11 . Memory (MB): peak = 6869.656 ; gain = 132.062 ; free physical = 4939 ; free virtual = 234422default:defaulth px� 
�

Phase %s%s
101*constraints2
3.9 2default:default22
Pipeline Register Optimization2default:defaultZ18-101h px� 
T
?Phase 3.9 Pipeline Register Optimization | Checksum: 14268d3a4
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:13:42 ; elapsed = 00:06:13 . Memory (MB): peak = 6869.656 ; gain = 132.062 ; free physical = 4996 ; free virtual = 234982default:defaulth px� 
D
/Phase 3 Detail Placement | Checksum: 14268d3a4
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:13:43 ; elapsed = 00:06:14 . Memory (MB): peak = 6869.656 ; gain = 132.062 ; free physical = 4995 ; free virtual = 234982default:defaulth px� 
�

Phase %s%s
101*constraints2
4 2default:default2<
(Post Placement Optimization and Clean-Up2default:defaultZ18-101h px� 
{

Phase %s%s
101*constraints2
4.1 2default:default2,
Post Commit Optimization2default:defaultZ18-101h px� 
E
%Done setting XDC timing constraints.
35*timingZ38-35h px� 
�

Phase %s%s
101*constraints2
4.1.1 2default:default2/
Post Placement Optimization2default:defaultZ18-101h px� 
V
APost Placement Optimization Initialization | Checksum: 1e5b3d045
*commonh px� 
u

Phase %s%s
101*constraints2
4.1.1.1 2default:default2"
BUFG Insertion2default:defaultZ18-101h px� 
�
VProcessed net %s, BUFG insertion was skipped because the netlist could not be updated.31*	placeflow2Q
=Base_Zynq_MPSoC_i/Simulated_Load_IP_Co_0/inst/u0/enable_s[19]2default:defaultZ46-32h px� 
�
PProcessed net %s, BUFG insertion was skipped due to placement/routing conflicts.32*	placeflow2�
}Base_Zynq_MPSoC_i/Simulated_Load_IP_Co_0/inst/u0/activity_blocks[3].switch/activity_blocks[0].switcherY/data_out_reg[17]_0[9]2default:defaultZ46-33h px� 
�
PProcessed net %s, BUFG insertion was skipped due to placement/routing conflicts.32*	placeflow2�
}Base_Zynq_MPSoC_i/Simulated_Load_IP_Co_0/inst/u0/activity_blocks[2].switch/activity_blocks[0].switcherY/data_out_reg[17]_0[9]2default:defaultZ46-33h px� 
�
PProcessed net %s, BUFG insertion was skipped due to placement/routing conflicts.32*	placeflow2�
}Base_Zynq_MPSoC_i/Simulated_Load_IP_Co_0/inst/u0/activity_blocks[1].switch/activity_blocks[0].switcherY/data_out_reg[17]_0[9]2default:defaultZ46-33h px� 
�
PProcessed net %s, BUFG insertion was skipped due to placement/routing conflicts.32*	placeflow2�
}Base_Zynq_MPSoC_i/Simulated_Load_IP_Co_0/inst/u0/activity_blocks[0].switch/activity_blocks[0].switcherY/data_out_reg[17]_0[9]2default:defaultZ46-33h px� 
�
2Processed net %s, inserted BUFG to drive %s loads.34*	placeflow2a
MBase_Zynq_MPSoC_i/ps8_0_axi_periph/xbar/inst/gen_samd.crossbar_samd/aresetn_d2default:default2
10162default:defaultZ46-35h px� 
�
Replicated bufg driver %s39*	placeflow2n
ZBase_Zynq_MPSoC_i/ps8_0_axi_periph/xbar/inst/gen_samd.crossbar_samd/aresetn_d_reg_bufg_rep2default:defaultZ46-45h px� 
�
�BUFG insertion identified %s candidate nets. Inserted BUFG: %s, Replicated BUFG Driver: %s, Skipped due to Placement/Routing Conflicts: %s, Skipped due to Timing Degradation: %s, Skipped due to Illegal Netlist: %s.43*	placeflow2
62default:default2
12default:default2
12default:default2
42default:default2
02default:default2
12default:defaultZ46-56h px� 
H
3Phase 4.1.1.1 BUFG Insertion | Checksum: 11f569a82
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:16:35 ; elapsed = 00:07:09 . Memory (MB): peak = 6949.652 ; gain = 212.059 ; free physical = 5010 ; free virtual = 235142default:defaulth px� 
�
hPost Placement Timing Summary WNS=%s. For the most accurate timing information please run report_timing.610*place2
3.7732default:defaultZ30-746h px� 
S
>Phase 4.1.1 Post Placement Optimization | Checksum: 17e68a550
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:16:37 ; elapsed = 00:07:11 . Memory (MB): peak = 6949.652 ; gain = 212.059 ; free physical = 5021 ; free virtual = 235252default:defaulth px� 
N
9Phase 4.1 Post Commit Optimization | Checksum: 17e68a550
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:16:38 ; elapsed = 00:07:13 . Memory (MB): peak = 6949.652 ; gain = 212.059 ; free physical = 5008 ; free virtual = 235122default:defaulth px� 
y

Phase %s%s
101*constraints2
4.2 2default:default2*
Post Placement Cleanup2default:defaultZ18-101h px� 
L
7Phase 4.2 Post Placement Cleanup | Checksum: 17e68a550
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:16:40 ; elapsed = 00:07:14 . Memory (MB): peak = 6949.652 ; gain = 212.059 ; free physical = 5036 ; free virtual = 235402default:defaulth px� 
�
r%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s ; free physical = %s ; free virtual = %s
480*common2.
Netlist sorting complete. 2default:default2
00:00:00.082default:default2
00:00:00.092default:default2
6976.6412default:default2
0.0002default:default2
50402default:default2
235452default:defaultZ17-722h px� 
s

Phase %s%s
101*constraints2
4.3 2default:default2$
Placer Reporting2default:defaultZ18-101h px� 
F
1Phase 4.3 Placer Reporting | Checksum: 19a0c57dc
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:16:48 ; elapsed = 00:07:22 . Memory (MB): peak = 6976.645 ; gain = 239.051 ; free physical = 5052 ; free virtual = 235562default:defaulth px� 
z

Phase %s%s
101*constraints2
4.4 2default:default2+
Final Placement Cleanup2default:defaultZ18-101h px� 
�
r%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s ; free physical = %s ; free virtual = %s
480*common2.
Netlist sorting complete. 2default:default2
00:00:00.042default:default2
00:00:00.042default:default2
6976.6452default:default2
0.0002default:default2
50522default:default2
235562default:defaultZ17-722h px� 
M
8Phase 4.4 Final Placement Cleanup | Checksum: 1cac67a19
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:16:50 ; elapsed = 00:07:23 . Memory (MB): peak = 6976.645 ; gain = 239.051 ; free physical = 5042 ; free virtual = 235462default:defaulth px� 
\
GPhase 4 Post Placement Optimization and Clean-Up | Checksum: 1cac67a19
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:16:51 ; elapsed = 00:07:25 . Memory (MB): peak = 6976.645 ; gain = 239.051 ; free physical = 5053 ; free virtual = 235582default:defaulth px� 
>
)Ending Placer Task | Checksum: 12e9a6f79
*commonh px� 
�

%s
*constraints2�
�Time (s): cpu = 00:16:51 ; elapsed = 00:07:25 . Memory (MB): peak = 6976.645 ; gain = 239.051 ; free physical = 5053 ; free virtual = 235582default:defaulth px� 
Z
Releasing license: %s
83*common2"
Implementation2default:defaultZ17-83h px� 
�
G%s Infos, %s Warnings, %s Critical Warnings and %s Errors encountered.
28*	vivadotcl2
902default:default2
22default:default2
02default:default2
02default:defaultZ4-41h px� 
^
%s completed successfully
29*	vivadotcl2 
place_design2default:defaultZ4-42h px� 
�
r%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s ; free physical = %s ; free virtual = %s
480*common2"
place_design: 2default:default2
00:17:022default:default2
00:07:322default:default2
6976.6452default:default2
239.0512default:default2
52802default:default2
237842default:defaultZ17-722h px� 
�
r%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s ; free physical = %s ; free virtual = %s
480*common2.
Netlist sorting complete. 2default:default2
00:00:00.052default:default2
00:00:00.052default:default2
6976.6452default:default2
0.0002default:default2
52682default:default2
237722default:defaultZ17-722h px� 
H
&Writing timing data to binary archive.266*timingZ38-480h px� 
D
Writing placer database...
1603*designutilsZ20-1893h px� 
=
Writing XDEF routing.
211*designutilsZ20-211h px� 
J
#Writing XDEF routing logical nets.
209*designutilsZ20-209h px� 
J
#Writing XDEF routing special nets.
210*designutilsZ20-210h px� 
�
r%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s ; free physical = %s ; free virtual = %s
480*common2)
Write XDEF Complete: 2default:default2
00:00:392default:default2
00:00:142default:default2
7008.6602default:default2
0.0042default:default2
48292default:default2
237282default:defaultZ17-722h px� 
�
 The %s '%s' has been generated.
621*common2

checkpoint2default:default2�
�/home/manvar00/Downloads/RELEASE_DVD/vivado_designs/zcu104_src_power/project_2/project_2.runs/impl_1/Base_Zynq_MPSoC_wrapper_placed.dcp2default:defaultZ17-1381h px� 
�
r%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s ; free physical = %s ; free virtual = %s
480*common2&
write_checkpoint: 2default:default2
00:00:592default:default2
00:00:372default:default2
7008.6722default:default2
32.0272default:default2
51842default:default2
237672default:defaultZ17-722h px� 
r
%s4*runtcl2V
BExecuting : report_io -file Base_Zynq_MPSoC_wrapper_io_placed.rpt
2default:defaulth px� 
�
�report_io: Time (s): cpu = 00:00:00.22 ; elapsed = 00:00:00.46 . Memory (MB): peak = 7008.672 ; gain = 0.000 ; free physical = 5157 ; free virtual = 23740
*commonh px� 
�
%s4*runtcl2�
�Executing : report_utilization -file Base_Zynq_MPSoC_wrapper_utilization_placed.rpt -pb Base_Zynq_MPSoC_wrapper_utilization_placed.pb
2default:defaulth px� 
�
r%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s ; free physical = %s ; free virtual = %s
480*common2(
report_utilization: 2default:default2
00:00:052default:default2
00:00:052default:default2
7008.6722default:default2
0.0002default:default2
51792default:default2
237632default:defaultZ17-722h px� 
�
%s4*runtcl2s
_Executing : report_control_sets -verbose -file Base_Zynq_MPSoC_wrapper_control_sets_placed.rpt
2default:defaulth px� 
�
�report_control_sets: Time (s): cpu = 00:00:04 ; elapsed = 00:00:04 . Memory (MB): peak = 7008.672 ; gain = 0.000 ; free physical = 5173 ; free virtual = 23753
*commonh px� 


End Record
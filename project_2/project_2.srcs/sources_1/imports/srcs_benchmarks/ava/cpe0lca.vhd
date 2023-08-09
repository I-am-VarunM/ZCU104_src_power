-- RTL description of synthesizable AVA decoder. Comments included.


library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

----------------------- Entity Declaration -----------------------

entity ava is
	port
	(
		CPE_Pclk                        : in std_logic;
		CPE_Reset                       : in std_logic;
		CPE_HostToPeFifoData_In         : in std_logic_vector ( 35 downto 0 );
		CPE_PeToHostFifoData_Out        : out std_logic_vector ( 35 downto 0 );
		CPE_HostToPeFifoEmpty_n         : in std_logic;
		CPE_Fifo_WE_n                   : out std_logic;
		CPE_FifoPtrIncr_EN              : out std_logic;
		CPE_PeToHostFifoData_OE         : out std_logic_vector ( 35 downto 0 )
	);
end ava;

-------------------------- Architecture Declaration --------------------------

-- This AVA decoder is described in an associated UMass Department of Electrical and 
-- Computer Engineering Technical Report. Note the following terminology:
-- 1. The term "child 0" refers to a next state created by a '0' input bit. Since the encoder 
--    is a shift chain, this '0' becomes the last bit of the next state
-- 2. The term "child 1" refers to a next state created by a '0' input bit. Since the encoder 
--    is a shift chain, this '1' becomes the last bit of the next state

architecture behavior of ava is

constant k : integer := 10;          -- K-1, where K is 9              
                                     -- Note that if this K value is changed it
                                     -- is also necessary to modify the
                                     -- expressions which determine encoder_bit2_out0
                                     -- and encoder_bit2_out1 
constant nmax : integer := 24;       -- Value of Nmax (Max number of paths allowed)
                                     -- Note that if this value is changed it
                                     -- is necessary to modify the circuitry
                                     -- which is used to search for the lowest
                                     -- cost dm (min1_update through min5_update)
constant nmaxd2 : integer := 12;     -- Value of Nmax divided by 2
constant nmaxd4 : integer := 6;      -- Value of Nmax divided by 4
constant nmaxd6 : integer := 4;      -- Value of Nmax divided by 6
constant nmaxd12 : integer := 2;     -- Value of Nmax divided by 12
constant tl : integer := 6;          -- Truncation length 
constant initialT  : std_logic_vector(5 downto 0) := "010100"; -- Initial value of T

signal T : std_logic_vector(5 downto 0);  -- threshold

type bm_array is array (3 downto 0) of std_logic_vector(3 downto 0);   -- defines output of branch metric unit
signal b : bm_array;                                                   -- branch metric outputs

signal initial, final : std_logic;                                     -- indicate initial and final input bit

type state_type is (reset_state, s1, s2, s3, evaluate_count, sort_step1, sort_step2, evaluate_dm, 
s7, s8, assign_child1_step1, complete_write,
fifo_write, dummy7, dummy5, increment_column, dummy4, evaluate_child0, evaluate_child1, 
evaluate_child0_incT, evaluate_child1_incT, assign_child1_test,   
Read1, Read2, assign_child1_step2, assign_child1_step4, dummy8, assign_child1_step3, dummy1, dummy0,       
dummy2, dummy3, dummy6, sort_step3, sort_step4, sort_step5, dummy9, dummy10);

signal present_state, next_state  : state_type;

signal valid : std_logic_vector(nmax-1 downto 0);     -- indicates which paths in surv. mem are valid.
signal one_survived : std_logic_vector(nmax-1 downto 0);   -- This value indicates that at least on child survived 
                                                            -- and a second child must be stored at a new row
                                                            -- One entry for each of original valid paths 
                                              
signal dm : std_logic_vector(5 downto 0);             -- minimum path metric from previous stage

type op_array is array (nmax-1 downto 0) of std_logic_vector(1 downto 0);

signal encoder_output0 : op_array;         -- encoder next output for each possible state if 0 input
signal encoder_output1 : op_array;         -- encoder next output for each possible state if 1 input

type ps_array is array (nmax-1 downto 0) of std_logic_vector(k-1 downto 0);
signal presentstate : ps_array;                

signal current_column : integer range 0 to tl;          -- indicates current column in survivor memory.
signal current_column_onehot : std_logic_vector(tl-1 downto 0); -- one hot version of current column pointer

signal onehot_nmax0 : std_logic_vector(nmax-1 downto 0);  -- onehot array which controls child evaluation
signal onehot_nmax1 : std_logic_vector(nmax-1 downto 0);  -- onehot array which controls child evaluation
signal onehot_nmax2 : std_logic_vector(nmax-1 downto 0);
signal onehot_nmax3 : std_logic_vector(nmax-1 downto 0);

                                                          -- if initial evaluation results in no survivors.

type ns_array is array (nmax-1 downto 0) of std_logic_vector(k-1 downto 0);
signal next_state0 : ns_array;   -- next state if 0 is input to encoder
signal next_state1 : ns_array;   -- next state if 1 is input to encoder

type next_array is array (nmax-1 downto 0) of std_logic_vector(k-1 downto 0);
signal survivor_nextstate0 : next_array;    -- Next state value for survivors created with 0 encoder input
signal survivor_nextstate1 : next_array;    -- Next state value for survivors created with 1 encoder input

type cs_array is array (nmax-1 downto 0) of std_logic_vector(5 downto 0);
signal survivor_pmetric0 : cs_array;   -- path metric for child 0 which survive pruning
signal survivor_pmetric1 : cs_array;   -- path metric for child 1 which survive pruning.
signal initial_pmetric0  : cs_array;   -- initial path metric for child 0 before pruning
signal initial_pmetric1  : cs_array;   -- initial path metric for child 0 before pruning

type csmain_array is array (nmax-1 downto 0) of std_logic_vector(5 downto 0);
signal pmetric : csmain_array;         -- path metric of survivors in present state array

type index_ns is array (nmax-1 downto 0) of std_logic;
signal path_used_child0 : index_ns;    -- indicates that the child0 has survived pruning
signal path_used_child1 : index_ns;    -- indicates that the child1 has survived pruning

type mem_array is array (nmax-1 downto 0) of std_logic_vector(tl-1 downto 0);
signal memory : mem_array;    -- survivor memory array

signal inc_T, dec_T, reset_T, inc_column, reset_column, inc_column_onehot, reset_column_onehot, inc_add, 
       reset_onehot_nmax1, inc_onehot_nmax1: std_logic;
signal inc_onehot_nmax0, reset_onehot_nmax0, inc_count, reset_count, calc_bm : std_logic;
signal inc_onehot_nmax2, inc_onehot_nmax3, reset_onehot_nmax2, reset_onehot_nmax3 : std_logic; 
signal test_variable, test_variable0 : std_logic;   -- indicates if child assignment to survivor memory has not occurred

signal quant_input1, quant_input2 : std_logic_vector(2 downto 0); -- quantized decoder inputs from channel
signal encoder_bit2_out0 : std_logic_vector(nmax-1 downto 0);  -- 2nd encoder output bit if 0 is encoder input
signal encoder_bit2_out1 : std_logic_vector(nmax-1 downto 0);  -- 2nd encoder output bit if 1 is encoder input

-- Various arrays used to locate lowest cost path metric (dm) so it can be used in next iteration
type min_array is array (nmax-1 downto 0) of std_logic_vector(5 downto 0);
signal min1: min_array;
type min2_array is array (nmaxd2-1 downto 0) of std_logic_vector(5 downto 0);
signal min2 : min2_array;
type row_array is array (nmaxd2-1 downto 0) of std_logic_vector(nmax-1 downto 0);
signal row1 : row_array;
type min3_array is array (nmaxd4-1 downto 0) of std_logic_vector(5 downto 0);
signal min3 : min3_array;
type row2_array is array (nmaxd4-1 downto 0) of std_logic_vector(nmax-1 downto 0);
signal row2 : row2_array;
type min4_array is array (nmaxd6-1 downto 0) of std_logic_vector(5 downto 0);
signal min4 : min4_array;
type row3_array is array (nmaxd6-1 downto 0) of std_logic_vector(nmax-1 downto 0);
signal row3 : row3_array;
type min5_array is array (nmaxd12-1 downto 0) of std_logic_vector(5 downto 0);
signal min5 : min5_array;
type row4_array is array (nmaxd12-1 downto 0) of std_logic_vector(nmax-1 downto 0);
signal row4 : row4_array;

signal count : integer range 0 to 50;  -- indicates number of survivors
signal used_row : std_logic_vector(nmax-1 downto 0);
signal spare_row : std_logic_vector(nmax-1 downto 0);
signal min_pmetric_row : std_logic_vector(nmax-1 downto 0);

signal norm_metric : std_logic;              -- Normalize metric by eliminating dm from each path metric
signal set_encoder_bit2_output : std_logic;  -- Determine second bit generated by encoder.     
signal set_next_state : std_logic;           -- Determine next state values for encoder for 0 and 1 input
signal set_encoder_output : std_logic;       -- Set all Nmax expected values from encoder.

signal read_quant_input : std_logic;          -- Read quantized input values
signal set_pmetrics_from_child0 : std_logic;  -- Move surviving path metrics from surv. arrays to pmetric array
signal set_pmetrics_from_child1 : std_logic; 
signal set_pmetrics_new_row : std_logic;      -- Move surv. path metrics to a spare row since both parents survive
signal reset_valid : std_logic;               -- Reset valid array

signal reset_rows, set_used_row, set_spare_row : std_logic;

signal set_dm, reset_dm : std_logic;
signal set_min1, set_min2, set_min3, set_min4, set_min5 : std_logic;

signal set_min_pmetric_row, reset_min_pmetric_row : std_logic;
signal set_fifo_out : std_logic;      -- Write output value to FIFO
signal reset_child_info : std_logic;  -- Reset child use arrays and child path metrics.

signal move_child1_to_child0 : std_logic;     -- a bit of a hack. If both a child0 and child1 survive, 
                                              --  the child1 must eventually become a child0 in a spare row
signal evaluate_child0_initial : std_logic;   -- determine path metric and if survived for child0 if count > 0
signal evaluate_child1_initial : std_logic;   -- determine path metric and if survived for child1 if count > 0
signal evaluate_child0_incrementT : std_logic;      -- determine path metric and if survived for child0 if initial count = 0
signal evaluate_child1_incrementT : std_logic;      -- determine path metric and if survived for child1 if initial count = 0
signal reset_row, reset_nextstates : std_logic;

begin  -- decoder

-- Branch metric generator. This block accepts the 2 three-bit quantized
-- inputs and determines the Hamming distance for all four possible
-- input combinations. b outputs are 4 bits in size. Note hear that
-- unlike the example in the Swaminathan paper, this BMU generates four
-- bit quantized branch metrics (the paper describes 2 bit metrics)

         bmg : process (CPE_Pclk,CPE_Reset)

         begin  -- process bmg
           if (CPE_Reset ='1') then
              for p in 3 downto 0 loop
                   b(p) <= (others => '0');
              end loop;  -- i
           elsif (CPE_Pclk'event and CPE_Pclk = '1') then
             if (calc_bm = '1') then
               b(0) <= ('0' & quant_input1) + ('0' & quant_input2);
               b(1) <= ('0' & quant_input1) + ("0111"-('0' & quant_input2)); 
               b(2) <= ('0' & quant_input2) + ("0111"-('0' & quant_input1));  
               b(3) <= ("0111"- ('0' & quant_input1)) + ("0111"- ('0' & quant_input2));
             end if;
           end if; 
         end process bmg;

-- The AVA decoder primarily operates as a finite state machine that
-- progresses through a series of states starting with a read of data
-- from a channel and terminating with a decoder output. The following
-- updates the state at every clock cycle.

         -- purpose: RESET
         -- type   : combinational
         -- inputs : clock, reset
         -- outputs: 
         state_clocked : process (CPE_Pclk, CPE_Reset)
         begin  -- process
           if CPE_Reset = '1' then
             present_state <= reset_state;
           elsif CPE_Pclk'event and CPE_Pclk = '1' then
             present_state <= next_state;
           end if;
         end process state_clocked;
   
-- Following the initial evaluation of new path metrics versus dm + T
-- three situations can occur 
-- 1. No paths survive.
-- 2. More than Nmax    
-- 3. Fewer than Nmax paths survive.

-- For the first two cases, T is modified and path metrics are
-- reevaluated against the new threshold.

         -- purpose: Threshold Update
         -- type   : sequential
         -- inputs : CPE_Pclk, CPE_Reset
         -- outputs: T
         T_update: process (CPE_Pclk, CPE_Reset)
         begin  -- process T_update
           if CPE_Reset = '1' then      -- asynchronous reset (active low)
             T <= initialT;             -- Set the default threshold
           elsif CPE_Pclk'event and CPE_Pclk = '1' then  -- rising clock edge
             if dec_T = '1' then        -- Too many paths survived
               T <= T - 2;
             elsif inc_T = '1' then     -- No paths survived
               T <= T + 2;
             elsif reset_T = '1' then   -- Reset T
               T <= initialT;
             end if;
           end if;
         end process T_update;
         
-- As explained in the FPGA'02 paper, decoded bits for each state at a
-- time slot (trellis stage) are stored in a column in the survivor memory. 
-- This process maintains a onehot pointer into the memory.

         -- purpose: Current_column_onehot Update
         -- type   : sequential
         -- inputs : CPE_Pclk, CPE_Reset
         -- outputs: current_column_onehot
         current_column_onehot_update: process (CPE_Pclk, CPE_Reset)
         begin  -- process current_column_onehot
           if CPE_Reset = '1' then      -- asynchronous reset (active low)
              current_column_onehot(tl-1 downto 1) <= (others => '0');
              current_column_onehot(0) <= '1';
           elsif CPE_Pclk'event and CPE_Pclk = '1' then  -- rising clock edge
             if reset_column_onehot = '1' then
                current_column_onehot(tl-1 downto 1) <= (others => '0');
                current_column_onehot(0) <= '1';
             elsif inc_column_onehot = '1' then
               current_column_onehot <= current_column_onehot(tl-2 downto 0) & current_column_onehot(tl-1);
             end if;
           end if;
         end process current_column_onehot_update;

-- As explained in the FPGA'02 paper, decoded bits for each state at a
-- time slot (trellis stage) are stored in a column in the survivor memory. 
-- This process maintains an integer pointer into the memory.

         -- purpose: current_column update
         -- type   : sequential
         -- inputs : CPE_Pclk, CPE_Reset
         -- outputs: current_column
         current_column_update: process (CPE_Pclk, CPE_Reset)
         begin  -- process current_column_update
           if CPE_Reset = '1' then      -- asynchronous reset (active low)
             current_column <= 0;
           elsif CPE_Pclk'event and CPE_Pclk = '1' then  -- rising clock edge
             if inc_column = '1' then
               current_column <= current_column + 1;
             elsif reset_column = '1' then
               current_column <= 0;
             end if;
           end if;
         end process current_column_update;

-- This code determines the path metrics for "child" paths created from
-- each surviving path from the previous stage. Note that the term 
-- "initial_pmetric" is used since these metrics have not yet been
-- compared to the dm + T threshold.

         -- purpose: path metrics
         -- type   : sequential
         -- inputs : CPE_Pclk, CPE_Reset
         -- outputs: branch metrics
         metrics: process (CPE_Pclk, CPE_Reset)
         begin  -- process hamming
           if CPE_Reset = '1' then      -- asynchronous reset (active low)
             initial_pmetric0 <= (others => (others => '0'));
             initial_pmetric1 <= (others => (others => '0'));
             -- initial_pmetric0 <= (others => "000000");
             -- initial_pmetric1 <= (others => "000000");
           elsif CPE_Pclk'event and CPE_Pclk = '1' then  -- rising clock edge
             if inc_add = '1' then
               for i in 0 to nmax-1 loop
               if valid(i) = '1' then
                 case encoder_output0(i) is
                   when "00" =>
                     initial_pmetric0(i) <= ("00" & b(0)) + pmetric(i);
                   when "01" =>
                     initial_pmetric0(i) <= ("00" & b(1)) + pmetric(i);
                   when "10" =>
                     initial_pmetric0(i) <= ("00" & b(2)) + pmetric(i);
                   when "11" =>
                     initial_pmetric0(i) <= ("00" & b(3)) + pmetric(i);
                   when others => null;
                 end case;
                 case encoder_output1(i) is
                   when "00" =>
                     initial_pmetric1(i) <= ("00" & b(0)) + pmetric(i);
                   when "01" =>
                     initial_pmetric1(i) <= ("00" & b(1)) + pmetric(i);
                   when "10" =>
                     initial_pmetric1(i) <= ("00" & b(2)) + pmetric(i);
                   when "11" =>
                     initial_pmetric1(i) <= ("00" & b(3)) + pmetric(i);
                   when others => null;
                 end case;
               end if;
               end loop;
             end if;
           end if;
         end process metrics;


-- A series of four one-hot counters are used to allow for sequential
-- evaluation of some parameters. These values effectively gate the
-- activity of various case and if statements 

         -- purpose: onehot_nmax0 increment
         -- type   : sequential
         -- inputs : CPE_Pclk, CPE_Reset
         -- outputs: onehot_nmax0
         onehot_nmax0_update: process (CPE_Pclk, CPE_Reset)
         begin  -- process onehot_nmax0_update
           if CPE_Reset = '1' then      -- asynchronous reset (active low)
             onehot_nmax0(nmax-1 downto 1) <= (others => '0');
             onehot_nmax0(0) <= '1';                         
           elsif CPE_Pclk'event and CPE_Pclk = '1' then  -- rising clock edge
             if reset_onehot_nmax0 = '1' then
               onehot_nmax0(nmax-1 downto 1) <= (others => '0');
               onehot_nmax0(0) <= '1';
             elsif inc_onehot_nmax0 = '1' then
               onehot_nmax0 <= onehot_nmax0(nmax-2 downto 0) & '0';
             end if;
           end if;
         end process onehot_nmax0_update;

         -- purpose: control onehot_nmax1
         -- type   : sequential
         -- inputs : CPE_Pclk, CPE_Reset
         -- outputs: onehot_nmax1
         running_out_of_names: process (CPE_Pclk, CPE_Reset)
         begin  -- process running_out_of_names
           if CPE_Reset = '1' then      -- asynchronous reset (active low)
             onehot_nmax1(nmax-1 downto 1) <= (others => '0');
             onehot_nmax1(0) <= '1';
           elsif CPE_Pclk'event and CPE_Pclk = '1' then  -- rising clock edge
             if reset_onehot_nmax1 = '1' then
               onehot_nmax1(nmax-1 downto 1) <= (others => '0');
               onehot_nmax1(0) <= '1';
             elsif inc_onehot_nmax1 = '1' then
               onehot_nmax1 <= onehot_nmax1(nmax-2 downto 0) & '0';
             end if;
           end if;
         end process running_out_of_names;

         -- purpose: update onehot_nmax2
         -- type   : sequential
         -- inputs : CPE_Pclk, CPE_Reset
         -- outputs: onehot_nmax2
         onehot_nmax2update: process (CPE_Pclk, CPE_Reset)
         begin  -- process onehot_nmax2update
           if CPE_Reset = '1' then      -- asynchronous reset (active low)
             onehot_nmax2(nmax-1 downto 1) <= (others => '0');
             onehot_nmax2(0) <= '1';
           elsif CPE_Pclk'event and CPE_Pclk = '1' then  -- rising clock edge
             if reset_onehot_nmax2 = '1' then
               onehot_nmax2(nmax-1 downto 1) <= (others => '0');
               onehot_nmax2(0) <= '1';
             elsif inc_onehot_nmax2 = '1' then
               onehot_nmax2 <= onehot_nmax2(nmax-2 downto 0) & '0';
             end if;
           end if;
         end process onehot_nmax2update;

         -- purpose: update onehot_nmax3
         -- type   : sequential
         -- inputs : CPE_Pclk, CPE_Reset
         -- outputs: onehot_nmax3
         onehot_nmax3update: process (CPE_Pclk, CPE_Reset)
         begin  -- process onehot_nmax2update
           if CPE_Reset = '1' then      -- asynchronous reset (active low)
             onehot_nmax3(nmax-1 downto 1) <= (others => '0');
             onehot_nmax3(0) <= '1';
           elsif CPE_Pclk'event and CPE_Pclk = '1' then  -- rising clock edge
             if reset_onehot_nmax3 = '1' then
               onehot_nmax3(nmax-1 downto 1) <= (others => '0');
               onehot_nmax3(0) <= '1';
             elsif inc_onehot_nmax3 = '1' then
               onehot_nmax3 <= onehot_nmax3(nmax-2 downto 0) & '0';
             end if;
           end if;
         end process onehot_nmax3update;


-- This variable tracks the number of surviving paths that meet the
-- threshold condition.

         -- purpose:
         -- 
         count_update: process (CPE_Pclk, CPE_Reset)
         begin  -- process count update
           if CPE_Reset = '1' then      -- asynchronous reset (active low)
             count <= 0;
           elsif CPE_Pclk'event and CPE_Pclk = '1' then  -- rising clock edge
             if reset_count = '1' then
               count <= 0;
             elsif inc_count = '1' then
               count <= count + 1;
             end if;
           end if;
         end process count_update;

-- Part of the decoding process is determining the expected next state
-- for each trellis "present state" and using this to determine the
-- expected two-bit value that was transmitted over the channel. Since
-- bit 1 of the transmitted value is always the encoder input bit,
-- XOR equations are only needed to determine the second expected
-- output bit. Note that since there a total of Nmax possible "present
-- states" two single bit arrays of Nmax bits are needed. 


        -- purpose: encoder_bit2_out0 update
         -- type   : sequential
         -- inputs : CPE_Pclk, CPE_Reset
         -- outputs: encoder_bit2_out0, encoder_bit2_out1
         out_update: process (CPE_Pclk, CPE_Reset)
         begin  -- process onehot_nmax2update
           if CPE_Reset = '1' then      -- asynchronous reset (active low)
             encoder_bit2_out0 <= (others => '0');
             encoder_bit2_out1 <= (others => '0');   
           elsif CPE_Pclk'event and CPE_Pclk = '1' then  -- rising clock edge
             if set_encoder_bit2_output = '1' then
                for g in 0 to nmax-1 loop
                   if valid(g) = '1' then
                      encoder_bit2_out0(g) <= ('0' xor presentstate(g)(0)) xor (presentstate(g)(1) 
                                                   xor presentstate(g)(2) xor presentstate(g)(3) 
                                                   xor presentstate(g)(4) xor presentstate(g)(5) 
                                                   xor presentstate(g)(6) xor presentstate(g)(7) xor presentstate(g)(8) 
                                                   xor presentstate(g)(9));
                      encoder_bit2_out1(g) <= ('1' xor presentstate(g)(0)) xor (presentstate(g)(1) 
                                                   xor presentstate(g)(2) xor presentstate(g)(3) 
                                                   xor presentstate(g)(4) xor presentstate(g)(5) 
                                                   xor presentstate(g)(6) xor presentstate(g)(7) 
                                                   xor presentstate(g)(8) xor presentstate(g)(9));
                   end if;
                end loop;
             end if;
           end if;
         end process out_update;

-- Create the expected "encoder output" for each trellis state based on the
-- bits determined above and a '0' or '1' encoder input.

         -- purpose: output update
         -- type   : sequential
         -- inputs : CPE_Pclk, CPE_Reset
         -- outputs: encoder_output0, encoder_output1
         output_update: process (CPE_Pclk, CPE_Reset)
         begin  -- process onehot_nmax2update
           if CPE_Reset = '1' then      -- asynchronous reset (active low)
             encoder_output0 <= (others => (others => '0'));
             encoder_output1 <= (others => (others => '0'));
             -- encoder_output0 <= (others => "00");
             -- encoder_output1 <= (others => "00");       
           elsif CPE_Pclk'event and CPE_Pclk = '1' then  -- rising clock edge
             if set_encoder_output = '1' then
                for g in 0 to nmax-1 loop
                   if valid(g) = '1' then
                     encoder_output0(g) <=  '0' & encoder_bit2_out0(g);
                     encoder_output1(g) <=  '1' & encoder_bit2_out1(g);      
                   end if;
                end loop;
             end if;
           end if;
         end process output_update;

-- This code determines the next states for each current present state.
-- The two next states represent values created by either a 0 or 1
-- encoder input. These represent the upper and lower fanout from a
-- trellis node.

        -- purpose: nsupdate
         -- type   : sequential
         -- inputs : CPE_Pclk, CPE_Reset
         -- outputs: next_state0, next_state1
         ns_update: process (CPE_Pclk, CPE_Reset)
         begin  -- process onehot_nmax2update
           if CPE_Reset = '1' then      -- asynchronous reset (active low)
             next_state0 <= (others => (others => '0'));
             next_state1 <= (others => (others => '0'));
--             next_state0 <= (others => "0000000000");
--             next_state1 <= (others => "0000000000");  
           elsif CPE_Pclk'event and CPE_Pclk = '1' then  -- rising clock edge
             if set_next_state = '1' then
                for g in 0 to nmax-1 loop
                   if valid(g) = '1' then
                      next_state0(g) <= '0' & presentstate(g)(k-1 downto 1);
                      next_state1(g) <= '1' & presentstate(g)(k-1 downto 1);     
                   end if;
                end loop;
             end if;
           end if;
         end process ns_update;
        

-- This is the input loop for data receiving from the channel. Note
-- that for this implementation data is received in a data packet which is
-- drawn from a FIFO. This packet includes the 2 three-bit quantized
-- soft inputs, and bits which indicate if this is the initial or final
-- data value. The "read_quant_input" control signal is asserted by the
-- AVA control state machine.

        -- purpose: get inputs
        -- type   : sequential
        -- inputs : CPE_Pclk, CPE_Reset
        -- outputs: quant_input1, quant_input2, initial, final
        dec_inputs: process (CPE_Pclk, CPE_Reset)
        begin  -- process inputs
          if CPE_Reset = '1' then       -- asynchronous reset (active low)
              quant_input1 <= (others => '0');
              quant_input2 <= (others => '0');
              initial <= '0';
              final <= '0';
          elsif CPE_Pclk'event and CPE_Pclk = '1' then  -- rising clock edge
            if (read_quant_input = '1') then
              quant_input1 <= CPE_HostToPeFifoData_In(2 downto 0);
              quant_input2 <= CPE_HostToPeFifoData_In(5 downto 3);
              initial <= CPE_HostToPeFifoData_In(6);
              final <= CPE_HostToPeFifoData_In(7);
            end if;
          end if;
        end process dec_inputs;

-- This process sets path metrics for child paths that meet the set
-- threshold requirement. There are four possibilities for setting child path
-- metrics, which are listed below and appear under the four elsif conditions. 
-- 1. If the path metric of a child state created by shifting a '0'
--    into the encoder meets the threshold condition, place in same
--    survivor mem row as parent if it is empty
-- 2. If the path metric of a child state created by shifting a '0'
--    into the encoder meets the threshold condition, place in same
--    survivor mem row as parent if it is empty
-- 3. If the path metric of a child state created by shifting a '1'
--    into the encoder meets the threshold condition and the parent
--    survivor mem row is filled with child 0 info, place child '1' 
--    info in a spare row.
-- 4. To save space, all path metrics for surviving states are reduced
--    by the magnitude of the small path metric.
-- Note here that path_used_child0 indicates that the child0 path meets
-- the threshold condition

         -- purpose: cumsum update
         -- type   : sequential
         -- inputs : CPE_Pclk, CPE_Reset
         -- outputs: cumsum
         update_sum: process (CPE_Pclk, CPE_Reset)
         begin  -- process update_sum
           if CPE_Reset = '1' then      -- asynchronous reset (active low)
             -- pmetric <= (others => "000000");
             pmetric <= (others => (others => '0'));
           elsif CPE_Pclk'event and CPE_Pclk = '1' then  -- rising clock edge
             if set_pmetrics_from_child0 = '1' then
               for c in 0 to nmax-1 loop
                 if path_used_child0(c) = '1' then
                   if valid(c) = '0' then
                     pmetric(c) <= survivor_pmetric0(c);     -- Save child 0 path metrics
                   end if;
                 end if;
               end loop;  -- c
             elsif set_pmetrics_from_child1 = '1' then
               for a in 0 to nmax-1 loop
                 if path_used_child1(a) = '1' then
                   if valid(a) = '0' then
                     pmetric(a) <= survivor_pmetric1(a);     -- Save child 1 path metrics
                   end if;
                 end if;
               end loop;  -- a
             elsif set_pmetrics_new_row = '1' then
               for index in 0 to nmax-1 loop
                 if spare_row(index) = '1' then
                   for kk in 0 to nmax-1 loop
                     if used_row(kk) = '1' then
                       pmetric(index) <= survivor_pmetric1(kk);  -- Save child 1 path metrics in spare row
                     end if;
                   end loop;
                 end if;
               end loop;
             elsif norm_metric = '1' then
               for dd in 0 to nmax-1 loop
                 if valid(dd) = '1' then
                   pmetric(dd) <= pmetric(dd) - dm;    -- Normalize path metric 
                 end if;
               end loop;  -- dd    
             end if;
           end if;
           end process update_sum;

-- This process sets valid bits for child paths that meet the set
-- threshold requirement. The valid bits indicate which of the Nmax
-- possible survivors are actually valid. There are three possibilities for setting child 
-- valid bits, which are listed below and appear under the three elsif conditions. 
-- 1. If the path metric of a child state created by shifting a '0'
--    into the encoder meets the threshold condition.
-- 2. If the path metric of a child state created by shifting a '0'
--    into the encoder meets the threshold condition.
-- 3. If the path metric of a child state created by shifting a '1'
--    into the encoder meets the threshold condition and the parent
--    survivor mem row is filled with child 0 info, place child '1' 
--    info in a spare row and mark valid
-- Note here that path_used_child0 (path_used_child1) indicates that 
-- the child0 (child1) path meets the threshold condition

         -- purpose: valid update
         -- type   : sequential
         -- inputs : CPE_Pclk, CPE_Reset
         -- outputs: valid
         update_valid: process (CPE_Pclk, CPE_Reset)
         begin  -- process update_sum
           if CPE_Reset = '1' then      -- asynchronous reset (active low)
             valid(nmax-1 downto 1) <= (others => '0');
             valid(0) <= '1';
           elsif CPE_Pclk'event and CPE_Pclk = '1' then  -- rising clock edge
             if set_pmetrics_from_child0 = '1' then
               for c in 0 to nmax-1 loop
                 if path_used_child0(c) = '1' then
                   if valid(c) = '0' then
                     valid(c) <= '1';
                   end if;
                 end if;
               end loop;  -- c
             elsif set_pmetrics_from_child1 = '1' then
               for a in 0 to nmax-1 loop
                 if path_used_child1(a) = '1' then
                   if valid(a) = '0' then
                     valid(a) <= '1';
                   end if;
                 end if;
               end loop;  -- a
             elsif set_pmetrics_new_row = '1' then
               for index in 0 to nmax-1 loop
                 if spare_row(index) = '1' then
                   for kk in 0 to nmax-1 loop
                     if used_row(kk) = '1' then
                      valid(index) <= '1';
                     end if;
                   end loop;
                 end if;
               end loop;
             elsif  reset_valid = '1' then
               valid <= (others => '0');    
             end if;
           end if;
           end process update_valid;

-- This process sets the "present state" for the next iteration for child paths that meet the set
-- threshold requirement. The present state is set for
-- survivors that are valid. There are three possibilities for setting present state 
-- entires, which are listed below and appear under the three elsif conditions. 
-- 1. If the path metric of a child state created by shifting a '0'
--    into the encoder meets the threshold condition.
-- 2. If the path metric of a child state created by shifting a '0'
--    into the encoder meets the threshold condition.
-- 3. If the path metric of a child state created by shifting a '1'
--    into the encoder meets the threshold condition and the parent
--    survivor mem row is filled with child 0 info, place child '1' 
--    info in a spare row and set the corresponding index location in the present state array
-- Note here that path_used_child0 (path_used_child1) indicates that 
-- the child0 (child1) path meets the threshold condition

          -- purpose: presentstate update
         -- type   : sequential
         -- inputs : CPE_Pclk, CPE_Reset
         -- outputs: presentstate
         update_presentstate: process (CPE_Pclk, CPE_Reset)
         begin  -- process update_sum
           if CPE_Reset = '1' then      -- asynchronous reset (active low)
--             presentstate <= (others => "0000000000");
               presentstate <= (others => (others => '0'));
           elsif CPE_Pclk'event and CPE_Pclk = '1' then  -- rising clock edge
             if set_pmetrics_from_child0 = '1' then
               for c in 0 to nmax-1 loop
                 if path_used_child0(c) = '1' then
                   if valid(c) = '0' then
                     presentstate(c) <= survivor_nextstate0(c);
                   end if;
                 end if;
               end loop;  -- c
             elsif set_pmetrics_from_child1 = '1' then
               for a in 0 to nmax-1 loop
                 if path_used_child1(a) = '1' then
                   if valid(a) = '0' then
                     presentstate(a) <= survivor_nextstate1(a);
                   end if;
                 end if;
               end loop;  -- a
             elsif set_pmetrics_new_row = '1' then     -- Both children survive so
                                                       -- a new row is needed for child 1 
               for index in 0 to nmax-1 loop
                 if spare_row(index) = '1' then        -- locate a spare row
                   for kk in 0 to nmax-1 loop
                     if used_row(kk) = '1' then
                       presentstate(index) <= survivor_nextstate1(kk);
                     end if;
                   end loop;
                 end if;
               end loop;
             end if;
           end if;
           end process update_presentstate;

-- This process sets a column of decoded bits in the survivor memory for child paths that meet the
-- threshold requirement. The memory values are set for
-- survivors that are valid. There are three possibilities for setting memory 
-- entries, which are listed below and appear under the three elsif conditions. 
-- 1. If the path metric of a child state created by shifting a '0'
--    into the encoder meets the threshold condition.
-- 2. If the path metric of a child state created by shifting a '0'
--    into the encoder meets the threshold condition.
-- 3. If the path metric of a child state created by shifting a '1'
--    into the encoder meets the threshold condition and the parent
--    survivor mem row is filled with child 0 info, place child '1' 
--    info in a spare row and set the corresponding index location in the present state array
-- Note here that path_used_child0 (path_used_child1) indicates that 
-- the child0 (child1) path meets the threshold condition

         -- purpose: memory update
         -- type   : sequential
         -- inputs : CPE_Pclk, CPE_Reset
         -- outputs: memory
         update_memory: process (CPE_Pclk, CPE_Reset)
         begin  -- process update_memory
           if CPE_Reset = '1' then      -- asynchronous reset (active low)
             memory <= (others => (others => '0'));
             -- memory <= (others => "000000");
           elsif CPE_Pclk'event and CPE_Pclk = '1' then  -- rising clock edge
             if set_pmetrics_from_child0 = '1' then
               for c in 0 to nmax-1 loop
                 if path_used_child0(c) = '1' then
                   if valid(c) = '0' then
                     for i in 0 to tl-1 loop
                       if current_column_onehot(i) = '1' then
                         memory(c)(i) <= survivor_nextstate0(c)(k-1);  -- store expected
                       end if;                                         -- encoder input as decoded bit
                     end loop;  
                   end if;
                 end if;
               end loop;  -- c
             elsif set_pmetrics_from_child1 = '1' then
               for a in 0 to nmax-1 loop
                 if path_used_child1(a) = '1' then
                   if valid(a) = '0' then
                     for i in 0 to tl-1 loop
                       if current_column_onehot(i) = '1' then
                         memory(a)(i) <= survivor_nextstate1(a)(k-1);  --doubt     
                       end if;
                     end loop;  -- i
                   end if;
                 end if;
               end loop;  -- a

             -- If a new row is memory row is needed since both
             -- children survive, the "parent" survivor memory row is copied
             -- before the decoded bit is copied to survivor memory

             elsif set_pmetrics_new_row = '1' then
               for index in 0 to nmax-1 loop
                 if spare_row(index) = '1' then
                   for kk in 0 to nmax-1 loop
                     if used_row(kk) = '1' then
                       for i in 0 to tl-1 loop
                         if current_column_onehot(i) = '1' then    -- append decoded bit
                           memory(index)(i) <= survivor_nextstate1(kk)(k-1);
                         else                                  -- copy one bit from parent to child row
                           memory(index)(i) <= memory(kk)(i);
                         end if;
                       end loop;  -- i
                     end if;
                   end loop;
                 end if;
               end loop;
             end if;
           end if;
           end process update_memory;

-- This process determines which rows are "spare" and can be used to
-- store info for child1 if both child0 and child 1 survive. Note that
-- spare rows in the survivor memory occur if BOTH child paths from a
-- parent fail to meet the path metric threshold.

           -- purpose: y
           -- type   : sequential
           -- inputs : CPE_Pclk, CPE_Reset
           -- outputs: y
           updatey: process (CPE_Pclk, CPE_Reset)
           begin  -- process updatey
             if CPE_Reset = '1' then    -- asynchronous reset (active low)
               spare_row <= (others => '0');
             elsif CPE_Pclk'event and CPE_Pclk = '1' then  -- rising clock edge
               if reset_rows = '1' then
                 spare_row <= (others => '0');
               elsif set_spare_row = '1' then
                 for index in 0 to nmax-1 loop
                   if onehot_nmax3(index) = '1' then
                     if valid(index) = '0' then       -- If row not valid after 
                                                      -- initial pass then mark as spare
                       spare_row(index) <= '1';
                     end if;
                   end if;
                 end loop;
               end if;
             end if;
             end process updatey;

-- This process determines which rows are "used". A row is used if at
-- least one of the child states of a present state meets the threshold condition

           -- purpose: x
           -- type   : sequential
           -- inputs : CPE_Pclk, CPE_Reset
           -- outputs: x
           updatex: process (CPE_Pclk, CPE_Reset)
           begin  -- process updatey
             if CPE_Reset = '1' then    -- asynchronous reset (active low)
               used_row <= (others => '0');
             elsif CPE_Pclk'event and CPE_Pclk = '1' then  -- rising clock edge
               if reset_rows = '1' then
                 used_row <= (others => '0');
               elsif set_used_row = '1' then
                 for pop in 0 to nmax-1 loop
                   if onehot_nmax2(pop) = '1' then
                     if one_survived(pop) = '1' then   -- If a child survived, mark
                       used_row(pop) <= '1';
                     end if;
                   end if;
                 end loop;
               end if;
             end if;
             end process updatex;
           
-- This process is used to set "one_survived" values. This array
-- determines if a new row must be determined for child1 survivors. As
-- soon as an spare row is located, the "one_survived" value for the parent row
-- is deasserted

             -- purpose: update one_survived
             -- type   : sequential
             -- inputs : CPE_Pclk, CPE_Reset
             -- outputs: one_survived
             update_one_survived: process (CPE_Pclk, CPE_Reset)
             begin  -- process update_one_survived
               if CPE_Reset = '1' then  -- asynchronous reset (active low)
                 one_survived <= (others => '0');
               elsif CPE_Pclk'event and CPE_Pclk = '1' then  -- rising clock edge
                 if set_pmetrics_from_child1 = '1' then
                   for a in 0 to nmax-1 loop
                     if path_used_child1(a) = '1' then    -- If row already used, mark 
                       if valid(a) = '1' then
                         one_survived(a) <= '1';
                       end if;
                     end if;
                   end loop;  -- a
                 elsif set_pmetrics_new_row = '1' then
                   for index in 0 to nmax-1 loop
                     if spare_row(index) = '1' then    -- Located spare row so unmark "one_survived" row
                       for kk in 0 to nmax-1 loop
                         if used_row(kk) = '1' then
                           one_survived(kk) <= '0';
                         end if;
                       end loop;
                     end if;
                   end loop;
                 end if;
               end if;
             end process update_one_survived;

-- The following processes are used to sort the path metrics of the
-- surviving paths to locate the minimum cost metric (dm).
-- ** Note that this code needs to be changed for each changed K value.
--    Each of the following processes sorts half the values in
--    parallel. The size of the sorting circuitry grows as log2(Nmax)

-- For process min1, determine if either child 0 or child 1 has a
-- smaller path metric for each of Nmax rows.

             -- purpose: min1
             -- type   : sequential
             -- inputs : CPE_Pclk, CPE_Reset
             -- outputs: min1
             min1_update: process (CPE_Pclk, CPE_Reset)
             begin  -- process min1_update
               if CPE_Reset = '1' then  -- asynchronous reset (active low)
--                 min1 <= (others => "000000");
                 min1 <= (others => (others => '0'));
               elsif CPE_Pclk'event and CPE_Pclk = '1' then  
                 if set_min1 = '1' then
                   for j in 0 to nmax-1 loop
                     if survivor_pmetric0(j) < survivor_pmetric1(j) then
                       min1(j) <= survivor_pmetric0(j);
                     else
                       min1(j) <= survivor_pmetric1(j);
                     end if;
                   end loop;
                 end if;
               end if;                  -- rising clock edge
             end process min1_update;

-- For process min2, compare the top half of the min1 array to the
-- bottom half. Store the smaller values in min2 for each comparison.
-- The row1 array indicates for each comparison if the smaller value
-- came from the top or bottom half of the array.
-- * Russ: verify the '11' in the following code and include a parameter.

             -- purpose: min2
             -- type   : sequential
             -- inputs : CPE_Pclk, CPE_Reset
             -- outputs: min2
             min2_update: process (CPE_Pclk, CPE_Reset)
             begin  -- process min2_update
               if CPE_Reset = '1' then  -- asynchronous reset (active low)
                 min2 <= (others => (others => '0'));
                 row1 <= (others => (others => '0'));
                 -- min2 <= (others => "000000");
                 -- row1 <= (others => "000000000000000000000000");
               elsif CPE_Pclk'event and CPE_Pclk = '1' then  
                 if set_min2 = '1' then
                   for j in 0 to nmaxd2-1 loop               -- break array in 2
                     if min1(j) < min1(nmax-1-j) then
                       min2(j) <= min1(j);
                       row1(j)(j) <= '1';
                     else
                       min2(j) <= min1(nmax-1-j);
                       row1(j)(nmax-1-j) <= '1';
                     end if;
                   end loop;  -- j
                 elsif reset_row = '1' then
                   row1 <= (others => (others => '0'));
                   -- row1 <= (others => "000000000000000000000000");
                 end if;
               end if;
             end process min2_update;

-- For process min3, compare the top half of the min2 array to the
-- bottom half. Store the smaller values in min3 for each comparison.
-- The row2 array indicates for each comparison if the smaller value
-- came from the top or bottom half of the array.
-- * Russ: Come up with a way to remove the constants from the
--   following code.

             -- purpose: min3 update
             -- type   : sequential
             -- inputs : CPE_Pclk, CPE_Reset
             -- outputs: min3
             min3_update: process (CPE_Pclk, CPE_Reset)
             begin  -- process min3_update
               if CPE_Reset = '1' then  -- asynchronous reset (active low)
                 min3 <= (others => (others => '0'));
                 row2 <= (others => (others => '0'));
                 -- min3 <= (others => "000000");
                 -- row2 <= (others => "000000000000000000000000");
               elsif CPE_Pclk'event and CPE_Pclk = '1' then  
                 if set_min3 = '1' then
                   for j in 0 to nmaxd4-1 loop
                     if min2(j) < min2(nmaxd2-1-j) then
                       min3(j) <= min2(j);
                       row2(j) <= row1(j);
                     else
                       min3(j) <= min2(nmaxd2-1-j);
                       row2(j) <= row1(nmaxd2-1-j);
                     end if;
                   end loop;  -- j
                 elsif reset_row = '1' then
                   row2 <= (others => (others => '0'));
                  -- row2 <= (others => "000000000000000000000000");
                 end if;
               end if;
             end process min3_update;

-- For process min4, compare the top half of the min3 array to the
-- bottom half. Store the smaller values in min4 for each comparison.
-- The row3 array indicates for each comparison if the smaller value
-- came from the top or bottom half of the array.
-- * Russ: Come up with a way to remove the constants from the
--   following code.

             -- purpose: min4 update
             -- type   : sequential
             -- inputs : CPE_Pclk, CPE_Reset
             -- outputs: min4
             min4_update: process (CPE_Pclk, CPE_Reset)
             begin  -- process min3_update
               if CPE_Reset = '1' then  -- asynchronous reset (active low)
                 min4 <= (others => (others => '0'));
                 row3 <= (others => (others => '0'));
                 -- min4 <= (others => "000000");
                 -- row3 <= (others => "000000000000000000000000");
               elsif CPE_Pclk'event and CPE_Pclk = '1' then  
                 if set_min4 = '1' then
                   for j in 0 to nmaxd6-1 loop
                     if min3(j) < min3(nmaxd4-1-j) then
                       min4(j) <= min3(j);
                       row3(j) <= row2(j);
                     else
                       min4(j) <= min3(nmaxd4-1-j);
                       row3(j) <= row2(nmaxd4-1-j);
                     end if;
                   end loop;  -- j
                 elsif reset_row = '1' then
                   row3 <= (others => (others => '0'));
                   -- row3 <= (others => "000000000000000000000000");
                 end if;
               end if;
             end process min4_update;
             
-- For process min5, compare the top half of the min4 array to the
-- bottom half. Store the smaller values in min5 for each comparison.
-- The row4 array indicates for each comparison if the smaller value
-- came from the top or bottom half of the array.
-- * Russ: Come up with a way to remove the constants from the
--   following code.

             -- purpose: min5 update
             -- type   : sequential
             -- inputs : CPE_Pclk, CPE_Reset
             -- outputs: min5
             min5_update: process (CPE_Pclk, CPE_Reset)
             begin  -- process min3_update
               if CPE_Reset = '1' then  -- asynchronous reset (active low)
                 min5 <= (others => (others => '0'));
                 row4 <= (others => (others => '0'));
                 -- min5 <= (others => "000000");
                 -- row4 <= (others => "000000000000000000000000");
               elsif CPE_Pclk'event and CPE_Pclk = '1' then  
                 if set_min5 = '1' then
                   for j in 0 to nmaxd12-1 loop
                     if min4(j) < min4(nmaxd6-1-j) then
                       min5(j) <= min4(j);
                       row4(j) <= row3(j);
                     else
                       min5(j) <= min4(nmaxd6-1-j);
                       row4(j) <= row3(nmaxd6-1-j);
                     end if;
                   end loop;  -- j
                 elsif reset_row = '1' then
                   row4 <= (others => (others => '0'));
                   -- row4 <= (others => "000000000000000000000000");
                 end if;
               end if;
             end process min5_update;
           
-- By using the min5 and row4 arrays it is possible to determine the
-- smallest resulting path metric and the row of its parent in the
-- survivor memory
  
             -- purpose: dm
             -- type   : sequential
             -- inputs : CPE_Pclk, CPE_Reset
             -- outputs: dm
             dm_update: process (CPE_Pclk, CPE_Reset)
             begin  -- process min2_update
               if CPE_Reset = '1' then  -- asynchronous reset (active low)
                 dm <= (others => '0');
                 -- dm <= "000000";
                 min_pmetric_row <= (others => '0');
               elsif CPE_Pclk'event and CPE_Pclk = '1' then  
                 if set_dm = '1' then
                   if min5(0) < min5(1) then
                     dm <= min5(0);
                     min_pmetric_row <= row4(0);  
                   else
                     dm <= min5(1);
                     min_pmetric_row <= row4(1);
                   end if;
                 elsif reset_dm = '1' then
                   dm <= (others => '0');
                   -- dm <= "000000";
                   min_pmetric_row <= (others => '0');
                 end if;
               end if;
             end process dm_update;

-- Write a decoded output bit from the survivor memory to the output
-- fifo. Note the loop to determine which column is currently being
-- accessed in the survivor memory. The output bit comes from the
-- column immediately to the right of the column being written.

             -- purpose: fifo output
             -- type   : sequential
             -- inputs : CPE_Pclk, CPE_Reset
             -- outputs: fifo
             fifowrite: process (CPE_Pclk, CPE_Reset)
             begin  -- process fifowrite
               if CPE_Reset = '1' then  -- asynchronous reset (active low)
                 CPE_PeToHostFifoData_Out(0) <= '0';
               elsif CPE_Pclk'event and CPE_Pclk = '1' then  
                 if set_fifo_out = '1' then
                   if current_column_onehot(tl-1) = '0' then
                     for jj in 0 to tl-2 loop
                       if current_column_onehot(jj) = '1' then
                         for mmm in 0 to nmax-1 loop
                           if min_pmetric_row(mmm) = '1' then
                             CPE_PeToHostFifoData_Out(0) <= memory(mmm)(jj+1);
                           end if;
                         end loop;  -- mmm
                       end if;
                     end loop;
                   else
                     for mmm in 0 to nmax-1 loop   -- Is output row the first row
                       if min_pmetric_row(mmm) = '1' then
                         CPE_PeToHostFifoData_Out(0) <= memory(mmm)(0);
                       end if;
                     end loop;  -- mmm
                   end if;
                 end if;
               end if;
             end process fifowrite;
               
-- Set the path metrics of the child0 survivors after comparison to dm + T
-- This can occur under two circumstances as indicated by the 2 elsif expressions below
-- 1. A path metric comparison using the initial T or an decremented T
-- 2. A path metric comparison using an incremented T

             survivor_pmetric0_update: process (CPE_Pclk, CPE_Reset)
             begin  -- process survivor_pmetric0_update
               if CPE_Reset = '1' then  -- asynchronous reset (active low)
                 survivor_pmetric0 <= (others => (others => '1'));
                 -- survivor_pmetric0 <= (others => "111111");
               elsif CPE_Pclk'event and CPE_Pclk = '1' then  
                  if reset_child_info = '1' then
                    survivor_pmetric0 <= (others => "111111");
                  elsif evaluate_child0_initial = '1' then
                    for i in 0 to nmax-1 loop
                      if onehot_nmax0(i) = '1' then
                        if valid(i) = '1' then
                          if initial_pmetric0(i) < T then
                            survivor_pmetric0(i) <= initial_pmetric0(i);
                          else
                            survivor_pmetric0(i) <= (others => '1');
                          end if;
                        end if;
                      end if;
                    end loop;
                  elsif evaluate_child0_incrementT = '1' then
                    for i in 0 to nmax-1 loop
                      if onehot_nmax1(i) = '1' then
                        if valid(i) = '1' then
                          if initial_pmetric0(i) < T then
                            survivor_pmetric0(i) <= initial_pmetric0(i);
                          else
                            survivor_pmetric0(i) <= (others => '1');
                            -- survivor_pmetric0(i) <= "111111";
                          end if;
                        end if;
                      end if;
                    end loop;
                  end if;
               end if;
             end process survivor_pmetric0_update;

-- Set the path metrics of the child1 survivors after comparison to dm + T
-- This can occur under two circumstances as indicated by the 2 elsif expressions below
-- 1. A path metric comparison using the initial T or an decremented T
-- 2. A path metric comparison using an incremented T

             survivor_pmetric1_update: process (CPE_Pclk, CPE_Reset)
             begin  -- process survivor_pmetric0_update
               if CPE_Reset = '1' then  -- asynchronous reset (active low)
                 survivor_pmetric1 <= (others => (others => '1'));
                 -- survivor_pmetric1 <= (others => "111111");
               elsif CPE_Pclk'event and CPE_Pclk = '1' then  
                  if reset_child_info = '1' then
                    survivor_pmetric1 <= (others => "111111");
                  elsif evaluate_child1_initial = '1' then
                    for i in 0 to nmax-1 loop
                      if onehot_nmax0(i) = '1' then
                        if valid(i) = '1' then
                          if initial_pmetric1(i) < T then
                            survivor_pmetric1(i) <= initial_pmetric1(i);
                          else
                            survivor_pmetric1(i) <= (others => '1');
                          end if;
                        end if;
                      end if;
                    end loop;
                  elsif evaluate_child1_incrementT = '1' then
                    for i in 0 to nmax-1 loop
                      if onehot_nmax1(i) = '1' then
                        if valid(i) = '1' then
                          if initial_pmetric1(i) < T then
                            survivor_pmetric1(i) <= initial_pmetric1(i);
                          else
                            survivor_pmetric1(i) <= (others => '1');
                            -- survivor_pmetric1(i) <= "111111";
                          end if;
                        end if;
                      end if;
                    end loop;
                  end if;
               end if;
             end process survivor_pmetric1_update;

-- Determine which child0 paths meet the dm + T threshold. The corresponding bit in 
-- path_used_child0 is set if the path is preserved.
-- This can occur under two circumstances as indicated by the 3 elsif expressions below
-- 1. A path metric comparison using the initial T or an decremented T
-- 2. A path metric comparison using an incremented T
-- 3. A path is moved to a spare row since both children survive

             path0_update: process (CPE_Pclk, CPE_Reset)
             begin  -- process survivor_pmetric0_update
               if CPE_Reset = '1' then  -- asynchronous reset (active low)
                 path_used_child0 <= (others => '0');
               elsif CPE_Pclk'event and CPE_Pclk = '1' then  
                  if reset_child_info = '1' then
                     path_used_child0 <= (others => '0');
                  elsif evaluate_child0_initial = '1' then
                    for i in 0 to nmax-1 loop
                      if onehot_nmax0(i) = '1' then
                        if valid(i) = '1' then
                          if initial_pmetric0(i) < T then
                            path_used_child0(i) <= '1';
                          else
                            path_used_child0(i) <= '0';
                          end if;
                        end if;
                      end if;
                    end loop;
                  elsif evaluate_child0_incrementT = '1' then
                    for i in 0 to nmax-1 loop
                      if onehot_nmax1(i) = '1' then
                        if valid(i) = '1' then
                          if initial_pmetric0(i) < T then
                            path_used_child0(i) <= '1';
                          else
                            path_used_child0(i) <= '0';
                          end if;
                        end if;
                      end if;
                    end loop;
                  elsif move_child1_to_child0 = '1' then   -- This previously spare row now has 
                    for index in 0 to nmax-1 loop          -- a child1 assigned to it 
                      if spare_row(index) = '1' then
                        if path_used_child0(index) = '0' then
                          path_used_child0(index) <= '1';
                        end if;
                      end if;
                    end loop;
                  end if;
               end if;
             end process path0_update;

-- Determine which child1 paths meet the dm + T threshold. The corresponding bit in 
-- path_used_child1 is set if the path is preserved.
-- This can occur under two circumstances as indicated by the 3 elsif expressions below
-- 1. A path metric comparison using the initial T or an decremented T
-- 2. A path metric comparison using an incremented T
-- 3. A path is moved to a spare row since both children survive

             path1_update: process (CPE_Pclk, CPE_Reset)
             begin  -- process survivor_pmetric0_update
               if CPE_Reset = '1' then  -- asynchronous reset (active low)
                 path_used_child1 <= (others => '0');
               elsif CPE_Pclk'event and CPE_Pclk = '1' then  
                  if reset_child_info = '1' then
                     path_used_child1 <= (others => '0');
                  elsif evaluate_child1_initial = '1' then
                    for i in 0 to nmax-1 loop
                      if onehot_nmax0(i) = '1' then
                        if valid(i) = '1' then
                          if initial_pmetric1(i) < T then
                            path_used_child1(i) <= '1';
                          else
                            path_used_child1(i) <= '0';
                          end if;
                        end if;
                      end if;
                    end loop;
                  elsif evaluate_child1_incrementT = '1' then
                    for i in 0 to nmax-1 loop
                      if onehot_nmax1(i) = '1' then
                        if valid(i) = '1' then
                          if initial_pmetric1(i) < T then
                            path_used_child1(i) <= '1';
                          else
                            path_used_child1(i) <= '0';
                          end if;
                        end if;
                      end if;
                    end loop;
                  elsif move_child1_to_child0 = '1' then         -- Value will now be stored as child1 in a spare row
                    for kk in 0 to nmax-1 loop
                      if used_row(kk) = '1' then
                        path_used_child1(kk) <= '0';
                      end if;
                    end loop;
                  end if;
               end if;
             end process path1_update;

-- Set the next state of the child0 survivors after comparison to dm + T
-- This can occur under two circumstances as indicated by the 2 elsif expressions below
-- 1. A path metric comparison using the initial T or an decremented T
-- 2. A path metric comparison using an incremented T

             survivor_nextstate0_update: process (CPE_Pclk, CPE_Reset)
             begin  -- process survivor_pmetric0_update
               if CPE_Reset = '1' then  -- asynchronous reset (active low)
                 survivor_nextstate0 <= (others => (others => '0'));
                 -- survivor_nextstate0 <= (others => "0000000000");
               elsif CPE_Pclk'event and CPE_Pclk = '1' then  
                 if evaluate_child0_initial = '1' then
                    for i in 0 to nmax-1 loop
                      if onehot_nmax0(i) = '1' then
                        if valid(i) = '1' then
                          if initial_pmetric0(i) < T then
                            survivor_nextstate0(i) <= next_state0(i);
                          else
                            survivor_nextstate0(i) <= (others => '0');
                            -- survivor_nextstate0(i) <= "0000000000";
                          end if;
                        end if;
                      end if;
                    end loop;
                 elsif evaluate_child0_incrementT = '1' then
                    for i in 0 to nmax-1 loop
                      if onehot_nmax1(i) = '1' then
                        if valid(i) = '1' then
                          if initial_pmetric0(i) < T then
                            survivor_nextstate0(i) <= next_state0(i);
                          else
                            survivor_nextstate0(i) <= (others => '0');
                            -- survivor_nextstate0(i) <=  "0000000000";
                          end if;
                        end if;
                      end if;
                    end loop;
                 end if;
               end if;
             end process survivor_nextstate0_update;

-- Set the next state of the child1 survivors after comparison to dm + T
-- This can occur under two circumstances as indicated by the 2 elsif expressions below
-- 1. A path metric comparison using the initial T or an decremented T
-- 2. A path metric comparison using an incremented T

             survivor_nextstate1_update: process (CPE_Pclk, CPE_Reset)
             begin  -- process survivor_pmetric0_update
               if CPE_Reset = '1' then  -- asynchronous reset (active low)
                 survivor_nextstate1 <= (others => (others => '0'));
                 -- survivor_nextstate1 <= (others => "0000000000");
               elsif CPE_Pclk'event and CPE_Pclk = '1' then  
                 if evaluate_child1_initial = '1' then
                    for i in 0 to nmax-1 loop
                      if onehot_nmax0(i) = '1' then
                        if valid(i) = '1' then
                          if initial_pmetric1(i) < T then
                            survivor_nextstate1(i) <= next_state1(i);
                          else
                            survivor_nextstate1(i) <= (others => '0');
                            -- survivor_nextstate1(i) <=  "0000000000";
                          end if;
                        end if;
                      end if;
                    end loop;
                 elsif evaluate_child1_incrementT = '1' then
                    for i in 0 to nmax-1 loop
                      if onehot_nmax1(i) = '1' then
                        if valid(i) = '1' then
                          if initial_pmetric1(i) < T then
                            survivor_nextstate1(i) <= next_state1(i);
                          else
                            survivor_nextstate1(i) <= (others => '0');
                            -- survivor_nextstate1(i) <= "0000000000";
                          end if;
                        end if;
                      end if;
                    end loop;
                 end if;
               end if;
             end process survivor_nextstate1_update;
             
-- State machine process. This process controls the operation of the AVA decoder on a 
-- cycle by cycle basis.

             CPE_PeToHostFifoData_Out(35 downto 1) <= (others => '0');
               
                      process (present_state,CPE_HosttoPeFifoEmpty_n,next_state1,next_state0,T,
                      onehot_nmax0,current_column_onehot,
                      onehot_nmax1,current_column,onehot_nmax3,onehot_nmax2,initial_pmetric1,
                      initial_pmetric0,count,one_survived,valid,initial,final)

    begin  -- process
           CPE_Fifo_WE_n <= '1';
           CPE_FifoPtrIncr_EN <= '0';
           CPE_PeToHostFifoData_OE <= (others => '0');
           calc_bm <= '0';
           inc_T <= '0';
           dec_T <= '0';
           reset_T <= '0';
           inc_column_onehot <= '0';
           inc_column <= '0';
           reset_column_onehot <= '0';
           reset_column <= '0';
           inc_add <= '0';
           inc_onehot_nmax1 <= '0';
           reset_onehot_nmax1 <= '0';
           reset_onehot_nmax0 <= '0';
           inc_onehot_nmax0 <= '0';
           reset_count <= '0';
           inc_count <= '0';
           test_variable <= '0';
           test_variable0 <= '0';
           reset_onehot_nmax2 <= '0';
           inc_onehot_nmax2 <= '0';
           reset_onehot_nmax3 <= '0';
           inc_onehot_nmax3 <= '0';
           norm_metric <= '0';
           set_encoder_bit2_output <= '0';
           set_encoder_output <= '0'; 
           set_next_state <= '0';
           read_quant_input <= '0';
           set_pmetrics_from_child0 <= '0';
           set_pmetrics_from_child1 <= '0';
           set_pmetrics_new_row <= '0';
           reset_valid <= '0';
           reset_rows <= '0';
           set_used_row <= '0';
           set_spare_row <= '0';
           set_min1 <= '0';
           set_min2 <= '0';
           set_min3 <= '0';
           set_min4 <= '0';
           set_min5 <= '0';
           set_dm <= '0';
           reset_dm <= '0';
           reset_min_pmetric_row <= '0';
           set_min_pmetric_row <= '0';
           set_fifo_out <= '0';
           reset_child_info <= '0';
           evaluate_child0_initial <= '0';
           evaluate_child0_incrementT <= '0';
           evaluate_child1_initial <= '0';
           evaluate_child1_incrementT <= '0';
           move_child1_to_child0 <= '0';
           reset_row <= '0';
           reset_nextstates <= '0';
           
     case present_state is

       when reset_state =>  -- reset various parameters after data is read
           next_state <= Read1;
           reset_column_onehot <= '1';
           reset_min_pmetric_row <= '1';
           reset_nextstates <= '1';

       when Read1 =>  -- Loop until channel data values available at FIFO output

         if CPE_HosttoPeFifoEmpty_n = '1' then
           CPE_FifoPtrIncr_EN <= '1';
           next_state <= Read2;
         else
           CPE_FifoPtrIncr_EN <= '0';
           next_state <= Read1;
         end if;
         reset_min_pmetric_row <= '1';
         reset_rows <= '1';  

       when Read2 => -- Read the input values
           read_quant_input <= '1';
           next_state <= s1;
                     
        when s1 =>
           calc_bm <= '1';    -- calculate the branch metric
           reset_dm <= '1';   -- reset minimum path metric
           reset_row <= '1';
           next_state <= s2;
           reset_child_info <= '1';
           set_encoder_bit2_output <= '1';
           

        when s2 =>
           set_encoder_output <= '1';  -- determine nextstate and output for each trellis state
           set_next_state <= '1'; 
           next_state <= s3;
           inc_add <= '1';             -- Set the path metrics
           reset_onehot_nmax0 <= '1';  -- reset a one hot index
           reset_count <= '1';

       when s3 =>  -- dummy state
         next_state <= evaluate_child0;

       when evaluate_child0 =>   -- For child 0 values, set path metrics and compare to dm + T
         evaluate_child0_initial <= '1';
         for i in 0 to nmax-1 loop
           if onehot_nmax0(i) = '1' then
             if valid(i) = '1' then              -- Is present state parent valid?
               if initial_pmetric0(i) < T then   -- Check child 0 against threshold
                 inc_count <= '1';               -- increment survivor path count.
               else
                 inc_count <= '0';
               end if;
             end if;
           end if;
         end loop;
         next_state <= evaluate_child1;
           
       when evaluate_child1 =>   -- For child 1 values, set path metrics and compare to dm + T
           evaluate_child1_initial <= '1';  
           for i in 0 to nmax-1 loop
             if onehot_nmax0(i) = '1' then
               if valid(i) = '1' then             -- Is present state parent valid?
                 if initial_pmetric1(i) < T then  -- Check child 0 against threshold
                   inc_count <= '1';              -- increment survivor path count.
                 else
                   inc_count <= '0';
                 end if;
               end if;                            
             end if;
           end loop;
           if onehot_nmax0(nmax-1) = '1' then     -- Have all present states been evaluated?
             next_state <= dummy1;                -- Go to evaluation
           else
             inc_onehot_nmax0 <= '1';             -- Else, evaluate next state
             next_state <= s3;
           end if;
         
      when dummy1 =>
          next_state <= evaluate_count;

      when evaluate_count =>                      -- Evaluate the number of survivors
         if count > nmax then                     -- If too many survivors, reduce T and reevaluate
           dec_T <= '1';
           next_state <= s2;
         elsif count = 0 then                     -- If no survivors, increment T and reevaluate
           inc_T <= '1';
           next_state <= dummy0;
           reset_onehot_nmax1 <= '1';
           reset_count <= '1';
         else
           next_state <= sort_step1;              -- Move on to sorting to determine dm
         end if;

       when dummy0 =>                             -- dummy state
           next_state <= evaluate_child0_incT;

       -- This case really should never happen if T is set correctly
       when evaluate_child0_incT =>               -- Following incrementation of T reevaluate path metrics
         evaluate_child0_incrementT <= '1';
           for i in 0 to nmax-1 loop
             if onehot_nmax1(i) = '1' then
               if valid(i) = '1' then
                 if initial_pmetric0(i) < T then
                   inc_count <= '1';
                 else
                   inc_count <= '0';
                 end if;
               end if;
             end if;
           end loop;
           if onehot_nmax1(nmax-1) = '0' then
             if nmax-2 > count then                 -- Have fewer than Nmax paths been found?
               next_state <= evaluate_child1_incT;  -- evaluate child1 paths
             else
               next_state <= sort_step1;            -- else go to sorting
             end if;
           else
             next_state <= sort_step1;
           end if;
           
       when evaluate_child1_incT =>                 -- Evaluate child 1 paths after T is incremented
         evaluate_child1_incrementT <= '1';
           for i in 0 to nmax-1 loop
             if onehot_nmax1(i) = '1' then
               if valid(i) = '1' then
                 if initial_pmetric1(i) < T then
                   inc_count <= '1';
                 else
                   inc_count <= '0';
                 end if;
               end if;                      
             end if;
           end loop;
           inc_onehot_nmax1 <= '1';  
         
         if onehot_nmax1(nmax-1) = '0' then         -- Keep evaluating child 1 paths until nmax-2 paths found
           if nmax-2 > count then
             next_state <= dummy0;
           else
             next_state <= sort_step1;
           end if;
         else
           next_state <= sort_step1;
         end if;

       -- These steps allow a sort-based search for the lowest cost path metric.

       when sort_step1 =>   
         set_min1 <= '1';
         next_state <= sort_step2;

       when sort_step2 =>
         set_min2 <= '1';
         next_state <= sort_step3;

       when sort_step3 =>
         set_min3 <= '1';
         next_state <= sort_step4;
                 
       when sort_step4 =>
         set_min4 <= '1';
         next_state <= sort_step5;

       when sort_step5 =>
         set_min5 <= '1';
         next_state <= evaluate_dm;
         
       -- This step sets the lowest path metric among the child states.
       -- This value is used to set the threshold during the next decode iteration

       when evaluate_dm =>
        set_dm <= '1';
        next_state <= s7;
        reset_valid <= '1';

       -- evaluate valid bits and path metrics

     
       -- Move values from child0 array to survivor arrays (valid, memory row, path metrics)
       when s7 =>
        set_pmetrics_from_child0 <= '1';
        next_state <= dummy2;

       when dummy2 =>
         next_state <= s8;

       -- Move values from child0 array to survivor arrays (valid, memory row, path metrics)
       when s8 =>
         next_state <= dummy3;
	 reset_onehot_nmax2 <= '1';
         set_pmetrics_from_child1 <= '1';

       when dummy3 =>
           next_state <= assign_child1_test;
         
       -- Keep looping until all children have been placed in one of Nmax locations.
       -- If both children survive, the child 1 values need to be assigned to a spare row, 
       -- The following states loop until all child 1 values are assigned to a row and 
       -- corresponding valid, path metric, and survivor memory values have been set.

       when assign_child1_test =>
         if one_survived = "0" then
         -- if one_survived = (others => '0') then
           next_state <= dummy4;
         else
           next_state <= assign_child1_step1;
	   reset_onehot_nmax3 <= '1';
         end if;

       when assign_child1_step1 =>                   -- copy memory row if already updated
           set_used_row <= '1';
           for pop in 0 to nmax-1 loop
             if onehot_nmax2(pop) = '1' then
               if one_survived(pop) = '1' then       -- Has this location (pop) not been assigned?
                 test_variable <= '1';
               end if;
             end if;
           end loop;  -- pop
           next_state <= assign_child1_step2;

       when assign_child1_step2 =>
           if test_variable = '1' then
              next_state <= assign_child1_step3;  -- If so, go to assign them
           else 
              if onehot_nmax2(nmax-1) = '0' then  -- Not at end of array
                inc_onehot_nmax2 <= '1';          -- Move to evaluate next child1 value
                next_state <= dummy9; 
              else
                next_state <= dummy4;             -- If all assigned, terminate
                reset_column <= '1';
              end if;
           end if;
           test_variable <= '0';

       when dummy9 =>
           next_state <= assign_child1_step1;

--       when assign_child1_step1 =>                       -- copy memory row if already updated
--           set_used_row <= '1';
--           for pop in 0 to nmax-1 loop
--             if onehot_nmax2(pop) = '1' then
--               if one_survived(pop) = '1' then       -- Has this location (pop) not been assigned?
--                 next_state <= assign_child1_step3;  -- If so, go to assign them
--               else
--                 if onehot_nmax2(nmax-1) = '0' then  -- Not at end of array
--                   inc_onehot_nmax2 <= '1';          -- Move to evaluate next child1 value
--                   next_state <= assign_child1_step2; 
--                 else
--                   next_state <= dummy4;             -- If all assigned, terminate
--                   reset_column <= '1';
--                 end if;
--               end if;
--             end if;
--           end loop;  -- pop

--       when assign_child1_step2 =>
--           next_state <= assign_child1_step1;
                      

      when assign_child1_step3 =>                   -- assign child 1 info to a spare row
           set_spare_row <= '1';
           for index in 0 to nmax-1 loop
             if onehot_nmax3(index) = '1' then
               if valid(index) = '0' then            -- Is this row valid yet?
                 test_variable0 <= '1';
               end if;
             end if;
           end loop;  -- index
           next_state <= dummy8;

       when dummy8 =>
           if test_variable0 = '1' then            -- Is this row valid yet?
              next_state <= assign_child1_step4;   -- If no, assign it
           else
              next_state <= dummy10;               -- else iterate
              inc_onehot_nmax3 <= '1';
           end if;
           test_variable0 <= '0';

       when dummy10 =>
           next_state <= assign_child1_step3;

--      when assign_child1_step3 =>                   -- assign child 1 info to a spare row
--           set_spare_row <= '1';
--           for index in 0 to nmax-1 loop
--             if onehot_nmax3(index) = '1' then
--               if valid(index) = '0' then            -- Is this row valid yet?
--                 next_state <= assign_child1_step4;  -- If no, assign it
--               else
--                 next_state <= dummy8;               -- else iterate
--                 inc_onehot_nmax3 <= '1';
--               end if;
--             end if;
--           end loop;  -- index
          
--       when dummy8 =>
--           next_state <= assign_child1_step3;

       when assign_child1_step4 =>                   -- Assignment of child 1 to new row complete
           move_child1_to_child0 <= '1';
           set_pmetrics_new_row <= '1';
           if onehot_nmax2(nmax-1) = '0' then        -- Still more rows to evaluate?
             next_state <= assign_child1_step1;      -- Go to evaluate next child1
             inc_onehot_nmax2 <= '1';
             reset_rows <= '1';
           else
             next_state <= dummy4;                   
             reset_column <= '1';
           end if;

       when dummy4 =>                                -- dummy state
         next_state <= fifo_write;
         set_min_pmetric_row <= '1';

       when fifo_write =>                            -- write output bit to fifo 
         if initial = '0' then                       -- location pointed to by current_column
           set_fifo_out <= '1';
         end if;

	 if (final = '1') then                       
	   next_state <= increment_column;
	 else
	   next_state <= complete_write;             
	 end if;

       -- Do some housekeeping for the final write
       when increment_column =>                      
          if current_column_onehot(tl-1) = '0' then
            inc_column_onehot <= '1';
          else
            reset_column_onehot <= '1';
          end if;
          if initial = '0' then
            CPE_Fifo_WE_n <= '0';
            CPE_FifoPtrIncr_EN <= '1';
            CPE_PeToHostFifoData_OE <= (others => '1');
          end if;

          if (current_column < tl - 1) then
            inc_column <= '1';
	    next_state <= dummy5;
	  else
            reset_column <= '1';
	    next_state <= complete_write;
	  end if;


       when dummy5 =>
         next_state <= fifo_write;
         
       when complete_write =>
         if initial = '0' then
           CPE_Fifo_WE_n <= '0';
           CPE_FifoPtrIncr_EN <= '1';
           CPE_PeToHostFifoData_OE <= (others => '1');
         end if;
         reset_T <= '1';    
         inc_column_onehot <= '1';           -- point to the next column
         reset_rows <= '1';
         reset_min_pmetric_row <= '1';     
         norm_metric <=  '1';                -- normalize path metrics
         if final = '1' then
           next_state <= dummy6;             -- loop once data retrieval is complete
         else
           next_state <= Read1;
         end if;

       when dummy6 =>
         next_state <= dummy7;  
             
       when dummy7 =>
         next_state <= dummy7;

       when others =>
         next_state <= reset_state;
     end case;    


    end process;

end behavior;









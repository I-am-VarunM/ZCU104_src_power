---------------------------------------------------------------------
--
-- PWM driver for B.0 fabric characterisation benchmark
--
-- pulse length = 1 s
-- pulse with adjustable from 0% to 100%
--
-- version:  1.0
-- date:     27.8.08
--
---------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.all;

-- library unisim;
-- use unisim.vcomponents.all;


entity pwm_driver is
   generic(clk_freq : integer := 100000000); -- 100MHz
   port (btn_on : in std_logic;      -- push button for permanently on
         btn_off : in std_logic;      -- push button for permanently off
         btn_up : in std_logic;       -- push button for increasing duty cycle
         btn_down : in std_logic;      -- push button for decreasing duty cycle
         led : out std_logic_vector(7 downto 0);  -- leds, bit 7: shows pusle out, bit 6-0: shows dudty cycle in binary
         pulse_out : out std_logic;       -- pulse out, drives FPGA under test
         clk : in std_logic);            -- clock in
end pwm_driver;


architecture Behavioral of pwm_driver is


component debounce
    generic(clk_freq : integer := 100000000);
    port (clk : in  std_logic;
         signal_in : in std_logic;
         debounce_out : out std_logic);
end component;


signal int_count         : integer range 0 to (clk_freq - 1) :=0;
signal duty_cycle        : integer range 0 to 100 :=0;
signal duty_cycle_v      : std_logic_vector(7 downto 0);
signal pulse_1hz         : std_logic;
signal btn_on_dbnc       : std_logic;
signal btn_off_dbnc      : std_logic;
signal btn_up_dbnc       : std_logic;
signal btn_down_dbnc     : std_logic;
signal btn_up_dbnc_del   : std_logic;
signal btn_down_dbnc_del : std_logic;



begin


-- debounce the push buttons

button_on_dbnc : debounce
   generic map(clk_freq => clk_freq)
   port map(clk => clk,
            signal_in => btn_on,
            debounce_out => btn_on_dbnc);
            
button_off_dbnc : debounce
   generic map(clk_freq => clk_freq)
   port map(clk => clk,
            signal_in => btn_off,
            debounce_out => btn_off_dbnc);
            
button_up_dbnc : debounce
   generic map(clk_freq => clk_freq)
   port map(clk => clk,
            signal_in => btn_up,
            debounce_out => btn_up_dbnc);
            
button_down_dbnc : debounce
   generic map(clk_freq => clk_freq)
   port map(clk => clk,
            signal_in => btn_down,
            debounce_out => btn_down_dbnc);


-- create pulses with 1s period and duty cycle from 0 to 100%

pulse_generate: process(clk)
  begin
    if clk'event and clk='1' then
    
      if btn_on_dbnc = '1' then  -- permanently on for button 'on'
         pulse_1hz <= '1';
      elsif btn_off_dbnc = '1' then   -- permanently off for button 'off'
         pulse_1hz <= '0';
      else    -- otherwise generate pulses

         if int_count < ((clk_freq / 100) * duty_cycle) then  -- on for (freq * duty/100) clock ticks
            pulse_1hz <= '1';
         else
            pulse_1hz <= '0';
         end if;

         if int_count = clk_freq - 1 then
            int_count <= 0;
         else
            int_count <= int_count + 1;
         end if;

      end if;

    end if; 
end process pulse_generate;


btn_delay : process(clk)
   begin
      if clk'event and clk = '1' then
         btn_up_dbnc_del <= btn_up_dbnc;
         btn_down_dbnc_del <= btn_down_dbnc;
      end if;
end process btn_delay;

-- adjust duty cycle with "up" and "down" buttons
             
duty_cycle_counter : process(clk)
   begin
      if clk'event and clk='1' then
         if btn_up_dbnc = '1' and btn_up_dbnc_del = '0' then    -- rising edge of button "up"
            if duty_cycle < 100 then   -- only count up to 100
               duty_cycle <= duty_cycle + 1;
            end if;
         elsif btn_down_dbnc = '1' and btn_down_dbnc_del = '0' then   -- rising edge of button "down"
            if duty_cycle > 0 then     -- only count down to 0
               duty_cycle <= duty_cycle - 1;
            end if;
         end if;
      end if;
end process duty_cycle_counter;


duty_cycle_v <= CONV_STD_LOGIC_VECTOR(duty_cycle, 8);


-- LEDs

led(7) <= pulse_1hz;     -- LED 7 shows pulse for visual verification
led(6 downto 0) <= duty_cycle_v(6 downto 0);  -- LED 6-0 show binary value of duty cycle


pulse_out <= pulse_1hz;


end Behavioral;



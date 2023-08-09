
-- debouncer


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.all;


entity debounce is
   generic(clk_freq : integer := 100000000);
   port (clk : in  std_logic;
         signal_in : in std_logic;
         debounce_out : out std_logic);
end debounce;


architecture Behavioral of debounce is

signal signal_in_sync : std_logic;
signal hysteresis : integer range 0 to (clk_freq / 100) :=0; -- 10ms 

begin

sync : process(clk)
   begin
      if clk'event and clk = '1' then
         signal_in_sync <= signal_in;
      end if;
end process;

debouce_p : process(clk)
   begin
      if clk'event and clk = '1' then
         if signal_in_sync = '1' then
            if hysteresis = (clk_freq / 100) then
               debounce_out <= '1';
            else
               hysteresis <= hysteresis + 1;
            end if;
         elsif signal_in_sync = '0' then
            if hysteresis = 0 then
               debounce_out <= '0';
            else
               hysteresis <= hysteresis - 1;
            end if;
         end if;
      end if;
end process;


end Behavioral;


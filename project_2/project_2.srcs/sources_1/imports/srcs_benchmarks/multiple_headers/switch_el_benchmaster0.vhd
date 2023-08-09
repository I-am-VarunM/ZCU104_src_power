library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- compile-time use only
use IEEE.MATH_REAL.all;

entity switch_elements is
   -- generic ( amount : integer := 16 );
    port ( enable_i : in STD_LOGIC_vector(31 downto 0);
           clk_i    : in std_logic;
           rst_i    : in std_logic;
           info_o : out STD_LOGIC_vector(31 downto 0)
         );
    
    attribute dont_touch : string;
    attribute dont_touch of switch_elements : entity is "true";
    
  
    
end switch_elements;

architecture bench0 of switch_elements is
component switch_elements0 is
   -- generic ( amount : integer := 16 );
    port ( enable_i : in STD_LOGIC_vector(31 downto 0);
           clk_i    : in std_logic;
           rst_i    : in std_logic;
           info_o : out STD_LOGIC_vector(31 downto 0)
         ); 
end component;
constant rep : integer := 3;
signal info_s : std_logic_vector (31 downto 0);
type   type_vector is array (0 to rep) of std_logic_vector(31 downto 0);
signal info_v : type_vector; 
signal enable_s : std_logic_vector(31 downto 0);

attribute dont_touch of activity_blocks : label is "true";
attribute dont_touch of info_s : signal is "true";
attribute dont_touch of info_v : signal is "true";

begin

    info_o <= info_s;
    
    activity_blocks : for i in 0 to rep generate
    begin
    switch: switch_elements0 port map (
           clk_i  => clk_i,
           rst_i => rst_i,
           enable_i => enable_s,
           info_o   => info_v(i)
    );
     --info_s <= info_s xor info_v(i);
    end generate;
    
    looper_process : process(clk_i)
    begin
         if rising_edge(clk_i) then
         for I in 0 to rep loop
             info_s <= info_s xor info_v(I);
         end loop;
    end if;
    end process;
    
    loop_process : process(clk_i)
    begin
         if rising_edge(clk_i) then
            if (rst_i = '1') then
               enable_s <= x"aaaa_aaaa";
            elsif (enable_i(0) = '1') then
               enable_s <= not enable_s;
            else 
               enable_s <= enable_s;
            end if;
         end if;
    end process;
    

end bench0;

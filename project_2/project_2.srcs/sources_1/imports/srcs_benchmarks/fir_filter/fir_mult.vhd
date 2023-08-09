-- RTL description of synthesizable multiplier.


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

----------------------- Entity Declaration -----------------------

entity lpm_mult0 is
	port
	(
		op1 : in unsigned ( 7 downto 0 );
		op2 : in unsigned ( 7 downto 0 );
		clk : in std_logic;
		res : out unsigned ( 15 downto 0 )
	);
end lpm_mult0;

-------------------------- Architecture Declaration --------------------------
architecture behavior of lpm_mult0 is

begin  

out_proc: process(clk)
begin
if rising_edge(clk) then
res <= op1*op2;
end if;
end process;

end behavior;









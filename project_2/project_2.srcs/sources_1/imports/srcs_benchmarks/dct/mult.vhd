-- RTL description of synthesizable multiplier.


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

----------------------- Entity Declaration -----------------------

entity lpm_mult is
	port
	(
		dataa : in unsigned ( 17 downto 0 );
		datab : in unsigned ( 17 downto 0 );
		result : out unsigned ( 18 downto 0 )
	);
end lpm_mult;

-------------------------- Architecture Declaration --------------------------
architecture behavior of lpm_mult is
signal res_sig : unsigned (35 downto 0);
begin  

result <= res_sig(18 downto 0);
res_sig <= dataa*datab;

end behavior;









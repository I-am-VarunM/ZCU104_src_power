---------------------------------------------------------------------
--
-- top level design for B.0 fabric characterisation benchmark
--
-- instantiates multiple random number generator cores and
-- connects output via xor chain to one output pin.
-- a clock buffer is used to switch RNGs on and off.
--
-- version:  1.0
-- date:     15.1.09
--
---------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;


entity top_level is
  generic (size : natural := 4);  -- number of RNGs, adjust accordingly
  port (
    clk : in std_logic;  -- clock in
    reset : in std_logic;  -- resets RNGs to initial state, not really needed for the benchmark
    enable : in std_logic;   -- switch RNGs on and off through clock buffer
    random_out : out std_logic;  -- output of xor chain
	 leds : out std_logic_vector(3 downto 0) -- LEDs for visual verification
  );
end top_level;

architecture STRUCTURE of top_level is


-- random number generator component
-- modify to use desired tap size
-- tap size should match LUT size of the target device

component rng_width512_taps4
	generic(
		init : std_logic_vector(511 downto 0)   -- do not initiate RNG with all zeros! any other value is fine
		);
	port(
		clk : in std_logic;
		reset : in std_logic;
		rng : out std_logic_vector(511 downto 0)
		);
end component;

-- clock buffer to control random number generator
-- modify to use appropriate clock buffer primitive of target device




signal clk_int : std_logic;     -- internal clock signal
signal reset_int : std_logic;    -- internal reset signal
signal enable_int : std_logic;    -- internal reset signal
type rng_out_array is array(size downto 1) of std_logic_vector(511 downto 0);
signal rng_out : rng_out_array;   -- array of RNG output vectors
signal rng_xor_chain :  std_logic_vector(size downto 0);  -- xor outputs of RNGs together, only one output bit per RNG is used




begin

-- modify and use appropriate clock buffer primitive of target device


   clk_int <= clk;
   
-- internal signals

reset_int <= reset;
enable_int <= enable;

-- start of xor chain

rng_xor_chain(0) <= '0'; 

-- generate RNGs and xor output bits together, one output bit per RNG is used to avoid
-- that the circuit is optimised away, each RNG is initialised with a different value to
-- avoid further optimisation
-- do not initiate RNG with "0", otherwise the circuit will be stuck in one state

rng_array : for i in 1 to size generate
begin
   
	rng: rng_width512_taps4
		generic map (
			init => conv_std_logic_vector(i, 512)
		)	
		port map(
			clk => clk_int,
			reset => reset_int,
			rng => rng_out(i)
		);

   rng_xor_chain(i) <=  rng_xor_chain(i-1) xor rng_out(i)(0);

end generate;

-- output last bit of chain

random_out <= rng_xor_chain(size);

-- additional LEDs to verify some of the internal signals, remove if not needed
leds(0) <= rng_xor_chain(size);
leds(1) <= enable_int;
leds(2) <= reset_int; 
leds(3) <= '0';


end;
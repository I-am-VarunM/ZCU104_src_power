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

architecture avaz of switch_elements is
component ava is
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
end component ava;

component pid is
	port
	(
		i_clk     : in std_logic;
		i_rst     : in std_logic;
		i_wb_cyc  : in std_logic;
		i_wb_stb  : in std_logic;
		i_wb_we   : in std_logic;
		i_wb_adr  : in std_logic_vector(15 downto 0);
		i_wb_data : in std_logic_vector (31 downto 0);
		o_wb_ack  : out std_logic;
		o_wb_data : out std_logic_vector (31 downto 0)
	);
end component pid;

component fir_filter is
	port
	(
		clk     : in std_logic;
		reset     : in std_logic;
		data_in  : in std_logic_vector(7 downto 0);
		coef_in  : in std_logic_vector(7 downto 0);
		load_c   : in std_logic;
		data_out  : out std_logic_vector(17 downto 0)
	);
end component fir_filter;
component control is
  port(
    data		: in std_logic_vector(7 downto 0);   
    loaddata	: in std_logic; 									   
    dataout		: out bit_vector ( 7 downto 0); 		 
    loaddataout	: out bit;									         
    clk         : in  std_logic;                     
    controlrst  : in std_logic                                       
  );
end component control;
component cf_fft_2048_16 is
port(
signal clock_c : in std_logic;
signal enable_i : in unsigned(0 downto 0);
signal reset_i : in unsigned(0 downto 0);
signal sync_i : in unsigned(0 downto 0);
signal data_0_i : in unsigned(31 downto 0);
signal data_1_i : in unsigned(31 downto 0);
signal sync_o : out unsigned(0 downto 0);
signal data_0_o : out unsigned(31 downto 0);
signal data_1_o : out unsigned(31 downto 0));
end component cf_fft_2048_16;

component cf_fft_4096_16 is
port(
signal clock_c : in std_logic;
signal enable_i : in unsigned(0 downto 0);
signal reset_i : in unsigned(0 downto 0);
signal sync_i : in unsigned(0 downto 0);
signal data_0_i : in unsigned(31 downto 0);
signal data_1_i : in unsigned(31 downto 0);
signal sync_o : out unsigned(0 downto 0);
signal data_0_o : out unsigned(31 downto 0);
signal data_1_o : out unsigned(31 downto 0));
end component cf_fft_4096_16;

component cf_fft_2048_18 is
port(
signal clock_c : in std_logic;
signal enable_i : in unsigned(0 downto 0);
signal reset_i : in unsigned(0 downto 0);
signal sync_i : in unsigned(0 downto 0);
signal data_0_i : in unsigned(35 downto 0);
signal data_1_i : in unsigned(35 downto 0);
signal sync_o : out unsigned(0 downto 0);
signal data_0_o : out unsigned(35 downto 0);
signal data_1_o : out unsigned(35 downto 0));
end component cf_fft_2048_18;

component cf_fft_4096_18 is
port(
signal clock_c : in std_logic;
signal enable_i : in unsigned(0 downto 0);
signal reset_i : in unsigned(0 downto 0);
signal sync_i : in unsigned(0 downto 0);
signal data_0_i : in unsigned(35 downto 0);
signal data_1_i : in unsigned(35 downto 0);
signal sync_o : out unsigned(0 downto 0);
signal data_0_o : out unsigned(35 downto 0);
signal data_1_o : out unsigned(35 downto 0));
end component cf_fft_4096_18;

component cf_fft_4096_8 is
port(
signal clock_c : in std_logic;
signal enable_i : in unsigned(0 downto 0);
signal reset_i : in unsigned(0 downto 0);
signal sync_i : in unsigned(0 downto 0);
signal data_0_i : in unsigned(15 downto 0);
signal data_1_i : in unsigned(15 downto 0);
signal sync_o : out unsigned(0 downto 0);
signal data_0_o : out unsigned(15 downto 0);
signal data_1_o : out unsigned(15 downto 0));
end component cf_fft_4096_8;

component RSACypher is
	Generic (KEYSIZE: integer := 32);
    Port (indata: in std_logic_vector(KEYSIZE-1 downto 0);
	 		 inExp: in std_logic_vector(KEYSIZE-1 downto 0);
	 		 inMod: in std_logic_vector(KEYSIZE-1 downto 0);
	 		 cypher: out std_logic_vector(KEYSIZE-1 downto 0);
			 clk: in std_logic;
			 ds: in std_logic;
			 reset: in std_logic;
			 ready: out std_logic
			 );
end component;

component fdct is
    Port (din: in std_logic_vector(7 downto 0);
	 		 dout: out std_logic_vector(11 downto 0);
	 		 dstrb: in std_logic;
	 		 douten: out std_logic;
			 clk: in std_logic;
			 ena: in std_logic;
			 rst: in std_logic
			 );
end component;

component jpeg_encoder is
    Port (din: in std_logic_vector(7 downto 0);
	 		 qnt_val: in std_logic_vector(7 downto 0);
	 		 amp: out std_logic_vector(11 downto 0);
	 		 qnt_cnt: out std_logic_vector(5 downto 0);
	 		 size: out std_logic_vector(3 downto 0);
	 		 rlen: out std_logic_vector(3 downto 0);
	 		 dstrb: in std_logic;
	 		 douten: out std_logic;
			 clk: in std_logic;
			 ena: in std_logic;
			 rst: in std_logic
			 );
end component;
        signal din_jpeg : std_logic_vector(7 downto 0);
        signal dstrb_jpeg : std_logic;
        signal ena_jpeg : std_logic;
        signal qnt_jpegI : std_logic_vector(7 downto 0);
        signal qnt_jpegO : std_logic_vector(5 downto 0);
        signal size_jpeg : std_logic_vector(3 downto 0);
        signal rlen_jpeg : std_logic_vector(3 downto 0);
        signal amp_jpeg : std_logic_vector(11 downto 0);
        signal douten_jpeg : std_logic;

component B1 is

  port (
    iClkFast : in std_logic;
    iClkSlow : in std_logic;
    iReset   : in std_logic;

    iCommandBus : in std_logic_vector(7 downto 0);
    iIdle       : in std_logic;

    oCount12 : out std_logic_vector(11 downto 0);
    oCount8  : out std_logic_vector(7 downto 0);
    oCount4  : out std_logic_vector(3 downto 0)
    );
end component B1;

component top_level is
  generic (size : natural := 4);  -- number of RNGs, adjust accordingly
  port (
    clk : in std_logic;  -- clock in
    reset : in std_logic;  -- resets RNGs to initial state, not really needed for the benchmark
    enable : in std_logic;   -- switch RNGs on and off through clock buffer
    random_out : out std_logic;  -- output of xor chain
	 leds : out std_logic_vector(3 downto 0) -- LEDs for visual verification
  );
end component;
signal random_out : std_logic;
signal enable_rng : std_logic;
signal leds       : std_logic_vector(3 downto 0);

component des3 is

  port (
    desout : out std_logic_vector(63 downto 0);
    desin : in std_logic_vector(63 downto 0);
    key1   : in std_logic_vector(55 downto 0);
    key2 : in std_logic_vector(55 downto 0);
    key3   : in std_logic_vector(55 downto 0);
    decrypt : in std_logic;
    clk : in std_logic
    );
end component des3;
    signal desout  : std_logic_vector(63 downto 0);
    signal desin   : std_logic_vector(63 downto 0);
    signal key1    : std_logic_vector(55 downto 0);
    signal key2    : std_logic_vector(55 downto 0);
    signal key3    : std_logic_vector(55 downto 0);
    signal decrypt : std_logic;

    
    signal inf0_s : std_logic_vector(35 downto 0);
    signal inf1_s : std_logic_vector(35 downto 0);
    signal inf2_s : std_logic_vector(2 downto 0);
    signal inf3_s : std_logic_vector(35 downto 0);
    signal inf4_s : std_logic_vector(31 downto 0);
    signal inf5_s : std_logic_vector(31 downto 0);
    signal inf6_s : std_logic_vector(31 downto 0);
    signal inf7_s : std_logic_vector(31 downto 0);
    signal bit_s  : bit_vector(27 downto 0);  
    signal enable_s : std_logic_vector(35 downto 0);  
    attribute box_type : string;
    attribute box_type of ava : component is "black_box";
    attribute dont_touch of activity_blocks : label is "true";

    signal enable_u : unsigned (31 downto 0);
    signal reset_u  : unsigned (0 downto 0);
    signal sync_iu  : unsigned (31 downto 0);
    signal sync_ou  : unsigned (31 downto 0);
    type   t16 is array (0 to 9) of unsigned(15 downto 0);
    type   t32 is array (0 to 9) of unsigned(31 downto 0);
    type   t36 is array (0 to 9) of unsigned(35 downto 0);
    signal vec16_in : t16;
    signal vec16_ot : t16;
    signal vec32_in : t32;
    signal vec32_ot : t32;
    signal vec36_in : t36;
    signal vec36_ot : t36;
    signal vec_uns  : unsigned(35 downto 0);
    signal vec_sig  : std_logic_vector(31 downto 0);
    signal reset_s : std_logic_vector (0 downto 0);

begin

    vec16_ot(1) <= unsigned(desout(15 downto 0));
    vec16_ot(2) <= unsigned(desout(31 downto 26));
    vec16_ot(3) <= unsigned(desout(47 downto 32));
    vec16_ot(4) <= unsigned(desout(63 downto 48));
    desin       <= std_logic_vector(vec16_in(1)) & std_logic_vector(vec16_in(2)) & std_logic_vector(vec16_in(3)) & std_logic_vector(vec16_in(4));
    key1        <= std_logic_vector(vec16_in(0)(15 downto 12)) & std_logic_vector(vec16_in(5)) & std_logic_vector(vec16_in(8)) & std_logic_vector(vec16_in(9)) & std_logic_vector(vec32_in(1)(7 downto 4));
    key2        <= std_logic_vector(vec32_in(0)) & std_logic_vector(vec32_in(1)(31 downto 8));
    key3        <= std_logic_vector(vec32_in(1)(3 downto 0)) & std_logic_vector(vec32_in(4)) & std_logic_vector(vec32_in(5)(19 downto 0));
    decrypt     <= vec32_in(5)(20);
    
    vec32_ot(0)(11 downto 8) <= unsigned(leds); 
    vec32_ot(0)(12)          <= random_out;
    enable_rng               <= enable_i(19);
    
    enable_u   <= unsigned(enable_i);
    reset_s(0) <= rst_i;
    reset_u    <= unsigned(reset_s);
    sync_iu    <= unsigned(inf1_s(31 downto 0));
    
    vec16_in(0) <= unsigned(inf0_s(15 downto 0));
    vec16_in(1) <= unsigned(inf0_s(31 downto 16));
    vec16_in(2) <= unsigned(inf1_s(15 downto 0));
    vec16_in(3) <= unsigned(inf1_s(31 downto 16));
    vec16_in(4) <= unsigned(inf3_s(15 downto 0));
    vec16_in(5) <= unsigned(inf3_s(31 downto 16));
    vec16_in(6) <= unsigned(inf4_s(15 downto 0));
    vec16_in(7) <= unsigned(inf4_s(31 downto 16));
    vec16_in(8) <= unsigned(enable_s(15 downto 0));
    vec16_in(9) <= unsigned(enable_s(31 downto 16));
    
    vec32_in(0) <= vec16_ot(0) & vec16_ot(1);
    vec32_in(1) <= vec16_ot(2) & vec16_ot(3);
    vec32_in(2) <= vec16_ot(4) & vec16_ot(5);
    vec32_in(3) <= vec16_ot(6) & vec16_ot(7);
    vec32_in(4) <= vec16_ot(8) & vec16_ot(9);
    vec32_in(5) <= vec16_ot(0) & vec16_ot(5);
    vec32_in(6) <= vec16_ot(1) & vec16_ot(6);
    vec32_in(7) <= vec16_ot(2) & vec16_ot(7);
    vec32_in(8) <= vec16_ot(3) & vec16_ot(8);
    vec32_in(9) <= vec16_ot(4) & vec16_ot(9);
    
    vec36_in(0) <= vec32_ot(0) & vec32_ot(1)(3 downto 0);
    vec36_in(1) <= vec32_ot(2) & vec32_ot(3)(3 downto 0);
    vec36_in(2) <= vec32_ot(4) & vec32_ot(5)(3 downto 0);
    vec36_in(3) <= vec32_ot(6) & vec32_ot(7)(3 downto 0);
    vec36_in(4) <= vec32_ot(8) & vec32_ot(9)(3 downto 0);
    vec36_in(5) <= vec32_ot(1) & vec32_ot(2)(3 downto 0);
    vec36_in(6) <= vec32_ot(3) & vec32_ot(4)(3 downto 0);
    vec36_in(7) <= vec32_ot(5) & vec32_ot(6)(3 downto 0);
    vec36_in(8) <= vec32_ot(7) & vec32_ot(8)(3 downto 0);
    vec36_in(9) <= vec32_ot(8) & vec32_ot(0)(3 downto 0);
    
    vec_sig(27 downto 0) <= std_logic_vector(vec_uns(27 downto 0));
    vec_sig(31 downto 28) <= std_logic_vector(vec_uns(35 downto 32) xor vec_uns(31 downto 28));
    vec_uns <= vec36_ot(0) xor vec36_ot(1) xor vec36_ot(2) xor vec36_ot(3) xor vec36_ot(4) xor vec36_ot(5) xor vec36_ot(6) xor vec36_ot(7) xor vec36_ot(8) xor vec36_ot(8); 
    
    din_jpeg <= std_logic_vector(vec32_in(5)(29 downto 22));
    dstrb_jpeg <= vec32_in(5)(30);
    ena_jpeg <= enable_i(19);
    qnt_jpegI <= std_logic_vector(vec32_in(6)(7 downto 0));
    vec32_ot(0)(18 downto 13) <= unsigned(qnt_jpegO);
    vec32_ot(0)(22 downto 19) <= unsigned(size_jpeg);
    vec32_ot(0)(26 downto 23) <= unsigned(rlen_jpeg);
    vec32_ot(0)(31 downto 27) <= unsigned(amp_jpeg(4 downto 0));
    vec16_ot(5)(6 downto 0) <= unsigned(amp_jpeg(11 downto 5));
    vec16_ot(5)(7) <= douten_jpeg;
    
    --unused vec
    vec16_ot(5)(15 downto 8) <= vec16_in(5)(15 downto 8);
    vec16_ot(8) <= vec16_in(8);
    vec16_ot(9) <= vec16_in(9);
    vec32_ot(1) <= vec32_in(1);
    vec32_ot(4) <= vec32_in(4);
    vec32_ot(5) <= vec32_in(5);
    vec32_ot(8) <= vec32_in(8);
    vec32_ot(9) <= vec32_in(9);
    vec36_ot(0) <= vec36_in(0);
    vec36_ot(1) <= vec36_in(1);
    vec36_ot(4) <= vec36_in(4);
    vec36_ot(5) <= vec36_in(5);
    vec36_ot(8) <= vec36_in(8);
    vec36_ot(9) <= vec36_in(9);
    
    activity_blocks : for i in 0 to 0 generate
    begin
    switch: ava port map (
           cpe_pclk  => clk_i,
           cpe_reset => rst_i,
           CPE_HostToPeFifoData_In => enable_s,
           CPE_PeToHostFifoData_Out => inf0_s,
           CPE_HostToPeFifoEmpty_n => enable_i(10),
           CPE_Fifo_WE_n => inf2_s(0),
           CPE_FifoPtrIncr_EN => inf2_s(1),
           CPE_PeToHostFifoData_OE => inf1_s
    );
    switchtlvl: top_level port map (
        clk => clk_i,
        reset => rst_i,
        enable => enable_rng,
        leds => leds,
        random_out => random_out
    );
    switchtjpg: jpeg_encoder port map (
        clk => clk_i,
        din => din_jpeg,
        dstrb => dstrb_jpeg,
        ena => ena_jpeg,
        rst => rst_i,
        qnt_val => qnt_jpegI,
        qnt_cnt => qnt_jpegO,
        size => size_jpeg,
        rlen => rlen_jpeg,
        amp => amp_jpeg,
        douten => douten_jpeg
    );
    switchv: B1 port map (
       iclkfast              => std_logic(vec16_in(0)(0)),
       iclkslow              => std_logic(vec16_in(0)(1)),
       ireset                => std_logic(vec16_in(0)(2)),
       icommandbus           => std_logic_vector(vec16_in(0)(10 downto 3)),
       iidle                 => std_logic(vec16_in(0)(11)),
       unsigned(ocount12)    => vec16_ot(0)(11 downto 0),
       unsigned(ocount8)    => vec32_ot(0)(7 downto 0),
       unsigned(ocount4)    => vec16_ot(0)(15 downto 12)
    );
    switchdes: des3 port map (
       desin              => desin,
       desout              => desout,
       key1                => key1,
       key2           => key2,
       key3                 => key3,
       clk    => clk_i,
       decrypt    => decrypt
    );
    switcher : pid port map (
        i_clk     =>clk_i,
		i_rst     =>rst_i,
		i_wb_cyc  =>enable_i(7),
		i_wb_stb  =>enable_i(15),
		i_wb_we   =>enable_i(23),
		i_wb_adr  =>enable_i(17 downto 2),
		i_wb_data =>enable_i,
		o_wb_ack  =>inf2_s(2),
		o_wb_data =>inf4_s 
    );
    switcherY: fir_filter port map (
        clk     =>clk_i,
		reset     =>rst_i,
		data_in  =>inf3_s(7 downto 0),
		coef_in  =>inf4_s(7 downto 0),
		load_c   =>enable_i(22),
		data_out  =>inf5_s(17 downto 0)
    );
    switchX: control port map (
        clk     =>clk_i,
		controlrst     =>rst_i,
		data  =>inf0_s(7 downto 0),
		loaddataout  =>bit_s(26),
		loaddata   =>enable_i(21),
		dataout  =>bit_s(25 downto 18)
    );
    switchR: RSACypher port map (
        clk    => clk_i,
		reset  => rst_i,
		indata => inf0_s(31 downto 0),
		inmod  => vec_sig,
		inexp  => inf1_s(31 downto 0),
		cypher =>inf6_s,
		ready  =>inf5_s(28),
		ds     =>inf5_s(0)
    );
    switchdct: fdct port map (
        clk    => clk_i,
		rst  => rst_i,
		din => inf5_s(7 downto 0),
		dout  => inf7_s(11 downto 0),
		douten  => inf7_s(12),
		ena =>inf5_s(9),
		dstrb  =>inf5_s(8)
    );
    switch3 : cf_fft_4096_8 
    port map(
       clock_c =>clk_i,
       enable_i => enable_u(3 downto 3),
       reset_i => reset_u,
       sync_i => sync_iu(3 downto 3),
       data_0_i => vec16_in(6),
       data_1_i => vec16_in(7),
       sync_o => sync_ou(3 downto 3),
       data_0_o => vec16_ot(6),
       data_1_o => vec16_ot(7));   
       switch6 : cf_fft_2048_16
       port map(
         clock_c =>clk_i,
         enable_i => enable_u(6 downto 6),
         reset_i => reset_u,
         sync_i => sync_iu(6 downto 6),
         data_0_i => vec32_in(2),
         data_1_i => vec32_in(3),
         sync_o => sync_ou(6 downto 6),
         data_0_o => vec32_ot(2),
         data_1_o => vec32_ot(3));
      switch8 : cf_fft_4096_16
      port map(
        clock_c =>clk_i,
        enable_i => enable_u(8 downto 8),
        reset_i => reset_u,
        sync_i => sync_iu(8 downto 8),
        data_0_i => vec32_in(6),
        data_1_i => vec32_in(7),
        sync_o => sync_ou(8 downto 8),
        data_0_o => vec32_ot(6),
        data_1_o => vec32_ot(7));     
      switch11 : cf_fft_2048_18  
      port map(
        clock_c =>clk_i,
        enable_i => enable_u(11 downto 11),
        reset_i => reset_u,
        sync_i => sync_iu(11 downto 11),
        data_0_i => vec36_in(2),
        data_1_i => vec36_in(3),
        sync_o => sync_ou(11 downto 11),
        data_0_o => vec36_ot(2),
        data_1_o => vec36_ot(3));        
      switch13 : cf_fft_4096_18 
      port map(
        clock_c =>clk_i,
        enable_i => enable_u(13 downto 13),
        reset_i => reset_u,
        sync_i => sync_iu(13 downto 13),
        data_0_i => vec36_in(6),
        data_1_i => vec36_in(7),
        sync_o => sync_ou(13 downto 13),
        data_0_o => vec36_ot(6),
        data_1_o => vec36_ot(7)); 
    end generate;
    inf5_s(26 downto 18) <= to_stdlogicvector(bit_s(26 downto 18));
    
    sequences: process(clk_i)
    begin
         if rising_edge(clk_i) then
             inf3_s(35 downto 2) <= inf0_s(35 downto 2) xor inf1_s(35 downto 2);
             inf3_s(2 downto 0) <= inf0_s(2 downto 0) xor inf1_s(2 downto 0) xor inf2_s(2 downto 0);
             info_o(27 downto 0) <= inf3_s(27 downto 0) xor inf4_s(27 downto 0) xor inf5_s(27 downto 0) xor vec_sig(27 downto 0) xor inf6_s(27 downto 0)xor inf7_s(27 downto 0);
             info_o(31 downto 28) <= inf3_s(31 downto 28) xor inf3_s(35 downto 32) xor inf4_s(31 downto 28) xor inf5_s(31 downto 28) xor vec_sig(31 downto 28) xor inf6_s(31 downto 28) xor inf7_s(31 downto 28); 
             enable_s(31 downto 0) <= enable_i(31 downto 0);
             enable_s(35 downto 32) <= inf3_s(31 downto 28) xor inf3_s(35 downto 32); 
         end if;
    end process;

end avaz;

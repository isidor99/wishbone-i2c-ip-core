----------------------------------------------------------------------------
-- ETF BL
-- Wishbone I2C
-----------------------------------------------------------------------------
--
--    unit    name:                        clock_generator_tb
--
--    description:
--
--             Testbench for clock_generator
--
-----------------------------------------------------------------------------
--    Copyright    (c)    ETF BL
-----------------------------------------------------------------------------
--    LICENSE    MIT License
-----------------------------------------------------------------------------
--    LICENSE    NOTICE
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_generator_tb is
end clock_generator_tb;

architecture arch of clock_generator_tb is

  component clock_generator
    generic (
      g_SYSTEM_CLOCK : integer
    );
    port(
	   clk_i : in  std_logic;
      rst_i : in  std_logic;
      enb_i : in  std_logic;
      sel_i : in  std_logic_vector(1 downto 0);
      clk_o : out std_logic
    );
  end component;
  
  constant c_T              : time    := 20 ns;
  constant c_STD_MODE       : time    := 10000 ns;
  constant c_FAST_MODE      : time    := 2500 ns;
  constant c_FAST_MODE_PLUS : time    := 1000 ns;
  constant SYSTEM_CLOCK     : natural := 50_000_000;

  signal clk     : std_logic;
  signal rst     : std_logic;
  signal enbl    : std_logic;
  signal sel     : std_logic_vector (1 downto 0);
  signal clk_out : std_logic;
begin

  -- uut instantiation
  uut: clock_generator
    generic map(g_SYSTEM_CLOCK => SYSTEM_CLOCK)
	 port map(
	   clk_i => clk,
		rst_i => rst,
		enb_i => enbl,
		sel_i => sel,
		clk_o => clk_out);

  -- clock generator
  process
  begin
    clk <= '0';
    wait for c_T/2;
    clk <= '1';
    wait for c_T/2;
  end process;

  -- stimulus generation
  process
  begin
    rst <= '1';
	 wait for c_T;
	 rst <= '0';
	 wait for c_T;

	 -- Checking output in the inactive state
	 enbl <= '0';
	 wait for c_T;
	 
	 assert(clk_out = '1')
	   report "Output should be high in the inactive state " & std_logic'image(clk_out)
	     severity error;

    -- Enabling output
	 enbl <= '1';
	 
    -- Standar mode testing
	 sel <= "00";
	 wait until rising_edge(clk_out);
	 wait for c_STD_MODE + c_T;

	 assert(clk_out = '1')
	   report "Output should be high but it's " & std_logic'image(clk_out)
	     severity error;
	 
	 -- Fast mode testing	  
    sel <= "01";
	 wait until rising_edge(clk_out);
	 wait for c_FAST_MODE + c_T;

	 assert(clk_out = '1')
	   report "Output should be high but it's " & std_logic'image(clk_out)
	     severity error;
	
	 -- Fast mode plus testing	  
    sel <= "10";
	 wait until rising_edge(clk_out);
	 wait for c_FAST_MODE_PLUS + c_T;

	 assert(clk_out = '1')
	   report "Output should be high but it's " & std_logic'image(clk_out)
	     severity error;
	 wait;
  end process;
end arch;

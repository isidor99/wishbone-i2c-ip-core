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
    port(
      clk_i : in  std_logic;
      rst_i : in  std_logic;
      enb_i : in  std_logic;
      sel_i : in  std_logic_vector(1 downto 0);
      sysclk_i : in std_logic_vector(31 downto 0);
      clk_o : out std_logic
    );
  end component;

  constant c_T                : time    := 1000 ns;
  constant c_SYSTEM_CLOCK     : natural := 50_000_000;

  type t_test_vector is record
    sysclk   : std_logic_vector (31 downto 0);
    sel      : std_logic_vector (1 downto 0);
    edge_num : natural;
    wait_for : time;
    period   : time;
  end record t_test_vector;

  type t_test_vector_array is array (natural range<>) of t_test_vector;

  constant c_TEST_VECTOR : t_test_vector_array := (
    ("01000000000000000000000011001000", "00", 10, 100 us, 5000 ns), -- 200 khz to 100 khz
    ("10000000000000000000000000000001", "00", 10, 100 us, 1000 ns), -- 1 Mhz to 100 khz
    ("10000000000000000000000000000001", "01", 10, 25  us, 1000 ns), -- 1 Mhz to 400 khz
    ("10000000000000000000000000000001", "10", 10, 10  us, 1000 ns), -- 1 Mhz to 1 Mhz
    ("10000000000000000000000000110010", "00", 10, 100 us, 20 ns),   -- 50 Mhz to 100 khz
    ("10000000000000000000000000110010", "01", 10, 25  us, 20 ns),   -- 50 Mhz to 400 khz
    ("10000000000000000000000000110010", "10", 10, 10  us, 20 ns),   -- 50 Mhz to 1 Mhz
    ("10000000000000000000000011001000", "00", 10, 100 us, 5 ns),    -- 200 Mhz to 100 khz
    ("10000000000000000000000011001000", "01", 10, 25  us, 5 ns),   -- 200 Mhz to 400 khz
    ("10000000000000000000000011001000", "10", 10, 10  us, 5 ns),    -- 200 Mhz to 1 Mhz
    ("11000000000000000000000000000001", "00", 10, 100 us, 1 ns),    -- 1 Ghz to 100 khz
    ("11000000000000000000000000000001", "01", 10, 25  us, 1 ns),    -- 1 Ghz to 400 khz
    ("11000000000000000000000000000001", "10", 10, 10  us, 1 ns)     -- 1 Ghz to 1 Mhz
  );

  signal i         : natural := 0;
  signal edge_cnt  : natural := 0;
  signal old_cnt   : natural := 0;
  signal cnt_diff  : natural := 0;
  signal stop      : std_logic := '0';

  signal clk     : std_logic;
  signal rst     : std_logic;
  signal enbl    : std_logic;
  signal sel     : std_logic_vector (1 downto 0) := c_TEST_VECTOR(i).sel;
  signal clk_out : std_logic;
  signal sysclk  : std_logic_vector(31 downto 0) := c_TEST_VECTOR(i).sysclk;

begin

  -- uut instantiation
  uut : clock_generator
    port map (
      clk_i    => clk,
      rst_i    => rst,
      enb_i    => enbl,
      sel_i    => sel,
      sysclk_i => sysclk,
      clk_o    => clk_out
    );

  -- stimulus generator
  process
  begin

    clk <= '0';
    wait for (c_TEST_VECTOR(i).period) / 2;
    clk <= '1';
    wait for (c_TEST_VECTOR(i).period) / 2;

    if stop = '1' then
      wait;
    end if;

  end process;

  -- count output signal rising edges
  process(clk_out)
  begin

    if rising_edge(clk_out) and enbl = '1' then
      edge_cnt <= edge_cnt + 1;
    end if;

  end process;

  -- check output
  process
  begin

    enbl <= '0';

    wait until rising_edge(clk);

    enbl <= '1';

    -- synchronize
    wait until rising_edge(clk);
    wait for c_TEST_VECTOR(i).wait_for;
    wait until falling_edge(clk);

    enbl <= '0';

    wait for 20 ns;

    -- Checking output in the inactive state
    assert (clk_out = '1')
      report "Output Clock Does Not Conform to Specified Value in The Inactive State"
        severity error;

    cnt_diff <= edge_cnt - old_cnt;

    wait for 20 ns;

    assert (cnt_diff = c_TEST_VECTOR(i).edge_num)
      report "Output Clock Does Not Conform to Specified Value "
       severity error;

    old_cnt <= edge_cnt;

    wait until rising_edge(clk);

    if i  /= c_TEST_VECTOR'length - 1 then
      i <= i + 1;
      sysclk <= c_TEST_VECTOR(i).sysclk;
      sel <= c_TEST_VECTOR(i).sel;
    else
      stop <= '1';
      wait;
    end if;

  end process;
end arch;

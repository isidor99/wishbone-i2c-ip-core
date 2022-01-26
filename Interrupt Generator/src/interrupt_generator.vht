-----------------------------------------------------------------------------
-- ETF BL
-- Interrupt Generator Test Bench
-----------------------------------------------------------------------------
--
--    unit name:   interrupt_generator_tb
--
--    description: This is test bench for top-level entity.
--
-----------------------------------------------------------------------------
--    Copyright    (c)    ETF BL
-----------------------------------------------------------------------------
--    LICENSE    NAME
-----------------------------------------------------------------------------
--    LICENSE    NOTICE
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity interrupt_generator_tb is
end interrupt_generator_tb;

architecture arch of interrupt_generator_tb is

  signal arlo_i_test       : std_logic;
  signal clk_i_test        : std_logic;
  signal int_ack_i_test    : std_logic;
  signal int_enable_i_test : std_logic;
  signal int_o_test        : std_logic;
  signal io                : std_logic; -- za testni vektor

  component interrupt_generator
    port (
   arlo_i       : in std_logic;
   clk_i        : in std_logic;
   int_ack_i    : in std_logic;
   int_enable_i : in std_logic;
   int_o        : out std_logic
   );
  end component;

  constant c_TIME : time := 20 ns;
  signal i : integer := 1;


  type t_test_vector is record
arlo : std_logic;
ack  : std_logic;
ie   : std_logic;
io   : std_logic;
end record t_test_vector;


  type t_test_vector_array is array (natural range <>) of t_test_vector;

  constant c_TEST_VECTOR : t_test_vector_array := (
    ('0', '0', '0', '0'),
    ('0', '0', '1', '0'),
    ('0', '1', '0', '0'),
    ('0', '1', '1', '0'),
    ('1', '0', '0', '0'),
    ('1', '0', '1', '1'),
    ('1', '1', '0', '0'),
    ('1', '1', '1', '0')
  );

begin
  i1 : interrupt_generator
    port map (
      arlo_i       => arlo_i_test,
      clk_i        => clk_i_test,
      int_ack_i    => int_ack_i_test,
      int_enable_i => int_enable_i_test,
      int_o        => int_o_test
   );
-- process
  process
  begin
    clk_i_test <= '0';
    wait for c_TIME / 2;
    clk_i_test <= '1';
    wait for c_TIME / 2;
    if i = c_TEST_VECTOR'length then
      wait;
    end if;
  end process;

-- stimulus generator
  process
  begin
    arlo_i_test <= c_TEST_VECTOR(i).arlo;
    int_ack_i_test <= c_TEST_VECTOR(i).ack;
    int_enable_i_test <= c_TEST_VECTOR(i).ie;
    io <= c_TEST_VECTOR(i).io;
    wait for c_TIME;

    if i /= c_TEST_VECTOR'length then
      i <= i + 1;
    else
      wait;
    end if;
  end process;

-- check output
  process
  begin

    wait until clk_i_test'event and clk_i_test = '1';
    wait for 5 ns;

    assert (int_o_test = io)
      report "Test failed."
      severity error;

    if i = c_TEST_VECTOR'length then
      report "Test completed.";
    end if;
  end process;
end arch;

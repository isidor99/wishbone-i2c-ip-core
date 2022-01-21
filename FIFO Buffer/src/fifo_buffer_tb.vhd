-----------------------------------------------------------------------------
-- ETF BL
-- Widhbone I2C
-----------------------------------------------------------------------------
--
--    unit    name:                        fifo_buffer_tb
--
--    description:
--
--              Testbench for FIFO buffer.
--
-----------------------------------------------------------------------------
--    Copyright    (c)    ETF BL
-----------------------------------------------------------------------------
--    LICENSE    NAME     MIT License
-----------------------------------------------------------------------------
--    LICENSE    NOTICE
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo_buffer_tb is
end fifo_buffer_tb;

architecture arch of fifo_buffer_tb is

  component fifo_buffer is
    generic
    (
      g_WIDTH : natural := 8;
      g_DEPTH : natural := 16
    );
    port
    (
      clk_i        : in  std_logic;
      rst_i        : in  std_logic;
      wr_en_i      : in  std_logic;
      rd_en_i      : in  std_logic;
      data_i       : in  std_logic_vector((g_WIDTH - 1) downto 0);
      data_o       : out std_logic_vector((g_WIDTH - 1) downto 0);
      buff_full_o  : out std_logic;
      buff_empty_o : out std_logic
    );
  end component;

  constant c_WIDTH : natural := 8;
  constant c_DEPTH : natural := 16;
  constant c_TIME  : time := 20 ns;

  type t_test_vector is record
    write_in : std_logic_vector((c_WIDTH - 1) downto 0);
    read_out : std_logic_vector((c_WIDTH - 1) downto 0);
  end record t_test_vector;

  type t_test_vector_array is array (natural range <>) of t_test_vector;

  constant c_TEST_VECTOR : t_test_vector_array :=
  (
    ("00110011", "00110011"),
    ("11001100", "11001100"),
    ("10000001", "10000001"),
    ("01111110", "01111110")
  );

  signal clk        : std_logic;
  signal rst        : std_logic;
  signal wr_en      : std_logic;
  signal rd_en      : std_logic;
  signal data_in    : std_logic_vector((c_WIDTH - 1) downto 0);
  signal data_out   : std_logic_vector((c_WIDTH - 1) downto 0);
  signal buff_full  : std_logic;
  signal buff_empty : std_logic;
  signal stop       : std_logic;

begin

  uut : fifo_buffer
    generic map (
      g_WIDTH => c_WIDTH,
      g_DEPTH => c_DEPTH
    )
    port map (
      clk_i        => clk,
      rst_i        => rst,
      wr_en_i      => wr_en,
      rd_en_i      => rd_en,
      data_i       => data_in,
      data_o       => data_out,
      buff_full_o  => buff_full,
      buff_empty_o => buff_empty
    );

  -- stimulus generator
  process
  begin

    clk <= '0';
    wait for c_TIME;
    clk <= '1';
    wait for c_TIME;

    if stop = '1' then
      wait;
    end if;

  end process;

  -- verifier
  process
  begin

    rst <= '0';
    rd_en <= '0';
    stop <= '0';

    for i in 1 to 20 loop

      wait for 15 ns;

      -- do not write in full buffer
      if buff_full = '0' then
        wr_en <= '1';
        data_in <= std_logic_vector(to_unsigned(i, 8));
      end if;

      wait until rising_edge(clk);
      wait for 5 ns;

      wr_en <= '0';

      wait until falling_edge(clk);
    end loop;


    for i in 1 to 20 loop

      wait for 15 ns;

      -- check if buffer is not empty
      if buff_empty = '0' then
        rd_en <= '1';

        wait until rising_edge(clk);
        wait for 5 ns;

        rd_en <= '0';

        -- out should be first element in buffer
        assert (data_out = std_logic_vector(to_unsigned(i, 8)))
        report "Output data should be " & integer'image(to_integer(to_unsigned(i, 8))) &
               ", but it is " & integer'image(to_integer(unsigned(data_out)))
        severity error;
      end if;

      wait until falling_edge(clk);
    end loop;

    wr_en <= '1';
    data_in <= c_TEST_VECTOR(0).write_in;

    wait until rising_edge(clk);
    wait for 5 ns;

    wr_en <= '0';

    wait until falling_edge(clk);

    for i in 1 to c_TEST_VECTOR'length - 1 loop

      wait for 15 ns;

      data_in <= c_TEST_VECTOR(i).write_in;
      wr_en <= '1';
      rd_en <= '1';

      wait until rising_edge(clk);
      wait for 5 ns;

      -- out should be first element in buffer
      assert (data_out = c_TEST_VECTOR(i - 1).read_out)
      report "Output data should be " &
             integer'image(to_integer(unsigned(c_TEST_VECTOR(i - 1).read_out))) &
             ", but it is " & integer'image(to_integer(unsigned(data_out)))
      severity error;

      wr_en <= '0';
      rd_en <= '0';

      wait until falling_edge(clk);
    end loop;

    wait for 15 ns;

    rd_en <= '1';

    wait until rising_edge(clk);
    wait for 5 ns;

    rd_en <= '0';

    -- out should be last element in c_TEST_VECTOR
    assert (data_out = c_TEST_VECTOR(c_TEST_VECTOR'length - 1).read_out)
    report "Output data should be " &
           integer'image(to_integer(unsigned(c_TEST_VECTOR(c_TEST_VECTOR'length - 1).read_out))) &
           ", but it is " & integer'image(to_integer(unsigned(data_out)))
    severity error;

    wait for 5 ns;

    stop <= '1';

    -- enable output
    assert (1 = 2)
    report "Test completed!";

    wait;

  end process;

end arch;

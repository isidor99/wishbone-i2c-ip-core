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
  
    wait until clk = '1';

    for i in 0 to 25 loop

      wait for 4 ns;

	   if buff_full = '0' then
		  wr_en <= '1';
        data_in <= std_logic_vector(to_unsigned(i, 8));
      end if;

      wait until rising_edge(clk);
      wait for 12 ns;

		wr_en <= '0';
    end loop;

    stop <= '1';
    wait;
    
  end process;
  
end arch;

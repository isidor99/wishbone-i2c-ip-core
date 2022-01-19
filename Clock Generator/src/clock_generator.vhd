----------------------------------------------------------------------------
-- ETF BL
-- Wishbone I2C
-----------------------------------------------------------------------------
--
--    unit    name:                        clock_generator
--
--    description:
--
--              This is top-level entity.
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

entity clock_generator is
  generic
  (
    g_SYSTEM_CLOCK : integer := 50_000_000
  );
  port
  (
    clk_i    : in  std_logic;
    rst_i    : in  std_logic;
    enb_i    : in  std_logic;
    sel_i    : in  std_logic_vector(1 downto 0);
    sysclk_i : in  std_logic_vector(31 downto 0);
    clk_o    : out std_logic
  );
end clock_generator;

architecture arch of clock_generator is

  constant c_STANDARD_MODE  : integer := 250;
  constant c_FAST_MODE      : integer := 63;
  constant c_FAST_MODE_PLUS : integer := 25;

  signal tmp   : std_logic := '0';
  signal col   : integer := 0;

begin

  -- Count process
  process(clk_i, rst_i)
    variable count : integer := 0;
  begin
    if rst_i = '1' then
      count := 0;
      tmp <= '0';
    elsif rising_edge(clk_i) then
      if count /= col - 1 then
        count := count + 1;
        tmp <= tmp;
      else
        count := 0;
        tmp <= not tmp;
      end if;
    end if;
  end process;

  with sel_i select
    col <= c_STANDARD_MODE when "00",
           c_FAST_MODE when "01",
           c_FAST_MODE_PLUS when "10",
           1 when others;

  clk_o <= tmp when enb_i = '1' else
           '1';

end arch;

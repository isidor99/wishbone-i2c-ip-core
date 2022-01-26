-----------------------------------------------------------------------------
-- ETF BL
-- Interrupt Generator
-----------------------------------------------------------------------------
--
--    unit name:interrupt_generator
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
use ieee.numeric_std.all;

entity interrupt_generator is
  port
   (

      -- Input ports
      int_enable_i : in std_logic;
      int_ack_i    : in std_logic;
      arlo_i       : in std_logic;
      clk_i        : in std_logic;

      -- Output ports
      int_o        : out std_logic
   );
end interrupt_generator;

architecture arch of interrupt_generator is

begin
-- process
  process(clk_i) is
  begin

    if rising_edge(clk_i)then
      if int_enable_i = '1' and int_ack_i = '0'then
        if arlo_i = '1'then
          int_o <= '1';
        else
          int_o <= '0';
        end if;
      else
        int_o <= '0';
      end if;
    end if;
  end process;
end arch;

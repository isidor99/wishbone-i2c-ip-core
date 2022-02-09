-----------------------------------------------------------------------------
-- ETF BL
-- Wishbone I2C
-----------------------------------------------------------------------------
--
--    unit name:interrupt_generator
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

entity interrupt_generator is
  port
   (
      -- Input ports
      int_enbl_i   : in  std_logic;
      int_ack_i    : in  std_logic;
      arlo_i       : in  std_logic;
      int_clr_i    : in  std_logic;

      -- Output ports
      int_o        : out std_logic
   );
end interrupt_generator;

architecture arch of interrupt_generator is

  signal tmp : std_logic;

begin

  tmp <= (int_enbl_i and not (int_clr_i));
  int_o <= tmp and (arlo_i or int_ack_i);

end arch;

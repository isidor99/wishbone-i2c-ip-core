----------------------------------------------------------------------------
-- ETF BL
-- Wishbone I2C
-----------------------------------------------------------------------------
--
--    unit    name:                        register_package
--
--    description:
--
--              This is package with register constants.
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

package register_package is

  constant c_50_MHZ : std_logic_vector(31 downto 0) := "10000000000000000000000000110010";

  constant c_REG_TX   : natural := 0;
  constant c_REG_RX   : natural := 1;
  constant c_REG_CTRL : natural := 2;
  constant c_REG_STAT : natural := 3;
  constant c_REG_CMD  : natural := 4;
  constant c_REG_SLVA : natural := 5;
  constant c_REG_GPO  : natural := 6;
  constant c_REG_SYSC : natural := 7;

  -- range
  subtype MODE         is natural range 2 downto 1;
  subtype BYTE_TO_TRAN is natural range 7 downto 4; 
  subtype DATA         is natural range 7 downto 0;
  subtype SLAVE_ADDR   is natural range 9 downto 0;

  -- control register
  constant c_MSL : natural   := 0;
  constant c_ALEN : natural  := 3;
  constant c_IEN : natural   := 4;
  constant c_I2CEN : natural := 5;

  -- status register
  constant c_ARLO  : natural := 0;
  constant c_ACK   : natural := 1;
  constant c_BUSY  : natural := 2;
  constant c_IF    : natural := 3;
  constant c_TXB_F : natural := 4;
  constant c_TXB_E : natural := 5;
  constant c_RXB_F : natural := 6;
  constant c_RXB_E : natural := 7;

  -- command register
  constant c_REP_ST  : natural := 0;
  constant c_IACK    : natural := 1;
  constant c_TXB_WEN : natural := 2;
  constant c_RXB_REN : natural := 3;

  -- test data
  constant c_WIDTH        : natural := 32;
  constant c_ADDR_WIDTH   : natural := 3;
  constant c_GPO_W        : natural := 8;
  constant c_TIME         : time    := 20 ns;  

  constant c_TEST_DATA_IN : std_logic_vector(31 downto 0) := (1 | 3 | 5 | 7 => '1', others => '0');
  constant c_TEST_RX_DATA : std_logic_vector(31 downto 0) := (0 | 1 | 2 | 3 => '1', others => '0');
  constant c_CLOCK_DATA   : std_logic_vector(31 downto 0) := "10000000000000000000000000110010";
  constant c_CTRL_REG_VAL : std_logic_vector(31 downto 0) := (0 | 1 | 4 | 5 => '1', others => '0');
  constant c_CMD_REP_STRT : std_logic_vector(31 downto 0) := (0 => '1', others => '0');
  constant c_CMD_CLR_INT  : std_logic_vector(31 downto 0) := (1 => '1', others => '0');
  constant c_CMD_BUFF_OP  : std_logic_vector(31 downto 0) := (2 | 3 => '1', others => '0');
  constant c_CMD_BTT      : std_logic_vector(31 downto 0) := (4 | 6 | 7 => '1', others => '0');
  constant c_SLV_ADDR     : std_logic_vector(9 downto 0)  := "1101100111";
  constant c_GPO_VAL      : std_logic_vector((c_GPO_W - 1) downto 0) := (0 | 1 | 2 => '1', others => '0');

end package register_package;

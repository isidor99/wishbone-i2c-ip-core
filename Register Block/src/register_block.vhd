----------------------------------------------------------------------------
-- ETF BL
-- Wishbone I2C
-----------------------------------------------------------------------------
--
--    unit    name:                        register_block
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

library altera;

use altera.altera_syn_attributes.all;

entity register_block is
  generic
  (
    g_WIDTH      : natural := 32;
    g_ADDR_WIDTH : natural := 3;
    g_GPO_W      : natural := 8
  );
  port
  (
    clk_i       : in    std_logic; --
    rst_i       : in    std_logic;
    we_i        : in    std_logic; --
    addr_i      : in    natural range 0 to 2 ** g_ADDR_WIDTH - 1; --
    dat_i       : in    std_logic_vector(g_WIDTH - 1 downto 0); --
    tx_buff_f_i : in    std_logic; --
    tx_buff_e_i : in    std_logic; --
    rx_buff_f_i : in    std_logic; --
    rx_buff_e_i : in    std_logic; --
    rx_data_i   : in    std_logic_vector(7 downto 0); --
    int_flg_b   : inout std_logic; --
    busy_flg_b  : inout std_logic; --
    ack_flg_b   : inout std_logic; --
    arlo_flg_b  : inout std_logic; --
    ack_o       : out   std_logic; --
    cyc_o       : out   std_logic;
    err_o       : out   std_logic;
    rty_o       : out   std_logic;
    int_o       : out   std_logic;
    mode_o      : out   std_logic_vector(1 downto 0); --
    clk_en_o    : out   std_logic; --
    int_en_o    : out   std_logic; --
    addr_len_o  : out   std_logic; --
    msl_o       : out   std_logic; --
    tx_data_o   : out   std_logic_vector(7 downto 0); --
    gpo_o       : out   std_logic_vector((g_GPO_W - 1) downto 0); --
    sl_addr_o   : out   std_logic_vector(9 downto 0); --
    sys_clk_o   : out   std_logic_vector((g_WIDTH - 1) downto 0); --
    dat_o       : out   std_logic_vector((g_WIDTH - 1) downto 0) --
  );
end register_block;

architecture arch of register_block is

  subtype t_word is std_logic_vector((g_WIDTH - 1) downto 0);
  type memory_t is array((2 ** g_ADDR_WIDTH - 1) downto 0) of t_word;
  signal ram : memory_t;
  signal addr_reg : natural range 0 to (2 ** g_ADDR_WIDTH - 1);

begin

  -- Process
  process(clk_i)
  begin
    if rising_edge(clk_i) then

      ram(1)(7 downto 0) <= rx_data_i;

      ram(3)(7 downto 4) <= (rx_buff_e_i & rx_buff_f_i & tx_buff_e_i & tx_buff_f_i);
      ram(3)(3 downto 0) <= (int_flg_io & busy_flg_io & ack_flg_io & arlo_flg_io);

      if we_i = '1' then
        if addr_i /= 3 then
          ram(addr_i) <= dat_i;
        end if;
      end if;

      addr_reg <= addr_i;

    end if;
  end process;

  dat_o <= ram(addr_reg);

  tx_data_o <= ram(0)(7 downto 0);

  sys_clk_o <= ram(7);

  with ram(2)(3) select
    sl_addr_o <= ("000" & ram(6)(6 downto 0)) when '0',
                 ram(6)(9 downto 0) when others;

  int_flg_b  <= ram(3)(3);
  busy_flg_b <= ram(3)(2);
  ack_flg_b  <= ram(3)(1);
  ack_o      <= ram(3)(1);
  arlo_flg_b <= ram(3)(0);

  clk_en_o   <= ram(2)(5);
  int_en_o   <= ram(2)(4);
  addr_len_o <= ram(2)(3);
  mode_o     <= ram(2)(2 downto 1);
  msl_o      <= ram(2)(0);

  gpo_o      <= ram(7)((g_GPO_W - 1) downto 0);

end arch;

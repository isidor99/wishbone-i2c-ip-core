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
    clk_i           : in    std_logic; --
    rst_i           : in    std_logic; --
    we_i            : in    std_logic; --
    addr_i          : in    natural range 0 to (2 ** g_ADDR_WIDTH - 1); --
    dat_i           : in    std_logic_vector((g_WIDTH - 1) downto 0); --
    tx_buff_f_i     : in    std_logic; --
    tx_buff_e_i     : in    std_logic; --
    rx_buff_f_i     : in    std_logic; --
    rx_buff_e_i     : in    std_logic; --
    arb_lost_i      : in    std_logic; --
    ack_res_flg_i   : in    std_logic; --
    busy_flg_i      : in    std_logic; --
    intr_flg_i      : in    std_logic; --
    rx_data_i       : in    std_logic_vector(7 downto 0); --
    ack_o           : out   std_logic; --
    arb_lost_o      : out   std_logic; --
    int_o           : out   std_logic; --
    mode_o          : out   std_logic_vector(1 downto 0); --
    i2c_en_o        : out   std_logic; --
    int_en_o        : out   std_logic; --
    slv_addr_len_o  : out   std_logic; --
    msl_o           : out   std_logic; --
    tx_buff_wr_en_o : out   std_logic; --
	 rx_buff_rd_en_o : out   std_logic; --
    rd_slv_o        : out   std_logic; --
    wr_slv_o        : out   std_logic; --
    clr_intr_o      : out   std_logic; --
    tx_data_o       : out   std_logic_vector(7 downto 0); --
    gpo_o           : out   std_logic_vector((g_GPO_W - 1) downto 0); --
    slv_addr_o      : out   std_logic_vector(9 downto 0); --
    sys_clk_o       : out   std_logic_vector((g_WIDTH - 1) downto 0); --
    dat_o           : out   std_logic_vector((g_WIDTH - 1) downto 0) --
  );
end register_block;

architecture arch of register_block is

  constant c_50_MHz : std_logic_vector(31 downto 0) := "10000000000000000000000000110010";

  subtype t_word is std_logic_vector((g_WIDTH - 1) downto 0);
  type memory_t is array((2 ** g_ADDR_WIDTH - 1) downto 0) of t_word;
  signal ram : memory_t := (7 => c_50_MHz, others => (others => '0'));

begin

  -- Process
  process (clk_i)
  begin
    if rst_i = '1' then

      ram(0) <= (others => '0');
      ram(1) <= (others => '0');
      ram(2) <= (0 => '1', others => '0');
      ram(3) <= (others => '0');
		ram(4) <= (others => '0');
		ram(5) <= (others => '0');
		ram(6) <= (others => '0');
		ram(7) <= c_50_MHz;

    elsif rising_edge(clk_i) then

      -- get data from rx buffer
      ram(1)(7 downto 0) <= rx_data_i;

      -- get status data from rx and tx buffer
      ram(3)(7 downto 4) <= (rx_buff_e_i & rx_buff_f_i & tx_buff_e_i & tx_buff_f_i);

      -- get interrupt data
		ram(3)(3 downto 0) <= (intr_flg_i & busy_flg_i & ack_res_flg_i & arb_lost_i);

      -- write or read data from wishbone master side
      if we_i = '1' then
        ram(addr_i) <= dat_i;
      else 
        dat_o <= ram(addr_i);
      end if;
    end if;
  end process;

  -- write data to tx buffer
  -- write is completed if tx buffer write is enabled
  tx_data_o <= ram(0)(7 downto 0);

  -- sys clock register
  sys_clk_o <= ram(7);

  -- select slave address
  with ram(2)(3) select
    slv_addr_o <= ("000" & ram(6)(6 downto 0)) when '0',
                  ram(6)(9 downto 0) when others;

  -- get flags from status register
  int_o      <= ram(3)(3);
  ack_o      <= ram(3)(1);
  arb_lost_o <= ram(3)(0);

  -- control register signals
  i2c_en_o       <= ram(2)(5);
  int_en_o       <= ram(2)(4);
  slv_addr_len_o <= ram(2)(3);
  mode_o         <= ram(2)(2 downto 1);
  msl_o          <= ram(2)(0);

  -- general purpose register
  gpo_o      <= ram(6)((g_GPO_W - 1) downto 0);

  -- command register signals
  tx_buff_wr_en_o <= '0' when ram(3)(4) = '1' else
                     ram(4)(3);
  rx_buff_rd_en_o <= '0' when ram(3)(7) = '1' else
                     ram(4)(4);
  rd_slv_o   <= ram(4)(0);
  wr_slv_o   <= ram(4)(1);
  clr_intr_o <= ram(4)(2);

end arch;

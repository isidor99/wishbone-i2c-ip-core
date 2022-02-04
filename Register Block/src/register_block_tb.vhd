----------------------------------------------------------------------------
-- ETF BL
-- Wishbone I2C
-----------------------------------------------------------------------------
--
--    unit    name:                        register_block_tb
--
--    description:
--
--              This is test bench for top-level entity.
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

use work.register_pkg.all;

entity register_block_tb is
end register_block_tb;

architecture arch of register_block_tb is

  component register_block is
    generic
    (
      g_WIDTH      : natural := 32;
      g_ADDR_WIDTH : natural := 3;
      g_GPO_W      : natural := 8
    );
    port
    (
      clk_i           : in    std_logic;
      rst_i           : in    std_logic;
      we_i            : in    std_logic;
      addr_i          : in    natural range 0 to (2 ** g_ADDR_WIDTH - 1);
      dat_i           : in    std_logic_vector((g_WIDTH - 1) downto 0);
      tx_buff_f_i     : in    std_logic;
      tx_buff_e_i     : in    std_logic;
      rx_buff_f_i     : in    std_logic;
      rx_buff_e_i     : in    std_logic;
      arb_lost_i      : in    std_logic;
      ack_res_flg_i   : in    std_logic;
      busy_flg_i      : in    std_logic;
      intr_flg_i      : in    std_logic;
      rx_data_i       : in    std_logic_vector(7 downto 0);
      ack_o           : out   std_logic;
      arb_lost_o      : out   std_logic;
      int_o           : out   std_logic;
      mode_o          : out   std_logic_vector(1 downto 0);
      bytes_to_tran_o : out   std_logic_vector(3 downto 0);
      i2c_en_o        : out   std_logic;
      int_en_o        : out   std_logic;
      slv_addr_len_o  : out   std_logic;
      msl_o           : out   std_logic;
      tx_buff_wr_en_o : out   std_logic;
      rx_buff_rd_en_o : out   std_logic;
      rep_strt_o      : out   std_logic;
      clr_intr_o      : out   std_logic;
      tx_data_o       : out   std_logic_vector(7 downto 0);
      gpo_o           : out   std_logic_vector((g_GPO_W - 1) downto 0);
      slv_addr_o      : out   std_logic_vector(9 downto 0);
      sys_clk_o       : out   std_logic_vector((g_WIDTH - 1) downto 0);
      dat_o           : out   std_logic_vector((g_WIDTH - 1) downto 0)
    );
  end component;

  signal stop  : std_logic := '0';
  signal h_val : std_logic_vector(31 downto 0) := (others => '0');

  signal clk_test           : std_logic;
  signal rst_test           : std_logic;
  signal we_test            : std_logic;
  signal addr_test          : natural range 0 to (2 ** c_ADDR_WIDTH - 1);
  signal dat_i_test         : std_logic_vector((c_WIDTH - 1) downto 0);
  signal tx_buff_f_test     : std_logic;
  signal tx_buff_e_test     : std_logic;
  signal rx_buff_f_test     : std_logic;
  signal rx_buff_e_test     : std_logic;
  signal arb_lost_i_test    : std_logic;
  signal ack_res_flg_test   : std_logic;
  signal busy_flg_test      : std_logic;
  signal intr_flg_test      : std_logic;
  signal rx_data_test       : std_logic_vector(7 downto 0);
  signal ack_test           : std_logic;
  signal arb_lost_o_test    : std_logic;
  signal int_test           : std_logic;
  signal mode_test          : std_logic_vector(1 downto 0);
  signal bytes_to_tran_test : std_logic_vector(3 downto 0);
  signal i2c_en_test        : std_logic;
  signal int_en_test        : std_logic;
  signal slv_addr_len_test  : std_logic;
  signal msl_test           : std_logic;
  signal tx_buff_wr_en_test : std_logic;
  signal rx_buff_rd_en_test : std_logic;
  signal rep_strt_test      : std_logic;
  signal clr_intr_test      : std_logic;
  signal tx_data_test       : std_logic_vector(7 downto 0);
  signal gpo_test           : std_logic_vector((c_GPO_W - 1) downto 0);
  signal slv_addr_test      : std_logic_vector(9 downto 0);
  signal sys_clk_test       : std_logic_vector((c_WIDTH - 1) downto 0);
  signal dat_o_test         : std_logic_vector((c_WIDTH - 1) downto 0);

begin

  uut : register_block
    generic map
    (
      g_WIDTH      => c_WIDTH,
      g_ADDR_WIDTH => c_ADDR_WIDTH,
      g_GPO_W      => c_GPO_W
    )
    port map
    (
      clk_i           => clk_test,
      rst_i           => rst_test,
      we_i            => we_test,
      addr_i          => addr_test,
      dat_i           => dat_i_test,
      tx_buff_f_i     => tx_buff_f_test,
      tx_buff_e_i     => tx_buff_e_test,
      rx_buff_f_i     => rx_buff_f_test,
      rx_buff_e_i     => rx_buff_e_test,
      arb_lost_i      => arb_lost_i_test,
      ack_res_flg_i   => ack_res_flg_test,
      busy_flg_i      => busy_flg_test,
      intr_flg_i      => intr_flg_test,
      rx_data_i       => rx_data_test,
      ack_o           => ack_test,
      arb_lost_o      => arb_lost_o_test,
      int_o           => int_test,
      mode_o          => mode_test,
      bytes_to_tran_o => bytes_to_tran_test,
      i2c_en_o        => i2c_en_test,
      int_en_o        => int_en_test,
      slv_addr_len_o  => slv_addr_len_test,
      msl_o           => msl_test,
      tx_buff_wr_en_o => tx_buff_wr_en_test,
      rx_buff_rd_en_o => rx_buff_rd_en_test,
      rep_strt_o      => rep_strt_test,
      clr_intr_o      => clr_intr_test,
      tx_data_o       => tx_data_test,
      gpo_o           => gpo_test,
      slv_addr_o      => slv_addr_test,
      sys_clk_o       => sys_clk_test,
      dat_o           => dat_o_test
    );

  -- stimulus generator
  process
  begin

    clk_test <= '0';
    wait for c_TIME / 2;
    clk_test <= '1';
    wait for c_TIME / 2;

    if stop = '1' then
      wait;
    end if;

  end process;

  -- verifier process
  process
  begin

    -- write test data
    we_test          <= '0';
    addr_test        <= 0;
    rst_test         <= '0';
    rx_buff_e_test   <= '1';
    rx_buff_f_test   <= '0';
    tx_buff_e_test   <= '1';
    tx_buff_f_test   <= '0';
    intr_flg_test    <= '0';
    busy_flg_test    <= '0';
    ack_res_flg_test <= '1';
    arb_lost_i_test  <= '0';
    rx_data_test     <= "00001111";
    dat_i_test       <= c_TEST_DATA_IN;

    -- test TX register
    wait until rising_edge(clk_test);

    we_test <= '1';

    wait until rising_edge(clk_test);
    wait for 2 ns;

    we_test <= '0';

    assert (unsigned(tx_data_test) = unsigned(c_TEST_DATA_IN(7 downto 0)))
      report "TX Register not ok. Expected TX buffer data in to be " &
             integer'image(to_integer(unsigned(c_TEST_DATA_IN(7 downto 0)))) & " but it is " &
             integer'image(to_integer(unsigned(tx_data_test)))
      severity error;

    wait until rising_edge(clk_test);
    wait for 2 ns;

    assert (dat_o_test = c_TEST_DATA_IN)
      report "TX Register not ok. Expected " &
             integer'image(to_integer(unsigned(c_TEST_DATA_IN))) &
             " but found " & integer'image(to_integer(unsigned(dat_o_test)))
      severity error;

    -- test RX register
    addr_test <= 1;

    wait until rising_edge(clk_test);
    wait for 2 ns;

    assert (dat_o_test = c_TEST_RX_DATA)
      report "RX Register not ok. Expected " &
             integer'image(to_integer(unsigned(c_TEST_RX_DATA))) &
             " but found " & integer'image(to_integer(unsigned(dat_o_test)))
      severity error;

    -- test CONTROL register
    addr_test  <= 2;
    dat_i_test <= c_CTRL_REG_VAL;
    we_test    <= '1';

    wait until rising_edge(clk_test);
    wait for 2 ns;

    assert (msl_test = '1')
      report "CONTROL register not ok. Expected bit0 value to be 1, but it is 0"
      severity error;

    assert (mode_test = "01")
      report "CONTROL register not ok. Expected bit[2..1] value to be 1, but it is " &
             integer'image(to_integer(unsigned(mode_test)))
      severity error;

    assert (slv_addr_len_test = '0')
      report "CONTROL register not ok. Expected bit3 value to be 0, but it is 1"
      severity error;

    assert (int_en_test = '1')
      report "CONTROL register not ok. Expected bit4 value to be 1, but it is 0"
      severity error;

    assert (i2c_en_test = '1')
      report "CONTROL register not ok. Expected bit5 value to be 1, but it is 0"
      severity error;

    we_test <= '0';

    -- test STATUS register
    addr_test <= 3;
    h_val     <= (1 | 5 | 7 => '1', others => '0');

    wait until rising_edge(clk_test);
    wait for 2 ns;

    -- default status register value
    assert (dat_o_test = h_val)
      report "STATUS Register not ok. Expected " &
             integer'image(to_integer(unsigned(h_val))) &
             " but found " & integer'image(to_integer(unsigned(dat_o_test)))
      severity error;

    rx_buff_e_test <= '0';
    tx_buff_e_test <= '0';

    h_val(5) <= '0';
    h_val(7) <= '0';

    wait until rising_edge(clk_test);
    wait for 2 ns;

    intr_flg_test    <= '1';
    busy_flg_test    <= '1';
    ack_res_flg_test <= '0';
    arb_lost_i_test  <= '1';

    wait until rising_edge(clk_test);
    wait for 2 ns;

    assert (dat_o_test = h_val)
      report "STATUS Register not ok. Expected " &
             integer'image(to_integer(unsigned(h_val))) &
             " but found " & integer'image(to_integer(unsigned(dat_o_test)))
      severity error;

    h_val(3 downto 0) <= "1101";

    wait until rising_edge(clk_test);
    wait for 2 ns;

    assert (dat_o_test = h_val)
      report "STATUS Register not ok. Expected " &
             integer'image(to_integer(unsigned(h_val))) &
             " but found " & integer'image(to_integer(unsigned(dat_o_test)))
      severity error;

    -- test COMMAND register
    addr_test <= 4;
    dat_i_test <= c_CMD_REP_STRT;
    we_test    <= '1';

    wait until rising_edge(clk_test);
    wait for 2 ns;

    assert (rep_strt_test = '1')
      report "COMMAND register not ok. Expected bit0 value to be 1, but it is 0"
      severity error;

--    dat_i_test <= c_CMD_WR_SLV;
--
--    wait until rising_edge(clk_test);
--    wait for 2 ns;
--
--    assert (wr_slv_test = '1')
--      report "COMMAND register not ok. Expected bit1 value to be 1, but it is 0"
--      severity error;

    dat_i_test <= c_CMD_CLR_INT;

    wait until rising_edge(clk_test);
    wait for 2 ns;

    assert (clr_intr_test = '1')
      report "COMMAND register not ok. Expected bit1 value to be 1, but it is 0"
      severity error;

    dat_i_test <= c_CMD_BUFF_OP;

    wait until rising_edge(clk_test);
    wait for 2 ns;

    assert (tx_buff_wr_en_test = '1')
      report "COMMAND register not ok. Expected bit2 value to be 1, but it is 0"
      severity error;

    assert (rx_buff_rd_en_test = '1')
      report "COMMAND register not ok. Expected bit3 value to be 1, but it is 0"
      severity error;

    dat_i_test <= c_CMD_BTT;

    wait until rising_edge(clk_test);
    wait for 2 ns;

    assert (bytes_to_tran_test = c_CMD_BTT(t_BYTE_TO_TRAN))
      report "COMMAND register not ok. Error with bytes to transfer"
      severity error;

    -- test SLAVE ADDRESS register
    dat_i_test             <= (others => '0');
    dat_i_test(9 downto 0) <= c_SLV_ADDR;
    addr_test              <= 5;

    wait until rising_edge(clk_test);
    wait for 2 ns;

    assert (unsigned(slv_addr_test) = unsigned(c_SLV_ADDR(6 downto 0)))
      report "SLAVE ADDRESS register not ok. 7 bit address expected to be " &
             integer'image(to_integer(unsigned(c_SLV_ADDR(6 downto 0)))) &
             " but it is " &
             integer'image(to_integer(unsigned(dat_o_test(6 downto 0))))
      severity error;

    addr_test     <= 2;
    dat_i_test    <= c_CTRL_REG_VAL;
    dat_i_test(3) <= '1';
    we_test       <= '1';

    wait until rising_edge(clk_test);
    wait for 2 ns;

    assert (unsigned(slv_addr_test) = unsigned(c_SLV_ADDR))
      report "SLAVE ADDRESS register not ok. 10 bit address expected to be " &
             integer'image(to_integer(unsigned(c_SLV_ADDR(9 downto 0)))) &
             " but it is " &
             integer'image(to_integer(unsigned(dat_o_test(9 downto 0))))
      severity error;

    -- test GPO register
    addr_test <= 6;
    we_test   <= '1';

    dat_i_test                         <= (others => '0');
    dat_i_test((c_GPO_W - 1) downto 0) <= c_GPO_VAL;

    wait until rising_edge(clk_test);
    wait for 2 ns;

    we_test <= '0';

    wait until rising_edge(clk_test);
    wait for 2 ns;

    assert (unsigned(dat_o_test) = unsigned(c_GPO_VAL))
      report "GPO register not ok. Expected value to be " &
             integer'image(to_integer(unsigned(c_GPO_VAL))) &
             " but it is " &
             integer'image(to_integer(unsigned(dat_o_test)))
      severity error;

    -- test SYSCLK register
    addr_test <= 7;

    wait until rising_edge(clk_test);
    wait for 2 ns;

    assert (dat_o_test = c_CLOCK_DATA)
      report "SYSCLK register not ok. Expected value to be " &
             integer'image(to_integer(unsigned(c_CLOCK_DATA))) &
             " but it is " &
             integer'image(to_integer(unsigned(dat_o_test)))
      severity error;

    wait until rising_edge(clk_test);

    assert (1 = 2)
      report "Test completed."
      severity note;

    stop <= '1';
    wait;

  end process;
end arch;

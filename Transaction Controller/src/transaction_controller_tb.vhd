-----------------------------------------------------------------------------
-- ETF BL
-- Wishbone I2C
-----------------------------------------------------------------------------
--
--    unit name: transaction_controller_tb
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

entity transaction_controller_tb is
end transaction_controller_tb;

architecture arch of transaction_controller_tb is

  component transaction_controller is
    port
    (
      clk_i          : in    std_logic;
      rst_i          : in    std_logic;
      enbl_i         : in    std_logic;
      rep_strt_i     : in    std_logic;
      slv_addr_len_i : in    std_logic;
      msl_sel_i      : in    std_logic;
      scl_i          : in    std_logic;
      tx_buff_e_i    : in    std_logic;
      rx_buff_f_i    : in    std_logic;
      byte_count_i   : in    std_logic_vector(3 downto 0);
      slv_addr_i     : in    std_logic_vector(9 downto 0);
      tx_data_i      : in    std_logic_vector(7 downto 0);
      mode_i         : in    std_logic_vector(1 downto 0);
      sysclk_i       : in    std_logic_vector(31 downto 0);
      sda_b          : inout std_logic;
      tx_rd_enbl_o   : out   std_logic;
      rx_wr_enbl_o   : out   std_logic;
      rx_data_o      : out   std_logic_vector(7 downto 0);
      busy_flg_o     : out   std_logic;
      ack_flg_o      : out   std_logic;
      clk_enbl_o     : out   std_logic;
      arb_lost_flg_o : out   std_logic
    );
  end component transaction_controller;

  constant c_TIME     : time := 20 ns;
  constant c_TIME_SCL : time := 10 us;
  constant c_SYS_CLK  : std_logic_vector := "10000000000000000000000000110010";

  signal stop : std_logic := '0';

  signal clk_test          : std_logic;
  signal rst_test          : std_logic;
  signal enbl_test         : std_logic;
  signal rep_strt_test     : std_logic;
  signal slv_addr_len_test : std_logic;
  signal msl_sel_test      : std_logic;
  signal scl_test          : std_logic;
  signal tx_buff_e_test    : std_logic;
  signal rx_buff_f_test    : std_logic;
  signal byte_count_test   : std_logic_vector(3 downto 0);
  signal slv_addr_test     : std_logic_vector(9 downto 0);
  signal tx_data_test      : std_logic_vector(7 downto 0);
  signal mode_test         : std_logic_vector(1 downto 0);
  signal sysclk_test       : std_logic_vector(31 downto 0);
  signal sda_test          : std_logic;
  signal tx_rd_enbl_test   : std_logic;
  signal rx_wr_enbl_test   : std_logic;
  signal rx_data_test      : std_logic_vector(7 downto 0);
  signal busy_flg_test     : std_logic;
  signal ack_flg_test      : std_logic;
  signal clk_enbl_test     : std_logic;
  signal arb_lost_flg_test : std_logic;

  signal tmp        : std_logic := '0';
  signal slave_data : std_logic_vector(7 downto 0);

begin

  uut : transaction_controller
    port map
    (
      clk_i          => clk_test,
      rst_i          => rst_test,
      enbl_i         => enbl_test,
      rep_strt_i     => rep_strt_test,
      slv_addr_len_i => slv_addr_len_test,
      msl_sel_i      => msl_sel_test,
      scl_i          => scl_test,
      tx_buff_e_i    => tx_buff_e_test,
      rx_buff_f_i    => rx_buff_f_test,
      byte_count_i   => byte_count_test,
      slv_addr_i     => slv_addr_test,
      tx_data_i      => tx_data_test,
      mode_i         => mode_test,
      sysclk_i       => sysclk_test,
      sda_b          => sda_test,
      tx_rd_enbl_o   => tx_rd_enbl_test,
      rx_wr_enbl_o   => rx_wr_enbl_test,
      rx_data_o      => rx_data_test,
      busy_flg_o     => busy_flg_test,
      ack_flg_o      => ack_flg_test,
      clk_enbl_o     => clk_enbl_test,
      arb_lost_flg_o => arb_lost_flg_test
    );

  sysclk_test <= c_SYS_CLK;

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

  -- stimulus generator for scl
  -- Count process
  process(clk_test, clk_enbl_test)
    variable count : integer := 0;
  begin
    if clk_enbl_test = '0' then
      count := 0;
    end if;

    if rising_edge(clk_test) then
      if count /= 250 then
        count := count + 1;
        tmp <= tmp;
      else
        count := 0;
        tmp <= not tmp;
      end if;
    end if;
  end process;

  scl_test <= '1' when clk_enbl_test = '0' else tmp;

  -- main process
  process

    procedure check_transmit (
      constant tx_data_test : in std_logic_vector(7 downto 0)
    ) is
    begin

      for i in 7 downto 0 loop
        wait until rising_edge(scl_test);

        assert (sda_test = tx_data_test(i))
          report "Transaction controller not ok. Error transmitting on bit" &
                 integer'image(i)
          severity error;
      end loop;

    end check_transmit;

    procedure write_on_sda (
      constant data : in std_logic_vector(7 downto 0)
    ) is
    begin

      for i in 7 downto 0 loop
        wait until falling_edge(scl_test);
        sda_test <= slave_data(i);
      end loop;

    end write_on_sda;

    procedure check_ack is
    begin

      wait until sda_test = 'Z';
      sda_test <= '0';
      wait until rising_edge(scl_test);
      sda_test <= 'Z';

      assert (ack_flg_test = '0')
        report "ACK not ok"
        severity error;

    end check_ack;

  begin

    rst_test          <= '0';
    enbl_test         <= '0';
    rep_strt_test     <= '0';
    slv_addr_len_test <= '0';
    msl_sel_test      <= '0';
    tx_buff_e_test    <= '0';
    rx_buff_f_test    <= '0';
    byte_count_test   <= "0000";
    slv_addr_test     <= "0000101010";
    tx_data_test      <= "00000000";
    mode_test         <= "00";
    sda_test          <= 'Z';
    slave_data        <= "10011001";

    wait until rising_edge(clk_test);
    wait for 50 * c_TIME;

    enbl_test <= '1';
    byte_count_test <= "0010";

    wait until rising_edge(clk_test);
    wait for 2 ns;

    wait until falling_edge(tx_rd_enbl_test);

    tx_data_test <= "10110010";
    byte_count_test <= "0000";

    wait until rising_edge(clk_test);

    -- check address
    check_transmit(tx_data_test);
    check_ack;

    wait until falling_edge(tx_rd_enbl_test);

    tx_data_test <= "01101011";
    wait until rising_edge(clk_test);

    rep_strt_test <= '1';

    -- transmit two bytes and check
    for j in 0 to 1 loop
      check_transmit(tx_data_test);
      check_ack;
    end loop;

    wait until falling_edge(clk_enbl_test);

    -- set new address
    tx_data_test    <= "10110011";
    rep_strt_test   <= '0';
    byte_count_test <= "0010";

    wait until sda_test = 'Z';
    wait until falling_edge(scl_test);

    -- check address
    check_transmit(tx_data_test);
    check_ack;

    -- read from slave
    -- this test simulates slave
    -- send some data on falling edge of scl
    byte_count_test <= "0000";

    for j in 0 to 1 loop

      wait until sda_test = 'Z';
      sda_test <= '0';

      write_on_sda(slave_data);

      wait until falling_edge(scl_test);
      sda_test <= 'Z';

      wait until rising_edge(rx_wr_enbl_test);
      wait for 2 ns;

      -- check RX buffer
      assert (rx_data_test = slave_data)
        report "Reading from slave not ok. Data not read correctly."
        severity error;
    end loop;

    wait for 50 us;
    stop <= '1';
    wait;

  end process;

end arch;

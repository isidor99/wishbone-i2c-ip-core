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
      i2c_start_i    : in    std_logic;
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

  type t_vector is array (natural range <>) of std_logic_vector(7 downto 0);

  constant c_TIME     : time := 20 ns;
  constant c_TIME_SCL : time := 10 us;
  constant c_SYS_CLK  : std_logic_vector := "10000000000000000000000000110010";

  constant c_SLV_DATA : t_vector :=
    (
      "10001111",
      "01110100"
    );

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
  signal i2c_start_test    : std_logic;
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

  signal tmp_1       : std_logic := '0';
  signal tmp_2       : std_logic := '0';
  signal slave_data : std_logic_vector(7 downto 0);
  signal gen_clk    : std_logic := '0';

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
      i2c_start_i    => i2c_start_test,
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
  -- count process
  process(clk_test, clk_enbl_test)
    variable count : integer := 0;
  begin
    if clk_enbl_test = '0' then
      count := 0;
      tmp_1 <= '1';
    end if;

    if rising_edge(clk_test) then
      if count /= 250 then
        count := count + 1;
        tmp_1 <= tmp_1;
      else
        count := 0;
        tmp_1 <= not tmp_1;
      end if;
    end if;
  end process;

  -- stimulus generator for scl
  -- count process
  process(clk_test, gen_clk)
    variable count : integer := 0;
  begin
    if gen_clk = '0' then
      count := 0;
      tmp_2 <= '1';
    end if;

    if rising_edge(clk_test) then
      if count /= 250 then
        count := count + 1;
        tmp_2 <= tmp_2;
      else
        count := 0;
        tmp_2 <= not tmp_2;
      end if;
    end if;
  end process;

  -- scl_test <= '1' when clk_enbl_test = '0' else tmp;
  scl_test <= tmp_2 when msl_sel_test = '1' else tmp_1;

  -- main process
  process

    -- PROCEDURE
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

    -- PROCEDURE
    procedure write_on_sda (
      constant data : in std_logic_vector(7 downto 0)
    ) is
    begin

      for i in 7 downto 0 loop
        wait until falling_edge(scl_test);
        sda_test <= slave_data(i);
      end loop;
    end write_on_sda;

    -- PROCEDURE
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

    -- PROCEDURE
    procedure init_slave_comm (
      constant slv_addr : in std_logic_vector(6 downto 0);
      constant rw_bit   : in std_logic
    ) is
    begin

      -- slave part
      -- select slave
      i2c_start_test <= '1';
      msl_sel_test <= '1';

      wait until rising_edge(clk_test);
      wait for 2 ns;

      wait until falling_edge(tx_rd_enbl_test);

      -- set number of bytes to transfer
      tx_data_test <= "00000010";
      i2c_start_test <= '0';

      -- drive down SDA
      -- prepare start condition
      sda_test <= '1';
      wait until rising_edge(clk_test);
      wait for 5 * c_TIME;
      sda_test <= '0';
      wait for 120 * c_TIME;

      -- start generation of SCL
      gen_clk <= '1';

      -- synchronize
      wait until falling_edge(scl_test);

      -- transmit address
      for i in 6 downto 0 loop
        sda_test <= slv_addr(i);
        wait until falling_edge(scl_test);
      end loop;

      -- write bit
      sda_test <= rw_bit;
      wait until falling_edge(scl_test);

      -- wait for ACK
      sda_test <= 'Z';
      wait until rising_edge(scl_test);

      -- check ACK
      assert (sda_test = '0')
        report "ACK not OK. Address not confirmed."
        severity error;
    end init_slave_comm;

    -- PROCEDURE
    procedure generate_stop is
    begin

      -- generate stop condition
      gen_clk  <= '0';
      sda_test <= '0';
      wait for 250 * c_TIME;
      sda_test <= '1';
      wait for 5 * c_TIME;
      sda_test <= 'Z';
    end generate_stop;

  begin

    rst_test          <= '0';
    enbl_test         <= '0';
    rep_strt_test     <= '0';
    slv_addr_len_test <= '0';
    msl_sel_test      <= '0';
    tx_buff_e_test    <= '0';
    rx_buff_f_test    <= '0';
    slv_addr_test     <= "0000101010";
    tx_data_test      <= "00000000";
    mode_test         <= "00";
    sda_test          <= 'Z';
    slave_data        <= "10011001";

    wait until rising_edge(clk_test);
    wait for 50 * c_TIME;

    enbl_test <= '1';
    i2c_start_test <= '1';

    wait until rising_edge(clk_test);
    wait for 2 ns;

    wait until falling_edge(tx_rd_enbl_test);

    tx_data_test <= "00000010";
    i2c_start_test <= '0';

    wait until falling_edge(tx_rd_enbl_test);

    tx_data_test <= "10110010";

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

    -- set new number of bytes
    wait until falling_edge(tx_rd_enbl_test);

    tx_data_test <= "00000010";

    -- wait until falling_edge(clk_enbl_test);

    -- set new address
    wait until falling_edge(tx_rd_enbl_test);

    tx_data_test    <= "10110011";
    rep_strt_test   <= '0';

    -- wait until sda_test = 'Z';
    wait until falling_edge(scl_test);

    -- check address
    check_transmit(tx_data_test);
    check_ack;

    -- read from slave
    -- this test simulates slave
    -- send some data on falling edge of scl
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

    -- time delay between two tests
    wait for 200 us;

    -- init communication with slave
    init_slave_comm("0101010", '0');

    for i in 0 to 1 loop

      -- drive sda low until next falling edge of SCL
      sda_test <= '0';
      slave_data <= c_SLV_DATA(i);

      -- shift first seven bits
      for i in 7 downto 1 loop
        wait until falling_edge(scl_test);
        sda_test <= slave_data(i);
      end loop;

      -- shift last bit
      wait until falling_edge(scl_test);
      sda_test <= slave_data(0);

      -- wait for ACK
      wait until falling_edge(scl_test);
      sda_test <= 'Z';
      wait until rising_edge(scl_test);

      -- check ACK
      assert (sda_test = '0')
        report "ACK not OK. Address not confirmed."
        severity error;

      -- drive sda low until next falling edge of SCL
      sda_test <= '0';

      -- check rx data
      wait until rising_edge(rx_wr_enbl_test);
      wait for 2 ns;

      assert (rx_data_test = slave_data)
        report "Writting to slave not ok. Data not write correctly."
        severity error;

    end loop;

    -- wait tx
    wait until falling_edge(rx_wr_enbl_test);
    wait until falling_edge(scl_test);
    wait for 500 ns;

    generate_stop;

    -- time delay between two tests
    wait for 200 us;

    -- start new transmission
    -- init communication with slave
    init_slave_comm("0101010", '1');

    for i in 0 to 1 loop

      wait until falling_edge(tx_rd_enbl_test);
      tx_data_test <= c_SLV_DATA(i);

      check_transmit(tx_data_test);

      -- send ack
      wait until falling_edge(scl_test);
      wait until sda_test = 'Z';
      sda_test <= '0';
      wait until rising_edge(scl_test);
      sda_test <= 'Z';

    end loop;

    generate_stop;

    wait for 500 us;
    stop <= '1';
    wait;

  end process;

end arch;

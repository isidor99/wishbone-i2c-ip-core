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

entity transaction_controller_tb is
end transaction_controller_tb;

architecture arch of transaction_controller_tb is

  component transaction_controller is
    port
    (
      clk_i          : in std_logic;
      rst_i          : in std_logic;
      enbl_i         : in std_logic;
      wr_slv_i       : in std_logic;
      rd_slv_i       : in std_logic;
      rep_strt_i     : in std_logic;
      slv_addr_len_i : in std_logic;
      msl_sel_i      : in std_logic;
      scl_i          : in std_logic;
      tx_buff_e_i    : in std_logic;
      slv_addr_i     : in std_logic_vector(9 downto 0);
      tx_data_i      : in std_logic_vector(7 downto 0);
      mode_i         : in std_logic_vector(1 downto 0);
      sysclk_i       : in std_logic_vector(31 downto 0);
      sda_b          : inout std_logic;
      tx_rd_enbl_o   : out std_logic;
      rx_wr_enbl_o   : out std_logic;
      rx_data_o      : out std_logic;
      busy_flg_o     : out std_logic;
      ack_flg_o      : out std_logic;
      clk_enbl_o     : out std_logic;
      arb_lost_flg_o : out std_logic
    );
  end component transaction_controller;

  constant c_TIME     : time := 20 ns;
  constant c_TIME_SCL : time := 10 us;
  constant c_SYS_CLK  : std_logic_vector := "10000000000000000000000000110010";

  signal stop : std_logic := '0';

  signal clk_test          : std_logic;
  signal rst_test          : std_logic;
  signal enbl_test         : std_logic;
  signal wr_slv_test       : std_logic;
  signal rd_slv_test       : std_logic;
  signal rep_strt_test     : std_logic;
  signal slv_addr_len_test : std_logic;
  signal msl_sel_test      : std_logic;
  signal scl_test          : std_logic;
  signal tx_buff_e_test    : std_logic;
  signal slv_addr_test     : std_logic_vector(9 downto 0);
  signal tx_data_test      : std_logic_vector(7 downto 0);
  signal mode_test         : std_logic_vector(1 downto 0);
  signal sysclk_test       : std_logic_vector(31 downto 0);
  signal sda_test          : std_logic;
  signal tx_rd_enbl_test   : std_logic;
  signal rx_wr_enbl_test   : std_logic;
  signal rx_data_test      : std_logic;
  signal busy_flg_test     : std_logic;
  signal ack_flg_test      : std_logic;
  signal clk_enbl_test     : std_logic;
  signal arb_lost_flg_test : std_logic;

begin

  uut : transaction_controller
    port map
    (
      clk_i          => clk_test,
      rst_i          => rst_test,
      enbl_i         => enbl_test,
      wr_slv_i       => wr_slv_test,
      rd_slv_i       => rd_slv_test,
      rep_strt_i     => rep_strt_test,
      slv_addr_len_i => slv_addr_len_test,
      msl_sel_i      => msl_sel_test,
      scl_i          => scl_test,
      tx_buff_e_i    => tx_buff_e_test,
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
  process
  begin

    if clk_enbl_test = '1' then
      scl_test <= '0';
      wait for c_TIME_SCL / 2;
      scl_test <= '1';
      wait for c_TIME_SCL / 2;
    else
      scl_test <= '1';
      wait for c_TIME_SCL / 2;
    end if;

    if stop = '1' then
      wait;
    end if;

  end process;

  -- main process
  process
  begin

    rst_test       <= '0';
    wr_slv_test    <= '0';
	 rd_slv_test    <= '0';
    enbl_test      <= '1';
    tx_buff_e_test <= '1';

    wait until rising_edge(clk_test);

    wr_slv_test <= '1';

    wait until rising_edge(clk_test);

    tx_buff_e_test <= '0';

    wait until rising_edge(tx_rd_enbl_test);
    wait until rising_edge(clk_test);

    tx_data_test <= "00110011";

    wait until rising_edge(clk_test);


    stop <= '1';
    wait;

  end process;

end arch;

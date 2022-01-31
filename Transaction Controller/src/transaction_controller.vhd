-----------------------------------------------------------------------------
-- ETF BL
-- Wishbone I2C
-----------------------------------------------------------------------------
--
--    unit name:transaction_controller
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

entity transaction_controller is
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
    slv_addr_i     : in std_logic_vector(9 downto 0);
	 tx_data_i      : in std_logic_vector(7 downto 0);
	 sda_o          : out std_logic;
	 tx_rd_enbl_o   : out std_logic;
	 rx_wr_enbl_o   : out std_logic;
	 rx_data_o      : out std_logic;
	 busy_flg_o     : out std_logic;
	 ack_flg_o      : out std_logic;
	 clk_enbl_o     : out std_logic;
	 arb_lost_flg_o : out std_logic
	);
  end transaction_controller;
  
architecture arch of transaction_controller is

  type t_state is (idle, enbl_tx, load, sda_low, scl_low, sda_high, scl_high, write_op, wait_ack, read_op, send_ack, enbl_rx, store);
  signal state_reg, state_next : t_state;
  
  signal data_clk      : STD_LOGIC;                      --data clock for sda
  signal data_clk_prev : STD_LOGIC;                      --data clock during previous system clock
  
  
  
  begin

  -- control path: state register
  process(clk_i, reset_i, scl_i)
  begin
    if reset_i = '1' then
      state_reg <= idle;
    elsif rising_edge(clk_i) then
      data_clk_prev <= data_clk;
		data_clk <= scl_i;
      state_reg <= state_next;
    end if;
  end process;

  -- control path: next-state/ output logic
  process(state_reg, data_clk, data_clk_prev, w_is_0, global_count_is_0)
  begin
    case state_reg is
      when idle =>
        if start_i = '1' then
          state_next <= load;
        else
          state_next <= idle;
        end if;
      when load =>
        if w_is_0 = '1' then
          state_next <= zero;
        else
          state_next <= one;
        end if;
      when one =>
        if count_is_0 = '1' then
          state_next <= zero;
        else
          state_next <= one;
        end if;
      when zero =>
        if global_count_is_0 = '1' then
          state_next <= idle;
        else
          state_next <= zero;
        end if;
    end case;
  end process;
  -- data path: data register
  process(clk_i, reset_i)
  begin
    if reset_i = '1' then
      w_reg <= (others => '0');
      c_reg <= (others => '0');
      g_reg <= (others => '0');
      pwm_reg <= '0';
    elsif rising_edge(clk_i) then
      w_reg <= w_next;
      c_reg <= c_next;
      g_reg <= g_next;
      pwm_reg <= pwm_next;
    end if;
  end process;
  -- data path: routing multipexer
  process(state_reg, w_reg, c_reg, g_reg,
          pwm_reg, w_i, counter, global_counter)
  begin
    case state_reg is
      when idle =>
        w_next <= w_reg;
        c_next <= c_reg;
        g_next <= g_reg;
        pwm_next <= '0';
      when load =>
        w_next <= w_i;
        c_next <= (others => '0');
        g_next <= (others => '0');
        pwm_next <= '0';
      when one =>
        w_next <= w_reg;
        c_next <= std_logic_vector(counter);
        g_next <= std_logic_vector(global_counter);
        pwm_next <= '1';
      when zero =>
        w_next <= w_reg;
        c_next <= (others => '0');
        g_next <= std_logic_vector(global_counter);
        pwm_next <= '0';
    end case;
  end process;
  -- data path: functional units
  counter <= unsigned(c_reg) + 1;
  global_counter <= unsigned(g_reg) + 1;
  -- data path: status
  count_is_0 <= '1' when c_next = w_i else '0';
  global_count_is_0 <= '1' when g_next = "1111" else '0';
  w_is_0 <= '1' when w_i = "0000" else '0';
  -- data path: output
  pwm_o <= pwm_reg;















end arch;

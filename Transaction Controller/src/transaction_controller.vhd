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
  end transaction_controller;
  
architecture arch of transaction_controller is

  constant c_STANDARD_MODE  : integer := 100_000;
  constant c_FAST_MODE      : integer := 400_000;
  constant c_FAST_MODE_PLUS : integer := 1_000_000;
  constant c_HZ_MULT        : integer := 1;
  constant c_KHZ_MULT       : integer := 1000;
  constant c_MHZ_MULT       : integer := 1_000_000;
  constant c_GHZ_MULT       : integer := 1_000_000_000;

  type t_state is (off_state, idle, enbl_tx, load, sda_low, scl_low, sda_high, scl_high, write_op, wait_ack);
  signal state_reg, state_next : t_state;
  
  signal data_clk      : std_logic;                      --data clock for sda
  signal data_clk_prev : std_logic;                      --data clock during previous system clock
  signal shift_reg_e   : std_logic;
  signal low_delay     : std_logic;
  signal bit_count     : natural := 7;
  signal shift_reg     : std_logic_vector(7 downto 0);
  signal sysclk_val    : integer := 1;
  signal sig_mult      : integer :=c_HZ_MULT;
  signal freq          : integer := c_STANDARD_MODE;
  signal busy          : std_logic := '0';
  
  signal clk_val       : integer := 1;
  signal divider       : integer := 1;
  
  begin

  -- control path: state register
  process(clk_i, rst_i, scl_i, enbl_i)
  variable count  :  integer range 0 to 125;
  begin
    if enbl_i = '0' then
	   state_reg <= off_state;
    elsif rst_i = '1' then
      state_reg <= idle;
		count := 0;
    elsif rising_edge(clk_i) then
      data_clk_prev <= data_clk;
		data_clk <= scl_i;
		if(count = divider - 1) THEN        
        count := 0;
		  low_delay <= '1';
      else         
        count := count + 1;
        low_delay <= '0';		  
      end if;
      state_reg <= state_next;
    end if;
  end process;

  -- control path: next-state/ output logic
  process(state_reg, data_clk, data_clk_prev, enbl_i, wr_slv_i, rd_slv_i, rep_strt_i, msl_sel_i)
  begin
    case state_reg is
	 
	   when off_state =>
		  if enbl_i = '1' then
		    state_next <= idle;
		  else
		    state_next <= state_reg;
		  end if;
	 
      when idle =>
        if wr_slv_i = '1' and tx_buff_e_i = '0' then
          state_next <= enbl_tx;
        else
          state_next <= idle;
        end if;
		  
      when enbl_tx =>
        state_next <= load;
		
      when load =>
        if shift_reg_e = '0' and busy = '0' then
          state_next <= sda_low;
        elsif rep_strt_i = '1' then
		    state_next <= sda_high;
		  elsif busy = '1' and shift_reg_e = '0' then
		    state_next <= write_op;
		  else 
		    state_next <= load;  
        end if;
		  
		when sda_low =>
		  if low_delay = '1' then
		    state_next <= scl_low;
		  else 
		    state_next <= sda_low;
		  end if;
		  
		when scl_low =>
		  state_next <= write_op;
		  
		when write_op =>
		  if bit_count /= 0 then
		     state_next <= write_op;
		  else
		     state_next <= wait_ack;
		  end if;
		when others =>
		  
    end case;
  end process;
  
  sysclk_val <= to_integer(unsigned(sysclk_i(29 downto 0)));
  
  with sysclk_i(31 downto 30) select
    sig_mult <= c_HZ_MULT when "00",
                c_KHZ_MULT when "01",
                c_MHZ_MULT when "10",
                c_GHZ_MULT when others;
					 
  with mode_i select
    freq <= c_STANDARD_MODE when "00",
            c_FAST_MODE when "01",
            c_FAST_MODE_PLUS when others;
				
  clk_val <= (sysclk_val * sig_mult);

  divider <= (clk_val / freq) / 4;

  
  process(state_reg)
  begin
    clk_enbl_o <= '0';
	 sda_b <= '1';
	 tx_rd_enbl_o <= '0';
	 
	 
    
    case state_reg is
	   when off_state =>
		  clk_enbl_o <= '0';
		  sda_b  <= '1';
	   when idle =>
		  clk_enbl_o <= '0';
		  sda_b  <= '1';
		when enbl_tx =>
		  tx_rd_enbl_o <= '1';
		when load =>
		  shift_reg <= tx_data_i;
		  shift_reg_e <= '0';
		  bit_count <= 7;
		when sda_low =>
		  sda_b <= '0';
		when scl_low =>
		  clk_enbl_o <= '1';
		when others =>
		
		
    end case;
  end process;

--  -- data path: data register
--  process(clk_i, reset_i)
--  begin
--    if reset_i = '1' then
--      w_reg <= (others => '0');
--      c_reg <= (others => '0');
--      g_reg <= (others => '0');
--      pwm_reg <= '0';
--    elsif rising_edge(clk_i) then
--      w_reg <= w_next;
--      c_reg <= c_next;
--      g_reg <= g_next;
--      pwm_reg <= pwm_next;
--    end if;
--  end process;
  -- data path: routing multipexer
--  process(state_reg, w_reg, c_reg, g_reg,
--          pwm_reg, w_i, counter, global_counter)
--  begin
--    case state_reg is
--      when idle =>
--        w_next <= w_reg;
--        c_next <= c_reg;
--        g_next <= g_reg;
--        pwm_next <= '0';
--      when load =>
--        w_next <= w_i;
--        c_next <= (others => '0');
--        g_next <= (others => '0');
--        pwm_next <= '0';
--      when one =>
--        w_next <= w_reg;
--        c_next <= std_logic_vector(counter);
--        g_next <= std_logic_vector(global_counter);
--        pwm_next <= '1';
--      when zero =>
--        w_next <= w_reg;
--        c_next <= (others => '0');
--        g_next <= std_logic_vector(global_counter);
--        pwm_next <= '0';
--    end case;
--  end process;
  -- data path: functional units
--  counter <= unsigned(c_reg) + 1;
--  global_counter <= unsigned(g_reg) + 1;
--  -- data path: status
--  count_is_0 <= '1' when c_next = w_i else '0';
--  global_count_is_0 <= '1' when g_next = "1111" else '0';
--  w_is_0 <= '1' when w_i = "0000" else '0';
--  -- data path: output
--  pwm_o <= pwm_reg;















end arch;

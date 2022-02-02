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
end transaction_controller;

architecture arch of transaction_controller is

  constant c_STANDARD_MODE  : integer := 100_000;
  constant c_FAST_MODE      : integer := 400_000;
  constant c_FAST_MODE_PLUS : integer := 1_000_000;
  constant c_HZ_MULT        : integer := 1;
  constant c_KHZ_MULT       : integer := 1000;
  constant c_MHZ_MULT       : integer := 1_000_000;
  constant c_GHZ_MULT       : integer := 1_000_000_000;

  type t_state is
  (
    off_state, idle, enbl_tx, wait_addr, load_addr,
    sda_low, scl_low, sda_high_stop, scl_high_stop,
    sda_high_rep, scl_high_rep, addr_op, wait_ack_addr,
    enbl_tx_data, wait_data, load_data, write_op, wait_stop, wait_rep,
    wait_ack_data, read_op, send_ack, enbl_rx, store, ack_intr
  );
  signal state_reg, state_next : t_state;

  signal data_clk      : std_logic;
  signal data_clk_prev : std_logic;
  signal low_delay     : std_logic;
  signal busy          : std_logic;
  signal ack           : std_logic := '0';
  signal rst_count     : std_logic := '0';
  signal arb_lost      : std_logic := '0';
  signal read_or_write : std_logic := '0';
  signal wait_done     : std_logic := '0';
  signal write_done    : std_logic := '0';


  signal sysclk_val    : integer := 1;
  signal sig_mult      : integer := c_HZ_MULT;
  signal freq          : integer := c_STANDARD_MODE;
  signal clk_val       : integer := 1;
  signal divider       : integer := 1;
  signal byte_count    : integer := 0;
  signal bit_count     : integer := 0;

  signal count         : integer range 0 to 125;

  signal addr_loaded : std_logic := '0';

  -- registers
  signal sda_reg, sda_next             : std_logic;
  signal rst_count_reg, rst_count_next : std_logic;
  signal busy_reg, busy_next           : std_logic;
  signal byte_count_reg, byte_count_next : integer := 0;
  signal bit_count_reg, bit_count_next   : integer;
  signal shift_reg, shift_next : std_logic_vector(7 downto 0);
  signal rx_reg, rx_next       : std_logic_vector(7 downto 0);

begin

  -- control path: state register
  process(clk_i, rst_i, enbl_i)
  begin

    if enbl_i = '0' then
      state_reg <= off_state;
    elsif rst_i = '1' then
      state_reg <= idle;
      count <= 0;
    elsif rising_edge(clk_i) then

      data_clk_prev <= data_clk;
      data_clk <= scl_i;

      if rst_count = '1' then
        count <= 0;
        low_delay <= '0';
      elsif count = divider - 1 then
        count <= 0;
        low_delay <= '1';
      else
        count <= count + 1;
        low_delay <= '0';
      end if;

      state_reg <= state_next;

    end if;
  end process;

  -- control path: next-state
  process(state_reg, data_clk, data_clk_prev, enbl_i, rep_strt_i,
          msl_sel_i, byte_count, arb_lost, low_delay, bit_count, ack, read_or_write)
  begin
    case state_reg is

      when off_state =>
        if enbl_i = '1' then
          state_next <= idle;
        else
          state_next <= off_state;
        end if;

      when idle =>
        if byte_count /= 0 then
          state_next <= enbl_tx;
        else
          state_next <= idle;
        end if;

      when enbl_tx =>
        state_next <= wait_addr;

      when wait_addr =>
        state_next <= load_addr;

      when load_addr =>
          state_next <= sda_low;

      when sda_high_rep =>
        if low_delay = '1' then
          state_next <= scl_high_rep;
        else
          state_next <= sda_high_rep;
        end if;

      when scl_high_rep =>
        if low_delay = '1' then
          state_next <= enbl_tx;
        else
          state_next <= scl_high_rep;
        end if;

      when sda_low =>
        if low_delay = '1' then
          state_next <= scl_low;
        else
          state_next <= sda_low;
        end if;

      when scl_low =>
        state_next <= addr_op;

      when addr_op =>
        if arb_lost = '1' then
          state_next <= ack_intr;
        elsif write_done = '1' then
          state_next <= wait_ack_addr;
        else
          state_next <= addr_op;
        end if;

      when wait_ack_addr =>
        if data_clk_prev = '0' and data_clk = '1' then
          if ack = '1' then
            state_next <= ack_intr;
          elsif read_or_write = '0' then
            state_next <= enbl_tx_data;
          else
            state_next <= read_op;
          end if;
        else
          state_next <= wait_ack_addr;
        end if;

      when enbl_tx_data =>
        state_next <= wait_data;

      when wait_data =>
        state_next <= load_data;

      when load_data =>
        state_next <= write_op;

      when write_op =>
        if arb_lost = '1' then
          state_next <= ack_intr;
        elsif write_done = '1' then
          state_next <= wait_ack_data;
        else
          state_next <= write_op;
        end if;

      when wait_ack_data =>
        if data_clk_prev = '0' and data_clk = '1' then
          if ack = '1' then
            state_next <= ack_intr;
          elsif byte_count /= 0 then
            state_next <= enbl_tx_data;
			 elsif rep_strt_i = '1' then
			   state_next <= wait_rep;
          else
            state_next <= wait_stop;
          end if;
        else
          state_next <= wait_ack_data;
        end if;

      when wait_rep =>
		  if data_clk_prev = '1' and data_clk = '0' then
		    state_next <= sda_high_rep;
		  else
		    state_next <= wait_rep;
		  end if;

      when wait_stop =>
        if data_clk_prev = '0' and data_clk = '1' then
          state_next <= scl_high_stop;
        else
          state_next <= wait_stop;
        end if;

      when scl_high_stop =>
        if low_delay = '1' then
          state_next <= sda_high_stop;
        else
          state_next <= scl_high_stop;
        end if;

      when sda_high_stop =>
        state_next <= idle;

      when read_op =>
        if data_clk_prev = '0' and data_clk = '1' then
          if bit_count /= 0 then
            state_next <= read_op;
          else
            state_next <= send_ack;
          end if;
        else
          state_next <= read_op;
        end if;

      when send_ack =>
        if data_clk_prev = '0' and data_clk = '1' then
          state_next <= enbl_rx;
        else
          state_next <= send_ack;
        end if;

      when enbl_rx =>
        state_next <= store;

      when store =>
        if byte_count /= 0 then
          state_next <= read_op;
        elsif rep_strt_i = '1' then
          state_next <= enbl_tx;
        else
          state_next <= scl_high_stop;
        end if;

      when ack_intr =>
        state_next <= idle;

      when others =>
        state_next <= idle;

    end case;
  end process;

  -- control path: output logic
  with state_reg select
    tx_rd_enbl_o <= '1' when enbl_tx | enbl_tx_data,
                    '0' when others;

  rx_wr_enbl_o <= '1' when state_reg = enbl_rx else
                  '0';

  with state_reg select
    clk_enbl_o <= '0' when off_state | idle | enbl_tx | wait_addr | load_addr | sda_low |
                           scl_high_rep | scl_high_stop | sda_high_stop |
                           ack_intr,
                  '1' when others;
  busy_flg_o <= busy_reg;
  ack_flg_o  <= ack when state_reg = ack_intr else
                '0';

  -- datapath: data register
  process(clk_i, rst_i)
  begin
  
    if rst_i = '1' then

      sda_reg        <= '1';
      busy_reg       <= '0';
      byte_count_reg <= to_integer(unsigned(byte_count_i));
      bit_count_reg  <= 8;
      rst_count_reg  <= '1';
		shift_reg      <= (others => '0');
      rx_reg         <= (others => '0');

    elsif rising_edge(clk_i) then

      sda_reg        <= sda_next;
      busy_reg       <= busy_next;
      byte_count_reg <= byte_count_next;
      bit_count_reg  <= bit_count_next;
      rst_count_reg  <= rst_count_next;
      shift_reg      <= shift_next;
      rx_reg         <= rx_next;

    end if;
  end process;
  
  -- datapath: routing multipexer
  process(state_reg, sda_reg, byte_count_reg, bit_count_reg,
          rst_count_reg, byte_count_i, data_clk)
  begin

    sda_next        <= '1';
    busy_next       <= busy_reg;
    byte_count_next <= byte_count_reg;
    bit_count_next  <= 8;
    rst_count_next  <= '0';
    shift_next      <= shift_reg;
    rx_next         <= rx_reg;

    case state_reg is
	   -- when off_state =>
		-- when idle =>
		-- when enbl_tx =>
		-- when wait_addr =>

      when off_state =>
        busy_next <= '0';

      when idle =>
        byte_count_next <= to_integer(unsigned(byte_count_i));
		
		when load_addr =>
		  shift_next     <= tx_data_i;
        bit_count_next <= 8;
		  rst_count_next <= '0';
        
		when sda_low =>
        sda_next <= '0';

		when scl_low =>
        sda_next <= '0';
        busy_next <= '1';
  
		when addr_op =>

        read_or_write <= shift_reg(0);

		  if data_clk_prev = '1' and data_clk = '0' then

          if bit_count_reg = 0 then
            write_done <= '1';

          else
		      bit_count_next <= bit_count_reg - 1;
			   sda_next <= shift_reg(bit_count_reg - 1);
          end if;

		  else
		    bit_count_next <= bit_count_reg;
			 sda_next <= sda_reg;
		  end if;
		
		when wait_ack_addr =>
		  sda_next <= 'Z';
        write_done <= '0';
		  
		when enbl_tx_data =>
		  sda_next <= sda_reg;
		  
		when wait_data =>
		  sda_next <= sda_reg;
		  
		when load_data =>
		  shift_next     <= tx_data_i;
        bit_count_next <= 8;
		  
		when write_op =>
		  if data_clk_prev = '1' and data_clk = '0' then

          if bit_count_reg = 0 then
            write_done <= '1';
            byte_count_next <= byte_count_reg - 1;
            sda_next <= 'Z';
          else
		      bit_count_next <= bit_count_reg - 1;
			   sda_next <= shift_reg(bit_count_reg - 1);
          end if;

		  else
		    bit_count_next <= bit_count_reg;
			 sda_next       <= sda_reg;
		  end if;
		  
		when wait_ack_data =>
		  sda_next   <= 'Z';
        write_done <= '0';

		when wait_rep =>
		  sda_next <= sda_reg;
		  
      when wait_stop =>
        sda_next <= '0';

		when scl_high_stop =>
		  rst_count_next <= '0';
        busy_next      <= '0';
        sda_next       <= '0';
		
		when sda_high_stop =>
        sda_next <= '1';
		
		when read_op =>
		  if data_clk_prev = '0' and data_clk = '1' then
		    bit_count_next <= bit_count_reg - 1;
			 shift_next(bit_count_reg - 1) <= sda_b;
			 if bit_count_reg - 1 = 0 then
			   byte_count_next <= byte_count_reg - 1;
          end if;
		  end if;
		  sda_next <= sda_b;
		  
		when send_ack =>
		  if bit_count_reg = 0 then
		    sda_next <= '0';
		  end if;
			 
		-- when enbl_rx =>
		
		when store =>
		  rx_next <= shift_reg;
		
		 when sda_high_rep =>
		   rst_count_next <= '0';
		
		when scl_high_rep =>
		  rst_count_next <= '0';
		
		when others =>
	  end case;
  end process;

  -- data path: status
  byte_count <= byte_count_reg;
  bit_count  <= bit_count_reg;
  rst_count  <= rst_count_reg;

  -- data path: functional unit
  ack <= sda_b;

  -- data path: output
  sda_b <= sda_reg;
  rx_data_o <= rx_reg;

  sysclk_val <= to_integer(unsigned(sysclk_i(29 downto 0)));

  with sysclk_i(31 downto 30) select
    sig_mult <= c_HZ_MULT  when "00",
                c_KHZ_MULT when "01",
                c_MHZ_MULT when "10",
                c_GHZ_MULT when others;

  with mode_i select
    freq <= c_STANDARD_MODE when "00",
            c_FAST_MODE when "01",
            c_FAST_MODE_PLUS when others;

  clk_val <= (sysclk_val * sig_mult);

  divider <= (clk_val / freq) / 4;
end arch;

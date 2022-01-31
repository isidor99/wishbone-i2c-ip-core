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
    wr_slv_i       : in    std_logic;
    rd_slv_i       : in    std_logic;
    rep_strt_i     : in    std_logic;
    slv_addr_len_i : in    std_logic;
    msl_sel_i      : in    std_logic;
    scl_i          : in    std_logic;
    tx_buff_e_i    : in    std_logic;
    rx_buff_f_i    : in    std_logic;
    slv_addr_i     : in    std_logic_vector(9 downto 0);
    tx_data_i      : in    std_logic_vector(7 downto 0);
    mode_i         : in    std_logic_vector(1 downto 0);
    sysclk_i       : in    std_logic_vector(31 downto 0);
    sda_b          : inout std_logic;
    tx_rd_enbl_o   : out   std_logic;
    rx_wr_enbl_o   : out   std_logic;
    rx_data_o      : out   std_logic;
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

  type t_state is (off_state, idle, enbl_tx, load, sda_low, scl_low,
                   sda_high_stop, scl_high_stop, sda_high_rep, scl_high_rep,
                   write_op, wait_ack, read_op, send_ack, enbl_rx, store, wait_data);
  signal state_reg, state_next : t_state;

  signal data_clk      : std_logic;
  signal data_clk_prev : std_logic;
  signal shift_reg_e   : std_logic;
  signal low_delay     : std_logic;
  signal bit_count     : natural := 7;
  signal shift_reg     : std_logic_vector(7 downto 0);
  signal sysclk_val    : integer := 1;
  signal sig_mult      : integer := c_HZ_MULT;
  signal freq          : integer := c_STANDARD_MODE;

  signal busy          : std_logic := '0';
  signal ack           : std_logic := '0';

  signal clk_val       : integer := 1;
  signal divider       : integer := 1;

  signal count         : integer range 0 to 125;
  signal rst_count     : std_logic := '0';
begin

  -- control path: state register
  process(clk_i, rst_i, scl_i, enbl_i)
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
      end if;
      -- HINT: Mozda ovde da ide elsif
      if count = divider - 1 then
        count <= 0;
        low_delay <= '1';
      else
        count <= count + 1;
        low_delay <= '0';
      end if;
      state_reg <= state_next;
    end if;
  end process;

  -- control path: next-state / output logic
  process(state_reg, data_clk, data_clk_prev, enbl_i, wr_slv_i, rd_slv_i, rep_strt_i, msl_sel_i)
  begin
    -- HINT: Nismo definisali sta se desava ako je tx_buffer prazan
    --       mozda se vratiti u idle stanje uz generisanje interrupt-a
    case state_reg is
      when off_state =>
        if enbl_i = '1' then
          state_next <= idle;
        else
          state_next <= off_state;
        end if;

      when idle =>
        if wr_slv_i = '1' and tx_buff_e_i = '0' then
          state_next <= enbl_tx;
        else
          state_next <= idle;
        end if;

      when enbl_tx =>
        state_next <= wait_data;

      when wait_data =>
        state_next <= load;

      when load =>
        -- HINT: Mozda prvo dodati uslog da li je rep_strt_i = 1
        --       a ispod dodati uslove za busy flag
        if busy = '0' then
          state_next <= sda_low;
        elsif rep_strt_i = '1' then
          state_next <= sda_high_rep;
        elsif busy = '1' and rep_strt_i = '0' then
          state_next <= write_op;
        else
          state_next <= load;
        end if;

      when sda_high_rep =>
        -- HINT: Mozda postavljanje res_count staviti u output logic process
        rst_count <= '0';
        if low_delay = '1' then
          rst_count <= '1';
          state_next <= scl_high_rep;
        else
          state_next <= sda_high_rep;
        end if;

      when scl_high_rep =>
        -- HINT: Mozda postavljanje res_count staviti u output logic process
        rst_count <= '0';
        if low_delay = '1' then
          rst_count <= '1';
          state_next <= sda_low;
        else
          state_next <= sda_high_rep;
        end if;

      when sda_low =>
        -- HINT: Mozda postavljanje res_count staviti u output logic process
        rst_count <= '0';
        if low_delay = '1' then
          rst_count <= '1';
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

      when wait_ack =>
        -- HINT: Mozda postavljanje bit_count ( = 8 ) staviti u output logic process
        bit_count <= 7;
        if ack = '1' then
          -- HINT: Postavljanje ack flega prebaciti u output state logic
          ack_flg_o <= '1';
          state_next <= idle;
        elsif ack = '0' and (wr_slv_i = '1' or rep_strt_i = '1') and tx_buff_e_i = '0' then
          state_next <= enbl_tx;
        elsif wr_slv_i = '0' and rd_slv_i = '0' and rep_strt_i = '0' then
          state_next <= scl_high_stop;
        elsif ack = '0' and rd_slv_i = '1' then
          state_next <= read_op;
        else
          state_next <= wait_ack;
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
        if bit_count /= 0 then
          state_next <= read_op;
        else
          state_next <= send_ack;
        end if;

      when send_ack =>
        -- HINT: Mozda postavljanje bit_count ( = 8 ) staviti u output logic process
        bit_count <= 7;
        if rx_buff_f_i = '0' then
          state_next <= enbl_rx;
        else
          state_next <= send_ack;
        end if;

      when enbl_rx =>
        state_next <= store;

      when store =>
        -- HINT: Ispitati uslov za wr_slv (mozda ici u idle state)
        if rd_slv_i = '0' and rep_strt_i = '0' then
          state_next <= scl_high_stop;
        elsif rd_slv_i = '1' then
          state_next <= read_op;
        elsif rep_strt_i = '1' and tx_buff_e_i = '0' then
          state_next <= enbl_tx;
        else
          state_next <= store;
        end if;

      when others =>
        state_next <= idle;

    end case;
  end process;

  -- output logic
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
        -- HINT: Ukloniti shift_reg_e
        shift_reg <= tx_data_i;
        shift_reg_e <= '0';

      when sda_low =>
        sda_b <= '0';

      when scl_low =>
        clk_enbl_o <= '1';

      when others =>

    end case;
  end process;

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

----------------------------------------------------------------------------
-- ETF BL
-- Wishbone I2C
-----------------------------------------------------------------------------
--
--    unit    name:                        wishbone i2c ip core
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

library uvvm_util;
use uvvm_util.types_pkg.all;
use uvvm_util.global_signals_and_shared_variables_pkg.all;
use uvvm_util.hierarchy_linked_list_pkg.all;
use uvvm_util.string_methods_pkg.all;
use uvvm_util.adaptations_pkg.all;
use uvvm_util.methods_pkg.all;
use uvvm_util.bfm_common_pkg.all;
use uvvm_util.alert_hierarchy_pkg.all;
use uvvm_util.license_pkg.all;
use uvvm_util.protected_types_pkg.all;
use uvvm_util.rand_pkg.all;
use uvvm_util.func_cov_pkg.all;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_sbi;
library bitvis_vip_i2c;

library bitvis_vip_wishbone;
use bitvis_vip_wishbone.wishbone_bfm_pkg.t_wishbone_bfm_config;

library bitvis_vip_clock_generator;

entity wishbone_i2c_ip_core_th is
end wishbone_i2c_ip_core_th;

architecture arch of wishbone_i2c_ip_core_th is

  constant C_WIDTH      : natural := 32;
  constant C_ADDR_WIDTH : natural := 3;
  constant C_GPO_W      : natural := 8;
  constant C_WIDTH_B    : natural := 8;
  constant C_DEPTH      : natural := 16;

  constant C_CLK_PERIOD : time    := 20 ns;
  constant C_CLOCK_GEN  : natural := 1;

  -- Define value for the BFM config
  constant C_WISHBONE_BFM_CONFIG : t_wishbone_bfm_config := (
    max_wait_cycles             => 10,
    max_wait_cycles_severity    => failure,
    clock_period                => C_CLK_PERIOD,
    clock_period_margin         => 0 ns,
    clock_margin_severity       => TB_ERROR,
    setup_time                  => 1 ns,
    hold_time                   => 1 ns,
    match_strictness            => MATCH_EXACT,
    id_for_bfm                  => ID_BFM,
    id_for_bfm_wait             => ID_BFM_WAIT,
    id_for_bfm_poll             => ID_BFM_POLL
  );


  signal clk_test    : std_logic;
  signal rst_test    : std_logic;
  signal we_test     : std_logic;
  signal addr_test   : std_logic_vector((C_ADDR_WIDTH - 1) downto 0);
  signal addr_test_u : unsigned((C_ADDR_WIDTH - 1) downto 0);
  signal data_i_test : std_logic_vector((C_WIDTH - 1) downto 0);
  signal data_o_test : std_logic_vector((C_WIDTH - 1) downto 0);
  signal stb_test    : std_logic;
  signal cyc_test    : std_logic;
  signal ack_test    : std_logic;
  signal int_test    : std_logic;
  signal scl_test    : std_logic;
  signal sda_test    : std_logic;
  signal gpo_test    : std_logic_vector(C_GPO_W - 1 downto 0);

begin

  -----------------------------------------------------------------------------
  -- Instantiate the concurrent procedure that initializes UVVM
  -----------------------------------------------------------------------------
  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  addr_test_u <= unsigned(addr_test);

  -----------------------------------------------------------------------------
  -- Wishbone I2C IP Core
  -----------------------------------------------------------------------------
  i_wishbone_i2c_ip_core : entity work.wishbone_i2c_ip_core
    generic map
    (
      g_WIDTH      => C_WIDTH,
      g_ADDR_WIDTH => C_ADDR_WIDTH,
      g_GPO_W      => C_GPO_W,
      g_WIDTH_B    => C_WIDTH_B,
      g_DEPTH      => C_DEPTH
    )
    port map
    (
      clk_i     => clk_test,
      rst_i     => rst_test,
      we_i      => we_test,
      stb_i     => stb_test,
      cyc_i     => cyc_test,
      addr_i    => addr_test_u,
      data_i    => data_i_test,
      data_o    => data_o_test,
      ack_o     => ack_test,
      int_o     => int_test,
      scl_b     => scl_test,
      sda_b     => sda_test,
      gpo_o     => gpo_test
    );

  -----------------------------------------------------------------------------
  -- Wishbone
  -----------------------------------------------------------------------------
  i1_wishbone_vvc : entity bitvis_vip_wishbone.wishbone_vvc
    generic map
    (
      GC_ADDR_WIDTH          => C_ADDR_WIDTH,
      GC_DATA_WIDTH          => C_WIDTH,
      GC_WISHBONE_BFM_CONFIG => C_WISHBONE_BFM_CONFIG
    )
    port map
    (
      clk => clk_test,
      wishbone_vvc_master_if.dat_i => data_o_test,
      wishbone_vvc_master_if.ack_i => ack_test,
      wishbone_vvc_master_if.adr_o => addr_test,
      wishbone_vvc_master_if.dat_o => data_i_test,
      wishbone_vvc_master_if.we_o  => we_test,
      wishbone_vvc_master_if.cyc_o => cyc_test,
      wishbone_vvc_master_if.stb_o => stb_test
    );

  -----------------------------------------------------------------------------
  -- I2C
  -----------------------------------------------------------------------------
  i1_i2c_vvc : entity bitvis_vip_i2c.i2c_vvc
    port map
    (
      i2c_vvc_if.scl => scl_test,
      i2c_vvc_if.sda => sda_test
    );

  -----------------------------------------------------------------------------
  -- Clock Generator VVC
  -----------------------------------------------------------------------------
  i_clock_generator_vvc : entity bitvis_vip_clock_generator.clock_generator_vvc
    generic map
    (
      GC_INSTANCE_IDX    => C_CLOCK_GEN,
      GC_CLOCK_NAME      => "Clock",
      GC_CLOCK_PERIOD    => C_CLK_PERIOD,
      GC_CLOCK_HIGH_TIME => C_CLK_PERIOD / 2
    )
    port map
    (
      clk => clk_test
    );

  rst_test <= '1', '0' after (5 * C_CLK_PERIOD);

end arch;
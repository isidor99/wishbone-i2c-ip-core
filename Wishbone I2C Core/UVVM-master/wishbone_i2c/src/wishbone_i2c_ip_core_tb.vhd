----------------------------------------------------------------------------
-- ETF BL
-- Wishbone I2C
-----------------------------------------------------------------------------
--
--    unit    name:                        wishbone i2c ip core testbench
--
--    description:
--
--              This is top-level entity testbench.
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
use bitvis_vip_sbi.vvc_methods_pkg.all;
use bitvis_vip_sbi.td_vvc_framework_common_methods_pkg.all;

library bitvis_vip_i2c;
use bitvis_vip_i2c.vvc_methods_pkg.all;
use bitvis_vip_i2c.td_vvc_framework_common_methods_pkg.all;

library bitvis_vip_wishbone;
use bitvis_vip_wishbone.vvc_methods_pkg.all;
use bitvis_vip_wishbone.td_vvc_framework_common_methods_pkg.all;
use bitvis_vip_wishbone.wishbone_bfm_pkg.t_wishbone_if;
use bitvis_vip_wishbone.wishbone_bfm_pkg.t_wishbone_bfm_config;
use bitvis_vip_wishbone.wishbone_bfm_pkg.C_WISHBONE_BFM_CONFIG_DEFAULT;

library bitvis_vip_clock_generator;
use bitvis_vip_clock_generator.vvc_cmd_pkg.all;
use bitvis_vip_clock_generator.vvc_methods_pkg.all;
use bitvis_vip_clock_generator.td_vvc_framework_common_methods_pkg.all;

use work.register_pkg.all;

entity wishbone_i2c_ip_core_tb is
end wishbone_i2c_ip_core_tb;

architecture arch of wishbone_i2c_ip_core_tb is

  constant C_CLK_PERIOD : time    := 20 ns;

  constant C_TEST_DATA : std_logic_vector(31 downto 0) := (1 => '1', others => '0');

  constant C_ADDR : unsigned(2 downto 0) := "011";

begin

  i_wishbone_i2c_core : entity work.wishbone_i2c_ip_core_th;

  -- main process
  process
  begin

    -- Wait for UVVM to finish initialization
    await_uvvm_initialization(VOID);

    start_clock(CLOCK_GENERATOR_VVCT, 1, "Start clock generator");

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    --enable_log_msg(ALL_MESSAGES);
    disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_SEQUENCER);
    enable_log_msg(ID_UVVM_SEND_CMD);

    log(ID_LOG_HDR, "Starting simulation of TB for UART using VVCs", C_SCOPE);
    ------------------------------------------------------------

    log("Wait 10 clock period for reset to be turned off");
    wait for (10 * C_CLK_PERIOD); -- for reset to be turned off


    log(ID_LOG_HDR, "Check simple transmit", C_SCOPE);
    -----------------------------------------------------------------------------
    wishbone_write(WISHBONE_VVCT, 1, C_ADDR, C_TEST_DATA, "Test transmit");
	 wait for 3 * C_CLK_PERIOD;
    wishbone_read(WISHBONE_VVCT, 1, C_ADDR, "Receive");

    wait for 10 * C_CLK_PERIOD;

    --wishbone_write(WISHBONE_VVCT, 1, C_ADDR, C_TEST_DATA, "Test transmit");
    --wishbone_read(WISHBONE_VVCT, 1, C_ADDR, "Receive");



    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 100 us;             -- to allow some time for completion
    report_alert_counters(FINAL); -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;  -- to stop completely

  end process;

end arch;
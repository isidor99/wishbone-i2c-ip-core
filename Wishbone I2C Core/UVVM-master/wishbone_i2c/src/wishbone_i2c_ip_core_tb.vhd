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
  constant C_SCL_PERIOD : time    := 10 us;

  constant C_TEST_DATA : std_logic_vector(31 downto 0) := (0 | 1 | 4 | 7 => '1', others => '0');

  constant C_SLAVE_ADDRESS       : std_logic_vector(6 downto 0) := "1110001";
  constant C_SLAVE_ADDRESS_CORE  : unsigned(6 downto 0)         := "0011110";  -- 0011110
  constant C_SLAVE_ADDRESS_8_BIT : std_logic_vector(7 downto 0) := "00100110";

  constant C_TEST_VECTOR_A : t_byte_array := (
    x"19",
    x"C7"
  );

  constant C_TEST_VECTOR_A_2 : t_byte_array := (
    x"A7",
    x"0B",
    x"6F"
  );

  constant ADDR_DATA  : std_logic_vector(31 downto 0) := "00000000000000000000000000011110";

begin

  i_wishbone_i2c_core : entity work.wishbone_i2c_ip_core_th;

  -- main process
  process

    -- send data to TX buffer
    procedure write_buffer (
      constant data : std_logic_vector(7 downto 0)
    ) is
      variable send : std_logic_vector(31 downto 0) := (others => '0');
    begin
      send := send(31 downto 8) & data;
      wishbone_write(WISHBONE_VVCT, 1, c_REG_TX,  send,              "Write data to TX register");
      wishbone_write(WISHBONE_VVCT, 1, c_REG_CMD, c_CMD_WRITE_BUFF,  "Enable TX");
      wishbone_write(WISHBONE_VVCT, 1, c_REG_CMD, c_CMD_DISABLE_ALL, "Disable all");
    end write_buffer;

    -- read data from RX buffer and check
    procedure check_buffer (
      constant data : std_logic_vector(7 downto 0)
    ) is
      variable send : std_logic_vector(31 downto 0) := (others => '0');
    begin
      send := send(31 downto 8) & data;
      wishbone_write(WISHBONE_VVCT, 1, c_REG_CMD, c_CMD_READ_BUFF,   "Enable RX");
      wishbone_write(WISHBONE_VVCT, 1, c_REG_CMD, c_CMD_DISABLE_ALL, "Disable all");
      wishbone_check(WISHBONE_VVCT, 1, c_REG_RX,  send,              "Check data in RX buffer");
    end check_buffer;

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

    log(ID_LOG_HDR, "Starting simulation of TB for Wishbone-I2C using VVCs", C_SCOPE);
    ------------------------------------------------------------

    log("Wait 10 clock period for reset to be turned off");
    wait for (10 * C_CLK_PERIOD); -- for reset to be turned off

    -- enable I2C and select master mode
    wishbone_write(WISHBONE_VVCT, 1, c_REG_CTRL, c_CTRL_I2C_EN_MASTER, "Setup control register");

    log(ID_LOG_HDR, "Test transmit two bytes", C_SCOPE);
    -----------------------------------------------------------------------------
    write_buffer("00000010");
    write_buffer("11100010");
    write_buffer(C_TEST_VECTOR_A(0));
    write_buffer(C_TEST_VECTOR_A(1));

    -- command register
    wishbone_write(WISHBONE_VVCT, 1, c_REG_CMD, c_CMD_I2C_START,   "Setup command register");
    wishbone_write(WISHBONE_VVCT, 1, c_REG_CMD, c_CMD_DISABLE_ALL, "Setup command register");

    i2c_slave_check(I2C_VVCT, 1, C_TEST_VECTOR_A, "I2C slave check bytes");

    await_completion(I2C_VVCT, 1, 3 * 11 * C_SCL_PERIOD);

    wait for 50 us;

    log(ID_LOG_HDR, "Test transmit one byte", C_SCOPE);
    -----------------------------------------------------------------------------
    write_buffer("00000001");
    write_buffer("11100010");
    write_buffer("00011001");

    -- command register
    wishbone_write(WISHBONE_VVCT, 1, c_REG_CMD, c_CMD_I2C_START,   "Setup command register");
    wishbone_write(WISHBONE_VVCT, 1, c_REG_CMD, c_CMD_DISABLE_ALL, "Setup command register");

    i2c_slave_check(I2C_VVCT, 1, "00011001", "I2C slave check byte");

    await_completion(I2C_VVCT, 1, 2 * 10 * C_SCL_PERIOD);

    wait for 50 us;

    log(ID_LOG_HDR, "Test read two bytes", C_SCOPE);
    -----------------------------------------------------------------------------
    write_buffer("00000010");
    write_buffer("11100011");

    -- command register
    wishbone_write(WISHBONE_VVCT, 1, c_REG_CMD, c_CMD_I2C_START, "Setup command register");
    wishbone_write(WISHBONE_VVCT, 1, c_REG_CMD, c_CMD_DISABLE_ALL, "Setup command register");

    -- slave write data
    i2c_slave_transmit(I2C_VVCT, 1, C_TEST_VECTOR_A, "Slave transmit");
    await_completion(I2C_VVCT, 1, 3 * 10 * C_SCL_PERIOD);

    -- wishbone read from RX buffer and check
    check_buffer(C_TEST_VECTOR_A(0));
    check_buffer(C_TEST_VECTOR_A(1));

    wait for 50 us;

    log(ID_LOG_HDR, "Test repeated start", C_SCOPE);
    -----------------------------------------------------------------------------
    write_buffer("00000011");
    write_buffer("11100010");
    write_buffer(C_TEST_VECTOR_A_2(0));
    write_buffer(C_TEST_VECTOR_A_2(1));
    write_buffer(C_TEST_VECTOR_A_2(2));

    -- command register
    wishbone_write(WISHBONE_VVCT, 1, c_REG_CMD, c_CMD_I2C_START, "Setup command register");
    wishbone_write(WISHBONE_VVCT, 1, c_REG_CMD, c_CMD_DISABLE_ALL, "Setup command register");

    i2c_slave_check(I2C_VVCT, 1, C_TEST_VECTOR_A_2, "I2C slave check bytes");

    -- set new data in TX
    write_buffer("00000001");
    write_buffer("11100011");

    -- command register
    -- set repeated start
    wishbone_write(WISHBONE_VVCT, 1, c_REG_CMD, c_CMD_REP_START, "Setup command register");

    -- wait for I2C completion
    await_completion(I2C_VVCT, 1, 4 * 10 * C_SCL_PERIOD);

    wait for 100 ns;

    -- command register
    wishbone_write(WISHBONE_VVCT, 1, c_REG_CMD, c_CMD_DISABLE_ALL, "Setup command register");

    -- slave write data
    i2c_slave_transmit(I2C_VVCT, 1, C_TEST_VECTOR_A(0), "Slave transmit");

    await_completion(I2C_VVCT, 1, 2 * 10 * C_SCL_PERIOD);

    -- wishbone read from RX buffer and check
    check_buffer(C_TEST_VECTOR_A(0));


    wait for 50 us;

    log(ID_LOG_HDR, "Test transmit two bytes to 10-bit address slave", C_SCOPE);
    -----------------------------------------------------------------------------
    write_buffer("00000011");
    write_buffer("11110110");            -- 10-bit address first byte
    write_buffer(C_SLAVE_ADDRESS_8_BIT); -- 10-bit address second byte
    write_buffer(C_TEST_VECTOR_A(0));
    write_buffer(C_TEST_VECTOR_A(1));

    -- command register
    wishbone_write(WISHBONE_VVCT, 1, c_REG_CMD, c_CMD_I2C_START,   "Setup command register");
    wishbone_write(WISHBONE_VVCT, 1, c_REG_CMD, c_CMD_DISABLE_ALL, "Setup command register");

    i2c_slave_check(I2C_VVCT, 2, C_TEST_VECTOR_A, "I2C slave check bytes");

    await_completion(I2C_VVCT, 2, 4 * 11 * C_SCL_PERIOD);

    wait for 50 us;

    log(ID_LOG_HDR, "TEST SLAVE MODE", C_SCOPE);
    -----------------------------------------------------------------------------
    -- set slave address
    -- enable I2C and select slave mode
    wishbone_write(WISHBONE_VVCT, 1, c_REG_SLVA, ADDR_DATA, "Setup core slave address");
    wishbone_write(WISHBONE_VVCT, 1, c_REG_CTRL, c_CTRL_I2C_EN_SLAVE,  "Setup control register");

    wait for 20 us;

    log(ID_LOG_HDR, "Test read from slave", C_SCOPE);
    -----------------------------------------------------------------------------
    write_buffer("00000001");
    write_buffer(C_TEST_VECTOR_A(0));
    -- write_buffer(C_TEST_VECTOR_A(1));

    -- command register
    wishbone_write(WISHBONE_VVCT, 1, c_REG_CMD, c_CMD_I2C_START,   "Setup command register");
    wishbone_write(WISHBONE_VVCT, 1, c_REG_CMD, c_CMD_DISABLE_ALL, "Setup command register");
    await_completion(I2C_VVCT, 3, 3 * C_SCL_PERIOD);

    wait for 5 us;

    -- master transmit
    i2c_master_transmit(I2C_VVCT, 3, C_SLAVE_ADDRESS_CORE, x"A4", "Master transmit");
    await_completion(I2C_VVCT, 3, 3 * 11 * C_SCL_PERIOD);

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 5000 us;              -- to allow some time for completion
    report_alert_counters(FINAL); -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;  -- to stop completely

  end process;

end arch;
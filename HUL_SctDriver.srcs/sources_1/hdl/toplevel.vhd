library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_misc.all;

library UNISIM;
use UNISIM.VComponents.all;

library mylib;
use mylib.defToplevel.all;
--use mylib.defNimEx_NetAssign.all;
use mylib.defSiTCP.all;
use mylib.defBCT.all;

entity toplevel is
  Port (
    -- System ----------------------------------------------------------------
    CLKOSC        : in std_logic; -- 50 MHz
    LED           : out std_logic_vector(kNumLED-1 downto 0);
    DIP           : in  std_logic_vector(kNumBitDIP-1 downto 0);
    PROG_B_ON     : out std_logic;
    VP            : in std_logic; -- XADC
    VN            : in std_logic; -- XADC

    -- Main input port -------------------------------------------------------
    MAIN_IN_U     : in std_logic_vector(kNumInput-1 downto 0); -- 0-31 ch
    MAIN_IN_D     : in std_logic_vector(kNumInput-1 downto 0); -- 32-63 ch

    -- Mezzanine signal ------------------------------------------------------
    MZN_SIG_Up    : out std_logic_vector(kNumInputMZN-1 downto 0); -- 64-95 ch
    MZN_SIG_Un    : out std_logic_vector(kNumInputMZN-1 downto 0);

    MZN_SIG_Dp    : out std_logic_vector(kNumInputMZN-1 downto 0); -- 96-127 ch
    MZN_SIG_Dn    : out std_logic_vector(kNumInputMZN-1 downto 0);

    -- PHY -------------------------------------------------------------------
    PHY_MDIO	    : inout std_logic;
    PHY_MDC       : out std_logic;
    PHY_nRST      : out std_logic;
    PHY_HPD       : out std_logic;
    --PHY_IRQ      : in std_logic;

    PHY_RXD       : in std_logic_vector(7 downto 0);
    PHY_RXDV      : in std_logic;
    PHY_RXER      : in std_logic;
    PHY_RX_CLK    : in std_logic;

    PHY_TXD       : out std_logic_vector(7 downto 0);
    PHY_TXEN      : out std_logic;
    PHY_TXER      : out std_logic;
    PHY_TX_CLK    : in std_logic;

    PHY_GTX_CLK   : out std_logic;

    PHY_CRS       : in std_logic;
    PHY_COL       : in std_logic;

    -- EEPROM ----------------------------------------------------------------
    PROM_CS	      : out std_logic;
    PROM_SK       : out std_logic;
    PROM_DI       : out std_logic;
    PROM_DO       : in std_logic;

    -- SPI flash memory ------------------------------------------------------
    FCS_B         : out std_logic;
--    USR_CLK       : out std_logic;
    MOSI          : out std_logic;
    DIN           : in  std_logic;

    -- J0 BUS ----------------------------------------------------------------
    -- Receiver mode --
    --J0RS         : in std_logic_vector(7 downto 1);
    J0DC          : out std_logic_vector(2 downto 1);

    -- Driver mode --
    --J0DS         : out std_logic_vector(7 downto 1);
    --J0RC         : in std_logic_vector(2 downto 1);

    -- User I/O --------------------------------------------------------------
    USER_RST_B    : in std_logic;
    NIMIN         : in  std_logic_vector(4 downto 1);
    NIMOUT        : out std_logic_vector(4 downto 1)

    );
end toplevel;

architecture Behavioral of toplevel is
  attribute mark_debug : string;
  attribute keep       : string;

  -- System ------------------------------------------------------------------
  signal sitcp_reset  : std_logic;
  signal system_reset : std_logic;
  signal user_reset   : std_logic;
  signal bct_reset    : std_logic;
  signal emergency_reset : std_logic;
  signal rst_from_bus : std_logic;

  -- DIP ---------------------------------------------------------------------
  signal dip_sw       : std_logic_vector(DIP'range);
  subtype DipID is integer range 0 to 7;
  type regLeaf is record
    Index : DipID;
  end record;
  constant kSiTCP     : regLeaf := (Index => 0);
  constant kNC1      : regLeaf := (Index => 1);
  constant kNC2      : regLeaf := (Index => 2);
  constant kNC3      : regLeaf := (Index => 3);
  constant kNC4       : regLeaf := (Index => 4);
  constant kNC5       : regLeaf := (Index => 5);
  constant kNC6       : regLeaf := (Index => 6);
  constant kUSER      : regLeaf := (Index => 7);

  -- Finxed input ports ------------------------------------------------------

  -- Mezzanine ports ---------------------------------------------------------
  signal mzn_u, mzn_d   : std_logic_vector(MZN_SIG_Up'range);
  signal dtl_u, dtl_d   : std_logic_vector(MZN_SIG_Up'range);
  --signal mznin_u, mznout_u  : std_logic_vector(MZN_SIG_Up'range);
  --signal mznin_d, mznout_d  : std_logic_vector(MZN_SIG_Up'range);

  -- SCTD --------------------------------------------------------------------
  signal mosi_u, mosi_d   : std_logic_vector(MZN_SIG_Up'range);

  -- SDS ---------------------------------------------------------------------
  signal shutdown_over_temp     : std_logic;
  signal uncorrectable_alarm    : std_logic;

  -- FMP ---------------------------------------------------------------------

  -- BCT --------------------------------------------------------------------
  signal addr_LocalBus          : LocalAddressType;
  signal data_LocalBusIn        : LocalBusInType;
  signal data_LocalBusOut       : DataArray;
  signal re_LocalBus            : ControlRegArray;
  signal we_LocalBus            : ControlRegArray;
  signal ready_LocalBus         : ControlRegArray;

  -- TSD ---------------------------------------------------------------------
  signal daq_data                          : std_logic_vector(kWidthDataTCP-1 downto 0);
  signal valid_data, empty_data, req_data  : std_logic;

  -- SiTCP -------------------------------------------------------------------
  signal sel_gmii_mii : std_logic;

  signal mdio_out, mdio_oe	: std_logic;
  signal tcp_isActive, close_req, close_act    : std_logic;
  signal reg_dummy0    : std_logic_vector(7 downto 0);
  signal reg_dummy1    : std_logic_vector(7 downto 0);
  signal reg_dummy2    : std_logic_vector(7 downto 0);
  signal reg_dummy3    : std_logic_vector(7 downto 0);

  signal tcp_tx_clk   : std_logic;
  signal tcp_rx_wr    : std_logic;
  signal tcp_rx_data  : std_logic_vector(kWidthDataTCP-1 downto 0);
  signal tcp_tx_full  : std_logic;
  signal tcp_tx_wr    : std_logic;
  signal tcp_tx_data  : std_logic_vector(kWidthDataTCP-1 downto 0);

  signal rbcp_act     : std_logic;
  signal rbcp_addr    : std_logic_vector(kWidthAddrRBCP-1 downto 0);
  signal rbcp_wd      : std_logic_vector(kWidthDataRBCP-1 downto 0);
  signal rbcp_we      : std_logic; --: Write enable
  signal rbcp_re      : std_logic; --: Read enable
  signal rbcp_ack     : std_logic; -- : Access acknowledge
  signal rbcp_rd      : std_logic_vector(kWidthDataRBCP-1 downto 0); -- : Read data[7:0]

  component WRAP_SiTCP_GMII_XC7K_32K
    port
      (
        CLK             : in  std_logic; --: System Clock >129MHz
        RST             : in  std_logic; --: System reset
        -- Configuration parameters
        FORCE_DEFAULTn  : in  std_logic; --: Load default parameters
        EXT_IP_ADDR     : in  std_logic_vector(31 downto 0); --: IP address[31:0]
        EXT_TCP_PORT    : in  std_logic_vector(15 downto 0); --: TCP port #[15:0]
        EXT_RBCP_PORT   : in  std_logic_vector(15 downto 0); --: RBCP port #[15:0]
        PHY_ADDR        : in  std_logic_vector(4 downto 0);  --: PHY-device MIF address[4:0]

        -- EEPROM
        EEPROM_CS       : out std_logic; --: Chip select
        EEPROM_SK       : out std_logic; --: Serial data clock
        EEPROM_DI       : out std_logic; --: Serial write data
        EEPROM_DO       : in  std_logic; --: Serial read data
        --    user data,lial values are stored in the EEPROM, 0xFFFF_FC3C-3F
        USR_REG_X3C     : out std_logic_vector(7 downto 0); --: Stored at 0xFFFF_FF3C
        USR_REG_X3D     : out std_logic_vector(7 downto 0); --: Stored at 0xFFFF_FF3D
        USR_REG_X3E     : out std_logic_vector(7 downto 0); --: Stored at 0xFFFF_FF3E
        USR_REG_X3F     : out std_logic_vector(7 downto 0); --: Stored at 0xFFFF_FF3F
        -- MII interface
        GMII_RSTn       : out std_logic; --: PHY reset
        GMII_1000M      : in  std_logic;  --: GMII mode (0:MII, 1:GMII)
        -- TX
        GMII_TX_CLK     : in  std_logic; -- : Tx clock
        GMII_TX_EN      : out std_logic; --: Tx enable
        GMII_TXD        : out std_logic_vector(7 downto 0); --: Tx data[7:0]
        GMII_TX_ER      : out std_logic; --: TX error
        -- RX
        GMII_RX_CLK     : in  std_logic; -- : Rx clock
        GMII_RX_DV      : in  std_logic; -- : Rx data valid
        GMII_RXD        : in  std_logic_vector(7 downto 0); -- : Rx data[7:0]
        GMII_RX_ER      : in  std_logic; --: Rx error
        GMII_CRS        : in  std_logic; --: Carrier sense
        GMII_COL        : in  std_logic; --: Collision detected
        -- Management IF
        GMII_MDC        : out std_logic; --: Clock for MDIO
        GMII_MDIO_IN    : in  std_logic; -- : Data
        GMII_MDIO_OUT   : out std_logic; --: Data
        GMII_MDIO_OE    : out std_logic; --: MDIO output enable
        -- User I/F
        SiTCP_RST       : out std_logic; --: Reset for SiTCP and related circuits
        -- TCP connectiorol
        TCP_OPEN_REQ    : in  std_logic; -- : Reserved input, shoud be 0
        TCP_OPEN_ACK    : out std_logic; --: Acknowledge for open (=Socket busy)
        TCP_ERROR       : out std_logic; --: TCP error, its active period is equal to MSL
        TCP_CLOSE_REQ   : out std_logic; --: Connection close request
        TCP_CLOSE_ACK   : in  std_logic ;-- : Acknowledge for closing
        -- FIFO I/F
        TCP_RX_WC       : in  std_logic_vector(15 downto 0); --: Rx FIFO write count[15:0] (Unused bits should be set 1)
        TCP_RX_WR       : out std_logic; --: Write enable
        TCP_RX_DATA     : out std_logic_vector(7 downto 0); --: Write data[7:0]
        TCP_TX_FULL     : out std_logic; --: Almost full flag
        TCP_TX_WR       : in  std_logic; -- : Write enable
        TCP_TX_DATA     : in  std_logic_vector(7 downto 0); -- : Write data[7:0]
        -- RBCP
        RBCP_ACT        : out std_logic; -- RBCP active
        RBCP_ADDR       : out std_logic_vector(31 downto 0); --: Address[31:0]
        RBCP_WD         : out std_logic_vector(7 downto 0); --: Data[7:0]
        RBCP_WE         : out std_logic; --: Write enable
        RBCP_RE         : out std_logic; --: Read enable
        RBCP_ACK        : in  std_logic; -- : Access acknowledge
        RBCP_RD         : in  std_logic_vector(7 downto 0 ) -- : Read data[7:0]
        );
  end component;

  -- Clock -------------------------------------------------------------------
  signal clk_sys, clk_gtx, clk_spi  : std_logic;
  signal clk_locked                 : std_logic;

  component clk_wiz_0
    port(
      -- Clock out ports --
      clk_sys     : out std_logic;
      clk_gtx     : out std_logic;
      clk_spi     : out std_logic;
      -- Status and control signals--
      reset       : in std_logic;
      locked      : out std_logic;
      clk_in1     : in std_logic
      );
  end component;

  -- debug -------------------------------------------------------------------

begin
  -- =========================================================================
  -- body
  -- =========================================================================

  -- Global ------------------------------------------------------------------
  system_reset  <= (NOT clk_locked) or (not USER_RST_B);
  user_reset    <= system_reset or rst_from_bus or emergency_reset;
  bct_reset     <= system_reset or emergency_reset;

  --dip_sw(0)   <= NOT DIP(0);
  dip_sw(1)   <= DIP(1);
  dip_sw(2)   <= DIP(2);
  dip_sw(3)   <= DIP(3);
  dip_sw(4)   <= DIP(4);
  dip_sw(5)   <= DIP(5);
  dip_sw(6)   <= DIP(6);
  dip_sw(7)   <= DIP(7);

  NIMOUT(1)   <= or_reduce(MAIN_IN_U);
  NIMOUT(2)   <= or_reduce(MAIN_IN_D);
  NIMOUT(3)   <= '0';
  NIMOUT(4)   <= '0';

  LED <= shutdown_over_temp & uncorrectable_alarm & "00";

  J0DC(1) <= '1';
  J0DC(2) <= '1';

  -- Fixed input ports -------------------------------------------------------


  -- Mezzanine connectors ----------------------------------------------------
  gen_mzn_sig : for i in 0 to 31 generate
    MZNU_BUFDS_Inst : OBUFDS
      generic map (IOSTANDARD => "LVDS", SLEW => "SLOW")
      port map (O => MZN_SIG_Up(i), OB => MZN_SIG_Un(i), I => mzn_u(i));

    MZND_BUFDS_Inst : OBUFDS
      generic map (IOSTANDARD => "LVDS", SLEW => "SLOW")
      port map (O => MZN_SIG_Dp(i), OB => MZN_SIG_Dn(i), I => mzn_d(i));
  end generate;

  u_DTL_NetAssign : entity mylib.DTL_NetAssign
    port map
      (
        mzn_out_u  => mzn_u,
        mzn_out_d  => mzn_d,
        dtl_in_u   => mosi_u,
        dtl_in_d   => mosi_d
      );

  --  --------------------------------------------------------------------
  u_SCTD_U : entity mylib.SctDriver
    generic map
    (
      kFreqSysClk   => 125_000_000,
      kNumIO        => kNumInputMZN,
      enDebug       => false
    )
    port map
    (
      -- System --
      rst         => user_reset,
      clk         => clk_sys,

      -- Rx Chip port --
      MOSI        => mosi_u,

      -- Local bus --
      addrLocalBus      => addr_LocalBus,
      dataLocalBusIn    => data_LocalBusIn,
      dataLocalBusOut   => data_LocalBusOut(kSCTDU.ID),
      reLocalBus        => re_LocalBus(kSCTDU.ID),
      weLocalBus        => we_LocalBus(kSCTDU.ID),
      readyLocalBus     => ready_LocalBus(kSCTDU.ID)
    );


  u_SCTD_D : entity mylib.SctDriver
    generic map
    (
      kFreqSysClk   => 125_000_000,
      kNumIO        => kNumInputMZN,
      enDebug       => false
    )
    port map
    (
      -- System --
      rst         => user_reset,
      clk         => clk_sys,

      -- Rx Chip port --
      MOSI        => mosi_d,

      -- Local bus --
      addrLocalBus      => addr_LocalBus,
      dataLocalBusIn    => data_LocalBusIn,
      dataLocalBusOut   => data_LocalBusOut(kSCTDD.ID),
      reLocalBus        => re_LocalBus(kSCTDD.ID),
      weLocalBus        => we_LocalBus(kSCTDD.ID),
      readyLocalBus     => ready_LocalBus(kSCTDD.ID)
    );

  -- SDS --------------------------------------------------------------------
  u_SDS_Inst : entity mylib.SelfDiagnosisSystem
    port map(
      rst               => user_reset,
      clk               => clk_sys,
      clkIcap           => clk_spi,

      -- Module input  --
      VP                => VP,
      VN                => VN,

      -- Module output --
      shutdownOverTemp  => shutdown_over_temp,
      uncorrectableAlarm => uncorrectable_alarm,

      -- Local bus --
      addrLocalBus      => addr_LocalBus,
      dataLocalBusIn    => data_LocalBusIn,
      dataLocalBusOut   => data_LocalBusOut(kSDS.ID),
      reLocalBus        => re_LocalBus(kSDS.ID),
      weLocalBus        => we_LocalBus(kSDS.ID),
      readyLocalBus     => ready_LocalBus(kSDS.ID)
      );


  -- FMP --------------------------------------------------------------------
  u_FMP_Inst : entity mylib.FlashMemoryProgrammer
    port map(
      rst	              => user_reset,
      clk	              => clk_sys,
      clkSpi            => clk_spi,

      -- Module output --
      CS_SPI            => FCS_B,
--      SCLK_SPI          => USR_CLK,
      MOSI_SPI          => MOSI,
      MISO_SPI          => DIN,

      -- Local bus --
      addrLocalBus      => addr_LocalBus,
      dataLocalBusIn    => data_LocalBusIn,
      dataLocalBusOut   => data_LocalBusOut(kFMP.ID),
      reLocalBus        => re_LocalBus(kFMP.ID),
      weLocalBus        => we_LocalBus(kFMP.ID),
      readyLocalBus     => ready_LocalBus(kFMP.ID)
      );


  -- BCT --------------------------------------------------------------------
  u_BCT_Inst : entity mylib.BusController
    port map(
      rstSys                    => bct_reset,
      rstFromBus                => rst_from_bus,
      reConfig                  => PROG_B_ON,
      clk                       => clk_sys,
      -- Local Bus --
      addrLocalBus              => addr_LocalBus,
      dataFromUserModules       => data_LocalBusOut,
      dataToUserModules         => data_LocalBusIn,
      reLocalBus                => re_LocalBus,
      weLocalBus                => we_LocalBus,
      readyLocalBus             => ready_LocalBus,
      -- RBCP --
      addrRBCP                  => rbcp_addr,
      wdRBCP                    => rbcp_wd,
      weRBCP                    => rbcp_we,
      reRBCP                    => rbcp_re,
      ackRBCP                   => rbcp_ack,
      rdRBCP                    => rbcp_rd
      );

  -- TSD ---------------------------------------------------------------------
  u_TSD_Inst : entity mylib.TCP_sender
    port map(
      RST               => user_reset,
      CLK               => clk_sys,

      -- data from EVB --
      rdFromEVB         => X"00",
      rvFromEVB         => '0',
      emptyFromEVB      => '1',
      reToEVB           => open,

      -- data to SiTCP
      isActive          => tcp_isActive,
      afullTx           => tcp_tx_full,
      weTx              => tcp_tx_wr,
      wdTx              => tcp_tx_data
      );


  -- SiTCP Inst -------------------------------------------------------------
  sitcp_reset     <= system_reset;
  PHY_MDIO        <= mdio_out when(mdio_oe = '1') else 'Z';
  sel_gmii_mii    <= '1';
  tcp_tx_clk      <= clk_gtx when(sel_gmii_mii = '1') else PHY_TX_CLK;
  PHY_GTX_CLK     <= clk_gtx;
  PHY_HPD         <= '0';

  u_SiTCP_Inst : WRAP_SiTCP_GMII_XC7K_32K
    port map
    (
      CLK               => clk_sys, --: System Clock >129MHz
      RST               => sitcp_reset, --: System reset
      -- Configuration parameters
      FORCE_DEFAULTn    => DIP(kSiTCP.Index), --: Load default parameters
      EXT_IP_ADDR       => X"00000000", --: IP address[31:0]
      EXT_TCP_PORT      => X"0000", --: TCP port #[15:0]
      EXT_RBCP_PORT     => X"0000", --: RBCP port #[15:0]
      PHY_ADDR          => "00000", --: PHY-device MIF address[4:0]

      -- EEPROM
      EEPROM_CS         => PROM_CS, --: Chip select
      EEPROM_SK         => PROM_SK, --: Serial data clock
      EEPROM_DI         => PROM_DI, --: Serial write data
      EEPROM_DO         => PROM_DO, --: Serial read data
      --    user data, intialial values are stored in the EEPROM, 0xFFFF_FC3C-3F
      USR_REG_X3C       => reg_dummy0, --: Stored at 0xFFFF_FF3C
      USR_REG_X3D       => reg_dummy1, --: Stored at 0xFFFF_FF3D
      USR_REG_X3E       => reg_dummy2, --: Stored at 0xFFFF_FF3E
      USR_REG_X3F       => reg_dummy3, --: Stored at 0xFFFF_FF3F
      -- MII interface
      GMII_RSTn         => PHY_nRST, --: PHY reset
      GMII_1000M        => sel_gmii_mii,  --: GMII mode (0:MII, 1:GMII)
      -- TX
      GMII_TX_CLK       => tcp_tx_clk, -- : Tx clock
      GMII_TX_EN        => PHY_TXEN, --: Tx enable
      GMII_TXD          => PHY_TXD, --: Tx data[7:0]
      GMII_TX_ER        => PHY_TXER, --: TX error
      -- RX
      GMII_RX_CLK       => PHY_RX_CLK, -- : Rx clock
      GMII_RX_DV        => PHY_RXDV, -- : Rx data valid
      GMII_RXD          => PHY_RXD, -- : Rx data[7:0]
      GMII_RX_ER        => PHY_RXER, --: Rx error
      GMII_CRS          => PHY_CRS, --: Carrier sense
      GMII_COL          => PHY_COL, --: Collision detected
      -- Management IF
      GMII_MDC          => PHY_MDC, --: Clock for MDIO
      GMII_MDIO_IN      => PHY_MDIO, -- : Data
      GMII_MDIO_OUT     => mdio_out, --: Data
      GMII_MDIO_OE      => mdio_oe, --: MDIO output enable
      -- User I/F
      SiTCP_RST         => emergency_reset, --: Reset for SiTCP and related circuits
      -- TCP connection rol
      TCP_OPEN_REQ      => '0', -- : Reserved input, shoud be 0
      TCP_OPEN_ACK      => tcp_isActive, --: Acknowledge for open (=Socket busy)
      --    TCP_ERROR       : out    std_logic; --: TCP error, its active period is equal to MSL
      TCP_CLOSE_REQ     => close_req, --: Connection close request
      TCP_CLOSE_ACK     => close_act, -- : Acknowledge for closing
      -- FIFO I/F
      TCP_RX_WC         => X"0000",    --: Rx FIFO write count[15:0] (Unused bits should be set 1)
      TCP_RX_WR         => open, --: Read enable
      TCP_RX_DATA       => open, --: Read data[7:0]
      TCP_TX_FULL       => tcp_tx_full, --: Almost full flag
      TCP_TX_WR         => tcp_tx_wr, -- : Write enable
      TCP_TX_DATA       => tcp_tx_data, -- : Write data[7:0]
      -- RBCP
      RBCP_ACT          => open, --: RBCP active
      RBCP_ADDR         => rbcp_addr, --: Address[31:0]
      RBCP_WD           => rbcp_wd, --: Data[7:0]
      RBCP_WE           => rbcp_we, --: Write enable
      RBCP_RE           => rbcp_re, --: Read enable
      RBCP_ACK          => rbcp_ack, -- : Access acknowledge
      RBCP_RD           => rbcp_rd -- : Read data[7:0]
      );

  u_gTCP_inst : entity mylib.global_sitcp_manager
    port map(
      RST           => system_reset,
      CLK           => clk_sys,
      ACTIVE        => tcp_isActive,
      REQ           => close_req,
      ACT           => close_act,
      rstFromTCP    => open
      );

  -- Clock inst ------------------------------------------------------
  u_ClkSys_Inst   : clk_wiz_0
    port map(
      -- Clock output ports --
      clk_sys     => clk_sys,
      clk_gtx     => clk_gtx,
      clk_spi     => clk_spi,

      -- Status and control signals --
      reset       => '0',
      locked      => clk_locked,
      clk_in1     => CLKOSC
      );

end Behavioral;

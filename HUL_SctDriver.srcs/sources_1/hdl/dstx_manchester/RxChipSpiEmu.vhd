library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

library mylib;
use mylib.defManchesterEncoder.all;
use mylib.defRxChipSpiEmu.all;
use mylib.defBCT.all;

entity RxChipSpiEmu is
  generic
  (
    freqSysClk  : integer := 125_000_000
  );
  port
  (
    -- System --
    rst         : in std_logic; -- Active high reset (async)
    clk         : in std_logic; -- System clock

    -- Rx Chip port --
    MOSI        : out std_logic; -- MOSI manchester coded signal

    -- Local bus --
    addrLocalBus        : in LocalAddressType;
    dataLocalBusIn      : in LocalBusInType;
    dataLocalBusOut	    : out LocalBusOutType;
    reLocalBus          : in std_logic;
    weLocalBus          : in std_logic;
    readyLocalBus	      : out std_logic
  );
end RxChipSpiEmu;

architecture RTL of RxChipSpiEmu is
  attribute mark_debug        : string;

  -- System --
  signal reset_shiftreg       : std_logic_vector(kWidthResetSync-1 downto 0);
  signal sync_reset           : std_logic;

  -- internal signal declaration ----------------------------------------
  signal mosi_txout     : std_logic;

  -- Local bus --
  signal reg_data_in    : DsTxDataType;
  signal en_write       : std_logic;
  signal start_a_cycle  : std_logic;
  signal busy_tx        : std_logic;
  signal state_com      : std_logic;

  signal state_lbus	    : BusProcessType;
begin
  -- =============================== body ===============================

  MOSI  <= mosi_txout when(state_com = '1') else '0';

  u_RxChipSpiInst : entity mylib.ManchesterTx
    generic map(
      freqSysClk => freqSysClk
      )
    port map(
      -- System --
      clk       => clk,
      reset     => sync_reset,
      dataIn    => reg_data_in,
      enWr      => en_write,
      start     => start_a_cycle,
      busy      => busy_tx,

      -- TX port --
      MOSI      => mosi_txout
    );

  ---------------------------------------------------------------------
  -- Local bus process
  ---------------------------------------------------------------------
  u_BusProcess : process(clk, sync_reset)
  begin
    if(sync_reset = '1') then
      start_a_cycle   <= '0';
      en_write        <= '0';
      state_lbus	    <= Init;
    elsif(clk'event and clk = '1') then
      case state_lbus is
        when Init =>
          start_a_cycle   <= '0';
          en_write        <= '0';
          dataLocalBusOut <= x"00";
          readyLocalBus		<= '0';
          state_lbus		  <= Idle;

        when Idle =>
          readyLocalBus	<= '0';
          if(weLocalBus = '1' or reLocalBus = '1') then
            state_lbus	<= Connect;
          end if;

        when Connect =>
          if(weLocalBus = '1') then
            state_lbus	<= Write;
          else
            state_lbus	<= Read;
          end if;

        when Write =>
          case addrLocalBus(kNonMultiByte'range) is
            when kWriteData(kNonMultiByte'range) =>
              reg_data_in   <= dataLocalBusIn;
              en_write      <= '1';
              state_lbus	  <= Finalize;

            when kStateCom(kNonMultiByte'range) =>
              state_com     <= dataLocalBusIn(0);
              state_lbus	  <= Finalize;

            when kStartCycle(kNonMultiByte'range) =>
              start_a_cycle   <= '1';
              state_lbus	    <= Finalize;

            when others =>
              state_lbus	<= Done;
          end case;

        when Read =>
          case addrLocalBus(kNonMultiByte'range) is
            when kBusyFlag(kNonMultiByte'range) =>
              dataLocalBusOut   <= B"0000_000" & busy_tx;
              state_lbus	      <= Done;

            when others => null;
          end case;

        when Finalize =>
          en_write        <= '0';
          start_a_cycle   <= '0';
          state_lbus      <= Done;

        when Done =>
          readyLocalBus	<= '1';
          if(weLocalBus = '0' and reLocalBus = '0') then
            state_lbus	<= Idle;
          end if;

        -- probably this is error --
        when others =>
          state_lbus	<= Init;
      end case;
    end if;
  end process u_BusProcess;

  -- Reset sequence --
  u_reset_gen_sys   : entity mylib.ResetGen
    port map(rst, clk, sync_reset);

end RTL;

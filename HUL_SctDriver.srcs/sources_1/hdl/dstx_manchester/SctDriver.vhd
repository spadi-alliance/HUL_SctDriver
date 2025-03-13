library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

library mylib;
use mylib.defManchesterEncoder.all;
use mylib.defSctDriver.all;
use mylib.defBCT.all;

entity SctDriver is
  generic
  (
    kFreqSysClk   : integer:= 125_000_000;
    kNumIO        : integer:= 32;
    enDebug       : boolean:= false
  );
  port
  (
    -- System --
    rst         : in std_logic; -- Active high reset (async)
    clk         : in std_logic; -- System clock

    -- Rx Chip port --
    MOSI        : out std_logic_vector(kNumIO-1 downto 0); -- MOSI manchester coded signal

    -- Local bus --
    addrLocalBus        : in LocalAddressType;
    dataLocalBusIn      : in LocalBusInType;
    dataLocalBusOut	    : out LocalBusOutType;
    reLocalBus          : in std_logic;
    weLocalBus          : in std_logic;
    readyLocalBus	      : out std_logic
  );
end SctDriver;

architecture RTL of SctDriver is
  attribute mark_debug        : boolean;

  signal sync_reset           : std_logic;

  -- internal signal declaration ----------------------------------------
  signal mosi_txout     : std_logic_vector(kNumIO-1 downto 0);

  -- Local bus --
  signal reg_data_in    : DsTxDataType;
  signal en_write       : std_logic_vector(kNumIO-1 downto 0);
  signal start_a_cycle  : std_logic_vector(kNumIO-1 downto 0);
  signal busy_tx        : std_logic_vector(kNumIO-1 downto 0);
  signal state_com      : std_logic_vector(kNumIO-1 downto 0);

  signal write_address  : std_logic_vector(7 downto 0);

  signal state_lbus	    : BusProcessType;

  -- Debug --------------------------------------------------------------
  attribute mark_debug of reg_data_in     : signal is enDebug;
  attribute mark_debug of en_write        : signal is enDebug;
  attribute mark_debug of start_a_cycle   : signal is enDebug;
  attribute mark_debug of busy_tx         : signal is enDebug;

  attribute mark_debug of state_lbus      : signal is enDebug;
begin
  -- =============================== body ===============================

  gen_RxChip : for i in 0 to kNumIO-1 generate
  begin

    MOSI(i) <= mosi_txout(i) when(state_com(i) = '1') else '1';

    u_RxChipSpiInst : entity mylib.ManchesterTx
      generic map(
        freqSysClk => kFreqSysClk
        )
      port map(
        -- System --
        clk       => clk,
        reset     => sync_reset,
        dataIn    => reg_data_in,
        enWr      => en_write(i),
        start     => start_a_cycle(i),
        busy      => busy_tx(i),

        -- TX port --
        MOSI      => mosi_txout(i)
      );
    end generate;

  ---------------------------------------------------------------------
  -- Local bus process
  ---------------------------------------------------------------------
  write_address   <= addrLocalBus(kNonMultiByte'left downto kNonMultiByte'left -7);

  u_BusProcess : process(clk, sync_reset)
  begin
    if(sync_reset = '1') then
      start_a_cycle   <= (others => '0');
      en_write        <= (others => '0');
      state_lbus	    <= Init;
    elsif(clk'event and clk = '1') then
      case state_lbus is
        when Init =>
          start_a_cycle   <= (others => '0');
          en_write        <= (others => '0');
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
            when kStateCom(kNonMultiByte'range) =>
            if(addrLocalBus(kMultiByte'range) = k1stByte) then
                state_com(7 downto 0)   <= dataLocalBusIn;
              elsif(addrLocalBus(kMultiByte'range) = k2ndByte) then
                state_com(15 downto 8)   <= dataLocalBusIn;
              elsif(addrLocalBus(kMultiByte'range) = k3rdByte) then
                state_com(23 downto 16)   <= dataLocalBusIn;
              else
                state_com(31 downto 24)   <= dataLocalBusIn;
              end if;
              state_lbus	    <= Finalize;

            when kStartCycle(kNonMultiByte'range) =>
            if(addrLocalBus(kMultiByte'range) = k1stByte) then
                start_a_cycle(7 downto 0)   <= dataLocalBusIn;
              elsif(addrLocalBus(kMultiByte'range) = k2ndByte) then
                start_a_cycle(15 downto 8)   <= dataLocalBusIn;
              elsif(addrLocalBus(kMultiByte'range) = k3rdByte) then
                start_a_cycle(23 downto 16)   <= dataLocalBusIn;
              else
                start_a_cycle(31 downto 24)   <= dataLocalBusIn;
              end if;
              state_lbus	    <= Finalize;

            when others =>
              reg_data_in                                         <= dataLocalBusIn;
              en_write(to_integer(unsigned(write_address)))       <= '1';
              state_lbus	                                        <= Finalize;

          end case;

        when Read =>
          case addrLocalBus(kNonMultiByte'range) is
            when kBusyFlag(kNonMultiByte'range) =>
              if(addrLocalBus(kMultiByte'range) = k1stByte) then
                dataLocalBusOut   <= busy_tx(7 downto 0);
              elsif(addrLocalBus(kMultiByte'range) = k2ndByte) then
                dataLocalBusOut   <= busy_tx(15 downto 8);
              elsif(addrLocalBus(kMultiByte'range) = k3rdByte) then
                dataLocalBusOut   <= busy_tx(23 downto 16);
              else
                dataLocalBusOut   <= busy_tx(31 downto 24);
              end if;
              state_lbus	      <= Done;

            when others => null;
          end case;

        when Finalize =>
          en_write        <= (others => '0');
          start_a_cycle   <= (others => '0');
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

---------------------------------------------------------------------
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library mylib;
use mylib.defManchesterEncoder.all;

entity ManchesterTx is
  generic(
    freqSysClk : integer := 125_000_000 --input clock speed from user logic in Hz
    --enDebug    : bool    := false
    );
  port(
    -- System --
    clk       : in std_logic;            --system clock
    reset     : in std_logic;            --synchronous active high reset
    dataIn    : in DsTxDataType;         --Data to be written
    enWr      : in std_logic;            --Write enable for dataIn
    start     : in std_logic;            --Start transmission cycle
    busy      : out std_logic;           --Busy flag

    -- TX port --
    MOSI      : out std_logic            --Master-out-slave-in (Manchester coded signal)
  );
end ManchesterTx;

architecture RTL of ManchesterTx is
  -- Signal definition --------------------------------------------------------------------

  -- Manchester encoder --
  signal sync_data  : DsTxDataType;
  signal reg_data   : DsTxDataType;
  signal reg_header : DsTxHeaderType;

  signal tx_ack     : std_logic;
  signal edge_tx_ack : std_logic_vector(1 downto 0);

  -- FSM --
  signal busy_tx          : std_logic;
  signal en_tx            : std_logic;
  signal fifo_read_gate   : std_logic;

  type TxChipType is
    (Init, Idle, SyncTxChip, SendData, Finalize, Done);
  signal state_tx         : TxChipType;

  -- FIFO --
  signal en_read          : std_logic;
  signal fifo_read_valid  : std_logic;
  signal fifo_data_is_valid : std_logic;
  signal fifo_dout, reg_fifo_dout    : DsTxDataType;
  signal fifo_empty       : std_logic;

  COMPONENT AsicSpiFifo
    PORT (
      clk : IN STD_LOGIC;
      srst : IN STD_LOGIC;
      din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      wr_en : IN STD_LOGIC;
      rd_en : IN STD_LOGIC;
      dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      full : OUT STD_LOGIC;
      empty : OUT STD_LOGIC;
      valid : OUT STD_LOGIC
    );
  END COMPONENT;

begin
  -- ====================================== body ====================================== --
  busy  <= busy_tx;

  -- Sync-frame generator -------------------------------------------------------------
  u_sync_data : process(clk, reset)
  begin
    if(clk'event and clk = '1') then
      if(reset = '1') then
        sync_data   <= kSyncData;
      else
        edge_tx_ack   <= edge_tx_ack(0) & tx_ack;
        if(edge_tx_ack = "01") then
          sync_data   <= sync_data(kSyncData'left-1 downto 0) & sync_data(kSyncData'left);
        end if;
      end if;
    end if;
  end process;

  -- TX process --
  u_fsm : process(clk, reset)
    variable sync_count : integer range 0 to kNumSyncCycle;
  begin
    if(clk'event and clk = '1') then
      if(reset = '1') then
        busy_tx       <= '0';
        en_tx         <= '0';
        fifo_read_gate  <= '0';
        state_tx      <= Init;
      else
        case state_tx is
          when Init =>
            state_tx  <= Idle;

          when Idle =>
            if(start = '1') then
              busy_tx     <= '1';
              en_tx       <= '1';
              sync_count  := kNumSyncCycle-1;
              state_tx    <= SyncTxChip;
            end if;

          when SyncTxChip =>
            if(edge_tx_ack = "01") then
              sync_count  := sync_count -1;
            end if;

            if(sync_count = 0) then
              fifo_read_gate  <= '1';
              state_tx        <= SendData;
            end if;

          when SendData =>
            if(edge_tx_ack = "01" and fifo_empty = '1') then
              fifo_read_gate  <= '0';
              sync_count      := kNumSyncCycle-1;
              state_tx        <= Finalize;
            end if;

          when Finalize =>
            if(edge_tx_ack = "01") then
              sync_count  := sync_count -1;
            end if;

            if(sync_count = 0) then
              state_tx        <= Done;
            end if;

          when Done =>
            busy_tx   <= '0';
            en_tx     <= '0';
            state_tx  <= Init;

          when others =>
            state_tx  <= Init;

        end case;
      end if;
    end if;
  end process;

  u_fifo_read : process(clk, reset)
  begin
    if(clk'event and clk = '1') then
      if(reset = '1') then
        en_read   <= '0';
        fifo_data_is_valid  <= '0';
      else
        -- FIFO read process --
        if(fifo_read_gate = '1' and edge_tx_ack = "01") then
          en_read   <= '1';
        else
          en_read   <= '0';
        end if;

        if(fifo_read_valid = '1') then
          fifo_data_is_valid  <= '1';
          reg_fifo_dout       <= fifo_dout;
        elsif(fifo_read_valid = '0' and edge_tx_ack = "01") then
          fifo_data_is_valid  <= '0';
        end if;

        -- Data select process --
        if(fifo_data_is_valid = '1') then
          reg_header  <= kDataHeader;
          reg_data    <= reg_fifo_dout;
        else
          reg_header  <= kSyncHeader;
          reg_data    <= sync_data;
        end if;
      end if;
    end if;
  end process;

  u_FIFO : AsicSpiFifo
    port map (
      clk     => clk,
      srst    => reset,
      din     => dataIn,
      wr_en   => enWr,
      rd_en   => en_read,
      dout    => fifo_dout,
      full    => open,
      empty   => fifo_empty,
      valid   => fifo_read_valid
    );

  u_ME : entity mylib.ManchesterEncoder
    generic map(
      freqSysClk => freqSysClk
      --enDebug    : bool    := false
      )
    port map(
      -- System --
      clk       => clk,
      reset     => reset,
      enTx      => en_tx,
      headerIn  => reg_header,
      dataIn    => reg_data,
      txAck     => tx_ack,
      txBeat    => open,
      txClk     => open,

      -- TX port --
      mosi      => MOSI
    );

end RTL;

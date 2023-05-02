---------------------------------------------------------------------
---------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

library mylib;
use mylib.defManchesterEncoder.all;

ENTITY SpiTxIf IS
  GENERIC(
    freqSysClk : integer := 125_000_000 --input clock speed from user logic in Hz
    --enDebug    : bool    := false
    );
  PORT(
    -- System --
    clk       : in std_logic;            --system clock
    reset     : in std_logic;            --active high reset
    enTx      : in std_logic;
    dataIn    : in DsTxDataType;
    txAck     : out std_logic;
    txBeat    : out std_logic;

    -- TX port --
    MOSI      : out std_logic;            --Master-out-slave-in (SPI MOSI)
    SCK       : out std_logic             --SPI clock
  );
END SpiTxIf;

ARCHITECTURE RTL OF SpiTxIf IS
  attribute mark_debug  : boolean;

  constant divider    : integer := (freqSysClk/freqTxClk)/2; --number of clocks in 1/2 cycle of TxClk
  constant kHalfCycle : integer := divider-1;

  signal tx_clk       : std_logic;                      --constantly running internal tx_clk
  signal tx_clk_prev  : std_logic;
  signal spi_clk      : std_logic;

  signal  int_data, reg_int_data    : DsTxDataType;
  signal  tx_beat, tx_ack           : std_logic;
  signal  ser_data                  : std_logic;
  signal  reg_ser_data              : std_logic;
  signal  int_en, int_en_prev       : std_logic;

  -- debug --


BEGIN
  -- =============================== body ================================== --
  txAck   <= tx_ack;
  txBeat  <= tx_beat;
  SCK     <= spi_clk;
  MOSI    <= ser_data;


  --generate the timing for the TxClk
  PROCESS(clk, reset)
    VARIABLE count  :  integer RANGE 0 TO divider*2;  --timing for clock generation
  BEGIN
    IF(reset = '1') THEN                --reset asserted
      count := 0;
    ELSIF(clk'EVENT AND clk = '1') THEN
      tx_clk_prev   <= tx_clk;          --store previous value of TxClk

      IF(count = divider*2-1) THEN      --end of timing cycle
        count := 0;                     --reset timer
      ELSE
        count := count + 1;             --continue clock generation timing
      END IF;
      CASE count IS
        WHEN 0 TO kHalfCycle =>          --first 1/2 cycle of clocking
          tx_clk   <= '0';
        WHEN OTHERS =>                  --last 1/2 cycle of clocking
          tx_clk   <= '1';
      END CASE;
    END IF;
  END PROCESS;

  int_data   <= dataIn;

  -- Serialization cycle --
  process(clk, reset)
    variable index : integer range 0 to kZeroData'length;
  begin
    if(clk'event and clk = '1') then
      if(reset = '1') then
        index         := kZeroData'length-1;
        reg_int_data  <= (others => '0');
        reg_ser_data  <= '0';
        tx_beat       <= '0';
        tx_ack        <= '0';
        int_en        <= '0';

      else
        ser_data  <= reg_ser_data and int_en_prev;
        spi_clk   <= (not tx_clk) and int_en_prev;

        -- Edge of TxClk --
        if(tx_clk = '1' and tx_clk_prev = '0') then
          int_en_prev     <= int_en;
          reg_ser_data    <= reg_int_data(index);

          -- Serialization loop --
          if(index = 0) then
            index   := kZeroData'length-1;
            tx_beat <= '1';

            if(enTx = '1') then
              reg_int_data  <= int_data;
              tx_ack        <= '1';
              int_en        <= '1';
            else
              int_en        <= '0';
            end if;
          else
            index         := index -1;
            tx_beat       <= '0';
            tx_ack        <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;


END RTL;

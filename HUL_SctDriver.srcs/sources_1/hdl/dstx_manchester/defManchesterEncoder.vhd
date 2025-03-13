library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package defManchesterEncoder is
  constant freqTxClk   : integer := 1_250_000; -- Data rate of Manchester coded signal

  subtype DsTxHeaderType  is std_logic_vector(1 downto 0);
  constant kSyncHeader    : DsTxHeaderType := "01";
  constant kDataHeader    : DsTxHeaderType := "10";

  subtype DsTxDataType    is std_logic_vector(7 downto 0);
  constant kZeroData      : DsTxDataType   := X"00";
  constant kSyncData      : DsTxDataType   := X"10";

  constant kLengthFrame   : integer := kSyncHeader'length + kZeroData'length;

  -- Manchester TX --
  constant kNumBalanceCycle   : integer := 2000;
  constant kNumSyncCycle      : integer := 2000;

end package;

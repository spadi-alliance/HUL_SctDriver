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
  constant kSyncData      : DsTxDataType   := X"01";

  constant kLengthFrame   : integer := kSyncHeader'length + kZeroData'length;

  -- Manchester TX --
  constant kNumSyncCycle  : integer := 4000;

end package;
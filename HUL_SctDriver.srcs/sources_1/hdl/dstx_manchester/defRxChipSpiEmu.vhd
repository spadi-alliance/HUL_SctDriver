library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library mylib;
use mylib.defBCT.all;

package defRxChipSpiEmu is
  -- Local Address  -------------------------------------------------------
  constant kWriteData       : LocalAddressType := x"000"; -- W,   [7:0]
  constant kBusyFlag        : LocalAddressType := x"010"; -- R,   [0:0]

  constant kStartCycle      : LocalAddressType := x"100"; -- W,
end package;
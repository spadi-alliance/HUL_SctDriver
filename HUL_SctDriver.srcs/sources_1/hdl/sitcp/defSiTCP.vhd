library ieee;
use ieee.std_logic_1164.all;

package defSiTCP is

  -- RBCP Bus definition
  constant kWidthAddrRBCP   : positive:=32;
  constant kWidthDataRBCP   : positive:=8;

  -- TCP bus definition
  constant kWidthDataTCP    : positive:=8;

end package defSiTCP;


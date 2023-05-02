library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package defToplevel is
  -- Number of input per a main port.
  constant kNumInput            : positive:= 32;
  constant kNumInputMZN         : positive:= 32;

  -- Mezzanine slot --
  constant kSlotUp              : positive:= 1;
  constant kSlotDown            : positive:= 2;
  
  -- HUL specification
  constant kNumLED              : positive:= 4;
  constant kNumBitDIP           : positive:= 8;

  constant kWidthRecvJ0S        : positive:= 7;

  -- J0 bus
  subtype J0bus is integer range 1 to 7;
  type regLeaf is record
    Index : J0bus;
  end record;
  constant kJ0Clear        : regLeaf := (Index => 1);
  constant kJ0Level2       : regLeaf := (Index => 2);
  constant kJ0Spill        : regLeaf := (Index => 3);
  constant kJ0Level1       : regLeaf := (Index => 4);
  constant kJ0EvtBit1st    : regLeaf := (Index => 5);
  constant kJ0EvtBit2nd    : regLeaf := (Index => 6);
  constant kJ0EvtBit3rd    : regLeaf := (Index => 7);
  
end package defToplevel;

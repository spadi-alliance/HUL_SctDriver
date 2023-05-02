library IEEE, mylib;
use IEEE.STD_LOGIC_1164.ALL;
use mylib.defToplevel.all;

entity MznOut_NetAssign is
  generic (
    kSlotPos  : positive
    );
  port (
    sigIn     : in std_logic_vector(kNumInputMZN-1 downto 0);
    mznOut    : out std_logic_vector(kNumInputMZN-1 downto 0)
    );
end MznOut_NetAssign;

architecture RTL of MznOut_NetAssign is

begin

  gen_slotup : if(kSlotPos = kSlotUp) generate
    mznOut(0)  <= sigIn(0);
    mznOut(1)  <= sigIn(1);
    mznOut(2)  <= sigIn(2);
    mznOut(3)  <= sigIn(3);
    mznOut(4)  <= sigIn(4);
    mznOut(5)  <= sigIn(5);
    mznOut(6)  <= sigIn(6);
    mznOut(7)  <= sigIn(7);
    mznOut(8)  <= sigIn(8);
    mznOut(9)  <= NOT sigIn(9);
    mznOut(10) <= sigIn(10);
    mznOut(11) <= sigIn(11);
    mznOut(12) <= sigIn(12);
    mznOut(13) <= sigIn(13);
    mznOut(14) <= NOT sigIn(14);
    mznOut(15) <= NOT sigIn(15);
    mznOut(16) <= sigIn(16);
    mznOut(17) <= sigIn(17);
    mznOut(18) <= sigIn(18);
    mznOut(19) <= sigIn(19);
    mznOut(20) <= sigIn(20);
    mznOut(21) <= sigIn(21);
    mznOut(22) <= sigIn(22);
    mznOut(23) <= sigIn(23);
    mznOut(24) <= sigIn(24);
    mznOut(25) <= NOT sigIn(25);
    mznOut(26) <= NOT sigIn(26);
    mznOut(27) <= sigIn(27);
    mznOut(28) <= NOT sigIn(28);
    mznOut(29) <= NOT sigIn(29);
    mznOut(30) <= sigIn(30);
    mznOut(31) <= sigIn(31);
  end generate;
    
  gen_slotdown : if(kSlotPos = kSlotDown) generate
    mznOut(0)  <= NOT sigIn(0);
    mznOut(1)  <= NOT sigIn(1);
    mznOut(2)  <= NOT sigIn(2);
    mznOut(3)  <= NOT sigIn(3);
    mznOut(4)  <= sigIn(4);
    mznOut(5)  <= sigIn(5);
    mznOut(6)  <= sigIn(6);
    mznOut(7)  <= sigIn(7);
    mznOut(8)  <= sigIn(8);
    mznOut(9)  <= sigIn(9);
    mznOut(10) <= sigIn(10);
    mznOut(11) <= sigIn(11);
    mznOut(12) <= sigIn(12);
    mznOut(13) <= sigIn(13);
    mznOut(14) <= sigIn(14);
    mznOut(15) <= sigIn(15);
    mznOut(16) <= sigIn(16);
    mznOut(17) <= sigIn(17);
    mznOut(18) <= sigIn(18);
    mznOut(19) <= sigIn(19);
    mznOut(20) <= sigIn(20);
    mznOut(21) <= sigIn(21);
    mznOut(22) <= sigIn(22);
    mznOut(23) <= sigIn(23);
    mznOut(24) <= sigIn(24);
    mznOut(25) <= NOT sigIn(25);
    mznOut(26) <= sigIn(26);
    mznOut(27) <= sigIn(27);
    mznOut(28) <= sigIn(28);
    mznOut(29) <= sigIn(29);
    mznOut(30) <= sigIn(30);
    mznOut(31) <= sigIn(31);
  end generate;

end RTL;

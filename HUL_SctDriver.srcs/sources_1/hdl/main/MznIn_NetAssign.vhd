library IEEE, mylib;
use IEEE.STD_LOGIC_1164.ALL;
use mylib.defToplevel.all;

entity MznIn_NetAssign is
  generic (
    kSlotPos  : positive
    );
  port (
    mznIn     : in std_logic_vector(kNumInputMZN-1 downto 0);
    sigOut    : out std_logic_vector(kNumInputMZN-1 downto 0)
    );
end MznIn_NetAssign;

architecture RTL of MznIn_NetAssign is

begin

  gen_slotup : if(kSlotPos = kSlotUp) generate
    sigOut(0)  <= mznIn(0);
    sigOut(1)  <= mznIn(1);
    sigOut(2)  <= mznIn(2);
    sigOut(3)  <= mznIn(3);
    sigOut(4)  <= mznIn(4);
    sigOut(5)  <= mznIn(5);
    sigOut(6)  <= mznIn(6);
    sigOut(7)  <= mznIn(7);
    sigOut(8)  <= mznIn(8);
    sigOut(9)  <= NOT mznIn(9);
    sigOut(10) <= mznIn(10);
    sigOut(11) <= mznIn(11);
    sigOut(12) <= mznIn(12);
    sigOut(13) <= mznIn(13);
    sigOut(14) <= NOT mznIn(14);
    sigOut(15) <= NOT mznIn(15);
    sigOut(16) <= mznIn(16);
    sigOut(17) <= mznIn(17);
    sigOut(18) <= mznIn(18);
    sigOut(19) <= mznIn(19);
    sigOut(20) <= mznIn(20);
    sigOut(21) <= mznIn(21);
    sigOut(22) <= mznIn(22);
    sigOut(23) <= mznIn(23);
    sigOut(24) <= mznIn(24);
    sigOut(25) <= NOT mznIn(25);
    sigOut(26) <= NOT mznIn(26);
    sigOut(27) <= mznIn(27);
    sigOut(28) <= NOT mznIn(28);
    sigOut(29) <= NOT mznIn(29);
    sigOut(30) <= mznIn(30);
    sigOut(31) <= mznIn(31);
  end generate;
    
  gen_slotdown : if(kSlotPos = kSlotDown) generate
    sigOut(0)  <= NOT mznIn(0);
    sigOut(1)  <= NOT mznIn(1);
    sigOut(2)  <= NOT mznIn(2);
    sigOut(3)  <= NOT mznIn(3);
    sigOut(4)  <= mznIn(4);
    sigOut(5)  <= mznIn(5);
    sigOut(6)  <= mznIn(6);
    sigOut(7)  <= mznIn(7);
    sigOut(8)  <= mznIn(8);
    sigOut(9)  <= mznIn(9);
    sigOut(10) <= mznIn(10);
    sigOut(11) <= mznIn(11);
    sigOut(12) <= mznIn(12);
    sigOut(13) <= mznIn(13);
    sigOut(14) <= mznIn(14);
    sigOut(15) <= mznIn(15);
    sigOut(16) <= mznIn(16);
    sigOut(17) <= mznIn(17);
    sigOut(18) <= mznIn(18);
    sigOut(19) <= mznIn(19);
    sigOut(20) <= mznIn(20);
    sigOut(21) <= mznIn(21);
    sigOut(22) <= mznIn(22);
    sigOut(23) <= mznIn(23);
    sigOut(24) <= mznIn(24);
    sigOut(25) <= NOT mznIn(25);
    sigOut(26) <= mznIn(26);
    sigOut(27) <= mznIn(27);
    sigOut(28) <= mznIn(28);
    sigOut(29) <= mznIn(29);
    sigOut(30) <= mznIn(30);
    sigOut(31) <= mznIn(31);
  end generate;

end RTL;

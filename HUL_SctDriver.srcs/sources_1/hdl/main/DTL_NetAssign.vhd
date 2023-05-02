library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DTL_NetAssign is
  port
  (
    mzn_out_u  : out  std_logic_vector(31 downto 0);
    mzn_out_d  : out  std_logic_vector(31 downto 0);
    dtl_in_u   : in std_logic_vector(31 downto 0);
    dtl_in_d   : in std_logic_vector(31 downto 0)
  );
end DTL_NetAssign;

architecture Behavioral of DTL_NetAssign is

begin
  mzn_out_u(15)    <= NOT dtl_in_u(0) ;
  mzn_out_u(13)    <=     dtl_in_u(1) ;
  mzn_out_u(11)    <=     dtl_in_u(2) ;
  mzn_out_u(9)     <= NOT dtl_in_u(3) ;
  mzn_out_u(7)     <=     dtl_in_u(4) ;
  mzn_out_u(5)     <=     dtl_in_u(5) ;
  mzn_out_u(3)     <=     dtl_in_u(6) ;
  mzn_out_u(1)     <=     dtl_in_u(7) ;
  mzn_out_u(31)    <=     dtl_in_u(8) ;
  mzn_out_u(29)    <= NOT dtl_in_u(9) ;
  mzn_out_u(27)    <=     dtl_in_u(10);
  mzn_out_u(25)    <= NOT dtl_in_u(11);
  mzn_out_u(23)    <=     dtl_in_u(12);
  mzn_out_u(21)    <=     dtl_in_u(13);
  mzn_out_u(19)    <=     dtl_in_u(14);
  mzn_out_u(17)    <=     dtl_in_u(15);
  mzn_out_u(14)    <= NOT dtl_in_u(16);
  mzn_out_u(12)    <=     dtl_in_u(17);
  mzn_out_u(10)    <=     dtl_in_u(18);
  mzn_out_u(8)     <=     dtl_in_u(19);
  mzn_out_u(6)     <=     dtl_in_u(20);
  mzn_out_u(4)     <=     dtl_in_u(21);
  mzn_out_u(2)     <=     dtl_in_u(22);
  mzn_out_u(0)     <=     dtl_in_u(23);
  mzn_out_u(30)    <=     dtl_in_u(24);
  mzn_out_u(28)    <= NOT dtl_in_u(25);
  mzn_out_u(26)    <= NOT dtl_in_u(26);
  mzn_out_u(24)    <=     dtl_in_u(27);
  mzn_out_u(22)    <=     dtl_in_u(28);
  mzn_out_u(20)    <=     dtl_in_u(29);
  mzn_out_u(18)    <=     dtl_in_u(30);
  mzn_out_u(16)    <=     dtl_in_u(31);

  mzn_out_d(15)    <=     dtl_in_d(0) ;
  mzn_out_d(13)    <=     dtl_in_d(1) ;
  mzn_out_d(11)    <=     dtl_in_d(2) ;
  mzn_out_d(9)     <=     dtl_in_d(3) ;
  mzn_out_d(7)     <=     dtl_in_d(4) ;
  mzn_out_d(5)     <=     dtl_in_d(5) ;
  mzn_out_d(3)     <= NOT dtl_in_d(6) ;
  mzn_out_d(1)     <= NOT dtl_in_d(7) ;
  mzn_out_d(31)    <=     dtl_in_d(8) ;
  mzn_out_d(29)    <=     dtl_in_d(9) ;
  mzn_out_d(27)    <=     dtl_in_d(10);
  mzn_out_d(25)    <= NOT dtl_in_d(11);
  mzn_out_d(23)    <=     dtl_in_d(12);
  mzn_out_d(21)    <=     dtl_in_d(13);
  mzn_out_d(19)    <=     dtl_in_d(14);
  mzn_out_d(17)    <=     dtl_in_d(15);
  mzn_out_d(14)    <=     dtl_in_d(16);
  mzn_out_d(12)    <=     dtl_in_d(17);
  mzn_out_d(10)    <=     dtl_in_d(18);
  mzn_out_d(8)     <=     dtl_in_d(19);
  mzn_out_d(6)     <=     dtl_in_d(20);
  mzn_out_d(4)     <=     dtl_in_d(21);
  mzn_out_d(2)     <= NOT dtl_in_d(22);
  mzn_out_d(0)     <= NOT dtl_in_d(23);
  mzn_out_d(30)    <=     dtl_in_d(24);
  mzn_out_d(28)    <=     dtl_in_d(25);
  mzn_out_d(26)    <=     dtl_in_d(26);
  mzn_out_d(24)    <=     dtl_in_d(27);
  mzn_out_d(22)    <=     dtl_in_d(28);
  mzn_out_d(20)    <=     dtl_in_d(29);
  mzn_out_d(18)    <=     dtl_in_d(30);
  mzn_out_d(16)    <=     dtl_in_d(31);

end Behavioral;

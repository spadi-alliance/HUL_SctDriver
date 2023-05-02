library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--library mylib;

entity DelayGen is
    generic(
      kNumDelay : integer:= 32
      );
    port (
      clk       : in std_logic;
      sigIn     : in std_logic;
      delayOut  : out std_logic
      );
end DelayGen;

architecture RTL of DelayGen is
  -- Internal signal declaration ---------------------------------------
  signal shift_reg : std_logic_vector(kNumDelay-1 downto 0);

begin
  --============================ body ==================================
  delayOut  <= shift_reg(kNumDelay-1);

  u_sr : process(clk)
  begin
    if(clk'event and clk = '1') then
      shift_reg   <= shift_reg(kNumDelay-2 downto 0) & sigIn;
    end if;
  end process;

end RTL;

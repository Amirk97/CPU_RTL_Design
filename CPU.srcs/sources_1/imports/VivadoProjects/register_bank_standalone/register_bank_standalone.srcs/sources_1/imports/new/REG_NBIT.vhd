library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.DigEng.ALL;
use IEEE.NUMERIC_STD.ALL;
-- This module contains the behavioral descreption
-- of a D-type register with variable size
-- It is consisted of a sequential circuit
entity REG_NBIT is
 generic (size : integer := 32);
 port(CLK, RST, WEN : in STD_LOGIC;    
      D             : in STD_LOGIC_VECTOR(size-1 downto 0); -- The data input to the register  
      Q             : out STD_LOGIC_VECTOR(size-1 downto 0) -- The output of register    
      );
end REG_NBIT;

architecture arch of REG_NBIT is
begin
  REG: process (CLK)
  begin
    if (rising_edge(CLK)) then
      if (RST = '1') then
        Q <= (others => '0');     
	  elsif (WEN = '1') then
        Q <= D;
 	  end if;
    end if;
  end process REG;
end arch;

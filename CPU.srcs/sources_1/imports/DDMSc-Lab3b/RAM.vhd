library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- It also contains a unit called sequencer, which calculates the address of*
-- Synchronous write / asynchrounous read 32x16 dual-port RAM
entity RAM is
    Port ( clk : in  STD_LOGIC;
           write_en : in  STD_LOGIC;                 -- Write enable
           Data_In : in  UNSIGNED (31 downto 0);     -- 32-bit data input
           Data_Address : in  UNSIGNED (6 downto 0); -- 7-bit address for
                                                     -- data 
           INST_Address : in  UNSIGNED (6 downto 0); -- 7-bit address for
                                                     -- instruction
           Data_Out : out  UNSIGNED (31 downto 0);   -- 32-bit data output
           INST_out : out  UNSIGNED (31 downto 0));  -- 32-bit instruction
                                                     -- output
end RAM;

architecture Behavioral of RAM is

type ram_type is array (0 to 127) of UNSIGNED(31 downto 0);
signal ram_inst: ram_type := (
    00  => X"00000000",
    01  => X"8407C00F", 
    02  => X"C007FDE0",
    03  => X"18007C1F",
    04  => X"10000001",
    05  => X"20000021",
    06  => X"CC0017E0",
    07  => X"980003E1",
    08  => X"20000021",
    09  => X"240003FF",
    10  => X"DC07F000",
    11  => X"84004002",
    12  => X"5400101E",
    13  => X"880003C3",
    14  => X"8C000FC4",
    15  => X"5BFFFC1D",
    16  => X"80000007",
    17  => X"500043A5",
    18  => X"50000486",
    19  => X"C00008C0",
    20  => X"10001C67",
    21  => X"64000484",
    22  => X"60000463",
    23  => X"240000A5",
    24  => X"C407E8A0",
    25  => X"94000007",
    26  => X"680024E7",
    27  => X"6C000CE7",
    28  => X"400000E8",
    29  => X"4C0023A8",
    30  => X"14001D09",
    31  => X"1C00052A",
    32  => X"D0002540",
    33  => X"D8002140",
    34  => X"1800094B",
    35  => X"D4001960",
    36  => X"48002CEC",
    37  => X"9C00040C",
    38  => X"44002D8C",
    39  => X"C8000D80",
    40  => X"DC000000",
    41  => X"DC000000",
    42  => X"9407E007",
    43  => X"DC000000",
    others => X"00000000"

);

begin

  -- Asynchronous read
  Data_Out <= ram_inst(to_integer(Data_Address));
  INST_out <= ram_inst(to_integer(INST_Address));  

  -- Synchronous write (write enable signal)
  process (clk)
  begin
    if (rising_edge(clk)) then 
       if (write_en='1') then
          ram_inst(to_integer(Data_Address)) <= Data_In;
       end if;
    end if;
  end process;

end Behavioral;


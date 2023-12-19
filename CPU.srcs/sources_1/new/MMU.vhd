

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


-- This module implements the Memory management unit for the cpu, It serves as
-- an interface between the processor and memory/IO , The virtual
-- addresses coming from control and processing unit get transformed to 
-- physical addresses suitable for Memory, The required signals for
-- peripherals and memory are also generated
entity MMU is
    Port ( OEn : in STD_LOGIC; -- The enable signal
                               -- that enables the
                               -- data to be written to 
                               -- memory/IO from datapath  
           IO_Data_i : in STD_LOGIC; -- The input data coming from IO, in 
                                     -- this case Its a pushbutton
           MIA_i : in STD_LOGIC_VECTOR (7 downto 0); -- the virtual instruction
                                                     -- address, coming from
                                                     -- control unit
           MDA_i : in STD_LOGIC_VECTOR (15 downto 0);-- The virtual data address
                                                     -- coming from processing
                                                     -- unit
           PU_Data_i : in STD_LOGIC_VECTOR (15 downto 0); -- the data which comes
                                                          -- from processing uint
           Mem_Data_i : in STD_LOGIC_VECTOR (31 downto 0);-- the data which comes
                                                          -- from memory 
           PU_Data_o : out STD_LOGIC_VECTOR (15 downto 0);-- the data which goes
                                                          -- to processing uint
           MIA_o : out STD_LOGIC_VECTOR (6 downto 0);-- the physical instruction
                                                     -- address, going to
                                                     -- memory
           MDA_o : out STD_LOGIC_VECTOR (6 downto 0);-- the physical data
                                                     -- address, going to
                                                     -- memory
           Mem_Data_o : out STD_LOGIC_VECTOR (31 downto 0);-- the data that goes
                                                           -- to memory 
           WE_Mem : out STD_LOGIC; -- write enable signal for memory
           WE_IO : out STD_LOGIC;  -- write enable signal for I/O register(LEDs)
           IO_Data_o : out STD_LOGIC_VECTOR (15 downto 0)); -- The data output to
                                                            -- IO registers(LED)
end MMU;

architecture Behavioral of MMU is
-- It also contains a unit called sequencer, which calculates the address of*
signal Ext_IO_Data_i : STD_LOGIC_VECTOR(15 downto 0); -- The input data coming
                                                      -- from IO, in this case
                                                      -- a pushbutton,extended
                                                      -- to 16 bits

begin

-- Extending the input data from pushbutton to 16 bits, compatible with CPU
Ext_IO_Data_i(15 downto 1) <= (others => '0') ;
Ext_IO_Data_i(0) <= IO_Data_i;

-- Fisrt two MSBs of MIA_i determine the page number, based on design we know
-- we only are going to use page 0 and it is loaded in memory in the physical
-- base address of 0x00, so the Fisrt two MSBs of MIA_i is replaced by 0
MIA_o <= '0' & MIA_i(5 downto 0);

-- bits number 7 & 8 determine the page number for data, based on design we know
-- we only are going to use page 0 and it is loaded in memory in the physical
-- base address of 0x40, first LSB bit of virtual address is going to select which
-- half of data returned by memory is our desired one and it doesnt affect the
-- the physical address generation
MDA_o <= '1' & MDA_i(6 downto 1);

-- since memory word differs from PU word, the first bit of virtual address is
-- going to select which half of data returned by memory is our desired one
-- The x"01F0" is the address for Pushbutton IO register
PU_Data_o <= Ext_IO_Data_i           when (MDA_i = x"01F0") else
             Mem_Data_i(15 downto 0) when (MDA_i(0) = '0')  else
             Mem_Data_i(31 downto 16)when (MDA_i(0) = '1')  else
             (others => 'U');
             
-- The bit eight of the MDA determines if we are writing to memory or 
-- peripheral and the write enable signals are assigned according to that
WE_Mem <= OEn when (MDA_i(8) = '0') else
          '0' when (MDA_i(8) = '1') else
          'U';
     
WE_IO <= OEn when (MDA_i(8) = '1') else
         '0' when (MDA_i(8) = '0') else
         'U';
         
IO_Data_o <= PU_Data_i;

-- Whenever there is a write, the memory reads the current value of that address,
-- first LSB of virtual address is going to select which half of data should be
-- replaced and written to  
Mem_data_o <= (Mem_data_i(31 downto 16) & PU_data_i) when (MDA_i(0) = '0') else
              (PU_data_i & Mem_data_i(15 downto 0)) when (MDA_i(0) = '1') else
              (others => 'U');      

end Behavioral;

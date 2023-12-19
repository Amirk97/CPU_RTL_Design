


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


-- In this module the memory subsystem is integrated with other parts of 
-- processor, It contains memory management unit, control unit and processing
-- unit, the inputs and outputs are signals coming from peripherals
entity Processor is
    Port ( PB : in STD_LOGIC; -- The start pushbutton which cues the cpu to
                              -- continue the execution of the instructions
           clk         : in std_logic;
           rst         : in std_logic;                   
           -- An outlet for displaying the internal process of the cpu                    
           LED_output : out STD_LOGIC_VECTOR (7 downto 0));
                                                            
end Processor;

architecture Behavioral of Processor is


-- The instruction that comes from memory 
signal INST        :  std_logic_vector(31 downto 0);
-- The data coming from the mmu as an input to a mux 
-- which its output gets connected to registers
signal Data_mem_i  :  STD_LOGIC_VECTOR(15 downto 0);
-- The data from bus B of register banks which is an output
-- data to mmu from processing unit       
signal Data_mem_o  :  STD_LOGIC_VECTOR(15 downto 0);
-- The address of data for mmu from processing unit      
signal MDA         :  STD_LOGIC_VECTOR(15 downto 0);
signal OEN         :  STD_LOGIC;     -- The enable signal
                                     -- that enables the
                                     -- data to be written to 
                                     -- memory from datapath                                                                                                 
-- The address of next instruction going to mmu
signal MIA         : STD_LOGIC_VECTOR(7 downto 0);
signal Mem_Data_i  : STD_LOGIC_VECTOR (31 downto 0);-- the data which comes
                                                    -- memory to mmu
signal MIA_o :  STD_LOGIC_VECTOR (6 downto 0);-- the physical instruction
                                              -- address, going to
                                              -- memory from mmu 
signal MDA_o :  STD_LOGIC_VECTOR (6 downto 0);  -- the physical data
                                                -- address, going to
                                                -- memory from mmu 
signal Mem_Data_o :  STD_LOGIC_VECTOR (31 downto 0);-- the data that goes
                                                    -- to memory from mmu
signal WE_Mem :  STD_LOGIC; -- write enable signal for memory
signal WE_IO :  STD_LOGIC;  -- write enable signal for I/O register(LEDs)
signal IO_Data_o :  STD_LOGIC_VECTOR (15 downto 0); -- The data output to
                                                    -- IO registers(LED)
signal LED_output_int : STD_LOGIC_VECTOR (15 downto 0);-- This signal is
                                                       -- devised to 
                                                       -- truncate 16 bit
                                                       -- register output
                                                       -- to 8                                                                                                                                                                                                    -- from memory 
begin
-- It also contains a unit called sequencer, which calculates the address of*
-- This module integrates control unit with Processing unit 
Control_process_unit : entity work.Control_datapath
    port map(clk => clk,
             rst => rst,
             INST => INST, -- The instruction that comes from memory 
             -- The data coming from the mmu as an input to a mux 
             -- which its output gets connected to registers
             Data_mem_i => Data_mem_i,
             -- The data from bus B of register banks which is an output
             -- data to mmu from processing unit    
             Data_mem_o => Data_mem_o,
             -- The address of data for mmu from processing unit  
             MDA => MDA,
             OEN => OEN,-- The enable signal
                        -- that enables the
                        -- data to be written to 
                        -- memory from datapath     
             MIA => MIA -- The address of next instruction going to mmu
            );
            
-- This module implements the Memory management unit for the cpu, It serves as
-- an interface between the processor and memory , The virtual
-- addresses coming from control and processing unit get transformed to 
-- physical addresses suitable for Memory, The required signals for
-- peripherals and memory are also generated
Mem_management : entity work.MMU
    Port Map(OEn => OEn, -- The enable signal
                         -- that enables the
                         -- data to be written to 
                         -- memory from datapath  
           IO_Data_i => PB, -- The input data coming from IO, in 
                            -- this case Its a pushbutton
           MIA_i => MIA,  -- the virtual instruction
                          -- address, coming from
                          -- control unit
           MDA_i => MDA,  -- The virtual data address
                          -- coming from processing
                          -- unit
           PU_Data_i => Data_mem_o, -- the data which comes
                                    -- from processing uint
           Mem_Data_i => Mem_Data_i, -- the data which comes
                                     -- from memory 
           PU_Data_o => Data_mem_i, -- the data which goes
                                    -- to processing uint
           MIA_o => MIA_o, -- the physical instruction
                           -- address, going to
                           -- memory
           MDA_o => MDA_o, -- the physical data
                           -- address, going to
                           -- memory
           Mem_Data_o => Mem_Data_o, -- the data that goes
                                     -- to memory 
           WE_Mem => WE_Mem,-- write enable signal for memory
           WE_IO => WE_IO,  -- write enable signal for I/O register(LEDs)
           IO_Data_o => IO_Data_o -- The data output to
                                  -- IO registers(LED)
    
            );
-- Synchronous write / asynchrounous read 32x16 dual-port RAM            
RAM_inst : entity work.RAM
    port map( clk => clk,
              write_en => WE_Mem,                -- Write enable
              Data_In  =>  UNSIGNED(Mem_Data_o), -- 32-bit data input
              Data_Address => UNSIGNED(MDA_o), -- 7-bit address for
                                               -- data 
              INST_Address => UNSIGNED(MIA_o), -- 7-bit address for
                                               -- instruction
              std_logic_vector(Data_Out) => Mem_Data_i,-- 32-bit data output
              std_logic_vector(INST_out) => INST-- 32-bit instruction output
          );
          
-- This module contains the behavioral descreption
-- of a D-type register with variable size, here Its used as an IO register
-- It is consisted of a sequential circuit            
IO_register : entity work.REG_NBIT
    generic map(size => 16)
    port map(clk => clk,
             rst => rst,
             wen => we_IO,
             D => IO_Data_o,
             Q => LED_output_int
             );
             
LED_output <= LED_output_int(15 downto 8);                                                

end Behavioral;

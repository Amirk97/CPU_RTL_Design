
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.DigEng.ALL;
use IEEE.NUMERIC_STD.ALL;


-- This module integrates control unit with Processing unit 
entity Control_datapath is
    port( clk         : in std_logic;
          rst         : in std_logic;
          -- The instruction that comes from memory 
          INST        : in std_logic_vector(31 downto 0);
          -- The data coming from the memory as an input to a mux 
          -- which its output gets connected to registers
          Data_mem_i  : in STD_LOGIC_VECTOR(15 downto 0);
          -- The data from bus B of register banks which is an output
          -- data to memory from processing unit       
          Data_mem_o  : out STD_LOGIC_VECTOR(15 downto 0);
          -- The address of data for memory from processing unit      
          MDA         : out STD_LOGIC_VECTOR(15 downto 0);
          OEN         : out STD_LOGIC;            -- The enable signal
                                                  -- that enables the
                                                  -- data to be written to 
                                                  -- memory from datapath                                               
                                                              
          -- The address of next instruction going to memory
          MIA         : out STD_LOGIC_VECTOR(7 downto 0)
          );       
end Control_datapath;

architecture Behavioral of Control_datapath is

signal AL          : STD_LOGIC_VECTOR(3 downto 0);                 
signal SH          : STD_LOGIC_VECTOR (3 downto 0);
signal s           : STD_LOGIC_VECTOR (2 downto 0);                  
signal Imm         : STD_LOGIC_VECTOR (15 downto 0);                   
signal MA          : STD_LOGIC_VECTOR (15 downto 0);       
signal RA          : STD_LOGIC_VECTOR( 4 downto 0);  
signal RB          : STD_LOGIC_VECTOR( 4 downto 0);  
signal WA          : STD_LOGIC_VECTOR( 4 downto 0);  
signal WEN         : STD_LOGIC;                                    
signal flags       : STD_LOGIC_VECTOR(7 downto 0);                 

begin

-- In this module the control logic for CPU is defined
-- The control logic fetches the instruction from memory and puts
-- it in Instruction Register, then based on the instruction
-- it issues the control signals needed for data path unit,
-- for that reason
-- It also contains a unit called sequencer, which calculates the address of
-- next instruction based on the current instruction and Flags from datapath
control_unit: entity work.control_logic
    port map(clk => clk,
             rst => rst,
             inst => inst,-- The instruction that comes from memory  
             mia => mia,  -- The address of next instruction going to memory
             AL =>  AL,   -- This control signal 
                          -- determines which 
                          -- operation is done 
                          -- by ALU
             -- This signal determines For How many positions we are shifting                                    
             SH => SH,            
             s => s,      -- The control logic for  muxes 
             -- The immediate value which can get selected for the input of one 
             -- of ALU's input                    
             Imm => Imm,
             -- The immediate value which can get selected as an input address 
             -- for memory                       
             MA => MA,
             -- the signal which is gonna get decoded and select which register 
             -- puts its data on the bus A               
             RA => RA,
             -- the signal which is gonna get decoded and select which register 
             -- puts its data on the bus B           
             RB => RB,
             -- the signal which is gonna get decoded and select which register 
             -- is gonna get written to            
             WA => WA,           
             WEN => WEN,  -- the write enable 
                          -- signal for writing 
                          -- into registers 
                          -- It determines if 
                          -- we have any   
                          -- writing to do or 
                          -- not                                      
             flags => flags( 6 downto 0),-- The flags that 
                                         -- result from ALU 
                                         -- operations
             OEN  => OEN  -- The enable signal
                          -- that enables the
                          -- data output to 
                          -- memory from datapath 
           );
             
-- This module implements the data path part for the CPU
-- It is consisted of ALU, register banks and few muxes
-- The register bank is consisted of sequential units
-- but the rest of module is just combinational circuits                    
processing_unit: entity work.data_path
    generic map(data_size => 16,
                num_reg   => 32)
    port map(clk => clk,
             -- The data coming from the memory as an input to a mux 
             -- which its output gets connected to registers
             Data_mem_i => Data_mem_i,
             -- The data from bus B of register banks which is an output
             -- data to memory from processing unit 
             Data_mem_o => Data_mem_o,
             rst => rst,
             AL =>  AL, -- This control signal 
                        -- determines which 
                        -- operation is done 
                        -- by ALU
             -- This signal determines For How many positions we are shifting                                    
             SH => SH,            
             s => s,    -- The control logic for  muxes
             -- The immediate value which can get selected for the input
             -- of one of ALU's input                    
             Imm => Imm,
             -- The immediate value which can get selected
             -- as an input address for memory                       
             MA => MA,               
             RA => RA,   -- the signal which is gonna get decoded and
                         -- select which register puts its data on the bus A        
             RB => RB,   -- the signal which is gonna get decoded and
                         -- select which register puts its data on the bus B         
             WA => WA,   -- the signal which is gonna get decoded and
                         -- select which register is gonna get written to        
             WEN => WEN, -- the write enable signal for writing into registers 
                         -- It determines if we have any writing to do or not                                     
             flags => flags, -- The flags that result from ALU operations
             MDA => MDA      -- The address for memory
             );
end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.DigEng.ALL;
use IEEE.NUMERIC_STD.ALL;

-- This module implements the data path part for the CPU
-- It is consisted of ALU, register banks and few muxes
-- The register bank is consisted of sequential units
-- but the rest of module is just combinational circuits
entity data_path is
    generic(data_size : integer := 32;
            num_reg   : integer := 8);
    port(AL          : in STD_LOGIC_VECTOR(3 downto 0);-- This control signal determines   
                                                        -- which operation is done by ALU
         -- This signal determines For How many positions we are shifting 
         SH          : in STD_LOGIC_VECTOR (log2(data_size)-1 downto 0);
         clk         : in STD_LOGIC;
         rst         : in STD_LOGIC;
         s           : in STD_LOGIC_VECTOR (2 downto 0);                -- The control logic for  muxes
         -- The immediate value which can get selected for the input of one of ALU's input   
         Imm         : in STD_LOGIC_VECTOR (data_size-1 downto 0);
         -- The immediate value which can get selected as an input address for memory                        
         MA          : in STD_LOGIC_VECTOR (data_size-1 downto 0);       
         RA          : in STD_LOGIC_VECTOR( log2(num_reg)-1 downto 0);   -- the signal which is gonna get decoded and
                                                                         -- select which register puts its data on the bus A
         RB          : in STD_LOGIC_VECTOR( log2(num_reg)-1 downto 0);   -- the signal which is gonna get decoded and
                                                                         -- select which register puts its data on the bus B
         WA          : in STD_LOGIC_VECTOR( log2(num_reg)-1 downto 0);   -- the signal which is gonna get decoded and
                                                                         -- select which register is gonna get written to
         WEN         : in STD_LOGIC;                                     -- the write enable signal for writing into registers 
                                                                         -- It determines if we have any writing to do or not
         Data_mem_i  : in STD_LOGIC_VECTOR (data_size-1 downto 0);       -- The data coming from the memory as an input to a mux 
                                                                         -- which its output gets connected to registers
         flags       : out STD_LOGIC_VECTOR(7 downto 0);                 -- The flags that result from ALU operations
         MDA         : out STD_LOGIC_VECTOR(data_size-1 downto 0);       -- The address for memory 
         Data_mem_o  : out STD_LOGIC_VECTOR (data_size-1 downto 0)       -- The data from bus B of register banks which is an output
                                                                         -- data to memory                                                                    
    );     

end data_path;

architecture Behavioral of data_path is
-- The outputs from register banks' buses
signal A       : STD_LOGIC_VECTOR( data_size-1 downto 0);       
signal B       : STD_LOGIC_VECTOR( data_size-1 downto 0);
Signal I1         : STD_LOGIC_VECTOR( data_size-1 downto 0);     -- The output going to I1 port of the ALU
signal ALU_output : STD_LOGIC_VECTOR( data_size-1 downto 0);
signal reg_input_data : STD_LOGIC_VECTOR( data_size-1 downto 0); -- The input data for register banks

begin
-- This module implements the Arithmatic logic unit of the CPU
-- The module is only consisted of combinational logic units
int_ALU : entity work.ALU
            Generic map(data_size => data_size)        
            PORT MAP (
               A => A,               -- Input data
               B => I1,              -- Input data
               -- This signal determines For How many positions we are shifting 
               X => SH,       
               Opcode => AL,         -- This control signal determines   
                                     -- which operation is done by ALU
               flags  => flags,      -- The output which shows the characteristics
                                     -- of the output of ALU operation
               ALU_out => ALU_output -- output parallel data
               );
               
-- In this entity the register bank of CPU is defined
-- There are two output buses and only one register can
-- be connected to one bus at a time
-- It is consisted of certain number of registers
-- the control signals determine which register output will be 
-- connected to the buses or which register is gonna get written
-- The only sequential part of this circuit is the registers,
-- The rest is consisted of combinational logic               
REG_BANK : entity work.reg_bank
                Generic map(data_size => data_size,
                            num_reg   => num_reg)
                PORT MAP(
                    input_data => reg_input_data,      -- the data that goes through the registers
                    RA         => RA,                  -- the signal which is gonna get decoded and
                                                       -- select which register puts its data on the bus A
                    RB         => RB,                  -- the signal which is gonna get decoded and
                                                       -- select which register puts its data on the bus B
                    WA         => WA,                  -- the signal which is gonna get decoded and
                                                       -- select which register is gonna get written to
                    WEN        => WEN,                 -- the write enable signal for writing into registers 
                                                       -- It determines if we have any writing to do or not                                                               
                    clk        => clk,
                    rst        => rst,                                                              
                    Data_out_A => A,                    -- the output data on the Bus A
                    Data_out_B => B                     -- the output data on the Bus B   
                    );               



Data_mem_o <= B;

-- Creating the mux before ALU input
I1 <= B   when ( S(0) = '0') else
      Imm when ( S(0) = '1') else
      (others => 'U') ;

-- Creating the mux for memory address bus     
MDA <= ALU_output when ( S(1) = '0') else
       MA         when ( S(1) = '1') else
      (others => 'U')  ;

-- Creating the mux for register inputs           
reg_input_data <= ALU_output  when ( S(2) = '0') else
                  Data_mem_i  when ( S(2) = '1') else
                  (others => 'U')  ;                   
      

end Behavioral;

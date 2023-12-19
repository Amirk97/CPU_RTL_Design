
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.DigEng.ALL;
use IEEE.NUMERIC_STD.ALL;

-- In this module the control logic for CPU is defined
-- The control logic fetches the instruction from memory and puts
-- it in Instruction Register, then based on the instruction
-- it issues the control signals needed for data path unit,
-- It also contains a unit called sequencer, which calculates the address of
-- next instruction based on the current instruction and Flags from datapath

entity control_logic is
    port(clk         : in STD_LOGIC;
         rst         : in STD_LOGIC;
         flags       : in STD_LOGIC_VECTOR(6 downto 0); -- The flags that 
                                                        -- result from ALU 
                                                        -- operations
         -- The instruction that comes from memory                                                                    
         INST        : in STD_LOGIC_VECTOR (31 downto 0);                                               
         AL          : out STD_LOGIC_VECTOR(3 downto 0);-- This control signal 
                                                        -- determines which 
                                                        -- operation is done 
                                                        -- by ALU
         -- This signal determines For How many positions we are shifting 
         SH          : out STD_LOGIC_VECTOR (3 downto 0);
         s           : out STD_LOGIC_VECTOR (2 downto 0);-- The control logic 
                                                         -- for  muxes
         -- The immediate value which can get selected for the input of one 
         -- of ALU's input   
         Imm         : out STD_LOGIC_VECTOR (15 downto 0);
         -- The immediate value which can get selected as an input address 
         -- for memory                        
         MA          : out STD_LOGIC_VECTOR (15 downto 0);
         -- the signal which is gonna get decoded and select which register 
         -- puts its data on the bus A
         RA          : out STD_LOGIC_VECTOR(4 downto 0);
	     -- the signal which is gonna get decoded and select which register 
         -- puts its data on the bus B
         RB          : out STD_LOGIC_VECTOR(4 downto 0);
	     -- the signal which is gonna get decoded and select which register 
         -- is gonna get written to
         WA          : out STD_LOGIC_VECTOR(4 downto 0);   
         WEN         : out STD_LOGIC;                   -- the write enable 
                                                        -- signal for writing 
                                                        -- into registers 
                                                        -- It determines if 
                                                        -- we have any   
                                                        -- writing to do or 
                                                        -- not
         OEN         : out STD_LOGIC;                   -- The enable signal
                                                        -- that enables the
                                                        -- data output to 
                                                        -- memory from datapath                                               
                                                             
         -- The address of next instruction going to memory
         MIA         : out STD_LOGIC_VECTOR(7 downto 0)

         );      

end control_logic;

architecture Behavioral of control_logic is

signal  IR_o  : STD_LOGIC_VECTOR( 31 downto 0); -- The output of
                                                -- instruction register
signal  PC_o  : STD_LOGIC_VECTOR( 7 downto 0); -- The output of
                                               -- instruction register                                                      
signal  MIA_int : STD_LOGIC_VECTOR(7 downto 0);

signal  PC_o_sum : STD_LOGIC_VECTOR(8 downto 0);-- The 9-bit result of
                                                -- PC and offset sum  

begin

-- This module contains the behavioral descreption
-- of a D-type register with variable size
-- It is consisted of a sequential circuit
-- This instance is used as instruction register                                                
    instruction_reg: entity work.REG_NBIT
        generic map(size => 32)
        port map ( clk => clk,
                   rst => rst,
                   WEN => '1',      -- Write enable signal for register
                   Q   => IR_o,     -- The output of register 
                   D   => INST);    -- The data input to the register  
      
-- This module contains the behavioral descreption
-- of a D-type register with variable size
-- It is consisted of a sequential circuit 
-- This instance is used as program counter                                                 
    program_counter: entity work.REG_NBIT
       generic map(size => 8)
       port map ( clk => clk,
                  rst => rst,
                  WEN => '1',      -- Write enable signal for register
                  Q   => PC_o,     -- The output of register 
                  D   => MIA_INT); -- The data input to the register

-- Here the control signals which only depend on opcode are generated 
-- The muxes are designed based on the table of control signals in
-- document               
    WEN <= '0' when ((IR_o(31 downto 26) = "000000") or
                     (IR_o(31 downto 26) = "100101") or
                     (IR_o(31 downto 26) = "100110") or
                     (IR_o(31 downto 26) = "100111") or
                     (IR_o(31 downto 30) = "11"))   else 
           '1';
                      
    OEN <= '1' when ((IR_o(31 downto 26) = "100101") or
                     (IR_o(31 downto 26) = "100110") or
                     (IR_o(31 downto 26) = "100111"))else
           '0';
           
    with IR_o(31 downto 26) select
    AL <= "1010"    when "000100",
          "1010"    when "000110",
          "1010"    when "100011",
          "1010"    when "100111",
          "1011"    when "000101",
          "1011"    when "000111",
          "1000"    when "001000",
          "1001"    when "001001",
          "0111"    when "010000",
          "0100"    when "010001",
          "0100"    when "010100",
          "0110"    when "010011",
          "1100"    when "011000",
          "1101"    when "011001",
          "1110"    when "011010",
          "1111"    when "011011",
          "0000"    when "000000",
          "0000"    when "100000",
          "0000"    when "100010",
          "0000"    when "100110",                             
          "0101"    when others;
          
    s(0) <= '1'    when ((IR_o(31 downto 26) = "000110") or             
                          (IR_o(31 downto 26) = "000111") or
                          (IR_o(31 downto 26) = "010100") or
                          (IR_o(31 downto 26) = "010101") or
                          (IR_o(31 downto 26) = "010110") or
                          (IR_o(31 downto 26) = "100011") or
                          (IR_o(31 downto 26) = "100111")) else
            '0';
             
    s(1) <= '1'     when ((IR_o(31 downto 26) = "100001") or
                          (IR_o(31 downto 26) = "100101"))else
            '0';
            
    s(2) <= '1'     when ((IR_o(31 downto 26) = "100001") or
                          (IR_o(31 downto 26) = "100010") or
                          (IR_o(31 downto 26) = "100011"))else
            '0'; 
            
-- Here the control signals which only depend on operand and opcode are generated                               
-- these signals are generated based on the the instruction coding for each
-- instruction                         
    RA  <= IR_o(9 downto 5);
    
    RB  <= IR_o(4 downto 0) when (IR_o(31)= '1') else
           IR_o(14 downto 10);
          
    WA  <= IR_o(4 downto 0);
    
    SH  <= IR_o(13 downto 10);
    
    Imm <= IR_o(25 downto 10);                                   
    
    MA  <= IR_o(25 downto 10);
    
-- Here the sequencer is defined, the address of next instruction
-- is calculated based on the opcodes and flags, The only sequential
-- part is the PC register

    -- The content of PC is an unsigned number which indicates a memory address
    -- but for being able to do jumps/branched we somtimes need to decrement the
    -- Pc so here a sign bit is concatenated to PC output and summation is done
    -- in signed number notation.  
    PC_o_sum <= std_logic_vector((signed('0'&PC_o) + signed(IR_o(18 downto 10))));
    
    MIA_int <= PC_o_sum(7 downto 0) when
                           (((IR_o(31 downto 26) = "110000") and (flags(0) = '1'))or
                            ((IR_o(31 downto 26) = "110001") and (flags(1) = '1'))or     
                            ((IR_o(31 downto 26) = "110010") and (flags(2) = '1'))or
                            ((IR_o(31 downto 26) = "110011") and (flags(3) = '1'))or
                            ((IR_o(31 downto 26) = "110100") and (flags(4) = '1'))or
                            ((IR_o(31 downto 26) = "110101") and (flags(5) = '1'))or
                            ((IR_o(31 downto 26) = "110110") and (flags(6) = '1'))or
                            ((IR_o(31 downto 26) = "110111"))) else
            std_logic_vector(unsigned(PC_o) + 1);                 
                            
MIA <= MIA_int;                                   
               

end Behavioral;

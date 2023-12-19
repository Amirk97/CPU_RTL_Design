library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.DigEng.ALL;
use IEEE.NUMERIC_STD.ALL;

-- In this entity the register bank of CPU is defined
-- There are two output buses and only one register can
-- be connected to one bus at a time
-- It is consisted of certain number of registers
-- the control signals determine which register output will be 
-- connected to the buses or which register is gonna get written
-- The only sequential part of this circuit is the registers,
-- The rest is consisted of combinational logic

entity reg_bank is
    generic(data_size : integer := 16;
            num_reg   : integer := 8);
    port( -- the data that goes through the registers
          input_data  : in STD_LOGIC_VECTOR( data_size-1 downto 0);
          -- the signal which is gonna get decoded and select which register puts its data on the bus A       
          RA          : in STD_LOGIC_VECTOR( log2(num_reg)-1 downto 0); 
          -- the signal which is gonna get decoded and select which register puts its data on the bus B  
          RB          : in STD_LOGIC_VECTOR( log2(num_reg)-1 downto 0);
          -- the signal which is gonna get decoded and select which register is gonna get written to   
          WA          : in STD_LOGIC_VECTOR( log2(num_reg)-1 downto 0);
          -- the write enable signal for writing into registers, It determines if we have any writing to do or not    
          WEN         : in STD_LOGIC;                                                                                                   
          clk         : in STD_LOGIC;
          rst         : in STD_LOGIC;                                                                  
          Data_out_A  : out STD_LOGIC_VECTOR( data_size-1 downto 0);     -- the output data on the Bus A
          Data_out_B  : out STD_LOGIC_VECTOR( data_size-1 downto 0)      -- the output data on the Bus B                                                         
                                                                                                                                                                                                                                                          
         );
    
end reg_bank;

architecture Behavioral of reg_bank is

type reg_bank_type is array (num_reg-1 downto 0) of
    std_logic_vector(data_size-1 downto 0);
    
signal  reg_bank_o : reg_bank_type;                        -- Each element of this array gets connected to the
                                                           -- output of corresponding register
signal  wen_int    : std_logic_vector(num_reg-1 downto 1); -- The internal write enable signal
                                                           -- which gets connected to registers
                                                           -- directly

begin
-- The for-generate loop creates the registers from 1 to n
-- and also the neccesary decoders and buffers

    reg_bank: for i in 1 to num_reg-1 generate  -- it is started from 1 because
                                                -- register 0 is not going to
                                                -- be synthesized here
    -- This module contains the behavioral descreption
    -- of a D-type register with variable size
    -- It is consisted of a sequential circuit                                                
     one_reg: entity work.REG_NBIT
        generic map(size => data_size)
        port map ( clk => clk,
                   rst => rst,
                   WEN => wen_int(i),    -- Write enable signal for register
                   Q   => reg_bank_o(i), -- The output of register 
                   D   => input_data);   -- The data input to the register  
    
     -- This circuit implements the tri-state buffer which is between 
     -- the output of registers and bus A with the required decoders              
     Data_out_A <= reg_bank_o(i) when ( unsigned(RA) = i) 
                   else (others => 'Z');
                   
    -- This circuit implements the tri-state buffer which is between 
    -- the output of registers and bus B with the required decoders                  
     Data_out_B <= reg_bank_o(i) when ( unsigned(RB) = i) 
                   else (others => 'Z'); 
                   
    -- This circuit implements the decoder for producing the write enable signals
    -- for the registers     
     wen_int(i) <= '1' when ( unsigned(WA) = i and WEN = '1')
                   else '0';                           
     
    end generate;
    
-- The following set of circuits create the R0 which is 
-- simply grounded bus and required tri-state buffers and decoders 
    reg_bank_o(0) <= (others => '0');
    
    Data_out_A <= reg_bank_o(0) when ( unsigned(RA) = 0) 
                  else (others => 'Z');
                  
    Data_out_B <= reg_bank_o(0) when ( unsigned(RB) = 0) 
                  else (others => 'Z');              
                   
    

end Behavioral;

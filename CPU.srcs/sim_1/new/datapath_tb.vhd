
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.DigEng.ALL;
use IEEE.NUMERIC_STD.ALL;


entity datapath_tb is

end datapath_tb;

architecture Behavioral of datapath_tb is

constant clk_period : time := 10 ns;
constant data_size : integer := 16;
constant num_reg   : integer := 32;

signal AL          : STD_LOGIC_VECTOR(3 downto 0);                 
signal SH          : STD_LOGIC_VECTOR (log2(data_size)-1 downto 0);
signal clk         : STD_LOGIC;
signal rst         : STD_LOGIC;
signal s           : STD_LOGIC_VECTOR (2 downto 0);                  
signal Imm         : STD_LOGIC_VECTOR (data_size-1 downto 0);                   
signal MA          : STD_LOGIC_VECTOR (data_size-1 downto 0);       
signal RA          : STD_LOGIC_VECTOR( log2(num_reg)-1 downto 0);  
signal RB          : STD_LOGIC_VECTOR( log2(num_reg)-1 downto 0);  
signal WA          : STD_LOGIC_VECTOR( log2(num_reg)-1 downto 0);  
signal WEN         : STD_LOGIC;                                    
signal Data_mem_i  : STD_LOGIC_VECTOR (data_size-1 downto 0);       
signal flags       : STD_LOGIC_VECTOR(7 downto 0);                 
signal MDA         : STD_LOGIC_VECTOR(data_size-1 downto 0);       
signal Data_mem_o  : STD_LOGIC_VECTOR (data_size-1 downto 0);
signal OEN         : STD_LOGIC;      

begin

UUT : entity work.data_path
  generic map(data_size => data_size,
              num_reg => num_reg)
  port map(
   AL => AL,                   
   SH => SH,        
   clk => clk,       
   rst => rst,       
   s => s,                     
   Imm => Imm,                     
   MA  => MA,             
   RA  => RA ,       
   RB  => RB,         
   WA  => WA,           
   WEN => WEN,                                       
   Data_mem_i => Data_mem_i,     
   flags => flags,                      
   MDA  =>  MDA,          
   Data_mem_o => Data_mem_o
   );

-- Clock process
clk_process :process
begin
     clk <= '0';
     wait for clk_period/2;
     clk <= '1';
     wait for clk_period/2;
end process; 

-- This module is gonna get tested with a sequence of instructions and verifying
-- if it can execute them properly, for each instruction the corresponding control
-- signals will be generated in the testbench, Here are the instruction:
-- inc R1, R0;
-- addi R2, R0, 005;
-- shl R3, R1, 3;
-- storr R2, R3;
-- loadi R5, 1f1f;
-- After this sequence the reset signal is tested and then these instructions
-- are repeated agian

test_process : process
begin
   -- wait 100 ns for global reset to finish
   wait for 100ns;
   
   wait until falling_edge(clk); -- Clock Synchronization
   
   -- initializing inputs
   AL  <= (others => '0');                   
   SH  <= (others => '0');        
   rst <= '0';       
   s   <= (others => '0');                      
   Imm <= (others => '0');                      
   MA  <= (others => '0');              
   RA  <= (others => '0');        
   RB  <= (others => '0');          
   WA  <= (others => '0');            
   WEN <= '0';                                       
   Data_mem_i <= (others => '0');
   OEN <= '0';     
   wait for clk_period*1;
   
   rst <= '1';                   -- reseting the module
   wait for clk_period*1;
   
   rst <= '0';
   wait for clk_period*1;
   
   -- Simulating the control signals for inc R1, R0
   RA  <= (others => '0');
   AL  <= "1000";
   s(2)<= '0';
   WEN <= '1';
   WA  <= std_logic_vector(to_unsigned(1, log2(num_reg)));
   wait for clk_period*1;
   
   -- Simulating the control signals for addi R2, R0, 005
   RA   <= (others => '0');
   s(0) <= '1';
   Imm  <= std_logic_vector(to_signed(5, data_size));
   AL   <= "1010";
   WEN  <= '1';
   WA   <= std_logic_vector(to_unsigned(2, log2(num_reg)));
   wait for clk_period*1;   
   
   -- Simulating the control signals for shl R3, R1, 3
   RA   <= std_logic_vector(to_unsigned(1, log2(num_reg)));
   s(0) <= '0';     
   Imm  <= std_logic_vector(to_signed(0, data_size));
   AL   <= "1100";
   SH   <= std_logic_vector(to_unsigned(3, size(data_size-1)));
   WEN  <= '1';
   WA   <= std_logic_vector(to_unsigned(3, log2(num_reg)));
   wait for clk_period*1;  
   
   -- Simulating the control signals for storr R2, R3
   RA   <= std_logic_vector(to_unsigned(3, log2(num_reg)));
   RB   <= std_logic_vector(to_unsigned(2, log2(num_reg)));
   OEN  <= '1';
   AL   <= "0000";
   s(1) <= '0';
   SH   <= (others => '0');
   WEN  <= '0';
   WA   <= (others => '0');
   wait for clk_period*1;  
   
   -- Simulating the control signals for loadi R5, 1f1f
   RA   <= (others => '0');
   RB   <= (others => '0');
   OEN  <= '0';
   MA   <= x"1F1F";
   s(1) <= '1';
   s(2) <= '1';
   Data_mem_i <= std_logic_vector(to_signed(7, data_size));
   WEN  <= '1';
   WA   <= std_logic_vector(to_unsigned(5, log2(num_reg)));
   wait for clk_period*1;
   
   -- reseting the module, when this module gets integrated
   -- to the final top module and the reset signal is set the
   -- values for WEN and OEN will also get set to zero by the
   -- control unit, here this assignment is also performed to
   -- simulate the reality 
   rst <= '1';
   OEN <= '0';            
   WEN <= '0';
   wait for clk_period*1;
   
   rst <= '0';
   wait for clk_period*1;
   
   -- Simulating the control signals for inc R1, R0
   RA  <= (others => '0');
   AL  <= "1000";
   s(2)<= '0';
   WEN <= '1';
   WA  <= std_logic_vector(to_unsigned(1, log2(num_reg)));
   wait for clk_period*1;
   
   -- Simulating the control signals for addi R2, R0, 005
   RA   <= (others => '0');
   s(0) <= '1';
   Imm  <= std_logic_vector(to_signed(5, data_size));
   AL   <= "1010";
   WEN  <= '1';
   WA   <= std_logic_vector(to_unsigned(2, log2(num_reg)));
   wait for clk_period*1;   
   
   wait;
   
end process;    

end Behavioral;

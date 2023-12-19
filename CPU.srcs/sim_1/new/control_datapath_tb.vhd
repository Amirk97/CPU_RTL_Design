
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.DigEng.ALL;
use IEEE.NUMERIC_STD.ALL;


entity control_datapath_tb is

end control_datapath_tb;

architecture Behavioral of control_datapath_tb is

constant clk_period : time := 10 ns;

signal clk         :  std_logic;
signal rst         :  std_logic;
signal INST        :  std_logic_vector(31 downto 0);
signal Data_mem_i  :  STD_LOGIC_VECTOR(15 downto 0);      
signal Data_mem_o  :  STD_LOGIC_VECTOR(15 downto 0);        
signal MDA         :  STD_LOGIC_VECTOR(15 downto 0);
signal OEN         :  STD_LOGIC;                                                                                                                     
signal MIA         :  STD_LOGIC_VECTOR(7 downto 0);

type test_vector is record
        rst : STD_LOGIC;
        INST :  STD_LOGIC_VECTOR(31 downto 0);
        Data_mem_i  :  STD_LOGIC_VECTOR(15 downto 0);
        Data_mem_o  :  STD_LOGIC_VECTOR(15 downto 0);
        MDA         :  STD_LOGIC_VECTOR(15 downto 0);
        OEN         :  STD_LOGIC; 
        MIA         :  STD_LOGIC_VECTOR(7 downto 0);
end record;

type test_vector_array is array
        (natural range <>) of test_vector;

-- For the partial verification of the current module, few instructions were 
-- encoded and given to cpu as the input and then the output was monitored
-- The output is checked one clock cycle after the input was given to module
constant test_vectors : test_vector_array := (
     -- rst, INST,      Data_mem_i, Data_mem_o, MDA, OEN, MIA
     -- reseting the module
     ('1', x"00000000", x"0000",    x"0000", x"0000", '0', x"01"),--#0
     ('0', x"00000000", x"0000",    x"0000", x"0000", '0', x"02"),--#1
     -- inc R1, R0;
     ('0', x"20000001", x"0000",    x"0000", x"0001", '0', x"03"),--#2
     -- addi R2, R0, 005
     ('0', x"18001402", x"0000",    x"0000", x"0005", '0', x"04"),--#3
     -- shl R3, R1, 3, 
     ('0', x"60000c23", x"0000",    x"0000", x"0008", '0', x"05"),--#4
     -- storr R2, R3
     ('0', x"98000062", x"0000",    x"0005", x"0008", '1', x"06"),--#5
     -- loadi R5, 1f1f
     ('0', x"847C7C05", x"0007",    x"0000", x"1f1f", '0', x"07"),--#6
     -- NOP
     ('0', x"00000000", x"0000",    x"0000", x"0000", '0', x"08"),--#7 
     -- Middle reset
     ('1', x"00000000", x"0000",    x"0000", x"0000", '0', x"01"),--#8
     ('0', x"00000000", x"0000",    x"0000", x"0000", '0', x"02"),--#9
     -- inc R1, R0;
     ('0', x"20000001", x"0000",    x"0000", x"0001", '0', x"03"),--#10
     -- addi R2, R0, 005
     ('0', x"18001402", x"0000",    x"0000", x"0005", '0', x"04"));--#11
        

begin
UUT: entity work.control_datapath
    port map(clk => clk,
             rst => rst,
             INST => INST,
             Data_mem_i => Data_mem_i,
             Data_mem_o => Data_mem_o,
             MDA => MDA,
             OEN => OEN,
             MIA => MIA
             );
             
-- Clock process
clk_process :process
begin
  clk <= '0';
  wait for clk_period/2;
  clk <= '1';
  wait for clk_period/2;
end process;

test_process: process
begin
    
    -- wait 100 ns for global reset to finish
    wait for 100ns;
    
    wait until falling_edge(clk); -- Clock Synchronization
    
    -- initializing inputs
    rst <= '0';
    INST <= x"00000000";
    Data_mem_i <= x"0000";
    wait for 1.5*clk_period;
    
    for i in test_vectors' range loop
       rst <= test_vectors(i).rst;
       INST <= test_vectors(i).INST;
       Data_mem_i <= test_vectors(i).Data_mem_i;
       
       wait for 1*clk_period;
       assert ((Data_mem_o = test_vectors(i).Data_mem_o) and
                      (MDA = test_vectors(i).MDA) and
                      (OEN = test_vectors(i).OEN) and
                      (MIA = test_vectors(i).MIA))
       report "Test vector " &
             integer'image(i) &
             " failed for inputs rst = " &
             std_logic'image(rst) &
             " and INST = " &
             integer'image(to_integer(unsigned(INST))) &
             " and Data_mem_i = " &
             integer'image(to_integer(unsigned(Data_mem_i))) &
             ". Expected Data_mem_o = " &
             integer'image(to_integer(unsigned(test_vectors(i).Data_mem_o))) &
             " and MDA =" &
             integer'image(to_integer(unsigned(test_vectors(i).MDA))) & 
             " and OEN =" &
             std_logic'image(test_vectors(i).OEN) &
             " and MIA =" &
             integer'image(to_integer(unsigned(test_vectors(i).MIA))) &  
             "; observed Data_mem_o = " &
             integer'image(to_integer(unsigned(Data_mem_o))) &
             " and MDA =" &
             integer'image(to_integer(unsigned(MDA))) & 
             " and OEN =" &
             std_logic'image(OEN) &
             " and MIA =" &
             integer'image(to_integer(unsigned(MIA)))   
       severity error; -- to stop the simulation
      
       report "The output corresponds to expectation at test vector " &
              integer'image(i) 
       severity note;
    

    end loop;
    wait;
end process;

end Behavioral;

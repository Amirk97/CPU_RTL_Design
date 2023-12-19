
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Processor_tb is

end Processor_tb;

architecture Behavioral of Processor_tb is

constant clk_period : time := 10ns;
signal PB         :  STD_LOGIC;
signal clk        :  std_logic;
signal rst        :  std_logic;                                   
signal LED_output :  STD_LOGIC_VECTOR (7 downto 0);

begin
UUT : entity work.Processor
    Port map(PB => PB,
             clk => clk,
             rst => rst,
             LED_output => LED_output
             );
             
-- Clock process
clk_process :process
begin
  clk <= '0';
  wait for clk_period/2;
  clk <= '1';
  wait for clk_period/2;
end process;              

-- The test strategy is to simply simulate pushing the pushbutton so the
-- execution of the instructions is continued in our program, other necessary
-- testing measures for synchronous circuits are also implemented
test_process : process
begin
    -- wait 100 ns for global reset to finish
    wait for 100ns;
    
    wait until falling_edge(clk); -- Clock Synchronization
    
    -- initializing inputs
    PB <= '0';
    rst <= '0';
    wait for clk_period*1;
    
    -- resetting the module
    rst <= '1';
    wait for clk_period*1;
    
    rst <= '0';
    wait for clk_period*5;
    -- Simulating pushing the button
    PB <= '1';
    wait for clk_period*10;
    
    PB <= '0';
    wait for clk_period*40;
    
    -- Middle reset
    rst <= '1';
    wait for clk_period*1;
    
    rst <= '0';
    wait for clk_period*1;
    -- going through instructions again
    PB <= '1';
    wait for clk_period*10;
    
    PB <= '0';
    
    wait;
end process;

end Behavioral;

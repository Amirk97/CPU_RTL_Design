

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.DigEng.ALL;
use IEEE.NUMERIC_STD.ALL;
 

-- This module implements the Arithmatic logic unit of the CPU
-- The module is only consisted of combinational logic units
entity ALU is
    generic(data_size : natural := 8);
    Port ( A : in STD_LOGIC_VECTOR (data_size-1 downto 0); -- Input data
           B : in STD_LOGIC_VECTOR (data_size-1 downto 0); -- Input data
           -- This signal determines For How many positions we are shifting 
           X : in STD_LOGIC_VECTOR (log2(data_size)-1 downto 0);       
           Opcode : in STD_LOGIC_VECTOR(3 downto 0);       -- This control signal determines   
                                                           -- which operation is done by ALU
           flags  : out STD_LOGIC_VECTOR(7 downto 0);      -- The output which shows the characteristics
                                                           -- of the output of ALU operation
           ALU_out : out STD_LOGIC_VECTOR (data_size-1 downto 0));  -- output parallel data
end ALU;

architecture Behavioral of ALU is

signal ALU_out_int : SIGNED (data_size-1 downto 0);

begin
-- The data output of the ALU is assigned its respective value based on the opcode
-- Its implemented using a mux
    with opcode select 
    ALU_out_int <=  signed(A)                                       when "0000",
                    signed(A and B)                                 when "0100",
                    signed(A or B)                                  when "0101",
                    signed(A xor B)                                 when "0110",
                    signed(not A)                                   when "0111",
                    signed(A) + 1                                   when "1000",
                    signed(A) - 1                                   when "1001",
                    signed(A) + signed(B)                           when "1010",
                    signed(A) - signed(B)                           when "1011",
                    shift_left(signed(A),to_integer(unsigned(X)))   when "1100",
                    shift_right(signed(A),to_integer(unsigned(X)))  when "1101",                     
                    rotate_left(signed(A),to_integer(unsigned(X)))  when "1110",
                    rotate_right(signed(A),to_integer(unsigned(X))) when "1111",
                    (others => '0')                                 when others;
                    
-- The flags are assigned values based on output of ALU 
-- and opcode
-- The oveflow condition for addition only happens when inputs have the same sign but the output has a different sign
-- In signed data the MSB indicates the sign of our number
-- For subtraction operation the principle is the same but it should be considered that the sign of second operand is negated
-- In Increment by 1 operation, we can only have an overflow for positive numbers
-- In decrement by 1 operation, we can only have an overflow for negative numbers
    flags(0) <= '1'   when ALU_out_int = 0  else '0'; 
    flags(1) <= '1'   when ALU_out_int /= 0 else '0'; 
    flags(2) <= '1'   when ALU_out_int = 1  else '0';  
    flags(3) <= '1'   when ALU_out_int < 0  else '0'; 
    flags(4) <= '1'   when ALU_out_int > 0  else '0';
    flags(5) <= '1'   when ALU_out_int <= 0 else '0';  
    flags(6) <= '1'   when ALU_out_int >= 0 else '0';      
    flags(7) <= '1'   when (((opcode =  "1010") and (A(data_size-1) = '0') and (B(data_size-1) = '0')  and (ALU_out_int(data_size-1) = '1')) or
                          (( opcode = "1010") and A(data_size-1) = '1' and B(data_size-1) = '1'  and ALU_out_int(data_size-1) = '0') or
                          (( opcode = "1011") and A(data_size-1) = '0' and B(data_size-1) = '1'  and ALU_out_int(data_size-1) = '1') or
                          (( opcode = "1011") and A(data_size-1) = '1' and B(data_size-1) = '0'  and ALU_out_int(data_size-1) = '0') or
                          (( opcode = "1000") and A(data_size-1) = '0' and ALU_out_int(data_size-1) = '1') or
                          (( opcode = "1001") and A(data_size-1) = '1' and ALU_out_int(data_size-1) = '0')) else
                          '0';

ALU_out <= std_logic_vector(ALU_out_int);
end Behavioral;

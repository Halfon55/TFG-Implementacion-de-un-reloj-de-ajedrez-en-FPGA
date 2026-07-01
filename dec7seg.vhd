----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.12.2023 20:09:26
-- Design Name: 
-- Module Name: dec7seg - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dec7seg is
    Port ( hex : in  STD_LOGIC_VECTOR (3 downto 0);
           led : out  STD_LOGIC_VECTOR (6 downto 0)
           );
end dec7seg;

architecture Behavioral of dec7seg is

begin

with hex select
	  led <= "1000000" when "0000",   
		     "1111001" when "0001",  
             "0100100" when "0010",    
             "0110000" when "0011",     
             "0011001" when "0100",     
             "0010010" when "0101",    
             "0000010" when "0110",      
             "1111000" when "0111",         
             "0000000" when "1000",      
             "0010000" when "1001",   
		     "0001110" when others;

end Behavioral;

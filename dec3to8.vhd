----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.12.2023 19:34:17
-- Design Name: 
-- Module Name: dec3to8 - Behavioral
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

entity dec3to8 is
   Port ( sel : in  STD_LOGIC_VECTOR (2 downto 0);
          an : out  STD_LOGIC_VECTOR (7 downto 0));
end dec3to8;

architecture Behavioral of dec3to8 is

begin

	process(sel)
		begin
			case sel is
				when "000" => 
				an <= "11111110";
				when "001" => 
				an <= "11111101";
				when "010" => 
				an <= "11111011";
				when "011" => 
				an <= "11110111";
				when "100" => 
				an <= "11101111";
				when "101" => 
				an <= "11011111";
				when "110" => 
				an <= "10111111";
				when others => 
				an <= "01111111";
			end case;
	end process;

end Behavioral;

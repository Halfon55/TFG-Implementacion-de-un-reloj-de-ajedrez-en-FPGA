----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.11.2024 22:33:19
-- Design Name: 
-- Module Name: BCD_adder_mod6_tb - Behavioral
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

entity BCD_adder_mod6_tb is
--  Port ( );
end BCD_adder_mod6_tb;

architecture Behavioral of BCD_adder_mod6_tb is

component BCD_adder_mod6
    Port ( numero4, incremento4 : in STD_LOGIC_VECTOR(3 downto 0);
           cin : in STD_LOGIC;
           salida4 : out STD_LOGIC_VECTOR(3 downto 0);
           cout : out STD_LOGIC
           );
end component;           

--Inputs
signal numero4, incremento4 : std_logic_vector(3 downto 0);
signal cin : std_logic;

--Outputs
signal salida4 : std_logic_vector(3 downto 0);
signal cout : std_logic;

begin

    process
    begin
        numero4 <= "0001";
        incremento4 <= "0000";
        cin <= '0';
        
        wait for 50 ns;
        
        incremento4 <= "0001";
        
        wait for 50 ns;
        
        incremento4 <= "0010";
        
        wait for 50 ns;
        
        incremento4 <= "0011";
        
        wait for 50 ns;
        
        incremento4 <= "0100";
        
        wait for 50 ns;
        
        incremento4 <= "0101";
        
        wait for 50 ns;
        
        incremento4 <= "0110";
        
        wait for 50 ns;
        
        incremento4 <= "0111";
    end process;

uut : BCD_adder_mod6
    PORT MAP( numero4 => numero4,
              incremento4 => incremento4,
              cin => cin,
              salida4 => salida4,
              cout => cout
             );

end Behavioral;
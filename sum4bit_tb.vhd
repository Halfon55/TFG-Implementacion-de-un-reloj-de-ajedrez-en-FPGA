----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.06.2026 22:53:36
-- Design Name: 
-- Module Name: sum4bit_tb - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sum4bit_tb is
--  Port ( );
end sum4bit_tb;

architecture Behavioral of sum4bit_tb is

    component sum4bit
        Port ( a4, b4   : in STD_LOGIC_VECTOR(3 downto 0);
               cin      : in STD_LOGIC;
               s4       : out STD_LOGIC_VECTOR(3 downto 0);
               overflow : out STD_LOGIC
             );
    end component;

    signal a4       : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal b4       : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal cin      : STD_LOGIC := '0';
    signal s4       : STD_LOGIC_VECTOR(3 downto 0);
    signal overflow : STD_LOGIC;

begin

    uut: sum4bit 
        PORT MAP (
            a4       => a4,
            b4       => b4,
            cin      => cin,
            s4       => s4,
            overflow => overflow
        );

    stim_proc: process
    begin
        a4 <= "0010"; 
        b4 <= "0000"; 
        cin <= '0';
        wait for 20 ns;
        
        b4 <= "0011";
        wait for 20 ns;

        b4 <= "0101";
        wait for 20 ns;

        b4 <= "0001";
        wait for 20 ns;

        b4 <= "1000";
        wait for 20 ns;

        b4 <= "1010";
        wait for 20 ns;

        b4 <= "1111";
        wait for 20 ns;
    end process;

end Behavioral;
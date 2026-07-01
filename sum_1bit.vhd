----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.11.2024 18:33:40
-- Design Name: 
-- Module Name: sum_1bit - Behavioral
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

entity sum_1bit is

  Port (a, b, cin : in std_logic;
        s, cout: out std_logic
        );
        
end sum_1bit;

architecture Behavioral of sum_1bit is

    signal cout_and1, cout_and2, cout_and3 : std_logic;
    
begin

    cout_and1 <= a and b;
    cout_and2 <= a and cin;
    cout_and3 <= b and cin;
    
    s <= (a xor b) xor cin;
    cout <= cout_and1 or cout_and2 or cout_and3;

end Behavioral;
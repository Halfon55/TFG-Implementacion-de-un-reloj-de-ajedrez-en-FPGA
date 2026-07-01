----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.11.2024 18:36:22
-- Design Name: 
-- Module Name: sum4bit - Behavioral
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

entity sum4bit is
   Port ( a4, b4 : in STD_LOGIC_VECTOR(3 downto 0);
          cin : in STD_LOGIC;
          s4 : out STD_LOGIC_VECTOR(3 downto 0);
          overflow : out STD_LOGIC
          );
end sum4bit;

architecture Behavioral of sum4bit is

component sum_1bit
    Port (a, b, cin : in std_logic;
          s, cout: out std_logic
          );
end component;

--Señales para los resultados de las sumas bit a bit.
signal suma1, suma2, suma3, suma4 : std_logic;

begin

--Se instancia el sumador de 1 bit 4 veces, uno para cada posición.
Inst_sum_1bit0 : sum_1bit
    PORT MAP( a => a4(0),
              b => b4(0),
              cin => cin,
              cout => suma1,
              s => s4(0)
             );
             
Inst_sum_1bit1 : sum_1bit
    PORT MAP( a => a4(1),
              b => b4(1),
              cin => suma1,
              cout => suma2,
              s => s4(1)
             );
             
Inst_sum_1bit2 : sum_1bit
    PORT MAP( a => a4(2),
              b => b4(2),
              cin => suma2,
              cout => suma3,
              s => s4(2)
             );
             
Inst_sum_1bit3 : sum_1bit
    PORT MAP( a => a4(3),
              b => b4(3),
              cin => suma3,
              cout => suma4,
              s => s4(3)
             );                                       

overflow <= suma4;

end Behavioral;

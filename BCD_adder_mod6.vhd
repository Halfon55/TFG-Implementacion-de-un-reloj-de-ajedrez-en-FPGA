----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.11.2024 22:30:56
-- Design Name: 
-- Module Name: BCD_adder_mod6 - Behavioral
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

entity BCD_adder_mod6 is
   Port ( numero4, incremento4 : in STD_LOGIC_VECTOR(3 downto 0);
          cin : in STD_LOGIC;
          salida4 : out STD_LOGIC_VECTOR(3 downto 0);
          cout : out STD_LOGIC
          );
end BCD_adder_mod6;

architecture Behavioral of BCD_adder_mod6 is

component sum4bit
    Port ( a4, b4 : in STD_LOGIC_VECTOR(3 downto 0);
           cin : in STD_LOGIC;
           s4 : out STD_LOGIC_VECTOR(3 downto 0);
           overflow : out STD_LOGIC
           );
end component;          

signal sMid4, b4addout : std_logic_vector(3 downto 0);
signal carry : std_logic;
signal andS1S2, comp6bit, sink : std_logic;

begin

Inst_sum4bit_in : sum4bit
    PORT MAP( a4 => numero4,
              b4 => incremento4,
              cin => cin,
              s4 => sMid4,
              overflow => carry
              );

--Operaciones lógicas para determinar si el número resultante es superior a 5.
andS1S2 <= sMid4(1) and sMid4(2);
comp6bit <= andS1S2 or carry or sMid4(3);

--Construcción de la señal de entrada al segundo sumador.
b4addout(0) <= '0';
b4addout(1) <= comp6bit;
b4addout(2) <= '0';
b4addout(3) <= comp6bit;

Inst_sum4bit_out : sum4bit
    PORT MAP( a4 => sMid4,
              b4 => b4addout,
              cin => '0',
              s4 => salida4,
              overflow => sink
              );

cout <= comp6bit;

end Behavioral;
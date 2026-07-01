---------------------------------------------------------------------------------
-- Company: ULL
-- Engineer: Eduardo Magdaleno Castell�
-- 
-- Create Date: 05.08.2024 15:43:13
-- Design Name: 
-- Module Name: countdown_timer - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: Vivado 2023.1
-- Description: 
----------------------------------------------------------------------------------
-- Este contador tiene 2 gen�ricos: el n�mero hasta el que se quiere contar (module)
-- y el ancho en bits de la cuenta (evidentemente estos n�meros est�n relacionados:
-- 2^width > module necesariamente
----------------------------------------------------------------------------------
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
use IEEE.std_logic_unsigned.all; -- librer�a para usar "-" y sintetizar contadores
use IEEE.std_logic_arith.all; -- para la funci�n conv_std_logic_vector

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity up_counter is
	Generic (module   : integer; -- los gen�ricos permiten "parametrizar" circuitos
			 width    : integer);
    Port   ( clk      : in  STD_LOGIC;
             reset    : in  STD_LOGIC;
             count    : out  STD_LOGIC_VECTOR (width-1 downto 0);
             ce       : in   STD_LOGIC;
             top      : out  STD_LOGIC);
end up_counter;

architecture Behavioral of up_counter is

signal q : std_logic_vector(width-1 downto 0) ;

begin

------------- counter -------------
process (clk, reset) 
begin
   if reset='1' then 
      q <= (others => '0');
   elsif (clk='1' and clk'event) then
      if ce='1' then
			if q = module - 1 then
				q <= (others => '0');
			else
				q <= q + 1;
			end if;
      end if;
   end if;
end process;

count <= q;
------------- counter -------------

---- generador de se�al de tope ----
process(q)
begin
	if q = module - 1 then
		top <= '1';
	else
		top <= '0';
	end if;
end process;
---- generador de se�al de tope ----

end Behavioral;

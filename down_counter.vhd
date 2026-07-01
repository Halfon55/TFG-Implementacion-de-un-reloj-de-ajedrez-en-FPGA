----------------------------------------------------------------------------------
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
-- Este contador tiene 2 gen�ricos: el n�mero desde el que se quiere descontar (module)
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

entity down_counter is
	Generic (module   : integer; -- los gen�ricos permiten "parametrizar" circuitos
			 width    : integer);
    Port   ( clk      : in  STD_LOGIC;
             preset   : in  STD_LOGIC;
             load     : in  STD_LOGIC;
             load_data: in  STD_LOGIC_VECTOR (width-1 downto 0);
             count    : out  STD_LOGIC_VECTOR (width-1 downto 0);
             ce       : in   STD_LOGIC;
             top      : out  STD_LOGIC);
end down_counter;

architecture Behavioral of down_counter is

signal q : std_logic_vector(width-1 downto 0) ;

begin

------------- counter -------------
process (clk, preset) 
begin
   if preset = '1' then 
      q <= conv_std_logic_vector(module-1, width);
   elsif (clk='1' and clk'event) then
      if load = '1' then 
           q <= load_data;            
      elsif ce = '1' then
			if q = 0 then
				q <= conv_std_logic_vector(module-1, width);
			else
				q <= q - 1;
			end if;
      end if;
   end if;
end process;

count <= q;
------------- counter -------------

---- generador de se�al de tope ----
process(q)
begin
	if q = 0 then
		top <= '1';
	else
		top <= '0';
	end if;
end process;
---- generador de se�al de tope ----

end Behavioral;

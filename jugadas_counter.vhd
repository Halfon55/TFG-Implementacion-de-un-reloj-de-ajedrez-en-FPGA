----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.11.2024 21:09:10
-- Design Name: 
-- Module Name: jugadas_counter - Behavioral
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
use IEEE.std_logic_unsigned.all; -- librer�a para usar "-" y sintetizar contadores
use IEEE.std_logic_arith.all; -- para la funci�n conv_std_logic_vector

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity jugadas_counter is
	Generic (module   : integer; -- los gen�ricos permiten "parametrizar" circuitos
			 width    : integer);
    Port   ( clk      : in  STD_LOGIC;
             reset    : in  STD_LOGIC;
             count    : out  STD_LOGIC_VECTOR (width-1 downto 0);
             ce       : in   STD_LOGIC;
             top      : out  STD_LOGIC);
end jugadas_counter;

architecture Behavioral of jugadas_counter is

signal q : std_logic_vector(width-1 downto 0) ;

--Señales para detectar el evento de que el enable pase de encendido a apagado
signal ce_now, ce_up : std_logic;

begin

--Proceso para asignar los valores del enable
process(clk)
    begin
        if rising_edge(clk) then
            ce_up <= ce_now;
            ce_now <= ce;
        end if;
end process;        

------------- counter -------------
process (clk, reset) 
begin
   if reset='1' then 
      q <= (others => '0');
   elsif (clk='1' and clk'event) then
      if (ce_up = '1' and ce_now = '0') then
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

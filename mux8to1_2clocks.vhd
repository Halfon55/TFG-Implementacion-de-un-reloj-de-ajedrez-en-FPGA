----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.07.2025 16:48:51
-- Design Name: 
-- Module Name: mux8to1_2clocks - Behavioral
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

entity mux8to1_2clocks is

     Port ( clk : in std_logic;
           centesimas1, centesimas2 : in  STD_LOGIC_VECTOR (3 downto 0);
           decimas1, decimas2 : in  STD_LOGIC_VECTOR (3 downto 0);
           useg1, useg2 : in  STD_LOGIC_VECTOR (3 downto 0);
           dseg1, dseg2 : in  STD_LOGIC_VECTOR (3 downto 0);
           uminutos1, uminutos2 : in  STD_LOGIC_VECTOR (3 downto 0);
           dminutos1, dminutos2 : in  STD_LOGIC_VECTOR (3 downto 0);
           uhoras1, uhoras2 : in  STD_LOGIC_VECTOR (3 downto 0);
           sel : in  STD_LOGIC_VECTOR (2 downto 0);
           hex : out  STD_LOGIC_VECTOR (3 downto 0));
           
end mux8to1_2clocks;

architecture Behavioral of mux8to1_2clocks is

signal horas : std_logic_vector(3 downto 0);
signal minutos : std_logic_vector(7 downto 0);

begin

--Se establecen las variables que se usarán para observar los valores de las cuentas de las horas por un lado y la de los minutos por otro	
	process(clk,
	       uhoras1, uhoras2, 
	       uminutos1, uminutos2, dminutos1, dminutos2
	       )
	begin
	   if rising_edge(clk) then
           if uhoras1 >= uhoras2 then   
              horas <= uhoras1;
           else
              horas <= uhoras2;
           end if;
            
           if uminutos1 >= uminutos2 then
               minutos <= dminutos1 & uminutos1;
           else
               minutos <= dminutos2 & uminutos2;
           end if;
       end if;
	end process;

--Proceso para cambiar lo que se muestra en los displays en función de los valores de las cuentas de las horas y minutos	
	process(horas, minutos, sel,
	        uhoras1, uhoras2,
	        dminutos1, dminutos2, uminutos1, uminutos2,
	        dseg1, dseg2, useg1, useg2,
	        decimas1, decimas2, centesimas1, centesimas2)
	   begin
	   --Se usan las horas para establecer el caso más general para la visualización
	       case horas is
	           when "0000" =>
	           --Se plantea el caso en el que solo quedan segundos en el reloj
                   if minutos = "00000000" then
                       case sel is
                           when "000" =>
                               hex <= centesimas2;
                           when "001" =>
                               hex <= decimas2;
                           when "010" =>
                               hex <= useg2;
                           when "011" =>
                               hex <= dseg2;
                           when "100" =>
                               hex <= centesimas1;
                           when "101" =>
                               hex <= decimas1;
                           when "110" =>
                               hex <= useg1;
                           when "111" =>
                               hex <= dseg1;
                           when others => null;
                       end case;
                   
                   --Se plantea el caso en el que quedan minutos de juego en el reloj, pero no horas    
                   else
                       case sel is
                           when "000" =>
                               hex <= useg2;
                           when "001" =>
                               hex <= dseg2;
                           when "010" =>
                               hex <= uminutos2;
                           when "011" =>
                               hex <= dminutos2;
                           when "100" =>
                               hex <= useg1;
                           when "101" =>
                               hex <= dseg1;
                           when "110" =>
                               hex <= uminutos1;
                           when "111" =>
                               hex <= dminutos1;
                           when others => null;
                       end case;
                   end if;    
	           
	           --Se plantea el caso de que aún queden horas de juego en el reloj
	           when others =>
	               case sel is
                       when "000" =>
                           hex <= uminutos2;
                       when "001" =>
                           hex <= dminutos2;
                       when "010" =>
                           hex <= uhoras2;
                       when "011" =>
                           hex <= "0000";
                       when "100" =>
                           hex <= uminutos1;
                       when "101" =>
                           hex <= dminutos1;
                       when "110" =>
                           hex <= uhoras1;
                       when "111" =>
                           hex <= "0000";
                       when others => null;
	               end case;
	       end case;
	end process;       
	         
end Behavioral;

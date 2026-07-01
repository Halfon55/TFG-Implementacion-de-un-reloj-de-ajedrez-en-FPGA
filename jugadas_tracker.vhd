----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.11.2024 21:23:46
-- Design Name: 
-- Module Name: jugadas_tracker - Behavioral
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

entity jugadas_tracker is
    Port ( clk : in STD_LOGIC;
           ce : in STD_LOGIC;
           preset : in STD_LOGIC;
           load_sel : in STD_LOGIC;
           jugadas_number : out STD_LOGIC_VECTOR(11 downto 0)           
           );
end jugadas_tracker;

architecture Behavioral of jugadas_tracker is

--Señales para las cuentas, top y ce de los contadores
signal unidades, decenas, centenas : std_logic_vector(3 downto 0);
signal ce_decenas, ce_centenas : std_logic;
signal top_unidades, top_decenas, top_centenas : std_logic;

component jugadas_counter
    Generic (module   : integer; 
			 width    : integer);
    Port   ( clk      : in  STD_LOGIC;
             reset    : in  STD_LOGIC;
             count    : out  STD_LOGIC_VECTOR (width-1 downto 0);
             ce       : in   STD_LOGIC;
             top      : out  STD_LOGIC);
end component;             

begin

--Se instancian los 3 contadores de jugadas y se concatenan sus cuentas
Inst_jugadas_unidades : jugadas_counter
    generic map ( 
          module => 10,
          width => 4)
    PORT MAP (
          clk => clk,
          reset => preset,
          count => unidades,
          top => top_unidades,
          ce => ce
     );
     
     ce_decenas <= ce and top_unidades;
     
Inst_jugadas_decenas : jugadas_counter
    generic map ( 
          module => 10,
          width => 4)
    PORT MAP (
          clk => clk,
          reset => preset,
          count => decenas,
          top => top_decenas,
          ce => ce_decenas
     );
     
     ce_centenas <= ce_decenas and top_decenas;
          
Inst_jugadas_centenas : jugadas_counter
    generic map ( 
          module => 10,
          width => 4)
    PORT MAP (
          clk => clk,
          reset => preset,
          count => centenas,
          top => top_centenas,
          ce => ce_centenas
     );     
     
     process(load_sel, preset,
             centenas, decenas, unidades)
        begin
            if preset = '1' or load_sel = '1' then
                jugadas_number <= "000000000000";
            else
                jugadas_number <= centenas & decenas & unidades;         
            end if;
     end process;
end Behavioral;

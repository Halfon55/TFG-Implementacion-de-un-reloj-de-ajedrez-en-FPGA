----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.11.2024 19:26:00
-- Design Name: 
-- Module Name: all_counters - Behavioral
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

entity all_counters is
    Port ( clk, preset, ce, load : in STD_LOGIC;
           load_data_centesimas, load_data_decimas, load_data_useg, load_data_dseg, load_data_uminutos, load_data_dminutos, load_data_uhoras : in STD_LOGIC_VECTOR(3 downto 0);
           uhoras, dminutos, uminutos, dseg, useg, decimas, centesimas : out STD_LOGIC_VECTOR(3 downto 0)
           );
end all_counters;

architecture Behavioral of all_counters is

component down_counter
    Generic (module   : integer; 
			 width    : integer);
    Port   ( clk      : in  STD_LOGIC;
             preset   : in  STD_LOGIC;
             load     : in  STD_LOGIC;
             load_data: in  STD_LOGIC_VECTOR (width-1 downto 0);
             count    : out  STD_LOGIC_VECTOR (width-1 downto 0);
             ce       : in   STD_LOGIC;
             top      : out  STD_LOGIC);
end component;

--Declaración de señales para los contadores
signal ce_uhoras, ce_dminutos, ce_uminutos, ce_dseg, ce_useg, ce_decimas : std_logic;
signal top_uhoras, top_dminutos, top_uminutos, top_dseg, top_useg, top_decimas, top_centesimas : std_logic;

begin

--Ponemos los contadores desde las centésimas hasta las unidades de segundo    

centesimas_unit : down_counter
    generic map ( 
          module => 10,
          width => 4)
    PORT MAP (
          clk => clk,
          preset => preset,
          load => load,
          load_data => load_data_centesimas,
          count => centesimas,
          top => top_centesimas,
          ce => ce
     );
     --Añadimos esta línea para obligar al siguiente contador a disminuir la cuenta cuando los anteriores han completado su ciclo.
     ce_decimas <= top_centesimas and ce;     

decimas_unit : down_counter
    generic map ( 
          module => 10,
          width => 4)
    PORT MAP (
          clk => clk,
          preset => preset,
          load => load,
          load_data => load_data_decimas,
          count => decimas,
          top => top_decimas,
          ce => ce_decimas
     );
     
     ce_useg <= ce_decimas and top_decimas;     

useg_unit : down_counter
    generic map ( 
          module => 10,
          width => 4)
    PORT MAP (
          clk => clk,
          preset => preset,
          load => load,
          load_data => load_data_useg,
          count => useg,
          top => top_useg,
          ce => ce_useg
     );
     
     ce_dseg <= top_useg and ce_useg;     

dseg_unit : down_counter
    generic map ( 
          module => 6,
          width => 4)
    PORT MAP (
          clk => clk,
          preset => preset,
          load => load,
          load_data => load_data_dseg,
          count => dseg,
          top => top_dseg,
          ce => ce_dseg
     );
     
     ce_uminutos <= top_dseg and ce_dseg;     

uminutos_unit : down_counter
    generic map ( 
          module => 10,
          width => 4)
    PORT MAP (
          clk => clk,
          preset => preset,
          load => load,
          load_data => load_data_uminutos,
          count => uminutos,
          top => top_uminutos,
          ce => ce_uminutos
     );
     
     ce_dminutos <= top_uminutos and ce_uminutos;     

dminutos_unit : down_counter
    generic map ( 
          module => 6,
          width => 4)
    PORT MAP (
          clk => clk,
          preset => preset,
          load => load,
          load_data => load_data_dminutos,
          count => dminutos,
          top => top_dminutos,
          ce => ce_dminutos
     );
     
     ce_uhoras <= top_dminutos and ce_dminutos;     
    
uhoras_unit : down_counter
    generic map ( 
          module => 4,
          width => 4)
    PORT MAP (
          clk => clk,
          preset => preset,
          load => load,
          load_data => load_data_uhoras,
          count => uhoras,
          top => top_uhoras,
          ce => ce_uhoras
     );

end Behavioral;

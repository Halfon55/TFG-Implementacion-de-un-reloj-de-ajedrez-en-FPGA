----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.11.2024 19:38:53
-- Design Name: 
-- Module Name: refresh_adders - Behavioral
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

entity refresh_adders is
    Port ( centesimas, decimas, uhoras, dminutos, uminutos, dseg, useg : in STD_LOGIC_VECTOR(3 downto 0);
           load_useg_inc, load_dseg_inc, load_uhoras_add, load_dminutos_add, load_uminutos_add : in STD_LOGIC_VECTOR(3 downto 0);
           load_data_centesimas, load_data_decimas, load_data_useg, load_data_dseg, load_data_uminutos, load_data_dminutos, load_data_uhoras : out STD_LOGIC_VECTOR(3 downto 0));
end refresh_adders;

architecture Behavioral of refresh_adders is

component BCD_adder_mod10
    Port ( numero4, incremento4 : in STD_LOGIC_VECTOR(3 downto 0);
           cin : in STD_LOGIC;
           salida4 : out STD_LOGIC_VECTOR(3 downto 0);
           cout : out STD_LOGIC
          );
end component;

component BCD_adder_mod6
    Port ( numero4, incremento4 : in STD_LOGIC_VECTOR(3 downto 0);
           cin : in STD_LOGIC;
           salida4 : out STD_LOGIC_VECTOR(3 downto 0);
           cout : out STD_LOGIC
          );
end component; 

--Declaración de señales para los sumadores BCD
signal coutuseg, coutdseg, coutumin, coutdmin, sink1, sink2, sink3 : std_logic;

begin

--Instanciamos los 7 sumadores para los incrementos
Inst_adder_centesimas : BCD_adder_mod10
    PORT MAP ( 
          numero4 => centesimas,
          incremento4 => "0000",
          cin => '0',
          salida4 => load_data_centesimas,
          cout => sink1
     );

Inst_adder_decimas : BCD_adder_mod10
    PORT MAP ( 
          numero4 => decimas,
          incremento4 => "0000",
          cin => sink1,
          salida4 => load_data_decimas,
          cout => sink2
     );

Inst_adder_useg : BCD_adder_mod10
    PORT MAP ( 
          numero4 => useg,
          incremento4 => load_useg_inc,
          cin => sink2,
          salida4 => load_data_useg,
          cout => coutuseg
     );
     
Inst_adder_dseg : BCD_adder_mod6
    PORT MAP ( 
          numero4 => dseg,
          incremento4 => load_dseg_inc,
          cin => coutuseg,
          salida4 => load_data_dseg,
          cout => coutdseg
     );
     
Inst_adder_umin : BCD_adder_mod10
    PORT MAP ( 
          numero4 => uminutos,
          incremento4 => load_uminutos_add,
          cin => coutdseg,
          salida4 => load_data_uminutos,
          cout => coutumin
     );     
     
Inst_adder_dmin : BCD_adder_mod6
    PORT MAP ( 
          numero4 => dminutos,
          incremento4 => load_dminutos_add,
          cin => coutumin,
          salida4 => load_data_dminutos,
          cout => coutdmin
     );
     
Inst_adder_uhoras : BCD_adder_mod10
    PORT MAP ( 
          numero4 => uhoras,
          incremento4 => load_uhoras_add,
          cin => coutdmin,
          salida4 => load_data_uhoras,
          cout => sink3
     );      

end Behavioral;

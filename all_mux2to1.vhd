----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.11.2024 13:52:47
-- Design Name: 
-- Module Name: all_mux2to1 - Behavioral
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

entity all_mux2to1 is
    Port ( adder_centesimas, adder_decimas, adder_useg, adder_dseg, adder_umin, adder_dmin, adder_uhoras : in STD_LOGIC_VECTOR(3 downto 0);
           centesimas_init, decimas_init, useg_init, dseg_init, uminutos_init, dminutos_init, uhoras_init : in STD_LOGIC_VECTOR(3 downto 0);
           sel : in STD_LOGIC;
           load_data_centesimas, load_data_decimas, load_data_useg, load_data_dseg, load_data_uminutos, load_data_dminutos, load_data_uhoras : out STD_LOGIC_VECTOR(3 downto 0)
           );
end all_mux2to1;

architecture Behavioral of all_mux2to1 is

component mux2to1
    Port ( sel : in std_logic;
           adder_out, load_data_init : in std_logic_vector(3 downto 0);
           load_data : out std_logic_vector(3 downto 0));
end component;  

begin

Inst_mux2to1_cetesimas : mux2to1
    PORT MAP (
              sel => sel,
              adder_out => adder_centesimas,
              load_data_init => centesimas_init,
              load_data => load_data_centesimas
              );

Inst_mux2to1_decimas : mux2to1
    PORT MAP (
              sel => sel,
              adder_out => adder_decimas,
              load_data_init => decimas_init,
              load_data => load_data_decimas
              );

Inst_mux2to1_useg : mux2to1
    PORT MAP (
              sel => sel,
              adder_out => adder_useg,
              load_data_init => useg_init,
              load_data => load_data_useg
              );
              
Inst_mux2to1_dseg : mux2to1
    PORT MAP (
              sel => sel,
              adder_out => adder_dseg,
              load_data_init => dseg_init,
              load_data => load_data_dseg
              );
              
Inst_mux2to1_uminutos : mux2to1
    PORT MAP (
              sel => sel,
              adder_out => adder_umin,
              load_data_init => uminutos_init,
              load_data => load_data_uminutos
              );
              
Inst_mux2to1_dminutos : mux2to1
    PORT MAP (
              sel => sel,
              adder_out => adder_dmin,
              load_data_init => dminutos_init,
              load_data => load_data_dminutos
              );
              
Inst_mux2to1_uhoras : mux2to1
    PORT MAP (
              sel => sel,
              adder_out => adder_uhoras,
              load_data_init => uhoras_init,
              load_data => load_data_uhoras
              );                                                        

end Behavioral;

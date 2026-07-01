----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.07.2025 17:33:50
-- Design Name: 
-- Module Name: crono_simple - Behavioral
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

entity crono_simple is
    Port ( clk, load, preset, sel, ce_centesimas : in STD_LOGIC;
           centesimas, decimas, uhoras, dminutos, uminutos, dseg, useg : inout STD_LOGIC_VECTOR(3 downto 0);
           load_data_uhoras, load_data_dminutos, load_data_uminutos, load_data_dseg ,load_data_useg, load_data_centesimas, load_data_decimas : in STD_LOGIC_VECTOR(3 downto 0);
           load_dseg_inc, load_useg_inc, load_uhoras_add, load_dminutos_add, load_uminutos_add : in STD_LOGIC_VECTOR(3 downto 0)
         );
end crono_simple;

architecture Behavioral of crono_simple is

--Declaración de señales para los sumadores
signal in_data_centesimas, in_data_decimas, in_data_uhoras, in_data_dminutos, in_data_uminutos, in_data_dseg, in_data_useg : std_logic_vector(3 downto 0);
signal centesimas_init, decimas_init, useg_init, dseg_init, uminutos_init, dminutos_init, uhoras_init  : std_logic_vector(3 downto 0);
signal mid_centesimas, mid_decimas, mid_useg, mid_dseg, mid_uminutos, mid_dminutos, mid_uhoras : std_logic_vector(3 downto 0);

component all_counters
    Port ( clk, preset, ce, load : in STD_LOGIC;
           load_data_centesimas, load_data_decimas, load_data_useg, load_data_dseg, load_data_uminutos, load_data_dminutos, load_data_uhoras : in STD_LOGIC_VECTOR(3 downto 0);
           uhoras, dminutos, uminutos, dseg, useg, decimas, centesimas : out STD_LOGIC_VECTOR(3 downto 0)
           );
end component;

component all_mux2to1
    Port ( adder_centesimas, adder_decimas, adder_useg, adder_dseg, adder_umin, adder_dmin, adder_uhoras : in STD_LOGIC_VECTOR(3 downto 0);
           centesimas_init, decimas_init, useg_init, dseg_init, uminutos_init, dminutos_init, uhoras_init : in STD_LOGIC_VECTOR(3 downto 0);
           sel : in STD_LOGIC;
           load_data_centesimas, load_data_decimas, load_data_useg, load_data_dseg, load_data_uminutos, load_data_dminutos, load_data_uhoras : out STD_LOGIC_VECTOR(3 downto 0)
           );
end component; 

component refresh_adders
    Port ( uhoras, dminutos, uminutos, dseg, useg, decimas, centesimas : in STD_LOGIC_VECTOR(3 downto 0);
           load_useg_inc, load_dseg_inc, load_uhoras_add, load_dminutos_add, load_uminutos_add : in STD_LOGIC_VECTOR(3 downto 0);
           load_data_centesimas, load_data_decimas, load_data_useg, load_data_dseg, load_data_uminutos, load_data_dminutos, load_data_uhoras : out STD_LOGIC_VECTOR(3 downto 0)
           );
end component; 

begin

Inst_all_mux2to1 : all_mux2to1
    PORT MAP (
        adder_centesimas => in_data_centesimas,
        adder_decimas => in_data_decimas,
        adder_useg => in_data_useg,
        adder_dseg => in_data_dseg,
        adder_umin => in_data_uminutos,
        adder_dmin => in_data_dminutos,
        adder_uhoras => in_data_uhoras,
        centesimas_init => load_data_centesimas,
        decimas_init => load_data_decimas,
        useg_init => load_data_useg,
        dseg_init => load_data_dseg,
        uminutos_init => load_data_uminutos,
        dminutos_init => load_data_dminutos,
        uhoras_init => load_data_uhoras,
        sel => sel,
        load_data_centesimas => mid_centesimas,
        load_data_decimas => mid_decimas,
        load_data_useg => mid_useg,
        load_data_dseg => mid_dseg,
        load_data_uminutos => mid_uminutos,
        load_data_dminutos => mid_dminutos,
        load_data_uhoras => mid_uhoras
        );
        
Inst_all_counters : all_counters
    PORT MAP (
        clk => clk,
        preset => preset,
        ce => ce_centesimas,
        load => load,
        load_data_centesimas => mid_centesimas,
        load_data_decimas => mid_decimas,
        load_data_useg => mid_useg,
        load_data_dseg => mid_dseg,
        load_data_uminutos => mid_uminutos,
        load_data_dminutos => mid_dminutos,
        load_data_uhoras => mid_uhoras,
        centesimas => centesimas,
        decimas => decimas,
        useg => useg,
        dseg => dseg,
        uminutos => uminutos,
        dminutos => dminutos,
        uhoras => uhoras
    ); 
    
Inst_refresh_adders : refresh_adders
    PORT MAP (
        centesimas => centesimas,
        decimas => decimas,
        useg => useg,
        dseg => dseg,
        uminutos => uminutos,
        dminutos => dminutos,
        uhoras => uhoras,
        load_dseg_inc => load_dseg_inc,
        load_useg_inc => load_useg_inc,
        load_data_centesimas => in_data_centesimas,
        load_data_decimas => in_data_decimas,
        load_data_useg => in_data_useg,
        load_data_dseg => in_data_dseg,
        load_data_uminutos => in_data_uminutos,
        load_data_dminutos => in_data_dminutos,
        load_data_uhoras => in_data_uhoras,
        load_uhoras_add => load_uhoras_add,
        load_dminutos_add => load_dminutos_add,
        load_uminutos_add => load_uminutos_add
    );            

end Behavioral;

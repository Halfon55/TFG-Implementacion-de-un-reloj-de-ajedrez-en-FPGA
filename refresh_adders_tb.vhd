----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.07.2025 17:51:21
-- Design Name: 
-- Module Name: refresh_adders_tb - Behavioral
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

entity refresh_adders_tb is
--  Port ( );
end refresh_adders_tb;

architecture Behavioral of refresh_adders_tb is

component refresh_adders is

    Port ( centesimas, decimas, uhoras, dminutos, uminutos, dseg, useg : in STD_LOGIC_VECTOR(3 downto 0);
           load_useg_inc, load_dseg_inc, load_uhoras_add, load_dminutos_add, load_uminutos_add : in STD_LOGIC_VECTOR(3 downto 0);
           load_data_centesimas, load_data_decimas, load_data_useg, load_data_dseg, load_data_uminutos, load_data_dminutos, load_data_uhoras : out STD_LOGIC_VECTOR(3 downto 0));

end component;

--Inputs
    signal centesimas, decimas, dminutos, uhoras, load_dseg_inc, load_uhoras_add, load_dminutos_add, load_uminutos_add : std_logic_vector(3 downto 0) := "0000";
    signal useg : std_logic_vector(3 downto 0) := "1001";
    signal dseg : std_logic_vector(3 downto 0) := "0101"; 
    signal uminutos : std_logic_vector(3 downto 0) := "0010";
    signal load_useg_inc : std_logic_vector(3 downto 0) := "0001";
    
    --Outputs
    signal load_data_centesimas, load_data_decimas, load_data_useg, load_data_dseg, load_data_uminutos, load_data_dminutos, load_data_uhoras : STD_LOGIC_VECTOR(3 downto 0);

begin

uut: refresh_adders 
    PORT MAP ( centesimas => centesimas,
               decimas => decimas,
               useg => useg,
               dseg => dseg,
               uminutos => uminutos,
               dminutos => dminutos,
               uhoras => uhoras,
               load_useg_inc => load_useg_inc,
               load_dseg_inc => load_dseg_inc,
               load_uminutos_add => load_uminutos_add,
               load_dminutos_add => load_dminutos_add,
               load_uhoras_add => load_uhoras_add,
               load_data_centesimas => load_data_centesimas,
               load_data_decimas => load_data_decimas,
               load_data_useg => load_data_useg,
               load_data_dseg => load_data_dseg,
               load_data_uminutos => load_data_uminutos,
               load_data_dminutos => load_data_dminutos,
               load_data_uhoras => load_data_uhoras
             );
        

stim_proc: process
begin
    decimas <= "0010"; decimas <= "0010";
    useg <= "0000"; dseg <= "0000"; uminutos <= "0000"; dminutos <= "0000"; uhoras <= "0000";
    load_useg_inc <= "0000"; load_dseg_inc <= "0000"; load_uminutos_add <= "0000"; load_dminutos_add <= "0000"; load_uhoras_add <= "0000";
    wait for 20 ns;
    
    load_useg_inc <= "0101";
    wait for 20 ns;
    
    useg <= "0111";
    load_useg_inc <= "0101";
    wait for 20 ns;
    
    useg <= "0000"; dseg <= "0101";
    load_useg_inc <= "0000"; load_dseg_inc <= "0010";
    wait for 20 ns;
    
    uhoras <= "0000"; dminutos <= "0101"; uminutos <= "1001"; dseg <= "0101"; useg <= "1001"; decimas <= "0000"; centesimas <= "0000";
    load_useg_inc <= "0001";
    load_dseg_inc <= "0000"; load_uminutos_add <= "0000"; load_dminutos_add <= "0000"; load_uhoras_add <= "0000";
    wait for 60 ns;
    
    wait;
    end process;
end Behavioral;

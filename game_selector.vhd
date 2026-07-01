----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.11.2024 19:49:07
-- Design Name: 
-- Module Name: game_selector - Behavioral
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

entity game_selector is
    Port ( clk : in std_logic;
           count_jugadas : in STD_LOGIC_VECTOR(6 downto 0);
           mode_time_inc : in STD_LOGIC_VECTOR(6 downto 0);
           load_data_uhoras, load_data_dminutos, load_data_uminutos, load_data_dseg ,load_data_useg, load_data_centesimas, load_data_decimas : out STD_LOGIC_VECTOR(3 downto 0);
           load_dseg_inc, load_useg_inc, load_uhoras_add, load_dminutos_add, load_uminutos_add : out STD_LOGIC_VECTOR(3 downto 0);
           zero, preset, load_sel : in STD_LOGIC
           );
end game_selector;

architecture Behavioral of game_selector is

--Señal para cargar los valores cambiantes del modo clásico
signal classic_dseg_inc, classic_useg_inc, classic_uhoras_add, classic_dminutos_add, classic_uminutos_add : std_logic_vector(3 downto 0);
signal turno_40, turno_50, turno_60, turno_X, incremento_ON : std_logic;
signal jugadas_time : std_logic_vector(6 downto 0);

--Señales intermedias
signal sel_load_data_uhoras     : std_logic_vector(3 downto 0);
signal sel_load_data_dminutos   : std_logic_vector(3 downto 0);
signal sel_load_data_uminutos   : std_logic_vector(3 downto 0);
signal sel_load_data_dseg       : std_logic_vector(3 downto 0);
signal sel_load_data_useg       : std_logic_vector(3 downto 0);
signal sel_load_data_decimas    : std_logic_vector(3 downto 0);
signal sel_load_data_centesimas : std_logic_vector(3 downto 0);
signal sel_load_dseg_inc        : std_logic_vector(3 downto 0);
signal sel_load_useg_inc        : std_logic_vector(3 downto 0);
signal sel_load_uhoras_add      : std_logic_vector(3 downto 0);
signal sel_load_dminutos_add    : std_logic_vector(3 downto 0);
signal sel_load_uminutos_add    : std_logic_vector(3 downto 0);

begin

--Proceso para bloquear la adición de incrementos en el caso de que una cuenta llegue a 0
process(clk)
    begin
    if rising_edge(clk) then
        --Inicializar todos los valores de los contadores a '0' decimal
        sel_load_data_uhoras     <= "0000";
        sel_load_data_dminutos   <= "0000";
        sel_load_data_uminutos   <= "0000";
        sel_load_data_dseg       <= "0000";
        sel_load_data_useg       <= "0000";
        sel_load_data_decimas    <= "0000";
        sel_load_data_centesimas <= "0000";
        sel_load_dseg_inc        <= "0000";
        sel_load_useg_inc        <= "0000";
        sel_load_uhoras_add      <= "0000";
        sel_load_dminutos_add    <= "0000";
        sel_load_uminutos_add    <= "0000";

            --Proceso para inicializar los contadores según el modo de juego
                case mode_time_inc is
                   --Forzar el preset del modo clásico
                      when "0000011" =>
                        sel_load_data_uhoras <= "0010";
                        sel_load_data_dminutos <= "0011";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                        sel_load_uhoras_add <= classic_uhoras_add;
                        sel_load_dminutos_add <= classic_dminutos_add;
                        sel_load_uminutos_add <= classic_uminutos_add;
                      when "0000010" =>
                        sel_load_data_uhoras <= "0010";
                        sel_load_data_dminutos <= "0011";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                        sel_load_uhoras_add <= classic_uhoras_add;
                        sel_load_dminutos_add <= classic_dminutos_add;
                        sel_load_uminutos_add <= classic_uminutos_add;
                      when "0000001" =>
                        sel_load_data_uhoras <= "0010";
                        sel_load_data_dminutos <= "0011";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                        sel_load_uhoras_add <= classic_uhoras_add;
                        sel_load_dminutos_add <= classic_dminutos_add;
                        sel_load_uminutos_add <= classic_uminutos_add;
                      when "0000000" =>
                        sel_load_data_uhoras <= "0010";
                        sel_load_data_dminutos <= "0011";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                        sel_load_uhoras_add <= classic_uhoras_add;
                        sel_load_dminutos_add <= classic_dminutos_add;
                        sel_load_uminutos_add <= classic_uminutos_add;
                      when "0001011" =>
                        sel_load_data_uhoras <= "0010";
                        sel_load_data_dminutos <= "0000";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= classic_dseg_inc;
                        sel_load_useg_inc <= classic_useg_inc;
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                        sel_load_uhoras_add <= classic_uhoras_add;
                        sel_load_dminutos_add <= classic_dminutos_add;
                        sel_load_uminutos_add <= classic_uminutos_add;
                      when "0001010" =>
                        sel_load_data_uhoras <= "0010";
                        sel_load_data_dminutos <= "0000";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= classic_dseg_inc;
                        sel_load_useg_inc <= classic_useg_inc;
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                        sel_load_uhoras_add <= classic_uhoras_add;
                        sel_load_dminutos_add <= classic_dminutos_add;
                        sel_load_uminutos_add <= classic_uminutos_add;
                      when "0001001" =>
                        sel_load_data_uhoras <= "0010";
                        sel_load_data_dminutos <= "0000";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= classic_dseg_inc;
                        sel_load_useg_inc <= classic_useg_inc;
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                        sel_load_uhoras_add <= classic_uhoras_add;
                        sel_load_dminutos_add <= classic_dminutos_add;
                        sel_load_uminutos_add <= classic_uminutos_add;
                      when "0001000" =>
                        sel_load_data_uhoras <= "0010";
                        sel_load_data_dminutos <= "0000";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= classic_dseg_inc;
                        sel_load_useg_inc <= classic_useg_inc;
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                        sel_load_uhoras_add <= classic_uhoras_add;
                        sel_load_dminutos_add <= classic_dminutos_add;
                        sel_load_uminutos_add <= classic_uminutos_add;
                      when "0010011" =>
                        sel_load_data_uhoras <= "0010";
                        sel_load_data_dminutos <= "0000";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                        sel_load_uhoras_add <= classic_uhoras_add;
                        sel_load_dminutos_add <= classic_dminutos_add;
                        sel_load_uminutos_add <= classic_uminutos_add;
                      when "0010010" =>
                        sel_load_data_uhoras <= "0010";
                        sel_load_data_dminutos <= "0000";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                        sel_load_uhoras_add <= classic_uhoras_add;
                        sel_load_dminutos_add <= classic_dminutos_add;
                        sel_load_uminutos_add <= classic_uminutos_add;
                      when "0010001" =>
                        sel_load_data_uhoras <= "0010";
                        sel_load_data_dminutos <= "0000";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                        sel_load_uhoras_add <= classic_uhoras_add;
                        sel_load_dminutos_add <= classic_dminutos_add;
                        sel_load_uminutos_add <= classic_uminutos_add;
                      when "0010000" =>
                        sel_load_data_uhoras <= "0010";
                        sel_load_data_dminutos <= "0000";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                        sel_load_uhoras_add <= classic_uhoras_add;
                        sel_load_dminutos_add <= classic_dminutos_add;
                        sel_load_uminutos_add <= classic_uminutos_add;
                      when "0011011" =>
                        sel_load_data_uhoras <= "0001";
                        sel_load_data_dminutos <= "0011";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= classic_dseg_inc;
                        sel_load_useg_inc <= classic_useg_inc;
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                        sel_load_uhoras_add <= classic_uhoras_add;
                        sel_load_dminutos_add <= classic_dminutos_add;
                        sel_load_uminutos_add <= classic_uminutos_add;
                      when "0011010" =>
                        sel_load_data_uhoras <= "0001";
                        sel_load_data_dminutos <= "0011";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= classic_dseg_inc;
                        sel_load_useg_inc <= classic_useg_inc;
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                        sel_load_uhoras_add <= classic_uhoras_add;
                        sel_load_dminutos_add <= classic_dminutos_add;
                        sel_load_uminutos_add <= classic_uminutos_add;
                      when "0011001" =>
                        sel_load_data_uhoras <= "0001";
                        sel_load_data_dminutos <= "0011";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= classic_dseg_inc;
                        sel_load_useg_inc <= classic_useg_inc;
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                        sel_load_uhoras_add <= classic_uhoras_add;
                        sel_load_dminutos_add <= classic_dminutos_add;
                        sel_load_uminutos_add <= classic_uminutos_add;
                      when "0011000" =>
                        sel_load_data_uhoras <= "0001";
                        sel_load_data_dminutos <= "0011";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= classic_dseg_inc;
                        sel_load_useg_inc <= classic_useg_inc;
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                        sel_load_uhoras_add <= classic_uhoras_add;
                        sel_load_dminutos_add <= classic_dminutos_add;
                        sel_load_uminutos_add <= classic_uminutos_add;
                     --Forzar el preset del modo rápido
                      when "0100011" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0110";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0100010" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0110";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0100001" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0110";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0100000" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0110";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0100111" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0101";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0100110" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0101";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0100101" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0101";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0100100" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0101";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0001";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0101011" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0100";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0101010" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0100";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0010";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0101001" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0100";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0001";
                        sel_load_useg_inc <= "0101";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0101000" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0100";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0001";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0101111" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0011";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0011";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0101110" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0011";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0010";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0101101" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0011";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0001";
                        sel_load_useg_inc <= "0101";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0101100" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0011";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0001";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0110011" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0010";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0011";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0110010" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0010";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0010";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0110001" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0010";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0001";
                        sel_load_useg_inc <= "0101";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0110000" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0010";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0001";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0110111" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0001";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0011";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0110110" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0001";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0010";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0110101" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0001";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0001";
                        sel_load_useg_inc <= "0101";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0110100" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0001";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0001";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0111011" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0001";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0011";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0111010" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0001";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0010";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0111001" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0001";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0001";
                        sel_load_useg_inc <= "0101";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0111000" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0001";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0001";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0111111" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0001";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0011";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0111110" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0001";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0010";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0111101" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0001";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0001";
                        sel_load_useg_inc <= "0101";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "0111100" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0001";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0001";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      --Forzar el preset del modo blitz
                      when "1000011" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0001";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "1000010" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0001";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "1000001" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0001";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "1000000" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0001";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "1001011" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0000";
                        sel_load_data_uminutos <= "1000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "1001010" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0000";
                        sel_load_data_uminutos <= "1000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "1001001" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0000";
                        sel_load_data_uminutos <= "1000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "1001000" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0000";
                        sel_load_data_uminutos <= "1000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0010";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "1010011" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0000";
                        sel_load_data_uminutos <= "0101";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0101";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "1010010" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0000";
                        sel_load_data_uminutos <= "0101";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0100";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "1010001" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0000";
                        sel_load_data_uminutos <= "0101";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0011";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "1010000" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0000";
                        sel_load_data_uminutos <= "0101";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0010";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "1011011" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0000";
                        sel_load_data_uminutos <= "0011";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0101";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "1011010" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0000";
                        sel_load_data_uminutos <= "0011";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0100";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "1011001" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0000";
                        sel_load_data_uminutos <= "0011";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0011";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "1011000" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0000";
                        sel_load_data_uminutos <= "0011";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0010";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      --Forzar el preset del modo bullet
                      when "1100011" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0000";
                        sel_load_data_uminutos <= "0010";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0001";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "1100010" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0000";
                        sel_load_data_uminutos <= "0010";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0001";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "1100001" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0000";
                        sel_load_data_uminutos <= "0010";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0001";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "1100000" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0000";
                        sel_load_data_uminutos <= "0010";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0001";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "1110011" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0000";
                        sel_load_data_uminutos <= "0001";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0001";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "1110010" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0000";
                        sel_load_data_uminutos <= "0001";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0001";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "1110001" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0000";
                        sel_load_data_uminutos <= "0001";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0001";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      when "1110000" =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0000";
                        sel_load_data_uminutos <= "0001";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0001";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                      --Si se introduce una combinación que no se corresponda con ningún modo.
                      when others =>
                        sel_load_data_uhoras <= "0000";
                        sel_load_data_dminutos <= "0000";
                        sel_load_data_uminutos <= "0000";
                        sel_load_data_dseg <= "0000";
                        sel_load_data_useg <= "0000";
                        sel_load_dseg_inc <= "0000";
                        sel_load_useg_inc <= "0000";
                        sel_load_data_decimas <= "0000";
                        sel_load_data_centesimas <= "0000";
                   end case;
    end if;         
end process;

--Señal para identificar los turnos clave
turno_40 <= count_jugadas(6) and not count_jugadas(5) and not count_jugadas(4) and (not count_jugadas(3) and not count_jugadas(2) and not count_jugadas(1) and not count_jugadas(0));
turno_50 <= count_jugadas(6) and not count_jugadas(5) and count_jugadas(4) and (not count_jugadas(3) and not count_jugadas(2) and not count_jugadas(1) and not count_jugadas(0));
turno_60 <= count_jugadas(6) and count_jugadas(5) and not count_jugadas(4) and (not count_jugadas(3) and not count_jugadas(2) and not count_jugadas(1) and not count_jugadas(0));
turno_X <= not turno_40 and not turno_50 and not turno_60;

--Señal  para indicar si se ha introducido un incremento
incremento_ON <= classic_dseg_inc(3) or classic_dseg_inc(2) or classic_dseg_inc(1) or classic_dseg_inc(0) or classic_useg_inc(3) or classic_useg_inc(2) or classic_useg_inc(1) or classic_useg_inc(0);

--Señal que contendrá la cuenta de las jugadas, los 2 bits referentes a la elección de tiempo en el modo clásico y el bit indicando si existe incremento añadido
jugadas_time <= turno_X & turno_40 & turno_50 & turno_60 & mode_time_inc(4) & mode_time_inc(3) & incremento_ON;

--Proceso controlado por reloj para la asignación de valores y adición de incrementos en función del número de jugadas
process(clk)
begin
    if rising_edge(clk) then
        -- Forzado a 0 de todos los valores de adición si la cuenta alcanza 0
        if zero = '1' or preset = '1' then
            classic_dseg_inc <= "0000";
            classic_useg_inc <= "0000";
            load_dseg_inc <= "0000";
            load_useg_inc <= "0000";
            classic_uhoras_add <= "0000";
            classic_dminutos_add <= "0000";
            classic_uminutos_add <= "0000";
            
        -- Asignación de los valores reales cuando se tenga el preset o el load_sel activo    
        elsif  load_sel  = '1' then
            load_data_uhoras     <= sel_load_data_uhoras;
            load_data_dminutos   <= sel_load_data_dminutos;
            load_data_uminutos   <= sel_load_data_uminutos;
            load_data_dseg       <= sel_load_data_dseg;
            load_data_useg       <= sel_load_data_useg;
            load_data_decimas    <= sel_load_data_decimas;
            load_data_centesimas <= sel_load_data_centesimas;
            
            load_dseg_inc        <= sel_load_dseg_inc;
            load_useg_inc        <= sel_load_useg_inc;
            load_uhoras_add      <= sel_load_uhoras_add;
            load_dminutos_add    <= sel_load_dminutos_add;
            load_uminutos_add    <= sel_load_uminutos_add;
                    
        else 
            case jugadas_time is
                --Cuenta en 0 jugadas, modo clásico 0
                when "1000000" =>
                    classic_dseg_inc <= "0000";
                    classic_useg_inc <= "0000";
                    classic_uhoras_add <= "0000";
                    classic_dminutos_add <= "0000";
                    classic_uminutos_add <= "0000";
                --Cuenta en 40 jugadas, modo clásico 0
                when "0100000" =>
                    classic_dseg_inc <= "0000";
                    classic_useg_inc <= "0000";
                    classic_uhoras_add <= "0001";
                    classic_dminutos_add <= "0000";
                    classic_uminutos_add <= "0000";
                --Cuenta en 60 jugadas, modo clásico 0
                when "0001000" =>
                    classic_dseg_inc <= "0000";
                    classic_useg_inc <= "0000";
                    classic_uhoras_add <= "0000";
                    classic_dminutos_add <= "0011";
                    classic_uminutos_add <= "0000";
                --Cuenta en 0 jugadas, modo clásico 1
                when "1000100" =>
                    classic_dseg_inc <= "0000";
                    classic_useg_inc <= "0000";
                    classic_uhoras_add <= "0000";
                    classic_dminutos_add <= "0000";
                    classic_uminutos_add <= "0000";
                --Cuenta en 40 jugadas, modo clásico 1
                when "0100100" =>
                    classic_dseg_inc <= "0000";
                    classic_useg_inc <= "0000";
                    classic_uhoras_add <= "0001";
                    classic_dminutos_add <= "0000";
                    classic_uminutos_add <= "0000";
                --Cuenta en 60 jugadas, modo clásico 1    
                when "0001100" =>
                    classic_dseg_inc <= "0011";
                    classic_useg_inc <= "0000";
                    classic_uhoras_add <= "0000";
                    classic_dminutos_add <= "0001";
                    classic_uminutos_add <= "0101";
                --Cuenta en +60 jugadas, modo clásico 1    
                when "1000101" =>
                    classic_dseg_inc <= "0011";
                    classic_useg_inc <= "0000";
                    classic_uhoras_add <= "0000";
                    classic_dminutos_add <= "0000";
                    classic_uminutos_add <= "0000";
                --Cuenta en 0 jugadas, modo clásico 2
                when "1000010" =>
                    classic_dseg_inc <= "0000";
                    classic_useg_inc <= "0000";
                    classic_uhoras_add <= "0000";
                    classic_dminutos_add <= "0000";
                    classic_uminutos_add <= "0000";
                --Cuenta en 50 jugadas, modo clásico 2
                when "0010010" =>
                    classic_dseg_inc <= "0000";
                    classic_useg_inc <= "0000";
                    classic_uhoras_add <= "0001";
                    classic_dminutos_add <= "0000";
                    classic_uminutos_add <= "0000";
                --Cuenta en 0 jugadas, modo clásico 3
                when "1000110" =>
                    classic_dseg_inc <= "0000";
                    classic_useg_inc <= "0000";
                    classic_uhoras_add <= "0000";
                    classic_dminutos_add <= "0000";
                    classic_uminutos_add <= "0000";
                --Cuenta en 40 jugadas, modo clásico 3   
                when "0100110" =>
                    classic_dseg_inc <= "0011";
                    classic_useg_inc <= "0000"; 
                    classic_uhoras_add <= "0000";
                    classic_dminutos_add <= "0011";
                    classic_uminutos_add <= "0000";
                --Cuenta en +40 jugadas, modo clásico 3   
                when "1000111" =>
                    classic_dseg_inc <= "0011";
                    classic_useg_inc <= "0000"; 
                    classic_uhoras_add <= "0000";
                    classic_dminutos_add <= "0000";
                    classic_uminutos_add <= "0000";
                when others =>
                    classic_dseg_inc <= "0000";
                    classic_useg_inc <= "0000"; 
                    classic_uhoras_add <= "0000";
                    classic_dminutos_add <= "0000";
                    classic_uminutos_add <= "0000";  
            end case;
         end if;
    end if;         
end process;  

--Guía de las distintas combinaciones de switches y lo que implican en el selector.

    --Teniendo en cuenta que mode_time_inc va de 6 a 0, siendo 6 el bit más significativo (el de más a la izquierda) 
    --y 0 el menos significativo (el de más a la derecha), estas son las distintas selecciones y cómo elegirlas según los switches correspondientes.

    --Selección de modo de juego (mode_time_inc(6) y mode_time_inc(5)):
        --Modo clásico -> "00"
        --Modo rápido -> "01"
        --Modo relámpago (blitz) -> "10"
        --Modo bala (bullet) -> "11"
        
    --Selección de tiempos (mode_time_inc(4), mode_time_inc(3) y mode_time_inc(2)):
        --Con modo clásico configurado (mode_time_inc(2) no afecta para este modo):
            --Modo 0: 2 horas y 30 minutos, con adición de 1 hora trás 40 jugadas y otros 30 minutos a las 60 jugadas -> "000"
            --Modo 1: 2 horas, con adición de 1 hora tras 40 jugadas y 15 minutos e incremento de 30 segundos a las 60 jugadas -> "010"
            --Modo 2: 2 horas, y adición de 1 hora tras 50 jugadas -> "100"
            --Modo 3: 1 hora y media, y adición de 30 minutos e incrementos de 30 segundos tras 40 jugadas -> "110"
        --Con modo rápido configurado:
            --Modo 0: 60 minutos sin incremento -> "000"
            --Modo 1: 50 minutos con incremento de 10 segundos -> "001"
            --Modo 2: 40 minutos con incremento de 20 segundos -> "010"
            --Modo 3: 30 minutos con incremento de 30 segundos -> "011"
            --Modo 4: 20 minutos con incremento variable (mirar selección de incrementos en el apartado de modo rápido) -> "100"
            --Modo 5, 6 y 7: 10 minutos con incremento variable (mirar selección de incrementos en el apartado de modo rápido) -> "101", "110" y "111"
        --Con modo relámpago configurado (mode_time_inc(2) no afecta para este modo):
            --Modo 0: 10 minutos sin incremento -> "000"
            --Modo 1: 8 minutos con incremento de 2 segundos -> "010"
            --Modo 2: 5 minutos con incremento variable (mirar selección de incrementos en el apartado de modo relámpago) -> "100"
            --Modo 3: 3 minutos con incremento variable (mirar selección de incrementos en el apartado de modo relámpago) -> "110"
        --Con modo bala configurado (mode_time_inc (3) y mode_time_inc(2) no afectan para este modo):
            --Modo 0: 2 minutos sin incremento -> "000"
            --Modo 1: 1 minuto con incremento de 1 segundo -> "100"
            
    --Selección de incrementos (mode_time_inc(1) y mode_time_inc(0)):
        --Con modo rápido configurado:
            --Incremento de 30 segundos -> "11"
            --Incremento de 20 segundos -> "10"
            --Incremento de 15 segundos -> "01"
            --Incremento de 10 segundos -> "00"
        --Con modo relámpago configurado:
            --Incremento de 5 segundos -> "11"
            --Incremento de 4 segundos -> "10"
            --Incremento de 3 segundos -> "01"
            --Incremento de 2 segundos -> "00"    
        --Para los modos o tiempos en los que no hayan incrementos o sean fijos, esta elección no afectará en absoluto
        
--Cualquier combinación de switches que no esté incluída como una opción dentro de las indicadas en esta guía, inicializará todos los contadores e incrementos a "0". 
          

end Behavioral;

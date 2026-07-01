----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.11.2024 20:09:55
-- Design Name: 
-- Module Name: segunda_prueba_tb - Behavioral
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

entity segunda_prueba_tb is
--  Port ( );
end segunda_prueba_tb;

architecture Behavioral of segunda_prueba_tb is

component segunda_prueba
    Port ( clk : in  STD_LOGIC;
           preset : in  STD_LOGIC;
           ce : in STD_LOGIC;
           load_sel : in  STD_LOGIC;
           mode_switch : in STD_LOGIC_VECTOR(1 downto 0);
           time_switch : in STD_LOGIC_VECTOR(2 downto 0);
           increment_switch : in STD_LOGIC_VECTOR(1 downto 0);
           led : out STD_LOGIC_VECTOR(6 downto 0);
           an : out STD_LOGIC_VECTOR(7 downto 0)
           );
end component;

    --Inputs
    signal clk : std_logic := '0';
    signal preset : std_logic := '1';
    signal ce : std_logic := '1'; 
    signal load_sel : std_logic := '1';
    signal mode_switch : std_logic_vector(1 downto 0) := "11";
    signal time_switch : std_logic_vector(2 downto 0) := "100";
    signal increment_switch : std_logic_vector(1 downto 0) := "00";
    
    --Outputs
    signal led : std_logic_vector(6 downto 0);
    signal an : std_logic_vector(7 downto 0);
    

begin

uut : segunda_prueba
    Port map (
        clk => clk,
        preset => preset,
        ce => ce,
        load_sel => load_sel,
        mode_switch => mode_switch,
        time_switch => time_switch,
        increment_switch => increment_switch,
        led => led,
        an => an
        );

 -- Generador de reloj: 100 MHz (10 ns de periodo)
    clk_process: process
    begin
        while now < 500 ms loop -- Limitar duración de simulación
            clk <= '1';
            wait for 5 ns;
            clk <= '0';
            wait for 5 ns;
        end loop;
        wait;
    end process clk_process;
    
    -- Proceso de prueba
    stim_proc: process
    begin
        -- Aplicar preset y verificar reinicio
        preset <= '1';
        load_sel <= '1';
        ce <= '1';
        wait for 50 ns; -- Tiempo de reinicio
        preset <= '0';
        wait for 2 ms;
        preset <= '1';
        wait for 20 ns;
        preset <= '0';
        load_sel <= '0';

        -- Habilitar el conteo y observar el cambio en las centésimas y décimas
        wait for 0.5 ms;
        ce <= '0';
        wait for 2000 ns;
        ce <= '1';

        -- Simulación completa
        wait;
    end process stim_proc; 
    
end Behavioral;
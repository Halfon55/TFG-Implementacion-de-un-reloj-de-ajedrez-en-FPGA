----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.10.2024 18:06:52
-- Design Name: 
-- Module Name: up_counter_tb - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity up_counter_tb is
--  Port ( );
end up_counter_tb;

architecture Behavioral of up_counter_tb is

    -- Señales de prueba
    signal clk       : std_logic := '0';
    signal reset     : std_logic := '0';
    signal ce        : std_logic := '0';
    signal count_out : std_logic_vector(3 downto 0);
    signal top       : std_logic;

    -- Parámetros del contador
    constant module_val : integer := 10;
    constant width_val  : integer := 4;

    -- Instancia del componente `up_counter`
    component up_counter
        Generic ( module : integer := module_val;
                  width  : integer := width_val );
        Port ( clk       : in  std_logic;
               reset     : in  std_logic;
               count     : out std_logic_vector(width_val-1 downto 0);
               ce        : in  std_logic;
               top       : out std_logic );
    end component;

begin

    -- Instanciar el contador
    uut: up_counter
        Generic map (
            module => module_val,
            width  => width_val
        )
        Port map (
            clk   => clk,
            reset => reset,
            count => count_out,
            ce    => ce,
            top   => top
        );

    -- Generador de reloj (500 ns de periodo = 1 MHz)
    clk_process : process
    begin
        clk <= '0';
        wait for 250 ns;
        clk <= '1';
        wait for 250 ns;
    end process;

    -- Proceso de estímulo
    stim_proc: process
    begin
        -- Probar el reinicio
        reset <= '1';
        wait for 500 ns;
        reset <= '0';
        
        -- Habilitar el conteo
        ce <= '1';
        
        -- Observar durante 10 ciclos de reloj
        wait for 5000 ns;
        
        -- Detener la simulación
        wait;
    end process;

end Behavioral;

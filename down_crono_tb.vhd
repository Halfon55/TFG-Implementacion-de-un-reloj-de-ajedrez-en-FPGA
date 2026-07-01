----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.10.2024 18:17:32
-- Design Name: 
-- Module Name: down_crono_tb - Behavioral
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

entity down_crono_tb is
--  Port ( );
end down_crono_tb;

architecture Behavioral of down_crono_tb is

component down_crono
    Port ( clk : in  STD_LOGIC;
           preset : in  STD_LOGIC;
           ce : in STD_LOGIC;
           led : out STD_LOGIC_VECTOR(6 downto 0);
           an : out STD_LOGIC_VECTOR(7 downto 0);
           modo, incremento : in STD_LOGIC_VECTOR(1 downto 0);
           tiempo : in STD_LOGIC_VECTOR(2 downto 0);
           uhoras_out : out STD_LOGIC_VECTOR(3 downto 0);
           dminutos_out : out STD_LOGIC_VECTOR(3 downto 0);
           uminutos_out : out STD_LOGIC_VECTOR(3 downto 0);
           dseg_out : out STD_LOGIC_VECTOR(3 downto 0);
           useg_out : out STD_LOGIC_VECTOR(3 downto 0));
end component;

    --Inputs
    signal clk           : std_logic := '0';
    signal preset         : std_logic := '0';
    signal ce            : std_logic := '1'; 
    signal modo          : std_logic_vector(1 downto 0) := "11";
    signal tiempo        : std_logic_vector(2 downto 0) := "000";
    signal incremento    : std_logic_vector(1 downto 0) := "00";
    
    --Outputs
    signal led           : std_logic_vector(6 downto 0);
    signal an            : std_logic_vector(7 downto 0);
    signal uhoras_out: std_logic_vector(3 downto 0); 
    signal dminutos_out: std_logic_vector(3 downto 0); 
    signal uminutos_out   : std_logic_vector(3 downto 0);
    signal dseg_out   : std_logic_vector(3 downto 0);
    signal useg_out   : std_logic_vector(3 downto 0);
    
begin

uut : down_crono
    Port map (
        clk => clk,
        preset => preset,
        ce => ce,
        led => led,
        an => an,
        modo => modo,
        tiempo => tiempo,
        incremento => incremento,
        uhoras_out => uhoras_out,
        dminutos_out => dminutos_out,
        uminutos_out => uminutos_out,
        dseg_out => dseg_out,
        useg_out => useg_out
        );
        
    -- Generador de reloj: 100 MHz (10 ns de periodo)
    clk_process: process
    begin
        while now < 500 ms loop -- Limitar duración de simulación
            clk <= '0';
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
        end loop;
        wait;
    end process clk_process;
    
    -- Proceso de prueba
    stim_proc: process
    begin
        -- Aplicar preset y verificar reinicio
        preset <= '1';
        wait for 20 ns; -- Tiempo de reinicio
        preset <= '0';
        wait for 2 ms;
        preset <= '1';
        wait for 20 ns;
        preset <= '0';

        -- Habilitar el conteo y observar el cambio en las centésimas y décimas
        ce <= '1';
        wait for 100 ns;
        ce <= '0';
        wait for 10 ns;
        ce <= '1';

        -- Simulación completa
        wait;
    end process stim_proc;            

end Behavioral;
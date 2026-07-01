----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.04.2026 13:39:10
-- Design Name: 
-- Module Name: chess_pkg - Behavioral
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

package chess_pkg is
    -- Definimos el tipo aquí para que sea global
    type menu_state_t is (
        MENU_INICIAL,      
        MODO_ELEGIDO,      
        TIEMPO_ELEGIDO,    
        LISTO_PARA_JUGAR,  
        JUEGO_COMENZADO,   
        JUEGO_PAUSADO      
    );
    
    --Definir el selector de modo para determinar la cantidad de opciones de tiempo que aparecen
    type mode_sel_t is (
        MODO_CLASICO,
        MODO_RAPIDO,
        MODO_RELAMPAGO,
        MODO_BALA,
        MODO_NINGUNO
    );
end package chess_pkg;

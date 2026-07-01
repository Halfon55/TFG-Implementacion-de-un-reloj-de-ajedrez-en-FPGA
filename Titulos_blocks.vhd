----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.04.2026 18:56:29
-- Design Name: 
-- Module Name: Titulos_blocks - Behavioral
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
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Titulos_blocks is
Generic (char_H_LOC : natural := 200;
	         char_V_LOC : natural := 100);
    Port ( CLK_I        : in  STD_LOGIC;
           VSYNC_I      : in  STD_LOGIC;
           h_cntr_reg   : in std_logic_vector(11 downto 0);
           v_cntr_reg   : in std_logic_vector(11 downto 0);           
--           ACTIVE_I   : in  STD_LOGIC;
           menu_state   : in std_logic_vector(4 downto 0);
           OVERLAY_O    : out  STD_LOGIC
           );
end Titulos_blocks;

architecture Behavioral of Titulos_blocks is

-- BRAM 950x220 blocks
COMPONENT Titulos_mem
PORT (
    clka  : IN STD_LOGIC;
    ena   : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
);
END COMPONENT;
    
constant SZ_char_WIDTH  : natural := 950;
constant SZ_char_HEIGHT : natural := 220; 

-- Declaración de las posiciones de cada bloque basados en la posición de referencia (genéricos de entrada)
-- Títulos "MENU DE AJEDREZ" y "PARTIDA EN CURSO" (misma ubicación, distintos estados del menú)
constant TITULO_LEFT	: natural := char_H_LOC + 285 - 1;
constant TITULO_RIGHT   : natural := char_H_LOC + 285 + SZ_char_WIDTH;
constant TITULO_TOP	    : natural := char_V_LOC - 60 - 1;
constant TITULO_BOTTOM  : natural := char_V_LOC - 60 + SZ_char_HEIGHT;

-- Señales addr para cada señal
signal addr_titulo_menu  : std_logic_vector(17 downto 0) := (others=>'0');
signal addr_titulo_juego : std_logic_vector(17 downto 0) := (others=>'0');

constant TOTAL_RAM_DEPTH : integer :=  (SZ_char_WIDTH*SZ_char_HEIGHT);
signal addr_titulo : std_logic_vector(17 downto 0) := (others=>'0');
signal data_titulo : std_logic_vector(1 downto 0);
signal data_dummy  : std_logic_vector(0 downto 0);
    
begin

-- 700x200 blocks
Inst_950x220_blocks : Titulos_mem
    PORT MAP(
    clka  =>  CLK_I,
    ena   => '1',
    addra => addr_titulo,
    douta => data_titulo
    ); 
    
-- Contadores de los bits contenidos en la memoria

-- Posición de los títulos
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_titulo <= (others=>'0');
     elsif (h_cntr_reg > TITULO_LEFT and h_cntr_reg < TITULO_RIGHT 
                          and v_cntr_reg < TITULO_BOTTOM and v_cntr_reg > TITULO_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_titulo = (TOTAL_RAM_DEPTH - 1)) then
        addr_titulo <= (others=>'0');
      else
        addr_titulo <= addr_titulo + 1;
      end if;
    end if;
  end if;
end process;      
        
-- Carga del dato de la memoria según la ubicación que se esté recorriendo

process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    -- "MENU DE AJEDREZ"
    if (menu_state(3 downto 0) /= "0000") and (h_cntr_reg > TITULO_LEFT and h_cntr_reg < TITULO_RIGHT 
                          and v_cntr_reg < TITULO_BOTTOM and v_cntr_reg > TITULO_TOP) then 
     data_dummy(0) <= data_titulo(1);
    -- "PARTIDA EN CURSO" 
    elsif (menu_state(4) = '1') and (h_cntr_reg > TITULO_LEFT and h_cntr_reg < TITULO_RIGHT 
                          and v_cntr_reg < TITULO_BOTTOM and v_cntr_reg > TITULO_TOP) then 
     data_dummy(0) <= data_titulo(0);
    else
     data_dummy(0) <= '1';
    end if;
  end if;
end process;

-- Assign output
OVERLAY_O <= data_dummy(0);
 
end Behavioral;

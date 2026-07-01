----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.04.2026 22:09:17
-- Design Name: 
-- Module Name: Ventana_emergente - Behavioral
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

entity Ventana_emergente is
	Generic (char_H_LOC : natural := 200;
	         char_V_LOC : natural := 100);
    Port ( CLK_I        : in  STD_LOGIC;
           VSYNC_I      : in  STD_LOGIC;
           h_cntr_reg   : in std_logic_vector(11 downto 0);
           v_cntr_reg   : in std_logic_vector(11 downto 0);           
--           ACTIVE_I   : in  STD_LOGIC;
           OVERLAY_O    : out  STD_LOGIC
           );
end Ventana_emergente;

architecture Behavioral of Ventana_emergente is

-- BRAM 400x120 text block
COMPONENT Ventana_emergente_texto
PORT (
    clka  : IN STD_LOGIC;
    ena   : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
);
END COMPONENT;
    
constant SZ_char_WIDTH  : natural := 400;
constant SZ_char_HEIGHT : natural := 120; 

-- Declaración de las posiciones de cada bloque basados en la posición de referencia (genéricos de entrada)
-- Texto de ventana emergente
constant VENTANA_LEFT	: natural := char_H_LOC + 560 - 1;
constant VENTANA_RIGHT  : natural := char_H_LOC + 560 + SZ_char_WIDTH;
constant VENTANA_TOP	: natural := char_V_LOC + 200 - 1;
constant VENTANA_BOTTOM : natural := char_V_LOC + 200 + SZ_char_HEIGHT;

constant TOTAL_RAM_DEPTH : integer :=  (SZ_char_WIDTH*SZ_char_HEIGHT);
signal addr_ventana : std_logic_vector(15 downto 0) := (others=>'0');
signal data_ventana : std_logic_vector(0 downto 0);
signal data_dummy   : std_logic_vector(0 downto 0);

begin

-- 150x90 blocks
Inst_400x120_blocks : Ventana_emergente_texto
    PORT MAP(
    clka  =>  CLK_I,
    ena   => '1',
    addra => addr_ventana,
    douta => data_ventana
    );
    
-- Contadores de los bits contenidos en la memoria

process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_ventana <= (others=>'0');
     elsif (h_cntr_reg > VENTANA_LEFT and h_cntr_reg < VENTANA_RIGHT 
                          and v_cntr_reg < VENTANA_BOTTOM and v_cntr_reg > VENTANA_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_ventana = (TOTAL_RAM_DEPTH - 1)) then
        addr_ventana <= (others=>'0');
      else
        addr_ventana <= addr_ventana + 1;
      end if;
    end if;
  end if;
end process;

-- Carga del dato de la memoria según la ubicación que se esté recorriendo

process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (h_cntr_reg > VENTANA_LEFT and h_cntr_reg < VENTANA_RIGHT 
                          and v_cntr_reg < VENTANA_BOTTOM and v_cntr_reg > VENTANA_TOP) then 
     data_dummy(0) <= data_ventana(0);
    else
     data_dummy(0) <= '1';
    end if;
  end if;
end process;

-- Assign output
OVERLAY_O <= data_dummy(0);
    
end Behavioral;
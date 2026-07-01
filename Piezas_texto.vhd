----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.03.2026 18:09:06
-- Design Name: 
-- Module Name: Piezas_texto - Behavioral
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

entity Piezas_texto is
	Generic (char_H_LOC : natural := 200;
	         char_V_LOC : natural := 100);
    Port ( CLK_I        : in  STD_LOGIC;
           VSYNC_I      : in  STD_LOGIC;
           h_cntr_reg   : in std_logic_vector(11 downto 0);
           v_cntr_reg   : in std_logic_vector(11 downto 0);           
--           ACTIVE_I   : in  STD_LOGIC;
           OVERLAY_O    : out  STD_LOGIC
           );
end Piezas_texto;

architecture Behavioral of Piezas_texto is

-- BRAM 700x200 blocks
COMPONENT Piezas_blocks_mem
PORT (
    clka  : IN STD_LOGIC;
    ena   : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
);
END COMPONENT;
    
constant SZ_char_WIDTH  : natural := 700;
constant SZ_char_HEIGHT : natural := 200; 

-- Declaración de las posiciones de cada bloque basados en la posición de referencia (genéricos de entrada)
-- "PIEZAS BLANCAS"
constant BLANCAS_LEFT	: natural := char_H_LOC + 20 - 1;
constant BLANCAS_RIGHT  : natural := char_H_LOC + 20 + SZ_char_WIDTH;
constant BLANCAS_TOP	: natural := char_V_LOC + 200 - 1;
constant BLANCAS_BOTTOM : natural := char_V_LOC + 200 + SZ_char_HEIGHT;

-- "PIEZAS NEGRAS"
constant NEGRAS_LEFT	: natural := char_H_LOC + 800 - 1;
constant NEGRAS_RIGHT   : natural := char_H_LOC + 800 + SZ_char_WIDTH;
constant NEGRAS_TOP	    : natural := char_V_LOC + 200 - 1;
constant NEGRAS_BOTTOM  : natural := char_V_LOC + 200 + SZ_char_HEIGHT;

-- Señales addr para cada señal
signal addr_blancas     : std_logic_vector(17 downto 0) := (others=>'0');
signal addr_negras      : std_logic_vector(17 downto 0) := (others=>'0');

constant TOTAL_RAM_DEPTH : integer :=  (SZ_char_WIDTH*SZ_char_HEIGHT);
signal addr_piezas : std_logic_vector(17 downto 0) := (others=>'0');
signal data_piezas : std_logic_vector(1 downto 0);
signal data_dummy : std_logic_vector(0 downto 0);
    
begin

-- 700x200 blocks
Inst_700x200_blocks : Piezas_blocks_mem
    PORT MAP(
    clka  =>  CLK_I,
    ena   => '1',
    addra => addr_piezas,
    douta => data_piezas
    ); 
    
-- Contadores de los bits contenidos en la memoria

-- Piezas blancas
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_blancas <= (others=>'0');
     elsif (h_cntr_reg > BLANCAS_LEFT and h_cntr_reg < BLANCAS_RIGHT 
                          and v_cntr_reg < BLANCAS_BOTTOM and v_cntr_reg > BLANCAS_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_blancas = (TOTAL_RAM_DEPTH - 1)) then
        addr_blancas <= (others=>'0');
      else
        addr_blancas <= addr_blancas + 1;
      end if;
    end if;
  end if;
end process;

-- Piezas negras
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_negras <= (others=>'0');
     elsif (h_cntr_reg > NEGRAS_LEFT and h_cntr_reg < NEGRAS_RIGHT 
                          and v_cntr_reg < NEGRAS_BOTTOM and v_cntr_reg > NEGRAS_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_negras = (TOTAL_RAM_DEPTH - 1)) then
        addr_negras <= (others=>'0');
      else
        addr_negras <= addr_negras + 1;
      end if;
    end if;
  end if;
end process;

-- Proceso de multiplexado de las cuentas
process(h_cntr_reg, v_cntr_reg, addr_blancas, addr_negras)
begin
    if (h_cntr_reg > BLANCAS_LEFT and h_cntr_reg < BLANCAS_RIGHT and v_cntr_reg < BLANCAS_BOTTOM and v_cntr_reg > BLANCAS_TOP) then
        addr_piezas <= addr_blancas;
    elsif (h_cntr_reg > NEGRAS_LEFT and h_cntr_reg < NEGRAS_RIGHT and v_cntr_reg < NEGRAS_BOTTOM and v_cntr_reg > NEGRAS_TOP) then
        addr_piezas <= addr_negras;
    else
        addr_piezas <= (others => '0');
    end if;
end process;        
        
-- Carga del dato de la memoria según la ubicación que se esté recorriendo

process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    -- Piezas blancas
    if (h_cntr_reg > BLANCAS_LEFT and h_cntr_reg < BLANCAS_RIGHT 
                          and v_cntr_reg < BLANCAS_BOTTOM and v_cntr_reg > BLANCAS_TOP) then 
     data_dummy(0) <= data_piezas(0);
    -- Piezas negras 
    elsif (h_cntr_reg > NEGRAS_LEFT and h_cntr_reg < NEGRAS_RIGHT 
                          and v_cntr_reg < NEGRAS_BOTTOM and v_cntr_reg > NEGRAS_TOP) then 
     data_dummy(0) <= data_piezas(1);
    else
     data_dummy(0) <= '1';
    end if;
  end if;
end process;

-- Assign output
OVERLAY_O <= data_dummy(0);
    
end Behavioral;

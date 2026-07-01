----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.03.2026 17:33:51
-- Design Name: 
-- Module Name: Navigation_blocks - Behavioral
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

entity Navigation_blocks is
	Generic (char_H_LOC : natural := 200;
	         char_V_LOC : natural := 100);
    Port ( CLK_I        : in  STD_LOGIC;
           VSYNC_I      : in  STD_LOGIC;
           h_cntr_reg   : in std_logic_vector(11 downto 0);
           v_cntr_reg   : in std_logic_vector(11 downto 0);           
--           ACTIVE_I   : in  STD_LOGIC;
           OVERLAY_O    : out  STD_LOGIC
           );
end Navigation_blocks;

architecture Behavioral of Navigation_blocks is

-- BRAM 140x80 blocks
COMPONENT General_blocks_mem
PORT (
    clka  : IN STD_LOGIC;
    ena   : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
);
END COMPONENT;

constant SZ_char_WIDTH  : natural := 140;
constant SZ_char_HEIGHT : natural := 80; 

---- Señales para asignar la posición de los bloques
--signal X_ATRAS       : natural := char_H_LOC;
--signal X_JUGAR       : natural := char_H_LOC;

-- Declaración de las posiciones de cada bloque basados en la posición de referencia (genéricos de entrada)
-- Bloque "ATRAS"
constant ATRAS_LEFT	    : natural := char_H_LOC + 20 - 1;
constant ATRAS_RIGHT    : natural := char_H_LOC + 20 + SZ_char_WIDTH;
constant ATRAS_TOP	    : natural := char_V_LOC + 840 - 1;
constant ATRAS_BOTTOM   : natural := char_V_LOC + 840 + SZ_char_HEIGHT;

-- Bloque "JUGAR"
constant JUGAR_LEFT	    : natural := char_H_LOC + 690 - 1;
constant JUGAR_RIGHT    : natural := char_H_LOC + 690 + SZ_char_WIDTH;
constant JUGAR_TOP	    : natural := char_V_LOC + 840 - 1;
constant JUGAR_BOTTOM   : natural := char_V_LOC + 840 + SZ_char_HEIGHT;

-- Señales addr para cada señal
signal addr_jugar       : std_logic_vector(13 downto 0) := (others=>'0');
signal addr_atras       : std_logic_vector(13 downto 0) := (others=>'0');

constant TOTAL_RAM_DEPTH : integer :=  (SZ_char_WIDTH*SZ_char_HEIGHT);
signal addr_general : std_logic_vector(13 downto 0) := (others=>'0');
signal data_general : std_logic_vector(1 downto 0);
signal data_dummy : std_logic_vector(0 downto 0);

begin

-- 140x80 blocks
Inst_Generales_blocks : General_blocks_mem
    PORT MAP(
    clka  =>  CLK_I,
    ena   => '1',
    addra => addr_general,
    douta => data_general
    ); 

-- Contadores de los bits contenidos en la memoria

-- ATRAS
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_atras <= (others=>'0');
     elsif (h_cntr_reg > ATRAS_LEFT and h_cntr_reg < ATRAS_RIGHT 
                          and v_cntr_reg < ATRAS_BOTTOM and v_cntr_reg > ATRAS_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_atras = (TOTAL_RAM_DEPTH - 1)) then
        addr_atras <= (others=>'0');
      else
        addr_atras <= addr_atras + 1;
      end if;
    end if;
  end if;
end process; 
 
-- JUGAR
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_jugar <= (others=>'0');
     elsif (h_cntr_reg > JUGAR_LEFT and h_cntr_reg < JUGAR_RIGHT 
                          and v_cntr_reg < JUGAR_BOTTOM and v_cntr_reg > JUGAR_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_jugar = (TOTAL_RAM_DEPTH - 1)) then
        addr_jugar <= (others=>'0');
      else
        addr_jugar <= addr_jugar + 1;
      end if;
    end if;
  end if;
end process;

-- Proceso de multiplexado de las cuentas
process(h_cntr_reg, v_cntr_reg, addr_jugar, addr_atras)
begin
    if (h_cntr_reg > ATRAS_LEFT and h_cntr_reg < ATRAS_RIGHT and v_cntr_reg < ATRAS_BOTTOM and v_cntr_reg > ATRAS_TOP) then
        addr_general <= addr_atras;
    elsif (h_cntr_reg > JUGAR_LEFT and h_cntr_reg < JUGAR_RIGHT and v_cntr_reg < JUGAR_BOTTOM and v_cntr_reg > JUGAR_TOP) then
        addr_general <= addr_jugar;
    else
        addr_general <= (others => '0');
    end if;
end process;

-- Carga del dato de la memoria según la ubicación que se esté recorriendo

-- ATRAS
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    -- ATRAS
    if (h_cntr_reg > ATRAS_LEFT and h_cntr_reg < ATRAS_RIGHT 
                          and v_cntr_reg < ATRAS_BOTTOM and v_cntr_reg > ATRAS_TOP) then 
     data_dummy(0) <= data_general(1);
    -- JUGAR
    elsif (h_cntr_reg > JUGAR_LEFT and h_cntr_reg < JUGAR_RIGHT 
                          and v_cntr_reg < JUGAR_BOTTOM and v_cntr_reg > JUGAR_TOP) then 
     data_dummy(0) <= data_general(0);
    else
     data_dummy(0) <= '1';
    end if;
  end if;
end process;

-- Assign output
OVERLAY_O <= data_dummy(0); 

end Behavioral;
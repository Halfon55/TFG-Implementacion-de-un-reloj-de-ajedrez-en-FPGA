----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.02.2026 16:42:22
-- Design Name: 
-- Module Name: Count_display - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Count_display is
    Generic (char_V_LOC : natural := 100);
    Port ( CLK_I        : in  STD_LOGIC;
           VSYNC_I      : in  STD_LOGIC;
           h_cntr_reg   : in std_logic_vector(11 downto 0);
           v_cntr_reg   : in std_logic_vector(11 downto 0);
           char_H_LOC   : in natural;           
--           ACTIVE_I   : in  STD_LOGIC;
           CUENTA       : in std_logic_vector(27 downto 0);
           OVERLAY_O    : out  STD_LOGIC
           );
end Count_display;

architecture Behavioral of Count_display is

COMPONENT Cuenta_mem
    PORT (
        clka  : IN STD_LOGIC;
        ena   : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
    );
END COMPONENT;

-- Dimensiones de los bloques
constant SZ_char_WIDTH     : natural := 50;
constant SZ_char_HEIGHT    : natural := 140; 

-- Declaración de las posiciones de cada bloque basados en la posición de referencia (genéricos de entrada)
-- Unidades de horas
signal UHORAS_LEFT	            : natural := char_H_LOC - 1;
signal UHORAS_RIGHT             : natural := char_H_LOC + SZ_char_WIDTH;
constant UHORAS_TOP	            : natural := char_V_LOC + 600 - 1;
constant UHORAS_BOTTOM          : natural := char_V_LOC + 600 + SZ_char_HEIGHT;

-- Dos puntos horas-minutos
signal PUNTOS_HORASMIN_LEFT	    : natural := UHORAS_RIGHT - 1;
signal PUNTOS_HORASMIN_RIGHT    : natural := UHORAS_RIGHT + SZ_char_WIDTH;
constant PUNTOS_HORASMIN_TOP	: natural := char_V_LOC + 600 - 1;
constant PUNTOS_HORASMIN_BOTTOM : natural := char_V_LOC + 600 + SZ_char_HEIGHT;

-- Decenas de minutos
signal DMINUTOS_LEFT            : natural := PUNTOS_HORASMIN_RIGHT - 1;
signal DMINUTOS_RIGHT           : natural := PUNTOS_HORASMIN_RIGHT + SZ_char_WIDTH;
constant DMINUTOS_TOP	        : natural := char_V_LOC + 600 - 1;
constant DMINUTOS_BOTTOM        : natural := char_V_LOC + 600 + SZ_char_HEIGHT;

-- Unidades de minutos
signal UMINUTOS_LEFT            : natural := DMINUTOS_RIGHT - 1;
signal UMINUTOS_RIGHT           : natural := DMINUTOS_RIGHT + SZ_char_WIDTH;
constant UMINUTOS_TOP	        : natural := char_V_LOC + 600 - 1;
constant UMINUTOS_BOTTOM        : natural := char_V_LOC + 600 + SZ_char_HEIGHT;

-- Dos puntos minutos-segundos
signal PUNTOS_MINSEG_LEFT	    : natural := UMINUTOS_RIGHT - 1;
signal PUNTOS_MINSEG_RIGHT      : natural := UMINUTOS_RIGHT + SZ_char_WIDTH;
constant PUNTOS_MINSEG_TOP	    : natural := char_V_LOC + 600 - 1;
constant PUNTOS_MINSEG_BOTTOM   : natural := char_V_LOC + 600 + SZ_char_HEIGHT;

-- Decenas de segundo
signal DSEG_LEFT	            : natural := PUNTOS_MINSEG_RIGHT - 1;
signal DSEG_RIGHT               : natural := PUNTOS_MINSEG_RIGHT + SZ_char_WIDTH;
constant DSEG_TOP	            : natural := char_V_LOC + 600 - 1;
constant DSEG_BOTTOM            : natural := char_V_LOC + 600 + SZ_char_HEIGHT;

-- Unidades de segundo
signal USEG_LEFT	            : natural := DSEG_RIGHT - 1;
signal USEG_RIGHT               : natural := DSEG_RIGHT + SZ_char_WIDTH;
constant USEG_TOP	            : natural := char_V_LOC + 600 - 1;
constant USEG_BOTTOM            : natural := char_V_LOC + 600 + SZ_char_HEIGHT;

-- Punto minutos-segundos
signal PUNTO_LEFT	            : natural := USEG_RIGHT - 1;
signal PUNTO_RIGHT              : natural := USEG_RIGHT + SZ_char_WIDTH;
constant PUNTO_TOP	            : natural := char_V_LOC + 600 - 1;
constant PUNTO_BOTTOM           : natural := char_V_LOC + 600 + SZ_char_HEIGHT;

-- Decimas
signal DECIMAS_LEFT	            : natural := PUNTO_RIGHT - 1;
signal DECIMAS_RIGHT            : natural := PUNTO_RIGHT + SZ_char_WIDTH;
constant DECIMAS_TOP	        : natural := char_V_LOC + 600 - 1;
constant DECIMAS_BOTTOM         : natural := char_V_LOC + 600 + SZ_char_HEIGHT;

-- Centesimas
signal CENTESIMAS_LEFT          : natural := DECIMAS_RIGHT - 1;
signal CENTESIMAS_RIGHT         : natural := DECIMAS_RIGHT + SZ_char_WIDTH;
constant CENTESIMAS_TOP	        : natural := char_V_LOC + 600 - 1;
constant CENTESIMAS_BOTTOM      : natural := char_V_LOC + 600 + SZ_char_HEIGHT;

-- Señales addr para cada señal
signal addr_uhoras          : std_logic_vector(12 downto 0) := (others=>'0');
signal addr_puntos_horasmin : std_logic_vector(12 downto 0) := (others=>'0');
signal addr_dminutos        : std_logic_vector(12 downto 0) := (others=>'0');
signal addr_uminutos        : std_logic_vector(12 downto 0) := (others=>'0');
signal addr_puntos_minseg   : std_logic_vector(12 downto 0) := (others=>'0');
signal addr_dseg            : std_logic_vector(12 downto 0) := (others=>'0');
signal addr_useg            : std_logic_vector(12 downto 0) := (others=>'0');
signal addr_punto           : std_logic_vector(12 downto 0) := (others=>'0');
signal addr_decimas         : std_logic_vector(12 downto 0) := (others=>'0');
signal addr_centesimas      : std_logic_vector(12 downto 0) := (others=>'0');

-- Señales generales del BRAM
constant TOTAL_RAM_DEPTH : integer :=  (SZ_char_WIDTH*SZ_char_HEIGHT);
signal addr_count        : std_logic_vector(12 downto 0) := (others=>'0');
signal data_count        : std_logic_vector(11 downto 0);
signal data_dummy        : std_logic_vector(0 downto 0);

begin

Inst_50x140_blocks : Cuenta_mem
    PORT MAP(
    clka  =>  CLK_I,
    ena   => '1',
    addra => addr_count,
    douta => data_count
    ); 
    
-- Contadores de los bits contenidos en la memoria

-- Unidades de hora
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_uhoras <= (others=>'0');
     elsif (h_cntr_reg > UHORAS_LEFT and h_cntr_reg < UHORAS_RIGHT 
                          and v_cntr_reg < UHORAS_BOTTOM and v_cntr_reg > UHORAS_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_uhoras = (TOTAL_RAM_DEPTH - 1)) then
        addr_uhoras <= (others=>'0');
      else
        addr_uhoras <= addr_uhoras + 1;
      end if;
    end if;
  end if;
end process;

-- Dos puntos entre horas y minutos
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_puntos_horasmin <= (others=>'0');
     elsif (h_cntr_reg > PUNTOS_HORASMIN_LEFT and h_cntr_reg < PUNTOS_HORASMIN_RIGHT 
                          and v_cntr_reg < PUNTOS_HORASMIN_BOTTOM and v_cntr_reg > PUNTOS_HORASMIN_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_puntos_horasmin = (TOTAL_RAM_DEPTH - 1)) then
        addr_puntos_horasmin <= (others=>'0');
      else
        addr_puntos_horasmin <= addr_puntos_horasmin + 1;
      end if;
    end if;
  end if;
end process;

-- Decenas de minuto
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_dminutos <= (others=>'0');
     elsif (h_cntr_reg > DMINUTOS_LEFT and h_cntr_reg < DMINUTOS_RIGHT 
                          and v_cntr_reg < DMINUTOS_BOTTOM and v_cntr_reg > DMINUTOS_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_dminutos = (TOTAL_RAM_DEPTH - 1)) then
        addr_dminutos <= (others=>'0');
      else
        addr_dminutos <= addr_dminutos + 1;
      end if;
    end if;
  end if;
end process;

-- Unidades de minuto
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_uminutos <= (others=>'0');
     elsif (h_cntr_reg > UMINUTOS_LEFT and h_cntr_reg < UMINUTOS_RIGHT 
                          and v_cntr_reg < UMINUTOS_BOTTOM and v_cntr_reg > UMINUTOS_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_uminutos = (TOTAL_RAM_DEPTH - 1)) then
        addr_uminutos <= (others=>'0');
      else
        addr_uminutos <= addr_uminutos + 1;
      end if;
    end if;
  end if;
end process;

-- Dos puntos entre minutos y segundos
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_puntos_minseg <= (others=>'0');
     elsif (h_cntr_reg > PUNTOS_MINSEG_LEFT and h_cntr_reg < PUNTOS_MINSEG_RIGHT 
                          and v_cntr_reg < PUNTOS_MINSEG_BOTTOM and v_cntr_reg > PUNTOS_MINSEG_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_puntos_minseg = (TOTAL_RAM_DEPTH - 1)) then
        addr_puntos_minseg <= (others=>'0');
      else
        addr_puntos_minseg <= addr_puntos_minseg + 1;
      end if;
    end if;
  end if;
end process;

-- Decenas de segundo
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_dseg <= (others=>'0');
     elsif (h_cntr_reg > DSEG_LEFT and h_cntr_reg < DSEG_RIGHT 
                          and v_cntr_reg < DSEG_BOTTOM and v_cntr_reg > DSEG_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_dseg = (TOTAL_RAM_DEPTH - 1)) then
        addr_dseg <= (others=>'0');
      else
        addr_dseg <= addr_dseg + 1;
      end if;
    end if;
  end if;
end process;

-- Unidades de segundo
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_useg <= (others=>'0');
     elsif (h_cntr_reg > USEG_LEFT and h_cntr_reg < USEG_RIGHT 
                          and v_cntr_reg < USEG_BOTTOM and v_cntr_reg > USEG_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_useg = (TOTAL_RAM_DEPTH - 1)) then
        addr_useg <= (others=>'0');
      else
        addr_useg <= addr_useg + 1;
      end if;
    end if;
  end if;
end process;

-- Punto entre segundos y decimas
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_punto <= (others=>'0');
     elsif (h_cntr_reg > PUNTO_LEFT and h_cntr_reg < PUNTO_RIGHT 
                          and v_cntr_reg < PUNTO_BOTTOM and v_cntr_reg > PUNTO_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_punto = (TOTAL_RAM_DEPTH - 1)) then
        addr_punto <= (others=>'0');
      else
        addr_punto <= addr_punto + 1;
      end if;
    end if;
  end if;
end process;

-- Decimas
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_decimas <= (others=>'0');
     elsif (h_cntr_reg > DECIMAS_LEFT and h_cntr_reg < DECIMAS_RIGHT 
                          and v_cntr_reg < DECIMAS_BOTTOM and v_cntr_reg > DECIMAS_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_decimas = (TOTAL_RAM_DEPTH - 1)) then
        addr_decimas <= (others=>'0');
      else
        addr_decimas <= addr_decimas + 1;
      end if;
    end if;
  end if;
end process;

-- Centesimas
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_centesimas <= (others=>'0');
     elsif (h_cntr_reg > CENTESIMAS_LEFT and h_cntr_reg < CENTESIMAS_RIGHT 
                          and v_cntr_reg < CENTESIMAS_BOTTOM and v_cntr_reg > CENTESIMAS_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_centesimas = (TOTAL_RAM_DEPTH - 1)) then
        addr_centesimas <= (others=>'0');
      else
        addr_centesimas <= addr_centesimas + 1;
      end if;
    end if;
  end if;
end process;

-- Proceso de multiplexado de las cuentas
process(h_cntr_reg, v_cntr_reg, addr_uhoras, addr_dminutos, addr_uminutos,
        addr_dseg, addr_useg, addr_decimas, addr_centesimas,
        addr_puntos_horasmin, addr_puntos_minseg, addr_punto,
        UHORAS_LEFT, UHORAS_RIGHT, DMINUTOS_LEFT, DMINUTOS_RIGHT, UMINUTOS_LEFT, UMINUTOS_RIGHT,
        DSEG_LEFT, DSEG_RIGHT, USEG_LEFT, USEG_RIGHT, DECIMAS_LEFT, DECIMAS_RIGHT, CENTESIMAS_LEFT, CENTESIMAS_RIGHT,
        PUNTOS_HORASMIN_LEFT, PUNTOS_HORASMIN_RIGHT, PUNTOS_MINSEG_LEFT, PUNTOS_MINSEG_RIGHT, PUNTO_LEFT, PUNTO_RIGHT)
begin
    if (h_cntr_reg > UHORAS_LEFT and h_cntr_reg < UHORAS_RIGHT and v_cntr_reg < UHORAS_BOTTOM and v_cntr_reg > UHORAS_TOP) then
        addr_count <= addr_uhoras;
    elsif (h_cntr_reg > DMINUTOS_LEFT and h_cntr_reg < DMINUTOS_RIGHT and v_cntr_reg < DMINUTOS_BOTTOM and v_cntr_reg > DMINUTOS_TOP) then
        addr_count <= addr_dminutos;
    elsif (h_cntr_reg > UMINUTOS_LEFT and h_cntr_reg < UMINUTOS_RIGHT and v_cntr_reg < UMINUTOS_BOTTOM and v_cntr_reg > UMINUTOS_TOP) then
        addr_count <= addr_uminutos;
    elsif (h_cntr_reg > DSEG_LEFT and h_cntr_reg < DSEG_RIGHT and v_cntr_reg < DSEG_BOTTOM and v_cntr_reg > DSEG_TOP) then
        addr_count <= addr_dseg;
    elsif (h_cntr_reg > USEG_LEFT and h_cntr_reg < USEG_RIGHT and v_cntr_reg < USEG_BOTTOM and v_cntr_reg > USEG_TOP) then
        addr_count <= addr_useg;
    elsif (h_cntr_reg > DECIMAS_LEFT and h_cntr_reg < DECIMAS_RIGHT and v_cntr_reg < DECIMAS_BOTTOM and v_cntr_reg > DECIMAS_TOP) then
        addr_count <= addr_decimas;
    elsif (h_cntr_reg > CENTESIMAS_LEFT and h_cntr_reg < CENTESIMAS_RIGHT and v_cntr_reg < CENTESIMAS_BOTTOM and v_cntr_reg > CENTESIMAS_TOP) then
        addr_count <= addr_centesimas;
    elsif (h_cntr_reg > PUNTOS_HORASMIN_LEFT and h_cntr_reg < PUNTOS_HORASMIN_RIGHT and v_cntr_reg < PUNTOS_HORASMIN_BOTTOM and v_cntr_reg > PUNTOS_HORASMIN_TOP) then
        addr_count <= addr_puntos_horasmin;
    elsif (h_cntr_reg > PUNTOS_MINSEG_LEFT and h_cntr_reg < PUNTOS_MINSEG_RIGHT and v_cntr_reg < PUNTOS_MINSEG_BOTTOM and v_cntr_reg > PUNTOS_MINSEG_TOP) then
        addr_count <= addr_puntos_minseg;
    elsif (h_cntr_reg > PUNTO_LEFT and h_cntr_reg < PUNTO_RIGHT and v_cntr_reg < PUNTO_BOTTOM and v_cntr_reg > PUNTO_TOP) then
        addr_count <= addr_punto;
    else
        addr_count <= (others => '0');
    end if;
end process;

-- Carga del dato de la memoria según la ubicación que se esté recorriendo

process(CLK_I)    
begin
    if (rising_edge(CLK_I)) then
    
        -- Pintar los números en la ubicación correspondiente
        if (h_cntr_reg > CENTESIMAS_LEFT and h_cntr_reg < CENTESIMAS_RIGHT and v_cntr_reg > CENTESIMAS_TOP and v_cntr_reg < CENTESIMAS_BOTTOM) then
            data_dummy(0) <= data_count(to_integer(unsigned(CUENTA(3 downto 0))));
        elsif (h_cntr_reg > DECIMAS_LEFT and h_cntr_reg < DECIMAS_RIGHT and v_cntr_reg > DECIMAS_TOP and v_cntr_reg < DECIMAS_BOTTOM) then
            data_dummy(0) <= data_count(to_integer(unsigned(CUENTA(7 downto 4))));
        elsif (h_cntr_reg > USEG_LEFT and h_cntr_reg < USEG_RIGHT and v_cntr_reg > USEG_TOP and v_cntr_reg < USEG_BOTTOM) then
            data_dummy(0) <= data_count(to_integer(unsigned(CUENTA(11 downto 8))));
        elsif (h_cntr_reg > DSEG_LEFT and h_cntr_reg < DSEG_RIGHT and v_cntr_reg > DSEG_TOP and v_cntr_reg < DSEG_BOTTOM) then
            data_dummy(0) <= data_count(to_integer(unsigned(CUENTA(15 downto 12))));
        elsif (h_cntr_reg > UMINUTOS_LEFT and h_cntr_reg < UMINUTOS_RIGHT and v_cntr_reg > UMINUTOS_TOP and v_cntr_reg < UMINUTOS_BOTTOM) then
            data_dummy(0) <= data_count(to_integer(unsigned(CUENTA(19 downto 16))));
        elsif (h_cntr_reg > DMINUTOS_LEFT and h_cntr_reg < DMINUTOS_RIGHT and v_cntr_reg > DMINUTOS_TOP and v_cntr_reg < DMINUTOS_BOTTOM) then
            data_dummy(0) <= data_count(to_integer(unsigned(CUENTA(23 downto 20))));
        elsif (h_cntr_reg > UHORAS_LEFT and h_cntr_reg < UHORAS_RIGHT and v_cntr_reg > UHORAS_TOP and v_cntr_reg < UHORAS_BOTTOM) then
            data_dummy(0) <= data_count(to_integer(unsigned(CUENTA(27 downto 24))));
            
        -- Pintar los símbolos que separan los números
        elsif ((h_cntr_reg > PUNTOS_HORASMIN_LEFT and h_cntr_reg < PUNTOS_HORASMIN_RIGHT and v_cntr_reg < PUNTOS_HORASMIN_BOTTOM and v_cntr_reg > PUNTOS_HORASMIN_TOP) or
        (h_cntr_reg > PUNTOS_MINSEG_LEFT and h_cntr_reg < PUNTOS_MINSEG_RIGHT and v_cntr_reg < PUNTOS_MINSEG_BOTTOM and v_cntr_reg > PUNTOS_MINSEG_TOP)) then
             data_dummy(0) <= data_count(11);
        elsif (h_cntr_reg > PUNTO_LEFT and h_cntr_reg < PUNTO_RIGHT and v_cntr_reg < PUNTO_BOTTOM and v_cntr_reg > PUNTO_TOP) then
            data_dummy(0) <= data_count(10);
        else
            data_dummy(0) <= '0';
        end if;
    end if;    
end process;

-- Assign output
OVERLAY_O <= data_dummy(0);

end Behavioral;

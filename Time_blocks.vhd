----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.03.2026 17:33:51
-- Design Name: 
-- Module Name: Time_blocks - Behavioral
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

entity Time_blocks is
	Generic (char_H_LOC : natural := 200;
	         char_V_LOC : natural := 100);
    Port ( CLK_I        : in  STD_LOGIC;
           VSYNC_I      : in  STD_LOGIC;
           h_cntr_reg   : in std_logic_vector(11 downto 0);
           v_cntr_reg   : in std_logic_vector(11 downto 0);           
--           ACTIVE_I   : in  STD_LOGIC;
           MODO         : in std_logic_vector(1 downto 0);
           TIEMPO       : in std_logic_vector(2 downto 0);
           OVERLAY_O    : out  STD_LOGIC
           );
end Time_blocks;

architecture Behavioral of Time_blocks is

COMPONENT Time_inc_blocks_mem
    PORT (
        clka  : IN STD_LOGIC;
        ena   : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(24 DOWNTO 0)
    );
END COMPONENT;

constant SZ_char_WIDTH  : natural := 160;
constant SZ_char_HEIGHT : natural := 80;  

-- Declaración de las posiciones de cada bloque basados en la posición de referencia (genéricos de entrada)

-----------------------------------------------------------------
--                          TIEMPOS
-----------------------------------------------------------------

-- CLÁSICO
-- Bloque "2h 30m"
constant TCLASICO1_LEFT	    : natural := char_H_LOC + 340 - 1;
constant TCLASICO1_RIGHT    : natural := char_H_LOC + 340 + SZ_char_WIDTH;
constant TCLASICO1_TOP	    : natural := char_V_LOC + 470 - 1;
constant TCLASICO1_BOTTOM   : natural := char_V_LOC + 470 + SZ_char_HEIGHT;

-- Bloque "2h + 1h + 15m"
constant TCLASICO2_LEFT	    : natural := char_H_LOC + 690 - 1;
constant TCLASICO2_RIGHT    : natural := char_H_LOC + 690 + SZ_char_WIDTH;
constant TCLASICO2_TOP	    : natural := char_V_LOC + 470 - 1;
constant TCLASICO2_BOTTOM   : natural := char_V_LOC + 470 + SZ_char_HEIGHT;

-- Bloque "2h + 1h"
constant TCLASICO3_LEFT	    : natural := char_H_LOC + 1015 - 1;
constant TCLASICO3_RIGHT    : natural := char_H_LOC + 1015 + SZ_char_WIDTH;
constant TCLASICO3_TOP	    : natural := char_V_LOC + 470 - 1;
constant TCLASICO3_BOTTOM   : natural := char_V_LOC + 470 + SZ_char_HEIGHT;

-- Bloque "1h 30m"
constant TCLASICO4_LEFT	    : natural := char_H_LOC + 1350 - 1;
constant TCLASICO4_RIGHT    : natural := char_H_LOC + 1350 + SZ_char_WIDTH;
constant TCLASICO4_TOP	    : natural := char_V_LOC + 470 - 1;
constant TCLASICO4_BOTTOM   : natural := char_V_LOC + 470 + SZ_char_HEIGHT;

-- RÁPIDO
-- Bloque "60m"
constant TRAPIDO1_LEFT	    : natural := char_H_LOC + 360 - 1;
constant TRAPIDO1_RIGHT     : natural := char_H_LOC + 360 + SZ_char_WIDTH;
constant TRAPIDO1_TOP	    : natural := char_V_LOC + 470 - 1;
constant TRAPIDO1_BOTTOM    : natural := char_V_LOC + 470 + SZ_char_HEIGHT;

-- Bloque "50m"
constant TRAPIDO2_LEFT	    : natural := char_H_LOC + 560 - 1;
constant TRAPIDO2_RIGHT     : natural := char_H_LOC + 560 + SZ_char_WIDTH;
constant TRAPIDO2_TOP	    : natural := char_V_LOC + 470 - 1;
constant TRAPIDO2_BOTTOM    : natural := char_V_LOC + 470 + SZ_char_HEIGHT;

-- Bloque "40m"
constant TRAPIDO3_LEFT	    : natural := char_H_LOC + 760 - 1;
constant TRAPIDO3_RIGHT     : natural := char_H_LOC + 760 + SZ_char_WIDTH;
constant TRAPIDO3_TOP	    : natural := char_V_LOC + 470 - 1;
constant TRAPIDO3_BOTTOM    : natural := char_V_LOC + 470 + SZ_char_HEIGHT;

-- Bloque "30m"
constant TRAPIDO4_LEFT	    : natural := char_H_LOC + 960 - 1;
constant TRAPIDO4_RIGHT     : natural := char_H_LOC + 960 + SZ_char_WIDTH;
constant TRAPIDO4_TOP	    : natural := char_V_LOC + 470 - 1;
constant TRAPIDO4_BOTTOM    : natural := char_V_LOC + 470 + SZ_char_HEIGHT;

-- Bloque "20m"
constant TRAPIDO5_LEFT	    : natural := char_H_LOC + 1160 - 1;
constant TRAPIDO5_RIGHT     : natural := char_H_LOC + 1160 + SZ_char_WIDTH;
constant TRAPIDO5_TOP	    : natural := char_V_LOC + 470 - 1;
constant TRAPIDO5_BOTTOM    : natural := char_V_LOC + 470 + SZ_char_HEIGHT;

-- Bloque "10m"
constant TRAPIDO6_LEFT	    : natural := char_H_LOC + 1360 - 1;
constant TRAPIDO6_RIGHT     : natural := char_H_LOC + 1360 + SZ_char_WIDTH;
constant TRAPIDO6_TOP	    : natural := char_V_LOC + 470 - 1;
constant TRAPIDO6_BOTTOM    : natural := char_V_LOC + 470 + SZ_char_HEIGHT;

-- RELÁMPAGO
-- Bloque "10m"
constant TRELAMPAGO1_LEFT   : natural := char_H_LOC + 340 - 1;
constant TRELAMPAGO1_RIGHT  : natural := char_H_LOC + 340 + SZ_char_WIDTH;
constant TRELAMPAGO1_TOP	: natural := char_V_LOC + 470 - 1;
constant TRELAMPAGO1_BOTTOM : natural := char_V_LOC + 470 + SZ_char_HEIGHT;

-- Bloque "8m"
constant TRELAMPAGO2_LEFT   : natural := char_H_LOC + 690 - 1;
constant TRELAMPAGO2_RIGHT  : natural := char_H_LOC + 690 + SZ_char_WIDTH;
constant TRELAMPAGO2_TOP	: natural := char_V_LOC + 470 - 1;
constant TRELAMPAGO2_BOTTOM : natural := char_V_LOC + 470 + SZ_char_HEIGHT;

-- Bloque "5m"
constant TRELAMPAGO3_LEFT   : natural := char_H_LOC + 1015 - 1;
constant TRELAMPAGO3_RIGHT  : natural := char_H_LOC + 1015 + SZ_char_WIDTH;
constant TRELAMPAGO3_TOP	: natural := char_V_LOC + 470 - 1;
constant TRELAMPAGO3_BOTTOM : natural := char_V_LOC + 470 + SZ_char_HEIGHT;

-- Bloque "3m"
constant TRELAMPAGO4_LEFT   : natural := char_H_LOC + 1350 - 1;
constant TRELAMPAGO4_RIGHT  : natural := char_H_LOC + 1350 + SZ_char_WIDTH;
constant TRELAMPAGO4_TOP	: natural := char_V_LOC + 470 - 1;
constant TRELAMPAGO4_BOTTOM : natural := char_V_LOC + 470 + SZ_char_HEIGHT;

-- BALA
-- Bloque "2m"
constant TBALA1_LEFT        : natural := char_H_LOC + 510 - 1;
constant TBALA1_RIGHT       : natural := char_H_LOC + 510 + SZ_char_WIDTH;
constant TBALA1_TOP	        : natural := char_V_LOC + 470 - 1;
constant TBALA1_BOTTOM      : natural := char_V_LOC + 470 + SZ_char_HEIGHT;

-- Bloque "1m"
constant TBALA2_LEFT        : natural := char_H_LOC + 1110 - 1;
constant TBALA2_RIGHT       : natural := char_H_LOC + 1110 + SZ_char_WIDTH;
constant TBALA2_TOP	        : natural := char_V_LOC + 470 - 1;
constant TBALA2_BOTTOM      : natural := char_V_LOC + 470 + SZ_char_HEIGHT;

-----------------------------------------------------------------
--                        INCREMENTOS
-----------------------------------------------------------------

-- CLÁSICO
-- Bloque "Estandar"
constant ICLASICO1_LEFT	    : natural := char_H_LOC + 810 - 1;
constant ICLASICO1_RIGHT    : natural := char_H_LOC + 810 + SZ_char_WIDTH;
constant ICLASICO1_TOP	    : natural := char_V_LOC + 710 - 1;
constant ICLASICO1_BOTTOM   : natural := char_V_LOC + 710 + SZ_char_HEIGHT;

-- RÁPIDO
-- Bloque "30s"
constant IRAPIDO1_LEFT	    : natural := char_H_LOC + 340 - 1;
constant IRAPIDO1_RIGHT     : natural := char_H_LOC + 340 + SZ_char_WIDTH;
constant IRAPIDO1_TOP	    : natural := char_V_LOC + 710 - 1;
constant IRAPIDO1_BOTTOM    : natural := char_V_LOC + 710 + SZ_char_HEIGHT;

-- Bloque "20s"
constant IRAPIDO2_LEFT	    : natural := char_H_LOC + 690 - 1;
constant IRAPIDO2_RIGHT     : natural := char_H_LOC + 690 + SZ_char_WIDTH;
constant IRAPIDO2_TOP	    : natural := char_V_LOC + 710 - 1;
constant IRAPIDO2_BOTTOM    : natural := char_V_LOC + 710 + SZ_char_HEIGHT;

-- Bloque "15s"
constant IRAPIDO3_LEFT	    : natural := char_H_LOC + 1015 - 1;
constant IRAPIDO3_RIGHT     : natural := char_H_LOC + 1015 + SZ_char_WIDTH;
constant IRAPIDO3_TOP	    : natural := char_V_LOC + 710 - 1;
constant IRAPIDO3_BOTTOM    : natural := char_V_LOC + 710 + SZ_char_HEIGHT;

-- Bloque "10s"
constant IRAPIDO4_LEFT	    : natural := char_H_LOC + 1350 - 1;
constant IRAPIDO4_RIGHT     : natural := char_H_LOC + 1350 + SZ_char_WIDTH;
constant IRAPIDO4_TOP	    : natural := char_V_LOC + 710 - 1;
constant IRAPIDO4_BOTTOM    : natural := char_V_LOC + 710 + SZ_char_HEIGHT;

-- RELÁMPAGO
-- Bloque "5s"
constant IRELAMPAGO1_LEFT   : natural := char_H_LOC + 340 - 1;
constant IRELAMPAGO1_RIGHT  : natural := char_H_LOC + 340 + SZ_char_WIDTH;
constant IRELAMPAGO1_TOP	: natural := char_V_LOC + 710 - 1;
constant IRELAMPAGO1_BOTTOM : natural := char_V_LOC + 710 + SZ_char_HEIGHT;

-- Bloque "4s"
constant IRELAMPAGO2_LEFT   : natural := char_H_LOC + 690 - 1;
constant IRELAMPAGO2_RIGHT  : natural := char_H_LOC + 690 + SZ_char_WIDTH;
constant IRELAMPAGO2_TOP	: natural := char_V_LOC + 710 - 1;
constant IRELAMPAGO2_BOTTOM : natural := char_V_LOC + 710 + SZ_char_HEIGHT;

-- Bloque "3s"
constant IRELAMPAGO3_LEFT   : natural := char_H_LOC + 1015 - 1;
constant IRELAMPAGO3_RIGHT  : natural := char_H_LOC + 1015 + SZ_char_WIDTH;
constant IRELAMPAGO3_TOP	: natural := char_V_LOC + 710 - 1;
constant IRELAMPAGO3_BOTTOM : natural := char_V_LOC + 710 + SZ_char_HEIGHT;

-- Bloque "2s"
constant IRELAMPAGO4_LEFT   : natural := char_H_LOC + 1350 - 1;
constant IRELAMPAGO4_RIGHT  : natural := char_H_LOC + 1350 + SZ_char_WIDTH;
constant IRELAMPAGO4_TOP	: natural := char_V_LOC + 710 - 1;
constant IRELAMPAGO4_BOTTOM : natural := char_V_LOC + 710 + SZ_char_HEIGHT;

-- BALA
-- Bloque "Estandar"
constant IBALA1_LEFT        : natural := char_H_LOC + 810 - 1;
constant IBALA1_RIGHT       : natural := char_H_LOC + 810 + SZ_char_WIDTH;
constant IBALA1_TOP	        : natural := char_V_LOC + 710 - 1;
constant IBALA1_BOTTOM      : natural := char_V_LOC + 710 + SZ_char_HEIGHT;

-- Señales addr para cada señal
-----------------------------------------------------------------
--                          TIEMPOS
-----------------------------------------------------------------
signal addr_tclasico1   : std_logic_vector(13 downto 0) := (others=>'0');
signal addr_tclasico2   : std_logic_vector(13 downto 0) := (others=>'0');
signal addr_tclasico3   : std_logic_vector(13 downto 0) := (others=>'0');
signal addr_tclasico4   : std_logic_vector(13 downto 0) := (others=>'0');

signal addr_trapido1    : std_logic_vector(13 downto 0) := (others=>'0');
signal addr_trapido2    : std_logic_vector(13 downto 0) := (others=>'0');
signal addr_trapido3    : std_logic_vector(13 downto 0) := (others=>'0');
signal addr_trapido4    : std_logic_vector(13 downto 0) := (others=>'0');
signal addr_trapido5    : std_logic_vector(13 downto 0) := (others=>'0');
signal addr_trapido6    : std_logic_vector(13 downto 0) := (others=>'0');

signal addr_trelampago1 : std_logic_vector(13 downto 0) := (others=>'0');
signal addr_trelampago2 : std_logic_vector(13 downto 0) := (others=>'0');
signal addr_trelampago3 : std_logic_vector(13 downto 0) := (others=>'0');
signal addr_trelampago4 : std_logic_vector(13 downto 0) := (others=>'0');

signal addr_tbala1      : std_logic_vector(13 downto 0) := (others=>'0');
signal addr_tbala2      : std_logic_vector(13 downto 0) := (others=>'0');

-----------------------------------------------------------------
--                        INCREMENTOS
-----------------------------------------------------------------
signal addr_iclasico1   : std_logic_vector(13 downto 0) := (others=>'0');

signal addr_irapido1    : std_logic_vector(13 downto 0) := (others=>'0');
signal addr_irapido2    : std_logic_vector(13 downto 0) := (others=>'0');
signal addr_irapido3    : std_logic_vector(13 downto 0) := (others=>'0');
signal addr_irapido4    : std_logic_vector(13 downto 0) := (others=>'0');

signal addr_irelampago1 : std_logic_vector(13 downto 0) := (others=>'0');
signal addr_irelampago2 : std_logic_vector(13 downto 0) := (others=>'0');
signal addr_irelampago3 : std_logic_vector(13 downto 0) := (others=>'0');
signal addr_irelampago4 : std_logic_vector(13 downto 0) := (others=>'0');

signal addr_ibala1      : std_logic_vector(13 downto 0) := (others=>'0');

constant TOTAL_RAM_DEPTH : integer :=  (SZ_char_WIDTH*SZ_char_HEIGHT);
signal addr_time_inc : std_logic_vector(13 downto 0) := (others=>'0');
signal data_time_inc : std_logic_vector(24 downto 0);
signal data_dummy : std_logic_vector(0 downto 0);

begin

Inst_160x80_blocks : Time_inc_blocks_mem
    PORT MAP(
    clka  =>  CLK_I,
    ena   => '1',
    addra => addr_time_inc,
    douta => data_time_inc
    );
    
-- Contadores de los bits contenidos en la memoria

-----------------------------------------------------------------
--                          TIEMPOS
-----------------------------------------------------------------

-- Clasico 1 (2h 30m)
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_tclasico1 <= (others=>'0');
     elsif MODO = "00" and (h_cntr_reg > TCLASICO1_LEFT and h_cntr_reg < TCLASICO1_RIGHT 
                          and v_cntr_reg < TCLASICO1_BOTTOM and v_cntr_reg > TCLASICO1_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_tclasico1 = (TOTAL_RAM_DEPTH - 1)) then
        addr_tclasico1 <= (others=>'0');
      else
        addr_tclasico1 <= addr_tclasico1 + 1;
      end if;
    end if;
  end if;
end process; 
 
-- Clasico 2 (2h + 1h + 15m)
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_tclasico2 <= (others=>'0');
     elsif MODO = "00" and (h_cntr_reg > TCLASICO2_LEFT and h_cntr_reg < TCLASICO2_RIGHT 
                          and v_cntr_reg < TCLASICO2_BOTTOM and v_cntr_reg > TCLASICO2_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_tclasico2 = (TOTAL_RAM_DEPTH - 1)) then
        addr_tclasico2 <= (others=>'0');
      else
        addr_tclasico2 <= addr_tclasico2 + 1;
      end if;
    end if;
  end if;
end process; 
 
-- Clasico 3 (2h + 1h)
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_tclasico3 <= (others=>'0');
     elsif MODO = "00" and (h_cntr_reg > TCLASICO3_LEFT and h_cntr_reg < TCLASICO3_RIGHT 
                          and v_cntr_reg < TCLASICO3_BOTTOM and v_cntr_reg > TCLASICO3_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_tclasico3 = (TOTAL_RAM_DEPTH - 1)) then
        addr_tclasico3 <= (others=>'0');
      else
        addr_tclasico3 <= addr_tclasico3 + 1;
      end if;
    end if;
  end if;
end process; 
 
-- Clasico 4 (1h 30m)
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_tclasico4 <= (others=>'0');
     elsif MODO = "00" and (h_cntr_reg > TCLASICO4_LEFT and h_cntr_reg < TCLASICO4_RIGHT 
                          and v_cntr_reg < TCLASICO4_BOTTOM and v_cntr_reg > TCLASICO4_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_tclasico4 = (TOTAL_RAM_DEPTH - 1)) then
        addr_tclasico4 <= (others=>'0');
      else
        addr_tclasico4 <= addr_tclasico4 + 1;
      end if;
    end if;
  end if;
end process;

-- Rápido 1 (60m)
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_trapido1 <= (others=>'0');
     elsif MODO = "01" and (h_cntr_reg > TRAPIDO1_LEFT and h_cntr_reg < TRAPIDO1_RIGHT 
                          and v_cntr_reg < TRAPIDO1_BOTTOM and v_cntr_reg > TRAPIDO1_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_trapido1 = (TOTAL_RAM_DEPTH - 1)) then
        addr_trapido1 <= (others=>'0');
      else
        addr_trapido1 <= addr_trapido1 + 1;
      end if;
    end if;
  end if;
end process; 
 
-- Rápido 2 (50m)
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_trapido2 <= (others=>'0');
     elsif MODO = "01" and (h_cntr_reg > TRAPIDO2_LEFT and h_cntr_reg < TRAPIDO2_RIGHT 
                          and v_cntr_reg < TRAPIDO2_BOTTOM and v_cntr_reg > TRAPIDO2_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_trapido2 = (TOTAL_RAM_DEPTH - 1)) then
        addr_trapido2 <= (others=>'0');
      else
        addr_trapido2 <= addr_trapido2 + 1;
      end if;
    end if;
  end if;
end process; 
 
-- Rápido 3 (40m)
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_trapido3 <= (others=>'0');
     elsif MODO = "01" and (h_cntr_reg > TRAPIDO3_LEFT and h_cntr_reg < TRAPIDO3_RIGHT 
                          and v_cntr_reg < TRAPIDO3_BOTTOM and v_cntr_reg > TRAPIDO3_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_trapido3 = (TOTAL_RAM_DEPTH - 1)) then
        addr_trapido3 <= (others=>'0');
      else
        addr_trapido3 <= addr_trapido3 + 1;
      end if;
    end if;
  end if;
end process; 
 
-- Rápido 4 (30m)
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_trapido4 <= (others=>'0');
     elsif MODO = "01" and (h_cntr_reg > TRAPIDO4_LEFT and h_cntr_reg < TRAPIDO4_RIGHT 
                          and v_cntr_reg < TRAPIDO4_BOTTOM and v_cntr_reg > TRAPIDO4_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_trapido4 = (TOTAL_RAM_DEPTH - 1)) then
        addr_trapido4 <= (others=>'0');
      else
        addr_trapido4 <= addr_trapido4 + 1;
      end if;
    end if;
  end if;
end process;
 
-- Rápido 5 (20m)
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_trapido5 <= (others=>'0');
     elsif MODO = "01" and (h_cntr_reg > TRAPIDO5_LEFT and h_cntr_reg < TRAPIDO5_RIGHT 
                          and v_cntr_reg < TRAPIDO5_BOTTOM and v_cntr_reg > TRAPIDO5_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_trapido5 = (TOTAL_RAM_DEPTH - 1)) then
        addr_trapido5 <= (others=>'0');
      else
        addr_trapido5 <= addr_trapido5 + 1;
      end if;
    end if;
  end if;
end process;
 
-- Rápido 6 (10m)
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_trapido6 <= (others=>'0');
     elsif MODO = "01" and (h_cntr_reg > TRAPIDO6_LEFT and h_cntr_reg < TRAPIDO6_RIGHT 
                          and v_cntr_reg < TRAPIDO6_BOTTOM and v_cntr_reg > TRAPIDO6_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_trapido6 = (TOTAL_RAM_DEPTH - 1)) then
        addr_trapido6 <= (others=>'0');
      else
        addr_trapido6 <= addr_trapido6 + 1;
      end if;
    end if;
  end if;
end process;

-- Relámpago 1 (10m)
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_trelampago1 <= (others=>'0');
     elsif MODO = "10" and (h_cntr_reg > TRELAMPAGO1_LEFT and h_cntr_reg < TRELAMPAGO1_RIGHT 
                          and v_cntr_reg < TRELAMPAGO1_BOTTOM and v_cntr_reg > TRELAMPAGO1_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_trelampago1 = (TOTAL_RAM_DEPTH - 1)) then
        addr_trelampago1 <= (others=>'0');
      else
        addr_trelampago1 <= addr_trelampago1 + 1;
      end if;
    end if;
  end if;
end process; 
 
-- Relámpago 2 (8m)
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_trelampago2 <= (others=>'0');
     elsif MODO = "10" and (h_cntr_reg > TRELAMPAGO2_LEFT and h_cntr_reg < TRELAMPAGO2_RIGHT 
                          and v_cntr_reg < TRELAMPAGO2_BOTTOM and v_cntr_reg > TRELAMPAGO2_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_trelampago2 = (TOTAL_RAM_DEPTH - 1)) then
        addr_trelampago2 <= (others=>'0');
      else
        addr_trelampago2 <= addr_trelampago2 + 1;
      end if;
    end if;
  end if;
end process; 
 
-- Relámpago 3 (5m)
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_trelampago3 <= (others=>'0');
     elsif MODO = "10" and (h_cntr_reg > TRELAMPAGO3_LEFT and h_cntr_reg < TRELAMPAGO3_RIGHT 
                          and v_cntr_reg < TRELAMPAGO3_BOTTOM and v_cntr_reg > TRELAMPAGO3_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_trelampago3 = (TOTAL_RAM_DEPTH - 1)) then
        addr_trelampago3 <= (others=>'0');
      else
        addr_trelampago3 <= addr_trelampago3 + 1;
      end if;
    end if;
  end if;
end process; 
 
-- Relámpago 4 (3m)
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_trelampago4 <= (others=>'0');
     elsif MODO = "10" and (h_cntr_reg > TRELAMPAGO4_LEFT and h_cntr_reg < TRELAMPAGO4_RIGHT 
                          and v_cntr_reg < TRELAMPAGO4_BOTTOM and v_cntr_reg > TRELAMPAGO4_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_trelampago4 = (TOTAL_RAM_DEPTH - 1)) then
        addr_trelampago4 <= (others=>'0');
      else
        addr_trelampago4 <= addr_trelampago4 + 1;
      end if;
    end if;
  end if;
end process;

-- Bala 1 (2m)
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_tbala1 <= (others=>'0');
     elsif MODO = "11" and (h_cntr_reg > TBALA1_LEFT and h_cntr_reg < TBALA1_RIGHT 
                          and v_cntr_reg < TBALA1_BOTTOM and v_cntr_reg > TBALA1_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_tbala1 = (TOTAL_RAM_DEPTH - 1)) then
        addr_tbala1 <= (others=>'0');
      else
        addr_tbala1 <= addr_tbala1 + 1;
      end if;
    end if;
  end if;
end process; 
 
-- Bala 2 (1m)
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_tbala2 <= (others=>'0');
     elsif MODO = "11" and (h_cntr_reg > TBALA2_LEFT and h_cntr_reg < TBALA2_RIGHT 
                          and v_cntr_reg < TBALA2_BOTTOM and v_cntr_reg > TBALA2_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_tbala2 = (TOTAL_RAM_DEPTH - 1)) then
        addr_tbala2 <= (others=>'0');
      else
        addr_tbala2 <= addr_tbala2 + 1;
      end if;
    end if;
  end if;
end process;

-----------------------------------------------------------------
--                        INCREMENTOS
-----------------------------------------------------------------

-- Clásico 1 (Estandar)
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_iclasico1 <= (others=>'0');
     elsif (MODO = "00" or MODO = "11" or ((MODO = "01" or MODO = "10") and TIEMPO = "000")) and 
                            (h_cntr_reg > ICLASICO1_LEFT and h_cntr_reg < ICLASICO1_RIGHT 
                          and v_cntr_reg < ICLASICO1_BOTTOM and v_cntr_reg > ICLASICO1_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_iclasico1 = (TOTAL_RAM_DEPTH - 1)) then
        addr_iclasico1 <= (others=>'0');
      else
        addr_iclasico1 <= addr_iclasico1 + 1;
      end if;
    end if;
  end if;
end process;

-- Rápido 1 (30s)
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_irapido1 <= (others=>'0');
     elsif MODO = "01" and (h_cntr_reg > IRAPIDO1_LEFT and h_cntr_reg < IRAPIDO1_RIGHT 
                          and v_cntr_reg < IRAPIDO1_BOTTOM and v_cntr_reg > IRAPIDO1_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_irapido1 = (TOTAL_RAM_DEPTH - 1)) then
        addr_irapido1 <= (others=>'0');
      else
        addr_irapido1 <= addr_irapido1 + 1;
      end if;
    end if;
  end if;
end process;

-- Rápido 2 (20s)
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_irapido2 <= (others=>'0');
     elsif MODO = "01" and (h_cntr_reg > IRAPIDO2_LEFT and h_cntr_reg < IRAPIDO2_RIGHT 
                          and v_cntr_reg < IRAPIDO2_BOTTOM and v_cntr_reg > IRAPIDO2_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_irapido2 = (TOTAL_RAM_DEPTH - 1)) then
        addr_irapido2 <= (others=>'0');
      else
        addr_irapido2 <= addr_irapido2 + 1;
      end if;
    end if;
  end if;
end process;

-- Rápido 3 (15s)
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_irapido3 <= (others=>'0');
     elsif MODO = "01" and (h_cntr_reg > IRAPIDO3_LEFT and h_cntr_reg < IRAPIDO3_RIGHT 
                          and v_cntr_reg < IRAPIDO3_BOTTOM and v_cntr_reg > IRAPIDO3_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_irapido3 = (TOTAL_RAM_DEPTH - 1)) then
        addr_irapido3 <= (others=>'0');
      else
        addr_irapido3 <= addr_irapido3 + 1;
      end if;
    end if;
  end if;
end process;

-- Rápido 4 (10s)
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_irapido4 <= (others=>'0');
     elsif MODO = "01" and (h_cntr_reg > IRAPIDO4_LEFT and h_cntr_reg < IRAPIDO4_RIGHT 
                          and v_cntr_reg < IRAPIDO4_BOTTOM and v_cntr_reg > IRAPIDO4_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_irapido4 = (TOTAL_RAM_DEPTH - 1)) then
        addr_irapido4 <= (others=>'0');
      else
        addr_irapido4 <= addr_irapido4 + 1;
      end if;
    end if;
  end if;
end process;

-- Relámpago 1 (5s)
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_irelampago1 <= (others=>'0');
     elsif MODO = "10" and (h_cntr_reg > IRELAMPAGO1_LEFT and h_cntr_reg < IRELAMPAGO1_RIGHT 
                          and v_cntr_reg < IRELAMPAGO1_BOTTOM and v_cntr_reg > IRELAMPAGO1_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_irelampago1 = (TOTAL_RAM_DEPTH - 1)) then
        addr_irelampago1 <= (others=>'0');
      else
        addr_irelampago1 <= addr_irelampago1 + 1;
      end if;
    end if;
  end if;
end process;

-- Relámpago 2 (4s)
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_irelampago2 <= (others=>'0');
     elsif MODO = "10" and (h_cntr_reg > IRELAMPAGO2_LEFT and h_cntr_reg < IRELAMPAGO2_RIGHT 
                          and v_cntr_reg < IRELAMPAGO2_BOTTOM and v_cntr_reg > IRELAMPAGO2_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_irelampago2 = (TOTAL_RAM_DEPTH - 1)) then
        addr_irelampago2 <= (others=>'0');
      else
        addr_irelampago2 <= addr_irelampago2 + 1;
      end if;
    end if;
  end if;
end process;

-- Relámpago 3 (3s)
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_irelampago3 <= (others=>'0');
     elsif MODO = "10" and (h_cntr_reg > IRELAMPAGO3_LEFT and h_cntr_reg < IRELAMPAGO3_RIGHT 
                          and v_cntr_reg < IRELAMPAGO3_BOTTOM and v_cntr_reg > IRELAMPAGO3_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_irelampago3 = (TOTAL_RAM_DEPTH - 1)) then
        addr_irelampago3 <= (others=>'0');
      else
        addr_irelampago3 <= addr_irelampago3 + 1;
      end if;
    end if;
  end if;
end process;

-- Relámpago 4 (2s)
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_irelampago4 <= (others=>'0');
     elsif MODO = "10" and (h_cntr_reg > IRELAMPAGO4_LEFT and h_cntr_reg < IRELAMPAGO4_RIGHT 
                          and v_cntr_reg < IRELAMPAGO4_BOTTOM and v_cntr_reg > IRELAMPAGO4_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_irelampago4 = (TOTAL_RAM_DEPTH - 1)) then
        addr_irelampago4 <= (others=>'0');
      else
        addr_irelampago4 <= addr_irelampago4 + 1;
      end if;
    end if;
  end if;
end process;   

-- Proceso de multiplexado de las cuentas
process(
        h_cntr_reg, v_cntr_reg, MODO, TIEMPO,
        addr_tclasico1, addr_tclasico2, addr_tclasico3, addr_tclasico4,
        addr_trapido1, addr_trapido2, addr_trapido3, addr_trapido4, addr_trapido5, addr_trapido6,
        addr_trelampago1, addr_trelampago2, addr_trelampago3, addr_trelampago4,
        addr_tbala1, addr_tbala2,
        addr_iclasico1, addr_irapido1, addr_irapido2, addr_irapido3, addr_irapido4,
        addr_irelampago1, addr_irelampago2, addr_irelampago3, addr_irelampago4,
        addr_ibala1
        )
begin
    addr_time_inc <= (others => '0');
    
    case MODO is
        when "00" =>
            
        -----------------------------------------------------------------
        --                          TIEMPOS
        -----------------------------------------------------------------    
            if (h_cntr_reg > TCLASICO1_LEFT and h_cntr_reg < TCLASICO1_RIGHT and v_cntr_reg > TCLASICO1_TOP and v_cntr_reg < TCLASICO1_BOTTOM) then
                addr_time_inc <= addr_tclasico1;
            elsif (h_cntr_reg > TCLASICO2_LEFT and h_cntr_reg < TCLASICO2_RIGHT and v_cntr_reg > TCLASICO2_TOP and v_cntr_reg < TCLASICO2_BOTTOM) then
                addr_time_inc <= addr_tclasico2;
            elsif (h_cntr_reg > TCLASICO3_LEFT and h_cntr_reg < TCLASICO3_RIGHT and v_cntr_reg > TCLASICO3_TOP and v_cntr_reg < TCLASICO3_BOTTOM) then
                addr_time_inc <= addr_tclasico3;
            elsif (h_cntr_reg > TCLASICO4_LEFT and h_cntr_reg < TCLASICO4_RIGHT and v_cntr_reg > TCLASICO4_TOP and v_cntr_reg < TCLASICO4_BOTTOM) then
                addr_time_inc <= addr_tclasico4;
            end if;
            
        -----------------------------------------------------------------
        --                        INCREMENTOS
        -----------------------------------------------------------------
            if (h_cntr_reg > ICLASICO1_LEFT and h_cntr_reg < ICLASICO1_RIGHT and v_cntr_reg > ICLASICO1_TOP and v_cntr_reg < ICLASICO1_BOTTOM) then
                addr_time_inc <= addr_iclasico1;
            end if;
        
        when "01" =>
            
        -----------------------------------------------------------------
        --                          TIEMPOS
        -----------------------------------------------------------------      
            if (h_cntr_reg > TRAPIDO1_LEFT and h_cntr_reg < TRAPIDO1_RIGHT and v_cntr_reg > TRAPIDO1_TOP and v_cntr_reg < TRAPIDO1_BOTTOM) then
                addr_time_inc <= addr_trapido1;
            elsif (h_cntr_reg > TRAPIDO2_LEFT and h_cntr_reg < TRAPIDO2_RIGHT and v_cntr_reg > TRAPIDO2_TOP and v_cntr_reg < TRAPIDO2_BOTTOM) then
                addr_time_inc <= addr_trapido2;
            elsif (h_cntr_reg > TRAPIDO3_LEFT and h_cntr_reg < TRAPIDO3_RIGHT and v_cntr_reg > TRAPIDO3_TOP and v_cntr_reg < TRAPIDO3_BOTTOM) then
                addr_time_inc <= addr_trapido3;
            elsif (h_cntr_reg > TRAPIDO4_LEFT and h_cntr_reg < TRAPIDO4_RIGHT and v_cntr_reg > TRAPIDO4_TOP and v_cntr_reg < TRAPIDO4_BOTTOM) then
                addr_time_inc <= addr_trapido4;
            elsif (h_cntr_reg > TRAPIDO5_LEFT and h_cntr_reg < TRAPIDO5_RIGHT and v_cntr_reg > TRAPIDO5_TOP and v_cntr_reg < TRAPIDO5_BOTTOM) then
                addr_time_inc <= addr_trapido5;
            elsif (h_cntr_reg > TRAPIDO6_LEFT and h_cntr_reg < TRAPIDO6_RIGHT and v_cntr_reg > TRAPIDO6_TOP and v_cntr_reg < TRAPIDO6_BOTTOM) then
                addr_time_inc <= addr_trapido6;
            end if;
            
        -----------------------------------------------------------------
        --                        INCREMENTOS
        -----------------------------------------------------------------  
            if TIEMPO = "000" then 
                if (h_cntr_reg > ICLASICO1_LEFT and h_cntr_reg < ICLASICO1_RIGHT and v_cntr_reg > ICLASICO1_TOP and v_cntr_reg < ICLASICO1_BOTTOM) then
                    addr_time_inc <= addr_iclasico1;
                end if;
            else
                if (h_cntr_reg > IRAPIDO1_LEFT and h_cntr_reg < IRAPIDO1_RIGHT and v_cntr_reg > IRAPIDO1_TOP and v_cntr_reg < IRAPIDO1_BOTTOM) then
                    addr_time_inc <= addr_irapido1;
                elsif (h_cntr_reg > IRAPIDO2_LEFT and h_cntr_reg < IRAPIDO2_RIGHT and v_cntr_reg > IRAPIDO2_TOP and v_cntr_reg < IRAPIDO2_BOTTOM) then
                    addr_time_inc <= addr_irapido2;
                elsif (h_cntr_reg > IRAPIDO3_LEFT and h_cntr_reg < IRAPIDO3_RIGHT and v_cntr_reg > IRAPIDO3_TOP and v_cntr_reg < IRAPIDO3_BOTTOM) then
                    addr_time_inc <= addr_irapido3;
                elsif (h_cntr_reg > IRAPIDO4_LEFT and h_cntr_reg < IRAPIDO4_RIGHT and v_cntr_reg > IRAPIDO4_TOP and v_cntr_reg < IRAPIDO4_BOTTOM) then
                    addr_time_inc <= addr_irapido4;
                end if;
            end if;
            
        when "10" =>
            
        -----------------------------------------------------------------
        --                          TIEMPOS
        -----------------------------------------------------------------       
            if (h_cntr_reg > TRELAMPAGO1_LEFT and h_cntr_reg < TRELAMPAGO1_RIGHT and v_cntr_reg > TRELAMPAGO1_TOP and v_cntr_reg < TRELAMPAGO1_BOTTOM) then
                addr_time_inc <= addr_trelampago1;
            elsif (h_cntr_reg > TRELAMPAGO2_LEFT and h_cntr_reg < TRELAMPAGO2_RIGHT and v_cntr_reg > TRELAMPAGO2_TOP and v_cntr_reg < TRELAMPAGO2_BOTTOM) then
                addr_time_inc <= addr_trelampago2;
            elsif (h_cntr_reg > TRELAMPAGO3_LEFT and h_cntr_reg < TRELAMPAGO3_RIGHT and v_cntr_reg > TRELAMPAGO3_TOP and v_cntr_reg < TRELAMPAGO3_BOTTOM) then
                addr_time_inc <= addr_trelampago3;
            elsif (h_cntr_reg > TRELAMPAGO4_LEFT and h_cntr_reg < TRELAMPAGO4_RIGHT and v_cntr_reg > TRELAMPAGO4_TOP and v_cntr_reg < TRELAMPAGO4_BOTTOM) then
                addr_time_inc <= addr_trelampago4;
            end if;
            
        -----------------------------------------------------------------
        --                        INCREMENTOS
        -----------------------------------------------------------------  
            if TIEMPO = "000" then
                if (h_cntr_reg > ICLASICO1_LEFT and h_cntr_reg < ICLASICO1_RIGHT and v_cntr_reg > ICLASICO1_TOP and v_cntr_reg < ICLASICO1_BOTTOM) then
                    addr_time_inc <= addr_iclasico1;
                end if;
            else                      
                if (h_cntr_reg > IRELAMPAGO1_LEFT and h_cntr_reg < IRELAMPAGO1_RIGHT and v_cntr_reg > IRELAMPAGO1_TOP and v_cntr_reg < IRELAMPAGO1_BOTTOM) then
                    addr_time_inc <= addr_irelampago1;
                elsif (h_cntr_reg > IRELAMPAGO2_LEFT and h_cntr_reg < IRELAMPAGO2_RIGHT and v_cntr_reg > IRELAMPAGO2_TOP and v_cntr_reg < IRELAMPAGO2_BOTTOM) then
                    addr_time_inc <= addr_irelampago2;
                elsif (h_cntr_reg > IRELAMPAGO3_LEFT and h_cntr_reg < IRELAMPAGO3_RIGHT and v_cntr_reg > IRELAMPAGO3_TOP and v_cntr_reg < IRELAMPAGO3_BOTTOM) then
                    addr_time_inc <= addr_irelampago3;
                elsif (h_cntr_reg > IRELAMPAGO4_LEFT and h_cntr_reg < IRELAMPAGO4_RIGHT and v_cntr_reg > IRELAMPAGO4_TOP and v_cntr_reg < IRELAMPAGO4_BOTTOM) then
                    addr_time_inc <= addr_irelampago4;
                end if;
            end if;
            
        when "11" =>                       
        -----------------------------------------------------------------
        --                          TIEMPOS
        ----------------------------------------------------------------- 
            if (h_cntr_reg > TBALA1_LEFT and h_cntr_reg < TBALA1_RIGHT and v_cntr_reg > TBALA1_TOP and v_cntr_reg < TBALA1_BOTTOM) then
                addr_time_inc <= addr_tbala1;
            elsif (h_cntr_reg > TBALA2_LEFT and h_cntr_reg < TBALA2_RIGHT and v_cntr_reg > TBALA2_TOP and v_cntr_reg < TBALA2_BOTTOM) then
                addr_time_inc <= addr_tbala2;
            end if;
            
        -----------------------------------------------------------------
        --                        INCREMENTOS
        ----------------------------------------------------------------- 
            if (h_cntr_reg > IBALA1_LEFT and h_cntr_reg < IBALA1_RIGHT and v_cntr_reg > IBALA1_TOP and v_cntr_reg < IBALA1_BOTTOM) then
                addr_time_inc <= addr_iclasico1;
            end if;
        
        when others => null;
    end case;
end process;


-- Carga del dato de la memoria según la ubicación que se esté recorriendo

process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
 
  data_dummy(0) <= '1';
  
    case MODO is
        when "00" =>         
          -----------------------------------------------------------------
          --                          TIEMPOS
          -----------------------------------------------------------------        
            -- Clasico 1 (2h 30m)
            if (h_cntr_reg > TCLASICO1_LEFT and h_cntr_reg < TCLASICO1_RIGHT 
                                  and v_cntr_reg < TCLASICO1_BOTTOM and v_cntr_reg > TCLASICO1_TOP) then 
             data_dummy(0) <= data_time_inc(24);
             -- Clasico 2 (2h + 1h + 15m)
            elsif (h_cntr_reg > TCLASICO2_LEFT and h_cntr_reg < TCLASICO2_RIGHT 
                                  and v_cntr_reg < TCLASICO2_BOTTOM and v_cntr_reg > TCLASICO2_TOP) then 
             data_dummy(0) <= data_time_inc(23);
             -- Clasico 3 (2h + 1h)
            elsif (h_cntr_reg > TCLASICO3_LEFT and h_cntr_reg < TCLASICO3_RIGHT 
                                  and v_cntr_reg < TCLASICO3_BOTTOM and v_cntr_reg > TCLASICO3_TOP) then 
             data_dummy(0) <= data_time_inc(22);
             -- Clasico 4 (1h 30m)
            elsif (h_cntr_reg > TCLASICO4_LEFT and h_cntr_reg < TCLASICO4_RIGHT 
                                  and v_cntr_reg < TCLASICO4_BOTTOM and v_cntr_reg > TCLASICO4_TOP) then 
             data_dummy(0) <= data_time_inc(21);
             
     
          -----------------------------------------------------------------
          --                       INCREMENTOS
          -----------------------------------------------------------------
            -- Clasico 1 (Estandar)
            elsif (h_cntr_reg > ICLASICO1_LEFT and h_cntr_reg < ICLASICO1_RIGHT 
                                  and v_cntr_reg < ICLASICO1_BOTTOM and v_cntr_reg > ICLASICO1_TOP) then 
             data_dummy(0) <= data_time_inc(0);
            end if;
            
        when "01" =>
                    
          -----------------------------------------------------------------
          --                          TIEMPOS
          -----------------------------------------------------------------  
             -- Rápido 1 (60m)
            if (h_cntr_reg > TRAPIDO1_LEFT and h_cntr_reg < TRAPIDO1_RIGHT 
                                  and v_cntr_reg < TRAPIDO1_BOTTOM and v_cntr_reg > TRAPIDO1_TOP) then 
             data_dummy(0) <= data_time_inc(20);
             -- Rápido 2 (50m)
            elsif (h_cntr_reg > TRAPIDO2_LEFT and h_cntr_reg < TRAPIDO2_RIGHT 
                                  and v_cntr_reg < TRAPIDO2_BOTTOM and v_cntr_reg > TRAPIDO2_TOP) then 
             data_dummy(0) <= data_time_inc(19);
             -- Rápido 3 (40m)
            elsif (h_cntr_reg > TRAPIDO3_LEFT and h_cntr_reg < TRAPIDO3_RIGHT 
                                  and v_cntr_reg < TRAPIDO3_BOTTOM and v_cntr_reg > TRAPIDO3_TOP) then 
             data_dummy(0) <= data_time_inc(18);
             -- Rápido 4 (30m)
            elsif (h_cntr_reg > TRAPIDO4_LEFT and h_cntr_reg < TRAPIDO4_RIGHT 
                                  and v_cntr_reg < TRAPIDO4_BOTTOM and v_cntr_reg > TRAPIDO4_TOP) then 
             data_dummy(0) <= data_time_inc(17);
             -- Rápido 5 (20m)
            elsif (h_cntr_reg > TRAPIDO5_LEFT and h_cntr_reg < TRAPIDO5_RIGHT 
                                  and v_cntr_reg < TRAPIDO5_BOTTOM and v_cntr_reg > TRAPIDO5_TOP) then 
             data_dummy(0) <= data_time_inc(16);
             -- Rápido 6 (10m)
            elsif (h_cntr_reg > TRAPIDO6_LEFT and h_cntr_reg < TRAPIDO6_RIGHT 
                                  and v_cntr_reg < TRAPIDO6_BOTTOM and v_cntr_reg > TRAPIDO6_TOP) then 
             data_dummy(0) <= data_time_inc(15);
             
          -----------------------------------------------------------------
          --                       INCREMENTOS
          -----------------------------------------------------------------
            elsif TIEMPO = "000" then
                if (h_cntr_reg > ICLASICO1_LEFT and h_cntr_reg < ICLASICO1_RIGHT 
                                  and v_cntr_reg < ICLASICO1_BOTTOM and v_cntr_reg > ICLASICO1_TOP) then 
                 data_dummy(0) <= data_time_inc(0);
                end if;
            else
                -- Rápido 1 (30s) 
                if (h_cntr_reg > IRAPIDO1_LEFT and h_cntr_reg < IRAPIDO1_RIGHT 
                                      and v_cntr_reg < IRAPIDO1_BOTTOM and v_cntr_reg > IRAPIDO1_TOP) then 
                 data_dummy(0) <= data_time_inc(8);
                -- Rápido 2 (20s) 
                elsif (h_cntr_reg > IRAPIDO2_LEFT and h_cntr_reg < IRAPIDO2_RIGHT 
                                      and v_cntr_reg < IRAPIDO2_BOTTOM and v_cntr_reg > IRAPIDO2_TOP) then 
                 data_dummy(0) <= data_time_inc(7);
                -- Rápido 3 (15s) 
                elsif (h_cntr_reg > IRAPIDO3_LEFT and h_cntr_reg < IRAPIDO3_RIGHT 
                                      and v_cntr_reg < IRAPIDO3_BOTTOM and v_cntr_reg > IRAPIDO3_TOP) then 
                 data_dummy(0) <= data_time_inc(6);
                -- Rápido 4 (10s) 
                elsif (h_cntr_reg > IRAPIDO4_LEFT and h_cntr_reg < IRAPIDO4_RIGHT 
                                      and v_cntr_reg < IRAPIDO4_BOTTOM and v_cntr_reg > IRAPIDO4_TOP) then 
                 data_dummy(0) <= data_time_inc(5);
                end if;
            end if;
                
        when "10" =>
        
          -----------------------------------------------------------------
          --                          TIEMPOS
          -----------------------------------------------------------------  
            -- Relámpago 1 (10m)
            if (h_cntr_reg > TRELAMPAGO1_LEFT and h_cntr_reg < TRELAMPAGO1_RIGHT 
                                  and v_cntr_reg < TRELAMPAGO1_BOTTOM and v_cntr_reg > TRELAMPAGO1_TOP) then 
             data_dummy(0) <= data_time_inc(14);
             -- Relámpago 2 (8m)
            elsif (h_cntr_reg > TRELAMPAGO2_LEFT and h_cntr_reg < TRELAMPAGO2_RIGHT 
                                  and v_cntr_reg < TRELAMPAGO2_BOTTOM and v_cntr_reg > TRELAMPAGO2_TOP) then 
             data_dummy(0) <= data_time_inc(13);
             -- Relámpago 3 (5m)
            elsif (h_cntr_reg > TRELAMPAGO3_LEFT and h_cntr_reg < TRELAMPAGO3_RIGHT 
                                  and v_cntr_reg < TRELAMPAGO3_BOTTOM and v_cntr_reg > TRELAMPAGO3_TOP) then 
             data_dummy(0) <= data_time_inc(12);
             -- Relámpago 4 (3m)
            elsif (h_cntr_reg > TRELAMPAGO4_LEFT and h_cntr_reg < TRELAMPAGO4_RIGHT 
                                  and v_cntr_reg < TRELAMPAGO4_BOTTOM and v_cntr_reg > TRELAMPAGO4_TOP) then 
             data_dummy(0) <= data_time_inc(11);
             
          -----------------------------------------------------------------
          --                       INCREMENTOS
          -----------------------------------------------------------------
            elsif TIEMPO = "000" then
                if (h_cntr_reg > ICLASICO1_LEFT and h_cntr_reg < ICLASICO1_RIGHT 
                                  and v_cntr_reg < ICLASICO1_BOTTOM and v_cntr_reg > ICLASICO1_TOP) then 
                 data_dummy(0) <= data_time_inc(0);
                end if;
            else
                -- Relámpago 1 (5s)
                if (h_cntr_reg > IRELAMPAGO1_LEFT and h_cntr_reg < IRELAMPAGO1_RIGHT 
                                      and v_cntr_reg < IRELAMPAGO1_BOTTOM and v_cntr_reg > IRELAMPAGO1_TOP) then 
                 data_dummy(0) <= data_time_inc(4);
                -- Relámpago 2 (4s)
                elsif (h_cntr_reg > IRELAMPAGO2_LEFT and h_cntr_reg < IRELAMPAGO2_RIGHT 
                                      and v_cntr_reg < IRELAMPAGO2_BOTTOM and v_cntr_reg > IRELAMPAGO2_TOP) then 
                 data_dummy(0) <= data_time_inc(3);
                -- Relámpago 3 (3s)
                elsif (h_cntr_reg > IRELAMPAGO3_LEFT and h_cntr_reg < IRELAMPAGO3_RIGHT 
                                      and v_cntr_reg < IRELAMPAGO3_BOTTOM and v_cntr_reg > IRELAMPAGO3_TOP) then 
                 data_dummy(0) <= data_time_inc(2);
                -- Relámpago 4 (2s)
                elsif (h_cntr_reg > IRELAMPAGO4_LEFT and h_cntr_reg < IRELAMPAGO4_RIGHT 
                                      and v_cntr_reg < IRELAMPAGO4_BOTTOM and v_cntr_reg > IRELAMPAGO4_TOP) then 
                 data_dummy(0) <= data_time_inc(1);
                 end if;
            end if;
                
       when "11" =>
          -----------------------------------------------------------------
          --                          TIEMPOS
          -----------------------------------------------------------------  
             -- Bala 1 (2m)
            if (h_cntr_reg > TBALA1_LEFT and h_cntr_reg < TBALA1_RIGHT 
                                  and v_cntr_reg < TBALA1_BOTTOM and v_cntr_reg > TBALA1_TOP) then 
             data_dummy(0) <= data_time_inc(10);
             -- Bala 2 (2m)
            elsif (h_cntr_reg > TBALA2_LEFT and h_cntr_reg < TBALA2_RIGHT 
                                  and v_cntr_reg < TBALA2_BOTTOM and v_cntr_reg > TBALA2_TOP) then 
             data_dummy(0) <= data_time_inc(9);
             
          -----------------------------------------------------------------
          --                       INCREMENTOS
          -----------------------------------------------------------------
            -- Bala 1 (Estandar)
            elsif (h_cntr_reg > IBALA1_LEFT and h_cntr_reg < IBALA1_RIGHT 
                                  and v_cntr_reg < IBALA1_BOTTOM and v_cntr_reg > IBALA1_TOP) then 
             data_dummy(0) <= data_time_inc(0);
            end if;
        when others => null;
    end case; 
  end if;
end process;

-- Assign output
OVERLAY_O <= data_dummy(0);
    
end Behavioral;

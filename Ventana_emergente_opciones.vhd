----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.03.2026 18:09:06
-- Design Name: 
-- Module Name: Ventana_emergente_opciones - Behavioral
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

entity Ventana_emergente_opciones is
	Generic (char_H_LOC : natural := 200;
	         char_V_LOC : natural := 100);
    Port ( CLK_I        : in  STD_LOGIC;
           VSYNC_I      : in  STD_LOGIC;
           h_cntr_reg   : in std_logic_vector(11 downto 0);
           v_cntr_reg   : in std_logic_vector(11 downto 0);           
--           ACTIVE_I   : in  STD_LOGIC;
           OVERLAY_O    : out  STD_LOGIC
           );
end Ventana_emergente_opciones;

architecture Behavioral of Ventana_emergente_opciones is

-- BRAM 150x90 blocks
COMPONENT Si_no_blocks_mem
PORT (
    clka  : IN STD_LOGIC;
    ena   : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
);
END COMPONENT;
    
constant SZ_char_WIDTH  : natural := 150;
constant SZ_char_HEIGHT : natural := 90; 

-- Declaración de las posiciones de cada bloque basados en la posición de referencia (genéricos de entrada)
-- Opción "SI"
constant SI_LEFT	: natural := char_H_LOC + 485 - 1;
constant SI_RIGHT   : natural := char_H_LOC + 485 + SZ_char_WIDTH;
constant SI_TOP	    : natural := char_V_LOC + 570 - 1;
constant SI_BOTTOM  : natural := char_V_LOC + 570 + SZ_char_HEIGHT;

-- Opción "NO"
constant NO_LEFT	: natural := char_H_LOC + 885 - 1;
constant NO_RIGHT   : natural := char_H_LOC + 885 + SZ_char_WIDTH;
constant NO_TOP	    : natural := char_V_LOC + 570 - 1;
constant NO_BOTTOM  : natural := char_V_LOC + 570 + SZ_char_HEIGHT;

-- Señales addr para cada señal
signal addr_si      : std_logic_vector(13 downto 0) := (others=>'0');
signal addr_no      : std_logic_vector(13 downto 0) := (others=>'0');

constant TOTAL_RAM_DEPTH : integer :=  (SZ_char_WIDTH*SZ_char_HEIGHT);
signal addr_si_no : std_logic_vector(13 downto 0) := (others=>'0');
signal data_si_no : std_logic_vector(1 downto 0);
signal data_dummy : std_logic_vector(0 downto 0);

begin

-- 150x90 blocks
Inst_150x90_blocks : Si_no_blocks_mem
    PORT MAP(
    clka  =>  CLK_I,
    ena   => '1',
    addra => addr_si_no,
    douta => data_si_no
    );
    
-- Contadores de los bits contenidos en la memoria

-- Opción "SI"
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_si <= (others=>'0');
     elsif (h_cntr_reg > SI_LEFT and h_cntr_reg < SI_RIGHT 
                          and v_cntr_reg < SI_BOTTOM and v_cntr_reg > SI_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_si = (TOTAL_RAM_DEPTH - 1)) then
        addr_si <= (others=>'0');
      else
        addr_si <= addr_si + 1;
      end if;
    end if;
  end if;
end process;

-- Opción "NO"
process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    if (VSYNC_I = '1') then -- Restart Address Counter at the beginning of the screen
      addr_no <= (others=>'0');
     elsif (h_cntr_reg > NO_LEFT and h_cntr_reg < NO_RIGHT 
                          and v_cntr_reg < NO_BOTTOM and v_cntr_reg > NO_TOP) then 
                          -- Increment the address counter when in the dmin region
--    elsif (ACTIVE_I = '1') then -- Increment the address counter when in the active screen region
      if (addr_no = (TOTAL_RAM_DEPTH - 1)) then
        addr_no <= (others=>'0');
      else
        addr_no <= addr_no + 1;
      end if;
    end if;
  end if;
end process;

-- Proceso de multiplexado de las cuentas
process(h_cntr_reg, v_cntr_reg, addr_si, addr_no)
begin
    if (h_cntr_reg > SI_LEFT and h_cntr_reg < SI_RIGHT and v_cntr_reg < SI_BOTTOM and v_cntr_reg > SI_TOP) then
        addr_si_no <= addr_si;
    elsif (h_cntr_reg > NO_LEFT and h_cntr_reg < NO_RIGHT and v_cntr_reg < NO_BOTTOM and v_cntr_reg > NO_TOP) then
        addr_si_no <= addr_no;
    else
        addr_si_no <= (others => '0');
    end if;
end process;  

-- Carga del dato de la memoria según la ubicación que se esté recorriendo

process(CLK_I)
begin
  if (rising_edge(CLK_I)) then
    -- Opción "SI"
    if (h_cntr_reg > SI_LEFT and h_cntr_reg < SI_RIGHT 
                          and v_cntr_reg < SI_BOTTOM and v_cntr_reg > SI_TOP) then 
     data_dummy(0) <= data_si_no(0);
    -- Opción "NO" 
    elsif (h_cntr_reg > NO_LEFT and h_cntr_reg < NO_RIGHT 
                          and v_cntr_reg < NO_BOTTOM and v_cntr_reg > NO_TOP) then 
     data_dummy(0) <= data_si_no(1);
    else
     data_dummy(0) <= '1';
    end if;
  end if;
end process;

-- Assign output
OVERLAY_O <= data_dummy(0);
    
end Behavioral;

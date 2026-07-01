----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.07.2025 16:19:00
-- Design Name: 
-- Module Name: crono_general - Behavioral
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

entity crono_general_final is
     Port (led              : out STD_LOGIC_VECTOR(6 downto 0);
           an               : out STD_LOGIC_VECTOR(7 downto 0);
           
           clk_i            : in  std_logic;
           rstn_i           : in  std_logic;
           -- VGA display
           vga_hs_o         : out std_logic;
           vga_vs_o         : out std_logic;
           vga_red_o        : out std_logic_vector(3 downto 0);
           vga_blue_o       : out std_logic_vector(3 downto 0);
           vga_green_o      : out std_logic_vector(3 downto 0);
           -- PS2 interface signals
           ps2_clk          : inout std_logic;
           ps2_data         : inout std_logic;
           
           -----------------------------------------------------
           --         SEÑALES PARA DEBUG
           -----------------------------------------------------
           
           -- Señales para probar el funcionamiento de los clicks del ratón
           MOUSE_LEFT_LED     : out std_logic;
           MOUSE_RIGHT_LED    : out std_logic;
           MOUSE_MIDDLE_LED   : out std_logic; 
           -- Debug del estado del menú
           MENU_LED           : inout std_logic_vector(5 downto 0);
           -- Debug de la configuración de partida
           GAMEMODE           : out std_logic_vector(6 downto 0);
           -- LED para el LOAD_SEL
           LOAD_SEL_LED       : out std_logic;
           -- LED para el PRESET
           PRESET_LED         : out std_logic
           );
end crono_general_final;

architecture Behavioral of crono_general_final is
----------------------------------------------------------------------------------------------------

--                            Declaración de señales

----------------------------------------------------------------------------------------------------

--Declaración de señales para los contadores
signal ce_uhoras, ce_dminutos, ce_uminutos, ce_dseg, ce_useg, ce_decimas, ce1_centesimas, ce2_centesimas, load, top_divisor : std_logic;
signal top_uhoras, top_dminutos, top_uminutos, top_dseg, top_useg, top_decimas, top_centesimas : std_logic;
signal uhoras1, dminutos1, uminutos1, dseg1, useg1, decimas1, centesimas1, hex : std_logic_vector(3 downto 0);
signal uhoras2, dminutos2, uminutos2, dseg2, useg2, decimas2, centesimas2 : std_logic_vector(3 downto 0);
signal load_data_uhoras, load_data_dminutos, load_data_uminutos, load_data_dseg, load_data_useg, load_data_decimas, load_data_centesimas : std_logic_vector(3 downto 0);
signal cuenta_jugadas : std_logic_vector(11 downto 0);

--Declaración de señales para el divisor de frecuencia
signal sel : std_logic_vector(2 downto 0);
signal divisor : std_logic_vector(19 downto 0);

--Declaración de señales para el selector de juego
signal count_jugadas : std_logic_vector(7 downto 0);
signal centesimas_init, decimas_init, useg_init, dseg_init, uminutos_init, dminutos_init, uhoras_init, load_useg_inc, load_dseg_inc, load_uhoras_add, load_dminutos_add, load_uminutos_add : std_logic_vector(3 downto 0);

--Declaración de señales para los sumadores
signal in_data_centesimas, in_data_decimas, in_data_uhoras, in_data_dminutos, in_data_uminutos, in_data_dseg, in_data_useg : std_logic_vector(3 downto 0);
signal load1_control, load2_control : std_logic;
signal load1, load2 : std_logic;
signal load_sel     : std_logic;
signal preset       : std_logic;

--Señales para la sincronización de relojes de load_sel y preset
signal preset_sync   : std_logic_vector(1 downto 0);
signal load_sel_sync : std_logic_vector(1 downto 0);

signal preset_sys    : std_logic;
signal load_sel_sys  : std_logic;

--Señal para detectar el final del descuento y apagar el contador coresspondiente
signal cuenta_final1, cuenta_final2 : std_logic_vector(27 downto 0);
signal zero, ce1_load, ce2_load : std_logic;

--Señales para la comunicación con el bloque de visualización
signal en_white_vga     : std_logic;
signal en_black_vga     : std_logic;
signal game_config      : std_logic_vector(6 downto 0);
signal en1_change_vga   : std_logic;
signal en2_change_vga   : std_logic;

--Señales para la sincronización de relojes
signal en_white_sys     : std_logic;
signal en_black_sys     : std_logic;
signal game_config_sys  : std_logic_vector(6 downto 0);
signal en1_change_sys   : std_logic;
signal en2_change_sys   : std_logic;

signal en_white_sync    : std_logic_vector(1 downto 0);
signal en_black_sync    : std_logic_vector(1 downto 0);
signal game_config_sync : std_logic_vector(6 downto 0);
signal en1_change_sync  : std_logic;
signal en2_change_sync  : std_logic; 

--Señales para el generador de relojes

-- Inverted input reset signal
signal rst        : std_logic;
-- Reset signal conditioned by the PLL lock
signal reset      : std_logic;
signal resetn     : std_logic;
signal locked     : std_logic;

-- 100 MHz buffered clock signal
signal clk_100MHz_buf : std_logic;
-- 148.5 MHz buffered clock signal
signal clk_148_5MHz_buf : std_logic;

-- Mouse data signals
signal MOUSE_X_POS      : std_logic_vector (11 downto 0);
signal MOUSE_Y_POS      : std_logic_vector (11 downto 0);
signal MOUSE_LEFT_BTN   : std_logic;
signal MOUSE_RIGHT_BTN  : std_logic;
signal MOUSE_MIDDLE_BTN : std_logic;

signal MOUSE_X_VGA      : std_logic_vector (11 downto 0);
signal MOUSE_Y_VGA      : std_logic_vector (11 downto 0);
signal MOUSE_LEFT_VGA   : std_logic;
signal MOUSE_RIGHT_VGA  : std_logic;
signal MOUSE_MIDDLE_VGA : std_logic;

signal MOUSE_X_SNC      : std_logic_vector (11 downto 0);
signal MOUSE_Y_SNC      : std_logic_vector (11 downto 0);
signal MOUSE_LEFT_SNC   : std_logic;
signal MOUSE_RIGHT_SNC  : std_logic;
signal MOUSE_MIDDLE_SNC : std_logic;

----------------------------------------------------------------------------------------------------

--                           Declaración de componentes

-----------------------------------------------------------------------------------------------------

--Reloj básico
component crono_simple
    Port ( clk, load, preset, sel, ce_centesimas : in STD_LOGIC;
           centesimas, decimas, uhoras, dminutos, uminutos, dseg, useg : inout STD_LOGIC_VECTOR(3 downto 0);
           load_data_uhoras, load_data_dminutos, load_data_uminutos, load_data_dseg ,load_data_useg, load_data_centesimas, load_data_decimas : in STD_LOGIC_VECTOR(3 downto 0);
           load_dseg_inc, load_useg_inc, load_uhoras_add, load_dminutos_add, load_uminutos_add : in STD_LOGIC_VECTOR(3 downto 0)
         );
end component;         

--Contador ascendente
component up_counter
    Generic (module   : integer; 
			 width    : integer);
    Port   ( clk      : in  STD_LOGIC;
             reset    : in  STD_LOGIC;
             count    : out  STD_LOGIC_VECTOR (width-1 downto 0);
             ce       : in   STD_LOGIC;
             top      : out  STD_LOGIC);
end component;

--Multiplexor para los 2 relojes
component mux8to1_2clocks
    Port ( clk : in std_logic;
           centesimas1, centesimas2 : in  STD_LOGIC_VECTOR (3 downto 0);
           decimas1, decimas2 : in  STD_LOGIC_VECTOR (3 downto 0);
           useg1, useg2 : in  STD_LOGIC_VECTOR (3 downto 0);
           dseg1, dseg2 : in  STD_LOGIC_VECTOR (3 downto 0);
           uminutos1, uminutos2 : in  STD_LOGIC_VECTOR (3 downto 0);
           dminutos1, dminutos2 : in  STD_LOGIC_VECTOR (3 downto 0);
           uhoras1, uhoras2 : in  STD_LOGIC_VECTOR (3 downto 0);
           sel : in  STD_LOGIC_VECTOR (2 downto 0);
           hex : out  STD_LOGIC_VECTOR (3 downto 0));
end component; 

--Decodificador
component dec3to8
    Port ( sel : in  STD_LOGIC_VECTOR (2 downto 0);
           an : out  STD_LOGIC_VECTOR (7 downto 0));
end component;

--Decodificador 7 segmentos
component dec7seg
    Port ( hex : in  STD_LOGIC_VECTOR (3 downto 0);
           led : out  STD_LOGIC_VECTOR (6 downto 0)
           );
end component; 

--Selector de juego
component game_selector
    Port ( clk : in std_logic;
           count_jugadas : in STD_LOGIC_VECTOR(6 downto 0);
           mode_time_inc : in STD_LOGIC_VECTOR(6 downto 0);
           load_data_uhoras, load_data_dminutos, load_data_uminutos, load_data_dseg ,load_data_useg, load_data_centesimas, load_data_decimas : out STD_LOGIC_VECTOR(3 downto 0);
           load_dseg_inc, load_useg_inc, load_uhoras_add, load_dminutos_add, load_uminutos_add : out STD_LOGIC_VECTOR(3 downto 0);
           zero, preset, load_sel : in STD_LOGIC
           --Señal de debug
--           DEBUG_SEL : out std_logic_vector(3 downto 0);
--           DEBUG_LOAD : out std_logic
           );
end component;

--Contador de jugadas
component jugadas_tracker
    Port ( clk : in STD_LOGIC;
           ce : in STD_LOGIC;
           preset : in STD_LOGIC;
           load_sel : in STD_LOGIC;
           jugadas_number : out STD_LOGIC_VECTOR(11 downto 0)           
           );
end component;           

-- VGA
COMPONENT Vga is
PORT( 
   clk_i          : in  std_logic;
   vga_hs_o       : out std_logic;
   vga_vs_o       : out std_logic;
   vga_red_o      : out std_logic_vector(3 downto 0);
   vga_blue_o     : out std_logic_vector(3 downto 0);
   vga_green_o    : out std_logic_vector(3 downto 0);
   MOUSE_X_POS      : in std_logic_vector (11 downto 0); -- X position from the mouse
   MOUSE_Y_POS      : in std_logic_vector (11 downto 0); -- Y position from the mouse
   MOUSE_LEFT_BTN   : in std_logic; -- Left button press from the mouse
   MOUSE_RIGHT_BTN  : in std_logic; -- Right button press from the mouse
   MOUSE_MIDDLE_BTN : in std_logic;  -- Middle button press from the mouse
   -- Estado del menú
   MENU_STATE_LED   : inout std_logic_vector (5 downto 0);
   -- Configuración del game selector
   GAME_CONFIG      : out std_logic_vector (6 downto 0);
   -- Enable de los relojes de los jugadores
   EN_WHITE         : out std_logic;
   EN_BLACK         : out std_logic;
   -- Cambio de los enable en los relojes
   EN1_CHANGE       : out std_logic;
   EN2_CHANGE       : out std_logic;   
   -- Cuentas de cada reloj
   CUENTA_BLANCAS   : in std_logic_vector(27 downto 0);
   CUENTA_NEGRAS    : in std_logic_vector(27 downto 0);
   -- Señal de carga de los valores de juego
   LOAD_SEL         : out std_logic;
   PRESET           : out std_logic
   ); 
END COMPONENT;

-- Clock Generator
component ClkGen
port
 (-- Clock in ports
  clk_100MHz_i          : in     std_logic;
  -- Clock out ports
  clk_100MHz_o          : out    std_logic;
  clk_148_5MHz_o        : out    std_logic;
  -- Status and control signals
  reset_i             : in     std_logic;
  locked_o            : out    std_logic
 );
end component;

-- Control del ratón
COMPONENT MouseCtl is
PORT(
   clk            : in std_logic;
   rst            : in std_logic;
   xpos           : out std_logic_vector(11 downto 0);
   ypos           : out std_logic_vector(11 downto 0);
   zpos           : out std_logic_vector(3 downto 0);
   left           : out std_logic;
   middle         : out std_logic;
   right          : out std_logic;
   new_event      : out std_logic;
   value          : in std_logic_vector(11 downto 0);
   setx           : in std_logic;
   sety           : in std_logic;
   setmax_x       : in std_logic;
   setmax_y       : in std_logic;
   ps2_clk        : inout std_logic;
   ps2_data       : inout std_logic
);
END COMPONENT;

begin

   -- The Reset Button on the Nexys4 board is active-low,
   -- however many components need an active-high reset
   rst <= not rstn_i;

   -- Assign reset signals conditioned by the PLL lock
   reset <= rst or (not locked);
   -- active-low version of the reset signal
   resetn <= not reset;
   
--Proceso de sincronización de relojes
process(clk_100MHz_buf)
begin
    if rising_edge(clk_100MHz_buf) then
        en_white_sync(0) <= en_white_vga;
        en_white_sync(1) <= en_white_sync(0); 
        
        en_black_sync(0) <= en_black_vga;
        en_black_sync(1) <= en_black_sync(0);  
        
        preset_sync(0)   <= preset;
        preset_sync(1)   <= preset_sync(0) and not preset;

        load_sel_sync(0) <= load_sel;
        load_sel_sync(1) <= load_sel_sync(0) and not load_sel;
        
        game_config_sync <= game_config;
        game_config_sys  <= game_config_sync;
        
        en1_change_sync  <= en1_change_vga;
        en1_change_sys   <= en1_change_sync;
        
        en2_change_sync  <= en2_change_vga;
        en2_change_sys   <= en2_change_sync;
    end if;
end process;

en_white_sys <= en_white_sync(1);
en_black_sys <= en_black_sync(1);

preset_sys   <= preset_sync(1);
load_sel_sys <= load_sel_sync(1);

--Proceso de sincronización para el VGA
process(clk_148_5MHz_buf)
begin
   if rising_edge(clk_148_5MHz_buf) then
      MOUSE_X_SNC      <= MOUSE_X_POS;
      MOUSE_X_VGA      <= MOUSE_X_SNC;
      
      MOUSE_Y_SNC      <= MOUSE_Y_POS;
      MOUSE_Y_VGA      <= MOUSE_Y_SNC;
      
      MOUSE_LEFT_SNC   <= MOUSE_LEFT_BTN;
      MOUSE_LEFT_VGA   <= MOUSE_LEFT_SNC;
      
      MOUSE_RIGHT_SNC  <= MOUSE_RIGHT_BTN;
      MOUSE_RIGHT_VGA  <= MOUSE_RIGHT_SNC;
      
      MOUSE_MIDDLE_SNC <= MOUSE_MIDDLE_BTN;
      MOUSE_MIDDLE_VGA <= MOUSE_MIDDLE_SNC;
   end if;
end process;

----------------------------------------------------------------------------------
-- Clock Generator
----------------------------------------------------------------------------------
   Inst_ClkGen: ClkGen
   port map (
      clk_100MHz_i   => clk_i,
      clk_100MHz_o   => clk_100MHz_buf,
      clk_148_5MHz_o => clk_148_5MHz_buf,   
      reset_i        => rst,
      locked_o       => locked
      );

----------------------------------------------------------------------------------
-- Divisor de frecuencia
----------------------------------------------------------------------------------
div_freq_unit : up_counter
    generic map(
		module => 1000000,
		width => 20)
	PORT MAP(
		clk => clk_100MHz_buf,
		reset => '0',
		count => divisor,
		ce => '1',
		top => top_divisor
	);

    --Refresco de 100MHz
	sel <= divisor(18 downto 16);
	ce1_centesimas <= top_divisor and en_white_sys and ce1_load;
	ce2_centesimas <= top_divisor and en_black_sys and ce2_load;

----------------------------------------------------------------------------------
-- Reloj del jugador 1 (blancas)
----------------------------------------------------------------------------------
Inst_player1 : crono_simple
    PORT MAP (
        clk => clk_100MHz_buf,
        load => load1,
        preset => preset_sys,
        sel => load_sel_sys,
        ce_centesimas => ce1_centesimas,
        centesimas => centesimas1,
        decimas => decimas1,
        useg => useg1,
        dseg => dseg1,
        uminutos => uminutos1,
        dminutos => dminutos1,
        uhoras => uhoras1,
        load_data_uhoras => uhoras_init,
        load_data_dminutos => dminutos_init,
        load_data_uminutos => uminutos_init,
        load_data_dseg => dseg_init,
        load_data_useg => useg_init,
        load_data_centesimas => centesimas_init,
        load_data_decimas => decimas_init,
        load_dseg_inc => load_dseg_inc,
        load_useg_inc => load_useg_inc,
        load_uhoras_add => load_uhoras_add,
        load_dminutos_add => load_dminutos_add,
        load_uminutos_add => load_uminutos_add
    );
 
----------------------------------------------------------------------------------
-- Reloj del jugador 2 (negras)
----------------------------------------------------------------------------------       
Inst_player2 : crono_simple
    PORT MAP (
        clk => clk_100MHz_buf,
        load => load2,
        preset => preset_sys,
        sel => load_sel_sys,
        ce_centesimas => ce2_centesimas,
        centesimas => centesimas2,
        decimas => decimas2,
        useg => useg2,
        dseg => dseg2,
        uminutos => uminutos2,
        dminutos => dminutos2,
        uhoras => uhoras2,
        load_data_uhoras => uhoras_init,
        load_data_dminutos => dminutos_init,
        load_data_uminutos => uminutos_init,
        load_data_dseg => dseg_init,
        load_data_useg => useg_init,
        load_data_centesimas => centesimas_init,
        load_data_decimas => decimas_init,
        load_dseg_inc => load_dseg_inc,
        load_useg_inc => load_useg_inc,
        load_uhoras_add => load_uhoras_add,
        load_dminutos_add => load_dminutos_add,
        load_uminutos_add => load_uminutos_add
    );        

----------------------------------------------------------------------------------
-- Multiplexor de los dos relojes para el 7 segmentos
----------------------------------------------------------------------------------
Inst_mux8to1 : mux8to1_2clocks
    PORT MAP (
        clk => clk_100MHz_buf,
        centesimas1 => centesimas1,
        centesimas2 => centesimas2,
        decimas1 => decimas1,
        decimas2 => decimas2,
        useg1 => useg1,
        useg2 => useg2,
        dseg1 => dseg1,
        dseg2 => dseg2,
        uminutos1 => uminutos1,
        uminutos2 => uminutos2,
        dminutos1 => dminutos1,
        dminutos2 => dminutos2,
        uhoras1 => uhoras1,
        uhoras2 => uhoras2,
        sel => sel,
        hex => hex
    );

----------------------------------------------------------------------------------
-- Decodificador para lo mostrado en el 7 segmentos
----------------------------------------------------------------------------------
Inst_dec3to8 : dec3to8
    PORT MAP (
        sel => sel,
        an => an
    );     
    
----------------------------------------------------------------------------------
-- Decodificador 7 segmentos
----------------------------------------------------------------------------------
Inst_dec7seg : dec7seg
    PORT MAP (
        hex => hex,
        led => led
    );

----------------------------------------------------------------------------------
-- Selector de juego
----------------------------------------------------------------------------------
Inst_game_selector : game_selector
    PORT MAP (
        clk => clk_100MHz_buf,
        count_jugadas => cuenta_jugadas(6 downto 0),
        mode_time_inc => game_config_sys,
        load_data_centesimas => centesimas_init,
        load_data_decimas => decimas_init,
        load_data_useg => useg_init,
        load_data_dseg => dseg_init,
        load_data_uminutos => uminutos_init,
        load_data_dminutos => dminutos_init,
        load_data_uhoras => uhoras_init,
        load_dseg_inc => load_dseg_inc,
        load_useg_inc => load_useg_inc,
        load_uhoras_add => load_uhoras_add,
        load_dminutos_add => load_dminutos_add,
        load_uminutos_add => load_uminutos_add,
        zero => zero,
        preset => preset_sys,
        load_sel => load_sel_sys
    );	

----------------------------------------------------------------------------------
-- Contador de jugadas
----------------------------------------------------------------------------------	
Inst_jugadas_tracker : jugadas_tracker
    PORT MAP (
        clk => clk_100MHz_buf,
        ce => en_black_sys,  --Se usa el cambio de jugada del segundo jugador
        preset => preset_sys,
        load_sel => load_sel_sys,
        jugadas_number => cuenta_jugadas
    );	

----------------------------------------------------------------------------------
-- Visualización
----------------------------------------------------------------------------------   
Inst_VGA: Vga
   port map(
      clk_i            => clk_148_5MHz_buf,
      
      vga_hs_o         => vga_hs_o,
      vga_vs_o         => vga_vs_o,
      vga_red_o        => vga_red_o,
      vga_green_o      => vga_green_o,
      vga_blue_o       => vga_blue_o,
      
      MOUSE_X_POS      => MOUSE_X_VGA,
      MOUSE_Y_POS      => MOUSE_Y_VGA,
      MOUSE_LEFT_BTN   => MOUSE_LEFT_VGA,
      MOUSE_RIGHT_BTN  => MOUSE_RIGHT_VGA,
      MOUSE_MIDDLE_BTN => MOUSE_MIDDLE_VGA,
      
      MENU_STATE_LED   => MENU_LED,
      
      GAME_CONFIG      => game_config,
      
      EN_WHITE         => en_white_vga,
      EN_BLACK         => en_black_vga,
      
      EN1_CHANGE       => en1_change_vga,
      EN2_CHANGE       => en2_change_vga,
      
      CUENTA_BLANCAS   => cuenta_final1,
      CUENTA_NEGRAS    => cuenta_final2,
      
      LOAD_SEL         => load_sel,
      PRESET           => preset
      ); 

----------------------------------------------------------------------------------
-- Mouse Controller
----------------------------------------------------------------------------------
   Inst_MouseCtl: MouseCtl
   PORT MAP
   (
      clk            => clk_100MHz_buf,
      rst            => rst,
      xpos           => MOUSE_X_POS,
      ypos           => MOUSE_Y_POS,
      zpos           => open,
      left           => MOUSE_LEFT_BTN,
      middle         => MOUSE_MIDDLE_BTN,
      right          => MOUSE_RIGHT_BTN,
      new_event      => open,
      value          => x"000",
      setx           => '0',
      sety           => '0',
      setmax_x       => '0',
      setmax_y       => '0',
      ps2_clk        => ps2_clk,
      ps2_data       => ps2_data
   );

--Señales que almacenan la cuenta total de los cronómetros
cuenta_final1 <= uhoras1 & dminutos1 & uminutos1 & dseg1 & useg1 & decimas1 & centesimas1;
cuenta_final2 <= uhoras2 & dminutos2 & uminutos2 & dseg2 & useg2 & decimas2 & centesimas2;

--Proceso para activar la señal de fin del cronómetro una vez llegue a 0 en todas las cuentas
process(cuenta_final1, cuenta_final2)
    begin
        if cuenta_final1 = "0000000000000000000000000000" or cuenta_final2 = "0000000000000000000000000000" then
            zero <= '1';
        else
            zero <= '0';
        end if;
end process; 

--Asignación de valores a los "load" de los relojes individuales
load1        <= load_sel_sys or en1_change_sys;
load2        <= load_sel_sys or en2_change_sys;

ce1_load     <= '0' when zero = '1' else en_white_sys;
ce2_load     <= '0' when zero = '1' else en_black_sys;

GAMEMODE     <= game_config_sys;
LOAD_SEL_LED <= load_sel_sys;
PRESET_LED   <= preset_sys;

-- Asignación de las señales del ratón a las salidas del top correspondientes
MOUSE_LEFT_LED  <= MOUSE_LEFT_VGA;
MOUSE_RIGHT_LED <= MOUSE_RIGHT_VGA;
MOUSE_MIDDLE_LED<= MOUSE_MIDDLE_VGA;

--Guía de las distintas combinaciones de mode_time_inc y lo que implican en el selector.

    --Teniendo en cuenta que mode_time_inc va de 6 a 0, siendo 6 el bit más significativo (el de más a la izquierda) 
    --y 0 el menos significativo (el de más a la derecha), estas son las distintas selecciones y qué representa cada una.

    --Selección de modo de juego (mode_time_inc(6) y mode_time_inc(5)):
        --Modo clásico -> "00"
        --Modo rápido -> "01"
        --Modo relámpago (blitz) -> "10"
        --Modo bala (bullet) -> "11"
        
    --Selección de tiempos (mode_time_inc(4), mode_time_inc(3) y mode_time_inc(2)):
        --Con modo clásico configurado:
            --Modo 0: 2 horas y 30 minutos, con adición de 1 hora trás 40 jugadas y otros 30 minutos a las 60 jugadas -> "000"
            --Modo 1: 2 horas, con adición de 1 hora tras 40 jugadas y 15 minutos e incremento de 30 segundos a las 60 jugadas -> "010"
            --Modo 2: 2 horas, y adición de 1 hora tras 50 jugadas -> "100"
            --Modo 3: 1 hora y media, y adición de 30 minutos e incrementos de 30 segundos tras 40 jugadas -> "110"
        --Con modo rápido configurado:
            --Modo 0: 60 minutos sin incremento -> "000"
            --Modo 1: 50 minutos con incremento de 10 segundos -> "001"
            --Modo 2: 40 minutos con incremento de 20 segundos -> "010"
            --Modo 3: 30 minutos con incremento de 30 segundos -> "011"
            --Modo 4: 20 minutos con incremento variable (mirar selección de incrementos en el apartado de modo rápido) -> "100"
            --Modo 5, 6 y 7: 10 minutos con incremento variable (mirar selección de incrementos en el apartado de modo rápido) -> "101", "110" y "111"
        --Con modo relámpago configurado:
            --Modo 0: 10 minutos sin incremento -> "000"
            --Modo 1: 8 minutos con incremento de 2 segundos -> "010"
            --Modo 2: 5 minutos con incremento variable (mirar selección de incrementos en el apartado de modo relámpago) -> "100"
            --Modo 3: 3 minutos con incremento variable (mirar selección de incrementos en el apartado de modo relámpago) -> "110"
        --Con modo bala configurado:
            --Modo 0: 2 minutos sin incremento -> "000"
            --Modo 1: 1 minuto con incremento de 1 segundo -> "100"
            
    --Selección de incrementos (mode_time_inc(1) y mode_time_inc(0)):
        --Con modo rápido configurado:
            --Incremento de 30 segundos -> "11"
            --Incremento de 20 segundos -> "10"
            --Incremento de 15 segundos -> "01"
            --Incremento de 10 segundos -> "00"
        --Con modo relámpago configurado:
            --Incremento de 5 segundos -> "11"
            --Incremento de 4 segundos -> "10"
            --Incremento de 3 segundos -> "01"
            --Incremento de 2 segundos -> "00"    
        --Para los modos o tiempos en los que no hayan incrementos o sean fijos, esta elección no afectará en absoluto
        
--Cualquier combinación de mode_time_inc que no esté incluída como una opción dentro de las indicadas en esta guía, inicializará todos los contadores e incrementos a "0".   
       
end Behavioral;

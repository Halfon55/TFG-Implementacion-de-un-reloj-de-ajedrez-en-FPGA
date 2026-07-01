----------------------------------------------------------------------------------
----------------------------------------------------------------------------
-- Author:  Albert Fazakas adapted from Alec Wyen and Mihaita Nagy
--          Copyright 2014 Digilent, Inc.
----------------------------------------------------------------------------
-- 
-- Create Date:    13:01:51 02/15/2013 
-- Design Name: 
-- Module Name:    Vga - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--       This module represents the Vga controller that creates the HSYNC and VSYNC signals
--    for the VGA screen and formats the 4-bit R, G and B signals to display various items
--    on the screen:
--       - A moving colorbar in the background
--       - A Digilent - Analog Devices logo for the Nexys4 board, the RGB data is provided 
--    by the LogoDisplay component. The logo bitmap is stored in the BRAM_1 Block RAM in .ngc format.
--       - The FPGA temperature on a 0..80C scale. Temperature data is taken from the XADC
--    component in the Artix-7 FPGA, provided by the upper level FPGAMonitor component and the RGB data is
--    provided by the Inst_XadcTempDisplay instance of the TempDisplay component.
--       - The Nexys4 Onboard ADT7420 Temperature Sensor temperature on a 0..80C scale. 
--    Temperature data is provided by the upper level TempSensorCtl component and the RGB data is
--    provided by the Inst_Adt7420TempDisplay instance of the TempDisplay component.
--       - The Nexys4 Onboard ADXL362 Accelerometer Temperature Sensor temperature on a 0..80C scale. 
--    Temperature data is provided by the upper level AccelerometerCtl component and the RGB data is
--    provided by the Inst_Adxl362TempDisplay instance of the TempDisplay component.
--       - The R, G and B data which is also sent to the Nexys4 onboard RGB Leds LD16 and LD17. The 
--    incomming RGB Led data is taken from the upper level RgbLed component and the formatted RGB data is provided
--    by the RGBLedDisplay component.
--       - The audio signal coming from the Nexys4 Onboard ADMP421 Omnidirectional Microphone. The formatted
--    RGB data is provided by the MicDisplay component.
--       - The X and Y acceleration in a form of a moving box and the acceleration magnitude determined by 
--    the SQRT (X^2 + Y^2 + Z^2) formula. The acceleration and magnitude data is provided by the upper level 
--    AccelerometerCtl component and the formatted RGB data is provided by the AccelDisplay component.
--       - The mouse cursor on the top on all of the items. The USB mouse should be connected to the Nexys4 board before 
--    the FPGA is configured. The mouse cursor data is provided by the upper level MouseCtl component and the 
--    formatted RGB data for the mouse cursor shape is provided by the MouseDisplay component.
--       - An overlay that displayed the frames and text for the displayed items described above. The overlay data is
--    stored in the overlay_bram Block RAM in the .ngc format and the data is provided by the OverlayCtl component.
--       The Vga controller holds the synchronization signal generation, the moving colorbar generation and the main
--    multiplexers for the outgoing R, G and B signals. Also the 108 MHz pixel clock (pxl_clk) generator is instantiated
--    inside the Vga controller.
--       The current resolution is 1280X1024 pixels, however, other resolutions can also be selected by 
--    commenting/uncommenting the corresponding VGA resolution constants. In the case when a different resolution
--    is selected, the pixel clock generator output frequency also has to be updated accordingly.
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.CHESS_PKG.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.math_real.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Vga is
    Port ( CLK_I : in  STD_LOGIC;
           -- VGA Output Signals
           VGA_HS_O         : out  STD_LOGIC; -- HSYNC OUT
           VGA_VS_O         : out  STD_LOGIC; -- VSYNC OUT
           VGA_RED_O        : out  STD_LOGIC_VECTOR (3 downto 0); -- Red signal going to the VGA interface
           VGA_GREEN_O      : out  STD_LOGIC_VECTOR (3 downto 0); -- Green signal going to the VGA interface
           VGA_BLUE_O       : out  STD_LOGIC_VECTOR (3 downto 0); -- Blue signal going to the VGA interface
           -- Mouse signals
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
end Vga;

architecture Behavioral of Vga is

-------------------------------------------------------------------------

-- Component Declarations

-------------------------------------------------------------------------


   -- To generate the 108 MHz Pixel Clock
   -- needed for a resolution of 1280*1024 pixels
--   COMPONENT PxlClkGen
--   PORT
--    (-- Clock in ports
--     CLK_IN1           : in std_logic;
--     -- Clock out ports
--     CLK_OUT1          : out std_logic;
--     -- Status and control signals
--     LOCKED            : out std_logic
--    );
--   END COMPONENT;
   
   -- Display the Mouse cursor
   COMPONENT MouseDisplay
   PORT (
      pixel_clk: in std_logic;
      xpos     : in std_logic_vector(11 downto 0); -- Mouse cursor X position
      ypos     : in std_logic_vector(11 downto 0); -- Mouse cursor Y position 

      hcount   : in std_logic_vector(11 downto 0);
      vcount   : in std_logic_vector(11 downto 0);
      --blank    : in std_logic; -- blank the screen in overlay mode, here is not used
      
      enable_mouse_display_out : out std_logic; -- When active, the mouse cursor signal is sent to the VGA display
      
      -- Output Red, blue and Green Signals
      red_out  : out std_logic_vector(3 downto 0);
      green_out: out std_logic_vector(3 downto 0);
      blue_out : out std_logic_vector(3 downto 0)
   );
  END COMPONENT;

-------------------------------------------------------------

-- BRAM Component Declaration

-------------------------------------------------------------
    
-- BRAM painting blocks

    COMPONENT Menu_modo_blocks
	Generic (char_H_LOC : natural := 200;
	         char_V_LOC : natural := 100);
    Port ( CLK_I        : in  STD_LOGIC;
           VSYNC_I      : in  STD_LOGIC;
           h_cntr_reg   : in std_logic_vector(11 downto 0);
           v_cntr_reg   : in std_logic_vector(11 downto 0);           
--           ACTIVE_I   : in  STD_LOGIC;
           OVERLAY_O    : out  STD_LOGIC
           );
    END COMPONENT;

    COMPONENT Time_blocks
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
    END COMPONENT;

    COMPONENT Navigation_blocks
	Generic (char_H_LOC : natural := 200;
	         char_V_LOC : natural := 100);
    Port ( CLK_I        : in  STD_LOGIC;
           VSYNC_I      : in  STD_LOGIC;
           h_cntr_reg   : in std_logic_vector(11 downto 0);
           v_cntr_reg   : in std_logic_vector(11 downto 0);           
--           ACTIVE_I   : in  STD_LOGIC;
           OVERLAY_O    : out  STD_LOGIC
           );
    END COMPONENT;

    COMPONENT Piezas_texto
	Generic (char_H_LOC : natural := 200;
	         char_V_LOC : natural := 100);
    Port ( CLK_I        : in  STD_LOGIC;
           VSYNC_I      : in  STD_LOGIC;
           h_cntr_reg   : in std_logic_vector(11 downto 0);
           v_cntr_reg   : in std_logic_vector(11 downto 0);           
--           ACTIVE_I   : in  STD_LOGIC;
           OVERLAY_O    : out  STD_LOGIC
           );
    END COMPONENT;

    COMPONENT Ventana_emergente_opciones
	Generic (char_H_LOC : natural := 200;
	         char_V_LOC : natural := 100);
    Port ( CLK_I        : in  STD_LOGIC;
           VSYNC_I      : in  STD_LOGIC;
           h_cntr_reg   : in std_logic_vector(11 downto 0);
           v_cntr_reg   : in std_logic_vector(11 downto 0);           
--           ACTIVE_I   : in  STD_LOGIC;
           OVERLAY_O    : out  STD_LOGIC
           );
    END COMPONENT;
    
    COMPONENT Ventana_emergente
    Generic (char_H_LOC : natural := 200;
	         char_V_LOC : natural := 100);
    Port ( CLK_I        : in  STD_LOGIC;
           VSYNC_I      : in  STD_LOGIC;
           h_cntr_reg   : in std_logic_vector(11 downto 0);
           v_cntr_reg   : in std_logic_vector(11 downto 0);           
--           ACTIVE_I   : in  STD_LOGIC;
           OVERLAY_O    : out  STD_LOGIC
           );
    END COMPONENT;

    COMPONENT Titulos_blocks
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
    END COMPONENT;

    COMPONENT Count_display
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
    END COMPONENT;
    
--    COMPONENT Button_detection
--    Port (pxl_clk         : in std_logic;
--          mode_sel        : in mode_sel_t;
--          MODE_CONFIG     : in std_logic_vector(1 downto 0);
--          TIME_CONFIG     : in std_logic_vector(2 downto 0);
--          INC_CONFIG      : in std_logic_vector(1 downto 0);
          
--          MOUSE_X_POS_REG : in std_logic_vector(11 downto 0);
--          MOUSE_Y_POS_REG : in std_logic_vector(11 downto 0);
          
--          OVER_CLASICO    : out std_logic;
--          OVER_RAPIDO     : out std_logic;
--          OVER_RELAMPAGO  : out std_logic;
--          OVER_BALA       : out std_logic;
            
--          OVER_T1         : out std_logic;
--          OVER_T2         : out std_logic;
--          OVER_T3         : out std_logic;
--          OVER_T4         : out std_logic;
--          OVER_T5         : out std_logic;
--          OVER_T6         : out std_logic;
            
--          OVER_I1         : out std_logic;
--          OVER_I2         : out std_logic;
--          OVER_I3         : out std_logic;
--          OVER_I4         : out std_logic;
            
--          OVER_ATRAS      : out std_logic;
--          OVER_JUGAR      : out std_logic;
            
--          OVER_SI         : out std_logic;
--          OVER_NO         : out std_logic
--          );
--    END COMPONENT;
    
--    COMPONENT VGA_load_manager
--    Port (pxl_clk    : in std_logic;
--          menu_state : in menu_state_t;
          
--          PRESET     : out std_logic;
--          LOAD_SEL   : out std_logic
--          );
--    END COMPONENT;
    
--    COMPONENT Selection_management
--    Port (pxl_clk            : in std_logic;
--          menu_state         : in menu_state_t;
--          MODE_CONFIG        : in std_logic_vector(1 downto 0);
--          TIME_CONFIG        : in std_logic_vector(2 downto 0);
--          INC_CONFIG         : in std_logic_vector(1 downto 0);
          
--          selected_clasico   : out std_logic;
--          selected_rapido    : out std_logic;
--          selected_relampago : out std_logic;
--          selected_bala      : out std_logic;
          
--          selected_2h_30m    : out std_logic;
--          selected_2h_1h_15m : out std_logic;
--          selected_2h_1h     : out std_logic;
--          selected_1h_30m    : out std_logic;
            
--          selected_60m       : out std_logic;
--          selected_50m       : out std_logic;
--          selected_40m       : out std_logic;
--          selected_30m       : out std_logic;
--          selected_20m       : out std_logic;
--          selected_10m       : out std_logic;
            
--          selected_10m_bz    : out std_logic;
--          selected_8m        : out std_logic;
--          selected_5m        : out std_logic;
--          selected_3m        : out std_logic;
            
--          selected_2m        : out std_logic;
--          selected_1m        : out std_logic;
            
--          selected_30s       : out std_logic;
--          selected_20s       : out std_logic;
--          selected_15s       : out std_logic;
--          selected_10s       : out std_logic;
            
--          selected_5s        : out std_logic;
--          selected_4s        : out std_logic;
--          selected_3s        : out std_logic;
--          selected_2s        : out std_logic;
            
--          selected_estandar  : out std_logic
--          );
--    END COMPONENT;

-------------------------------------------------------------

-- Signal declaration for BRAM Components

-------------------------------------------------------------



-------------------------------------------------------------

-- Signal declaration for block border color change

-------------------------------------------------------------

-- Mouse selected blocks
signal selected_clasico   : std_logic;
signal selected_rapido    : std_logic;
signal selected_relampago : std_logic;
signal selected_bala      : std_logic;

signal selected_2h_30m    : std_logic;
signal selected_2h_1h_15m : std_logic;
signal selected_2h_1h     : std_logic;
signal selected_1h_30m    : std_logic;

signal selected_60m       : std_logic;
signal selected_50m       : std_logic;
signal selected_40m       : std_logic;
signal selected_30m       : std_logic;
signal selected_20m       : std_logic;
signal selected_10m       : std_logic;

signal selected_10m_bz    : std_logic;
signal selected_8m        : std_logic;
signal selected_5m        : std_logic;
signal selected_3m        : std_logic;

signal selected_2m        : std_logic;
signal selected_1m        : std_logic;

signal selected_30s       : std_logic;
signal selected_20s       : std_logic;
signal selected_15s       : std_logic;
signal selected_10s       : std_logic;

signal selected_5s        : std_logic;
signal selected_4s        : std_logic;
signal selected_3s        : std_logic;
signal selected_2s        : std_logic;

signal selected_estandar  : std_logic;

-------------------------------------------------------------

-- Constants for various VGA Resolutions

-------------------------------------------------------------

--***640x480@60Hz***--  
--constant FRAME_WIDTH : natural := 640;
--constant FRAME_HEIGHT : natural := 480;

--constant H_FP : natural := 16; --H front porch width (pixels)
--constant H_PW : natural := 96; --H sync pulse width (pixels)
--constant H_MAX : natural := 800; --H total period (pixels)
--
--constant V_FP : natural := 10; --V front porch width (lines)
--constant V_PW : natural := 2; --V sync pulse width (lines)
--constant V_MAX : natural := 525; --V total period (lines)

--constant H_POL : std_logic := '0';
--constant V_POL : std_logic := '0';

--***800x600@60Hz***--
--constant FRAME_WIDTH : natural := 800;
--constant FRAME_HEIGHT : natural := 600;
--
--constant H_FP : natural := 40; --H front porch width (pixels)
--constant H_PW : natural := 128; --H sync pulse width (pixels)
--constant H_MAX : natural := 1056; --H total period (pixels)
--
--constant V_FP : natural := 1; --V front porch width (lines)
--constant V_PW : natural := 4; --V sync pulse width (lines)
--constant V_MAX : natural := 628; --V total period (lines)
--
--constant H_POL : std_logic := '1';
--constant V_POL : std_logic := '1';

--***1280x1024@60Hz***--
--constant FRAME_WIDTH : natural := 1280;
--constant FRAME_HEIGHT : natural := 1024;

--constant H_FP : natural := 48; --H front porch width (pixels)
--constant H_PW : natural := 112; --H sync pulse width (pixels)
--constant H_MAX : natural := 1688; --H total period (pixels)

--constant V_FP : natural := 1; --V front porch width (lines)
--constant V_PW : natural := 3; --V sync pulse width (lines)
--constant V_MAX : natural := 1066; --V total period (lines)

--constant H_POL : std_logic := '1';
--constant V_POL : std_logic := '1';

--***1920x1080@60Hz***--
constant FRAME_WIDTH : natural := 1920;
constant FRAME_HEIGHT : natural := 1080;

constant H_FP : natural := 88; --H front porch width (pixels)
constant H_PW : natural := 44; --H sync pulse width (pixels)
constant H_MAX : natural := 2200; --H total period (pixels)

constant V_FP : natural := 4; --V front porch width (lines)
constant V_PW : natural := 5; --V sync pulse width (lines)
constant V_MAX : natural := 1125; --V total period (lines)

constant H_POL : std_logic := '1';
constant V_POL : std_logic := '1';

------------------------------------------------------------------

-- Signals to manage the LOAD_SEL and PRESET states

------------------------------------------------------------------

signal PRESET_S   : std_logic;
signal LOAD_SEL_S : std_logic;
signal RONDA1     : std_logic := '1';

------------------------------------------------------------------

-- Constants for setting the displayed text size and coordinates

------------------------------------------------------------------

--Señal que contendrá el modo seleccionado 
signal mode_sel : mode_sel_t := MODO_NINGUNO;
signal modo_escogido : std_logic := '0';

signal tiempo_escogido            : std_logic := '0';

--Señales que se usarán para las elecciones de incremento
signal incremento_escogido        : std_logic := '0';

--Señales para los logos independientes de atras y jugar
signal atras_escogido             : std_logic := '0';
signal jugar_escogido             : std_logic := '0';

--Señales para determinar los turnos de los jugadores
signal turno_blancas              : std_logic := '0';
signal turno_negras               : std_logic := '0';

--Señal que guarda el estado del menú
signal menu_state : menu_state_t := MENU_INICIAL;

--Señal que sirve para limitar la cantidad de veces que se retrocede en el menú al pulsar el botón "ATRAS"
signal ATRAS_DISPONIBLE : std_logic := '1';

-- Señales para la configuración del selector de juego
signal MODE_CONFIG     : std_logic_vector (1 downto 0) := "00";
signal TIME_CONFIG     : std_logic_vector (2 downto 0) := "000";
signal INC_CONFIG      : std_logic_vector (1 downto 0) := "00";

-------------------------------------------------------------------------

-- Signal Declarations

-------------------------------------------------------------------------


-------------------------------------------------------------------------

-- VGA Controller specific signals: Counters, Sync, R, G, B

-------------------------------------------------------------------------
-- Pixel clock, in this case 108 MHz
signal pxl_clk : std_logic;
-- The active signal is used to signal the active region of the screen (when not blank)
signal active  : std_logic;

-- Horizontal and Vertical counters
signal h_cntr_reg : std_logic_vector(11 downto 0) := (others =>'0');
signal v_cntr_reg : std_logic_vector(11 downto 0) := (others =>'0');

-- Pipe Horizontal and Vertical Counters
signal h_cntr_reg_dly   : std_logic_vector(11 downto 0) := (others => '0');
signal v_cntr_reg_dly   : std_logic_vector(11 downto 0) := (others => '0');

-- Horizontal and Vertical Sync
signal h_sync_reg : std_logic := not(H_POL);
signal v_sync_reg : std_logic := not(V_POL);
-- Pipe Horizontal and Vertical Sync
signal h_sync_reg_dly : std_logic := not(H_POL);
signal v_sync_reg_dly : std_logic :=  not(V_POL);

-- VGA R, G and B signals coming from the main multiplexers
signal vga_red_cmb   : std_logic_vector(3 downto 0);
signal vga_green_cmb : std_logic_vector(3 downto 0);
signal vga_blue_cmb  : std_logic_vector(3 downto 0);
--The main VGA R, G and B signals, validated by active
signal vga_red    : std_logic_vector(3 downto 0);
signal vga_green  : std_logic_vector(3 downto 0);
signal vga_blue   : std_logic_vector(3 downto 0);
-- Register VGA R, G and B signals
signal vga_red_reg   : std_logic_vector(3 downto 0) := (others =>'0');
signal vga_green_reg : std_logic_vector(3 downto 0) := (others =>'0');
signal vga_blue_reg  : std_logic_vector(3 downto 0) := (others =>'0');

-------------------------------------------------------------------------

-- Signals for registering the mouse inputs

-------------------------------------------------------------------------

signal MOUSE_X_POS_REG         : std_logic_vector (11 downto 0);
signal MOUSE_Y_POS_REG         : std_logic_vector (11 downto 0);

signal MOUSE_X_PIXEL           : integer := 0;
signal MOUSE_Y_PIXEL           : integer := 0;

signal MOUSE_LEFT_BUTTON_ACT   : std_logic;
signal MOUSE_RIGHT_BUTTON_ACT  : std_logic;
signal MOUSE_MIDDLE_BUTTON_ACT : std_logic;

signal MOUSE_LEFT_BUTTON_PRE   : std_logic := '0';
signal MOUSE_RIGHT_BUTTON_PRE  : std_logic := '0';
signal MOUSE_MIDDLE_BUTTON_PRE : std_logic := '0';

-----------------------------------------------------------
-- Signals for generating the background (moving colorbar)
-----------------------------------------------------------

-- Colorbar red, greeen and blue signals
signal bg_red 			: std_logic_vector(3 downto 0);
signal bg_blue 			: std_logic_vector(3 downto 0);
signal bg_green 		: std_logic_vector(3 downto 0);
-- Pipe the colorbar red, green and blue signals
signal bg_red_dly		: std_logic_vector(3 downto 0) := (others => '0');
signal bg_green_dly		: std_logic_vector(3 downto 0) := (others => '0');
signal bg_blue_dly		: std_logic_vector(3 downto 0) := (others => '0');


-------------------------------------------------------------------------

-- Interconnection signals for the displaying components

-------------------------------------------------------------------------

-- Digilent and Analog Devices logo display signals
signal logo_red   : std_logic_vector(3 downto 0);
signal logo_blue  : std_logic_vector(3 downto 0);
signal logo_green : std_logic_vector(3 downto 0);
signal logo_on    : std_logic;

-- Mouse cursor display signals
signal mouse_cursor_red    : std_logic_vector (3 downto 0) := (others => '0');
signal mouse_cursor_blue   : std_logic_vector (3 downto 0) := (others => '0');
signal mouse_cursor_green  : std_logic_vector (3 downto 0) := (others => '0');
-- Mouse cursor enable display signals
signal enable_mouse_display:  std_logic;

-------------------------------------------------------------------------

-- Signals for the displaying BRAM modules

-------------------------------------------------------------------------

-- Constant block dimensions
constant MODO_MENU_WIDTH     : natural := 200;
constant TIME_INC_WIDTH      : natural := 160;
constant NAVIGATION_WIDTH    : natural := 140;
constant PIEZAS_WIDTH        : natural := 700;
constant VENTANA_OPC_WIDTH   : natural := 150;
constant VENTANA_TEXT_WIDTH  : natural := 400;
constant TITULOS_WIDTH       : natural := 950;
constant CUENTAS_WIDTH       : natural := 50;

constant MODO_MENU_HEIGHT    : natural := 80;
constant TIME_INC_HEIGHT     : natural := 80;
constant NAVIGATION_HEIGHT   : natural := 80;
constant PIEZAS_HEIGHT       : natural := 200;
constant VENTANA_OPC_HEIGHT  : natural := 90;
constant VENTANA_TEXT_HEIGHT : natural := 120;
constant TITULOS_HEIGHT      : natural := 220;
constant CUENTAS_HEIGHT      : natural := 140;

-- Overlay output signals
signal overlay_output_modo        : std_logic_vector(3 downto 0)  := (others => '0');
signal overlay_output_tiempo      : std_logic_vector(3 downto 0)  := (others => '0');
signal overlay_output_nav         : std_logic_vector(3 downto 0)  := (others => '0');
signal overlay_output_piezas      : std_logic_vector(3 downto 0)  := (others => '0');
signal overlay_output_ventana_opc : std_logic_vector(3 downto 0)  := (others => '0');
signal overlay_output_ventana_txt : std_logic_vector(3 downto 0)  := (others => '0');
signal overlay_output_ventana     : std_logic_vector(3 downto 0)  := (others => '0');
signal overlay_output_titulos     : std_logic_vector(3 downto 0)  := (others => '0');
signal overlay_output_cuenta1     : std_logic_vector(11 downto 0) := (others => '0');
signal overlay_output_cuenta2     : std_logic_vector(11 downto 0) := (others => '0');

-- Overlay BRAM signals
signal overlay_menu_modo   : std_logic;
signal overlay_time_inc    : std_logic;
signal overlay_navigation  : std_logic;
signal overlay_piezas      : std_logic;
signal overlay_ventana_opc : std_logic;
signal overlay_ventana_txt : std_logic;
signal overlay_titulos     : std_logic;
signal overlay_cuenta1     : std_logic;
signal overlay_cuenta2     : std_logic;

-- Overlay specific function to convert bits into colour
function overlay_color(overlay_bit : std_logic) return std_logic_vector is
begin
    if overlay_bit = '1' then
        return "0000";
    else
        return "1111";
    end if;
end function;

-- Overlay specific function to convert count numbers to red when the count reaches a certain value
function overlay_count_color(
    overlay_bit : std_logic; 
    cuenta      : std_logic_vector(27 downto 0)
    ) return std_logic_vector is
        variable r, g, b : std_logic_vector(3 downto 0);
begin
    if overlay_bit = '1' then
        if cuenta(27 downto 16) = "000000000000" and cuenta(15 downto 0) <= "0011000000000000" then
            r := "1111";
            g := "0000";
            b := "0000";
        else
            r := "0000";
            g := "0000";
            b := "0000";
        end if;
    else
        r := "1111";
        g := "1111";
        b := "1111";
    end if;
    
    return r & g & b;
end function;

-- Horizontal module counter signals
signal h_menu_modo_reg : std_logic_vector(11 downto 0);

-- Vertical module counter signals
signal v_menu_modo_reg : std_logic_vector(11 downto 0);

-- Declaración de las posiciones de cada bloque basados en la posición de referencia (genéricos de entrada)

-- Posiciones de referencia global
constant MENU_X_START       : integer := 200;
constant MENU_Y_START       : integer := 100;

-- Posiciones variables de las cuentas en la pantalla de juego
signal CUENTA1_X_START      : integer;
signal CUENTA2_X_START      : integer;

-- Bloque "MODO"
constant MODO_LEFT	        : natural := MENU_X_START;
constant MODO_RIGHT         : natural := MENU_X_START + MODO_MENU_WIDTH;
constant MODO_TOP	        : natural := MENU_Y_START + 230 - 1;
constant MODO_BOTTOM        : natural := MENU_Y_START + 230 + MODO_MENU_HEIGHT;

-- Bloque "TIEMPO"
constant TIEMPO_LEFT        : natural := MENU_X_START;
constant TIEMPO_RIGHT       : natural := MENU_X_START + MODO_MENU_WIDTH;
constant TIEMPO_TOP	        : natural := MENU_Y_START + 470 - 1;
constant TIEMPO_BOTTOM      : natural := MENU_Y_START + 470 + MODO_MENU_HEIGHT;

-- Bloque "INCREMENTO"
constant INCREMENTO_LEFT    : natural := MENU_X_START;
constant INCREMENTO_RIGHT   : natural := MENU_X_START + MODO_MENU_WIDTH;
constant INCREMENTO_TOP	    : natural := MENU_Y_START + 710 - 1;
constant INCREMENTO_BOTTOM  : natural := MENU_Y_START + 710 + MODO_MENU_HEIGHT;

-- Bloque "CLASICO"
constant CLASICO_LEFT	    : natural := MENU_X_START + MODO_LEFT + 133;
constant CLASICO_RIGHT      : natural := MENU_X_START + MODO_LEFT + 133 + MODO_MENU_WIDTH;
constant CLASICO_TOP	    : natural := MENU_Y_START + 230 - 1;
constant CLASICO_BOTTOM     : natural := MENU_Y_START + 230 + MODO_MENU_HEIGHT;

-- Bloque "RAPIDO"
constant RAPIDO_LEFT	    : natural := MENU_X_START + CLASICO_LEFT + 133 - 1;
constant RAPIDO_RIGHT       : natural := MENU_X_START + CLASICO_LEFT + 133 + MODO_MENU_WIDTH;
constant RAPIDO_TOP	        : natural := MENU_Y_START + 230 - 1;
constant RAPIDO_BOTTOM      : natural := MENU_Y_START + 230 + MODO_MENU_HEIGHT;

-- Bloque "RELAMPAGO"
constant RELAMPAGO_LEFT	    : natural := MENU_X_START + RAPIDO_LEFT + 133 - 1;
constant RELAMPAGO_RIGHT    : natural := MENU_X_START + RAPIDO_LEFT + 133 + MODO_MENU_WIDTH;
constant RELAMPAGO_TOP	    : natural := MENU_Y_START + 230 - 1;
constant RELAMPAGO_BOTTOM   : natural := MENU_Y_START + 230 + MODO_MENU_HEIGHT;

-- Bloque "BALA"
constant BALA_LEFT	        : natural := MENU_X_START + RELAMPAGO_LEFT + 133 - 1;
constant BALA_RIGHT         : natural := MENU_X_START + RELAMPAGO_LEFT + 133 + MODO_MENU_WIDTH;
constant BALA_TOP	        : natural := MENU_Y_START + 230 - 1;
constant BALA_BOTTOM        : natural := MENU_Y_START + 230 + MODO_MENU_HEIGHT;

-- CLÁSICO
-- Bloque "2h 30m"
constant TCLASICO1_LEFT	    : natural := MENU_X_START + 340;
constant TCLASICO1_RIGHT    : natural := MENU_X_START + 340 + TIME_INC_WIDTH;
constant TCLASICO1_TOP	    : natural := MENU_Y_START + 470 - 1;
constant TCLASICO1_BOTTOM   : natural := MENU_Y_START + 470 + TIME_INC_HEIGHT;

-- Bloque "2h + 1h + 15m"
constant TCLASICO2_LEFT	    : natural := MENU_X_START + 690;
constant TCLASICO2_RIGHT    : natural := MENU_X_START + 690 + TIME_INC_WIDTH;
constant TCLASICO2_TOP	    : natural := MENU_Y_START + 470 - 1;
constant TCLASICO2_BOTTOM   : natural := MENU_Y_START + 470 + TIME_INC_HEIGHT;

-- Bloque "2h + 1h"
constant TCLASICO3_LEFT	    : natural := MENU_X_START + 1015;
constant TCLASICO3_RIGHT    : natural := MENU_X_START + 1015 + TIME_INC_WIDTH;
constant TCLASICO3_TOP	    : natural := MENU_Y_START + 470 - 1;
constant TCLASICO3_BOTTOM   : natural := MENU_Y_START + 470 + TIME_INC_HEIGHT;

-- Bloque "1h 30m"
constant TCLASICO4_LEFT	    : natural := MENU_X_START + 1350;
constant TCLASICO4_RIGHT    : natural := MENU_X_START + 1350 + TIME_INC_WIDTH;
constant TCLASICO4_TOP	    : natural := MENU_Y_START + 470 - 1;
constant TCLASICO4_BOTTOM   : natural := MENU_Y_START + 470 + TIME_INC_HEIGHT;

-- RÁPIDO
-- Bloque "60m"
constant TRAPIDO1_LEFT	    : natural := MENU_X_START + 360;
constant TRAPIDO1_RIGHT     : natural := MENU_X_START + 360 + TIME_INC_WIDTH;
constant TRAPIDO1_TOP	    : natural := MENU_Y_START + 470 - 1;
constant TRAPIDO1_BOTTOM    : natural := MENU_Y_START + 470 + TIME_INC_HEIGHT;

-- Bloque "50m"
constant TRAPIDO2_LEFT	    : natural := MENU_X_START + 560;
constant TRAPIDO2_RIGHT     : natural := MENU_X_START + 560 + TIME_INC_WIDTH;
constant TRAPIDO2_TOP	    : natural := MENU_Y_START + 470 - 1;
constant TRAPIDO2_BOTTOM    : natural := MENU_Y_START + 470 + TIME_INC_HEIGHT;

-- Bloque "40m"
constant TRAPIDO3_LEFT	    : natural := MENU_X_START + 760;
constant TRAPIDO3_RIGHT     : natural := MENU_X_START + 760 + TIME_INC_WIDTH;
constant TRAPIDO3_TOP	    : natural := MENU_Y_START + 470 - 1;
constant TRAPIDO3_BOTTOM    : natural := MENU_Y_START + 470 + TIME_INC_HEIGHT;

-- Bloque "30m"
constant TRAPIDO4_LEFT	    : natural := MENU_X_START + 960;
constant TRAPIDO4_RIGHT     : natural := MENU_X_START + 960 + TIME_INC_WIDTH;
constant TRAPIDO4_TOP	    : natural := MENU_Y_START + 470 - 1;
constant TRAPIDO4_BOTTOM    : natural := MENU_Y_START + 470 + TIME_INC_HEIGHT;

-- Bloque "20m"
constant TRAPIDO5_LEFT	    : natural := MENU_X_START + 1160;
constant TRAPIDO5_RIGHT     : natural := MENU_X_START + 1160 + TIME_INC_WIDTH;
constant TRAPIDO5_TOP	    : natural := MENU_Y_START + 470 - 1;
constant TRAPIDO5_BOTTOM    : natural := MENU_Y_START + 470 + TIME_INC_HEIGHT;

-- Bloque "10m"
constant TRAPIDO6_LEFT	    : natural := MENU_X_START + 1360;
constant TRAPIDO6_RIGHT     : natural := MENU_X_START + 1360 + TIME_INC_WIDTH;
constant TRAPIDO6_TOP	    : natural := MENU_Y_START + 470 - 1;
constant TRAPIDO6_BOTTOM    : natural := MENU_Y_START + 470 + TIME_INC_HEIGHT;

-- RELÁMPAGO
-- Bloque "10m"
constant TRELAMPAGO1_LEFT   : natural := MENU_X_START + 340;
constant TRELAMPAGO1_RIGHT  : natural := MENU_X_START + 340 + TIME_INC_WIDTH;
constant TRELAMPAGO1_TOP	: natural := MENU_Y_START + 470 - 1;
constant TRELAMPAGO1_BOTTOM : natural := MENU_Y_START + 470 + TIME_INC_HEIGHT;

-- Bloque "8m"
constant TRELAMPAGO2_LEFT   : natural := MENU_X_START + 690;
constant TRELAMPAGO2_RIGHT  : natural := MENU_X_START + 690 + TIME_INC_WIDTH;
constant TRELAMPAGO2_TOP	: natural := MENU_Y_START + 470 - 1;
constant TRELAMPAGO2_BOTTOM : natural := MENU_Y_START + 470 + TIME_INC_HEIGHT;

-- Bloque "5m"
constant TRELAMPAGO3_LEFT   : natural := MENU_X_START + 1015;
constant TRELAMPAGO3_RIGHT  : natural := MENU_X_START + 1015 + TIME_INC_WIDTH;
constant TRELAMPAGO3_TOP	: natural := MENU_Y_START + 470 - 1;
constant TRELAMPAGO3_BOTTOM : natural := MENU_Y_START + 470 + TIME_INC_HEIGHT;

-- Bloque "3m"
constant TRELAMPAGO4_LEFT   : natural := MENU_X_START + 1350;
constant TRELAMPAGO4_RIGHT  : natural := MENU_X_START + 1350 + TIME_INC_WIDTH;
constant TRELAMPAGO4_TOP	: natural := MENU_Y_START + 470 - 1;
constant TRELAMPAGO4_BOTTOM : natural := MENU_Y_START + 470 + TIME_INC_HEIGHT;

-- BALA
-- Bloque "2m"
constant TBALA1_LEFT        : natural := MENU_X_START + 510;
constant TBALA1_RIGHT       : natural := MENU_X_START + 510 + TIME_INC_WIDTH;
constant TBALA1_TOP	        : natural := MENU_Y_START + 470 - 1;
constant TBALA1_BOTTOM      : natural := MENU_Y_START + 470 + TIME_INC_HEIGHT;

-- Bloque "1m"
constant TBALA2_LEFT        : natural := MENU_X_START + 1110;
constant TBALA2_RIGHT       : natural := MENU_X_START + 1110 + TIME_INC_WIDTH;
constant TBALA2_TOP	        : natural := MENU_Y_START + 470 - 1;
constant TBALA2_BOTTOM      : natural := MENU_Y_START + 470 + TIME_INC_HEIGHT;

-- CLÁSICO
-- Bloque "Estandar"
constant ICLASICO1_LEFT	    : natural := MENU_X_START + 810;
constant ICLASICO1_RIGHT    : natural := MENU_X_START + 810 + TIME_INC_WIDTH;
constant ICLASICO1_TOP	    : natural := MENU_Y_START + 710 - 1;
constant ICLASICO1_BOTTOM   : natural := MENU_Y_START + 710 + TIME_INC_HEIGHT;

-- RÁPIDO
-- Bloque "30s"
constant IRAPIDO1_LEFT	    : natural := MENU_X_START + 340;
constant IRAPIDO1_RIGHT     : natural := MENU_X_START + 340 + TIME_INC_WIDTH;
constant IRAPIDO1_TOP	    : natural := MENU_Y_START + 710 - 1;
constant IRAPIDO1_BOTTOM    : natural := MENU_Y_START + 710 + TIME_INC_HEIGHT;

-- Bloque "20s"
constant IRAPIDO2_LEFT	    : natural := MENU_X_START + 690;
constant IRAPIDO2_RIGHT     : natural := MENU_X_START + 690 + TIME_INC_WIDTH;
constant IRAPIDO2_TOP	    : natural := MENU_Y_START + 710 - 1;
constant IRAPIDO2_BOTTOM    : natural := MENU_Y_START + 710 + TIME_INC_HEIGHT;

-- Bloque "15s"
constant IRAPIDO3_LEFT	    : natural := MENU_X_START + 1015;
constant IRAPIDO3_RIGHT     : natural := MENU_X_START + 1015 + TIME_INC_WIDTH;
constant IRAPIDO3_TOP	    : natural := MENU_Y_START + 710 - 1;
constant IRAPIDO3_BOTTOM    : natural := MENU_Y_START + 710 + TIME_INC_HEIGHT;

-- Bloque "10s"
constant IRAPIDO4_LEFT	    : natural := MENU_X_START + 1350;
constant IRAPIDO4_RIGHT     : natural := MENU_X_START + 1350 + TIME_INC_WIDTH;
constant IRAPIDO4_TOP	    : natural := MENU_Y_START + 710 - 1;
constant IRAPIDO4_BOTTOM    : natural := MENU_Y_START + 710 + TIME_INC_HEIGHT;

-- RELÁMPAGO
-- Bloque "5s"
constant IRELAMPAGO1_LEFT   : natural := MENU_X_START + 340;
constant IRELAMPAGO1_RIGHT  : natural := MENU_X_START + 340 + TIME_INC_WIDTH;
constant IRELAMPAGO1_TOP	: natural := MENU_Y_START + 710 - 1;
constant IRELAMPAGO1_BOTTOM : natural := MENU_Y_START + 710 + TIME_INC_HEIGHT;

-- Bloque "4s"
constant IRELAMPAGO2_LEFT   : natural := MENU_X_START + 690;
constant IRELAMPAGO2_RIGHT  : natural := MENU_X_START + 690 + TIME_INC_WIDTH;
constant IRELAMPAGO2_TOP	: natural := MENU_Y_START + 710 - 1;
constant IRELAMPAGO2_BOTTOM : natural := MENU_Y_START + 710 + TIME_INC_HEIGHT;

-- Bloque "3s"
constant IRELAMPAGO3_LEFT   : natural := MENU_X_START + 1015;
constant IRELAMPAGO3_RIGHT  : natural := MENU_X_START + 1015 + TIME_INC_WIDTH;
constant IRELAMPAGO3_TOP	: natural := MENU_Y_START + 710 - 1;
constant IRELAMPAGO3_BOTTOM : natural := MENU_Y_START + 710 + TIME_INC_HEIGHT;

-- Bloque "2s"
constant IRELAMPAGO4_LEFT   : natural := MENU_X_START + 1350;
constant IRELAMPAGO4_RIGHT  : natural := MENU_X_START + 1350 + TIME_INC_WIDTH;
constant IRELAMPAGO4_TOP	: natural := MENU_Y_START + 710 - 1;
constant IRELAMPAGO4_BOTTOM : natural := MENU_Y_START + 710 + TIME_INC_HEIGHT;

-- BALA
-- Bloque "Estandar"
constant IBALA1_LEFT        : natural := MENU_X_START + 810;
constant IBALA1_RIGHT       : natural := MENU_X_START + 810 + TIME_INC_WIDTH;
constant IBALA1_TOP	        : natural := MENU_Y_START + 710 - 1;
constant IBALA1_BOTTOM      : natural := MENU_Y_START + 710 + TIME_INC_HEIGHT;

-- Bloque "ATRAS"
constant ATRAS_LEFT         : natural := MENU_X_START + 20;
constant ATRAS_RIGHT        : natural := MENU_X_START + 20 + NAVIGATION_WIDTH;
constant ATRAS_TOP	        : natural := MENU_Y_START + 840 - 1;
constant ATRAS_BOTTOM       : natural := MENU_Y_START + 840 + NAVIGATION_HEIGHT;

-- Bloque "JUGAR"
constant JUGAR_LEFT         : natural := MENU_X_START + 690;
constant JUGAR_RIGHT        : natural := MENU_X_START + 690 + NAVIGATION_WIDTH;
constant JUGAR_TOP	        : natural := MENU_Y_START + 840 - 1;
constant JUGAR_BOTTOM       : natural := MENU_Y_START + 840 + NAVIGATION_HEIGHT;

-- Bloque "PIEZAS BLANCAS"
constant BLANCAS_LEFT	    : natural := MENU_X_START + 20;
constant BLANCAS_RIGHT      : natural := MENU_X_START + 20 + PIEZAS_WIDTH;
constant BLANCAS_TOP	    : natural := MENU_Y_START + 200 - 1;
constant BLANCAS_BOTTOM     : natural := MENU_Y_START + 200 + PIEZAS_HEIGHT;

-- Bloque "PIEZAS NEGRAS"
constant NEGRAS_LEFT	    : natural := MENU_X_START + 800;
constant NEGRAS_RIGHT       : natural := MENU_X_START + 800 + PIEZAS_WIDTH;
constant NEGRAS_TOP	        : natural := MENU_Y_START + 200 - 1;
constant NEGRAS_BOTTOM      : natural := MENU_Y_START + 200 + PIEZAS_HEIGHT;

-- Opción "SI"
constant SI_LEFT	        : natural := MENU_X_START + 485;
constant SI_RIGHT           : natural := MENU_X_START + 485 + VENTANA_OPC_WIDTH;
constant SI_TOP	            : natural := MENU_Y_START + 570 - 1;
constant SI_BOTTOM          : natural := MENU_Y_START + 570 + VENTANA_OPC_HEIGHT;

-- Opción "NO"
constant NO_LEFT	        : natural := MENU_X_START + 885;
constant NO_RIGHT           : natural := MENU_X_START + 885 + VENTANA_OPC_WIDTH;
constant NO_TOP	            : natural := MENU_Y_START + 570 - 1;
constant NO_BOTTOM          : natural := MENU_Y_START + 570 + VENTANA_OPC_HEIGHT;

-- Texto de ventana emergente
constant VENTANA_LEFT	    : natural := MENU_X_START + 560;
constant VENTANA_RIGHT      : natural := MENU_X_START + 560 + VENTANA_TEXT_WIDTH;
constant VENTANA_TOP	    : natural := MENU_Y_START + 200 - 1;
constant VENTANA_BOTTOM     : natural := MENU_Y_START + 200 + VENTANA_TEXT_HEIGHT;

-- "MENU DE AJEDREZ"
constant TITULO_LEFT	    : natural := MENU_X_START + 285;
constant TITULO_RIGHT       : natural := MENU_X_START + 285 + TITULOS_WIDTH;
constant TITULO_TOP	        : natural := MENU_Y_START - 60 - 1;
constant TITULO_BOTTOM      : natural := MENU_Y_START - 60 + TITULOS_HEIGHT;

-- POSICIONES PARA LA CUENTA DE JUGADOR 1 (BLANCAS)
-- Unidades de horas
constant UHORAS1_LEFT	         : natural := CUENTA1_X_START - 1;
constant UHORAS1_RIGHT           : natural := CUENTA1_X_START + CUENTAS_WIDTH;
constant UHORAS1_TOP	         : natural := MENU_Y_START + 600 - 1;
constant UHORAS1_BOTTOM          : natural := MENU_Y_START + 600 + CUENTAS_HEIGHT;

-- Dos puntos horas-minutos
constant PUNTOS_HORASMIN1_LEFT	 : natural := UHORAS1_RIGHT - 1;
constant PUNTOS_HORASMIN1_RIGHT  : natural := UHORAS1_RIGHT + CUENTAS_WIDTH;
constant PUNTOS_HORASMIN1_TOP	 : natural := MENU_Y_START + 600 - 1;
constant PUNTOS_HORASMIN1_BOTTOM : natural := MENU_Y_START + 600 + CUENTAS_HEIGHT;

-- Decenas de minutos
constant DMINUTOS1_LEFT          : natural := PUNTOS_HORASMIN1_RIGHT - 1;
constant DMINUTOS1_RIGHT         : natural := PUNTOS_HORASMIN1_RIGHT + CUENTAS_WIDTH;
constant DMINUTOS1_TOP	         : natural := MENU_Y_START + 600 - 1;
constant DMINUTOS1_BOTTOM        : natural := MENU_Y_START + 600 + CUENTAS_HEIGHT;

-- Unidades de minutos
constant UMINUTOS1_LEFT          : natural := DMINUTOS1_RIGHT - 1;
constant UMINUTOS1_RIGHT         : natural := DMINUTOS1_RIGHT + CUENTAS_WIDTH;
constant UMINUTOS1_TOP	         : natural := MENU_Y_START + 600 - 1;
constant UMINUTOS1_BOTTOM        : natural := MENU_Y_START + 600 + CUENTAS_HEIGHT;

-- Dos puntos minutos-segundos
constant PUNTOS_MINSEG1_LEFT	 : natural := UMINUTOS1_RIGHT - 1;
constant PUNTOS_MINSEG1_RIGHT    : natural := UMINUTOS1_RIGHT + CUENTAS_WIDTH;
constant PUNTOS_MINSEG1_TOP	     : natural := MENU_Y_START + 600 - 1;
constant PUNTOS_MINSEG1_BOTTOM   : natural := MENU_Y_START + 600 + CUENTAS_HEIGHT;

-- Decenas de segundo
constant DSEG1_LEFT	             : natural := PUNTOS_MINSEG1_RIGHT - 1;
constant DSEG1_RIGHT             : natural := PUNTOS_MINSEG1_RIGHT + CUENTAS_WIDTH;
constant DSEG1_TOP	             : natural := MENU_Y_START + 600 - 1;
constant DSEG1_BOTTOM            : natural := MENU_Y_START + 600 + CUENTAS_HEIGHT;

-- Unidades de segundo
constant USEG1_LEFT	             : natural := DSEG1_RIGHT - 1;
constant USEG1_RIGHT             : natural := DSEG1_RIGHT + CUENTAS_WIDTH;
constant USEG1_TOP	             : natural := MENU_Y_START + 600 - 1;
constant USEG1_BOTTOM            : natural := MENU_Y_START + 600 + CUENTAS_HEIGHT;

-- Punto minutos-segundos
constant PUNTO1_LEFT	         : natural := USEG1_RIGHT - 1;
constant PUNTO1_RIGHT            : natural := USEG1_RIGHT + CUENTAS_WIDTH;
constant PUNTO1_TOP	             : natural := MENU_Y_START + 600 - 1;
constant PUNTO1_BOTTOM           : natural := MENU_Y_START + 600 + CUENTAS_HEIGHT;

-- Decimas
constant DECIMAS1_LEFT	         : natural := PUNTO1_RIGHT - 1;
constant DECIMAS1_RIGHT          : natural := PUNTO1_RIGHT + CUENTAS_WIDTH;
constant DECIMAS1_TOP	         : natural := MENU_Y_START + 600 - 1;
constant DECIMAS1_BOTTOM         : natural := MENU_Y_START + 600 + CUENTAS_HEIGHT;

-- Centesimas
constant CENTESIMAS1_LEFT        : natural := DECIMAS1_RIGHT - 1;
constant CENTESIMAS1_RIGHT       : natural := DECIMAS1_RIGHT + CUENTAS_WIDTH;
constant CENTESIMAS1_TOP	     : natural := MENU_Y_START + 600 - 1;
constant CENTESIMAS1_BOTTOM      : natural := MENU_Y_START + 600 + CUENTAS_HEIGHT;

-- POSICIONES PARA LA CUENTA DE JUGADOR 2 (NEGRAS)
-- Unidades de horas
constant UHORAS2_LEFT	         : natural := CUENTA2_X_START - 1;
constant UHORAS2_RIGHT           : natural := CUENTA2_X_START + CUENTAS_WIDTH;
constant UHORAS2_TOP	         : natural := MENU_Y_START + 600 - 1;
constant UHORAS2_BOTTOM          : natural := MENU_Y_START + 600 + CUENTAS_HEIGHT;

-- Dos puntos horas-minutos
constant PUNTOS_HORASMIN2_LEFT	 : natural := UHORAS2_RIGHT - 1;
constant PUNTOS_HORASMIN2_RIGHT  : natural := UHORAS2_RIGHT + CUENTAS_WIDTH;
constant PUNTOS_HORASMIN2_TOP	 : natural := MENU_Y_START + 600 - 1;
constant PUNTOS_HORASMIN2_BOTTOM : natural := MENU_Y_START + 600 + CUENTAS_HEIGHT;

-- Decenas de minutos
constant DMINUTOS2_LEFT          : natural := PUNTOS_HORASMIN2_RIGHT - 1;
constant DMINUTOS2_RIGHT         : natural := PUNTOS_HORASMIN2_RIGHT + CUENTAS_WIDTH;
constant DMINUTOS2_TOP	         : natural := MENU_Y_START + 600 - 1;
constant DMINUTOS2_BOTTOM        : natural := MENU_Y_START + 600 + CUENTAS_HEIGHT;

-- Unidades de minutos
constant UMINUTOS2_LEFT          : natural := DMINUTOS2_RIGHT - 1;
constant UMINUTOS2_RIGHT         : natural := DMINUTOS2_RIGHT + CUENTAS_WIDTH;
constant UMINUTOS2_TOP	         : natural := MENU_Y_START + 600 - 1;
constant UMINUTOS2_BOTTOM        : natural := MENU_Y_START + 600 + CUENTAS_HEIGHT;

-- Dos puntos minutos-segundos
constant PUNTOS_MINSEG2_LEFT	 : natural := UMINUTOS2_RIGHT - 1;
constant PUNTOS_MINSEG2_RIGHT    : natural := UMINUTOS2_RIGHT + CUENTAS_WIDTH;
constant PUNTOS_MINSEG2_TOP	     : natural := MENU_Y_START + 600 - 1;
constant PUNTOS_MINSEG2_BOTTOM   : natural := MENU_Y_START + 600 + CUENTAS_HEIGHT;

-- Decenas de segundo
constant DSEG2_LEFT	             : natural := PUNTOS_MINSEG2_RIGHT - 1;
constant DSEG2_RIGHT             : natural := PUNTOS_MINSEG2_RIGHT + CUENTAS_WIDTH;
constant DSEG2_TOP	             : natural := MENU_Y_START + 600 - 1;
constant DSEG2_BOTTOM            : natural := MENU_Y_START + 600 + CUENTAS_HEIGHT;

-- Unidades de segundo
constant USEG2_LEFT	             : natural := DSEG2_RIGHT - 1;
constant USEG2_RIGHT             : natural := DSEG2_RIGHT + CUENTAS_WIDTH;
constant USEG2_TOP	             : natural := MENU_Y_START + 600 - 1;
constant USEG2_BOTTOM            : natural := MENU_Y_START + 600 + CUENTAS_HEIGHT;

-- Punto minutos-segundos
constant PUNTO2_LEFT	         : natural := USEG2_RIGHT - 1;
constant PUNTO2_RIGHT            : natural := USEG2_RIGHT + CUENTAS_WIDTH;
constant PUNTO2_TOP	             : natural := MENU_Y_START + 600 - 1;
constant PUNTO2_BOTTOM           : natural := MENU_Y_START + 600 + CUENTAS_HEIGHT;

-- Decimas
constant DECIMAS2_LEFT	         : natural := PUNTO2_RIGHT - 1;
constant DECIMAS2_RIGHT          : natural := PUNTO2_RIGHT + CUENTAS_WIDTH;
constant DECIMAS2_TOP	         : natural := MENU_Y_START + 600 - 1;
constant DECIMAS2_BOTTOM         : natural := MENU_Y_START + 600 + CUENTAS_HEIGHT;

-- Centesimas
constant CENTESIMAS2_LEFT        : natural := DECIMAS2_RIGHT - 1;
constant CENTESIMAS2_RIGHT       : natural := DECIMAS2_RIGHT + CUENTAS_WIDTH;
constant CENTESIMAS2_TOP	     : natural := MENU_Y_START + 600 - 1;
constant CENTESIMAS2_BOTTOM      : natural := MENU_Y_START + 600 + CUENTAS_HEIGHT;

-- Señales para la gestión del proceso geométrico
-- MODOS
signal OVER_CLASICO              : std_logic;
signal OVER_RAPIDO               : std_logic;
signal OVER_RELAMPAGO            : std_logic;
signal OVER_BALA                 : std_logic;

-- TIEMPOS
signal OVER_T1                   : std_logic;
signal OVER_T2                   : std_logic;
signal OVER_T3                   : std_logic;
signal OVER_T4                   : std_logic;
signal OVER_T5                   : std_logic;
signal OVER_T6                   : std_logic;

-- INCREMENTOS
signal OVER_I1                   : std_logic;
signal OVER_I2                   : std_logic;
signal OVER_I3                   : std_logic;
signal OVER_I4                   : std_logic;

-- GENERALES
signal OVER_ATRAS                : std_logic;
signal OVER_JUGAR                : std_logic;

-- VENTANA DE PAUSA
signal OVER_SI                   : std_logic;
signal OVER_NO                   : std_logic;

---------------------------------------------------------------------------------

-- Pipe all of the interconnection signals coming from the displaying components

---------------------------------------------------------------------------------

-- Registered Digilent and Analog Devices logo display signals
signal logo_red_dly			: std_logic_vector(3 downto 0);
signal logo_blue_dly 		: std_logic_vector(3 downto 0);
signal logo_green_dly 		: std_logic_vector(3 downto 0);

-- Registered Mouse cursor display signals
signal mouse_cursor_red_dly   : std_logic_vector (3 downto 0) := (others => '0');
signal mouse_cursor_blue_dly  : std_logic_vector (3 downto 0) := (others => '0');
signal mouse_cursor_green_dly : std_logic_vector (3 downto 0) := (others => '0');

-- Registered Mouse cursor enable display signals
signal enable_mouse_display_dly  :  std_logic;


begin
  
  pxl_clk <= CLK_I; 
    
--LEDs que se encienden según el estado de menu_state
MENU_STATE_LED <= "000001" when menu_state = MENU_INICIAL else
                  "000010" when menu_state = MODO_ELEGIDO else
                  "000100" when menu_state = TIEMPO_ELEGIDO else
                  "001000" when menu_state = LISTO_PARA_JUGAR else
                  "010000" when menu_state = JUEGO_COMENZADO else
                  "100000" when menu_state = JUEGO_PAUSADO else
                  "000000";  

------------------------------------

-- Generate the 108 MHz pixel clock 

------------------------------------
--   Inst_PxlClkGen: PxlClkGen
--   port map
--    (-- Clock in ports
--     CLK_IN1   => CLK_I,
--     -- Clock out ports
--     CLK_OUT1  => pxl_clk,
--     -- Status and control signals
--     LOCKED   => open
--    );

---------------------------------------------------------------

-- Generate Horizontal, Vertical counters and the Sync signals

---------------------------------------------------------------
  -- Horizontal counter
  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then
      if (h_cntr_reg = (H_MAX - 1)) then
        h_cntr_reg <= (others =>'0');
      else
        h_cntr_reg <= h_cntr_reg + 1;
      end if;
    end if;
  end process;
  -- Vertical counter
  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then
      if ((h_cntr_reg = (H_MAX - 1)) and (v_cntr_reg = (V_MAX - 1))) then
        v_cntr_reg <= (others =>'0');
      elsif (h_cntr_reg = (H_MAX - 1)) then
        v_cntr_reg <= v_cntr_reg + 1;
      end if;
    end if;
  end process;
  -- Horizontal sync
  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then
      if (h_cntr_reg >= (H_FP + FRAME_WIDTH - 1)) and (h_cntr_reg < (H_FP + FRAME_WIDTH + H_PW - 1)) then
        h_sync_reg <= H_POL;
      else
        h_sync_reg <= not(H_POL);
      end if;
    end if;
  end process;
  -- Vertical sync
  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then
      if (v_cntr_reg >= (V_FP + FRAME_HEIGHT - 1)) and (v_cntr_reg < (V_FP + FRAME_HEIGHT + V_PW - 1)) then
        v_sync_reg <= V_POL;
      else
        v_sync_reg <= not(V_POL);
      end if;
    end if;
  end process;
  
--------------------

-- The active 

--------------------  
  -- active signal
  active <= '1' when h_cntr_reg < FRAME_WIDTH and v_cntr_reg < FRAME_HEIGHT
            else '0';

--------------------

-- Register Inputs

--------------------
register_inputs: process (pxl_clk, v_sync_reg)
    
  begin
    if (rising_edge(pxl_clk)) then
     MOUSE_X_POS_REG <= MOUSE_X_POS;
     MOUSE_Y_POS_REG <= MOUSE_Y_POS;
     
     MOUSE_X_PIXEL  <= to_integer(unsigned(MOUSE_X_POS_REG));
     MOUSE_Y_PIXEL  <= to_integer(unsigned(MOUSE_Y_POS_REG));
    end if;
end process register_inputs;

-- Procesos para hacer la posición dinámica de las cuentas en función de la misma cuenta
-- Cuenta de jugador 1
process(CUENTA_BLANCAS)
begin
    if CUENTA_BLANCAS(27 downto 24) = "0000" then
        if CUENTA_BLANCAS(27 downto 16) = "000000000000" then
            CUENTA1_X_START <= 180;
        else
            CUENTA1_X_START <= 270;
        end if;
    else
        CUENTA1_X_START <= 320;
    end if;
end process;

-- Cuenta de jugador 2
process(CUENTA_NEGRAS)
begin
    if CUENTA_NEGRAS(27 downto 24) = "0000" then
        if CUENTA_NEGRAS(27 downto 16) = "000000000000" then
            CUENTA2_X_START <= 1000;
        else
            CUENTA2_X_START <= 1090;
        end if;
    else
        CUENTA2_X_START <= 1140;
    end if;
end process;

-- Proceso para calcular posiciones relativas del ratón frente a los botones
process(pxl_clk)
    variable mx : integer;
    variable my : integer;
begin
    if rising_edge(pxl_clk) then
    
        mx := conv_integer(MOUSE_X_POS_REG); --Variable que permite identificar la posición en X del ratón
        my := conv_integer(MOUSE_Y_POS_REG); --Variable que permite identificar la posición en Y del ratón
        
        -- Se inicializan a 0 las señales de detección de los botones
        -- MODOS
        OVER_CLASICO   <= '0';
        OVER_RAPIDO    <= '0';
        OVER_RELAMPAGO <= '0';
        OVER_BALA      <= '0';
        
        -- TIEMPOS
        OVER_T1        <= '0';
        OVER_T2        <= '0';
        OVER_T3        <= '0';
        OVER_T4        <= '0';
        OVER_T5        <= '0';
        OVER_T6        <= '0';
        
        -- TIEMPOS
        OVER_I1        <= '0';
        OVER_I2        <= '0';
        OVER_I3        <= '0';
        OVER_I4        <= '0';
        
        -- GENERALES
        OVER_ATRAS     <= '0';
        OVER_JUGAR     <= '0';

        -- VENTANA DE PAUSA
        OVER_SI        <= '0';
        OVER_NO        <= '0';
        
        -- MODOS
        if (mx >= CLASICO_LEFT      and mx <= CLASICO_RIGHT   and my >= CLASICO_TOP   and my <= CLASICO_BOTTOM) then 
            OVER_CLASICO   <= '1';
        elsif (mx >= RAPIDO_LEFT    and mx <= RAPIDO_RIGHT    and my >= RAPIDO_TOP    and my <= RAPIDO_BOTTOM) then
            OVER_RAPIDO    <= '1';
        elsif (mx >= RELAMPAGO_LEFT and mx <= RELAMPAGO_RIGHT and my >= RELAMPAGO_TOP and my <= RELAMPAGO_BOTTOM) then
            OVER_RELAMPAGO <= '1';
        elsif (mx >= BALA_LEFT      and mx <= BALA_RIGHT      and my >= BALA_TOP      and my <= BALA_BOTTOM) then
            OVER_BALA      <= '1';
        end if;
        
        -- TIEMPOS
        if mode_sel = MODO_CLASICO or mode_sel = MODO_RELAMPAGO then
            if (mx >= TCLASICO1_LEFT and mx <= TCLASICO1_RIGHT and my >= TCLASICO1_TOP and my <= TCLASICO1_BOTTOM) then 
                OVER_T1 <= '1';
            elsif (mx >= TCLASICO2_LEFT and mx <= TCLASICO2_RIGHT and my >= TCLASICO2_TOP and my <= TCLASICO2_BOTTOM) then
                OVER_T2 <= '1';
            elsif (mx >= TCLASICO3_LEFT and mx <= TCLASICO3_RIGHT and my >= TCLASICO3_TOP and my <= TCLASICO3_BOTTOM) then
                OVER_T3 <= '1';
            elsif (mx >= TCLASICO4_LEFT and mx <= TCLASICO4_RIGHT and my >= TCLASICO4_TOP and my <= TCLASICO4_BOTTOM) then
                OVER_T4 <= '1';
            end if;
            
        elsif mode_sel = MODO_RAPIDO then
            if (mx >= TRAPIDO1_LEFT and mx <= TRAPIDO1_RIGHT and my >= TRAPIDO1_TOP and my <= TRAPIDO1_BOTTOM) then 
                OVER_T1 <= '1';
            elsif (mx >= TRAPIDO2_LEFT and mx <= TRAPIDO2_RIGHT and my >= TRAPIDO2_TOP and my <= TRAPIDO2_BOTTOM) then
                OVER_T2 <= '1';
            elsif (mx >= TRAPIDO3_LEFT and mx <= TRAPIDO3_RIGHT and my >= TRAPIDO3_TOP and my <= TRAPIDO3_BOTTOM) then
                OVER_T3 <= '1';
            elsif (mx >= TRAPIDO4_LEFT and mx <= TRAPIDO4_RIGHT and my >= TRAPIDO4_TOP and my <= TRAPIDO4_BOTTOM) then
                OVER_T4 <= '1';
            elsif (mx >= TRAPIDO5_LEFT and mx <= TRAPIDO5_RIGHT and my >= TRAPIDO5_TOP and my <= TRAPIDO5_BOTTOM) then
                OVER_T5 <= '1';
            elsif (mx >= TRAPIDO6_LEFT and mx <= TRAPIDO6_RIGHT and my >= TRAPIDO6_TOP and my <= TRAPIDO6_BOTTOM) then
                OVER_T6 <= '1';
            end if;
        
        elsif mode_sel = MODO_BALA then
            if (mx >= TBALA1_LEFT and mx <= TBALA1_RIGHT and my >= TBALA1_TOP and my <= TBALA1_BOTTOM) then
                OVER_T1 <= '1';
            elsif (mx >= TBALA2_LEFT and mx <= TBALA2_RIGHT and my >= TBALA2_TOP and my <= TBALA2_BOTTOM) then
                OVER_T2 <= '1';
            end if;
        end if;
            
        -- INCREMENTOS
        if mode_sel = MODO_CLASICO or mode_sel = MODO_BALA or ((mode_sel = MODO_RAPIDO or mode_sel = MODO_RELAMPAGO) and TIME_CONFIG = "000") then
            if (mx >= ICLASICO1_LEFT and mx <= ICLASICO1_RIGHT and my >= ICLASICO1_TOP and my <= ICLASICO1_BOTTOM) then 
                OVER_I1 <= '1';
            end if;
            
        elsif (mode_sel = MODO_RAPIDO or mode_sel = MODO_RELAMPAGO) and TIME_CONFIG /= "000" then
            if (mx >= IRAPIDO4_LEFT and mx <= IRAPIDO4_RIGHT and my >= IRAPIDO4_TOP and my <= IRAPIDO4_BOTTOM) then
                OVER_I4 <= '1';
            elsif not (mode_sel = MODO_RELAMPAGO and TIME_CONFIG = "010") and not (mode_sel = MODO_RAPIDO and TIME_CONFIG = "001") then
                if (mx >= IRAPIDO3_LEFT and mx <= IRAPIDO3_RIGHT and my >= IRAPIDO3_TOP and my <= IRAPIDO3_BOTTOM) then
                    OVER_I3 <= '1';
                elsif (mx >= IRAPIDO2_LEFT and mx <= IRAPIDO2_RIGHT and my >= IRAPIDO2_TOP and my <= IRAPIDO2_BOTTOM) then
                    OVER_I2 <= '1';
                elsif (mx >= IRAPIDO1_LEFT and mx <= IRAPIDO1_RIGHT and my >= IRAPIDO1_TOP and my <= IRAPIDO1_BOTTOM) then
                    if not (mode_sel = MODO_RAPIDO and TIME_CONFIG = "010") then
                        OVER_I1 <= '1';
                    end if;
                end if;    
            end if;
        end if;
        
        -- ATRAS
        if (mx >= ATRAS_LEFT and mx <= ATRAS_RIGHT and my >= ATRAS_TOP and my <= ATRAS_BOTTOM) then
            OVER_ATRAS <= '1';
        end if;
        
        -- JUGAR
        if (mx >= JUGAR_LEFT and mx <= JUGAR_RIGHT and my >= JUGAR_TOP and my <= JUGAR_BOTTOM) then
            OVER_JUGAR <= '1';
        end if;
        
        -- SI
        if (mx >= SI_LEFT and mx <= SI_RIGHT and my >= SI_TOP and my <= SI_BOTTOM) then
            OVER_SI <= '1';
        end if;
        
        -- NO
        if (mx >= NO_LEFT and mx <= NO_RIGHT and my >= NO_TOP and my <= NO_BOTTOM) then
            OVER_NO <= '1';
        end if;   
    end if;
end process;

-- Proceso que gestiona PRESET y LOAD_SEL
process(pxl_clk)
    variable ciclos : integer range 0 to 3 := 0;
begin
    if rising_edge(pxl_clk) then
        -- Valores por defecto (Estado de reposo)
        PRESET_S   <= '0';
        LOAD_SEL_S <= '0';

        case menu_state is
            when MENU_INICIAL =>
                PRESET_S <= '1';

            when LISTO_PARA_JUGAR =>
                if RONDA1 = '1' then
                    if ciclos < 4 then
                        LOAD_SEL_S <= not LOAD_SEL_S;
                        ciclos := ciclos + 1;
                    else
                        LOAD_SEL_S <= '0';
                    end if;
                else
                    LOAD_SEL_S <= '1';
                end if;

            when others =>
                -- Mantenemos las señales en '0' para evitar disparos accidentales
                PRESET_S   <= '0';
                LOAD_SEL_S <= '0';
        end case;
    end if;
end process;

-- Asignación de los valores de LOAD_SEL y PRESET a las salidas reales
PRESET   <= PRESET_S;
LOAD_SEL <= LOAD_SEL_S;

--Proceso para el funcionamiento del menú basado en las posiciones de las múltiples opciones
process(pxl_clk)
    variable mx : integer;
    variable my : integer;
begin
    
    if rising_edge(pxl_clk) then
       
        mx := conv_integer(MOUSE_X_POS_REG); --Variable que permite identificar la posición en X del ratón
        my := conv_integer(MOUSE_Y_POS_REG); --Variable que permite identificar la posición en Y del ratón
                
        --Procesos para la detección de flancos del ratón
        MOUSE_LEFT_BUTTON_ACT   <= '0';
        MOUSE_RIGHT_BUTTON_ACT  <= '0';
        MOUSE_MIDDLE_BUTTON_ACT <= '0';
        
        if MOUSE_LEFT_BTN = '1' and MOUSE_LEFT_BUTTON_PRE = '0' then
            MOUSE_LEFT_BUTTON_ACT   <= '1';
            end if;
            
        if MOUSE_RIGHT_BTN = '1' and MOUSE_RIGHT_BUTTON_PRE = '0' then
            MOUSE_RIGHT_BUTTON_ACT  <= '1';
            end if;
            
        if MOUSE_MIDDLE_BTN = '1' and MOUSE_MIDDLE_BUTTON_PRE = '0' then
            MOUSE_MIDDLE_BUTTON_ACT <= '1';
            end if;
            
        MOUSE_LEFT_BUTTON_PRE   <= MOUSE_LEFT_BTN;
        MOUSE_RIGHT_BUTTON_PRE  <= MOUSE_RIGHT_BTN; 
        MOUSE_MIDDLE_BUTTON_PRE <= MOUSE_MIDDLE_BTN;   
        
        --Inicializar los cambios entre relojes
        EN1_CHANGE    <= '0';
        EN2_CHANGE    <= '0';
        
        --Inicializar el estado del boton atras como disponible
        ATRAS_DISPONIBLE <= '1'; 
        
        -- Gestión del estado del menú
        case menu_state is
            -- Elección de modo
            when MENU_INICIAL =>
                
                EN_WHITE      <= '0';
                EN_BLACK      <= '0';
                ATRAS_DISPONIBLE <= '1';
                
                MODE_CONFIG     <= "00";
                TIME_CONFIG     <= "000";
                INC_CONFIG      <= "00";
                
                if MOUSE_MIDDLE_BUTTON_ACT = '1' then
                    -- Clásico
                    if OVER_CLASICO = '1' then
                        mode_sel         <= MODO_CLASICO;
                        modo_escogido    <= '1';
                        menu_state       <= MODO_ELEGIDO;
                        MODE_CONFIG      <= "00";

                    -- Rápido
                    elsif OVER_RAPIDO = '1' then
                        mode_sel         <= MODO_RAPIDO;
                        modo_escogido    <= '1';
                        menu_state       <= MODO_ELEGIDO;
                        MODE_CONFIG      <= "01";

                    -- Relámpago
                    elsif OVER_RELAMPAGO = '1' then
                        mode_sel            <= MODO_RELAMPAGO;
                        modo_escogido       <= '1';
                        menu_state          <= MODO_ELEGIDO;
                        MODE_CONFIG         <= "10";

                    -- Bala
                    elsif OVER_BALA = '1' then
                        mode_sel       <= MODO_BALA;
                        modo_escogido  <= '1';
                        menu_state     <= MODO_ELEGIDO;
                        MODE_CONFIG    <= "11";
                    end if;
                end if;

            -- Una vez se ha elegido modo, se pasa a la elección de tiempo
            when MODO_ELEGIDO =>
                
                -- Se comprueba si se ha escogido dar hacia atrás
                if OVER_ATRAS = '1' and MOUSE_MIDDLE_BUTTON_ACT = '1' and modo_escogido = '1' and tiempo_escogido = '0' and ATRAS_DISPONIBLE = '1' then
                    menu_state          <= MENU_INICIAL;
                    modo_escogido       <= '0';
                    mode_sel            <= MODO_NINGUNO;
                    ATRAS_DISPONIBLE    <= '0';
                    MODE_CONFIG         <= "00";
                        
                   if MOUSE_MIDDLE_BUTTON_ACT = '0' then
                        ATRAS_DISPONIBLE  <= '1';
                   end if;
                
                -- Elección de tiempo según el modo previamente escogido              
                elsif MOUSE_MIDDLE_BUTTON_ACT = '1' then
                    -- Clásico/Relámpago
                    if (mode_sel = MODO_CLASICO) or (mode_sel = MODO_RELAMPAGO) then
                        if OVER_T1 = '1' or OVER_T2 = '1' or OVER_T3 = '1' or OVER_T4 = '1' then
                            if OVER_T1 = '1' then
                                    TIME_CONFIG            <= "000";
                                    
                            elsif OVER_T2 = '1' then
                                       TIME_CONFIG            <= "010";
                                       
                            elsif OVER_T3 = '1' then
                                       TIME_CONFIG          <= "100";
                                    
                            elsif OVER_T4 = '1' then
                                       TIME_CONFIG          <= "110";
                        end if;
                        
                        tiempo_escogido <= '1';
                        menu_state      <= TIEMPO_ELEGIDO;
                        end if;
                        
                    -- Rápido
                    elsif (mode_sel = MODO_RAPIDO) then
                        if OVER_T1 = '1' or OVER_T2 = '1' or OVER_T3 = '1' or OVER_T4 = '1' or OVER_T5 = '1' or OVER_T6 = '1' then
                            if OVER_T1 = '1' then
                                    TIME_CONFIG     <= "000";
                                  
                            elsif OVER_T2 = '1' then
                                       TIME_CONFIG  <= "001";
                                       
                            elsif OVER_T3 = '1' then
                                       TIME_CONFIG  <= "010";
                                    
                            elsif OVER_T4 = '1' then
                                       TIME_CONFIG  <= "011";
                                       
                            elsif OVER_T5 = '1' then
                                       TIME_CONFIG  <= "100";
                                    
                            elsif OVER_T6 = '1' then
                                       TIME_CONFIG  <= "101";
                            end if;
                        
                        tiempo_escogido <= '1';
                        menu_state      <= TIEMPO_ELEGIDO;
                        end if;
                        
                    -- Bala
                    elsif (mode_sel = MODO_BALA) then
                        if OVER_T1 = '1' or OVER_T2 = '1' then
                            if OVER_T1 = '1' then
                                    TIME_CONFIG     <= "000";
                                  
                            elsif OVER_T2 = '1' then
                                       TIME_CONFIG  <= "100";
                            end if;
                        
                        tiempo_escogido <= '1';
                        menu_state      <= TIEMPO_ELEGIDO;
                        end if;
                    end if;
                end if;

            -- Una vez se elige el tiempo, se pasa a la elección del incremento, si es posible
            when TIEMPO_ELEGIDO =>

                -- Se comprueba si se ha escogido dar hacia atrás
                if OVER_ATRAS = '1' and MOUSE_MIDDLE_BUTTON_ACT = '1' and tiempo_escogido = '1' and incremento_escogido = '0' and ATRAS_DISPONIBLE = '1' then
                    menu_state        <= MODO_ELEGIDO;
                    tiempo_escogido   <= '0';
                    ATRAS_DISPONIBLE  <= '0';
                    TIME_CONFIG       <= "000";
                        
                   if MOUSE_MIDDLE_BUTTON_ACT = '0' then
                       ATRAS_DISPONIBLE  <= '1';
                   end if;

                elsif MOUSE_MIDDLE_BUTTON_ACT = '1' then 
                      
                    -- Para tiempos de los modos Clásico o Bala solo hay incrementos por defecto   
                    if (mode_sel = MODO_CLASICO) or (mode_sel = MODO_BALA) then
                        if OVER_I1 = '1' then
                            INC_CONFIG            <= "00";
                        
                        incremento_escogido <= '1';
                        menu_state          <= LISTO_PARA_JUGAR;
                        end if;
                        
                    -- Para tiempos de los modos Clásico o Bala solo hay incrementos por defecto   
                    elsif (mode_sel = MODO_RAPIDO) or (mode_sel = MODO_RELAMPAGO) then
                        if OVER_I1 = '1' or OVER_I2 = '1' or OVER_I3 = '1' or OVER_I4 = '1' then
                            if OVER_I1 = '1' then
                                    INC_CONFIG            <= "11";
                                    
                            elsif OVER_I2 = '1' then
                                    INC_CONFIG            <= "10";
                                    
                            elsif OVER_I3 = '1' then
                                    INC_CONFIG            <= "01";
                                    
                            elsif OVER_I4 = '1' then
                                    INC_CONFIG            <= "00";
                                    
                            end if;
                        
                        incremento_escogido <= '1';
                        menu_state          <= LISTO_PARA_JUGAR;
                        end if;
                    end if;  
                end if;

            -- Cuando se han hecho todas las elecciones, se pasa al estado previo al comienzo del juego
            when LISTO_PARA_JUGAR =>
                
                if MOUSE_MIDDLE_BUTTON_ACT = '1' then
                    -- Se comprueba si se ha escogido dar hacia atrás
                    if OVER_ATRAS = '1' and incremento_escogido = '1' and ATRAS_DISPONIBLE = '1' then  
                        menu_state          <= TIEMPO_ELEGIDO;
                        incremento_escogido <= '0';
                        ATRAS_DISPONIBLE    <= '0';
                        INC_CONFIG          <= "00";
                                                   
                       if MOUSE_MIDDLE_BUTTON_ACT = '0' then
                            ATRAS_DISPONIBLE    <= '1';
                       end if;
    
                    -- Se comprueba si se ha escogido comenzar el juego
                    elsif OVER_JUGAR = '1' then
                        jugar_escogido <= '1';
                        turno_blancas  <= '1';
                        menu_state     <= JUEGO_COMENZADO;
                    end if;    
                end if;
            
            when JUEGO_COMENZADO =>
                
                -- Cambio de turno de blancas a negras
                if MOUSE_LEFT_BUTTON_ACT = '1' and jugar_escogido = '1' and turno_blancas = '1' then 
                    EN_WHITE      <= '0';
                    EN_BLACK      <= '1';
                    EN1_CHANGE    <= '1';
                    turno_blancas <= '0';
                    turno_negras  <= '1';
                end if;
                
                -- Cambio de turno de negras a blancas
                if MOUSE_RIGHT_BUTTON_ACT = '1' and jugar_escogido = '1' and turno_negras = '1' then 
                    EN_WHITE      <= '1';
                    EN_BLACK      <= '0';
                    EN2_CHANGE    <= '1';
                    turno_blancas <= '1';
                    turno_negras  <= '0';
                end if;
                
                --Si se pulsa la rueda del ratón, debe aparecer una ventana emergente que de la opción de regresar al menú o continuar la partida
                if MOUSE_MIDDLE_BUTTON_ACT = '1' and jugar_escogido = '1' then 
                    menu_state <= JUEGO_PAUSADO;
                    EN_WHITE   <= '0';
                    EN_BLACK   <= '0';
                end if; 
                                
            when JUEGO_PAUSADO =>
                
                if MOUSE_MIDDLE_BUTTON_ACT = '1' and jugar_escogido = '1' then
                    -- Se comprueba si el ratón está sobre SI
                    if OVER_SI = '1' then
                        menu_state      <= MENU_INICIAL;
                        jugar_escogido  <= '0';    
                   
                    -- Se comprueba si el ratón está sobre NO  
                    elsif OVER_NO = '1' then
                        menu_state      <= JUEGO_COMENZADO;
                        
                        --Reanudar el juego con el reloj correspondiente
                        if turno_blancas = '1' then
                            EN_WHITE <= '1';
                        elsif turno_negras = '1' then
                            EN_BLACK <= '1';
                        end if;
                    end if;
                end if;   
            when others => null;
        end case;
    end if;
end process;

-- Proceso para gestionar las señales de selección de botones
process(pxl_clk, menu_state, 
        MODE_CONFIG, TIME_CONFIG, INC_CONFIG)
begin           
        -- Se apaga cualquier señal de bloque seleccionado
        selected_clasico   <= '0';
        selected_rapido    <= '0';
        selected_relampago <= '0';
        selected_bala      <= '0';
        
        selected_2h_30m    <= '0';
        selected_2h_1h_15m <= '0';
        selected_2h_1h     <= '0';
        selected_1h_30m    <= '0';
        
        selected_60m       <= '0';
        selected_50m       <= '0';
        selected_40m       <= '0';
        selected_30m       <= '0';
        selected_20m       <= '0';
        selected_10m       <= '0';
        
        selected_10m_bz    <= '0';
        selected_8m        <= '0';
        selected_5m        <= '0';
        selected_3m        <= '0';
        
        selected_2m        <= '0';
        selected_1m        <= '0';
        
        selected_30s       <= '0';
        selected_20s       <= '0';
        selected_15s       <= '0';
        selected_10s       <= '0';
        
        selected_5s        <= '0';
        selected_4s        <= '0';
        selected_3s        <= '0';
        selected_2s        <= '0';
        
        selected_estandar  <= '0'; 
        
        -- MODO 
        if menu_state >= MODO_ELEGIDO then
            case MODE_CONFIG is
                when "00" => selected_clasico   <= '1';
                when "01" => selected_rapido    <= '1';
                when "10" => selected_relampago <= '1';
                when "11" => selected_bala      <= '1';
                when others => null;
            end case;
            
            -- TIEMPO
            if menu_state >= TIEMPO_ELEGIDO then
                case MODE_CONFIG is
                    when "00" =>
                        case TIME_CONFIG is
                              when "000" => selected_2h_30m    <= '1';
                              when "010" => selected_2h_1h_15m <= '1';
                              when "100" => selected_2h_1h     <= '1';
                              when "110" => selected_1h_30m    <= '1';
                              when others => null;
                        end case;
                        
                    when "01" =>
                        case TIME_CONFIG is
                              when "000" => selected_60m  <= '1';
                              when "001" => selected_50m  <= '1';
                              when "010" => selected_40m  <= '1';
                              when "011" => selected_30m  <= '1';
                              when "100" => selected_20m  <= '1';
                              when "101" => selected_10m  <= '1';
                              when others => null;
                        end case;
                        
                    when "10" =>
                        case TIME_CONFIG is
                              when "000" => selected_10m_bz <= '1';
                              when "010" => selected_8m     <= '1';
                              when "100" => selected_5m     <= '1';
                              when "110" => selected_3m     <= '1';
                              when others => null;
                        end case;
                        
                    when "11" =>
                        case TIME_CONFIG is
                              when "000" => selected_2m  <= '1';
                              when "100" => selected_1m  <= '1';
                              when others => null;
                        end case;
                end case;  
                    
                -- INCREMENTO
                if menu_state = LISTO_PARA_JUGAR then
                    case MODE_CONFIG is
                        when "00" =>
                            case INC_CONFIG is
                                  when "00" => selected_estandar <= '1';
                                  when others => null;
                            end case;
                            
                        when "01" =>
                            case TIME_CONFIG is
                                  when "000" => selected_estandar <= '1';
                                  when "001" =>
                                    case INC_CONFIG is
                                          when "00" => selected_10s  <= '1';
                                          when others => null;
                                    end case;
                                  when "010" =>
                                    case INC_CONFIG is
                                          when "00" => selected_10s  <= '1';
                                          when "01" => selected_15s  <= '1';
                                          when "10" => selected_20s  <= '1';
                                          when others => null;
                                    end case;
                                  when others =>
                                    case INC_CONFIG is
                                          when "00" => selected_10s  <= '1';
                                          when "01" => selected_15s  <= '1';
                                          when "10" => selected_20s  <= '1';
                                          when "11" => selected_30s  <= '1';
                                          when others => null;
                                    end case;
                            end case;  
                            
                            
                        when "10" =>
                            case TIME_CONFIG is
                                  when "000" => selected_estandar <= '1';
                                  when "010" =>
                                    case INC_CONFIG is
                                          when "00" => selected_2s  <= '1';
                                          when others => null;
                                    end case;
                                  when others =>
                                    case INC_CONFIG is
                                          when "00" => selected_2s  <= '1';
                                          when "01" => selected_3s  <= '1';
                                          when "10" => selected_4s  <= '1';
                                          when "11" => selected_5s  <= '1';
                                          when others => null;
                                    end case;
                            end case;        
                            
                        when "11" =>
                            case INC_CONFIG is
                                  when "00" => selected_estandar <= '1';
                                  when others => null;
                            end case;
                    end case;
                end if;
            end if;  
        end if;       
end process;

-- Asignación a la salida real del game selector la elección final
GAME_CONFIG <= MODE_CONFIG & TIME_CONFIG & INC_CONFIG;
            
--------------------------

-- BRAM painting instances

--------------------------

Inst_menu_modo_blocks : Menu_modo_blocks
	GENERIC MAP (char_H_LOC  => MENU_X_START,
	             char_V_LOC  => MENU_Y_START
	             )
    PORT MAP    ( CLK_I      => pxl_clk,
                  VSYNC_I    => v_sync_reg,
                  h_cntr_reg => h_cntr_reg,
                  v_cntr_reg => v_cntr_reg,
        --          ACTIVE_I   : in  STD_LOGIC;
                  OVERLAY_O  => overlay_menu_modo
                  );

Inst_tiempo_inc_blocks : Time_blocks
	GENERIC MAP (char_H_LOC  => MENU_X_START,
	             char_V_LOC  => MENU_Y_START
	             )
    PORT MAP    ( CLK_I      => pxl_clk,
                  VSYNC_I    => v_sync_reg,
                  h_cntr_reg => h_cntr_reg,
                  v_cntr_reg => v_cntr_reg,
        --          ACTIVE_I   : in  STD_LOGIC;
                  MODO       => MODE_CONFIG,
                  TIEMPO     => TIME_CONFIG,
                  OVERLAY_O  => overlay_time_inc
                  );

Inst_navegacion_blocks : Navigation_blocks
	GENERIC MAP (char_H_LOC  => MENU_X_START,
	             char_V_LOC  => MENU_Y_START
	             )
    PORT MAP    ( CLK_I      => pxl_clk,
                  VSYNC_I    => v_sync_reg,
                  h_cntr_reg => h_cntr_reg,
                  v_cntr_reg => v_cntr_reg,
        --          ACTIVE_I   : in  STD_LOGIC;
                  OVERLAY_O  => overlay_navigation
                  );

Inst_piezas_texto : Piezas_texto
	GENERIC MAP (char_H_LOC  => MENU_X_START,
	             char_V_LOC  => MENU_Y_START
	             )
    PORT MAP    ( CLK_I      => pxl_clk,
                  VSYNC_I    => v_sync_reg,
                  h_cntr_reg => h_cntr_reg,
                  v_cntr_reg => v_cntr_reg,           
        --          ACTIVE_I   : in  STD_LOGIC;
                  OVERLAY_O  => overlay_piezas
                  );

Inst_ventana_opciones : Ventana_emergente_opciones
	GENERIC MAP (char_H_LOC  => MENU_X_START,
	             char_V_LOC  => MENU_Y_START
	             )
    PORT MAP    ( CLK_I      => pxl_clk,
                  VSYNC_I    => v_sync_reg,
                  h_cntr_reg => h_cntr_reg,
                  v_cntr_reg => v_cntr_reg,          
        --          ACTIVE_I   : in  STD_LOGIC;
                  OVERLAY_O  => overlay_ventana_opc
                  );

Inst_ventana_texto : Ventana_emergente
	GENERIC MAP (char_H_LOC  => MENU_X_START,
	             char_V_LOC  => MENU_Y_START
	             )
    PORT MAP    ( CLK_I      => pxl_clk,
                  VSYNC_I    => v_sync_reg,
                  h_cntr_reg => h_cntr_reg,
                  v_cntr_reg => v_cntr_reg,          
        --          ACTIVE_I   : in  STD_LOGIC;
                  OVERLAY_O  => overlay_ventana_txt
                  );

Inst_titulos : Titulos_blocks
	GENERIC MAP (char_H_LOC  => MENU_X_START,
	             char_V_LOC  => MENU_Y_START
	             )
    PORT MAP    ( CLK_I      => pxl_clk,
                  VSYNC_I    => v_sync_reg,
                  h_cntr_reg => h_cntr_reg,
                  v_cntr_reg => v_cntr_reg,           
        --          ACTIVE_I   : in  STD_LOGIC;
                  menu_state => MENU_STATE_LED(4 downto 0),
                  OVERLAY_O  => overlay_titulos
                  );

Inst_cuenta1 : Count_display
	GENERIC MAP (char_V_LOC  => MENU_Y_START
	             )
    PORT MAP    ( CLK_I      => pxl_clk,
                  VSYNC_I    => v_sync_reg,
                  h_cntr_reg => h_cntr_reg,
                  v_cntr_reg => v_cntr_reg,           
        --          ACTIVE_I   : in  STD_LOGIC;
                  char_H_LOC => CUENTA1_X_START, 
                  CUENTA     => CUENTA_BLANCAS,
                  OVERLAY_O  => overlay_cuenta1
                  );

Inst_cuenta2 : Count_display
	GENERIC MAP (char_V_LOC  => MENU_Y_START
	             )
    PORT MAP    ( CLK_I      => pxl_clk,
                  VSYNC_I    => v_sync_reg,
                  h_cntr_reg => h_cntr_reg,
                  v_cntr_reg => v_cntr_reg,           
        --          ACTIVE_I   : in  STD_LOGIC;
                  char_H_LOC => CUENTA2_X_START, 
                  CUENTA     => CUENTA_NEGRAS,
                  OVERLAY_O  => overlay_cuenta2
                  );
    
-- Asignación de los valores de color según el valor de bit de los overlay de salida
overlay_output_modo        <= overlay_color(overlay_menu_modo);
overlay_output_tiempo      <= overlay_color(overlay_time_inc);
overlay_output_nav         <= overlay_color(overlay_navigation);
overlay_output_piezas      <= overlay_color(overlay_piezas);
overlay_output_ventana_opc <= overlay_color(overlay_ventana_opc);
overlay_output_ventana_txt <= overlay_color(overlay_ventana_txt);
overlay_output_titulos     <= overlay_color(overlay_titulos);
overlay_output_cuenta1     <= overlay_count_color(overlay_cuenta1, CUENTA_BLANCAS);
overlay_output_cuenta2     <= overlay_count_color(overlay_cuenta2, CUENTA_NEGRAS);

overlay_output_ventana     <= overlay_output_ventana_opc or overlay_output_ventana_txt;

------------------------------------

---- Internal processes instances

------------------------------------

--Inst_Button_detection: Button_detection
--    PORT MAP    ( pxl_clk    => pxl_clk,
--                  mode_sel => mode_sel,
--                  MODE_CONFIG => MODE_CONFIG,
--                  TIME_CONFIG => TIME_CONFIG,
--                  INC_CONFIG  => INC_CONFIG,
                  
--                  MOUSE_X_POS_REG => MOUSE_X_POS_REG,
--                  MOUSE_Y_POS_REG => MOUSE_Y_POS_REG,
          
--                  OVER_CLASICO    => OVER_CLASICO,
--                  OVER_RAPIDO     => OVER_RAPIDO,
--                  OVER_RELAMPAGO  => OVER_RELAMPAGO,
--                  OVER_BALA       => OVER_BALA,
                    
--                  OVER_T1         => OVER_T1,
--                  OVER_T2         => OVER_T2,
--                  OVER_T3         => OVER_T3,
--                  OVER_T4         => OVER_T4,
--                  OVER_T5         => OVER_T5,
--                  OVER_T6         => OVER_T6,
                    
--                  OVER_I1         => OVER_I1,
--                  OVER_I2         => OVER_I2,
--                  OVER_I3         => OVER_I3,
--                  OVER_I4         => OVER_I4,
                    
--                  OVER_ATRAS      => OVER_ATRAS,
--                  OVER_JUGAR      => OVER_JUGAR,
                    
--                  OVER_SI         => OVER_SI,
--                  OVER_NO         => OVER_NO
--                  );
                  
--Inst_VGA_load_manager: VGA_load_manager
--    PORT MAP    ( pxl_clk    => pxl_clk,
--                  menu_state => menu_state,
                   
--                  PRESET     => PRESET,
--                  LOAD_SEL   => LOAD_SEL
--                  );

--Inst_Selection_management: Selection_management
--    PORT MAP    ( pxl_clk            => pxl_clk,
--                  menu_state         => menu_state,
--                  MODE_CONFIG        => MODE_CONFIG,
--                  TIME_CONFIG        => TIME_CONFIG,
--                  INC_CONFIG         => INC_CONFIG,
          
--                  selected_clasico   => selected_clasico,
--                  selected_rapido    => selected_rapido,
--                  selected_relampago => selected_relampago,
--                  selected_bala      => selected_bala,
                  
--                  selected_2h_30m    => selected_2h_30m,
--                  selected_2h_1h_15m => selected_2h_1h_15m,
--                  selected_2h_1h     => selected_2h_1h,
--                  selected_1h_30m    => selected_1h_30m,
                    
--                  selected_60m       => selected_60m,
--                  selected_50m       => selected_50m,
--                  selected_40m       => selected_40m,
--                  selected_30m       => selected_30m,
--                  selected_20m       => selected_20m,
--                  selected_10m       => selected_10m,
                    
--                  selected_10m_bz    => selected_10m_bz,
--                  selected_8m        => selected_8m,
--                  selected_5m        => selected_5m,
--                  selected_3m        => selected_3m,
                    
--                  selected_2m        => selected_2m,
--                  selected_1m        => selected_1m,
                    
--                  selected_30s       => selected_30s,
--                  selected_20s       => selected_20s,
--                  selected_15s       => selected_15s,
--                  selected_10s       => selected_10s,
                    
--                  selected_5s        => selected_5s,
--                  selected_4s        => selected_4s,
--                  selected_3s        => selected_3s,
--                  selected_2s        => selected_2s,
                    
--                  selected_estandar  => selected_estandar
--                  );
        
    
----------------------------------

-- Mouse Cursor display instance

----------------------------------
   Inst_MouseDisplay: MouseDisplay
   PORT MAP 
   (
      pixel_clk   => pxl_clk,
      xpos        => MOUSE_X_POS_REG, 
      ypos        => MOUSE_Y_POS_REG,
      hcount      => h_cntr_reg,
      vcount      => v_cntr_reg,
      enable_mouse_display_out  => enable_mouse_display,
      red_out     => mouse_cursor_red,
      green_out   => mouse_cursor_green,
      blue_out    => mouse_cursor_blue
   );
  
---------------------------------------

-- Generate color background

---------------------------------------

-- Proceso para crear el fondo checker
process(h_cntr_reg, v_cntr_reg)
    -- Variables para el patrón checker
    variable v_col : integer;
    variable v_row : integer;
    
    -- Variables para el marco marrón
    constant marco_width  : integer := 60;
    constant marco_height : integer := 40;
begin
    -- Comprobamos que no está sobre el marco
    if (unsigned(h_cntr_reg) < marco_width or unsigned(h_cntr_reg) >= (FRAME_WIDTH - marco_width) or
       unsigned(v_cntr_reg) < marco_height or unsigned(v_cntr_reg) >= (FRAME_HEIGHT - marco_height)) then
       
       -- Color marrón del marco
       bg_red   <= "1001";
       bg_green <= "0011";
       bg_blue  <= "0000";
       
    else
       
        v_col := (to_integer(unsigned(h_cntr_reg)) - marco_width) / 200;
        v_row := (to_integer(unsigned(v_cntr_reg)) - marco_height) / 200;
    
        if ((v_col + v_row) mod 2 = 0) then
            bg_red   <= "0000";
            bg_green <= "0000";
            bg_blue  <= "0000";
        else
            bg_red   <= "1111";
            bg_green <= "1111";
            bg_blue  <= "1111";
        end if;
    end if;
end process;

--   bg_red   <= X"D";  -- Red = 13
--   bg_green <= X"B";  -- Green = 11
--   bg_blue  <= X"9";  -- Blue = 9
   
---------------------------------------------------------------------------------------------------

-- Register Outputs coming from the displaying components and the horizontal and vertical counters

---------------------------------------------------------------------------------------------------
  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then
   
--      logo_red_dly		   <= (others => '0');
--	  logo_green_dly	   <= (others => '0');
--	  logo_blue_dly		   <= (others => '0');
	  
--	  logo_red_dly   <= logo_red;
--      logo_green_dly <= logo_green;
--      logo_blue_dly  <= logo_blue;
	        
      bg_red_dly			<= bg_red;
	  bg_green_dly		    <= bg_green;
	  bg_blue_dly			<= bg_blue;

      mouse_cursor_red_dly    <= mouse_cursor_red;
      mouse_cursor_blue_dly   <= mouse_cursor_blue;
      mouse_cursor_green_dly  <= mouse_cursor_green;

      enable_mouse_display_dly   <= enable_mouse_display;
      
      h_cntr_reg_dly <= h_cntr_reg;
      v_cntr_reg_dly <= v_cntr_reg;
     
    end if;
  end process;

-------------------------------------------------------------

-- Main Multiplexers for the VGA Red, Green and Blue signals

-------------------------------------------------------------
----------
-- Red
----------

  vga_red <=   -- Mouse_cursor_display is on the top of others
               mouse_cursor_red_dly when enable_mouse_display_dly = '1'
--               else
--               -- Overlay display is black 
--               x"0" when overlay_en_dly = '1'
               else
               -- Display of BRAM content
               
               -- Pintar títulos de pantalla
               overlay_output_titulos when (                    
                                        -- Bloque "PIEZAS BLANCAS" y bloque "PIEZAS NEGRAS"
                                        ((MENU_STATE_LED(5) = '0') and
                                        (h_cntr_reg_dly > TITULO_LEFT and h_cntr_reg_dly < TITULO_RIGHT and v_cntr_reg_dly > TITULO_TOP and v_cntr_reg_dly < TITULO_BOTTOM)
                                        ))
               else
               
               -- Pintar bloques fijos y modos de juego
               overlay_output_modo when (-- Bloques Principales (Menú Raíz)
                                        ((MENU_STATE_LED(4) = '0' and MENU_STATE_LED(5) = '0') and (
                                        (h_cntr_reg_dly > MODO_LEFT       and h_cntr_reg_dly < MODO_RIGHT       and v_cntr_reg_dly > MODO_TOP       and v_cntr_reg_dly < MODO_BOTTOM) or
                                        (h_cntr_reg_dly > TIEMPO_LEFT     and h_cntr_reg_dly < TIEMPO_RIGHT     and v_cntr_reg_dly > TIEMPO_TOP     and v_cntr_reg_dly < TIEMPO_BOTTOM) or
                                        (h_cntr_reg_dly > INCREMENTO_LEFT and h_cntr_reg_dly < INCREMENTO_RIGHT and v_cntr_reg_dly > INCREMENTO_TOP and v_cntr_reg_dly < INCREMENTO_BOTTOM) or
                                        (h_cntr_reg_dly > CLASICO_LEFT    and h_cntr_reg_dly < CLASICO_RIGHT    and v_cntr_reg_dly > CLASICO_TOP    and v_cntr_reg_dly < CLASICO_BOTTOM) or
                                        (h_cntr_reg_dly > RAPIDO_LEFT     and h_cntr_reg_dly < RAPIDO_RIGHT     and v_cntr_reg_dly > RAPIDO_TOP     and v_cntr_reg_dly < RAPIDO_BOTTOM) or
                                        (h_cntr_reg_dly > RELAMPAGO_LEFT  and h_cntr_reg_dly < RELAMPAGO_RIGHT  and v_cntr_reg_dly > RELAMPAGO_TOP  and v_cntr_reg_dly < RELAMPAGO_BOTTOM) or
                                        (h_cntr_reg_dly > BALA_LEFT       and h_cntr_reg_dly < BALA_RIGHT       and v_cntr_reg_dly > BALA_TOP       and v_cntr_reg_dly < BALA_BOTTOM)
                                        )))
               else
               
               -- Pintar iconos de navegación del menú
               overlay_output_nav when (                    
                                        -- Bloque "ATRAS"
                                        ((MENU_STATE_LED(3) = '1' or MENU_STATE_LED(2) = '1' or MENU_STATE_LED(1) = '1') and (
                                        (h_cntr_reg_dly > ATRAS_LEFT and h_cntr_reg_dly < ATRAS_RIGHT and v_cntr_reg_dly > ATRAS_TOP and v_cntr_reg_dly < ATRAS_BOTTOM)
                                        )) or
                                    
                                        -- Bloque "JUGAR"
                                        ((MENU_STATE_LED(3) = '1') and (
                                        (h_cntr_reg_dly > JUGAR_LEFT and h_cntr_reg_dly < JUGAR_RIGHT and v_cntr_reg_dly > JUGAR_TOP and v_cntr_reg_dly < JUGAR_BOTTOM)
                                        ))                                
                                        )
               else
               
               -- Pintar tiempo e incrementos
               overlay_output_tiempo when (                    
                                        -- Bloques de Tiempo: CLÁSICO
                                        ((MENU_STATE_LED(3 downto 1) /= "000") and (MODE_CONFIG = "00" and (
                                        (h_cntr_reg_dly > TCLASICO1_LEFT and h_cntr_reg_dly < TCLASICO1_RIGHT and v_cntr_reg_dly > TCLASICO1_TOP and v_cntr_reg_dly < TCLASICO1_BOTTOM) or
                                        (h_cntr_reg_dly > TCLASICO2_LEFT and h_cntr_reg_dly < TCLASICO2_RIGHT and v_cntr_reg_dly > TCLASICO2_TOP and v_cntr_reg_dly < TCLASICO2_BOTTOM) or
                                        (h_cntr_reg_dly > TCLASICO3_LEFT and h_cntr_reg_dly < TCLASICO3_RIGHT and v_cntr_reg_dly > TCLASICO3_TOP and v_cntr_reg_dly < TCLASICO3_BOTTOM) or
                                        (h_cntr_reg_dly > TCLASICO4_LEFT and h_cntr_reg_dly < TCLASICO4_RIGHT and v_cntr_reg_dly > TCLASICO4_TOP and v_cntr_reg_dly < TCLASICO4_BOTTOM)
                                        ))) or
                                    
                                        -- Bloques de Tiempo: RÁPIDO
                                        ((MENU_STATE_LED(3 downto 1) /= "000") and (MODE_CONFIG = "01" and (
                                        (h_cntr_reg_dly > TRAPIDO1_LEFT and h_cntr_reg_dly < TRAPIDO1_RIGHT and v_cntr_reg_dly > TRAPIDO1_TOP and v_cntr_reg_dly < TRAPIDO1_BOTTOM) or
                                        (h_cntr_reg_dly > TRAPIDO2_LEFT and h_cntr_reg_dly < TRAPIDO2_RIGHT and v_cntr_reg_dly > TRAPIDO2_TOP and v_cntr_reg_dly < TRAPIDO2_BOTTOM) or
                                        (h_cntr_reg_dly > TRAPIDO3_LEFT and h_cntr_reg_dly < TRAPIDO3_RIGHT and v_cntr_reg_dly > TRAPIDO3_TOP and v_cntr_reg_dly < TRAPIDO3_BOTTOM) or
                                        (h_cntr_reg_dly > TRAPIDO4_LEFT and h_cntr_reg_dly < TRAPIDO4_RIGHT and v_cntr_reg_dly > TRAPIDO4_TOP and v_cntr_reg_dly < TRAPIDO4_BOTTOM) or
                                        (h_cntr_reg_dly > TRAPIDO5_LEFT and h_cntr_reg_dly < TRAPIDO5_RIGHT and v_cntr_reg_dly > TRAPIDO5_TOP and v_cntr_reg_dly < TRAPIDO5_BOTTOM) or
                                        (h_cntr_reg_dly > TRAPIDO6_LEFT and h_cntr_reg_dly < TRAPIDO6_RIGHT and v_cntr_reg_dly > TRAPIDO6_TOP and v_cntr_reg_dly < TRAPIDO6_BOTTOM)
                                        ))) or
                                    
                                        -- Bloques de Tiempo: RELÁMPAGO
                                        ((MENU_STATE_LED(3 downto 1) /= "000") and (MODE_CONFIG = "10" and (
                                        (h_cntr_reg_dly > TRELAMPAGO1_LEFT and h_cntr_reg_dly < TRELAMPAGO1_RIGHT and v_cntr_reg_dly > TRELAMPAGO1_TOP and v_cntr_reg_dly < TRELAMPAGO1_BOTTOM) or
                                        (h_cntr_reg_dly > TRELAMPAGO2_LEFT and h_cntr_reg_dly < TRELAMPAGO2_RIGHT and v_cntr_reg_dly > TRELAMPAGO2_TOP and v_cntr_reg_dly < TRELAMPAGO2_BOTTOM) or
                                        (h_cntr_reg_dly > TRELAMPAGO3_LEFT and h_cntr_reg_dly < TRELAMPAGO3_RIGHT and v_cntr_reg_dly > TRELAMPAGO3_TOP and v_cntr_reg_dly < TRELAMPAGO3_BOTTOM) or
                                        (h_cntr_reg_dly > TRELAMPAGO4_LEFT and h_cntr_reg_dly < TRELAMPAGO4_RIGHT and v_cntr_reg_dly > TRELAMPAGO4_TOP and v_cntr_reg_dly < TRELAMPAGO4_BOTTOM)
                                        ))) or
                                    
                                        -- Bloques de Tiempo: BALA
                                        ((MENU_STATE_LED(3 downto 1) /= "000") and (MODE_CONFIG = "11" and (
                                        (h_cntr_reg_dly > TBALA1_LEFT and h_cntr_reg_dly < TBALA1_RIGHT and v_cntr_reg_dly > TBALA1_TOP and v_cntr_reg_dly < TBALA1_BOTTOM) or
                                        (h_cntr_reg_dly > TBALA2_LEFT and h_cntr_reg_dly < TBALA2_RIGHT and v_cntr_reg_dly > TBALA2_TOP and v_cntr_reg_dly < TBALA2_BOTTOM)
                                        ))) or   
                                                          
                                        -- Bloques de Incremento: CLÁSICO
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (
                                        ((MODE_CONFIG = "00" or ((MODE_CONFIG = "10" or MODE_CONFIG = "01") and TIME_CONFIG = "000")) and (
                                        (h_cntr_reg_dly > ICLASICO1_LEFT and h_cntr_reg_dly < ICLASICO1_RIGHT and v_cntr_reg_dly > ICLASICO1_TOP and v_cntr_reg_dly < ICLASICO1_BOTTOM)
                                        )))) or
                                    
                                        -- Bloques de Incremento: RÁPIDO
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (MODE_CONFIG = "01" and (
                                        TIME_CONFIG /= "000" and (
                                        (h_cntr_reg_dly > IRAPIDO4_LEFT and h_cntr_reg_dly < IRAPIDO4_RIGHT and v_cntr_reg_dly > IRAPIDO4_TOP and v_cntr_reg_dly < IRAPIDO4_BOTTOM) or
                                        (TIME_CONFIG /= "001" and (
                                        (h_cntr_reg_dly > IRAPIDO3_LEFT and h_cntr_reg_dly < IRAPIDO3_RIGHT and v_cntr_reg_dly > IRAPIDO3_TOP and v_cntr_reg_dly < IRAPIDO3_BOTTOM) or
                                        (h_cntr_reg_dly > IRAPIDO2_LEFT and h_cntr_reg_dly < IRAPIDO2_RIGHT and v_cntr_reg_dly > IRAPIDO2_TOP and v_cntr_reg_dly < IRAPIDO2_BOTTOM) or
                                        (TIME_CONFIG /= "010" and (
                                        (h_cntr_reg_dly > IRAPIDO1_LEFT and h_cntr_reg_dly < IRAPIDO1_RIGHT and v_cntr_reg_dly > IRAPIDO1_TOP and v_cntr_reg_dly < IRAPIDO1_BOTTOM)
                                        )))
                                        )
                                        )))) or
                                    
                                        -- Bloques de Incremento: RELÁMPAGO
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (MODE_CONFIG = "10" and (
                                        TIME_CONFIG /= "000" and (
                                        (h_cntr_reg_dly > IRELAMPAGO4_LEFT and h_cntr_reg_dly < IRELAMPAGO4_RIGHT and v_cntr_reg_dly > IRELAMPAGO4_TOP and v_cntr_reg_dly < IRELAMPAGO4_BOTTOM) or
                                        (TIME_CONFIG /= "010" and (
                                        (h_cntr_reg_dly > IRELAMPAGO1_LEFT and h_cntr_reg_dly < IRELAMPAGO1_RIGHT and v_cntr_reg_dly > IRELAMPAGO1_TOP and v_cntr_reg_dly < IRELAMPAGO1_BOTTOM) or
                                        (h_cntr_reg_dly > IRELAMPAGO2_LEFT and h_cntr_reg_dly < IRELAMPAGO2_RIGHT and v_cntr_reg_dly > IRELAMPAGO2_TOP and v_cntr_reg_dly < IRELAMPAGO2_BOTTOM) or
                                        (h_cntr_reg_dly > IRELAMPAGO3_LEFT and h_cntr_reg_dly < IRELAMPAGO3_RIGHT and v_cntr_reg_dly > IRELAMPAGO3_TOP and v_cntr_reg_dly < IRELAMPAGO3_BOTTOM)
                                        ))
                                        ) 
                                        ))) or
                                    
                                        -- Bloques de Incremento: BALA
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (MODE_CONFIG = "11" and (
                                        (h_cntr_reg_dly > IBALA1_LEFT and h_cntr_reg_dly < IBALA1_RIGHT and v_cntr_reg_dly > IBALA1_TOP and v_cntr_reg_dly < IBALA1_BOTTOM)
                                        )))
                                        
                                        )
               else
               
               -- Pintar textos de los jugadores en la pantalla de juego
               overlay_output_piezas when (                    
                                        -- Bloque "PIEZAS BLANCAS" y bloque "PIEZAS NEGRAS"
                                        ((MENU_STATE_LED(4) = '1') and (
                                        (h_cntr_reg_dly > BLANCAS_LEFT and h_cntr_reg_dly < BLANCAS_RIGHT and v_cntr_reg_dly > BLANCAS_TOP and v_cntr_reg_dly < BLANCAS_BOTTOM) or
                                        (h_cntr_reg_dly > NEGRAS_LEFT  and h_cntr_reg_dly < NEGRAS_RIGHT  and v_cntr_reg_dly > NEGRAS_TOP  and v_cntr_reg_dly < NEGRAS_BOTTOM)
                                        ))                              
                                        )
               else
               
               -- Pintar bloques de la ventana emergente
               overlay_output_ventana when (                    
                                        -- Bloque "SI", bloque "NO" y bloque de texto de la ventana emergente
                                        ((MENU_STATE_LED(5) = '1') and (
                                        (h_cntr_reg_dly > SI_LEFT      and h_cntr_reg_dly < SI_RIGHT      and v_cntr_reg_dly > SI_TOP      and v_cntr_reg_dly < SI_BOTTOM) or
                                        (h_cntr_reg_dly > NO_LEFT      and h_cntr_reg_dly < NO_RIGHT      and v_cntr_reg_dly > NO_TOP      and v_cntr_reg_dly < NO_BOTTOM) or
                                        (h_cntr_reg_dly > VENTANA_LEFT and h_cntr_reg_dly < VENTANA_RIGHT and v_cntr_reg_dly > VENTANA_TOP and v_cntr_reg_dly < VENTANA_BOTTOM)
                                        ))                              
                                        )
               else
               
               -- Pintar números de la cuenta del jugador 1 (blancas)
               overlay_output_cuenta1(11 downto 8) when (                    
                                        ((MENU_STATE_LED(4) = '1') and (
                                        ((h_cntr_reg_dly > UHORAS1_LEFT          and h_cntr_reg_dly < UHORAS1_RIGHT          and v_cntr_reg_dly > UHORAS1_TOP          and v_cntr_reg_dly < UHORAS1_BOTTOM) and
                                        (CUENTA_BLANCAS(27 downto 24) /= "0000")) or
                                        ((h_cntr_reg_dly > PUNTOS_HORASMIN1_LEFT and h_cntr_reg_dly < PUNTOS_HORASMIN1_RIGHT and v_cntr_reg_dly > PUNTOS_HORASMIN1_TOP and v_cntr_reg_dly < PUNTOS_HORASMIN1_BOTTOM) and
                                        (CUENTA_BLANCAS(27 downto 24) /= "0000")) or
                                        ((h_cntr_reg_dly > DMINUTOS1_LEFT        and h_cntr_reg_dly < DMINUTOS1_RIGHT        and v_cntr_reg_dly > DMINUTOS1_TOP        and v_cntr_reg_dly < DMINUTOS1_BOTTOM) and
                                        (CUENTA_BLANCAS(27 downto 16) /= "000000000000")) or
                                        ((h_cntr_reg_dly > UMINUTOS1_LEFT        and h_cntr_reg_dly < UMINUTOS1_RIGHT        and v_cntr_reg_dly > UMINUTOS1_TOP        and v_cntr_reg_dly < UMINUTOS1_BOTTOM) and
                                        (CUENTA_BLANCAS(27 downto 16) /= "000000000000")) or
                                        ((h_cntr_reg_dly > PUNTOS_MINSEG1_LEFT   and h_cntr_reg_dly < PUNTOS_MINSEG1_RIGHT   and v_cntr_reg_dly > PUNTOS_MINSEG1_TOP   and v_cntr_reg_dly < PUNTOS_MINSEG1_BOTTOM) and
                                        (CUENTA_BLANCAS(27 downto 16) /= "000000000000")) or
                                        (h_cntr_reg_dly > DSEG1_LEFT            and h_cntr_reg_dly < DSEG1_RIGHT            and v_cntr_reg_dly > DSEG1_TOP            and v_cntr_reg_dly < DSEG1_BOTTOM) or
                                        (h_cntr_reg_dly > USEG1_LEFT            and h_cntr_reg_dly < USEG1_RIGHT            and v_cntr_reg_dly > USEG1_TOP            and v_cntr_reg_dly < USEG1_BOTTOM) or
                                        (h_cntr_reg_dly > PUNTO1_LEFT           and h_cntr_reg_dly < PUNTO1_RIGHT           and v_cntr_reg_dly > PUNTO1_TOP           and v_cntr_reg_dly < PUNTO1_BOTTOM) or
                                        (h_cntr_reg_dly > DECIMAS1_LEFT         and h_cntr_reg_dly < DECIMAS1_RIGHT         and v_cntr_reg_dly > DECIMAS1_TOP         and v_cntr_reg_dly < DECIMAS1_BOTTOM) or
                                        (h_cntr_reg_dly > CENTESIMAS1_LEFT      and h_cntr_reg_dly < CENTESIMAS1_RIGHT      and v_cntr_reg_dly > CENTESIMAS1_TOP      and v_cntr_reg_dly < CENTESIMAS1_BOTTOM)
                                        ))
                                        )
               else
               
               -- Pintar números de la cuenta del jugador 2 (negras)
               overlay_output_cuenta2(11 downto 8) when (                    
                                        ((MENU_STATE_LED(4) = '1') and (
                                        ((h_cntr_reg_dly > UHORAS2_LEFT          and h_cntr_reg_dly < UHORAS2_RIGHT          and v_cntr_reg_dly > UHORAS2_TOP          and v_cntr_reg_dly < UHORAS2_BOTTOM) and
                                        (CUENTA_NEGRAS(27 downto 24) /= "0000")) or
                                        ((h_cntr_reg_dly > PUNTOS_HORASMIN2_LEFT and h_cntr_reg_dly < PUNTOS_HORASMIN2_RIGHT and v_cntr_reg_dly > PUNTOS_HORASMIN2_TOP and v_cntr_reg_dly < PUNTOS_HORASMIN2_BOTTOM) and
                                        (CUENTA_NEGRAS(27 downto 24) /= "0000")) or
                                        ((h_cntr_reg_dly > DMINUTOS2_LEFT        and h_cntr_reg_dly < DMINUTOS2_RIGHT        and v_cntr_reg_dly > DMINUTOS2_TOP        and v_cntr_reg_dly < DMINUTOS2_BOTTOM) and
                                        (CUENTA_NEGRAS(27 downto 16) /= "000000000000")) or
                                        ((h_cntr_reg_dly > UMINUTOS2_LEFT        and h_cntr_reg_dly < UMINUTOS2_RIGHT        and v_cntr_reg_dly > UMINUTOS2_TOP        and v_cntr_reg_dly < UMINUTOS2_BOTTOM) and
                                        (CUENTA_NEGRAS(27 downto 16) /= "000000000000")) or
                                        ((h_cntr_reg_dly > PUNTOS_MINSEG2_LEFT   and h_cntr_reg_dly < PUNTOS_MINSEG2_RIGHT   and v_cntr_reg_dly > PUNTOS_MINSEG2_TOP   and v_cntr_reg_dly < PUNTOS_MINSEG2_BOTTOM) and
                                        (CUENTA_NEGRAS(27 downto 16) /= "000000000000")) or
                                        (h_cntr_reg_dly > DSEG2_LEFT            and h_cntr_reg_dly < DSEG2_RIGHT            and v_cntr_reg_dly > DSEG2_TOP            and v_cntr_reg_dly < DSEG2_BOTTOM) or
                                        (h_cntr_reg_dly > USEG2_LEFT            and h_cntr_reg_dly < USEG2_RIGHT            and v_cntr_reg_dly > USEG2_TOP            and v_cntr_reg_dly < USEG2_BOTTOM) or
                                        (h_cntr_reg_dly > PUNTO2_LEFT           and h_cntr_reg_dly < PUNTO2_RIGHT           and v_cntr_reg_dly > PUNTO2_TOP           and v_cntr_reg_dly < PUNTO2_BOTTOM) or
                                        (h_cntr_reg_dly > DECIMAS2_LEFT         and h_cntr_reg_dly < DECIMAS2_RIGHT         and v_cntr_reg_dly > DECIMAS2_TOP         and v_cntr_reg_dly < DECIMAS2_BOTTOM) or
                                        (h_cntr_reg_dly > CENTESIMAS2_LEFT      and h_cntr_reg_dly < CENTESIMAS2_RIGHT      and v_cntr_reg_dly > CENTESIMAS2_TOP      and v_cntr_reg_dly < CENTESIMAS2_BOTTOM)
                                        ))
                                        )
               else
               
               -- Painting a green border around the selectable BRAM blocks once selected
               x"0" when                (                                        
                                        (-- Bloques Principales (Menú Raíz)
                                        ((MENU_STATE_LED(3 downto 1) /= "000") and (
                                        ((h_cntr_reg_dly > CLASICO_LEFT - 3   and h_cntr_reg_dly < CLASICO_RIGHT + 3   and v_cntr_reg_dly > CLASICO_TOP - 3   and v_cntr_reg_dly < CLASICO_BOTTOM + 3) and
                                        (selected_clasico = '1')) or
                                        ((h_cntr_reg_dly > RAPIDO_LEFT - 3    and h_cntr_reg_dly < RAPIDO_RIGHT + 3    and v_cntr_reg_dly > RAPIDO_TOP - 3    and v_cntr_reg_dly < RAPIDO_BOTTOM + 3) and
                                        (selected_rapido = '1')) or
                                        ((h_cntr_reg_dly > RELAMPAGO_LEFT - 3 and h_cntr_reg_dly < RELAMPAGO_RIGHT + 3 and v_cntr_reg_dly > RELAMPAGO_TOP - 3 and v_cntr_reg_dly < RELAMPAGO_BOTTOM + 3) and
                                        (selected_relampago = '1')) or
                                        ((h_cntr_reg_dly > BALA_LEFT - 3      and h_cntr_reg_dly < BALA_RIGHT + 3      and v_cntr_reg_dly > BALA_TOP - 3      and v_cntr_reg_dly < BALA_BOTTOM + 3) and
                                        (selected_bala = '1'))
                                        )) or
                                    
                                        -- Bloques de Tiempo: CLÁSICO
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (
                                        ((h_cntr_reg_dly > TCLASICO1_LEFT - 3 and h_cntr_reg_dly < TCLASICO1_RIGHT + 3 and v_cntr_reg_dly > TCLASICO1_TOP - 3 and v_cntr_reg_dly < TCLASICO1_BOTTOM + 3) and
                                        (selected_2h_30m = '1')) or
                                        ((h_cntr_reg_dly > TCLASICO2_LEFT - 3 and h_cntr_reg_dly < TCLASICO2_RIGHT + 3 and v_cntr_reg_dly > TCLASICO2_TOP - 3 and v_cntr_reg_dly < TCLASICO2_BOTTOM + 3) and
                                        (selected_2h_1h_15m = '1')) or
                                        ((h_cntr_reg_dly > TCLASICO3_LEFT - 3 and h_cntr_reg_dly < TCLASICO3_RIGHT + 3 and v_cntr_reg_dly > TCLASICO3_TOP - 3 and v_cntr_reg_dly < TCLASICO3_BOTTOM + 3) and
                                        (selected_2h_1h = '1')) or
                                        ((h_cntr_reg_dly > TCLASICO4_LEFT - 3 and h_cntr_reg_dly < TCLASICO4_RIGHT + 3 and v_cntr_reg_dly > TCLASICO4_TOP - 3 and v_cntr_reg_dly < TCLASICO4_BOTTOM + 3) and
                                        (selected_1h_30m = '1'))
                                        )) or
                                    
                                        -- Bloques de Tiempo: RÁPIDO
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (
                                        ((h_cntr_reg_dly > TRAPIDO1_LEFT - 3 and h_cntr_reg_dly < TRAPIDO1_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO1_TOP - 3 and v_cntr_reg_dly < TRAPIDO1_BOTTOM + 3) and
                                        (selected_60m = '1')) or
                                        ((h_cntr_reg_dly > TRAPIDO2_LEFT - 3 and h_cntr_reg_dly < TRAPIDO2_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO2_TOP - 3 and v_cntr_reg_dly < TRAPIDO2_BOTTOM + 3) and
                                        (selected_50m = '1')) or
                                        ((h_cntr_reg_dly > TRAPIDO3_LEFT - 3 and h_cntr_reg_dly < TRAPIDO3_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO3_TOP - 3 and v_cntr_reg_dly < TRAPIDO3_BOTTOM + 3) and
                                        (selected_40m = '1')) or
                                        ((h_cntr_reg_dly > TRAPIDO4_LEFT - 3 and h_cntr_reg_dly < TRAPIDO4_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO4_TOP - 3 and v_cntr_reg_dly < TRAPIDO4_BOTTOM + 3) and
                                        (selected_30m = '1')) or
                                        ((h_cntr_reg_dly > TRAPIDO5_LEFT - 3 and h_cntr_reg_dly < TRAPIDO5_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO5_TOP - 3 and v_cntr_reg_dly < TRAPIDO5_BOTTOM + 3) and
                                        (selected_20m = '1')) or
                                        ((h_cntr_reg_dly > TRAPIDO6_LEFT - 3 and h_cntr_reg_dly < TRAPIDO6_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO6_TOP - 3 and v_cntr_reg_dly < TRAPIDO6_BOTTOM + 3) and
                                        (selected_10m = '1'))
                                        )) or
                                    
                                        -- Bloques de Tiempo: RELÁMPAGO
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (
                                        ((h_cntr_reg_dly > TRELAMPAGO1_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO1_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO1_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO1_BOTTOM + 3) and
                                        (selected_10m_bz = '1')) or
                                        ((h_cntr_reg_dly > TRELAMPAGO2_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO2_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO2_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO2_BOTTOM + 3) and
                                        (selected_8m = '1')) or
                                        ((h_cntr_reg_dly > TRELAMPAGO3_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO3_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO3_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO3_BOTTOM + 3) and
                                        (selected_5m = '1')) or
                                        ((h_cntr_reg_dly > TRELAMPAGO4_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO4_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO4_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO4_BOTTOM + 3) and
                                        (selected_3m = '1'))
                                        )) or
                                    
                                        -- Bloques de Tiempo: BALA
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (
                                        ((h_cntr_reg_dly > TBALA1_LEFT - 3 and h_cntr_reg_dly < TBALA1_RIGHT + 3 and v_cntr_reg_dly > TBALA1_TOP - 3 and v_cntr_reg_dly < TBALA1_BOTTOM + 3) and
                                        (selected_2m = '1')) or
                                        ((h_cntr_reg_dly > TBALA2_LEFT - 3 and h_cntr_reg_dly < TBALA2_RIGHT + 3 and v_cntr_reg_dly > TBALA2_TOP - 3 and v_cntr_reg_dly < TBALA2_BOTTOM + 3) and
                                        (selected_1m = '1'))
                                        )) or
                                    
                                        -- Bloques de Incremento: CLÁSICO
                                        ((MENU_STATE_LED(3) = '1') and (
                                        ((h_cntr_reg_dly > ICLASICO1_LEFT - 3 and h_cntr_reg_dly < ICLASICO1_RIGHT + 3 and v_cntr_reg_dly > ICLASICO1_TOP - 3 and v_cntr_reg_dly < ICLASICO1_BOTTOM + 3) and
                                        (selected_estandar = '1'))
                                        )) or
                                    
                                        -- Bloques de Incremento: RÁPIDO
                                        ((MENU_STATE_LED(3) = '1') and (
                                        ((h_cntr_reg_dly > IRAPIDO1_LEFT - 3 and h_cntr_reg_dly < IRAPIDO1_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO1_TOP - 3 and v_cntr_reg_dly < IRAPIDO1_BOTTOM + 3) and
                                        (selected_30s = '1')) or
                                        ((h_cntr_reg_dly > IRAPIDO2_LEFT - 3 and h_cntr_reg_dly < IRAPIDO2_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO2_TOP - 3 and v_cntr_reg_dly < IRAPIDO2_BOTTOM + 3) and
                                        (selected_20s = '1')) or
                                        ((h_cntr_reg_dly > IRAPIDO3_LEFT - 3 and h_cntr_reg_dly < IRAPIDO3_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO3_TOP - 3 and v_cntr_reg_dly < IRAPIDO3_BOTTOM + 3) and
                                        (selected_15s = '1')) or
                                        ((h_cntr_reg_dly > IRAPIDO4_LEFT - 3 and h_cntr_reg_dly < IRAPIDO4_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO4_TOP - 3 and v_cntr_reg_dly < IRAPIDO4_BOTTOM + 3) and
                                        (selected_10s = '1'))
                                        )) or
                                        
                                        -- Bloques de Incremento: RELÁMPAGO
                                        ((MENU_STATE_LED(3) = '1') and (
                                        ((h_cntr_reg_dly > IRELAMPAGO1_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO1_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO1_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO1_BOTTOM + 3) and
                                        (selected_5s = '1')) or
                                        ((h_cntr_reg_dly > IRELAMPAGO2_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO2_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO2_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO2_BOTTOM + 3) and
                                        (selected_4s = '1')) or
                                        ((h_cntr_reg_dly > IRELAMPAGO3_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO3_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO3_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO3_BOTTOM + 3) and
                                        (selected_3s = '1')) or
                                        ((h_cntr_reg_dly > IRELAMPAGO4_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO4_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO4_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO4_BOTTOM + 3) and
                                        (selected_2s = '1'))
                                        )) or
                                    
                                        -- Bloques de Incremento: BALA
                                        ((MENU_STATE_LED(3) = '1') and (
                                        ((h_cntr_reg_dly > IBALA1_LEFT - 3 and h_cntr_reg_dly < IBALA1_RIGHT + 3 and v_cntr_reg_dly > IBALA1_TOP - 3 and v_cntr_reg_dly < IBALA1_BOTTOM + 3) and
                                        (selected_estandar = '1'))
                                        )))
                                        )
               else
               
               -- Painting a yellow border around the selectable BRAM blocks being hovered
               x"F" when                (-- Bloques Principales (Menú Raíz)
                                        ((MENU_STATE_LED(0) = '1') and (
                                        ((h_cntr_reg_dly > CLASICO_LEFT - 3   and h_cntr_reg_dly < CLASICO_RIGHT + 3   and v_cntr_reg_dly > CLASICO_TOP - 3   and v_cntr_reg_dly < CLASICO_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > CLASICO_LEFT     and MOUSE_X_PIXEL < CLASICO_RIGHT    and MOUSE_Y_PIXEL > CLASICO_TOP    and MOUSE_Y_PIXEL < CLASICO_BOTTOM)) or
                                        ((h_cntr_reg_dly > RAPIDO_LEFT - 3    and h_cntr_reg_dly < RAPIDO_RIGHT + 3    and v_cntr_reg_dly > RAPIDO_TOP - 3    and v_cntr_reg_dly < RAPIDO_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > RAPIDO_LEFT      and MOUSE_X_PIXEL < RAPIDO_RIGHT     and MOUSE_Y_PIXEL > RAPIDO_TOP     and MOUSE_Y_PIXEL < RAPIDO_BOTTOM)) or
                                        ((h_cntr_reg_dly > RELAMPAGO_LEFT - 3 and h_cntr_reg_dly < RELAMPAGO_RIGHT + 3 and v_cntr_reg_dly > RELAMPAGO_TOP - 3 and v_cntr_reg_dly < RELAMPAGO_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > RELAMPAGO_LEFT   and MOUSE_X_PIXEL < RELAMPAGO_RIGHT  and MOUSE_Y_PIXEL > RELAMPAGO_TOP  and MOUSE_Y_PIXEL < RELAMPAGO_BOTTOM)) or
                                        ((h_cntr_reg_dly > BALA_LEFT - 3      and h_cntr_reg_dly < BALA_RIGHT + 3      and v_cntr_reg_dly > BALA_TOP - 3      and v_cntr_reg_dly < BALA_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > BALA_LEFT        and MOUSE_X_PIXEL < BALA_RIGHT       and MOUSE_Y_PIXEL > BALA_TOP       and MOUSE_Y_PIXEL < BALA_BOTTOM))
                                        )) or
                                        
                                        -- Bloque "ATRAS"
                                        ((MENU_STATE_LED(3) = '1' or MENU_STATE_LED(2) = '1' or MENU_STATE_LED(1) = '1') and (
                                        ((h_cntr_reg_dly > ATRAS_LEFT - 3 and h_cntr_reg_dly < ATRAS_RIGHT + 3 and v_cntr_reg_dly > ATRAS_TOP - 3 and v_cntr_reg_dly < ATRAS_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > ATRAS_LEFT   and MOUSE_X_PIXEL < ATRAS_RIGHT  and MOUSE_Y_PIXEL > ATRAS_TOP  and MOUSE_Y_PIXEL < ATRAS_BOTTOM))
                                        )) or
                                    
                                        -- Bloque "JUGAR"
                                        ((MENU_STATE_LED(3) = '1') and (
                                        ((h_cntr_reg_dly > JUGAR_LEFT - 3 and h_cntr_reg_dly < JUGAR_RIGHT + 3 and v_cntr_reg_dly > JUGAR_TOP - 3 and v_cntr_reg_dly < JUGAR_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > JUGAR_LEFT   and MOUSE_X_PIXEL < JUGAR_RIGHT  and MOUSE_Y_PIXEL > JUGAR_TOP  and MOUSE_Y_PIXEL < JUGAR_BOTTOM))
                                        )) or
                                    
                                        -- Bloques de Tiempo: CLÁSICO
                                        ((MENU_STATE_LED(1) = '1') and (MODE_CONFIG = "00" and (
                                        ((h_cntr_reg_dly > TCLASICO1_LEFT - 3 and h_cntr_reg_dly < TCLASICO1_RIGHT + 3 and v_cntr_reg_dly > TCLASICO1_TOP - 3 and v_cntr_reg_dly < TCLASICO1_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TCLASICO1_LEFT   and MOUSE_X_PIXEL < TCLASICO1_RIGHT  and MOUSE_Y_PIXEL > TCLASICO1_TOP  and MOUSE_Y_PIXEL < TCLASICO1_BOTTOM)) or
                                        ((h_cntr_reg_dly > TCLASICO2_LEFT - 3 and h_cntr_reg_dly < TCLASICO2_RIGHT + 3 and v_cntr_reg_dly > TCLASICO2_TOP - 3 and v_cntr_reg_dly < TCLASICO2_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TCLASICO2_LEFT   and MOUSE_X_PIXEL < TCLASICO2_RIGHT  and MOUSE_Y_PIXEL > TCLASICO2_TOP  and MOUSE_Y_PIXEL < TCLASICO2_BOTTOM)) or
                                        ((h_cntr_reg_dly > TCLASICO3_LEFT - 3 and h_cntr_reg_dly < TCLASICO3_RIGHT + 3 and v_cntr_reg_dly > TCLASICO3_TOP - 3 and v_cntr_reg_dly < TCLASICO3_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TCLASICO3_LEFT   and MOUSE_X_PIXEL < TCLASICO3_RIGHT  and MOUSE_Y_PIXEL > TCLASICO3_TOP  and MOUSE_Y_PIXEL < TCLASICO3_BOTTOM)) or
                                        ((h_cntr_reg_dly > TCLASICO4_LEFT - 3 and h_cntr_reg_dly < TCLASICO4_RIGHT + 3 and v_cntr_reg_dly > TCLASICO4_TOP - 3 and v_cntr_reg_dly < TCLASICO4_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TCLASICO4_LEFT   and MOUSE_X_PIXEL < TCLASICO4_RIGHT  and MOUSE_Y_PIXEL > TCLASICO4_TOP  and MOUSE_Y_PIXEL < TCLASICO4_BOTTOM))
                                        ))) or
                                    
                                        -- Bloques de Tiempo: RÁPIDO
                                        ((MENU_STATE_LED(1) = '1') and (MODE_CONFIG = "01" and (
                                        ((h_cntr_reg_dly > TRAPIDO1_LEFT - 3 and h_cntr_reg_dly < TRAPIDO1_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO1_TOP - 3 and v_cntr_reg_dly < TRAPIDO1_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRAPIDO1_LEFT   and MOUSE_X_PIXEL < TRAPIDO1_RIGHT  and MOUSE_Y_PIXEL > TRAPIDO1_TOP  and MOUSE_Y_PIXEL < TRAPIDO1_BOTTOM)) or
                                        ((h_cntr_reg_dly > TRAPIDO2_LEFT - 3 and h_cntr_reg_dly < TRAPIDO2_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO2_TOP - 3 and v_cntr_reg_dly < TRAPIDO2_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRAPIDO2_LEFT   and MOUSE_X_PIXEL < TRAPIDO2_RIGHT  and MOUSE_Y_PIXEL > TRAPIDO2_TOP  and MOUSE_Y_PIXEL < TRAPIDO2_BOTTOM)) or
                                        ((h_cntr_reg_dly > TRAPIDO3_LEFT - 3 and h_cntr_reg_dly < TRAPIDO3_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO3_TOP - 3 and v_cntr_reg_dly < TRAPIDO3_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRAPIDO3_LEFT   and MOUSE_X_PIXEL < TRAPIDO3_RIGHT  and MOUSE_Y_PIXEL > TRAPIDO3_TOP  and MOUSE_Y_PIXEL < TRAPIDO3_BOTTOM)) or
                                        ((h_cntr_reg_dly > TRAPIDO4_LEFT - 3 and h_cntr_reg_dly < TRAPIDO4_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO4_TOP - 3 and v_cntr_reg_dly < TRAPIDO4_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRAPIDO4_LEFT   and MOUSE_X_PIXEL < TRAPIDO4_RIGHT  and MOUSE_Y_PIXEL > TRAPIDO4_TOP  and MOUSE_Y_PIXEL < TRAPIDO4_BOTTOM)) or
                                        ((h_cntr_reg_dly > TRAPIDO5_LEFT - 3 and h_cntr_reg_dly < TRAPIDO5_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO5_TOP - 3 and v_cntr_reg_dly < TRAPIDO5_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRAPIDO5_LEFT   and MOUSE_X_PIXEL < TRAPIDO5_RIGHT  and MOUSE_Y_PIXEL > TRAPIDO5_TOP  and MOUSE_Y_PIXEL < TRAPIDO5_BOTTOM)) or
                                        ((h_cntr_reg_dly > TRAPIDO6_LEFT - 3 and h_cntr_reg_dly < TRAPIDO6_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO6_TOP - 3 and v_cntr_reg_dly < TRAPIDO6_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRAPIDO6_LEFT   and MOUSE_X_PIXEL < TRAPIDO6_RIGHT  and MOUSE_Y_PIXEL > TRAPIDO6_TOP  and MOUSE_Y_PIXEL < TRAPIDO6_BOTTOM))
                                        ))) or
                                    
                                        -- Bloques de Tiempo: RELÁMPAGO
                                        ((MENU_STATE_LED(1) = '1') and (MODE_CONFIG = "10" and (
                                        ((h_cntr_reg_dly > TRELAMPAGO1_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO1_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO1_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO1_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRELAMPAGO1_LEFT   and MOUSE_X_PIXEL < TRELAMPAGO1_RIGHT  and MOUSE_Y_PIXEL > TRELAMPAGO1_TOP  and MOUSE_Y_PIXEL < TRELAMPAGO1_BOTTOM)) or
                                        ((h_cntr_reg_dly > TRELAMPAGO2_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO2_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO2_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO2_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRELAMPAGO2_LEFT   and MOUSE_X_PIXEL < TRELAMPAGO2_RIGHT  and MOUSE_Y_PIXEL > TRELAMPAGO2_TOP  and MOUSE_Y_PIXEL < TRELAMPAGO2_BOTTOM)) or
                                        ((h_cntr_reg_dly > TRELAMPAGO3_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO3_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO3_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO3_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRELAMPAGO3_LEFT   and MOUSE_X_PIXEL < TRELAMPAGO3_RIGHT  and MOUSE_Y_PIXEL > TRELAMPAGO3_TOP  and MOUSE_Y_PIXEL < TRELAMPAGO3_BOTTOM)) or
                                        ((h_cntr_reg_dly > TRELAMPAGO4_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO4_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO4_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO4_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRELAMPAGO4_LEFT   and MOUSE_X_PIXEL < TRELAMPAGO4_RIGHT  and MOUSE_Y_PIXEL > TRELAMPAGO4_TOP  and MOUSE_Y_PIXEL < TRELAMPAGO4_BOTTOM))
                                        ))) or
                                    
                                        -- Bloques de Tiempo: BALA
                                        ((MENU_STATE_LED(1) = '1') and (MODE_CONFIG = "11" and (
                                        ((h_cntr_reg_dly > TBALA1_LEFT - 3 and h_cntr_reg_dly < TBALA1_RIGHT + 3 and v_cntr_reg_dly > TBALA1_TOP - 3 and v_cntr_reg_dly < TBALA1_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TBALA1_LEFT   and MOUSE_X_PIXEL < TBALA1_RIGHT  and MOUSE_Y_PIXEL > TBALA1_TOP  and MOUSE_Y_PIXEL < TBALA1_BOTTOM)) or
                                        ((h_cntr_reg_dly > TBALA2_LEFT - 3 and h_cntr_reg_dly < TBALA2_RIGHT + 3 and v_cntr_reg_dly > TBALA2_TOP - 3 and v_cntr_reg_dly < TBALA2_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TBALA2_LEFT   and MOUSE_X_PIXEL < TBALA2_RIGHT  and MOUSE_Y_PIXEL > TBALA2_TOP  and MOUSE_Y_PIXEL < TBALA2_BOTTOM))
                                        ))) or
                                    
                                        -- Bloques de Incremento: CLÁSICO
                                        ((MENU_STATE_LED(2) = '1') and (
                                        ((MODE_CONFIG = "00" or ((MODE_CONFIG = "10" or MODE_CONFIG = "01") and TIME_CONFIG = "000")) and (
                                        ((h_cntr_reg_dly > ICLASICO1_LEFT - 3 and h_cntr_reg_dly < ICLASICO1_RIGHT + 3 and v_cntr_reg_dly > ICLASICO1_TOP - 3 and v_cntr_reg_dly < ICLASICO1_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > ICLASICO1_LEFT   and MOUSE_X_PIXEL < ICLASICO1_RIGHT  and MOUSE_Y_PIXEL > ICLASICO1_TOP  and MOUSE_Y_PIXEL < ICLASICO1_BOTTOM))
                                        )
                                        ))) or
                                    
                                        -- Bloques de Incremento: RÁPIDO
                                        ((MENU_STATE_LED(2) = '1') and (MODE_CONFIG = "01" and (
                                        TIME_CONFIG /= "000" and (
                                        ((h_cntr_reg_dly > IRAPIDO4_LEFT - 3 and h_cntr_reg_dly < IRAPIDO4_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO4_TOP - 3 and v_cntr_reg_dly < IRAPIDO4_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > IRAPIDO4_LEFT   and MOUSE_X_PIXEL < IRAPIDO4_RIGHT  and MOUSE_Y_PIXEL > IRAPIDO4_TOP  and MOUSE_Y_PIXEL < IRAPIDO4_BOTTOM)) or
                                        (TIME_CONFIG /= "001" and (
                                        ((h_cntr_reg_dly > IRAPIDO3_LEFT - 3 and h_cntr_reg_dly < IRAPIDO3_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO3_TOP - 3 and v_cntr_reg_dly < IRAPIDO3_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > IRAPIDO3_LEFT   and MOUSE_X_PIXEL < IRAPIDO3_RIGHT  and MOUSE_Y_PIXEL > IRAPIDO3_TOP  and MOUSE_Y_PIXEL < IRAPIDO3_BOTTOM)) or
                                        ((h_cntr_reg_dly > IRAPIDO2_LEFT - 3 and h_cntr_reg_dly < IRAPIDO2_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO2_TOP - 3 and v_cntr_reg_dly < IRAPIDO2_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > IRAPIDO2_LEFT   and MOUSE_X_PIXEL < IRAPIDO2_RIGHT  and MOUSE_Y_PIXEL > IRAPIDO2_TOP  and MOUSE_Y_PIXEL < IRAPIDO2_BOTTOM)) or
                                        (TIME_CONFIG /= "010" and (
                                        ((h_cntr_reg_dly > IRAPIDO1_LEFT - 3 and h_cntr_reg_dly < IRAPIDO1_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO1_TOP - 3 and v_cntr_reg_dly < IRAPIDO1_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > IRAPIDO1_LEFT   and MOUSE_X_PIXEL < IRAPIDO1_RIGHT  and MOUSE_Y_PIXEL > IRAPIDO1_TOP  and MOUSE_Y_PIXEL < IRAPIDO1_BOTTOM))
                                        )))
                                        )
                                        )))) or
                                    
                                        -- Bloques de Incremento: RELÁMPAGO
                                        ((MENU_STATE_LED(2) = '1') and (MODE_CONFIG = "10" and (
                                        TIME_CONFIG /= "000" and (
                                        ((h_cntr_reg_dly > IRELAMPAGO4_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO4_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO4_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO4_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > IRELAMPAGO4_LEFT   and MOUSE_X_PIXEL < IRELAMPAGO4_RIGHT  and MOUSE_Y_PIXEL > IRELAMPAGO4_TOP  and MOUSE_Y_PIXEL < IRELAMPAGO4_BOTTOM)) or
                                        (TIME_CONFIG /= "010" and (
                                        ((h_cntr_reg_dly > IRELAMPAGO1_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO1_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO1_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO1_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > IRELAMPAGO1_LEFT   and MOUSE_X_PIXEL < IRELAMPAGO1_RIGHT  and MOUSE_Y_PIXEL > IRELAMPAGO1_TOP  and MOUSE_Y_PIXEL < IRELAMPAGO1_BOTTOM)) or
                                        ((h_cntr_reg_dly > IRELAMPAGO2_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO2_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO2_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO2_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > IRELAMPAGO2_LEFT   and MOUSE_X_PIXEL < IRELAMPAGO2_RIGHT  and MOUSE_Y_PIXEL > IRELAMPAGO2_TOP  and MOUSE_Y_PIXEL < IRELAMPAGO2_BOTTOM)) or
                                        ((h_cntr_reg_dly > IRELAMPAGO3_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO3_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO3_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO3_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > IRELAMPAGO3_LEFT   and MOUSE_X_PIXEL < IRELAMPAGO3_RIGHT  and MOUSE_Y_PIXEL > IRELAMPAGO3_TOP  and MOUSE_Y_PIXEL < IRELAMPAGO3_BOTTOM)) 
                                        ))
                                        )
                                        ))) or
                                    
                                        -- Bloques de Incremento: BALA
                                        ((MENU_STATE_LED(2) = '1') and (MODE_CONFIG = "11" and (
                                        ((h_cntr_reg_dly > IBALA1_LEFT - 3 and h_cntr_reg_dly < IBALA1_RIGHT + 3 and v_cntr_reg_dly > IBALA1_TOP - 3 and v_cntr_reg_dly < IBALA1_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > IBALA1_LEFT   and MOUSE_X_PIXEL < IBALA1_RIGHT  and MOUSE_Y_PIXEL > IBALA1_TOP  and MOUSE_Y_PIXEL < IBALA1_BOTTOM))
                                        ))) or
                                        
                                        -- Bloque "SI" y bloque "NO"
                                        ((MENU_STATE_LED(5) = '1') and (
                                        ((h_cntr_reg_dly > SI_LEFT - 3 and h_cntr_reg_dly < SI_RIGHT + 3 and v_cntr_reg_dly > SI_TOP - 3 and v_cntr_reg_dly < SI_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > SI_LEFT   and MOUSE_X_PIXEL < SI_RIGHT  and MOUSE_Y_PIXEL > SI_TOP  and MOUSE_Y_PIXEL < SI_BOTTOM)) or
                                        ((h_cntr_reg_dly > NO_LEFT - 3 and h_cntr_reg_dly < NO_RIGHT + 3 and v_cntr_reg_dly > NO_TOP - 3 and v_cntr_reg_dly < NO_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > NO_LEFT   and MOUSE_X_PIXEL < NO_RIGHT  and MOUSE_Y_PIXEL > NO_TOP  and MOUSE_Y_PIXEL < NO_BOTTOM))
                                        ))
                                        )
               else
                                        
               -- Painting a red border around the BRAM blocks
               x"F" when                (-- Bloques Principales (Menú Raíz)
                                        ((MENU_STATE_LED(4) = '0' and MENU_STATE_LED(5) = '0') and (
                                        (h_cntr_reg_dly > CLASICO_LEFT - 3    and h_cntr_reg_dly < CLASICO_RIGHT + 3    and v_cntr_reg_dly > CLASICO_TOP - 3    and v_cntr_reg_dly < CLASICO_BOTTOM + 3) or
                                        (h_cntr_reg_dly > RAPIDO_LEFT - 3     and h_cntr_reg_dly < RAPIDO_RIGHT + 3     and v_cntr_reg_dly > RAPIDO_TOP - 3     and v_cntr_reg_dly < RAPIDO_BOTTOM + 3) or
                                        (h_cntr_reg_dly > RELAMPAGO_LEFT - 3  and h_cntr_reg_dly < RELAMPAGO_RIGHT + 3  and v_cntr_reg_dly > RELAMPAGO_TOP - 3  and v_cntr_reg_dly < RELAMPAGO_BOTTOM + 3) or
                                        (h_cntr_reg_dly > BALA_LEFT - 3       and h_cntr_reg_dly < BALA_RIGHT + 3       and v_cntr_reg_dly > BALA_TOP - 3       and v_cntr_reg_dly < BALA_BOTTOM + 3)
                                        )) or
                                        
                                        -- Bloque "ATRAS"
                                        ((MENU_STATE_LED(3) = '1' or MENU_STATE_LED(2) = '1' or MENU_STATE_LED(1) = '1') and (
                                        (h_cntr_reg_dly > ATRAS_LEFT - 3 and h_cntr_reg_dly < ATRAS_RIGHT + 3 and v_cntr_reg_dly > ATRAS_TOP - 3 and v_cntr_reg_dly < ATRAS_BOTTOM + 3)
                                        )) or
                                    
                                        -- Bloque "JUGAR"
                                        ((MENU_STATE_LED(3) = '1') and (
                                        (h_cntr_reg_dly > JUGAR_LEFT - 3 and h_cntr_reg_dly < JUGAR_RIGHT + 3 and v_cntr_reg_dly > JUGAR_TOP - 3 and v_cntr_reg_dly < JUGAR_BOTTOM + 3)
                                        )) or
                                    
                                        -- Bloques de Tiempo: CLÁSICO
                                        ((MENU_STATE_LED(3 downto 1) /= "000") and (MODE_CONFIG = "00" and (
                                        (h_cntr_reg_dly > TCLASICO1_LEFT - 3 and h_cntr_reg_dly < TCLASICO1_RIGHT + 3 and v_cntr_reg_dly > TCLASICO1_TOP - 3 and v_cntr_reg_dly < TCLASICO1_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TCLASICO2_LEFT - 3 and h_cntr_reg_dly < TCLASICO2_RIGHT + 3 and v_cntr_reg_dly > TCLASICO2_TOP - 3 and v_cntr_reg_dly < TCLASICO2_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TCLASICO3_LEFT - 3 and h_cntr_reg_dly < TCLASICO3_RIGHT + 3 and v_cntr_reg_dly > TCLASICO3_TOP - 3 and v_cntr_reg_dly < TCLASICO3_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TCLASICO4_LEFT - 3 and h_cntr_reg_dly < TCLASICO4_RIGHT + 3 and v_cntr_reg_dly > TCLASICO4_TOP - 3 and v_cntr_reg_dly < TCLASICO4_BOTTOM + 3)
                                        ))) or
                                    
                                        -- Bloques de Tiempo: RÁPIDO
                                        ((MENU_STATE_LED(3 downto 1) /= "000") and (MODE_CONFIG = "01" and (
                                        (h_cntr_reg_dly > TRAPIDO1_LEFT - 3 and h_cntr_reg_dly < TRAPIDO1_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO1_TOP - 3 and v_cntr_reg_dly < TRAPIDO1_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TRAPIDO2_LEFT - 3 and h_cntr_reg_dly < TRAPIDO2_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO2_TOP - 3 and v_cntr_reg_dly < TRAPIDO2_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TRAPIDO3_LEFT - 3 and h_cntr_reg_dly < TRAPIDO3_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO3_TOP - 3 and v_cntr_reg_dly < TRAPIDO3_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TRAPIDO4_LEFT - 3 and h_cntr_reg_dly < TRAPIDO4_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO4_TOP - 3 and v_cntr_reg_dly < TRAPIDO4_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TRAPIDO5_LEFT - 3 and h_cntr_reg_dly < TRAPIDO5_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO5_TOP - 3 and v_cntr_reg_dly < TRAPIDO5_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TRAPIDO6_LEFT - 3 and h_cntr_reg_dly < TRAPIDO6_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO6_TOP - 3 and v_cntr_reg_dly < TRAPIDO6_BOTTOM + 3)
                                        ))) or
                                    
                                        -- Bloques de Tiempo: RELÁMPAGO
                                        ((MENU_STATE_LED(3 downto 1) /= "000") and (MODE_CONFIG = "10" and (
                                        (h_cntr_reg_dly > TRELAMPAGO1_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO1_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO1_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO1_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TRELAMPAGO2_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO2_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO2_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO2_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TRELAMPAGO3_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO3_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO3_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO3_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TRELAMPAGO4_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO4_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO4_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO4_BOTTOM + 3)
                                        ))) or
                                    
                                        -- Bloques de Tiempo: BALA
                                        ((MENU_STATE_LED(3 downto 1) /= "000") and (MODE_CONFIG = "11" and (
                                        (h_cntr_reg_dly > TBALA1_LEFT - 3 and h_cntr_reg_dly < TBALA1_RIGHT + 3 and v_cntr_reg_dly > TBALA1_TOP - 3 and v_cntr_reg_dly < TBALA1_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TBALA2_LEFT - 3 and h_cntr_reg_dly < TBALA2_RIGHT + 3 and v_cntr_reg_dly > TBALA2_TOP - 3 and v_cntr_reg_dly < TBALA2_BOTTOM + 3)
                                        ))) or
                                    
                                        -- Bloques de Incremento: CLÁSICO
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (
                                        ((MODE_CONFIG = "00" or ((MODE_CONFIG = "10" or MODE_CONFIG = "01") and TIME_CONFIG = "000")) and (
                                        (h_cntr_reg_dly > ICLASICO1_LEFT - 3 and h_cntr_reg_dly < ICLASICO1_RIGHT + 3 and v_cntr_reg_dly > ICLASICO1_TOP - 3 and v_cntr_reg_dly < ICLASICO1_BOTTOM + 3)
                                        )))) or
                                    
                                        -- Bloques de Incremento: RÁPIDO
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (MODE_CONFIG = "01" and (
                                        TIME_CONFIG /= "000" and (
                                        (h_cntr_reg_dly > IRAPIDO4_LEFT - 3 and h_cntr_reg_dly < IRAPIDO4_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO4_TOP - 3 and v_cntr_reg_dly < IRAPIDO4_BOTTOM + 3) or
                                        (TIME_CONFIG /= "001" and (
                                        (h_cntr_reg_dly > IRAPIDO3_LEFT - 3 and h_cntr_reg_dly < IRAPIDO3_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO3_TOP - 3 and v_cntr_reg_dly < IRAPIDO3_BOTTOM + 3) or
                                        (h_cntr_reg_dly > IRAPIDO2_LEFT - 3 and h_cntr_reg_dly < IRAPIDO2_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO2_TOP - 3 and v_cntr_reg_dly < IRAPIDO2_BOTTOM + 3) or
                                        (TIME_CONFIG /= "010" and (
                                        (h_cntr_reg_dly > IRAPIDO1_LEFT - 3 and h_cntr_reg_dly < IRAPIDO1_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO1_TOP - 3 and v_cntr_reg_dly < IRAPIDO1_BOTTOM + 3)
                                        )))
                                        )
                                        )))) or
                                    
                                        -- Bloques de Incremento: RELÁMPAGO
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (MODE_CONFIG = "10" and (
                                        TIME_CONFIG /= "000" and (
                                        (h_cntr_reg_dly > IRELAMPAGO4_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO4_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO4_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO4_BOTTOM + 3) or
                                        (TIME_CONFIG /= "010" and (
                                        (h_cntr_reg_dly > IRELAMPAGO1_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO1_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO1_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO1_BOTTOM + 3) or
                                        (h_cntr_reg_dly > IRELAMPAGO2_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO2_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO2_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO2_BOTTOM + 3) or
                                        (h_cntr_reg_dly > IRELAMPAGO3_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO3_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO3_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO3_BOTTOM + 3)
                                        ))
                                        ) 
                                        ))) or
                                    
                                        -- Bloques de Incremento: BALA
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (MODE_CONFIG = "11" and (
                                        (h_cntr_reg_dly > IBALA1_LEFT - 3 and h_cntr_reg_dly < IBALA1_RIGHT + 3 and v_cntr_reg_dly > IBALA1_TOP - 3 and v_cntr_reg_dly < IBALA1_BOTTOM + 3)
                                        ))) or
                                        
                                        -- Bloque "SI" y bloque "NO"
                                        ((MENU_STATE_LED(5) = '1') and (
                                        (h_cntr_reg_dly > SI_LEFT - 3 and h_cntr_reg_dly < SI_RIGHT + 3 and v_cntr_reg_dly > SI_TOP - 3 and v_cntr_reg_dly < SI_BOTTOM + 3) or
                                        (h_cntr_reg_dly > NO_LEFT - 3 and h_cntr_reg_dly < NO_RIGHT + 3 and v_cntr_reg_dly > NO_TOP - 3 and v_cntr_reg_dly < NO_BOTTOM + 3)
                                        ))
                                        )
               else
               
               -- Pintar rectángulo blanco que simula ventana de pausa durante una partida en progreso
               x"F" when
                                        -- Bloque de texto de la ventana emergente
                                        ((MENU_STATE_LED(5) = '1') and (
                                        (h_cntr_reg_dly > 610 and h_cntr_reg_dly < 1310 and v_cntr_reg_dly > VENTANA_TOP and v_cntr_reg_dly < 800)
                                        ))
               else
               
               -- Pintar rectángulos blancos que contienen las cuentas de los jugadores durante la partida
               x"F" when                ((MENU_STATE_LED(4) = '1') and (
                                        (h_cntr_reg_dly > 280  and h_cntr_reg_dly < 860  and v_cntr_reg_dly > 680 and v_cntr_reg_dly < 870) or
                                        (h_cntr_reg_dly > 1100 and h_cntr_reg_dly < 1680 and v_cntr_reg_dly > 680 and v_cntr_reg_dly < 870)
                                        ))
               else
               
               -- Painting a grey border around non-selectable blocks
               x"8" when                (-- Bloques del menú fijo (MODO, TIEMPO e INCREMENTO)
                                        ((MENU_STATE_LED(4) = '0' and MENU_STATE_LED(5) = '0') and (
                                        (h_cntr_reg_dly > MODO_LEFT - 3       and h_cntr_reg_dly < MODO_RIGHT + 3       and v_cntr_reg_dly > MODO_TOP - 3       and v_cntr_reg_dly < MODO_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TIEMPO_LEFT - 3     and h_cntr_reg_dly < TIEMPO_RIGHT + 3     and v_cntr_reg_dly > TIEMPO_TOP - 3     and v_cntr_reg_dly < TIEMPO_BOTTOM + 3) or
                                        (h_cntr_reg_dly > INCREMENTO_LEFT - 3 and h_cntr_reg_dly < INCREMENTO_RIGHT + 3 and v_cntr_reg_dly > INCREMENTO_TOP - 3 and v_cntr_reg_dly < INCREMENTO_BOTTOM + 3)
                                        )) or
                                        
                                        -- Bloque "PIEZAS BLANCAS" y bloque "PIEZAS NEGRAS"
                                        ((MENU_STATE_LED(4) = '1') and (
                                        (h_cntr_reg_dly > BLANCAS_LEFT - 3 and h_cntr_reg_dly < BLANCAS_RIGHT + 3 and v_cntr_reg_dly > BLANCAS_TOP - 3 and v_cntr_reg_dly < BLANCAS_BOTTOM + 3) or
                                        (h_cntr_reg_dly > NEGRAS_LEFT - 3  and h_cntr_reg_dly < NEGRAS_RIGHT + 3  and v_cntr_reg_dly > NEGRAS_TOP - 3  and v_cntr_reg_dly < NEGRAS_BOTTOM + 3)
                                        )) or
                                        
                                        -- Bloque de texto de la ventana emergente
                                        ((MENU_STATE_LED(5) = '1') and (
                                        (h_cntr_reg_dly > 610 - 3 and h_cntr_reg_dly < 1310 + 3 and v_cntr_reg_dly > VENTANA_TOP - 3 and v_cntr_reg_dly < 800 + 3)
                                        )) or
                                        
                                        -- Bloques de los títulos
                                        ((MENU_STATE_LED(5) = '0') and
                                        (h_cntr_reg_dly > TITULO_LEFT - 3 and h_cntr_reg_dly < TITULO_RIGHT + 3 and v_cntr_reg_dly > TITULO_TOP - 3 and v_cntr_reg_dly < TITULO_BOTTOM + 3)
                                        ) or
                                        
                                        -- Bloques blancos que contienen las cuentas
                                        ((MENU_STATE_LED(4) = '1') and (
                                        (h_cntr_reg_dly > 280 - 3  and h_cntr_reg_dly < 860 + 3  and v_cntr_reg_dly > 680 - 3 and v_cntr_reg_dly < 870 + 3) or
                                        (h_cntr_reg_dly > 1100 - 3 and h_cntr_reg_dly < 1680 + 3 and v_cntr_reg_dly > 680 - 3 and v_cntr_reg_dly < 870 + 3)
                                        ))
                                        )
               else
               -- Colorbar will be on the backround
               bg_red_dly;
                
-----------
-- Green
-----------

  vga_green <= -- Mouse_cursor_display is on the top of others
               mouse_cursor_green_dly when enable_mouse_display_dly = '1'
--               else
--               -- Overlay display is black 
--               x"0" when overlay_en_dly = '1'
               else
               -- Display of BRAM content
               
               -- Pintar títulos de pantalla
               overlay_output_titulos when (                    
                                        -- Bloque "MENU DE AJEDREZ" y bloque "PARTIDA EN CURSO"
                                        ((MENU_STATE_LED(5) = '0') and
                                        (h_cntr_reg > TITULO_LEFT and h_cntr_reg < TITULO_RIGHT and v_cntr_reg > TITULO_TOP and v_cntr_reg < TITULO_BOTTOM)
                                        ))
               else
               
               -- Pintar bloques fijos y modos de juego
               overlay_output_modo when (-- Bloques Principales (Menú Raíz)
                                        ((MENU_STATE_LED(4) = '0' and MENU_STATE_LED(5) = '0') and (
                                        (h_cntr_reg_dly > MODO_LEFT       and h_cntr_reg_dly < MODO_RIGHT       and v_cntr_reg_dly > MODO_TOP       and v_cntr_reg_dly < MODO_BOTTOM) or
                                        (h_cntr_reg_dly > TIEMPO_LEFT     and h_cntr_reg_dly < TIEMPO_RIGHT     and v_cntr_reg_dly > TIEMPO_TOP     and v_cntr_reg_dly < TIEMPO_BOTTOM) or
                                        (h_cntr_reg_dly > INCREMENTO_LEFT and h_cntr_reg_dly < INCREMENTO_RIGHT and v_cntr_reg_dly > INCREMENTO_TOP and v_cntr_reg_dly < INCREMENTO_BOTTOM) or
                                        (h_cntr_reg_dly > CLASICO_LEFT    and h_cntr_reg_dly < CLASICO_RIGHT    and v_cntr_reg_dly > CLASICO_TOP    and v_cntr_reg_dly < CLASICO_BOTTOM) or
                                        (h_cntr_reg_dly > RAPIDO_LEFT     and h_cntr_reg_dly < RAPIDO_RIGHT     and v_cntr_reg_dly > RAPIDO_TOP     and v_cntr_reg_dly < RAPIDO_BOTTOM) or
                                        (h_cntr_reg_dly > RELAMPAGO_LEFT  and h_cntr_reg_dly < RELAMPAGO_RIGHT  and v_cntr_reg_dly > RELAMPAGO_TOP  and v_cntr_reg_dly < RELAMPAGO_BOTTOM) or
                                        (h_cntr_reg_dly > BALA_LEFT       and h_cntr_reg_dly < BALA_RIGHT       and v_cntr_reg_dly > BALA_TOP       and v_cntr_reg_dly < BALA_BOTTOM)
                                        )))
               else
               
               -- Pintar iconos de navegación del menú
               overlay_output_nav when (                    
                                        -- Bloque "ATRAS"
                                        ((MENU_STATE_LED(3) = '1' or MENU_STATE_LED(2) = '1' or MENU_STATE_LED(1) = '1') and (
                                        (h_cntr_reg_dly > ATRAS_LEFT and h_cntr_reg_dly < ATRAS_RIGHT and v_cntr_reg_dly > ATRAS_TOP and v_cntr_reg_dly < ATRAS_BOTTOM)
                                        )) or
                                    
                                        -- Bloque "JUGAR"
                                        ((MENU_STATE_LED(3) = '1') and (
                                        (h_cntr_reg_dly > JUGAR_LEFT and h_cntr_reg_dly < JUGAR_RIGHT and v_cntr_reg_dly > JUGAR_TOP and v_cntr_reg_dly < JUGAR_BOTTOM)
                                        ))                                
                                        )
               else
               
               -- Pintar tiempo e incrementos
               overlay_output_tiempo when (                    
                                        -- Bloques de Tiempo: CLÁSICO
                                        ((MENU_STATE_LED(3 downto 1) /= "000") and (MODE_CONFIG = "00" and (
                                        (h_cntr_reg_dly > TCLASICO1_LEFT and h_cntr_reg_dly < TCLASICO1_RIGHT and v_cntr_reg_dly > TCLASICO1_TOP and v_cntr_reg_dly < TCLASICO1_BOTTOM) or
                                        (h_cntr_reg_dly > TCLASICO2_LEFT and h_cntr_reg_dly < TCLASICO2_RIGHT and v_cntr_reg_dly > TCLASICO2_TOP and v_cntr_reg_dly < TCLASICO2_BOTTOM) or
                                        (h_cntr_reg_dly > TCLASICO3_LEFT and h_cntr_reg_dly < TCLASICO3_RIGHT and v_cntr_reg_dly > TCLASICO3_TOP and v_cntr_reg_dly < TCLASICO3_BOTTOM) or
                                        (h_cntr_reg_dly > TCLASICO4_LEFT and h_cntr_reg_dly < TCLASICO4_RIGHT and v_cntr_reg_dly > TCLASICO4_TOP and v_cntr_reg_dly < TCLASICO4_BOTTOM)
                                        ))) or
                                    
                                        -- Bloques de Tiempo: RÁPIDO
                                        ((MENU_STATE_LED(3 downto 1) /= "000") and (MODE_CONFIG = "01" and (
                                        (h_cntr_reg_dly > TRAPIDO1_LEFT and h_cntr_reg_dly < TRAPIDO1_RIGHT and v_cntr_reg_dly > TRAPIDO1_TOP and v_cntr_reg_dly < TRAPIDO1_BOTTOM) or
                                        (h_cntr_reg_dly > TRAPIDO2_LEFT and h_cntr_reg_dly < TRAPIDO2_RIGHT and v_cntr_reg_dly > TRAPIDO2_TOP and v_cntr_reg_dly < TRAPIDO2_BOTTOM) or
                                        (h_cntr_reg_dly > TRAPIDO3_LEFT and h_cntr_reg_dly < TRAPIDO3_RIGHT and v_cntr_reg_dly > TRAPIDO3_TOP and v_cntr_reg_dly < TRAPIDO3_BOTTOM) or
                                        (h_cntr_reg_dly > TRAPIDO4_LEFT and h_cntr_reg_dly < TRAPIDO4_RIGHT and v_cntr_reg_dly > TRAPIDO4_TOP and v_cntr_reg_dly < TRAPIDO4_BOTTOM) or
                                        (h_cntr_reg_dly > TRAPIDO5_LEFT and h_cntr_reg_dly < TRAPIDO5_RIGHT and v_cntr_reg_dly > TRAPIDO5_TOP and v_cntr_reg_dly < TRAPIDO5_BOTTOM) or
                                        (h_cntr_reg_dly > TRAPIDO6_LEFT and h_cntr_reg_dly < TRAPIDO6_RIGHT and v_cntr_reg_dly > TRAPIDO6_TOP and v_cntr_reg_dly < TRAPIDO6_BOTTOM)
                                        ))) or
                                    
                                        -- Bloques de Tiempo: RELÁMPAGO
                                        ((MENU_STATE_LED(3 downto 1) /= "000") and (MODE_CONFIG = "10" and (
                                        (h_cntr_reg_dly > TRELAMPAGO1_LEFT and h_cntr_reg_dly < TRELAMPAGO1_RIGHT and v_cntr_reg_dly > TRELAMPAGO1_TOP and v_cntr_reg_dly < TRELAMPAGO1_BOTTOM) or
                                        (h_cntr_reg_dly > TRELAMPAGO2_LEFT and h_cntr_reg_dly < TRELAMPAGO2_RIGHT and v_cntr_reg_dly > TRELAMPAGO2_TOP and v_cntr_reg_dly < TRELAMPAGO2_BOTTOM) or
                                        (h_cntr_reg_dly > TRELAMPAGO3_LEFT and h_cntr_reg_dly < TRELAMPAGO3_RIGHT and v_cntr_reg_dly > TRELAMPAGO3_TOP and v_cntr_reg_dly < TRELAMPAGO3_BOTTOM) or
                                        (h_cntr_reg_dly > TRELAMPAGO4_LEFT and h_cntr_reg_dly < TRELAMPAGO4_RIGHT and v_cntr_reg_dly > TRELAMPAGO4_TOP and v_cntr_reg_dly < TRELAMPAGO4_BOTTOM)
                                        ))) or
                                    
                                        -- Bloques de Tiempo: BALA
                                        ((MENU_STATE_LED(3 downto 1) /= "000") and (MODE_CONFIG = "11" and (
                                        (h_cntr_reg_dly > TBALA1_LEFT and h_cntr_reg_dly < TBALA1_RIGHT and v_cntr_reg_dly > TBALA1_TOP and v_cntr_reg_dly < TBALA1_BOTTOM) or
                                        (h_cntr_reg_dly > TBALA2_LEFT and h_cntr_reg_dly < TBALA2_RIGHT and v_cntr_reg_dly > TBALA2_TOP and v_cntr_reg_dly < TBALA2_BOTTOM)
                                        ))) or   
                                                          
                                        -- Bloques de Incremento: CLÁSICO
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (
                                        ((MODE_CONFIG = "00" or ((MODE_CONFIG = "10" or MODE_CONFIG = "01") and TIME_CONFIG = "000")) and (
                                        (h_cntr_reg_dly > ICLASICO1_LEFT and h_cntr_reg_dly < ICLASICO1_RIGHT and v_cntr_reg_dly > ICLASICO1_TOP and v_cntr_reg_dly < ICLASICO1_BOTTOM)
                                        )))) or
                                    
                                        -- Bloques de Incremento: RÁPIDO
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (MODE_CONFIG = "01" and (
                                        TIME_CONFIG /= "000" and (
                                        (h_cntr_reg_dly > IRAPIDO4_LEFT and h_cntr_reg_dly < IRAPIDO4_RIGHT and v_cntr_reg_dly > IRAPIDO4_TOP and v_cntr_reg_dly < IRAPIDO4_BOTTOM) or
                                        (TIME_CONFIG /= "001" and (
                                        (h_cntr_reg_dly > IRAPIDO3_LEFT and h_cntr_reg_dly < IRAPIDO3_RIGHT and v_cntr_reg_dly > IRAPIDO3_TOP and v_cntr_reg_dly < IRAPIDO3_BOTTOM) or
                                        (h_cntr_reg_dly > IRAPIDO2_LEFT and h_cntr_reg_dly < IRAPIDO2_RIGHT and v_cntr_reg_dly > IRAPIDO2_TOP and v_cntr_reg_dly < IRAPIDO2_BOTTOM) or
                                        (TIME_CONFIG /= "010" and (
                                        (h_cntr_reg_dly > IRAPIDO1_LEFT and h_cntr_reg_dly < IRAPIDO1_RIGHT and v_cntr_reg_dly > IRAPIDO1_TOP and v_cntr_reg_dly < IRAPIDO1_BOTTOM)
                                        )))
                                        )
                                        )))) or
                                    
                                        -- Bloques de Incremento: RELÁMPAGO
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (MODE_CONFIG = "10" and (
                                        TIME_CONFIG /= "000" and (
                                        (h_cntr_reg_dly > IRELAMPAGO4_LEFT and h_cntr_reg_dly < IRELAMPAGO4_RIGHT and v_cntr_reg_dly > IRELAMPAGO4_TOP and v_cntr_reg_dly < IRELAMPAGO4_BOTTOM) or
                                        (TIME_CONFIG /= "010" and (
                                        (h_cntr_reg_dly > IRELAMPAGO1_LEFT and h_cntr_reg_dly < IRELAMPAGO1_RIGHT and v_cntr_reg_dly > IRELAMPAGO1_TOP and v_cntr_reg_dly < IRELAMPAGO1_BOTTOM) or
                                        (h_cntr_reg_dly > IRELAMPAGO2_LEFT and h_cntr_reg_dly < IRELAMPAGO2_RIGHT and v_cntr_reg_dly > IRELAMPAGO2_TOP and v_cntr_reg_dly < IRELAMPAGO2_BOTTOM) or
                                        (h_cntr_reg_dly > IRELAMPAGO3_LEFT and h_cntr_reg_dly < IRELAMPAGO3_RIGHT and v_cntr_reg_dly > IRELAMPAGO3_TOP and v_cntr_reg_dly < IRELAMPAGO3_BOTTOM)
                                        ))
                                        ) 
                                        ))) or
                                    
                                        -- Bloques de Incremento: BALA
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (MODE_CONFIG = "11" and (
                                        (h_cntr_reg_dly > IBALA1_LEFT and h_cntr_reg_dly < IBALA1_RIGHT and v_cntr_reg_dly > IBALA1_TOP and v_cntr_reg_dly < IBALA1_BOTTOM)
                                        )))
                                        
                                        )
               else
               
               -- Pintar textos de los jugadores en la pantalla de juego
               overlay_output_piezas when (                    
                                        -- Bloque "PIEZAS BLANCAS" y bloque "PIEZAS NEGRAS"
                                        ((MENU_STATE_LED(4) = '1') and (
                                        (h_cntr_reg_dly > BLANCAS_LEFT and h_cntr_reg_dly < BLANCAS_RIGHT and v_cntr_reg_dly > BLANCAS_TOP and v_cntr_reg_dly < BLANCAS_BOTTOM) or
                                        (h_cntr_reg_dly > NEGRAS_LEFT  and h_cntr_reg_dly < NEGRAS_RIGHT  and v_cntr_reg_dly > NEGRAS_TOP  and v_cntr_reg_dly < NEGRAS_BOTTOM)
                                        ))                              
                                        )
               else
               
               -- Pintar bloques de la ventana emergente
               overlay_output_ventana when (                    
                                        -- Bloque "SI", bloque "NO" y bloque de texto de la ventana emergente
                                        ((MENU_STATE_LED(5) = '1') and (
                                        (h_cntr_reg_dly > SI_LEFT      and h_cntr_reg_dly < SI_RIGHT      and v_cntr_reg_dly > SI_TOP      and v_cntr_reg_dly < SI_BOTTOM) or
                                        (h_cntr_reg_dly > NO_LEFT      and h_cntr_reg_dly < NO_RIGHT      and v_cntr_reg_dly > NO_TOP      and v_cntr_reg_dly < NO_BOTTOM) or
                                        (h_cntr_reg_dly > VENTANA_LEFT and h_cntr_reg_dly < VENTANA_RIGHT and v_cntr_reg_dly > VENTANA_TOP and v_cntr_reg_dly < VENTANA_BOTTOM)
                                        ))                              
                                        )
               else
               
               -- Pintar números de la cuenta del jugador 1 (blancas)
               overlay_output_cuenta1(7 downto 4) when (                    
                                        ((MENU_STATE_LED(4) = '1') and (
                                        ((h_cntr_reg_dly > UHORAS1_LEFT          and h_cntr_reg_dly < UHORAS1_RIGHT          and v_cntr_reg_dly > UHORAS1_TOP          and v_cntr_reg_dly < UHORAS1_BOTTOM) and
                                        (CUENTA_BLANCAS(27 downto 24) /= "0000")) or
                                        ((h_cntr_reg_dly > PUNTOS_HORASMIN1_LEFT and h_cntr_reg_dly < PUNTOS_HORASMIN1_RIGHT and v_cntr_reg_dly > PUNTOS_HORASMIN1_TOP and v_cntr_reg_dly < PUNTOS_HORASMIN1_BOTTOM) and
                                        (CUENTA_BLANCAS(27 downto 24) /= "0000")) or
                                        ((h_cntr_reg_dly > DMINUTOS1_LEFT        and h_cntr_reg_dly < DMINUTOS1_RIGHT        and v_cntr_reg_dly > DMINUTOS1_TOP        and v_cntr_reg_dly < DMINUTOS1_BOTTOM) and
                                        (CUENTA_BLANCAS(27 downto 16) /= "000000000000")) or
                                        ((h_cntr_reg_dly > UMINUTOS1_LEFT        and h_cntr_reg_dly < UMINUTOS1_RIGHT        and v_cntr_reg_dly > UMINUTOS1_TOP        and v_cntr_reg_dly < UMINUTOS1_BOTTOM) and
                                        (CUENTA_BLANCAS(27 downto 16) /= "000000000000")) or
                                        ((h_cntr_reg_dly > PUNTOS_MINSEG1_LEFT   and h_cntr_reg_dly < PUNTOS_MINSEG1_RIGHT   and v_cntr_reg_dly > PUNTOS_MINSEG1_TOP   and v_cntr_reg_dly < PUNTOS_MINSEG1_BOTTOM) and
                                        (CUENTA_BLANCAS(27 downto 16) /= "000000000000")) or
                                        (h_cntr_reg_dly > DSEG1_LEFT            and h_cntr_reg_dly < DSEG1_RIGHT            and v_cntr_reg_dly > DSEG1_TOP            and v_cntr_reg_dly < DSEG1_BOTTOM) or
                                        (h_cntr_reg_dly > USEG1_LEFT            and h_cntr_reg_dly < USEG1_RIGHT            and v_cntr_reg_dly > USEG1_TOP            and v_cntr_reg_dly < USEG1_BOTTOM) or
                                        (h_cntr_reg_dly > PUNTO1_LEFT           and h_cntr_reg_dly < PUNTO1_RIGHT           and v_cntr_reg_dly > PUNTO1_TOP           and v_cntr_reg_dly < PUNTO1_BOTTOM) or
                                        (h_cntr_reg_dly > DECIMAS1_LEFT         and h_cntr_reg_dly < DECIMAS1_RIGHT         and v_cntr_reg_dly > DECIMAS1_TOP         and v_cntr_reg_dly < DECIMAS1_BOTTOM) or
                                        (h_cntr_reg_dly > CENTESIMAS1_LEFT      and h_cntr_reg_dly < CENTESIMAS1_RIGHT      and v_cntr_reg_dly > CENTESIMAS1_TOP      and v_cntr_reg_dly < CENTESIMAS1_BOTTOM)
                                        ))
                                        )
               else
               
               -- Pintar números de la cuenta del jugador 2 (negras)
               overlay_output_cuenta2(7 downto 4) when (                    
                                        ((MENU_STATE_LED(4) = '1') and (
                                        ((h_cntr_reg_dly > UHORAS2_LEFT          and h_cntr_reg_dly < UHORAS2_RIGHT          and v_cntr_reg_dly > UHORAS2_TOP          and v_cntr_reg_dly < UHORAS2_BOTTOM) and
                                        (CUENTA_NEGRAS(27 downto 24) /= "0000")) or
                                        ((h_cntr_reg_dly > PUNTOS_HORASMIN2_LEFT and h_cntr_reg_dly < PUNTOS_HORASMIN2_RIGHT and v_cntr_reg_dly > PUNTOS_HORASMIN2_TOP and v_cntr_reg_dly < PUNTOS_HORASMIN2_BOTTOM) and
                                        (CUENTA_NEGRAS(27 downto 24) /= "0000")) or
                                        ((h_cntr_reg_dly > DMINUTOS2_LEFT        and h_cntr_reg_dly < DMINUTOS2_RIGHT        and v_cntr_reg_dly > DMINUTOS2_TOP        and v_cntr_reg_dly < DMINUTOS2_BOTTOM) and
                                        (CUENTA_NEGRAS(27 downto 16) /= "000000000000")) or
                                        ((h_cntr_reg_dly > UMINUTOS2_LEFT        and h_cntr_reg_dly < UMINUTOS2_RIGHT        and v_cntr_reg_dly > UMINUTOS2_TOP        and v_cntr_reg_dly < UMINUTOS2_BOTTOM) and
                                        (CUENTA_NEGRAS(27 downto 16) /= "000000000000")) or
                                        ((h_cntr_reg_dly > PUNTOS_MINSEG2_LEFT   and h_cntr_reg_dly < PUNTOS_MINSEG2_RIGHT   and v_cntr_reg_dly > PUNTOS_MINSEG2_TOP   and v_cntr_reg_dly < PUNTOS_MINSEG2_BOTTOM) and
                                        (CUENTA_NEGRAS(27 downto 16) /= "000000000000")) or
                                        (h_cntr_reg_dly > DSEG2_LEFT            and h_cntr_reg_dly < DSEG2_RIGHT            and v_cntr_reg_dly > DSEG2_TOP            and v_cntr_reg_dly < DSEG2_BOTTOM) or
                                        (h_cntr_reg_dly > USEG2_LEFT            and h_cntr_reg_dly < USEG2_RIGHT            and v_cntr_reg_dly > USEG2_TOP            and v_cntr_reg_dly < USEG2_BOTTOM) or
                                        (h_cntr_reg_dly > PUNTO2_LEFT           and h_cntr_reg_dly < PUNTO2_RIGHT           and v_cntr_reg_dly > PUNTO2_TOP           and v_cntr_reg_dly < PUNTO2_BOTTOM) or
                                        (h_cntr_reg_dly > DECIMAS2_LEFT         and h_cntr_reg_dly < DECIMAS2_RIGHT         and v_cntr_reg_dly > DECIMAS2_TOP         and v_cntr_reg_dly < DECIMAS2_BOTTOM) or
                                        (h_cntr_reg_dly > CENTESIMAS2_LEFT      and h_cntr_reg_dly < CENTESIMAS2_RIGHT      and v_cntr_reg_dly > CENTESIMAS2_TOP      and v_cntr_reg_dly < CENTESIMAS2_BOTTOM)
                                        ))
                                        )
               else
               
               -- Painting a green border around the selectable BRAM blocks once selected
               x"F" when                (                                        
                                        (-- Bloques Principales (Menú Raíz)
                                        ((MENU_STATE_LED(3 downto 1) /= "000") and (
                                        ((h_cntr_reg_dly > CLASICO_LEFT - 3   and h_cntr_reg_dly < CLASICO_RIGHT + 3   and v_cntr_reg_dly > CLASICO_TOP - 3   and v_cntr_reg_dly < CLASICO_BOTTOM + 3) and
                                        (selected_clasico = '1')) or
                                        ((h_cntr_reg_dly > RAPIDO_LEFT - 3    and h_cntr_reg_dly < RAPIDO_RIGHT + 3    and v_cntr_reg_dly > RAPIDO_TOP - 3    and v_cntr_reg_dly < RAPIDO_BOTTOM + 3) and
                                        (selected_rapido = '1')) or
                                        ((h_cntr_reg_dly > RELAMPAGO_LEFT - 3 and h_cntr_reg_dly < RELAMPAGO_RIGHT + 3 and v_cntr_reg_dly > RELAMPAGO_TOP - 3 and v_cntr_reg_dly < RELAMPAGO_BOTTOM + 3) and
                                        (selected_relampago = '1')) or
                                        ((h_cntr_reg_dly > BALA_LEFT - 3      and h_cntr_reg_dly < BALA_RIGHT + 3      and v_cntr_reg_dly > BALA_TOP - 3      and v_cntr_reg_dly < BALA_BOTTOM + 3) and
                                        (selected_bala = '1'))
                                        )) or
                                    
                                        -- Bloques de Tiempo: CLÁSICO
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (
                                        ((h_cntr_reg_dly > TCLASICO1_LEFT - 3 and h_cntr_reg_dly < TCLASICO1_RIGHT + 3 and v_cntr_reg_dly > TCLASICO1_TOP - 3 and v_cntr_reg_dly < TCLASICO1_BOTTOM + 3) and
                                        (selected_2h_30m = '1')) or
                                        ((h_cntr_reg_dly > TCLASICO2_LEFT - 3 and h_cntr_reg_dly < TCLASICO2_RIGHT + 3 and v_cntr_reg_dly > TCLASICO2_TOP - 3 and v_cntr_reg_dly < TCLASICO2_BOTTOM + 3) and
                                        (selected_2h_1h_15m = '1')) or
                                        ((h_cntr_reg_dly > TCLASICO3_LEFT - 3 and h_cntr_reg_dly < TCLASICO3_RIGHT + 3 and v_cntr_reg_dly > TCLASICO3_TOP - 3 and v_cntr_reg_dly < TCLASICO3_BOTTOM + 3) and
                                        (selected_2h_1h = '1')) or
                                        ((h_cntr_reg_dly > TCLASICO4_LEFT - 3 and h_cntr_reg_dly < TCLASICO4_RIGHT + 3 and v_cntr_reg_dly > TCLASICO4_TOP - 3 and v_cntr_reg_dly < TCLASICO4_BOTTOM + 3) and
                                        (selected_1h_30m = '1'))
                                        )) or
                                    
                                        -- Bloques de Tiempo: RÁPIDO
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (
                                        ((h_cntr_reg_dly > TRAPIDO1_LEFT - 3 and h_cntr_reg_dly < TRAPIDO1_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO1_TOP - 3 and v_cntr_reg_dly < TRAPIDO1_BOTTOM + 3) and
                                        (selected_60m = '1')) or
                                        ((h_cntr_reg_dly > TRAPIDO2_LEFT - 3 and h_cntr_reg_dly < TRAPIDO2_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO2_TOP - 3 and v_cntr_reg_dly < TRAPIDO2_BOTTOM + 3) and
                                        (selected_50m = '1')) or
                                        ((h_cntr_reg_dly > TRAPIDO3_LEFT - 3 and h_cntr_reg_dly < TRAPIDO3_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO3_TOP - 3 and v_cntr_reg_dly < TRAPIDO3_BOTTOM + 3) and
                                        (selected_40m = '1')) or
                                        ((h_cntr_reg_dly > TRAPIDO4_LEFT - 3 and h_cntr_reg_dly < TRAPIDO4_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO4_TOP - 3 and v_cntr_reg_dly < TRAPIDO4_BOTTOM + 3) and
                                        (selected_30m = '1')) or
                                        ((h_cntr_reg_dly > TRAPIDO5_LEFT - 3 and h_cntr_reg_dly < TRAPIDO5_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO5_TOP - 3 and v_cntr_reg_dly < TRAPIDO5_BOTTOM + 3) and
                                        (selected_20m = '1')) or
                                        ((h_cntr_reg_dly > TRAPIDO6_LEFT - 3 and h_cntr_reg_dly < TRAPIDO6_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO6_TOP - 3 and v_cntr_reg_dly < TRAPIDO6_BOTTOM + 3) and
                                        (selected_10m = '1'))
                                        )) or
                                    
                                        -- Bloques de Tiempo: RELÁMPAGO
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (
                                        ((h_cntr_reg_dly > TRELAMPAGO1_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO1_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO1_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO1_BOTTOM + 3) and
                                        (selected_10m_bz = '1')) or
                                        ((h_cntr_reg_dly > TRELAMPAGO2_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO2_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO2_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO2_BOTTOM + 3) and
                                        (selected_8m = '1')) or
                                        ((h_cntr_reg_dly > TRELAMPAGO3_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO3_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO3_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO3_BOTTOM + 3) and
                                        (selected_5m = '1')) or
                                        ((h_cntr_reg_dly > TRELAMPAGO4_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO4_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO4_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO4_BOTTOM + 3) and
                                        (selected_3m = '1'))
                                        )) or
                                    
                                        -- Bloques de Tiempo: BALA
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (
                                        ((h_cntr_reg_dly > TBALA1_LEFT - 3 and h_cntr_reg_dly < TBALA1_RIGHT + 3 and v_cntr_reg_dly > TBALA1_TOP - 3 and v_cntr_reg_dly < TBALA1_BOTTOM + 3) and
                                        (selected_2m = '1')) or
                                        ((h_cntr_reg_dly > TBALA2_LEFT - 3 and h_cntr_reg_dly < TBALA2_RIGHT + 3 and v_cntr_reg_dly > TBALA2_TOP - 3 and v_cntr_reg_dly < TBALA2_BOTTOM + 3) and
                                        (selected_1m = '1'))
                                        )) or
                                    
                                        -- Bloques de Incremento: CLÁSICO
                                        ((MENU_STATE_LED(3) = '1') and (
                                        ((h_cntr_reg_dly > ICLASICO1_LEFT - 3 and h_cntr_reg_dly < ICLASICO1_RIGHT + 3 and v_cntr_reg_dly > ICLASICO1_TOP - 3 and v_cntr_reg_dly < ICLASICO1_BOTTOM + 3) and
                                        (selected_estandar = '1'))
                                        )) or
                                    
                                        -- Bloques de Incremento: RÁPIDO
                                        ((MENU_STATE_LED(3) = '1') and (
                                        ((h_cntr_reg_dly > IRAPIDO1_LEFT - 3 and h_cntr_reg_dly < IRAPIDO1_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO1_TOP - 3 and v_cntr_reg_dly < IRAPIDO1_BOTTOM + 3) and
                                        (selected_30s = '1')) or
                                        ((h_cntr_reg_dly > IRAPIDO2_LEFT - 3 and h_cntr_reg_dly < IRAPIDO2_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO2_TOP - 3 and v_cntr_reg_dly < IRAPIDO2_BOTTOM + 3) and
                                        (selected_20s = '1')) or
                                        ((h_cntr_reg_dly > IRAPIDO3_LEFT - 3 and h_cntr_reg_dly < IRAPIDO3_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO3_TOP - 3 and v_cntr_reg_dly < IRAPIDO3_BOTTOM + 3) and
                                        (selected_15s = '1')) or
                                        ((h_cntr_reg_dly > IRAPIDO4_LEFT - 3 and h_cntr_reg_dly < IRAPIDO4_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO4_TOP - 3 and v_cntr_reg_dly < IRAPIDO4_BOTTOM + 3) and
                                        (selected_10s = '1'))
                                        )) or
                                        
                                        -- Bloques de Incremento: RELÁMPAGO
                                        ((MENU_STATE_LED(3) = '1') and (
                                        ((h_cntr_reg_dly > IRELAMPAGO1_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO1_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO1_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO1_BOTTOM + 3) and
                                        (selected_5s = '1')) or
                                        ((h_cntr_reg_dly > IRELAMPAGO2_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO2_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO2_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO2_BOTTOM + 3) and
                                        (selected_4s = '1')) or
                                        ((h_cntr_reg_dly > IRELAMPAGO3_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO3_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO3_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO3_BOTTOM + 3) and
                                        (selected_3s = '1')) or
                                        ((h_cntr_reg_dly > IRELAMPAGO4_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO4_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO4_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO4_BOTTOM + 3) and
                                        (selected_2s = '1'))
                                        )) or
                                    
                                        -- Bloques de Incremento: BALA
                                        ((MENU_STATE_LED(3) = '1') and (
                                        ((h_cntr_reg_dly > IBALA1_LEFT - 3 and h_cntr_reg_dly < IBALA1_RIGHT + 3 and v_cntr_reg_dly > IBALA1_TOP - 3 and v_cntr_reg_dly < IBALA1_BOTTOM + 3) and
                                        (selected_estandar = '1'))
                                        )))
                                        )
               else
               
               -- Painting a yellow border around the selectable BRAM blocks being hovered
               x"F" when                (-- Bloques Principales (Menú Raíz)
                                        ((MENU_STATE_LED(0) = '1') and (
                                        ((h_cntr_reg_dly > CLASICO_LEFT - 3   and h_cntr_reg_dly < CLASICO_RIGHT + 3   and v_cntr_reg_dly > CLASICO_TOP - 3   and v_cntr_reg_dly < CLASICO_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > CLASICO_LEFT     and MOUSE_X_PIXEL < CLASICO_RIGHT    and MOUSE_Y_PIXEL > CLASICO_TOP    and MOUSE_Y_PIXEL < CLASICO_BOTTOM)) or
                                        ((h_cntr_reg_dly > RAPIDO_LEFT - 3    and h_cntr_reg_dly < RAPIDO_RIGHT + 3    and v_cntr_reg_dly > RAPIDO_TOP - 3    and v_cntr_reg_dly < RAPIDO_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > RAPIDO_LEFT      and MOUSE_X_PIXEL < RAPIDO_RIGHT     and MOUSE_Y_PIXEL > RAPIDO_TOP     and MOUSE_Y_PIXEL < RAPIDO_BOTTOM)) or
                                        ((h_cntr_reg_dly > RELAMPAGO_LEFT - 3 and h_cntr_reg_dly < RELAMPAGO_RIGHT + 3 and v_cntr_reg_dly > RELAMPAGO_TOP - 3 and v_cntr_reg_dly < RELAMPAGO_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > RELAMPAGO_LEFT   and MOUSE_X_PIXEL < RELAMPAGO_RIGHT  and MOUSE_Y_PIXEL > RELAMPAGO_TOP  and MOUSE_Y_PIXEL < RELAMPAGO_BOTTOM)) or
                                        ((h_cntr_reg_dly > BALA_LEFT - 3      and h_cntr_reg_dly < BALA_RIGHT + 3      and v_cntr_reg_dly > BALA_TOP - 3      and v_cntr_reg_dly < BALA_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > BALA_LEFT        and MOUSE_X_PIXEL < BALA_RIGHT       and MOUSE_Y_PIXEL > BALA_TOP       and MOUSE_Y_PIXEL < BALA_BOTTOM))
                                        )) or
                                        
                                        -- Bloque "ATRAS"
                                        ((MENU_STATE_LED(3) = '1' or MENU_STATE_LED(2) = '1' or MENU_STATE_LED(1) = '1') and (
                                        ((h_cntr_reg_dly > ATRAS_LEFT - 3 and h_cntr_reg_dly < ATRAS_RIGHT + 3 and v_cntr_reg_dly > ATRAS_TOP - 3 and v_cntr_reg_dly < ATRAS_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > ATRAS_LEFT   and MOUSE_X_PIXEL < ATRAS_RIGHT  and MOUSE_Y_PIXEL > ATRAS_TOP  and MOUSE_Y_PIXEL < ATRAS_BOTTOM))
                                        )) or
                                    
                                        -- Bloque "JUGAR"
                                        ((MENU_STATE_LED(3) = '1') and (
                                        ((h_cntr_reg_dly > JUGAR_LEFT - 3 and h_cntr_reg_dly < JUGAR_RIGHT + 3 and v_cntr_reg_dly > JUGAR_TOP - 3 and v_cntr_reg_dly < JUGAR_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > JUGAR_LEFT   and MOUSE_X_PIXEL < JUGAR_RIGHT  and MOUSE_Y_PIXEL > JUGAR_TOP  and MOUSE_Y_PIXEL < JUGAR_BOTTOM))
                                        )) or
                                    
                                        -- Bloques de Tiempo: CLÁSICO
                                        ((MENU_STATE_LED(1) = '1') and (MODE_CONFIG = "00" and (
                                        ((h_cntr_reg_dly > TCLASICO1_LEFT - 3 and h_cntr_reg_dly < TCLASICO1_RIGHT + 3 and v_cntr_reg_dly > TCLASICO1_TOP - 3 and v_cntr_reg_dly < TCLASICO1_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TCLASICO1_LEFT   and MOUSE_X_PIXEL < TCLASICO1_RIGHT  and MOUSE_Y_PIXEL > TCLASICO1_TOP  and MOUSE_Y_PIXEL < TCLASICO1_BOTTOM)) or
                                        ((h_cntr_reg_dly > TCLASICO2_LEFT - 3 and h_cntr_reg_dly < TCLASICO2_RIGHT + 3 and v_cntr_reg_dly > TCLASICO2_TOP - 3 and v_cntr_reg_dly < TCLASICO2_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TCLASICO2_LEFT   and MOUSE_X_PIXEL < TCLASICO2_RIGHT  and MOUSE_Y_PIXEL > TCLASICO2_TOP  and MOUSE_Y_PIXEL < TCLASICO2_BOTTOM)) or
                                        ((h_cntr_reg_dly > TCLASICO3_LEFT - 3 and h_cntr_reg_dly < TCLASICO3_RIGHT + 3 and v_cntr_reg_dly > TCLASICO3_TOP - 3 and v_cntr_reg_dly < TCLASICO3_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TCLASICO3_LEFT   and MOUSE_X_PIXEL < TCLASICO3_RIGHT  and MOUSE_Y_PIXEL > TCLASICO3_TOP  and MOUSE_Y_PIXEL < TCLASICO3_BOTTOM)) or
                                        ((h_cntr_reg_dly > TCLASICO4_LEFT - 3 and h_cntr_reg_dly < TCLASICO4_RIGHT + 3 and v_cntr_reg_dly > TCLASICO4_TOP - 3 and v_cntr_reg_dly < TCLASICO4_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TCLASICO4_LEFT   and MOUSE_X_PIXEL < TCLASICO4_RIGHT  and MOUSE_Y_PIXEL > TCLASICO4_TOP  and MOUSE_Y_PIXEL < TCLASICO4_BOTTOM))
                                        ))) or
                                    
                                        -- Bloques de Tiempo: RÁPIDO
                                        ((MENU_STATE_LED(1) = '1') and (MODE_CONFIG = "01" and (
                                        ((h_cntr_reg_dly > TRAPIDO1_LEFT - 3 and h_cntr_reg_dly < TRAPIDO1_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO1_TOP - 3 and v_cntr_reg_dly < TRAPIDO1_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRAPIDO1_LEFT   and MOUSE_X_PIXEL < TRAPIDO1_RIGHT  and MOUSE_Y_PIXEL > TRAPIDO1_TOP  and MOUSE_Y_PIXEL < TRAPIDO1_BOTTOM)) or
                                        ((h_cntr_reg_dly > TRAPIDO2_LEFT - 3 and h_cntr_reg_dly < TRAPIDO2_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO2_TOP - 3 and v_cntr_reg_dly < TRAPIDO2_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRAPIDO2_LEFT   and MOUSE_X_PIXEL < TRAPIDO2_RIGHT  and MOUSE_Y_PIXEL > TRAPIDO2_TOP  and MOUSE_Y_PIXEL < TRAPIDO2_BOTTOM)) or
                                        ((h_cntr_reg_dly > TRAPIDO3_LEFT - 3 and h_cntr_reg_dly < TRAPIDO3_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO3_TOP - 3 and v_cntr_reg_dly < TRAPIDO3_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRAPIDO3_LEFT   and MOUSE_X_PIXEL < TRAPIDO3_RIGHT  and MOUSE_Y_PIXEL > TRAPIDO3_TOP  and MOUSE_Y_PIXEL < TRAPIDO3_BOTTOM)) or
                                        ((h_cntr_reg_dly > TRAPIDO4_LEFT - 3 and h_cntr_reg_dly < TRAPIDO4_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO4_TOP - 3 and v_cntr_reg_dly < TRAPIDO4_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRAPIDO4_LEFT   and MOUSE_X_PIXEL < TRAPIDO4_RIGHT  and MOUSE_Y_PIXEL > TRAPIDO4_TOP  and MOUSE_Y_PIXEL < TRAPIDO4_BOTTOM)) or
                                        ((h_cntr_reg_dly > TRAPIDO5_LEFT - 3 and h_cntr_reg_dly < TRAPIDO5_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO5_TOP - 3 and v_cntr_reg_dly < TRAPIDO5_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRAPIDO5_LEFT   and MOUSE_X_PIXEL < TRAPIDO5_RIGHT  and MOUSE_Y_PIXEL > TRAPIDO5_TOP  and MOUSE_Y_PIXEL < TRAPIDO5_BOTTOM)) or
                                        ((h_cntr_reg_dly > TRAPIDO6_LEFT - 3 and h_cntr_reg_dly < TRAPIDO6_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO6_TOP - 3 and v_cntr_reg_dly < TRAPIDO6_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRAPIDO6_LEFT   and MOUSE_X_PIXEL < TRAPIDO6_RIGHT  and MOUSE_Y_PIXEL > TRAPIDO6_TOP  and MOUSE_Y_PIXEL < TRAPIDO6_BOTTOM))
                                        ))) or
                                    
                                        -- Bloques de Tiempo: RELÁMPAGO
                                        ((MENU_STATE_LED(1) = '1') and (MODE_CONFIG = "10" and (
                                        ((h_cntr_reg_dly > TRELAMPAGO1_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO1_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO1_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO1_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRELAMPAGO1_LEFT   and MOUSE_X_PIXEL < TRELAMPAGO1_RIGHT  and MOUSE_Y_PIXEL > TRELAMPAGO1_TOP  and MOUSE_Y_PIXEL < TRELAMPAGO1_BOTTOM)) or
                                        ((h_cntr_reg_dly > TRELAMPAGO2_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO2_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO2_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO2_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRELAMPAGO2_LEFT   and MOUSE_X_PIXEL < TRELAMPAGO2_RIGHT  and MOUSE_Y_PIXEL > TRELAMPAGO2_TOP  and MOUSE_Y_PIXEL < TRELAMPAGO2_BOTTOM)) or
                                        ((h_cntr_reg_dly > TRELAMPAGO3_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO3_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO3_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO3_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRELAMPAGO3_LEFT   and MOUSE_X_PIXEL < TRELAMPAGO3_RIGHT  and MOUSE_Y_PIXEL > TRELAMPAGO3_TOP  and MOUSE_Y_PIXEL < TRELAMPAGO3_BOTTOM)) or
                                        ((h_cntr_reg_dly > TRELAMPAGO4_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO4_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO4_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO4_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRELAMPAGO4_LEFT   and MOUSE_X_PIXEL < TRELAMPAGO4_RIGHT  and MOUSE_Y_PIXEL > TRELAMPAGO4_TOP  and MOUSE_Y_PIXEL < TRELAMPAGO4_BOTTOM))
                                        ))) or
                                    
                                        -- Bloques de Tiempo: BALA
                                        ((MENU_STATE_LED(1) = '1') and (MODE_CONFIG = "11" and (
                                        ((h_cntr_reg_dly > TBALA1_LEFT - 3 and h_cntr_reg_dly < TBALA1_RIGHT + 3 and v_cntr_reg_dly > TBALA1_TOP - 3 and v_cntr_reg_dly < TBALA1_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TBALA1_LEFT   and MOUSE_X_PIXEL < TBALA1_RIGHT  and MOUSE_Y_PIXEL > TBALA1_TOP  and MOUSE_Y_PIXEL < TBALA1_BOTTOM)) or
                                        ((h_cntr_reg_dly > TBALA2_LEFT - 3 and h_cntr_reg_dly < TBALA2_RIGHT + 3 and v_cntr_reg_dly > TBALA2_TOP - 3 and v_cntr_reg_dly < TBALA2_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TBALA2_LEFT   and MOUSE_X_PIXEL < TBALA2_RIGHT  and MOUSE_Y_PIXEL > TBALA2_TOP  and MOUSE_Y_PIXEL < TBALA2_BOTTOM))
                                        ))) or
                                    
                                        -- Bloques de Incremento: CLÁSICO
                                        ((MENU_STATE_LED(2) = '1') and (
                                        ((MODE_CONFIG = "00" or ((MODE_CONFIG = "10" or MODE_CONFIG = "01") and TIME_CONFIG = "000")) and (
                                        ((h_cntr_reg_dly > ICLASICO1_LEFT - 3 and h_cntr_reg_dly < ICLASICO1_RIGHT + 3 and v_cntr_reg_dly > ICLASICO1_TOP - 3 and v_cntr_reg_dly < ICLASICO1_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > ICLASICO1_LEFT   and MOUSE_X_PIXEL < ICLASICO1_RIGHT  and MOUSE_Y_PIXEL > ICLASICO1_TOP  and MOUSE_Y_PIXEL < ICLASICO1_BOTTOM))
                                        )
                                        ))) or
                                    
                                        -- Bloques de Incremento: RÁPIDO
                                        ((MENU_STATE_LED(2) = '1') and (MODE_CONFIG = "01" and (
                                        TIME_CONFIG /= "000" and (
                                        ((h_cntr_reg_dly > IRAPIDO4_LEFT - 3 and h_cntr_reg_dly < IRAPIDO4_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO4_TOP - 3 and v_cntr_reg_dly < IRAPIDO4_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > IRAPIDO4_LEFT   and MOUSE_X_PIXEL < IRAPIDO4_RIGHT  and MOUSE_Y_PIXEL > IRAPIDO4_TOP  and MOUSE_Y_PIXEL < IRAPIDO4_BOTTOM)) or
                                        (TIME_CONFIG /= "001" and (
                                        ((h_cntr_reg_dly > IRAPIDO3_LEFT - 3 and h_cntr_reg_dly < IRAPIDO3_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO3_TOP - 3 and v_cntr_reg_dly < IRAPIDO3_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > IRAPIDO3_LEFT   and MOUSE_X_PIXEL < IRAPIDO3_RIGHT  and MOUSE_Y_PIXEL > IRAPIDO3_TOP  and MOUSE_Y_PIXEL < IRAPIDO3_BOTTOM)) or
                                        ((h_cntr_reg_dly > IRAPIDO2_LEFT - 3 and h_cntr_reg_dly < IRAPIDO2_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO2_TOP - 3 and v_cntr_reg_dly < IRAPIDO2_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > IRAPIDO2_LEFT   and MOUSE_X_PIXEL < IRAPIDO2_RIGHT  and MOUSE_Y_PIXEL > IRAPIDO2_TOP  and MOUSE_Y_PIXEL < IRAPIDO2_BOTTOM)) or
                                        (TIME_CONFIG /= "010" and (
                                        ((h_cntr_reg_dly > IRAPIDO1_LEFT - 3 and h_cntr_reg_dly < IRAPIDO1_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO1_TOP - 3 and v_cntr_reg_dly < IRAPIDO1_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > IRAPIDO1_LEFT   and MOUSE_X_PIXEL < IRAPIDO1_RIGHT  and MOUSE_Y_PIXEL > IRAPIDO1_TOP  and MOUSE_Y_PIXEL < IRAPIDO1_BOTTOM))
                                        )))
                                        )
                                        )))) or
                                    
                                        -- Bloques de Incremento: RELÁMPAGO
                                        ((MENU_STATE_LED(2) = '1') and (MODE_CONFIG = "10" and (
                                        TIME_CONFIG /= "000" and (
                                        ((h_cntr_reg_dly > IRELAMPAGO4_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO4_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO4_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO4_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > IRELAMPAGO4_LEFT   and MOUSE_X_PIXEL < IRELAMPAGO4_RIGHT  and MOUSE_Y_PIXEL > IRELAMPAGO4_TOP  and MOUSE_Y_PIXEL < IRELAMPAGO4_BOTTOM)) or
                                        (TIME_CONFIG /= "010" and (
                                        ((h_cntr_reg_dly > IRELAMPAGO1_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO1_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO1_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO1_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > IRELAMPAGO1_LEFT   and MOUSE_X_PIXEL < IRELAMPAGO1_RIGHT  and MOUSE_Y_PIXEL > IRELAMPAGO1_TOP  and MOUSE_Y_PIXEL < IRELAMPAGO1_BOTTOM)) or
                                        ((h_cntr_reg_dly > IRELAMPAGO2_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO2_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO2_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO2_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > IRELAMPAGO2_LEFT   and MOUSE_X_PIXEL < IRELAMPAGO2_RIGHT  and MOUSE_Y_PIXEL > IRELAMPAGO2_TOP  and MOUSE_Y_PIXEL < IRELAMPAGO2_BOTTOM)) or
                                        ((h_cntr_reg_dly > IRELAMPAGO3_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO3_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO3_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO3_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > IRELAMPAGO3_LEFT   and MOUSE_X_PIXEL < IRELAMPAGO3_RIGHT  and MOUSE_Y_PIXEL > IRELAMPAGO3_TOP  and MOUSE_Y_PIXEL < IRELAMPAGO3_BOTTOM)) 
                                        ))
                                        )
                                        ))) or
                                    
                                        -- Bloques de Incremento: BALA
                                        ((MENU_STATE_LED(2) = '1') and (MODE_CONFIG = "11" and (
                                        ((h_cntr_reg_dly > IBALA1_LEFT - 3 and h_cntr_reg_dly < IBALA1_RIGHT + 3 and v_cntr_reg_dly > IBALA1_TOP - 3 and v_cntr_reg_dly < IBALA1_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > IBALA1_LEFT   and MOUSE_X_PIXEL < IBALA1_RIGHT  and MOUSE_Y_PIXEL > IBALA1_TOP  and MOUSE_Y_PIXEL < IBALA1_BOTTOM))
                                        ))) or
                                        
                                        -- Bloque "SI" y bloque "NO"
                                        ((MENU_STATE_LED(5) = '1') and (
                                        ((h_cntr_reg_dly > SI_LEFT - 3 and h_cntr_reg_dly < SI_RIGHT + 3 and v_cntr_reg_dly > SI_TOP - 3 and v_cntr_reg_dly < SI_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > SI_LEFT   and MOUSE_X_PIXEL < SI_RIGHT  and MOUSE_Y_PIXEL > SI_TOP  and MOUSE_Y_PIXEL < SI_BOTTOM)) or
                                        ((h_cntr_reg_dly > NO_LEFT - 3 and h_cntr_reg_dly < NO_RIGHT + 3 and v_cntr_reg_dly > NO_TOP - 3 and v_cntr_reg_dly < NO_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > NO_LEFT   and MOUSE_X_PIXEL < NO_RIGHT  and MOUSE_Y_PIXEL > NO_TOP  and MOUSE_Y_PIXEL < NO_BOTTOM))
                                        ))
                                        )
               else
                                        
               -- Painting a red border around the BRAM blocks
               x"0" when                (-- Bloques Principales (Menú Raíz)
                                        ((MENU_STATE_LED(4) = '0' and MENU_STATE_LED(5) = '0') and (
                                        (h_cntr_reg_dly > CLASICO_LEFT - 3    and h_cntr_reg_dly < CLASICO_RIGHT + 3    and v_cntr_reg_dly > CLASICO_TOP - 3    and v_cntr_reg_dly < CLASICO_BOTTOM + 3) or
                                        (h_cntr_reg_dly > RAPIDO_LEFT - 3     and h_cntr_reg_dly < RAPIDO_RIGHT + 3     and v_cntr_reg_dly > RAPIDO_TOP - 3     and v_cntr_reg_dly < RAPIDO_BOTTOM + 3) or
                                        (h_cntr_reg_dly > RELAMPAGO_LEFT - 3  and h_cntr_reg_dly < RELAMPAGO_RIGHT + 3  and v_cntr_reg_dly > RELAMPAGO_TOP - 3  and v_cntr_reg_dly < RELAMPAGO_BOTTOM + 3) or
                                        (h_cntr_reg_dly > BALA_LEFT - 3       and h_cntr_reg_dly < BALA_RIGHT + 3       and v_cntr_reg_dly > BALA_TOP - 3       and v_cntr_reg_dly < BALA_BOTTOM + 3)
                                        )) or
                                        
                                        -- Bloque "ATRAS"
                                        ((MENU_STATE_LED(3) = '1' or MENU_STATE_LED(2) = '1' or MENU_STATE_LED(1) = '1') and (
                                        (h_cntr_reg_dly > ATRAS_LEFT - 3 and h_cntr_reg_dly < ATRAS_RIGHT + 3 and v_cntr_reg_dly > ATRAS_TOP - 3 and v_cntr_reg_dly < ATRAS_BOTTOM + 3)
                                        )) or
                                    
                                        -- Bloque "JUGAR"
                                        ((MENU_STATE_LED(3) = '1') and (
                                        (h_cntr_reg_dly > JUGAR_LEFT - 3 and h_cntr_reg_dly < JUGAR_RIGHT + 3 and v_cntr_reg_dly > JUGAR_TOP - 3 and v_cntr_reg_dly < JUGAR_BOTTOM + 3)
                                        )) or
                                    
                                        -- Bloques de Tiempo: CLÁSICO
                                        ((MENU_STATE_LED(3 downto 1) /= "000") and (MODE_CONFIG = "00" and (
                                        (h_cntr_reg_dly > TCLASICO1_LEFT - 3 and h_cntr_reg_dly < TCLASICO1_RIGHT + 3 and v_cntr_reg_dly > TCLASICO1_TOP - 3 and v_cntr_reg_dly < TCLASICO1_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TCLASICO2_LEFT - 3 and h_cntr_reg_dly < TCLASICO2_RIGHT + 3 and v_cntr_reg_dly > TCLASICO2_TOP - 3 and v_cntr_reg_dly < TCLASICO2_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TCLASICO3_LEFT - 3 and h_cntr_reg_dly < TCLASICO3_RIGHT + 3 and v_cntr_reg_dly > TCLASICO3_TOP - 3 and v_cntr_reg_dly < TCLASICO3_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TCLASICO4_LEFT - 3 and h_cntr_reg_dly < TCLASICO4_RIGHT + 3 and v_cntr_reg_dly > TCLASICO4_TOP - 3 and v_cntr_reg_dly < TCLASICO4_BOTTOM + 3)
                                        ))) or
                                    
                                        -- Bloques de Tiempo: RÁPIDO
                                        ((MENU_STATE_LED(3 downto 1) /= "000") and (MODE_CONFIG = "01" and (
                                        (h_cntr_reg_dly > TRAPIDO1_LEFT - 3 and h_cntr_reg_dly < TRAPIDO1_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO1_TOP - 3 and v_cntr_reg_dly < TRAPIDO1_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TRAPIDO2_LEFT - 3 and h_cntr_reg_dly < TRAPIDO2_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO2_TOP - 3 and v_cntr_reg_dly < TRAPIDO2_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TRAPIDO3_LEFT - 3 and h_cntr_reg_dly < TRAPIDO3_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO3_TOP - 3 and v_cntr_reg_dly < TRAPIDO3_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TRAPIDO4_LEFT - 3 and h_cntr_reg_dly < TRAPIDO4_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO4_TOP - 3 and v_cntr_reg_dly < TRAPIDO4_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TRAPIDO5_LEFT - 3 and h_cntr_reg_dly < TRAPIDO5_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO5_TOP - 3 and v_cntr_reg_dly < TRAPIDO5_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TRAPIDO6_LEFT - 3 and h_cntr_reg_dly < TRAPIDO6_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO6_TOP - 3 and v_cntr_reg_dly < TRAPIDO6_BOTTOM + 3)
                                        ))) or
                                    
                                        -- Bloques de Tiempo: RELÁMPAGO
                                        ((MENU_STATE_LED(3 downto 1) /= "000") and (MODE_CONFIG = "10" and (
                                        (h_cntr_reg_dly > TRELAMPAGO1_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO1_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO1_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO1_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TRELAMPAGO2_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO2_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO2_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO2_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TRELAMPAGO3_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO3_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO3_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO3_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TRELAMPAGO4_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO4_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO4_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO4_BOTTOM + 3)
                                        ))) or
                                    
                                        -- Bloques de Tiempo: BALA
                                        ((MENU_STATE_LED(3 downto 1) /= "000") and (MODE_CONFIG = "11" and (
                                        (h_cntr_reg_dly > TBALA1_LEFT - 3 and h_cntr_reg_dly < TBALA1_RIGHT + 3 and v_cntr_reg_dly > TBALA1_TOP - 3 and v_cntr_reg_dly < TBALA1_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TBALA2_LEFT - 3 and h_cntr_reg_dly < TBALA2_RIGHT + 3 and v_cntr_reg_dly > TBALA2_TOP - 3 and v_cntr_reg_dly < TBALA2_BOTTOM + 3)
                                        ))) or
                                    
                                        -- Bloques de Incremento: CLÁSICO
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (
                                        ((MODE_CONFIG = "00" or ((MODE_CONFIG = "10" or MODE_CONFIG = "01") and TIME_CONFIG = "000")) and (
                                        (h_cntr_reg_dly > ICLASICO1_LEFT - 3 and h_cntr_reg_dly < ICLASICO1_RIGHT + 3 and v_cntr_reg_dly > ICLASICO1_TOP - 3 and v_cntr_reg_dly < ICLASICO1_BOTTOM + 3)
                                        )))) or
                                    
                                        -- Bloques de Incremento: RÁPIDO
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (MODE_CONFIG = "01" and (
                                        TIME_CONFIG /= "000" and (
                                        (h_cntr_reg_dly > IRAPIDO4_LEFT - 3 and h_cntr_reg_dly < IRAPIDO4_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO4_TOP - 3 and v_cntr_reg_dly < IRAPIDO4_BOTTOM + 3) or
                                        (TIME_CONFIG /= "001" and (
                                        (h_cntr_reg_dly > IRAPIDO3_LEFT - 3 and h_cntr_reg_dly < IRAPIDO3_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO3_TOP - 3 and v_cntr_reg_dly < IRAPIDO3_BOTTOM + 3) or
                                        (h_cntr_reg_dly > IRAPIDO2_LEFT - 3 and h_cntr_reg_dly < IRAPIDO2_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO2_TOP - 3 and v_cntr_reg_dly < IRAPIDO2_BOTTOM + 3) or
                                        (TIME_CONFIG /= "010" and (
                                        (h_cntr_reg_dly > IRAPIDO1_LEFT - 3 and h_cntr_reg_dly < IRAPIDO1_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO1_TOP - 3 and v_cntr_reg_dly < IRAPIDO1_BOTTOM + 3)
                                        )))
                                        )
                                        )))) or
                                    
                                        -- Bloques de Incremento: RELÁMPAGO
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (MODE_CONFIG = "10" and (
                                        TIME_CONFIG /= "000" and (
                                        (h_cntr_reg_dly > IRELAMPAGO4_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO4_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO4_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO4_BOTTOM + 3) or
                                        (TIME_CONFIG /= "010" and (
                                        (h_cntr_reg_dly > IRELAMPAGO1_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO1_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO1_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO1_BOTTOM + 3) or
                                        (h_cntr_reg_dly > IRELAMPAGO2_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO2_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO2_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO2_BOTTOM + 3) or
                                        (h_cntr_reg_dly > IRELAMPAGO3_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO3_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO3_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO3_BOTTOM + 3)
                                        ))
                                        ) 
                                        ))) or
                                    
                                        -- Bloques de Incremento: BALA
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (MODE_CONFIG = "11" and (
                                        (h_cntr_reg_dly > IBALA1_LEFT - 3 and h_cntr_reg_dly < IBALA1_RIGHT + 3 and v_cntr_reg_dly > IBALA1_TOP - 3 and v_cntr_reg_dly < IBALA1_BOTTOM + 3)
                                        ))) or
                                        
                                        -- Bloque "SI" y bloque "NO"
                                        ((MENU_STATE_LED(5) = '1') and (
                                        (h_cntr_reg_dly > SI_LEFT - 3 and h_cntr_reg_dly < SI_RIGHT + 3 and v_cntr_reg_dly > SI_TOP - 3 and v_cntr_reg_dly < SI_BOTTOM + 3) or
                                        (h_cntr_reg_dly > NO_LEFT - 3 and h_cntr_reg_dly < NO_RIGHT + 3 and v_cntr_reg_dly > NO_TOP - 3 and v_cntr_reg_dly < NO_BOTTOM + 3)
                                        ))
                                        )
               else
               
               -- Pintar rectángulo blanco que simula ventana de pausa durante una partida en progreso
               x"F" when
                                        -- Bloque de texto de la ventana emergente
                                        ((MENU_STATE_LED(5) = '1') and (
                                        (h_cntr_reg_dly > 610 and h_cntr_reg_dly < 1310 and v_cntr_reg_dly > VENTANA_TOP and v_cntr_reg_dly < 800)
                                        ))
               else
               
               -- Pintar rectángulos blancos que contienen las cuentas de los jugadores durante la partida
               x"F" when                ((MENU_STATE_LED(4) = '1') and (
                                        (h_cntr_reg_dly > 280  and h_cntr_reg_dly < 860  and v_cntr_reg_dly > 680 and v_cntr_reg_dly < 870) or
                                        (h_cntr_reg_dly > 1100 and h_cntr_reg_dly < 1680 and v_cntr_reg_dly > 680 and v_cntr_reg_dly < 870)
                                        ))
               else
               
               -- Painting a grey border around non-selectable blocks
               x"8" when                (-- Bloques del menú fijo (MODO, TIEMPO e INCREMENTO)
                                        ((MENU_STATE_LED(4) = '0' and MENU_STATE_LED(5) = '0') and (
                                        (h_cntr_reg_dly > MODO_LEFT - 3       and h_cntr_reg_dly < MODO_RIGHT + 3       and v_cntr_reg_dly > MODO_TOP - 3       and v_cntr_reg_dly < MODO_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TIEMPO_LEFT - 3     and h_cntr_reg_dly < TIEMPO_RIGHT + 3     and v_cntr_reg_dly > TIEMPO_TOP - 3     and v_cntr_reg_dly < TIEMPO_BOTTOM + 3) or
                                        (h_cntr_reg_dly > INCREMENTO_LEFT - 3 and h_cntr_reg_dly < INCREMENTO_RIGHT + 3 and v_cntr_reg_dly > INCREMENTO_TOP - 3 and v_cntr_reg_dly < INCREMENTO_BOTTOM + 3)
                                        )) or
                                        
                                        -- Bloque "PIEZAS BLANCAS" y bloque "PIEZAS NEGRAS"
                                        ((MENU_STATE_LED(4) = '1') and (
                                        (h_cntr_reg_dly > BLANCAS_LEFT - 3 and h_cntr_reg_dly < BLANCAS_RIGHT + 3 and v_cntr_reg_dly > BLANCAS_TOP - 3 and v_cntr_reg_dly < BLANCAS_BOTTOM + 3) or
                                        (h_cntr_reg_dly > NEGRAS_LEFT - 3  and h_cntr_reg_dly < NEGRAS_RIGHT + 3  and v_cntr_reg_dly > NEGRAS_TOP - 3  and v_cntr_reg_dly < NEGRAS_BOTTOM + 3)
                                        )) or
                                        
                                        -- Bloque de texto de la ventana emergente
                                        ((MENU_STATE_LED(5) = '1') and (
                                        (h_cntr_reg_dly > 610 - 3 and h_cntr_reg_dly < 1310 + 3 and v_cntr_reg_dly > VENTANA_TOP - 3 and v_cntr_reg_dly < 800 + 3)
                                        )) or
                                        
                                        -- Bloques de los títulos
                                        ((MENU_STATE_LED(5) = '0') and
                                        (h_cntr_reg_dly > TITULO_LEFT - 3 and h_cntr_reg_dly < TITULO_RIGHT + 3 and v_cntr_reg_dly > TITULO_TOP - 3 and v_cntr_reg_dly < TITULO_BOTTOM + 3)
                                        ) or
                                        
                                        -- Bloques blancos que contienen las cuentas
                                        ((MENU_STATE_LED(4) = '1') and (
                                        (h_cntr_reg_dly > 280 - 3  and h_cntr_reg_dly < 860 + 3  and v_cntr_reg_dly > 680 - 3 and v_cntr_reg_dly < 870 + 3) or
                                        (h_cntr_reg_dly > 1100 - 3 and h_cntr_reg_dly < 1680 + 3 and v_cntr_reg_dly > 680 - 3 and v_cntr_reg_dly < 870 + 3)
                                        ))
                                        )
               else
               -- Colorbar will be on the backround
               bg_green_dly;

-----------
-- Blue
-----------

  vga_blue <=  -- Mouse_cursor_display is on the top of others
               mouse_cursor_blue_dly when enable_mouse_display_dly = '1'
--               else
--               -- Overlay display is black 
--               x"0" when overlay_en_dly = '1'
               else
               -- Display of BRAM content
               
               -- Pintar títulos de pantalla
               overlay_output_titulos when (                    
                                        -- Bloque "MENU DE AJEDREZ" y bloque "PARTIDA EN CURSO"
                                        ((MENU_STATE_LED(5) = '0') and
                                        (h_cntr_reg > TITULO_LEFT and h_cntr_reg < TITULO_RIGHT and v_cntr_reg > TITULO_TOP and v_cntr_reg < TITULO_BOTTOM)
                                        ))
               else
               
               -- Pintar bloques fijos y modos de juego
               overlay_output_modo when (-- Bloques Principales (Menú Raíz)
                                        ((MENU_STATE_LED(4) = '0' and MENU_STATE_LED(5) = '0') and (
                                        (h_cntr_reg_dly > MODO_LEFT       and h_cntr_reg_dly < MODO_RIGHT       and v_cntr_reg_dly > MODO_TOP       and v_cntr_reg_dly < MODO_BOTTOM) or
                                        (h_cntr_reg_dly > TIEMPO_LEFT     and h_cntr_reg_dly < TIEMPO_RIGHT     and v_cntr_reg_dly > TIEMPO_TOP     and v_cntr_reg_dly < TIEMPO_BOTTOM) or
                                        (h_cntr_reg_dly > INCREMENTO_LEFT and h_cntr_reg_dly < INCREMENTO_RIGHT and v_cntr_reg_dly > INCREMENTO_TOP and v_cntr_reg_dly < INCREMENTO_BOTTOM) or
                                        (h_cntr_reg_dly > CLASICO_LEFT    and h_cntr_reg_dly < CLASICO_RIGHT    and v_cntr_reg_dly > CLASICO_TOP    and v_cntr_reg_dly < CLASICO_BOTTOM) or
                                        (h_cntr_reg_dly > RAPIDO_LEFT     and h_cntr_reg_dly < RAPIDO_RIGHT     and v_cntr_reg_dly > RAPIDO_TOP     and v_cntr_reg_dly < RAPIDO_BOTTOM) or
                                        (h_cntr_reg_dly > RELAMPAGO_LEFT  and h_cntr_reg_dly < RELAMPAGO_RIGHT  and v_cntr_reg_dly > RELAMPAGO_TOP  and v_cntr_reg_dly < RELAMPAGO_BOTTOM) or
                                        (h_cntr_reg_dly > BALA_LEFT       and h_cntr_reg_dly < BALA_RIGHT       and v_cntr_reg_dly > BALA_TOP       and v_cntr_reg_dly < BALA_BOTTOM)
                                        )))
               else
               
               -- Pintar iconos de navegación del menú
               overlay_output_nav when (                    
                                        -- Bloque "ATRAS"
                                        ((MENU_STATE_LED(3) = '1' or MENU_STATE_LED(2) = '1' or MENU_STATE_LED(1) = '1') and (
                                        (h_cntr_reg_dly > ATRAS_LEFT and h_cntr_reg_dly < ATRAS_RIGHT and v_cntr_reg_dly > ATRAS_TOP and v_cntr_reg_dly < ATRAS_BOTTOM)
                                        )) or
                                    
                                        -- Bloque "JUGAR"
                                        ((MENU_STATE_LED(3) = '1') and (
                                        (h_cntr_reg_dly > JUGAR_LEFT and h_cntr_reg_dly < JUGAR_RIGHT and v_cntr_reg_dly > JUGAR_TOP and v_cntr_reg_dly < JUGAR_BOTTOM)
                                        ))                                
                                        )
               else
               
               -- Pintar tiempo e incrementos
               overlay_output_tiempo when (                    
                                        -- Bloques de Tiempo: CLÁSICO
                                        ((MENU_STATE_LED(3 downto 1) /= "000") and (MODE_CONFIG = "00" and (
                                        (h_cntr_reg_dly > TCLASICO1_LEFT and h_cntr_reg_dly < TCLASICO1_RIGHT and v_cntr_reg_dly > TCLASICO1_TOP and v_cntr_reg_dly < TCLASICO1_BOTTOM) or
                                        (h_cntr_reg_dly > TCLASICO2_LEFT and h_cntr_reg_dly < TCLASICO2_RIGHT and v_cntr_reg_dly > TCLASICO2_TOP and v_cntr_reg_dly < TCLASICO2_BOTTOM) or
                                        (h_cntr_reg_dly > TCLASICO3_LEFT and h_cntr_reg_dly < TCLASICO3_RIGHT and v_cntr_reg_dly > TCLASICO3_TOP and v_cntr_reg_dly < TCLASICO3_BOTTOM) or
                                        (h_cntr_reg_dly > TCLASICO4_LEFT and h_cntr_reg_dly < TCLASICO4_RIGHT and v_cntr_reg_dly > TCLASICO4_TOP and v_cntr_reg_dly < TCLASICO4_BOTTOM)
                                        ))) or
                                    
                                        -- Bloques de Tiempo: RÁPIDO
                                        ((MENU_STATE_LED(3 downto 1) /= "000") and (MODE_CONFIG = "01" and (
                                        (h_cntr_reg_dly > TRAPIDO1_LEFT and h_cntr_reg_dly < TRAPIDO1_RIGHT and v_cntr_reg_dly > TRAPIDO1_TOP and v_cntr_reg_dly < TRAPIDO1_BOTTOM) or
                                        (h_cntr_reg_dly > TRAPIDO2_LEFT and h_cntr_reg_dly < TRAPIDO2_RIGHT and v_cntr_reg_dly > TRAPIDO2_TOP and v_cntr_reg_dly < TRAPIDO2_BOTTOM) or
                                        (h_cntr_reg_dly > TRAPIDO3_LEFT and h_cntr_reg_dly < TRAPIDO3_RIGHT and v_cntr_reg_dly > TRAPIDO3_TOP and v_cntr_reg_dly < TRAPIDO3_BOTTOM) or
                                        (h_cntr_reg_dly > TRAPIDO4_LEFT and h_cntr_reg_dly < TRAPIDO4_RIGHT and v_cntr_reg_dly > TRAPIDO4_TOP and v_cntr_reg_dly < TRAPIDO4_BOTTOM) or
                                        (h_cntr_reg_dly > TRAPIDO5_LEFT and h_cntr_reg_dly < TRAPIDO5_RIGHT and v_cntr_reg_dly > TRAPIDO5_TOP and v_cntr_reg_dly < TRAPIDO5_BOTTOM) or
                                        (h_cntr_reg_dly > TRAPIDO6_LEFT and h_cntr_reg_dly < TRAPIDO6_RIGHT and v_cntr_reg_dly > TRAPIDO6_TOP and v_cntr_reg_dly < TRAPIDO6_BOTTOM)
                                        ))) or
                                    
                                        -- Bloques de Tiempo: RELÁMPAGO
                                        ((MENU_STATE_LED(3 downto 1) /= "000") and (MODE_CONFIG = "10" and (
                                        (h_cntr_reg_dly > TRELAMPAGO1_LEFT and h_cntr_reg_dly < TRELAMPAGO1_RIGHT and v_cntr_reg_dly > TRELAMPAGO1_TOP and v_cntr_reg_dly < TRELAMPAGO1_BOTTOM) or
                                        (h_cntr_reg_dly > TRELAMPAGO2_LEFT and h_cntr_reg_dly < TRELAMPAGO2_RIGHT and v_cntr_reg_dly > TRELAMPAGO2_TOP and v_cntr_reg_dly < TRELAMPAGO2_BOTTOM) or
                                        (h_cntr_reg_dly > TRELAMPAGO3_LEFT and h_cntr_reg_dly < TRELAMPAGO3_RIGHT and v_cntr_reg_dly > TRELAMPAGO3_TOP and v_cntr_reg_dly < TRELAMPAGO3_BOTTOM) or
                                        (h_cntr_reg_dly > TRELAMPAGO4_LEFT and h_cntr_reg_dly < TRELAMPAGO4_RIGHT and v_cntr_reg_dly > TRELAMPAGO4_TOP and v_cntr_reg_dly < TRELAMPAGO4_BOTTOM)
                                        ))) or
                                    
                                        -- Bloques de Tiempo: BALA
                                        ((MENU_STATE_LED(3 downto 1) /= "000") and (MODE_CONFIG = "11" and (
                                        (h_cntr_reg_dly > TBALA1_LEFT and h_cntr_reg_dly < TBALA1_RIGHT and v_cntr_reg_dly > TBALA1_TOP and v_cntr_reg_dly < TBALA1_BOTTOM) or
                                        (h_cntr_reg_dly > TBALA2_LEFT and h_cntr_reg_dly < TBALA2_RIGHT and v_cntr_reg_dly > TBALA2_TOP and v_cntr_reg_dly < TBALA2_BOTTOM)
                                        ))) or   
                                                          
                                        -- Bloques de Incremento: CLÁSICO
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (
                                        ((MODE_CONFIG = "00" or ((MODE_CONFIG = "10" or MODE_CONFIG = "01") and TIME_CONFIG = "000")) and (
                                        (h_cntr_reg_dly > ICLASICO1_LEFT and h_cntr_reg_dly < ICLASICO1_RIGHT and v_cntr_reg_dly > ICLASICO1_TOP and v_cntr_reg_dly < ICLASICO1_BOTTOM)
                                        )))) or
                                    
                                        -- Bloques de Incremento: RÁPIDO
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (MODE_CONFIG = "01" and (
                                        TIME_CONFIG /= "000" and (
                                        (h_cntr_reg_dly > IRAPIDO4_LEFT and h_cntr_reg_dly < IRAPIDO4_RIGHT and v_cntr_reg_dly > IRAPIDO4_TOP and v_cntr_reg_dly < IRAPIDO4_BOTTOM) or
                                        (TIME_CONFIG /= "001" and (
                                        (h_cntr_reg_dly > IRAPIDO3_LEFT and h_cntr_reg_dly < IRAPIDO3_RIGHT and v_cntr_reg_dly > IRAPIDO3_TOP and v_cntr_reg_dly < IRAPIDO3_BOTTOM) or
                                        (h_cntr_reg_dly > IRAPIDO2_LEFT and h_cntr_reg_dly < IRAPIDO2_RIGHT and v_cntr_reg_dly > IRAPIDO2_TOP and v_cntr_reg_dly < IRAPIDO2_BOTTOM) or
                                        (TIME_CONFIG /= "010" and (
                                        (h_cntr_reg_dly > IRAPIDO1_LEFT and h_cntr_reg_dly < IRAPIDO1_RIGHT and v_cntr_reg_dly > IRAPIDO1_TOP and v_cntr_reg_dly < IRAPIDO1_BOTTOM)
                                        )))
                                        )
                                        )))) or
                                    
                                        -- Bloques de Incremento: RELÁMPAGO
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (MODE_CONFIG = "10" and (
                                        TIME_CONFIG /= "000" and (
                                        (h_cntr_reg_dly > IRELAMPAGO4_LEFT and h_cntr_reg_dly < IRELAMPAGO4_RIGHT and v_cntr_reg_dly > IRELAMPAGO4_TOP and v_cntr_reg_dly < IRELAMPAGO4_BOTTOM) or
                                        (TIME_CONFIG /= "010" and (
                                        (h_cntr_reg_dly > IRELAMPAGO1_LEFT and h_cntr_reg_dly < IRELAMPAGO1_RIGHT and v_cntr_reg_dly > IRELAMPAGO1_TOP and v_cntr_reg_dly < IRELAMPAGO1_BOTTOM) or
                                        (h_cntr_reg_dly > IRELAMPAGO2_LEFT and h_cntr_reg_dly < IRELAMPAGO2_RIGHT and v_cntr_reg_dly > IRELAMPAGO2_TOP and v_cntr_reg_dly < IRELAMPAGO2_BOTTOM) or
                                        (h_cntr_reg_dly > IRELAMPAGO3_LEFT and h_cntr_reg_dly < IRELAMPAGO3_RIGHT and v_cntr_reg_dly > IRELAMPAGO3_TOP and v_cntr_reg_dly < IRELAMPAGO3_BOTTOM)
                                        ))
                                        ) 
                                        ))) or
                                    
                                        -- Bloques de Incremento: BALA
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (MODE_CONFIG = "11" and (
                                        (h_cntr_reg_dly > IBALA1_LEFT and h_cntr_reg_dly < IBALA1_RIGHT and v_cntr_reg_dly > IBALA1_TOP and v_cntr_reg_dly < IBALA1_BOTTOM)
                                        )))
                                        
                                        )
               else
               
               -- Pintar textos de los jugadores en la pantalla de juego
               overlay_output_piezas when (                    
                                        -- Bloque "PIEZAS BLANCAS" y bloque "PIEZAS NEGRAS"
                                        ((MENU_STATE_LED(4) = '1') and (
                                        (h_cntr_reg_dly > BLANCAS_LEFT and h_cntr_reg_dly < BLANCAS_RIGHT and v_cntr_reg_dly > BLANCAS_TOP and v_cntr_reg_dly < BLANCAS_BOTTOM) or
                                        (h_cntr_reg_dly > NEGRAS_LEFT  and h_cntr_reg_dly < NEGRAS_RIGHT  and v_cntr_reg_dly > NEGRAS_TOP  and v_cntr_reg_dly < NEGRAS_BOTTOM)
                                        ))                              
                                        )
               else
               
               -- Pintar bloques de la ventana emergente
               overlay_output_ventana when (                    
                                        -- Bloque "SI", bloque "NO" y bloque de texto de la ventana emergente
                                        ((MENU_STATE_LED(5) = '1') and (
                                        (h_cntr_reg_dly > SI_LEFT      and h_cntr_reg_dly < SI_RIGHT      and v_cntr_reg_dly > SI_TOP      and v_cntr_reg_dly < SI_BOTTOM) or
                                        (h_cntr_reg_dly > NO_LEFT      and h_cntr_reg_dly < NO_RIGHT      and v_cntr_reg_dly > NO_TOP      and v_cntr_reg_dly < NO_BOTTOM) or
                                        (h_cntr_reg_dly > VENTANA_LEFT and h_cntr_reg_dly < VENTANA_RIGHT and v_cntr_reg_dly > VENTANA_TOP and v_cntr_reg_dly < VENTANA_BOTTOM)
                                        ))                              
                                        )
               else
               
               -- Pintar números de la cuenta del jugador 1 (blancas)
               overlay_output_cuenta1(3 downto 0) when (                    
                                        ((MENU_STATE_LED(4) = '1') and (
                                        ((h_cntr_reg_dly > UHORAS1_LEFT          and h_cntr_reg_dly < UHORAS1_RIGHT          and v_cntr_reg_dly > UHORAS1_TOP          and v_cntr_reg_dly < UHORAS1_BOTTOM) and
                                        (CUENTA_BLANCAS(27 downto 24) /= "0000")) or
                                        ((h_cntr_reg_dly > PUNTOS_HORASMIN1_LEFT and h_cntr_reg_dly < PUNTOS_HORASMIN1_RIGHT and v_cntr_reg_dly > PUNTOS_HORASMIN1_TOP and v_cntr_reg_dly < PUNTOS_HORASMIN1_BOTTOM) and
                                        (CUENTA_BLANCAS(27 downto 24) /= "0000")) or
                                        ((h_cntr_reg_dly > DMINUTOS1_LEFT        and h_cntr_reg_dly < DMINUTOS1_RIGHT        and v_cntr_reg_dly > DMINUTOS1_TOP        and v_cntr_reg_dly < DMINUTOS1_BOTTOM) and
                                        (CUENTA_BLANCAS(27 downto 16) /= "000000000000")) or
                                        ((h_cntr_reg_dly > UMINUTOS1_LEFT        and h_cntr_reg_dly < UMINUTOS1_RIGHT        and v_cntr_reg_dly > UMINUTOS1_TOP        and v_cntr_reg_dly < UMINUTOS1_BOTTOM) and
                                        (CUENTA_BLANCAS(27 downto 16) /= "000000000000")) or
                                        ((h_cntr_reg_dly > PUNTOS_MINSEG1_LEFT   and h_cntr_reg_dly < PUNTOS_MINSEG1_RIGHT   and v_cntr_reg_dly > PUNTOS_MINSEG1_TOP   and v_cntr_reg_dly < PUNTOS_MINSEG1_BOTTOM) and
                                        (CUENTA_BLANCAS(27 downto 16) /= "000000000000")) or
                                        (h_cntr_reg_dly > DSEG1_LEFT            and h_cntr_reg_dly < DSEG1_RIGHT            and v_cntr_reg_dly > DSEG1_TOP            and v_cntr_reg_dly < DSEG1_BOTTOM) or
                                        (h_cntr_reg_dly > USEG1_LEFT            and h_cntr_reg_dly < USEG1_RIGHT            and v_cntr_reg_dly > USEG1_TOP            and v_cntr_reg_dly < USEG1_BOTTOM) or
                                        (h_cntr_reg_dly > PUNTO1_LEFT           and h_cntr_reg_dly < PUNTO1_RIGHT           and v_cntr_reg_dly > PUNTO1_TOP           and v_cntr_reg_dly < PUNTO1_BOTTOM) or
                                        (h_cntr_reg_dly > DECIMAS1_LEFT         and h_cntr_reg_dly < DECIMAS1_RIGHT         and v_cntr_reg_dly > DECIMAS1_TOP         and v_cntr_reg_dly < DECIMAS1_BOTTOM) or
                                        (h_cntr_reg_dly > CENTESIMAS1_LEFT      and h_cntr_reg_dly < CENTESIMAS1_RIGHT      and v_cntr_reg_dly > CENTESIMAS1_TOP      and v_cntr_reg_dly < CENTESIMAS1_BOTTOM)
                                        ))
                                        )
               else
               
               -- Pintar números de la cuenta del jugador 2 (negras)
               overlay_output_cuenta2(3 downto 0) when (                    
                                        ((MENU_STATE_LED(4) = '1') and (
                                        ((h_cntr_reg_dly > UHORAS2_LEFT          and h_cntr_reg_dly < UHORAS2_RIGHT          and v_cntr_reg_dly > UHORAS2_TOP          and v_cntr_reg_dly < UHORAS2_BOTTOM) and
                                        (CUENTA_NEGRAS(27 downto 24) /= "0000")) or
                                        ((h_cntr_reg_dly > PUNTOS_HORASMIN2_LEFT and h_cntr_reg_dly < PUNTOS_HORASMIN2_RIGHT and v_cntr_reg_dly > PUNTOS_HORASMIN2_TOP and v_cntr_reg_dly < PUNTOS_HORASMIN2_BOTTOM) and
                                        (CUENTA_NEGRAS(27 downto 24) /= "0000")) or
                                        ((h_cntr_reg_dly > DMINUTOS2_LEFT        and h_cntr_reg_dly < DMINUTOS2_RIGHT        and v_cntr_reg_dly > DMINUTOS2_TOP        and v_cntr_reg_dly < DMINUTOS2_BOTTOM) and
                                        (CUENTA_NEGRAS(27 downto 16) /= "000000000000")) or
                                        ((h_cntr_reg_dly > UMINUTOS2_LEFT        and h_cntr_reg_dly < UMINUTOS2_RIGHT        and v_cntr_reg_dly > UMINUTOS2_TOP        and v_cntr_reg_dly < UMINUTOS2_BOTTOM) and
                                        (CUENTA_NEGRAS(27 downto 16) /= "000000000000")) or
                                        ((h_cntr_reg_dly > PUNTOS_MINSEG2_LEFT   and h_cntr_reg_dly < PUNTOS_MINSEG2_RIGHT   and v_cntr_reg_dly > PUNTOS_MINSEG2_TOP   and v_cntr_reg_dly < PUNTOS_MINSEG2_BOTTOM) and
                                        (CUENTA_NEGRAS(27 downto 16) /= "000000000000")) or
                                        (h_cntr_reg_dly > DSEG2_LEFT            and h_cntr_reg_dly < DSEG2_RIGHT            and v_cntr_reg_dly > DSEG2_TOP            and v_cntr_reg_dly < DSEG2_BOTTOM) or
                                        (h_cntr_reg_dly > USEG2_LEFT            and h_cntr_reg_dly < USEG2_RIGHT            and v_cntr_reg_dly > USEG2_TOP            and v_cntr_reg_dly < USEG2_BOTTOM) or
                                        (h_cntr_reg_dly > PUNTO2_LEFT           and h_cntr_reg_dly < PUNTO2_RIGHT           and v_cntr_reg_dly > PUNTO2_TOP           and v_cntr_reg_dly < PUNTO2_BOTTOM) or
                                        (h_cntr_reg_dly > DECIMAS2_LEFT         and h_cntr_reg_dly < DECIMAS2_RIGHT         and v_cntr_reg_dly > DECIMAS2_TOP         and v_cntr_reg_dly < DECIMAS2_BOTTOM) or
                                        (h_cntr_reg_dly > CENTESIMAS2_LEFT      and h_cntr_reg_dly < CENTESIMAS2_RIGHT      and v_cntr_reg_dly > CENTESIMAS2_TOP      and v_cntr_reg_dly < CENTESIMAS2_BOTTOM)
                                        ))
                                        )
               else
               
               -- Painting a green border around the selectable BRAM blocks once selected
               x"0" when                (                                        
                                        (-- Bloques Principales (Menú Raíz)
                                        ((MENU_STATE_LED(3 downto 1) /= "000") and (
                                        ((h_cntr_reg_dly > CLASICO_LEFT - 3   and h_cntr_reg_dly < CLASICO_RIGHT + 3   and v_cntr_reg_dly > CLASICO_TOP - 3   and v_cntr_reg_dly < CLASICO_BOTTOM + 3) and
                                        (selected_clasico = '1')) or
                                        ((h_cntr_reg_dly > RAPIDO_LEFT - 3    and h_cntr_reg_dly < RAPIDO_RIGHT + 3    and v_cntr_reg_dly > RAPIDO_TOP - 3    and v_cntr_reg_dly < RAPIDO_BOTTOM + 3) and
                                        (selected_rapido = '1')) or
                                        ((h_cntr_reg_dly > RELAMPAGO_LEFT - 3 and h_cntr_reg_dly < RELAMPAGO_RIGHT + 3 and v_cntr_reg_dly > RELAMPAGO_TOP - 3 and v_cntr_reg_dly < RELAMPAGO_BOTTOM + 3) and
                                        (selected_relampago = '1')) or
                                        ((h_cntr_reg_dly > BALA_LEFT - 3      and h_cntr_reg_dly < BALA_RIGHT + 3      and v_cntr_reg_dly > BALA_TOP - 3      and v_cntr_reg_dly < BALA_BOTTOM + 3) and
                                        (selected_bala = '1'))
                                        )) or
                                    
                                        -- Bloques de Tiempo: CLÁSICO
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (
                                        ((h_cntr_reg_dly > TCLASICO1_LEFT - 3 and h_cntr_reg_dly < TCLASICO1_RIGHT + 3 and v_cntr_reg_dly > TCLASICO1_TOP - 3 and v_cntr_reg_dly < TCLASICO1_BOTTOM + 3) and
                                        (selected_2h_30m = '1')) or
                                        ((h_cntr_reg_dly > TCLASICO2_LEFT - 3 and h_cntr_reg_dly < TCLASICO2_RIGHT + 3 and v_cntr_reg_dly > TCLASICO2_TOP - 3 and v_cntr_reg_dly < TCLASICO2_BOTTOM + 3) and
                                        (selected_2h_1h_15m = '1')) or
                                        ((h_cntr_reg_dly > TCLASICO3_LEFT - 3 and h_cntr_reg_dly < TCLASICO3_RIGHT + 3 and v_cntr_reg_dly > TCLASICO3_TOP - 3 and v_cntr_reg_dly < TCLASICO3_BOTTOM + 3) and
                                        (selected_2h_1h = '1')) or
                                        ((h_cntr_reg_dly > TCLASICO4_LEFT - 3 and h_cntr_reg_dly < TCLASICO4_RIGHT + 3 and v_cntr_reg_dly > TCLASICO4_TOP - 3 and v_cntr_reg_dly < TCLASICO4_BOTTOM + 3) and
                                        (selected_1h_30m = '1'))
                                        )) or
                                    
                                        -- Bloques de Tiempo: RÁPIDO
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (
                                        ((h_cntr_reg_dly > TRAPIDO1_LEFT - 3 and h_cntr_reg_dly < TRAPIDO1_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO1_TOP - 3 and v_cntr_reg_dly < TRAPIDO1_BOTTOM + 3) and
                                        (selected_60m = '1')) or
                                        ((h_cntr_reg_dly > TRAPIDO2_LEFT - 3 and h_cntr_reg_dly < TRAPIDO2_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO2_TOP - 3 and v_cntr_reg_dly < TRAPIDO2_BOTTOM + 3) and
                                        (selected_50m = '1')) or
                                        ((h_cntr_reg_dly > TRAPIDO3_LEFT - 3 and h_cntr_reg_dly < TRAPIDO3_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO3_TOP - 3 and v_cntr_reg_dly < TRAPIDO3_BOTTOM + 3) and
                                        (selected_40m = '1')) or
                                        ((h_cntr_reg_dly > TRAPIDO4_LEFT - 3 and h_cntr_reg_dly < TRAPIDO4_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO4_TOP - 3 and v_cntr_reg_dly < TRAPIDO4_BOTTOM + 3) and
                                        (selected_30m = '1')) or
                                        ((h_cntr_reg_dly > TRAPIDO5_LEFT - 3 and h_cntr_reg_dly < TRAPIDO5_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO5_TOP - 3 and v_cntr_reg_dly < TRAPIDO5_BOTTOM + 3) and
                                        (selected_20m = '1')) or
                                        ((h_cntr_reg_dly > TRAPIDO6_LEFT - 3 and h_cntr_reg_dly < TRAPIDO6_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO6_TOP - 3 and v_cntr_reg_dly < TRAPIDO6_BOTTOM + 3) and
                                        (selected_10m = '1'))
                                        )) or
                                    
                                        -- Bloques de Tiempo: RELÁMPAGO
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (
                                        ((h_cntr_reg_dly > TRELAMPAGO1_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO1_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO1_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO1_BOTTOM + 3) and
                                        (selected_10m_bz = '1')) or
                                        ((h_cntr_reg_dly > TRELAMPAGO2_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO2_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO2_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO2_BOTTOM + 3) and
                                        (selected_8m = '1')) or
                                        ((h_cntr_reg_dly > TRELAMPAGO3_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO3_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO3_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO3_BOTTOM + 3) and
                                        (selected_5m = '1')) or
                                        ((h_cntr_reg_dly > TRELAMPAGO4_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO4_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO4_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO4_BOTTOM + 3) and
                                        (selected_3m = '1'))
                                        )) or
                                    
                                        -- Bloques de Tiempo: BALA
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (
                                        ((h_cntr_reg_dly > TBALA1_LEFT - 3 and h_cntr_reg_dly < TBALA1_RIGHT + 3 and v_cntr_reg_dly > TBALA1_TOP - 3 and v_cntr_reg_dly < TBALA1_BOTTOM + 3) and
                                        (selected_2m = '1')) or
                                        ((h_cntr_reg_dly > TBALA2_LEFT - 3 and h_cntr_reg_dly < TBALA2_RIGHT + 3 and v_cntr_reg_dly > TBALA2_TOP - 3 and v_cntr_reg_dly < TBALA2_BOTTOM + 3) and
                                        (selected_1m = '1'))
                                        )) or
                                    
                                        -- Bloques de Incremento: CLÁSICO
                                        ((MENU_STATE_LED(3) = '1') and (
                                        ((h_cntr_reg_dly > ICLASICO1_LEFT - 3 and h_cntr_reg_dly < ICLASICO1_RIGHT + 3 and v_cntr_reg_dly > ICLASICO1_TOP - 3 and v_cntr_reg_dly < ICLASICO1_BOTTOM + 3) and
                                        (selected_estandar = '1'))
                                        )) or
                                    
                                        -- Bloques de Incremento: RÁPIDO
                                        ((MENU_STATE_LED(3) = '1') and (
                                        ((h_cntr_reg_dly > IRAPIDO1_LEFT - 3 and h_cntr_reg_dly < IRAPIDO1_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO1_TOP - 3 and v_cntr_reg_dly < IRAPIDO1_BOTTOM + 3) and
                                        (selected_30s = '1')) or
                                        ((h_cntr_reg_dly > IRAPIDO2_LEFT - 3 and h_cntr_reg_dly < IRAPIDO2_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO2_TOP - 3 and v_cntr_reg_dly < IRAPIDO2_BOTTOM + 3) and
                                        (selected_20s = '1')) or
                                        ((h_cntr_reg_dly > IRAPIDO3_LEFT - 3 and h_cntr_reg_dly < IRAPIDO3_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO3_TOP - 3 and v_cntr_reg_dly < IRAPIDO3_BOTTOM + 3) and
                                        (selected_15s = '1')) or
                                        ((h_cntr_reg_dly > IRAPIDO4_LEFT - 3 and h_cntr_reg_dly < IRAPIDO4_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO4_TOP - 3 and v_cntr_reg_dly < IRAPIDO4_BOTTOM + 3) and
                                        (selected_10s = '1'))
                                        )) or
                                        
                                        -- Bloques de Incremento: RELÁMPAGO
                                        ((MENU_STATE_LED(3) = '1') and (
                                        ((h_cntr_reg_dly > IRELAMPAGO1_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO1_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO1_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO1_BOTTOM + 3) and
                                        (selected_5s = '1')) or
                                        ((h_cntr_reg_dly > IRELAMPAGO2_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO2_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO2_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO2_BOTTOM + 3) and
                                        (selected_4s = '1')) or
                                        ((h_cntr_reg_dly > IRELAMPAGO3_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO3_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO3_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO3_BOTTOM + 3) and
                                        (selected_3s = '1')) or
                                        ((h_cntr_reg_dly > IRELAMPAGO4_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO4_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO4_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO4_BOTTOM + 3) and
                                        (selected_2s = '1'))
                                        )) or
                                    
                                        -- Bloques de Incremento: BALA
                                        ((MENU_STATE_LED(3) = '1') and (
                                        ((h_cntr_reg_dly > IBALA1_LEFT - 3 and h_cntr_reg_dly < IBALA1_RIGHT + 3 and v_cntr_reg_dly > IBALA1_TOP - 3 and v_cntr_reg_dly < IBALA1_BOTTOM + 3) and
                                        (selected_estandar = '1'))
                                        )))
                                        )
               else
               
               -- Painting a yellow border around the selectable BRAM blocks being hovered
               x"0" when                (-- Bloques Principales (Menú Raíz)
                                        ((MENU_STATE_LED(0) = '1') and (
                                        ((h_cntr_reg_dly > CLASICO_LEFT - 3   and h_cntr_reg_dly < CLASICO_RIGHT + 3   and v_cntr_reg_dly > CLASICO_TOP - 3   and v_cntr_reg_dly < CLASICO_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > CLASICO_LEFT     and MOUSE_X_PIXEL < CLASICO_RIGHT    and MOUSE_Y_PIXEL > CLASICO_TOP    and MOUSE_Y_PIXEL < CLASICO_BOTTOM)) or
                                        ((h_cntr_reg_dly > RAPIDO_LEFT - 3    and h_cntr_reg_dly < RAPIDO_RIGHT + 3    and v_cntr_reg_dly > RAPIDO_TOP - 3    and v_cntr_reg_dly < RAPIDO_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > RAPIDO_LEFT      and MOUSE_X_PIXEL < RAPIDO_RIGHT     and MOUSE_Y_PIXEL > RAPIDO_TOP     and MOUSE_Y_PIXEL < RAPIDO_BOTTOM)) or
                                        ((h_cntr_reg_dly > RELAMPAGO_LEFT - 3 and h_cntr_reg_dly < RELAMPAGO_RIGHT + 3 and v_cntr_reg_dly > RELAMPAGO_TOP - 3 and v_cntr_reg_dly < RELAMPAGO_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > RELAMPAGO_LEFT   and MOUSE_X_PIXEL < RELAMPAGO_RIGHT  and MOUSE_Y_PIXEL > RELAMPAGO_TOP  and MOUSE_Y_PIXEL < RELAMPAGO_BOTTOM)) or
                                        ((h_cntr_reg_dly > BALA_LEFT - 3      and h_cntr_reg_dly < BALA_RIGHT + 3      and v_cntr_reg_dly > BALA_TOP - 3      and v_cntr_reg_dly < BALA_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > BALA_LEFT        and MOUSE_X_PIXEL < BALA_RIGHT       and MOUSE_Y_PIXEL > BALA_TOP       and MOUSE_Y_PIXEL < BALA_BOTTOM))
                                        )) or
                                        
                                        -- Bloque "ATRAS"
                                        ((MENU_STATE_LED(3) = '1' or MENU_STATE_LED(2) = '1' or MENU_STATE_LED(1) = '1') and (
                                        ((h_cntr_reg_dly > ATRAS_LEFT - 3 and h_cntr_reg_dly < ATRAS_RIGHT + 3 and v_cntr_reg_dly > ATRAS_TOP - 3 and v_cntr_reg_dly < ATRAS_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > ATRAS_LEFT   and MOUSE_X_PIXEL < ATRAS_RIGHT  and MOUSE_Y_PIXEL > ATRAS_TOP  and MOUSE_Y_PIXEL < ATRAS_BOTTOM))
                                        )) or
                                    
                                        -- Bloque "JUGAR"
                                        ((MENU_STATE_LED(3) = '1') and (
                                        ((h_cntr_reg_dly > JUGAR_LEFT - 3 and h_cntr_reg_dly < JUGAR_RIGHT + 3 and v_cntr_reg_dly > JUGAR_TOP - 3 and v_cntr_reg_dly < JUGAR_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > JUGAR_LEFT   and MOUSE_X_PIXEL < JUGAR_RIGHT  and MOUSE_Y_PIXEL > JUGAR_TOP  and MOUSE_Y_PIXEL < JUGAR_BOTTOM))
                                        )) or
                                    
                                        -- Bloques de Tiempo: CLÁSICO
                                        ((MENU_STATE_LED(1) = '1') and (MODE_CONFIG = "00" and (
                                        ((h_cntr_reg_dly > TCLASICO1_LEFT - 3 and h_cntr_reg_dly < TCLASICO1_RIGHT + 3 and v_cntr_reg_dly > TCLASICO1_TOP - 3 and v_cntr_reg_dly < TCLASICO1_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TCLASICO1_LEFT   and MOUSE_X_PIXEL < TCLASICO1_RIGHT  and MOUSE_Y_PIXEL > TCLASICO1_TOP  and MOUSE_Y_PIXEL < TCLASICO1_BOTTOM)) or
                                        ((h_cntr_reg_dly > TCLASICO2_LEFT - 3 and h_cntr_reg_dly < TCLASICO2_RIGHT + 3 and v_cntr_reg_dly > TCLASICO2_TOP - 3 and v_cntr_reg_dly < TCLASICO2_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TCLASICO2_LEFT   and MOUSE_X_PIXEL < TCLASICO2_RIGHT  and MOUSE_Y_PIXEL > TCLASICO2_TOP  and MOUSE_Y_PIXEL < TCLASICO2_BOTTOM)) or
                                        ((h_cntr_reg_dly > TCLASICO3_LEFT - 3 and h_cntr_reg_dly < TCLASICO3_RIGHT + 3 and v_cntr_reg_dly > TCLASICO3_TOP - 3 and v_cntr_reg_dly < TCLASICO3_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TCLASICO3_LEFT   and MOUSE_X_PIXEL < TCLASICO3_RIGHT  and MOUSE_Y_PIXEL > TCLASICO3_TOP  and MOUSE_Y_PIXEL < TCLASICO3_BOTTOM)) or
                                        ((h_cntr_reg_dly > TCLASICO4_LEFT - 3 and h_cntr_reg_dly < TCLASICO4_RIGHT + 3 and v_cntr_reg_dly > TCLASICO4_TOP - 3 and v_cntr_reg_dly < TCLASICO4_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TCLASICO4_LEFT   and MOUSE_X_PIXEL < TCLASICO4_RIGHT  and MOUSE_Y_PIXEL > TCLASICO4_TOP  and MOUSE_Y_PIXEL < TCLASICO4_BOTTOM))
                                        ))) or
                                    
                                        -- Bloques de Tiempo: RÁPIDO
                                        ((MENU_STATE_LED(1) = '1') and (MODE_CONFIG = "01" and (
                                        ((h_cntr_reg_dly > TRAPIDO1_LEFT - 3 and h_cntr_reg_dly < TRAPIDO1_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO1_TOP - 3 and v_cntr_reg_dly < TRAPIDO1_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRAPIDO1_LEFT   and MOUSE_X_PIXEL < TRAPIDO1_RIGHT  and MOUSE_Y_PIXEL > TRAPIDO1_TOP  and MOUSE_Y_PIXEL < TRAPIDO1_BOTTOM)) or
                                        ((h_cntr_reg_dly > TRAPIDO2_LEFT - 3 and h_cntr_reg_dly < TRAPIDO2_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO2_TOP - 3 and v_cntr_reg_dly < TRAPIDO2_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRAPIDO2_LEFT   and MOUSE_X_PIXEL < TRAPIDO2_RIGHT  and MOUSE_Y_PIXEL > TRAPIDO2_TOP  and MOUSE_Y_PIXEL < TRAPIDO2_BOTTOM)) or
                                        ((h_cntr_reg_dly > TRAPIDO3_LEFT - 3 and h_cntr_reg_dly < TRAPIDO3_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO3_TOP - 3 and v_cntr_reg_dly < TRAPIDO3_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRAPIDO3_LEFT   and MOUSE_X_PIXEL < TRAPIDO3_RIGHT  and MOUSE_Y_PIXEL > TRAPIDO3_TOP  and MOUSE_Y_PIXEL < TRAPIDO3_BOTTOM)) or
                                        ((h_cntr_reg_dly > TRAPIDO4_LEFT - 3 and h_cntr_reg_dly < TRAPIDO4_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO4_TOP - 3 and v_cntr_reg_dly < TRAPIDO4_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRAPIDO4_LEFT   and MOUSE_X_PIXEL < TRAPIDO4_RIGHT  and MOUSE_Y_PIXEL > TRAPIDO4_TOP  and MOUSE_Y_PIXEL < TRAPIDO4_BOTTOM)) or
                                        ((h_cntr_reg_dly > TRAPIDO5_LEFT - 3 and h_cntr_reg_dly < TRAPIDO5_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO5_TOP - 3 and v_cntr_reg_dly < TRAPIDO5_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRAPIDO5_LEFT   and MOUSE_X_PIXEL < TRAPIDO5_RIGHT  and MOUSE_Y_PIXEL > TRAPIDO5_TOP  and MOUSE_Y_PIXEL < TRAPIDO5_BOTTOM)) or
                                        ((h_cntr_reg_dly > TRAPIDO6_LEFT - 3 and h_cntr_reg_dly < TRAPIDO6_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO6_TOP - 3 and v_cntr_reg_dly < TRAPIDO6_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRAPIDO6_LEFT   and MOUSE_X_PIXEL < TRAPIDO6_RIGHT  and MOUSE_Y_PIXEL > TRAPIDO6_TOP  and MOUSE_Y_PIXEL < TRAPIDO6_BOTTOM))
                                        ))) or
                                    
                                        -- Bloques de Tiempo: RELÁMPAGO
                                        ((MENU_STATE_LED(1) = '1') and (MODE_CONFIG = "10" and (
                                        ((h_cntr_reg_dly > TRELAMPAGO1_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO1_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO1_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO1_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRELAMPAGO1_LEFT   and MOUSE_X_PIXEL < TRELAMPAGO1_RIGHT  and MOUSE_Y_PIXEL > TRELAMPAGO1_TOP  and MOUSE_Y_PIXEL < TRELAMPAGO1_BOTTOM)) or
                                        ((h_cntr_reg_dly > TRELAMPAGO2_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO2_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO2_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO2_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRELAMPAGO2_LEFT   and MOUSE_X_PIXEL < TRELAMPAGO2_RIGHT  and MOUSE_Y_PIXEL > TRELAMPAGO2_TOP  and MOUSE_Y_PIXEL < TRELAMPAGO2_BOTTOM)) or
                                        ((h_cntr_reg_dly > TRELAMPAGO3_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO3_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO3_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO3_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRELAMPAGO3_LEFT   and MOUSE_X_PIXEL < TRELAMPAGO3_RIGHT  and MOUSE_Y_PIXEL > TRELAMPAGO3_TOP  and MOUSE_Y_PIXEL < TRELAMPAGO3_BOTTOM)) or
                                        ((h_cntr_reg_dly > TRELAMPAGO4_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO4_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO4_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO4_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TRELAMPAGO4_LEFT   and MOUSE_X_PIXEL < TRELAMPAGO4_RIGHT  and MOUSE_Y_PIXEL > TRELAMPAGO4_TOP  and MOUSE_Y_PIXEL < TRELAMPAGO4_BOTTOM))
                                        ))) or
                                    
                                        -- Bloques de Tiempo: BALA
                                        ((MENU_STATE_LED(1) = '1') and (MODE_CONFIG = "11" and (
                                        ((h_cntr_reg_dly > TBALA1_LEFT - 3 and h_cntr_reg_dly < TBALA1_RIGHT + 3 and v_cntr_reg_dly > TBALA1_TOP - 3 and v_cntr_reg_dly < TBALA1_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TBALA1_LEFT   and MOUSE_X_PIXEL < TBALA1_RIGHT  and MOUSE_Y_PIXEL > TBALA1_TOP  and MOUSE_Y_PIXEL < TBALA1_BOTTOM)) or
                                        ((h_cntr_reg_dly > TBALA2_LEFT - 3 and h_cntr_reg_dly < TBALA2_RIGHT + 3 and v_cntr_reg_dly > TBALA2_TOP - 3 and v_cntr_reg_dly < TBALA2_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > TBALA2_LEFT   and MOUSE_X_PIXEL < TBALA2_RIGHT  and MOUSE_Y_PIXEL > TBALA2_TOP  and MOUSE_Y_PIXEL < TBALA2_BOTTOM))
                                        ))) or
                                    
                                        -- Bloques de Incremento: CLÁSICO
                                        ((MENU_STATE_LED(2) = '1') and (
                                        ((MODE_CONFIG = "00" or ((MODE_CONFIG = "10" or MODE_CONFIG = "01") and TIME_CONFIG = "000")) and (
                                        ((h_cntr_reg_dly > ICLASICO1_LEFT - 3 and h_cntr_reg_dly < ICLASICO1_RIGHT + 3 and v_cntr_reg_dly > ICLASICO1_TOP - 3 and v_cntr_reg_dly < ICLASICO1_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > ICLASICO1_LEFT   and MOUSE_X_PIXEL < ICLASICO1_RIGHT  and MOUSE_Y_PIXEL > ICLASICO1_TOP  and MOUSE_Y_PIXEL < ICLASICO1_BOTTOM))
                                        )
                                        ))) or
                                    
                                        -- Bloques de Incremento: RÁPIDO
                                        ((MENU_STATE_LED(2) = '1') and (MODE_CONFIG = "01" and (
                                        TIME_CONFIG /= "000" and (
                                        ((h_cntr_reg_dly > IRAPIDO4_LEFT - 3 and h_cntr_reg_dly < IRAPIDO4_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO4_TOP - 3 and v_cntr_reg_dly < IRAPIDO4_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > IRAPIDO4_LEFT   and MOUSE_X_PIXEL < IRAPIDO4_RIGHT  and MOUSE_Y_PIXEL > IRAPIDO4_TOP  and MOUSE_Y_PIXEL < IRAPIDO4_BOTTOM)) or
                                        (TIME_CONFIG /= "001" and (
                                        ((h_cntr_reg_dly > IRAPIDO3_LEFT - 3 and h_cntr_reg_dly < IRAPIDO3_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO3_TOP - 3 and v_cntr_reg_dly < IRAPIDO3_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > IRAPIDO3_LEFT   and MOUSE_X_PIXEL < IRAPIDO3_RIGHT  and MOUSE_Y_PIXEL > IRAPIDO3_TOP  and MOUSE_Y_PIXEL < IRAPIDO3_BOTTOM)) or
                                        ((h_cntr_reg_dly > IRAPIDO2_LEFT - 3 and h_cntr_reg_dly < IRAPIDO2_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO2_TOP - 3 and v_cntr_reg_dly < IRAPIDO2_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > IRAPIDO2_LEFT   and MOUSE_X_PIXEL < IRAPIDO2_RIGHT  and MOUSE_Y_PIXEL > IRAPIDO2_TOP  and MOUSE_Y_PIXEL < IRAPIDO2_BOTTOM)) or
                                        (TIME_CONFIG /= "010" and (
                                        ((h_cntr_reg_dly > IRAPIDO1_LEFT - 3 and h_cntr_reg_dly < IRAPIDO1_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO1_TOP - 3 and v_cntr_reg_dly < IRAPIDO1_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > IRAPIDO1_LEFT   and MOUSE_X_PIXEL < IRAPIDO1_RIGHT  and MOUSE_Y_PIXEL > IRAPIDO1_TOP  and MOUSE_Y_PIXEL < IRAPIDO1_BOTTOM))
                                        )))
                                        )
                                        )))) or
                                    
                                        -- Bloques de Incremento: RELÁMPAGO
                                        ((MENU_STATE_LED(2) = '1') and (MODE_CONFIG = "10" and (
                                        TIME_CONFIG /= "000" and (
                                        ((h_cntr_reg_dly > IRELAMPAGO4_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO4_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO4_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO4_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > IRELAMPAGO4_LEFT   and MOUSE_X_PIXEL < IRELAMPAGO4_RIGHT  and MOUSE_Y_PIXEL > IRELAMPAGO4_TOP  and MOUSE_Y_PIXEL < IRELAMPAGO4_BOTTOM)) or
                                        (TIME_CONFIG /= "010" and (
                                        ((h_cntr_reg_dly > IRELAMPAGO1_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO1_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO1_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO1_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > IRELAMPAGO1_LEFT   and MOUSE_X_PIXEL < IRELAMPAGO1_RIGHT  and MOUSE_Y_PIXEL > IRELAMPAGO1_TOP  and MOUSE_Y_PIXEL < IRELAMPAGO1_BOTTOM)) or
                                        ((h_cntr_reg_dly > IRELAMPAGO2_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO2_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO2_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO2_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > IRELAMPAGO2_LEFT   and MOUSE_X_PIXEL < IRELAMPAGO2_RIGHT  and MOUSE_Y_PIXEL > IRELAMPAGO2_TOP  and MOUSE_Y_PIXEL < IRELAMPAGO2_BOTTOM)) or
                                        ((h_cntr_reg_dly > IRELAMPAGO3_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO3_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO3_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO3_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > IRELAMPAGO3_LEFT   and MOUSE_X_PIXEL < IRELAMPAGO3_RIGHT  and MOUSE_Y_PIXEL > IRELAMPAGO3_TOP  and MOUSE_Y_PIXEL < IRELAMPAGO3_BOTTOM)) 
                                        ))
                                        )
                                        ))) or
                                    
                                        -- Bloques de Incremento: BALA
                                        ((MENU_STATE_LED(2) = '1') and (MODE_CONFIG = "11" and (
                                        ((h_cntr_reg_dly > IBALA1_LEFT - 3 and h_cntr_reg_dly < IBALA1_RIGHT + 3 and v_cntr_reg_dly > IBALA1_TOP - 3 and v_cntr_reg_dly < IBALA1_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > IBALA1_LEFT   and MOUSE_X_PIXEL < IBALA1_RIGHT  and MOUSE_Y_PIXEL > IBALA1_TOP  and MOUSE_Y_PIXEL < IBALA1_BOTTOM))
                                        ))) or
                                        
                                        -- Bloque "SI" y bloque "NO"
                                        ((MENU_STATE_LED(5) = '1') and (
                                        ((h_cntr_reg_dly > SI_LEFT - 3 and h_cntr_reg_dly < SI_RIGHT + 3 and v_cntr_reg_dly > SI_TOP - 3 and v_cntr_reg_dly < SI_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > SI_LEFT   and MOUSE_X_PIXEL < SI_RIGHT  and MOUSE_Y_PIXEL > SI_TOP  and MOUSE_Y_PIXEL < SI_BOTTOM)) or
                                        ((h_cntr_reg_dly > NO_LEFT - 3 and h_cntr_reg_dly < NO_RIGHT + 3 and v_cntr_reg_dly > NO_TOP - 3 and v_cntr_reg_dly < NO_BOTTOM + 3) and
                                        (MOUSE_X_PIXEL > NO_LEFT   and MOUSE_X_PIXEL < NO_RIGHT  and MOUSE_Y_PIXEL > NO_TOP  and MOUSE_Y_PIXEL < NO_BOTTOM))
                                        ))
                                        )
               else
                                        
               -- Painting a red border around the BRAM blocks
               x"0" when                (-- Bloques Principales (Menú Raíz)
                                        ((MENU_STATE_LED(4) = '0' and MENU_STATE_LED(5) = '0') and (
                                        (h_cntr_reg_dly > CLASICO_LEFT - 3    and h_cntr_reg_dly < CLASICO_RIGHT + 3    and v_cntr_reg_dly > CLASICO_TOP - 3    and v_cntr_reg_dly < CLASICO_BOTTOM + 3) or
                                        (h_cntr_reg_dly > RAPIDO_LEFT - 3     and h_cntr_reg_dly < RAPIDO_RIGHT + 3     and v_cntr_reg_dly > RAPIDO_TOP - 3     and v_cntr_reg_dly < RAPIDO_BOTTOM + 3) or
                                        (h_cntr_reg_dly > RELAMPAGO_LEFT - 3  and h_cntr_reg_dly < RELAMPAGO_RIGHT + 3  and v_cntr_reg_dly > RELAMPAGO_TOP - 3  and v_cntr_reg_dly < RELAMPAGO_BOTTOM + 3) or
                                        (h_cntr_reg_dly > BALA_LEFT - 3       and h_cntr_reg_dly < BALA_RIGHT + 3       and v_cntr_reg_dly > BALA_TOP - 3       and v_cntr_reg_dly < BALA_BOTTOM + 3)
                                        )) or
                                        
                                        -- Bloque "ATRAS"
                                        ((MENU_STATE_LED(3) = '1' or MENU_STATE_LED(2) = '1' or MENU_STATE_LED(1) = '1') and (
                                        (h_cntr_reg_dly > ATRAS_LEFT - 3 and h_cntr_reg_dly < ATRAS_RIGHT + 3 and v_cntr_reg_dly > ATRAS_TOP - 3 and v_cntr_reg_dly < ATRAS_BOTTOM + 3)
                                        )) or
                                    
                                        -- Bloque "JUGAR"
                                        ((MENU_STATE_LED(3) = '1') and (
                                        (h_cntr_reg_dly > JUGAR_LEFT - 3 and h_cntr_reg_dly < JUGAR_RIGHT + 3 and v_cntr_reg_dly > JUGAR_TOP - 3 and v_cntr_reg_dly < JUGAR_BOTTOM + 3)
                                        )) or
                                    
                                        -- Bloques de Tiempo: CLÁSICO
                                        ((MENU_STATE_LED(3 downto 1) /= "000") and (MODE_CONFIG = "00" and (
                                        (h_cntr_reg_dly > TCLASICO1_LEFT - 3 and h_cntr_reg_dly < TCLASICO1_RIGHT + 3 and v_cntr_reg_dly > TCLASICO1_TOP - 3 and v_cntr_reg_dly < TCLASICO1_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TCLASICO2_LEFT - 3 and h_cntr_reg_dly < TCLASICO2_RIGHT + 3 and v_cntr_reg_dly > TCLASICO2_TOP - 3 and v_cntr_reg_dly < TCLASICO2_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TCLASICO3_LEFT - 3 and h_cntr_reg_dly < TCLASICO3_RIGHT + 3 and v_cntr_reg_dly > TCLASICO3_TOP - 3 and v_cntr_reg_dly < TCLASICO3_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TCLASICO4_LEFT - 3 and h_cntr_reg_dly < TCLASICO4_RIGHT + 3 and v_cntr_reg_dly > TCLASICO4_TOP - 3 and v_cntr_reg_dly < TCLASICO4_BOTTOM + 3)
                                        ))) or
                                    
                                        -- Bloques de Tiempo: RÁPIDO
                                        ((MENU_STATE_LED(3 downto 1) /= "000") and (MODE_CONFIG = "01" and (
                                        (h_cntr_reg_dly > TRAPIDO1_LEFT - 3 and h_cntr_reg_dly < TRAPIDO1_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO1_TOP - 3 and v_cntr_reg_dly < TRAPIDO1_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TRAPIDO2_LEFT - 3 and h_cntr_reg_dly < TRAPIDO2_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO2_TOP - 3 and v_cntr_reg_dly < TRAPIDO2_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TRAPIDO3_LEFT - 3 and h_cntr_reg_dly < TRAPIDO3_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO3_TOP - 3 and v_cntr_reg_dly < TRAPIDO3_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TRAPIDO4_LEFT - 3 and h_cntr_reg_dly < TRAPIDO4_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO4_TOP - 3 and v_cntr_reg_dly < TRAPIDO4_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TRAPIDO5_LEFT - 3 and h_cntr_reg_dly < TRAPIDO5_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO5_TOP - 3 and v_cntr_reg_dly < TRAPIDO5_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TRAPIDO6_LEFT - 3 and h_cntr_reg_dly < TRAPIDO6_RIGHT + 3 and v_cntr_reg_dly > TRAPIDO6_TOP - 3 and v_cntr_reg_dly < TRAPIDO6_BOTTOM + 3)
                                        ))) or
                                    
                                        -- Bloques de Tiempo: RELÁMPAGO
                                        ((MENU_STATE_LED(3 downto 1) /= "000") and (MODE_CONFIG = "10" and (
                                        (h_cntr_reg_dly > TRELAMPAGO1_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO1_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO1_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO1_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TRELAMPAGO2_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO2_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO2_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO2_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TRELAMPAGO3_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO3_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO3_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO3_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TRELAMPAGO4_LEFT - 3 and h_cntr_reg_dly < TRELAMPAGO4_RIGHT + 3 and v_cntr_reg_dly > TRELAMPAGO4_TOP - 3 and v_cntr_reg_dly < TRELAMPAGO4_BOTTOM + 3)
                                        ))) or
                                    
                                        -- Bloques de Tiempo: BALA
                                        ((MENU_STATE_LED(3 downto 1) /= "000") and (MODE_CONFIG = "11" and (
                                        (h_cntr_reg_dly > TBALA1_LEFT - 3 and h_cntr_reg_dly < TBALA1_RIGHT + 3 and v_cntr_reg_dly > TBALA1_TOP - 3 and v_cntr_reg_dly < TBALA1_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TBALA2_LEFT - 3 and h_cntr_reg_dly < TBALA2_RIGHT + 3 and v_cntr_reg_dly > TBALA2_TOP - 3 and v_cntr_reg_dly < TBALA2_BOTTOM + 3)
                                        ))) or
                                    
                                        -- Bloques de Incremento: CLÁSICO
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (
                                        ((MODE_CONFIG = "00" or ((MODE_CONFIG = "10" or MODE_CONFIG = "01") and TIME_CONFIG = "000")) and (
                                        (h_cntr_reg_dly > ICLASICO1_LEFT - 3 and h_cntr_reg_dly < ICLASICO1_RIGHT + 3 and v_cntr_reg_dly > ICLASICO1_TOP - 3 and v_cntr_reg_dly < ICLASICO1_BOTTOM + 3)
                                        )))) or
                                    
                                        -- Bloques de Incremento: RÁPIDO
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (MODE_CONFIG = "01" and (
                                        TIME_CONFIG /= "000" and (
                                        (h_cntr_reg_dly > IRAPIDO4_LEFT - 3 and h_cntr_reg_dly < IRAPIDO4_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO4_TOP - 3 and v_cntr_reg_dly < IRAPIDO4_BOTTOM + 3) or
                                        (TIME_CONFIG /= "001" and (
                                        (h_cntr_reg_dly > IRAPIDO3_LEFT - 3 and h_cntr_reg_dly < IRAPIDO3_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO3_TOP - 3 and v_cntr_reg_dly < IRAPIDO3_BOTTOM + 3) or
                                        (h_cntr_reg_dly > IRAPIDO2_LEFT - 3 and h_cntr_reg_dly < IRAPIDO2_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO2_TOP - 3 and v_cntr_reg_dly < IRAPIDO2_BOTTOM + 3) or
                                        (TIME_CONFIG /= "010" and (
                                        (h_cntr_reg_dly > IRAPIDO1_LEFT - 3 and h_cntr_reg_dly < IRAPIDO1_RIGHT + 3 and v_cntr_reg_dly > IRAPIDO1_TOP - 3 and v_cntr_reg_dly < IRAPIDO1_BOTTOM + 3)
                                        )))
                                        )
                                        )))) or
                                    
                                        -- Bloques de Incremento: RELÁMPAGO
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (MODE_CONFIG = "10" and (
                                        TIME_CONFIG /= "000" and (
                                        (h_cntr_reg_dly > IRELAMPAGO4_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO4_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO4_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO4_BOTTOM + 3) or
                                        (TIME_CONFIG /= "010" and (
                                        (h_cntr_reg_dly > IRELAMPAGO1_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO1_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO1_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO1_BOTTOM + 3) or
                                        (h_cntr_reg_dly > IRELAMPAGO2_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO2_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO2_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO2_BOTTOM + 3) or
                                        (h_cntr_reg_dly > IRELAMPAGO3_LEFT - 3 and h_cntr_reg_dly < IRELAMPAGO3_RIGHT + 3 and v_cntr_reg_dly > IRELAMPAGO3_TOP - 3 and v_cntr_reg_dly < IRELAMPAGO3_BOTTOM + 3)
                                        ))
                                        ) 
                                        ))) or
                                    
                                        -- Bloques de Incremento: BALA
                                        ((MENU_STATE_LED(3 downto 2) /= "00") and (MODE_CONFIG = "11" and (
                                        (h_cntr_reg_dly > IBALA1_LEFT - 3 and h_cntr_reg_dly < IBALA1_RIGHT + 3 and v_cntr_reg_dly > IBALA1_TOP - 3 and v_cntr_reg_dly < IBALA1_BOTTOM + 3)
                                        ))) or
                                        
                                        -- Bloque "SI" y bloque "NO"
                                        ((MENU_STATE_LED(5) = '1') and (
                                        (h_cntr_reg_dly > SI_LEFT - 3 and h_cntr_reg_dly < SI_RIGHT + 3 and v_cntr_reg_dly > SI_TOP - 3 and v_cntr_reg_dly < SI_BOTTOM + 3) or
                                        (h_cntr_reg_dly > NO_LEFT - 3 and h_cntr_reg_dly < NO_RIGHT + 3 and v_cntr_reg_dly > NO_TOP - 3 and v_cntr_reg_dly < NO_BOTTOM + 3)
                                        ))
                                        )
               else
               
               -- Pintar rectángulo blanco que simula ventana de pausa durante una partida en progreso
               x"F" when
                                        -- Bloque de texto de la ventana emergente
                                        ((MENU_STATE_LED(5) = '1') and (
                                        (h_cntr_reg_dly > 610 and h_cntr_reg_dly < 1310 and v_cntr_reg_dly > VENTANA_TOP and v_cntr_reg_dly < 800)
                                        ))
               else
               
               -- Pintar rectángulos blancos que contienen las cuentas de los jugadores durante la partida
               x"F" when                ((MENU_STATE_LED(4) = '1') and (
                                        (h_cntr_reg_dly > 280  and h_cntr_reg_dly < 860  and v_cntr_reg_dly > 680 and v_cntr_reg_dly < 870) or
                                        (h_cntr_reg_dly > 1100 and h_cntr_reg_dly < 1680 and v_cntr_reg_dly > 680 and v_cntr_reg_dly < 870)
                                        ))
               else
               
               -- Painting a grey border around non-selectable blocks
               x"8" when                (-- Bloques del menú fijo (MODO, TIEMPO e INCREMENTO)
                                        ((MENU_STATE_LED(4) = '0' and MENU_STATE_LED(5) = '0') and (
                                        (h_cntr_reg_dly > MODO_LEFT - 3       and h_cntr_reg_dly < MODO_RIGHT + 3       and v_cntr_reg_dly > MODO_TOP - 3       and v_cntr_reg_dly < MODO_BOTTOM + 3) or
                                        (h_cntr_reg_dly > TIEMPO_LEFT - 3     and h_cntr_reg_dly < TIEMPO_RIGHT + 3     and v_cntr_reg_dly > TIEMPO_TOP - 3     and v_cntr_reg_dly < TIEMPO_BOTTOM + 3) or
                                        (h_cntr_reg_dly > INCREMENTO_LEFT - 3 and h_cntr_reg_dly < INCREMENTO_RIGHT + 3 and v_cntr_reg_dly > INCREMENTO_TOP - 3 and v_cntr_reg_dly < INCREMENTO_BOTTOM + 3)
                                        )) or
                                        
                                        -- Bloque "PIEZAS BLANCAS" y bloque "PIEZAS NEGRAS"
                                        ((MENU_STATE_LED(4) = '1') and (
                                        (h_cntr_reg_dly > BLANCAS_LEFT - 3 and h_cntr_reg_dly < BLANCAS_RIGHT + 3 and v_cntr_reg_dly > BLANCAS_TOP - 3 and v_cntr_reg_dly < BLANCAS_BOTTOM + 3) or
                                        (h_cntr_reg_dly > NEGRAS_LEFT - 3  and h_cntr_reg_dly < NEGRAS_RIGHT + 3  and v_cntr_reg_dly > NEGRAS_TOP - 3  and v_cntr_reg_dly < NEGRAS_BOTTOM + 3)
                                        )) or
                                        
                                        -- Bloque de texto de la ventana emergente
                                        ((MENU_STATE_LED(5) = '1') and (
                                        (h_cntr_reg_dly > 610 - 3 and h_cntr_reg_dly < 1310 + 3 and v_cntr_reg_dly > VENTANA_TOP - 3 and v_cntr_reg_dly < 800 + 3)
                                        )) or
                                        
                                        -- Bloques de los títulos
                                        ((MENU_STATE_LED(5) = '0') and
                                        (h_cntr_reg_dly > TITULO_LEFT - 3 and h_cntr_reg_dly < TITULO_RIGHT + 3 and v_cntr_reg_dly > TITULO_TOP - 3 and v_cntr_reg_dly < TITULO_BOTTOM + 3)
                                        ) or
                                        
                                        -- Bloques blancos que contienen las cuentas
                                        ((MENU_STATE_LED(4) = '1') and (
                                        (h_cntr_reg_dly > 280 - 3  and h_cntr_reg_dly < 860 + 3  and v_cntr_reg_dly > 680 - 3 and v_cntr_reg_dly < 870 + 3) or
                                        (h_cntr_reg_dly > 1100 - 3 and h_cntr_reg_dly < 1680 + 3 and v_cntr_reg_dly > 680 - 3 and v_cntr_reg_dly < 870 + 3)
                                        ))
                                        )
               else
               -- Colorbar will be on the backround
               bg_blue_dly;
                
------------------------------------------------------------
-- Turn Off VGA RBG Signals if outside of the active screen
-- Make a 4-bit AND logic with the R, G and B signals
------------------------------------------------------------
 vga_red_cmb   <=  vga_red and (active & active & active & active);
 vga_green_cmb <= vga_green and (active & active & active & active);
 vga_blue_cmb  <= vga_blue and (active & active & active & active);
 

 -- Register Outputs
  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then

      v_sync_reg_dly <= v_sync_reg;
      h_sync_reg_dly <= h_sync_reg;
      vga_red_reg    <= vga_red_cmb;
      vga_green_reg  <= vga_green_cmb;
      vga_blue_reg   <= vga_blue_cmb;      
    end if;
  end process;

  -- Assign outputs
  VGA_HS_O     <= h_sync_reg_dly;
  VGA_VS_O     <= v_sync_reg_dly;
  VGA_RED_O    <= vga_red_reg;
  VGA_GREEN_O  <= vga_green_reg;
  VGA_BLUE_O   <= vga_blue_reg;

end Behavioral;

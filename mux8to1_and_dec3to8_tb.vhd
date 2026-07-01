----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.06.2026 18:20:02
-- Design Name: 
-- Module Name: mux8to1_and_dec3to8_tb - Behavioral
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

entity mux8to1_and_dec3to8_tb is
--  Port ( );
end mux8to1_and_dec3to8_tb;

architecture Behavioral of mux8to1_and_dec3to8_tb is

    component dec3to8
        Port ( sel : in  STD_LOGIC_VECTOR (2 downto 0);
               an  : out STD_LOGIC_VECTOR (7 downto 0));
    end component;

    component mux8to1
        Port ( centesimas : in  STD_LOGIC_VECTOR (3 downto 0);
               decimas    : in  STD_LOGIC_VECTOR (3 downto 0);
               useg       : in  STD_LOGIC_VECTOR (3 downto 0);
               dseg       : in  STD_LOGIC_VECTOR (3 downto 0);
               uminutos   : in  STD_LOGIC_VECTOR (3 downto 0);
               dminutos   : in  STD_LOGIC_VECTOR (3 downto 0);
               uhoras     : in  STD_LOGIC_VECTOR (3 downto 0);
               dhoras     : in  STD_LOGIC_VECTOR (3 downto 0);
               sel        : in  STD_LOGIC_VECTOR (2 downto 0);
               hex        : out STD_LOGIC_VECTOR (3 downto 0));
    end component;
    
    signal centesimas : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal decimas    : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal useg       : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal dseg       : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal uminutos   : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal dminutos   : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal uhoras     : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal dhoras     : STD_LOGIC_VECTOR(3 downto 0) := "0000";

    signal sel        : STD_LOGIC_VECTOR(2 downto 0) := "000";

    signal an         : STD_LOGIC_VECTOR(7 downto 0);
    signal hex        : STD_LOGIC_VECTOR(3 downto 0);

begin

    -- Instanciación del Decodificador 3 a 8
    uut_dec: dec3to8
        PORT MAP (
            sel => sel,
            an  => an
        );

    -- Instanciación del Multiplexor 8 a 1
    uut_mux: mux8to1
        PORT MAP (
            centesimas => centesimas,
            decimas    => decimas,
            useg       => useg,
            dseg       => dseg,
            uminutos   => uminutos,
            dminutos   => dminutos,
            uhoras     => uhoras,
            dhoras     => dhoras,
            sel        => sel,
            hex        => hex
        );

    stim_proc: process
    begin
        -- Ejemplo: 1 Hora, 42 Minutos, 35 Segundos, 89 Centésimas
        dhoras     <= "0000";
        uhoras     <= "0001";
        dminutos   <= "0100";
        uminutos   <= "0010";
        dseg       <= "0011";
        useg       <= "0101";
        decimas    <= "1000";
        centesimas <= "1001";
        wait for 10 ns;
        
        sel <= "000"; wait for 10 ns;
        sel <= "001"; wait for 10 ns;
        sel <= "010"; wait for 10 ns;
        sel <= "011"; wait for 10 ns;
        sel <= "100"; wait for 10 ns;
        sel <= "101"; wait for 10 ns;
        sel <= "110"; wait for 10 ns;
        sel <= "111"; wait for 10 ns;
               
        wait;
    end process;
    
end Behavioral;

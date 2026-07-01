----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.06.2026 00:30:02
-- Design Name: 
-- Module Name: jugadas_counter_tb - Behavioral
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

entity jugadas_counter_tb is
--  Port ( );
end jugadas_counter_tb;

architecture Behavioral of jugadas_counter_tb is

component jugadas_counter
        Generic (
            module : integer;
            width  : integer
        );
        Port ( 
            clk   : in  STD_LOGIC;
            reset : in  STD_LOGIC;
            count : out STD_LOGIC_VECTOR (width-1 downto 0);
            ce    : in  STD_LOGIC;
            top   : out STD_LOGIC
        );
end component;
  
    constant TEST_MODULE : integer := 4;
    constant TEST_WIDTH  : integer := 3;

    signal clk   : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '0';
    signal ce    : STD_LOGIC := '0';
    signal count : STD_LOGIC_VECTOR (TEST_WIDTH-1 downto 0);
    signal top   : STD_LOGIC;

    constant CLK_PERIOD : time := 10 ns;  
    
begin

    uut: jugadas_counter
        generic map (
            module => TEST_MODULE,
            width  => TEST_WIDTH
        )
        port map (
            clk   => clk,
            reset => reset,
            count => count,
            ce    => ce,
            top   => top
        );

    clk_process : process
        begin
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end process;        
        
    stim_proc: process
    begin
        reset <= '1';
        ce    <= '0';
        wait for CLK_PERIOD * 2;
        reset <= '0';
        wait for CLK_PERIOD;

        ce <= '1';
        wait for CLK_PERIOD * 3;

        ce <= '0'; 
        wait for CLK_PERIOD * 3; 

        ce <= '1'; wait for CLK_PERIOD * 2;
        ce <= '0'; 
        wait for CLK_PERIOD * 3;

        ce <= '1'; wait for CLK_PERIOD * 2;
        ce <= '0'; 
        wait for CLK_PERIOD * 3;

        ce <= '1'; wait for CLK_PERIOD * 2;
        ce <= '0'; 
        wait for CLK_PERIOD * 3;
        
        ce <= '1'; wait for CLK_PERIOD * 2;
        ce <= '0'; -- Cae ce -> Q = 1
        wait for CLK_PERIOD * 2;
        
        reset <= '1'; 
        wait for CLK_PERIOD * 2;
        reset <= '0'; 

        wait;
    end process;
end Behavioral;

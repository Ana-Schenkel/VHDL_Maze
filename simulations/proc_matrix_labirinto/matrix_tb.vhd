library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity matrix_tb is
end matrix_tb;

architecture Behavioral of matrix_tb is

component proc_matrix is
	 port (
--		ascii_char 	: out std_logic_vector (7 downto 0);
		key_pulse	: in std_logic;
		key_press	: in integer;
		line_0		: out string(1 to 16);
		line_1		: out string(1 to 16)
	);
end component;

signal key_press 	: integer;
signal key_pulse 	: std_logic;
signal line_0		: string(1 to 16);
signal line_1		: string(1 to 16);
--signal ascii_char : std_logic_vector (7 downto 0);

begin

matrix_dut : proc_matrix 
port map (
--      ascii_char => ascii_char,
		key_press => key_press,
		key_pulse => key_pulse,
		line_0 => line_0,
		line_1 => line_1
		);
   
	
-- Clock process definitions
clock_process :process
begin
     key_pulse <= '0';
     wait for 2 ns;
     key_pulse <= '1';
     wait for 2 ns;
end process;


-- Stimulus process
stim_proc: process
begin        

	key_press <= 5; -- test start e game over
	wait for 30 ns;
	key_press <= 2;
	wait for 30 ns;
	key_press <= 4;
	wait for 30 ns;
	key_press <= 2;
	wait for 30 ns;
	
	key_press <= 5;
	wait for 30 ns;
	key_press <= 2;
	wait for 30 ns;
	key_press <= 4;
	wait for 30 ns;
	key_press <= 2;
	wait for 8 ns;
	key_press <= 3;
	wait for 30 ns;
	key_press <= 2;
	wait for 30 ns;
	key_press <= 4;
	wait for 30 ns;
	key_press <= 2;
	wait for 30 ns;
	key_press <= 3;
	wait for 30 ns;
	key_press <= 2;
	wait for 30 ns;
	
	
   wait;
end process;
end Behavioral;

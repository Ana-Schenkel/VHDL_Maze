library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity key_tb is
end key_tb;

architecture Behavioral of key_tb is

component key 
    Port ( 
				data : in  std_logic;   -- scan data from keyboard
				pclk : in  std_logic;   -- clock input for keyboard
				key_press   	: out std_logic;
				l1   : out std_logic;   -- data display
				l2   : out std_logic;
				l3   : out std_logic;
				l4   : out std_logic;
				l5   : out std_logic;
				l6   : out std_logic;
				l7   : out std_logic;
				l8   : out std_logic
     );
end component;

signal key_press, data, pclk, l1, l2, l3, l4, l5, l6, l7, l8 : std_logic;

begin
dut: key port map (key_press => key_press, pclk => pclk, data => data, l1 => l1, l2 => l2, l3 => l3, l4 => l4, l5 => l5, l6 => l6, l7 => l7, l8 => l8);
   
	
-- Clock process definitions
clock_process :process
begin
     pclk <= '0';
     wait for 5 ns;
     pclk <= '1';
     wait for 5 ns;
end process;


-- Stimulus process
stim_proc: process
begin        
   -- send E0 11100000
	
	data <= '0';
   wait for 11 ns;
	data <= '1';
   wait for 10 ns;
	data <= '1';
   wait for 10 ns;
	data <= '1';
   wait for 10 ns;
	data <= '0';
   wait for 10 ns;
	data <= '0';
   wait for 10 ns;
	data <= '0';
   wait for 10 ns;
	data <= '0';
   wait for 10 ns;
	data <= '0';
   wait for 10 ns;
	data <= '0';
   wait for 10 ns;
	data <= '1';
   wait for 10 ns;
	
	
	-- send F0 11110000
	data <= '0';
   wait for 10 ns;
	data <= '1';
   wait for 10 ns;
	data <= '1';
   wait for 10 ns;
	data <= '1';
   wait for 10 ns;
	data <= '1';
   wait for 10 ns;
	data <= '0';
   wait for 10 ns;
	data <= '0';
   wait for 10 ns;
	data <= '0';
   wait for 10 ns;
	data <= '0';
   wait for 10 ns;
	data <= '1';
   wait for 10 ns;
	data <= '1';
   wait for 10 ns;
	
	-- send 5A 01011010
	data <= '0';
   wait for 10 ns;
	data <= '0';
   wait for 10 ns;
	data <= '1';
   wait for 10 ns;
	data <= '0';
   wait for 10 ns;
	data <= '1';
   wait for 10 ns;
	data <= '1';
   wait for 10 ns;
	data <= '0';
   wait for 10 ns;
	data <= '1';
   wait for 10 ns;
	data <= '0';
   wait for 10 ns;
	data <= '1';
   wait for 10 ns;
	data <= '1';
   wait for 10 ns;
	
   wait;
end process;
end Behavioral;

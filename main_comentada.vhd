library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main is
  port (
	clk      	: in std_logic;
	ps2_clk  	: in std_logic;
	ps2_data 	: in std_logic;
	RS, RW   	: out bit;
	E        	: buffer bit;
	DB       	: out std_logic_vector(7 downto 0);
	leds		: out std_logic_vector (7 downto 0)
	 );
end main;

architecture Behavioral of main is  

	-- Components from each file that are connected to the main module
	component key is
	 port (
		data		: in std_logic;
		pclk		: in std_logic;
		clk		: in std_logic;
		key_pulse   	: out std_logic;
		key_press   	: out integer
	 );
	end component;

	component LCD is
	 port (
		line_0		: in string(1 to 16);
		line_1		: in string(1 to 16);
		clk		: in std_logic;
		RS, RW		: out bit;
		E		: buffer bit;
		DB		: out std_logic_vector(7 downto 0)
	 );
	end component;
  
	component proc_matrix is
	 port (
		clk	     	: in std_logic;
		key_pulse	: in std_logic;
		key_press	: in integer;
		line_0		: out string(1 to 16);
		line_1		: out string(1 to 16);
		game_level	: out integer
	);
	end component;

	-- Auxiliary signals for the connection between proc_matrix.vhd and LCD.vhd
	signal key_press 	: integer;
	signal key_pulse 	: std_logic;
	signal line_0		: string(1 to 16) :=  "                ";
	signal line_1		: string(1 to 16) :=  "                ";
	
	-- Signals for the LEDs logic
	signal game_level	: integer; -- Output from the proc_matrix.vhd file
	signal leds_s		: std_logic_vector (7 downto 0);
	signal counter		: integer range 0 to 49_999_999 := 0;
	signal flash_leds_s : std_logic := '0';
	
begin

-- DUT of KEY
  key_dut : key port map (
      		data => ps2_data,
      		pclk => ps2_clk,
		clk => clk,
      		key_press => key_press,
		key_pulse => key_pulse
    );
	 
-- DUT of proc_matrix      
  matrix_dut : proc_matrix port map (
      		clk => clk,
		key_press => key_press,
		key_pulse => key_pulse,
		line_0 => line_0,
		line_1 => line_1,
		game_level => game_level
    );

-- DUT of LCD      
  lcd_dut : LCD port map (
      		line_0 => line_0,
		line_1 => line_1,
		clk => clk,
      		RS => RS,
      		RW => RW,
      		E  => E,
      		DB => DB
    );
	 
leds <= leds_s;

  -- Process to handle LED sequence for each game mode (lose, win, levels 1, 2, and 3)
	 
process(clk)
begin
	if rising_edge(clk) then
		case game_level is -- leds sequence for game levels
		when 2 =>
		leds_s <= "00000001";
		when 3 =>
		leds_s <= "00000011";
		when 4 => 
		leds_s <= "00000111";
		when 5 =>
		if counter = 49_999_999 then -- winning mode
			counter <= 0;
			flash_leds_s <= not flash_leds_s;
		else
			counter <= counter + 1;
		end if;
		if flash_leds_s = '1' then
			leds_s <= "10101010";
		else
			leds_s <= "01010101";
		end if;
		when others => -- losing mode
		leds_s <= "00000000";
		counter <= 0;
		flash_leds_s <='0';
		end case;
	end if;
end process;

end Behavioral; 

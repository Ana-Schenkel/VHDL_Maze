library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main is
  port (
    clk      	: in std_logic; -- System clock (from FPGA)
    ps2_clk  	: in std_logic; -- PS/2 clock signal from keyboard
    ps2_data 	: in std_logic; -- PS/2 data signal from keyboard
    RS, RW   	: out bit; 	-- LCD control signals: RS (Register Select), RW (Read/Write) 
    E        	: buffer bit;	-- LCD Enable signal
    DB       	: out std_logic_vector(7 downto 0); 	-- LCD data bus (8-bit)
    leds			: out std_logic_vector (7 downto 0) -- Debug or status LEDs (optional usage)
	 );
end main;

architecture Behavioral of main is  

	-- Componentes
	component key is
	 port (
		data			: in std_logic;		-- Serial data line from PS/2 keyboard
		pclk			: in std_logic;		-- PS/2 clock signal (from keyboard)
		clk			: in std_logic;		-- System clock (used for internal processing)
		key_pulse   		: out std_logic;	-- Pulse indicating a new key press (1 clock cycle)
		key_press   		: out integer		-- Identifier of the pressed key
	 );
	end component;

	component LCD is
	 port (
		line_0		: in string(1 to 16);			-- Text to display on the first LCD line (16 characters max)
       		line_1		: in string(1 to 16);			-- Text to display on the second LCD line (16 characters max)
		clk		: in std_logic;				-- System clock for internal timing/state control
		RS, RW		: out bit;				-- LCD control lines: RS (Register Select), RW (Read/Write)
		E		: buffer bit;				-- LCD Enable signal
		DB		: out std_logic_vector(7 downto 0)	-- 8-bit data bus to send commands and characters to the LCD
	 );
	end component;

  
	component proc_matrix is
	 port (
		clk	     	: in std_logic;		-- System clock for synchronous operations
		key_pulse	: in std_logic;		-- Pulse indicating a new key press (1 clock cycle)
		key_press	: in integer;		-- Identifier of the pressed key
		line_0		: out string(1 to 16);	-- Output string for the first line of the LCD
        	line_1		: out string(1 to 16);	-- Output string for the second line of the LCD
		game_level	: out integer		-- Current game level and state identifier
	);
	end component;

	-- Signals to link components
	signal key_press 	: integer;					-- Holds the code of the most recently pressed key
	signal key_pulse 	: std_logic;					-- Pulse signal (1 clock cycle) when a new key is detected
	signal line_0		: string(1 to 16) :=  "                ";	-- Text for the first LCD line (initialized as blank)
    	signal line_1		: string(1 to 16) :=  "                ";	-- Text for the second LCD line (initialized as blank)
	signal game_level	: integer;					-- Current game level and state

	-- Signals for the LEDs logic
	signal leds_s		: std_logic_vector (7 downto 0);		-- Internal signal for LED output
	signal counter		: integer range 0 to 49_999_999 := 0;		-- Counter used for timing purposes
	signal flash_leds_s : std_logic := '0';					-- Toggles to create a flashing LED effect

begin

-- DUT of KEY
  key_dut : key port map (
      	data => ps2_data,			-- Connects to PS/2 keyboard data line
      	pclk => ps2_clk,			-- Connects to PS/2 keyboard clock line
	clk => clk,				-- System clock for internal processing
      	key_press => key_press, 		-- Outputs the decoded key code
	key_pulse => key_pulse			-- One-cycle pulse indicating a new key was received
    );

-- DUT of proc_matrix      
  matrix_dut : proc_matrix port map (
      	clk => clk,				-- System clock
	key_press => key_press,			-- Key code input from keyboard module
	key_pulse => key_pulse,			-- One-cycle pulse indicating a new key input
	line_0 => line_0,			-- Output string for LCD line 0
	line_1 => line_1,			-- Output string for LCD line 1
	game_level => game_level		-- Current game level and state
    );

-- DUT of LCD      
  lcd_dut : LCD port map (
      	line_0 => line_0,			-- Input string for the first line of the LCD
	line_1 => line_1,			-- Input string for the second line of the LCD
	clk => clk,				-- System clock for internal FSM
      	RS => RS,				-- LCD Register Select control signal
      	RW => RW,				-- LCD Read/Write control signal
      	E  => E,				-- LCD Enable signal
      	DB => DB				-- LCD data bus (8-bit)
    );
	 
leds <= leds_s;	-- Drive output LEDs from internal control signal

process(clk)
begin
	if rising_edge(clk) then
		case game_level is
        -- Level 1: Turn on only the first LED
		when 2 =>
		leds_s <= "00000001";
        
        -- Level 2: Turn on the first two LEDs
		when 3 =>
		leds_s <= "00000011";
        
        -- Level 3: Turn on the first three LEDs
		when 4 => 
		leds_s <= "00000111";
        
        -- Winning State: Flash LEDs in a alternating pattern using a counter as a timer
		when 5 =>
		if counter = 49_999_999 then
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
          
        -- Default case: all LEDs off and reset timer state
		when others =>
		leds_s <= "00000000";
		counter <= 0;
		flash_leds_s <='0';
		end case;
	end if;
end process;

end Behavioral; 

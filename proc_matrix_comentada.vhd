library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity proc_matrix is
  
  port (
		clk		     	    : in std_logic;	-- System clock for synchronous operations
		key_pulse     	: in std_logic;	-- Pulse indicating a new key press (1 clock cycle)
		key_press   	  : in integer;	-- Identifier of the pressed key
		line_0			    : out string(1 to 16);	-- Output string for the first line of the LCD
		line_1			    : out string(1 to 16);	-- Output string for the second line of the LCD
		game_level		  : out integer			-- Current game level and state identifier
  );

end proc_matrix;

architecture Behavioral of proc_matrix is  

	signal cursor_x_s 		: integer range 1 to 16 := 1;	-- Cursor column position (1 to 16)
  signal cursor_y_s 		: std_logic  := '0';			-- Cursor row (0 for line_0, 1 for line_1)

-- Reference matrix
	signal line_0_ref_s		: string(1 to 16) := "  |       | * X ";
	signal line_1_ref_s		: string(1 to 16) := "    X|  X   |   ";

-- Static user-facing welcome screen
	signal line_0_user		: string(1 to 16) := " Press Space To ";
	signal line_1_user		: string(1 to 16) := "     Start      ";

-- Internal buffer for line display
	signal line_0_control	: string(1 to 16) := " Press Space To ";
	signal line_1_control	: string(1 to 16) := "     Start      ";

	signal game_state_s 		: integer range 0 to 5 := 1;	-- Tracks current state of the game

begin

-- Assign internal control buffer to output lines
	line_0 <= line_0_control;
	line_1 <= line_1_control;

-- Assign current game state to output game_level
	game_level <= game_state_s;

process (clk)
begin
	if rising_edge(clk) then
		
		case game_state_s is
		when 0 =>			-- Game Over state
		line_0_control	<= "   Game Over    ";
		line_1_control	<= "                ";
        
		when 1 =>			-- Initial screen
		line_0_control	<= " Press Space To ";
		line_1_control	<= "     Start      ";
        
		when 5 =>			-- Victory screen
		line_0_control	<= "    You Win     ";
		line_1_control	<= "                ";
        
		when others =>		-- Default
		line_0_control <= line_0_user;
		line_1_control <= line_1_user;
		end case;
	end if;
end process;

process (key_pulse)

-- Local variables for cursor position
	variable cursor_x 		: integer range 1 to 16 := 1;
	variable cursor_y 		: std_logic  := '0';

-- Local copies of current reference map for each level
	variable line_0_ref		: string(1 to 16) := "  |       | * X ";
	variable line_1_ref		: string(1 to 16) := "    X|  X   |   ";

-- Local game state tracker
	variable game_state 		: integer range 0 to 5 := 1;

begin

	if falling_edge(key_pulse) then
    
	-- Load current state from signals into local variables
		cursor_x := cursor_x_s;
		cursor_y := cursor_y_s;
		line_0_ref := line_0_ref_s;
		line_1_ref := line_1_ref_s;
		game_state := game_state_s;

	case game_state is
	
	-- Game Over screen
	when 0 =>
		if key_press = 5 then
			game_state := 1; -- Restart from beginning when the space key is pressed
		end if;
	
	-- Initial screen: wait for spacebar to start the game
	when 1 =>
		if key_press = 5 then
			line_0_user	<= "_ |       | * X ";
			line_1_user	<= "    X|  X   |   ";
			cursor_x := 1;
			cursor_y := '0';
			game_state := 2;
		end if;
	
	-- Victory screen
	when 5 =>
		if key_press = 5 then
			game_state := 1; -- Restart from beginning when the space key is pressed
		end if;
		
	-- Main gameplay logic
	
	when others =>
		
		case key_press is
		
			when 1 => -- Move left
				if cursor_x > 1 then
					if cursor_y = '0' then
						if line_0_user(cursor_x - 1) /= '|' then
							cursor_x := cursor_x - 1;
						end if;
					else
						if line_1_user(cursor_x - 1) /= '|' then
							cursor_x := cursor_x - 1;
						end if;
					end if;
				end if;
			
			when 2 => -- Move right
				if cursor_x < 16 then
					if cursor_y = '0' then
						if line_0_user(cursor_x + 1) /= '|' then
							cursor_x := cursor_x + 1;
						end if;
					else
						if line_1_user(cursor_x + 1) /= '|' then
							cursor_x := cursor_x + 1;
						end if;
					end if;
				end if;
			
			when 3 => -- Move up
				if cursor_y = '1' then
					if line_0_user(cursor_x) /= '|' then
						cursor_y := '0';
					end if;
				end if;
			
			when 4 => -- Move down
				if cursor_y = '0' then
					if line_1_user(cursor_x) /= '|' then
						cursor_y := '1';
					end if;
				end if;
				 
			when others =>
				game_state := game_state_s;
		end case;
	  	
    -- Check for collision on the fist row
		if cursor_y = '0' then
        -- Hit a trap, game over
			if line_0_user(cursor_x) = 'X' then
				game_state := 0;
			end if;
        -- Reached goal, go to next level
			if line_0_user(cursor_x) = '*' then
				game_state := game_state + 1;
			end if;
    -- Check for collision on the second row
		else
      -- Hit a trap, game over
			if line_1_user(cursor_x) = 'X' then
				game_state := 0;
			end if;
      -- Reached goal, go to next level
			if line_1_user(cursor_x) = '*' then
				game_state := game_state + 1;
			end if;
		end if;
		
    -- Load reference map for next level if advanced
		if game_state = 2 then
			line_0_ref := "  |       | * X ";
			line_1_ref := "    X|  X   |   ";
		end if;
		if game_state = 3 then
			line_0_ref := "*|   X    ||   |";
			line_1_ref := "   X   |X     ||";
		end if;
		if game_state = 4 then
			line_0_ref := " XX   X    XX *|";
			line_1_ref := "    X   XX    X|";
		end if;
		
    -- Update visible user map with new reference
		line_0_user <= line_0_ref;
		line_1_user <= line_1_ref;

		-- Place cursor on updated map
		if cursor_y = '0' then
			line_0_user(cursor_x) <= '_';
		else
			line_1_user(cursor_x) <= '_';
		end if;
	
	end case;
    
    -- Commit all local variable updates to output signals
	cursor_x_s <= cursor_x;
	cursor_y_s <= cursor_y;
	line_0_ref_s <= line_0_ref;
	line_1_ref_s <= line_1_ref;
	game_state_s <= game_state;

	end if;
	
end process;

end Behavioral;

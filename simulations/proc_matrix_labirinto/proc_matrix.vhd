library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity proc_matrix is
  
  generic(
		line_0_ref		: string(1 to 16) := "  |       | * X ";
		line_1_ref		: string(1 to 16) := "    X|  X   |   "
	);
  
  port (
		key_pulse     	: in std_logic;
		key_press   	: in integer;
		line_0			: out string(1 to 16);
		line_1			: out string(1 to 16)
  );

end proc_matrix;

architecture Behavioral of proc_matrix is  

	signal cursor_x_s 	: integer range 1 to 16 := 1;
   signal cursor_y_s 	: std_logic  := '0';
	
	signal line_0_user	: string(1 to 16) := "                ";
	signal line_1_user	: string(1 to 16) := "                ";

	signal game_state_s 	: integer range 0 to 4 := 1;

begin

line_0 <= line_0_user;
line_1 <= line_1_user;


process (key_pulse)

variable cursor_x 		: integer range 1 to 16 := 1;
variable cursor_y 		: std_logic  := '0';

variable game_state 		: integer range 0 to 4 := 1;

begin

	if falling_edge(key_pulse) then
	
		cursor_x := cursor_x_s;
		cursor_y := cursor_y_s;
		
		game_state := game_state_s;

	case game_state is
	
	
	-- Derrota do usuário
	when 0 =>
	
		if key_press = 5 then
			line_0_user	<= " Press Space To ";
			line_1_user	<= "     Start      ";
			game_state := 1;
		else
			line_0_user	<= "   Game Over    ";
			line_1_user	<= "                ";
		end if;
	
	
	-- Início do jogo
	when 1 =>
		if key_press = 5 then
			line_0_user	<= "_ |       | * X ";
			line_1_user	<= "    X|  X   |   ";
			cursor_x := 1;
			cursor_y := '0';
			game_state := 2;
		else
			line_0_user	<= " Press Space To ";
			line_1_user	<= "     Start      ";
		end if;
	
	when 2 =>
		
		case key_press is
		
			when 1 => -- esquerda
				
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
			
			when 2 => -- direita
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
			
			when 3 => -- cima
				if cursor_y = '1' then
					if line_0_user(cursor_x) /= '|' then
						cursor_y := '0';
						line_1_user(cursor_x) <= ' ';
					end if;
				end if;
			
			when 4 => -- baixo
				if cursor_y = '0' then
					if line_1_user(cursor_x) /= '|' then
						cursor_y := '1';
						line_0_user(cursor_x) <= ' ';
					end if;
				end if;
				 
			when others =>
				cursor_x := 1;
				cursor_y := '0';
		end case;
	  
		if cursor_y = '0' then
			if line_0_user(cursor_x) = 'X' then
				game_state := 0;
			end if;
			if line_0_user(cursor_x) = '*' then
				game_state := game_state + 1;
			end if;
		else
			if line_1_user(cursor_x) = 'X' then
				game_state := 0;
			end if;
			if line_1_user(cursor_x) = '*' then
				game_state := game_state + 1;
			end if;
			
		end if;
		
		
		for i in 1 to 16 loop
			if i = cursor_x then
				if cursor_y = '0' then
					line_0_user(i) <= '_';
				else
					line_1_user(i) <= '_';
				end if;
			else
				line_0_user(i) <= line_0_ref(i);
				line_1_user(i) <= line_1_ref(i);
			end if;
		end loop;
	
	-- Vitória do usuário
	when 3 =>
	
		if key_press = 5 then
			line_0_user	<= " Press Space To ";
			line_1_user	<= "     Start      ";
			cursor_x := 1;
			cursor_y := '0';
			game_state := 1;
		else
			line_0_user	<= "    You Win     ";
			line_1_user	<= "                ";
		end if;
	
	when others =>
		cursor_x := 1;
		cursor_y := '0';
	
	end case;
		
	cursor_x_s <= cursor_x;
	cursor_y_s <= cursor_y;
	
	game_state_s <= game_state;

	end if;
	
end process;

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity proc_matrix is
  
  generic(
		line_0_ref		: string(1 to 16) := "1B11B101B10112B1"; 	-- Matriz de referência
		line_1_ref		: string(1 to 16) := "111111011101B211";
		
		line_0_win		: string(1 to 16) := "1P11P101P10112P1"; 	-- Matriz que o usuário deve chegar para ganhar
		line_1_win		: string(1 to 16) := "111111011101P211"
	);
  
  port (
		key_pulse     	: in std_logic;									-- Evento de uma tecla pressionada
		key_press   	: in integer;										-- Valor da tecla pressionada
		line_0			: out string(1 to 16);							-- Primeira linha do LCD
		line_1			: out string(1 to 16)							-- Segunda linha do LCD
  );

end proc_matrix;

architecture Behavioral of proc_matrix is  

	-- Sinal que decide o estado do jogo (início, ativo, derrota, vitória)
	signal game_state 	: integer range 1 to 4 := 1;				
	
	-- Sinais que guardam a posição do cursor
	signal cursor_x_s 	: integer range 1 to 16 := 1;
   signal cursor_y_s 	: std_logic  := '0';
	
	-- Sinais que guardam a matriz do usuário, bandeiras, ícones revelados e etc
	signal line_0_user_s	: string(1 to 16) := " Press Enter To ";
	signal line_1_user_s	: string(1 to 16) := "     Start      ";

begin

-- LCD recebe a matriz do usuário
line_0 <= line_0_user_s;
line_1 <= line_1_user_s;


-- Process ativado sempre que uma tecla é pressionada
process (key_pulse)

-- Variáveis que alteram o cursor e a matriz do usuário conforme o jogo
variable cursor_x 		: integer range 1 to 16 := 1;
variable cursor_y 		: std_logic  := '0';
variable line_0_user		: string(1 to 16) := " Press Enter To ";
variable line_1_user		: string(1 to 16) := "     Start      ";

begin

	if falling_edge(key_pulse) then
	
	-- Variáveis, que podem gerar novas decisões em um mesmo pulso, recebem os valores armazenados nos sinais
	cursor_x := cursor_x_s;
	cursor_y := cursor_y_s;
	line_0_user	:= line_0_user_s;
	line_1_user	:= line_1_user_s;
		
	case game_state is
	
	-- Início do jogo
	when 1 =>
		if key_press = 6 then
			line_0_user	:= "_               ";
			line_1_user	:= "                ";
			cursor_x := 1;
			cursor_y := '0';
			game_state <= 2;
		else
			line_0_user	:= " Press Enter To ";
			line_1_user	:= "     Start      ";
		end if;
	
--------------------------------------------------- Lógica do Jogo ---------------------------------------------------
	
-- Jogo Ativo
	when 2 =>
	
-- Apaga o símbolo de cursor na posição anterior
		if cursor_y_s = '0' then
			if line_0_user(cursor_x_s) = 'p' then
				line_0_user(cursor_x_s) := 'P';
			else
				line_0_user(cursor_x_s) := ' ';
			end if;
		else
			if line_1_user(cursor_x_s) = 'p' then
				line_1_user(cursor_x_s) := 'P';
			else
				line_1_user(cursor_x_s) := ' ';
			end if;
		end if;
		
		case key_press is
		
-- Seta para a esquerda
			when 1 =>
			
				for i in 1 to 16 loop
					if (cursor_x - i) >= 1 then
						if cursor_y = '0' then
							if line_0_user(cursor_x - i) = ' ' or line_0_user(cursor_x - i) = 'P' then
								cursor_x := cursor_x - i;
								exit;
							end if;
						else
							if line_1_user(cursor_x - i) = ' ' or line_1_user(cursor_x - i) = 'P' then
								cursor_x := cursor_x - i;
								exit;
							end if;
						end if;
					end if;
				end loop;
				
-- Seta para a direita
			when 2 => 
				
				for i in 1 to 16 loop
					if (cursor_x + i) <= 16 then
						if cursor_y = '0' then
							if line_0_user(cursor_x + i) = ' ' or line_0_user(cursor_x + i) = 'P' then
								cursor_x := cursor_x + i;
								exit;
							end if;
						else
							if line_1_user(cursor_x + i) = ' ' or line_1_user(cursor_x + i) = 'P' then
								cursor_x := cursor_x + i;
								exit;
							end if;
						end if;
					end if;
				end loop;

-- Seta para cima
			when 3 =>
				
				if cursor_y = '1' then
					for i in 0 to 16 loop
						if (cursor_x + i) <= 16 then
							if line_0_user(cursor_x + i) = ' ' or line_0_user(cursor_x + i) = 'P' then
								cursor_x := cursor_x + i;
								cursor_y := '0';
								exit;
							end if;
						end if;
						if (cursor_x - i) >= 1 then
							if line_0_user(cursor_x - i) = ' ' or line_0_user(cursor_x - i) = 'P'then
								cursor_x := cursor_x - i;
								cursor_y := '0';
								exit;
							end if;
						end if;
					end loop;
				end if;
			
-- Seta para baixo
			when 4 =>
				
				if cursor_y = '0' then
					for i in 0 to 16 loop
						if (cursor_x + i) <= 16 then
							if line_1_user(cursor_x + i) = ' ' or line_1_user(cursor_x + i) = 'P' then
								cursor_x := cursor_x + i;
								cursor_y := '1';
								exit;
							end if;
						end if;
						if (cursor_x - i) >= 1 then
							if line_1_user(cursor_x - i) = ' ' or line_1_user(cursor_x - i) = 'P'then
								cursor_x := cursor_x - i;
								cursor_y := '1';
								exit;
							end if;
						end if;
					end loop;
				end if;
				
-- Tecla de espaço (ação para bandeira "P")
			when 5 =>
			
				if cursor_y = '0' then
					if line_0_user(cursor_x) = 'P' then
						line_0_user(cursor_x) := ' ';
					else
						line_0_user(cursor_x) := 'P';
					end if;
				else
					if line_1_user(cursor_x) = 'P' then
						line_1_user(cursor_x) := ' ';
					else
						line_1_user(cursor_x) := 'P';
					end if;
				end if;
			
-- Tecla Enter (ação para revelar um ícone)
			when 6 =>
			
				if cursor_y = '0' then						
					line_0_user(cursor_x) := line_0_ref(cursor_x);
					if line_0_ref(cursor_x) = 'B' then
						game_state <= 3;
					end if;
				else
					line_1_user(cursor_x) := line_1_ref(cursor_x);
					if line_1_ref(cursor_x) = 'B' then
						game_state <= 3;
					end if;
				end if;
				
				for i in 0 to 16 loop
					if (cursor_x + i) <= 16 then
						if line_0_user(cursor_x + i) = ' ' then
							cursor_x := cursor_x + i;
							cursor_y := '0';
							exit;
						end if;
						if line_1_user(cursor_x + i) = ' ' then
							cursor_x := cursor_x + i;
							cursor_y := '1';
							exit;
						end if;
					end if;
					if (cursor_x - i) >= 1 then
						if line_0_user(cursor_x - i) = ' ' then
							cursor_x := cursor_x - i;
							cursor_y := '0';
							exit;
						end if;
						if line_1_user(cursor_x - i) = ' ' then
							cursor_x := cursor_x - i;
							cursor_y := '1';
							exit;
						end if;
					end if;
				end loop;
				
-- Condicional impossível
			when others =>
				line_0_user	:= "ERRO            ";
				line_1_user	:= "                ";
		end case;

-- Verifica Vitória do usuário
		if line_0_user = line_0_win and line_1_user = line_1_win then
			game_state <= 4;
			line_0_user	:= "    You Win     ";
			line_1_user	:= "                ";
		end if;

-- Escreve o símbolo de cursor na posição nova
		if cursor_y = '0' then
			if line_0_user(cursor_x) = 'P' then
				line_0_user(cursor_x) := 'p';
			else
				line_0_user(cursor_x) := '_';
			end if;
		else
			if line_1_user(cursor_x) = 'P' then
				line_1_user(cursor_x) := 'p';
			else
				line_1_user(cursor_x) := '_';
			end if;
		end if;
---------------------------------------------------- Fim --------------------------------------------------------------
	
	-- Derrota do usuário
	when 3 =>
	
		if key_press = 6 then
			line_0_user	:= "_               ";
			line_1_user	:= "                ";
			cursor_x := 1;
			cursor_y := '0';
			game_state <= 2;
		else
			line_0_user	:= "   Game Over    ";
			line_1_user	:= "                ";
		end if;
	
	-- Vitória do usuário
	when 4 =>
	
		if key_press = 6 then
			line_0_user	:= "_               ";
			line_1_user	:= "                ";
			cursor_x := 1;
			cursor_y := '0';
			game_state <= 2;
		else
			line_0_user	:= "    You Win     ";
			line_1_user	:= "                ";
		end if;
	end case;
	
	-- Sinais guardam os valores alterados das variáveis de posição do cursor e matriz do usuário
	cursor_x_s <= cursor_x;							
	cursor_y_s <= cursor_y;
	line_0_user_s	<= line_0_user;				
	line_1_user_s	<= line_1_user;

	end if;
	
end process;

end Behavioral;

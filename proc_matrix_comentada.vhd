library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity proc_matrix is
  port (
    clk          : in std_logic;           -- System clock
    key_pulse    : in std_logic;           -- Pulse signaling a valid key press event
    key_press    : in integer;              -- Encoded key pressed (e.g. arrow keys, space)
    line_0       : out string(1 to 16);    -- Output string for first line of game display
    line_1       : out string(1 to 16);    -- Output string for second line of game display
    game_level   : out integer               -- Current game state or level indicator
  );
end proc_matrix;

architecture Behavioral of proc_matrix is

  -- Cursor position state variables
  signal cursor_x_s     : integer range 1 to 16 := 1;  -- Cursor horizontal position (1 to 16)
  signal cursor_y_s     : std_logic := '0';            -- Cursor vertical position ('0' = line 0, '1' = line 1)

  -- Reference game board strings (static layouts for different levels)
  signal line_0_ref_s   : string(1 to 16) := "  |       | * X ";
  signal line_1_ref_s   : string(1 to 16) := "    X|  X   |   ";

  -- User-visible game board strings (updated with cursor and game state)
  signal line_0_user    : string(1 to 16) := " Press Space To ";
  signal line_1_user    : string(1 to 16) := "     Start      ";

  -- Control signals for output lines (reflect current display)
  signal line_0_control : string(1 to 16) := " Press Space To ";
  signal line_1_control : string(1 to 16) := "     Start      ";

  -- Game state variable: 0=game over, 1=start screen, 2..4=levels, 5=win
  signal game_state_s   : integer range 0 to 5 := 1;

begin

  -- Output assignments
  line_0 <= line_0_control;
  line_1 <= line_1_control;
  game_level <= game_state_s;

  -- =============================
  -- Process 1: Update display text according to game state on clock edge
  -- =============================
  process(clk)
  begin
    if rising_edge(clk) then
      case game_state_s is
        when 0 =>  -- Game Over screen
          line_0_control <= "   Game Over    ";
          line_1_control <= "                ";
        when 1 =>  -- Start screen
          line_0_control <= " Press Space To ";
          line_1_control <= "     Start      ";
        when 5 =>  -- Win screen
          line_0_control <= "    You Win     ";
          line_1_control <= "                ";
        when others =>  -- Game in progress, show user board
          line_0_control <= line_0_user;
          line_1_control <= line_1_user;
      end case;
    end if;
  end process;

  -- =============================
  -- Process 2: Handle game logic on key press event
  -- =============================
  process(key_pulse)
    variable cursor_x     : integer range 1 to 16 := 1;
    variable cursor_y     : std_logic := '0';
    variable line_0_ref   : string(1 to 16) := "  |       | * X ";
    variable line_1_ref   : string(1 to 16) := "    X|  X   |   ";
    variable game_state   : integer range 0 to 5 := 1;
  begin
    if falling_edge(key_pulse) then
      -- Load current state into local variables
      cursor_x := cursor_x_s;
      cursor_y := cursor_y_s;
      line_0_ref := line_0_ref_s;
      line_1_ref := line_1_ref_s;
      game_state := game_state_s;

      case game_state is

        -- Game Over state
        when 0 =>
          if key_press = 5 then  -- Space key pressed, restart game
            line_0_user <= " Press Space To ";
            line_1_user <= "     Start      ";
            game_state := 1;
          else
            line_0_user <= "   Game Over    ";
            line_1_user <= "                ";
          end if;

        -- Start screen state
        when 1 =>
          if key_press = 5 then  -- Space key pressed, begin level 2
            line_0_user <= "_ |       | * X ";
            line_1_user <= "    X|  X   |   ";
            cursor_x := 1;
            cursor_y := '0';
            game_state := 2;
          else
            line_0_user <= " Press Space To ";
            line_1_user <= "     Start      ";
          end if;

        -- Win state
        when 5 =>
          if key_press = 5 then  -- Space key pressed, restart
            line_0_user <= " Press Space To ";
            line_1_user <= "     Start      ";
            cursor_x := 1;
            cursor_y := '0';
            game_state := 1;
          else
            line_0_user <= "    You Win     ";
            line_1_user <= "                ";
          end if;

        -- Game playing states (2,3,4)
        when others =>
          -- Process arrow key inputs
          case key_press is
            when 1 =>  -- Move cursor left
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

            when 2 =>  -- Move cursor right
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

            when 3 =>  -- Move cursor up
              if cursor_y = '1' then
                if line_0_user(cursor_x) /= '|' then
                  cursor_y := '0';
                end if;
              end if;

            when 4 =>  -- Move cursor down
              if cursor_y = '0' then
                if line_1_user(cursor_x) /= '|' then
                  cursor_y := '1';
                end if;
              end if;

            when others =>
              game_state := game_state; -- No change
          end case;

          -- Check game conditions for current cursor position
          if cursor_y = '0' then
            if line_0_user(cursor_x) = 'X' then
              game_state := 0;  -- Lose if stepped on X
            elsif line_0_user(cursor_x) = '*' then
              game_state := game_state + 1;  -- Progress to next level if stepped on *
            end if;
          else
            if line_1_user(cursor_x) = 'X' then
              game_state := 0;  -- Lose
            elsif line_1_user(cursor_x) = '*' then
              game_state := game_state + 1;  -- Next level
            end if;
          end if;

          -- Update the reference board depending on game state
          if game_state = 2 then
            line_0_ref := "  |       | * X ";
            line_1_ref := "    X|  X   |   ";
          elsif game_state = 3 then
            line_0_ref := "*|   X    ||   |";
            line_1_ref := "   X   |X     ||";
          elsif game_state = 4 then
            line_0_ref := " XX   X    XX *|";
            line_1_ref := "    X   XX    X|";
          end if;

          -- Update user board to show current game layout
          line_0_user <= line_0_ref;
          line_1_user <= line_1_ref;

          -- Mark cursor position on display with underscore '_'
          if cursor_y = '0' then
            line_0_user(cursor_x) <= '_';
          else
            line_1_user(cursor_x) <= '_';
          end if;

      end case;

      -- Save updated states back to signals
      cursor_x_s <= cursor_x;
      cursor_y_s <= cursor_y;
      line_0_ref_s <= line_0_ref;
      line_1_ref_s <= line_1_ref;
      game_state_s <= game_state;

    end if;
  end process;

end Behavioral;

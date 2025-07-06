library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LCD is
    generic (
        fclk : natural := 50_000_000  -- 50 MHz clock input
    );
    port (
        line_0    : in string(1 to 16);  -- First line of array (16 characters)
        line_1    : in string(1 to 16);  -- Second line of array (16 characters)
        clk       : in bit;              -- System clock
        RS, RW    : out bit;             -- LCD control signals: Register Select and Read/Write
        E         : buffer bit;          -- LCD Enable signal (toggled to latch commands)
        DB        : out std_logic_vector(7 downto 0)  -- 8-bit data bus for LCD
    );
end LCD;

architecture hardware of LCD is
    signal pr_state, nx_state : integer := 0;  -- FSM states: present and next
    signal pr_index, index    : integer := 1;  -- Index counters for line character position
begin

-- =========================================
-- Clock Divider: Generates a ~1kHz toggle
-- =========================================
-- Toggles the Enable signal (E) every 1ms (500Hz toggle), derived from 50 MHz input clock.
-- The Enable signal is used to trigger command execution in the LCD.
process (clk)
    variable count : natural range 0 to fclk/1000;
begin
    if (clk'event and clk = '1') then
        count := count + 1;
        if (count = fclk/1000) then
            E <= not E;
            count := 0;
        end if;
    end if;
end process;

-- =====================================
-- FSM Lower Section: Updates on E edge
-- =====================================
-- Updates state and character index on rising edge of E
-- This mimics the LCD's timing expectation: data is latched on E rising edge
process (E)
begin
    if (E'event and E = '1') then
        -- Optional reset logic could go here
        pr_state <= 0; 
		pr_index <= 0; 
        pr_state <= nx_state;
        pr_index <= index;
    end if;
end process;

-- ======================================
-- FSM Upper Section: LCD State Machine
-- ======================================
-- Sends initialization commands, then writes line_0 and line_1 to LCD
process (pr_state)
    variable ascii_char : std_logic_vector(7 downto 0);  -- Holds ASCII code of current char
begin
    case pr_state is

        when 0 =>  -- Function Set (8-bit, 2-line display)
            RS <= '0'; RW <= '0';
            DB <= "00111000";
            nx_state <= pr_state + 1;

        when 1 =>  -- Function Set (repeat to ensure LCD recognizes)
            RS <= '0'; RW <= '0';
            DB <= "00111000";
            nx_state <= pr_state + 1;

        when 2 =>  -- Clear Display
            RS <= '0'; RW <= '0';
            DB <= "00000001";
            nx_state <= pr_state + 1;

        when 3 =>  -- Display ON, Cursor OFF
            RS <= '0'; RW <= '0';
            DB <= "00001100";
            nx_state <= pr_state + 1;

        when 4 =>  -- Entry Mode Set (increment cursor)
            RS <= '0'; RW <= '0';
            DB <= "00000110";
            nx_state <= pr_state + 1;

        when 5 =>  -- Write a blank space (initial)
            RS <= '1'; RW <= '0';
            DB <= "00100000";  -- ASCII for space
            nx_state <= pr_state + 1;

        when 6 =>  -- Set DDRAM address to start of line 0
            RS <= '0'; RW <= '0';
            DB <= "10000000";  -- LCD command for Line 0, position 0
            nx_state <= pr_state + 1;
            index <= 0; -- Reset index to the first position (character)

        when 7 =>  -- Write characters to Line 0
            ascii_char := std_logic_vector(to_unsigned(character'pos(line_0(index)), 8));
            RS <= '1'; RW <= '0';
            DB <= ascii_char;
            index <= pr_index + 1; -- Changes to the next character of line_0
            nx_state <= 7;
            if pr_index = 15 then -- Stops writing line_0 and changes to the next state
                nx_state <= pr_state + 1;
            end if;

        when 8 =>  -- Set DDRAM address to start of line 1
            RS <= '0'; RW <= '0';
            DB <= "11000000";  -- LCD command for Line 1, position 0
            index <= 0; -- Reset index to the first position (character)
            nx_state <= pr_state + 1;

        when 9 =>  -- Write characters to Line 1
            ascii_char := std_logic_vector(to_unsigned(character'pos(line_1(index)), 8));
            RS <= '1'; RW <= '0';
            DB <= ascii_char;
            index <= pr_index + 1; -- Changes to the next character of line_0
            nx_state <= 9;
            if pr_index = 15 then -- Stops writing line_0 and changes to the next state
                nx_state <= pr_state + 1;
            end if;

        when 10 =>  -- Loop back to line 0
            RS <= '0'; RW <= '0';
            DB <= "10000000";  -- Reposition cursor to start of line 0
            nx_state <= 6;

        when others =>  -- Safety fallback
            nx_state <= 0;
    end case;
end process;

end architecture;

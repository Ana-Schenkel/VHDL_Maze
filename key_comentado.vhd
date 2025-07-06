library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity key is
    port(
        data         : in  std_logic;    -- Serial data input from keyboard (PS/2 data line)
        pclk         : in  std_logic;    -- PS/2 clock input from keyboard
        clk          : in  std_logic;    -- System clock
        key_pulse    : out std_logic;    -- Pulse output indicating that a valid key was detected
        key_press    : out integer       -- Encoded key output (1 to 5)
    );
end key;

architecture Behavioral of key is

    signal count_bit       : integer := 0;  -- Bit counter for PS/2 serial frame

    -- FSM shift registers for storing scan codes
    signal store0          : std_logic_vector(0 to 10) := (others => '0');  -- Full 11-bit frame
    signal store1          : std_logic_vector(0 to 7) := (others => '0');   -- Most recent 8-bit scan code
    signal store2          : std_logic_vector(0 to 7) := (others => '0');   -- Second-most recent scan code
    signal store3          : std_logic_vector(0 to 7) := (others => '0');   -- Third-most recent scan code

    signal key_press_s     : integer := 0;      -- Internal signal for encoded key output
    signal key_pulse_s     : std_logic := '0';  -- Internal signal for pulse output
    signal pulse_control   : std_logic := '0';  -- Flag to prevent repeated pulses for the same key
	 
begin

-- Map internal signals to output ports
key_press <= key_press_s;
key_pulse <= key_pulse_s;

-- =============================
-- Process 1: PS/2 bit reception
-- =============================
-- Captures bits on the falling edge of the keyboard clock (pclk)
-- Assembles 11-bit PS/2 frame: start bit, 8 data bits, parity, stop bit
process(pclk)
    variable num_bit : integer := count_bit;
begin
    if falling_edge(pclk) then
        store0(num_bit) <= data;           -- Shift in bit from keyboard into store0
        num_bit := num_bit + 1;

        if num_bit > 10 then               -- After 11 bits received (full PS/2 frame)
            -- Optional validation of start/stop bits could be added here
            store3 <= store2;              -- Shift previous scan codes
            store2 <= store1;
            store1 <= store0(1 to 8);      -- Extract 8-bit data field (scan code)
            num_bit := 0;                  -- Reset bit counter
        end if;

        count_bit <= num_bit;
    end if;
end process;

-- =====================================
-- Process 2: Key recognition and coding
-- =====================================
-- Runs on system clock, analyzes received scan codes
-- Detects break codes and maps certain keys to numeric codes
process(clk)
begin
    if falling_edge(clk) then

        -- Reset pulse after it has been triggered
        if pulse_control = '1' then
            key_pulse_s <= '0';
        end if;

        -- Check if current scan code (store2) is a break code (F0h = "00001111")
        if store2 = "00001111" then
            if pulse_control = '0' then    -- Only process if not already triggered

                case store3 is             -- Check the scan code before F0 (store3)

                    when "10010100" =>     -- Space key (29h)
                        key_press_s <= 5;
                        key_pulse_s <= '1';
                        pulse_control <= '1';

                    when "00000111" =>     -- Extended key prefix (E0h)
                        case store1 is     -- Next byte after E0-F0 is the actual key code

                            when "01001110" =>  -- Down arrow (72h)
                                key_press_s <= 4;
                                key_pulse_s <= '1';
                                pulse_control <= '1';

                            when "10101110" =>  -- Up arrow (75h)
                                key_press_s <= 3;
                                key_pulse_s <= '1';
                                pulse_control <= '1';

                            when "00101110" =>  -- Right arrow (74h)
                                key_press_s <= 2;
                                key_pulse_s <= '1';
                                pulse_control <= '1';

                            when "11010110" =>  -- Left arrow (6Bh)
                                key_press_s <= 1;
                                key_pulse_s <= '1';
                                pulse_control <= '1';

                            when others =>
                                key_pulse_s <= '0'; -- Unrecognized key
                        end case;

                    when others =>
                        key_pulse_s <= '0';     -- Ignore other break codes
                end case;
            end if;
        else
            pulse_control <= '0'; -- Reset control flag if not in break state
        end if;
    end if;
end process;

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
 
entity key is
    port(
        data 			: in  std_logic;   -- scan data from keyboard
        pclk 			: in  std_logic;   -- clock input for keyboard
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
end key;
 
architecture Behavioral of key is

    signal count_bit 	: integer := 0;
	 signal enter_press 	: std_logic := '0';
	 signal store0    	: std_logic_vector(0 to 10) := (others => '0');
	 signal store1    	: std_logic_vector(0 to 7) := (others => '0');
	 signal store2    	: std_logic_vector(0 to 7) := (others => '0');
	 signal store3    	: std_logic_vector(0 to 7) := (others => '0');
	 
begin

key_press <= enter_press;

l1 <= store1(0);
l2 <= store1(1);
l3 <= store1(2);
l4 <= store1(3);
l5 <= store1(4);
l6 <= store1(5);
l7 <= store1(6);
l8 <= store1(7);


-- Processo 1: Em cada borda de descida de pclk, captura um bit de `data`
process(pclk)
 
variable num_bit : integer := count_bit;
 
begin
	  if falling_edge(pclk) then
	  
			store0(num_bit) <= data;
			
			num_bit := num_bit + 1;
			
			if num_bit > 10 then
--				if store0(0) = '0' and store(10) = '1' then
				store3 <= store2;
				store2 <= store1;
				store1 <= store0(1 to 8);
				num_bit := 0;
--				end if;
			end if;
			
			count_bit <= num_bit;
			
	  end if;
end process;

-- Processo 2: Em cada borda de descida de pclk, analisa os dados
process(pclk)
 
begin

	  if falling_edge(pclk) then
	  
			if store2 = "11110000" then
			
				case store3 is
				
				when "11100000" =>
				
					case store1 is
					
					when "01011010" =>
						enter_press <= '1';
					
					when others =>
						enter_press <= '0';
					end case;
					
				when others =>
					enter_press <= '0';
				end case;
			end if;
	  end if;
end process;
 
end Behavioral;

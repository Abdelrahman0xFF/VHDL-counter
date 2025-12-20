library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- This code contains some issues due to bouncing issue of mechanical switches 

entity counter is
    Port ( 
        clk       : in  STD_LOGIC;               
        reset     : in  STD_LOGIC;            
        btn_inc   : in  STD_LOGIC;           
        btn_dec   : in  STD_LOGIC;                 
        segments  : out STD_LOGIC_VECTOR(6 downto 0);
	T         : out STD_LOGIC
    );
end counter;

architecture Behavioral of counter is
    signal count_reg : integer range 0 to 9 := 0;
    signal inc_prev : std_logic := '1';
    signal dec_prev : std_logic := '1';
begin
    process(clk)
    begin
	T <= '0';
        if falling_edge(clk) then
            if reset = '0' then
                count_reg <= 0;
            else
                if (btn_inc = '0' and inc_prev = '1') then
                    if count_reg = 9 then
                        count_reg <= 0;
                    else
                        count_reg <= count_reg + 1;
                    end if;
                elsif (btn_dec = '0' and dec_prev = '1') then
                    if count_reg = 0 then
                        count_reg <= 9;
                    else
                        count_reg <= count_reg - 1;
                    end if;
                end if;
                inc_prev <= btn_inc;
                dec_prev <= btn_dec;
                
            end if;
        end if;
    end process;

    process(count_reg)
    begin
        case count_reg is
            when 0 => segments <= "1000000"; -- 0
            when 1 => segments <= "1111001"; -- 1
            when 2 => segments <= "0100100"; -- 2
            when 3 => segments <= "0110000"; -- 3
            when 4 => segments <= "0011001"; -- 4
            when 5 => segments <= "0010010"; -- 5
            when 6 => segments <= "0000010"; -- 6
            when 7 => segments <= "1111000"; -- 7
            when 8 => segments <= "0000000"; -- 8
            when 9 => segments <= "0010000"; -- 9
            when others => segments <= "1000000"; -- Off/Error
        end case;
    end process;

end Behavioral;
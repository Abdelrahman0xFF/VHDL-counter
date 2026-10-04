library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- This code contains solves the bouncing issue of mechanical switches 

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

    -------------------------------
    -- Debounce signals
    -------------------------------
    signal inc_sync1, inc_sync2 : std_logic := '1';
    signal dec_sync1, dec_sync2 : std_logic := '1';

    signal inc_stable : std_logic := '1';
    signal dec_stable : std_logic := '1';

    constant DEBOUNCE_MAX : integer := 500000; -- ~10ms @ 50MHz
    signal inc_cnt : integer range 0 to DEBOUNCE_MAX := 0;
    signal dec_cnt : integer range 0 to DEBOUNCE_MAX := 0;

begin

    T <= '0';

    ---------------------------------------------------
    -- 1) Synchronize button inputs
    ---------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            inc_sync1 <= btn_inc;
            inc_sync2 <= inc_sync1;

            dec_sync1 <= btn_dec;
            dec_sync2 <= dec_sync1;
        end if;
    end process;

    ---------------------------------------------------
    -- 2) Debounce logic using counters
    ---------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then

            -- INC button
            if inc_sync2 = inc_stable then
                inc_cnt <= 0;  -- no change
            else
                if inc_cnt = DEBOUNCE_MAX then
                    inc_stable <= inc_sync2; -- accept new stable value
                    inc_cnt <= 0;
                else
                    inc_cnt <= inc_cnt + 1;
                end if;
            end if;

            -- DEC button
            if dec_sync2 = dec_stable then
                dec_cnt <= 0;
            else
                if dec_cnt = DEBOUNCE_MAX then
                    dec_stable <= dec_sync2;
                    dec_cnt <= 0;
                else
                    dec_cnt <= dec_cnt + 1;
                end if;
            end if;

        end if;
    end process;

    ---------------------------------------------------
    -- 3) Edge detection (clean, debounced)
    ---------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then

            inc_prev <= inc_stable;
            dec_prev <= dec_stable;

            if reset = '0' then
                count_reg <= 0;

            else
                -- increment on falling edge (pressed)
                if (inc_stable = '0' and inc_prev = '1') then
                    if count_reg = 9 then
                        count_reg <= 0;
                    else
                        count_reg <= count_reg + 1;
                    end if;

                elsif (dec_stable = '0' and dec_prev = '1') then
                    if count_reg = 0 then
                        count_reg <= 9;
                    else
                        count_reg <= count_reg - 1;
                    end if;

                end if;
            end if;
        end if;
    end process;

    ---------------------------------------------------
    -- 4) 7-segment decoder
    ---------------------------------------------------
    process(count_reg)
    begin
        case count_reg is
            when 0 => segments <= "1000000";
            when 1 => segments <= "1111001";
            when 2 => segments <= "0100100";
            when 3 => segments <= "0110000";
            when 4 => segments <= "0011001";
            when 5 => segments <= "0010010";
            when 6 => segments <= "0000010";
            when 7 => segments <= "1111000";
            when 8 => segments <= "0000000";
            when 9 => segments <= "0010000";
            when others => segments <= "1000000";
        end case;
    end process;

end Behavioral;

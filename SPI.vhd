library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SPI_Master_Mode0 is
    Port (
        clk      : in  STD_LOGIC;  
        rst      : in  STD_LOGIC;  
        start    : in  STD_LOGIC;  
        data_in  : in  STD_LOGIC_VECTOR(7 downto 0);  
        miso     : in  STD_LOGIC;  
        sclk     : out STD_LOGIC;  
        mosi     : out STD_LOGIC;  
        ss       : out STD_LOGIC;  
        data_out : out STD_LOGIC_VECTOR(7 downto 0)  
    );
end SPI_Master_Mode0;

architecture Behavioral of SPI_Master_Mode0 is
    signal sclk_int      : STD_LOGIC := '0';  
    signal bit_count     : INTEGER := 0;      
    signal shift_reg_out : STD_LOGIC_VECTOR(7 downto 0);  
    signal shift_reg_in  : STD_LOGIC_VECTOR(7 downto 0);  
    signal transmitting  : STD_LOGIC := '0';  
begin

    
    process(clk, rst)
    begin
        if rst = '1' then
            sclk_int <= '0';
        elsif rising_edge(clk) then
            if transmitting = '1' then
                sclk_int <= not sclk_int;  
            else
                sclk_int <= '0';  
            end if;
        end if;
    end process;

    
    process(clk, rst)
    begin
        if rst = '1' then
            mosi <= '0';
            ss <= '1';  
            bit_count <= 0;
            transmitting <= '0';
            shift_reg_out <= (others => '0');
            shift_reg_in <= (others => '0');
            data_out <= (others => '0');
        elsif rising_edge(clk) then
            if start = '1' and transmitting = '0' then
                shift_reg_out <= data_in;  
                ss <= '0';  
                transmitting <= '1';  
                bit_count <= 0;
            elsif transmitting = '1' then
                if sclk_int = '1' then  
                    
                    mosi <= shift_reg_out(7); 
                    shift_reg_out <= shift_reg_out(6 downto 0) & '0'; 

                    
                    shift_reg_in <= shift_reg_in(6 downto 0) & miso;  

                    bit_count <= bit_count + 1;
                    if bit_count = 7 then
                        transmitting <= '0';  
                        ss <= '1';  
                        data_out <= shift_reg_in;  
                    end if;
                end if;
            end if;
        end if;
    end process;

    
    sclk <= sclk_int;

end Behavioral;
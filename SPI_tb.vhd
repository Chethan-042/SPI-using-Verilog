library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SPI_Master_Mode0_TB is
end SPI_Master_Mode0_TB;

architecture Behavioral of SPI_Master_Mode0_TB is
    signal clk      : STD_LOGIC := '0';
    signal rst      : STD_LOGIC := '1';
    signal start    : STD_LOGIC := '0';
    signal data_in  : STD_LOGIC_VECTOR(7 downto 0) := "10101010";
    signal miso     : STD_LOGIC := '0';
    signal sclk     : STD_LOGIC;
    signal mosi     : STD_LOGIC;
    signal ss       : STD_LOGIC;
    signal data_out : STD_LOGIC_VECTOR(7 downto 0);
begin

    uut: entity work.SPI_Master_Mode0
        Port Map (
            clk      => clk,
            rst      => rst,
            start    => start,
            data_in  => data_in,
            miso     => miso,
            sclk     => sclk,
            mosi     => mosi,
            ss       => ss,
            data_out => data_out
        );

    clk <= not clk after 5 ns;

    process
    begin

        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 20 ns;

        start <= '1';
        wait for 20 ns;
        start <= '0';

        miso <= '1'; wait for 10 ns;  
        miso <= '0'; wait for 10 ns;  
        miso <= '1'; wait for 10 ns;  
        miso <= '0'; wait for 10 ns;  
        miso <= '1'; wait for 10 ns;  
        miso <= '0'; wait for 10 ns;  
        miso <= '1'; wait for 10 ns;  
        miso <= '0'; wait for 10 ns;  

        
        wait for 200 ns;
        assert false report "Simulation Complete" severity failure;
    end process;

end Behavioral;
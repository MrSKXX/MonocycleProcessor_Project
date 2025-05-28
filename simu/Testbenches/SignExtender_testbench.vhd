library IEEE;
use IEEE.std_logic_1164.all;

entity SignExtender_testbench is
end entity SignExtender_testbench;

architecture test of SignExtender_testbench is
    component SignExtender is
        generic (
            N : integer := 8
        );
        port (
            E : in std_logic_vector(N-1 downto 0);
            S : out std_logic_vector(31 downto 0)
        );
    end component;
    
    constant N_TEST : integer := 8;
    signal E_tb : std_logic_vector(N_TEST-1 downto 0) := (others => '0');
    signal S_tb : std_logic_vector(31 downto 0);
    
begin
    UUT: SignExtender 
        generic map (
            N => N_TEST
        )
        port map (
            E => E_tb,
            S => S_tb
        );
    
    stimulus: process
    begin
        -- Test 1: Valeur positive sans extension (bit de signe = 0)
        E_tb <= "01101010"; -- 0x6A
        wait for 10 ns;
        assert S_tb(7 downto 0) = "01101010" report "Test 1 (lower bits) failed" severity error;
        assert S_tb(31 downto 8) = X"000000" report "Test 1 (upper bits) failed" severity error;
        
        -- Test 2: Valeur négative avec extension (bit de signe = 1)
        E_tb <= "10011010"; -- 0x9A
        wait for 10 ns;
        assert S_tb(7 downto 0) = "10011010" report "Test 2 (lower bits) failed" severity error;
        assert S_tb(31 downto 8) = X"FFFFFF" report "Test 2 (upper bits) failed" severity error;
        
        -- Test 3: Valeur minimum (tous bits à 0)
        E_tb <= "00000000";
        wait for 10 ns;
        assert S_tb = X"00000000" report "Test 3 (min value) failed" severity error;
        
        -- Test 4: Valeur maximum négative (MSB à 1, reste à 0)
        E_tb <= "10000000";
        wait for 10 ns;
        assert S_tb(7 downto 0) = "10000000" report "Test 4 (lower bits) failed" severity error;
        assert S_tb(31 downto 8) = X"FFFFFF" report "Test 4 (upper bits) failed" severity error;
        
        report "All tests completed";
        wait;
    end process;
    
end architecture test;
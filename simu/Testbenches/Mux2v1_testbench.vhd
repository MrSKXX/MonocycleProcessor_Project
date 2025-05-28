library IEEE;
use IEEE.std_logic_1164.all;

entity Mux2v1_testbench is
end entity Mux2v1_testbench;

architecture test of Mux2v1_testbench is
    component Mux2v1 is
        generic (
            N : integer := 32
        );
        port (
            A, B : in std_logic_vector(N-1 downto 0);
            COM : in std_logic;
            S : out std_logic_vector(N-1 downto 0)
        );
    end component;
    
    constant N_TEST : integer := 8; 
    signal A_tb, B_tb : std_logic_vector(N_TEST-1 downto 0) := (others => '0');
    signal COM_tb : std_logic := '0';
    signal S_tb : std_logic_vector(N_TEST-1 downto 0);
    
begin
    UUT: Mux2v1 
        generic map (
            N => N_TEST
        )
        port map (
            A => A_tb,
            B => B_tb,
            COM => COM_tb,
            S => S_tb
        );
    
    stimulus: process
    begin
        -- Test 1: COM = 0, devrait sélectionner A
        A_tb <= "10101010";
        B_tb <= "01010101";
        COM_tb <= '0';
        wait for 10 ns;
        assert S_tb = "10101010" report "Test 1 (COM=0) failed" severity error;
        
        -- Test 2: COM = 1, devrait sélectionner B
        COM_tb <= '1';
        wait for 10 ns;
        assert S_tb = "01010101" report "Test 2 (COM=1) failed" severity error;
        
        -- Test 3: Changement des valeurs d'entrée
        A_tb <= "11110000";
        B_tb <= "00001111";
        wait for 10 ns;
        assert S_tb = "00001111" report "Test 3 (changing values) failed" severity error;
        
        -- Test 4: Changement de sélection
        COM_tb <= '0';
        wait for 10 ns;
        assert S_tb = "11110000" report "Test 4 (switching back) failed" severity error;
        
        report "All tests completed";
        wait;
    end process;
    
end architecture test;
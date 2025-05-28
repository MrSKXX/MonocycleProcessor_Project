library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity DataMemory_testbench is
end entity DataMemory_testbench;

architecture test of DataMemory_testbench is
    component DataMemory is
        port (
            CLK : in std_logic;
            Reset : in std_logic;
            DataIn : in std_logic_vector(31 downto 0);
            DataOut : out std_logic_vector(31 downto 0);
            Addr : in std_logic_vector(5 downto 0);
            WrEn : in std_logic
        );
    end component;
    
    signal CLK_tb : std_logic := '0';
    signal Reset_tb : std_logic := '0';
    signal DataIn_tb : std_logic_vector(31 downto 0) := (others => '0');
    signal DataOut_tb : std_logic_vector(31 downto 0);
    signal Addr_tb : std_logic_vector(5 downto 0) := (others => '0');
    signal WrEn_tb : std_logic := '0';
    constant CLK_PERIOD : time := 10 ns;
    
begin
    UUT: DataMemory port map (
        CLK => CLK_tb,
        Reset => Reset_tb,
        DataIn => DataIn_tb,
        DataOut => DataOut_tb,
        Addr => Addr_tb,
        WrEn => WrEn_tb
    );
    
    clk_process: process
    begin
        CLK_tb <= '0';
        wait for CLK_PERIOD/2;
        CLK_tb <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    stimulus: process
    begin
        Reset_tb <= '1';
        wait for CLK_PERIOD;
        Reset_tb <= '0';
        wait for CLK_PERIOD;
        
        -- Test 1: Écriture à l'adresse 0
        Addr_tb <= "000000";  -- Adresse 0
        DataIn_tb <= X"ABCD1234";
        WrEn_tb <= '1';
        wait for CLK_PERIOD;
        WrEn_tb <= '0';
        
        -- Vérification de la lecture à l'adresse 0
        wait for CLK_PERIOD/2; -- Attendre la lecture asynchrone
        assert DataOut_tb = X"ABCD1234" report "Test 1 (Write/Read Addr 0) failed" severity error;
        
        -- Test 2: Écriture à l'adresse 10
        Addr_tb <= "001010";  -- Adresse 10
        DataIn_tb <= X"FEDC5678";
        WrEn_tb <= '1';
        wait for CLK_PERIOD;
        WrEn_tb <= '0';
        
        -- Vérification de la lecture à l'adresse 10
        wait for CLK_PERIOD/2;
        assert DataOut_tb = X"FEDC5678" report "Test 2 (Write/Read Addr 10) failed" severity error;
        
        -- Test 3: Lecture à l'adresse 0 pour vérifier que la valeur est toujours présente
        Addr_tb <= "000000";
        wait for CLK_PERIOD/2;
        assert DataOut_tb = X"ABCD1234" report "Test 3 (Read Addr 0 again) failed" severity error;
        
        -- Test 4: Vérifier que l'écriture ne se fait pas quand WrEn=0
        Addr_tb <= "000001";  -- Adresse 1
        DataIn_tb <= X"11111111";
        WrEn_tb <= '0';
        wait for CLK_PERIOD;
        wait for CLK_PERIOD/2;
        assert DataOut_tb = X"00000000" report "Test 4 (No write when WrEn=0) failed" severity error;
        
        -- Test 5: Vérifier la lecture à l'adresse maximale
        Addr_tb <= "111111";  -- Adresse 63
        wait for CLK_PERIOD/2;
        -- Pas d'assertion ici car nous savons juste que la valeur doit être 0 après le reset
        
        report "All tests completed";
        wait;
    end process;
    
end architecture test;
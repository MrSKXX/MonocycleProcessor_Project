library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity RegisterBank_testbench is
end entity RegisterBank_testbench;

architecture test of RegisterBank_testbench is
    component RegisterBank is
        port (
            CLK : in std_logic;
            Reset : in std_logic;
            W : in std_logic_vector(31 downto 0);
            RA : in std_logic_vector(3 downto 0);
            RB : in std_logic_vector(3 downto 0);
            RW : in std_logic_vector(3 downto 0);
            WE : in std_logic;
            A : out std_logic_vector(31 downto 0);
            B : out std_logic_vector(31 downto 0)
        );
    end component;
    
    signal CLK_tb : std_logic := '0';
    signal Reset_tb : std_logic := '0';
    signal W_tb : std_logic_vector(31 downto 0) := (others => '0');
    signal RA_tb, RB_tb, RW_tb : std_logic_vector(3 downto 0) := (others => '0');
    signal WE_tb : std_logic := '0';
    signal A_tb, B_tb : std_logic_vector(31 downto 0);
    
    constant CLK_PERIOD : time := 10 ns;
    
begin
    UUT: RegisterBank port map (
        CLK => CLK_tb,
        Reset => Reset_tb,
        W => W_tb,
        RA => RA_tb,
        RB => RB_tb,
        RW => RW_tb,
        WE => WE_tb,
        A => A_tb,
        B => B_tb
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
        
        -- Test 1: Lecture de R15 (qui est initialisé à 0x30)
        RA_tb <= "1111";  -- R15
        wait for CLK_PERIOD;
        assert A_tb = X"00000030" report "Test 1 (Read R15) failed" severity error;
        
        -- Test 2: Écriture dans R1 et lecture
        RW_tb <= "0001";  -- R1
        W_tb <= X"ABCD1234";
        WE_tb <= '1';
        wait for CLK_PERIOD;
        WE_tb <= '0';
        RA_tb <= "0001";  -- R1
        wait for CLK_PERIOD/2;  
        assert A_tb = X"ABCD1234" report "Test 2 (Write/Read R1) failed" severity error;
        
        -- Test 3: Écriture dans R2 et lecture simultanée de R1 et R2
        RW_tb <= "0010";  -- R2
        W_tb <= X"12345678";
        WE_tb <= '1';
        wait for CLK_PERIOD;
        WE_tb <= '0';
        RA_tb <= "0001";  -- R1
        RB_tb <= "0010";  -- R2
        wait for CLK_PERIOD/2;
        assert A_tb = X"ABCD1234" report "Test 3 (Read R1) failed" severity error;
        assert B_tb = X"12345678" report "Test 3 (Read R2) failed" severity error;
        
        -- Test 4: Vérifier que l'écriture ne se fait pas quand WE=0
        RW_tb <= "0011";  -- R3
        W_tb <= X"FFFFFFFF";
        WE_tb <= '0';
        wait for CLK_PERIOD;
        RA_tb <= "0011";  -- R3
        wait for CLK_PERIOD/2;
        assert A_tb = X"00000000" report "Test 4 (No write when WE=0) failed" severity error;
        
        report "All tests completed";
        wait;
    end process;
    
end architecture test;
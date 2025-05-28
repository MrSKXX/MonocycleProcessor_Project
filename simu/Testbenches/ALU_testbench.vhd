library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU_testbench is
end entity ALU_testbench;

architecture test of ALU_testbench is
    component ALU is
        port (
            OP : in std_logic_vector(1 downto 0);
            A, B : in std_logic_vector(31 downto 0);
            S : out std_logic_vector(31 downto 0);
            N : out std_logic;
            Z : out std_logic
        );
    end component;
    
    signal OP_tb : std_logic_vector(1 downto 0) := "00";
    signal A_tb, B_tb : std_logic_vector(31 downto 0) := (others => '0');
    signal S_tb : std_logic_vector(31 downto 0);
    signal N_tb, Z_tb : std_logic;
    
    constant PERIOD : time := 10 ns;

begin
    UUT: ALU port map (
        OP => OP_tb,
        A => A_tb,
        B => B_tb,
        S => S_tb,
        N => N_tb,
        Z => Z_tb
    );
    
    stimulus: process
    begin
        -- Test 1: Addition A + B
        A_tb <= x"00000010";  -- 16 en décimal
        B_tb <= x"00000020";  -- 32 en décimal
        OP_tb <= "00";        -- ADD
        wait for PERIOD;
        assert S_tb = x"00000030" report "Test 1 (ADD) failed" severity error;
        assert Z_tb = '0' report "Test 1 (Z flag) failed" severity error;
        assert N_tb = '0' report "Test 1 (N flag) failed" severity error;
        
        -- Test 2: B uniquement
        OP_tb <= "01";        -- B
        wait for PERIOD;
        assert S_tb = x"00000020" report "Test 2 (B) failed" severity error;
        
        -- Test 3: Soustraction A - B
        A_tb <= x"00000020";  -- 32 en décimal
        B_tb <= x"00000030";  -- 48 en décimal
        OP_tb <= "10";        -- SUB
        wait for PERIOD;
        assert S_tb = x"FFFFFFF0" report "Test 3 (SUB) failed" severity error;
        assert N_tb = '1' report "Test 3 (N flag) failed" severity error;
        
        -- Test 4: A uniquement
        OP_tb <= "11";        -- A
        wait for PERIOD;
        assert S_tb = x"00000020" report "Test 4 (A) failed" severity error;
        
        -- Test 5: Test du flag Z (résultat = 0)
        A_tb <= x"00000010";
        B_tb <= x"00000010";
        OP_tb <= "10";        -- SUB
        wait for PERIOD;
        assert S_tb = x"00000000" report "Test 5 (SUB=0) failed" severity error;
        assert Z_tb = '1' report "Test 5 (Z flag) failed" severity error;
        
        report "All tests completed";
        wait;
    end process;
    
end architecture test;
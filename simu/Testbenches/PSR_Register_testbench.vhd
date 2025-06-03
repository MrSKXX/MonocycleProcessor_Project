library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PSR_Register_testbench is
end entity PSR_Register_testbench;

architecture test of PSR_Register_testbench is
    component PSR_Register is
        port (
            CLK : in std_logic;
            Reset : in std_logic;
            WE : in std_logic;
            DATAIN : in std_logic_vector(31 downto 0);
            DATAOUT : out std_logic_vector(31 downto 0)
        );
    end component;
    
    signal CLK_tb : std_logic := '0';
    signal Reset_tb : std_logic := '0';
    signal WE_tb : std_logic := '0';
    signal DATAIN_tb : std_logic_vector(31 downto 0) := (others => '0');
    signal DATAOUT_tb : std_logic_vector(31 downto 0);
    
    constant CLK_PERIOD : time := 10 ns;
    
begin
    UUT: PSR_Register port map (
        CLK => CLK_tb,
        Reset => Reset_tb,
        WE => WE_tb,
        DATAIN => DATAIN_tb,
        DATAOUT => DATAOUT_tb
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
        -- Test 1: Reset
        Reset_tb <= '1';
        wait for CLK_PERIOD*2;
        Reset_tb <= '0';
        wait for CLK_PERIOD;
        assert DATAOUT_tb = x"00000000" report "Test 1 (Reset) failed" severity error;
        
        -- Test 2: Écriture avec WE=1
        DATAIN_tb <= x"80000001"; -- N=1, Z=0, autres bits=0
        WE_tb <= '1';
        wait for CLK_PERIOD;
        WE_tb <= '0';
        wait for CLK_PERIOD/2;
        assert DATAOUT_tb = x"80000001" report "Test 2 (Write N=1, Z=0) failed" severity error;
        
        -- Test 3: Tentative d'écriture avec WE=0
        DATAIN_tb <= x"40000002"; -- N=0, Z=1
        WE_tb <= '0';
        wait for CLK_PERIOD;
        wait for CLK_PERIOD/2;
        assert DATAOUT_tb = x"80000001" report "Test 3 (No write when WE=0) failed" severity error;
        
        -- Test 4: Nouvelle écriture avec WE=1
        DATAIN_tb <= x"C0000003"; -- N=1, Z=1
        WE_tb <= '1';
        wait for CLK_PERIOD;
        WE_tb <= '0';
        wait for CLK_PERIOD/2;
        assert DATAOUT_tb = x"C0000003" report "Test 4 (Write N=1, Z=1) failed" severity error;
        
        -- Test 5: Vérification que les drapeaux sont bien positionnés
        assert DATAOUT_tb(31) = '1' report "Test 5 (N flag) failed" severity error;
        assert DATAOUT_tb(30) = '1' report "Test 5 (Z flag) failed" severity error;
        
        report "All PSR tests completed";
        wait;
    end process;
    
end architecture test;
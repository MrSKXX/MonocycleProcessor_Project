library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity InstructionUnit_testbench is
end entity InstructionUnit_testbench;

architecture test of InstructionUnit_testbench is
    -- Déclaration du composant à tester
    component InstructionUnit is
        port (
            CLK : in std_logic;
            Reset : in std_logic;
            nPCsel : in std_logic;
            offset : in std_logic_vector(23 downto 0);
            Instruction : out std_logic_vector(31 downto 0)
        );
    end component;
    
    -- Signaux de test
    signal CLK_tb : std_logic := '0';
    signal Reset_tb : std_logic := '0';
    signal nPCsel_tb : std_logic := '0';
    signal offset_tb : std_logic_vector(23 downto 0) := (others => '0');
    signal Instruction_tb : std_logic_vector(31 downto 0);
    
    -- Constantes pour les tests
    constant CLK_PERIOD : time := 10 ns;
    
begin
    -- Instanciation du composant à tester
    UUT: InstructionUnit port map (
        CLK => CLK_tb,
        Reset => Reset_tb,
        nPCsel => nPCsel_tb,
        offset => offset_tb,
        Instruction => Instruction_tb
    );
    
    -- Génération de l'horloge
    clk_process: process
    begin
        CLK_tb <= '0';
        wait for CLK_PERIOD/2;
        CLK_tb <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    -- Processus de test
    stimulus: process
    begin
        -- Reset initial
        Reset_tb <= '1';
        wait for CLK_PERIOD*2;
        Reset_tb <= '0';
        wait for CLK_PERIOD;
        
        -- Test 1: Exécution séquentielle (nPCsel = 0)
        -- Le PC s'incrémente de 1 à chaque cycle
        nPCsel_tb <= '0';
        
        -- Attendre un cycle pour que la première instruction soit chargée
        wait for CLK_PERIOD;
        -- PC = 0, Instruction devrait être MOV R1,#0x10
        assert Instruction_tb = x"E3A01010" 
            report "Test failed: Expected MOV R1,#0x10 at PC=0" severity error;
        
        -- Passer à l'instruction suivante
        wait for CLK_PERIOD;
        -- PC = 1, Instruction devrait être MOV R2,#0x00
        assert Instruction_tb = x"E3A02000" 
            report "Test failed: Expected MOV R2,#0x00 at PC=1" severity error;
        
        -- Passer à l'instruction suivante
        wait for CLK_PERIOD;
        -- PC = 2, Instruction devrait être LDR R0,0(R1)
        assert Instruction_tb = x"E4110000" 
            report "Test failed: Expected LDR R0,0(R1) at PC=2" severity error;
        
        -- Passer à l'instruction suivante
        wait for CLK_PERIOD;
        -- PC = 3, Instruction devrait être ADD R2,R2,R0
        assert Instruction_tb = x"E0822000" 
            report "Test failed: Expected ADD R2,R2,R0 at PC=3" severity error;
        
        -- Passer à l'instruction suivante
        wait for CLK_PERIOD;
        -- PC = 4, Instruction devrait être ADD R1,R1,#1
        assert Instruction_tb = x"E2811001" 
            report "Test failed: Expected ADD R1,R1,#1 at PC=4" severity error;
        
        -- Test 2: Saut avec offset négatif (nPCsel = 1)
        -- On va simuler un branchement à l'étiquette 'loop' (PC = 2)
        -- Depuis PC = 5, le saut devrait être de -5
        offset_tb <= "111111111111111111111011"; -- Offset de -5 (en complément à 2)
        nPCsel_tb <= '1';
        wait for CLK_PERIOD;
        -- PC devrait être PC + 1 - 5 = 5 + 1 - 5 = 1
        -- Instruction devrait être MOV R2,#0x00
        assert Instruction_tb = x"E3A02000" 
            report "Test failed: Expected MOV R2,#0x00 after jump to PC=1" severity error;
        
        -- Revenons au mode séquentiel pour continuer
        nPCsel_tb <= '0';
        wait for CLK_PERIOD;
        -- PC = 2, Instruction devrait être LDR R0,0(R1)
        assert Instruction_tb = x"E4110000" 
            report "Test failed: Expected LDR R0,0(R1) at PC=2 after sequential execution" severity error;
        
        -- Test 3: Saut avec offset négatif (nPCsel = 1)
        -- On va simuler un branchement à l'étiquette 'main' (PC = 0)
        -- Supposons que nous sommes à PC = 8 (instruction BAL main)
        -- Exécutons séquentiellement jusqu'à PC = 8
        wait for CLK_PERIOD * 6;  -- Atteindre PC = 8
        
        -- Maintenant simulons le saut à 'main'
        offset_tb <= "111111111111111111110111"; -- Offset de -9 (en complément à 2)
        nPCsel_tb <= '1';
        wait for CLK_PERIOD;
        -- PC devrait être PC + 1 - 9 = 8 + 1 - 9 = 0
        -- Instruction devrait être MOV R1,#0x10
        assert Instruction_tb = x"E3A01010" 
            report "Test failed: Expected MOV R1,#0x10 at PC=0 after jump" severity error;
        
        -- Fin des tests
        report "All tests completed";
        wait;
    end process;
    
end architecture test;
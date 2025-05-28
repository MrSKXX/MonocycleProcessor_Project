library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ControlUnit_testbench is
end entity ControlUnit_testbench;

architecture test of ControlUnit_testbench is
    -- Déclaration du composant à tester
    component ControlUnit is
        port (
            CLK : in std_logic;
            Reset : in std_logic;
            Instruction : in std_logic_vector(31 downto 0);
            N_ALU : in std_logic;
            Z_ALU : in std_logic;
            N : out std_logic;
            nPC_SEL : out std_logic;
            RegWr : out std_logic;
            RegSel : out std_logic;
            Rn : out std_logic_vector(3 downto 0);
            Rm : out std_logic_vector(3 downto 0);
            Rd : out std_logic_vector(3 downto 0);
            ALUCtr : out std_logic_vector(1 downto 0);
            ALUSrc : out std_logic;
            MemWr : out std_logic;
            WrSrc : out std_logic;
            MemToReg : out std_logic;
            RegAff : out std_logic_vector(31 downto 0)
        );
    end component;
    
    -- Signaux de test
    signal CLK_tb : std_logic := '0';
    signal Reset_tb : std_logic := '0';
    signal Instruction_tb : std_logic_vector(31 downto 0) := (others => '0');
    signal N_ALU_tb : std_logic := '0';
    signal Z_ALU_tb : std_logic := '0';
    signal N_tb : std_logic;
    signal nPC_SEL_tb : std_logic;
    signal RegWr_tb : std_logic;
    signal RegSel_tb : std_logic;
    signal Rn_tb : std_logic_vector(3 downto 0);
    signal Rm_tb : std_logic_vector(3 downto 0);
    signal Rd_tb : std_logic_vector(3 downto 0);
    signal ALUCtr_tb : std_logic_vector(1 downto 0);
    signal ALUSrc_tb : std_logic;
    signal MemWr_tb : std_logic;
    signal WrSrc_tb : std_logic;
    signal MemToReg_tb : std_logic;
    signal RegAff_tb : std_logic_vector(31 downto 0);
    
    -- Constantes pour les tests
    constant CLK_PERIOD : time := 10 ns;
    
begin
    -- Instanciation du composant à tester
    UUT: ControlUnit port map (
        CLK => CLK_tb,
        Reset => Reset_tb,
        Instruction => Instruction_tb,
        N_ALU => N_ALU_tb,
        Z_ALU => Z_ALU_tb,
        N => N_tb,
        nPC_SEL => nPC_SEL_tb,
        RegWr => RegWr_tb,
        RegSel => RegSel_tb,
        Rn => Rn_tb,
        Rm => Rm_tb,
        Rd => Rd_tb,
        ALUCtr => ALUCtr_tb,
        ALUSrc => ALUSrc_tb,
        MemWr => MemWr_tb,
        WrSrc => WrSrc_tb,
        MemToReg => MemToReg_tb,
        RegAff => RegAff_tb
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
        
        -- Test 1: Instruction MOV R1, #0x10
        Instruction_tb <= x"E3A01010";
        wait for CLK_PERIOD*2;
        -- Vérification des signaux de contrôle
        assert RegWr_tb = '1' report "Test 1: RegWr should be 1" severity error;
        assert ALUCtr_tb = "01" report "Test 1: ALUCtr should be 01" severity error;
        assert ALUSrc_tb = '1' report "Test 1: ALUSrc should be 1" severity error;
        assert nPC_SEL_tb = '0' report "Test 1: nPC_SEL should be 0" severity error;
        
        -- Test 2: Instruction ADD R2, R2, R0
        Instruction_tb <= x"E0822000";
        wait for CLK_PERIOD*2;
        -- Vérification des signaux de contrôle
        assert RegWr_tb = '1' report "Test 2: RegWr should be 1" severity error;
        assert ALUCtr_tb = "00" report "Test 2: ALUCtr should be 00" severity error;
        assert ALUSrc_tb = '0' report "Test 2: ALUSrc should be 0" severity error;
        assert nPC_SEL_tb = '0' report "Test 2: nPC_SEL should be 0" severity error;
        
        -- Test 3: Instruction CMP R1, #0x1A
        Instruction_tb <= x"E351001A";
        N_ALU_tb <= '1';  -- Simuler un résultat négatif
        Z_ALU_tb <= '0';
        wait for CLK_PERIOD*2;
        -- Vérification des signaux de contrôle
        assert RegWr_tb = '0' report "Test 3: RegWr should be 0" severity error;
        assert ALUCtr_tb = "10" report "Test 3: ALUCtr should be 10" severity error;
        assert ALUSrc_tb = '1' report "Test 3: ALUSrc should be 1" severity error;
        -- Note: PSREn est un signal interne, nous ne pouvons pas le tester directement
        
        -- Attendre que les drapeaux soient mis à jour dans le PSR
        wait for CLK_PERIOD*2;
        
        -- Test 4: Instruction BLT loop
        Instruction_tb <= x"BAFFFFFB";
        wait for CLK_PERIOD*2;
        -- Vérification des signaux de contrôle
        -- Drapeau N doit être à 1 dans le PSR, donc le branchement doit être pris
        assert nPC_SEL_tb = '1' report "Test 4: nPC_SEL should be 1 when N = 1" severity error;
        
        -- Test 5: Instruction BLT loop avec N = 0
        -- D'abord, on met à jour les drapeaux pour avoir N = 0
        Instruction_tb <= x"E351001A"; -- CMP R1, #0x1A
        N_ALU_tb <= '0';  -- Simuler un résultat non négatif
        Z_ALU_tb <= '0';
        wait for CLK_PERIOD*2;
        -- Attendre que les drapeaux soient mis à jour
        wait for CLK_PERIOD*2;
        
        -- Maintenant tester BLT avec N = 0
        Instruction_tb <= x"BAFFFFFB";
        wait for CLK_PERIOD*2;
        -- Vérification des signaux de contrôle
        -- Drapeau N est à 0, donc le branchement ne doit pas être pris
        assert nPC_SEL_tb = '0' report "Test 5: nPC_SEL should be 0 when N = 0" severity error;
        
        -- Test 6: Instruction LDR R0, 0(R1)
        Instruction_tb <= x"E4110000";
        wait for CLK_PERIOD*2;
        -- Vérification des signaux de contrôle
        assert RegWr_tb = '1' report "Test 6: RegWr should be 1" severity error;
        assert ALUCtr_tb = "00" report "Test 6: ALUCtr should be 00" severity error;
        assert MemToReg_tb = '1' report "Test 6: MemToReg should be 1" severity error;
        
        -- Test 7: Instruction STR R2, 0(R1)
        Instruction_tb <= x"E4012000";
        wait for CLK_PERIOD*2;
        -- Vérification des signaux de contrôle
        assert RegWr_tb = '0' report "Test 7: RegWr should be 0" severity error;
        assert MemWr_tb = '1' report "Test 7: MemWr should be 1" severity error;
        -- Vérifier que RegAff contient une valeur non nulle (le PSR)
        assert RegAff_tb /= x"00000000" report "Test 7: RegAff should not be 0" severity error;
        
        -- Test 8: Instruction BAL main
        Instruction_tb <= x"EAFFFFF7";
        wait for CLK_PERIOD*2;
        -- Vérification des signaux de contrôle
        assert nPC_SEL_tb = '1' report "Test 8: nPC_SEL should be 1" severity error;
        
        -- Fin des tests
        report "All tests completed";
        wait;
    end process;
    
end architecture test;
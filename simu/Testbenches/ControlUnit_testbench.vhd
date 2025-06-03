library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ControlUnit_testbench is
end entity ControlUnit_testbench;

architecture test of ControlUnit_testbench is
    -- Déclaration du composant à tester (CORRIGÉE selon votre ControlUnit.vhd)
    component ControlUnit is
        port (
            CLK : in std_logic;
            Reset : in std_logic;
            Instruction : in std_logic_vector(31 downto 0);
            N_ALU : in std_logic;
            Z_ALU : in std_logic;
            BusB : in std_logic_vector(31 downto 0);  -- AJOUTÉ
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
    signal BusB_tb : std_logic_vector(31 downto 0) := x"12345678";  -- AJOUTÉ
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
    
    constant CLK_PERIOD : time := 10 ns;
    
begin
    -- Instanciation du composant à tester (CORRIGÉE)
    UUT: ControlUnit port map (
        CLK => CLK_tb,
        Reset => Reset_tb,
        Instruction => Instruction_tb,
        N_ALU => N_ALU_tb,
        Z_ALU => Z_ALU_tb,
        BusB => BusB_tb,  -- AJOUTÉ
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
    
    -- Processus de test simplifié
    stimulus: process
    begin
        -- Reset initial
        Reset_tb <= '1';
        wait for CLK_PERIOD*2;
        Reset_tb <= '0';
        wait for CLK_PERIOD;
        
        -- Test 1: MOV R1, #0x10
        Instruction_tb <= x"E3A01010";
        wait for CLK_PERIOD*2;
        
        -- Test 2: ADD R2, R2, R0
        Instruction_tb <= x"E0822000";
        wait for CLK_PERIOD*2;
        
        -- Test 3: CMP R1, #0x1A avec N=1
        Instruction_tb <= x"E351001A";
        N_ALU_tb <= '1';
        Z_ALU_tb <= '0';
        wait for CLK_PERIOD*2;
        
        -- Attendre mise à jour PSR
        wait for CLK_PERIOD*2;
        
        -- Test 4: BLT avec N=1
        Instruction_tb <= x"BAFFFFFB";
        wait for CLK_PERIOD*2;
        
        -- Test 5: CMP avec N=0
        Instruction_tb <= x"E351001A";
        N_ALU_tb <= '0';
        Z_ALU_tb <= '0';
        wait for CLK_PERIOD*2;
        
        -- Attendre mise à jour PSR
        wait for CLK_PERIOD*2;
        
        -- Test 6: BLT avec N=0
        Instruction_tb <= x"BAFFFFFB";
        wait for CLK_PERIOD*2;
        
        -- Test 7: LDR R0, 0(R1)
        Instruction_tb <= x"E4110000";
        wait for CLK_PERIOD*2;
        
        -- Test 8: STR R2, 0(R1)
        Instruction_tb <= x"E4012000";
        BusB_tb <= x"ABCDEF12";  -- Valeur à afficher
        wait for CLK_PERIOD*2;
        
        -- Test 9: BAL main
        Instruction_tb <= x"EAFFFFF7";
        wait for CLK_PERIOD*2;
        
        report "Tous les tests terminés";
        wait;
    end process;
    
end architecture test;
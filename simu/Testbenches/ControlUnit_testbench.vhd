library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ControlUnit_testbench is
end entity ControlUnit_testbench;

architecture test of ControlUnit_testbench is
    component ControlUnit is
        port (
            CLK : in std_logic;
            Reset : in std_logic;
            Instruction : in std_logic_vector(31 downto 0);
            N_ALU : in std_logic;
            Z_ALU : in std_logic;
            BusB : in std_logic_vector(31 downto 0);
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
    signal BusB_tb : std_logic_vector(31 downto 0) := x"12345678";
    
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
    UUT: ControlUnit port map (
        CLK => CLK_tb,
        Reset => Reset_tb,
        Instruction => Instruction_tb,
        N_ALU => N_ALU_tb,
        Z_ALU => Z_ALU_tb,
        BusB => BusB_tb,
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
    
    -- Generation de l'horloge
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
        report "--- DEBUT TEST CONTROL UNIT ---";
        
        -- Reset initial
        Reset_tb <= '1';
        wait for CLK_PERIOD*2;
        Reset_tb <= '0';
        wait for CLK_PERIOD;
        
        -- Verifier etat initial
        assert RegAff_tb = x"00000000" report "Reset: RegAff devrait etre 0" severity error;
        assert N_tb = '0' report "Reset: N devrait etre 0" severity error;
        report "OK Reset initial";
        
        -- Test 1: MOV R1,#0x10
        Instruction_tb <= x"E3A01010";
        N_ALU_tb <= '0';
        Z_ALU_tb <= '0';
        BusB_tb <= x"AAAAAAAA";
        wait for CLK_PERIOD;
        
        assert RegWr_tb = '1' report "MOV: RegWr devrait etre 1" severity error;
        assert ALUCtr_tb = "01" report "MOV: ALUCtr devrait etre 01" severity error;
        assert ALUSrc_tb = '1' report "MOV: ALUSrc devrait etre 1" severity error;
        assert nPC_SEL_tb = '0' report "MOV: nPC_SEL devrait etre 0" severity error;
        assert MemWr_tb = '0' report "MOV: MemWr devrait etre 0" severity error;
        assert Rd_tb = "0001" report "MOV: Rd devrait etre 0001" severity error;
        report "OK Test MOV";
        
        -- Test 2: ADD R2,R2,R0
        Instruction_tb <= x"E0822000";
        wait for CLK_PERIOD;
        
        assert RegWr_tb = '1' report "ADDr: RegWr devrait etre 1" severity error;
        assert ALUCtr_tb = "00" report "ADDr: ALUCtr devrait etre 00" severity error;
        assert ALUSrc_tb = '0' report "ADDr: ALUSrc devrait etre 0" severity error;
        assert Rn_tb = "0010" report "ADDr: Rn devrait etre 0010" severity error;
        assert Rm_tb = "0000" report "ADDr: Rm devrait etre 0000" severity error;
        assert Rd_tb = "0010" report "ADDr: Rd devrait etre 0010" severity error;
        report "OK Test ADD registre";
        
        -- Test 3: CMP R1,#0x1A avec mise a jour PSR
        Instruction_tb <= x"E351001A";
        N_ALU_tb <= '1';  -- Simuler resultat negatif
        Z_ALU_tb <= '0';
        wait for CLK_PERIOD;
        
        assert RegWr_tb = '0' report "CMP: RegWr devrait etre 0" severity error;
        assert ALUCtr_tb = "10" report "CMP: ALUCtr devrait etre 10" severity error;
        assert ALUSrc_tb = '1' report "CMP: ALUSrc devrait etre 1" severity error;
        report "OK Test CMP";
        
        -- Attendre mise a jour PSR
        wait for CLK_PERIOD;
        assert N_tb = '1' report "CMP: Flag N devrait etre 1 apres mise a jour" severity error;
        report "OK Test PSR mise a jour";
        
        -- Test 4: BLT avec N=1 (doit brancher)
        Instruction_tb <= x"BAFFFFFB";
        wait for CLK_PERIOD;
        
        assert nPC_SEL_tb = '1' report "BLT(N=1): nPC_SEL devrait etre 1" severity error;
        assert RegWr_tb = '0' report "BLT: RegWr devrait etre 0" severity error;
        report "OK Test BLT avec N=1";
        
        -- Test 5: Changer PSR et tester BLT avec N=0
        Instruction_tb <= x"E351001A"; -- CMP pour changer PSR
        N_ALU_tb <= '0';  -- Simuler resultat positif
        Z_ALU_tb <= '0';
        wait for CLK_PERIOD*2; -- Attendre mise a jour PSR
        
        Instruction_tb <= x"BAFFFFFB"; -- BLT
        wait for CLK_PERIOD;
        
        assert nPC_SEL_tb = '0' report "BLT(N=0): nPC_SEL devrait etre 0" severity error;
        assert N_tb = '0' report "BLT: Flag N devrait etre 0" severity error;
        report "OK Test BLT avec N=0";
        
        -- Test 6: LDR R0,0(R1)
        Instruction_tb <= x"E4110000";
        wait for CLK_PERIOD;
        
        assert RegWr_tb = '1' report "LDR: RegWr devrait etre 1" severity error;
        assert ALUCtr_tb = "00" report "LDR: ALUCtr devrait etre 00" severity error;
        assert ALUSrc_tb = '1' report "LDR: ALUSrc devrait etre 1" severity error;
        assert MemToReg_tb = '1' report "LDR: MemToReg devrait etre 1" severity error;
        assert MemWr_tb = '0' report "LDR: MemWr devrait etre 0" severity error;
        report "OK Test LDR";
        
        -- Test 7: STR R2,0(R1) avec affichage
        Instruction_tb <= x"E4012000";
        BusB_tb <= x"DEADBEEF"; -- Valeur a afficher
        wait for CLK_PERIOD;
        
        assert RegWr_tb = '0' report "STR: RegWr devrait etre 0" severity error;
        assert MemWr_tb = '1' report "STR: MemWr devrait etre 1" severity error;
        assert ALUCtr_tb = "00" report "STR: ALUCtr devrait etre 00" severity error;
        assert ALUSrc_tb = '1' report "STR: ALUSrc devrait etre 1" severity error;
        assert RegSel_tb = '1' report "STR: RegSel devrait etre 1" severity error;
        
        -- Verifier affichage apres cycle d'horloge
        wait for CLK_PERIOD;
        assert RegAff_tb = x"DEADBEEF" report "STR: RegAff devrait contenir DEADBEEF" severity error;
        report "OK Test STR et affichage";
        
        -- Test 8: BAL main
        Instruction_tb <= x"EAFFFFF7";
        wait for CLK_PERIOD;
        
        assert nPC_SEL_tb = '1' report "BAL: nPC_SEL devrait etre 1" severity error;
        assert RegWr_tb = '0' report "BAL: RegWr devrait etre 0" severity error;
        report "OK Test BAL";
        
        -- Test 9: Test sequence CMP -> BLT complete
        report "--- Test sequence CMP -> BLT ---";
        
        -- CMP avec resultat negatif
        Instruction_tb <= x"E351001A";
        N_ALU_tb <= '1';
        Z_ALU_tb <= '0';
        wait for CLK_PERIOD*2; -- Attendre PSR
        
        -- BLT doit brancher
        Instruction_tb <= x"BAFFFFFB";
        wait for CLK_PERIOD;
        assert nPC_SEL_tb = '1' report "Sequence: BLT devrait brancher" severity error;
        
        -- CMP avec resultat positif
        Instruction_tb <= x"E351001A";
        N_ALU_tb <= '0';
        Z_ALU_tb <= '0';
        wait for CLK_PERIOD*2; -- Attendre PSR
        
        -- BLT ne doit pas brancher
        Instruction_tb <= x"BAFFFFFB";
        wait for CLK_PERIOD;
        assert nPC_SEL_tb = '0' report "Sequence: BLT ne devrait pas brancher" severity error;
        
        report "OK Test sequence complete";
        
        -- Test 10: Verification que RegAff conserve sa valeur
        Instruction_tb <= x"E3A01010"; -- MOV (pas d'affichage)
        BusB_tb <= x"11111111";
        wait for CLK_PERIOD*2;
        assert RegAff_tb = x"DEADBEEF" report "Conservation: RegAff devrait conserver DEADBEEF" severity error;
        report "OK Test conservation RegAff";
        
        report "--- TOUS LES TESTS CONTROL UNIT PASSES ---";
        wait;
    end process;
    
end architecture test;
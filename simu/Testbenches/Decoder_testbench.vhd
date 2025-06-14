library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Decoder_testbench is
end entity Decoder_testbench;

architecture test of Decoder_testbench is
    component Decoder is
        port (
            instruction : in std_logic_vector(31 downto 0);
            RegPSR : in std_logic_vector(31 downto 0);
            nPC_SEL : out std_logic;
            PSREn : out std_logic;
            RegWr : out std_logic;
            RegSel : out std_logic;
            Rn : out std_logic_vector(3 downto 0);
            Rm : out std_logic_vector(3 downto 0);
            Rd : out std_logic_vector(3 downto 0);
            ALUCtrl : out std_logic_vector(1 downto 0);
            ALUSrc : out std_logic;
            MemWr : out std_logic;
            WrSrc : out std_logic;
            RegAff : out std_logic
        );
    end component;
    
    signal Instruction_tb : std_logic_vector(31 downto 0) := (others => '0');
    signal RegPSR_tb : std_logic_vector(31 downto 0) := (others => '0');
    signal nPC_SEL_tb : std_logic;
    signal PSREn_tb : std_logic;
    signal RegWr_tb : std_logic;
    signal RegSel_tb : std_logic;
    signal Rn_tb : std_logic_vector(3 downto 0);
    signal Rm_tb : std_logic_vector(3 downto 0);
    signal Rd_tb : std_logic_vector(3 downto 0);
    signal ALUCtrl_tb : std_logic_vector(1 downto 0);
    signal ALUSrc_tb : std_logic;
    signal MemWr_tb : std_logic;
    signal WrSrc_tb : std_logic;
    signal RegAff_tb : std_logic;
    
begin
    UUT: Decoder port map (
        instruction => Instruction_tb,
        RegPSR => RegPSR_tb,
        nPC_SEL => nPC_SEL_tb,
        PSREn => PSREn_tb,
        RegWr => RegWr_tb,
        RegSel => RegSel_tb,
        Rn => Rn_tb,
        Rm => Rm_tb,
        Rd => Rd_tb,
        ALUCtrl => ALUCtrl_tb,
        ALUSrc => ALUSrc_tb,
        MemWr => MemWr_tb,
        WrSrc => WrSrc_tb,
        RegAff => RegAff_tb
    );
    
    stimulus: process
    begin
        report "--- DEBUT TEST DECODER SIMPLIFIE ---";
        
        -- Test 1: MOV R1,#0x10 (E3A01010)
        Instruction_tb <= x"E3A01010";
        RegPSR_tb <= x"00000000";
        wait for 10 ns;
        assert RegWr_tb = '1' report "MOV: RegWr devrait etre 1" severity error;
        assert ALUCtrl_tb = "01" report "MOV: ALUCtrl devrait etre 01" severity error;
        assert ALUSrc_tb = '1' report "MOV: ALUSrc devrait etre 1" severity error;
        assert Rd_tb = "0001" report "MOV: Rd devrait etre 0001" severity error;
        report "OK Test MOV";
        
        -- Test 2: ADD R2,R2,R0 (E0822000) 
        Instruction_tb <= x"E0822000";
        wait for 10 ns;
        assert RegWr_tb = '1' report "ADDr: RegWr devrait etre 1" severity error;
        assert ALUCtrl_tb = "00" report "ADDr: ALUCtrl devrait etre 00" severity error;
        assert ALUSrc_tb = '0' report "ADDr: ALUSrc devrait etre 0" severity error;
        assert Rn_tb = "0010" report "ADDr: Rn devrait etre 0010" severity error;
        assert Rm_tb = "0000" report "ADDr: Rm devrait etre 0000" severity error;
        assert Rd_tb = "0010" report "ADDr: Rd devrait etre 0010" severity error;
        report "OK Test ADDr";
        
        -- Test 3: ADD R1,R1,#1 (E2811001)
        Instruction_tb <= x"E2811001";
        wait for 10 ns;
        assert RegWr_tb = '1' report "ADDi: RegWr devrait etre 1" severity error;
        assert ALUCtrl_tb = "00" report "ADDi: ALUCtrl devrait etre 00" severity error;
        assert ALUSrc_tb = '1' report "ADDi: ALUSrc devrait etre 1" severity error;
        report "OK Test ADDi";
        
        -- Test 4: CMP R1,#0x1A (E351001A)
        Instruction_tb <= x"E351001A";
        wait for 10 ns;
        assert RegWr_tb = '0' report "CMP: RegWr devrait etre 0" severity error;
        assert ALUCtrl_tb = "10" report "CMP: ALUCtrl devrait etre 10" severity error;
        assert ALUSrc_tb = '1' report "CMP: ALUSrc devrait etre 1" severity error;
        assert PSREn_tb = '1' report "CMP: PSREn devrait etre 1" severity error;
        report "OK Test CMP";
        
        -- Test 5: BLT avec N=1 (BAFFFFFB)
        Instruction_tb <= x"BAFFFFFB";
        RegPSR_tb <= x"80000000"; -- N=1
        wait for 10 ns;
        assert nPC_SEL_tb = '1' report "BLT(N=1): nPC_SEL devrait etre 1" severity error;
        report "OK Test BLT N=1";
        
        -- Test 6: BLT avec N=0
        RegPSR_tb <= x"00000000"; -- N=0
        wait for 10 ns;
        assert nPC_SEL_tb = '0' report "BLT(N=0): nPC_SEL devrait etre 0" severity error;
        report "OK Test BLT N=0";
        
        -- Test 7: LDR R0,0(R1) (E4110000)
        Instruction_tb <= x"E4110000";
        wait for 10 ns;
        assert RegWr_tb = '1' report "LDR: RegWr devrait etre 1" severity error;
        assert WrSrc_tb = '1' report "LDR: WrSrc devrait etre 1" severity error;
        assert ALUSrc_tb = '1' report "LDR: ALUSrc devrait etre 1" severity error;
        report "OK Test LDR";
        
        -- Test 8: STR original (E4012000) - Test si detection marche
        Instruction_tb <= x"E4012000";
        wait for 10 ns;
        assert MemWr_tb = '1' report "STR: MemWr devrait etre 1" severity error;
        assert RegAff_tb = '1' report "STR: RegAff devrait etre 1" severity error;
        assert RegSel_tb = '1' report "STR: RegSel devrait etre 1" severity error;
        report "OK Test STR E4012000";
        
        -- Test 9: STR variante (E5812000)
        Instruction_tb <= x"E5812000";
        wait for 10 ns;
        assert MemWr_tb = '1' report "STR var: MemWr devrait etre 1" severity error;
        assert RegAff_tb = '1' report "STR var: RegAff devrait etre 1" severity error;
        report "OK Test STR variante";
        
        -- Test 10: BAL main (EAFFFFF7)
        Instruction_tb <= x"EAFFFFF7";
        wait for 10 ns;
        assert nPC_SEL_tb = '1' report "BAL: nPC_SEL devrait etre 1" severity error;
        assert RegWr_tb = '0' report "BAL: RegWr devrait etre 0" severity error;
        report "OK Test BAL";
        
        report "--- TOUS LES TESTS DECODER PASSES ---";
        wait;
    end process;
    
end architecture test;
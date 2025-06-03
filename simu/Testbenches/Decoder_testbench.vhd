library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Decoder_testbench is
end entity Decoder_testbench;

architecture test of Decoder_testbench is
    component Decoder is
        port (
            instruction : in std_logic_vector(31 downto 0);
            N : in std_logic;
            N_ALU : in std_logic;
            nPC_SEL : out std_logic;
            PSREn : out std_logic;
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
            RegAff : out std_logic
        );
    end component;
    
    signal instruction_tb : std_logic_vector(31 downto 0) := (others => '0');
    signal N_tb : std_logic := '0';
    signal N_ALU_tb : std_logic := '0';
    signal nPC_SEL_tb : std_logic;
    signal PSREn_tb : std_logic;
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
    signal RegAff_tb : std_logic;
    
begin
    UUT: Decoder port map (
        instruction => instruction_tb,
        N => N_tb,
        N_ALU => N_ALU_tb,
        nPC_SEL => nPC_SEL_tb,
        PSREn => PSREn_tb,
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
    
    stimulus: process
    begin
        -- Test 1: MOV R1,#0x10 (E3A01010)
        instruction_tb <= x"E3A01010";
        N_tb <= '0';
        wait for 10 ns;
        assert RegWr_tb = '1' report "Test MOV: RegWr should be 1" severity error;
        assert ALUCtr_tb = "01" report "Test MOV: ALUCtr should be 01" severity error;
        assert ALUSrc_tb = '1' report "Test MOV: ALUSrc should be 1" severity error;
        assert nPC_SEL_tb = '0' report "Test MOV: nPC_SEL should be 0" severity error;
        assert PSREn_tb = '0' report "Test MOV: PSREn should be 0" severity error;
        assert MemWr_tb = '0' report "Test MOV: MemWr should be 0" severity error;
        assert Rd_tb = "0001" report "Test MOV: Rd should be 0001" severity error;
        
        -- Test 2: ADD R2,R2,R0 (E0822000)
        instruction_tb <= x"E0822000";
        wait for 10 ns;
        assert RegWr_tb = '1' report "Test ADDr: RegWr should be 1" severity error;
        assert ALUCtr_tb = "00" report "Test ADDr: ALUCtr should be 00" severity error;
        assert ALUSrc_tb = '0' report "Test ADDr: ALUSrc should be 0" severity error;
        assert nPC_SEL_tb = '0' report "Test ADDr: nPC_SEL should be 0" severity error;
        assert Rn_tb = "0010" report "Test ADDr: Rn should be 0010" severity error;
        assert Rm_tb = "0000" report "Test ADDr: Rm should be 0000" severity error;
        assert Rd_tb = "0010" report "Test ADDr: Rd should be 0010" severity error;
        
        -- Test 3: ADD R1,R1,#1 (E2811001)
        instruction_tb <= x"E2811001";
        wait for 10 ns;
        assert RegWr_tb = '1' report "Test ADDi: RegWr should be 1" severity error;
        assert ALUCtr_tb = "00" report "Test ADDi: ALUCtr should be 00" severity error;
        assert ALUSrc_tb = '1' report "Test ADDi: ALUSrc should be 1" severity error;
        
        -- Test 4: CMP R1,#0x1A (E351001A)
        instruction_tb <= x"E351001A";
        wait for 10 ns;
        assert RegWr_tb = '0' report "Test CMP: RegWr should be 0" severity error;
        assert ALUCtr_tb = "10" report "Test CMP: ALUCtr should be 10" severity error;
        assert ALUSrc_tb = '1' report "Test CMP: ALUSrc should be 1" severity error;
        assert PSREn_tb = '1' report "Test CMP: PSREn should be 1" severity error;
        
        -- Test 5: BLT loop avec N=1 (BAFFFFFB)
        instruction_tb <= x"BAFFFFFB";
        N_tb <= '1';
        wait for 10 ns;
        assert nPC_SEL_tb = '1' report "Test BLT (N=1): nPC_SEL should be 1" severity error;
        assert RegWr_tb = '0' report "Test BLT: RegWr should be 0" severity error;
        
        -- Test 6: BLT loop avec N=0
        N_tb <= '0';
        wait for 10 ns;
        assert nPC_SEL_tb = '0' report "Test BLT (N=0): nPC_SEL should be 0" severity error;
        
        -- Test 7: LDR R0,0(R1) (E4110000)
        instruction_tb <= x"E4110000";
        wait for 10 ns;
        assert RegWr_tb = '1' report "Test LDR: RegWr should be 1" severity error;
        assert ALUCtr_tb = "00" report "Test LDR: ALUCtr should be 00" severity error;
        assert ALUSrc_tb = '1' report "Test LDR: ALUSrc should be 1" severity error;
        assert MemToReg_tb = '1' report "Test LDR: MemToReg should be 1" severity error;
        assert MemWr_tb = '0' report "Test LDR: MemWr should be 0" severity error;
        
        -- Test 8: STR R2,0(R1) (E4012000)
        instruction_tb <= x"E4012000";
        wait for 10 ns;
        assert RegWr_tb = '0' report "Test STR: RegWr should be 0" severity error;
        assert MemWr_tb = '1' report "Test STR: MemWr should be 1" severity error;
        assert ALUCtr_tb = "00" report "Test STR: ALUCtr should be 00" severity error;
        assert ALUSrc_tb = '1' report "Test STR: ALUSrc should be 1" severity error;
        assert RegAff_tb = '1' report "Test STR: RegAff should be 1" severity error;
        
        -- Test 9: BAL main (EAFFFFF7)
        instruction_tb <= x"EAFFFFF7";
        wait for 10 ns;
        assert nPC_SEL_tb = '1' report "Test BAL: nPC_SEL should be 1" severity error;
        assert RegWr_tb = '0' report "Test BAL: RegWr should be 0" severity error;
        
        report "All Decoder tests completed";
        wait;
    end process;
    
end architecture test;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MonocycleProcessor is
    port (
        CLK : in std_logic;
        Reset : in std_logic;
        RegAff : out std_logic_vector(31 downto 0)
    );
end entity MonocycleProcessor;

architecture structural of MonocycleProcessor is
    -- Declaration des composants
    component InstructionUnit is
        port (
            CLK : in std_logic;
            Reset : in std_logic;
            nPCsel : in std_logic;
            offset : in std_logic_vector(23 downto 0);
            Instruction : out std_logic_vector(31 downto 0)
        );
    end component;
    
    component ProcessingUnitFinal is
        port (
            CLK : in std_logic;
            Reset : in std_logic;
            RegWr : in std_logic;
            ALUSrc : in std_logic;
            ALUCtr : in std_logic_vector(1 downto 0);
            MemWr : in std_logic;
            MemToReg : in std_logic;
            RegSel : in std_logic;
            RA : in std_logic_vector(3 downto 0);
            RB : in std_logic_vector(3 downto 0);
            RW : in std_logic_vector(3 downto 0);
            Immediat : in std_logic_vector(7 downto 0);
            N : out std_logic;
            Z : out std_logic;
            BusB_out : out std_logic_vector(31 downto 0)
        );
    end component;
    
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
    
    -- Signaux internes de connexion
    signal Instruction : std_logic_vector(31 downto 0);
    signal nPC_SEL : std_logic;
    signal RegWr : std_logic;
    signal RegSel : std_logic;
    signal Rn, Rm, Rd : std_logic_vector(3 downto 0);
    signal ALUCtr : std_logic_vector(1 downto 0);
    signal ALUSrc : std_logic;
    signal MemWr : std_logic;
    signal WrSrc : std_logic;
    signal MemToReg : std_logic;
    signal N_ALU, Z_ALU : std_logic;
    signal N_PSR : std_logic;
    signal offset : std_logic_vector(23 downto 0);
    signal Immediat : std_logic_vector(7 downto 0);
    signal BusB_data : std_logic_vector(31 downto 0);
    
begin
    -- Extraction de l'offset depuis l'instruction (pour les branchements)
    offset <= Instruction(23 downto 0);
    
    -- Extraction de l'immediat depuis l'instruction (pour les operations avec immediat)
    Immediat <= Instruction(7 downto 0);
    
    -- Instanciation de l'unite de gestion des instructions
    Instruction_Unit: InstructionUnit port map (
        CLK => CLK,
        Reset => Reset,
        nPCsel => nPC_SEL,
        offset => offset,
        Instruction => Instruction
    );
    
    -- Instanciation de l'unite de traitement
    Processing_Unit: ProcessingUnitFinal port map (
        CLK => CLK,
        Reset => Reset,
        RegWr => RegWr,
        ALUSrc => ALUSrc,
        ALUCtr => ALUCtr,
        MemWr => MemWr,
        MemToReg => MemToReg,
        RegSel => RegSel,
        RA => Rn,
        RB => Rm,
        RW => Rd,
        Immediat => Immediat,
        N => N_ALU,
        Z => Z_ALU,
        BusB_out => BusB_data
    );
    
    -- Instanciation de l'unite de controle
    Control_Unit: ControlUnit port map (
        CLK => CLK,
        Reset => Reset,
        Instruction => Instruction,
        N_ALU => N_ALU,
        Z_ALU => Z_ALU,
        BusB => BusB_data,
        N => N_PSR,
        nPC_SEL => nPC_SEL,
        RegWr => RegWr,
        RegSel => RegSel,
        Rn => Rn,
        Rm => Rm,
        Rd => Rd,
        ALUCtr => ALUCtr,
        ALUSrc => ALUSrc,
        MemWr => MemWr,
        WrSrc => WrSrc,
        MemToReg => MemToReg,
        RegAff => RegAff
    );
    
end architecture structural;
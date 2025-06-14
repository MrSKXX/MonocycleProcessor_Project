library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ControlUnit is
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
end entity ControlUnit;

architecture structural of ControlUnit is
    component PSR_Register is
        port (
            CLK : in std_logic;
            Reset : in std_logic;
            WE : in std_logic;
            DATAIN : in std_logic_vector(31 downto 0);
            DATAOUT : out std_logic_vector(31 downto 0)
        );
    end component;

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

    signal PSR_OUT : std_logic_vector(31 downto 0);
    signal PSR_IN : std_logic_vector(31 downto 0);
    signal PSREn : std_logic;
    signal RegAff_control : std_logic;
    signal RegAff_stored : std_logic_vector(31 downto 0);
    signal WrSrc_internal : std_logic;

begin
    -- Registre PSR pour stocker les drapeaux
    PSR_Reg: PSR_Register port map (
        CLK => CLK,
        Reset => Reset,
        WE => PSREn,
        DATAIN => PSR_IN,
        DATAOUT => PSR_OUT
    );

    -- Construction de l'entree PSR avec les drapeaux ALU
    PSR_IN(31) <= N_ALU;  -- Flag N
    PSR_IN(30) <= Z_ALU;  -- Flag Z
    PSR_IN(29 downto 0) <= (others => '0');

    -- Sortie du flag N vers l'exterieur
    N <= PSR_OUT(31);

    -- Decodeur d'instructions
    Instruction_Decoder: Decoder port map (
        instruction => Instruction,
        RegPSR => PSR_OUT,
        nPC_SEL => nPC_SEL,
        PSREn => PSREn,
        RegWr => RegWr,
        RegSel => RegSel,
        Rn => Rn,
        Rm => Rm,
        Rd => Rd,
        ALUCtrl => ALUCtr,
        ALUSrc => ALUSrc,
        MemWr => MemWr,
        WrSrc => WrSrc_internal,
        RegAff => RegAff_control
    );

    -- Signal MemToReg derive de WrSrc pour compatibilite
    WrSrc <= WrSrc_internal;
    MemToReg <= WrSrc_internal;

    -- Gestion de l'affichage (registre synchrone)
    affichage_process: process(CLK, Reset)
    begin
        if Reset = '1' then
            RegAff_stored <= (others => '0');
        elsif rising_edge(CLK) then
            if RegAff_control = '1' then
                RegAff_stored <= BusB;
            end if;
        end if;
    end process;

    RegAff <= RegAff_stored;

end architecture structural;

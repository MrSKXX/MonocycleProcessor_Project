library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ControlUnit is
    port (
        CLK : in std_logic;
        Reset : in std_logic;
        
        -- Entrées
        Instruction : in std_logic_vector(31 downto 0);
        N_ALU : in std_logic;  -- Drapeau N de l'ALU
        Z_ALU : in std_logic;  -- Drapeau Z de l'ALU
        
        -- Sorties vers le registre PSR
        N : out std_logic;  -- Drapeau N mémorisé
        
        -- Signaux de contrôle pour l'unité de gestion des instructions
        nPC_SEL : out std_logic;
        
        -- Signaux de contrôle pour le banc de registres
        RegWr : out std_logic;
        RegSel : out std_logic;
        
        -- Adresses des registres
        Rn : out std_logic_vector(3 downto 0);
        Rm : out std_logic_vector(3 downto 0);
        Rd : out std_logic_vector(3 downto 0);
        
        -- Signaux de contrôle pour l'ALU
        ALUCtr : out std_logic_vector(1 downto 0);
        ALUSrc : out std_logic;
        
        -- Signaux de contrôle pour la mémoire de données
        MemWr : out std_logic;
        
        -- Signaux de contrôle pour les multiplexeurs
        WrSrc : out std_logic;
        MemToReg : out std_logic;
        
        -- Signal pour l'affichage
        RegAff : out std_logic_vector(31 downto 0)
    );
end entity ControlUnit;

architecture structural of ControlUnit is
    -- Déclaration des composants
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
            N : in std_logic;
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
    
    -- Signaux internes
    signal PSR_OUT : std_logic_vector(31 downto 0);
    signal PSR_IN : std_logic_vector(31 downto 0);
    signal PSREn : std_logic;
    signal RegAff_control : std_logic;
    
begin
    -- Instanciation du registre PSR
    PSR_Reg: PSR_Register port map (
        CLK => CLK,
        Reset => Reset,
        WE => PSREn,
        DATAIN => PSR_IN,
        DATAOUT => PSR_OUT
    );
    
    -- Construction du PSR_IN
    -- Les bits 31 et 30 sont respectivement les drapeaux N et Z
    PSR_IN(31) <= N_ALU;
    PSR_IN(30) <= Z_ALU;
    PSR_IN(29 downto 0) <= (others => '0');  -- Les autres bits sont à 0
    
    -- Sortie du drapeau N
    N <= PSR_OUT(31);
    
    -- Instanciation du décodeur
    Instruction_Decoder: Decoder port map (
        instruction => Instruction,
        N => PSR_OUT(31),
        nPC_SEL => nPC_SEL,
        PSREn => PSREn,
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
        RegAff => RegAff_control
    );
    
    -- Gestion du registre RegAff
    process(RegAff_control, PSR_OUT)
    begin
        if RegAff_control = '1' then
            RegAff <= PSR_OUT;  -- Afficher la valeur du PSR sur les LEDs
        else
            RegAff <= (others => '0');
        end if;
    end process;
    
end architecture structural;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity InstructionUnit is
    port (
        CLK : in std_logic;
        Reset : in std_logic;
        -- Entrée de contrôle
        nPCsel : in std_logic;
        -- Entrées des données
        offset : in std_logic_vector(23 downto 0);
        -- Sortie
        Instruction : out std_logic_vector(31 downto 0)
    );
end entity InstructionUnit;

architecture structural of InstructionUnit is
    -- Déclaration des composants
    component instruction_memory is
        port (
            PC : in std_logic_vector(31 downto 0);
            Instruction : out std_logic_vector(31 downto 0)
        );
    end component;
    
    component PC_Register is
        port (
            CLK : in std_logic;
            Reset : in std_logic;
            PC_in : in std_logic_vector(31 downto 0);
            PC_out : out std_logic_vector(31 downto 0)
        );
    end component;
    
    component SignExtend_24to32 is
        port (
            E : in std_logic_vector(23 downto 0);
            S : out std_logic_vector(31 downto 0)
        );
    end component;
    
    component PC_Update is
        port (
            PC : in std_logic_vector(31 downto 0);
            SignExtImm : in std_logic_vector(31 downto 0);
            nPCsel : in std_logic;
            Next_PC : out std_logic_vector(31 downto 0)
        );
    end component;
    
    -- Signaux internes
    signal PC_out : std_logic_vector(31 downto 0);
    signal Next_PC : std_logic_vector(31 downto 0);
    signal SignExtImm : std_logic_vector(31 downto 0);
    
begin
    -- Instanciation du registre PC
    PC_Reg: PC_Register port map (
        CLK => CLK,
        Reset => Reset,
        PC_in => Next_PC,
        PC_out => PC_out
    );
    
    -- Instanciation de l'extension de signe
    Sign_Ext: SignExtend_24to32 port map (
        E => offset,
        S => SignExtImm
    );
    
    -- Instanciation de l'unité de mise à jour du PC
    PC_Updater: PC_Update port map (
        PC => PC_out,
        SignExtImm => SignExtImm,
        nPCsel => nPCsel,
        Next_PC => Next_PC
    );
    
    -- Instanciation de la mémoire d'instructions
    Inst_Mem: instruction_memory port map (
        PC => PC_out,
        Instruction => Instruction
    );
    
end architecture structural;
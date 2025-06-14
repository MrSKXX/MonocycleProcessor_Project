library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Decoder is
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
end entity Decoder;

architecture simple of Decoder is
    type enum_instruction is (MOV, ADDi, ADDr, CMP, LDR, STR, BAL, BLT);
    signal instr_courante: enum_instruction;
begin
    
    -- Extraction des champs registres (toujours identique)
    Rn <= instruction(19 downto 16);
    Rm <= instruction(3 downto 0) when instr_courante /= STR else instruction(15 downto 12);
    Rd <= instruction(15 downto 12);
    
    -- Décodage simple et direct
    decode_process: process(instruction)
    begin
        instr_courante <= MOV; -- Par défaut
        
        -- Décodage par pattern exact
        case instruction(31 downto 20) is
            when x"E3A" => instr_courante <= MOV;    -- MOV Rd,#imm
            when x"E28" => instr_courante <= ADDi;   -- ADD Rd,Rn,#imm  
            when x"E08" => instr_courante <= ADDr;   -- ADD Rd,Rn,Rm
            when x"E35" => instr_courante <= CMP;    -- CMP Rn,#imm
            when x"E15" => instr_courante <= CMP;    -- CMP Rn,Rm
            when x"E41" => instr_courante <= LDR;    -- LDR Rd,[Rn]
            when x"E40" => instr_courante <= STR;    -- STR Rd,[Rn]
            when x"E59" => instr_courante <= LDR;    -- LDR variante
            when x"E58" => instr_courante <= STR;    -- STR variante
            when others =>
                -- Branchements (8 bits)
                case instruction(31 downto 24) is
                    when x"EA" => instr_courante <= BAL;  -- BAL
                    when x"BA" => instr_courante <= BLT;  -- BLT
                    when others => instr_courante <= MOV;
                end case;
        end case;
    end process;
    
    -- Génération signaux de contrôle
    control_process: process(instr_courante, RegPSR, instruction)
    begin
        -- Valeurs par défaut (sécurisées)
        nPC_SEL <= '0';
        PSREn <= '0';
        RegWr <= '0';
        RegSel <= '0';
        ALUCtrl <= "00";
        ALUSrc <= '0';
        MemWr <= '0';
        WrSrc <= '0';
        RegAff <= '0';
        
        case instr_courante is
            when MOV =>
                RegWr <= '1';
                ALUCtrl <= "01"; -- Pass B
                ALUSrc <= '1';   -- Immédiat
                
            when ADDi =>
                RegWr <= '1';
                ALUCtrl <= "00"; -- ADD
                ALUSrc <= '1';   -- Immédiat
                
            when ADDr =>
                RegWr <= '1';
                ALUCtrl <= "00"; -- ADD
                ALUSrc <= '0';   -- Registre
                
            when CMP =>
                PSREn <= '1';
                ALUCtrl <= "10"; -- SUB pour comparaison
                if instruction(25) = '1' then
                    ALUSrc <= '1'; -- CMP avec immédiat
                else
                    ALUSrc <= '0'; -- CMP avec registre
                end if;
                
            when LDR =>
                RegWr <= '1';
                ALUCtrl <= "00"; -- ADD pour calcul adresse
                ALUSrc <= '1';   -- Offset immédiat
                WrSrc <= '1';    -- Données viennent de la mémoire
                
            when STR =>
                MemWr <= '1';
                ALUCtrl <= "00"; -- ADD pour calcul adresse
                ALUSrc <= '1';   -- Offset immédiat
                RegSel <= '1';   -- Source = registre destination
                RegAff <= '1';   -- Déclencher affichage
                
            when BAL =>
                nPC_SEL <= '1';  -- Branchement inconditionnel
                
            when BLT =>
                if RegPSR(31) = '1' then -- Test flag N
                    nPC_SEL <= '1';
                else
                    nPC_SEL <= '0';
                end if;
                
            when others =>
                -- NOP : tous signaux à '0' (déjà fait par défaut)
                null;
        end case;
    end process;
    
end architecture simple;
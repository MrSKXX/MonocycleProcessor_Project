library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Decoder is
    port (
        -- Entrées
        instruction : in std_logic_vector(31 downto 0);
        N : in std_logic;  -- Drapeau N du registre d'état
        
        -- Signaux de contrôle pour l'unité de gestion des instructions
        nPC_SEL : out std_logic;
        
        -- Signaux de contrôle pour le registre PSR
        PSREn : out std_logic;
        
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
        RegAff : out std_logic
    );
end entity Decoder;

architecture behavioral of Decoder is
    -- Type énuméré pour les instructions
    type enum_instruction is (MOV, ADDi, ADDr, CMP, LDR, STR, BAL, BLT);
    signal instr_courante: enum_instruction;
begin
    -- Process pour déterminer l'instruction courante
    process(instruction)
    begin
        -- Par défaut, instruction inconnue
        instr_courante <= MOV; -- Valeur par défaut
        
        -- Déterminer l'instruction à partir du code d'opération
        case instruction(31 downto 28) is
            when "1110" =>
                -- Instructions sans condition
                case instruction(27 downto 26) is
                    when "00" =>
                        -- Instructions de traitement de données
                        case instruction(25) is
                            when '0' =>
                                -- Instructions avec registres
                                case instruction(24 downto 21) is
                                    when "0100" =>
                                        instr_courante <= ADDr; -- ADD avec registres
                                    when "1010" =>
                                        instr_courante <= CMP; -- CMP
                                    when others =>
                                        -- Autres instructions non implémentées
                                        instr_courante <= MOV;
                                end case;
                            when '1' =>
                                -- Instructions avec valeur immédiate
                                case instruction(24 downto 21) is
                                    when "0100" =>
                                        instr_courante <= ADDi; -- ADD avec immédiat
                                    when "1101" =>
                                        instr_courante <= MOV; -- MOV
                                    when others =>
                                        -- Autres instructions non implémentées
                                        instr_courante <= MOV;
                                end case;
                            when others =>
                                instr_courante <= MOV;
                        end case;
                    when "01" =>
                        -- Instructions de transfert de données
                        if instruction(20) = '1' then
                            instr_courante <= LDR; -- Chargement
                        else
                            instr_courante <= STR; -- Stockage
                        end if;
                    when "10" =>
                        -- Instructions de branchement
                        instr_courante <= BAL; -- Branchement inconditionnel
                    when others =>
                        instr_courante <= MOV;
                end case;
            when "1011" =>
                -- Branchement conditionnel - BLT
                instr_courante <= BLT;
            when others =>
                instr_courante <= MOV;
        end case;
    end process;
    
    -- Process pour générer les signaux de contrôle en fonction de l'instruction
    process(instr_courante, N, instruction)
    begin
        -- Valeurs par défaut
        nPC_SEL <= '0';
        PSREn <= '0';
        RegWr <= '0';
        RegSel <= '0';
        ALUCtr <= "00";
        ALUSrc <= '0';
        MemWr <= '0';
        WrSrc <= '0';
        MemToReg <= '0';
        RegAff <= '0';
        
        -- Extraction des adresses des registres
        Rn <= instruction(19 downto 16);
        Rm <= instruction(3 downto 0);
        Rd <= instruction(15 downto 12);
        
        -- Génération des signaux de contrôle en fonction de l'instruction
        case instr_courante is
            when MOV =>
                -- MOV Rd, #imm
                RegWr <= '1';     -- Écriture dans le registre
                ALUCtr <= "01";   -- Opération B (pass through)
                ALUSrc <= '1';    -- Utiliser l'immédiat
                
            when ADDi =>
                -- ADD Rd, Rn, #imm
                RegWr <= '1';     -- Écriture dans le registre
                ALUCtr <= "00";   -- Opération ADD
                ALUSrc <= '1';    -- Utiliser l'immédiat
                
            when ADDr =>
                -- ADD Rd, Rn, Rm
                RegWr <= '1';     -- Écriture dans le registre
                ALUCtr <= "00";   -- Opération ADD
                ALUSrc <= '0';    -- Utiliser le registre Rm
                
            when CMP =>
                -- CMP Rn, #imm ou CMP Rn, Rm
                PSREn <= '1';     -- Mise à jour des drapeaux
                ALUCtr <= "10";   -- Opération SUB
                if instruction(25) = '1' then
                    ALUSrc <= '1';  -- Utiliser l'immédiat
                else
                    ALUSrc <= '0';  -- Utiliser le registre Rm
                end if;
                
            when LDR =>
                -- LDR Rd, [Rn]
                RegWr <= '1';     -- Écriture dans le registre
                ALUCtr <= "00";   -- Opération ADD (pour calculer l'adresse)
                if instruction(25) = '0' then
                    -- Adressage immédiat
                    ALUSrc <= '1';   -- Utiliser l'immédiat
                else
                    -- Adressage par registre
                    ALUSrc <= '0';   -- Utiliser le registre Rm
                    RegSel <= '1';   -- Sélectionner Rm
                end if;
                MemToReg <= '1';  -- Utiliser la sortie de la mémoire
                
            when STR =>
                -- STR Rd, [Rn]
                MemWr <= '1';      -- Écriture en mémoire
                ALUCtr <= "00";    -- Opération ADD (pour calculer l'adresse)
                if instruction(25) = '0' then
                    -- Adressage immédiat
                    ALUSrc <= '1';   -- Utiliser l'immédiat
                else
                    -- Adressage par registre
                    ALUSrc <= '0';   -- Utiliser le registre Rm
                    RegSel <= '1';   -- Sélectionner Rm
                end if;
                RegAff <= '1';     -- Affichage de la valeur sur les LEDs
                
            when BAL =>
                -- BAL label
                nPC_SEL <= '1';    -- Saut
                
            when BLT =>
                -- BLT label
                if N = '1' then
                    nPC_SEL <= '1';  -- Saut si N = 1 (résultat négatif)
                end if;
                
            when others =>
                -- Instruction non reconnue ou non implémentée
                null;
        end case;
    end process;
end architecture behavioral;
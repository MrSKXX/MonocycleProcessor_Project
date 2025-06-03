library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Decoder is
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
end entity Decoder;

architecture behavioral of Decoder is
    type enum_instruction is (MOV, ADDi, ADDr, CMP, LDR, STR, BAL, BLT);
    signal instr_courante: enum_instruction;
begin
    process(instruction)
    begin
        instr_courante <= MOV;
        
        case instruction(31 downto 28) is
            when "1011" =>
                instr_courante <= BLT;
            when "1110" =>
                case instruction(27 downto 26) is
                    when "00" =>
                        case instruction(25) is
                            when '0' =>
                                case instruction(24 downto 21) is
                                    when "0100" => instr_courante <= ADDr;
                                    when "1010" => instr_courante <= CMP;
                                    when others => instr_courante <= MOV;
                                end case;
                            when '1' =>
                                case instruction(24 downto 21) is
                                    when "0100" => instr_courante <= ADDi;
                                    when "0101" => instr_courante <= CMP;
                                    when "1101" => instr_courante <= MOV;
                                    when others => instr_courante <= MOV;
                                end case;
                            when others => instr_courante <= MOV;
                        end case;
                    when "01" =>
                        if instruction(20) = '1' then
                            instr_courante <= LDR;
                        else
                            instr_courante <= STR;
                        end if;
                    when "10" =>
                        instr_courante <= BAL;
                    when others => instr_courante <= MOV;
                end case;
            when others => instr_courante <= MOV;
        end case;
    end process;
    
    process(instr_courante, N, N_ALU, instruction)
    begin
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
        
        if instr_courante = STR then
            Rn <= instruction(19 downto 16);
            Rm <= instruction(15 downto 12);
            Rd <= instruction(15 downto 12);
        else
            Rn <= instruction(19 downto 16);
            Rm <= instruction(3 downto 0);
            Rd <= instruction(15 downto 12);
        end if;
        
        case instr_courante is
            when MOV =>
                RegWr <= '1';
                ALUCtr <= "01";
                ALUSrc <= '1';
                
            when ADDi =>
                RegWr <= '1';
                ALUCtr <= "00";
                ALUSrc <= '1';
                
            when ADDr =>
                RegWr <= '1';
                ALUCtr <= "00";
                ALUSrc <= '0';
                
            when CMP =>
                PSREn <= '1';
                RegWr <= '0';
                ALUCtr <= "10";
                if instruction(25) = '1' then
                    ALUSrc <= '1';
                else
                    ALUSrc <= '0';
                end if;
                
            when LDR =>
                RegWr <= '1';
                ALUCtr <= "00";
                ALUSrc <= '1';
                MemToReg <= '1';
                
            when STR =>
                MemWr <= '1';
                ALUCtr <= "00";
                ALUSrc <= '1';
                RegSel <= '0';
                RegAff <= '1';
                
            when BAL =>
                nPC_SEL <= '1';
                
            when BLT =>
                if N = '1' then
                    nPC_SEL <= '1';
                else
                    nPC_SEL <= '0';
                end if;
                
            when others =>
                null;
        end case;
    end process;
end architecture behavioral;
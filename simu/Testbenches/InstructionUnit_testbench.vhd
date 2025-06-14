library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity InstructionUnit_testbench is
end entity InstructionUnit_testbench;

architecture test of InstructionUnit_testbench is
    -- D�claration du composant � tester
    component InstructionUnit is
        port (
            CLK : in std_logic;
            Reset : in std_logic;
            nPCsel : in std_logic;
            offset : in std_logic_vector(23 downto 0);
            Instruction : out std_logic_vector(31 downto 0)
        );
    end component;
    
    -- Signaux de test
    signal CLK_tb : std_logic := '0';
    signal Reset_tb : std_logic := '0';
    signal nPCsel_tb : std_logic := '0';
    signal offset_tb : std_logic_vector(23 downto 0) := (others => '0');
    signal Instruction_tb : std_logic_vector(31 downto 0);
    
    -- Constantes pour les tests
    constant CLK_PERIOD : time := 10 ns;
    
    -- ?? FONCTION DE CONVERSION POUR MODELSIM 2016
    function to_hex_string(value : std_logic_vector) return string is
        variable result : string(1 to value'length/4);
        variable temp : std_logic_vector(value'length-1 downto 0) := value;
        variable nibble : std_logic_vector(3 downto 0);
    begin
        for i in result'range loop
            nibble := temp(temp'length-1 downto temp'length-4);
            case nibble is
                when "0000" => result(i) := '0';
                when "0001" => result(i) := '1';
                when "0010" => result(i) := '2';
                when "0011" => result(i) := '3';
                when "0100" => result(i) := '4';
                when "0101" => result(i) := '5';
                when "0110" => result(i) := '6';
                when "0111" => result(i) := '7';
                when "1000" => result(i) := '8';
                when "1001" => result(i) := '9';
                when "1010" => result(i) := 'A';
                when "1011" => result(i) := 'B';
                when "1100" => result(i) := 'C';
                when "1101" => result(i) := 'D';
                when "1110" => result(i) := 'E';
                when "1111" => result(i) := 'F';
                when others => result(i) := 'X';
            end case;
            temp := temp(temp'length-5 downto 0) & "0000";
        end loop;
        return result;
    end function;
    
begin
    -- Instanciation du composant � tester
    UUT: InstructionUnit port map (
        CLK => CLK_tb,
        Reset => Reset_tb,
        nPCsel => nPCsel_tb,
        offset => offset_tb,
        Instruction => Instruction_tb
    );
    
    -- G�n�ration de l'horloge
    clk_process: process
    begin
        CLK_tb <= '0';
        wait for CLK_PERIOD/2;
        CLK_tb <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    -- ?? PROCESSUS DE TEST FINAL
    stimulus: process
    begin
        report "=== DEBUT TEST INSTRUCTIONUNIT FINAL ===";
        
        -- Reset initial
        Reset_tb <= '1';
        wait for CLK_PERIOD*2;
        Reset_tb <= '0';
        wait for CLK_PERIOD;
        
        -- ========================================
        -- PHASE 1: VALIDATION COMPLETE DES INSTRUCTIONS
        -- ========================================
        report "=== PHASE 1: VALIDATION SEQUENTIELLE COMPLETE ===";
        nPCsel_tb <= '0';
        
        -- PC = 0: MOV R1,#0x10
        wait for CLK_PERIOD;
        report "PC=0 (MOV R1,#16): " & to_hex_string(Instruction_tb);
        assert Instruction_tb = x"E3A01010" 
            report "ERREUR PC=0: Expected E3A01010, Got " & to_hex_string(Instruction_tb) severity error;
        
        -- PC = 1: MOV R2,#0x00
        wait for CLK_PERIOD;
        report "PC=1 (MOV R2,#0): " & to_hex_string(Instruction_tb);
        assert Instruction_tb = x"E3A02000" 
            report "ERREUR PC=1: Expected E3A02000, Got " & to_hex_string(Instruction_tb) severity error;
        
        -- PC = 2: LDR R0,0(R1)
        wait for CLK_PERIOD;
        report "PC=2 (LDR R0,0(R1)): " & to_hex_string(Instruction_tb);
        assert Instruction_tb = x"E4110000" 
            report "ERREUR PC=2: Expected E4110000, Got " & to_hex_string(Instruction_tb) severity error;
        
        -- PC = 3: ADD R2,R2,R0
        wait for CLK_PERIOD;
        report "PC=3 (ADD R2,R2,R0): " & to_hex_string(Instruction_tb);
        assert Instruction_tb = x"E0822000" 
            report "ERREUR PC=3: Expected E0822000, Got " & to_hex_string(Instruction_tb) severity error;
        
        -- PC = 4: ADD R1,R1,#1
        wait for CLK_PERIOD;
        report "PC=4 (ADD R1,R1,#1): " & to_hex_string(Instruction_tb);
        assert Instruction_tb = x"E2811001" 
            report "ERREUR PC=4: Expected E2811001, Got " & to_hex_string(Instruction_tb) severity error;
        
        -- PC = 5: CMP R1,#0x1A
        wait for CLK_PERIOD;
        report "PC=5 (CMP R1,#26): " & to_hex_string(Instruction_tb);
        assert Instruction_tb = x"E351001A" 
            report "ERREUR PC=5: Expected E351001A, Got " & to_hex_string(Instruction_tb) severity error;
        
        -- ?? PC = 6: BLT loop (INSTRUCTION CRITIQUE)
        wait for CLK_PERIOD;
        report "PC=6 (BLT loop - CRITIQUE): " & to_hex_string(Instruction_tb);
        assert Instruction_tb = x"BAFFFFFB" 
            report "ERREUR CRITIQUE PC=6: Expected BAFFFFFB, Got " & to_hex_string(Instruction_tb) severity error;
        
        if Instruction_tb = x"BAFFFFFB" then
            report "SUCCES: BLT INSTRUCTION CORRECTE EN MEMOIRE !";
        else
            report "ECHEC: BLT INSTRUCTION INCORRECTE - VERIFIER MEMOIRE !";
        end if;
        
        -- PC = 7: STR R2,0(R1)
        wait for CLK_PERIOD;
        report "PC=7 (STR R2,0(R1)): " & to_hex_string(Instruction_tb);
        assert Instruction_tb = x"E4012000" 
            report "ERREUR PC=7: Expected E4012000, Got " & to_hex_string(Instruction_tb) severity error;
        
        -- PC = 8: BAL main
        wait for CLK_PERIOD;
        report "PC=8 (BAL main): " & to_hex_string(Instruction_tb);
        assert Instruction_tb = x"EAFFFFF7" 
            report "ERREUR PC=8: Expected EAFFFFF7, Got " & to_hex_string(Instruction_tb) severity error;
        
        -- ========================================
        -- PHASE 2: TEST BRANCHEMENT BLT
        -- ========================================
        report "=== PHASE 2: TEST BRANCHEMENT BLT ===";
        
        -- Reset et positionnement � PC=6 (BLT)
        Reset_tb <= '1';
        wait for CLK_PERIOD;
        Reset_tb <= '0';
        nPCsel_tb <= '0'; -- Mode s�quentiel
        
        -- Avancer jusqu'� PC=6
        for i in 0 to 5 loop
            wait for CLK_PERIOD;
        end loop;
        
        -- V�rification position BLT
        report "Verification position BLT: " & to_hex_string(Instruction_tb);
        assert Instruction_tb = x"BAFFFFFB" 
            report "ERREUR: Pas a BLT au bon moment !" severity error;
        
        -- Analyse de l'offset BLT
        report "ANALYSE OFFSET BLT:";
        report "   Instruction complete: " & to_hex_string(Instruction_tb);
        report "   Offset (bits 23:0): " & to_hex_string(Instruction_tb(23 downto 0));
        report "   Offset decimal: " & integer'image(to_integer(signed(Instruction_tb(23 downto 0))));
        
        -- Test du branchement BLT
        -- PC actuel = 6, offset = -5
        -- Next_PC = PC + 1 + offset = 6 + 1 + (-5) = 2
        offset_tb <= Instruction_tb(23 downto 0); -- Offset r�el de l'instruction
        nPCsel_tb <= '1'; -- Activer le branchement
        wait for CLK_PERIOD;
        
        -- V�rification: retour � PC=2 (LDR)
        report "Apres branchement BLT: " & to_hex_string(Instruction_tb);
        if Instruction_tb = x"E4110000" then
            report "SUCCES: BRANCHEMENT BLT REUSSI ! Retour a PC=2 (LDR)";
        else
            report "ECHEC: BRANCHEMENT BLT RATE ! Attendu LDR (E4110000), Obtenu " & to_hex_string(Instruction_tb);
        end if;
        
        -- ========================================
        -- PHASE 3: TEST BRANCHEMENT BAL (REFERENCE)
        -- ========================================
        report "=== PHASE 3: TEST BRANCHEMENT BAL (REFERENCE) ===";
        
        -- Reset et positionnement � PC=8 (BAL)
        Reset_tb <= '1';
        wait for CLK_PERIOD;
        Reset_tb <= '0';
        nPCsel_tb <= '0';
        
        -- Avancer jusqu'� PC=8
        for i in 0 to 7 loop
            wait for CLK_PERIOD;
        end loop;
        
        -- Test BAL
        report "Test BAL: " & to_hex_string(Instruction_tb);
        offset_tb <= Instruction_tb(23 downto 0); -- FFFFF7 = -9
        nPCsel_tb <= '1';
        wait for CLK_PERIOD;
        
        if Instruction_tb = x"E3A01010" then
            report "SUCCES: BRANCHEMENT BAL REUSSI ! PC=0 (MOV R1)";
        else
            report "ECHEC: BRANCHEMENT BAL RATE ! Attendu MOV (E3A01010), Obtenu " & to_hex_string(Instruction_tb);
        end if;
        
        -- ========================================
        -- RESUME FINAL
        -- ========================================
        report "=== RESUME FINAL ===";
        report "Tests realises:";
        report "1. Validation de toutes les instructions (PC=0 a PC=8)";
        report "2. Test specifique instruction BLT";
        report "3. Test branchement BLT (PC=6 -> PC=2)";
        report "4. Test branchement BAL (PC=8 -> PC=0)";
        report "";
        report "Si tous les tests sont SUCCES:";
        report "- InstructionUnit est PARFAITEMENT fonctionnelle";
        report "- BLT devrait marcher sur FPGA";
        report "";
        report "Si des tests sont ECHEC:";
        report "- Verifier instruction_memory.vhd";
        report "- Verifier PC_Update.vhd";
        report "- Verifier SignExtend_24to32.vhd";
        
        report "=== FIN TEST INSTRUCTIONUNIT FINAL ===";
        wait; -- ARRET DEFINITIF
    end process;
    
end architecture test;
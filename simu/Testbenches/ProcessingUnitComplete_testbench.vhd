library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ProcessingUnitComplete_testbench is
end entity ProcessingUnitComplete_testbench;

architecture test of ProcessingUnitComplete_testbench is
    component ProcessingUnitComplete is
        port (
            CLK : in std_logic;
            Reset : in std_logic;
            RegWr : in std_logic;
            ALUSrc : in std_logic;
            ALUCtr : in std_logic_vector(1 downto 0);
            MemWr : in std_logic;
            MemToReg : in std_logic;
            RA : in std_logic_vector(3 downto 0);
            RB : in std_logic_vector(3 downto 0);
            RW : in std_logic_vector(3 downto 0);
            Immediat : in std_logic_vector(7 downto 0);
            N : out std_logic;
            Z : out std_logic
        );
    end component;
    
    signal CLK_tb : std_logic := '0';
    signal Reset_tb : std_logic := '0';
    signal RegWr_tb : std_logic := '0';
    signal ALUSrc_tb : std_logic := '0';
    signal ALUCtr_tb : std_logic_vector(1 downto 0) := "00";
    signal MemWr_tb : std_logic := '0';
    signal MemToReg_tb : std_logic := '0';
    signal RA_tb, RB_tb, RW_tb : std_logic_vector(3 downto 0) := (others => '0');
    signal Immediat_tb : std_logic_vector(7 downto 0) := (others => '0');
    signal N_tb, Z_tb : std_logic;
    
    constant CLK_PERIOD : time := 10 ns;
    constant R0 : std_logic_vector(3 downto 0) := "0000";
    constant R1 : std_logic_vector(3 downto 0) := "0001";
    constant R2 : std_logic_vector(3 downto 0) := "0010";
    constant R3 : std_logic_vector(3 downto 0) := "0011";
    constant R4 : std_logic_vector(3 downto 0) := "0100";
    constant R5 : std_logic_vector(3 downto 0) := "0101";
    constant R6 : std_logic_vector(3 downto 0) := "0110";
    constant R7 : std_logic_vector(3 downto 0) := "0111";
    constant R15 : std_logic_vector(3 downto 0) := "1111";
    constant ALU_ADD : std_logic_vector(1 downto 0) := "00";
    constant ALU_B : std_logic_vector(1 downto 0) := "01";
    constant ALU_SUB : std_logic_vector(1 downto 0) := "10";
    constant ALU_A : std_logic_vector(1 downto 0) := "11";
    
begin
    UUT: ProcessingUnitComplete port map (
        CLK => CLK_tb,
        Reset => Reset_tb,
        RegWr => RegWr_tb,
        ALUSrc => ALUSrc_tb,
        ALUCtr => ALUCtr_tb,
        MemWr => MemWr_tb,
        MemToReg => MemToReg_tb,
        RA => RA_tb,
        RB => RB_tb,
        RW => RW_tb,
        Immediat => Immediat_tb,
        N => N_tb,
        Z => Z_tb
    );
    
    clk_process: process
    begin
        CLK_tb <= '0';
        wait for CLK_PERIOD/2;
        CLK_tb <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    stimulus: process
    begin
        Reset_tb <= '1';
        wait for CLK_PERIOD*2;
        Reset_tb <= '0';
        wait for CLK_PERIOD;
        
        -- Test 1: L'addition de 2 registres - R(2) = R(15) + R(15)
        RA_tb <= R15;      
        RB_tb <= R15;     
        RW_tb <= R2;       
        ALUSrc_tb <= '0'; 
        ALUCtr_tb <= ALU_ADD; 
        RegWr_tb <= '1';   
        MemWr_tb <= '0';  
        MemToReg_tb <= '0'; 
        wait for CLK_PERIOD;
        
        -- Vérification: R2 devrait contenir 0x60 (0x30 + 0x30)
        RA_tb <= R2;      
        ALUCtr_tb <= ALU_A; 
        RegWr_tb <= '0';   
        wait for CLK_PERIOD/2;
        -- Le drapeau Z devrait être 0 (car R2 contient 0x60 ≠ 0)
        assert Z_tb = '0' report "Test 1 (R2 = R15 + R15) failed, Z should be 0" severity error;
        
        -- Test 2: L'addition d'un registre avec une valeur immédiate - R(3) = R(15) + 0x10
        RA_tb <= R15;      
        RW_tb <= R3;       
        Immediat_tb <= X"10"; 
        ALUSrc_tb <= '1'; 
        ALUCtr_tb <= ALU_ADD; 
        RegWr_tb <= '1';   
        wait for CLK_PERIOD;
        
        -- Vérification: R3 devrait contenir 0x40 (0x30 + 0x10)
        RA_tb <= R3;       
        ALUCtr_tb <= ALU_A; 
        RegWr_tb <= '0';   
        wait for CLK_PERIOD/2;
        -- Le drapeau Z devrait être 0 (car R3 contient 0x40 ≠ 0)
        assert Z_tb = '0' report "Test 2 (R3 = R15 + 0x10) failed, Z should be 0" severity error;
        
        -- Test 3: La soustraction de 2 registres - R(4) = R(2) - R(3)
        RA_tb <= R2;       
        RB_tb <= R3;       
        RW_tb <= R4;       
        ALUSrc_tb <= '0';  
        ALUCtr_tb <= ALU_SUB; 
        RegWr_tb <= '1';   
        wait for CLK_PERIOD;
        
        -- Vérification: R4 devrait contenir 0x20 (0x60 - 0x40)
        RA_tb <= R4;       
        ALUCtr_tb <= ALU_A; 
        RegWr_tb <= '0';   
        wait for CLK_PERIOD/2;
        -- Le drapeau Z devrait être 0 (car R4 contient 0x20 ≠ 0)
        assert Z_tb = '0' report "Test 3 (R4 = R2 - R3) failed, Z should be 0" severity error;
        
        -- Test 4: La soustraction d'une valeur immédiate à un registre - R(5) = R(2) - 0x60
        RA_tb <= R2;       
        RW_tb <= R5;       
        Immediat_tb <= X"60"; 
        ALUSrc_tb <= '1';  
        ALUCtr_tb <= ALU_SUB; 
        RegWr_tb <= '1';   
        wait for CLK_PERIOD;
        
        -- Vérification: R5 devrait contenir 0 (0x60 - 0x60)
        RA_tb <= R5;       
        ALUCtr_tb <= ALU_A; 
        RegWr_tb <= '0';   
        wait for CLK_PERIOD/2;
        -- Le drapeau Z devrait être 1 (car R5 contient 0)
        assert Z_tb = '1' report "Test 4 (R5 = R2 - 0x60) failed, Z should be 1" severity error;
        
        -- Test 5: La copie de la valeur d'un registre dans un autre registre - R(6) = R(2)
        RA_tb <= R2;       
        RW_tb <= R6;       
        ALUCtr_tb <= ALU_A; 
        RegWr_tb <= '1';   
        wait for CLK_PERIOD;
        
        -- Vérification: R6 devrait contenir 0x60 (comme R2)
        RA_tb <= R6;       -- Lire R6
        RB_tb <= R2;       -- Lire R2
        ALUCtr_tb <= ALU_SUB; -- Opération: SUB (pour vérifier l'égalité)
        RegWr_tb <= '0';   -- Désactiver l'écriture
        wait for CLK_PERIOD/2;
        -- Le drapeau Z devrait être 1 (car R6 - R2 = 0)
        assert Z_tb = '1' report "Test 5 (R6 = R2) failed, Z should be 1" severity error;
        
        -- Test 6: L'écriture d'un registre dans un mot de la mémoire - Mem(0) = R(2)
        RA_tb <= R0;       
        RB_tb <= R2;       
        ALUSrc_tb <= '0';  
        ALUCtr_tb <= ALU_A; 
        MemWr_tb <= '1';  
        RegWr_tb <= '0';   
        wait for CLK_PERIOD;
        
        -- Test 7: La lecture d'un mot de la mémoire dans un registre - R(7) = Mem(0)
        RA_tb <= R0;      
        RW_tb <= R7;       
        ALUSrc_tb <= '0';  
        ALUCtr_tb <= ALU_A; 
        MemWr_tb <= '0';   
        MemToReg_tb <= '1';
        RegWr_tb <= '1';   
        wait for CLK_PERIOD;
        
        -- Vérification: R7 devrait contenir 0x60 (comme R2)
        RA_tb <= R7;       
        RB_tb <= R2;       
        ALUCtr_tb <= ALU_SUB; 
        RegWr_tb <= '0';   
        MemToReg_tb <= '0'; 
        wait for CLK_PERIOD/2;
        -- Le drapeau Z devrait être 1 (car R7 - R2 = 0)
        assert Z_tb = '1' report "Test 7 (R7 = Mem(0) = R2) failed, Z should be 1" severity error;
        
        report "All tests completed";
        wait;
    end process;
    
end architecture test;
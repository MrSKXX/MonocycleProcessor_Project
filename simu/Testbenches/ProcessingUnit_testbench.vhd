library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ProcessingUnit_testbench is
end entity ProcessingUnit_testbench;

architecture test of ProcessingUnit_testbench is
    component ProcessingUnit is
        port (
            CLK : in std_logic;
            Reset : in std_logic;
            RegWr : in std_logic;
            RegSel : in std_logic;
            ALUCtr : in std_logic_vector(1 downto 0);
            RA : in std_logic_vector(3 downto 0);
            RB : in std_logic_vector(3 downto 0);
            RW : in std_logic_vector(3 downto 0);
            N : out std_logic;
            Z : out std_logic
        );
    end component;
    
    signal CLK_tb : std_logic := '0';
    signal Reset_tb : std_logic := '0';
    signal RegWr_tb : std_logic := '0';
    signal RegSel_tb : std_logic := '0';
    signal ALUCtr_tb : std_logic_vector(1 downto 0) := "00";
    signal RA_tb, RB_tb, RW_tb : std_logic_vector(3 downto 0) := (others => '0');
    signal N_tb, Z_tb : std_logic;
    
    constant CLK_PERIOD : time := 10 ns;
    constant R0 : std_logic_vector(3 downto 0) := "0000";
    constant R1 : std_logic_vector(3 downto 0) := "0001";
    constant R2 : std_logic_vector(3 downto 0) := "0010";
    constant R3 : std_logic_vector(3 downto 0) := "0011";
    constant R5 : std_logic_vector(3 downto 0) := "0101";
    constant R7 : std_logic_vector(3 downto 0) := "0111";
    constant R15 : std_logic_vector(3 downto 0) := "1111";
    constant ALU_ADD : std_logic_vector(1 downto 0) := "00";
    constant ALU_B : std_logic_vector(1 downto 0) := "01";
    constant ALU_SUB : std_logic_vector(1 downto 0) := "10";
    constant ALU_A : std_logic_vector(1 downto 0) := "11";
    
begin
    UUT: ProcessingUnit port map (
        CLK => CLK_tb,
        Reset => Reset_tb,
        RegWr => RegWr_tb,
        RegSel => RegSel_tb,
        ALUCtr => ALUCtr_tb,
        RA => RA_tb,
        RB => RB_tb,
        RW => RW_tb,
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
        wait for CLK_PERIOD;
        Reset_tb <= '0';
        wait for CLK_PERIOD;
        
        -- Test 1: R(1) = R(15) (Copie R15 dans R1)
        RA_tb <= R15;      
        ALUCtr_tb <= ALU_A; 
        RW_tb <= R1;      
        RegWr_tb <= '1';  
        wait for CLK_PERIOD;
                
        -- Vérification de R1 = R15
        RA_tb <= R1;     
        RB_tb <= R15;      
        ALUCtr_tb <= ALU_SUB; 
        RegWr_tb <= '0';  
        wait for CLK_PERIOD;
        assert Z_tb = '1' report "Test 1 (R1 = R15) failed" severity error;
        
        -- Test 2: R(1) = R(1) + R(15)
        RA_tb <= R1;    
        RB_tb <= R15;      
        ALUCtr_tb <= ALU_ADD; 
        RW_tb <= R1;       
        RegWr_tb <= '1'; 
        wait for CLK_PERIOD;
        
        -- Test 3: R(2) = R(1) + R(15)
        RA_tb <= R1;       
        RB_tb <= R15;      
        ALUCtr_tb <= ALU_ADD; 
        RW_tb <= R2;      
        RegWr_tb <= '1'; 
        wait for CLK_PERIOD;
        
        -- Test 4: R(3) = R(1) - R(15)
        RA_tb <= R1;      
        RB_tb <= R15;     
        ALUCtr_tb <= ALU_SUB; 
        RW_tb <= R3;       
        RegWr_tb <= '1';   
        wait for CLK_PERIOD;
        
        -- Test 5: R(5) = R(7) - R(15)
        RA_tb <= R15;     
        ALUCtr_tb <= ALU_A; 
        RW_tb <= R7;      
        RegWr_tb <= '1';  
        wait for CLK_PERIOD;
        
        -- R5 = R7 - R15
        RA_tb <= R7;       
        RB_tb <= R15;      
        ALUCtr_tb <= ALU_SUB; 
        RW_tb <= R5;      
        RegWr_tb <= '1';  
        wait for CLK_PERIOD;
        
        -- résultat de R5 = R7 - R15 (résultat attendu: 0)
        RA_tb <= R5;
        ALUCtr_tb <= ALU_A; 
        RegWr_tb <= '0';
        wait for CLK_PERIOD/2;
        assert Z_tb = '1' report "Test 5 (R5 = R7 - R15 = 0) failed" severity error;
        
        report "All tests completed";
        wait;
    end process;
    
end architecture test;
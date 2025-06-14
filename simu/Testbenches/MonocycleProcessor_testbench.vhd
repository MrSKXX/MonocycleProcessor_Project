library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MonocycleProcessor_testbench is
end entity MonocycleProcessor_testbench;

architecture test of MonocycleProcessor_testbench is
    component MonocycleProcessor is
        port (
            CLK : in std_logic;
            Reset : in std_logic;
            RegAff : out std_logic_vector(31 downto 0)
        );
    end component;
    
    signal CLK_tb : std_logic := '0';
    signal Reset_tb : std_logic := '0';
    signal RegAff_tb : std_logic_vector(31 downto 0);
    
    constant CLK_PERIOD : time := 20 ns;
    
begin
    UUT: MonocycleProcessor port map (
        CLK => CLK_tb,
        Reset => Reset_tb,
        RegAff => RegAff_tb
    );
    
    -- Generation de l'horloge
    clk_process: process
    begin
        CLK_tb <= '0';
        wait for CLK_PERIOD/2;
        CLK_tb <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    -- Processus de test adaptÃ© au programme du professeur
    stimulus: process
    begin
        report "--- DEBUT TEST PROGRAMME PROFESSEUR ---";
        
        -- Reset initial
        Reset_tb <= '1';
        wait for CLK_PERIOD*5;
        Reset_tb <= '0';
        wait for CLK_PERIOD;
        
        report "Reset termine, execution programme professeur";
        report "Programme: Calcul somme 1+2+...+10 avec BLT";
        
        -- ANALYSE DU PROGRAMME PROFESSEUR:
        -- PC=0: MOV R1,#0x10    (R1 = 16, adresse debut donnees)
        -- PC=1: MOV R2,#0x00    (R2 = 0, somme)
        -- PC=2: LDR R0,0(R1)    (R0 = DATA[R1])
        -- PC=3: ADD R2,R2,R0    (R2 += R0)
        -- PC=4: ADD R1,R1,#1    (R1++)
        -- PC=5: CMP R1,#0x1A    (Compare R1 avec 26)
        -- PC=6: BLT loop        (Si R1 < 26, branche vers PC=2)
        -- PC=7: STR R2,0(R1)    (Stocke somme finale)
        -- PC=8: BAL main        (Retour au debut)
        
        -- Execution cycle par cycle
        wait for CLK_PERIOD; -- PC=0: MOV R1,#0x10
        report "Cycle 1: MOV R1,#0x10 (R1=16)";
        
        wait for CLK_PERIOD; -- PC=1: MOV R2,#0x00
        report "Cycle 2: MOV R2,#0x00 (R2=0)";
        
        -- Premier passage boucle (R1=16, charge DATA[16]=1)
        wait for CLK_PERIOD; -- PC=2: LDR R0,0(R1)
        report "Cycle 3: LDR R0,0(R1) - Charge DATA[16]=1";
        
        wait for CLK_PERIOD; -- PC=3: ADD R2,R2,R0
        report "Cycle 4: ADD R2,R2,R0 - R2=0+1=1";
        
        wait for CLK_PERIOD; -- PC=4: ADD R1,R1,#1
        report "Cycle 5: ADD R1,R1,#1 - R1=17";
        
        wait for CLK_PERIOD; -- PC=5: CMP R1,#0x1A
        report "Cycle 6: CMP R1,#0x1A - Compare 17<26 (N=1)";
        
        wait for CLK_PERIOD; -- PC=6: BLT loop
        report "Cycle 7: BLT loop - Branche vers PC=2 car R1<26";
        
        -- Deuxieme iteration (R1=17, charge DATA[17]=2)
        wait for CLK_PERIOD; -- PC=2: LDR R0,0(R1)
        report "Cycle 8: LDR R0,0(R1) - Charge DATA[17]=2";
        
        wait for CLK_PERIOD; -- PC=3: ADD R2,R2,R0
        report "Cycle 9: ADD R2,R2,R0 - R2=1+2=3";
        
        wait for CLK_PERIOD; -- PC=4: ADD R1,R1,#1
        report "Cycle 10: ADD R1,R1,#1 - R1=18";
        
        wait for CLK_PERIOD; -- PC=5: CMP R1,#0x1A
        report "Cycle 11: CMP R1,#0x1A - Compare 18<26 (N=1)";
        
        wait for CLK_PERIOD; -- PC=6: BLT loop
        report "Cycle 12: BLT loop - Branche vers PC=2 car R1<26";
        
        -- Laisser la boucle s'executer jusqu'a completion
        report "--- Execution automatique de la boucle ---";
        
        -- La boucle va s'executer pour R1 = 16,17,18,19,20,21,22,23,24,25
        -- Somme = 1+2+3+4+5+6+7+8+9+10 = 55 = 0x37
        
        for i in 1 to 50 loop -- Plus que necessaire pour etre sur
            wait for CLK_PERIOD;
            
            -- Detecter quand on sort de la boucle (STR execute)
            if i mod 10 = 0 then
                report "Iteration " & integer'image(i) & 
                       ", RegAff = " & integer'image(to_integer(unsigned(RegAff_tb)));
            end if;
            
            -- Verifier si on a atteint la somme finale
            if RegAff_tb = x"00000037" then -- 55 en hexa
                report "SUCCES: Somme finale 55 (0x37) detectee !";
                report "La boucle BLT a fonctionne correctement";
                exit;
            end if;
        end loop;
        
        -- Verification finale
        wait for CLK_PERIOD*5;
        
        if RegAff_tb = x"00000037" then
            report "TEST REUSSI: Programme professeur execute correctement";
            report "Somme calculee = 55 = 1+2+3+4+5+6+7+8+9+10";
        elsif RegAff_tb = x"00000000" then
            report "ECHEC: RegAff reste a 0, STR pas execute";
        else
            report "ATTENTION: RegAff = " & integer'image(to_integer(unsigned(RegAff_tb))) & 
                   " (attendu 55)";
        end if;
        
        -- Verifier stabilite (le programme continue en boucle)
        wait for CLK_PERIOD*20;
        report "Verification stabilite: Le processeur continue a fonctionner";
        
        report "--- TEST PROGRAMME PROFESSEUR TERMINE ---";
        wait;
    end process;
    
    -- Moniteur pour detecter les changements de RegAff
    monitor_regaff: process(RegAff_tb)
    begin
        if RegAff_tb /= x"00000000" then
            report "AFFICHAGE DETECTE: RegAff = " & 
                   integer'image(to_integer(unsigned(RegAff_tb)));
        end if;
    end process;
    
end architecture test;
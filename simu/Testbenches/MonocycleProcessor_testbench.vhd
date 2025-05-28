library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MonocycleProcessor_testbench is
end entity MonocycleProcessor_testbench;

architecture test of MonocycleProcessor_testbench is
    -- Déclaration du composant à tester
    component MonocycleProcessor is
        port (
            CLK : in std_logic;
            Reset : in std_logic;
            RegAff : out std_logic_vector(31 downto 0)
        );
    end component;
    
    -- Signaux de test
    signal CLK_tb : std_logic := '0';
    signal Reset_tb : std_logic := '0';
    signal RegAff_tb : std_logic_vector(31 downto 0);
    
    -- Constantes pour les tests
    constant CLK_PERIOD : time := 10 ns;
    
begin
    -- Instanciation du composant à tester
    UUT: MonocycleProcessor port map (
        CLK => CLK_tb,
        Reset => Reset_tb,
        RegAff => RegAff_tb
    );
    
    -- Génération de l'horloge
    clk_process: process
    begin
        CLK_tb <= '0';
        wait for CLK_PERIOD/2;
        CLK_tb <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    -- Processus de test
    stimulus: process
    begin
        -- Reset initial
        Reset_tb <= '1';
        wait for CLK_PERIOD*3;
        Reset_tb <= '0';
        
        -- Laisser le programme s'exécuter
        -- Le programme de test fait une boucle qui :
        -- 1. Initialise R1 à 0x10 et R2 à 0
        -- 2. Lit des données de la mémoire à partir de l'adresse 0x10
        -- 3. Les additionne dans R2
        -- 4. Incrémente R1
        -- 5. Compare R1 avec 0x1A
        -- 6. Branche à la boucle si R1 < 0x1A
        -- 7. Stocke le résultat dans la mémoire
        -- 8. Branche au début
        
        -- Exécution du programme principal
        -- MOV R1,#0x10 (PC = 0)
        wait for CLK_PERIOD;
        
        -- MOV R2,#0 (PC = 1)
        wait for CLK_PERIOD;
        
        -- Début de la boucle
        -- LDR R0,0(R1) (PC = 2)
        wait for CLK_PERIOD;
        
        -- ADD R2,R2,R0 (PC = 3)
        wait for CLK_PERIOD;
        
        -- ADD R1,R1,#1 (PC = 4)
        wait for CLK_PERIOD;
        
        -- CMP R1,0x1A (PC = 5)
        wait for CLK_PERIOD;
        
        -- BLT loop (PC = 6) - Branchement conditionnel
        wait for CLK_PERIOD;
        
        -- La boucle va s'exécuter plusieurs fois
        -- Laisser suffisamment de temps pour que le programme termine
        wait for CLK_PERIOD * 200;
        
        -- Vérifier que le processeur fonctionne
        -- À ce stade, le programme devrait avoir calculé la somme
        -- des valeurs en mémoire de 0x10 à 0x19 et l'avoir stockée
        
        report "Program execution completed";
        wait;
    end process;
    
end architecture test;
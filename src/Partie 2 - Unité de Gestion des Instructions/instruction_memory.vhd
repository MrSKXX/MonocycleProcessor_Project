library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity instruction_memory is
    port(
        PC: in std_logic_vector(31 downto 0);
        Instruction: out std_logic_vector(31 downto 0)
    );
end entity;

architecture RTL of instruction_memory is
    type RAM64x32 is array(0 to 63) of std_logic_vector(31 downto 0);

    -- À remplacer dans instruction_memory.vhd
-- TEST POUR VÉRIFIER LES DRAPEAUX CMP

	function init_mem return RAM64x32 is
    variable result : RAM64x32;
begin
    result := (others => x"E3200000");  -- NOP par défaut
    
   -- ===== MAIN =====
     result (0):=x"E3A01010";-- MOV R1,#16    -- R1 = 0x10 (adresse début données)
    result (1):=x"E3A02000";-- MOV R2,#0     -- R2 = 0 (somme)
    
    -- ===== LOOP (sans BLT) =====
    result (2):=x"E5910000";-- LDR R0,0(R1)  -- R0 = DATA_MEM[R1] (lit la valeur)
    result (3):=x"E0822000";-- ADD R2,R2,R0  -- R2 = R2 + R0 (additionne à la somme)
    result (4):=x"E2811001";-- ADD R1,R1,#1  -- R1 = R1 + 1 (adresse suivante)
    
    -- ===== CMP (pour debug, sans effet) =====
    result (5):=x"E351001A";-- CMP R1,#26    -- Compare R1 avec 0x1A (26)
    
    -- ===== AFFICHAGE =====
    result (6):=x"E4022000";-- STR R2,0(R1)  -- Afficher somme actuelle
    
    -- ===== RETOUR AU LOOP (au lieu de BLT) =====
    result (7):=x"EAFFFFFA";-- BAL loop      -- Retour vers PC=2 (boucle infinie)
    return result;
end init_mem;

    signal mem: RAM64x32 := init_mem;
begin
    Instruction <= mem(to_integer(unsigned(PC(5 downto 0))));  -- 6 bits pour 64 adresses
end architecture;
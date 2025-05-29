library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity instruction_memory is
 port(
 PC: in std_logic_vector (31 downto 0);
 Instruction: out std_logic_vector (31 downto 0)
 );
end entity;
architecture RTL of instruction_memory is
 type RAM64x32 is array (0 to 63) of std_logic_vector (31 downto 0);

function init_mem return RAM64x32 is
 variable result : RAM64x32;
begin
for i in 63 downto 0 loop
 result (i):=(others=>'0');
end loop; 

-- ⭐ TEST BLT : Condition qui doit TOUJOURS être vraie
result (0):=x"E3A01001";-- 0x0 -- MOV R1,#0x01 -- R1 = 1
result (1):=x"E3A02001";-- 0x1 -- MOV R2,#0x01 -- R2 = 1  
result (2):=x"E4012000";-- 0x2 -- STR R2,0(R1) -- Afficher 1
result (3):=x"E3510010";-- 0x3 -- CMP R1,#0x10 -- R1(1) - 0x10(16) = -15 → N=1
result (4):=x"BA000001";-- 0x4 -- BLT +2 (vers PC=7) -- ⭐ Doit brancher car N=1
result (5):=x"E3A02005";-- 0x5 -- MOV R2,#0x05 -- ⚠️ IGNORÉ si BLT fonctionne
result (6):=x"E4012000";-- 0x6 -- STR R2,0(R1) -- ⚠️ IGNORÉ si BLT fonctionne  
result (7):=x"E3A0200A";-- 0x7 -- MOV R2,#0x0A -- R2 = 10 (destination BLT)
result (8):=x"E4012000";-- 0x8 -- STR R2,0(R1) -- Afficher 10

-- ⭐ LOGIQUE : R1=1, compare avec 0x10=16
-- Résultat : 1-16 = -15 (négatif) → Drapeau N=1 → BLT doit brancher

-- ⭐ RÉSULTAT ATTENDU SI BLT FONCTIONNE :
-- Séquence : 1 → A (saute le 5)

-- ⭐ RÉSULTAT SI BLT NE FONCTIONNE PAS :
-- Séquence : 1 → 5 → A (exécution séquentielle)

 return result;
end init_mem; 
signal mem: RAM64x32 := init_mem;
begin
 Instruction <= mem(to_integer(unsigned (PC)));
end architecture;
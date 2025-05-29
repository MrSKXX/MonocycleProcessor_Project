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
        
        -- ⭐ PROGRAMME ORIGINAL DU TP - PARTIE 4
        result (0):=x"E3A01010";-- 0x0 _main -- MOV R1,#0x10 -- R1 = 0x10
        result (1):=x"E3A02000";-- 0x1       -- MOV R2,#0x00 -- R2 = 0
        result (2):=x"E4110000";-- 0x2 _loop -- LDR R0,0(R1) -- R0 = DATAMEM[R1] 
        result (3):=x"E0822000";-- 0x3       -- ADD R2,R2,R0 -- R2 = R2 + R0
        result (4):=x"E2811001";-- 0x4       -- ADD R1,R1,#1 -- R1 = R1 + 1
        result (5):=x"E351001A";-- 0x5       -- CMP R1,0x1A  -- R1 - 0x1A, mise à jour de N
        result (6):=x"BAFFFFFB";-- 0x6       -- BLT loop     -- branchement à _loop si R1 < 0x1A
        result (7):=x"E4012000";-- 0x7 _end  -- STR R2,0(R1) -- DATAMEM[R1] = R2 (affichage)
        result (8):=x"EAFFFFF7";-- 0x8       -- BAL main     -- branchement à _main
        
        -- ⭐ LOGIQUE DU PROGRAMME :
        -- 1. R1 = 0x10 (16), R2 = 0 (somme)
        -- 2. Boucle : R0 = DATA_MEM[R1], R2 += R0, R1++
        -- 3. Continue tant que R1 < 0x1A (26)
        -- 4. Lit les valeurs de 0x10 à 0x19 (16 à 25)
        -- 5. Somme = 1+2+3+4+5+6+7+8+9+10 = 55 = 0x37
        -- 6. Affiche 0x37 via STR
        
        return result;
    end init_mem; 
    
    signal mem: RAM64x32 := init_mem;
    
begin
    Instruction <= mem(to_integer(unsigned (PC)));
end architecture;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PC_Update is
    port (
        PC : in std_logic_vector(31 downto 0);
        SignExtImm : in std_logic_vector(31 downto 0);
        nPCsel : in std_logic;
        Next_PC : out std_logic_vector(31 downto 0)
    );
end entity PC_Update;

architecture behavioral of PC_Update is
begin
    process(PC, SignExtImm, nPCsel)
    begin
        if nPCsel = '0' then
            -- PC = PC + 1 (exécution séquentielle)
            Next_PC <= std_logic_vector(unsigned(PC) + 1);
        else
            -- ⭐ CORRECTION CRITIQUE : PC = PC + 1 + SignExt(offset)
            -- Conversion correcte : tout en signed pour gérer les offsets négatifs
            Next_PC <= std_logic_vector(signed(PC) + 1 + signed(SignExtImm));
        end if;
    end process;
end architecture behavioral;
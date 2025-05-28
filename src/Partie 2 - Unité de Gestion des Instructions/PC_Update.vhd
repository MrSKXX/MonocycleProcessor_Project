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
            -- PC = PC + 1
            Next_PC <= std_logic_vector(unsigned(PC) + 1);
        else
            -- PC = PC + 1 + SignExt(offset)
            Next_PC <= std_logic_vector(unsigned(PC) + 1 + unsigned(SignExtImm));
        end if;
    end process;
end architecture behavioral;
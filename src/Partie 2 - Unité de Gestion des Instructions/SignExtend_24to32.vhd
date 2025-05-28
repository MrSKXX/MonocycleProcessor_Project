library IEEE;
use IEEE.std_logic_1164.all;

entity SignExtend_24to32 is
    port (
        E : in std_logic_vector(23 downto 0);
        S : out std_logic_vector(31 downto 0)
    );
end entity SignExtend_24to32;

architecture behavioral of SignExtend_24to32 is
begin
    process(E)
    begin
        S(23 downto 0) <= E;
        
        for i in 31 downto 24 loop
            S(i) <= E(23);  
        end loop;
    end process;
end architecture behavioral;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PC_Register is
    port (
        CLK : in std_logic;
        Reset : in std_logic;
        PC_in : in std_logic_vector(31 downto 0);
        PC_out : out std_logic_vector(31 downto 0)
    );
end entity PC_Register;

architecture behavioral of PC_Register is
begin
    process(CLK, Reset)
    begin
        if Reset = '1' then
            PC_out <= (others => '0');  
        elsif rising_edge(CLK) then
            PC_out <= PC_in;
        end if;
    end process;
end architecture behavioral;
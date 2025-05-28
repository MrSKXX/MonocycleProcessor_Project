library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU is
    port (
        OP : in std_logic_vector(1 downto 0);  
        A, B : in std_logic_vector(31 downto 0); 
        S : out std_logic_vector(31 downto 0); 
        N : out std_logic;  
        Z : out std_logic   
    );
end entity ALU;

architecture behavioral of ALU is
    signal result : std_logic_vector(31 downto 0);
begin
    process(OP, A, B)
    begin
        case OP is
            when "00" => 
                result <= std_logic_vector(unsigned(A) + unsigned(B));
            when "01" => 
                result <= B;
            when "10" => 
                result <= std_logic_vector(unsigned(A) - unsigned(B));
            when "11" => 
                result <= A;
            when others => 
                result <= (others => '0');
        end case;
    end process;
    
    S <= result;
    N <= result(31);  
    Z <= '1' when (unsigned(result) = 0) else '0';  
    
end architecture behavioral;
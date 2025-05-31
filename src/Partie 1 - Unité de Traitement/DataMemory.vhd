library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity DataMemory is
    port (
        CLK : in std_logic;
        Reset : in std_logic;
        DataIn : in std_logic_vector(31 downto 0);
        DataOut : out std_logic_vector(31 downto 0);
        Addr : in std_logic_vector(5 downto 0);
        WrEn : in std_logic
    );
end entity DataMemory;

architecture behavioral of DataMemory is
    type mem_array is array(0 to 63) of std_logic_vector(31 downto 0);
    
			 -- ⭐ DONNÉES ORIGINALES DU TP
			-- Dans DataMemory.vhd
		function init_mem return mem_array is
			 variable result : mem_array;
		begin
			 result := (others => (others => '0'));
			 
			 -- Données à sommer (1+2+...+10 = 55 = 0x37)
			 result(16) := x"00000001";  -- 0x10
			 result(17) := x"00000002";  -- 0x11
			 result(18) := x"00000003";  -- 0x12
			 result(19) := x"00000004";  -- 0x13
			 result(20) := x"00000005";  -- 0x14
			 result(21) := x"00000006";  -- 0x15
			 result(22) := x"00000007";  -- 0x16
			 result(23) := x"00000008";  -- 0x17
			 result(24) := x"00000009";  -- 0x18
			 result(25) := x"0000000A";  -- 0x19
			 
			 return result;
		end init_mem;
    
    signal memory: mem_array := init_mem;
    
begin
    DataOut <= memory(to_integer(unsigned(Addr)));
    
    write_process: process(CLK, Reset)
    begin
        if Reset = '1' then
            memory <= init_mem;
        elsif rising_edge(CLK) then
            if WrEn = '1' then
                memory(to_integer(unsigned(Addr))) <= DataIn;
            end if;
        end if;
    end process;
    
end architecture behavioral;
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
    
    function init_mem return RAM64x32 is
        variable result : RAM64x32;
    begin
	 for i in 63 downto 0 loop
        result (i):= (others => '0'); 
        end loop;
        result(0) := x"E3A01010"; -- PC=0 MOV R1,#0x10
        result(1) := x"E3A02000"; -- PC=1 MOV R2,#0x00
        result(2) := x"E4110000"; -- PC=2 LDR R0,0(R1) 
        result(3) := x"E0822000"; -- PC=3 ADD R2,R2,R0
        result(4) := x"E2811001"; -- PC=4 ADD R1,R1,#1
        result(5) := x"E351001A"; -- PC=5 CMP R1,0x1A
        result(6) := x"BAFFFFFB"; -- PC=6 BLT loop
        result(7) := x"E4012000"; -- PC=7 STR R2,0(R1) 
        result(8) := x"EAFFFFF7"; -- PC=8 BAL main
        
        return result;
    end init_mem;
    
    signal mem: RAM64x32 := init_mem;
    
begin
    Instruction <= mem(to_integer(unsigned(PC)));
end architecture;
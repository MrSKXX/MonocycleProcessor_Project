library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ProcessingUnit is
    port (
        CLK : in std_logic;
        Reset : in std_logic;
        RegWr : in std_logic;  
        RegSel : in std_logic; 
        ALUCtr : in std_logic_vector(1 downto 0);  
        RA : in std_logic_vector(3 downto 0);
        RB : in std_logic_vector(3 downto 0);
        RW : in std_logic_vector(3 downto 0);
        N : out std_logic;
        Z : out std_logic
    );
end entity ProcessingUnit;

architecture structural of ProcessingUnit is
    component ALU is
        port (
            OP : in std_logic_vector(1 downto 0);
            A, B : in std_logic_vector(31 downto 0);
            S : out std_logic_vector(31 downto 0);
            N : out std_logic;
            Z : out std_logic
        );
    end component;
    
    component RegisterBank is
        port (
            CLK : in std_logic;
            Reset : in std_logic;
            W : in std_logic_vector(31 downto 0);
            RA : in std_logic_vector(3 downto 0);
            RB : in std_logic_vector(3 downto 0);
            RW : in std_logic_vector(3 downto 0);
            WE : in std_logic;
            A : out std_logic_vector(31 downto 0);
            B : out std_logic_vector(31 downto 0)
        );
    end component;
    
    signal BusA, BusB : std_logic_vector(31 downto 0);
    signal BusW : std_logic_vector(31 downto 0);
    
begin
    Banc_Reg: RegisterBank port map (
        CLK => CLK,
        Reset => Reset,
        W => BusW,
        RA => RA,
        RB => RB,
        RW => RW,
        WE => RegWr,
        A => BusA,
        B => BusB
    );
    
    ALU_Unit: ALU port map (
        OP => ALUCtr,
        A => BusA,
        B => BusB,
        S => BusW,
        N => N,
        Z => Z
    );
    
end architecture structural;
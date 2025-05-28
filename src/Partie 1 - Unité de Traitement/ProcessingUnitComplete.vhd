library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ProcessingUnitComplete is
    port (
        CLK : in std_logic;
        Reset : in std_logic;
        RegWr : in std_logic;          
        ALUSrc : in std_logic;         
        ALUCtr : in std_logic_vector(1 downto 0);  
        MemWr : in std_logic;          
        MemToReg : in std_logic;       
        RA : in std_logic_vector(3 downto 0);
        RB : in std_logic_vector(3 downto 0);
        RW : in std_logic_vector(3 downto 0);
        Immediat : in std_logic_vector(7 downto 0);
        N : out std_logic;
        Z : out std_logic
    );
end entity ProcessingUnitComplete;

architecture structural of ProcessingUnitComplete is
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
    
    component Mux2v1 is
        generic (
            N : integer := 32
        );
        port (
            A, B : in std_logic_vector(N-1 downto 0);
            COM : in std_logic;
            S : out std_logic_vector(N-1 downto 0)
        );
    end component;
    
    component SignExtender is
        generic (
            N : integer := 8
        );
        port (
            E : in std_logic_vector(N-1 downto 0);
            S : out std_logic_vector(31 downto 0)
				);
    end component;
    
    component DataMemory is
        port (
            CLK : in std_logic;
            Reset : in std_logic;
            DataIn : in std_logic_vector(31 downto 0);
            DataOut : out std_logic_vector(31 downto 0);
            Addr : in std_logic_vector(5 downto 0);
            WrEn : in std_logic
        );
    end component;
    
    signal BusA, BusB : std_logic_vector(31 downto 0);
    signal ALUout : std_logic_vector(31 downto 0);
    signal DataOut : std_logic_vector(31 downto 0);
    signal BusW : std_logic_vector(31 downto 0);
    signal ImmExtended : std_logic_vector(31 downto 0);
    signal ALUin : std_logic_vector(31 downto 0);
    
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
    
    Imm_Extender: SignExtender 
        generic map (
            N => 8
        )
        port map (
            E => Immediat,
            S => ImmExtended
        );
    
    Mux_ALU: Mux2v1 
        generic map (
            N => 32
        )
        port map (
            A => BusB,
            B => ImmExtended,
            COM => ALUSrc,
            S => ALUin
        );
    
    ALU_Unit: ALU port map (
        OP => ALUCtr,
        A => BusA,
        B => ALUin,
        S => ALUout,
        N => N,
        Z => Z
    );
    
    Data_Mem: DataMemory port map (
        CLK => CLK,
        Reset => Reset,
        DataIn => BusB,
        DataOut => DataOut,
        Addr => ALUout(5 downto 0), 
        WrEn => MemWr
    );
    
    
    Mux_Mem: Mux2v1 
        generic map (
            N => 32
        )
        port map (
            A => ALUout,
            B => DataOut,
            COM => MemToReg,
            S => BusW
        );
    
end architecture structural;
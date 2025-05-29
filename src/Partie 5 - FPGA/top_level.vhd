library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top_level is
    port (
        CLOCK_50 : in std_logic;
        KEY : in std_logic_vector(1 downto 0);
        SW : in std_logic_vector(9 downto 0);
        HEX0 : out std_logic_vector(6 downto 0);
        HEX1 : out std_logic_vector(6 downto 0);
        HEX2 : out std_logic_vector(6 downto 0);
        HEX3 : out std_logic_vector(6 downto 0);
        LEDR : out std_logic_vector(9 downto 0)
    );
end entity top_level;

architecture archi of top_level is
    component MonocycleProcessor is
        port (
            CLK : in std_logic;
            Reset : in std_logic;
            RegAff : out std_logic_vector(31 downto 0)
        );
    end component;
    
    component SevenSegDecoder is
        port (
            input : in std_logic_vector(3 downto 0);
            output : out std_logic_vector(6 downto 0)
        );
    end component;
    
    signal Reset : std_logic;
    signal RegAff : std_logic_vector(31 downto 0);
    signal clk_div : std_logic;
    signal counter : unsigned(21 downto 0) := (others => '0');  -- Fréquence confortable
    
begin
    -- Gestion du reset (bouton KEY(0) inversé car les boutons sont actifs bas)
    Reset <= not KEY(0);
    
    -- Diviseur d'horloge pour avoir une fréquence observable
    process(CLOCK_50, Reset)
    begin
        if Reset = '1' then
            counter <= (others => '0');
            clk_div <= '0';
        elsif rising_edge(CLOCK_50) then
            counter <= counter + 1;
            if counter = 0 then
                clk_div <= not clk_div;
            end if;
        end if;
    end process;
    
    -- Instanciation du processeur monocycle
    Processor: MonocycleProcessor port map (
        CLK => clk_div,
        Reset => Reset,
        RegAff => RegAff
    );
    
    -- Instanciation des décodeurs 7 segments
    Decoder0: SevenSegDecoder port map (
        input => RegAff(3 downto 0),
        output => HEX0
    );
    
    Decoder1: SevenSegDecoder port map (
        input => RegAff(7 downto 4),
        output => HEX1
    );
    
    Decoder2: SevenSegDecoder port map (
        input => RegAff(11 downto 8),
        output => HEX2
    );
    
    Decoder3: SevenSegDecoder port map (
        input => RegAff(15 downto 12),
        output => HEX3
    );
    
    -- LEDs d'état et debug
    LEDR(9) <= Reset;                              -- État du reset
    LEDR(8) <= clk_div;                           -- Horloge du processeur
    LEDR(7) <= '1' when RegAff /= x"00000000" else '0';  -- RegAff actif
    
    -- LEDs de diagnostic BLT
    LEDR(6) <= '1' when RegAff = x"00000001" else '0';   -- "1" affiché
    LEDR(5) <= '1' when RegAff = x"00000005" else '0';   -- "5" affiché (ERREUR si BLT marche)
    LEDR(4) <= '1' when RegAff = x"0000000A" else '0';   -- "A" affiché (SUCCÈS si BLT marche)
    
    LEDR(3 downto 0) <= RegAff(3 downto 0);              -- Valeur hexadécimale directe
    
    -- ⭐ RÉSULTAT FINAL ATTENDU AVEC LE FIX NOP :
    -- HEX: 0001 → 000A → 0001 → 000A... (le 5 ne doit jamais apparaître)
    -- LEDR(6): Clignote (détection "1")
    -- LEDR(4): Clignote (détection "A") 
    -- LEDR(5): JAMAIS allumé (pas de "5" = BLT fonctionne)
    
end architecture archi;
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
    signal RegAff_captured : std_logic_vector(31 downto 0) := (others => '0');
    signal clk_div : std_logic;
    signal counter : unsigned(23 downto 0) := (others => '0'); -- Plus lent pour observer
    
begin
    -- Gestion du reset (bouton KEY(0) inverse car les boutons sont actifs bas)
    Reset <= not KEY(0);
    
    -- Diviseur d'horloge pour avoir une frequence observable
    -- Divise par 2^24 = ~16M, donc 50MHz -> ~3Hz
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
    
    -- LATCH pour capturer la valeur maximale de RegAff
    -- Necessaire car STR ne s'execute qu'une fois dans le programme
    capture_process: process(clk_div, Reset)
    begin
        if Reset = '1' then
            RegAff_captured <= (others => '0');
        elsif rising_edge(clk_div) then
            -- Capture toute valeur non-nulle (garde la plus recente)
            if RegAff /= x"00000000" then
                RegAff_captured <= RegAff;
            end if;
        end if;
    end process;
    
    -- Instanciation des decodeurs 7 segments (UTILISE RegAff_captured)
    Decoder0: SevenSegDecoder port map (
        input => RegAff_captured(3 downto 0),
        output => HEX0
    );
    
    Decoder1: SevenSegDecoder port map (
        input => RegAff_captured(7 downto 4),
        output => HEX1
    );
    
    Decoder2: SevenSegDecoder port map (
        input => RegAff_captured(11 downto 8),
        output => HEX2
    );
    
    Decoder3: SevenSegDecoder port map (
        input => RegAff_captured(15 downto 12),
        output => HEX3
    );
    
    -- LEDs d'etat et debug ADAPTE AU PROGRAMME PROFESSEUR
    LEDR(9) <= Reset;                              -- Etat du reset
    LEDR(8) <= clk_div;                           -- Horloge du processeur
    LEDR(7) <= '1' when RegAff_captured /= x"00000000" else '0';  -- RegAff capture actif
    
    -- LEDs de diagnostic pour le programme professeur (somme = 55)
    LEDR(6) <= '1' when RegAff_captured = x"00000037" else '0';   -- "55" affiche (SUCCES FINAL)
    LEDR(5) <= '1' when RegAff_captured = x"00000001" else '0';   -- "1" premiere iteration
    LEDR(4) <= '1' when RegAff_captured = x"00000003" else '0';   -- "3" deuxieme iteration
    LEDR(3) <= '1' when RegAff_captured = x"00000006" else '0';   -- "6" troisieme iteration
    LEDR(2) <= '1' when RegAff_captured = x"0000000A" else '0';   -- "10" quatrieme iteration
    
    -- LED pour detecter la progression
    LEDR(1) <= '1' when to_integer(unsigned(RegAff_captured)) > 20 else '0';  -- Somme > 20
    LEDR(0) <= '1' when to_integer(unsigned(RegAff_captured)) > 40 else '0';  -- Somme > 40
    
    -- COMPORTEMENT ATTENDU SUR FPGA:
    -- HEX3 HEX2 HEX1 HEX0 devrait afficher "0037" (55 en decimal)
    -- LEDR(6) devrait s'allumer quand le calcul est termine (et rester allume)
    -- LEDR(7) indique qu'une valeur a ete capturee
    -- Le latch garde la derniere valeur de RegAff meme si le programme redémarre
    
end architecture archi;
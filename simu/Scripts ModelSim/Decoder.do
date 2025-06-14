# Script ModelSim pour VOTRE Decoder sp�cifique
# Decoder.do - Version adapt�e

# Cr�er la biblioth�que de travail
vlib work

# Compiler les fichiers sources
vcom -93 -work work Decoder.vhd
vcom -93 -work work Decoder_testbench.vhd

# D�marrer la simulation
vsim -t ps work.Decoder_testbench

# Ajouter les signaux ADAPT�S � votre Decoder
add wave -divider "ENTR�ES"
add wave sim:/Decoder_testbench/Instruction_tb
add wave sim:/Decoder_testbench/RegPSR_tb
add wave -radix binary sim:/Decoder_testbench/RegPSR_tb(31)
add wave -label "N_flag" sim:/Decoder_testbench/RegPSR_tb(31)

add wave -divider "SORTIES CONTR�LE"
add wave sim:/Decoder_testbench/nPC_SEL_tb
add wave sim:/Decoder_testbench/PSREn_tb
add wave sim:/Decoder_testbench/RegWr_tb
add wave sim:/Decoder_testbench/RegSel_tb

add wave -divider "SORTIES ALU"
add wave -radix unsigned sim:/Decoder_testbench/ALUCtrl_tb
add wave sim:/Decoder_testbench/ALUSrc_tb

add wave -divider "SORTIES M�MOIRE"
add wave sim:/Decoder_testbench/MemWr_tb
add wave sim:/Decoder_testbench/WrSrc_tb
add wave sim:/Decoder_testbench/RegAff_tb

add wave -divider "D�CODAGE INTERNE"
add wave sim:/Decoder_testbench/UUT/instr_courante

# Configuration de l'affichage
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -timelineunits ns

# Lancer la simulation
run 200ns

# Zoomer pour voir tous les signaux
wave zoom full

echo "======================================"
echo "Simulation Decoder termin�e"
echo "======================================"
echo "V�rifiez les signaux pour chaque test :"
echo "10ns  : MOV R1,#0x10"
echo "20ns  : ADD R2,R2,R0 (ADDr)"
echo "30ns  : ADD R1,R1,#1 (ADDi)"
echo "40ns  : CMP R1,#0x1A"
echo "50ns  : BLT avec N=1"
echo "60ns  : BLT avec N=0"
echo "70ns  : LDR R0,0(R1)"
echo "80ns  : STR original (E4012000) - DEVRAIT �CHOUER"
echo "90ns  : STR correct (E6002000) - DEVRAIT MARCHER"
echo "100ns : BAL main"
echo "======================================"
echo "IMPORTANT : RegAff doit �tre '1' SEULEMENT � 90ns"
echo "Si RegAff='1' � 80ns, votre Decoder a un probl�me"
echo "Si RegAff='0' � 90ns, v�rifiez le pattern STR"
echo "======================================"
# Script ModelSim pour tester ControlUnit complet
# ControlUnit.do

# Créer la bibliothèque de travail
vlib work

# Compiler tous les fichiers nécessaires
vcom -93 -work work PSR_Register.vhd
vcom -93 -work work Decoder.vhd
vcom -93 -work work ControlUnit.vhd
vcom -93 -work work ControlUnit_testbench.vhd

# Démarrer la simulation
vsim -t ps work.ControlUnit_testbench

# Ajouter les signaux principaux
add wave -divider "HORLOGE ET RESET"
add wave sim:/ControlUnit_testbench/CLK_tb
add wave sim:/ControlUnit_testbench/Reset_tb

add wave -divider "ENTRÉES"
add wave sim:/ControlUnit_testbench/Instruction_tb
add wave sim:/ControlUnit_testbench/N_ALU_tb
add wave sim:/ControlUnit_testbench/Z_ALU_tb
add wave sim:/ControlUnit_testbench/BusB_tb

add wave -divider "SORTIES CONTRÔLE"
add wave sim:/ControlUnit_testbench/nPC_SEL_tb
add wave sim:/ControlUnit_testbench/RegWr_tb
add wave sim:/ControlUnit_testbench/RegSel_tb
add wave sim:/ControlUnit_testbench/MemWr_tb

add wave -divider "SORTIES ALU"
add wave -radix unsigned sim:/ControlUnit_testbench/ALUCtr_tb
add wave sim:/ControlUnit_testbench/ALUSrc_tb

add wave -divider "ADRESSES REGISTRES"
add wave -radix unsigned sim:/ControlUnit_testbench/Rn_tb
add wave -radix unsigned sim:/ControlUnit_testbench/Rm_tb
add wave -radix unsigned sim:/ControlUnit_testbench/Rd_tb

add wave -divider "PSR ET DRAPEAUX"
add wave sim:/ControlUnit_testbench/N_tb
add wave sim:/ControlUnit_testbench/UUT/PSR_OUT

add wave -divider "AFFICHAGE"
add wave sim:/ControlUnit_testbench/RegAff_tb
add wave sim:/ControlUnit_testbench/UUT/RegAff_control
add wave sim:/ControlUnit_testbench/UUT/RegAff_stored

add wave -divider "DÉCODAGE INTERNE"
add wave sim:/ControlUnit_testbench/UUT/Instruction_Decoder/instr_courante

# Configuration de l'affichage
configure wave -namecolwidth 300
configure wave -valuecolwidth 120
configure wave -timelineunits ns

# Lancer la simulation
run 200ns

# Zoomer pour voir tous les signaux
wave zoom full

echo "======================================"
echo "Simulation ControlUnit terminée"
echo "======================================"
echo "Tests à vérifier :"
echo "20ns  : MOV - RegWr=1, ALUCtr=01"
echo "40ns  : CMP - PSR mis à jour avec N=1"
echo "60ns  : BLT - nPC_SEL=1 (branchement)"
echo "80ns  : STR - RegAff_control=1"
echo "90ns  : STR - RegAff=0x37 (affiché)"
echo "120ns : ADD - RegAff reste 0x37"
echo "140ns : Reset - RegAff=0"
echo "180ns : STR final - RegAff=0x7F"
echo "======================================"
echo "POINTS CLÉS À VÉRIFIER :"
echo "1. PSR_OUT se met à jour après CMP"
echo "2. RegAff_control='1' seulement pour STR"
echo "3. RegAff_stored garde la valeur entre STR"
echo "4. Reset remet RegAff à 0"
echo "5. Extraction Rn,Rm,Rd correcte"
echo "======================================"
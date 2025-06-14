# Script de simulation ModelSim pour le processeur complet
# Cr�ation de la biblioth�que de travail
vlib work

# Compilation des fichiers VHDL dans l'ordre des d�pendances
echo "Compilation des modules de base..."
vcom -93 -work work ALU.vhd
vcom -93 -work work RegisterBank.vhd
vcom -93 -work work Mux2v1.vhd
vcom -93 -work work SignExtender.vhd
vcom -93 -work work DataMemory.vhd
vcom -93 -work work ProcessingUnitFinal.vhd

echo "Compilation de l'unit� d'instructions..."
vcom -93 -work work instruction_memory.vhd
vcom -93 -work work PC_Register.vhd
vcom -93 -work work SignExtend_24to32.vhd
vcom -93 -work work PC_Update.vhd
vcom -93 -work work InstructionUnit.vhd

echo "Compilation de l'unit� de contr�le..."
vcom -93 -work work PSR_Register.vhd
vcom -93 -work work Decoder.vhd
vcom -93 -work work ControlUnit.vhd

echo "Compilation du processeur complet..."
vcom -93 -work work MonocycleProcessor.vhd
vcom -93 -work work MonocycleProcessor_testbench.vhd

# Chargement du testbench
echo "Chargement du testbench..."
vsim -t 1ns work.MonocycleProcessor_testbench

# Configuration de la fen�tre des signaux
configure wave -namecolwidth 300
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0

# Ajout des signaux principaux (CORRIGES)
add wave -divider "SIGNAUX PRINCIPAUX"
add wave -position insertpoint \
sim:/MonocycleProcessor_testbench/CLK_tb \
sim:/MonocycleProcessor_testbench/Reset_tb

# Signaux internes du processeur (CORRIGES)
add wave -divider "CONTROLE PROCESSEUR"
add wave -position insertpoint \
sim:/MonocycleProcessor_testbench/UUT/Instruction \
sim:/MonocycleProcessor_testbench/UUT/nPC_SEL

# Unit� d'instructions (CORRIGES)
add wave -divider "UNITE INSTRUCTIONS"
add wave -position insertpoint \
sim:/MonocycleProcessor_testbench/UUT/Instruction_Unit/PC_out \
sim:/MonocycleProcessor_testbench/UUT/offset

# Signaux de l'ALU (CORRIGES)
add wave -divider "ALU ET DRAPEAUX"
add wave -position insertpoint \
sim:/MonocycleProcessor_testbench/UUT/N_ALU \
sim:/MonocycleProcessor_testbench/UUT/Z_ALU \
sim:/MonocycleProcessor_testbench/UUT/N_PSR

# Signaux de contr�le (CORRIGES)
add wave -divider "SIGNAUX CONTROLE"
add wave -position insertpoint \
sim:/MonocycleProcessor_testbench/UUT/RegWr \
sim:/MonocycleProcessor_testbench/UUT/ALUCtr \
sim:/MonocycleProcessor_testbench/UUT/ALUSrc \
sim:/MonocycleProcessor_testbench/UUT/MemWr

# Adresses registres (CORRIGES)
add wave -divider "ADRESSES REGISTRES"
add wave -position insertpoint \
sim:/MonocycleProcessor_testbench/UUT/Rn \
sim:/MonocycleProcessor_testbench/UUT/Rm \
sim:/MonocycleProcessor_testbench/UUT/Rd

# Unit� de traitement (CORRIGES)
add wave -divider "UNITE DE TRAITEMENT"
add wave -position insertpoint \
sim:/MonocycleProcessor_testbench/UUT/Processing_Unit/BusA \
sim:/MonocycleProcessor_testbench/UUT/Processing_Unit/BusB_out \
sim:/MonocycleProcessor_testbench/UUT/Processing_Unit/ALUout

# Registres importants (CORRIGES)
add wave -divider "REGISTRES (R0, R1, R2)"
add wave -radix decimal -position insertpoint \
sim:/MonocycleProcessor_testbench/UUT/Processing_Unit/Banc_Reg/Banc(0) \
sim:/MonocycleProcessor_testbench/UUT/Processing_Unit/Banc_Reg/Banc(1) \
sim:/MonocycleProcessor_testbench/UUT/Processing_Unit/Banc_Reg/Banc(2)

# M�moire de donn�es (CORRIGES)
add wave -divider "MEMOIRE DE DONNEES"
add wave -radix decimal -position insertpoint \
sim:/MonocycleProcessor_testbench/UUT/Processing_Unit/Data_Mem/memory(16) \
sim:/MonocycleProcessor_testbench/UUT/Processing_Unit/Data_Mem/memory(17) \
sim:/MonocycleProcessor_testbench/UUT/Processing_Unit/Data_Mem/memory(18) \
sim:/MonocycleProcessor_testbench/UUT/Processing_Unit/Data_Mem/memory(19) \
sim:/MonocycleProcessor_testbench/UUT/Processing_Unit/Data_Mem/memory(20)

# R�SULTAT FINAL (SANS ROUGE)
add wave -divider "RESULTAT FINAL"
add wave -radix decimal -position insertpoint \
sim:/MonocycleProcessor_testbench/RegAff_tb

# Ex�cution de la simulation
echo "D�marrage de la simulation..."
run 2000 ns

# Zoom pour voir tous les signaux
wave zoom full

# Messages de contr�le
echo "=== VERIFICATION DU RESULTAT ==="
echo "RegAff devrait afficher 55 (0x37 en hexa)"
echo "Si RegAff = 0, probl�me avec STR"
echo "Si RegAff != 55, v�rifier calcul somme"
echo "Valeurs attendues dans les registres:"
echo "- R1: doit �voluer de 16 � 26"
echo "- R2: doit contenir la somme progressive"
echo "- R0: contient la derni�re valeur lue"

# Commandes utiles pour debug
echo "=== COMMANDES UTILES ==="
echo "Pour relancer: restart -f; run 2000 ns"
echo "Pour voir tous les registres:"
echo "examine -radix decimal sim:/MonocycleProcessor_testbench/UUT/Processing_Unit/Banc_Reg/Banc"
echo "Pour voir la m�moire de donn�es:"
echo "examine -radix decimal sim:/MonocycleProcessor_testbench/UUT/Processing_Unit/Data_Mem/memory"
echo "Pour voir la m�moire d'instructions:"
echo "examine -radix hex sim:/MonocycleProcessor_testbench/UUT/Instruction_Unit/Inst_Mem/mem"
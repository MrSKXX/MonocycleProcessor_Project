# Script de simulation ModelSim pour le processeur complet

# Création de la bibliothèque de travail
vlib work

# Compilation des fichiers VHDL dans l'ordre des dépendances
vcom -93 -work work ALU.vhd
vcom -93 -work work RegisterBank.vhd
vcom -93 -work work Mux2v1.vhd
vcom -93 -work work SignExtender.vhd
vcom -93 -work work DataMemory.vhd
vcom -93 -work work ProcessingUnitFinal.vhd

vcom -93 -work work instruction_memory.vhd
vcom -93 -work work PC_Register.vhd
vcom -93 -work work SignExtend_24to32.vhd
vcom -93 -work work PC_Update.vhd
vcom -93 -work work InstructionUnit.vhd

vcom -93 -work work PSR_Register.vhd
vcom -93 -work work Decoder.vhd
vcom -93 -work work ControlUnit.vhd

vcom -93 -work work MonocycleProcessor.vhd
vcom -93 -work work MonocycleProcessor_testbench.vhd

# Chargement du testbench
vsim -t 1ns work.MonocycleProcessor_testbench

# Ajout des signaux à observer
add wave -position insertpoint \
sim:/MonocycleProcessor_testbench/CLK_tb \
sim:/MonocycleProcessor_testbench/Reset_tb \
sim:/MonocycleProcessor_testbench/RegAff_tb

# Signaux internes du processeur
add wave -position insertpoint \
sim:/MonocycleProcessor_testbench/UUT/Instruction \
sim:/MonocycleProcessor_testbench/UUT/nPC_SEL \
sim:/MonocycleProcessor_testbench/UUT/Instruction_Unit/PC_out \
sim:/MonocycleProcessor_testbench/UUT/Processing_Unit/BusA \
sim:/MonocycleProcessor_testbench/UUT/Processing_Unit/BusB \
sim:/MonocycleProcessor_testbench/UUT/Processing_Unit/ALUout \
sim:/MonocycleProcessor_testbench/UUT/N_ALU \
sim:/MonocycleProcessor_testbench/UUT/Z_ALU

# Quelques registres du banc pour voir l'évolution
add wave -position insertpoint \
sim:/MonocycleProcessor_testbench/UUT/Processing_Unit/Banc_Reg/Banc(0) \
sim:/MonocycleProcessor_testbench/UUT/Processing_Unit/Banc_Reg/Banc(1) \
sim:/MonocycleProcessor_testbench/UUT/Processing_Unit/Banc_Reg/Banc(2)

# Exécution de la simulation
run 2000 ns

# Zoom pour voir tous les signaux
wave zoom full
# Script de simulation ModelSim pour l'unité de contrôle

# Création de la bibliothèque de travail
vlib work

# Compilation des fichiers VHDL
vcom -93 -work work PSR_Register.vhd
vcom -93 -work work Decoder.vhd
vcom -93 -work work ControlUnit.vhd
vcom -93 -work work ControlUnit_testbench.vhd

# Chargement du testbench
vsim -t 1ns work.ControlUnit_testbench

# Ajout des signaux à observer dans la fenêtre de forme d'onde
add wave -position insertpoint \
sim:/ControlUnit_testbench/CLK_tb \
sim:/ControlUnit_testbench/Reset_tb \
sim:/ControlUnit_testbench/Instruction_tb \
sim:/ControlUnit_testbench/N_ALU_tb \
sim:/ControlUnit_testbench/Z_ALU_tb \
sim:/ControlUnit_testbench/N_tb \
sim:/ControlUnit_testbench/nPC_SEL_tb \
sim:/ControlUnit_testbench/RegWr_tb \
sim:/ControlUnit_testbench/RegSel_tb \
sim:/ControlUnit_testbench/Rn_tb \
sim:/ControlUnit_testbench/Rm_tb \
sim:/ControlUnit_testbench/Rd_tb \
sim:/ControlUnit_testbench/ALUCtr_tb \
sim:/ControlUnit_testbench/ALUSrc_tb \
sim:/ControlUnit_testbench/MemWr_tb \
sim:/ControlUnit_testbench/WrSrc_tb \
sim:/ControlUnit_testbench/MemToReg_tb \
sim:/ControlUnit_testbench/RegAff_tb

# Exécution de la simulation pendant une durée suffisante
run 200 ns

# Zoom pour voir tous les signaux
wave zoom full
# Script de simulation ModelSim pour l'ALU

# Cr�ation de la biblioth�que de travail
vlib work

# Compilation des fichiers VHDL
vcom -93 -work work ALU.vhd
vcom -93 -work work ALU_testbench.vhd

# Chargement du testbench
vsim -t 1ns work.ALU_testbench

# Ajout des signaux � observer dans la fen�tre de forme d'onde
add wave -position insertpoint \
sim:/ALU_testbench/UUT/OP \
sim:/ALU_testbench/UUT/A \
sim:/ALU_testbench/UUT/B \
sim:/ALU_testbench/UUT/S \
sim:/ALU_testbench/UUT/N \
sim:/ALU_testbench/UUT/Z

# Ex�cution de la simulation pendant une dur�e suffisante
run 100 ns

# Zoom pour voir tous les signaux
wave zoom full
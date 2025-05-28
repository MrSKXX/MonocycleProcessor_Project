# Script de simulation ModelSim pour l'extension de signe

# Cr�ation de la biblioth�que de travail
vlib work

# Compilation des fichiers VHDL
vcom -93 -work work SignExtender.vhd
vcom -93 -work work SignExtender_testbench.vhd

# Chargement du testbench
vsim -t 1ns work.SignExtender_testbench

# Ajout des signaux � observer dans la fen�tre de forme d'onde
add wave -position insertpoint \
sim:/SignExtender_testbench/E_tb \
sim:/SignExtender_testbench/S_tb

# Ex�cution de la simulation pendant une dur�e suffisante
run 40 ns

# Zoom pour voir tous les signaux
wave zoom full
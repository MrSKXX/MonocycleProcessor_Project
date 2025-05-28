# Script de simulation ModelSim pour l'extension de signe

# Création de la bibliothèque de travail
vlib work

# Compilation des fichiers VHDL
vcom -93 -work work SignExtender.vhd
vcom -93 -work work SignExtender_testbench.vhd

# Chargement du testbench
vsim -t 1ns work.SignExtender_testbench

# Ajout des signaux à observer dans la fenêtre de forme d'onde
add wave -position insertpoint \
sim:/SignExtender_testbench/E_tb \
sim:/SignExtender_testbench/S_tb

# Exécution de la simulation pendant une durée suffisante
run 40 ns

# Zoom pour voir tous les signaux
wave zoom full
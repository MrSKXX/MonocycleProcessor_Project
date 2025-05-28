# Script de simulation ModelSim pour le multiplexeur 2 vers 1

# Création de la bibliothèque de travail
vlib work

# Compilation des fichiers VHDL
vcom -93 -work work Mux2v1.vhd
vcom -93 -work work Mux2v1_testbench.vhd

# Chargement du testbench
vsim -t 1ns work.Mux2v1_testbench

# Ajout des signaux à observer dans la fenêtre de forme d'onde
add wave -position insertpoint \
sim:/Mux2v1_testbench/A_tb \
sim:/Mux2v1_testbench/B_tb \
sim:/Mux2v1_testbench/COM_tb \
sim:/Mux2v1_testbench/S_tb

# Exécution de la simulation pendant une durée suffisante
run 40 ns

# Zoom pour voir tous les signaux
wave zoom full
# Script de simulation ModelSim pour la mémoire de données

# Création de la bibliothèque de travail
vlib work

# Compilation des fichiers VHDL
vcom -93 -work work DataMemory.vhd
vcom -93 -work work DataMemory_testbench.vhd

# Chargement du testbench
vsim -t 1ns work.DataMemory_testbench

# Ajout des signaux à observer dans la fenêtre de forme d'onde
add wave -position insertpoint \
sim:/DataMemory_testbench/CLK_tb \
sim:/DataMemory_testbench/Reset_tb \
sim:/DataMemory_testbench/DataIn_tb \
sim:/DataMemory_testbench/DataOut_tb \
sim:/DataMemory_testbench/Addr_tb \
sim:/DataMemory_testbench/WrEn_tb

# Visualiser quelques adresses mémoire
add wave -position insertpoint \
sim:/DataMemory_testbench/UUT/memory(0) \
sim:/DataMemory_testbench/UUT/memory(1) \
sim:/DataMemory_testbench/UUT/memory(2) \
sim:/DataMemory_testbench/UUT/memory(10)

# Exécution de la simulation pendant une durée suffisante
run 100 ns

# Zoom pour voir tous les signaux
wave zoom full
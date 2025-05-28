# Script de simulation ModelSim pour la m�moire de donn�es

# Cr�ation de la biblioth�que de travail
vlib work

# Compilation des fichiers VHDL
vcom -93 -work work DataMemory.vhd
vcom -93 -work work DataMemory_testbench.vhd

# Chargement du testbench
vsim -t 1ns work.DataMemory_testbench

# Ajout des signaux � observer dans la fen�tre de forme d'onde
add wave -position insertpoint \
sim:/DataMemory_testbench/CLK_tb \
sim:/DataMemory_testbench/Reset_tb \
sim:/DataMemory_testbench/DataIn_tb \
sim:/DataMemory_testbench/DataOut_tb \
sim:/DataMemory_testbench/Addr_tb \
sim:/DataMemory_testbench/WrEn_tb

# Visualiser quelques adresses m�moire
add wave -position insertpoint \
sim:/DataMemory_testbench/UUT/memory(0) \
sim:/DataMemory_testbench/UUT/memory(1) \
sim:/DataMemory_testbench/UUT/memory(2) \
sim:/DataMemory_testbench/UUT/memory(10)

# Ex�cution de la simulation pendant une dur�e suffisante
run 100 ns

# Zoom pour voir tous les signaux
wave zoom full
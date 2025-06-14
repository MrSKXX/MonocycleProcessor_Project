# Script de simulation ModelSim pour le banc de registres

# Cr�ation de la biblioth�que de travail
vlib work

# Compilation des fichiers VHDL
vcom -93 -work work RegisterBank.vhd
vcom -93 -work work RegisterBank_testbench.vhd

# Chargement du testbench
vsim -t 1ns work.RegisterBank_testbench

# Ajout des signaux � observer dans la fen�tre de forme d'onde
add wave -position insertpoint \
sim:/RegisterBank_testbench/CLK_tb \
sim:/RegisterBank_testbench/Reset_tb \
sim:/RegisterBank_testbench/W_tb \
sim:/RegisterBank_testbench/RA_tb \
sim:/RegisterBank_testbench/RB_tb \
sim:/RegisterBank_testbench/RW_tb \
sim:/RegisterBank_testbench/WE_tb \
sim:/RegisterBank_testbench/A_tb \
sim:/RegisterBank_testbench/B_tb

# Visualiser certains registres internes
add wave -position insertpoint \
sim:/RegisterBank_testbench/UUT/Banc(15) \
sim:/RegisterBank_testbench/UUT/Banc(1) \
sim:/RegisterBank_testbench/UUT/Banc(2) \
sim:/RegisterBank_testbench/UUT/Banc(3)

# Ex�cution de la simulation pendant une dur�e suffisante
run 100 ns

# Zoom pour voir tous les signaux
wave zoom full
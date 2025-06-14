# Script de simulation ModelSim pour l'unit� de traitement initiale

# Cr�ation de la biblioth�que de travail
vlib work

# Compilation des fichiers VHDL
vcom -93 -work work ALU.vhd
vcom -93 -work work RegisterBank.vhd
vcom -93 -work work ProcessingUnit.vhd
vcom -93 -work work ProcessingUnit_testbench.vhd

# Chargement du testbench
vsim -t 1ns work.ProcessingUnit_testbench

# Ajout des signaux � observer dans la fen�tre de forme d'onde
add wave -position insertpoint \
sim:/ProcessingUnit_testbench/CLK_tb \
sim:/ProcessingUnit_testbench/Reset_tb \
sim:/ProcessingUnit_testbench/RegWr_tb \
sim:/ProcessingUnit_testbench/RegSel_tb \
sim:/ProcessingUnit_testbench/ALUCtr_tb \
sim:/ProcessingUnit_testbench/RA_tb \
sim:/ProcessingUnit_testbench/RB_tb \
sim:/ProcessingUnit_testbench/RW_tb \
sim:/ProcessingUnit_testbench/N_tb \
sim:/ProcessingUnit_testbench/Z_tb

# Visualiser certains signaux internes
add wave -position insertpoint \
sim:/ProcessingUnit_testbench/UUT/BusA \
sim:/ProcessingUnit_testbench/UUT/BusB \
sim:/ProcessingUnit_testbench/UUT/BusW \
sim:/ProcessingUnit_testbench/UUT/Banc_Reg/Banc(1) \
sim:/ProcessingUnit_testbench/UUT/Banc_Reg/Banc(2) \
sim:/ProcessingUnit_testbench/UUT/Banc_Reg/Banc(3) \
sim:/ProcessingUnit_testbench/UUT/Banc_Reg/Banc(5) \
sim:/ProcessingUnit_testbench/UUT/Banc_Reg/Banc(7) \
sim:/ProcessingUnit_testbench/UUT/Banc_Reg/Banc(15)

# Ex�cution de la simulation pendant une dur�e suffisante
run 150 ns

# Zoom pour voir tous les signaux
wave zoom full
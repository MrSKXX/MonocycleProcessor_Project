# Script de simulation ModelSim pour l'unité de traitement complète

# Création de la bibliothèque de travail
vlib work

# Compilation des fichiers VHDL
vcom -93 -work work ALU.vhd
vcom -93 -work work RegisterBank.vhd
vcom -93 -work work Mux2v1.vhd
vcom -93 -work work SignExtender.vhd
vcom -93 -work work DataMemory.vhd
vcom -93 -work work ProcessingUnitComplete.vhd
vcom -93 -work work ProcessingUnitComplete_testbench.vhd

# Chargement du testbench
vsim -t 1ns work.ProcessingUnitComplete_testbench

# Ajout des signaux à observer dans la fenêtre de forme d'onde
add wave -position insertpoint \
sim:/ProcessingUnitComplete_testbench/CLK_tb \
sim:/ProcessingUnitComplete_testbench/Reset_tb \
sim:/ProcessingUnitComplete_testbench/RegWr_tb \
sim:/ProcessingUnitComplete_testbench/ALUSrc_tb \
sim:/ProcessingUnitComplete_testbench/ALUCtr_tb \
sim:/ProcessingUnitComplete_testbench/MemWr_tb \
sim:/ProcessingUnitComplete_testbench/MemToReg_tb \
sim:/ProcessingUnitComplete_testbench/RA_tb \
sim:/ProcessingUnitComplete_testbench/RB_tb \
sim:/ProcessingUnitComplete_testbench/RW_tb \
sim:/ProcessingUnitComplete_testbench/Immediat_tb \
sim:/ProcessingUnitComplete_testbench/N_tb \
sim:/ProcessingUnitComplete_testbench/Z_tb

# Visualiser les signaux internes importants
add wave -position insertpoint \
sim:/ProcessingUnitComplete_testbench/UUT/BusA \
sim:/ProcessingUnitComplete_testbench/UUT/BusB \
sim:/ProcessingUnitComplete_testbench/UUT/ALUout \
sim:/ProcessingUnitComplete_testbench/UUT/DataOut \
sim:/ProcessingUnitComplete_testbench/UUT/BusW \
sim:/ProcessingUnitComplete_testbench/UUT/ImmExtended \
sim:/ProcessingUnitComplete_testbench/UUT/ALUin \
sim:/ProcessingUnitComplete_testbench/UUT/Banc_Reg/Banc(2) \
sim:/ProcessingUnitComplete_testbench/UUT/Banc_Reg/Banc(3) \
sim:/ProcessingUnitComplete_testbench/UUT/Banc_Reg/Banc(4) \
sim:/ProcessingUnitComplete_testbench/UUT/Banc_Reg/Banc(5) \
sim:/ProcessingUnitComplete_testbench/UUT/Banc_Reg/Banc(6) \
sim:/ProcessingUnitComplete_testbench/UUT/Banc_Reg/Banc(7) \
sim:/ProcessingUnitComplete_testbench/UUT/Data_Mem/memory(0)

# Exécution de la simulation pendant une durée suffisante
run 200 ns

# Zoom pour voir tous les signaux
wave zoom full
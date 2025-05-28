# Script de simulation ModelSim pour l'unit� de gestion des instructions

# Cr�ation de la biblioth�que de travail
vlib work

# Compilation des fichiers VHDL
vcom -93 -work work instruction_memory.vhd
vcom -93 -work work PC_Register.vhd
vcom -93 -work work SignExtend_24to32.vhd
vcom -93 -work work PC_Update.vhd
vcom -93 -work work InstructionUnit.vhd
vcom -93 -work work InstructionUnit_testbench.vhd

# Chargement du testbench
vsim -t 1ns work.InstructionUnit_testbench

# Ajout des signaux � observer dans la fen�tre de forme d'onde
add wave -position insertpoint \
sim:/InstructionUnit_testbench/CLK_tb \
sim:/InstructionUnit_testbench/Reset_tb \
sim:/InstructionUnit_testbench/nPCsel_tb \
sim:/InstructionUnit_testbench/offset_tb \
sim:/InstructionUnit_testbench/Instruction_tb

# Visualiser certains signaux internes
add wave -position insertpoint \
sim:/InstructionUnit_testbench/UUT/PC_out \
sim:/InstructionUnit_testbench/UUT/Next_PC \
sim:/InstructionUnit_testbench/UUT/SignExtImm

# Ex�cution de la simulation pendant une dur�e suffisante
run 200 ns

# Zoom pour voir tous les signaux
wave zoom full
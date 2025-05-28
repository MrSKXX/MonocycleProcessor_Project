# Script global de simulation pour la Partie 1

# Création de la bibliothèque de travail
vlib work

# Compilation de tous les fichiers VHDL
echo "Compilation des composants de base..."
vcom -93 -work work ALU.vhd
vcom -93 -work work RegisterBank.vhd
vcom -93 -work work Mux2v1.vhd
vcom -93 -work work SignExtender.vhd
vcom -93 -work work DataMemory.vhd
vcom -93 -work work ProcessingUnitComplete.vhd

echo "Compilation des testbenches..."
vcom -93 -work work ALU_testbench.vhd
vcom -93 -work work RegisterBank_testbench.vhd
vcom -93 -work work Mux2v1_testbench.vhd
vcom -93 -work work SignExtender_testbench.vhd
vcom -93 -work work DataMemory_testbench.vhd
vcom -93 -work work ProcessingUnitComplete_testbench.vhd

# Exécution des tests un par un
echo "Test de l'ALU..."
vsim -t 1ns work.ALU_testbench
run 50 ns
echo "Test de l'ALU terminé."

echo "Test du banc de registres..."
vsim -t 1ns work.RegisterBank_testbench
run 100 ns
echo "Test du banc de registres terminé."

echo "Test du multiplexeur..."
vsim -t 1ns work.Mux2v1_testbench
run 40 ns
echo "Test du multiplexeur terminé."

echo "Test de l'extension de signe..."
vsim -t 1ns work.SignExtender_testbench
run 40 ns
echo "Test de l'extension de signe terminé."

echo "Test de la mémoire de données..."
vsim -t 1ns work.DataMemory_testbench
run 100 ns
echo "Test de la mémoire de données terminé."

echo "Test final de l'unité de traitement complète..."
vsim -t 1ns work.ProcessingUnitComplete_testbench
run 200 ns
echo "Test de l'unité de traitement complète terminé."

echo "Tous les tests de la Partie 1 sont terminés."
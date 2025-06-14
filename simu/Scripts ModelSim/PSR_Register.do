# Script ModelSim pour PSR_Register
# PSR_Register_sim.do

# Cr�er la biblioth�que de travail
vlib work

# Compiler les fichiers sources
vcom -93 -work work {PSR_Register.vhd}
vcom -93 -work work {PSR_Register_testbench.vhd}

# D�marrer la simulation
vsim -t ps work.PSR_Register_testbench

# Ajouter les signaux � la forme d'onde
add wave -position insertpoint sim:/PSR_Register_testbench/CLK_tb
add wave -position insertpoint sim:/PSR_Register_testbench/Reset_tb
add wave -position insertpoint sim:/PSR_Register_testbench/WE_tb
add wave -position insertpoint -radix hexadecimal sim:/PSR_Register_testbench/DATAIN_tb
add wave -position insertpoint -radix hexadecimal sim:/PSR_Register_testbench/DATAOUT_tb

# S�parer les drapeaux individuels pour une meilleure visibilit�
add wave -position insertpoint -radix binary sim:/PSR_Register_testbench/DATAOUT_tb(31)
add wave -position insertpoint -radix binary sim:/PSR_Register_testbench/DATAOUT_tb(30)

# Renommer les signaux pour plus de clart�
configure wave -namecolwidth 200
configure wave -valuecolwidth 100

# Configurer les noms des signaux
set wave_signals [list \
    {sim:/PSR_Register_testbench/CLK_tb CLK} \
    {sim:/PSR_Register_testbench/Reset_tb Reset} \
    {sim:/PSR_Register_testbench/WE_tb WE} \
    {sim:/PSR_Register_testbench/DATAIN_tb DATAIN} \
    {sim:/PSR_Register_testbench/DATAOUT_tb DATAOUT} \
    {sim:/PSR_Register_testbench/DATAOUT_tb(31) N_Flag} \
    {sim:/PSR_Register_testbench/DATAOUT_tb(30) Z_Flag} \
]

# Lancer la simulation
run 200ns

# Zoomer pour voir tous les signaux
wave zoom full

echo "Simulation PSR_Register termin�e"
echo "V�rifiez que :"
echo "1. Le reset remet DATAOUT � 0"
echo "2. L'�criture avec WE=1 fonctionne"
echo "3. Pas d'�criture quand WE=0"
echo "4. Les drapeaux N et Z sont correctement stock�s"
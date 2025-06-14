# Script ModelSim pour tester la s�quence compl�te du programme
# Program_sequence.do

# Cr�er la biblioth�que de travail
vlib work

# Compiler tous les fichiers n�cessaires
vcom -93 -work work PSR_Register.vhd
vcom -93 -work work Decoder.vhd
vcom -93 -work work ControlUnit.vhd
vcom -93 -work work ControlUnit_program_testbench.vhd

# D�marrer la simulation
vsim -t ps work.ControlUnit_program_testbench

# Ajouter les signaux dans l'ordre du programme
add wave -divider "SIMULATION PROGRAM"
add wave sim:/ControlUnit_program_testbench/CLK_tb
add wave sim:/ControlUnit_program_testbench/Reset_tb
add wave -radix unsigned sim:/ControlUnit_program_testbench/PC_sim

add wave -divider "INSTRUCTIONS EXECUTEES"
add wave sim:/ControlUnit_program_testbench/Instruction_tb
add wave sim:/ControlUnit_program_testbench/UUT/Instruction_Decoder/instr_courante

add wave -divider "CONTROLES PRINCIPAUX"
add wave sim:/ControlUnit_program_testbench/RegWr_tb
add wave sim:/ControlUnit_program_testbench/nPC_SEL_tb
add wave sim:/ControlUnit_program_testbench/MemWr_tb
add wave -radix unsigned sim:/ControlUnit_program_testbench/ALUCtr_tb

add wave -divider "REGISTRES MANIPULES"
add wave -radix unsigned sim:/ControlUnit_program_testbench/Rn_tb
add wave -radix unsigned sim:/ControlUnit_program_testbench/Rm_tb
add wave -radix unsigned sim:/ControlUnit_program_testbench/Rd_tb

add wave -divider "FLAGS ET PSR"
add wave sim:/ControlUnit_program_testbench/N_ALU_tb
add wave sim:/ControlUnit_program_testbench/Z_ALU_tb
add wave sim:/ControlUnit_program_testbench/N_tb
add wave sim:/ControlUnit_program_testbench/UUT/PSR_OUT

add wave -divider "AFFICHAGE FINAL"
add wave sim:/ControlUnit_program_testbench/BusB_tb
add wave sim:/ControlUnit_program_testbench/RegAff_tb
add wave sim:/ControlUnit_program_testbench/UUT/RegAff_control
add wave sim:/ControlUnit_program_testbench/UUT/RegAff_stored

# Configuration de l'affichage
configure wave -namecolwidth 350
configure wave -valuecolwidth 150
configure wave -timelineunits ns

# Lancer la simulation
run 200ns

# Zoomer pour voir tous les signaux
wave zoom full

echo "=========================================="
echo "SIMULATION SEQUENCE PROGRAMME COMPLETE"
echo "=========================================="
echo "INSTRUCTIONS TESTEES DANS L'ORDRE :"
echo "PC=0 (30ns) : MOV R1,#0x10"
echo "PC=1 (40ns) : MOV R2,#0x00"
echo "PC=2 (50ns) : LDR R0,0(R1)"
echo "PC=3 (60ns) : ADD R2,R2,R0"
echo "PC=4 (70ns) : ADD R1,R1,#1"
echo "PC=5 (80ns) : CMP R1,0x1A"
echo "PC=6 (90ns) : BLT loop"
echo "PC=7 (110ns): STR R2,0(R1) - CORRIGE"
echo "PC=8 (130ns): BAL main"
echo "=========================================="
echo "VERIFICATION CLES :"
echo "1. instr_courante suit : MOV->MOV->LDR->ADD->ADD->CMP->BLT->STR->BAL"
echo "2. RegWr=1 pour MOV, LDR, ADD"
echo "3. nPC_SEL=1 pour BLT et BAL"
echo "4. N_tb=1 apr�s CMP (simule R1 < 0x1A)"
echo "5. RegAff_tb=0x37 apr�s STR corrig�"
echo "=========================================="
echo "SI RegAff=0x37 apparait : SUCCES !"
echo "SI RegAff reste 0 : Probl�me instruction STR"
echo "=========================================="
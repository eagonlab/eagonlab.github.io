#!/bin/bash
#This script will run a virtual screen with iDock on a Windows machine
#This script should be in the parent directory with a idock.conf file,
#the protein as a PDBQT file, the idock program, and all ligands in a
#directory named Ligands.  Each input ligand needs a name beginning with
#the word "ligand" and be in PDBQT format.  Output files will be in PDBQT format
mkdir -p Results
cd ./Ligands
for f in ligand*.pdbqt; do grep -n "Name" $f > $f.txt; done
for f in ligand*.txt; do sed -i 1i"$f" $f; done
for f in ligand*.txt; do paste -s $f >> IDs.txt; done
for f in ligand*.txt; do rm $f; done
mv IDs.txt ../Results/
cd ../
./idock.exe --config idock.conf
cd Results/
awk '{print $1" "$5}' IDs.txt | column -t >> id.txt
awk -F "\"*,\"*" '{print $1,$3}' log.csv > energy.txt
sed -i '1d' energy.txt
awk '$1=$1".pdbqt"' energy.txt > energy2.txt
sort -n -k1 energy2.txt > energy_sort.txt
sort -n -k1 id.txt > id_sort.txt
paste energy_sort.txt id_sort.txt > final.txt
sort -n -k2 final.txt | column -t > Summary_Final.txt
cp Summary_Final.txt ../
rm energy*.txt id.txt id_sort.txt final*.txt
#results
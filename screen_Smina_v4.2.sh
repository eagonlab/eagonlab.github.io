#!/bin/bash
#This script will run a virtual screen with Smina
#This script should be in the parent directory with a conf.txt file, the protein
#target as a PDBQT file, the smina.static program, and all ligands in a directory
#named Ligands, each with a name starting with "ligand," and in PDBQT format.
#Output files will be in PDBQT format.
cp *.pdbqt Ligands/
mkdir -p Results
cd Ligands/
for f in ligand*.pdbqt; do grep -n "Name" $f > $f.txt; done
for f in ligand*.txt; do sed -i 1i"$f" $f; done
for f in ligand*.txt; do paste -s $f >> IDs.txt; done
for f in ligand*.txt; do rm $f; done
mv IDs.txt ../Results/
for f in ligand*.pdbqt; do sed -i '/USER/d' $f; sed -i '/TER/d' $f; done
for f in ligand*.pdbqt; do  b=`basename $f`; echo Processing ligand $b; ../smina.static --config ../conf.txt --ligand $f --out ../Results/$f --log ../Results/$f.txt; done
cd ../Results/
for f in ligand*.pdbqt; do mv "$f" "${f%.pdbqt}_OUTPUT.pdbqt"; done
for f in ligand*.txt; do sed -i 1i"$f" $f; done
for f in ligand*.txt; do sed -n '1p;27p' $f > Best_$f; done
for f in Best*.txt; do paste -s $f >> Summary.txt; done
sort -n -k3 Summary.txt -o Summary_Sorted.txt
for f in Best*.txt; do rm $f; done
awk '{print $1" "$3}' Summary_Sorted.txt | column -t >> energy.txt
sort energy.txt > energy_sort.txt
awk '{print $1" "$5}' IDs.txt | column -t >> id.txt
sort id.txt > id_sort.txt
paste energy_sort.txt id_sort.txt > final.txt
sort -n -k2 final.txt > Summary_Final.txt
cp Summary_Final.txt ../
rm energy*.txt id.txt id_sort.txt final*.txt ligand*.txt
#result
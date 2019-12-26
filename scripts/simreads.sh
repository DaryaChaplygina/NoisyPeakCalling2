#!/bin/bash

PROJECT_FOLDER=/home/NoisyPeakCalling2

if [[ $1 == "-h" || $1 == "--help" ]]; then
  echo "Script runs tulip reads simulation with different noise level.
  Usage: [name (of histone modification)] [peak caller (which peaks to use)]
         [n_reads] [reference]
         [file with peaks] [tulip model without noise]"
  exit 0
fi

if [[ "$#" -ne 6 ]]; then
  echo "Incorrect number of arguments (use -h for help)"
  exit 1
fi

name=$1
caller=$2
n_reads=$3
ref=$4
peaks=$5
model=$6

here_folder=${PROJECT_FOLDER}/tulip_sim/${caller}_peaks

if [[ ! -d ${PROJECT_FOLDER}/tulip_sim ]]; then
  mkdir ${PROJECT_FOLDER}/tulip_sim
fi

if [[ ! -d ${PROJECT_FOLDER}/tulip_sim/${caller}_peaks ]]; then
  mkdir ${PROJECT_FOLDER}/tulip_sim/${caller}_peaks
fi

if [[ ! -d ${here_folder}/${name} ]]; then
  cd ${here_folder}
  mkdir ${name}
  cd ${name}/
  mkdir fastqs
  mkdir bams
  mkdir bigwigs
fi

here_folder=${here_folder}/${name}
cd ${here_folder}

for i in 0.2 0.1 0.05 0.01 0.007 0.005
  do
    tulip simreads -p ${peaks} \
     -f ${ref} \
     -o fastqs/${name}_noize${i/./} \
     -t bed -c 5 --numreads ${n_reads} \
     --model ${model} \
     --spot ${i} --scale-outliers --seed 12 --thread 4
  done

cd ${PROJECT_FOLDER}/scripts/
./prepare_dataset.sh ${here_folder}/fastqs/ ${ref} ${here_folder}/bams
cd ${here_folder}

for i in 02 01 005 001 0007 0005
  do 
    bamCoverage -b bams/${name}_noize${i}.bam -o bigwigs/${name}_noize${i}.bw -of bigwig 
  done

#!/bin/bash


if [[ $1 == "-h" || $1 == "--help" ]]; then
  echo "Script builds tulip models for data with increasing noise.
  Usage: [chip_file (.bam)] [control_file (.bam)] [n_reads]
         [name] [peaks] [outdir name]"
  exit 0
fi

if [[ "$#" -ne 6 ]]; then
  echo "Incorrect number of arguments (use -h for help)"
  exit 1
fi

chip=$1
control=$2
n_reads=$3
name=$4
peaks=$5
outdir=$6

chip_lines=$(sambamba view -t 4 -c  ${chip})
control_lines=$(sambamba view -t 4 -c  ${control})

if [[ ! -d ../tulip_models ]]; then
  mkdir ../tulip_models
  mkdir ../tulip_models/${outdir}
fi

if [[ ! -d ../tulip_models/${outdir} ]]; then
  mkdir ../tulip_models/${outdir}
fi

for i in {0..9}
  do
    ./join_files.sh ${chip} ${control} ${n_reads} ${chip_lines} ${control_lines} ${i}
    tulip learn -b merged${i}.bam -p ${peaks} -t bed -c 5 -o ../tulip_models/${outdir}/${name}_${i}

    rm -rf *.bam
    rm -rf *.bai
  done
 

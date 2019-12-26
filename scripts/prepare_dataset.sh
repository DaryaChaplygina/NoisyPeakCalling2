#!/bin/bash

if [[ $1 == "-h" || $1 == "--help" ]]; then
  echo "Script aligns data to the given reference.
  Usage: [data_folder (with .fastq files)] [reference] [output_folder]"
  exit 0
fi

data_folder=$1
ref=$2
output_folder=$3

if [[ ! -d ${data_folder} ]]; then
  echo "Data folder not found! Please provide existing directory (use -h for help)"
  exit 1
fi

cd ${data_folder}

if [[ ! -f ${ref} ]]; then
  echo "Reference not found! Please check if your file exists and is in provided folder
  (use -h for help)"
  exit 1
fi

bowtie2-build ${ref} ref

for f in *.fastq
  do
    echo $f
    name=$(echo ${f} | cut -d'.' -f 1)
    echo $name
    bowtie2 -x ref -U ${f} -S ${output_folder}/${name}_aln.sam
    samtools view -bhS ${output_folder}/${name}_aln.sam > ${output_folder}/${name}_aln.bam
    samtools sort ${output_folder}/${name}_aln.bam > ${output_folder}/${name}.bam
    samtools index ${output_folder}/${name}.bam

    rm -rf ${output_folder}/${name}_aln.sam
    rm -rf ${output_folder}/${name}_aln.bam
  done
 

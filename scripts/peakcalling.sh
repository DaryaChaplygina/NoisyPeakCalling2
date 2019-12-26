#!/bin/bash

PROJECT_FOLDER=/home/NoisyPeakCalling2
SPAN_PATH=/home/span/span-0.11.0.build.jar
span_cs=/home/span/hg38.chrom.sizes

if [[ $1 == "-h" || $1 == "--help" ]]; then
  echo "Script performs peakcalling for simulated noisy reads.
  Usage: [name (of histone modification)] [peakcaller (which peaks to use)] 
         [control] [peakcaller (algorithm to find peaks)]
         [fdr]"
  exit 0
fi

if [[ "$#" -ne 5 ]]; then
  echo "Incorrect number of arguments (use -h for help)"
  exit 1
fi

name=$1
peaks=$2
control=$3
peakcaller=$4
fdr=$5

file_folder=${PROJECT_FOLDER}/tulip_sim/${peaks}_peaks/${name}

if [[ ${peakcaller} == "sicer" ]] ; then
  mkdir ${file_folder}/${peakcaller}
  mv ${control} control.bed 
fi

for noize in 0.01
  do
    if [[ ${peakcaller} == "macs2" ]] ; then
        macs2 callpeak -t ${file_folder}/bams/${name}_noize${noize/./}.bam \
        -c ${control} -n ${name}_${noize/./} \
        --outdir ${file_folder}/${peakcaller} --broad \
        -q ${fdr} --broad-cutoff ${fdr}
    elif [[ ${peakcaller} == "sicer" ]] ; then
        bedtools bamtobed -i ${file_folder}/bams/${name}_noize${noize/./}.bam > ${name}_noize${noize/./}.bed
        SICER.sh . ${name}_noize${noize/./}.bed control.bed \
        ${file_folder}/${peakcaller} hg38 1 200 150 0.75 400 ${fdr}

        rm -rf ${file_folder}/${peakcaller}/${name}_noize${noize/./}*.bed
        rm -rf ${name}_noize${noize/./}.bed
        rm -rf chr.list
    else
      java -Xmx6G -jar ${SPAN_PATH} analyze -t ${file_folder}/bams/${name}_noize${noize/./}.bam \
      -c ${control} --threads 4 --cs ${span_cs} \
      -p ${file_folder}/${peakcaller}/${name}_noize${noize/./}.peak --fdr ${fdr} 
      rm -rf logs/
      rm -rf cache/
      rm -rf fit/

    fi
  done

if [[ ${peakcaller} == "sicer" ]] ; then
  mv control.bed ${control} 
fi
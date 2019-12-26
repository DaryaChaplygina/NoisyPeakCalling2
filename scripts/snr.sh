#!/bin/bash

PROJECT_FOLDER=/home/NoisyPeakCalling2
frag=0


if [[ $1 == "-h" || $1 == "--help" ]]; then
  echo "Script traverses all simulated read files and counts SNR"
  exit 0
fi

for hm in h3k4me3 h3k27me3 h3k4me1 h3k27ac h3k36me3
  do
    case ${hm} in
      h3k4me1)
        frag=227
        ;;
      h3k4me3)
        frag=189
        ;;
      h3k27ac)
        frag=278
        ;;
      h3k27me3)
        frag=222
        ;;
      *)
        frag=293
        ;;
    esac

    for peakcaller in span encode
      do
        outp=${PROJECT_FOLDER}/tulip_sim/${peakcaller}_peaks/${hm}/snr
        touch ${outp}
        for noize in 0.2 0.1 0.05 0.01 0.007 0.005  
          do
            f=${PROJECT_FOLDER}/tulip_sim/${peakcaller}_peaks/${hm}/bams/${hm}_noize${noize/./}.bam
            if [[ -f ${f} ]]; then
              python signal_to_noise_estimation.py ${f} -d ${frag} --percentiles 0.1 0.99 >> ${outp}
            fi
          done 
      done
  done
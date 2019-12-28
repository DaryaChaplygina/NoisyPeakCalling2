# NoisyPeakCalling2

## Project description
This is a continuation of the [NoisyPeakCalling](https://github.com/DaryaChaplygina/NoisyPeakCalling/) project. Previously we analyzed an impact of noise in ChIP-seq data on peak calling algorithms performance by using _additive noise model_ (which means that we added control reads to chip-seq reads in some proportion). Here we explore Tulip[[1]](#tulip) tool and apply it to obtain noisy data (_deductive noise model_).

## Goals and objectives
The aims of the project:
1. To learn how noise in data affects parameters in Tulip model.
2. To acquire noisy data for an experiment by changing some parameters of Tulip model.
3. To analyse the influence of Tulip noise model on __MACS2__[[2]](#macs2), __SICER__[[3]](#sicer) and __SPAN__[[4]](#span) peak calling algorithms.

## Methods
### Data

We use the same dataset of five H3 histone modifications as in previous project, so please check [its page](https://github.com/DaryaChaplygina/NoisyPeakCalling/) to get the ENCODE[[5]](#encode) project accession codes. 

For buildig Tulip models, which requires a peak set, we use two different peak sources: 
- from ENCODE ([H3K4me1](https://www.encodeproject.org/files/ENCFF366GZW/), [H3K4me3](https://www.encodeproject.org/files/ENCFF651GXK/), [H3K27ac](https://www.encodeproject.org/files/ENCFF039XWV/), [H3K27me3](https://www.encodeproject.org/files/ENCFF666NYB/), [H3K36me3](https://www.encodeproject.org/files/ENCFF213IBM/));
- from SPAN (version 0.11.0 with default settings except fdr=0.5).

We use:
- bowtie2 (version 2.3.4.3) for reads alignment;
- samtools (1.9) for sorting and filtering;
- bamCoverage from deeptools package (version 3.2.1) to obtain bigWig files;
- bamtobed from bedtools package (version 2.28.0) to obtain bed files from alignment;
- sambamba (version 0.6.6) for mixing ChIP-seq and control reads.

### Project scripts

`prepare_dataset.sh` takes as input _[data_folder]_ _[ref]_ _[output_folder]_, where
- _data_folder_ is an existing directory with .fastq files you want to align
- _ref_ is a .fasta file with reference for your data
- _output_folder_ is an output directory.

The script aligns and indexes all the .fastq files in _data_folder_ using _ref_ as reference.

`tulip_analysis.sh` takes as input _[chip]_ _[control]_ _[n_reads]_ _[name]_ _[peaks]_ _[output_foder]_, where
- _chip_ is aligned chip-seq reads
- _control_ is aligned control reads
- _n_reads_ is number of reads to choose for experiment (should be less then number of reads both in chip and control)
- _name_ is a name for output file (recommended to be a modification name)
- _peaks_ is a set of peaks to use for Tulip model learning
- _output_folder_ is an output directory.

The script creates noisy ChIP-seq dataset by mixing reads from chip and control files in proportion from 0% to 90% (additive noise model), and then builds Tulip model. The goal is to find out how Tulip model parameters are changing with growing noise level. 

`join_files.sh` is a supplementary script, that is runned by `tulip_analysis.sh` to mix chip and control with specified proportion.

`simreads.sh` takes as input _[name]_ _[peak set name]_ _[n_reads]_ _[ref]_ _[peaks]_ _[tulip model]_, where
- _name_ is a prefix for output files (recommended to be a modification name)
- _peak set name_ is a output folder name (recommended be an identificator of algorithm that created given peak set)
- _n_reads_ is a number of reads to simulate
- _ref_ is a reference file
- _peaks_ is a peak set for Tulip simulation
- _tulip_model_ is a json with Tulip model parameters.

The script run Tulip reads simulation, using precomputed peak set and tulip model. It changes one parameter in model (percentage of reads in peaks) to obtain noisy dataset. The result is a set of .fastq files with increasing noise level.

`peakcalling.sh` takes as input _[name]_ _[peak set name]_ _[control]_ _[peak caller]_ _[fdr]_, where
- _name_ and _peak set name_ should be the same as given to `simreads.sh` script, because this script works with output of `peakcalling.sh`
- _control_ is aligned control reads
- _peak caller_ is a peakcalling algorithm (now available macs2, sicer and span)

The script runs _peakcaller_ on files from Tulip simulation. Now it is possible to choose only _fdr_ parameter for running.

`signal_to_noise_estimation.py` takes as input _[file]_ _[-d fragment_size]_  _[OPTIONS]_, where
- _[file]_ is a path to file in .bam format
- _-d_ is a size of chip fragment (you could obtain it from macs2 logs, for example)

The script counts signal-to-noise ratio as ratio of 90 to 10 percentiles of genome bin coverage distribution (90 to 10 is default settings, but I recommend you to set first number to larger value, like 95% or 99%).

`snr.sh` is a script that runs `signal_to_noise_estimation.py` on every file from Tulip simulation.

### Project pipeline

- Download files listed in __data__ 
- Run `conda env create -f env.yaml` to get all the required programs
- Install Tulip
- Run `./prepare_data.sh` to align your ChIP-seq and control reads
- Run `tulip_analysis.sh` to learn how Tulip model is affected by additive noise model
- Run `simreads.sh` to create noisy dataset with Tulip (_deductive noise model_) 
- Run `./peakcalling.sh` to perform peak calling on new dataset
- Run `snr.sh` to compute SNR rate in new dataset

Some plots from results also require an information about peaks overlaping. You can obtain it from JBR Genome Browser and write it into `result/snr_tulip_noise_model.csv`. 

## Results
The following plots show that Tulip model parameter _P(B|D) - the probability that a fragment is bound given that it is pulled down_ (calculated as percent of fragments falling within peaks) __is decreasing with noise level increasing__ (aditive noise model). 
<p align="center">
  <img src="https://github.com/DaryaChaplygina/NoisyPeakCalling2/blob/master/results/pictures/encode_s_dynamics.png" width="400" />
  <img src="https://github.com/DaryaChaplygina/NoisyPeakCalling2/blob/master/results/pictures/span_s_dynamics.png" width="400" />
</p>

Next plots shows simultaneous change of SNR and percent of reads within peaks affected by additive and deductive noise models. As we can see, percent of reads within peaks could vary significantly for the same histone modification and SNR. Therefore, __SNR is not enough to learn the quality of your dataset__. 
<p align="center">
  <img src="https://github.com/DaryaChaplygina/NoisyPeakCalling2/blob/master/results/pictures/snr_additive_model_encode.png" width="400" />
  <img src="https://github.com/DaryaChaplygina/NoisyPeakCalling2/blob/master/results/pictures/snr_deductive_model_encode.png" width="400" />
</p>

Visualization of peak calling algorithms precision and recall shows that
- SICER is the precise algorithm when SNR is low
- SPAN has the biggest recall in low SNR
- MACS2 is precise but has the lowest recall; and also this algorithms cannot perform peak calling when SNR is lower than 14 (on average)
<p align="center">
  <img src="https://github.com/DaryaChaplygina/NoisyPeakCalling2/blob/master/results/pictures/precision_span_peaks.png" width="400" />
  <img src="https://github.com/DaryaChaplygina/NoisyPeakCalling2/blob/master/results/pictures/recall_span_peaks.png" width="400" />
</p>

<p align="center">
  <img src="https://github.com/DaryaChaplygina/NoisyPeakCalling2/blob/master/results/pictures/precision_encode_peaks.png" width="400" />
  <img src="https://github.com/DaryaChaplygina/NoisyPeakCalling2/blob/master/results/pictures/recall_encode_peaks.png" width="400" />
</p>


## References 

<a name="tulip">[1]</a>  An Zheng, Michael Lamkin, Yutong Qiu, Kevin Ren, Alon Goren, Melissa Gymrek. A flexible simulation toolkit for designing and evaluating ChIP-sequencing experiments. doi: https://doi.org/10.1101/624486

<a name="macs2">[2]</a>  Zhang Y, Liu T, Meyer CA, et al. Model-based analysis of ChIP-Seq (MACS). Genome Biol. 2008;9(9):R137. doi:10.1186/gb-2008-9-9-r137

<a name="sicer">[3]</a>  Xu S, Grullon S, Ge K, Peng W. Spatial clustering for identification of ChIP-enriched regions (SICER) to map regions of histone methylation patterns in embryonic stem cells. Methods Mol Biol. 2014;1150:97–111. doi:10.1007/978-1-4939-0512-6_5

<a name="span">[4]</a> SPAN Semi-supervised Peak Analyzer https://github.com/JetBrains-Research/span

<a name="encode">[5]</a>  Encyclopedia of DNA Elements. https://www.encodeproject.org/

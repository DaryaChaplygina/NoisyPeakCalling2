# NoisyPeakCalling2

## Project description
This is a continuation of the [NoisyPeakCalling](https://github.com/DaryaChaplygina/NoisyPeakCalling/) project. Previously we analyzed an impact of noise in ChIP-seq data on peak calling algorithms performance by using _additive noise model_ (which means that we added control reads to chip-seq reads in some proportion). Here we explore Tulip[[1]](#tulip) tool and apply it to obtain noisy data.

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
### Project pipeline
## Results
## References 

<a name="tulip">[1]</a>  An Zheng, Michael Lamkin, Yutong Qiu, Kevin Ren, Alon Goren, Melissa Gymrek. A flexible simulation toolkit for designing and evaluating ChIP-sequencing experiments. doi: https://doi.org/10.1101/624486

<a name="macs2">[2]</a>  Zhang Y, Liu T, Meyer CA, et al. Model-based analysis of ChIP-Seq (MACS). Genome Biol. 2008;9(9):R137. doi:10.1186/gb-2008-9-9-r137

<a name="sicer">[3]</a>  Xu S, Grullon S, Ge K, Peng W. Spatial clustering for identification of ChIP-enriched regions (SICER) to map regions of histone methylation patterns in embryonic stem cells. Methods Mol Biol. 2014;1150:97–111. doi:10.1007/978-1-4939-0512-6_5

<a name="span">[4]</a> SPAN Semi-supervised Peak Analyzer https://github.com/JetBrains-Research/span

<a name="encode">[5]</a>  Encyclopedia of DNA Elements. https://www.encodeproject.org/

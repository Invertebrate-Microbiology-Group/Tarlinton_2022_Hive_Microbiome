#!/bin/bash
#PBS -N Processing_MRA_Chip_2
#PBS -l ncpus=16
#PBS -l walltime=12:00:00
#PBS -l mem=64gb
source ~/miniconda3/etc/profile.d/conda.sh
conda activate qiime2-2022.8
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
cd $PBS_O_WORKDIR
qiime tools import \
	--type 'SampleData[PairedEndSequencesWithQuality]' \
	--input-path Selected_Data/H2/ \
	--input-format CasavaOneEightSingleLanePerSampleDirFmt \
	--output-path QIIME_Processing/H2/demultiplexed_sequences.qza  
qiime dada2 denoise-paired \
	--i-demultiplexed-seqs QIIME_Processing/H2/demultiplexed_sequences.qza 	\
	--p-trunc-len-f 0 --p-trunc-len-r 270 \
	--p-trim-left-f 17 --p-trim-left-r 21 \
	--p-n-threads 0 \
	--o-table QIIME_Processing/H2/feat_tab.qza \
	--o-representative-sequences QIIME_Processing/H2/rep_seqs.qza  \
	--o-denoising-stats QIIME_Processing/H2/stats.qza
qiime feature-classifier classify-consensus-blast \
	--i-query QIIME_Processing/H2/rep_seqs.qza \
	--i-reference-reads 16S_Taxonomy_DB/silva-138-99-seqs.qza \
	--i-reference-taxonomy 16S_Taxonomy_DB/silva-138-99-tax.qza \
	--o-classification QIIME_Processing/H2/taxonomy.qza \
	--o-search-results QIIME_Processing/H2/tophits.qza

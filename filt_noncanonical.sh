#!/bin/bash

# This script filters out non-canonical transcripts from the input file
# and writes the filtered transcripts to a new file.
# Binning analysis is also performed on the filtered transcripts either by read or position coverage depth. 

if [ $# -ne 4 ]; then
    echo "Usage: $0 <input_dir> <unannotated_bed> <genome_fasta> <analysis_method>"
    exit 1
fi

INPUT_DIR=$1
UNANNOTATED_BED=$2
GENOME_FASTA=$3
ANALYSIS_METHOD=$4

BAM_FILE="$INPUT_DIR/*.bam"

### CHECKS ON INPUT FILE ###

# check if input directory exists
if [ ! -d "$INPUT_DIR" ]; then
    echo "Input directory not found. Exiting..."
    exit 1
fi

# check if input bam file exists
if [ ! -f $BAM_FILE ]; then
    echo "Input BAM file not found. Exiting..."
    exit 1
fi

# check if input bam file is sorted
if [ ! $(samtools view -H $BAM_FILE | grep -c "SO:coordinate") -eq 1 ]; then
    echo "Input BAM file is not sorted. Sorting..."
    samtools sort -o "$INPUT_DIR/sorted.bam" $BAM_FILE
    BAM_FILE="$INPUT_DIR/sorted.bam"
fi

# check if index file (.bai) exists
if [ ! -f "$INPUT_DIR/$(basename $BAM_FILE).bai" ]; then
    echo "Index file not found. Running samtools index..."
    samtools index $BAM_FILE
fi

### FILTERING FOR NON-CANONICAL TRANSCRIPTS ###

# filter out annotated transcripts
bedtools intersect -a $BAM_FILE -b $UNANNOTATED_BED -v > "$INPUT_DIR/non_canonical_filtered.bam"

# sort the filtered bam file
samtools sort -o "$INPUT_DIR/non_canonical_filtered_sorted.bam" "$INPUT_DIR/non_canonical_filtered.bam"

# index the sorted bam file
samtools index "$INPUT_DIR/non_canonical_filtered_sorted.bam"

### GENERATING COVERAGE ###

# check if faidx file exists
if [ ! -f "$GENOME_FASTA.fai" ]; then
    echo "Faidx file not found. Running samtools faidx..."
    samtools faidx $GENOME_FASTA
fi

# check if windows file exists
if [ ! -f "$INPUT_DIR/windows.bed" ]; then
    echo "Windows file not found. Generating..."
    bedtools makewindows -g "$GENOME_FASTA.fai" -w 1000 > "$INPUT_DIR/windows.bed"
fi

# depending on analysis, generate coverage
# if analysis method is "read_depth"
if [ "$ANALYSIS_METHOD" == "read_depth" ]; then
    # generate 1000bp windows of read depth
    bedtools coverage -a "$INPUT_DIR/windows.bed" -b "$INPUT_DIR/non_canonical_filtered_sorted_reads.bam" > "$INPUT_DIR/read_coverage.bed"
    # compute tpm calculation (optional additional logic)

fi

# if analysis method is "position_depth"
if [ "$ANALYSIS_METHOD" == "position_depth" ]; then
    # generate 1000bp windows of position depth
    mosdepth -b 1000 position_depth "$INPUT_DIR/non_canonical_filtered_sorted_position.bam"
fi
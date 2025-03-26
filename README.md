# TCGA_unannotated_transcription
Project to analyze transcriptional events in RNAseq occuring in unannotated regions of TCGA samples

## Projected Pipeline

### Filtering for unannotated regions and binning

Each .bam RNA-seq file will be filtered for regions unannotated in the reference GTF file provided and binned into 1kb regions.

```bash
filt_noncanonical.sh input_dir unannotated_bed genome_fasta analysis_method
```

input_dir: Input directory of the .bam RNA-seq file
unannotated_bed: The bed file created from the inverse of the .gtf annoataion file
genome_fasta: The .fa file of the reference genome used
analysis method: (read_depth, position_depth) The method in which the data is collected
- read_depth: The data collected per 1kb is the read depth at each bin
- position_depth: The data collected per 1kb is the sum of position coverage


### Form Depth Matrix

NEED TO REWORK

Form a .mtx file of depth by window and sample

TEMPORARY

```bash
python3 process_depth_files(input_dir, output_file, selected_chrom)
```

### JUPYTER NOTEBOOKS FOR DOWNSTREAM ANALYSIS

Will be saved in notebooks directory
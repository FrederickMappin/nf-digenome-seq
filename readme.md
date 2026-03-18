
# nf-digenome-seq

Nextflow DSL2 pipeline for running a Digenome-seq style analysis workflow.

## Development Status

This project is still in development.

- Interfaces, parameters, and outputs may change between commits.
- Some modules are present but not yet fully wired into the top-level workflow.
- Please treat this repository as experimental until a tagged release is published.

## Overview

The pipeline currently supports two execution paths:

1. BAM input mode (direct Digenome analysis)
2. Paired-end FASTQ mode (FastQC + BWA-MEM + Digenome)

Core modules in this repository:

- `FASTQC` for read quality reports
- `BWA_MEM` for alignment
- `DIGENOME` for cleavage site calling CSV/log output

An additional helper script, `process_csv_files.py`, can annotate and merge CSV outputs.

## Repository Layout

- `main.nf`: top-level workflow
- `nextflow.config`: pipeline parameters, profiles, and reporting/provenance setup
- `conf/base.config`: resource labels and process defaults
- `conf/modules.config`: module-level settings and publish directories
- `modules/`: DSL2 module implementations
- `data/`: example local input files (including BAM mode example CSV)

## Requirements

- Nextflow >= 22.10.1
- Java 11+
- One runtime profile:
	- `docker`
	- `singularity`
	- `conda` or `mamba`

## Quick Start

Run from repository root.

### 1) BAM input mode (recommended for current repo contents)

Example file already included: `data/bam.csv`

```bash
nextflow run main.nf \
	-profile docker \
	--bam_csv data/bam.csv \
	--q 0 \
	--overhang 0 \
	--outdir results
```

### 2) Paired-end FASTQ mode

Use this mode only if you provide a paired-end sample sheet and BWA reference/index files.

```bash
nextflow run main.nf \
	-profile docker \
	--input data/paired-end.csv \
	--fasta data/reference/hg19_chr8.fa \
	--bwa_index data/reference \
	--outdir results
```

## Input Formats

### BAM CSV (`--bam_csv`)

Required columns:

- `sample_id`
- `bam_path`

Example:

```csv
sample_id,bam_path
treated,data/treated.sorted.bam
wt,data/wt.sorted.bam
```

### Paired-end CSV (`--input`)

Required columns:

- `sample_id`
- `fastq_1`
- `fastq_2`

## Main Parameters

- `--bam_csv`: optional CSV of BAM files for direct Digenome analysis
- `--input`: paired-end FASTQ sample sheet (used when `--bam_csv` is not set)
- `--fasta`: reference FASTA path
- `--bwa_index`: directory containing BWA index files
- `--q`: Digenome quality threshold
- `--overhang`: sticky-end overhang length
- `--outdir`: output directory (default: `results`)

## Outputs

Published outputs are organized under `--outdir` (default `results`):

- `results/digenome/`: Digenome CSV and log files
- `results/alignment/`: alignment BAM/CSI files (FASTQ mode)
- `results/fastqc/`: FastQC reports (FASTQ mode)
- `results/pipeline_info/`: timeline, report, trace, and DAG HTML/TXT files

Provenance metadata is also enabled through `nf-prov`.

## Optional CSV Post-processing

The script `process_csv_files.py` can:

- add a `Filename` column to each CSV in a directory
- optionally concatenate processed CSVs into one output file

Example:

```bash
python process_csv_files.py results/digenome
```

## Notes and Limitations

- This pipeline is under active development.
- A `multiqc` module exists in `modules/`, but it is not currently invoked in `main.nf`.
- Default config values may require project-specific adjustment before production use.

## Citation

If you use this workflow or Digenome-seq in your work, please cite the original Digenome publications:

- Park J. et al. Digenome-seq web tool for profiling CRISPR specificity. Nature Methods 14, 548-549 (2017).
- Kim D. et al. Digenome-seq: genome-wide profiling of CRISPR-Cas9 off-target effects in human cells. Nature Methods 12, 237-243 (2015).

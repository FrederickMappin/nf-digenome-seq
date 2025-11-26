#!/usr/bin/env nextflow

// Import modules
include { FASTQC } from './modules/fastqc/main'
include { BWA_MEM } from './modules/mem/main'
include { DIGENOME } from './modules/digenome/main'

/*
 * Pipeline parameters
 */


params.input = "${projectDir}/data/paired-end.csv"
params.outdir = "results"
params.fasta = "${projectDir}/data/reference/hg19_chr8.fa"
params.bwa_index = "${projectDir}/data/reference"
params.q = 0  // Quality threshold for digenome analysis
params.overhang = 0  // Length of sticky end overhang
params.bam_csv = null  // CSV for direct BAM input

/*
 * Main workflow
 */
workflow {

    if (params.bam_csv) {
        // Read BAMs from CSV and create channel for Digenome
        ch_bam = Channel
            .fromPath(params.bam_csv, checkIfExists: true)
            .splitCsv(header: true)
            .map { row -> [ [ id: row.sample_id ], file(row.bam_path) ] }

        DIGENOME(
            ch_bam,
            params.q,
            params.overhang
        )

        DIGENOME.out.csv.view { meta, csv -> "Digenome CSV: ${meta.id} -> ${csv}" }
        DIGENOME.out.log.view { meta, log -> "Digenome Log: ${meta.id} -> ${log}" }
    } else {
        // Read the paired-end CSV file and create a channel with meta map and reads
        ch_input = channel
            .fromPath(params.input, checkIfExists: true)
            .splitCsv(header: true)
            .map { row ->
                def meta = [ id: row.sample_id, single_end: false ]
                def reads = [ file(row.fastq_1), file(row.fastq_2) ]
                [ meta, reads ]
            }

        // Run FastQC on the paired-end reads
        FASTQC(ch_input)

        // Prepare reference genome and index files
        ch_fasta = Channel.fromPath(params.fasta, checkIfExists: true)
            .map { fasta -> [ [ id: 'genome' ], fasta ] }

        ch_bwa_index = Channel.fromPath("${params.bwa_index}/hg19_chr8.fa.{amb,ann,bwt,pac,sa}", checkIfExists: true)
            .collect()
            .map { files -> [ [ id: 'genome' ], files ] }

        // Run BWA-MEM alignment
        BWA_MEM(
            ch_input,
            ch_bwa_index,
            ch_fasta,
            true  // sort_bam = true
        )

        // Run Digenome analysis on aligned BAM files
        DIGENOME(
            BWA_MEM.out.bam,
            params.q,
            params.overhang
        )

        // View the outputs
        FASTQC.out.html.view { meta, html -> "FastQC HTML: ${meta.id} -> ${html}" }
        BWA_MEM.out.bam.view { meta, bam -> "BAM file: ${meta.id} -> ${bam}" }
        DIGENOME.out.csv.view { meta, csv -> "Digenome CSV: ${meta.id} -> ${csv}" }
        DIGENOME.out.log.view { meta, log -> "Digenome Log: ${meta.id} -> ${log}" }
    }
}


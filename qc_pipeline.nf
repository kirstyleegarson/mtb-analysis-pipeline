#!/usr/bin/env nextflow

// Parameters
params.input = "samplesheet.csv"
params.outdir = "results"

// Read sample sheet and create channel
Channel
    .fromPath(params.input)
    .splitCsv(header: true)
    .map { row ->
        def sample = row.sample
        def fastq1 = file(row.fastq_1)
        def fastq2 = file(row.fastq_2)
        return [sample, [fastq1, fastq2]]
    }
    .set { read_pairs_ch }

// FastQC process
process fastqc {
    // Load required modules
    module 'fastqc/0.12.1'

    // Save results
    publishDir "${params.outdir}/fastqc", mode: 'copy'

    // Use sample name for process identification
    tag "$sample_id"

    input:
    tuple val(sample_id), path(reads)

    output:
    path "*_fastqc.{zip,html}"

    script:
    """
    echo "Running FastQC on ${sample_id}"
    echo "Processing files: ${reads.join(', ')}"
    fastqc ${reads}
    """
}

// Show what files were created
fastqc_ch.view { "FastQC report: $it" }

process FASTP {
    tag "${sample_id}"
    publishDir "results/qc", mode: 'copy'

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}_trimmed_1.fastq.gz"), path("${sample_id}_trimmed_2.fastq.gz"), emit: trimmed_reads
    path "${sample_id}_fastp.html", emit: html_report
    path "${sample_id}_fastp.json", emit: json_report

    script:
    """
    fastp \\
        --in1 ${reads[0]} \\
        --in2 ${reads[1]} \\
        --out1 ${sample_id}_trimmed_1.fastq.gz \\
        --out2 ${sample_id}_trimmed_2.fastq.gz \\
        --html ${sample_id}_fastp.html \\
        --json ${sample_id}_fastp.json \\
        --thread 2
    """
}
process BWA_ALIGN {
    tag "${sample_id}"
    publishDir "results/bam", mode: 'copy'

    input:
    tuple val(sample_id), path(read1), path(read2)
    path ref
    path index_files

    output:
    tuple val(sample_id), path("${sample_id}.sorted.bam"), path("${sample_id}.sorted.bam.bai"), emit: bam

    script:
    """
    bwa mem -t 2 -R "@RG\\tID:${sample_id}\\tSM:${sample_id}\\tPL:ILLUMINA" ${ref} ${read1} ${read2} | \
    samtools sort -@ 2 -o ${sample_id}.sorted.bam -
    samtools index ${sample_id}.sorted.bam
    """
}
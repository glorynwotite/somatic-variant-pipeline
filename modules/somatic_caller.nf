process SOMATIC_CALLER {
    tag "${pair_id}"
    publishDir "results/vcf", mode: 'copy'

    input:
    tuple val(pair_id), path(tumor_bam), path(tumor_bai), path(normal_bam), path(normal_bai)
    path ref
    path ref_fai

    output:
    tuple val(pair_id), path("${pair_id}_somatic.vcf"), emit: vcf

    script:
    """
    bcftools mpileup -Ou -f ${ref} ${tumor_bam} ${normal_bam} | \
    bcftools call -mv -Ov -o ${pair_id}_somatic.vcf
    """
}
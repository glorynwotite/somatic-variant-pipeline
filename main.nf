nextflow.enable.dsl=2

params.reads_dir = "${projectDir}/data/samples"
params.ref       = "${projectDir}/data/ref/genome.fasta"
params.outdir    = "results"

include { FASTP } from './modules/fastp'
include { BWA_ALIGN } from './modules/bwa_align'
include { SOMATIC_CALLER } from './modules/somatic_caller'
include { MULTIQC } from './modules/multiqc'

process INDEX_REF {
    tag "${ref.name}"

    input:
    path ref

    output:
    path ref, emit: reference
    path "${ref}.*", emit: index_files
    path "${ref}.fai", emit: fai

    script:
    """
    bwa index ${ref}
    samtools faidx ${ref}
    """
}

workflow {
    log.info """\
    =======================================================
    T U M O R - N O R M A L   S O M A T I C   P I P E L I N E
    =======================================================
    reads      : ${params.reads_dir}
    reference  : ${params.ref}
    outdir     : ${params.outdir}
    =======================================================
    """

    ref_ch = Channel.fromPath(params.ref)
    INDEX_REF(ref_ch)

    raw_reads_ch = Channel.fromFilePairs("${params.reads_dir}/*_{1,2}.fastq.gz")

    FASTP(raw_reads_ch)

    BWA_ALIGN(
        FASTP.out.trimmed_reads,
        INDEX_REF.out.reference.first(),
        INDEX_REF.out.index_files.first()
    )

    tumor_bams = BWA_ALIGN.out.bam
        .filter { sample_id, bam, bai -> sample_id.contains('tumor') }
        .map { sample_id, bam, bai -> 
            def patient_id = sample_id.replaceAll(/_tumor/, '')
            tuple(patient_id, bam, bai)
        }

    normal_bams = BWA_ALIGN.out.bam
        .filter { sample_id, bam, bai -> sample_id.contains('normal') }
        .map { sample_id, bam, bai -> 
            def patient_id = sample_id.replaceAll(/_normal/, '')
            tuple(patient_id, bam, bai)
        }

    paired_bams_ch = tumor_bams.join(normal_bams)

    SOMATIC_CALLER(
        paired_bams_ch,
        INDEX_REF.out.reference.first(),
        INDEX_REF.out.fai.first()
    )

    // Collect all QC reports and generate the MultiQC dashboard
    qc_reports = FASTP.out.json_report.collect()
    MULTIQC(qc_reports)
}

process MULTIQC {
    publishDir "results/multiqc", mode: 'copy'

    input:
    path ('qc_files/*')

    output:
    path "multiqc_report.html", emit: report
    path "*_data", emit: data

    script:
    """
    multiqc qc_files/ -n multiqc_report.html
    """
}

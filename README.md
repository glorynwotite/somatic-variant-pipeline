# End-to-End Somatic Variant Calling Pipeline (Nextflow DSL2)

An automated, containerized bioinformatics workflow for somatic mutation detection from matched tumor-normal paired-end sequencing data.

## Architecture Overview
Raw FASTQ Pairs (Tumor & Normal)
│
▼
[ FASTP ] ──► Quality Filtering, Adapter Trimming & HTML QC
│
▼
[ BWA-MEM ] ──► Reference Genome Alignment
│
▼
[ SAMTOOLS ] ──► Coordinate Sorting & BAM Indexing (.bam / .bai)
│
▼
[ Channel Join ] ──► Matched-Pair Aggregation by Patient ID
│
▼
[ BCFTOOLS ] ──► Somatic Variant Calling & VCF Generation
│
▼
[ MULTIQC ] ──► Aggregated Interactive QC Report
## Features
* **Nextflow DSL2 Architecture:** Modular pipeline components for alignment, variant calling, and reporting.
* **Containerized Reproducibility:** Containerized execution using Docker and BioContainers.
* **Matched-Pair Processing:** Channel manipulation logic to dynamically match tumor and normal samples per patient.
* **Aggregated QC:** Automated MultiQC report synthesis.

## Quick Start

### Prerequisites
* Nextflow (>= 22.10)
* Docker Desktop / Docker Engine

### Execution
Run the pipeline with Docker enabled:

```bash
nextflow run main.nf -with-docker
results/qc/ - fastp read quality dashboards (HTML/JSON).

results/bam/ - Coordinate-sorted and indexed BAM files.

results/vcf/ - Somatic variant call files.

results/multiqc/ - MultiQC interactive HTML summary report.

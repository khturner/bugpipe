workflow bugpipe {

    String SRA_accession

    call download_fastq {
        input:
            SRA_accession = SRA_accession
    }

    call trim_reads {
        input:
            SRA_accession = SRA_accession,
            raw_reads_1 = download_fastq.raw_reads_1,
            raw_reads_2 = download_fastq.raw_reads_2
    }

    call assemble_genome {
        input:
            SRA_accession = SRA_accession,
            trimmed_reads_1 = trim_reads.trimmed_reads_1,
            trimmed_reads_2 = trim_reads.trimmed_reads_2
    }

    call annotate_assembly {
        input:
    }

    call generate_assembly_report {
        input:
    }

}

task download_fastq {

    String SRA_accession

    command {
        fastq-dump --split-files --gzip ${SRA_accession}
    }

    output {
        File raw_reads_1 = "${SRA_accession}_1.fastq.gz"
        File raw_reads_2 = "${SRA_accession}_2.fastq.gz"
    }

    runtime {
        docker: "bugpipe/sratoolkit:latest"
        memory: "4G"
        cpu: "1"
    }
    
}

task trim_reads {

    String SRA_accession
    File raw_reads_1
    File raw_reads_2

    command {
        trim_galore --paired ${raw_reads_1} ${raw_reads_2}
    }

    output {
        File trimmed_reads_1 = "${SRA_accession}_1_val_1.fq.gz"
        File trimmed_reads_2 = "${SRA_accession}_2_val_2.fq.gz"
    }

    runtime {
        docker: "bugpipe/trim_galore:latest"
        memory: "4G"
        cpu: "1"
    }

}

task assemble_genome {

    String SRA_accession
    File trimmed_reads_1
    File trimmed_reads_2
    
    command {
        shovill --outdir ${SRA_accession} --R1 ${trimmed_reads_1} --R2 ${trimmed_reads_2}
    }

    output {
        # YOU ARE HERE

    }

    runtime {
        docker: "bugpipe/shovill:latest"
        memory: "8G"
        cpu: "1"
    }

}

task annotate_assembly {

}

task generate_assembly_report {

}
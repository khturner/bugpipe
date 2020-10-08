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
            SRA_accession = SRA_accession,
            contigs = assemble_genome.contigs
    }

    call generate_assembly_report {
        input:
            SRA_accession = SRA_accession,
            contigs = assemble_genome.contigs,
            gff = annotate_assembly.gff
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
        File contigs = "${SRA_accession}/contigs.fa"
    }

    runtime {
        docker: "bugpipe/shovill:latest"
        memory: "7G"
        cpu: "1"
    }

}

task annotate_assembly {

    String SRA_accession
    File contigs

    command {
        prokka --outdir ${SRA_accession}.prokka --prefix ${SRA_accession} --locustag ${SRA_accession} ${contigs}
    }

    runtime {
        docker: "bugpipe/prokka:latest"
        memory: "4G"
        cpu: "1"
    }

    output {
        File gff = "${SRA_accession}.prokka/${SRA_accession}.gff"
    }
}

task generate_assembly_report {

    String SRA_accession
    File contigs
    File gff

    command {
        quast.py -o ${SRA_accession}.quast -g ${gff} ${contigs}
    }

    runtime {
        docker: "bugpipe/quast:latest"
        memory: "4G"
        cpu: "1"
    }

}
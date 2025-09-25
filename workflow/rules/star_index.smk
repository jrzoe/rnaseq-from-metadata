rule star_index:
    input:
        fasta=str(config["genome_fasta"]),
        gtf=str(config["annotation"])
        # sjdbOverhang default of 99 is fine for longer reads
    output:
        directory(str(config["star_index"])),
    threads: 8
    params:
        extra="",
    log:
        "logs/star_index.log",
    wrapper:
        "v7.2.0/bio/star/index"

rule samtools_index:
    input:
        "{base_path}/star/bam/{basename}_sortedByCoord.bam",
    output:
        "{base_path}/star/bam/{basename}_sortedByCoord.bam.bai",
    log:
        "{base_path}/logs/samtools_index/{basename}_Log.out",
    params:
        extra="-b",  # optional params string
    threads: 4  # This value - 1 will be sent to -@
    wrapper:
        "v7.2.0/bio/samtools/index"

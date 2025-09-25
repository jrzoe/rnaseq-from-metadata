rule feature_counts:
    input:
        # list of sam or bam files
        samples="{base_path}/star/bam/{basename}_sortedByCoord.bam",
        annotation=str(config["annotation"]),
    output:
        multiext(
            "{base_path}/featurecounts/{basename}_gene_counts",
            ".txt",
            ".txt.summary",
        ),
    threads: 4
    params:
        strand=lambda wildcards: str(
            samples.loc[
                samples["sample_basename"] == wildcards.basename,
                "strand_specific"
                ].values[0] # technical replicates must be same strandedness
        ),
        r_path="",  # implicitly sets the --Rpath flag
        extra = (
            "-F GTF -t exon -g gene_id -p --countReadPairs {}"
        ).format(
            config["featurecounts_extra"]
        ),
    log:
        "{base_path}/logs/featurecounts/{basename}.log",
    wrapper:
        "v7.2.0/bio/subread/featurecounts"

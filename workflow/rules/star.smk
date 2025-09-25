def get_seq_reps(wildcards):
    return samples.loc[
        samples["sample_basename"] == wildcards.basename,
        "seq_replicate"
    ].sort_values().tolist()

rule star_pe_multi:
    input:
        # paired end reads needs to be ordered so each item in the two lists match
        fq1=lambda wildcards: expand(
            "{{base_path}}/fastp/{{basename}}_run{seq_rep}_R1.fq.gz",
            seq_rep=get_seq_reps(wildcards)
        ),
        fq2=lambda wildcards: expand(
            "{{base_path}}/fastp/{{basename}}_run{seq_rep}_R2.fq.gz",
            seq_rep=get_seq_reps(wildcards)
        ),
        # path to STAR reference genome index
        idx=str(config["star_index"]),
    output:
        # would have to edit wrapper in order to output separate unmapped files;
        # cannot use functions to define output files
        aln="{base_path}/star/bam/{basename}_sortedByCoord.bam",
        log="{base_path}/logs/star/{basename}_Log.out",
        log_final="{base_path}/report/star/{basename}_Log.final.out",
        sj="{base_path}/star/sj/{basename}_SJ.out.tab",
        reads_per_gene="{base_path}/star/gene_counts/{basename}_ReadsPerGene.out.tab",
    log:
        "{base_path}/logs/star/{basename}.log"
    params:
        # optional parameters
        extra = (
            "--outSAMtype BAM SortedByCoordinate "
            "--quantMode TranscriptomeSAM GeneCounts "
            "--sjdbGTFfile {} {}"
        ).format(
            str(config["annotation"]),
            config["star_extra"]
        ),
    threads: 8
    retries: 2
    wrapper:
        "v7.2.0/bio/star/align"

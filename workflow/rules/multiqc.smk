# get sample basenames for a given base_path
def get_basenames(wildcards):
    return samples.loc[
        samples["base_path"] == wildcards.base_path,
        "sample_basename"
    ].unique().tolist()

rule multiqc:
    input:
        lambda wildcards: expand(
            "{{base_path}}/report/fastp/{sample.sample_basename}_run{sample.seq_replicate}.json",
            sample=samples.loc[
                samples["base_path"] == wildcards.base_path,
                ["sample_basename", "seq_replicate"]
            ].itertuples(),
        ),
        lambda wildcards: expand(
            "{{base_path}}/report/star/{basename}_Log.final.out",
            basename=get_basenames(wildcards),
        ),
        lambda wildcards: expand(
            "{{base_path}}/report/rseqc/junction_anno/{basename}.junction.bed",
            basename=get_basenames(wildcards),
        ),
        lambda wildcards: expand(
            "{{base_path}}/report/rseqc/junction_sat/{basename}.junctionSaturation_plot.pdf",
            basename=get_basenames(wildcards),
        ),
        lambda wildcards: expand(
            "{{base_path}}/report/rseqc/infer_exp/{basename}.infer_experiment.txt",
            basename=get_basenames(wildcards),
        ),
        lambda wildcards: expand(
            "{{base_path}}/report/rseqc/bam_stat/{basename}.stats.txt",
            basename=get_basenames(wildcards),
        ),
        lambda wildcards: expand(
            "{{base_path}}/report/rseqc/innder_dist/{basename}.inner_distance.txt",
            basename=get_basenames(wildcards),
        ),
        lambda wildcards: expand(
            "{{base_path}}/report/rseqc/read_distr/{basename}.readdistribution.txt",
            basename=get_basenames(wildcards),
        ),
        lambda wildcards: expand(
            "{{base_path}}/report/rseqc/read_dup/{basename}.DupRate_plot.pdf",
            basename=get_basenames(wildcards),
        ),
        lambda wildcards: expand(
            "{{base_path}}/report/rseqc/readgc/{basename}.GC_plot.pdf",
            basename=get_basenames(wildcards),
        ),
        lambda wildcards: expand(
            "{{base_path}}/logs/rseqc/junction_anno/{basename}.log",
            basename=get_basenames(wildcards),
        ),
        lambda wildcards: expand(
            "{{base_path}}/featurecounts/{basename}_gene_counts.txt.summary",
            basename=get_basenames(wildcards),
        ),
        config="config/multiqc_config.yaml",
    output:
        "{base_path}/report/multiqc_report.html",
    log:
        "{base_path}/logs/multiqc.log",
    wrapper:
        "v7.2.0/bio/multiqc"

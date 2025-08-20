import os

bed_path = str(config["annotation"]).replace(".gtf", ".bed")

# generate bed file
rule rseqc_gtf2bed:
    input:
        str(config["annotation"]),
    output:
        bed=str(config["annotation"]).replace(".gtf", ".bed"),
        db=temp(str(config["annotation"]).replace(".gtf", ".db")),
    log:
        "logs/rseqc_gtf2bed.log",
    conda:
        "../envs/gffutils.yaml"
    script:
        "../scripts/gtf2bed.py"


rule rseqc_junction_annotation:
    input:
        bam="{base_path}/star/bam/{basename}_sortedByCoord.bam",
        bed=bed_path,
    output:
        "{base_path}/report/rseqc/junction_anno/{basename}.junction.bed",
    priority: 1
    log:
        "{base_path}/logs/rseqc/junction_anno/{basename}.log",
    params:
        extra=r"-q 255",  # STAR uses 255 as a score for unique mappers
        prefix=lambda w, output: output[0].replace(".junction.bed", ""),
    conda:
        "../envs/rseqc.yaml"
    shell:
        "junction_annotation.py {params.extra} -i {input.bam} -r {input.bed} -o {params.prefix} "
        "> {log[0]} 2>&1"


rule rseqc_junction_saturation:
    input:
        bam="{base_path}/star/bam/{basename}_sortedByCoord.bam",
        bed=bed_path,
    output:
        "{base_path}/report/rseqc/junction_sat/{basename}.junctionSaturation_plot.pdf"
    priority: 1
    log:
        "{base_path}/logs/rseqc/junction_sat/{basename}.log"
    params:
        extra=r"-q 255",
        prefix=lambda w, output: output[0].replace(".junctionSaturation_plot.pdf", ""),
    conda:
        "../envs/rseqc.yaml"
    shell:
        "junction_saturation.py {params.extra} -i {input.bam} -r {input.bed} -o {params.prefix} "
        "> {log} 2>&1"


rule rseqc_stat:
    input:
        "{base_path}/star/bam/{basename}_sortedByCoord.bam",
    output:
        "{base_path}/report/rseqc/bam_stat/{basename}.stats.txt",
    priority: 1
    log:
        "{base_path}/logs/rseqc/bam_stat/{basename}.log",
    conda:
        "../envs/rseqc.yaml"
    shell:
        "bam_stat.py -i {input} > {output} 2> {log}"


rule rseqc_infer:
    input:
        bam="{base_path}/star/bam/{basename}_sortedByCoord.bam",
        bed=bed_path,
    output:
        "{base_path}/report/rseqc/infer_exp/{basename}.infer_experiment.txt",
    priority: 1
    log:
        "{base_path}/logs/rseqc/infer_exp/{basename}.log",
    conda:
        "../envs/rseqc.yaml"
    shell:
        "infer_experiment.py -r {input.bed} -i {input.bam} > {output} 2> {log}"


rule rseqc_innerdis:
    input:
        bam="{base_path}/star/bam/{basename}_sortedByCoord.bam",
        bed=bed_path,
    output:
        "{base_path}/report/rseqc/innder_dist/{basename}.inner_distance.txt",
    priority: 1
    log:
        "{base_path}/logs/rseqc/innder_dist/{basename}.log",
    params:
        prefix=lambda w, output: output[0].replace(".inner_distance.txt", ""),
    conda:
        "../envs/rseqc.yaml"
    shell:
        "inner_distance.py -r {input.bed} -i {input.bam} -o {params.prefix} > {log} 2>&1"


rule rseqc_readdis:
    input:
        bam="{base_path}/star/bam/{basename}_sortedByCoord.bam",
        bed=bed_path,
    output:
        "{base_path}/report/rseqc/read_distr/{basename}.readdistribution.txt",
    priority: 1
    log:
        "{base_path}/logs/rseqc/read_distr/{basename}.log",
    conda:
        "../envs/rseqc.yaml"
    shell:
        "read_distribution.py -r {input.bed} -i {input.bam} > {output} 2> {log}"


rule rseqc_readdup:
    input:
        "{base_path}/star/bam/{basename}_sortedByCoord.bam",
    output:
        "{base_path}/report/rseqc/read_dup/{basename}.DupRate_plot.pdf",
    priority: 1
    log:
        "{base_path}/logs/rseqc/read_dup/{basename}.log",
    params:
        prefix=lambda w, output: output[0].replace(".DupRate_plot.pdf", ""),
    conda:
        "../envs/rseqc.yaml"
    shell:
        "read_duplication.py -i {input} -o {params.prefix} > {log} 2>&1"


rule rseqc_readgc:
    input:
        "{base_path}/star/bam/{basename}_sortedByCoord.bam",
    output:
        "{base_path}/report/rseqc/readgc/{basename}.GC_plot.pdf",
    priority: 1
    log:
        "{base_path}/logs/rseqc/readgc/{basename}.log",
    params:
        prefix=lambda w, output: output[0].replace(".GC_plot.pdf", ""),
    conda:
        "../envs/rseqc.yaml"
    shell:
        "read_GC.py -i {input} -o {params.prefix} > {log} 2>&1"

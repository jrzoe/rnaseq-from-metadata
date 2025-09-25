rule fastp_pe:
    input:
        sample=[
            "{base_path}/fastq/{basename}_run{seq_rep}_R1.fq.gz",
            "{base_path}/fastq/{basename}_run{seq_rep}_R2.fq.gz"
        ]
    output:
        trimmed=[
            temp("{base_path}/fastp/{basename}_run{seq_rep}_R1.fq.gz"),
            temp("{base_path}/fastp/{basename}_run{seq_rep}_R2.fq.gz")
        ],
        unpaired1=temp("{base_path}/fastp/{basename}_run{seq_rep}_u1.fq.gz"),
        unpaired2=temp("{base_path}/fastp/{basename}_run{seq_rep}_u2.fq.gz"),
        failed=temp("{base_path}/fastp/{basename}_run{seq_rep}_failed.fq.gz"),
        html="{base_path}/report/fastp/{basename}_run{seq_rep}.html",
        json="{base_path}/report/fastp/{basename}_run{seq_rep}.json"
    log:
        "{base_path}/logs/fastp/{basename}_run{seq_rep}.log"
    params:
        # Specify adapter sequences to trim if provided in sample metadata
        adapters=lambda wildcards: ( # \ def overcomplicated this, but it works
            " ".join(filter(None, [
                f"--adapter_sequence {adapter_r1}" 
                if 'adapter_r1' in samples.columns and 
                   len(adapter_r1_vals := samples.loc[(samples['sample_basename'] == wildcards.basename) & (samples['seq_replicate'] == wildcards.seq_rep), 'adapter_r1'].values) > 0 and
                   pd.notna(adapter_r1 := adapter_r1_vals[0]) and 
                   str(adapter_r1).strip() != '' else "",
                f"--adapter_sequence_r2 {adapter_r2}"
                if 'adapter_r2' in samples.columns and 
                   len(adapter_r2_vals := samples.loc[(samples['sample_basename'] == wildcards.basename) & (samples['seq_replicate'] == wildcards.seq_rep), 'adapter_r2'].values) > 0 and
                   pd.notna(adapter_r2 := adapter_r2_vals[0]) and 
                   str(adapter_r2).strip() != '' else ""
            ]))
        ),
        # add in UMI processing per config file if sample has UMI
        extra=lambda wildcards: (
            " ".join(filter(None, [
                config["umi_params"] if samples.loc[(samples["sample_basename"] == wildcards.basename) & (samples["seq_replicate"] == wildcards.seq_rep), "UMI"].iloc[0] == 1 else ""
            ]))
        )
    threads: 4
    retries: 1
    wrapper:
        "v7.2.0/bio/fastp"

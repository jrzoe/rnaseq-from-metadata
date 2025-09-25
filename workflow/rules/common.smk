import pandas as pd
import os
from pathlib import Path

#### sample metadata ####

samples = (
    pd.read_csv(
        config["samples"],
        dtype={"sample_basename": str})
)

# remove samples which don't pass QC
if "qc_fail" not in samples.columns:
    print("No QC column found in samples file - all samples will be used")
else:
    failed = samples[samples["qc_fail"] == 1]["sample_basename"].tolist()
    samples = samples[samples["qc_fail"] != 1]
    if len(failed) > 0:
        print(f"Samples removed due to failing QC: {set(failed)}")

# check that columns from config are valid columns in samples
for col in config["metadata_columns"]:
    if col not in samples.columns:
        raise ValueError(f"Column '{col}' not found in sample metadata file")
    # set data type to string
    samples[col] = samples[col].astype(str)

#### Set wildcard contraints ####

samples["base_path"] = samples.apply(
    lambda sample:
        os.path.join(
            config["data_dir"],
            *[sample[col] for col in config["metadata_columns"]],
        ),
    axis=1
)

wildcard_constraints:
    base_path="|".join(samples["base_path"].unique().tolist()),
    basename="|".join(samples["sample_basename"].unique().tolist()),
    seq_rep="|".join(samples["seq_replicate"].unique().tolist())

#### multiqc output ####

def get_multiqc_output():
    samples["multiqc_out"] = samples.apply(
        lambda sample:
            os.path.join(
                config["data_dir"],
                *[sample[col] for col in config["metadata_columns"]],
                "report",
                "multiqc_report.html"
            ),
        axis=1,
    )
    multiqc_out = samples["multiqc_out"].unique().tolist()
    return multiqc_out

def get_final_output(): 
    final_output = get_multiqc_output()
    return final_output

# rna_seq Pipeline

This pipeline relies on a comma-separated metadata file to process raw paired-end RNAseq fastq files, outputting alignment files, gene counts, and several quality control metrics into a structured data directory. This approach is especially useful for large sequencing projects involving hundreds of samples. For example, for projects with many cell lines, each with a few distinct cell line modifications, it is helpful to organize output files into informative subdirectories (e.g. cell_line_1/gene_mod_x). 

## Preparing the inputs

### Sample metadata

The pipeline requires a sample metadata file to determine file paths for inputs and outputs. In general, it is best to keep any and all metadat you may find handy in the sample sheet, but only some will be used for this pipeline. *For columns names, use underscores rather than spaces between words.*

The sample metadata must be in .csv format and has a few required columns, with an example file found in this repo. The following columns are strictly required to run this pipeline:

* `sample_basename`: This name should be unique for each distinct *biological* sample/replicate (e.g. WT_1, WT_2, KO_1, KO_2). Avoid using R1 or R2 at the end of a `sample_basename` to reflect *biological* replicates, as fastq file names use R1 and R2 to reflect the separate read pairs for a given sample. *Technical* replicates (i.e. running one sample over multiple sequencing runs) must have the same `sample_basename` value and must instead have unique values for `seq_replicate` and `seq_run_name`.
* `seq_replicate`: This should be a unique value for each *technical* sequencing replicate for a given sample. For example, if one sequences a pool of sample libraries over three sequencing runs, the `sample_basename` for each technical replicate will be the same, but the value for  `seq_replicate` must be different (A, B, and C). While these can be any value, I'd recommend successive capital letters to keep the resulting file names short.
* `strand_specific`: [0, 1, 2] 0 for unstranded, 1 for forward-stranded, 2 for reverse-stranded. If you are unsure, put 0 and run the pipeline. The RSeQC infer_experiment results will let you know if you need to change this value. Then run the pipeline again - only the featureCounts and MultiQC steps will be rerun which are quick.
* `UMI`: [0, 1] 0 if the library prep method did not use UMIs, 1 if it did. If 1, one must edit the config file to specify how fastp should process the UMIs. Of note, the pipeline currently does not perform deduplication - it only processes the UMIs if they are present in the fastq files.
* `adapter_r1`: R1 adapter sequence. These values can be left blank and adapters will be autodetected, but it is recommended to specify the adapter sequences if known. 
* `adapter_r2`: R2 adapter sequence. These values can be left blank and adapters will be autodetected, but it is recommended to specify the adapter sequences if known. 

Within the configuration file, the user can also specify additional column names that will be used to generate subdirectories within the root output directory for further organization. The names listed must exactly match the column names in the sample metadata file you provide. The order also matters - the first column name provided will be the first subdirectory created, the second column name will be the second subdirectory created, and so on.

### Configuration file

Within `config.yaml`, the user can edit key parameters detailed therein. Of note, this is where one can (optionally) specify additional column names that will be used to generate subdirectories within the data output directory, to facilitate organization. The names listed must exactly match the column names in the sample metdaata file you provide. The order also matters - the first column name provided will be the first subdirectory created, the second column name will be the second subdirectory created, and so on.

Confiuguration parameters can also be specified at the command line (e.g. --config samples=<path/to/meta.csv>), which will overwrite anything written in the `config.yaml` for the run.

## Running the pipeline

### Setting up environment

To run on an HPC using Slurm, one can run the pipeline within either an interactive session (ideally running within a tmux window) or vai job submission. Snakemake itself is lightweight and submits all jobs to compute nodes; running it within an interactive session is fine and makes it easy to debug any issues that may arise. While the author of the Slurm plugin for Snakemake recommends running from the head node, not all clusters allow this. One will need a conda environment with four packages: `snakemake`, `snakemake-executor-plugin-slurm`, `snakedeploy`, and `snakemake-wrapper-utils`. This environment can be created with:

```bash
conda create -n snakemake -c bioconda snakemake snakemake-executor-plugin-slurm snakedeploy snakemake-wrapper-utils
```

If oyur HPC has a particularly outdated `conda` version installed for all users, one can add `anaconda::conda` to the list of packages to use the faster mamba solver. If an executor other than Slurm is needed, other plugins are available (be sure to update the executor specified in your workflow profile accordingly).

### Deploying the workflow

Deploy this pipeline into the root data directory specified within the `config.yaml` file, within a subdirectory called `snakemake`. For example, you would navigate to `/path/to/config_data_dir/snakemake`, then use `snakedeploy` to deploy the pipeline and keep it associated with the data it will process. Be sure to specify the version number being used, for example:

```bash
snakedeploy deploy-workflow --tag <version_number> git_link.git <dest-dir>
```

### Profiles

A profile for executing this pipeline on an HPC using Slurm is provided in the `workflow/profile/default` directory. Reasonable time and resource limites are set, but be sure to adjust partitions based on your cluster.

### Running

After activating the conda environment, navigate to the root directory of this pipeline. A dry run can be started with:

```bash
snakemake -n --workflow-profile workflow/profile/default --use-conda
```

If the dry run looks appropriate, remove the `-n` flag from the above command and the run will begin.

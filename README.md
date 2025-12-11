# TEProF2

[![License](https://img.shields.io/badge/License-Custom-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/Python-2.7-blue.svg)](https://www.python.org/)
[![R](https://img.shields.io/badge/R-%E2%89%A53.4.1-blue.svg)](https://www.r-project.org/)
[![DOI](https://img.shields.io/badge/DOI-10.1038%2Fs41588--023--01349--3-blue)](https://doi.org/10.1038/s41588-023-01349-3)

**T**ransposable **E**lement **Pro**moter **F**inder **2** (TEProF2) is a comprehensive bioinformatics pipeline designed to identify and quantify transposable element (TE)-derived gene fusion transcripts from short-read RNA-sequencing data.

## 🔬 Overview

TEProf2 enables researchers to:
- **Discover** TE-gene fusion transcripts from RNA-seq data
- **Quantify** transcript expression and identify treatment-enriched transcripts  
- **Analyze** both *de novo* and reference-guided approaches
- **Translate** identified transcripts to predict protein products
- **Identify** potential antigenic peptides for immunotherapy research

This tool has been used to identify transposable element-derived transcripts across 33 cancer types in TCGA data and has applications in cancer genomics, immunology, and gene regulation studies.

## 📖 Citation

If you use TEProf2 in your research, please cite:

> Park, J.S., et al. (2023). Transposable elements as a source of tumor neoantigens in solid tumors. *Nature Genetics*, 55, 701-713. [https://doi.org/10.1038/s41588-023-01349-3](https://doi.org/10.1038/s41588-023-01349-3)

## 📑 Table of Contents

* [Overview](#-overview)
* [Citation](#-citation)
* [Key Features](#-key-features)
* [Quick Start](#-quick-start)
* [Installation](#-installation)
  * [Option 1: Docker (Recommended)](#option-1-docker-recommended)
  * [Option 2: Conda Environment](#option-2-conda-environment)
  * [Option 3: Manual Installation](#option-3-manual-installation)
* [Reference Files](#-reference-files)
  * [Pre-built References](#pre-built-references)
  * [Custom Reference Setup](#custom-reference-setup)
* [Input Data Preparation](#-input-data-preparation)
* [Usage](#-usage)
  * [De Novo Discovery Mode](#de-novo-discovery-mode)
  * [Reference-Guided Mode](#reference-guided-mode)
* [Project Structure](#-project-structure)
* [Detailed Pipeline Steps](#-detailed-pipeline-steps)
* [Output Files](#-output-files)
* [Troubleshooting](#-troubleshooting)
* [Contributing](#-contributing)
* [License](#-license)
* [Support](#-support)

## ✨ Key Features

- **De novo discovery**: Identify novel TE-gene fusion transcripts without prior knowledge
- **Reference-guided analysis**: Quantify known transcripts across samples
- **Multi-species support**: Pre-configured for human (hg19, hg38) and mouse (mm10)
- **Flexible filtering**: Customizable parameters for candidate selection
- **Translation prediction**: Built-in modules for identifying protein-coding potential
- **Treatment enrichment**: Statistical tools for identifying disease-specific transcripts
- **Ballgown integration**: Compatible with downstream differential expression analysis

## 🚀 Quick Start

For users who want to get started quickly:

```bash
# 1. Build Docker image from source
git clone https://github.com/junseokpark/TEProf2Paper.git
cd TEProf2Paper/docker
docker build -t teprof2 .

# 2. Run the container
docker run -it -v /path/to/data:/data teprof2

# 3. Inside the container, activate the environment
conda activate teprof2

# 4. Set up your arguments.txt file (see Reference Files section)
# 5. Run the pipeline on your stringtie GTF files
```

For detailed instructions, see the [Installation](#-installation) and [Usage](#-usage) sections below.

## 📦 Installation

### Option 1: Docker (Recommended)

Docker provides a containerized environment with all dependencies pre-installed.

**Build from source:**
```bash
# Clone the repository
git clone https://github.com/junseokpark/TEProf2Paper.git
cd TEProf2Paper/docker

# Build the Docker image
docker build -t teprof2 .

# Run the container
docker run -it -v /path/to/your/data:/data teprof2
```

**Note:** Replace `/path/to/your/data` with your actual data directory path.

### Option 2: Conda Environment

Conda installation is recommended for users who prefer not to use Docker.

**Prerequisites:**
- Conda or Miniconda installed ([installation guide](https://docs.anaconda.com/anaconda/install/))

**Installation steps:**
```bash
# Clone the repository
git clone https://github.com/junseokpark/TEProf2Paper.git
cd TEProf2Paper

# Create conda environment
conda env create -f TEProf2.yml

# Activate the environment
conda activate teprof2

# Install Xmisc R package
R
```

In the R console:
```r
# Try installing from CRAN first
install.packages('Xmisc')

# If the above fails (Xmisc removed from CRAN), use devtools:
# Exit R and run:
# conda install -c conda-forge r-devtools
# Then start R again and run:
Sys.setenv(TAR = "/bin/tar")
library(devtools)
install_url("https://cran.r-project.org/src/contrib/Archive/Xmisc/Xmisc_0.2.1.tar.gz")
```

**Add bin folder to PATH:**
```bash
export PATH="/path/to/TEProf2Paper/bin:$PATH"
# Add this line to your ~/.bashrc or ~/.bash_profile for persistence
```

### Option 3: Manual Installation

Install dependencies individually if conda is not available.

**Required Software:**
- Python 2.7 with cPickle and pytabix 0.1
- R ≥ 3.4.1
- stringtie ≥ 1.3.3
- samtools ≥ 1.3.1
- cufflinks ≥ 2.2.1

**R Packages:**
- ggplot2
- BSgenome.Hsapiens.UCSC.hg38 (or genome of your choice)
- Xmisc
- reshape2

**Installation commands:**
```bash
# Python packages
pip install pytabix==0.1

# R packages
R -e "install.packages(c('ggplot2', 'reshape2', 'Xmisc'))"
R -e "BiocManager::install('BSgenome.Hsapiens.UCSC.hg38')"
```

**Note:** The pipeline has been tested with the specified versions and may not work correctly with newer versions.

## 📚 Reference Files

TEProf2 requires several reference files for annotation. These files are specified in an `arguments.txt` configuration file.

### Pre-built References

We provide pre-built reference files for three genome assemblies:

| Assembly | Download Link | Size |
|----------|--------------|------|
| **hg38** | [Download](https://wangftp.wustl.edu/~nshah/rnapipeline_public_link/rnapipelinerefhg38.tar.gz) | ~5 GB |
| **hg19** | [Download](https://wangftp.wustl.edu/~nshah/rnapipeline_public_link/rnapipelinerefhg19.tar.gz) | ~5 GB |
| **mm10** | [Download](https://wangftp.wustl.edu/~nshah/rnapipeline_public_link/rnapipelinerefmm10.tar.gz) | ~4 GB |

**Setup:**
```bash
# Download and extract reference files
wget https://wangftp.wustl.edu/~nshah/rnapipeline_public_link/rnapipelinerefhg38.tar.gz
tar -xzf rnapipelinerefhg38.tar.gz

# Create arguments.txt file (see example below)
```

**Example arguments.txt:**
```
rmsk	/path/to/reference/rmskhg38.bed6.gz
rmskannotationfile	/path/to/reference/repeatmasker_description_uniq.lst
gencodeplusdic	/path/to/reference/genecode_plus_hg38.dic
gencodeminusdic	/path/to/reference/genecode_minus_hg38.dic
focusgenes	/path/to/reference/oncogenes_augmented.txt
plusintron	/path/to/reference/gencode.v25.annotation.sorted.gtf_introns_plus_sorted.gz
minusintron	/path/to/reference/gencode.v25.annotation.sorted.gtf_introns_minus_sorted.gz
```

**Required Fields:**
- `rmsk`: Tabix-indexed BED6 file of RepeatMasker annotations
- `rmskannotationfile`: Tab-delimited file mapping TE subfamily to class and family
- `gencodeplusdic`: Dictionary of GENCODE elements for plus (+) strand
- `gencodeminusdic`: Dictionary of GENCODE elements for minus (-) strand

**Optional Fields:**
- `focusgenes`: List of genes to focus analysis on (e.g., oncogenes)
- `plusintron`: Tabix-indexed intron annotations for plus strand
- `minusintron`: Tabix-indexed intron annotations for minus strand

### Custom Reference Setup

For other genome assemblies or custom TE annotations, see the [Detailed Pipeline Steps](#-detailed-pipeline-steps) section below for instructions on creating custom reference files.

## 🧬 Input Data Preparation

TEProf2 requires stringtie-assembled GTF files as input. The pipeline has been optimized for stringtie output and has not been extensively tested with other assemblers.

### From Raw FASTQ to Input GTF

**Complete workflow:**

1. **Quality Control**
   ```bash
   fastqc sample.fastq.gz
   ```

2. **Adapter Trimming** (e.g., with Trimmomatic or cutadapt)

3. **Alignment** (STAR recommended)
   ```bash
   STAR --genomeDir /path/to/genome_index \
        --readFilesIn sample_R1.fastq.gz sample_R2.fastq.gz \
        --readFilesCommand zcat \
        --outSAMtype BAM SortedByCoordinate \
        --outSAMstrandField intronMotif
   ```
   
   **Note:** The `-XS` tag must be present for stringtie. HISAT2 can also be used but uses quality 60 for unique reads instead of 255.

4. **Filtering for Uniquely Mapped Reads**
   ```bash
   samtools view -q 255 -h -b input.bam > uniquely_mapped.bam
   # Use -q 60 for HISAT2-aligned files
   ```

5. **Index BAM Files**
   ```bash
   samtools index uniquely_mapped.bam
   ```

6. **Assembly with stringtie**
   ```bash
   samtools view -q 255 -h uniquely_mapped.bam | \
   stringtie - -o sample.gtf -m 100 -c 1
   ```
   
   **Parameters:**
   - `-m 100`: Minimum assembled transcript length
   - `-c 1`: Minimum coverage for low-coverage transcript discovery
   - Adjust parameters based on your sequencing depth and study design

**Important:** Name your GTF files to match your BAM files (e.g., `sample.bam` → `sample.gtf`) to facilitate downstream read validation steps.

## 💻 Usage

TEProf2 can be run in two modes:

### De Novo Discovery Mode

Recommended for discovering novel TE-gene fusions in your dataset.

**Overview:** This mode performs *de novo* assembly and discovery of TE-gene fusion transcripts, validates candidates with read support, and quantifies expression across samples.

**Quick workflow:**
```bash
# 1. Annotate each GTF file
rmskhg38_annotate_gtf_update_test_tpm.py sample1.gtf arguments.txt

# 2. Process annotations
annotationtpmprocess.py sample1.gtf_annotated_filtered_test_all

# 3-11. Continue with remaining steps (see detailed guide below)
```

See [De Novo Discovery Pipeline](#de-novo-discovery-pipeline-detailed-steps) for complete step-by-step instructions.

### Reference-Guided Mode

Use this mode when you have a pre-defined set of TE-gene transcripts to quantify (e.g., from a previous analysis or published dataset).

**Overview:** This mode skips the discovery phase and directly quantifies known transcripts across your samples.

**Quick workflow:**
```bash
# 1. Obtain or create reference GTF/GFF3 file
# Download TCGA reference:
wget https://wangftp.wustl.edu/~nshah/ucsf/TCGA33Download/reference_merged_candidates.gtf

# 2. Annotate reference (if not pre-annotated)
rmskhg38_annotate_gtf_update_test_tpm_cuff.py reference_merged_candidates.gff3

# 3. Quantify with stringtie
# 4-8. Process and analyze (see detailed guide below)
```

See [Reference-Guided Pipeline](#reference-guided-pipeline-detailed-steps) for complete instructions.

## 📁 Project Structure

```
TEProf2Paper/
├── bin/                          # Core pipeline scripts
│   ├── rmskhg38_annotate_gtf_update_test_tpm.py      # GTF annotation
│   ├── annotationtpmprocess.py                        # TPM processing
│   ├── aggregateProcessedAnnotation.R                 # Sample aggregation
│   ├── commandsmax_speed.py                           # Read validation (paired-end)
│   ├── commandsmax_speed_se.py                        # Read validation (single-end)
│   ├── filterReadCandidates.R                         # Candidate filtering
│   ├── mergeAnnotationProcess.R                       # Reference merging
│   ├── finalStatisticsOutput.R                        # Final statistics
│   ├── stringtieExpressionFrac.py                     # Expression fractions
│   ├── translationPart1.R                             # Translation (Kozak)
│   ├── translationPart2.R                             # Translation (CPC2)
│   ├── genecode_to_dic.py                             # GENCODE dictionary builder
│   ├── genecode_introns.py                            # Intron annotation builder
│   └── ...
├── docker/                       # Docker configuration
│   ├── Dockerfile
│   ├── TEProf2.yml
│   └── build.sh
├── TEProf2.yml                   # Conda environment specification
├── LICENSE                       # License information
└── README.md                     # This file

```

## 🔍 Detailed Pipeline Steps

### De Novo Discovery Pipeline (Detailed Steps)

#### Step 1: Setup arguments.txt

Create a tab-delimited configuration file (no headers, no extra lines):

```
rmsk	/path/to/rmskhg38.bed6.gz
rmskannotationfile	/path/to/repeatmasker_description_uniq.lst
gencodeplusdic	/path/to/genecode_plus_hg38.dic
gencodeminusdic	/path/to/genecode_minus_hg38.dic
focusgenes	/path/to/oncogenes_augmented.txt
plusintron	/path/to/introns_plus_sorted.gz
minusintron	/path/to/introns_minus_sorted.gz
```

#### Step 2: Annotate GTF Files

Run annotation on each stringtie GTF file:

```bash
rmskhg38_annotate_gtf_update_test_tpm.py sample.gtf arguments.txt
```

**Outputs:**
- `sample.gtf_annotated_test_all` - All genes
- `sample.gtf_annotated_filtered_test_all` - Filtered for TE-derived
- `sample.gtf_annotated_test` - Focus genes (if specified)
- `sample.gtf_annotated_filtered_test` - Focus genes filtered

[Column descriptions](https://wangftp.wustl.edu/~nshah/rnapipeline_public_link/Transcript%20Annotation%20Description.xlsx)

#### Step 3: Process TPM Estimates

```bash
annotationtpmprocess.py sample.gtf_annotated_filtered_test_all
```

**Output:** `sample.gtf_annotated_filtered_test_all_c` - Adds relative expression metrics

#### Step 4: Aggregate Samples

```bash
aggregateProcessedAnnotation.R -e treatment_label -l 2588 -s 2 -n 1 -a arguments.txt
```

**Key parameters:**
- `-e`: Label in treatment file names (default: '', all samples as treatment)
- `-l`: Max exon 1 length (default: 2588, 99th percentile of GENCODE v25)
- `-s`: Max exon skipping events (default: 2)
- `-n`: Min samples with candidate (default: 1)

**Outputs:**
- `filter_combined_candidates.tsv` - All TE-gene transcripts
- `initial_candidate_list.tsv` - Summary per unique candidate
- `Step4.RData` - R workspace

#### Step 5: Calculate Read Support

**5A. Create output directory:**
```bash
mkdir filterreadstats
```

**5B. Generate commands:**
```bash
# Paired-end
commandsmax_speed.py filter_combined_candidates.tsv /full/path/to/bamfiles/

# Single-end
commandsmax_speed_se.py filter_combined_candidates.tsv /full/path/to/bamfiles/
```

**Output:** `filterreadcommands.txt`

**5C. Run commands in parallel:**
```bash
# For HISAT2 users, first run:
sed -i 's/ 255 / 60 /g' filterreadcommands.txt

# Execute
parallel -j 4 < filterreadcommands.txt
```

**5D. Combine results:**
```bash
find ./filterreadstats -name "*.stats" -type f -maxdepth 1 -print0 | \
  xargs -0 -n128 -P1 grep e > resultgrep_filterreadstatsdone.txt
cat resultgrep_filterreadstatsdone.txt | sed 's/\:/\t/g' > filter_read_stats.txt
```

#### Step 6: Filter by Read Support

```bash
filterReadCandidates.R -r 10 -s 1 -e 0.15 -d 2500
```

**Parameters:**
- `-r`: Min reads in TE per file (default: 10)
- `-s`: Min spanning reads across all files (default: 1)
- `-e`: Max exonization reads percent (default: 0.15)
- `-d`: Min distance from TE to transcript start (default: 2500)

**Outputs:**
- `read_filtered_candidates.tsv`
- `candidate_transcripts.gff3`
- `Step6.RData`

```bash
rm Step4.RData  # Clean up
```

#### Step 7: Merge with Reference

```bash
gffread -E candidate_transcripts.gff3 -T -o candidate_transcripts.gtf
echo candidate_transcripts.gtf > cuffmergegtf.list
cuffmerge -o ./merged_asm_full -g /path/to/gencode.v25.basic.annotation.gtf cuffmergegtf.list
mv ./merged_asm_full/merged.gtf reference_merged_candidates.gtf
gffread -E reference_merged_candidates.gtf -o- > reference_merged_candidates.gff3
```

#### Step 8: Annotate Merged Reference

```bash
rmskhg38_annotate_gtf_update_test_tpm_cuff.py reference_merged_candidates.gff3 arguments.txt
```

**Output:** `reference_merged_candidates.gff3_annotated_filtered_test_all`

#### Step 9: Quantify Expression

```bash
# Single sample
samtools view -q 255 -h sample.bam | \
  stringtie - -o sample.gtf -e -b sample_stats -p 2 -m 100 -c 1 \
  -G reference_merged_candidates.gtf

# Batch processing
find /path/to/bams -name "*bam" | while read file ; do
  xbase=${file##*/}
  echo "samtools view -q 255 -h "$file" | stringtie - -o "${xbase%.*}".gtf -e -b "${xbase%.*}"_stats -p 2 -m 100 -c 1 -G reference_merged_candidates.gtf"
done > quantificationCommands.txt

parallel -j 4 < quantificationCommands.txt
```

#### Step 10: Process Expression Output

**10A. Merge annotations:**
```bash
mergeAnnotationProcess.R -f reference_merged_candidates.gff3_annotated_filtered_test_all
```

**Outputs:** `candidate_introns.txt`, `candidate_names.txt`, `Step10.RData`

```bash
rm Step6.RData  # Clean up
```

**10B. Extract intron coverage:**
```bash
# Find all intron data files
find . -name "*i_data.ctab" > ctab_i.txt

# Extract candidate introns
cat ctab_i.txt | while read ID ; do
  fileid=$(echo "$ID" | awk -F "/" '{print $2}')
  cat <(printf 'chr\tstrand\tstart\tend\t'${fileid/_stats/}'\n') \
      <(grep -F -f candidate_introns.txt $ID | awk -F'\t' '{ print $2"\t"$3"\t"$4"\t"$5"\t"$6 }') \
      > ${ID}_cand
done

# Combine into table
cat <(find . -name "*i_data.ctab_cand" | head -1 | while read file ; do
  cat $file | awk '{print $1"\t"$2"\t"$3"\t"$4}'
done) > table_i_all

find . -name "*i_data.ctab_cand" | while read file ; do
  paste -d'\t' <(cat table_i_all) <(cat $file | awk '{print $5}') > table_i_all_temp
  mv table_i_all_temp table_i_all
done
```

**10C. Process transcript expression:**
```bash
# Generate processing commands
ls ./*stats/t_data.ctab > ctablist.txt
cat ctablist.txt | while read file ; do
  echo "stringtieExpressionFrac.py $file"
done > stringtieExpressionFracCommands.txt

# Execute
parallel -j 4 < stringtieExpressionFracCommands.txt

# Aggregate results
ls ./*stats/t_data.ctab_frac_tot > ctab_frac_tot_files.txt
ls ./*stats/t_data.ctab_tpm > ctab_tpm_files.txt

# Create fraction table
cat <(echo "TranscriptID") <(find . -name "*ctab_frac_tot" | head -1 | while read file ; do
  sort $file | awk '{print $1}'
done) > table_frac_tot

cat ctab_frac_tot_files.txt | while read file ; do
  fileid=$(echo "$file" | awk -F "/" '{print $2}')
  paste -d'\t' <(cat table_frac_tot) <(cat <(echo ${fileid/_stats/}) <(sort $file | awk '{print $2}')) > table_frac_tot_temp
  mv table_frac_tot_temp table_frac_tot
done

# Create TPM table
cat <(echo "TranscriptID") <(find . -name "*ctab_tpm" | head -1 | while read file ; do
  sort $file | awk '{print $1}'
done) > table_tpm

cat ctab_tpm_files.txt | while read file ; do
  fileid=$(echo "$file" | awk -F "/" '{print $2}')
  paste -d'\t' <(cat table_tpm) <(cat <(echo ${fileid/_stats/}) <(sort $file | awk '{print $2}')) > table_tpm_temp
  mv table_tpm_temp table_tpm
done

# Filter for candidates
cat <(head -1 table_frac_tot) <(grep -Ff candidate_names.txt table_frac_tot) > table_frac_tot_cand
cat <(head -1 table_tpm) <(grep -Ff candidate_names.txt table_tpm) > table_tpm_cand
```

#### Step 11: Final Statistics

```bash
finalStatisticsOutput.R -e treatment_label -i 1 -t 1 -a arguments.txt
```

**Parameters:**
- `-e`: Treatment label
- `-i`: Min reads spanning intron (default: 1)
- `-t`: Min gene TPM (default: 1)

**Outputs:**
- `All TE-derived Alternative Isoforms Statistics.xlsx` - Final results
- `allCandidateStatistics.tsv` - Complete statistics table
- `Step11_FINAL.RData`

```bash
rm Step10.RData  # Clean up
```

#### Step 12-14: Translation Analysis (Optional)

**Step 12: Kozak-based translation:**
```bash
translatePart1.R -g BSgenome.Hsapiens.UCSC.hg38
```

**Outputs:** `candidates.fa`, `Step12.RData`

**Step 13: CPC2 analysis:**
```bash
CPC2.py -i candidates.fa -o candidates_cpcout.fa
```

**Step 14: Final translation:**
```bash
translatePart2.R -g BSgenome.Hsapiens.UCSC.hg38
```

**Outputs:** Protein sequences and antigen predictions

```bash
rm Step11_FINAL.RData Step12.RData  # Clean up
```

#### Step 15: Ballgown Integration (Optional)

```bash
mkdir ballgown
cd ballgown
ls -d ../*_stats | while read file ; do
  mkdir $(basename $file)
  cd $(basename $file)
  ls ../${file}/*ctab | while read file2 ; do ln -s $file2 ; done
  cd ..
done
```

### Reference-Guided Pipeline (Detailed Steps)

For quantifying known TE-gene transcripts without discovery:

#### Step 1: Obtain Reference

```bash
# Download TCGA reference (optional)
wget https://wangftp.wustl.edu/~nshah/ucsf/TCGA33Download/reference_merged_candidates.gtf
wget https://wangftp.wustl.edu/~nshah/ucsf/TCGA33Download/reference_merged_candidates.gff3

# Or convert custom GTF to GFF3
gffread -E custom_reference.gtf -o- > reference_merged_candidates.gff3
```

#### Step 2: Annotate Reference (if needed)

```bash
rmskhg38_annotate_gtf_update_test_tpm_cuff.py reference_merged_candidates.gff3 arguments.txt
```

#### Step 3-4: Follow De Novo Steps 9-11

Continue with:
- **Step 9**: Quantification with stringtie (see de novo Step 9)
- **Step 10**: Process expression output (see de novo Step 10)
- **Step 11**: Final statistics (see de novo Step 11)

#### Step 5-7: Translation Analysis (Optional)

If you need protein predictions, follow:
- **Step 12**: Kozak-based translation (see de novo Step 12)
- **Step 13**: CPC2 analysis (see de novo Step 13)
- **Step 14**: Final translation (see de novo Step 14)

#### Step 8: Ballgown Integration (Optional)

See de novo Step 15 for Ballgown setup.

## 📊 Output Files

### Key Output Files

| File | Description |
|------|-------------|
| `All TE-derived Alternative Isoforms Statistics.xlsx` | Final candidate statistics with expression, treatment enrichment |
| `candidate_transcripts.gff3` | GFF3 of validated TE-gene transcripts |
| `allCandidateStatistics.tsv` | Complete statistics table for custom analysis |
| `candidates.fa` | RNA sequences of candidate transcripts |
| `table_frac_tot_cand` | Fraction of gene expression per sample |
| `table_tpm_cand` | TPM values per sample |
| `table_i_all` | Intron junction read counts |

### Understanding the Final Statistics

The main output file contains:
- **Transcript information**: ID, gene, TE subfamily/family/class
- **Gene expression**: Mean TPM in treatment and normal samples
- **Fraction expression**: Candidate transcript as fraction of total gene expression
- **Read support**: Intron junction read counts
- **Sample counts**: Number of samples passing thresholds
- **Treatment enrichment**: Statistical enrichment in treatment vs normal

**Note:** The Treatment/Normal Count columns reflect samples passing user-defined thresholds. All underlying data is included for custom re-analysis with different cutoffs.

## 🛠️ Troubleshooting

### Common Issues

**Problem:** `cPickle module not found`
- **Solution:** Ensure you're using Python 2.7. The pipeline requires Python 2.7 due to legacy dependencies.

**Problem:** `Xmisc package installation fails`
- **Solution:** 
  ```r
  # Install devtools first if not available
  install.packages('devtools')
  
  # Then install Xmisc from archive
  Sys.setenv(TAR = "/bin/tar")
  library(devtools)
  install_url("https://cran.r-project.org/src/contrib/Archive/Xmisc/Xmisc_0.2.1.tar.gz")
  ```

**Problem:** No candidates found after filtering
- **Solution:** 
  - Check that BAM files match GTF file names
  - Lower read support thresholds in `filterReadCandidates.R`
  - Verify sequencing depth is adequate (>30M reads recommended)
  - Ensure using uniquely mapped reads (MAPQ 255 for STAR, 60 for HISAT2)

**Problem:** `arguments.txt` not found
- **Solution:** Either place `arguments.txt` in the `bin/` directory or specify full path as second argument to scripts

**Problem:** Memory issues during processing
- **Solution:** 
  - Use focus gene list to reduce computational burden
  - Process samples in batches
  - Increase available RAM or use high-memory compute node

**Problem:** HISAT2 alignment compatibility
- **Solution:** Replace MAPQ threshold 255 with 60 in all commands:
  ```bash
  sed -i 's/ 255 / 60 /g' filterreadcommands.txt
  sed -i 's/ 255 / 60 /g' quantificationCommands.txt
  ```

### Getting Help

- **GitHub Issues**: [Report bugs or ask questions](https://github.com/junseokpark/TEProf2Paper/issues)
- **Documentation**: Review the [detailed pipeline steps](#-detailed-pipeline-steps)
- **Publication**: See the [original paper](https://doi.org/10.1038/s41588-023-01349-3) for methodology details

## 🤝 Contributing

We welcome contributions to TEProf2! Here's how you can help:

### Ways to Contribute

1. **Report Bugs**: Open an issue with detailed steps to reproduce
2. **Suggest Features**: Propose new features or improvements via issues
3. **Improve Documentation**: Submit PRs for documentation enhancements
4. **Code Contributions**: Fix bugs or add features

### Development Guidelines

- Fork the repository and create a feature branch
- Test your changes thoroughly
- Ensure compatibility with existing reference files
- Document new features or parameters
- Submit a pull request with clear description

### Code Style

- Python: Follow PEP 8 guidelines
- R: Follow tidyverse style guide
- Include comments for complex logic
- Add error handling for user inputs

## 📄 License

Copyright (c) 2018 Washington University in St. Louis

This software is provided for academic and non-commercial use under a custom license agreement. See the [LICENSE](LICENSE) file for full terms.

**Key Points:**
- ✅ Free for academic and non-commercial research
- ✅ Can modify and distribute with attribution
- ❌ Commercial use requires separate agreement
- ⚠️ Provided "AS IS" without warranty

**Citation Required:** When publishing results, cite the original paper and acknowledge the software.

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/junseokpark/TEProf2Paper/issues)
- **Questions**: Post in GitHub Discussions or Issues
- **Publication**: [Nature Genetics 2023](https://doi.org/10.1038/s41588-023-01349-3)

## 🙏 Acknowledgments

TEProf2 was developed in the Wang Lab at Washington University in St. Louis. We thank the bioinformatics and cancer genomics communities for their contributions to the tools and databases that make this analysis possible.

---

**Version:** 0.1  
**Last Updated:** 2024  
**Maintained By:** Junseok Park, Wang Lab

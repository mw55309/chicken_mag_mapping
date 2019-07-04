#Adding support to GCS
from pathlib import Path
from snakemake.remote.GS import RemoteProvider as GSRemoteProvider
GS = GSRemoteProvider()

GS_INPUT = "metagenomics-benchmarking"
GS_PREFIX = GS_INPUT

shell.executable("/bin/bash")
shell.prefix("source $HOME/.bashrc; ")

IDS,  = glob_wildcards("chicken_runs/{id}.txt")
IDS2, = glob_wildcards("chicken_runs/{id}.txt")

######################################################
#
#
# rule "all" is the default rule that Snakemake runs
# this rule basically pulls data through the entire
# pipeline by specifying the final outputs of the
# pipeline as input. The rule does nothing
#
#
######################################################


rule all:
	input: GS.remote(expand(GS_PREFIX + "/chicken_single_coverage/{sample}.txt", sample=IDS))

######################################################
#
#
# The actual rules
#
#
######################################################

rule cutadapt:
	input: "chicken_runs/{id}.txt"

	output:
		R1=GS.remote(GS_PREFIX + "/chicken_trimmed/{id}_1.t.fastq.gz"),
		R2=GS.remote(GS_PREFIX + "/chicken_trimmed/{id}_2.t.fastq.gz")
	params:
		id="{id}"
	conda: "envs/cutadapt.yaml"
	threads: 4
	shell: "curl https://raw.githubusercontent.com/WatsonLab/GoogleMAGs/master/scripts/ftp_n_trimm.sh | bash -s {params.id} {output.R1} {output.R2}"


rule bwa_index:
	input:  GS.remote(GS_PREFIX + "/chicken_MAGs/allmags.fa")
	output: 
		ann=GS.remote(GS_PREFIX + "/chicken_bwa_indices/allmags.fa.ann"),
		pac=GS.remote(GS_PREFIX + "/chicken_bwa_indices/allmags.fa.pac"),
		amb=GS.remote(GS_PREFIX + "/chicken_bwa_indices/allmags.fa.amb"),
		bwt=GS.remote(GS_PREFIX + "/chicken_bwa_indices/allmags.fa.bwt"),
		sa =GS.remote(GS_PREFIX + "/chicken_bwa_indices/allmags.fa.sa")
	params:
		idx=GS.remote(GS_PREFIX + "/chicken_bwa_indices/allmags.fa")
	conda: "envs/bwa.yaml"
	threads: 8
	shell:
		'''
		bwa index -p {params.idx} {input}
		'''

rule bwa_mem:
	input:
		R1=GS.remote(GS_PREFIX + "/chicken_trimmed/{id}_1.t.fastq.gz"),
		R2=GS.remote(GS_PREFIX + "/chicken_trimmed/{id}_2.t.fastq.gz"),
		ann=GS.remote(GS_PREFIX + "/chicken_bwa_indices/allmags.fa.ann"),
		pac=GS.remote(GS_PREFIX + "/chicken_bwa_indices/allmags.fa.pac"),
		amb=GS.remote(GS_PREFIX + "/chicken_bwa_indices/allmags.fa.amb"),
		bwt=GS.remote(GS_PREFIX + "/chicken_bwa_indices/allmags.fa.bwt"),
		sa =GS.remote(GS_PREFIX + "/chicken_bwa_indices/allmags.fa.sa")
	output: 
		bam=GS.remote(GS_PREFIX + "/chicken_bam/{id}.bam"),
		bai=GS.remote(GS_PREFIX + "/chicken_bam/{id}.bam.bai"),
		fla=GS.remote(GS_PREFIX + "/chicken_bam/{id}.bam.flagstat")
	params:
		idx=GS.remote(GS_PREFIX + "/chicken_bwa_indices/allmags.fa")
	conda: "envs/bwa.yaml"
	threads: 8
	shell: 
		'''
		bwa mem -t 8 {params.idx} {input.R1} {input.R2} | samtools sort -@8 -m 500M -o {output.bam} -
		samtools index {output.bam}

		samtools flagstat {output.bam} > {output.fla}
		'''

rule single_coverage:
	input: 
		bam=GS.remote(GS_PREFIX + "/chicken_bam/{id}.bam"),
		bai=GS.remote(GS_PREFIX + "/chicken_bam/{id}.bam.bai")
	output:
		cov=GS.remote(GS_PREFIX + "/chicken_single_coverage/{id}.txt")
	conda: "envs/metabat2.yaml"
	threads: 1
	shell:
		'''
		jgi_summarize_bam_contig_depths --outputDepth {output.cov} {input.bam}
		''' 




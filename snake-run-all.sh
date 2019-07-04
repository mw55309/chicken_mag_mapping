#!/bin/bash

set -x #echo on
SAMPLES=5
RUNID=16
CLUSTERNAME=metagenomics-benchmarking
CLUSTERZONE=europe-west1-d
GSPREFIX=metagenomics-benchmarking
SNAKEFILE=Snakefile.sc.pig${SAMPLES}
DOCKERIMAGE='gcr.io/tagareby/snakemake'

snakemake -s $SNAKEFILE --unlock

#Run run_cutadapt
RULE=run_cutadapt
gcloud container clusters update $CLUSTERNAME --update-labels sample-count=$SAMPLES,rule=$RULE,run-id=$RUNID --zone $CLUSTERZONE
snakemake  -p --verbose --keep-remote  -j 400 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE

sleep 10m
snakemake  -p --verbose --keep-remote  -j 400 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE

#Run run_megahit
RULE=run_megahit
gcloud container clusters update $CLUSTERNAME --update-labels sample-count=$SAMPLES,rule=$RULE,run-id=$RUNID --zone $CLUSTERZONE
snakemake  -p --verbose --keep-remote  -j 400 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE

sleep 10m
snakemake  -p --verbose --keep-remote  -j 400 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE


#Run run_bwa_index
RULE=run_bwa_index
gcloud container clusters update $CLUSTERNAME --update-labels sample-count=$SAMPLES,rule=$RULE,run-id=$RUNID --zone $CLUSTERZONE
snakemake  -p --verbose --keep-remote  -j 400 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE

sleep 10m
snakemake  -p --verbose --keep-remote  -j 400 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE


#Run run_bwa_mem
RULE=run_bwa_mem
gcloud container clusters update $CLUSTERNAME --update-labels sample-count=$SAMPLES,rule=$RULE,run-id=$RUNID --zone $CLUSTERZONE
snakemake  -p --verbose --keep-remote  -j 400 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE

sleep 10m
snakemake  -p --verbose --keep-remote  -j 400 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE

#Run single_coverage
RULE=run_single_coverage
gcloud container clusters update $CLUSTERNAME --update-labels sample-count=$SAMPLES,rule=$RULE,run-id=$RUNID --zone $CLUSTERZONE
snakemake  -p --verbose --keep-remote  -j 400 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE

sleep 10m
snakemake  -p --verbose --keep-remote  -j 400 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE


#Run run_coverage
RULE=run_coverage
gcloud container clusters update $CLUSTERNAME --update-labels sample-count=$SAMPLES,rule=$RULE,run-id=$RUNID --zone $CLUSTERZONE
snakemake  -p --verbose --keep-remote  -j 400 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE

sleep 10m
snakemake  -p --verbose --keep-remote  -j 400 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE


#Run run_metabat2
RULE=run_metabat2
gcloud container clusters update $CLUSTERNAME --update-labels sample-count=$SAMPLES,rule=$RULE,run-id=$RUNID --zone $CLUSTERZONE
snakemake  -p --verbose --keep-remote  -j 400 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE

sleep 10m
snakemake  -p --verbose --keep-remote  -j 400 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE


#Run run_checkm
RULE=run_checkm
gcloud container clusters update $CLUSTERNAME --update-labels sample-count=$SAMPLES,rule=$RULE,run-id=$RUNID --zone $CLUSTERZONE
snakemake  -p --verbose --keep-remote  -j 400 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE

sleep 10m
snakemake  -p --verbose --keep-remote  -j 400 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE


#Reset labels
gcloud container clusters update $CLUSTERNAME --update-labels sample-count=0,rule=idle,run-id=0 --zone $CLUSTERZONE

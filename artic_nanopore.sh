#Summary of the analysis pipeline following artic nanopore sequencing of SARS-CoV-2 at NIPH

##########################
##Map these paths##
#########################

primer_schemes=artic-ncov2019/primer_schemes
#primer schemes downloaded from https://github.com/artic-network/fieldbioinformatics/tree/master/test-data/primer-schemes
schemes_sample=nCoV-2019/V3
fast5=fast5_pass/
fastq_pass=fastq_pass/
summary=[summary file from nanopore]

##########################
##Starting guppylex analysis##
#########################

for dir in $(ls -d */)
do
	cd ${dir}
	artic guppyplex --skip-quality-check --min-length 200 --max-length 1200 --directory ./  --prefix ${dir%/}; 
	cd "${fastq_pass}"
done

###########################
##Starting Artic minion analysis###
###########################

for dir in $(ls -d */)
do
	cd ${dir} 
	artic minion --normalise 1200 --threads 8 --scheme-directory ${primer_schemes} --read-file ${dir%/}_.fastq --fast5-directory ${basedir}/${fast5} --sequencing-summary ${basedir}/${summary} ${schemes_sample}  ${dir%/}
	#21.02.18: we will likely adjust this soon to --medaka, in order to speed up the analysis and transfer of files (excluding the enormous fast5 files) - currently comparing output from the two settings
	cd "${fastq_pass}"
done

#########################
##Starting coverage analysis###
#########################

# using weeSAM & bedtools to obtain coverage and QC
# combine all consensus fasta files for each run {runname}.fa

####### Pangolin og Nextclade  ##### START #####

pangolin --update
pangolin ${runname}.fa --outfile ${runname}_pangolin_out.csv

#we collect all consensus fasta files into one folder
docker run -it --rm -u 1000 --volume="fasta/:/seq" neherlab/nextclade nextclade --input-fasta /seq/${runname}.fa  --output-csv /seq/${runname}_Nextclade.results.csv

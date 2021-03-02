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
	#2.3.21: we will likely revert back to the default values 400/700 - the idea behind increasing the width was an effort to include possible bridged amplicons/read-through. It is uncertain whether if these bridged reads occurs.
	cd "${fastq_pass}"
done

###########################
##Starting Artic minion analysis###
###########################

for dir in $(ls -d */)
do
	cd ${dir} 
	artic minion --normalise 1200 --threads 8 --scheme-directory ${primer_schemes} --read-file ${dir%/}_.fastq --fast5-directory ${basedir}/${fast5} --sequencing-summary ${basedir}/${summary} ${schemes_sample}  ${dir%/}
	#18.02.21: we will likely adjust this soon to --medaka, in order to speed up the analysis and transfer of files (excluding the enormous fast5 files) - currently comparing output from the two settings
	#2.3.21: we increased the --normalise value from 500 > 1200 as this increased the quality (depth/coverage) in the beginning of the development of the method - however with better quality output - it may not be neccessary.
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

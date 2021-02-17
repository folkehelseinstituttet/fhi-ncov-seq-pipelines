#Summary of the analysis pipeline following artic illumina sequencing of SARS-CoV-2 at NIPH

##########################
##Map these paths##
#########################

Aar=2021	# Year
basedir=$(pwd)
runname=${basedir##*/}
scriptdir=[where you keep your scripts]
script_name1=`basename $0`


###### DATABASER/REFERANSESEKVENSER ########
CoronaRef=[where you keep your nCoV-2019.reference.fasta]
PrimerBed=/artic-ncov2019/primer_schemes/nCoV-2019/V3/nCoV-2019.bed
#download from here: https://github.com/artic-network/fieldbioinformatics/tree/master/test-data/primer-schemes/nCoV-2019/V3

#stringency for mapping, 1-100
String2=85 


######## DEL 1 Mapping #### START ######
basedir=$(pwd)
runname=${basedir##/}

for dir in $(ls -d */)
do
    cd ${dir}
	R1=$(ls *_R1*.fastq.gz)
    R2=$(ls *_R2*.fastq.gz)

gzip -d ${R1} 
gzip -d ${R2} 

    newR1=$(ls *_R1*.fastq)
    newR2=$(ls *_R2*.fastq)
#align
    bestF2="${newR1%%_*L001*}_${bestF1%_*}" # brukes til navnsetting av outputfil 
    tanoti -r ${CoronaRef} -i ${newR1} ${newR2} -o ${bestF2}tanoti.sam -p 1 -m ${String2}
    bestF3=$(ls *_tanoti.sam)
    samtools view -bS ${bestF3} | samtools sort -o ${bestF3%.sam}_sorted.bam
    samtools index ${bestF3%.sam}_sorted.bam
   
    cd "${basedir}"
done
######## DEL 1 Mapping #### SLUTT ######


######## DEL 2 Trimming #### START ######
basedir=$(pwd)
runname=${basedir##*/}

for dir in $(ls -d */)
do
    cd ${dir}
    bestF4=$(ls *_sorted.bam)
#trim
    ivar trim -i ${bestF4} -b ${PrimerBed} -p ${bestF4%_sorted.bam}.trimmed -m 50 -q 15 -s 4 > ${bestF4%_sorted.bam}.TrimReport.txt #brukt forslag fra manual
    
    samtools view -bS ${bestF4%_sorted.bam}.trimmed.bam | samtools sort -o ${bestF4%_sorted.bam}.trimmed.sorted.bam
    samtools index ${bestF4%_sorted.bam}.trimmed.sorted.bam
    cd "${basedir}"
done
######## DEL 2 Trimming #### SLUTT ######

######## DEL 3 VariantCalling og Consensus #### START ######
basedir=$(pwd)
runname=${basedir##*/}

for dir in $(ls -d Art*/)
do

cd ${dir}

# Lage konsensus for Main-genotype
    bestF5=$(ls *trimmed.sorted.bam)

	samtools sort -n ${bestF5} > ${bestF5%.bam}.byQuery.bam 
#tester samtools vs bcftools. Versjon 1.9
	samtools mpileup -f ${CoronaRef} ${bestF5%} -d 100000 -Q 30 -B| ivar consensus -t 0 -m 10 -n N -p cons.fa 
    #bcftools index calls.vcf.gz
    bedtools genomecov -bga -ibam ${bestF5}| grep -w '0$\|1$\|2$\|3$' > regionswithlessthan4coverage.bed   
    #ivar consensus -m regionswithlessthan4coverage.bed -f ${CoronaRef} calls.vcf.gz -o cons.fa
    seqkit replace -p "(.+)" -r ${bestF5%%_*} cons.fa | sed -r '2s/^N{1,}//g' | sed -r '$ s/N{1,}$//g' > ${bestF5%%_*}_consensus.fa

cd "${basedir}"
######## DEL 3 VariantCalling og Consensus #### SLUTT ######


######## DEL 4 CoveragePlot og Statistikk #### START ######

# using weeSAM & bedtools to obtain coverage and QC

######## DEL 4 CoveragePlot og Statistikk #### SLUTT ######


####### Pangolin og Nextclade  ##### START #####

pangolin --update
pangolin ${basedir}/${runname}_summaries/fasta/${runname}.fa --outfile ${basedir}/${runname}_summaries/${runname}_pangolin_out.csv

docker run -it --rm -u 1000 --volume="${basedir}/${runname}_summaries/fasta/:/seq" neherlab/nextclade nextclade --input-fasta /seq/${runname}.fa  --output-csv /seq/${runname}_Nextclade.results.csv

####### Pangolin og Nextclade  ##### SLUTT #####

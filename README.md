# fhi-ncov-seq-pipelines
FHI/NIPH pipelines for SARS-CoV-2 sequences generated with the ARTIC sequencing protocol

Summaries of the pipelines are described in the .sh files.

Details on paths and specifics on QC (e.g. coverage) analyses have been omitted as these have been suited to our needs, but information can be supplied if requested.

We extensively use conda environment for the different programs, these have not been specified in the examples.

Some text still in Norwegian, will eventually be translated. Contact if you have any specific question.

## Q&A ##

We've been asked a couple of questions in regards to our protocols and analyses, we'll try to post answers here in order to clarify (stimulate further studies):

### % unclassified reads from nanopore ###

*Under investigation*

### % unmapped reads from illumina/nanopore ###

In our hands we see 7-22% unmapped reads from illumina reads

*Nanopore under investigation*

### Quality cut-off ###

Ref GISAID - we use a quality cut-off limit of 97% coverage with minimum depth 10x (illumina) and 20x (nanopore)

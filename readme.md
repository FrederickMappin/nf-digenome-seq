
# Nextflow implementation of digenome-seq


Digenome-seq is an in vitro nuclease-digested whole-genome sequencing to profile genome-wide nuclease off-target effects in cells. This in vitro digest yields sequence reads with the same 5' ends at cleavage sites that can be computationally identified by Digenome-seq program. Thanks to Emscripten, this web version of Digenome-seq program completely runs on the client-side so that large amounts of sequencing data do not need to be uploaded to the server.


Citation info:

Park J. et al. Digenome-seq web tool for profiling CRISPR specificity. Nature Methods 14, 548-549 (2017).
Kim D. et al. Digenome-seq: genome-wide profiling of CRISPR-Cas9 off-target effects in human cells. Nature Methods 12, 237-243 (2015).


Steps: 
- Fastqc
- MEM-BWA
- Digenome
- CSVprocessing
- HTML output
      

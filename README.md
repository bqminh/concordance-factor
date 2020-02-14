This page contains the supplementary data for the manuscript:

Bui Quang Minh, Matthew W. Hahn, and Robert Lanfear. New methods to calculate concordance factors for phylogenomic datasets. Submitted.

A tutorial how to perform concordance factor analysis is available here: <http://www.iqtree.org/doc/Concordance-Factor>.

Files in this repository
------------------------

* `Rodriguez_2018.tar.gz`: the Lizard data set containing 3220 UCE alignments kindly provided by Zachary Rodriguez (<https://doi.org/10.1126/sciadv.aao5017>). It contains the `alignment.nex` file in NEXUS format for the concatenated alignment with partitioning information.
* `outputs/partitions.spp.treefile.rename`: Newick tree used to draw Figure 2.
* `scripts/`: This folder contains the bash scripts that we used to run IQ-TREE under Linux (see below for the detailed command lines) and R scripts to make Figure 3 (`figure3.R`) and the supplementary figures (`make_supplementary_figures.R`).

Lizard dataset
--------------

In order to replicate the analysis for the Lizard dataset (Rodriguez et al. 2018), please do the following:

1. Unzip the Lizard data file into a folder `Rodriguez_2018`:

		tar -xzf Rodriguez_2018.tar.gz

2. Go inside this folder:

		cd Rodriguez_2018

3. Infer a species tree using partition model and ultrafast bootstrap (assuming that `iqtree` command points to the IQ-TREE version 2.0-rc1):

		iqtree -p alignment.nex --prefix concat -bb 10000 -nt AUTO -seed 609149

4. Infer separate locus trees (one for each UCE):

		iqtree -S alignment.nex --prefix loci -nt 10 -seed 937413

5. Compute gene and site concordance factors:

		iqtree -t concat.treefile --gcf loci.treefile -p alignment.nex --scf 100 --prefix concord
		
		
The resulting newick tree `concord.cf.tree` will have branches annotated with bootstrap proportion, gene and site concordance factors separated by  slash (`/`). This tree file can be viewed by e.g. FigTree. Note that the sCF values might be slightly different from the output newick tree provided here due to random sampling of the quartets.

Detailed tree branch statistics are printed to `concord.cf.stat` and tree with branch ID `concord.cf.branch`.

Subsampling analysis
--------------------

The other nine datasets (Table 1 of the main text) are obtained from <https://github.com/roblanf/BenchmarkAlignments>, with the link to FigShare to download the alignments: <https://figshare.com/s/622e9e0a156e5233944b>. Unzipping the file will create a directory for each dataset (e.g., `Ballesteros_2019`), which contains an `alignment.nex` file for the alignment in NEXUS format. You should remove the `CHARSET nuclear_genome = ...` line in this file.

To analyze a subsampled alignment of 10, 20, ..., 200 loci, go to the directory for each dataset and run the ultrafast boostrap (UFBoot), single-locus tree inference and standard boostrap (StdBoot) with a for loop in Linux:

	threads=10 # can be changed depending on the machine
	for ((k=10; k <= 200; k+=10)); do
		# perform ultrafast bootstrap (UFBoot)
		iqtree -p alignment.nex --prefix ufboot.$k -T $threads -m TEST -bb 1000 --no-terrace --subsample $k --subsample-seed 1

		# perform single-locus tree inference
	  	iqtree -S alignment.nex --prefix loci.$k -T $threads -m TEST --subsample $k --subsample-seed 1

		# perform standard bootstrap, only for Rodriguez dataset
		iqtree -p alignment.nex --prefix stdboot.$k -T $threads -m TEST -b 100 --no-terrace --subsample $k --subsample-seed 1
	done

Once done, we can now compute gCF and sCF onto the best 200-loci tree:

	for ((k=10; k <= 200; k+=10)); do
		# map the UFBoot supports onto the 200-loci tree
		iqtree -sup ufboot.200.treefile -t ufboot.$k.splits.nex --prefix ufboot_sup.$k

		# further map the gCF and sCF onto this tree
		iqtree -t ufboot_sup.$k.suptree --gcf loci.$k.treefile -p alignment.nex --subsample $k --subsample-seed 1 --scf 100 --prefix concord.$k	
	done
	
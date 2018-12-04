This page contain supplementary data for the manuscript:

Bui Quang Minh, Matthew W. Hahn, and Robert Lanfear (2018) New methods to calculate concordance factors for phylogenomic datasets. in prep.


* `one-p70.tar.gz`: the Lizard data set containing 3220 UCE alignments kindly provided by Zachary Rodriguez (<https://doi.org/10.1126/sciadv.aao5017>).

A tutorial how to perform concordance factor analysis is available here: <http://www.iqtree.org/doc/Concordance-Factor>.

In order to replicate the analysis for the Lizard dataset, please do the following:

1. Download IQ-TREE version 1.7-beta6 from <https://github.com/Cibiv/IQ-TREE/releases/tag/v1.7-beta6>.
2. Unzip the Lizard data file into a folder, e.g. `lizard`:

		mkdir lizard
		tar -xzf one-p70.tar.gz -C lizard
3. Infer a species tree using partition model and ultrafast bootstrap (assuming that `iqtree` command points to the version 1.7-beta6 just installed):

		iqtree -p lizard --prefix concat -bb 10000 -nt AUTO
4. Infer separate locus trees (one for each UCE):

		iqtree -S lizard --prefix loci -nt 10
5. Compute gene and site concordance factors:

		iqtree -t concat.treefile --gcf loci.treefile -p lizard --scf 100 --prefix concord
		

		
The resulting newick tree `concord.cf.tree` will have branches annotated with bootstrap proportion, gene and site concordance factors separated by  slash (`/`). This tree file can be viewed by e.g. FigTree.

Detailed tree branch statistics are printed to `concord.cf.stat` and tree with branch ID `concord.cf.branch`.

#! /bin/bash

# $ -q hugemem.q
# $ -l virtual_free=10g,h_vmem=10.1g
#$ -l compute
#$ -S /bin/bash
#$ -pe threads 10
#$ -j y
#$ -r y
#$ -cwd
#$ -N concord
#$ -V
#$ -b y
#$ -m ea
#$ -M m.bui@anu.edu.au

dir=$1
max_loci=200
min_loci=10
step_loci=10
aln=alignment.nex
seed=1
threads=5

if [ "$1" == "" ]; then
	echo "Usage: $0 <DIR> [EXTRA_OPTIONS]"
	exit 1
fi

for ((step=min_loci; step <= max_loci; step+=step_loci)); do


  prefix=u$step

  if [ ! -f $dir/$aln ]; then
    echo "ERROR: $dir/$aln not found"
    exit 2
  fi



#  /project/pd-phylo/bin/iqtree2 -s $dir/$aln -p $dir/$aln --prefix $dir/$prefix -T $threads -m TEST -bb 1000 --no-terrace --subsample $step --subsample-seed $seed ${@:2}


#  /project/pd-phylo/bin/iqtree2 -s $dir/$aln -S $dir/$aln --prefix $dir/"l"$step -T $threads -m TEST --subsample $step --subsample-seed $seed


target_tree=$dir/u$max_loci".treefile"

  if [ ! -f $target_tree ]; then
    break
  fi

  if [ -f $dir/$prefix.iqtree -a -f $dir/"l"$step".iqtree" ]; then

    /project/pd-phylo/bin/iqtree2 -sup $target_tree -t $dir/$prefix.splits.nex -pre $dir/"uu"$step
    /project/pd-phylo/bin/iqtree2 -t $dir/"uu"$step.suptree --gcf $dir/"l"$step".treefile" -p $dir/$aln --subsample $step --subsample-seed $seed --scf 100 --prefix $dir/"s"$step -T $threads ${@:2}

  fi

  if [ -f $dir/c$step.iqtree -a -f $dir/"l"$step".iqtree" ]; then
    /project/pd-phylo/bin/iqtree2 -sup $target_tree -t $dir/c$step.boottrees -pre $dir/"cc"$step
    /project/pd-phylo/bin/iqtree2 -t $dir/"cc"$step.suptree --gcf $dir/"l"$step".treefile" -p $dir/$aln --subsample $step --subsample-seed $seed --scf 100 --prefix $dir/"r"$step -T $threads ${@:2}


  fi
  #let seed++

done


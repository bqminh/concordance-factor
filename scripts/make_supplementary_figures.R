
library(reshape2)
library(ggplot2)
library(stringr)
library(dplyr)
library(viridis)


base = "/Users/roblanfear/Dropbox/Projects_Current/concordance/writeup/MBE-rev/Figures"

folders = c(
          "Ballesteros_2019",
          "Branstetter_2017",
           "Cannon_2016",
          "Jarvis_2015",
          "Misof_2014",
          "Ran_2018_aa",
          "Ran_2018_dna",
           "Rodriguez_2018",
          "Wu_2018_aa",
          "Wu_2018_dna")

pdf(paste0(base,"/supplementary_figures",".pdf"),width=10 )

fig_i = 1


for(name in folders){

    
    print(name)
    
    ids = seq(10, 200, 10)
    
    if(name=="Ballesteros_2019"){
        # for this dataset, the analysis with just 10 and 20 loci failed because they led to some taxa being excluded from the matrix entirely,
            # so we skip it
        ids = seq(30, 200, 10)
    }
    
    if(name=="Rodriguez_2018"){
        # this allows us to include the standard bootstrap and the UFboot for the 1 dataset for which we calculated both
        prefixes = c("r", "s")
    }else{
        prefixes = c("s")
    }
    
    
    dir = file.path(base, name)
    
    d_all = NULL
    names = NULL
    
    for (prefix in prefixes) {
      if (!file.exists(paste0(dir,"/", prefix, ids[1], ".cf.stat"))) {
        next
      }
      d = NULL
      for (i in ids) {
        filename=paste0(dir,"/", prefix, i, ".cf.stat")
        if (file.exists(filename)) {
          cf.data = read.delim(filename, header=T, comment.char="#")
          cf.data$loci = i
          d = rbind(d, cf.data)
        }
      }
      
      d$Label = as.numeric(matrix(unlist(str_split(d$Label, "/")),ncol=2,byrow=TRUE)[,2])
    
      if (is.null(d_all))
        d_all = d
      else {
        d_all = cbind(d_all, d$Label)
        colnames(d_all)[colnames(d_all)=="d$Label"]="Label"
      }
      
      # change the column name
      boot="UFBoot"
      if (prefix == "r") {
        boot="StdBoot"
      }
      names = c(names, boot)
      colnames(d_all)[colnames(d_all)=="Label"]=boot
    }
    
    dm = NA
    dm = melt(d_all, id.vars = c("loci", "ID"))
    
    lines = data.frame(variable = c("sCF"), i = c(33.333333333))
    
    # sCF vs. gCF vs. bootstrap
    
    p1 = ggplot(d_all, aes(x = gCF, y = sCF)) + 
        geom_point(aes(colour = UFBoot)) + 
        scale_colour_viridis(direction = -1) + 
        xlim(0, 100) +
        ylim(0, 100) +
        geom_abline(slope = 1, intercept = 0, linetype = "dashed") + 
        facet_wrap(~loci, ncol=5) +
        ggtitle(paste0("Supplementary Figure ", fig_i, "A"), 
                subtitle = paste0("Dataset: ", name, "\nA scatterplot of gCF vs sCF values, coloured by UFBoot values. Each point represents a single branch in the tree \n calculated from the 200 locus dataset. Each panel represents an analysis in which the concordance factors and bootstraps \n were calculated from the number of loci specified in the panel header. The dashed line is the 1:1 line"))
    
    print(p1)
    
    # one line per branch
    p2 = ggplot(subset(dm, variable %in% c("gCF", "sCF", names)), aes(x=loci, colour=factor(ID), y = value)) + 
        geom_point() + 
        geom_line() + 
        geom_hline(data=lines, aes(yintercept = i), linetype='dashed') +
        facet_wrap(ncol=1, ~variable) + theme(legend.position = "none") +
        ggtitle(paste0("Supplementary Figure ", fig_i, "B"), 
                subtitle = paste0("Dataset: ", name, "\nThe value of each variable (where the variable name is shown in the panel header) by number of loci used in the analysis.\n Each coloured line represents a single branch in the tree estimated from the 200 locus dataset."))
    
    
    print(p2)
    
    # proportion of bootstrap values that are 100%
    
    
    dm$proportion_100_percent = dm$value ==100
    
    props = NA
    props = dm %>%
        group_by(loci, variable) %>%
        summarise_at(vars(proportion_100_percent), funs(sum(., na.rm=TRUE)/n()))
    
    p3 = ggplot(subset(props, variable %in% c("gCF", "sCF", names)), aes(x=loci, y = proportion_100_percent, colour = factor(variable))) + 
        geom_point() + 
        geom_line() + 
        ylim(0, 1) +
        ggtitle(paste0("Supplementary Figure ", fig_i, "C"), 
                subtitle = paste0("Dataset: ", name, "\nThe proportion of CF or Bootstrap values that are 100% (y axis) versus the number of loci used in the analysis (x axis)."))
        
    
    print(p3)
    
    
    # correlation of boot and ufboot
    if(name == "Rodriguez_2018"){
        p4 = ggplot(d_all, aes(x = UFBoot, y = StdBoot)) + 
            geom_point() +
            xlim(0, 100) +
            ylim(0, 100) +
            geom_abline(slope = 1, intercept = 0, linetype = "dashed") + 
            facet_wrap(~loci, ncol=5) +
            ggtitle(paste0("Supplementary Figure ", fig_i, "D"), 
                    subtitle = paste0("Dataset: ", name, "\nA scatterplot of UFBoot vs. standard (i.e. Felsenstein) bootstrap values.\n Each panel represents a different analysis using a number of loci specified in the panel header.\n The dashed line is the 1:1 line"))
        
        print(p4)
        
        
        
    }
    
    fig_i = fig_i + 1
}

dev.off()


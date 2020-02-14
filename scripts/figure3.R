
library(reshape2)
library(ggplot2)
library(stringr)
library(dplyr)
library(viridis)
library(cowplot)


base = "/Users/roblanfear/Dropbox/Projects_Current/concordance/writeup/MBE-rev/concord"

folders = c("Rodriguez_2018")

pdf(paste0(base,"/figure3",".pdf"),width=10, height=5)

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
    
    # one line per branch
    p2 = ggplot(subset(dm, variable %in% c("gCF", "sCF", names)), aes(x=loci, colour=factor(ID), y = value)) + 
        geom_point() + 
        geom_line() + 
        geom_hline(data=lines, aes(yintercept = i), linetype='dashed') +
        facet_wrap(ncol=1, ~variable) +
        theme_bw() + theme(legend.position = "none") +
        xlab("Number of loci included in analysis") +
        ylab("Value of metric (percent)")
        
    
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
        theme_bw() + 
        ylab("Proportion of branches with a value of 100%") + 
        xlab("Number of loci included in analysis") + 
        labs(colour = "metric")
        
    
    print(p3)
    
    p4 = plot_grid(p2, p3, labels = c('A', 'B'), ncol = 2)
    
    print(p4)
    }
    

dev.off()


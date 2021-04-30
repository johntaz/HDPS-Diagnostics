###########################################################
# R script:    001_highLevelConceptsSummary.R
#
# Author:      John Tazare
#
# Date:        29/04/2021
#
# Description: Plot for summarising high-level concepts in 
#              the Top N ranked HDPS covariates separated 
#              by data dimension.
#
# Inspired and adapted from: 
# https://www.data-to-viz.com/graph/circularbarplot.html
###########################################################

# Load relevant library
library(tidyverse)

###########################################################
# Import data set with high-level concepts at chapter level.
###########################################################

###########################################################
# Variable Descriptions:
# description: chapter label/name
# dim: dimension identifier (e.g. d1 = clinical etc..)
# tot: total number of selected covariates from a particular 
#      chapter 
# percent: Out of N selected covariates, how many came from 
#      this particular chapter

###########################################################

# Load data
data <- read.csv("-insert-data-path-here") %>% 
  select(description, dim, tot, percent)
# Order data:
data <- data %>% arrange(dim, tot) 

# Create whitespace to separate each dimension by adding empty bars
empty_bar <- 4
to_add <- data.frame(matrix(NA, empty_bar*nlevels(data$dim), ncol(data)))
colnames(to_add) <- colnames(data)
to_add$dim <- rep(levels(data$dim), each=empty_bar)
data <- rbind(data, to_add)
data <- data %>% arrange(dim)
data$id <- seq(1, nrow(data))

# Get the name, angles and position of dimension chapter
label_data <- data
number_of_bar <- nrow(label_data)
angle <- 90 - 360 * (label_data$id-0.5) /number_of_bar     
label_data$hjust <- ifelse( angle < -90, 1, 0)
label_data$angle <- ifelse(angle < -90, angle+180, angle)

# Make the plot
p <- ggplot(data, aes(x=as.factor(id), y=tot, fill=dim)) +    
  geom_bar(stat="identity", alpha=0.5) +
  ylim(-100,120) +
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank(),
    plot.margin = unit(rep(-1,4), "cm") 
  ) +
  coord_polar() + 
  geom_text(data=label_data, aes(x=id, y=tot+10, label=description, hjust=hjust), color="black", fontface="bold",alpha=0.6, size=2.5, angle= label_data$angle, inherit.aes = FALSE ) 

p

# Save
ggsave("-insert-output-path-here/conceptsPlot.pdf", device = "pdf")





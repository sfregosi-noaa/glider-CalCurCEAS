# avg encounters per day for CalCurCEAS

events_sg639 <- 174
events_sg679 <- 376
events_sg680 <- 185

mst <- read.csv("outputs/missionSummaryTable.csv")

mst$encounters <- c(174,376,185)
mst$encPerDay = mst$encounters/mst$durDays

# HIRC2014-2015
bw <- 11
sw <- 31
gg <- 11
lfw <- 17
hfw <- 4
lhfw <- 19
ecbp <- 29
blue <- 39
fin <- 190
sei <- 17
humpback <- 131
minke <- 140
639 total enocunters

#' ---------------------------
#' title: CalCurCEAS2024 Ship Track
#' authors: Selene Fregosi
#' purpose: extract on effort ship tracks for CalCurCEAS 2024 with the intent to
#' plot the ship tracks with the DASBRs and gliders
#' The DASALL2024 file is from January 2025 and is not the final QA/QC'd version
#' ---------------------------

library(here)

# define DAS file location
dasFile <- here("secret", "DASALL2024 (8).das")


# process the DAS using swfscDAS package
# basic data checks
df_check <- swfscDAS::das_check(dasFile, skip = 0, 
                                print.cruise.nums = FALSE)
# read and process
df_read <- swfscDAS::das_read(dasFile, skip = 0)
df_proc <- swfscDAS::das_process(dasFile)

# save copy of df_proc
saveRDS(df_proc, file = here("secret", "DASALL2024 (8)_processed.rda"))


# extract effort data

# NB: effort types can be 'N' non-standard, 'S' standard', and 'F' fine-scale
# could further trim by this. For now including all of them

# trim the read in data to just the cols we care about
df_proc_sub <- subset(df_proc, select = c(file_das, line_num, Cruise, Event, DateTime, 
                                          Lat, Lon, Mode, OnEffort, EffortDot,
                                          EffType, SpdKt, Bft))
# technically E is on effort so fix those lines
df_proc_sub$OnEffort[which(df_proc_sub$Event == 'E')] <- TRUE
df_proc_sub$EffortDot[which(df_proc_sub$Event == 'E')] <- TRUE

# loop through all lines and add a segment number for continuous effort segments
df_proc_sub$SegID <- 0
segCounter <- 1
for(i in 1:length(df_proc_sub$line_num)) { 
  if (df_proc_sub$OnEffort[i] == 'TRUE' & df_proc_sub$Event[i] == 'R'){
    df_proc_sub$SegID[i] <- segCounter
  } else if (df_proc_sub$OnEffort[i] == 'TRUE' & df_proc_sub$Event[i] != 'E'){
    df_proc_sub$SegID[i] <- segCounter
  } else if (df_proc_sub$OnEffort[i] == 'TRUE' & df_proc_sub$Event[i] == 'E'){
    df_proc_sub$SegID[i] <- segCounter
    segCounter <- segCounter + 1
  }
}

# Deal with timezones - import assumes UTC but is in local time
# set separately for during/after daylight savings, switch was on Sun Nov 3 2024
pdt <- which(df_proc_sub$DateTime < "2024-11-03 00:00:00") 
df_proc_sub$DateTime[pdt] <- lubridate::force_tz(df_proc_sub$DateTime[pdt], 'PDT')
pst <- which(df_proc_sub$DateTime > "2024-11-03 00:00:00")
df_proc_sub$DateTime[pst] <- lubridate::force_tz(df_proc_sub$DateTime[pst], 'PST')
# update the column name 
colnames(df_proc_sub)[colnames(df_proc_sub) == 'DateTime'] <- 'DateTime_UTC'

# clean up output
# remove off effort lines
ep <- subset(df_proc_sub, SegID > 0)
# remove begin effort because it's not needed
ep <- subset(ep, Event != 'B')
# remove comments
ep <- subset(ep, Event != 'C')

# plot to check
plot(ep$Lon, ep$Lat)
# write to csv
write.csv(ep, file = here('secret', 'ship_effort.csv'))


# ALTERNATIVE could extract effort data as track segments
# these are kind of harder to work with but maybe useful

# 'section' method pulls lat/lon for all 'R' (resume effort) and all 'E' (end 
# effort) entries, then calcs dist btwn
et_all <- swfscDAS::das_effort(df_proc, method = 'section', 
                               dist.method = 'greatcircle', num.cores = 1)
# trim to just what we want
et_seg <- et_all$segdata
et <- subset(et_seg, select = c(Cruise, segnum, file, stlin:mtime, Mode, 
                                EffType, avgSpdKt, avgBft))

# rename the file_das column to match tracks output
colnames(et)[3] = 'file_das'




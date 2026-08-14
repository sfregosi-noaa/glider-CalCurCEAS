#' ---
#' title: Rename CalCurCEAS 2024 acoustic events to 3-digit padding
#' author: Selene Fregosi
#' date: 2026-08-12
#' ---
#'
#' Script to fix insufficient zero-padding in the eventIDs for sg680. I already
#' made the AcousticStudy which took 19+ hours so didn't want to re-create it.
#' This bumps up zero padding from 2 digits to 3 since there are 100+ events
#' Renames @id on each event, the events list names, and the grouping table in
#' @ancillary.
#' 
#' The zero padding is now fixed in the MATLAB workflow_cleanTritonLogs.m script
#' so this only needed to be done once. 
#'
#' Inputs:  pam20217a_glider_banter_sg680_CalCurCEAS_Sep2024_acousticStudy.rds
#' Outputs: renamed version of the above
#'
#' Requires: PAMpal (>= 1.x)
#'


# ---- rename events ------------------------------------------------------

padId <- function(x) {
  pre <- sub('_(\\d+)$', '', x)
  num <- as.integer(sub('^.*_(\\d+)$', '\\1', x))
  sprintf('%s_%03d', pre, num)
}

old <- names(events(acSt))
new <- padId(old)
head(data.frame(old, new))
stopifnot(!any(duplicated(new)), !any(is.na(new)))

for(i in seq_along(acSt@events)) {
  acSt@events[[i]]@id <- new[i]
}

names(acSt@events) <- new

# check
newCheck <- names(events(acSt))
head(newCheck)
identical(names(acSt@events), unname(sapply(acSt@events, id)))
head(names(acSt@events))


# ---- fix groupings ------------------------------------------------------

# fix groupings
if(!is.null(acSt@ancillary$grouping)) {
  acSt@ancillary$grouping$id <- padId(as.character(acSt@ancillary$grouping$id))
}


# ---- fix detectors ------------------------------------------------------

any(sapply(acSt@events, function(e) any(sapply(e@detectors, function(d) 'eventId' %in% names(d)))))
# was FALSE so didn't have to run below

for(i in seq_along(acSt@events)) {
  acSt@events[[i]]@detectors <- lapply(acSt@events[[i]]@detectors, function(d) {
    if('eventId' %in% names(d)) d$eventId <- new[i]
    d
  })
}


# ---- check again --------------------------------------------------------

identical(names(events(acSt)), unname(sapply(events(acSt), id)))
head(getClickData(acSt)[, c('eventId', 'UID')])
saveRDS(acSt, acStFile)

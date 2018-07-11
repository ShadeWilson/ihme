# Author: Shade Wilson
# 2/5/18
# qstating through R
# making complicated qstat outputs easier to comprend by leveraging the better interface of R
# (will need to be on the cluster to use, obvi)

qstat <- function(print = FALSE) {
  object <- system("qstat", intern = TRUE)

  if (print) {
    system("qstat")
  }
  return(object)
}
q <- qstat()
q <- as.data.frame(q)

#
# trim <- function(string) {
#   gsub("(^ )|( $)", "", string)
# }
#
# split_whitespace <- function(string) {
#   strsplit(string, "[ \t]+")
# }
#
# cat <- qstat()
# cat1 <- trim(cat)
#
# split <- split_whitespace(cat1)
#
# rows <- rbind(split[[3]], split[[4]])
# df <- as.data.frame(rows)
# setNames(df, split[[1]])
#
#
# strsplit(cat1, " +")
#
#
#

#' @author Shade Wilson

library(XML)
library(magrittr)
library("ihme", lib.loc = "/home/j/temp/shadew")
library(dplyr)

setup()
source_functions(get_location_metadata = T)

loc_data <- get_location_metadata(35)

#'Returns the number of jobs running at each location level
#'
#' @param MVID dismod model version ID
#' @param location_metadata df returned from get_location_metadata shared function
#'
dismod_status <- function(MVID, location_metadata = loc_data) {
  qstat <- system("qstat -xml", intern = TRUE)

  qstat_list <- xmlToList(qstat)
  job_info <- as.list(qstat_list[["job_info"]])

  df <- data.frame(matrix(unlist(job_info), nrow=length(job_info), byrow=T))
  names(df) <- c("JB_job_number", "JAT_prio", "JB_name", "JB_owner", "state_id", "JB_submission_time", "slots", "state")

  df <- df %>%
    mutate(mvid = regmatches(JB_name, regexpr("^(dm_\\d{6})", JB_name)),
                  mvid = gsub("dm_", "", mvid),
                  job_name_detail = gsub("^(dm_\\d{6})_", "", JB_name),
                  location_id = gsub("_[mf]_\\d+_.*$", "", job_name_detail))


  dm <- filter(df, mvid == MVID)

  # tack on location ids
  location_metadata <- select(loc_data, location_id, location_name, location_type)
  location_metadata <- mutate(loc_data, location_id = as.character(location_id))

  dm <- left_join(dm, location_metadata, by = "location_id") %>%
    mutate(location_type = if_else(is.na(location_type), location_id, location_type))

  job_count <- group_by(dm, location_type, state_id) %>% count()
  return(job_count)
}

# example
dismod_status(MVID = 327020)







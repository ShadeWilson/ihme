# Author: Shade Wilson
# 2/5/18
# qstating through R
# making complicated qstat outputs easier to comprend by leveraging the better interface of R
# (will need to be on the cluster to use, obvi)


#' @author Shade Wilson

library(XML)
library(magrittr)
library("ihme", lib.loc = "/home/j/temp/shadew")
library(dplyr)

setup()
source_functions(get_location_metadata = T)
source()

loc_data <- get_location_metadata(35)

#' Returns the number of jobs running at each location level
#'
#' @param MVID dismod model version ID
#' @param user uuw net id of modeler running DisMod
#' @param location_metadata df returned from get_location_metadata shared function
#'
dismod_status <- function(MVID, user, location_metadata = loc_data) {
  qstat <- system(paste0("qstat -u ", user, " -xml"), intern = TRUE)

  qstat_list <- xmlToList(qstat)
  job_info <- as.list(qstat_list[["job_info"]])
  queue_info <- as.list(qstat_list[["queue_info"]])

  df <- data.frame(matrix(unlist(job_info), nrow=length(job_info), byrow=T))
  queue_df <- data.frame(matrix(unlist(queue_info), nrow=length(queue_info), byrow=T)) %>%
    select(-X7, X7 = X8, X8 = X9)


  df <- rbind(df, queue_df)

  names(df) <- c("JB_job_number", "JAT_prio", "JB_name", "JB_owner", "state_id", "JB_submission_time", "slots", "state")

  df <- df %>%
    filter(grepl("dm_", JB_name)) %>%
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

  levels <- c("G0", "superregion", "region", "admin0", "varnish")

  job_count <- group_by(dm, mvid, location_name, location_type, state_id) %>%
    summarize(jobs_left = n()) %>%
    mutate(progress = if_else(!is.na(location_name), paste0(signif((1 - jobs_left / 12) * 100, digits = 2), "%"), ""))

  # order the jobs from global to subnational
  job_count$location_type <- factor(job_count$location_type, levels = levels)
  job_count <- arrange(job_count, location_type)

  return(job_count)
}

# example
hmwe_mvids <- c(329123, 329837, 329852)

dismod_status(MVID = 329123, user = "hmwekyu")






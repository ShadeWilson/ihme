# Author: Shade Wilson
# 2/5/18
# qstating through R
# making complicated qstat outputs easier to comprend by leveraging the better interface of R
# (will need to be on the cluster to use, obvi)


#' @author Shade Wilson

library(XML)
library(magrittr)
library(dplyr)

library(data.table)

setup()

#' Basic qstat functionality for monitoring jobs running on the Sun Grid Engine.
#'
#' @description qstat shows the current status of  the  available  Sun  Grid
#' Engine  queues  and  the  jobs  associated  with the queues.
#' Selection  options  allow  you  to  get  information   about
#' specific  jobs, queues or users.  If multiple selections are
#' done a queue is only displayed if all selection criteria for
#' a  queue  instance  are  met.  Without any option qstat will
#' display only a list of jobs with no  queue  status  information.
#'
#' @references http://gridscheduler.sourceforge.net/htmlman/htmlman1/qstat.html
#'
#' @param username string, the username to run the qstat for
#' @param full TRUE for full job names, FALSE otherwise
#' @param grep a regular expression string to search for in the qstat output
#' @param verbose TRUE for a printout of the qstat command run, FALSE otherwise
#' @param state string, grab only jobs in the given state. Most common are "r" (running) and
#' "p" (pending). All options are {p|r|s|z|S|N|P|hu|ho|hs|hd|hj|ha|h|a}. Any combination
#' of states is possible. See qstat manula page for more details.
#' @return a data.frame of the qstat output
#' @export
#' @examples
#' qstat()
#' qstat(full = TRUE)
#' qstat(grep = "sti")
#' qstat(username = "emumford", full = TRUE, grep = "", verbose = TRUE)
#' qstat(username = "shadew", grep = "", verbose = TRUE, state = "r")

qstat <- function(username = user, full = FALSE, grep = "", verbose = FALSE, state = "") {
  command <- ""
  if (full) {
    command <- "export SGE_LONG_JOB_NAMES=-1 && "
  }

  if (grep != "") {
    grep <- paste0("| grep ", grep)
  }

  if (state != "") {
    state <- paste0(" -s ", state)
  }

  command <- paste0(command, "qstat -u ", username, state, " | tail -n+3 ", grep)

  if (verbose) {
    message(command)
  }


  q <- suppressWarnings(data.table::as.data.table(system(command, intern = TRUE)))
  q <- suppressWarnings(tidyr::separate(q, into = paste0("v", 1:10), col = V1, sep = " +"))
  q[, v1 := NULL]

  names(q) <- c("JB_job_number", "JAT_prio", "JB_name", "JB_owner", "state_id", "JB_submission_date", "JB_submission_time", "queue", "slots")
  q[, node := stringr::str_extract(queue, "c[n2].*\\d")]

  data.table::setattr(q, "time", Sys.time())
  return(q[])
}

qstat_dismod <- function(username = user, model_version_id = NA) {
  if (!is.na(model_version_id)) {
    return(dismod_status(username = username, model_version_id = model_version_id))
  } else {
    q <- qstat(username = user, full = TRUE, grep = "dm_")
    q[, mvid := stringr::str_extract(JB_name, "\\d{6}")]
    q <- q[, .(jobs = .N), by = c("mvid", "JB_owner")]
    return(q[])
  }
}

qstat_dismod(username = "shadew")



#' Returns the number of jobs running at each location level
#'
#' @param model_version_id dismod model version ID
#' @param user uuw net id of modeler running DisMod
#' @param location_metadata df returned from get_location_metadata shared function
#'
dismod_status <- function(username, model_version_id) {
  loc_data <- read.csv(paste0(h_root, "ihme_r_pkg_files/location_metadata.csv"))
  qstat <- system(paste0("qstat -u ", user, " -xml"), intern = TRUE)

  qstat_list <- xmlToList(qstat)
  job_info <- as.list(qstat_list[["job_info"]])
  queue_info <- as.list(qstat_list[["queue_info"]])

  df <- data.frame(matrix(unlist(job_info), nrow=length(job_info), byrow=T))
  queue_df <- data.frame(matrix(unlist(queue_info), nrow=length(queue_info), byrow=T)) %>%
    select(-X7, X7 = X8, X8 = X9)

  # handling for if only one job (varnish) is left? unclear how often this comes up
  if (ncol(df) == 1) {
    df <- queue_df
  } else {
    df <- rbind(df, queue_df)
  }


  names(df) <- c("JB_job_number", "JAT_prio", "JB_name", "JB_owner", "state_id", "JB_submission_time", "slots", "state")

  df <- df %>%
    filter(grepl("dm_", JB_name)) %>%
    mutate(model_version_id = regmatches(JB_name, regexpr("^(dm_\\d{6})", JB_name)),
                  model_version_id = gsub("dm_", "", model_version_id),
                  job_name_detail = gsub("^(dm_\\d{6})_", "", JB_name),
                  location_id = gsub("_[mf]_\\d+_.*$", "", job_name_detail))

  dm <- filter(df, model_version_id == model_version_id)

  # tack on location ids
  location_metadata <- select(loc_data, location_id, location_name, location_type)
  location_metadata <- mutate(loc_data, location_id = as.character(location_id))

  dm <- left_join(dm, location_metadata, by = "location_id") %>%
    mutate(location_type = if_else(is.na(location_type), location_id, as.character(location_type)))

  levels <- c("G0", "superregion", "region", "admin0", "varnish")

  job_count <- group_by(dm, model_version_id, location_name, location_type, state_id) %>%
    summarize(jobs_left = n()) %>%
    mutate(progress = if_else(!is.na(location_name), paste0(signif((1 - jobs_left / 12) * 100, digits = 2), "%"), ""))

  # order the jobs from global to subnational
  job_count$location_type <- factor(job_count$location_type, levels = levels)
  job_count <- arrange(job_count, location_type)

  return(job_count)
}

# example
# hmwe_mvids <- c(329123, 329837, 329852)
#
dismod_status(username = "tvos", model_version_id = 358979)




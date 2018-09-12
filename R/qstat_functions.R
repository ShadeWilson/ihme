# Author: Shade Wilson
# 2/5/18
# qstating through R
# making complicated qstat outputs easier to comprend by leveraging the better interface of R
# (will need to be on the cluster to use, obvi)


#' @author Shade Wilson

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

#' Qstating for dismod models explicitly.
#'
#' @description Interface for checking job status of dismod jobs running on the cluster. Allows for in-depth progress
#'              reports for specific models if desired
#'
#' @param username uuw net id of modeler running DisMod
#' @param model_version_id unique MVID of the model to check progress. Default is NA, so will report
#'                         total jobs running for each model that the modeler is running. If model_version_id is
#'                         supplied, returns an in-depth summary of the jobs running for each location and the progress
#'                         made.
#'
#' @return data.table summarizing dismod jobs
#' @export
#' @examples
#' qstat_dismod(username = "shadew", model_version_id = 123456)
#' qstat_dismod(username = "shadew")
#'
qstat_dismod <- function(username = user, model_version_id = NA) {
  q <- qstat(username = user, full = TRUE, grep = "dm_")
  q[, mvid := stringr::str_extract(JB_name, "\\d{6}")]

  if (!is.na(model_version_id)) {
    return(dismod_status(dt = q, username = username, model_version_id = model_version_id))
  } else {
    q <- q[, .(jobs = .N), by = c("mvid", "JB_owner")]

    return(q[])
  }
}

#' Returns the number of jobs running at each location level
#'
#' @param dt data.table of qstat jobs, passed in
#' @param model_version_id dismod model version ID
#' @param user uuw net id of modeler running DisMod
#'
dismod_status <- function(dt, username, model_version_id) {
  loc_data <- data.table::fread(paste0(h_root, "ihme_r_pkg_files/location_metadata.csv"))

  dt <- data.table::copy(dt)
  dt[, job_name_detail := gsub("^(dm_\\d{6})_", "", JB_name)]
  dt[, location_id     := gsub("_[mf]_\\d+_.*$", "", job_name_detail)]

  dm <- dt[mvid == model_version_id]

  # tack on location ids
  location_metadata <- loc_data[, c("location_id", "location_name", "location_type")]
  location_metadata[, location_id := as.character(location_id)]

  dm <- merge(dm, location_metadata, by = "location_id", all.x = TRUE)
  dm[, location_type := ifelse(is.na(location_type), location_id, as.character(location_type))]

  # order the cascade levels: G0 (global) > ... > varnish (save results)
  levels <- c("G0", "superregion", "region", "admin0", "varnish")

  # Summarize jobs left running/waiting
  job_count <- dm[, .(jobs_left = .N), by = c("mvid", "location_name", "location_type", "state_id")]
  job_count[, progress := ifelse(!is.na(location_name), paste0(signif((1 - jobs_left / 12) * 100, digits = 2), "%"), "")]

  # order the jobs from global to subnational
  job_count$location_type <- factor(job_count$location_type, levels = levels)
  job_count <- job_count[order(location_type), ]

  return(job_count[])
}

##########
# qstat_dismod(username = "shadew", model_version_id = 123456)
# qstat_dismod(username = "shadew")




# Author: Shade Wilson
# 2/5/18
# qstating through R
# making complicated qstat outputs easier to comprend by leveraging the better interface of R
# (will need to be on the cluster to use, obvi)


#' @author Shade Wilson

# library(data.table)


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
#' qstat(username = "emumford", full = TRUE, verbose = TRUE)
#' qstat(username = "shadew", grep = "1.0", verbose = TRUE, state = "r")

qstat <- function(username = NULL, full = FALSE, grep = "", verbose = FALSE, state = "") {
  if (is.null(username)) {
    username <- Sys.info()[["user"]]
  }

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

  names(q) <- c("job_id", "JAT_prio", "job_name", "job_owner", "state_id", "job_submission_date",
                "job_submission_time", "queue", "slots")
  q[, node := stringr::str_extract(queue, "c[n2l].*\\d")]

  data.table::setattr(q, "time", Sys.time())
  return(q[])
}

#' Checking job status of DisMod models
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
  q[, mvid := stringr::str_extract(job_name, "\\d{6}")]

  if (!is.na(model_version_id)) {
    return(dismod_status(dt = q, username = username, model_version_id = model_version_id))
  } else {
    q <- q[, .(jobs = .N), by = c("mvid", "job_owner")]

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
  dt[, job_name_detail := gsub("^(dm_\\d{6})_", "", job_name)]
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



basic_qdel <- function(job_id, force) {
  force_flag <- if (force) {
    "-f "
  } else {
    ""
  }

  system(paste0("qdel ", force_flag, job_id))
}

#' Delete SGE jobs using qdel
#'
#' @description Flexible job deletion using different patterning including job name, job id,
#'              job state, etc.
#' @references http://gridscheduler.sourceforge.net/htmlman/htmlman1/qdel.html
#'
#' @param job_id the job_id(s) to delete. If this is specified, all other arguments are
#' overridden. If not specified, all other arguments to subset current jobs are taken into account
#' @param full TRUE for full job names, FALSE otherwise. Affects what is found with grep when the
#' job names are long
#' @param grep a regular expression string to search for in the qstat output
#' @param state string, grab only jobs in the given state. Most common are "r" (running) and
#' "p" (pending). All options are {p|r|s|z|S|N|P|hu|ho|hs|hd|hj|ha|h|a}. Any combination
#' of states is possible. See qstat manula page for more details.
#' @param state_id the specific state(s) seen when qstat is run, ie 'r', 'qw', 'hqw'. Can pass in multiple
#' @param node string name of the node(s) to delete jobs from. Can pass in multiple.
#' @param force Adds the force flag, '-f' to the qdel command to force deletion if TRUE. Default is FALSE
#' @param all if no job_ids are passed in and no arguments to subset qstat dataframe are given, all user
#' jobs will be deleted if set to TRUE. Use with caution. Default is false.
#' @return Nothing. Prints out system output for qdel command.
#' @export
#' @examples
#' qdel() # warning for no arguments passed in
#' qdel(all = TRUE) # deletes all running jobs
#' qdel(grep = "sti")
#' qdel(grep = "sti", node = c("cn555", "cn333")) # deletes all jobs matching 'sti' on either node cn555 or cn333
#' qdel(state = "p") # deletes all pending jobs
#' qdel(state_id = c("qw", "r")) # deletes all jobs in 'qw' OR 'r'
#'
qdel <- function(job_id = NA, full = FALSE, grep = "", state = "", state_id = NA,
                 node = NA, force = FALSE, all = FALSE) {
  if (is.na(job_id) && full == FALSE && grep == "" && state == "" &&
      is.na(state_id) && is.na(node) && all == FALSE) {
    stop(paste0("Must pass in at least one argument. If you wish to ",
                "delete all your jobs running, set 'all' to 'TRUE'."))
  }

  # if passed in vector of job_ids, delete them all
  if (!all(is.na(job_id))) {
    invisible(mapply(basic_qdel, job_id, force = force))
  } else {

    # grab qstat for USER given the arguments passed in
    q <- qstat(full = full, grep = grep, state = state)

    # subset jobs to r, qw, hqw, etc
    if (!all(is.na(state_id))) {
      state_ident <- state_id
      q <- q[state_id %in% state_ident]
    }

    # subset jobs to just the node passed (if given one)
    if (!all(is.na(node))) {
      node_name <- node
      q <- q[node %in% node_name]
    }

    if (nrow(q) == 0) {
      warning("No jobs met the filter criteria. No deletions will occur.")
    }
    invisible(mapply(basic_qdel, q$job_id, force = force))
  }
}



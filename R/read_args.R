#' Concise method to read in all arguments passed to an R script via the command line.
#'
#' @description Function to simplify reading in trailing arguments for a launched script. Designed for
#'              concise syntax and a more scalable interface. Arguments can be passed in as both quoted
#'              and unquoted strings.
#'
#' @param ... Pass in the variable names to assign to each trailing argument. Can be either
#'            symbols (names) or strings. Number of arguments passed in to this function must
#'            match exactly the number of trailing arguments. Trailing commandline arguments and
#'            arguments are paired up 1 to 1, so the order must match as well (but is not checked).
#'
#' @return Variables for each trailing commandline argument with the given names.
#' @export
#' @examples
#' read_args(my_name, my_script, info) # read in trailing arguments as variables named `my_name`, `my_script`, and `info`
#' read_args("location_id", "root_dir", "out_dir", "last_arg")

read_args <- function(...) {
  args   <- commandArgs(trailingOnly = TRUE)
  params <- as.list(match.call())
  i      <- 2

  if (length(args) != length(params) - 1) {
    stop(paste0("The number of trailing arguments (", length(args),
                ") does not match the number of arguments passed in (",
                length(params) - 1, ")."))
  }

  while (i <= length(args) + 1) {
    name <- conditional_deparse(params[[i]])
    assign(name, args[i - 1], envir = .GlobalEnv)
    i <- i + 1
  }
}

# read_args(location_id, "root_dir", out_dir, last_arg)

#' Helper function: deparse object names conditionally, only
#' if the argument passed in is indeed an object name
#'
#' @return string; deparsed name if was an object, returns original string otherwise
conditional_deparse <- function(a) {
  name <- if(is.name(a)) {
    deparse(a)
  } else {
    a
  }
}



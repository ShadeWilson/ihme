# Shade Wilson
# 11/28/2017
# More concise way of sourcing shared functions without having to remember the full file path 
# Can also source multiple functions at a time
# Will add in ability to specify functions by passing in a string vector

setup <- function(j_root_name = "j_root", h_root_name = "h_root", user_name = "user") {
  
  user <- Sys.info()[["user"]]
  
  # Linux or mac
  if (Sys.info()["sysname"] %in% c("Linux", "Darwin")) {
    j_root <- "/home/j/"
    h_root <- "~/"
  } else { 
    j_root <- "J:/"
    h_root <- "H:/"
  }
  
  # assign root values to global variables (or else they're lost in scope!)
  assign(j_root_name, j_root, envir = .GlobalEnv)
  assign(h_root_name, h_root, envir = .GlobalEnv)
  assign(user_name, user, envir = .GlobalEnv)
}


source_functions <- function(get_cod_data = FALSE, get_covariate_estimate = TRUE, 
                             get_results = FALSE, all = FALSE) {
  
  # set up OS flexibility
  setup()
  base <- paste0(j_root, "WORK/10_functions/etc/")
  
  args_list <- as.list(sys.call())
  
  # check if there were arguments given. If not, stop.
  if (length(args_list) == 1) {
    stop("Must set at least one function to source as true. If you want to source all functions, set all = TRUE.")
  }
  
  # translate the function arguments into a dataframe for easier subsetting
  # drop the first item (list name)
  args_char <- unlist(args_list[2:length(args_list)])       
  args_df <- data.frame(function_name=names(args_char), bool=args_char, row.names=NULL)
  
  # grab just the trues
  if (is.logical(args_df$bool)) {
    true_args <- args_df[args_df$bool, ]
  } else {
    stop("Invalid argument type. Must be logical (either TRUE or FALSE).")
  }
  
  # stop if none of the arguments passed in are false
  # no one should ever do this, but just in case
  if (nrow(true_args) == 0) {
    stop("At least one argument must be true.")
  }
  
  # source here, not print
  print(mapply(paste0, base, true_args$function_name, ".R"))
  
}

source_functions(get_cod_data = TRUE, get_results = TRUE)
source_functions(get_cod_data = TRUE, get_results = FALSE)
source_functions()
source_functions(get_cod_data = "one")
source_functions(get_cod_data = FALSE)

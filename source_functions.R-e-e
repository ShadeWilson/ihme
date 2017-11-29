# Shade Wilson
# 11/28/2017
# More concise way of sourcing shared functions without having to remember the full file path 
# Can also source multiple functions at a time
# Will add in ability to specify functions by passing in a string vector

setup <- function(j_root_name = "j_root", h_root_name = "h_root", user_name = "user") {
  
  user <- Sys.info()[["user"]]
  
  if (Sys.info()["sysname"] == "Linux") {
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


source_functions <- function(get_cod_data = FALSE, get_covariate_estimate = FALSE) {
  # source path roots
  setup()
  
  base <- paste0(j_root, "WORK/10_functions/etc")
  #print(base)
    
  args <- as.list(args(source_functions))
  for (arg in args) {
    print(arg)
  }
}

source_functions()

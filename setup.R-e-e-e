# Shade Wilson
# 11/16/2017
# Automated set up of j and h roots plus username
# can specify desired variable names, deults given


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

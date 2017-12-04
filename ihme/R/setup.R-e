#' Automated set up of j and h roots plus username based on the operating system.
#' @param j_root_name variable name for J drive root as a character string.
#' @param h_root_name variable name for H drive root as a character string.
#' @param user_name variable name for username as a character string.
#' @keywords setup
#' @export
#' @examples
#' setup() # uses default root names (j_root, h_root), and username default (user)
#' setup(j_root_name = "j", h_root_name = "h")


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

# Shade Wilson
# 12/7/2017

#' Git clone command in R
#' @description Perform a git clone in R. Default clones the repo to your H drive
#' @param repo_url The url of the repo you want to clone
#' @param repo_name The name you want to call the repo when you clone it. If not specified, use the original name of the repo
#' @export
#' @examples
#' git_clone("https://github.com/ShadeWilson/ihme")
#' git_clone("https://github.com/tidyverse/tidyverse", repo_name = "my_favorite_repo")

# TODO: give ability to change where cloned, rn default to h drive

git_clone <- function(repo_url, repo_name = NULL) {
  setup()

  # automatically grab repo name if not supplied one
  if (is.null(repo_name)) {
    intermediate_name <- stringr::str_extract(repo_url, "[^/]*.git$")
    repo_name <- stringr::str_extract(intermediate_name, "^[^.]*")
  }

  # if not, check the OS. Matters because linux/mac commands WONT work on windows
  if (Sys.info()["sysname"] %in% c("Linux", "Darwin")) {
    system(paste0("git clone ", repo_url, " ", h_root, repo_name))
  } else {
    # create temp shell script to run on Windows command line that opens a bash shell and executes
    temp_file <- "git_clone.sh"
    shell(paste0("ECHO #!/bin/bash > ", h_root, temp_file))
    shell(paste0("ECHO git clone ", repo_url , " ", h_root, repo_name, " >> ", h_root, temp_file))
    shell(paste0(h_root, temp_file))
    shell(paste0("del /f H:\\", temp_file)) # delete temp shell script
  }
}




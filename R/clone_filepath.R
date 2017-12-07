# do the git cloning here
# git clone git@github.com:whatever folder-name

# IDEA: check if exist, if not then clone and use :)

git_clone <- function(repo) {
  # check if the repo has already been cloned
  if ("ihme_r_pkg_files" %in% list.files(paste0(h_root))) {
    inner_path <- paste0(h_root, "ihme_r_pkg_files/inner_path")
    return(readChar(inner_path, file.info(inner_path)$size))
  }

  # if not, check the OS. Matters because linux/mac commands WONT work on windows
  if (Sys.info()["sysname"] %in% c("Linux", "Darwin")) {
    system(paste0("git clone", repo))
  } else {
    # create temp shell script to run on Windows command line that opens a bash shell and executes
    temp_file <- "git_clone.sh"
    shell(paste0("ECHO #!/bin/bash > ", h_root, temp_file))
    shell(paste0("ECHO git clone ", repo, " >> ", h_root, temp_file))
    shell(paste0(h_root, temp_file))
    #shell(paste0("del ", h_root, temp_file)) # delete temp shell script
  }

  inner_path <- paste0(h_root, "ihme_r_pkg_files/inner_path")
  return(readChar(inner_path, file.info(inner_path)$size))
}

git_clone("https://shadew@stash.ihme.washington.edu/scm/~shadew/ihme_r_pkg_files.git")




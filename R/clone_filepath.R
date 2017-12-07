# do the git cloning here
# git clone git@github.com:whatever folder-name

# wouldnt be have to grep for repo name

git_clone <- function(repo_url, repo_name = NULL) {

  if (is.null(repo_name)) {
    intermediate_name <- stringr::str_extract(repo_url, "[^/]*.git$")
    repo_name <- stringr::str_extract(intermediate_name, "^[^.]*")
  }

  # check if the repo has already been cloned
  # if (repo_name %in% list.files(paste0(h_root))) {
  #   inner_path <- paste0(h_root, repo_name, "/inner_path")
  #   return(readChar(inner_path, file.info(inner_path)$size))
  # }

  # if not, check the OS. Matters because linux/mac commands WONT work on windows
  if (Sys.info()["sysname"] %in% c("Linux", "Darwin")) {
    system(paste0("git clone", repo_url, " ", h_root, repo_name))
  } else {
    # create temp shell script to run on Windows command line that opens a bash shell and executes
    temp_file <- "git_clone.sh"
    shell(paste0("ECHO #!/bin/bash > ", h_root, temp_file))
    shell(paste0("ECHO git clone ", repo_url , " ", h_root, repo_name, " >> ", h_root, temp_file))
    shell(paste0(h_root, temp_file))
    shell(paste0("del /f H:\\", temp_file)) # delete temp shell script
  }
}

#git_clone("https://shadew@stash.ihme.washington.edu/scm/~shadew/ihme_r_pkg_files.git")



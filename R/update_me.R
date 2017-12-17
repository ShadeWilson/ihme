# Shade Wilson
# 12/14/17
# Can we figure out a good way to get this r package onto peoples computer for use on the cluster?
# it appears not, but we can automate the process or at least give people an alternative interface to do it?

# Adapted some ideas from http://thecoatlessprofessor.com/programming/automatically-check-if-r-package-is-the-latest-version-on-package-load/

library(magrittr)

# function to update package ihme
# needs work
update_me_at <- function(folder) {
  message(paste0("Updating package \"ihme\" at ", folder))
  args <- paste0('--library=\"', folder, "\"")

  devtools::install_github("ShadeWilson/ihme", args = args, force = TRUE)

  message("Please refresh your session of R to use the updated version of package ihme.")

}

folder <- "H:/packages"

update_me_at("H:/packages")

packages <- list.files("H:/packages")

is_installed <- function(package) is.element(package, installed.packages()[,1])

available <- as.data.frame(available.packages())

available[available$Package %in% packages, ] %>% View()

utils::packageDescription('ihme')


# Get the most recent package version available on the CRAN
package_version_cran <- function(package, cran_url="http://cran.r-project.org/web/packages/") {

  # Create URL
  cran_pkg_loc <- paste0(cran_url, package)

  # Try to establish a connection
  suppressWarnings(conn <- try(url(cran_pkg_loc), silent = TRUE))

  # If connection, try to parse values, otherwise return NULL
  if (all(class(conn) != "try-error")) {
    suppressWarnings(cran_pkg_page <- try(readLines(conn), silent = TRUE))
    close(conn)
  } else {
    return(NULL)
  }

  # Extract version info
  version_line <- cran_pkg_page[grep("Version:", cran_pkg_page) + 1]
  gsub("<(td|\\/td)>","",version_line)
}

package_version_cran("ggplot2")

# check package version of something hosted on github (ex: this package)
# TODO add better error handling
package_version_github <- function(repo) {
  raw_url <- paste0("https://raw.githubusercontent.com/", repo, "/master/DESCRIPTION")

  suppressWarnings(conn <- try(url(raw_url), silent = TRUE))

  # If connection, try to parse values, otherwise return NULL
  if (all(class(conn) != "try-error")) {
    suppressWarnings(description <- try(readLines(conn)))
    close(conn)
  } else {
    return(NULL)
  }

  version_line <- grep("Version", description, value = TRUE)
  version <- gsub("^Version: ", "", version_line)
  return(version)
}

package_version_github(repo = "ShadeWilson/ihme")


# check if locally downloaded package for use on cluster is up to date with the CRAN version
# github option is for if the package is hosted on github rather than the CRAN (or you want the dev version)
check_package <- function(package, folder, github_repo = NA){
  message(paste0(package, ":"))

  # Obtain the installed package information
  local_package <- utils::packageDescription(package, lib.loc = folder)

  # Grab the package information from CRAN
  latest_version <- package_version_cran(package)

  if (length(latest_version) == 0L && !is.na(github_repo)) {
    latest_version <- package_version_github(github_repo)
  }

  # Verify we have package information
  if(!is.null(latest_version) && length(latest_version) != 0L){
    latest_version <- utils::compareVersion(latest_version, local_package$Version)

    status <- if(latest_version == 0){
      'CURRENT'
    }else if(latest_version == 1){
      'OUT OF DATE'
    }else{
      'DEVELOPMENT'
    }

  }else{ # Gracefully fail.
    status <- "ERROR IN OBTAINING REMOTE VERSION INFO"
    latest_version <- 0

  }

  message(paste0('Version: ', local_package$Version, ' (', status,') of ', package, ' built on ', local_package$Date))

  if(latest_version == 1){
    message(paste0("Package ", package, " out of date. Update as soon as possible."))
  }
}


check_package(package = "ggplot2", folder = folder)
check_package("ihme", folder = folder, github_repo = "ShadeWilson/ihme")


# wrapper for check_package, allows easy way to check multiple packages in a single folder
check_package_all <- function(packages, folder, github_repo = NA) {
  stopifnot(is.character(packages))

  invisible(mapply(check_package, package = packages, folder = folder, github_repo = github_repo))
}

github <- c(rep(NA, 3), "ShadeWilson/ihme", rep(NA, 4))
check_package_all(packages, folder, github_repo = "ShadeWilson/ihme")
check_package_all(packages, folder, github_repo = github)









# Shade Wilson
# 12/14/17
# Can we figure out a good way to get this r package onto peoples computer for use on the cluster?
# it appears not, but we can automate the process or at least give people an alternative interface to do it?

# Adapted some ideas from http://thecoatlessprofessor.com/programming/automatically-check-if-r-package-is-the-latest-version-on-package-load/

#' Get the most recent package version available
#' @description Retrieve the package version for the latest package available on either the CRAN or Github.
#' Since the approval process for packages on the CRAN can lag behind the pace of development, the Github version
#' of packages that are hosted there is likely to be more up to date. Helper methods for check_package(), update_package(),
#' and family members.
#' @param package Name of the package as a string
#' @param cran_url Defaults to the CRAN's R package landing page. Does not need to be changed unless for advanced usage.
#' @export
#' @examples
#' package_version_cran("ggplot2")



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

# folder <- "H:/packages"
# packages <- list.files("H:/packages")
# package_version_cran("ggplot2")

# check package version of something hosted on github (ex: this package)
# TODO add better error handling

#' @describeIn package_version_cran Get Github package version
#' @examples
#' package_version_github("ShadeWilson/ihme")

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

# package_version_github("ShadeWilson/ihme")


# check if locally downloaded package for use on cluster is up to date with the CRAN version
# github option is for if the package is hosted on github rather than the CRAN (or you want the dev version)
# concise gives a concise message whether the package is current or not as well
# as a bool (true if it is the lastest, false if not)

#' Check if a package is up to date with the latest version
#' @description Check if a locally downloaded package for use on the cluster is up to date with the
#' lastest version available. Works for a package hosted on either the CRAN or on Github. For checking mutliple
#' packages at once, use check_package_all(): a wrapper for check_package that allows you to pass in a character
#' vector of multiple packages
#' @param package Name of the package as a string
#' @param folder Folder (directory) where all the packages are stored
#' @param github_repo Specifies the Github repo the package is hosted at. Defaults to NA for packages hosted on the CRAN
#' @param concise Whether or not to return a concise message on the package status (CURRENT, OUT OF DATE, etc.) Defaults to FALSE.
#' @export
#' @examples
#' folder <- "H:/packages"
#' packages <- list.files("H:/packages")
#'
#' check_package("ggplot2", folder = folder, concise = TRUE)
#' check_package("ihme", folder = folder, github_repo = "ShadeWilson/ihme")
#'
#' check_package_all(packages, folder)

check_package <- function(package, folder, github_repo = NA, concise = FALSE){
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

  if (concise) {
    message(status)
    return(ifelse(latest_version == 0, TRUE, FALSE))
  }

  message(paste0('Version: ', local_package$Version, ' (', status,') of ', package, ' built on ', local_package$Date))

  if(latest_version == 1){
    message(paste0("Package ", package, " out of date. Update as soon as possible."))
  }
}

# folder <- "H:/packages"
# packages <- list.files("H:/packages")
#
# check_package(package = "ggplot2", folder = folder, concise = TRUE)
# check_package("ihme", folder = folder, github_repo = "ShadeWilson/ihme")



#' @describeIn check_package Wrapper for checking multiple packages at once
#' folder <- "H:/packages"
#' cran_packages <- c("data.table", "devtools", "ggplot2", "lme4", "openxlsx", "tibble" , "tidyr")
#'
#' # can also list packages in a folder with list.files(folder)
#' packages <- list.files("H:/packages")
#'
#' # all packages hosted on the CRAN
#' check_package_all(cran_packages, folder)
#'
#' # all packages on the CRAN except "ihme", which is hosted on Github
#' mixed_packages <- c("data.table", "devtools", "ggplot2" , "ihme", "lme4", "openxlsx", "tibble" , "tidyr")
#' github_repos <- c(rep(NA, 3), "ShadeWilson/ihme", rep(NA, 4))
#'
#' check_package_all(mixed_packages, folder, github_repo = github_repos)

check_package_all <- function(package, folder, github_repo = NA, concise = FALSE) {
  stopifnot(is.character(package))

  invisible(mapply(check_package, package = package, folder = folder, github_repo = github_repo, concise = concise))
}

# TODO: make helper function to tell which are hosted on github?

# github_repos <- c(rep(NA, 3), "ShadeWilson/ihme", rep(NA, 4))
# check_package_all(packages, folder)
# check_package_all(packages, folder, github_repo = github_repos)
# check_package_all(packages, folder, github_repo = github_repos, concise = TRUE)


#' Update locally downloaded package(s)
#' @description Update one or many packages in a sinlge, local folder to ease version control when working on the cluster
#' or elsewhere remotely. Will only update the packages that are determined to be out of date to avoid wasting time
#' re-downloading packages that are already current.
#' @param package Name of the package as a string
#' @param folder Folder (directory) where all the packages are stored
#' @param github_repo Specifies the Github repo the package is hosted at. Defaults to NA for packages hosted on the CRAN
#' @export
#' @examples
#' folder <- "H:/packages"
#'
#' update_package("data.table", folder)
#' update_package("ihme", folder = folder, github_repo = "ShadeWilson/ihme")

update_package <- function(package, folder, github_repo = NA) {
  is_current <- check_package(package, folder = folder, concise = TRUE)

  # if the package is already current, don't re-install
  if (is_current) {
    return(message(paste0("Package ", package, " is up to date already.")))
  }

  # if the package version is out of date:
  if (!is_current) {
    if (!is.na(github_repo)) {
      message(paste0("Updating package", package, " at ", folder))
      args <- paste0('--library=\"', folder, "\"")

      devtools::install_github(github_repo, args = args, force = TRUE)
      message(paste0("Please refresh your session of R to use the updated version of package ", package, "."))
    }
    else {
      install.packages(package, lib = folder)
    }
  }

  message("Finished installation in ", folder, ".")
}

# update_package("data.table", folder)


#' @describeIn update_package Wrapper for update_package
#' @examples
#' folder <- "H:/packages"
#' packages <- list.files(folder)
#'
#' update_package_all(packages, folder)

update_package_all <- function(package, folder, github_repo = NA) {
  stopifnot(is.character(package))

  invisible(mapply(update_package, package = package, folder = folder, github_repo = github_repo))
}

# some_packages <- packages[5:8]
# update_package_all(some_packages, folder)



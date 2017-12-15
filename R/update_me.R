# Shade Wilson
# 12/14/17
# Can we figure out a good way to get this r package onto peoples computer for use on the cluster?
# it appears not, but we can automate the process or at least give people an alternative interface to do it?

library(magrittr)


update_me_at <- function(folder) {
  message(paste0("Updating package \"ihme\" at ", folder))
  args <- paste0('--library=\"', folder, "\"")

  devtools::install_github("ShadeWilson/ihme", args = args, force = TRUE)

}

folder <- "H:/packages"

update_me_at("H:/packages")

packages <- list.files("H:/packages")

is_installed <- function(package) is.element(package, installed.packages()[,1])

available <- as.data.frame(available.packages())

available[available$Package %in% packages, ] %>% View()

utils::packageDescription('ihme')

pkgVersionCRAN = function(pkg, cran_url="http://cran.r-project.org/web/packages/")
{

  # Create URL
  cran_pkg_loc = paste0(cran_url,pkg)

  # Try to establish a connection
  suppressWarnings( conn <- try( url(cran_pkg_loc) , silent=TRUE ) )

  # If connection, try to parse values, otherwise return NULL
  if ( all( class(conn) != "try-error") ) {
    suppressWarnings( cran_pkg_page <- try( readLines(conn) , silent=TRUE ) )
    close(conn)
  } else {
    return(NULL)
  }

  # Extract version info
  version_line = cran_pkg_page[grep("Version:",cran_pkg_page)+1]
  gsub("<(td|\\/td)>","",version_line)
}

pkgVersionCRAN("ggplot2")


check_package <- function(...){
  # Avoid running if in batch job / user not present
  if (!interactive()) return()

  # Obtain the installed package information
  local_version = utils::packageDescription('ggplot2', lib.loc = folder)$Version

  # Grab the package information from CRAN
  cran_version = pkgVersionCRAN("ggplot2")

  # Verify we have package information
  if(!is.null(cran_version) && length(cran_version) != 0L){
    latest_version = utils::compareVersion(cran_version, local_version)

    d = if(latest_version == 0){
      'CURRENT'
    }else if(latest_version == 1){
      'OUT OF DATE'
    }else{
      'DEVELOPMENT'
    }

  }else{ # Gracefully fail.
    d = "ERROR IN OBTAINING REMOTE VERSION INFO"
    latest_version = 0
  }

  # Use packageStartUpMessages() so that folks can suppress package messages with
  # suppressPackageStartupMessages(library(pkg))
  packageStartupMessage('Version: ', local_version$Version, ' (', d,') built on ', local_version$Date)
  if(latest_version == 1){
    packageStartupMessage('\n!!! NEW VERSION ', cran_version , ' !!!')
    packageStartupMessage('Download the latest version: ',cran_version,' from CRAN via `install.packages("pkgname")`\n')
  }
}

# Shade Wilson
# 12/14/17
# Can we figure out a good way to get this r package onto peoples computer for use on the cluster?
# it appears not, but we can automate the process or at least give people an alternative interface to do it?




update_me_at <- function(filepath) {
  message(paste0("Updating package \"ihme\" at ", filepath))
  args <- paste0('--library=\"', filepath, "\"")

  devtools::install_github("ShadeWilson/ihme", args = args, force = TRUE)

}

update_me_at("H:/packages/")

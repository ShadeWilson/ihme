# Shade Wilson
# 11/28/2017
# More concise way of sourcing shared functions without having to remember the full file path
# Can also source multiple functions at a time
# Will add in ability to specify functions by passing in a string vector

# TODO: add in arg to specify version

try_source <- function(base, func, folder) {
  file <- paste0(base, func, ".R")

  shared_function = tryCatch({
    source(file, echo = FALSE, print.eval = FALSE)
    message(paste0("Sourced ", func))
 }, error = function(e) {
    message(paste0("Function does not exist in ", folder, ". Error: ", e))
    return (NA)
  }, warning = function(cond) {
    message(paste0(func, " does not exist in folder: ", folder, ". ", cond))
    return(NA)
  }, finally = {

  }
  )
}


source_functions <- function(get_best_model_versions = FALSE, get_cause_metadata = FALSE, get_covariate_estimates = TRUE,
                             get_demographics = FALSE, get_epi_data = FALSE, get_ids = FALSE,
                             get_location_metadata = FALSE, get_rei_metadata = FALSE, get_restrictions = FALSE,
                             upload_epi_data = FALSE, validate_input_sheet = FALSE, get_cod_data = FALSE,
                             get_envelope = FALSE, get_envelope_with_shock = FALSE, get_life_table = FALSE,
                             get_life_table_with_shock = FALSE, get_model_results = FALSE, get_population = FALSE,
                             get_draws = FALSE, get_outputs = FALSE, interpolate = FALSE, save_results_cod = FALSE,
                             save_results_epi = FALSE, get_pct_change = FALSE, split_cod_model = FALSE,
                             split_epi_model = FALSE, all = FALSE) {

  # set up OS flexibility
  setup()
  folder <- "current"
  base <- paste0(j_root, "REDACTED/", folder, "/r/")

  # source all functions if option all is true
  if (all == TRUE) {
    default_args <- as.list(args(source_functions))
    default_args <- default_args[1:(length(default_args) - 2)]
    functions <- names(default_args)
    #print(mapply(paste0, base, functions, ".R"))
    filepaths <- mapply(paste0, base, functions, ".R")
    mapply(try_source, base = base, func = unname(functions), folder = folder)
    message("All shared functions sourced.")
    return()
  }

  args_list <- as.list(sys.call())

  # check if there were arguments given. If not, stop.
  if (length(args_list) == 1) {
    stop("At least one shared function must be true. To source all functions, set all = TRUE.")
  }

  # translate the function arguments into a dataframe for easier subsetting
  # drop the first item (list name)
  args_char <- unlist(args_list[2:length(args_list)])
  args_df <- data.frame(function_name=names(args_char), bool=args_char, row.names=NULL)

  # grab just the trues
  if (is.logical(args_df$bool)) {
    true_args <- args_df[args_df$bool, ]
  } else {
    stop("Invalid argument type. Must be logical (either TRUE or FALSE).")
  }

  # stop if none of the arguments passed in are false
  # no one should ever do this, but just in case
  if (nrow(true_args) == 0) {
    stop("At least one argument must be true.")
  }

  # source here, not print
  filepaths <- mapply(paste0, base, true_args$function_name, ".R")
  #mapply(try_source, base = base, func = unname(filepaths), folder = folder)
  mapply(try_source, base = base, func = true_args$function_name, folder = folder)
}

source_functions(get_cod_data = TRUE)
source_functions(get_cause_metadata = TRUE, save_results_cod = TRUE)
source_functions()
source_functions(get_cod_data = "one")
source_functions(get_cod_data = FALSE)
source_functions(split_cod_model = TRUE)
source_functions(all = TRUE)

try_source(base = paste0(j_root, "REDACTED/current/r/"), func = "split_cod_model", folder = "current")




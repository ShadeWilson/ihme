# Shade Wilson
# 11/28/2017

#' Simplified shared function sourcing
#' @description More concise way of sourcing shared functions without having to remember the full file path. Can source multiple functions at a time or all of them at once. All arguments for shared functions must be logical (ie. TRUE)
#' @param create_connection_string provides the credentials to access GBD databases. Not currently avaiable for GBD 2017.
#' @param get_best_model_versions queries gbd team specific databases (cod, epi, covariate) for best model versions based on GBD team and id.
#' @param get_cause_metadata returns cause hierarchy information. By default it will provide the current best version of whatever cause set is specified. The full list of valid cause sets are in shared.cause_set
#' @param get_covariate_estimates retrieve covariate esitmates in database. By default it returns all demographics, but you can optionally specify a subset. Also by default it retrives the best covariate model from the current GBD round, you can alternatively specify
#' @param get_demographics Given a gbd team (cod/epi/epi_ar/cov/mort) and a gbd round, return an dictionary with proper demographic ids.
#' @param get_epi_data read epi data directly into memory, allowing users to bypass the download button in the epiupload webpage. Only active data for a single bundle_id can be retrieved.
#' @param get_ids A simple table lookup function used to return a dataframe of entity (example: ‘cause’, ‘rei’) ids and names
#' @param get_location_metadata Return a location hierarchy for a given location set id, or version id
#' @param get_rei_metadata Returns rei hiearchy with additional metadata. Given a rei set id, return a rei hierarchy. By default, returns the current best version for gbd 2017.
#' @param get_restrictions Return restrictions for sex, measure, or age for given combinations of causes and those dimensions
#' @param model_custom deprecated function
#' @param upload_epi_data Process upload request for a given file. Works for bundles associated with either dismod or stgpr.
#' @param validate_input_sheet run validations on a file independent of running a full upload
#' @param get_cod_data Returns a dataframe of cod data for a given cause, a given cause set version and a given location set version
#' @param get_envelope Returns a dataframe of all-cause envelope for a set of given ages locations, years, and sexes, and given envelope specifications corresponding to “best” status. If -1 is an input, runs on all possible values of that argument. Accepts -1 for ages, locations, sexes, and years
#' @param get_envelope_with_shock Coming soon.
#' @param get_life_table Returns a dataframe of life table values for a set of given ages,locations, years, and sexes, a given status, and given envelope specifications. If -1 is an input, runs on all possible values of that argument. Accepts -1 for ages, locations, sexes, years, and life_table_parameter_ids.
#' @param get_life_table_with_shock Coming soon.
#' @param get_model_results Returns the best/latest/version_id-specific model results for the given arguments
#' @param get_population Returns a dataframe of populations for a set of given ages, locations,years, and sexes, and a given status. If ‘all’ is an input, runs on all possible values of that argument. Accepts ‘all’ for ages, locations, sexes, and years
#' @param get_draws for reading draw files. The function is designed to support reading draws from specific points in the GBD process.
#' @param get_outputs Get_outputs is a function used to retrieve our final results from the GBD outputs database. This is the same database that GBD-Compare uses.
#' @param interpolate wrapper function that lives inside of draw_ops which brings together both gopher.draws to pull the draws, maths.interpolate to interpolate draws, and maths.extrapolate to back-interpolate the draws to 1980 for applicable measures and sources.
#' @param save_results_cod The save_results package allows researchers to upload custom models for further processing in the GBD pipeline.
#' @param save_results_epi The save_results package allows researchers to upload custom models for further processing in the GBD pipeline.
#' @param get_pct_change calculates the percent change between two years for a given set of demographics and ids at the draw level.
#' @param make_aggregates Coming soon.
#' @param save_results_covariates The save_results package allows researchers to upload custom models for further processing in the GBD pipeline.
#' @param save_results_risk The save_results package allows researchers to upload custom models for further processing in the GBD pipeline.
#' @param split_cod_model useful if you have a one cod model (e.g. Liver cancer, p0) that you want to split into a number of sub-cause cod models (e.g. due to Hepatitis B (p1), due to Hepatitis C (p2), due to Alcohol Use (p3), and due to Other (p4))
#' @param split_epi_model useful if you have a one model (e.g. prevalence of dementia, p0) that you want to split into a number of sub-models (e.g. mild, moderate, and severe dementia; p1, p2, and p3 respectively).
#' @param all set to TRUE if you want to source all available shared functions in the selected folder (default: current/r)
#' @param folder the folder where the shared functions are checked for, defaults to current/r. Change only if you know which older version you want to source
#' @keywords source shared functions
#' @export
#' @examples
#' source_functions(get_cod_data = TRUE)
#' source_functions(get_cause_metadata = TRUE, save_results_cod = TRUE)
#' source_functions(all = TRUE)

source_functions <- function(create_connection_string = FALSE,   # WAVE 1
                             get_best_model_versions = FALSE,
                             get_cause_metadata = FALSE,
                             get_covariate_estimates = TRUE,
                             get_demographics = FALSE,
                             get_epi_data = FALSE,
                             get_ids = FALSE,
                             get_location_metadata = FALSE,
                             get_rei_metadata = FALSE,
                             get_restrictions = FALSE,
                             model_custom = FALSE,
                             upload_epi_data = FALSE,
                             validate_input_sheet = FALSE,
                             get_cod_data = FALSE,               # WAVE 2
                             get_envelope = FALSE,
                             get_envelope_with_shock = FALSE,
                             get_life_table = FALSE,
                             get_life_table_with_shock = FALSE,
                             get_model_results = FALSE,
                             get_population = FALSE,
                             get_draws = FALSE,                  # WAVE 3
                             get_outputs = FALSE,
                             interpolate = FALSE,
                             save_results_cod = FALSE,
                             save_results_epi = FALSE,
                             get_pct_change = FALSE,             # WAVE 4
                             make_aggregates = FALSE,
                             save_results_covariates = FALSE,    # name maybe incorrect
                             save_results_risk = FALSE,
                             split_cod_model = FALSE,
                             split_epi_model = FALSE,
                             all = FALSE, folder = "current/r/") {

  # try catch for sourcing: catches functions not yet imported into the current (or any) folder
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

  # set up OS flexibility
  setup()
  base <- paste0(j_root, "REDACTED", folder)

  # source all functions if option all is true
  if (all == TRUE) {
    default_args <- as.list(args(source_functions))
    default_args <- default_args[1:(length(default_args) - 3)]
    functions <- names(default_args)
    #print(mapply(paste0, base, functions, ".R"))
    #filepaths <- mapply(paste0, base, functions, ".R")
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
  #filepaths <- mapply(paste0, base, true_args$function_name, ".R")
  invisible(mapply(try_source, base = base, func = true_args$function_name, folder = folder))
}

source_functions(get_cod_data = TRUE)
source_functions(get_cause_metadata = TRUE, save_results_cod = TRUE)
source_functions()
source_functions(get_cod_data = "one")
source_functions(get_cod_data = FALSE)
source_functions(split_cod_model = TRUE)
source_functions(all = TRUE)






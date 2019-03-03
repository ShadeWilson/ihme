# Functions for Simplifying Life at IHME 
Functions to improve efficiency, minimize copying/pasting common code, and abstract away unimportant details like exact filepaths.

A simple R package for internal use at IHME. Any feedback about the current functions or suggestions for other useful functions you may have would be great! [Submit any ideas or issues here](https://github.com/ShadeWilson/ihme/issues) or contact me at shadew@uw.edu.

## Installation

```r
install.packages("devtools")
devtools::install_github("ShadeWilson/ihme")

# to download the package for use on the cluster 
# change the library argument to wherever you want it to be saved
# Here I save to H:/packages. Hint: to compile correctly, I've found I need to run this locally
devtools::install_github("ShadeWilson/ihme", args = c('--library="H:/packages/"'))
```

## Usage

```r
# locally
library(ihme)

# or
ihme::setup() # (or any other function in the package)

# on the cluster
library("ihme", lib.loc = "~/packages") # lib.loc is wherever you have the package saved
```

**Functions currently available:** `setup()`, `source_functions()`, `git_clone()`, `read_args()`, `qstat()`, `qstat_dismod()`, `package_version_cran()`, `package_version_github()`, `check_package()`, `check_package_all()`, `check_package_all()`, `update_package()`, `update_package_all()`

**Functions under development:** None currently. [Suggest one here](https://github.com/ShadeWilson/ihme/issues)!

Below are descriptions of each function and examples of how to use them.

### Basic functions

`setup()`: Automated environment setup based on the operating system. Gives default variable names of j_root, h_root, and user, but any argument can be passed a different name if desired.

```r
setup() # uses default root names (j_root, h_root), and username default (user)
setup(j_root_name = "j", h_root_name = "h")
```

`source_functions`: More concise way of sourcing shared functions without having to remember the full file path. Can source multiple functions at a time or all of them at once.

```r
source_functions(get_cod_data = TRUE)                      # source just get_cod_data
source_functions(get_cod_data = TRUE, get_results = TRUE)  # source both listed functions
source_functions(all = TRUE)                               # source all available shared functions
```

### Cluster tools

`qsub()`: Submit a job on the cluster through R with a simplyfied interface. Adapting code written by Grant Nguyen.

```r
jobname <- "my_job_name"
args    <- list(out_dir, root_dir, location_id, model_version_id)
  
qsub(jobname, code = paste0(root_dir, code = "00_best_script.R"), pass = args,
     slots = 5, submit = TRUE, proj = "proj_my_project", shell = "~/my_shell_script.sh")
```

`qstat()`: Basic qstat functionality for monitoring jobs running on the Sun Grid Engine (SGE).

```r
qstat()             # defaults to checking jobs for the current user
qstat(full = TRUE)  # current user with full job names
qstat(grep = "sti") # current user, only shows jobs whose job name contains "sti". Can pass any regex
qstat(username = "emumford", full = TRUE, verbose = TRUE) # shows jobs for user "emumford", full job names, and prints qstat command
qstat(username = "shadew", grep = "1.0", verbose = TRUE, state = "r") # qstat for "shadew" matching jobs with pattern "1.0" that are running
```

`qstat_dismod()`: Checking job status of DisMod models.

```r
qstat_dismod() # returns a summary table of number of jobs running for each model for user
qstat_dismod(username = "shadew", model_version_id = 123456) # for "shadew" and given model, returns in-depth job summary table
```

`read_args()`: Concise method to read in all arguments passed to an R script via the command line.

```r
# if reading in arguments from script qsub-ed in example above:
read_args(out_dir, root_dir, location_id, model_version_id)

# can also use strings
read_args(paste0(var, 1:4))
```

### Package versioning tools

`git_clone()`: Perform a git clone in R. Can choose a new name for the cloned repo or keep the original

```r
git_clone("https://github.com/ShadeWilson/ihme")
git_clone("https://github.com/tidyverse/tidyverse", repo_name = "my_favorite_repo")
```

`package_version_cran()`, `package_version_github()`: Retrieve the most recent package version on the CRAN/Github. Helper methods for `check_package()`, `update_package()`, and family members.

```r
package_version_cran("ggplot2")
package_version_github("ShadeWilson/ihme")
```

`check_package()`, `check_package_all()`: Check if a locally downloaded package for use on the cluster is up to date with the lastest version available. The github_repo option is for packages hosted on Github rather than the CRAN (or you want the developer version instead). `check_package_all()` is a wrapper for `check_package()` that allows you to check the version status of multiple packages at a time.

```r
setup()
folder <- paste0(h_root, "packages")

check_package("ggplot2", folder = folder)
check_package("ihme", folder = folder, github_repo = "ShadeWilson/ihme")

# can also list packages in a folder with list.files(folder)
# all packages hosted on the CRAN
cran_packages <- c("data.table", "devtools", "ggplot2", "lme4", "openxlsx", "tibble" , "tidyr")
check_package_all(cran_packages, folder)

# all packages on the CRAN except "ihme", which is hosted on Github
mixed_packages <- c("data.table", "devtools", "ggplot2" , "ihme", "lme4", "openxlsx", "tibble" , "tidyr")
github_repos <- c(rep(NA, 3), "ShadeWilson/ihme", rep(NA, 4))

check_package_all(mixed_packages, folder, github_repo = github_repos)
```

`update_package()`, `update_package_all()`: Update one or all packages in a single, local folder to ease package version control when working on the cluster or elsewhere remotely. Will only update the packages that are determined to be out of date to avoid wasting time re-downloading packages that are already current.

```r
setup()
folder <- paste0(h_root, "packages")

update_package("data.table", folder)
update_package("ihme", folder = folder, github_repo = "ShadeWilson/ihme")

packages <- list.files(folder)
update_package_all(packages, folder)
```


## Updates

Version | Updates
--- | ---
**0.6.1.0** | Fix `qstat()` documentation
**0.6.0.0** | Add flexible SGE job deletion with `qdel()`. Update `source_functions()` for GBD 2019 shared function names. Minor bug fix for `qstat()`.
**0.5.1.1** | Add data.table to imports to fix issues qith `qstat()`
**0.5.1.0** | Minor bug fixes
**0.5.0.0** | Add in several new functions: `read_args()` for easier parsing trailing arguments when launching a script, and two function built aroud qstating.
**0.4.0.0** | Address bug breaking `source_functions()` for first-time users; minor edits.
**0.3.0.0** | Add in `qsub()` functions.
**0.2.1.0** | Fix documentation bug with some of the package version control functions.
**0.2.0.0** | Add in package version control functions.
**0.1.0.0** | Update version number to follow conventions. Fix bug in `source_functions()`.
**0.0.2.9000** | Add function `git_clone()`. Replace file path mentions within code with calls to secure repos. Update `source_functions()`.



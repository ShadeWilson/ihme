# Functions for Simplifying Life at IHME 
Functions to improve efficiency, minimize copying/pasting common code, and abstract away unimportant details like exact filepaths.

A simple R package for internal use at IHME. Any feedback about the current functions or suggestions for other useful functions you may have would be great! [Submit any ideas or issues here](https://github.com/ShadeWilson/ihme/issues) or contact me at shadew@uw.edu.

## Installation

```r
install.packages("devtools")
devtools::install_github("ShadeWilson/ihme")

# to download the package for use on the cluster 
# change the library argument to wherever you want it to be saved
# Here I save to H:/packages
devtools::install_github("ShadeWilson/ihme", args = c('--library="H:/packages/"')
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

**Functions currently available:** `setup()`, `source_functions()`, `git_clone()`

**Functions under development:** `qsub()` (and related functions)

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

`qsub()`: Submit a job on the cluster through R with a simplyfied interface. Adapting code written by Grant Nguyen.

`git_clone()`: Perform a git clone in R. Can choose a new name for the cloned repo or keep the original

```r
git_clone("https://github.com/ShadeWilson/ihme")
git_clone("https://github.com/tidyverse/tidyverse", repo_name = "my_favorite_repo")
```

## Updates

**0.1.0.0**: Update version number to follow conventions. Fix bug in `source_functions()`.

**0.0.2.9000:** Add function `git_clone()`. Replace file path mentions within code with calls to secure repos. Update `source_functions()`.



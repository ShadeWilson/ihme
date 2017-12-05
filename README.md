# Functions for Simplifying Life at IHME 
Functions to improve efficiency, minimize copying/pasting common code, and abstract away unimportant details like exact filepaths.

A simple R package for internal use at IHME. Any feedback you may have would be great! [Submit any suggestions or issues here](https://github.com/ShadeWilson/ihme/issues) or contact me at shadew@uw.edu.

## Installation

```r
install.packages("devtools")
library(devtools)
install_github("ShadeWilson/ihme")
```

## Usage

```r
library(ihme)

# or
ihme::setup() # (or any other function in the package)
```

**Functions currently available:** `setup()`, `source_functions()`

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






# Author: Shade Wilson
# 2/5/18
# qstating through R
# making complicated qstat outputs easier to comprend by leveraging the better interface of R
# (will need to be on the cluster to use, obvi)

# qstat <- function(print = FALSE) {
#   object <- system("qstat -u emgold2", intern = TRUE)
#
#   if (print) {
#     system("qstat")
#   }
#   return(object)
# }
# qstat()
#
# trim <- function(string) {
#   gsub("(^ )|( $)", "", string)
# }
#
# split_whitespace <- function(string) {
#   strsplit(string, "[ \t]+")
# }
#
# cat <- qstat()
# cat1 <- trim(cat)
#
# split <- split_whitespace(cat1)
#
# rows <- rbind(split[[3]], split[[4]])
# df <- as.data.frame(rows)
# setNames(df, split[[1]])
#
#
# strsplit(cat1, " +")
#
#
#







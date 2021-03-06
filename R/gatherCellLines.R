library(readr)
library(dplyr)
library(tidyr)

# matchcell <- read_csv("https://raw.githubusercontent.com/bhklab/DRUGNET/master/Curation/matching_cell.csv")
matchcell <- read_csv("./data/matching_cell.csv")

## Find NA
nacol <- which(is.na(names(matchcell)))
if (length(nacol)) {
    matchcell <- matchcell[, -which(is.na(names(matchcell)))]
}

## Remove empty variable
matchcell <- matchcell[, !names(matchcell) == "X14"]

## remove NA column
## subset variables that are not ID vars into object
verbosevars <- select(matchcell, Comment, COSMIC.tissueid)

## remove unwanted variables from data
matchcell <- select(matchcell, -Comment, -COSMIC.tissueid)

matchcell2 <- gather(matchcell, key = "idtype", value = "multi.cellid", 2:length(matchcell))
matchcell2 %>% select(unique.cellid, multi.cellid) -> matchcell2
matchcell2 <- matchcell2[!duplicated(matchcell2),]

cellids <- matchcell2

if (!dir.exists("./inst/extdata/"))
    dir.create("./inst/extdata/", recursive = TRUE)

cellid_db <- src_sqlite("./inst/extdata/cellid.sqlite", create = TRUE)

cellid <- copy_to(cellid_db, cellids, temporary = FALSE, indexes = list("unique.cellid"))

# matchcell2 <- matchcell2[apply(matchcell2, 1, function(rows) { !duplicated(rows) })[2, ] ,]
# matchcellF <- matchcell2[complete.cases(matchcell2),]

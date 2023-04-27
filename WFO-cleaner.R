### The purpose of this script is to utilize the WorldFlora package to clean the scientific names of a set of species ###
                                            # author: GTEduarte2023


# install packages (only do this for the first time add '#' to disable the line)
install.packages("WorldFlora")
install.packages("qdap")
install.packages("dplyr")


# load packages
library(WorldFlora) 
library(qdap)
library(dplyr)

# set base directory (change this to directory on your laptop)
basedir <- "C:/Users/Gerald/Desktop/R-Studio/Packages/WFO-cleaner"

# set country
country <- "Philippines"
# note: this should be indicated in the in the filename of the downloaded checklist
# (1) go to website of GlobalTreeSearch and download checklist of the Philippines


# load species set to download data from
setwd(dir = paste0(basedir, "/Input data"))
species <- read.csv(paste0("globaltreesearch_results_", country, ".csv"))
# you may also load your list
#setwd(dir = paste0(basedir, "/Input data"))
#species <- read.csv(paste0("addFileNameHere.csv"))


# download WorldFlora taxonomic backbone
setwd(dir = paste0(basedir, "/Result data"))

#WFO.download()
library(WorldFlora)
WFO.download()

# match with WorldFlora
# full matching
species_cleaned <- WFO.match(spec.data = species, 
                             spec.name = "taxon",
                             squish = TRUE,
                             WFO.data = WFO.data, 
                             counter = 1, 
                             verbose = TRUE,
                             Fuzzy = 0.05)
# select the best match
species_cleaned_best <- WFO.one(WFO.result = species_cleaned,
                                priority = "Accepted",
                                counter = 1,
                                verbose =  TRUE)

# keep the original species name if only matching genus returned
# do this by counting the words in the cleaned species names column
w_c <- word_count(species_cleaned_best$scientificName)

# replace cleaned species names by original names if count < 2
i <- which(w_c < 2)
species_cleaned_best$scientificName[i] <- species_cleaned_best$taxon.ORIG[i]

# remove subspecies
for (i in 1:nrow(species_cleaned_best)) {
  species_split <- strsplit(species_cleaned_best$scientificName[i], split = " ")[[1]]
  species_cleaned_best$scientificName[i] <- paste0(species_split[1], " ", species_split[2])
}

# check the results
head(species_cleaned_best)

# get only the columns we need
species_cleaned_best <- species_cleaned_best[,c("taxon.ORIG", "scientificName")]
# rename
names(species_cleaned_best)[2] <- "species"

# indicate for which species the name has changed
species_cleaned_best$changed <- NA
i <- which(species_cleaned_best$species != species_cleaned_best$taxon.ORIG)
species_cleaned_best$changed[i] <- "updated"
head(species_cleaned_best)

# save the results
setwd(dir = paste0(basedir, "/Result data"))
write.csv(species_cleaned_best, paste0("globaltreesearch_results_", country, "_cleaned.csv")) 
# MANUALLY CHECK IF OK
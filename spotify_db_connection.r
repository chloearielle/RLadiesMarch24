# load required packages
library(tidyverse)
library(RSQLite)
# library(dbplyr) # DON'T NEED TO LOAD DBPLYR IN!! (so long as it is installed)
# FUN FACT: dplyr automatically loads in dbplyr when it sees you working with a database
# in this case, when it sees us setting up a database connection using dbConnect() below

# set working directory to current folder
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# create SQLite database connection
db_conn <- DBI::dbConnect(RSQLite::SQLite(), "rladies_march24.db")

# check the tables present within this database
dbListTables(db_conn)

# create a tbl object for each table within the database
listens <- tbl(db_conn, sql("listens"))
songs <- tbl(db_conn, sql("songs"))

# filter to only include songs by David Bowie
ongs %>% 
  inner_join(listens) %>% 
  select(song_name, artist_name, album_name, timestamp) %>% 
  filter(artist_name == "David Bowie") %>% 
  arrange(-timestamp) %>% 
  head(n = 100)

# create a table with only my listens to David Bowie
bowie_songs_ft <- songs %>% 
  inner_join(listens) %>% 
  select(song_name, artist_name, album_name, timestamp) %>% 
  filter(artist_name == "David Bowie") %>% 
  collect() # collect() function forces the database to return the full data, 
  # rather than 'lazily' running the query

  
# show my most-listened Bowie songs of all time
bowie_songs_ft %>% 
  count(song_name, sort = TRUE)
# TODO: find a way to tidy remasters: remove everything after hyphen IF song_name contains Remaster

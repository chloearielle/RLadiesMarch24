# load required packages
library(tidyverse)
library(RSQLite)
library(DBI)
# library(dbplyr) # DON'T NEED TO LOAD DBPLYR IN!! (so long as it is installed)
# FUN FACT: dplyr automatically loads in dbplyr when it sees you working with a database
# in this case, when it sees us setting up a database connection using dbConnect() below

# set working directory to current folder
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# create SQLite database connection
db_conn <- DBI::dbConnect(RSQLite::SQLite(), "rladies_march24.db")

# check the tables present within this database
dbListTables(db_conn)


############## USING DPLYR ############## 
# create a tbl object for each table within the database
listens <- tbl(db_conn, sql("listens"))
songs <- tbl(db_conn, sql("songs"))


# filter the dataset to only include songs by David Bowie
songs %>% 
  inner_join(listens) %>% 
  select(song_name, artist_name, album_name, timestamp) %>% 
  filter(artist_name == "David Bowie") %>% 
  arrange(-timestamp) %>% 
  head(n = 100)


# show my most-listened Bowie songs of all time
songs %>% 
  inner_join(listens) %>% 
  filter(artist_name == "David Bowie") %>% 
  count(song_name, sort = TRUE) # %>% # TODO: test this query with and without collect() at end
# collect() # collect() function forces the database to return the full data, 
# rather than 'lazily' running the query

# use the show_query() function from dplyr package
# to show how the dplyr translates into SQL
songs %>% 
  inner_join(listens) %>% 
  filter(artist_name == "David Bowie") %>% 
  count(song_name, sort = TRUE) %>% 
  show_query()


############## USING SQL ############## 
# picking out min and max timestamp of Australia listens
dbGetQuery(db_conn, "
  SELECT min(timestamp), max(timestamp)
  FROM listens l
  WHERE conn_country = 'AU';
")



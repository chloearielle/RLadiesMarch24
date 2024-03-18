# load required packages
library(dplyr)
# library(dbplyr) # DON'T NEED TO LOAD DBPLYR IN!! (so long as it is installed)
# FUN FACT: dplyr automatically loads in dbplyr when it sees you working with a database
# in this case, when it sees us setting up a database connection using dbConnect() below
library(RSQLite)
library(ggplot2)

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
bowie_songs_ft <- songs %>% 
  inner_join(listens) %>% 
  select(song_name, artist_name, album_name, timestamp) %>% 
  filter(artist_name == "David Bowie") %>% 
  arrange(-timestamp) %>% 
  head(n = 100) %>% 
  collect() # collect() function forces the database to return the full data, 
            # rather than 'lazily' running the query

  
# show my most-listened Bowie songs of all time
bowie_songs_ft %>% 
  count(song_name, sort = TRUE)
# TODO: find a way to tidy remasters: remove everything after hyphen IF song_name contains Remaster

# show my most-listened Bowie songs of all time
bowie_songs_ft %>% 
  count(album_name, sort = TRUE) %>% 
  print(n = 107)

# when was I listening to A New Career In A New Town??
bowie_songs_ft %>% 
  filter(album_name == "A New Career in a New Town (1977 - 1982)") %>% 
  count(song_name, sort = TRUE)

# can i convt timestamp to date
listens$timestamp <- as.Date(listens$timestamp) 

summary(listens)

# plot how my use of shuffle changed over time
# filter songs where shuffle = y
shuffled <- listens %>% 
  filter(shuffle == TRUE) %>% 
  collect()

shuffled %>% 
  ggplot(aes(x = timestamp)) +
    geom_histogram()

# vs the SQL
# SELECT timestamp, song_name, artist_name # the SELECT statement is where we pick the columns
#   FROM listens                    # the FROM statement specifies the table we are working with
# WHERE artist_name = 'David Bowie'        # the WHERE statement is used to filter rows based on condition(s)


# IMPORTANT TOPICS TO COVER
  # show_query() function to show how the dplyr translates into SQL
  # then PASTE THAT SQL into DB explorer to show how it works in SQL








listens <- dbGetQuery(db_conn, "SELECT * FROM listens")

# lazyness: make sure to retrieve all query results from database
# add COLLECT function at end of pipe

result <-
  listens %>% 
  filter(weight < 5) %>% 
  select(species_id, sex, weight) %>% 
  collect()

dim(result)
result[1,]


plots <- tbl(db_conn, "plots")
plots
listens



# join plots and listens
joined_ps <- 
  plots %>% 
  inner_join(listens) %>% 
  collect()


head(joined_ps)
head(plots)
head(listens)





plots_df <- plots %>% 
  filter(plot_id == 1) %>% 
  inner_join(listens) %>% 
  collect() # this pulls up ALL of the rows from a database (without this you get ?? rows)

plots_df_avg <- plots_df %>% 
  group_by(species_id, year) %>% 
  summarise(avg_weight = mean(weight, na.rm = TRUE))


ggplot(plots_df_avg, aes(x = year, y = avg_weight, color = species_id)) +
  geom_line()


# grouping by year only
plots_df_avg <- plots_df %>% 
  group_by(year) %>% 
  summarise(avg_weight = mean(weight, na.rm = TRUE))


ggplot(plots_df_avg, aes(x = year, y = avg_weight)) +
  geom_line()






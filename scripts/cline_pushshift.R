library(tidyverse)
library(tidyselect)
library(httr)
library(jsonlite)

# Helper functions

## Submissions

subred_submissions <- function(subreddit, start_time, end_time, n_comm, day_int = 7){
  
  epo_start_time <- as.numeric(as.POSIXct(start_time))
  epo_end_time <- as.numeric(as.POSIXct(end_time))
  epo_int = as.numeric(day_int)*24*60*60
  
  after_vec <- seq(epo_start_time, epo_end_time, by = epo_int)
  
  print(paste("Getting submissions for subreddit: ", subreddit, sep = ''))
  
  print(paste("Loops to run: ", as.character(length(after_vec))), sep = '')
  
  subred_tbl_map <- map_dfr(after_vec, ~ subred_sub_int(subreddit, .x, .x+epo_int-1, n_comm))
  
  return(subred_tbl_map)
}

subred_sub_int <- function(subreddit, start_time, end_time, n_comm){
  
  start_time_char <- as.character(start_time)
  end_time_char <- as.character(end_time)
  
  print(paste("Start time:",start_time_char, "; End time:", end_time_char, sep = " "))
  
  get_url <-  paste(ps_sub_base_url,"?size=1000",
                    "&after=", start_time_char,
                    "&before=", end_time_char,
                    "&subreddit=",subreddit,
                    "&num_comments=>",as.character(n_comm),
                    #"&metadata=True",
                    sep = '')
  Sys.sleep(0.5)
  
  get_tbl <- GET(url = get_url) %>% 
    content(as = 'parsed', type = "application/json") %>% 
    as_tibble() %>%
    unnest_wider(data)
  
  return(get_tbl)
}

## Comments



# Inputs

subred_cargs <- commandArgs(trailingOnly = TRUE)
subreddit <- subred_cargs[1]
day_int <- subred_cargs[2]

ps_sub_base_url <- "https://api.pushshift.io/reddit/search/submission/"

start_time <- "2016-11-08 00:00:00"
end_time <- "2019-11-08 00:00:00"

# Execution

sub_df <- subred_submissions(subreddit, start_time, end_time, 10, day_int)



# Write Output

write_rds(sub_df, paste(paste(paste("data/submissions/",subreddit, sep =''),
                    as.character(as.POSIXct(start_time)),
                    as.character(as.POSIXct(end_time)),sep = '-'), ".gz", sep=''),
          compress = "gz")




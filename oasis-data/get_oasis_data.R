library(readxl); library(tidyverse)

health_districts <- read_csv("ga_dph_districts_counties.csv")

get_oasis_data <- function() {
  parse_data_oasis_county_year <- function(filename, folder_path) {
    df1 <- read_excel(paste0(folder_path, filename))
    df2 <- df1[3:161,1:20]
    names(df2) <- as.character(c("county",1999:2017))
    return(df2 %>% gather(year, value, `1999`:`2017`) %>% 
             mutate(age = str_extract(filename, "(?<=age )\\d{1,2}-\\d{1,2}"),
                    value = as.integer(parse_number(value)),
                    year = as.integer(year)))
  }
  filename_vec_all_opioids <- list.files("./oasis-data/deaths - all opioids")
  data_list_all_opioid <- vector(mode = "list", length = length(filename_vec_all_opioids))
  filename_vec_population <- list.files("./oasis-data/population")
  data_list_population <- vector(mode = "list", length = length(filename_vec_population))
  for(i in seq_along(filename_vec_all_opioids)) {
    cat(i, " ")
    data_list_all_opioid[[i]] <- 
      parse_data_oasis_county_year(filename_vec_all_opioids[i], 
                                   folder_path = "./oasis-data/deaths - all opioids/") %>%
      rename(deaths = value)
    data_list_population[[i]] <- 
      parse_data_oasis_county_year(filename_vec_population[i],
                                   folder_path = "./oasis-data/population/") %>%
      rename(population = value)
  }
  data_all_opioid <- bind_rows(data_list_all_opioid)
  data_population <- bind_rows(data_list_population)
  
  county_age_data <- data_all_opioid %>% 
    left_join(data_population, by = c("county", "year", "age")) %>% 
    left_join(health_districts, by = "county") %>% 
    mutate(death_rate = deaths / population) %>% 
    select(county, district_id, district_name, district_office_flag, age, year, 
           population, deaths, death_rate)
  
  return(county_age_data)
}

county_age_data <- get_oasis_data()

write_csv(county_age_data, "oasis-data/oasis-opioid-data.csv")

# p <- county_age_data %>% group_by(year, district_name) %>% summarise(death_rate = 100000 * sum(deaths) / sum(population)) %>% ggplot() + geom_point(aes(year, death_rate, color = district_name)) + geom_smooth(aes(year, death_rate, group = district_name, color = district_name), se = F, span = .5) + labs(title = "Georgia: Death Rate from Opioid Overdose, by Health District", caption = "Data Source: GA DPH OASIS system, Drug Overdose - Cause = All Opioids (death rate calculation: 100,000 * opioid deaths / population)") + scale_x_continuous(breaks = 1999:2017, minor_breaks = F)
# p
# ggsave(filename = "death_rate_opioid_overdose.pdf", width = 11, height = 8.5)
# plotly::ggplotly(p)

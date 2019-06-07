## Get data from DEA Diversion Control Division: Automation of Reports and Consolidated Orders System (ARCOS)
## Overall program flow: Read text from PDF using R package pdftools, then 
##  parse through the data to extract drug names and quarterly distribution by 3 digit zip

library(tidyverse); library(pdftools)

# Reference: https://www.deadiversion.usdoj.gov/arcos/

get_dea_diversion <- function(year) {
  url <- paste0("https://www.deadiversion.usdoj.gov/arcos/retail_drug_summary/report_yr_", year, ".pdf")
  cat("    Getting pdf text", "\n")
  temp <- pdftools::pdf_text(url)
  cat("    Finished getting pdf text", "\n")
  
  temp2 <- map(temp, ~str_split(., "\\n"))
  temp3 <- unlist(temp2)
  
  drug_name_linenums <- which(str_detect(temp3, "DRUG NAME"))
  drug_line_text <- temp3[drug_name_linenums]
  drug_names <- str_extract(temp3[drug_name_linenums], "(?<= ?DRUG NAME:).+")
  drug_codes <- str_extract(temp3[drug_name_linenums], "(?<= ?DRUG CODE: {0,100})\\d{4}[A-Z]?")
  
  data_linenums <- which(str_detect(temp3, "^ {4,}\\d{1,3}( +[0-9\\.,]+){5}$"))
  data_raw <- temp3[data_linenums]
  
  parse_zip_values <- function(x) {
    # x is a line of text with format: ^ {4,}\\d{1,3}(__number){5}$
    x <- str_replace(x, "^ {4,}", "")
    x <- str_split(x, " +")[[1]]
    if(length(x) != 6L) {
      stop("parse error")
    } else {
      return(x)
    }
  }
  
  # data_parsed is a list where each element is a character vector of the split values
  data_parsed <- map(data_raw, parse_zip_values)
  # collect data into tibble, and format zip as ###; parse numeric gram values
  cat("    Starting data_parsed_df", "\n")
  data_parsed_df <- map_df(data_parsed, ~(tibble(zip = str_pad(.[1], width = 3, pad = "0"),
                                                 q1 = .[2], q2 = .[3], q3 = .[4], q4 = .[5], total = .[6]))) %>%
    mutate_at(vars(q1, q2, q3, q4, total), funs(parse_number)) %>%
    mutate(linenum = data_linenums)
  cat("    Finished data_parsed_df", "\n")
  
  # for each data_linenums, figure out which drug is associated w/ it
  # example: drug 1100 - AMPHETAMINE (1st line)
  zipcode_end_line <- min(which(str_detect(temp3, "ARCOS 3 - REPORT 2")))
  drug_index <- tibble(drug_name = drug_names, 
                       drug_code = drug_codes,
                       start_line = drug_name_linenums, 
                       end_line = lead(drug_name_linenums) - 1)
  drug_index2 <- drug_index %>% filter(start_line <= zipcode_end_line) %>% 
    mutate(drug_name = str_trim(drug_name)) %>%
    group_by(drug_code, drug_name) %>% 
    summarise(start_line = min(start_line), end_line = max(end_line)) %>%
    ungroup() %>%
    arrange(start_line) %>%
    mutate(line_index = map2(start_line, end_line, ~seq.int(from = .x, to = .y, by = 1L)))
  drug_index3 <- unnest(drug_index2)
  
  final_df <- data_parsed_df %>% left_join(drug_index3, by = c("linenum" = "line_index")) %>%
    select(-start_line, -end_line) %>%
    mutate(year = year) %>%
    group_by(year, drug_code, drug_name, zip) %>%
    summarise(q1 = sum(q1), q2 = sum(q2), q3 = sum(q3), q4 = sum(q4), total = sum(total),
              linenum_min = min(linenum), linenum_max = max(linenum))
  
  return(list(raw_text = temp3, parsed_data = final_df))
}

data_2016 <- get_dea_diversion(2016)
data_2017 <- get_dea_diversion(2017)

write_csv(bind_rows(data_2016$parsed_data, data_2017$parsed_data) %>% 
            select(-linenum_min, -linenum_max), 
          "dea-retail-drug-distribution/dea-retail-drug-distribution.csv")

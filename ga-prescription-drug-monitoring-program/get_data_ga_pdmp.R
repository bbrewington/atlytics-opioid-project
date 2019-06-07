library(tidyverse)

get_pdmp_data <- function(url) {
  data_raw <- pdftools::pdf_text(url)
  data_raw2 <- unlist(map(data_raw[9:13], ~str_split(., "\\n")))[14:176] %>%
    str_replace("Ben Hill", "BenHill")
  
  data_parsed <- 
    map_df(str_split(str_trim(data_raw2)," +"),
           ~tibble(county = .[1], 
                   opioid_prescp_per_1000_pop = .[2],
                   avg_days_per_opioid_prescp = .[3],
                   pct_patient_days_with_overlapping_opioid_prescp = .[4],
                   pct_patient_days_with_overlapping_opioid_and_benzo_prescp = .[5]
           )) %>% filter(county != "") %>%
    mutate_at(vars(2:5), funs(parse_number))
  
  return(data_parsed)
}

pdmp_data_county <- get_pdmp_data("https://dph.georgia.gov/sites/dph.georgia.gov/files/PDMP%20county%20level%20data.pdf")

write_csv(pdmp_data_county, "ga-prescription-drug-monitoring-program/ga_pdmp_metrics_bycounty.csv")

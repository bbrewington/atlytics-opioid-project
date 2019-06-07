# atlytics-opioid-project
Code and data for use in ATLytics project "Illustrating Opioid Addiction"

#### Data Sources

* **oasis-data**
    - **Source**: Manually downloaded files from OASIS portal https://oasis.state.ga.us/oasis/webquery/qryDrugOverdose.aspx
        - Parameters
            - Age
                - 0-9 years: <1 year, 1-4 years, 5-9 years
                - Other age buckets were downloaded one at a time (5 year increments), from "10-14 years" to "85+ years"
            - Geography: selected Rural & Non-Rural to return all counties
            - Race: All Races
            - Ethnicity: All Ethnicities
            - Sex: All Sexes
    - **Dataset Description**: Oasis Opioid Deaths, Population, Death Rate by County/Year.  On some reports by GA DPH, rates involving a count of < 4 are flagged as N/A.  This was not done in this report - derived death rate from deaths & population in these files.
    - **Fields**
        - county
        - district_id
        - district_name
        - district_office_flag
        - age
        - year
        - population
        - deaths
        - death_rate: calculation: deaths / population
            - NOTE: sometimes, rates are scaled (for ease of reading) as count per 100,000 population.  In this case, it is the actual non-scaled rate

* **dea-retail-drug-distribution**
    - **Source File(s)**
        - https://www.deadiversion.usdoj.gov/arcos/retail_drug_summary/report_yr_2016.pdf
        - https://www.deadiversion.usdoj.gov/arcos/retail_drug_summary/report_yr_2017.pdf
    - **Dataset description**: Automated Reports and Consolidated Ordering System (ARCOS) is a data collection system in which manufacturers and distributors report their controlled substances transactions to the Drug Enforcement Administration (DEA). ARCOS provides an acquisition/distribution transactional records of applicable activities to the DEA involving certain controlled substances
    - **Fields**
        - year
        - drug_code
        - drug_name
        - zip (3 digit)
        - distributed mass in grams: q1, q2, q3, q4, total

* **ga-prescription-drug-monitoring-program**
    - **Source File(s)**: https://dph.georgia.gov/sites/dph.georgia.gov/files/PDMP%20county%20level%20data.pdf
    - **Dataset Description**: Prescription data from the Georgia Prescription Drug Monitoring
Program (PDMP) were analyzed by the Georgia Department of Public Health (DPH) Epidemiology Program Drug Overdose Surveillance Unit.  Certain prescribing practices are considered high-risk, and may predispose patients to opioid use disorder and overdose, hence contributing to the growing opioid epidemic. These prescribing practices are presented as PDMP indicators in this document; detailed analyses of the PDMP data were conducted to measure the total number of opioid prescriptions, number of patients receiving opioids, drug type, days dispensed, and other indicators of prescribing such as overlapping opioid or opioid and benzodiazepine prescriptions.
    - **Fields** 
        - county
        - opioid_prescp_per_1000_pop
        - avg_days_per_opioid_prescp
        - pct_patient_days_with_overlapping_opioid_prescp
        - pct_patient_days_with_overlapping_opioid_and_benzo_prescp
    - **Definitions**: 
        - **Opioid Prescription**: Opioid analgesic controlled substance prescriptions dispensed and reported to the PDMP. Drugs administered to patients by substance abuse treatment programs are usually excluded from PDMP files and therefore are not captured by this indicator. Additional exclusion criteria include: (1) drugs not typically used in outpatient settings or otherwise not critical for calculating dosages in morphine milligram equivalents (MME), such as cough and cold formulations including elixirs, and combination products containing antitussives, decongestants, antihistamines, and expectorants; (2) all buprenorphine products. Rate is calculated per 1,000 population (Georgia residents).
        - **Opioid prescription patients**: The number of individual patients receiving an opioid analgesic controlled substance prescription that was dispensed and reported to the PDMP. Rate is calculated per 1,000 population
(Georgia residents).
        - **Patient days with overlapping opioid prescription**: % of days that patients had more than one prescribed opioid prescription on the same day.
            - Numerator: total number of days any patient had more than one opioid prescription
            - Denominator: total number of opioid prescription days for state residents in the state PDMP. A prescribed day with overlapping opioid prescriptions (≥2) is only counted as one
prescribed opioid day
        - **Patient days with overlapping opioid and benzodiazepine prescription**: % of days that patients had an opioid and benzodiazepine prescription on the same day
            - Numerator: total number of days any patient had an opioid and benzodiazepine prescription on the same day
            - Denominator: total number of opioid prescription days for state residents in the state PDMP. A prescribed day with overlapping opioid prescriptions (≥2) is only counted as one
prescribed opioid day

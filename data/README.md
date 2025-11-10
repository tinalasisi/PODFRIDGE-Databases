# Data Dictionary

This folder contains four primary datasets documenting U.S. forensic DNA databases. All datasets are versioned and archived on Zenodo (DOI: [10.5281/zenodo.17215677](https://doi.org/10.5281/zenodo.17215677)) including the raw, intermediate and final files. Below we will discuss only the versioned processed data in the `versioned_data` subfolder. The process for getting to these final files is described in each analysis file that generates the processed data from the raw (see `analysis/` subfolder).

---

## Subfolder Descriptions

- `ndis/`: Contains raw and intermediate data files related to the National DNA Index System (NDIS), including archived FBI webpages and extracted statistics used to build the time series dataset.

- `sdis/`: Includes raw data and notes from state DNA index systems (SDIS) collected through web searches, legislative databases, and state government sources.

- `ndis_crossref/`: Holds cross-referencing files for NDIS data, such as jurisdiction name standardizations and mappings between various data sources.

- `annual_dna_collection/`: Houses data and metadata from Murphy & Tong (2020) Appendix, detailing annual DNA profile collection estimates by race for all 50 states. Users should cite *Murphy, E., & Tong, J. (2020). The racial composition of forensic DNA databases. California Law Review.* when utilizing this data.

- `foia/`: Contains data obtained via FOIA requests and analyzed in Murphy & Tong (2020), documenting demographic composition and policy information from seven states. Users should cite *Murphy, E., & Tong, J. (2020). The racial composition of forensic DNA databases. California Law Review.* when using these files.

- `versioned_data/`: Contains the finalized, versioned datasets ready for analysis, including cleaned and processed files like `NDIS_time_series.csv` and `SDIS_cross_section.csv`.


## Finalized Dataset Overview (`versioned_data/`)

| Dataset | Rows | Time Coverage | Spatial Coverage | Source |
|---------|------|---------------|------------------|--------|
| `NDIS_time_series.csv` | 9,442 | 2001-2025 | 54 jurisdictions | FBI CODIS-NDIS Statistics (Wayback Machine Internet Archive) |
| `SDIS_cross_section.csv` | 50 | 1997-2017 | 50 states | Web Searches |
| `FOIA_demographics.csv` | 202 | 2018 | 7 states | Murphy & Tong (2020) |
| `Annual_DNA_Collection.csv` | 50 | 1997-2017 | 50 states | Murphy & Tong (2020) Appendix |

---

## 1. NDIS_time_series.csv

**Description:** Monthly time series of National DNA Index System (NDIS) statistics reconstructed from archived FBI webpages.

**Source:** FBI CODIS-NDIS Statistics pages, accessed via Internet Archive Wayback Machine  
**Temporal Coverage:** July 2001 - July 2025  
**Spatial Coverage:** 54 jurisdictions (50 states + DC + FBI Lab + US Army + Puerto Rico)  

### Column Definitions

| Column | Type | Description | Format/Units | Notes |
|--------|------|-------------|--------------|-------|
| `jurisdiction` | character | Name of reporting jurisdiction | Standardized state/territory names | Includes 50 states, DC, and federal entities (FBI Lab, US Army) |
| `year_month` | character | Report date from wayback machine timestamp (before 2007) and webpage "as of" statement (after 2007) | YYYY-MM-DD (first day of month) | Parsed from FBI webpage; distinct from capture date |
| `offender_profiles` | integer | Cumulative count of offender profiles in NDIS | Count | Includes convicted offenders; monotonically increasing |
| `arrestee` | integer | Cumulative count of arrestee profiles in NDIS | Count | Only available 2012+; NA for earlier periods |
| `forensic_profiles` | integer | Cumulative count of forensic (crime scene) profiles | Count | Monotonically increasing |
| `investigations_aided` | integer | Cumulative investigations aided by CODIS | Count | "Hits" that led to investigative leads |
| `ndis_labs` | integer | Number of participating NDIS laboratories | Count | Can increase or decrease as labs join/leave |

**Missing Data Patterns:**
- `arrestee`: NA for all records before 2012 (not collected)
- Some jurisdictions have intermittent reporting gaps

**Data Quality Notes:**
- Outliers and monotonicity violations detected have been flagged and corrected
- Original uncorrected data available in `intermediate/` folder

**Recommended Use:**
- Time series analysis of DNA database growth
- Jurisdictional comparisons over time
- Policy impact analysis (e.g., 2017 CODIS expansion to 20 loci)

---

## 2. SDIS_cross_section.csv

**Description:** Cross-sectional snapshot of state DNA index system (SDIS) statistics and policies as of 2025.

**Source:** State government websites, department of justice sites, legislative databases  
**Temporal Coverage:** 2018 (FOIA responses received)
**Spatial Coverage:** 50 U.S. states  

### Column Definitions

| Column | Type | Description | Format/Units | Notes |
|--------|------|-------------|--------------|-------|
| `state` | character | State name | Full state names | Alphabetical order |
| `n_total_estimated` | integer | Total SDIS profiles (estimated if not reported) | Count | May include imputations where only subtotals available |
| `n_total_reported` | integer | Total SDIS profiles as directly reported by state | Count | NA if state did not report aggregate total |
| `n_total_estimated_comment` | character | Explanation of estimation method | Free text | Documents calculation or data limitations |
| `total_method` | character | Method used to derive total | Categorical | "Offenders + Arrestees", "Unknown", etc. |
| `n_arrestees` | integer | Count of arrestee profiles | Count | NA if not reported separately |
| `n_offenders` | integer | Count of offender profiles | Count | NA if not reported separately |
| `n_forensic` | integer | Count of forensic profiles | Count | NA if not reported separately |
| `arrestee_collection` | character | Whether state collects DNA from arrestees | "yes", "no", "unspecified" | Based on statute review |
| `fam_search` | character | Familial search policy | "permitted", "prohibited", "unspecified" | Based on statute/policy review |
| `collection_statute` | character | Primary DNA collection statute citation | Legal citation format | State code reference |

**Missing Data Patterns:**
- `n_total_estimated` may differ from `n_total_reported` when subtotals are summed
- Profile counts highly variable in completeness across states

**Data Quality Notes:**
- Not all states have SDIS-level statistics
- Where totals are "estimated", see `n_total_estimated_comment` for methodology

**Recommended Use:**
- Cross-state policy comparisons
- Database size comparisons
- Identifying states with detailed public reporting

---

## 3. FOIA_demographics.csv

**Description:** Demographic composition (race/gender) of state DNA databases from FOIA responses documented in Murphy & Tong (2020).

**Source:** Murphy & Tong (2020) - FOIA responses from state agencies  
**Temporal Coverage:** Statutes from 1996-2017, arrest sources from 2009-2016
**Spatial Coverage:** 7 states (California, Florida, Louisiana, Maryland, North Carolina, South Carolina, Wisconsin)  

### Column Definitions

| Column | Type | Description | Format/Units | Notes |
|--------|------|-------------|--------------|-------|
| `state` | character | State name | Full state name | Only 7 states responded to FOIA |
| `offender_type` | character | Type of profile | "Convicted Offender", "Arrestee", "Forensic", etc. | As categorized by reporting agency |
| `variable_category` | character | High-level demographic category | "total", "gender", "race", "ethnicity" | Hierarchical grouping |
| `variable_detailed` | character | Specific demographic variable | e.g., "Male", "Female", "Black", "White", "Hispanic" | As reported by state agency |
| `value` | numeric | Count or percentage | Count or percentage | See `value_type` |
| `value_type` | character | Type of value reported | "count", "percentage", "rate" | Units for `value` column |
| `value_source` | character | Provenance of value | "reported", "calculated" | Whether directly reported by agency or derived |

**Missing Data Patterns:**
- Only 7 of 50 states responded to FOIA requests
- Racial/ethnic categories vary by state (not standardized)
- Some states provided percentages only, others counts

**Data Quality Notes:**
- Categories reflect state agency terminology (not standardized across states)
- Some values are calculated from provided data (see `value_source`)
- Years of data collection vary by state
- This data represents demographic composition at time of FOIA response, not current

**Recommended Use:**
- Demographic disparity analysis
- Comparison with general population demographics
- Understanding variation in state reporting practices

---

## 4. Annual_DNA_Collection.csv

**Description:** Annual DNA profile collection estimates by race, combined with policy metadata, as compiled by Murphy & Tong (2020).

**Source:** Murphy & Tong (2020) Appendix - derived from FOIA responses, 2010 Census data, and state reports
**Temporal Coverage:** ?
**Spatial Coverage:** All 50 U.S. states  

### Column Definitions

| Column | Type | Description | Format/Units | Notes |
|--------|------|-------------|--------------|-------|
| `state` | character | State name | Full state name | All 50 states |
| `state_abbrev` | character | State abbreviation | Two-letter code | Standard USPS abbreviations |
| `Black_DNA_Pct` | numeric | Percentage of DNA profiles from Black individuals | Percentage (0-100) | Murphy & Tong calculation |
| `Black_DNA_N` | integer | Count of DNA profiles from Black individuals | Count | Estimated or reported |
| `Hispanic_DNA_Pct` | numeric | Percentage of DNA profiles from Hispanic individuals | Percentage (0-100) | Murphy & Tong calculation |
| `Hispanic_DNA_N` | integer | Count of DNA profiles from Hispanic individuals | Count | Estimated or reported |
| `Asian_DNA_Pct` | numeric | Percentage of DNA profiles from Asian individuals | Percentage (0-100) | Murphy & Tong calculation |
| `Asian_DNA_N` | integer | Count of DNA profiles from Asian individuals | Count | Estimated or reported |
| `Native_American_DNA_Pct` | numeric | Percentage of DNA profiles from Native American individuals | Percentage (0-100) | Murphy & Tong calculation |
| `Native_American_DNA_N` | integer | Count of DNA profiles from Native American individuals | Count | Estimated or reported |
| `White_DNA_Pct` | numeric | Percentage of DNA profiles from White individuals | Percentage (0-100) | Murphy & Tong calculation |
| `White_DNA_N` | integer | Count of DNA profiles from White individuals | Count | Estimated or reported |
| `Total_DNA_Profiles` | integer | Total DNA profiles in database | Count | Sum of racial/ethnic categories |
| `Black_Pop_Pct` | numeric | Black population percentage from Census | Percentage (0-100) | U.S. Census data |
| `Hispanic_Pop_Pct` | numeric | Hispanic population percentage from Census | Percentage (0-100) | U.S. Census data |
| `Asian_Pop_Pct` | numeric | Asian population percentage from Census | Percentage (0-100) | U.S. Census data |
| `Native_American_Pop_Pct` | numeric | Native American population percentage from Census | Percentage (0-100) | U.S. Census data |
| `White_Pop_Pct` | numeric | White population percentage from Census | Percentage (0-100) | U.S. Census data |
| `Black_Collection_Rate` | numeric | Annual DNA collection rate for Black individuals | Rate per 1,000 population | Murphy & Tong calculation |
| `Hispanic_Collection_Rate` | numeric | Annual DNA collection rate for Hispanic individuals | Rate per 1,000 population | Murphy & Tong calculation |
| `Asian_Collection_Rate` | numeric | Annual DNA collection rate for Asian individuals | Rate per 1,000 population | Murphy & Tong calculation |
| `Native_American_Collection_Rate` | numeric | Annual DNA collection rate for Native American individuals | Rate per 1,000 population | Murphy & Tong calculation |
| `White_Collection_Rate` | numeric | Annual DNA collection rate for White individuals | Rate per 1,000 population | Murphy & Tong calculation |
| `legal_framework` | character | Primary DNA collection statute | Legal citation | State code reference |
| `collection_triggers` | character | Events that trigger DNA collection | Free text description | Arrests, convictions, specific offenses |
| `collection_trigger_category` | character | Categorization of collection scope | Categorical | e.g., "Comprehensive: All felonies + broad arrests" |
| `data_limitations` | character | Known data limitations for that state | Free text | Documents missing data, estimation methods |
| `data_limitation_category` | character | Categorized data limitation | Categorical | e.g., "Missing conviction data" |
| `source_url` | character | Source URLs for data | URLs | State reports, DOC websites |

**Missing Data Patterns:**
- Many states have NA values for specific racial/ethnic categories
- Collection rates may be NA where population or profile data unavailable
- Legal framework details only available for states analyzed in detail by Murphy & Tong

**Data Quality Notes:**
- Collection rates represent annual additions, not total database size
- Racial/ethnic categories may not align perfectly across states due to reporting differences

**Recommended Use:**
- Comparative analysis of DNA collection rates across states and demographics
- Disparate impact analysis
- Policy framework comparisons
- Must account for varying data quality and estimation methods by state


**Last updated:** 2025-11-09
**Zenodo DOI:** [10.5281/zenodo.17215677](https://doi.org/10.5281/zenodo.17215677)

# PODFRIDGE - U.S. Forensic DNA Database

**Website:** [https://lasisilab.github.io/PODFRIDGE-Databases/](https://lasisilab.github.io/PODFRIDGE-Databases/)

## Overview

This repository is part of the *PODFRIDGE* project — **P**opulation **D**ifferences in **F**orensic **R**elative **I**dentification via **G**enetic **G**enealogy. The first phase focuses on consolidating authoritative information about where and how DNA profiles are stored in U.S. databases so later modeling can plug in realistic availability assumptions.

## Associated Publication

This dataset is described in:

**Pryor, Y.; Donadio, J. P.; Muller, S.C.; Wilson, J.; Lasisi, T.** (2025). National and state-level datasets of United States forensic DNA databases 2001–2025. arXiv preprint. [DOI to be added upon publication]

**Dataset DOI:** [To be added]

## Getting Started

If you just want to get a quick overview of the data and analyses, you can view the rendered website hosted on GitHub Pages: https://lasisilab.github.io/PODFRIDGE-Databases/

If you want to run the code locally or contribute, follow the setup instructions below.

### Prerequisites
- **R** ≥ 4.0 ([Download](https://cran.r-project.org/))
- **Python** ≥ 3.13 ([Download](https://www.python.org/downloads/))
- **Quarto** ≥ 1.3 ([Download](https://quarto.org/docs/get-started/))

### Quick Setup

```bash
# Clone the repository
git clone https://github.com/lasisilab/PODFRIDGE-Databases.git
cd PODFRIDGE-Databases

# Run automated setup (installs all dependencies)
bash setup/setup.sh

# Preview the website locally
quarto preview
```

### Manual Setup

If you prefer to install dependencies separately:

```bash
# Install Python packages (for web scraping and analyses)
pip install -r setup/requirements.txt

# Install R packages (for Quarto analyses)
Rscript setup/install.R

# Preview the website
quarto preview
```

### Troubleshooting

**CRAN mirror error:** The `install.R` script automatically sets the CRAN mirror. If you encounter issues, manually set it in R:
```r
options(repos = c(CRAN = "https://cloud.r-project.org/"))
```

**Package conflicts:** Ensure you're using compatible versions:
```bash
R --version        # Should be >= 4.0
python3 --version  # Should be >= 3.13
quarto --version   # Should be >= 1.3
```

## Project Components

### 1. NDIS Time Series Analysis (2001-2025)
Reconstructs the growth of the FBI's National DNA Index System using archived snapshots from the Internet Archive's Wayback Machine.

- **Data Source:** FBI CODIS-NDIS Statistics pages
- **Coverage:** Monthly snapshots from 2001-2025
- **Metrics:** Offender profiles, arrestee profiles, forensic profiles, participating laboratories, investigations aided
- **Methods:** Web scraping, HTML parsing, temporal validation, outlier detection

[View NDIS Scraping Methodology →](https://lasisilab.github.io/PODFRIDGE-Databases/qmd_root/ndis_scraping.html)

[View NDIS Analysis →](https://lasisilab.github.io/PODFRIDGE-Databases/qmd_root/ndis_analysis.html)

### 2. SDIS Cross-Sectional Summary (2025)
Compiles current state-level DNA database statistics and policy information across all 50 states and Washington D.C.

- **Data Source:** State government websites, legislative databases
- **Coverage:** Current snapshot (August 2025)
- **Content:** Profile counts by type (where available), arrestee collection policies, familial search authorization, statutory citations
- **Methods:** Systematic web searches, policy documentation, legal statute review

[View SDIS Analysis →](https://lasisilab.github.io/PODFRIDGE-Databases/qmd_root/sdis_summary.html)

### 3. FOIA Demographic Data Processing
Standardizes demographic composition data from state DNA databases obtained through public records requests documented in Murphy & Tong (2020).

- **Data Source:** FOIA responses from 7 states (Murphy & Tong, 2020, Appendix A)
- **Coverage:** ~2018 
- **Content:** Racial and gender composition by profile type (offender/arrestee/forensic)
- **Methods:** OCR processing, data standardization, quality validation

[View FOIA Analysis →](https://lasisilab.github.io/PODFRIDGE-Databases/qmd_root/foia_processing.html)

### 4. Annual DNA Collection Methodology
Documents the methodology and data sources used in Murphy & Tong (2020) for calculating annual DNA collection rates by race.

- **Data Source:** Murphy & Tong (2020, Appendix B)
- **Coverage:** All 50 states
- **Content:** Annual collection estimates, Census demographics, calculated collection rates by race
- **Methods:** Data provenance tracking, methodology documentation

[View Methodology →](https://lasisilab.github.io/PODFRIDGE-Databases/qmd_root/appendix_analysis.html)

## Repository Structure 

- `analysis/` – Quarto notebooks (NDIS, SDIS, FOIA, methodology, version freeze)
- `data/{annual_dna_collection, foia, ndis, ndis_crossref, sdis}` - various dataset types
  - `/raw/` – Raw inputs (Wayback HTML snapshots, FOIA PDFs, etc.)
  - `/intermediate/` – Staging outputs produced during processing
  - `/final/` – Latest cleaned datasets for each component
- `data/versioned_data/` – Snapshots of final processed datasets created via `analysis/version_freeze.qmd`
- `setup/` – Setup scripts to run code (`setup.sh`, `install.R`, Python requirements)
- `docs/` – Rendered website for GitHub Pages
- `_freeze` - caching some expensive computation for some of the analysis to simplify render
- `podfridge-db-env` - venv info for running python scripts fors craping

## Authors

- **Yemko Pryor** ([`@ypryor`](https://github.com/ypryor))
- **João Pedro Donadio** ([`@DonadioJP`](https://github.com/DonadioJP))
- **Sam Muller**
- **Jenna Wilson**
- **Tina Lasisi** ([`@lasisilab`](https://github.com/lasisilab))

## Technical Details

### Software Requirements

- Python (≥ 3.13)

- R (≥ 4.0)

- Quarto (≥ 1.3)

- Python packages: `requests`, `beautifulsoup4`, `lxml`, `pandas`, `tqdm`, `hashlib`, `collections`, `pathlib`, `datetime`, `os`

- R packages: `tidyverse`, `rvest`, `httr`, `lubridate`, `jsonlite`, `knitr`, `plotly`

### Key Methods

- **Web Scraping:** Internet Archive Wayback Machine API

- **Data Validation:** Monotonicity testing, median absolute deviation (MAD) outlier detection

- **External Validation:** Comparison with peer-reviewed publications and FBI press releases

- **Reproducibility:** All processing code available; versioned datasets archived on Zenodo

## Data Access

All final datasets are archived and publicly available on Zenodo:

**Zenodo Repository:** [DOI to be added upon publication]

The repository includes:
- `NDIS_time_series.csv` - Monthly NDIS statistics (2001-2025)
- `SDIS_cross_section.csv` - State-level profiles and policies
- `FOIA_Demographics.csv` - Demographic composition from FOIA responses (Murphy & Tong, 2020)
- `Annual_DNA_Collection.csv` - Annual collection rates (Murphy & Tong, 2020)
- Raw HTML files, intermediate processing outputs, and complete documentation

## License
Code: MIT License  
Data: CC BY 4.0 (pending Zenodo publication; FOIA-derived data subject to original authors' permissions)

Last update: November 09, 2025

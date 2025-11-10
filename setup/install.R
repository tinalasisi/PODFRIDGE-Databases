# R Package Installation Script for PODFRIDGE-Databases

# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org/"))

# Required R packages
required_packages <- c(
  "tidyverse",
  "rvest",
  "httr",
  "lubridate",
  "jsonlite",
  "knitr",
  "kableExtra",
  "plotly",
  "here",
  "rmarkdown",
  "quarto",
  "systemfonts",  # Required by flextable
  "flextable",
  "qualpalr"
)

# Install missing packages
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]

if(length(new_packages)) {
  cat("Installing", length(new_packages), "missing packages...\n")
  install.packages(new_packages, dependencies = TRUE)
}

# Verify installation
cat("\n=== Package Installation Summary ===\n")
for(pkg in required_packages) {
  status <- if(require(pkg, character.only = TRUE, quietly = TRUE)) "✓" else "✗"
  cat(status, pkg, "\n")
}

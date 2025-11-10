# Setup Directory

This directory contains all setup and installation scripts for the PODFRIDGE-Databases project.

## Files

### `setup.sh`
Automated setup script that installs all dependencies (Python and R packages).

**Usage:**
```bash
bash setup/setup.sh
```

### `requirements.txt`
Complete Python package dependencies for the project (generated from the virtual environment).

**Usage:**
```bash
pip install -r setup/requirements.txt
```

### `requirements-scraping.txt`
Minimal Python dependencies needed only for web scraping components.

**Usage:**
```bash
pip install -r setup/requirements-scraping.txt
```

### `install.R`
R package installation script for all required R packages.

**Usage:**
```bash
Rscript setup/install.R
```

## Quick Start

From the project root directory:

```bash
# Option 1: Automated (recommended)
bash setup/setup.sh

# Option 2: Manual Python setup
python3 -m venv podfridge-db-env
source podfridge-db-env/bin/activate  # On Windows: podfridge-db-env\Scripts\activate
pip install -r setup/requirements.txt

# Option 3: Manual R setup
Rscript setup/install.R
```

## Virtual Environment

The project uses a Python virtual environment located at `podfridge-db-env/` in the project root. This keeps dependencies isolated from your system Python installation.

**Activate the environment:**
```bash
# macOS/Linux
source podfridge-db-env/bin/activate

# Windows
podfridge-db-env\Scripts\activate
```

**Deactivate:**
```bash
deactivate
```

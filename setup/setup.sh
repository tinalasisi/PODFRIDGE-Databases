#!/bin/bash

echo "=== PODFRIDGE-Databases Setup ==="
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Check prerequisites
command -v R >/dev/null 2>&1 || { echo "Error: R is not installed. Please install R >= 4.0"; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "Error: Python is not installed. Please install Python >= 3.13"; exit 1; }
command -v quarto >/dev/null 2>&1 || { echo "Error: Quarto is not installed. Please install Quarto >= 1.3"; exit 1; }

echo "✓ Prerequisites found"
echo ""

# Install Python dependencies
echo "Installing Python dependencies..."
python3 -m pip install -r "$SCRIPT_DIR/requirements.txt"
echo ""

# Install R packages
echo "Installing R packages..."
Rscript "$SCRIPT_DIR/install.R"
echo ""

echo "=== Setup Complete ==="
echo "From project root, run: quarto preview"

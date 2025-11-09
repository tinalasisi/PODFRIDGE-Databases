#!/bin/bash

echo "=== PODFRIDGE-Databases Setup ==="
echo ""

# Check prerequisites
command -v R >/dev/null 2>&1 || { echo "Error: R is not installed. Please install R >= 4.0"; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "Error: Python is not installed. Please install Python >= 3.13"; exit 1; }
command -v quarto >/dev/null 2>&1 || { echo "Error: Quarto is not installed. Please install Quarto >= 1.3"; exit 1; }

echo "✓ Prerequisites found"
echo ""

# Install Python dependencies
echo "Installing Python dependencies..."
python3 -m pip install -r requirements.txt
echo ""

# Install R packages
echo "Installing R packages..."
Rscript install.R
echo ""

echo "=== Setup Complete ==="
echo "To preview the website, run: quarto preview"

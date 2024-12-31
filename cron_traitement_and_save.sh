#!/bin/bash

# Resolve the directory of the current script
BASE_DIR=$(dirname "$(realpath "$0")")

# Execute the Python script using the virtual environment
$BASE_DIR/venv/bin/python3 $BASE_DIR/test.traitementDonnes1.py 


#!/bin/bash

# Resolve the directory of the current script
BASE_DIR=$(dirname "$(realpath "$0")")

# Execute all scripts dynamically
$BASE_DIR/oil_price.sh
$BASE_DIR/usd_euro.sh
$BASE_DIR/commodite_prix.sh
$BASE_DIR/prix_or.sh
$BASE_DIR/traitement.sh

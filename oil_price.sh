#!/bin/bash

# Get the current date and hour in YYYY-MM-DD_HH format
CURRENT_TIMESTAMP=$(date +"%Y-%m-%d_%H:%M")

# Define API URL and headers
URL="https://finnhub.io/api/v1/quote?symbol=CL&token=ctanb79r01qrt5hi2rb0ctanb79r01qrt5hi2rbg"

# Create the directory if it doesn't exist
OUTPUT_DIR="/home/blm/Documents/linux_project_final/oil_price"
mkdir -p "$OUTPUT_DIR"

# Define file path with the current date and hour
FILE_PATH="$OUTPUT_DIR/oil_price_$CURRENT_TIMESTAMP.json"

# Make the GET request and save the response
/usr/bin/curl --request GET \
     --url "$URL" \
      > "$FILE_PATH"

echo "oil price saved to $FILE_PATH" >> /home/blm/Documents/linux_project_final/oil_price.log


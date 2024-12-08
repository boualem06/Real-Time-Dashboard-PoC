#!/bin/bash

# Get the current date and hour in YYYY-MM-DD_HH format
CURRENT_TIMESTAMP=$(date +"%Y-%m-%d_%H:%M")

# Define API URL and headers
URL="https://real-time-finance-data.p.rapidapi.com/currency-time-series?from_symbol=USD&to_symbol=EUR&period=1D&language=en"
HOST="x-rapidapi-host: real-time-finance-data.p.rapidapi.com"
KEY="x-rapidapi-key: d214f59563msh2656c98ebc79709p1d569fjsn0c06518876af"

# Create the directory if it doesn't exist
OUTPUT_DIR="/home/blm/Documents/linux_project_final/usd_to_euro"
mkdir -p "$OUTPUT_DIR"

# Define file path with the current date and hour
FILE_PATH="$OUTPUT_DIR/time_series_data_$CURRENT_TIMESTAMP.json"

# Make the GET request and save the response
/usr/bin/curl --request GET \
     --url "$URL" \
     --header "$HOST" \
     --header "$KEY" |
     jq '.data.time_series' > "$FILE_PATH"

echo "Time series data saved to $FILE_PATH" >>/home/blm/Documents/linux_project_final/usd_euro.log



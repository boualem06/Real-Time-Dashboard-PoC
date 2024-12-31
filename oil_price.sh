#!/bin/bash

# Get the current date and hour in YYYY-MM-DD_HH format
CURRENT_TIMESTAMP=$(date +"%Y-%m-%d_%H:%M")


URL="https://finnhub.io/api/v1/quote?symbol=CL&token=ctanb79r01qrt5hi2rb0ctanb79r01qrt5hi2rbg"

# Create the directory if it doesn't exist
BASE_DIR=$(dirname "$(realpath "$0")")
OUTPUT_DIR="$BASE_DIR/oil_price"

mkdir -p "$OUTPUT_DIR"

FILE_PATH="$OUTPUT_DIR/oil_price_$CURRENT_TIMESTAMP.json"

RESPONSE=$(curl --request GET --url "$URL")

# Extract the timestamp from the response
TIMESTAMP=$(echo "$RESPONSE" | jq '.t')

# Convert the timestamp to human-readable date format
REAL_DATE=$(date -d @$TIMESTAMP +"%Y-%m-%d %H:%M:%S")

# Replace the timestamp in the response with the real date
MODIFIED_RESPONSE=$(echo "$RESPONSE" | jq --arg real_date "$REAL_DATE" '.t = $real_date')

echo "$MODIFIED_RESPONSE" > "$FILE_PATH"
echo "oil price saved to $FILE_PATH" > $OUTPUT_DIR/oil_price.log


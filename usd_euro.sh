#!/bin/bash

CURRENT_TIMESTAMP=$(date +"%Y-%m-%d_%H:%M")

URL="https://api.twelvedata.com/exchange_rate?symbol=EUR/USD&apikey=25d17aa10da34a45a30cd295a2d87cf2"

# Create the directory if it doesn't exist
BASE_DIR=$(dirname "$(realpath "$0")")
OUTPUT_DIR="$BASE_DIR/usd_to_euro"

mkdir -p "$OUTPUT_DIR"

FILE_PATH="$OUTPUT_DIR/usd_euro$CURRENT_TIMESTAMP.json"

RESPONSE=$(curl --request GET --url "$URL")

# Extract the timestamp from the response
TIMESTAMP=$(echo "$RESPONSE" | jq '.timestamp')

# Convert the timestamp to human-readable date format
REAL_DATE=$(date -d @$TIMESTAMP +"%Y-%m-%d %H:%M:%S")

# Replace the timestamp in the response with the real date
MODIFIED_RESPONSE=$(echo "$RESPONSE" | jq --arg real_date "$REAL_DATE" '.timestamp = $real_date')

echo "$MODIFIED_RESPONSE" > "$FILE_PATH"
echo "usd_euro price saved to $FILE_PATH"> $OUTPUT_DIR/usd_euro.log


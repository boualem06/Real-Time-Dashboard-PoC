#!/bin/bash

# Define the database and collection names
DB_NAME="currency_data"
COLLECTION_NAME="usd_to_eur"

# Define the directory containing JSON files
FILE_DIR="/home/blm/Documents/linux_project_final/usd_to_euro"

# Log file for storing results of the operations
LOG_FILE="/home/blm/Documents/linux_project_final/import_and_delete.log"

# Iterate over JSON files in the directory
for file in "$FILE_DIR"/*.json; do
    if [[ -f "$file" ]]; then
        echo "Processing file: $file" >> "$LOG_FILE"
        
        # Import the file into MongoDB
        mongoimport --db "$DB_NAME" --collection "$COLLECTION_NAME" --file "$file" >> "$LOG_FILE" 2>&1
        
        # Check if the import was successful
        if [[ $? -eq 0 ]]; then
            echo "Successfully imported: $file" >> "$LOG_FILE"
            # Delete the file
            rm "$file"
            echo "Deleted file: $file" >> "$LOG_FILE"
        else
            echo "Failed to import: $file" >> "$LOG_FILE"
        fi
    else
        echo "No JSON files found in $FILE_DIR" >> "$LOG_FILE"
    fi
done


#===================================================================================================================================
# oil_price 

#!/bin/bash

# Define the database and collection names
DB_NAME="currency_data"
COLLECTION_NAME="oil_price"

# Define the directory containing JSON files
FILE_DIR="/home/blm/Documents/linux_project_final/oil_price"


# Iterate over JSON files in the directory
for file in "$FILE_DIR"/*.json; do
    if [[ -f "$file" ]]; then
        echo "Processing file: $file" >> "$LOG_FILE"
        
        # Import the file into MongoDB
        mongoimport --db "$DB_NAME" --collection "$COLLECTION_NAME" --file "$file" >> "$LOG_FILE" 2>&1
        
        # Check if the import was successful
        if [[ $? -eq 0 ]]; then
            echo "Successfully imported: $file" >> "$LOG_FILE"
            # Delete the file
            rm "$file"
            echo "Deleted file: $file" >> "$LOG_FILE"
        else
            echo "Failed to import: $file" >> "$LOG_FILE"
        fi
    else
        echo "No JSON files found in $FILE_DIR" >> "$LOG_FILE"
    fi
done

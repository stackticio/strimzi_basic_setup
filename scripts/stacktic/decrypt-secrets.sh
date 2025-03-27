#!/bin/bash

if [[ -z "$STACKTIC_OUTPUT" ]]; then
  echo "STACKTIC_OUTPUT is not set, please configure it with the root directory of your System"
  exit 1
fi

if [[ -z "$SOPS_AGE_KEY_FILE" ]]; then
  echo "SOPS_AGE_KEY_FILE is not set, please configure it with the path to your age key file"
  exit 1
fi

# Set the directory where you want to start searching
directory=$STACKTIC_OUTPUT

# Use find to locate files matching the pattern
files=$(find "$directory" -type f -name "*.sops.*")

# Loop through the files and apply your function
for file in $files; do

    # Extract the directory and filename parts
    dir=$(dirname "$file")
    filename=$(basename "$file")

    # Remove the .sops. from the filename
    new_filename=$(echo "$filename" | sed 's/\.sops\././')

    # Construct the new path for the decrypted file
    decrypted_file="$dir/$new_filename"

    # Run the sops --decrypt command and write the decrypted file
    sops --decrypt "$file" > "$decrypted_file"

    echo "Decrypted $file and saved as $decrypted_file" | sed "s|$directory/||g"

done

echo "All SOPS files have been decrypted"
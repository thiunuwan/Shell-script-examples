#!/bin/bash

# ========================================================
# 100 uploads per day, 5GB file size limit for FREE plan.
# ========================================================

URL="https://file.io"
DEFAULT_EXPIRE="14d" # Default to 14 days
echo "working directory:"
pwd
echo "............."
if [ $# -eq 0 ]; then
    printf "Usage: file.io.sh FILE [DURATION]\n"
    printf "Example: file.io.sh path/to/my/file 1w\n"
    exit 1
fi

FILE=$1
EXPIRE=${2:-$DEFAULT_EXPIRE}

if [ ! -f "$FILE" ]; then
    echo "File ${FILE} not found"
    exit 1
fi

RESPONSE=$(curl -# -F "file=@${FILE}" "${URL}/?expires=${EXPIRE}")

link=$(echo "$RESPONSE" | jq -r '.link')
echo "$link"

# Generate QR code and display in terminal
qrencode -t ANSIUTF8 "${link}"


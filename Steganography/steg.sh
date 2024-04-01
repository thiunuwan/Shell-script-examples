#!/bin/bash

# Check if steghide is installed
if ! command -v steghide &> /dev/null; then
    echo "Error: steghide is not installed. Please install it first."
    exit 1
fi

# Check if correct number of arguments are provided
if [ "$#" -lt 3 ]; then
    echo "Usage:"
    echo "Embedding: $0 embed <cover_image> <file_to_embed> <output_image> <passphrase>"
    echo "Decoding: $0 decode <steg_image> <passphrase> [output_file]"
    exit 1
fi

mode=$1
shift

case $mode in
    embed)
        # Assign input arguments to variables
        cover_image="$1"
        file_to_embed="$2"
        output_image="$3"
        passphrase="$4"

        # Check if cover image exists
        if [ ! -f "$cover_image" ]; then
            echo "Error: Cover image '$cover_image' not found."
            exit 1
        fi

        # Check if file to embed exists
        if [ ! -f "$file_to_embed" ]; then
            echo "Error: File to embed '$file_to_embed' not found."
            exit 1
        fi

        # Convert PNG to JPEG format if needed
        if [[ "$cover_image" == *.png ]]; then
            converted_image="${cover_image%.png}.jpg"
            echo "Converting $cover_image to JPEG format..."
            convert "$cover_image" "$converted_image"
            cover_image="$converted_image"
        fi

        # Embed file into cover image using steghide
        steghide embed -cf "$cover_image" -ef "$file_to_embed" -sf "./vol/$output_image" -p "$passphrase"

        if [ $? -eq 0 ]; then
            echo "File embedded successfully in $output_image"
        else
            echo "Error occurred while embedding file."
        fi
        ;;
    decode)
        # Assign input arguments to variables
        steg_image="$1"
        passphrase="$2"
        output_file="$3"

        # Check if steg image exists
        if [ ! -f "$steg_image" ]; then
            echo "Error: Steg image '$steg_image' not found."
            exit 1
        fi
        
        mkdir -p vol

        # Extract file from steg image using steghide
        if [ -n "$output_file" ]; then
            steghide extract -sf "$steg_image" -xf "./vol/$output_file" -p "$passphrase"
        else
            steghide extract -sf "$steg_image" -p "$passphrase"
        fi

        if [ $? -eq 0 ]; then
            echo "File extracted successfully"
        else
            echo "Error occurred while extracting file."
        fi
        ;;
    *)
        echo "Invalid mode. Please specify 'embed' or 'decode'."
        exit 1
        ;;
esac


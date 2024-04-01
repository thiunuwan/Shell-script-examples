#!/bin/bash

# Function to plot weather data
plot_weather() {
    local parameter="$1"
    local data_path="$2"
    mkdir -p graphs

    # Extract data for the specified parameter
    if [ "$parameter" == "wind" ]; then
        grep -o "\"$parameter\":{\"speed\":[0-9]\+\(\.[0-9]\+\)\?" "$data_path" | cut -d ":" -f 3 | cut -d "," -f 1 > "${parameter}_data.txt"
    elif [ "$parameter" == "clouds" ]; then
        grep -o "\"$parameter\":{\"all\":[0-9]\+" "$data_path" | cut -d ":" -f 3 | cut -d "}" -f 1 > "${parameter}_data.txt"
    else
        grep -o "\"$parameter\":[0-9]\+\(\.[0-9]\+\)\?" "$data_path" | cut -d ":" -f 2 > "${parameter}_data.txt"
    fi

    # Check if any data is extracted
    if [ -s "${parameter}_data.txt" ]; then
        # Generate Gnuplot script
        cat << EOF > plot_weather_${parameter}.gp
set terminal dumb
set title "${parameter^} Forecast"
set xlabel "Time (Hours)"
set ylabel "${parameter^}"
set xtics rotate by -45
set grid

plot "${parameter}_data.txt" with linespoints title "${parameter^}"
EOF

        # Execute Gnuplot script
                echo "${parameter} graph :"
        gnuplot plot_weather_${parameter}.gp

    else
        echo "No data found for $parameter"
    fi
}

# Function to fetch weather data
fetch_weather_data() {
    local location="$1"
    local api_key="$2"
    local cache_path="$3"
    local data

    # Create cache directory if it doesn't exist
    mkdir -p "$(dirname "$cache_path")"

    # Fetch weather data
    if [[ "$location" =~ ^[0-9]+$ ]]; then
        data=$(curl -s "http://api.openweathermap.org/data/2.5/forecast?id=$location&units=metric&appid=$api_key")
    else
        data=$(curl -s "http://api.openweathermap.org/data/2.5/forecast?q=$location&units=metric&appid=$api_key")
    fi

    # Check if data retrieval was successful
    if [ $? -eq 0 ]; then
        echo "$data" > "$cache_path"
    else
        echo "Failed to fetch weather data"
        exit 1
    fi
}

# Main function
main() {
    # Check if gnuplot is installed
    if ! command -v gnuplot &> /dev/null; then
        echo "Error: Gnuplot is not installed. Please install Gnuplot to generate plots."
        exit 1
    fi

    # Set default values
    apiKey="07fb471f79f27b0575cdb96b16af6432"
    defaultLocation="1246294"
    CachePath="/tmp/fore-$defaultLocation.json"
    degreeCharacter="c"

    # Read command line options
    while [ $# -gt 0 ]; do
        option="$1"
        case $option in
            -k) apiKey="$2"; shift ;;
            -l) defaultLocation="$2"; shift ;;
            -p) CachePath="$2"; shift ;;
            -f) degreeCharacter="f" ;;
        esac
        shift
    done

    # Fetch weather data
    data=$(fetch_weather_data "$defaultLocation" "$apiKey" "$CachePath")

    # Call the plot_weather function for each parameter
    plot_weather "temp" "$CachePath"
    plot_weather "wind" "$CachePath"
    plot_weather "humidity" "$CachePath"
    plot_weather "clouds" "$CachePath"
}

# Execute the main function
main "$@"


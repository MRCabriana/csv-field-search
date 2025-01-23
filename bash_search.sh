#! /bin/bash
# Default values for directory_name, search_patterns and output_file
directory_name="$(pwd)"
search_patterns=()
output_file="$(pwd)/search.txt"

# Display how script is to be used if option provided is wrong
usage() {
    echo "Usage: $0 [-d <directory_name> | --directory=<directory_name>] <search_pattern_1> <search_pattern_2> ..."
    exit 1
}

# Get the options if `$1` starts with a dash
while [[ "$1" =~ ^- ]]; do
    case "$1" in
        -d)
            if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                directory_name="$2"
                shift 2
            else
                echo "Error: Option '-d' requires an argument." >&2
                usage
            fi
            ;;
        --directory=*)
            directory_name="${1#*=}"
            if [[ -z "$directory_name" ]]; then
                echo "Error: Option '--directory' requires an argument." >&2
                usage
            fi

            shift
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            ;;
    esac
done

# Collect other arguments after options, these are search patterns
search_patterns=("$@")

# Raise error if no search pattern is provided
if [[ ${#search_patterns[@]} -eq 0 ]]; then
    echo "Error: No search pattern arguments provided." >&2
    usage
fi

# Delete output file if present
if [[ -f $output_file ]]; then
    rm $output_file
fi

# Get the length of the longest search pattern
# Then increment with `5` for padding
max_length=0
for search_pattern in "${search_patterns[@]}"; do
    # Get the length of the current `search_pattern`
    len=${#search_pattern}

    # Update `max_length` if the current `search_pattern` is longer
    if (( len > max_length )); then
        max_length=$len
    fi
done
((max_length+=5))

# Loop search pattern then file
declare -A search_result
for search_pattern in "${search_patterns[@]}"; do
    echo "$search_pattern:" >> $output_file
    echo "==============" >> $output_file

    # Get converted pattern
    conv_pattern="${search_pattern//\*/[^,]*}"
    conv_pattern="${conv_pattern//\?/[^,]}"
    conv_pattern="[^,[:space:]]*$conv_pattern[^,]*"

    index=0
    for file in "$directory_name/"*.csv; do
        if [ -f "$file" ]; then  # Ensure it's a file (not a directory)
            # Add grep results to a key-value pair
            while IFS= read -r line; do
                echo "    $line" >> $output_file
                ((index++))
            done < <(grep -o $conv_pattern $file)
        fi
    done

    # Assign match result
    search_result[$search_pattern]=$index
    if [[ $index -eq 0 ]]; then
        search_result[$search_pattern]="none"
        echo "    NO DATA" >> $output_file
    fi

    printf "\n" >> $output_file
done

# Output final result
# Print the header (fixed column widths)
printf "%-${max_length}s %-10s\n" "" "No. of hits"

# Print each pattern and its corresponding hit value
for search_pattern in "${search_patterns[@]}"; do
    printf "%-${max_length}s %-10s\n" "$search_pattern:" "${search_result[$search_pattern]}"
done

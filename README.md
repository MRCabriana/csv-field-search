usage: ./bash_search.sh [-d DIRECTORY_NAME] [search_pattern [search_pattern ...]]

This program reads CSV files in the current working directory or a specified directory (using the -d or --d parameter).
It searches for lines that match the given search patterns. The terminal will display the total number of matches for
each search pattern, and a text file named search.txt will be created, containing all the matched results.

optional arguments:
-d, --directory DIRECTORY_NAME          Reads the csv files specified in the DIRECTORY_NAME.
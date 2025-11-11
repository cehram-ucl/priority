# -*- coding: utf-8 -*-
"""
Python script to remove binary zeroes from a file.
This appears to be due to some data corruption

@author: rmjlton
"""

import math
import time

# Start timer
time_start = time.time()

# File constants
CPRD_FILE = "Observation"
PREFIX = "JC"
PART = 721  # This is the file that needs fixing
FILE = f"{PREFIX}_Extract_{CPRD_FILE}_{PART}"
PATH = "S:/CALIBER_23_003266/Phil/1a_raw_data"

# Open file
with open(f"{PATH}/{FILE}.txt", "r") as file:
    
    # Read the first line (variable names)
    first_line = file.readline()
    
    # Iteration variables
    line_count = 0
    clean_lines = []
    dirty_lines = []
    
    # Read each line of file
    for line in file:
        
        # Increment line count
        line_count += 1
        
        # Check to see if line contains binary zeros
        if "\0" in line:
            print(f"Line {line_count} contains binary zeroes.")
            dirty_lines.append(line)
        else:
            clean_lines.append(line)

print(f"Total lines read: {line_count}")

with open(f"{PATH}/{FILE}_clean.txt", "w") as clean_file:
    clean_file.write(first_line)  # Write stored variable names as first row
    clean_file.writelines(clean_lines)  # Write the remaining lines
    
with open(f"{PATH}/{FILE}_dirty.txt", "w") as dirty_file:
    dirty_file.write(first_line)  # Write stored variable names as first row
    dirty_file.writelines(dirty_lines)  # Write the remaining lines

# Stop timer
time_end = time.time()

# Calcuate run time
runtime = time_end - time_start
print("Run time:",
      f"{math.floor(runtime/3600)} hours",
      f"{math.floor((runtime % 3600)/60)} minutes",
      f"{math.floor(runtime % 60)} seconds",
      f"{round((runtime % 1)*1000, 6)} milliseconds")

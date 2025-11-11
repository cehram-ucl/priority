# -*- coding: utf-8 -*-
"""
Python script to split large CPRD files into multiple parts
based on a desired number of lines within each part file.

This takes a very long time to run for a large file.
Approximately 48 hours for a 650GB file.

@author: rmjlton
"""

import math
import time

# Start timer
time_start = time.time()

# File constants
CPRD_FILE = "DrugIssue"
PREFIX = "JC"
PATH_FILE = f"S:/CALIBER_23_003266/DELETE/Drugissue/{PREFIX}_Extract_{CPRD_FILE}.txt"
FILE_LINES = 6000000  # No. of lines per file part
PATH_EXPORT = "S:/CALIBER_23_003266/Phil/1a_raw_data"
PART_RESUME = 0  # Part No. you want to resume creating files from (0 to start from beginning)

# Open file
with open(PATH_FILE, "r") as file:
    
    # Read the first line (variable names)
    first_line = file.readline()
    
    # Iteration variables
    part = 1
    current_lines = []
    
    # Read each line of file
    for line in file:
        current_lines.append(line)
        
        # When No. of lines reaches desired No. per file write to file
        if len(current_lines) >= FILE_LINES:
            
            # If resuming from a previous failed run start from "PART_RESUME"
            if part >= PART_RESUME:
                with open(f"{PATH_EXPORT}/{PREFIX}_Extract_{CPRD_FILE}_{part}.txt", "w") as output_file:
                    output_file.write(first_line)  # Write stored variable names as first row
                    output_file.writelines(current_lines)  # Write the remaining lines
                
            # Increment file count
            part += 1
            
            # Reset line storage
            current_lines = []
            
    # Write final remaining lines to last file part
    if current_lines:
        with open(f"{PATH_EXPORT}/{PREFIX}_Extract_{CPRD_FILE}_{part}.txt", "w") as output_file:
            output_file.write(first_line)  # Write stored variable names as first row
            output_file.writelines(current_lines)  # Write the remaining lines

# Stop timer
time_end = time.time()

# Calcuate run time
runtime = time_end - time_start
print("Run time:",
      f"{math.floor(runtime/3600)} hours",
      f"{math.floor((runtime % 3600)/60)} minutes",
      f"{math.floor(runtime % 60)} seconds",
      f"{round((runtime % 1)*1000, 6)} milliseconds")

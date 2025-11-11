clear all
set more off

// Set working directory (project folder)
cd "S:\CALIBER_23_003266\Phil"

// Record start time to benchmark processing time of do file
local start = clock("$S_DATE $S_TIME", "DMY hms")
local date = subinstr("$S_DATE", " ", "", .)
local time = subinstr("$S_TIME", ":", "", .)


// File constants to ease automation
local file "DrugIssue"   //the file name


// Open log file
capture log close
log using "2b_build_logs/01d_Import`file'_`date'_`time'", text replace

// Required directories
local raw_data_dir "../DELETE/`file'"
local lookup_dir "../DELETE/Lookup/202309_Lookups_CPRDAurum"

// Check parts, prefix, and number of cohorts
dir "`raw_data_dir'/*`file'*.txt"


//Run my import_drugissue do file passing the file prefix, No. of parts, raw data location, location to write Stata formatted file to, and the location of the lookups
do 2a_build_scripts/import_drugissue ///
	JC_Extract 15 "`raw_data_dir'" "1b_formatted_data" "`lookup_dir'"
do 2a_build_scripts/import_drugissue ///
	JC_Extract_2 36 "`raw_data_dir'" "1b_formatted_data" "`lookup_dir'"
do 2a_build_scripts/import_drugissue ///
	JC_3 40 "`raw_data_dir'" "1b_formatted_data" "`lookup_dir'"
do 2a_build_scripts/import_drugissue ///
	JC_4 36 "`raw_data_dir'" "1b_formatted_data" "`lookup_dir'"



// Print time taken to run the do file
local runtime = clock("$S_DATE $S_TIME", "DMY hms") - `start'
display "Runtime: " floor(`runtime'/60000) " minutes " mod(`runtime'/1000, 60) " seconds"

// Close the log file
log close

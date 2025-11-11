clear all
set more off

// Set working directory (project folder)
cd "S:\CALIBER_23_003266\Phil"

// Record start time to benchmark processing time of do file
local start = clock("$S_DATE $S_TIME", "DMY hms")
local date = subinstr("$S_DATE", " ", "", .)
local time = subinstr("$S_TIME", ":", "", .)


// File constants to ease automation
local file "Practice"   //the file name


// Open log file
capture log close
log using "2b_build_logs/01a_Import`file'_`date'_`time'", text replace

// Required directories
local raw_data_dir "../DELETE/`file'"
local lookup_dir "../DELETE/Lookup/202309_Lookups_CPRDAurum"

// Check parts, prefix, and number of cohorts
dir "`raw_data_dir'/*`file'*.txt"


// Loop through files
foreach prefix in JC JC_Extract JC_Extract_2 JC_3 JC_4 {
	
	if "`prefix'" == "JC" {
		
		import delimited ///
			"`raw_data_dir'/`prefix'_Extract_`file'.txt", clear
	}
	else {
		
		import delimited ///
			"`raw_data_dir'/`prefix'_Extract_`file'_001.txt", clear
	}
	
	// Format dates - requires cprddate command (assumes DMY)
	if "`prefix'" == "JC" {
		
		cprddate lcd, format("YMD")
	}
	else {
		
		cprddate lcd
	}

	// Label categorical vars using lookup files - requires cprdlabel command
	cprdlabel region, lookup("Region") location("`lookup_dir'")

	// Label variables
	label var pracid "CPRD practice identifier"
	label var lcd    "Last Collection Date"
	label var uts    "Up-to-standard date"
	label var region "Region"

	// Drop unused variables
	codebook uts   //not generated yet
	drop uts

	// Save to tempfile
	compress
	tempfile `prefix'
	save ``prefix''
}

// Loop through tempfiles and merge
foreach prefix in JC_3 JC_Extract_2  JC_Extract JC {
	
	merge 1:1 pracid using ``prefix'', update replace nogenerate
}

codebook

// Save to tempfile
compress
save 1b_formatted_data/`file', replace


// Print time taken to run the do file
local runtime = clock("$S_DATE $S_TIME", "DMY hms") - `start'
display "Runtime: " floor(`runtime'/60000) " minutes " mod(`runtime'/1000, 60) " seconds"

// Close the log file
log close

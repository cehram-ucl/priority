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
log using "2b_build_logs/01d_Import`file'_part2_`date'_`time'", text replace

// Required directories
local raw_data_dir "1a_raw_data"
local lookup_dir "../DELETE/Lookup/202309_Lookups_CPRDAurum"

// Check parts, prefix, and number of cohorts
dir "`raw_data_dir'/*`file'*.txt"


// Observation file characteristics
local prefix "JC"
local parts = 525


//For each part of file
forvalues part = 1/`parts' {
	
	//Add leading zeros to count if necessary
	if `part' < 10 {
		
		local str_part = "00`part'"
	}
	else if `part' < 100 {
		
		local str_part = "0`part'"
	}
	else {
		
		local str_part = "`part'"
	}
	
	display "Importing `prefix'_Extract_`file'_`part'"
	
	dir "`raw_data_dir'/`prefix'_Extract_`file'_`part'.txt"
	
	import delimited ///
		"`raw_data_dir'/`prefix'_Extract_`file'_`part'.txt", ///
		stringcols(1 2 4 5 9) asdouble clear
	
	// Remove last 5 digits from patid and convert to numeric to save storage space
	replace patid = substr(patid, 1, strlen(patid) - 5)
	destring patid, replace
	format %12.0g patid
	
	// Place patid and pracid next to each other as they need to be combined
	order pracid, after(patid)
	
	// Format dates - requires cprddate command (assumes DMY)
	cprddate issuedate enterdate, format("YMD")

	// Label categorical vars using lookup files - requires cprdlabel command
	cprdlabel quantunitid, lookup("QuantUnit") location("`lookup_dir'")

	// Label variables
	label var patid       "Patient identifier"
	label var issueid     "Issue record identifier"
	label var pracid      "CPRD practice identifier"
	label var probobsid   "Problem observation identifier"
	label var drugrecid   "Drug record identifier"
	label var issuedate   "Event date"
	label var enterdate   "Entered date"
	label var staffid     "Staff identifier"
	label var prodcodeid  "Drug code identifier"
	label var dosageid    "Dosage identifier"
	label var quantity    "Quantity"
	label var quantunitid "Quantity unit identifier"
	label var duration    "Course duration in days"
	label var estnhscost  "Estimated NHS cost"

	//Can't make use of these observations
	display
	display "Useless observations: "
	count if issuedate == .
	drop if issuedate == .

	// Save
	compress
	// Don't bother with part suffix if only 1 part
	if `parts' < 2 {
		
		save "1b_formatted_data/`prefix'_`file'", replace
	}
	else {
		
		save "1b_formatted_data/`prefix'_`file'_`str_part'", replace
	}
}


// Print time taken to run the do file
local runtime = clock("$S_DATE $S_TIME", "DMY hms") - `start'
display "Runtime: " floor(`runtime'/60000) " minutes " mod(`runtime'/1000, 60) " seconds"

// Close the log file
log close

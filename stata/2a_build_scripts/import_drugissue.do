args prefix parts read_dir write_dir lookup_dir

// Record start time to benchmark processing time of do file
local start = clock("$S_DATE $S_TIME", "DMY hms")

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
	
	display "Importing `prefix'_Extract_DrugIssue_`str_part'"
	
	dir "`read_dir'/`prefix'_Extract_DrugIssue_`str_part'.txt"
	
	import delimited ///
		"`read_dir'/`prefix'_Extract_DrugIssue_`str_part'.txt", ///
		stringcols(1 2 4 5 9) asdouble clear
	
	// Remove last 5 digits from patid and convert to numeric to save storage space
	replace patid = substr(patid, 1, strlen(patid) - 5)
	destring patid, replace
	format %12.0g patid
	
	// Place patid and pracid next to each other as they need to be combined
	order pracid, after(patid)
	
	// Format dates - requires cprddate command (assumes DMY)
	cprddate issuedate enterdate

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
		
		save "`write_dir'/`prefix'_DrugIssue", replace
	}
	else {
		
		save "`write_dir'/`prefix'_DrugIssue_`str_part'", replace
	}
	
	// Print time taken to run steps for each imported/saved raw file
	local runtime = clock("$S_DATE $S_TIME", "DMY hms") - `start'
	display "Current runtime: " floor(`runtime'/60000) " minutes " ///
		mod(`runtime'/1000, 60) " seconds"
}
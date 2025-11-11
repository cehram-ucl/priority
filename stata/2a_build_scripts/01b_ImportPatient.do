clear all
set more off

// Set working directory (project folder)
cd "S:\CALIBER_23_003266\Phil"

// Record start time to benchmark processing time of do file
local start = clock("$S_DATE $S_TIME", "DMY hms")
local date = subinstr("$S_DATE", " ", "", .)
local time = subinstr("$S_TIME", ":", "", .)


// File constants to ease automation
local file "Patient"   //the file name


// Open log file
capture log close
log using "2b_build_logs/01b_Import`file'_`date'_`time'", text replace

// Required directories
local raw_data_dir "../DELETE/`file'"
local lookup_dir "../DELETE/Lookup/202309_Lookups_CPRDAurum"

// Check parts, prefix, and number of cohorts
dir "`raw_data_dir'/*`file'*.txt"


local prefix "JC"


// Import file
import delimited ///
	"`raw_data_dir'/`prefix'_Extract_`file'.txt", ///
	stringcols(1) clear

// (Optional) Convert patid to numeric after removing pracid component

// Check last 5 digits of patid are the same as the pracid
assert real(substr(patid, -5, .)) == pracid

// Check last 5 digits of patid + patid minus last 5 digits = patid
assert substr(patid, 1, strlen(patid) - 5) + substr(patid, -5, .) == patid

// Check conversion to numeric and back to string loses no information
assert strofreal(real(substr(patid, 1, strlen(patid) - 5)), "%14.0f") ///
	+ strofreal(pracid) == patid

// Check conversion to numeric and back to string using destring/tostring
generate pat1 = substr(patid, 1, strlen(patid) - 5)
destring pat1, replace
tostring pat1, replace
replace pat1 = pat1 + strofreal(pracid)
assert pat1 == patid
drop pat1

// Remove last 5 digits from patid and convert to numeric to save storage space
replace patid = substr(patid, 1, strlen(patid) - 5)
destring patid, replace
format %14.0f patid

// Place patid and pracid next to each other as they need to be combined
order pracid, after(patid)


// Format dates - requires cprddate command (assumes DMY)
cprddate dob emis_ddate regstartdate regenddate deathdate ///
	lcd data_start data_end smi_ist_dt, format("YMD")

// Label categorical vars using lookup files - requires cprdlabel command
cprdlabel gender, lookup("Gender") location("`lookup_dir'")
cprdlabel patienttypeid, lookup("PatientType") location("`lookup_dir'")
cprdlabel region, lookup("Region") location("`lookup_dir'")

// Label variables
label var patid          "Patient identifier"
label var pracid         "CPRD practice identifier"
//label var usualgpstaffid "Usual GP"
label var gender         "Gender"
//label var yob            "Year of birth"
//label var mob            "Month of birth"
label var emis_ddate     "Date of death"
label var regstartdate   "Registration start date"
label var patienttypeid  "Patient type"
label var regenddate     "Registration end date"
label var acceptable     "Acceptable flag"
label var deathdate     "CPRD death date"  //normally called cprd_ddate

//OPTIONAL STEPS (modify as needed)

codebook

// Drop unused variables
//codebook mob
//drop mob  //only provided for children
drop uts  //empty
drop emis_ddate  //Not reliable; use CPRD derived 'cprd_ddate' instead

// Save
compress	
save 1b_formatted_data/`file', replace


// Print time taken to run the do file
local runtime = clock("$S_DATE $S_TIME", "DMY hms") - `start'
display "Runtime: " floor(`runtime'/60000) " minutes " mod(`runtime'/1000, 60) " seconds"

// Close the log file
log close

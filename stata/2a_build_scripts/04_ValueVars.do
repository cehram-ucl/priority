clear all
set more off

// Set working directory (project folder)
cd "S:\CALIBER_23_003266\Phil"

// Record start time to benchmark processing time of do file
local start = clock("$S_DATE $S_TIME", "DMY hms")
local date = subinstr("$S_DATE", " ", "", .)
local time = subinstr("$S_TIME", ":", "", .)

// Open log file
capture log close
log using "2b_build_logs/04_ValueVars_`date'_`time'", text replace

// Study constants
local study_start = dmy(1, 1, 2000)
local study_end = dmy(31, 12, 2019)
local build_date = dmy(1, 9, 2023)  //Sep 2023 Build


//Combine required medical codelists
use "codelists/compact/blood_pressure", clear
merge 1:1 medcodeid using "codelists/compact/body_mass_index", nogenerate
merge 1:1 medcodeid using "codelists/compact/cholesterol", nogenerate
merge 1:1 medcodeid using "codelists/compact/HbA1c", nogenerate
merge 1:1 medcodeid using "codelists/compact/alcohol_consumption", nogenerate
drop if !missing(alcstatus)
drop if hba1c == 1 & target == 1  //remove target HbA1c codes
tab target
drop alcstatus alclevel target

tempfile valuecodelists
save `valuecodelists'


//Limit cohort to essential variables
use pracid patid gender dob regenddate deathdate lcd using 3_builds/linkage_eligible, clear
tempfile cohort
save `cohort'


local prefix_list "JC_Extract JC_Extract_2 JC_3 JC_4 JC"
local first_prefix: word 1 of `prefix_list'
local count = 0  //initialise count of total number of file parts

foreach prefix of local prefix_list {
	
	if "`prefix'" == "JC_Extract" {
		
		local parts = 18
	}
	else if "`prefix'" == "JC_Extract_2" {
		
		local parts = 51
	}
	else if "`prefix'" == "JC_3" {
		
		local parts = 54
	}
	else if "`prefix'" == "JC_4" {
		
		local parts = 45
	}
	else if "`prefix'" == "JC" {
		
		local parts = 732
	}
	else {
		
		display as error "Error with prefix list"
		error
	}
	
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
		
		//Increment new overall part count (ignoring prefix)
		local count = `count' + 1
		
		//Open Observation file
		display "Opening: `prefix'_Observation_`str_part'..."
		use pracid patid obsdate medcodeid value numunitid using ///
			1b_formatted_data/`prefix'_Observation_`str_part', clear
		count

		//Remove codes without a value
		drop if value == .
		
		//Remove codes without a date
		drop if obsdate == .
		
		//Remove codes with a negative value (not possible)
		drop if value < 0

		//Merge with cohort to restrict size of merge operation
		merge m:1 pracid patid using `cohort', nogenerate keep(match)
		order pracid patid gender dob regenddate deathdate lcd
		
		//Remove records before 18th birthday
		drop if obsdate < dob + (365.25 * 18)
		
		//Remove records after end of follow-up (earliest of registration end, death, last collection)
		drop if obsdate > min(regenddate, deathdate, lcd)
		
		//Merge with codelists
		merge m:1 medcodeid using `valuecodelists', nogenerate keep(match)
		compress
		
		//Save values and dates for each value variable
		foreach var of varlist bp cholesterol hba1c height weight bmi alcvalue {
			
			preserve
				keep if `var' != .
				
				//Just keep necessary variables
				if "`var'" == "bp" {
					
					keep pracid patid obsdate medcodeid value numunitid `var' ///
						systolic_bp diastolic_bp bp_type
				}
				else if "`var'" == "cholesterol" {
					
					keep pracid patid obsdate medcodeid value numunitid `var' ///
						triglycerides ldl non_hdl hdl total ratio vldl cholesterol_type
				}
				else if inlist("`var'", "bmi", "height", "weight") {
					
					keep pracid patid obsdate medcodeid value numunitid ///
						bmi height weight
				}
				else {
					
					keep pracid patid obsdate medcodeid value numunitid `var'
				}
				
				drop `var'
				rename value `var'
				rename obsdate `var'_date
				rename numunitid `var'_units
				
				compress
				//count  //for debugging
				save temp/`var'_`count', replace
			restore
		}
	}
}

foreach var in bp cholesterol hba1c height weight bmi alcvalue {
	
	//display "Opening `var'_1..."  //for debugging
	use temp/`var'_1, clear
	
	forvalues i = 2/`count' {
		
		//display "Appending `var'_`i'..."  //for debugging
		append using temp/`var'_`i'
	}
	
	//display "Saving combined `var'..."  //for debugging
	//count  //for debugging
	compress
	duplicates drop
	save 3_builds/`var', replace
}


// Print time taken to run the do file
local runtime = clock("$S_DATE $S_TIME", "DMY hms") - `start'
display "Runtime: " floor(`runtime'/60000) " minutes " mod(`runtime'/1000, 60) " seconds"

log close

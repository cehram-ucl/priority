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
log using "2b_build_logs/05_DrugVars_`date'_`time'", text replace

// Study constants
local study_start = dmy(1, 1, 2000)
local study_end = dmy(31, 12, 2019)
local build_date = dmy(1, 9, 2023)  //Sep 2023 Build


//Combine required medical codelists
use "codelists/compact/antipsychotics", clear
merge 1:1 prodcodeid using "codelists/compact/statins", nogenerate
merge 1:1 prodcodeid using "codelists/compact/antihypertensives", nogenerate
merge 1:1 prodcodeid using "codelists/compact/t2dm_meds", nogenerate

tempfile drugcodelists
save `drugcodelists'


//Limit cohort to essential variables
use 3_builds/linkage_eligible, clear
keep pracid patid //data_start data_end flg_smi smi_ist_dt
tempfile cohort
save `cohort'


local prefix_list "JC_Extract JC_Extract_2 JC_3 JC_4 JC"
local first_prefix: word 1 of `prefix_list'
local count = 0

foreach prefix of local prefix_list {
	
	if "`prefix'" == "JC_Extract" {
		
		local parts = 15
	}
	else if "`prefix'" == "JC_Extract_2" {
		
		local parts = 36
	}
	else if "`prefix'" == "JC_3" {
		
		local parts = 40
	}
	else if "`prefix'" == "JC_4" {
		
		local parts = 36
	}
	else if "`prefix'" == "JC" {
		
		local parts = 525
	}
	else {
		
		display as error "Error with prefix list"
		error
	}
	
	forvalues part = 1/`parts' {
		
		//New overall part count (ignoring prefix)
		local count = `count' + 1
		
		//Add leading zeros to prefix part count if necessary
		if `part' < 10 {
			
			local str_part = "00`part'"
		}
		else if `part' < 100 {
			
			local str_part = "0`part'"
		}
		else {
			
			local str_part = "`part'"
		}
		
		//Open Observation file
		display "Opening: `prefix'_DrugIssue_`str_part'..."
		use pracid patid issuedate prodcodeid dosageid quantity quantunitid ///
			duration ///
			using 1b_formatted_data/`prefix'_DrugIssue_`str_part', clear
		count

		//Merge with cohort to restrict size of merge operation
		merge m:1 pracid patid using `cohort', nogenerate keep(match)
		
		//Merge with codelists
		merge m:1 prodcodeid using `drugcodelists', nogenerate keep(match)
		compress

		//Save events for each variable
		foreach var of varlist antipsychotic lipid_lowering antihypertensive t2dm_med {
			
			preserve
				keep if `var' != .
				
				if "`var'" == "antipsychotic" {
					
					keep pracid patid issuedate prodcodeid dosageid ///
						quantity quantunitid duration ///
						`var' antipsychotic_medication ///
						injected solution multiple ap_strength
				}
				else if "`var'" == "antihypertensive" {
					
					keep pracid patid issuedate prodcodeid ///
						quantity quantunitid duration ///
						`var' antihypertensive_medication
				}
				else if "`var'" == "lipid_lowering" {
					
					keep pracid patid issuedate prodcodeid ///
						quantity quantunitid duration ///
						`var' statin
				}
				else {
					
					keep pracid patid issuedate prodcodeid ///
						quantity quantunitid duration ///
						`var'
				}
				
				rename issuedate `var'_date
				
				compress
				//count  //for debugging
				save temp/`var'_`count', replace
			restore
		}
	}
}


foreach var of varlist antipsychotic lipid_lowering antihypertensive t2dm_med {
	
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
	
	if "`var'" == "antipsychotic" {
		
		//Create an antipsychotic list without injected medicines
		tab injected, missing
		drop if injected == 1
		tab injected, missing
		drop injected
		compress
		save 3_builds/`var'_no_injected, replace
	}
}


// Print time taken to run the do file
local runtime = clock("$S_DATE $S_TIME", "DMY hms") - `start'
display "Runtime: " floor(`runtime'/60000) " minutes " mod(`runtime'/1000, 60) " seconds"

log close

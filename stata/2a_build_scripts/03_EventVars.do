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
log using "2b_build_logs/03_EventVars_`date'_`time'", text replace

// Study constants
local study_start = dmy(1, 1, 2000)
local study_end = dmy(31, 12, 2019)
local build_date = dmy(1, 9, 2023)  //Sep 2023 Build


//Combine required medical codelists
use "codelists/compact/smi(pop def)_snomed_6_PWS_v3", clear
merge 1:1 medcodeid using "codelists/compact/type_2_diabetes", nogenerate
merge 1:1 medcodeid using "codelists/compact/myocardial_infarction", nogenerate
merge 1:1 medcodeid using "codelists/compact/stroke", nogenerate
merge 1:1 medcodeid using "codelists/compact/ischaemic_heart_disease", nogenerate
merge 1:1 medcodeid using "codelists/compact/major_cardiovascular_surgery", nogenerate
merge 1:1 medcodeid using "codelists/compact/smoking_status", nogenerate
merge 1:1 medcodeid using "codelists/compact/alcohol_use_disorder", nogenerate
merge 1:1 medcodeid using "codelists/compact/ethnicity", nogenerate
merge 1:1 medcodeid using "codelists/compact/dementia", nogenerate
merge 1:1 medcodeid using "codelists/compact/alcohol_consumption", nogenerate
drop if alcvalue == 1  //dont' want value codes
drop alcvalue

tempfile eventcodelists
save `eventcodelists'


//Limit cohort to essential variables
use 3_builds/linkage_eligible, clear
keep pracid patid //data_start data_end flg_smi smi_ist_dt
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
		use pracid patid obsdate medcodeid using ///
			1b_formatted_data/`prefix'_Observation_`str_part', clear
		count
		
		//Remove codes without a date
		drop if obsdate == .
		
		count
		
		//Merge with cohort to restrict size of merge operation
		merge m:1 pracid patid using `cohort', nogenerate keep(match)
		
		//Merge with codelists
		merge m:1 medcodeid using `eventcodelists', nogenerate keep(match)
		compress
		
		//Save events for each variable
		foreach var of varlist smi t2dm mi stroke ihd cv_surgery smoking_status ///
			alcohol_use_disorder eth5 dementia alcstatus {
			
			preserve
				keep if `var' != .
				
				if "`var'" == "smi" {
					
					keep pracid patid obsdate medcodeid `var' subtype
				}
				else if "`var'" == "t2dm" {
					
					keep pracid patid obsdate medcodeid `var' `var'_incprev
				}
				else if "`var'" == "alcstatus" {
					
					keep pracid patid obsdate medcodeid `var' alclevel
				}
				else {
					
					keep pracid patid obsdate medcodeid `var'
				}
				
				rename obsdate `var'_date
				
				compress
				//count  //for debugging
				save temp/`var'_`count', replace
			restore
		}
	}
}

//Merge all the parts in to one file
foreach var of varlist smi t2dm mi stroke ihd cv_surgery smoking_status ///
	alcohol_use_disorder eth5 dementia alcstatus {
	
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
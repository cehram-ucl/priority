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
log using "2b_build_logs/08_BaselineCovariates_`date'_`time'", text replace

// Study constants
local study_start = dmy(1, 1, 2000)
local study_end = dmy(31, 12, 2019)
local build_date = dmy(1, 9, 2023)  //Sep 2023 Build


//Start with cohort
use 3_builds/cohort, clear
count

// STATUS AS AT INDEX DATE OF FIRST ANTIPSYCHOTIC PRESCRIPTION

//Ethnicity (most common category in record)
preserve
	keep pracid patid antipsychotic_first
	merge 1:m pracid patid using 3_builds/eth5
	keep if _merge == 3
	drop _merge medcodeid

	label list eth5
	drop if eth5 == 6  //"Not stated" isn't useful
	generate byte white = 1 if eth5 == 1
	generate byte south_asian = 1 if eth5 == 2
	generate byte black = 1 if eth5 == 3
	generate byte other = 1 if eth5 == 4
	generate byte mixed = 1 if eth5 == 5

	gsort pracid patid -eth5_date
	by pracid patid: egen white_total = count(white)
	by pracid patid: egen sa_total = count(south_asian)
	by pracid patid: egen black_total = count(black)
	by pracid patid: egen other_total = count(other)
	by pracid patid: egen mixed_total = count(mixed)

	by pracid patid: keep if _n == 1
	egen highestcount = rowmax(white_total sa_total black_total other_total mixed_total)

	//Make a new ethnicity variable
	generate byte ethnicity = .
	label values ethnicity eth5
	replace ethnicity = 1 if white_total == highestcount & highestcount ! = 0
	replace ethnicity = 2 if sa_total == highestcount & highestcount ! = 0
	replace ethnicity = 3 if black_total == highestcount & highestcount ! = 0
	replace ethnicity = 4 if other_total == highestcount & highestcount ! = 0
	replace ethnicity = 5 if mixed_total == highestcount & highestcount ! = 0

	//If 2 or more categories with same count, choose most recent ethnicity code
	generate byte samecount_count = 0
	foreach var of varlist white_total sa_total black_total other_total mixed_total {
		
		replace samecount_count = samecount_count + 1 ///
			if `var' == highestcount & highestcount ! = 0
	}
	replace ethnicity = eth5 if samecount_count > 1

	keep pracid patid ethnicity
	tempfile ethnicity
	save `ethnicity'
restore
merge 1:1 pracid patid using `ethnicity', nogenerate
order ethnicity, after(e2019_imd_5_patient)
recode ethnicity (. = 99)
label define eth5 99 "Missing", add
tab ethnicity, missing


//Smoking status (most recent at index date; replace never with ex if any smoking codes)
preserve
	keep pracid patid antipsychotic_first
	merge 1:m pracid patid using 3_builds/smoking_status
	drop if _merge == 2
	drop _merge medcodeid
	label list smoking_status
	drop if smoking_status_date > antipsychotic_first
	gsort pracid patid -smoking_status_date -smoking_status  //sort highest exposure first
	by pracid patid: egen highest_status = max(smoking_status)
	by pracid patid: keep if _n == 1
	replace smoking_status = 2 if smoking_status == 1 & highest_status > 1
	keep pracid patid smoking_status_date smoking_status
	tempfile smoking
	save `smoking'
restore
merge 1:1 pracid patid using `smoking', nogenerate
recode smoking_status (. = 99)
label define smoking_status 99 "Missing", add
tab smoking_status, missing


//Alcohol status (most recent at index date; replace never with ex if any current/ex codes)
preserve
	keep pracid patid antipsychotic_first
	merge 1:m pracid patid using 3_builds/alcstatus
	keep if _merge == 3
	drop _merge alclevel
	drop if alcstatus_date > antipsychotic_first
	gsort pracid patid -alcstatus_date -alcstatus  //sort highest exposure first
	by pracid patid: egen highest_status = max(alcstatus)
	by pracid patid: keep if _n == 1
	replace alcstatus = 2 if alcstatus == 1 & highest_status > 1
	keep pracid patid alcstatus_date alcstatus
	tempfile alcstat
	save `alcstat'
restore
merge 1:1 pracid patid using `alcstat', nogenerate
recode alcstatus (. = 99)
label define alcstatus 99 "Missing", add
tab1 alcstatus, missing


//Alcohol level (most recent at index date)
preserve
	keep pracid patid antipsychotic_first
	merge 1:m pracid patid using 3_builds/alcstatus
	keep if _merge == 3
	drop _merge alcstatus
	drop if alclevel == .
	rename alcstatus_date alclevel_date
	drop if alclevel_date > antipsychotic_first
	gsort pracid patid -alclevel_date -alclevel  //sort highest exposure first
	by pracid patid: keep if _n == 1
	keep pracid patid alclevel_date alclevel
	tempfile alclev
	save `alclev'
restore
merge 1:1 pracid patid using `alclev', nogenerate
recode alclevel (. = 99)
label define alclevel 99 "Missing", add
tab1 alclevel, missing


//Alcohol consumption (most recent at index date)
preserve
	keep pracid patid antipsychotic_first
	merge 1:m pracid patid using 3_builds/alcvalue
	keep if _merge == 3
	drop _merge
	drop if alcvalue_date > antipsychotic_first
	merge m:1 medcodeid using codelists/alcohol_consumption
	keep if _merge == 3
	drop _merge observations originalreadcode cleansedreadcode ///
		snomedctconceptid snomedctdescriptionid alcohol alcstatus alclevel
	tab1 alcvalue_units, sort missing
	tab1 alcvalue_units, sort missing nolabel
	tab1 alcvalue_units ///
		if inlist(alcvalue_units, 290, 278, 380, 291, 62, 1620, 682, 1904, ///
			2262, 1096, 1848), sort missing
	tab1 alcvalue_units ///
		if !inlist(alcvalue_units, 290, 278, 380, 291, 62, 1620, 682, 1904, ///
			2262, 1096, 1848), sort missing
	keep if inlist(alcvalue_units, 290, 278, 380, 291, 62, 1620, 682, 1904, ///
			2262, 1096, 1848)
	drop medcodeid term alcvalue_units
	rename alcvalue units_per_week
	rename alcvalue_date units_date
	tab units_per_week, missing
	drop if units_per_week > 0 & units_per_week < 0.1  //less than 0.1 probably an error
	drop if units_per_week > 840  //equivalent to 3 litres of spirits per day
	label define unitcat 0 "0 units/week" 1 "<=14 units/week" 2 ">14 units/week"
	generate unitcat = 0 if units_per_week == 0
	replace unitcat = 1 if units_per_week > 0 & units_per_week <= 14
	replace unitcat = 2 if units_per_week > 14
	label values unitcat unitcat
	gsort pracid patid -units_date -unitcat  //sort highest exposure first
	by pracid patid: keep if _n == 1
	keep pracid patid units_date unitcat
	tempfile alcval
	save `alcval'
restore
merge 1:1 pracid patid using `alcval', nogenerate
recode unitcat (. = 99)
label define unitcat 99 "Missing", add
tab1 unitcat, missing


//Alcohol use disorder (first diagnosis; exclude diagnoses after index date)
preserve
	keep pracid patid antipsychotic_first
	merge 1:m pracid patid using 3_builds/alcohol_use_disorder
	drop if _merge == 2
	drop _merge medcodeid
	drop if alcohol_use_disorder_date > antipsychotic_first
	gsort pracid patid alcohol_use_disorder_date
	by pracid patid: keep if _n == 1
	keep pracid patid alcohol_use_disorder_date alcohol_use_disorder
	tempfile alcohol
	save `alcohol'
restore
merge 1:1 pracid patid using `alcohol', nogenerate
recode alcohol_use_disorder (. = 0)
tab alcohol_use_disorder, missing


//Baseline outcome results (most recent value before initiation)
local outcomes "hba1c cholesterol_ldl bp_systolic weight"
foreach outcome of local outcomes {
	
	preserve
		keep pracid patid antipsychotic_first
		merge 1:m pracid patid using 3_builds/`outcome'_clean
		keep if _merge == 3
		drop _merge
		drop if `outcome'_date > antipsychotic_first
		//remove measures from more than 2 years ago
		drop if `outcome'_date < antipsychotic_first-(365.25*2)
		collapse (mean) `outcome', by(pracid patid `outcome'_date)  //avg for same day
		gsort pracid patid -`outcome'_date
		by pracid patid: keep if _n == 1
		keep pracid patid `outcome'_date `outcome'
		
		rename `outcome'_date bl_`outcome'_date
		label variable bl_`outcome'_date "Date of baseline `outcome' measurement"
		rename `outcome' bl_`outcome'
		label variable bl_`outcome' "Baseline `outcome' value"
		
		if "`outcome'" == "hba1c" {
			
			label define bl_hba1c_cat 1 "Normal" 2 "Prediabetes" 3 "Diabetes" ///
				99 "Missing"
			generate byte bl_hba1c_cat = 1 if bl_hba1c < 42
			replace bl_hba1c_cat = 2 if bl_hba1c >= 42 & bl_hba1c < 48
			replace bl_hba1c_cat = 3 if bl_hba1c >= 48
			label values bl_hba1c_cat bl_hba1c_cat
			label variable bl_hba1c_cat "HbA1c status at baseline"
			label variable bl_hba1c "Baseline HbA1c value"
		}
		
		tempfile `outcome'_tmp
		save ``outcome'_tmp'
	restore
	
	merge 1:1 pracid patid using ``outcome'_tmp', update replace
	drop _merge
}
recode bl_hba1c_cat (. = 99)


//Label variables
label values alcohol_use_disorder yn

label variable ethnicity "Ethnicity"
label variable smoking_status "Smoking status"
label variable smoking_status_date "Date of smoking status"
label variable alcstatus_date "Date of alcohol status"
label variable alcstatus "Alcohol status"
label variable alclevel_date "Date of alcohol level record"
label variable alclevel "Level of alcohol drinking"
label variable units_date "Date of alcohol consumption record"
label variable unitcat "Units of alcohol consumed per week"
label variable alcohol_use_disorder "Alcohol use disorder"
label variable alcohol_use_disorder_date "Date of first alcohol use disorder diagnosis code"

describe
tab1 ethnicity smoking_status alcstatus alclevel unitcat alcohol_use_disorder bl_hba1c_cat, missing


compress
save 3_builds/cohort_baseline, replace


// Print time taken to run the do file
local runtime = clock("$S_DATE $S_TIME", "DMY hms") - `start'
display "Runtime: " floor(`runtime'/60000) " minutes " mod(`runtime'/1000, 60) " seconds"

log close
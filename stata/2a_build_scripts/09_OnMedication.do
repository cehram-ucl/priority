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
log using "2b_build_logs/09_OnMedication_`date'_`time'", text replace

// Study constants
local study_start = dmy(1, 1, 2000)
local study_end = dmy(31, 12, 2019)
local build_date = dmy(1, 9, 2023)  //Sep 2023 Build


// ON STATIN MEDICATION
//======================

//Simply defined as the period between their first ever and last ever statin prescription

use 3_builds/cohort_baseline, clear
count
keep pracid patid antipsychotic_first

//Merge with statins
merge 1:m pracid patid using 3_builds/lipid_lowering
keep if _merge == 3
drop _merge

//Just keep statins
keep if statin == 1
rename lipid_lowering_date statin_date
drop prodcodeid quantity quantunitid duration lipid_lowering statin

gsort pracid patid statin_date

//Check for second prescription within 90 days
by pracid patid: generate in90 = 1 if _n != _N ///
	& statin_date >= statin_date[_n+1]-90
tab1 in90, missing

preserve
	by pracid patid: keep if _n == 1
	keep if in90 == 1
	drop in90
	drop if statin_date > antipsychotic_first
	generate byte bl_onstatin = 1
	label variable bl_onstatin "Patient on statin medication at baseline"
	tempfile onstatin
	save `onstatin'
restore

preserve
	by pracid patid: keep if _n == 1
	keep if in90 == 1
	drop in90
	drop if statin_date > antipsychotic_first + 90
	drop if statin_date < antipsychotic_first - 90
	generate byte initiatied_statin = 1
	label variable initiatied_statin "Initiated statin within 3 months (pre-/post-) of antipsychotic"
	tempfile initiatestatin
	save `initiatestatin'
restore

drop antipsychotic_first
drop in90  //>97%

preserve
	by pracid patid: keep if _n == 1
	rename statin_date statin_first
	label variable statin_first "Date of first statin prescription"
	tempfile first_statin
	save `first_statin'
restore

gsort pracid patid -statin_date

preserve
	by pracid patid: keep if _n == 1
	rename statin_date statin_last
	label variable statin_last "Date of last statin prescription"
	tempfile last_statin
	save `last_statin'
restore


// ON ANTIHYPERTENSIVE MEDICATION
//================================

//Simply defined as the period between their first ever and last ever statin prescription

use 3_builds/cohort_baseline, clear
count
keep pracid patid

//Merge with statins
merge 1:m pracid patid using 3_builds/antihypertensive
keep if _merge == 3
drop _merge
drop prodcodeid quantity quantunitid duration antihypertensive antihypertensive_medication

gsort pracid patid antihypertensive_date

//Check for second prescription within 90 days
by pracid patid: generate in90 = 1 if _n != _N ///
	& antihypertensive_date >= antihypertensive_date[_n+1]-90
tab1 in90, missing
drop in90  //>97%

preserve
	by pracid patid: keep if _n == 1
	rename antihypertensive_date antihypertensive_first
	label variable antihypertensive_first "Date of first antihypertensive prescription"
	tempfile first_antihypertensive
	save `first_antihypertensive'
restore

gsort pracid patid -antihypertensive_date

preserve
	by pracid patid: keep if _n == 1
	rename antihypertensive_date antihypertensive_last
	label variable antihypertensive_last "Date of last antihypertensive prescription"
	tempfile last_antihypertensive
	save `last_antihypertensive'
restore


//Merge in medications a patient is on to main dataset
use 3_builds/cohort_baseline, clear

merge m:1 pracid patid using `onstatin', nogenerate keep(master match)
merge m:1 pracid patid using `initiatestatin', nogenerate keep(master match)
merge m:1 pracid patid using `first_statin', nogenerate keep(master match)
merge m:1 pracid patid using `last_statin', nogenerate keep(master match)
merge m:1 pracid patid using `first_antihypertensive', nogenerate keep(master match)
merge m:1 pracid patid using `last_antihypertensive', nogenerate keep(master match)

recode bl_onstatin initiatied_statin (. = 0)
label values bl_onstatin initiatied_statin yn

tab1 bl_onstatin initiatied_statin, missing

summarize statin_first statin_last antihypertensive_first antihypertensive_last, detail

compress
save 3_builds/cohort_baseline_medication, replace


// Print time taken to run the do file
local runtime = clock("$S_DATE $S_TIME", "DMY hms") - `start'
display "Runtime: " floor(`runtime'/60000) " minutes " mod(`runtime'/1000, 60) " seconds"

log close
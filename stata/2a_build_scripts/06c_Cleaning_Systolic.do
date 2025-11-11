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
log using "2b_build_logs/06c_Cleaning_Systolic_`date'_`time'", text replace

// Study constants
local study_start = dmy(1, 1, 2000)
local study_end = dmy(31, 12, 2019)
local build_date = dmy(1, 9, 2023)  //Sep 2023 Build


//Open blood pressure events
use 3_builds/bp, clear
count

//Add term to improve clarity
merge m:1 medcodeid using codelists/blood_pressure, keepusing(term systolic_bp diastolic_bp bp_type)

//Codes that didn't match
list medcodeid term systolic_bp diastolic_bp bp_type if _merge == 2
keep if _merge == 3
drop _merge
tab term, sort missing

//Drop measures without a value
drop if bp == .
drop if bp == 0

//Limit to just systolic codes (not many BP codes with both values - 0.03% of all)
tab1 systolic_bp diastolic_bp bp_type, missing
tab systolic_bp diastolic_bp, missing
keep if systolic_bp == 1
tab1 systolic_bp diastolic_bp bp_type, missing
drop systolic_bp diastolic_bp bp_type
rename bp bp_systolic
rename bp_date bp_systolic_date
rename bp_units bp_systolic_units

//Most used term/medcode
tab1 term medcodeid, sort missing

//Most used units
tab bp_systolic_units, sort missing
tab bp_systolic_units, sort missing nolabel

tab1 medcodeid term bp_systolic_units ///
	if inlist(bp_systolic_units, 210, 216, 215, 212, 1207, ., 2391, ///
	3759, 11071, 1452, 178, 1155, 4003, 1209, 905, 22349, 7714), sort missing
tab bp_systolic_units if medcodeid == "114311000006111", sort missing
tab bp_systolic_units if medcodeid == "114311000006111", sort missing nolabel
summarize bp_systolic if inlist(bp_systolic_units, 210, 216, 215, 212, 1207, ., 2391, ///
	3759, 11071, 1452, 178, 1155, 4003, 1209, 905, 22349, 7714), detail

//Overly aggressive cleaning
count
keep if medcodeid == "114311000006111" & inlist(bp_systolic_units, 210, 216, 215, 212, ///
	1207, ., 2391, 3759, 11071, 1452, 178, 1155, 4003, 1209, 905, 22349, 7714)
drop medcodeid term
duplicates drop pracid patid bp_systolic_date bp_systolic, force
count

//Remove impossible values
//drop if bp > 400

//Remove extreme values (top and bottom 0.1%)
local pcvar "bp_systolic"
summarize `pcvar', detail
local bottom_1pc = r(p1)
local top_1pc = r(p99)

summarize `pcvar' if `pcvar' < `bottom_1pc', detail
local bottom_01pc = r(p10)

summarize `pcvar' if `pcvar' < `bottom_01pc', detail
drop if `pcvar' < `bottom_01pc'

summarize `pcvar' if `pcvar' > `top_1pc', detail
local top_01pc = r(p90)

summarize `pcvar' if `pcvar' > `top_01pc', detail
drop if `pcvar' > `top_01pc'

summarize `pcvar', detail


//Label variables
label variable bp_systolic_date "Date of blood pressure result"
label variable bp_systolic "Systolic blood pressure (mmHg)"
label variable bp_systolic_units "Units of blood pressure result"


compress
save 3_builds/bp_systolic_clean, replace


// Print time taken to run the do file
local runtime = clock("$S_DATE $S_TIME", "DMY hms") - `start'
display "Runtime: " floor(`runtime'/60000) " minutes " mod(`runtime'/1000, 60) " seconds"

log close
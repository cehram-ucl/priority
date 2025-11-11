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
log using "2b_build_logs/06b_Cleaning_LDL-C_`date'_`time'", text replace

// Study constants
local study_start = dmy(1, 1, 2000)
local study_end = dmy(31, 12, 2019)
local build_date = dmy(1, 9, 2023)  //Sep 2023 Build


//Open cholesterol events
use 3_builds/cholesterol, clear
count

//Add term to improve clarity
merge m:1 medcodeid using codelists/cholesterol, keepusing(term cholesterol_type)

//Codes that didn't match
list medcodeid term cholesterol_type if _merge == 2
keep if _merge == 3
drop _merge

//Drop measures without a value
drop if cholesterol == .
drop if cholesterol == 0

//Restrict to just LDL codes
tab1 cholesterol_type, missing
keep if cholesterol_type == 3
tab1 cholesterol_type, missing
drop triglycerides ldl non_hdl hdl total ratio vldl cholesterol_type
rename cholesterol cholesterol_ldl
rename cholesterol_date cholesterol_ldl_date
rename cholesterol_units cholesterol_ldl_units

//Most used term/medcode
tab1 term medcodeid, sort missing

//Most used units
tab cholesterol_ldl_units, sort missing
tab cholesterol_ldl_units, sort missing nolabel
tab cholesterol_ldl_units if inlist(cholesterol_ldl_units, 218, 1145, 1595, 2693, 847), sort

tab term if inlist(cholesterol_ldl_units, 218, 1145, 1595, 2693, 847), sort missing
tab term if !inlist(cholesterol_ldl_units, 218, 1145, 1595, 2693, 847), sort missing
summarize cholesterol_ldl ///
	if inlist(cholesterol_ldl_units, 218, 1145, 1595, 2693, 847), detail
summarize cholesterol_ldl ///
	if !inlist(cholesterol_ldl_units, 218, 1145, 1595, 2693, 847), detail
summarize cholesterol_ldl ///
	if cholesterol_ldl_units == ., detail

//Aggressive cleaning (still retains over 95% of values though)
count
keep if inlist(cholesterol_ldl_units, 218, 1145, 1595, 2693, 847)
drop medcodeid term
duplicates drop pracid patid cholesterol_ldl_date cholesterol_ldl, force
count

//Remove extreme values (top and bottom 0.1%)
local pcvar "cholesterol_ldl"
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
label variable cholesterol_ldl_date "Date of LDL cholesterol result"
label variable cholesterol_ldl "LDL cholesterol (mmol/L)"
label variable cholesterol_ldl_units "Units for LDL cholesterol result"


compress
save 3_builds/cholesterol_ldl_clean, replace


// Print time taken to run the do file
local runtime = clock("$S_DATE $S_TIME", "DMY hms") - `start'
display "Runtime: " floor(`runtime'/60000) " minutes " mod(`runtime'/1000, 60) " seconds"

log close
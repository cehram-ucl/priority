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
log using "2b_build_logs/06a_Cleaning_HbA1c_`date'_`time'", text replace

// Study constants
local study_start = dmy(1, 1, 2000)
local study_end = dmy(31, 12, 2019)
local build_date = dmy(1, 9, 2023)  //Sep 2023 Build


//Open HbA1c events
use 3_builds/hba1c, clear
count

//Add term to improve clarity
merge m:1 medcodeid using codelists/hba1c, keepusing(term target)

list medcodeid term target if _merge == 2
keep if _merge == 3
tab1 target, missing
drop target _merge

//Drop measures without a value
drop if hba1c == .
drop if hba1c == 0

//Most used term/medcode
tab1 term medcodeid, sort missing

//check for specific IFCC/DCCT codes
tab1 term medcodeid hba1c_units if strmatch(lower(term), "*ifcc*"), sort missing
tab1 term medcodeid hba1c_units if strmatch(lower(term), "*dcct*"), sort missing

//Most used units
tab hba1c_units, sort missing
tab hba1c_units, sort missing nolabel

//mmol/mol (IFCC) (Note: hba1c_units = numunitid) (rounded to whole number)
tab1 hba1c_units term if inlist(hba1c_units, 220, 892, 879, 1031, 916, 1675, ///
	917, 2824, 219, 332, 959, 6210, 2985), sort missing
summarize hba1c if inlist(hba1c_units, 220, 892, 879, 1031, 916, 1675, ///
	917, 2824, 219, 332, 959, 6210, 2985), detail

generate double hba1c_mmol_mol = round(hba1c) if inlist(hba1c_units, 220, 892, 879, ///
	1031, 916, 1675, 917, 2824, 219, 332, 959, 6210, 2985)
	
//% (DCCT) (rounded to whole number)
tab1 hba1c_units term if inlist(hba1c_units, 1, 246, 1043, 355, 849, 1396, ///
	912, 1192, 2, 1594, 2758, 2161, 860, 1844, 1282, 1905, 3411, 2290, 1570, ///
	1697, 2990, 6427), sort missing
summarize hba1c if inlist(hba1c_units, 1, 246, 1043, 355, 849, 1396, ///
	912, 1192, 2, 1594, 2758, 2161, 860, 1844, 1282, 1905, 3411, 2290, 1570, ///
	1697, 2990, 6427), detail

generate double hba1c_pc = round(hba1c) if inlist(hba1c_units, 1, 246, 1043, 355, ///
	849, 1396, 912, 1192, 2, 1594, 2758, 2161, 860, 1844, 1282, 1905, 3411, ///
	2290, 1570, 1697, 2990, 6427)

//Convert % to mmol/mol (rounded to whole number)
replace hba1c_mmol_mol = round((hba1c_pc - 2.14) * 10.929) if hba1c_pc != .
summarize hba1c_mmol_mol, detail

//Check data without units or wrong units
summarize hba1c if hba1c_mmol_mol == ., detail
tab term if hba1c_mmol_mol == ., sort missing

count
drop if hba1c_mmol_mol == .
drop if hba1c_mmol_mol < 1
drop if hba1c_mmol_mol > 1000  //still ridiculous
drop medcodeid term hba1c hba1c_units hba1c_pc
duplicates drop
count

/*
//Convert units
generate double hba1c_pc = round((hba1c * 0.0915) + 2.15, 0.1)
generate double hba1c_mmol_mol = round((hba1c * 10.93) - 23.5)
*/

//Remove extreme values (top and bottom 0.1%)
local pcvar "hba1c_mmol_mol"
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
label variable hba1c_date "Date of HbA1c measurement"
label variable hba1c_mmol_mol "HbA1c (mmol/mol)"
rename hba1c_mmol_mol hba1c  //to make variable consistent for subsequent do files


compress
save 3_builds/hba1c_clean, replace


// Print time taken to run the do file
local runtime = clock("$S_DATE $S_TIME", "DMY hms") - `start'
display "Runtime: " floor(`runtime'/60000) " minutes " mod(`runtime'/1000, 60) " seconds"

log close
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
log using "2b_build_logs/06d_Cleaning_Weight_`date'_`time'", text replace

// Study constants
local study_start = dmy(1, 1, 2000)
local study_end = dmy(31, 12, 2019)
local build_date = dmy(1, 9, 2023)  //Sep 2023 Build


//Open weight events
use 3_builds/weight, clear
count

//Add term to improve clarity
merge m:1 medcodeid using codelists/body_mass_index, keepusing(term height bmi) update replace

list medcodeid term height bmi if _merge == 2
keep if _merge == 3
drop _merge

//Remove height & BMI codes
count
tab term if bmi == 1
tab term if height == 1
drop if height == 1
drop if bmi == 1
drop height bmi

//Drop measures without a value
drop if weight == .
drop if weight == 0

//Most used term/medcode
tab1 term medcodeid, sort missing

//Most used units
tab weight_units, sort missing
tab weight_units, sort missing nolabel

tab1 term medcodeid weight_units if inlist(weight_units, 156, 827, 3283, 1778, 2400, 3906, 2514, 10179, 10185), sort missing
tab weight_units if medcodeid == "253677014", sort missing

//Cleaning (removes approx 1%)
count
keep if medcodeid == "253677014" & inlist(weight_units, 156, 827, 3283, 1778, 2400, 3906, 2514, 10179, 10185)
drop medcodeid term
duplicates drop pracid patid weight_date weight, force
count

//Remove extreme values (top and bottom 0.1%)
local pcvar "weight"
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
label variable weight_date "Date of weight measurement"
label variable weight "Weight (Kg)"
label variable weight_units "Units of weight measurement"


compress
save 3_builds/weight_clean, replace


// Print time taken to run the do file
local runtime = clock("$S_DATE $S_TIME", "DMY hms") - `start'
display "Runtime: " floor(`runtime'/60000) " minutes " mod(`runtime'/1000, 60) " seconds"

log close
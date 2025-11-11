clear all
macro drop _all
set more off

// Set working directory (project folder)
cd "S:\CALIBER_23_003266\Phil"

// Record start time to benchmark processing time of do file
global start = clock("$S_DATE $S_TIME", "DMY hms")
global datetime = subinstr("$S_DATE", " ", "", .) + "_" + subinstr("$S_TIME", ":", "", .)

// Open log file
capture log close
log using "4b_analysis_logs/Weight_randomslope_$datetime", smcl replace

// Study constants
local study_start = dmy(1, 1, 2000)
local study_end = dmy(31, 12, 2019)
local build_date = dmy(1, 9, 2023)  //Sep 2023 Build


do 4a_analysis_scripts/analysis_randomslope_v4 weight "Weight" "Kg"


// Print time taken to run the do file
local runtime = clock("$S_DATE $S_TIME", "DMY hms") - $start
display "Runtime: " floor(`runtime'/60000) " minutes " mod(`runtime'/1000, 60) " seconds"

log close
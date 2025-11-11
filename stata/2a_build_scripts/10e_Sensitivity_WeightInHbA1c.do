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
log using "2b_build_logs/10e_Sensitivity_WeightInHbA1c_$datetime", text replace

// Study constants
local study_start = dmy(1, 1, 2000)
local study_end = dmy(31, 12, 2019)
local build_date = dmy(1, 9, 2023)  //Sep 2023 Build


//Outcome name
local name "Weight (HbA1c & weight cohort)"


//Generate variables to indicate which cohorts a patient is in
foreach cohort in hba1c /*cholesterol_ldl bp_systolic*/ weight {
	
	use 3_builds/cohort_baseline_medication_`cohort', clear
	keep pracid patid
	bysort pracid patid: keep if _n == 1
	generate byte `cohort'_result = 1
	tempfile `cohort'
	save ``cohort''
}


//Generate final dataset for analysis
use 3_builds/cohort_baseline_medication, clear
count


//Merge in cohort indicators
foreach cohort in hba1c /*cholesterol_ldl bp_systolic*/ weight {
	
	merge 1:1 pracid patid using ``cohort''
	drop _merge
	recode `cohort'_result (. = 0)
	label values `cohort'_result yn
	tab `cohort'_result, missing
}
label variable hba1c_result "People with one or more HbA1c result"
//label variable cholesterol_ldl_result "People with one or more LDL cholesterol result"
//label variable bp_systolic_result "People with one or more systolic blood pressure result"
label variable weight_result "People with one or more weight result"

tab1 *_result, missing
tab hba1c_result weight_result, missing row
keep if hba1c_result == 1 & weight_result == 1
tab1 *_result, missing
drop *_result
count
local denominator = r(N)
generate N = _N
tab1 N, missing

//Make Gender label a bit clearer
codebook gender
label list Gender
label define Gender 1 "Male" 2 "Female", modify
label list Gender
codebook gender
label variable gender "Sex"

preserve
	//Merge clean outcome results to get data in long format
	merge 1:m pracid patid using 3_builds/cohort_baseline_medication_weight
	keep if _merge == 3
	drop _merge
	
	duplicates drop

	//Average multiple values on same day
	collapse (mean) weight, by(pracid patid weight_date)
	
	tempfile weight_1perday
	save `weight_1perday'
restore

merge 1:m pracid patid using `weight_1perday'
keep if _merge == 3
drop _merge

//Remove events after end of follow-up
drop if weight_date > end_fu

//Looking back 2 years instead of until start of follow-up
//as this allows us to include measures from previous practices
drop if weight_date < antipsychotic_first - (365.25*2)

count

gsort pracid patid weight_date

//Generate variables for analysis
generate weight_day = round(weight_date - antipsychotic_first)
//generate weight_week = wofd(weight_date) - wofd(antipsychotic_first)
label variable weight_day "Day of weight result"
//label variable weight_week "Week of weight result"

mkspline ls1 0 ls2 90 ls3 = weight_day
//mkspline ls1 0 ls2 12 ls3 = weight_week

label variable ls1 "`name' pre-baseline: Up to day 0"
label variable ls2 "`name' post-baseline (short-term): Day 0 to 90"
label variable ls3 "`name' post-baseline (long-term): Day 90 onwards"

rename weight* weightinhba1c*

compress
save 3_builds/cohort_baseline_medication_weightinhba1c, replace


//Open Word file for graphs
putdocx begin
putdocx paragraph, style(Heading1)
putdocx text ("`name' missing data")
putdocx paragraph

//Graph showing measurements for each person over time
putdocx paragraph, style(Heading2)
putdocx text ("Measures of weight over time for each patient")
putdocx paragraph
graph twoway scatter tspatid weightinhba1c_day, ///
	msize(vtiny) ///
	xline(0) xtitle("Days since antipsychotic initiation") ///
	title("Records of `name'")
graph save "5_outputs/weightinhba1c_measurements_$datetime"
graph export "5_outputs/weightinhba1c_measurements_$datetime.png", replace
graph export "5_outputs/weightinhba1c_measurements.png", replace
putdocx image "5_outputs/weightinhba1c_measurements_$datetime.png", linebreak(1)


//Graph showing who is contributing data over time
keep tspatid weightinhba1c_day
bysort tspatid weightinhba1c_day: keep if _n == 1

//Plot of % of cohort contributing data at specific time point
preserve
	collapse (count) patids_pday_current = tspatid, by(weightinhba1c_day)
	generate double pc_contrib_current = ///
		round((patids_pday_current/`denominator') * 100, .01)
	label variable pc_contrib_current "Weight measured"
	tempfile contrib_current
	save `contrib_current'
	//twoway bar pc_contrib_current weightinhba1c_day, name(weight_3, replace)
restore

//Plot of % of cohort contributing data during time interval
tsset tspatid weightinhba1c_day
tsfill
collapse (count) patids_pday_full = tspatid, by(weightinhba1c_day)
generate double pc_contrib_full = round((patids_pday_full/`denominator') * 100, .01)
label variable pc_contrib_full "Contributing weight data"
tempfile contrib_full
save `contrib_full'
//twoway bar pc_contrib_full weightinhba1c_day, name(weight_2, replace)

//Plot of % of cohort contributing follow-up at time point
use 3_builds/cohort_baseline_medication_weightinhba1c, clear
keep tspatid pracid patid gender agebands region e2019_imd_5_patient ethnicity ///
	start_fu end_fu antipsychotic_first ///
	ap_med smoking_status unitcat
duplicates drop
generate fu_day1 = round(start_fu - antipsychotic_first)
//generate fu_week1 = wofd(start_fu) - wofd(antipsychotic_first)
generate fu_day2 = round(end_fu - antipsychotic_first)
//generate fu_week2 = wofd(end_fu) - wofd(antipsychotic_first)
reshape long fu_day, i(tspatid) j(startend)
bysort tspatid fu_day: keep if _n == 1  //for people with just one day of FU
keep tspatid fu_day
tsset tspatid fu_day
tsfill
collapse (count) patids_followup = tspatid, by(fu_day)
generate double pc_fu = round((patids_followup/`denominator') * 100, .01)
label variable pc_fu "In follow-up"
//twoway bar pc_fu fu_day, name(weight_1, replace)

rename fu_day weightinhba1c_day
label variable weightinhba1c_day "Day of weight result"
merge 1:1 weightinhba1c_day using `contrib_full', nogenerate
merge 1:1 weightinhba1c_day using `contrib_current', nogenerate

putdocx paragraph, style(Heading2)
putdocx text ("Proportion of cohort in follow-up and contributing weight data over time")
putdocx paragraph
twoway bar pc_fu pc_contrib_full pc_contrib_current weightinhba1c_day, ///
	title("Data over time: `name'") ///
	ytitle("% of cohort") ///
	xline(0) xtitle("Days since antipsychotic initiation") ///
	legend(ring(0) position(2) cols(1) margin(zero) size(small) ///
		region(fcolor(none) lcolor(none)))
graph save "5_outputs/weightinhba1c_missing_$datetime"
graph export "5_outputs/weightinhba1c_missing_$datetime.png", replace
graph export "5_outputs/weightinhba1c_missing.png", replace
putdocx image "5_outputs/weightinhba1c_missing_$datetime.png", linebreak(1)

summarize pc_fu pc_contrib_full pc_contrib_current weightinhba1c_day, detail


putdocx save "5_outputs/weightinhba1c_missingdata", replace
copy "5_outputs/weightinhba1c_missingdata.docx" ///
	"5_outputs/weightinhba1c_missingdata_$datetime.docx", replace


// Print time taken to run the do file
local runtime = clock("$S_DATE $S_TIME", "DMY hms") - $start
display "Runtime: " floor(`runtime'/60000) " minutes " mod(`runtime'/1000, 60) " seconds"

log close
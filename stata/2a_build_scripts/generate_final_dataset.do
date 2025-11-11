//Arguments: outcome variable; Name of variable in string format
args outcome name


//Generate final dataset for analysis
use 3_builds/cohort_baseline_medication, clear
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
	merge 1:m pracid patid using 3_builds/`outcome'_clean
	keep if _merge == 3
	drop _merge
	
	duplicates drop

	//Average multiple values on same day
	collapse (mean) `outcome', by(pracid patid `outcome'_date)
	
	tempfile `outcome'_1perday
	save ``outcome'_1perday'
restore

merge 1:m pracid patid using ``outcome'_1perday'
keep if _merge == 3
drop _merge

//Remove events after end of follow-up
drop if `outcome'_date > end_fu

//Looking back 2 years instead of until start of follow-up
//as this allows us to include measures from previous practices
drop if `outcome'_date < antipsychotic_first - (365.25*2)

count

gsort pracid patid `outcome'_date

//Generate variables for analysis
generate `outcome'_day = round(`outcome'_date - antipsychotic_first)
//generate `outcome'_week = wofd(`outcome'_date) - wofd(antipsychotic_first)
label variable `outcome'_day "Day of `name' result"
//label variable `outcome'_week "Week of `name' result"

mkspline ls1 0 ls2 90 ls3 = `outcome'_day
//mkspline ls1 0 ls2 12 ls3 = `outcome'_week

label variable ls1 "`name' pre-baseline: Up to day 0"
label variable ls2 "`name' post-baseline (short-term): Day 0 to 90"
label variable ls3 "`name' post-baseline (long-term): Day 90 onwards"

compress
save 3_builds/cohort_baseline_medication_`outcome', replace


//Open Word file for graphs
putdocx begin
putdocx paragraph, style(Heading1)
putdocx text ("`name' missing data")
putdocx paragraph

//Graph showing measurements for each person over time
putdocx paragraph, style(Heading2)
putdocx text ("Measures of `name' over time for each patient")
putdocx paragraph
graph twoway scatter tspatid `outcome'_day, ///
	msize(vtiny) ///
	xline(0) xtitle("Days since antipsychotic initiation") ///
	title("Records of `name'")
graph save "5_outputs/`outcome'_measurements_$datetime"
graph export "5_outputs/`outcome'_measurements_$datetime.png", replace
graph export "5_outputs/`outcome'_measurements.png", replace
putdocx image "5_outputs/`outcome'_measurements_$datetime.png", linebreak(1)


//Graph showing who is contributing data over time
keep tspatid `outcome'_day
bysort tspatid `outcome'_day: keep if _n == 1

//Plot of % of cohort contributing data at specific time point
preserve
	collapse (count) patids_pday_current = tspatid, by(`outcome'_day)
	generate double pc_contrib_current = ///
		round((patids_pday_current/`denominator') * 100, .01)
	label variable pc_contrib_current "`name' measured"
	tempfile contrib_current
	save `contrib_current'
	//twoway bar pc_contrib_current `outcome'_day, name(`outcome'_3, replace)
restore

//Plot of % of cohort contributing data during time interval
tsset tspatid `outcome'_day
tsfill
collapse (count) patids_pday_full = tspatid, by(`outcome'_day)
generate double pc_contrib_full = round((patids_pday_full/`denominator') * 100, .01)
label variable pc_contrib_full "Contributing `name' data"
tempfile contrib_full
save `contrib_full'
//twoway bar pc_contrib_full `outcome'_day, name(`outcome'_2, replace)

//Plot of % of cohort contributing follow-up at time point
use 3_builds/cohort_baseline, clear
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
//twoway bar pc_fu fu_day, name(`outcome'_1, replace)

rename fu_day `outcome'_day
label variable `outcome'_day "Day of `name' result"
merge 1:1 `outcome'_day using `contrib_full', nogenerate
merge 1:1 `outcome'_day using `contrib_current', nogenerate

putdocx paragraph, style(Heading2)
putdocx text ("Proportion of cohort in follow-up and contributing `name' data over time")
putdocx paragraph
twoway bar pc_fu pc_contrib_full pc_contrib_current `outcome'_day, ///
	title("Data over time: `name'") ///
	ytitle("% of cohort") ///
	xline(0) xtitle("Days since antipsychotic initiation") ///
	legend(ring(0) position(2) cols(1) margin(zero) size(small) ///
		region(fcolor(none) lcolor(none)))
graph save "5_outputs/`outcome'_missing_$datetime"
graph export "5_outputs/`outcome'_missing_$datetime.png", replace
graph export "5_outputs/`outcome'_missing.png", replace
putdocx image "5_outputs/`outcome'_missing_$datetime.png", linebreak(1)

summarize pc_fu pc_contrib_full pc_contrib_current `outcome'_day, detail


putdocx save "5_outputs/`outcome'_missingdata", replace
copy "5_outputs/`outcome'_missingdata.docx" ///
	"5_outputs/`outcome'_missingdata_$datetime.docx", replace
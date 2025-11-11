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
log using "4b_analysis_logs/TimeToDiabetes_`date'_`time'", smcl replace


//Generate variables to indicate which cohorts a patient is in
foreach cohort in hba1c weight {
	
	use 3_builds/cohort_baseline_medication_`cohort', clear
	keep pracid patid
	bysort pracid patid: keep if _n == 1
	generate byte `cohort' = 1
	tempfile `cohort'
	save ``cohort''
}


//Start with baseline cohort
use 3_builds/cohort_baseline_medication, clear
count

tab gender, missing
label variable gender "Sex"
label list Gender
label define sex 1 "Male" 2 "Female"
label values gender sex
tab gender, missing

//Merge in cohort indicators
foreach cohort in hba1c weight {
	
	merge 1:1 pracid patid using ``cohort''
	drop _merge
	recode `cohort' (. = 0)
	label values `cohort' yn
	tab `cohort', missing
}
label variable hba1c "People with one or more HbA1c result"
label variable weight "People with one or more weight result"

generate byte hba1cANDweight = (hba1c == 1 & weight == 1)
label values hba1cANDweight yn
label variable hba1cANDweight "People with HbA1c & weight results"
tab hba1cANDweight, missing


//Open Word document
putdocx begin
putdocx paragraph, style(Title)
putdocx text ("Time to Diabetes diagnosis/prescription")


stset end_fu, id(tspatid) failure(t2dm) origin(time antipsychotic_first) ///
	enter(time start_fu) exit(time min(t2dm_date, end_fu)) scale(365.25)
	
sts graph, by(bl_hba1c_cat)
graph save "5_outputs/KM_timetodiabetes", replace
graph export "5_outputs/KM_timetodiabetes.png", replace
putdocx image "5_outputs/KM_timetodiabetes.png", linebreak(1)

sts graph, by(bl_hba1c_cat) risktable(, failevents size(small) ///
	title("No. at risk (failed)", size(small)) rowtitle(, size(small)))
graph save "5_outputs/KM_timetodiabetes_table", replace
graph export "5_outputs/KM_timetodiabetes_table.png", replace
putdocx image "5_outputs/KM_timetodiabetes_table.png", linebreak(1)

sts list, risktable(0(0.25)2) by(bl_hba1c_cat)

sts list, risktable(0(0.25)2) by(bl_hba1c_cat) compare

putdocx save "5_outputs/TimeToDiabetes", replace
copy "5_outputs/TimeToDiabetes.docx" "5_outputs/TimeToDiabetes_`date'_`time'.docx", replace

log close
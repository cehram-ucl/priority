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
log using "2b_build_logs/07_BuildCohort_`date'_`time'", text replace

// Study constants
local study_start = dmy(1, 1, 2000)
local study_end = dmy(31, 12, 2019)
local build_date = dmy(1, 9, 2023)  //Sep 2023 Build


//Start with linkage eligible cohort
use 3_builds/linkage_eligible, clear
count

// Not needed
drop lcd region data_start data_end age_data_start age_data_end

// Remove patients that don't meet acceptable data quality standards
tab acceptable, missing
drop if acceptable == 0
drop acceptable

// Restrict to "Regular" patients only (no "Temporary" or "Other")
label list PatientType
tab patienttypeid, missing
keep if patienttypeid == 3
drop patienttypeid

//drop usualgpstaffid  //don't need

tab gender, missing  //restrict to male and female patients
keep if gender == 1 | gender == 2
tab gender, missing

//Birthday assumed as 1st Jan
//1st Jan rather than 1st July as this resulted in negative time to events associated
//with events around birthdays (can't remember precise examples now, but in a previous
//study I ended up with negative time to certain events that became hard to interpret
//due to the arbitrary choice of 1st July as DOB)
/*gen dob = mdy(1, 1, yob)
gen do40 = mdy(1, 1, yob+40)
order dob do40, after(yob)
format %td dob do40
*/

//Merge Practice data
merge m:1 pracid using 1b_formatted_data/Practice, update replace
keep if _merge >= 3
drop _merge

sum lcd, format


//Check all date variables & remove if after practice last data collection date
summarize /*yob*/ dob regstartdate regenddate /*cprd_ddate*/ deathdate lcd, format detail
count if lcd > `build_date'
drop if regstartdate >= lcd
drop if regenddate >= lcd & regenddate != .
drop if deathdate >= lcd & deathdate != .
summarize /*yob*/ dob regstartdate regenddate deathdate lcd, format


//Label and remove practices with duplicate information that CPRD recommends removing
//https://www.cprd.com/sites/default/files/2024-08/CPRD%20Aurum%20Data%20Specification%20v3.5.pdf
generate byte duplicate_practice = 1 if ///
	pracid == 20024 | pracid == 20036 | pracid == 20091 | pracid == 20171 | ///
	pracid == 20178 | pracid == 20202 | pracid == 20254 | pracid == 20389 | ///
	pracid == 20430 | pracid == 20452 | pracid == 20469 | pracid == 20487 | ///
	pracid == 20552 | pracid == 20554 | pracid == 20640 | pracid == 20717 | ///
	pracid == 20734 | pracid == 20737 | pracid == 20740 | pracid == 20790 | ///
	pracid == 20803 | pracid == 20804 | pracid == 20822 | pracid == 20868 | ///
	pracid == 20908 | pracid == 20912 | pracid == 20996 | pracid == 21001 | ///
	pracid == 21015 | pracid == 21078 | pracid == 21112 | pracid == 21118 | ///
	pracid == 21172 | pracid == 21173 | pracid == 21277 | pracid == 21281 | ///
	pracid == 21331 | pracid == 21334 | pracid == 21390 | pracid == 21430 | ///
	pracid == 21444 | pracid == 21451 | pracid == 21529 | pracid == 21553 | ///
	pracid == 21558 | pracid == 21585

tab1 duplicate_practice, missing
drop if duplicate_practice == 1
drop duplicate_practice


//Merge with IMD data
preserve
	import delimited 1c_linked_data/23_003266_type_2/Results/Aurum_linked/Final/practice_imd_23_003266.txt, clear
	codebook
	rename e2019_imd_5 e2019_imd_5_practice
	keep pracid e2019_imd_5_practice
	tempfile practice_imd
	save `practice_imd'
	
	import delimited 1c_linked_data/23_003266_type_2/Results/Aurum_linked/Final/patient_2019_imd_23_003266.txt, stringcols(1) clear
	
	// Remove last 5 digits from patid and convert to numeric to save storage space
	replace patid = substr(patid, 1, strlen(patid) - 5)
	destring patid, replace
	format %14.0f patid   //after removing last 5 digits, max length is 14 characters
	
	rename e2019_imd_5 e2019_imd_5_patient
	keep pracid patid e2019_imd_5_patient
	tempfile patient_imd
	save `patient_imd'
restore

tab1 lsoa_e, missing
drop lsoa_e

count
merge m:1 pracid using `practice_imd'
drop if _merge == 2
drop _merge

merge 1:1 pracid patid using `patient_imd'
drop if _merge == 2
drop _merge
count

label define imd_quintile 1 "1 (least deprived)" 5 "5 (most deprived)" 99 "Missing"
label values e2019_imd_5_practice e2019_imd_5_patient imd_quintile

tab1 e2019_imd_5_practice e2019_imd_5_patient, missing

//Remove patients without patient-level IMD
tab1 gender region if e2019_imd_5_patient != ., missing
tab1 gender region if e2019_imd_5_patient == ., missing
summarize dob regstartdate regenddate deathdate lcd if e2019_imd_5_patient != ., format
summarize dob regstartdate regenddate deathdate lcd if e2019_imd_5_patient == ., format
drop if e2019_imd_5_patient == .
tab1 e2019_imd_5_practice e2019_imd_5_patient, missing
recode e2019_imd_5_patient (. = 99)
tab1 e2019_imd_5_practice e2019_imd_5_patient, missing


//Get first SMI date
count
preserve
	keep pracid patid regenddate
	merge 1:m pracid patid using 3_builds/smi
	keep if _merge == 3
	drop _merge
	drop if smi_date > regenddate
	gsort pracid patid smi_date
	by pracid patid (smi_date): keep if _n == 1
	rename smi_date smi_first
	rename subtype smi_subtype
	rename medcodeid smi_medcodeid
	tempfile smi
	save `smi'
restore
merge 1:1 pracid patid using `smi', nogenerate
recode smi (. = 0)
tab smi, missing
tab flg_smi smi, missing  //People I can't find an SMI diagnosis for
drop flg_smi smi_ist_dt

//Restrict to people with SMI only
keep if smi == 1
drop smi


//Check for antipsychotic (AP) prescription (non-injected AP)
count
preserve
	keep pracid patid regstartdate regenddate
	merge 1:m pracid patid using 3_builds/antipsychotic_no_injected
	keep if _merge == 3
	tab1 quantunitid solution multiple, missing
	drop _merge prodcodeid dosageid quantity quantunitid duration ///
		solution multiple ap_strength
	drop if antipsychotic_date > regenddate
	
	levelsof antipsychotic_medication, local(levels)
	foreach i of local levels {
		
		local levellab`i': label (antipsychotic_medication) `i'
		display as result "Category: `levellab`i''"
		
		generate byte `levellab`i'' = 1 if antipsychotic_medication == `i'
	}
	collapse (max) Amisulpride-Asenapine, by(pracid patid regstartdate regenddate antipsychotic_date)
	duplicates report pracid patid antipsychotic_date
	
	generate antipsychotic_medication = .
	foreach i of local levels {
		
		replace antipsychotic_medication = `i' if `levellab`i'' == 1
	}
	egen totalap = rowtotal(Amisulpride-Asenapine)
	tab totalap, missing
	replace antipsychotic_medication = 99 if totalap > 1
	label values antipsychotic_medication antipsychotic_medication
	label define antipsychotic_medication 99 "Multiple", add
	tab antipsychotic_medication, sort missing

	//Calculate gap between prescriptions
	gsort pracid patid antipsychotic_date
	by pracid patid (antipsychotic_date): ///
		generate ap_gap = antipsychotic_date[_n+1] - antipsychotic_date

	//Check for second AP prescription within 90 days of first (and not on same day)
	by pracid patid (antipsychotic_date): generate byte in90 = (ap_gap[1] <= 90 ///
		& ap_gap[1] > 0)

	//Check for change of AP between first and second prescription
	by pracid patid (antipsychotic_date): ///
		generate byte ap_change = ///
			(_N > 1 & antipsychotic_medication[1] != antipsychotic_medication[2])

	//Label prescription gaps >180 days to get last prescription before 180 day gap
	generate byte gap180 = (ap_gap > 180 & ap_gap != .)
	generate ap180 = antipsychotic_date if gap180 == 1
	by pracid patid (antipsychotic_date): egen ap180_first = min(ap180)
	by pracid patid (antipsychotic_date): generate ap_last = antipsychotic_date[_N]

	//Label last ever prescription as last if no 180 day gap found
	gen antipsychotic_last = min(ap_last, ap180_first)
	format %td ap180 ap180_first ap_last antipsychotic_last
	
	//Restrict to first AP per person
	by pracid patid (antipsychotic_date): keep if _n == 1
	generate byte antipsychotic = 1
	
	drop Amisulpride-Asenapine totalap  ap_gap gap180 ap180 ap180_first ap_last
	rename antipsychotic_date antipsychotic_first
	
	//Cleaning (people with AP in study period and under GP follow-up)
	drop if antipsychotic_first < regstartdate  //just want incident AP use
	drop if antipsychotic_first < `study_start'
	
	tempfile ap
	save `ap'
restore
merge 1:1 pracid patid using `ap', nogenerate
recode antipsychotic (. = 0)
tab antipsychotic, missing
tab in90

//Restrict to people with second AP prescription in 90 days of their first ever AP
keep if antipsychotic == 1  //No. of people without AP prescription
count
keep if in90 == 1           //No. of people without 2 AP prescriptions in 90 days
drop antipsychotic in90
count

//Generate age at first AP prescription
generate age_1st_antipsychotic = yofd(antipsychotic_first) - yofd(dob)
summarize age_1st_antipsychotic, detail
drop if age_1st_antipsychotic < 1  //unknown date of first antipsychotic
count

//Generate categorical age variable
label define agebands 1 "18-29" 2 "30-39" 3 "40-49" 4 "50-59" 5 "60-69" 6 "70-79" 7 "80+"
generate byte agebands = 1 if age_1st_antipsychotic >= 18
replace agebands = 2 if age_1st_antipsychotic >= 30
replace agebands = 3 if age_1st_antipsychotic >= 40
replace agebands = 4 if age_1st_antipsychotic >= 50
replace agebands = 5 if age_1st_antipsychotic >= 60
replace agebands = 6 if age_1st_antipsychotic >= 70
replace agebands = 7 if age_1st_antipsychotic >= 80
replace agebands = . if age_1st_antipsychotic == .
label values agebands agebands
tab agebands, missing


//Exclusion criteria
//Remove people under 18 years or 60 years and older at antipsychotic initiation
//Remove people with dementia prior to and upto 1 year after antipsychotic initiation
//Remove people with T2DM before antipsychotic initiation

//Age
count
summarize age_1st_antipsychotic, detail
summarize age_1st_antipsychotic if age_1st_antipsychotic < 18, detail
summarize age_1st_antipsychotic if age_1st_antipsychotic >= 18 & ///
	age_1st_antipsychotic < 60, detail
summarize age_1st_antipsychotic if age_1st_antipsychotic >= 60, detail
drop if age_1st_antipsychotic < 18
count
drop if age_1st_antipsychotic >= 60
count

//Dementia
preserve
	keep pracid patid regenddate antipsychotic_first
	merge 1:m pracid patid using 3_builds/dementia
	keep if _merge == 3
	drop _merge medcodeid
	drop if dementia_date > regenddate  //don't need diagnoses after registration end
	gsort pracid patid dementia_date
	by pracid patid: keep if _n == 1
	keep pracid patid dementia_date dementia
	tempfile dementia
	save `dementia'
restore
merge 1:1 pracid patid using `dementia', nogenerate
recode dementia (. = 0)
tab dementia, missing

//T2DM
label define t2dm_cat 1 "Diagnosis" 2 "Prescription" 3 "HbA1c"
preserve
	use patid pracid t2dm_med_date using 3_builds/t2dm_med, clear
	rename t2dm_med_date t2dm_date
	generate byte t2dm_cat = 2
	append using 3_builds/t2dm
	drop medcodeid
	order t2dm_cat, last
	recode t2dm t2dm_cat (. = 1)
	tab1 t2dm t2dm_cat, missing
	compress
	tempfile t2dm_events
	save `t2dm_events'
restore, preserve	
	keep pracid patid regenddate antipsychotic_first
	merge 1:m pracid patid using `t2dm_events'
	keep if _merge == 3
	drop _merge
	drop if t2dm_date > regenddate  //don't need diagnoses after registration end
	gsort pracid patid t2dm_date t2dm_cat  //prioritise diagnosis then prescription
	by pracid patid: keep if _n == 1
	drop regenddate antipsychotic_first t2dm_incprev
	tempfile diabetes
	save `diabetes'
restore
merge 1:1 pracid patid using `diabetes', nogenerate
recode t2dm (. = 0)
label values t2dm_cat t2dm_cat
label variable t2dm_cat "Type-2 Diabetes diagnosis definition"
tab t2dm, missing

//HbA1c values indicating T2DM
preserve
	use 3_builds/hba1c_clean, clear
	drop if hba1c < 48  //Remove values that don't indicate diabetes
	drop hba1c
	rename hba1c_date hba1c48_date
	generate byte hba1c48 = 1
	tempfile t2dm_hba1c
	save `t2dm_hba1c'
restore, preserve	
	keep pracid patid regenddate antipsychotic_first
	merge 1:m pracid patid using `t2dm_hba1c'
	keep if _merge == 3
	drop _merge
	drop if hba1c48_date > regenddate  //don't need diagnoses after registration end
	gsort pracid patid hba1c48_date
	by pracid patid: keep if _n == 1
	drop regenddate antipsychotic_first
	tempfile hba1c48
	save `hba1c48'
restore
merge 1:1 pracid patid using `hba1c48', nogenerate
recode hba1c48 (. = 0)
label variable hba1c48 "HbA1c >= 48 mmol/mol"
tab1 t2dm t2dm_cat hba1c48, missing

//Remove people with dementia prior to and upto 1 year after antipsychotic initiation
summarize dementia_date if dementia_date <= antipsychotic_first+365.25, detail format
drop if dementia_date <= antipsychotic_first+365.25
count
tab1 dementia, missing

//Remove people with T2DM before antipsychotic initiation
summarize t2dm_date if t2dm_date <= antipsychotic_first, detail format
drop if t2dm_date <= antipsychotic_first

summarize hba1c48_date if hba1c48_date <= antipsychotic_first, detail format
drop if hba1c48_date <= antipsychotic_first

count
tab1 t2dm hba1c48 dementia, missing  //people diagnosed with these during follow-up


//Calculate follow-up
//follow-up ends 180 days after last antipsychotic (last: >180 day gap)
//follow-up ends at T2DM diagnosis/drug prescribed
//look back 2 years prior to index (antipsychotic initiation)
//look forwards 2 years after index
gen start_fu = max(regstartdate, `study_start', antipsychotic_first-(365.25*2))
gen end_fu = min(regenddate, deathdate, lcd, t2dm_date, ///
	antipsychotic_first+(365.25*2), antipsychotic_last+180)
format %td start_fu end_fu

summarize dob regstartdate regenddate deathdate lcd smi_first antipsychotic_first ///
	if start_fu >= end_fu, format
drop if start_fu >= end_fu
generate followup = end_fu - start_fu
summarize start_fu end_fu followup, format detail
order start_fu end_fu followup, before(smi_first)
count


//Drop if antipsychotic was prescribed outside of follow-up period  **should be 0
summarize antipsychotic_first if antipsychotic_first < start_fu, detail format
summarize antipsychotic_first if antipsychotic_first >= end_fu, detail format
drop if antipsychotic_first < start_fu
drop if antipsychotic_first >= end_fu
count


//Correct dementia and T2DM diagnoses based on end of follow-up date
tab1 dementia t2dm, missing
replace dementia = 0 if dementia_date > end_fu
replace dementia_date = . if dementia_date > end_fu
replace t2dm = 0 if t2dm_date > end_fu
replace t2dm_date = . if t2dm_date > end_fu
replace t2dm_cat = . if t2dm_date > end_fu
//replace t2dm_incprev = . if t2dm_date > end_fu
//replace t2dm_med = . if t2dm_date > end_fu
replace hba1c48 = 0 if hba1c48_date > end_fu
replace hba1c48_date = . if hba1c48_date > end_fu
tab1 dementia t2dm hba1c48, missing


//Calculate number of people with SMI diagnosis after first antipsychotic prescription
count if smi_first > antipsychotic_first
generate time_smi_to_ap = antipsychotic_first - smi_first
summarize time_smi_to_ap, detail
summarize time_smi_to_ap if time_smi_to_ap < 0, detail

//Generate variable to show those with SMI diagnosis after antipsychotic prescription
generate byte smi_after_ap = (smi_first > antipsychotic_first)
tab smi_after_ap, missing
preserve
	bysort smi_after_ap: summarize time_smi_to_ap, detail
restore

//Remove patients with SMI diagnoses more than a year after their first antipsychotic prescription
count if smi_first > antipsychotic_first + 365.25
//drop if smi_first > antipsychotic_first + 365.25
count


//Some finishing touches

//Variable to indicate patients that died during follow-up
generate byte died = (deathdate <= end_fu)

//Variable for top 7 antipsychotics that represent >90% of prescribed antipsychotics
tab antipsychotic_medication, sort missing
tab antipsychotic_medication, sort missing nolabel
generate ap_med = antipsychotic_medication
order ap_med, after(antipsychotic_medication)
label define ap_med 1 "Olanzapine" 2 "Quetiapine" ///
	3 "Risperidone" 4 "Other/Multiple"
recode ap_med (16 = 1) (23 = 2) (24 = 3) (1/15 17/22 25/33 99 = 4)
label values ap_med ap_med
tab ap_med, missing
tab antipsychotic_medication ap_med, missing

//Generate unique numeric patiend ID (for time series commands)
egen tspatid = group(pracid patid), autotype
order tspatid


//Give variables labels
label define yn 0 "No" 1 "Yes"
label values ap_change t2dm dementia smi_after_ap died yn

label variable dob "Date of birth"
label variable e2019_imd_5_practice "Quintile of IMD for practice location"
label variable e2019_imd_5_patient "Quintile of IMD for patient's current residence"
label variable start_fu "Start of follow-up"
label variable end_fu "End of follow-up"
label variable followup "Length of follow-up (days)"
label variable smi_first "Date of first SMI diagnosis code"
label variable smi_medcodeid "SMI diagnosis code"
label variable smi_subtype "SMI sub-type"
label variable antipsychotic_first "Date of first antipsychotic prescription"
label variable antipsychotic_last "Date of last antipsychotic prescription"
label variable antipsychotic_medication "First antipsychotic prescription"
label variable ap_med "First antipsychotic prescription"
label variable ap_change "Second antipsychotic prescription differs from first"
label variable dementia "Dementia"
label variable dementia_date "Date of first Dementia code"
label variable t2dm "Type-2 diabetes mellitus"
label variable t2dm_date "Date of first diabetes diagnosis code"
//label variable t2dm_incprev "Incident/prevalent diabetes diagnosis code"
//label variable t2dm_med "Diabetes medication"
label variable age_1st_antipsychotic "Age at 1st antipsychotic prescription"
label variable agebands "Age group at 1st antipsychotic prescription"
label variable smi_after_ap "Received an SMI diagnosis after their first antipsychotic prescription"
label variable time_smi_to_ap "Time from SMI diagnosis to first antipsychotic prescription"
label variable died "Patient died during follow-up"
label variable tspatid "Time-series patient ID"

describe

summarize dob regstartdate regenddate deathdate lcd start_fu end_fu followup ///
	smi_first antipsychotic_first dementia_date t2dm_date ///
	age_1st_antipsychotic time_smi_to_ap, format detail
	
tab1 gender region e2019_imd_5_practice e2019_imd_5_patient ///
	antipsychotic_medication ap_med ap_change dementia t2dm t2dm_cat ///
	agebands smi_after_ap died, missing
	
codebook tspatid


compress
save 3_builds/cohort, replace

// Print time taken to run the do file
local runtime = clock("$S_DATE $S_TIME", "DMY hms") - `start'
display "Runtime: " floor(`runtime'/60000) " minutes " mod(`runtime'/1000, 60) " seconds"

log close
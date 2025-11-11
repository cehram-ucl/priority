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
log using "2b_build_logs/Antipsy_dosage_v2_`date'_`time'", text replace

// Required directories
local lookup_dir "../DELETE/Lookup/202309_Lookups_CPRDAurum"


// Import common dosages lookup
//==============================

import delimited "`lookup_dir'/common_dosages.txt", asdouble favorstrfixed clear
tempfile commondosages
save `commondosages'


// Calculate dosages on antipsychotics codelist
//==============================================
/* APPLIED TO CODELIST
use codelists/antipsychotics, clear

drop drugissues dmdid productname bnfchapter bnfcode bnfname antipsychotic antipsychotic_medication lshtm_2796 oc_opensafely_1stgenAP oc_opensafely_2ndgenAP oc_opensafely_depotAP

//Exclude injected medicines
tab routeofadministration, sort missing
keep if inlist(routeofadministration, "Oral", "", "Sublingual", "Rectal")
drop if routeofadministration == "" & strpos(lower(termfromemis), "injection")

//Some "liquid" drugs are still included; could be oral or intramuscular
list prodcodeid termfromemis ///
	if routeofadministration == "" ///
	& (strpos(lower(termfromemis), "liquid") | strpos(lower(termfromemis), "elixir"))

//Search for drugs in solution
generate byte solution = 1 if strpos(substancestrength, "/")

//Use regex to search term to find missing info; basically a search for "mg/ml"
replace solution = 1 ///
	if solution == . ///
	& regexm(lower(termfromemis), "[0-9]*[.]*[0-9]* ?(mg|micrograms?)/[0-9]*[.]*[0-9]* ?ml")


//Search for products containing multiple drugs or multiple doses
generate byte multiple = 1 if strpos(substancestrength, "+")
replace multiple = 1 ///
	if multiple != 1 ///
	& regexm(lower(termfromemis), "(mg|microgram).*(mg|microgram)")


//Extract dose
generate strength_mg = regexs(0) ///
	if multiple != 1 ///
	& regexm(substancestrength, "[0-9]*[.][0-9]* ?(mg|microgram)")

replace strength_mg = regexs(0) ///
	if strength_mg == "" & multiple != 1 ///
	& regexm(lower(termfromemis), "[0-9]*[.]*[0-9]* ?(mg|microgram)")
	
//Extract dose for products containing multiple drugs (theres only one)
replace strength_mg = regexs(0) ///
	if multiple == 1 ///
	& drugsubstancename == "Amitriptyline hydrochloride/ Perphenazine" ///
	& regexm(substancestrength, "[+] [0-9]*[.][0-9]* ?mg")

replace strength_mg = subinstr(strength_mg, "+ ", "", 1)
replace strength_mg = subinstr(strength_mg, "mg", "", 1)
replace strength_mg = subinstr(strength_mg, "microgram", "", 1)
destring strength_mg, replace


//Extract dose per ml for solutions
generate strength_per_x_ml = regexs(0) ///
	if solution == 1 ///
	& regexm(substancestrength, "/[0-9]*[.][0-9]* ?ml")

replace strength_per_x_ml = regexs(0) ///
	if strength_per_x_ml == "" & solution == 1 ///
	& regexm(lower(termfromemis), "/[0-9]*[.]*[0-9]* ?ml")

replace strength_per_x_ml = subinstr(strength_per_x_ml, "/ml", "1", 1)
replace strength_per_x_ml = subinstr(strength_per_x_ml, "/", "", 1)
replace strength_per_x_ml = subinstr(strength_per_x_ml, "ml", "", 1)
destring strength_per_x_ml, replace

generate double strength_mg_per_ml = strength_mg / strength_per_x_ml

//tidy up
replace strength_mg = . if solution == 1
drop strength_per_x_ml

//generate combined variable
generate double ap_strength = strength_mg
replace ap_strength = strength_mg_per_ml if solution == 1

compress
tempfile antipsychotics
save `antipsychotics'
*/

// Open baseline cohort for generating dataset
//=============================================

use 3_builds/cohort_baseline, clear

rename antipsychotic_medication antipsychotic_first_medication
drop regstartdate regenddate deathdate lcd e2019_imd_5_practice followup smi_medcodeid smi_subtype ap_change dementia_date dementia t2dm_date t2dm t2dm_incprev cv_date cv_event cardiovascular time_smi_to_ap smi_after_ap ap_med smoking_status_date alcstatus_date alcohol_use_disorder_date


// Merge cohort with antipsychotic prescriptions, clean, and estimate frequency
//==============================================================================

merge 1:m pracid patid using 3_builds/antipsychotic_no_injected
drop if _merge == 2
drop _merge antipsychotic

//Clean quantity and duration variables
count
summarize quantity duration, detail
replace quantity = . if quantity < 1
replace duration = . if duration < 1
replace duration = . if duration > 3653  //10 years is still ridiculous
count
summarize quantity duration, detail

//Quantity units that we can use to assume daily frequency of medicine
tab1 quantunitid, sort missing
tab1 quantunitid, sort missing nolabel
tab1 quantunitid if inlist(quantunitid, 83, ., 14, 13, 78, 67), sort missing
tab1 quantunitid if !inlist(quantunitid, 83, ., 14, 13, 78, 67), sort missing

//Estimate daily frequency of medicine
generate double ap_daily_freq = quantity / duration ///
	if inlist(quantunitid, 83, ., 14, 13, 78, 67)
summarize ap_daily_freq, detail
	

// Merge antipsychotics codelist to estimate dose
//================================================
/*
merge m:1 prodcodeid using `antipsychotics'
tab quantunitid if _merge == 1, sort missing  //should be the injections
keep if _merge == 3
drop _merge prodcodeid
*/
tab1 quantunitid /*formulation routeofadministration*/, sort missing

//order quantity quantunitid duration ap_daily_freq, last

//Estimate dose in milligrams
generate double ap_dailydose_mg = ap_strength * ap_daily_freq if solution != 1  //previously 'strength_mg'
generate double ap_solutiondose_mg = ap_strength * quantity if solution == 1  //previously 'strength_mg_per_ml'
count
summarize ap_dailydose_mg ap_solutiondose_mg, detail


// Merge common dosages lookup to get more precise dosage information
//====================================================================

merge m:1 dosageid using `commondosages'
drop if _m == 2
compress
gsort pracid patid antipsychotic_date

generate byte no_dosage_lookup = (_merge == 1)
tab _merge no_dosage_lookup, missing
drop _merge dosageid
order no_dosage_lookup, after(multiple)
tab no_dosage_lookup, missing

//Common dosages variables
tab1 daily_dose dose_number dose_unit dose_frequency dose_interval choice_of_dose dose_max_average change_dose dose_duration, missing sort


// Explore missing dosage data and try to fill in any gaps
//=========================================================

tab ap_strength, sort missing  //var I generated using substancestrength and term
tab daily_dose, sort missing
tab ap_strength if daily_dose == ., sort missing

//Try to fill in some gaps
generate double dailyfreq = daily_dose if daily_dose > 0
replace dailyfreq = ap_daily_freq if dailyfreq == .
recode dailyfreq (0 = .)  //0 is missing basically

//Remove values that may not be correct
tab dosage_text ///
	if strmatch(lower(dosage_text), "*directed*") ///
	| strmatch(lower(dosage_text), "*described*") ///
	| strmatch(lower(dosage_text), "*needed*") ///
	| strmatch(lower(dosage_text), "*unknown*"), sort missing
replace dailyfreq = . ///
	if strmatch(lower(dosage_text), "*directed*") ///
	| strmatch(lower(dosage_text), "*described*") ///
	| strmatch(lower(dosage_text), "*needed*") ///
	| strmatch(lower(dosage_text), "*unknown*")

//more thorough check of dosage_text perhaps required

count
summarize dailyfreq, detail

generate double dailydose_mg = ap_strength * dailyfreq ///
	if solution == . ///
	| (solution == 1 & dose_unit == "ML")  //only include solutions with volume info

//Round to 1dp to group similar values together
generate double dailydose_mg_1dp = round(dailydose_mg, 0.1)
recode dailydose_mg_1dp (0 = .)

count
summarize dailydose_mg dailydose_mg_1dp, detail
preserve
	bysort no_dosage_lookup: summarize dailydose_mg dailydose_mg_1dp, detail
restore

mdesc dailydose_mg_1dp


// Generate dose equivalence (low or high dose) between antipsychotics
//=====================================================================

//See "JCBA_table AP dose equivalences_240428.xlsx" for low/high cut points
//Leucht et al. 2016; 100mg Chlorpromazine reference
/*
antipsychotic_medication:
Value	Medication Label	Cut point
1	Amisulpride	133
2	Aripiprazole	5
3	Benperidol	1
//4	Cariprazine	
5	Chlorpromazine	100
6	Chlorprothixene	100
7	Clozapine	100
//8	Droperidol	
9	Flupentixol	2
10	Fluphenazine	3
11	Haloperidol	3
12	Levomepromazine	100
13	Loxapine	33
14	Lurasidone	20
15	Melperone	100
16	Olanzapine	3
17	Oxypertine	40
18	Paliperidone	2
19	Periciazine	17
20	Perphenazine	10
21	Pimozide	1
22	Promazine	100
23	Quetiapine	133
24	Risperidone	2
25	Sertindole	5
26	Sulpiride	267
27	Thioridazine	100
28	Trifluoperazine	7
29	Ziprasidone	27
30	Zotepine	67
31	Zuclopenthixol	10
32	Pipotiazine	3
33	Asenapine	7
*/

generate double dose_equivalence = dailydose_mg_1dp

//This requires the dose_equivalence.do file I created (code below in case)
/*
args dose_equiv_var med_var med_value cutoff

recode `dose_equiv_var' (min/`cutoff' = 1) (`cutoff'/max = 2) ///
	if `med_var' == `med_value' & `dose_equiv_var' != .
*/
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 1 133
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 2 5
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 3 1
//do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 4 999
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 5 100
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 6 100
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 7 100
//do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 8 999
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 9 2
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 10 3
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 11 3
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 12 100
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 13 33
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 14 20
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 15 100
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 16 3
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 17 40
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 18 2
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 19 17
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 20 10
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 21 1
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 22 100
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 23 133
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 24 2
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 25 5
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 26 267
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 27 100
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 28 7
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 29 27
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 30 67
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 31 10
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 32 3
do 2a_build_scripts/dose_equivalence dose_equivalence antipsychotic_medication 33 7

replace dose_equivalence = . if inlist(antipsychotic_medication, 4, 8)

label define dose_equivalence 1 "Low" 2 "High"
label values dose_equivalence dose_equivalence
tab dose_equivalence, missing
tab dose_equivalence no_dosage_lookup, col missing
tab antipsychotic_medication dose_equivalence, missing

compress
save 3_builds/cohort_baseline_antipsychotic_dailydose, replace


// Generate dose equivalence by quarter (90 days)
// (we assume all subsequent prescriptions are same drug as first)
//=================================================================

bysort pracid patid (antipsychotic_date): ///
	generate days_from_1st_ap = antipsychotic_date[_n] - antipsychotic_date[1]

//Label observations with a different initial antipsychotic than was found
//when using all antipsychotics (included injected medicines)
by pracid patid: generate diff_1st_ap = ///
	(antipsychotic_medication[1] != antipsychotic_first_medication)
tab diff_1st_ap, missing

generate quarter = floor(days_from_1st_ap/90) + 1

egen max_dose_equiv_per_quarter = max(dose_equivalence), by(pracid patid quarter)
label values max_dose_equiv_per_quarter dose_equivalence
tab max_dose_equiv_per_quarter, missing

egen prescriptions_per_person = count(days_from_1st_ap), by(pracid patid)
tab prescriptions_per_person, plot

//Cohort should already include people with at least 2 antipsychotic prescriptions
//This limits cohort to people with at least 2 non-injected antipsychotics
//drop if prescriptions_per_person == 1

//Drop variables that will have information removed by removing duplicates
drop antipsychotic_date antipsychotic_medication /*termfromemis formulation routeofadministration drugsubstancename substancestrength*/ solution multiple no_dosage_lookup /*strength_mg strength_mg_per_ml*/ ap_strength quantity quantunitid duration ap_daily_freq ap_dailydose_mg ap_solutiondose_mg dosage_text daily_dose dose_number dose_unit dose_frequency dose_interval choice_of_dose dose_max_average change_dose dose_duration dailyfreq dailydose_mg dailydose_mg_1dp dose_equivalence days_from_1st_ap prodcodeid

duplicates drop pracid patid quarter, force

gsort pracid patid quarter 

tab quarter, plot
codebook tspatid

compress
save 3_builds/cohort_baseline_antipsychotic_dailydose_quarterly, replace


// Impute dose equivalence per quarter using low/high proportion for each antipsychotic
// (assumes data are missing at random)
//======================================================================================
set seed 12354
generate random_number = runiform()

tab antipsychotic_first_medication max_dose_equiv_per_quarter, missing
label list antipsychotic_medication
local ap_med_count = r(max)  //total number of antipsychotics

forvalues medication = 1/`ap_med_count' {
	
	display "Medication value: `medication'"
	tab antipsychotic_first_medication ///
		if antipsychotic_first_medication == `medication' ///
		& max_dose_equiv_per_quarter != .
	tab max_dose_equiv_per_quarter if antipsychotic_first_medication == `medication'
	
	if r(N) == 0 {  //if no observations
		
		continue  //proceed to next medicine in loop
	}
	
	//Get proportion of people on low dose for specified medication
	proportion max_dose_equiv_per_quarter ///
		if antipsychotic_first_medication == `medication'
	capture noisily local proportion_lowdose = e(b)[1, "1.max_dose_equiv_per_quarter"]
	if _rc == 111 {  //if "low" dose equivalence not found
		
		display "100% high dose"
		local proportion_lowdose = 0
	}
	else {
		
		display "Low dose proportion: `proportion_lowdose'"
	}
	
	preserve
		//Keep specified medicine with missing dose values
		keep if antipsychotic_first_medication == `medication' ///
			& max_dose_equiv_per_quarter == .
		gsort random_number
		
		count
		local N = r(N)
		if `N' == 0 {
			
			display "No missing data, no need to impute."
			restore  //restore data with all medicines
			continue  //proceed to next medicine in loop
		}
		
		//Apply same proportion of low/high dose to data with missing dose
		local split_point = round(`proportion_lowdose' * `N') + 1
		if `split_point' > `N' {
			
			display "100% low dose"
			local split_point = `N'
		}
		display "Split point: `split_point'"
		
		replace max_dose_equiv_per_quarter = 1 in 1/`split_point'
		replace max_dose_equiv_per_quarter = 2 in `split_point'/`N'
		tab max_dose_equiv_per_quarter, missing
		
		if `medication' > 1 {
			
			display "Appending previous data..."
			append using ///
				3_builds/cohort_baseline_antipsychotic_dailydose_quarterly_imputed
		}
		save 3_builds/cohort_baseline_antipsychotic_dailydose_quarterly_imputed, replace
	restore
}

//Merge in imputed data using "update replace" option to fill in missing data
merge 1:1 pracid patid quarter using ///
	3_builds/cohort_baseline_antipsychotic_dailydose_quarterly_imputed, ///
	update replace
tab _merge, missing
drop _merge random_number

gsort pracid patid quarter
	
tab max_dose_equiv_per_quarter, missing

compress
save 3_builds/cohort_baseline_antipsychotic_dailydose_quarterly_imputed, replace	


// Print time taken to run the do file
local runtime = clock("$S_DATE $S_TIME", "DMY hms") - `start'
display "Runtime: " floor(`runtime'/60000) " minutes " mod(`runtime'/1000, 60) " seconds"

log close
//==============================================================================
// 2024-10-18 PWS codelist creation template
//
// ALCOHOL CONSUMPTION
//
// Lines with 2 asterisks (**) at the beginning and end require modification
// Lines with 1 asterisk (*) at the beginning and end MAY require modification
//==============================================================================


// Initialise do file & import CPRD Aurum medical dictionary
//===========================================================

clear all
set more off

//** UPDATE THESE VARIABLES **==================================================

//**Working directory - where you will open/save files**
cd "C:\Users\rmjlton.AD\Documents\GitHub\priority\codelists"

//**Enter name of do file here. This ensures all files have the same name.**
local filename "alcohol_consumption"

//*Aurum build/version*
local aurum_build "202309"

//==============================================================================

//Open log file
capture log close
log using `filename', text replace


//= CPRD LOOKUP LOCATION - would be good to get this in a shared location ======

//*Directory of medical dictionary*
local browser_dir "C:/Users/rmjlton.AD/OneDrive - University College London/CPRD/CPRD Aurum/Lookups/`aurum_build'_Lookups_CPRDAurum"

//*Directory of label lookups*
local lookup_dir "C:/Users/rmjlton.AD/OneDrive - University College London/CPRD/CPRD Aurum/Lookups/`aurum_build'_Lookups_CPRDAurum"

//==============================================================================

//Import latest medical browser; force medcodeid, SNOMED CT Description ID, and SNOMED CT Concept ID to be string
//import delimited "`browser_dir'/CPRDAurumMedical.txt", stringcols(1 6 7) favorstrfixed
import delimited "`browser_dir'/`aurum_build'_EMISMedicalDictionary.txt", stringcols(1 6 7) favorstrfixed

//Drop useless variables
drop release emiscodecategoryid

order medcodeid observations originalreadcode cleansedreadcode ///
	snomedctconceptid snomedctdescriptionid term

//Save medical code browser to a tempfile
tempfile medical
save `medical'


// SKIP STEPS 1 & 2, USE PRE-EXISTING CODELIST INSTEAD
//=====================================================

//Use pre-existing codelist
import delimited https://datacompass.lshtm.ac.uk/id/eprint/4214/37/covariate_alcohol_aurum.txt, stringcols(1) favorstrfixed clear

tab1 alcstatus alclevel, missing

//Generate tidier variables
label define alcstatus 1 "Non-drinker" 2 "Ex-drinker" 3 "Current drinker" ///
	99 "Unknown"
replace alcstatus = "1" if alcstatus == "non"
replace alcstatus = "2" if alcstatus == "ex"
replace alcstatus = "3" if alcstatus == "curr"
replace alcstatus = "99" if alcstatus == "unknown"
destring alcstatus, replace
label values alcstatus alcstatus

label define alclevel 1 "Light drinker" 2 "Moderate drinker" 3 "Heavy drinker"
replace alclevel = "1" if alclevel == "L"
replace alclevel = "2" if alclevel == "M"
replace alclevel = "3" if alclevel == "H"
destring alclevel, replace
label values alclevel alclevel

rename term term_old

//Merge with version of CPRD medical dictionary used for study
merge 1:1 medcodeid using `medical', update replace
drop if _merge == 2

//List terms not in this version of the Aurum medical dictionary
list medcodeid term_old alcstatus alclevel if _merge == 1
drop if _merge == 1
drop _merge

//Compare codelist and dictionary terms
list medcodeid term term_old if lower(term) != lower(term_old)

//EVERYTHING LOOKS FINE

generate byte alcohol = 1
drop term_old
order alcstatus alclevel, last

gsort alcstatus alclevel


// (OPTIONAL) STEP 3. PERFORM A SECONDARY SEARCH TO EXCLUDE BROAD UNDESIRED TERMS
//================================================================================

//Comment out this section if not required.

// **Exclusion terms**

local exclude " "*family*" "*maternal*care*" "

//Search for codes to exclude
foreach excludeterm in exclude /**/familyhistory/**/ {

	gen byte `excludeterm' = .

	foreach codeterm in lower(term) {
		
		foreach searchterm in ``excludeterm'' {		
			
			replace `excludeterm' = 1 if strmatch(`codeterm', "`searchterm'")
		}
	}
}

//Check that nothing important is highlighted for exclusion before dropping
list observations term if exclude == 1

drop if exclude == 1

drop exclude
count
compress


// STEP 4. MANUAL SCREEN OF CODELIST TO REMOVE UNDESIRED TERMS
//=============================================================

// **medcodeids to remove**
local initial_remove "5497631000006115 3367991000006112 346501000006111"

gen byte remove = 0

foreach medcode of local initial_remove {
	
	replace remove = 1 if medcodeid == "`medcode'"
}

list medcodeid snomedctdescriptionid snomedctconceptid originalreadcode term if remove == 1
drop if remove == 1
drop remove

compress
tab1 /**/alcohol alcstatus alclevel/**/


//Recode to "Current drinker" status
local current "4978411000006113 4978421000006117 451082013"

foreach medcode of local current {
	
	replace alcstatus = 3 if medcodeid == "`medcode'"
	display "Recoded to Current drinker"
	list term alcstatus if medcodeid == "`medcode'"
}

//Recode to "Unknown" status
local unknown "6289331000006118 6282101000006116 14147511000006111 476501000006115 14147521000006115"

foreach medcode of local unknown {
	
	replace alcstatus = 99 if medcodeid == "`medcode'"
	display "Recoded to Unknown"
	list term alcstatus if medcodeid == "`medcode'"
}

//Recode to "Heavy drinker" level
local heavy "401797010"

foreach medcode of local heavy {
	
	replace alclevel = 3 if medcodeid == "`medcode'"
	display "Recoded to Heavy"
	list term alcstatus alclevel if medcodeid == "`medcode'"
}

gsort alcstatus alclevel


// STEP 5. USE THE SNOMED CT CONCEPT ID TO FIND ADDITIONAL SYNONYMOUS TERMS
//==========================================================================

//Check for missing SNOMED CT Concepts
codebook snomedctconceptid
assert !missing(snomedctconceptid)

count

//Make a note of current list
preserve
	keep medcodeid /**/alcohol alcstatus alclevel/**/
	gen byte original = 1
	tempfile original
	save `original'
restore

//Merge SNOMED CT Concepts with medical dictionary
keep snomedctconceptid /**/alcohol alcstatus alclevel/**/
gsort /**/alcohol -alcstatus -alclevel/**/  //prioritise worst or missing
bysort snomedctconceptid: keep if _n == 1

//Merge with original search results
merge 1:m snomedctconceptid using `medical', nogenerate keep(match)
compress
merge 1:1 medcodeid using `original', update replace
list medcodeid term alcstatus alclevel if _merge > 3  //conflicts
drop _merge
order snomedctconceptid, before(snomedctdescriptionid)
order /**/alcohol alcstatus alclevel/**/, last
gsort /**/alcohol alcstatus alclevel/**/ originalreadcode

//Label new codes
gen new_snomedct_synonym = (original != 1)
drop original

//Show new codes
foreach category of varlist /**/alcohol/**/ {
	
	display "New terms found for: `category'"
	list snomedctconceptid term if new_snomedct_synonym == 1
}

//Check new codes in the context of originally included SNOMED CT Concept ID codes
preserve
	keep if new_snomedct_synonym == 1
	keep snomedctconceptid
	bysort snomedctconceptid: keep if _n == 1

	count
	local obs = r(N)

	forvalues i = 1/`obs' {
		
		if `i' == 1 {
			
			local expanded_ids = snomedctconceptid in `i'
		}
		else {
			
			local expanded_ids = "`expanded_ids' " + snomedctconceptid in `i'
		}
	}
restore

foreach expanded_id of local expanded_ids {
	
	display "SNOMED CT Concept ID for which additional terms where found: `expanded_id'"
	
	list medcodeid term new_snomedct_synonym alcstatus alclevel ///
		if snomedctconceptid == "`expanded_id'"
}


//Remove substance abuse codes
local snomed_remove "371422002 91388009"

foreach conceptid of local snomed_remove {
	
	list medcodeid term new_snomedct_synonym alcstatus ///
		if snomedctconceptid == "`conceptid'"
	
	list medcodeid term new_snomedct_synonym alcstatus ///
		if snomedctconceptid == "`conceptid'" & new_snomedct_synonym == 1
		
	drop if snomedctconceptid == "`conceptid'" & new_snomedct_synonym == 1
}


tab1 alcohol alcstatus alclevel, missing


//STEP 6 - not required; already categorised


//STEP 7 - not required; already using pre-existing list


//STEP 8 - clinical review not required at present


// STEP 9. SAVE CODELIST
//=======================

//Save clinician approved codelist
gsort alcstatus alclevel snomedctconceptid snomedctdescriptionid originalreadcode
drop new_snomedct_synonym
compress
save `filename', replace
export delimited `filename', replace quote


// STEP 10. GENERATE METADATA FILE
//=================================

//=**Update details here, everything else is automated**========================
local description "Alcohol consumption"
local code_type "medcodeid (SNOMED CT)"
local database "CPRD Aurum"
local database_version = ym(real(substr("`aurum_build'", 1, 4)), ///
							real(substr("`aurum_build'", 5, 2)))
local author "Philip Stone"
local date = ym(2025, 6)  //year, month
local clinical_reviewer ""
local date_approved = . //ym(2025, 6)  //year, month
local notes "Created for PRIORITY study. Modified version of https://doi.org/10.17037/DATA.00004214 from LSHTM Data Compass"
local keywords ""
//==============================================================================

clear
gen v1 = ""
gen v2 = .
format %tmMon_CCYY v2
set obs 10

replace v1 = "`description'" in 1
replace v1 = "`code_type'" in 2
replace v1 = "`database'" in 3
replace v2 = `database_version' in 4
replace v1 = "`author'" in 5
replace v2 = `date' in 6
replace v1 = "`clinical_reviewer'" in 7
replace v2 = `date_approved' in 8
replace v1 = "`notes'" in 9
replace v1 = "`keywords'" in 10

tostring v2, replace usedisplayformat force
replace v1 = v2 in 4
replace v1 = v2 in 6
replace v1 = v2 in 8
drop v2

export delimited "`filename'.meta", replace novarnames delimiter(tab)


use "`filename'", clear  //So that you can see results of search after do file run


log close
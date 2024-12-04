//==============================================================================
// 2024-10-18 PWS codelist creation template
//
// ETHNICITY
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
cd "C:\Users\rmjlton\GitHub\priority\codelists"

//**Enter name of do file here. This ensures all files have the same name.**
local filename "ethnicity"

//*Aurum build/version*
local aurum_build "202309"

//==============================================================================

//Open log file
capture log close
log using `filename', text replace


//= CPRD LOOKUP LOCATION - would be good to get this in a shared location ======

//*Directory of medical dictionary*
local browser_dir "C:/Users/rmjlton/OneDrive - University College London/PRIORITY/lookups/`aurum_build'_Lookups_CPRDAurum"

//*Directory of label lookups*
local lookup_dir "C:/Users/rmjlton/OneDrive - University College London/PRIORITY/lookups/`aurum_build'_Lookups_CPRDAurum"

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


//Import pre-existing codelists
import delimited https://datacompass.lshtm.ac.uk/id/eprint/2102/65/ethnicity_aurum_may20.txt, stringcols(1) clear

drop eth16

local name "lshtm_2102"

rename term term_`name'
rename eth5 eth5_`name'

compress
tempfile `name'
save ``name''

import delimited https://datacompass.lshtm.ac.uk/id/eprint/4214/24/covariate_ethniciity_aurum.txt, stringcols(1) favorstrfixed clear

//merge with previous list
merge 1:1 medcodeid using `lshtm_2102'

//check for differences
list medcodeid term term_lshtm_2102 if lower(term) != lower(term_lshtm_2102) & _merge == 3
list medcodeid eth5 eth5_lshtm_2102 if lower(eth5) != lower(eth5_lshtm_2102) & _merge == 3

//combine variables into one
replace term_lshtm_2102 = term if _merge == 1
replace eth5_lshtm_2102 = eth5 if _merge == 1

//limit to just medcodeid and ethnicity category
keep medcodeid term_lshtm_2102 eth5_lshtm_2102

//encode ethnicity var
encode eth5_lshtm_2102, generate(eth5)
drop eth5_lshtm_2102

//Merge with version of CPRD medical dictionary used for study
merge 1:1 medcodeid using `medical', update replace
drop if _merge == 2

//List terms not in this version of the Aurum medical dictionary
list medcodeid term_lshtm_2102 eth5 if _merge == 1
drop if _merge == 1
drop _merge term_lshtm_2102

order term eth5, last

tab eth5, missing

//not sure what this is doing here
list medcodeid term eth5 if eth5 == .
drop if eth5 == .


// STEP 5. USE THE SNOMED CT CONCEPT ID TO FIND ADDITIONAL SYNONYMOUS TERMS
//==========================================================================

//Check for missing SNOMED CT Concepts
codebook snomedctconceptid
assert !missing(snomedctconceptid)

count

//Make a note of current list
preserve
	keep medcodeid /**/eth5/**/
	gen byte original = 1
	tempfile original
	save `original'
restore

//Merge SNOMED CT Concepts with medical dictionary
keep snomedctconceptid /**/eth5/**/
bysort snomedctconceptid: keep if _n == 1

//Merge with original search results
merge 1:m snomedctconceptid using `medical', nogenerate keep(match)
compress
merge 1:1 medcodeid using `original', nogenerate
order snomedctconceptid, before(snomedctdescriptionid)
order /**/eth5/**/, last
gsort /**/eth5/**/ originalreadcode

//Label new codes
gen new_snomedct_synonym = (original != 1)
drop original

//Show new codes
foreach category of varlist /**/eth5/**/ {
	
	display "New terms found for: `category'"
	list snomedctconceptid originalreadcode term if new_snomedct_synonym == 1
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
	
	list medcodeid originalreadcode term new_snomedct_synonym eth5 ///
		if snomedctconceptid == "`expanded_id'"
}


//save codelist and export as CSV
order medcodeid observations
gsort eth5 -observations snomedctconceptid snomedctdescriptionid originalreadcode
drop new_snomedct_synonym
compress
save `filename', replace
export delimited `filename', replace quote


// STEP 10. GENERATE METADATA FILE
//=================================

//=**Update details here, everything else is automated**========================
local description "Ethnicity"
local code_type "medcodeid (SNOMED CT)"
local database "CPRD Aurum"
local database_version = ym(real(substr("`aurum_build'", 1, 4)), ///
							real(substr("`aurum_build'", 5, 2)))
local author "Philip Stone"
local date = ym(2024, 12)  //year, month
local clinical_reviewer ""
local date_approved = . //ym(2024, 12)  //year, month
local notes "Created for PRIORITY study."
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
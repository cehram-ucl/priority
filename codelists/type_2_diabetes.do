//==============================================================================
// 2024-10-18 PWS codelist creation template
//
// TYPE 2 DIABETES MELLITUS
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
local filename "type_2_diabetes"

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


// STEP 1. IDENTIFY SEARCH TERMS
//===============================

//**Define search terms below. Use multiple local macros if categorising desired codes in to multiple categories make more sense**

local t2dm " "*type 2*diabet*" "*type ii*diabet*" "*diabet*type 2*" "*diabet*type ii*" "*diabet*remission*" "*remission*diabet*" "*non*insulin*dependent*diabet*" "*diabet*non*insulin*" "*adult*onset*diabet*" "*diabet*adult*onset*" "


// STEP 2. SEARCH THE MEDICAL TERMINOLOGY DICTIONARY USING THE SEARCH TERMS
//==========================================================================

//**Add any additional local macros if you have used more than 1**
//For each specified local macro...
foreach termgroup in /**/t2dm/**/ {
	
	//Generate an empty binary indicator variable taking the name of the local macro
	gen byte `termgroup' = .
	
	//For each SNOMED CT term description (converted to lower case)...
	foreach codeterm in lower(term) {
		
		//For each individual search term in the local macro
		foreach searchterm in ``termgroup'' {
			
			//Set the indicator variable to 1 if the SNOMED CT term description matches the search term from the local macro
			replace `termgroup' = 1 if strmatch(`codeterm', "`searchterm'")
		}
	}
}

keep if /**/t2dm/**/ == 1
compress

gsort /**/t2dm/**/ -observations snomedctconceptid snomedctdescriptionid originalreadcode

tab1 /**/t2dm/**/


// (OPTIONAL) STEP 3. PERFORM A SECONDARY SEARCH TO EXCLUDE BROAD UNDESIRED TERMS
//================================================================================

//Comment out this section if not required.

// **Exclusion terms**

local exclude " "*type 1*" "*type i *" "*family*history*" "*maternal*history*" "*score*" "*risk*" "

//Search for codes to exclude
foreach excludeterm in exclude /**/ /*ADD ANY EXTRA TERMS HERE*/ /**/ {

	gen byte `excludeterm' = .

	foreach codeterm in lower(term) {
		
		foreach searchterm in ``excludeterm'' {		
			
			replace `excludeterm' = 1 if strmatch(`codeterm', "`searchterm'")
		}
	}
}

//Check that nothing important is highlighted for exclusion before dropping
list term if exclude == 1
/**/ /*ADD ANY EXTRA TERMS HERE*/ /**/

drop if exclude == 1 ///
/**/ /*ADD ANY EXTRA TERMS HERE*/ /**/

drop exclude /**/ /*ADD ANY EXTRA TERMS HERE*/ /**/
count
compress


// STEP 4. MANUAL SCREEN OF CODELIST TO REMOVE UNDESIRED TERMS
//=============================================================
/* EVERYTHING LOOKS OK
// **medcodeids to remove**
local initial_remove "123"

gen byte remove = 0

foreach medcode of local initial_remove {
	
	replace remove = 1 if medcodeid == "`medcode'"
}

list medcodeid snomedctdescriptionid snomedctconceptid originalreadcode term if remove == 1
drop if remove == 1
drop remove

compress
tab1 /**/t2dm/**/
*/

// STEP 5. USE THE SNOMED CT CONCEPT ID TO FIND ADDITIONAL SYNONYMOUS TERMS
//==========================================================================

//Check for missing SNOMED CT Concepts
codebook snomedctconceptid
assert !missing(snomedctconceptid)

count

//Make a note of current list
preserve
	keep medcodeid /**/t2dm/**/
	gen byte original = 1
	tempfile original
	save `original'
restore

//Merge SNOMED CT Concepts with medical dictionary
keep snomedctconceptid /**/t2dm/**/
bysort snomedctconceptid: keep if _n == 1

//Merge with original search results
merge 1:m snomedctconceptid using `medical', nogenerate keep(match)
compress
merge 1:1 medcodeid using `original', nogenerate
order snomedctconceptid, before(snomedctdescriptionid)
order /**/t2dm/**/, last
gsort /**/t2dm/**/ originalreadcode

//Label new codes
gen new_snomedct_synonym = (original != 1)
drop original

//Show new codes
foreach category of varlist /**/t2dm/**/ {
	
	display "New terms found for: `category'"
	list snomedctconceptid originalreadcode term if new_snomedct_synonym == 1 & `category' == 1
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
	
	list medcodeid originalreadcode term new_snomedct_synonym ///
		if snomedctconceptid == "`expanded_id'"
}


// (OPTIONAL) STEP 6. USE ANOTHER SEARCH TO AUTOMATE THE CATEGORISATION OF CODES
//===============================================================================

//Comment out this section if not required.
/*
// **Search terms for each categorisation desired**
local cat1 " "*cat1*" "
local cat2 " "*cat2*" "

//Search for codes
foreach categoryterm in /**/cat1 cat2/**/ {
	
	gen byte `categoryterm' = .
	
	foreach codeterm in lower(term) {
		
		foreach searchterm in ``categoryterm'' {		
			
			replace `categoryterm' = 1 if strmatch(`codeterm', "`searchterm'")
		}
	}
}

tab1 cat1 cat2
*/

// STEP 7. COMPARE LIST WITH PRE-EXISTING CODELIST(S)
//====================================================

//Comment this section out if no previous codelist

//Format pre-existing codelist(s) ready for merging
preserve
	import delimited https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/dmtype2_cod/20200812/download.csv, stringcols(1) clear
	
	local name "refset_dmtype2"
	
	rename * *_`name'
	rename code_`name' snomedctconceptid
	
	generate byte `name' = 1

	tempfile `name'
	compress
	save ``name''
restore

preserve
	import delimited https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/dmtype2audit_cod/20210127/download.csv, stringcols(1) clear
	
	local name "refset_dmtype2audit"
	
	rename * *_`name'
	rename code_`name' snomedctconceptid
	
	generate byte `name' = 1

	tempfile `name'
	compress
	save ``name''
restore


foreach codelist in refset_dmtype2 refset_dmtype2audit {
	
	//Merge previous codelist
	merge m:1 snomedctconceptid using ``codelist''

	//Check for any differences
	list term term_`codelist' if _merge == 3 ///
		& lower(term) != lower(term_`codelist')

	//Comment on result above: **No meaningful differences**

	display "Terms on pre-existing list only..."
	list snomedctconceptid term_`codelist' if _merge == 2
	
	//Put pre-existing codelist terms in current codelist term column
	replace term = term_`codelist' if _merge == 2
	replace t2dm = 1 if _merge == 2

	//Drop old terms and merge variable
	drop *_`codelist' _merge
}

//Count number of codes that didn't match
count if medcodeid == ""
gsort snomedctconceptid
list snomedctconceptid if medcodeid == ""
preserve
	keep if medcodeid == ""
	keep snomedctconceptid
	generate byte nomatch = 1
	tempfile nomatch
	save `nomatch'
restore

//Compare newly found Concept IDs against dictionary
preserve
	//Merge SNOMED CT Concepts with medical dictionary
	keep snomedctconceptid
	bysort snomedctconceptid: keep if _n == 1
	merge 1:m snomedctconceptid using `medical'
	list snomedctconceptid if _merge == 1
	merge m:1 snomedctconceptid using `nomatch', nogenerate
	gsort snomedctconceptid
	list if _merge != 1 & nomatch == 1
restore

//extra terms found weren't in CPRD Aurum dictionary
drop if medcode == ""


// STEP 8. EXPORT CODELIST FOR REVIEW BY A PRIMARY CARE CLINICIAN
//================================================================

gsort refset_dmtype2 refset_dmtype2audit -observations snomedctconceptid snomedctdescriptionid
compress
save `filename', replace
export excel `filename'_raw.xlsx, firstrow(variables) replace

//Format Excel file using Python
python:
from openpyxl import load_workbook, Workbook

excel_file = "`filename'_raw.xlsx"

wb = load_workbook(excel_file)
ws = wb.active

# Freeze top row
ws.freeze_panes = 'A2'

# Auto-size column widths
for column in ws.columns:
	max_length = 0
	column_letter = column[0].column_letter

	for cell in column:
		try:
			if len(str(cell.value)) > max_length:
				max_length = len(cell.value)
		except:
			pass

	adjusted_width = (max_length + 2) * 0.92   # this is a bit arbitrary
	ws.column_dimensions[column_letter].width = adjusted_width

wb.save(excel_file)
end
/*
Make sure that reviewing clinician's initials are appended to the end of the file name after reviewing.

e.g. codelist_raw_ABC.xlsx
*/


// STEP 9. RESTRICT YOUR CODELIST TO CODES APPROVED BY A PRIMARY CARE CLINICIAN AND SAVE
//=======================================================================================

//Load clinician classifications
local clinician "CCG"

import excel `filename'_raw_`clinician', firstrow clear

generate t2dm_incprev = incidentprevalent12

//Reclassify incident/prevalent variable to 1s and 2s only
replace t2dm_incprev = strtrim(t2dm_incprev)
replace t2dm_incprev = "1" if t2dm_incprev == "" & `clinician' == 1
replace t2dm_incprev = "1" if strmatch(t2dm_incprev, "*likely 1*")
replace t2dm_incprev = "1" if t2dm_incprev == "1 or 2"
replace t2dm_incprev = "1" if strmatch(t2dm_incprev, "*I or 2*")
replace t2dm_incprev = "1" if t2dm_incprev == "possible1"
replace t2dm_incprev = "1" if strmatch(t2dm_incprev, "*incident*")
replace t2dm_incprev = "1" if strmatch(t2dm_incprev, "*could be 1*")
replace t2dm_incprev = "1" if strmatch(N, "*could be 1*")
replace t2dm_incprev = "2" if strmatch(t2dm_incprev, "*likely 2*")
replace t2dm_incprev = "2" if t2dm_incprev == "possible 2"

//Destring and label
destring t2dm_incprev, replace
label define t2dm_incprev 1 "Incident" 2 "Prevalent"
label values t2dm_incprev t2dm_incprev

//Remerge with original in case of any formatting issues with Excel spreadsheet
keep medcodeid `clinician' t2dm_incprev

tempfile `clinician'_classification
save ``clinician'_classification'

use `filename', clear

merge 1:1 medcodeid using ``clinician'_classification', nogenerate

//Remove codes marked for exclusion by clinician
display "Terms excluded by clinician..."
list medcodeid snomedctconceptid term if `clinician' == 0
drop if `clinician' == 0

//Save clinican approved codelist
gsort snomedctconceptid snomedctdescriptionid originalreadcode
drop new_snomedct_synonym `clinician'
compress
save `filename', replace
export delimited `filename', replace quote


// STEP 10. GENERATE METADATA FILE
//=================================

//=**Update details here, everything else is automated**========================
local description "Type 2 diabetes mellitus"
local code_type "medcodeid (SNOMED CT)"
local database "CPRD Aurum"
local database_version = ym(real(substr("`aurum_build'", 1, 4)), ///
							real(substr("`aurum_build'", 5, 2)))
local author "Philip Stone"
local date = ym(2024, 10)  //year, month
local clinical_reviewer "Carolyn Chew-Graham"
local date_approved = ym(2024, 11)  //year, month
local notes "Created for PRIORITY study"
local keywords "type II diabetes"
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
//==============================================================================
// 2024-10-18 PWS codelist creation template
//
// DEMENTIA
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
local filename "dementia"

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


// STEP 0. COMBINE EXTERNAL CODELIST(S) TO USE AS A GUIDE
//========================================================

//Comment this section out if no pre-existing codelists

//MedCodeID codelists (LSHTM Data Compass)

//Format pre-existing codelist(s) ready for merging
preserve
	import delimited https://datacompass.lshtm.ac.uk/id/eprint/2402/1/cr_codelist_dementia_aurum.txt, stringcols(1) favorstrfixed clear
	
	keep medcodeid
	
	local name "lshtm_2402"
	
	generate byte external_codelist = 1
	generate byte `name' = 1
	generate byte dementia = 1
	
	count

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://datacompass.lshtm.ac.uk/id/eprint/2803/2/dementia_aurum_mar20.txt, stringcols(1 5 6) favorstrfixed clear
	
	keep medcodeid
	
	local name "lshtm_2803"
	
	generate byte external_codelist = 1
	generate byte `name' = 1
	generate byte dementia = 1
	
	count

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://datacompass.lshtm.ac.uk/id/eprint/3265/1/aad_aurum_clincodes.txt, stringcols(1) favorstrfixed clear
	
	keep if dementia == 1
	keep medcodeid
	
	local name "lshtm_3265"
	
	generate byte external_codelist = 1
	generate byte `name' = 1
	generate byte dementia = 1
	
	count

	tempfile `name'
	save ``name''
restore

//SNOMED CT codelists (HDR UK Phenotype Library and OpenCodelists)

//Format pre-existing codelist(s) ready for merging
preserve
	import delimited https://phenotypes.healthdatagateway.org/phenotypes/PH842/version/1763/export/codes, stringcols(1) favorstrfixed clear
	
	rename code snomedctconceptid
	keep snomedctconceptid
	
	local name "hdruk_842"
	
	generate byte external_codelist = 1
	generate byte `name' = 1
	generate byte dementia = 1
	
	count

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://phenotypes.healthdatagateway.org/phenotypes/PH963/version/2141/export/codes, stringcols(1) favorstrfixed clear
	
	keep if strmatch(coding_system, "*SNOMED*CT*")
	
	generate dementia_cat = substr(concept_name, length(phenotype_name) + 43, .)
	
	rename code snomedctconceptid
	keep snomedctconceptid dementia_cat
	
	local name "hdruk_963"
	
	generate byte external_codelist = 1
	generate byte `name' = 1
	generate byte dementia = 1
	
	count

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://phenotypes.healthdatagateway.org/phenotypes/PH1004/version/2182/export/codes, stringcols(1) favorstrfixed clear
	
	keep if strmatch(coding_system, "*SNOMED*CT*")
	
	generate dementia_cat = substr(concept_name, length(phenotype_name) + 43, .)
	
	rename code snomedctconceptid
	keep snomedctconceptid dementia_cat
	
	local name "hdruk_1004"
	
	generate byte external_codelist = 1
	generate byte `name' = 1
	generate byte dementia = 1
	
	count

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/bristol/any-dementia-snomed-ct-v14/5dda3a39/download.csv, stringcols(1) favorstrfixed clear
	
	rename code snomedctconceptid
	keep snomedctconceptid
	
	local name "oc_bristol_anydementia"
	
	generate byte external_codelist = 1
	generate byte `name' = 1
	generate byte dementia = 1
	
	count

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/bristol/lewy-body-dementia-snomed-v1/0f16321e/download.csv, stringcols(1) favorstrfixed clear
	
	rename code snomedctconceptid
	keep snomedctconceptid
	
	local name "oc_bristol_lewybodydementia"
	
	generate byte external_codelist = 1
	generate byte `name' = 1
	generate byte dementia = 1
	
	count

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/bristol/other-dementias-snomed-ct-v15/275ef1c4/download.csv, stringcols(1) favorstrfixed clear
	
	rename code snomedctconceptid
	keep snomedctconceptid
	
	local name "oc_bristol_otherdementias"
	
	generate byte external_codelist = 1
	generate byte `name' = 1
	generate byte dementia = 1
	
	count

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/bristol/unspecified-dementia-snomed-ct-v13/7436ed78/download.csv, stringcols(1) favorstrfixed clear
	
	rename code snomedctconceptid
	keep snomedctconceptid
	
	local name "oc_bristol_unspecifieddementia"
	
	generate byte external_codelist = 1
	generate byte `name' = 1
	generate byte dementia = 1
	
	count

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/bristol/vascular-dementia-snomed-ct-v13/2655d3e3/download.csv, stringcols(1) favorstrfixed clear
	
	rename code snomedctconceptid
	keep snomedctconceptid
	
	local name "oc_bristol_vasculardementia"
	
	generate byte external_codelist = 1
	generate byte `name' = 1
	generate byte dementia = 1
	
	count

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/alzheimers-disease-dementia-codes/20241205/download.csv, stringcols(1) favorstrfixed clear
	
	rename code snomedctconceptid
	keep snomedctconceptid
	
	local name "oc_nhspcdr_demalz"
	
	generate byte external_codelist = 1
	generate byte `name' = 1
	generate byte dementia = 1
	
	count

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/dem_cod/20241205/download.csv, stringcols(1) favorstrfixed clear
	
	rename code snomedctconceptid
	keep snomedctconceptid
	
	local name "oc_nhspcdr_dem"
	
	generate byte external_codelist = 1
	generate byte `name' = 1
	generate byte dementia = 1
	
	count

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/dementia-diagnosis-codes-excluding-alzheimers-vascular-lewy-body-frontotemporal-and-mixed/20241205/download.csv, stringcols(1) favorstrfixed clear
	
	rename code snomedctconceptid
	keep snomedctconceptid
	
	local name "oc_nhspcdr_demother"
	
	generate byte external_codelist = 1
	generate byte `name' = 1
	generate byte dementia = 1
	
	count

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/frontotemporal-dementia-codes/20241205/download.csv, stringcols(1) favorstrfixed clear
	
	rename code snomedctconceptid
	keep snomedctconceptid
	
	local name "oc_nhspcdr_demftemp"
	
	generate byte external_codelist = 1
	generate byte `name' = 1
	generate byte dementia = 1
	
	count

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/lewy-body-dementia-codes/20241205/download.csv, stringcols(1) favorstrfixed clear
	
	rename code snomedctconceptid
	keep snomedctconceptid
	
	local name "oc_nhspcdr_demlewy"
	
	generate byte external_codelist = 1
	generate byte `name' = 1
	generate byte dementia = 1
	
	count

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/mixed-dementia-codes/20241205/download.csv, stringcols(1) favorstrfixed clear
	
	rename code snomedctconceptid
	keep snomedctconceptid
	
	local name "oc_nhspcdr_demmix"
	
	generate byte external_codelist = 1
	generate byte `name' = 1
	generate byte dementia = 1
	
	count

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/vascular-dementia-codes/20241205/download.csv, stringcols(1) favorstrfixed clear
	
	rename code snomedctconceptid
	keep snomedctconceptid
	
	local name "oc_nhspcdr_demvasc"
	
	generate byte external_codelist = 1
	generate byte `name' = 1
	generate byte dementia = 1
	
	count

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/opensafely/dementia-snomed/2020-04-22/download.csv, stringcols(1) favorstrfixed clear
	
	rename id snomedctconceptid
	keep snomedctconceptid
	
	local name "oc_opensafely_dementia"
	
	generate byte external_codelist = 1
	generate byte `name' = 1
	generate byte dementia = 1
	
	count

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/qcovid/has_dementia/48be03fb/download.csv, stringcols(1) favorstrfixed clear
	
	rename code snomedctconceptid
	keep snomedctconceptid
	
	local name "oc_qcovid_hasdementia"
	
	generate byte external_codelist = 1
	generate byte `name' = 1
	generate byte dementia = 1
	
	count

	tempfile `name'
	save ``name''
restore


//Merge into medical browser
use `medical', clear
count

//Medcode lists
foreach external_med in lshtm_2402 lshtm_2803 lshtm_3265 {
	
	merge 1:1 medcodeid using ``external_med'', update replace
	drop if _merge == 2
	
	display "Conflicts..."
	list medcodeid term dementia if _merge == 5
	drop _merge
}

//SNOMED CT lists
foreach external_sct in hdruk_842 hdruk_963 hdruk_1004 ///
	oc_bristol_anydementia oc_bristol_lewybodydementia ///
	oc_bristol_otherdementias oc_bristol_unspecifieddementia ///
	oc_bristol_vasculardementia ///
	oc_nhspcdr_demalz oc_nhspcdr_dem oc_nhspcdr_demother oc_nhspcdr_demftemp ///
	oc_nhspcdr_demlewy oc_nhspcdr_demmix oc_nhspcdr_demvasc ///
	oc_opensafely_dementia oc_qcovid_hasdementia {
	
	merge m:1 snomedctconceptid using ``external_sct'', update replace
	drop if _merge == 2
	
	display "Conflicts..."
	list medcodeid term dementia if _merge == 5
	drop _merge
}

tab dementia, missing


// STEP 1. IDENTIFY SEARCH TERMS
//===============================

// **Define search terms below. Use multiple local macros if categorising
//   desired codes in to multiple categories make more sense**

// **If using repository codelists in Step 0, make sure macro has same name as
//   variable created to identify condition in repository codelists**

local dementia " "*dementia*" "*alzheimer*" "*lewy body*" "


// STEP 2. SEARCH THE MEDICAL TERMINOLOGY DICTIONARY USING THE SEARCH TERMS
//==========================================================================

// **Add any additional local macros if you have used more than 1**
//For each specified local macro...
foreach termgroup in /**/dementia/**/ {
	
	//For each SNOMED CT term description (converted to lower case)...
	foreach codeterm in lower(term) {
		
		//For each individual search term in the local macro
		foreach searchterm in ``termgroup'' {
			
			//Set the indicator variable to 1 if the SNOMED CT term description matches the search term from the local macro
			replace `termgroup' = 1 if strmatch(`codeterm', "`searchterm'")
		}
	}
}

keep if /**/dementia == 1/**/
compress

gsort /**/dementia/**/ -observations snomedctconceptid snomedctdescriptionid originalreadcode

tab1 /**/dementia/**/


// (OPTIONAL) STEP 3. PERFORM A SECONDARY SEARCH TO EXCLUDE BROAD UNDESIRED TERMS
//================================================================================

//Comment out this section if not required.

// **Exclusion terms**

local exclude " "*family*history*" "*fh:*" "*not indicated*" "*at risk*" "*carer of*" "*screening*" "*worker*" "*staff*" "*pseudodementia*" "*health check*" "*test*" "

//Search for codes to exclude
foreach excludeterm in exclude /**/ /*ANY OTHER EXCLUSION CATEGORIES*/ /**/ {

	gen byte `excludeterm' = .

	foreach codeterm in lower(term) {
		
		foreach searchterm in ``excludeterm'' {		
			
			replace `excludeterm' = 1 if strmatch(`codeterm', "`searchterm'")
		}
	}
}

//Check that nothing important is highlighted for exclusion before dropping
tab exclude, missing
list medcodeid term if exclude == 1
/**/ /*ANY OTHER EXCLUSION CATEGORIES*/ /**/

//Make any corrections
local corrections "123"
/*
foreach correction of local corrections {
	
	list medcodeid term if medcodeid == "`correction'"
	
	foreach var of varlist exclude /**/ /*ANY OTHER EXCLUSION CATEGORIES*/ /**/ {
	
		replace `var' = . if medcodeid == "`correction'"
	}
}

replace exclude = 1 if /**/ /*ANY OTHER EXCLUSION CATEGORIES*/ /**/ */
drop if exclude == 1 & external_codelist != 1
count
compress


// STEP 4. MANUAL SCREEN OF CODELIST TO REMOVE UNDESIRED TERMS
//=============================================================

// **medcodeids to remove**
local initial_remove "2247561000000112"

gen byte remove = 0

foreach medcode of local initial_remove {
	
	replace remove = 1 if medcodeid == "`medcode'"
}

list medcodeid snomedctdescriptionid snomedctconceptid originalreadcode term  ///
	observations external_codelist if remove == 1
drop if remove == 1 & external_codelist != 1

//List disagreements between my list and external lists
replace exclude = 1 if remove == 1
list term /*lshtm_* oc_**/ if exclude == 1 & external_codelist == 1

// COMMENT HERE
// No disagreements.

drop if exclude == 1
drop exclude /**/ /*ANY OTHER EXCLUSION CATEGORIES*/ /**/ remove

//External codes that I didn't find
list medcodeid term /**_ext lshtm_* oc_**/ ///
	if dementia != 1 & external_codelist == 1

// COMMENT HERE
// None.

compress
tab1 /**/dementia/**/


// (OPTIONAL) STEP 5. USE ANOTHER SEARCH TO AUTOMATE THE CATEGORISATION OF CODES
//===============================================================================
/*
//Comment out this section if not required.

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
gsort cat1 cat2
*/

// STEP 6. USE THE SNOMED CT CONCEPT ID TO FIND ADDITIONAL SYNONYMOUS TERMS
//==========================================================================

//Check for missing SNOMED CT Concepts
codebook snomedctconceptid
assert !missing(snomedctconceptid)

count

//Make a note of current list
preserve
	keep medcodeid external_codelist lshtm_* hdruk_* oc_* ///
		/**/dementia dementia_cat/**/
	gen byte original = 1
	tempfile original
	save `original'
restore

//Merge SNOMED CT Concepts with medical dictionary
keep snomedctconceptid /**/dementia/**/
bysort snomedctconceptid: keep if _n == 1

merge 1:m snomedctconceptid using `medical', nogenerate keep(match)
compress

//Merge with original search results
merge 1:1 medcodeid using `original', nogenerate
order medcodeid observations originalreadcode cleansedreadcode ///
	snomedctconceptid snomedctdescriptionid term
gsort /**/dementia/**/ originalreadcode

//Label new codes
gen new_snomedct_synonym = (original != 1)
drop original

//Show new codes
foreach category of varlist /**/dementia/**/ {
	
	display "New terms found for: `category'"
	list snomedctconceptid originalreadcode term if new_snomedct_synonym == 1 & `category' != .
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
	
	list medcodeid originalreadcode term new_snomedct_synonym dementia ///
		external_codelist if snomedctconceptid == "`expanded_id'"
}


// STEP 7. COMPARE LIST WITH PREVIOUS CODELIST
//=============================================

//None - this is the first version of the codelist


// STEP 8. EXPORT CODELIST FOR REVIEW BY A PRIMARY CARE CLINICIAN
//================================================================

gsort /**/dementia/**/ -observations snomedctconceptid snomedctdescriptionid
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
*/

// STEP 9. RESTRICT CODELIST TO CODES APPROVED BY A CLINICIAN AND SAVE
//=====================================================================

//Load clinician classifications
local clinician "ABC"
/* NOT CURRENTLY REVIEWED
import excel `filename'_raw_`clinician', firstrow clear sheet("BP (value)")

//Remerge with original in case of any formatting issues with Excel spreadsheet
keep medcodeid `clinician'

tempfile `clinician'_classification
save ``clinician'_classification'

use `filename', clear

merge 1:1 medcodeid using ``clinician'_classification', nogenerate
recode `clinician' (. = 0)

//Remove codes marked for exclusion by clinician
display "Terms excluded by clinician..."
list medcodeid snomedctconceptid term if `clinician' == 0
drop if `clinician' == 0
*/
//Save clinican approved codelist
gsort /**/dementia/**/ -observations snomedctconceptid snomedctdescriptionid originalreadcode
drop new_snomedct_synonym /*codestatus*/ /*`clinician'*/
compress
save `filename', replace
export delimited `filename', replace quote


// STEP 10. GENERATE METADATA FILE
//=================================

//=**Update details here, everything else is automated**========================
local description "Dementia"
local code_type "medcodeid (SNOMED CT)"
local database "CPRD Aurum"
local database_version = ym(real(substr("`aurum_build'", 1, 4)), ///
							real(substr("`aurum_build'", 5, 2)))
local author "Philip Stone"
local date = ym(2025, 3)  //year, month
local clinical_reviewer ""
local date_approved = . //year, month
local notes "Created for PRIORITY study"
local keywords "alzheimer's, lewy body"
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
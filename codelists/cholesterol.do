//==============================================================================
// 2024-10-18 PWS codelist creation template
//
// CHOLESTEROL MEASUREMENT
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
local filename "cholesterol"

//*Aurum build/version*
local aurum_build "202309"

//==============================================================================

//Open log file
capture log close
log using `filename', text replace


//= CPRD LOOKUP LOCATION - would be good to get this in a shared location ======

//*Directory of medical dictionary*
local browser_dir "C:\Users\rmjlton.AD\OneDrive - University College London\Projects\PRIORITY\lookups/`aurum_build'_Lookups_CPRDAurum"

//*Directory of label lookups*
local lookup_dir "C:\Users\rmjlton.AD\OneDrive - University College London\Projects\PRIORITY\lookups/`aurum_build'_Lookups_CPRDAurum"

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

local cholesterol " "*cholesterol*" "*dens*lipo*" "
local triglycerides " "*triglyceride*" "


// STEP 2. SEARCH THE MEDICAL TERMINOLOGY DICTIONARY USING THE SEARCH TERMS
//==========================================================================

//**Add any additional local macros if you have used more than 1**
//For each specified local macro...
foreach termgroup in /**/cholesterol triglycerides/**/ {
	
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

keep if /**/cholesterol == 1 | triglycerides/**/ == 1
compress

gsort /**/cholesterol triglycerides/**/ -observations snomedctconceptid snomedctdescriptionid originalreadcode

tab1 /**/cholesterol triglycerides/**/


// (OPTIONAL) STEP 3. PERFORM A SECONDARY SEARCH TO EXCLUDE BROAD UNDESIRED TERMS
//================================================================================

//Comment out this section if not required.

// **Exclusion terms**

local exclude " "*mildly*" "*mutation*" "*disorder*" "*fh:*" "*family*history*" "*education*" "*emia*" "*programme*" "*diet*" "*provision*" "*decline*" "*clinic*" "*cholesterolosis*" "*embol*" "*gall*" "*prophylaxis*" "*genotyp*" "*adverse*" "*granuloma*" "*polyp*" "*supplement*" "*intake*" "*7-dehydrocholesterol reductase*" "*high cholesterol*" "*high blood cholesterol*" "*disease*" "

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
/* 
   Use this command to check new possible exclusion terms:
   list term if strmatch(lower(term), lower("*example*"))
*/


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
tab1 /**/cholesterol triglycerides/**/
*/

// STEP 5. USE THE SNOMED CT CONCEPT ID TO FIND ADDITIONAL SYNONYMOUS TERMS
//==========================================================================

//Check for missing SNOMED CT Concepts
codebook snomedctconceptid
assert !missing(snomedctconceptid)

count

//Make a note of current list
preserve
	keep medcodeid /**/cholesterol triglycerides/**/
	gen byte original = 1
	tempfile original
	save `original'
restore

//Merge SNOMED CT Concepts with medical dictionary
keep snomedctconceptid /**/cholesterol triglycerides/**/
bysort snomedctconceptid: keep if _n == 1

//Merge with original search results
merge 1:m snomedctconceptid using `medical', nogenerate keep(match)
compress
merge 1:1 medcodeid using `original', nogenerate
order snomedctconceptid, before(snomedctdescriptionid)
order /**/cholesterol triglycerides/**/, last
gsort /**/cholesterol triglycerides/**/ originalreadcode

//Label new codes
gen new_snomedct_synonym = (original != 1)
drop original

//Show new codes
foreach category of varlist /**/cholesterol triglycerides/**/ {
	
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

// **Search terms for each categorisation desired**
local ldl " "*ldl*" "*low*density*" "
local non_hdl " "*non*hdl*" "*non*high*" "
local hdl " "*hdl*" "*high*density*" "
local total " "*total*" "
local ratio " "ratio *" "* ratio" "* ratio *" "
local vldl "  "*vldl*" "*very*low*" "

//Search for codes
foreach categoryterm in /**/ldl non_hdl hdl total ratio vldl/**/ {
	
	gen byte `categoryterm' = .
	
	foreach codeterm in lower(term) {
		
		foreach searchterm in ``categoryterm'' {		
			
			replace `categoryterm' = 1 if strmatch(`codeterm', "`searchterm'")
		}
	}
}

replace ldl = . if vldl == 1
replace hdl = . if non_hdl == 1 & ratio != 1
tab1 ldl non_hdl hdl total ratio vldl
gsort ratio ldl non_hdl hdl total vldl cholesterol triglycerides


// STEP 7. COMPARE LIST WITH PRE-EXISTING CODELIST(S)
//====================================================

//Comment this section out if no pre-existing codelist

//Format pre-existing codelist(s) ready for merging
preserve
	import delimited https://www.opencodelists.org/codelist/ardens/cholesterol-total-level/2020-11-06/download.csv, stringcols(1) clear
	
	local name "oc_chol_total"
	
	rename * *_`name'
	rename code_`name' snomedctconceptid
	
	generate byte `name' = 1

	tempfile `name'
	compress
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/opensafely/cholesterol-tests/09896c09/download.csv, stringcols(1) clear
	
	local name "oc_chol_test"
	
	rename * *_`name'
	rename code_`name' snomedctconceptid
	
	generate byte `name' = 1

	tempfile `name'
	compress
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/opensafely/cholesterol-tests-numerical-value/7e3a22f3/download.csv, stringcols(1) clear
	
	local name "oc_chol_value"
	
	rename * *_`name'
	rename code_`name' snomedctconceptid
	
	generate byte `name' = 1

	tempfile `name'
	compress
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/ardens/hdl-cholesterol/2020-11-06/download.csv, stringcols(1) clear
	
	local name "oc_hdlc"
	
	rename * *_`name'
	rename code_`name' snomedctconceptid
	
	generate byte `name' = 1

	tempfile `name'
	compress
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/bristol/hdl-cholesterol/64775990/download.csv, stringcols(1) clear
	
	local name "oc_hdlc_2"
	
	rename * *_`name'
	rename code_`name' snomedctconceptid
	
	generate byte `name' = 1

	tempfile `name'
	compress
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/hdlcchol_cod/20200812/download.csv, stringcols(1) clear
	
	local name "refset_hdlcchol"
	
	rename * *_`name'
	rename code_`name' snomedctconceptid
	
	generate byte `name' = 1

	tempfile `name'
	compress
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/ldlcchol_cod/20200812/download.csv, stringcols(1) clear
	
	local name "refset_ldlcchol"
	
	rename * *_`name'
	rename code_`name' snomedctconceptid
	
	generate byte `name' = 1

	tempfile `name'
	compress
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/ndacholest_cod/20200812/download.csv, stringcols(1) clear
	
	local name "refset_ndacholest"
	
	rename * *_`name'
	rename code_`name' snomedctconceptid
	
	generate byte `name' = 1

	tempfile `name'
	compress
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/ardens/non-hdl-cholesterol/2020-11-06/download.csv, stringcols(1) clear
	
	local name "oc_nonhdlc"
	
	rename * *_`name'
	rename code_`name' snomedctconceptid
	
	generate byte `name' = 1

	tempfile `name'
	compress
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/nonhdlcchol_cod/20200812/download.csv, stringcols(1) clear
	
	local name "refset_nonhdlcchol"
	
	rename * *_`name'
	rename code_`name' snomedctconceptid
	
	generate byte `name' = 1

	tempfile `name'
	compress
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/chol_cod/20200812/download.csv, stringcols(1) clear
	
	local name "refset_chol"
	
	rename * *_`name'
	rename code_`name' snomedctconceptid
	
	generate byte `name' = 1

	tempfile `name'
	compress
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/chol2_cod/20200812/download.csv, stringcols(1) clear
	
	local name "refset_chol2"
	
	rename * *_`name'
	rename code_`name' snomedctconceptid
	
	generate byte `name' = 1

	tempfile `name'
	compress
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/tcholhdl_cod/20200812/download.csv, stringcols(1) clear
	
	local name "refset_tcholhdl"
	
	rename * *_`name'
	rename code_`name' snomedctconceptid
	
	generate byte `name' = 1

	tempfile `name'
	compress
	save ``name''
restore

foreach codelist in oc_chol_total oc_chol_test oc_chol_value oc_hdlc oc_hdlc_2 refset_hdlcchol refset_ldlcchol refset_ndacholest oc_nonhdlc refset_nonhdlcchol refset_chol refset_chol2 refset_tcholhdl {
	
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
	replace cholesterol = 1 if _merge == 2

	//Drop old terms and merge variable
	drop *_`codelist' _merge
}

//Count number of codes that didn't match
count if medcodeid == ""
list snomedctconceptid term if medcodeid == ""

//Compare newly found Concept IDs against Aurum dictionary
preserve
	//Merge SNOMED CT Concepts with medical dictionary
	keep snomedctconceptid
	bysort snomedctconceptid: keep if _n == 1
	merge 1:m snomedctconceptid using `medical'
	generate byte not_in_dictionary = 1 if _merge == 1
	list snomedctconceptid if not_in_dictionary == 1
	keep if not_in_dictionary == 1
	keep snomedctconceptid not_in_dictionary
	tempfile notindict
	save `notindict'
restore

//Remove codes not in Aurum dictionary
merge m:1 snomedctconceptid using `notindict'
list snomedctconceptid term if not_in_dictionary == 1
drop if not_in_dictionary == 1
drop not_in_dictionary _merge

//Check for any addictional new codes that haven't been accounted for
list snomedctconceptid term if medcode == ""


// STEP 8. EXPORT CODELIST FOR REVIEW BY A PRIMARY CARE CLINICIAN
//================================================================

gsort ratio ldl non_hdl hdl total vldl cholesterol triglycerides -observations snomedctconceptid snomedctdescriptionid
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


// STEP 9. RESTRICT CODELIST TO CODES APPROVED BY A CLINICIAN AND SAVE
//=====================================================================

//Load clinician classifications
local clinician "CA"  //Christina Avgerinou

import excel `filename'_raw_`clinician', describe

local worksheets_N = r(N_worksheet)
local sheets ""

forvalues i = 1/`worksheets_N' {
	
	local worksheet = r(worksheet_`i')
	
	if `i' == `worksheets_N' & lower("`worksheet'") == "exclude" {
		
		continue  //skip current loop
	}
	
	local sheets "`sheets' `"`worksheet'"' "
}

local firstsheet: word 1 of `sheets'
local count = 0
tempfile sheetlabels

foreach sheet of local sheets {
	
	local count = `count'+1
	display "Reading worksheet: `sheet'"
	import excel `filename'_raw_`clinician', firstrow clear sheet("`sheet'")
	
	keep medcodeid
	generate byte `clinician' = 1
	generate byte cholesterol_type = `count'
	
	if "`sheet'" != "`firstsheet'" {
		do `sheetlabels'
	}
	label define cholesterol_type `count' "`sheet'", add
	label save using `sheetlabels', replace
	
	tempfile clinician`count'
	save `clinician`count''
}

use `filename', clear

forvalues i = 1/`count' {
	
	merge 1:1 medcodeid using `clinician`i'', update replace
	list medcodeid term if _merge == 2
	drop if _merge == 2
	drop _merge
}
do `sheetlabels'
label values cholesterol_type cholesterol_type
tab cholesterol_type, missing
list medcodeid term if cholesterol_type == .

recode `clinician' (. = 0)

//Remove codes marked for exclusion by clinician
display "Terms excluded by clinician..."
count if `clinician' == 0
list medcodeid snomedctconceptid term if `clinician' == 0
drop if `clinician' == 0

//Save clinician approved codelist
gsort cholesterol_type total hdl ldl -observations snomedctconceptid snomedctdescriptionid originalreadcode
drop new_snomedct_synonym `clinician'
compress
save `filename', replace
export delimited `filename', replace quote


// STEP 10. GENERATE METADATA FILE
//=================================

//=**Update details here, everything else is automated**========================
local description "Cholesterol measurement"
local code_type "medcodeid (SNOMED CT)"
local database "CPRD Aurum"
local database_version = ym(real(substr("`aurum_build'", 1, 4)), ///
							real(substr("`aurum_build'", 5, 2)))
local author "Philip Stone"
local date = ym(2024, 11)  //year, month
local clinical_reviewer "Christina Avgerinou"
local date_approved = ym(2025, 1)  //year, month
local notes "Created for PRIORITY study. This codelist identifies values/measurements of cholesterol only and excludes codes that indicate a diagnosis of high cholesterol"
local keywords "ldl, hdl, triglycerides, total, ratio, vldl"
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
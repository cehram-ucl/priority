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


// STEP 0. COMBINE EXTERNAL CODELIST(S) TO USE AS A GUIDE
//========================================================

//Comment this section out if no pre-existing codelists

//MedCodeID codelists (LSHTM Data Compass)

//Format pre-existing codelist(s) ready for merging
preserve
	import delimited https://datacompass.lshtm.ac.uk/id/eprint/2102/65/ethnicity_aurum_may20.txt, stringcols(1) favorstrfixed clear
	
	label define eth5 ///
		1 "White" ///
		2 "South Asian" ///
		3 "Black" ///
		4 "Other" ///
		5 "Mixed" ///
		6 "Not Stated"
	replace eth5 = "1" if eth5 == "0. White"
	replace eth5 = "2" if eth5 == "1. South Asian"
	replace eth5 = "3" if eth5 == "2. Black"
	replace eth5 = "4" if eth5 == "3. Other"
	replace eth5 = "5" if eth5 == "4. Mixed"
	replace eth5 = "6" if eth5 == "5. Not Stated"
	destring eth5, replace
	label values eth5 eth5
	
	label define eth16 ///
		1 "British" ///
		2 "Irish" ///
		3 "Other White" ///
		4 "White and Black Caribbean" ///
		5 "White and Black African" ///
		6 "White and Asian" ///
		7 "Other Mixed" ///
		8 "Indian" ///
		9 "Pakistani" ///
		10 "Bangladeshi" ///
		11 "Other Asian" ///
		12 "Caribbean" ///
		13 "African" ///
		14 "Other Black" ///
		15 "Chinese" ///
		16 "Other ethnic group" ///
		17 "Not Stated"
	replace eth16 = "1" if eth16 == "1. British"
	replace eth16 = "2" if eth16 == "2. Irish"
	replace eth16 = "3" if eth16 == "3. Other White"
	replace eth16 = "4" if eth16 == "4. White and Black Caribbean"
	replace eth16 = "5" if eth16 == "5. White and Black African"
	replace eth16 = "6" if eth16 == "6. White and Asian"
	replace eth16 = "7" if eth16 == "7. Other Mixed"
	replace eth16 = "8" if eth16 == "8. Indian"
	replace eth16 = "9" if eth16 == "9. Pakistani"
	replace eth16 = "10" if eth16 == "10. Bangladeshi"
	replace eth16 = "11" if eth16 == "11. Other Asian"
	replace eth16 = "12" if eth16 == "12. Caribbean"
	replace eth16 = "13" if eth16 == "13. African"
	replace eth16 = "14" if eth16 == "14. Other Black"
	replace eth16 = "15" if eth16 == "15. Chinese"
	replace eth16 = "16" if eth16 == "16. Other ethnic group"
	replace eth16 = "17" if eth16 == "17. Not Stated"
    destring eth16, replace
	label values eth16 eth16
	
	//Remove "Not Stated" codes
	tab eth16 eth5, missing
	drop if eth5 == 6
	drop if eth16 == 17
	
	local name "lshtm_2102"
	
	rename term term_`name'
	generate byte external_codelist = 1
	generate byte `name' = 1
	
	count

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://datacompass.lshtm.ac.uk/id/eprint/2414/1/cr_codelist_ethnicity_aurum.txt, stringcols(1) favorstrfixed clear
	
	//NO CATEGORISATION PROVIDED
	
	local name "lshtm_2414"
	
	rename term term_`name'
	generate byte external_codelist = 1
	generate byte `name' = 1
	
	count

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://datacompass.lshtm.ac.uk/id/eprint/4214/24/covariate_ethniciity_aurum.txt, stringcols(1) favorstrfixed clear
	
	label define eth5 ///
		1 "White" ///
		2 "South Asian" ///
		3 "Black" ///
		4 "Other" ///
		5 "Mixed" ///
		6 "Not Stated"
	replace eth5 = "1" if eth5 == "0. White"
	replace eth5 = "2" if eth5 == "1. South Asian"
	replace eth5 = "3" if eth5 == "2. Black"
	replace eth5 = "4" if eth5 == "3. Other"
	replace eth5 = "5" if eth5 == "4. Mixed"
	replace eth5 = "6" if eth5 == "5. Not Stated"
	destring eth5, replace
	label values eth5 eth5
	
	//Remove "Not Stated" codes
	tab eth5, missing
	drop if eth5 == 6
	
	local name "lshtm_4214"
	
	rename term term_`name'
	generate byte external_codelist = 1
	generate byte `name' = 1
	
	count

	tempfile `name'
	save ``name''
restore

//SNOMED CT codelists (HDR UK Phenotype Library and OpenCodelists)

//Format pre-existing codelist(s) ready for merging
preserve
	import delimited https://www.opencodelists.org/codelist/opensafely/ethnicity-snomed-0removed/2e641f61/download.csv, stringcols(1) favorstrfixed clear
	
	rename snomedcode snomedctconceptid
	
	//OpenSAFELY's 5 category ethnicity is ordered differently
	/* Their categorisation:
	1 "White" ///
	2 "Mixed" ///
	3 "Asian or Asian British" ///
	4 "Black or Black British" ///
	5 "Chinese or Other Ethnic Groups"
	*/
	rename grouping_6 eth5
	recode eth5 (2 = 5) (3 = 2) (4 = 3) (5 = 4)
	label define eth5 ///
		1 "White" ///
		2 "South Asian" ///
		3 "Black" ///
		4 "Other" ///
		5 "Mixed" ///
		6 "Not Stated"
	label values eth5 eth5
	
	rename grouping_16 eth16
	label define eth16 ///
		1 "British" ///
		2 "Irish" ///
		3 "Other White" ///
		4 "White and Black Caribbean" ///
		5 "White and Black African" ///
		6 "White and Asian" ///
		7 "Other Mixed" ///
		8 "Indian" ///
		9 "Pakistani" ///
		10 "Bangladeshi" ///
		11 "Other Asian" ///
		12 "Caribbean" ///
		13 "African" ///
		14 "Other Black" ///
		15 "Chinese" ///
		16 "Other ethnic group" ///
		17 "Not Stated"
	label values eth16 eth16
	
	local name "oc_opensafely_ethnicity"
	
	rename ethnicity term_`name'
	rename eth5 eth5_`name'
	rename eth16 eth16_`name'
	
	generate byte external_codelist = 1
	generate byte `name' = 1
	
	count

	tempfile `name'
	save ``name''
restore

//Merge into medical browser
use `medical', clear
count

//Medcode lists
foreach external_med in lshtm_2102 lshtm_2414 lshtm_4214 {
	
	merge 1:1 medcodeid using ``external_med'', update replace
	drop if _merge == 2
	
	display "Conflicts..."
	list medcodeid term eth16 eth5 if _merge == 5
	drop _merge
	
	display "Differences in term from CPRD dictionary..."
	count if lower(term) != lower(term_`external_med') & term_`external_med' != ""
	list term term_`external_med' ///
		if lower(term) != lower(term_`external_med') & term_`external_med' != ""
	drop term_`external_med'
}

//SNOMED CT lists
foreach external_sct in oc_opensafely_ethnicity {
	
	merge m:1 snomedctconceptid using ``external_sct'', update //replace
	drop if _merge == 2
	
	display "Conflicts..."
	list medcodeid term eth16 eth5 if _merge == 5
	drop _merge
	
	drop term_`external_sct'
}

order external_codelist, after(term)
order lshtm_* oc_*, last
count

//Fill in gaps with OpenSAFELY codelist categories
replace eth5 = eth5_oc_opensafely_ethnicity if eth5 == .
replace eth16 = eth16_oc_opensafely_ethnicity if eth16 == .

//Choose correct value for conflicts
list medcodeid term eth5 eth5_oc_opensafely_ethnicity ///
	if eth5 != eth5_oc_opensafely_ethnicity & eth5_oc_opensafely_ethnicity != .

display "Changing..."
local changes "250243013 141511000000116 158371000000111 1968121000006114 285925010 285930014 285976013 405064011 405067016 411578016 411579012 411580010 453109012 453110019 196601000006113 6846371000006111 196641000006110 141521000000110 141591000000113 141601000000119 285951012 4740361000006111"
foreach change of local changes {
	
	list observations term eth5* if medcodeid == "`change'"
	replace eth5 = eth5_oc_opensafely_ethnicity if medcodeid == "`change'"
	
	list observations term eth16* if medcodeid == "`change'"
	replace eth16 = eth16_oc_opensafely_ethnicity if medcodeid == "`change'"
}

display "Leaving as is..."
list term eth5* ///
	if eth5 != eth5_oc_opensafely_ethnicity & eth5_oc_opensafely_ethnicity != .
	
list medcodeid term eth16 eth16_oc_opensafely_ethnicity ///
	if eth16 != eth16_oc_opensafely_ethnicity & eth16_oc_opensafely_ethnicity != .
	
drop eth5_oc_opensafely_ethnicity eth16_oc_opensafely_ethnicity


//Making some (what I think are) corrections
local asianother "157351000000115 250268010 1745831000006112 490271012 2694381019 2692541014 2692313014 3493721000006113 3605071000006112 142891000000115"
foreach code of local asianother {
	
	replace eth5 = 2 if medcodeid == "`code'"
	replace eth16 = 11 if medcodeid == "`code'"
	list term eth5 eth16 if medcodeid == "`code'"
}

local whiteother "250227018 286008019 713761000000111 714141000000111 2691976017"
foreach code of local whiteother {
	
	replace eth5 = 1 if medcodeid == "`code'"
	replace eth16 = 3 if medcodeid == "`code'"
	list term eth5 eth16 if medcodeid == "`code'"
}

local blackcarribean "250231012"
foreach code of local blackcarribean {
	
	replace eth5 = 3 if medcodeid == "`code'"
	replace eth16 = 12 if medcodeid == "`code'"
	list term eth5 eth16 if medcodeid == "`code'"
}

local otherchinese "713491000000110"
foreach code of local otherchinese {
	
	replace eth5 = 4 if medcodeid == "`code'"
	replace eth16 = 15 if medcodeid == "`code'"
	list term eth5 eth16 if medcodeid == "`code'"
}

local otherother "1573191000006117 250225014 250226010 2849971000006118 196661000006114 196701000006118 3748491000006113"
foreach code of local otherother {
	
	replace eth5 = 4 if medcodeid == "`code'"
	replace eth16 = 16 if medcodeid == "`code'"
	list term eth5 eth16 if medcodeid == "`code'"
}

local remove "6260901000006118 459785017"
foreach code of local remove {
	
	list term eth5 eth16 if medcodeid == "`code'"
	drop if medcodeid == "`code'"
}


// STEP 1. IDENTIFY SEARCH TERMS
//===============================

// JUST AMALGAMATING/MODIFIYING EXISTING LISTS; NO SEARCH REQUIRED
keep if external_codelist == 1
drop if eth5 == .
compress

// **Define search terms below. Use multiple local macros if categorising desired codes in to multiple categories make more sense**
/*
local ethnicity " "*ethnicity*" "


// STEP 2. SEARCH THE MEDICAL TERMINOLOGY DICTIONARY USING THE SEARCH TERMS
//==========================================================================

// **Add any additional local macros if you have used more than 1**
//For each specified local macro...
foreach termgroup in /**/ethnicity/**/ {
	
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

keep if /**/ethnicity == 1/**/ | external_codelist == 1
compress

order /**/ethnicity/**/, after(term)
gsort /**/ethnicity/**/ -observations snomedctconceptid snomedctdescriptionid originalreadcode

tab1 /**/ethnicity/**/


// (OPTIONAL) STEP 3. PERFORM A SECONDARY SEARCH TO EXCLUDE BROAD UNDESIRED TERMS
//================================================================================

//Comment out this section if not required.

// **Exclusion terms**

local exclude " "*excludeme*" "

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
list medcodeid term if exclude == 1
/**/ /*ANY OTHER EXCLUSION CATEGORIES*/ /**/

//Make any corrections
local corrections "123"

foreach correction of local corrections {
	
	list medcodeid term if medcodeid == "`correction'"
	
	foreach var of varlist exclude /**/ /*ANY OTHER EXCLUSION CATEGORIES*/ /**/ {
	
		replace `var' = . if medcodeid == "`correction'"
	}
}

replace exclude = 1 if /**/ /*ANY OTHER EXCLUSION CATEGORIES*/ /**/
drop if exclude == 1 & external_codelist != 1
//drop exclude /**/ /*ANY OTHER EXCLUSION CATEGORIES*/ /**/
count
compress


// STEP 4. MANUAL SCREEN OF CODELIST TO REMOVE UNDESIRED TERMS
//=============================================================

// **medcodeids to remove**
local initial_remove "123"

gen byte remove = 0

foreach medcode of local initial_remove {
	
	replace remove = 1 if medcodeid == "`medcode'"
}

list medcodeid snomedctdescriptionid snomedctconceptid originalreadcode term  ///
	observations external_codelist if remove == 1
drop if remove == 1 & external_codelist != 1

//List disagreements between my list and external lists
replace exclude = 1 if remove == 1
list term lshtm_* oc_* if exclude == 1 & external_codelist == 1

// COMMENT HERE

drop if exclude == 1
drop exclude /**/ /*ANY OTHER EXCLUSION CATEGORIES*/ /**/ remove

//External codes that I didn't find
list medcodeid term *_ext lshtm_* oc_* ///
	if bmi != 1 & height != 1 & weight != 1 & external_codelist == 1

// COMMENT HERE

compress
tab1 /**/ethnicity/**/


// (OPTIONAL) STEP 5. USE ANOTHER SEARCH TO AUTOMATE THE CATEGORISATION OF CODES
//===============================================================================

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

//Already categorised, but requires fixing
replace weight = . if bmi == 1
*/

// STEP 6. USE THE SNOMED CT CONCEPT ID TO FIND ADDITIONAL SYNONYMOUS TERMS
//==========================================================================

//Check for missing SNOMED CT Concepts
codebook snomedctconceptid
assert !missing(snomedctconceptid)

count

//Make a note of current list
preserve
	keep medcodeid /**/eth5 eth16 lshtm_* oc_* /**/
	gen byte original = 1
	tempfile original
	save `original'
restore

//Merge SNOMED CT Concepts with medical dictionary
keep snomedctconceptid /**/eth5 eth16/**/
bysort snomedctconceptid: keep if _n == 1

//Merge with original search results
merge 1:m snomedctconceptid using `medical', nogenerate keep(match)
compress
merge 1:1 medcodeid using `original', nogenerate
order medcodeid observations originalreadcode cleansedreadcode ///
	snomedctconceptid snomedctdescriptionid term
gsort /**/eth5 eth16/**/ originalreadcode

//Label new codes
gen new_snomedct_synonym = (original != 1)
drop original

//Show new codes
foreach category of varlist /**/eth5 eth16/**/ {
	
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
	
	list medcodeid originalreadcode term new_snomedct_synonym eth5 eth16 ///
		if snomedctconceptid == "`expanded_id'"
}

//Any corrections
list if medcodeid == "459785017"
drop if medcodeid == "459785017"


// STEP 7. COMPARE LIST WITH PREVIOUS CODELIST
//=============================================

//None - this is the first version of the codelist


// STEP 8. EXPORT CODELIST FOR REVIEW BY A PRIMARY CARE CLINICIAN
//================================================================
/* NOT BEING REVIEWED
gsort /**/ethnicity/**/ -observations snomedctconceptid snomedctdescriptionid
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

// STEP 9. RESTRICT YOUR CODELIST TO CODES APPROVED BY A PRIMARY CARE CLINICIAN AND SAVE
//=======================================================================================

//Load clinician classifications
local clinician "ABC"
/* NOT CLINICALLY REVIEWED
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
gsort /**/eth5 eth16/**/ -observations snomedctconceptid snomedctdescriptionid originalreadcode
drop new_snomedct_synonym /*codestatus*/ /*`clinician'*/
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
local date_approved = . //year, month
local notes "The ethnicity categories defined in the 2001 Census: https://www.ethnicity-facts-figures.service.gov.uk/style-guide/ethnic-groups/#2001-census. Rationale being that NHS Data Model and Dictionary still uses 2001 Census categories. See: https://github.com/opensafely/codelist-development/issues/126. An amalgamation of codelists created by Rohini Mathur and colleagues with some corrections I felt were necessary. 'Not Stated' codes were removed. Created for PRIORITY study."
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
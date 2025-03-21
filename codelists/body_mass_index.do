//==============================================================================
// 2024-10-18 PWS codelist creation template
//
// BODY MASS INDEX
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
local filename "body_mass_index"

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


// STEP 0. COMBINE EXTERNAL CODELIST(S) TO USE AS A GUIDE
//========================================================

//Comment this section out if no pre-existing codelists

//MedCodeID codelists (LSHTM Data Compass)

//Format pre-existing codelist(s) ready for merging
preserve
	import delimited https://datacompass.lshtm.ac.uk/id/eprint/2413/1/cr_codelist_bmi_aurum.txt, stringcols(1) clear
	
	recode bmi weight height (9 = 1)
	keep medcodeid bmi weight height
	
	local name "lshtm_2413"
	
	rename * *_ext
	rename medcodeid_ex medcodeid
	generate byte external_codelist = 1
	generate byte `name' = 1
	
	count

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://datacompass.lshtm.ac.uk/id/eprint/3323/7/m_heightweightbmi_aurum.txt, stringcols(1) favorstrfixed clear
	
	keep medcodeid weight bmi
	
	local name "lshtm_3323"
	
	rename * *_ext
	rename medcodeid_ex medcodeid
	generate byte external_codelist = 1
	generate byte `name' = 1
	
	count

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://datacompass.lshtm.ac.uk/id/eprint/4214/33/covariate_bmi_aurum.txt, stringcols(1) favorstrfixed clear
	
	recode bmi weight height (9 = 1)
	
	tab bmicat
	label define bmicat 1 "Underweight (<18.5)" 2 "Normal (18.5-24.9)" ///
		3 "Overweight (25-29)" 4 "Obese (30+)"
	replace bmicat = "1" if bmicat == "underweight <18.5"
	replace bmicat = "2" if bmicat == "normal 18.5-24.9"
	replace bmicat = "3" if bmicat == "overweight 25-29"
	replace bmicat = "4" if bmicat == "obese 30+"
	destring bmicat, replace
	label values bmicat bmicat
	tab bmicat bmi, missing
	
	keep medcodeid weight bmi bmicat
	
	local name "lshtm_4214"
	
	rename * *_ext
	rename medcodeid_ex medcodeid
	generate byte external_codelist = 1
	generate byte `name' = 1
	
	count

	tempfile `name'
	save ``name''
restore

//SNOMED CT codelists (HDR UK Phenotype Library and OpenCodelists)

//Format pre-existing codelist(s) ready for merging
preserve
	import delimited https://www.opencodelists.org/codelist/primis-covid19-vacc-uptake/bmi/v2.5/download.csv, stringcols(1) clear
	
	keep code
	rename code snomedctconceptid
	
	local name "oc_primis_bmi"
	
	generate byte bmi_ext = 1
	generate byte external_codelist = 1
	generate byte `name' = 1
	
	count

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/bmival_cod/20201016/download.csv, stringcols(1) clear
	
	local name "oc_nhspcdr_bmival"
	
	keep code
	rename code snomedctconceptid
	
	generate byte bmi_ext = 1
	generate byte external_codelist = 1
	generate byte `name' = 1
	
	count

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/opensafely/weight-snomed/5459abc6/download.csv, stringcols(1) clear
	
	local name "oc_opensafely_weight"
	
	keep code
	rename code snomedctconceptid
	
	generate byte weight_ext = 1
	generate byte external_codelist = 1
	generate byte `name' = 1
	
	count

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/opensafely/height-snomed/3b4a3891/download.csv, stringcols(1) clear
	
	local name "oc_opensafely_height"
	
	keep code
	rename code snomedctconceptid
	
	generate byte height_ext = 1
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
foreach external_med in lshtm_2413 lshtm_3323 lshtm_4214 {
	
	merge 1:1 medcodeid using ``external_med'', update replace
	drop if _merge == 2
	drop _merge
}

//SNOMED CT lists
foreach external_sct in oc_primis_bmi oc_nhspcdr_bmival oc_opensafely_weight oc_opensafely_height {
	
	merge m:1 snomedctconceptid using ``external_sct'', update replace
	drop if _merge == 2
	drop _merge
}

order external_codelist, after(term)
order lshtm_* oc_*, last
count


// STEP 1. IDENTIFY SEARCH TERMS
//===============================

//**Define search terms below. Use multiple local macros if categorising desired codes in to multiple categories make more sense**

local bmi " "*body*mass*index*" "bmi *" "* bmi" "* bmi *" "*obese*" "*overweight*" "*underweight*" "
local height " "*height*" "
local weight " "*weight*" "


// STEP 2. SEARCH THE MEDICAL TERMINOLOGY DICTIONARY USING THE SEARCH TERMS
//==========================================================================

//**Add any additional local macros if you have used more than 1**
//For each specified local macro...
foreach termgroup in /**/bmi height weight/**/ {
	
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

keep if /**/bmi == 1 | height == 1 | weight == 1/**/ | external_codelist == 1
compress

order /**/bmi height weight/**/, after(term)
gsort /**/bmi height weight/**/ -observations snomedctconceptid snomedctdescriptionid originalreadcode

tab1 /**/bmi height weight/**/


// (OPTIONAL) STEP 3. PERFORM A SECONDARY SEARCH TO EXCLUDE BROAD UNDESIRED TERMS
//================================================================================

//Comment out this section if not required.

// **Exclusion terms**

local exclude " "*glucose*" "*abdomen*" "*gestation*" "*foetal*" "*fetal*" "*disorder*" "*tool*" "*questionnaire*" "*score*" "*risk*" "*advice*" "*weight*bear*" "*fundal*" "*fundus*" "*uterine*" "*uterus*" "*predict*" "*fall*" "*injury*" "*unfit*" "*unsuitable*" "*knee*" "*modification*" "*step*" "*fear*" "*jump*" "*footwear*" "*heightened*" "*sitting*" "*demispan*" "*pubis*" "*heights*" "*gait*" "*ratio*" "*estimate*" "*monitor*" "*diet*" "*regimen*" "*7pcl*" "*checklist*" "*molecular*" "*counterweight*" "*problem*" "*concern*" "*placenta*" "*weightless*" "*weighted*" "*wave*" "*education*" "*symptom*" "*screen*" "*calculus*" "*appraisal*" "*trend*" "*eyelid*" "*not*" "*lifter*" "*weights*" "*decline*" "*fixation*" "*preoccup*" "*dry*" "*sweat*" "*sample*" "*heavy*" "*transfer*" "*chart*" "*date*" "*velocity*" "*previous*" "*consult*" "*kcal/kg*" "*g/kg*" "
local change " "*change*" "*reduc*" "*decreasing*" "*los*" "*increasing*" "*gain*" "*fluctuate*" "
local target " "*target*" "*ideal*" "
local child " "*child*" "*centile*" "*age*" "*grow*" "*parent*" "
local baby " "*baby*" "*birth*" "*infant*" "

//Search for codes to exclude
foreach excludeterm in exclude /**/change target child baby/**/ {

	gen byte `excludeterm' = .

	foreach codeterm in lower(term) {
		
		foreach searchterm in ``excludeterm'' {		
			
			replace `excludeterm' = 1 if strmatch(`codeterm', "`searchterm'")
		}
	}
}

//Check that nothing important is highlighted for exclusion before dropping
list medcodeid term if exclude == 1
/**/list medcodeid term observations if change == 1
list medcodeid term observations if target == 1
list medcodeid term if child == 1
list medcodeid term observations if baby == 1/**/

//Make any corrections
local corrections "981741000006110 981731000006117"

foreach correction of local corrections {
	
	list medcodeid term if medcodeid == "`correction'"
	
	foreach var of varlist exclude /**/change target child baby/**/ {
	
		replace `var' = . if medcodeid == "`correction'"
	}
}

replace exclude = 1 if /**/change == 1 | target == 1 | child == 1 | baby == 1/**/
drop if exclude == 1 & external_codelist != 1
//drop exclude /**/change target child baby/**/
count
compress


// STEP 4. MANUAL SCREEN OF CODELIST TO REMOVE UNDESIRED TERMS
//=============================================================

// **medcodeids to remove**
local initial_remove "908721000006111 5256391000006115 957731000006119 982601000006111 982611000006114 4935071000006119 3667431000006112 5529871000006114"

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

//OpenCodelists codelists appear to be of higher quaity (no disagreement)
//Nothing important in disagreements with LSHTM, so I will exclude

drop if exclude == 1
drop exclude /**/change target child baby/**/ remove

//External codes that I didn't find
list medcodeid term *_ext lshtm_* oc_* ///
	if bmi != 1 & height != 1 & weight != 1 & external_codelist == 1

//extra BMI code from OpenCodelists
//I will add it as it is based on SNOMED CT concept ID
replace bmi = 1 if medcodeid == "3484811000006112"

compress
tab1 /**/bmi height weight/**/


// (OPTIONAL) STEP 5. USE ANOTHER SEARCH TO AUTOMATE THE CATEGORISATION OF CODES
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
gsort cat1 cat2
*/
//Already categorised, but requires fixing
replace weight = . if bmi == 1


// STEP 6. USE THE SNOMED CT CONCEPT ID TO FIND ADDITIONAL SYNONYMOUS TERMS
//==========================================================================

//Check for missing SNOMED CT Concepts
codebook snomedctconceptid
assert !missing(snomedctconceptid)

count

//Make a note of current list
preserve
	keep medcodeid /**/bmi height weight *_ext lshtm_* oc_*/**/
	gen byte original = 1
	tempfile original
	save `original'
restore

//Merge SNOMED CT Concepts with medical dictionary
keep snomedctconceptid /**/bmi height weight/**/
bysort snomedctconceptid: keep if _n == 1

//Merge with original search results
merge 1:m snomedctconceptid using `medical', nogenerate keep(match)
compress
merge 1:1 medcodeid using `original', nogenerate
order medcodeid observations originalreadcode cleansedreadcode ///
	snomedctconceptid snomedctdescriptionid term
gsort /**/bmi height weight/**/ originalreadcode

//Label new codes
gen new_snomedct_synonym = (original != 1)
drop original

//Show new codes
foreach category of varlist /**/bmi height weight/**/ {
	
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


// STEP 7. COMPARE LIST WITH PREVIOUS CODELIST
//=============================================

//None - this is the first version of the codelist


// STEP 8. EXPORT CODELIST FOR REVIEW BY A PRIMARY CARE CLINICIAN
//================================================================
/* NOT CLINICALLY REVIEWED
gsort /**/bmi height weight/**/ -observations snomedctconceptid snomedctdescriptionid
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
order *_ext, last
gsort /**/bmi height weight/**/ -observations snomedctconceptid snomedctdescriptionid originalreadcode
drop new_snomedct_synonym /**_ext lshtm_* oc_**/ /*`clinician'*/
compress
save `filename', replace
export delimited `filename', replace quote


// STEP 10. GENERATE METADATA FILE
//=================================

//=**Update details here, everything else is automated**========================
local description "Body mass index"
local code_type "medcodeid (SNOMED CT)"
local database "CPRD Aurum"
local database_version = ym(real(substr("`aurum_build'", 1, 4)), ///
							real(substr("`aurum_build'", 5, 2)))
local author "Philip Stone"
local date = ym(2024, 12)  //year, month
local clinical_reviewer ""
local date_approved = . //ym(2024, 12)  //year, month
local notes "Not clinicially reviewed. Created for PRIORITY study. Child and birth measures are excluded. Target weight/BMI is also excluded."
local keywords "height, weight, bmi"
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
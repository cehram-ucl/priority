//==============================================================================
// 2025-03-1804 PWS drug codelist creation template
//
// STATINS
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
local filename "statins"

//*Aurum build/version*
local aurum_build "202309"

//==============================================================================

//Open log file
capture log close
log using `filename', text replace


//= CPRD LOOKUP LOCATION - would be good to get this in a shared location ======

//*Directory of product dictionary*
local browser_dir "C:\Users\rmjlton.AD\OneDrive - University College London\CPRD\CPRD Aurum\Code Browser\CPRD_CodeBrowser_`aurum_build'_Aurum"

//*Directory of BNF to SNOMED mapping*
local bnfsnomedmap_dir "C:\Users\rmjlton.AD\OneDrive - University College London\NHS TRUD\NHSBSA BNF SNOMED Mapping"

//==============================================================================

//Import BNF to SNOMED mapping
import excel "`bnfsnomedmap_dir'/BNF Snomed Mapping data 20250221.xlsx", firstrow case(lower) clear

drop if bnfcode == ""
keep bnfcode bnfname snomedcode
rename snomedcode dmdid

tempfile bnf_snomed_map
save `bnf_snomed_map'


//Import latest product browser; force prodcodeid and DM+D ID to be string
import delimited "`browser_dir'/CPRDAurumProduct.txt", stringcols(1 2 9) favorstrfixed bindquotes(nobind) clear

order drugissues, after(prodcodeid)

//Merge with BNF mapping
count
merge m:1 dmdid using `bnf_snomed_map'
drop if _merge == 2
drop _merge
count

//Generate clean BNF variable
//Leading zero is omitted at 1st level in 'bnfchapter' variable
//Leading zero is omitted at 4th level in 'bnfcode' variable
generate bnfchapt = bnfchapter
replace bnfchapt = "0" + bnfchapter if length(bnfchapter) == 7
generate bnfcodeshort = substr(bnfcode, 1, 6) + "0" + substr(bnfcode, 7, 1) ///
	if bnfcode != ""

//Disagreements
list termfromemis drugsubstancename bnfchapt bnfcodeshort ///
	if bnfchapt != bnfcodeshort & bnfchapter != "" & bnfcode != ""
	
//Favour original value but keep bnfcodeshort variable for reference
replace bnfchapt = bnfcodeshort if bnfchapt == ""

order bnfchapt, after(bnfchapter)
drop bnfchapter
order bnfcodeshort, after(bnfcode)

//Save product code browser to a tempfile
compress
tempfile product
save `product'


// STEP 1. SELECT BNF CHAPTERS TO INCLUDE
//========================================

//BNF Chapter information: https://openprescribing.net/bnf/

//BNF Chapter 2.12: Lipid-regulating drugs
generate byte bnf0212 = 1 if strmatch(bnfchapt, "0212*")

//Show drugs in each chapter
foreach chapter in 0212 {
	
	display "BNF Chapter: `chapter'"
	tab drugsubstancename if bnf`chapter' == 1, missing
}


// STEP 2. USING INFOFORMATION FROM BNF AND STEP 1 CREATE SEARCH TERMS
//         (ONE TERM FOR EACH DRUG THAT INCLUDES CHEMICAL NAME AND ANY 
//         BRAND NAMES)
//=====================================================================

//BNF Chapter 2.12: Lipid-regulating drugs
local acipimox "acipimox olbetam"
local alirocumab "alirocumab praluent"
local atorvastatin "atorvastatin lipitor"
local bempedoic "bempedoic nilemdo nustendi"
local bezafibrate "bezafibrate bezalip lipozate liparol fibrazate zimbacol bezagen"
local cerivastatin "cerivastatin lipobay"
local ciprofibrate "ciprofibrate modalim"
local colesevelam "colesevelam cholestagel"
local colestipol "colestipol colestid"
local colestyramine "colestyramine questran"
local evolocumab "evolocumab repatha"
local ezetimibe "ezetimibe nustendi ezetrol inegy"
local fenofibrate "fenofibrate lipantil supralip cholib fenogal"
local fluvastatin "fluvastatin luvinsta dorisin nandovar lescol"
local gemfibrozil "gemfibrozil lopid"
local icosapent "icosapent vazkepa"
local inclisiran "inclisiran leqvio"
//local ispaghula "ispaghula"
local lomitapide "lomitapide"  //not listed on OpenPrescribing
local nicotinic "nicotinic tredaptive"
local omega "omega eicosapentaenoic docosahexaenoic omacor teromeg prestylon nebbaro dualtis"
local policosanol "policosanol"
local pravastatin "pravastatin lipostat"
local rosuvastatin "rosuvastatin crestor"
local simvastatin "simvastatin zocor inegy simvador cholib"

local bnf0212 "acipimox alirocumab atorvastatin bempedoic bezafibrate cerivastatin ciprofibrate colesevelam colestipol colestyramine evolocumab ezetimibe fenofibrate fluvastatin gemfibrozil icosapent inclisiran lomitapide nicotinic omega policosanol pravastatin rosuvastatin simvastatin"


// STEP 3. CREATE MACRO CONTAINING ALL DRUG MACROS CREATED IN STEP 2
//         AND SEARCH THE PRODUCT DICTIONARY FOR EACH DRUG
//===================================================================

local statins "bnf0212"

generate byte statin = 0

foreach bnf_section of local statins {
	
	display "`bnf_section'"
	
	foreach drug of local `bnf_section' {
		
		display "Drug: `drug'"  //for debugging
		generate byte `drug' = 0
		
		foreach term of local `drug' {
			
			display "Term: `term'"  //for debugging
			
			foreach scan_var of varlist termfromemis drugsubstancename bnfname {
				
				foreach label_var of varlist statin `drug' ///
					`bnf_section' {
					
					replace `label_var' = 1 if strpos(lower(`scan_var'), "`term'")
				}
			}
		}
	}
}

tab1 statin, missing
foreach bnf_section of local statins {
	
	tab `bnf_section', missing
	
	foreach drug of local `bnf_section' {
		
		tab `drug', missing
	}
}

tab bnf0212 statin, missing
list prodcodeid termfromemis drugsubstancename bnfchapt ///
	if bnf0212 == 1 & statin == 0  //keep or remove?

keep if statin == 1
compress
count

//Fix erroneous labelling of Eicosapentaenoic acid as Icosapent
list termfromemis drugsubstancename icosapent omega ///
	if icosapent == 1 & omega == 1
replace icosapent = 0 if icosapent == 1 & omega == 1
list termfromemis drugsubstancename icosapent omega ///
	if icosapent == 1 & omega == 1

//Check included products for each drug
//(Also use this to go back and add any brand names that may have been missed)
foreach bnf_section of local statins {
	
	foreach drug of local `bnf_section' {
		
		display "Drug: `drug'"
		tab `drug', missing
		list prodcodeid termfromemis drugsubstancename routeofadministration ///
			bnfchapt if `drug' == 1
	}
}


// (OPTIONAL) STEP 4. PERFORM SECOND SEARCH TO EXCLUDE UNDESIRED PRODUCTS
//========================================================================

//Comment out this section if not required.

// **Exclusion terms**

local exclude " "*clopidogrel*" "*ticlopidine*" "*deodorising*" "*niacin*" "*berocca*" "*omega oil*" "*omega pharma*" "*omega-7*" "*keyomega*" "*docomega*" "*fish oil*" "*eye *" "*eyes *" "*nomegestrol*" "*nutrigen*" "*somacorrect*" "*breast*" "

//Search for codes to exclude
foreach excludeterm in exclude {

	gen byte `excludeterm' = .

	foreach codeterm in termfromemis drugsubstancename {
		
		foreach searchterm in ``excludeterm'' {		
			
			replace `excludeterm' = 1 ///
				if strmatch(lower(`codeterm'), "`searchterm'")
		}
	}
}

//Check that nothing important is highlighted for exclusion before dropping
list /*prodcodeid*/ termfromemis drugsubstancename bnfchapt if exclude == 1
drop if exclude == 1
drop exclude
count
compress

//Check included products for each drug
//(Also use this to go back and add any brand names that may have been missed)
foreach bnf_section of local statins {
	
	foreach drug of local `bnf_section' {
		
		display "Drug: `drug'"
		tab `drug', missing
		list prodcodeid termfromemis drugsubstancename routeofadministration ///
			bnfchapt if `drug' == 1
	}
}


// (OPTIONAL) STEP 5. CATEGORISE DRUGS
//=====================================

//Check for any products containing multiple drugs (categorisation won't work otherwise)
egen statin_count = rowtotal(acipimox alirocumab atorvastatin bempedoic bezafibrate cerivastatin ciprofibrate colesevelam colestipol colestyramine evolocumab ezetimibe fenofibrate fluvastatin gemfibrozil icosapent inclisiran lomitapide nicotinic omega policosanol pravastatin rosuvastatin simvastatin)

tab statin_count, missing
//drop statin_count
/* NOT POSSIBLE TO CATEGORISE
generate byte statin_medication = 0
label define statin_medication, replace
label values statin_medication statin_medication
local count = 0
foreach drug of local statins {
	
	local count = `count'+1
	local capitalise = strproper("`drug'")  //makes first letter upper case
	
	label define statin_medication `count' "`capitalise'", add
	
	replace statin_medication = `count' if `drug' == 1
	
	tab statin_medication `drug', missing
	drop `drug'
}
recode statin_medication (0 = .)
tab1 statin_medication, missing
*/

// (OPTIONAL) STEP 6. COMPARE AGAINST PRE-EXISTING LISTS
//=======================================================

//Import repository codelists

//MedCodeID codelists (LSHTM Data Compass)
preserve
	import delimited https://datacompass.lshtm.ac.uk/id/eprint/2102/49/statins_aurum_mar20.txt, stringcols(1) favorstrfixed clear
	
	keep prodcodeid termfromemis
	
	local name "lshtm_2102"
	
	rename * *_ext
	rename prodcodeid_ext prodcodeid
	generate byte statin = 1
	generate byte external_codelist = 1
	generate byte `name' = 1
	
	count
	merge 1:1 prodcodeid using `product'
	list prodcodeid termfromemis_ext if _merge == 1
	keep if _merge == 3
	keep prodcodeid statin external_codelist `name'

	tempfile `name'
	compress
	save ``name''
restore, preserve
	import delimited https://datacompass.lshtm.ac.uk/id/eprint/2199/1/statins_aurum_mar20.csv, stringcols(1) favorstrfixed clear
	
	keep prodcodeid termfromemis
	
	local name "lshtm_2199"
	
	rename * *_ext
	rename prodcodeid_ext prodcodeid
	generate byte statin = 1
	generate byte external_codelist = 1
	generate byte `name' = 1
	
	count
	merge 1:1 prodcodeid using `product'
	list prodcodeid termfromemis_ext if _merge == 1
	keep if _merge == 3
	keep prodcodeid statin external_codelist `name'

	tempfile `name'
	compress
	save ``name''
restore, preserve
	import delimited https://datacompass.lshtm.ac.uk/id/eprint/2470/1/statins_aurum_feb21.txt, stringcols(1) favorstrfixed clear
	
	keep prodcodeid termfromemis
	
	local name "lshtm_2470"
	
	rename * *_ext
	rename prodcodeid_ext prodcodeid
	generate byte statin = 1
	generate byte external_codelist = 1
	generate byte `name' = 1
	
	count
	merge 1:1 prodcodeid using `product'
	list prodcodeid termfromemis_ext if _merge == 1
	keep if _merge == 3
	keep prodcodeid statin external_codelist `name'

	tempfile `name'
	compress
	save ``name''
restore

//SNOMED CT codelists (HDR UK Phenotype Library and OpenCodelists)
preserve
	import delimited https://phenotypes.healthdatagateway.org/phenotypes/PH972/version/2150/export/codes, stringcols(1) favorstrfixed clear
	
	keep code description
	rename code bnfcode
	
	codebook bnfcode
	
	local name "hdruk_972"
	
	rename description description_ext
	generate byte statin = 1
	generate byte external_codelist = 1
	generate byte `name' = 1
	
	count
	merge 1:m bnfcode using `product'
	list bnfcode description_ext if _merge == 1
	keep if _merge == 3
	keep prodcodeid statin external_codelist `name'

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://phenotypes.healthdatagateway.org/phenotypes/PH1013/version/2191/export/codes, stringcols(1) favorstrfixed clear
	
	keep code description
	rename code bnfcode
	
	codebook bnfcode
	
	local name "hdruk_1013"
	
	rename description description_ext
	generate byte statin = 1
	generate byte external_codelist = 1
	generate byte `name' = 1
	
	count
	merge 1:m bnfcode using `product'
	list bnfcode description_ext if _merge == 1
	keep if _merge == 3
	keep prodcodeid statin external_codelist `name'

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://phenotypes.healthdatagateway.org/phenotypes/PH1600/version/3013/export/codes, stringcols(1) favorstrfixed clear
	
	keep code description
	rename code bnfcode
	
	codebook bnfcode
	
	local name "hdruk_1600"
	
	rename description description_ext
	generate byte statin = 1
	generate byte external_codelist = 1
	generate byte `name' = 1
	
	count
	merge 1:m bnfcode using `product'
	list bnfcode description_ext if _merge == 1
	keep if _merge == 3
	keep prodcodeid statin external_codelist `name'

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/openprescribing/all-statins/542a136e/dmd-download.csv, stringcols(1 2) favorstrfixed clear
	
	rename dmd_id dmdid
	rename dmd_name term
	rename bnf_code bnfcode
	
	//Check which BNF codes are included
	generate bnf_short = substr(bnfcode, 1, 6)
	tab bnf_short, missing
	
	local name "oc_openpresc_allstatins"
	
	rename * *_ext
	rename dmdid_ext dmdid
	generate byte statin = 1
	generate byte external_codelist = 1
	generate byte `name' = 1
	
	count
	merge 1:m dmdid using `product'
	list dmdid term_ext bnfcode_ext if _merge == 1
	keep if _merge == 3
	list prodcodeid termfromemis dmdid bnfcode bnfcode_ext ///
		if bnfcode != bnfcode_ext & bnfcode != "" & bnfcode_ext != ""
	keep prodcodeid statin external_codelist `name'

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/openprescribing/low-and-medium-intensity-statins/6d3986a3/dmd-download.csv, stringcols(1 2) favorstrfixed clear
	
	rename dmd_id dmdid
	rename dmd_name term
	rename bnf_code bnfcode
	
	//Check which BNF codes are included
	generate bnf_short = substr(bnfcode, 1, 6)
	tab bnf_short, missing
	
	local name "oc_openpresc_lowmedstatins"
	
	rename * *_ext
	rename dmdid_ext dmdid
	generate byte statin = 1
	generate byte external_codelist = 1
	generate byte `name' = 1
	
	count
	merge 1:m dmdid using `product'
	list dmdid term_ext bnfcode_ext if _merge == 1
	keep if _merge == 3
	list prodcodeid termfromemis dmdid bnfcode bnfcode_ext ///
		if bnfcode != bnfcode_ext & bnfcode != "" & bnfcode_ext != ""
	keep prodcodeid statin external_codelist `name'

	tempfile `name'
	save ``name''
restore

//Merge in repository codelists
foreach repocodelist in lshtm_2102 lshtm_2199 lshtm_2470 ///
	hdruk_972 hdruk_1013 hdruk_1600 ///
	oc_openpresc_allstatins oc_openpresc_lowmedstatins {
	
	display "Codelist: `repocodelist'"
	merge 1:1 prodcodeid using ``repocodelist'', update replace
	quietly count if _merge == 2
	display "`repocodelist' codes that didn't match: " r(N)
	//drop if _merge == 2
	drop _merge
}

merge 1:1 prodcodeid using `product', update replace
drop if _merge == 2
drop _merge
tab external_codelist, missing
tab external_codelist if statin_count != ., missing
tab external_codelist if statin_count == ., missing  //just one extra code


// STEP 7. EXPORT CODELIST FOR REVIEW BY A CLINICIAN
//===================================================

gsort /**/bnf0212/**/ -drugissues dmdid
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


// STEP 8. RESTRICT CODELIST TO CODES APPROVED BY CLINICIAN AND SAVE
//===================================================================
/*
//Load clinician classifications
local clinician "ABC"

import excel `filename'_raw_`clinician', firstrow clear

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

//Save clinican approved codelist
gsort /**/statin_medication/**/ -drugissues dmdid
drop `clinician'
compress
save `filename', replace*/
export delimited `filename', replace quote


// STEP 9. GENERATE METADATA FILE
//================================

//=**Update details here, everything else is automated**========================
local description "Statins"
local code_type "prodcodeid (dm+d / SNOMED CT)"
local database "CPRD Aurum"
local database_version = ym(real(substr("`aurum_build'", 1, 4)), ///
							real(substr("`aurum_build'", 5, 2)))
local author "Philip Stone"
local date = ym(2025, 3)  //year, month
local clinical_reviewer ""
local date_approved = . //ym(2025, 3)  //year, month
local notes "Created for PRIORITY study"
local keywords "acipimox alirocumab atorvastatin bempedoic bezafibrate cerivastatin ciprofibrate colesevelam colestipol colestyramine evolocumab ezetimibe fenofibrate fluvastatin gemfibrozil icosapent inclisiran lomitapide nicotinic omega policosanol pravastatin rosuvastatin simvastatin"
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
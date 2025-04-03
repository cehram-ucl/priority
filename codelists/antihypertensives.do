//==============================================================================
// 2025-03-1804 PWS drug codelist creation template
//
// ANTIHYPERTENSIVES
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
local filename "antihypertensives"

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

//BNF Chapter 2.5: Hypertension and heart failure
generate byte bnf0205 = 1 if strmatch(bnfchapt, "0205*")

//BNF Chapter 2.5.1: Vasodilator antihypertensive drugs
generate byte bnf020501 = 1 if strmatch(bnfchapt, "020501*")

//BNF Chapter 2.5.2: Centrally-acting antihypertensive drugs
generate byte bnf020502 = 1 if strmatch(bnfchapt, "020502*")

//BNF Chapter 2.5.3: Adrenergic neurone blocking drugs
generate byte bnf020503 = 1 if strmatch(bnfchapt, "020503*")

//BNF Chapter 2.5.4: Alpha-adrenoceptor blocking drugs
generate byte bnf020504 = 1 if strmatch(bnfchapt, "020504*")

//BNF Chapter 2.5.5: Renin-angiotensin system drugs
generate byte bnf020505 = 1 if strmatch(bnfchapt, "020505*")

//BNF Chapter 2.5.5.1: Angiotensin-converting enzyme inhibitors
generate byte bnf02050501 = 1 if strmatch(bnfchapt, "02050501*")

//BNF Chapter 2.5.5.2: Angiotensin-II receptor antagonists
generate byte bnf02050502 = 1 if strmatch(bnfchapt, "02050502*")

//BNF Chapter 2.5.5.3: Renin inhibitors
generate byte bnf02050503 = 1 if strmatch(bnfchapt, "02050503*")

//BNF Chapter 2.5.8: Other adrenergic neurone blocking drugs
generate byte bnf020508 = 1 if strmatch(bnfchapt, "020508*")

//Show drugs in each chapter
foreach chapter in 0205 020501 020502 020503 020504 020505 02050501 ///
	02050502 02050503 020508 {
	
	display "BNF Chapter: `chapter'"
	tab drugsubstancename if bnf`chapter' == 1, missing
}


// STEP 2. USING INFOFORMATION FROM BNF AND STEP 1 CREATE SEARCH TERMS
//         (ONE TERM FOR EACH DRUG THAT INCLUDES CHEMICAL NAME AND ANY 
//         BRAND NAMES)
//=====================================================================

//BNF Chapter 2.5.1: Vasodilator antihypertensive drugs
local ambrisentan "ambrisentan volibris"
local bosentan "bosentan stayveer tracleer"
local diazoxide "diazoxide proglycem eudemine" //maybe exclude?
local hydralazine "hydralazine apresoline"
local iloprost "iloprost ilomedin ventavis"
local macitentan "macitentan opsumit"
local minoxidil "minoxidil loniten"
local riociguat "riociguat adempas"
local selexipag "selexipag uptravi"  //not listed on OpenPrescribing
local sildenafil "sildenafil granpidam revatio"
local sitaxentan "sitaxentan"
local tadalafil "tadalafil adcirca"
local vericiguat "vericiguat verquvo"

local bnf020501 "ambrisentan bosentan diazoxide hydralazine iloprost macitentan minoxidil riociguat selexipag sildenafil sitaxentan tadalafil vericiguat"

//BNF Chapter 2.5.2: Centrally-acting antihypertensive drugs
local clonidine "clonidine catapres"
local guanfacine "guanfacine tenex"
local methyldopa "methyldopa aldomet"
local moxonidine "moxonidine physiotens"

local bnf020502 "clonidine guanfacine methyldopa moxonidine"

//BNF Chapter 2.5.3: Adrenergic neurone blocking drugs
local debrisoquine "debrisoquine"  //not listed on OpenPrescribing
local guanethidine "guanethidine ismelin"

local bnf020503 "debrisoquine guanethidine"

//BNF Chapter 2.5.4: Alpha-adrenoceptor blocking drugs
local doxazosin "doxazosin cardura doxadura larbex raporsin slocinx colixil oxandosin doxzogen cascor cardozin"
local indoramin "indoramin baratol"
local phenoxybenzamine "phenoxybenzamine dibenyline"
local phentolamine "phentolamine rogitine"
local prazosin "prazosin hypovase minipress alphavase"
local terazosin "terazosin hytrin benph"

local bnf020504 "doxazosin indoramin phenoxybenzamine phentolamine prazosin terazosin"

//BNF Chapter 2.5.5.1: Angiotensin-converting enzyme inhibitors
local captopril "captopril co-zidocapt capozide capoten ecopace noyada acezide kaplon acepril tensopril"
local cilazapril "cilazapril vascace"
local enalapril "enalapril aqumeldi innovace innozide pralenal"
local fosinopril "fosinopril staril"
local imidapril "imidapril tanatril"
local lisinopril "lisinopril zestril zestoretic carace"
local moexipril "moexipril perdix"
local perindopril "perindopril coversyl"
local quinapril "quinapril accupro quinil"
local ramipril "ramipril tritace lopace"
local trandolapril "trandolapril verapamil odrik gopten"

local bnf02050501 "captopril cilazapril enalapril fosinopril imidapril lisinopril moexipril perindopril quinapril ramipril trandolapril"

//BNF Chapter 2.5.5.2: Angiotensin-II receptor antagonists
local azilsartan "azilsartan edarbi"
local candesartan "candesartan amias"
local eprosartan "eprosartan teveten"
local irbesartan "irbesartan aprovel coaprovel ifirmasta"
local losartan "losartan cozaar"
local olmesartan "olmesartan olmetec sevikar"
local telmisartan "telmisartan micardis actelsar tolura tolucombi"
local valsartan "valsartan entresto diovan"

local bnf02050502 "azilsartan candesartan eprosartan irbesartan losartan olmesartan telmisartan valsartan"

//BNF Chapter 2.5.5.3: Renin inhibitors
local aliskiren "aliskiren rasilez"

local bnf02050503 "aliskiren"

//BNF Chapter 2.5.8: Other adrenergic neurone blocking drugs
local ketanserin "ketanserin ketensin"

local bnf020508 "ketanserin"


// STEP 3. CREATE MACRO CONTAINING ALL DRUG MACROS CREATED IN STEP 2
//         AND SEARCH THE PRODUCT DICTIONARY FOR EACH DRUG
//===================================================================

local antihypertensives "bnf020501 bnf020502 bnf020503 bnf020504 bnf02050501 bnf02050502 bnf02050503 bnf020508"

generate byte antihypertensive = 0

foreach bnf_section of local antihypertensives {
	
	display "`bnf_section'"
	
	foreach drug of local `bnf_section' {
		
		display "Drug: `drug'"  //for debugging
		generate byte `drug' = 0
		
		foreach term of local `drug' {
			
			display "Term: `term'"  //for debugging
			
			foreach scan_var of varlist termfromemis drugsubstancename bnfname {
				
				foreach label_var of varlist antihypertensive `drug' ///
					`bnf_section' {
					
					replace `label_var' = 1 if strpos(lower(`scan_var'), "`term'")
				}
			}
		}
	}
}

tab1 antihypertensive, missing
foreach bnf_section of local antihypertensives {
	
	tab `bnf_section', missing
	
	foreach drug of local `bnf_section' {
		
		tab `drug', missing
	}
}

egen antihyper_tot = rowtotal(bnf020501 bnf020502 bnf020503 bnf020504 bnf02050501 bnf02050502 bnf02050503 bnf020508)
tab antihyper_tot antihypertensive, missing
drop antihyper_tot

//Check higher level categories
replace bnf0205 = 1 if inlist(1, bnf020501, bnf020502, bnf020503, ///
	bnf020504, bnf02050501, bnf02050502, bnf02050503, bnf020508)
tab bnf0205 antihypertensive, missing

replace bnf020505 = 1 if inlist(1, bnf02050501, bnf02050502, bnf02050503)
tab bnf020505 antihypertensive, missing

//** Chapter 2.5.6 Trimetaphan - should this be included? **
list prodcodeid termfromemis drugsubstancename bnfchapt ///
	if bnf0205 == 1 & antihypertensive != 1

keep if antihypertensive == 1
compress
count

//Check included products for each drug
//(Also use this to go back and add any brand names that may have been missed)
foreach bnf_section of local antihypertensives {
	
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

local exclude " "*regaine*" "*minoxidil*%*solution*" "* gel" "* gel *" "*foam*" "*apraclonidine*" "*eye*drops*" "*glutenex*" "

//Search for codes to exclude
foreach excludeterm in exclude {

	gen byte `excludeterm' = .

	foreach codeterm in lower(term) {
		
		foreach searchterm in ``excludeterm'' {		
			
			replace `excludeterm' = 1 if strmatch(`codeterm', "`searchterm'")
		}
	}
}

//Check that nothing important is highlighted for exclusion before dropping
list prodcodeid termfromemis drugsubstancename bnfchapt if exclude == 1
drop if exclude == 1
drop exclude
count
compress

//Check included products for each drug
//(Also use this to go back and add any brand names that may have been missed)
foreach bnf_section of local antihypertensives {
	
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
egen aht_count = rowtotal(ambrisentan bosentan diazoxide hydralazine iloprost macitentan minoxidil riociguat selexipag sildenafil sitaxentan tadalafil vericiguat clonidine guanfacine methyldopa moxonidine debrisoquine guanethidine doxazosin indoramin phenoxybenzamine phentolamine prazosin terazosin captopril cilazapril enalapril fosinopril imidapril lisinopril moexipril perindopril quinapril ramipril trandolapril azilsartan candesartan eprosartan irbesartan losartan olmesartan telmisartan valsartan aliskiren ketanserin)

tab aht_count, missing
drop aht_count

generate byte antihypertensive_medication = 0
label define antihypertensive_medication, replace
label values antihypertensive_medication antihypertensive_medication
local count = 0
foreach bnf_section of local antihypertensives {
	
	foreach drug of local `bnf_section' {
		
		local count = `count'+1
		local capitalise = strproper("`drug'")  //makes first letter upper case
		
		label define antihypertensive_medication `count' "`capitalise'", add
		
		replace antihypertensive_medication = `count' if `drug' == 1
		
		tab antihypertensive_medication `drug', missing
		drop `drug'
	}
}
recode antihypertensive_medication (0 = .)
tab1 antihypertensive_medication, missing


// (OPTIONAL) STEP 6. COMPARE AGAINST PRE-EXISTING LISTS
//=======================================================

//Import repository codelists

//MedCodeID codelists (LSHTM Data Compass)
preserve
	import delimited https://datacompass.lshtm.ac.uk/id/eprint/2102/37/antihypertensives_aurum_mar20.txt, stringcols(1) favorstrfixed clear
	
	keep prodcodeid termfromemis
	
	local name "lshtm_2102"
	
	rename * *_ext
	rename prodcodeid_ext prodcodeid
	generate byte antihypertensive = 1
	generate byte external_codelist = 1
	generate byte `name' = 1
	
	count
	merge 1:1 prodcodeid using `product'
	list prodcodeid termfromemis_ext if _merge == 1
	keep if _merge == 3
	keep prodcodeid antihypertensive external_codelist `name'

	tempfile `name'
	compress
	save ``name''
restore, preserve
	import delimited https://datacompass.lshtm.ac.uk/id/eprint/2187/1/Antihypertensives_aurum_mar20.csv, stringcols(1) favorstrfixed clear
	
	keep prodcodeid termfromemis
	
	local name "lshtm_2187"
	
	rename * *_ext
	rename prodcodeid_ext prodcodeid
	generate byte antihypertensive = 1
	generate byte external_codelist = 1
	generate byte `name' = 1
	
	count
	merge 1:1 prodcodeid using `product'
	list prodcodeid termfromemis_ext if _merge == 1
	keep if _merge == 3
	keep prodcodeid antihypertensive external_codelist `name'

	tempfile `name'
	compress
	save ``name''
restore, preserve
	import delimited https://datacompass.lshtm.ac.uk/id/eprint/2814/1/antihypertensives_aurum_feb21.txt, stringcols(1) favorstrfixed clear
	
	keep prodcodeid termfromemis
	
	local name "lshtm_2814"
	
	rename * *_ext
	rename prodcodeid_ext prodcodeid
	generate byte antihypertensive = 1
	generate byte external_codelist = 1
	generate byte `name' = 1
	
	count
	merge 1:1 prodcodeid using `product'
	list prodcodeid termfromemis_ext if _merge == 1
	keep if _merge == 3
	keep prodcodeid antihypertensive external_codelist `name'

	tempfile `name'
	compress
	save ``name''
restore, preserve
	import delimited https://datacompass.lshtm.ac.uk/id/eprint/3590/96/codelist_antihypertensive_aurum.txt, stringcols(1) favorstrfixed clear
	
	keep prodcodeid termfromemis drugsub ace_i arb calcium_b beta_b
	
	local name "lshtm_3590"
	
	rename termfromemis termfromemis_ext
	generate byte antihypertensive = 1
	generate byte external_codelist = 1
	generate byte `name' = 1
	
	count
	merge 1:1 prodcodeid using `product'
	list prodcodeid termfromemis_ext if _merge == 1
	keep if _merge == 3
	keep prodcodeid antihypertensive external_codelist `name'

	tempfile `name'
	compress
	save ``name''
restore

//SNOMED CT codelists (HDR UK Phenotype Library and OpenCodelists)
preserve
	import delimited https://phenotypes.healthdatagateway.org/phenotypes/PH1595/version/3008/export/codes, stringcols(1) favorstrfixed clear
	
	keep code description
	rename code bnfcode
	
	codebook bnfcode
	
	local name "hdruk_1595"
	
	rename description description_ext
	generate byte antihypertensive = 1
	generate byte external_codelist = 1
	generate byte `name' = 1
	
	count
	merge 1:m bnfcode using `product'
	list bnfcode description_ext if _merge == 1
	keep if _merge == 3
	keep prodcodeid antihypertensive external_codelist `name'

	tempfile `name'
	save ``name''
restore, preserve
	import delimited https://www.opencodelists.org/codelist/opensafely/combination-blood-pressure-medication/2020-05-19/download.csv, stringcols(1 3) favorstrfixed clear
	
	rename code dmdid
	rename bnf_code bnfcode
	
	//Check dmdid and id are the same
	count if dmdid != id
	drop id
	
	//Check which BNF codes are included
	generate bnf_short = substr(bnfcode, 1, 6)
	tab bnf_short, missing
	
	local name "oc_opensafely_combbpmed"
	
	rename * *_ext
	rename dmdid_ext dmdid
	generate byte antihypertensive = 1
	generate byte external_codelist = 1
	generate byte `name' = 1
	
	count
	merge 1:m dmdid using `product'
	list dmdid term_ext bnfcode_ext if _merge == 1
	keep if _merge == 3
	list prodcodeid termfromemis dmdid bnfcode bnfcode_ext ///
		if bnfcode != bnfcode_ext & bnfcode != "" & bnfcode_ext != ""
	keep prodcodeid antihypertensive external_codelist `name'

	tempfile `name'
	save ``name''
restore

//Merge in repository codelists
foreach repocodelist in lshtm_2102 lshtm_2187 lshtm_2814 lshtm_3590 ///
	hdruk_1595 oc_opensafely_combbpmed {
	
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
tab external_codelist if antihypertensive_medication != ., missing
tab external_codelist if antihypertensive_medication == ., missing  //lots of extras

//Clinician input needed on whether these should be included
//Would require adding extra terms to search if these should be included


// STEP 7. EXPORT CODELIST FOR REVIEW BY A CLINICIAN
//===================================================

gsort antihypertensive_medication -drugissues dmdid
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
gsort /**/antihypertensive_medication/**/ -drugissues dmdid
drop `clinician'
compress
save `filename', replace*/
export delimited `filename', replace quote


// STEP 9. GENERATE METADATA FILE
//================================

//=**Update details here, everything else is automated**========================
local description "Antihypertensives"
local code_type "prodcodeid (dm+d / SNOMED CT)"
local database "CPRD Aurum"
local database_version = ym(real(substr("`aurum_build'", 1, 4)), ///
							real(substr("`aurum_build'", 5, 2)))
local author "Philip Stone"
local date = ym(2025, 3)  //year, month
local clinical_reviewer ""
local date_approved = . //ym(2025, 3)  //year, month
local notes "Created for PRIORITY study"
local keywords "ambrisentan bosentan diazoxide hydralazine iloprost macitentan minoxidil riociguat selexipag sildenafil sitaxentan tadalafil vericiguat clonidine guanfacine methyldopa moxonidine debrisoquine guanethidine doxazosin indoramin phenoxybenzamine phentolamine prazosin terazosin captopril cilazapril enalapril fosinopril imidapril lisinopril moexipril perindopril quinapril ramipril trandolapril azilsartan candesartan eprosartan irbesartan losartan olmesartan telmisartan valsartan aliskiren ketanserin"
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
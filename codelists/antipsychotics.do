//==============================================================================
// 2025-03-1804 PWS drug codelist creation template
//
// ANTIPSYCHOTICS
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
local filename "antipsychotics"

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

//Save product code browser to a tempfile
compress
tempfile product
save `product'


// STEP 1. SELECT BNF CHAPTERS TO INCLUDE
//========================================

//BNF Chapter information: https://openprescribing.net/bnf/
//Leading zero isn't included in 'bnfchapter' variable

//BNF Chapter 4.2: Drugs used in psychoses and related disorders
generate byte bnf0402 = 1 if strmatch(bnfchapter, "402*") ///
	| strmatch(bnfcode, "0402*")

//BNF Chapter 4.2.1: Antipsychotic drugs
generate byte bnf040201 = 1 if strmatch(bnfchapter, "40201*") ///
	| strmatch(bnfcode, "040201*")

//BNF Chapter 4.2.2: Antipsychotic depot injections
generate byte bnf040202 = 1 if strmatch(bnfchapter, "40202*") ///
	| strmatch(bnfcode, "040202*")

//BNF Chapter 4.2.3: Drugs used for mania and hypomania
generate byte bnf040203 = 1 if strmatch(bnfchapter, "40203*") ///
	| strmatch(bnfcode, "040203*")
	
//Show drugs in each chapter
foreach chapter in 0402 040201 040202 040203 {
	
	display "BNF Chapter: `chapter'"
	tab drugsubstancename if bnf`chapter' == 1, missing
}


// STEP 2. USING INFOFORMATION FROM BNF AND STEP 1 CREATE SEARCH TERMS
//         (ONE TERM FOR EACH DRUG THAT INCLUDES CHEMICAL NAME AND ANY 
//         BRAND NAMES)
//=====================================================================

//BNF chapter 4.2.1
local amisulpride "amisulpride solian"
local aripiprazole "aripiprazole abilify arpoya elozar"
local benperidol "benperidol"
local cariprazine "cariprazine reagila"
local chlorpromazine "chlorpromazine largactil"
local chlorprothixene "chlorprothixene truxal"
local clozapine "clozapine clozaril denzapine zaponex"
local droperidol "droperidol"  //not listed on OpenPrescribing
local flupentixol "flupentixol depixol psytixol"
local fluphenazine "fluphenazine modecate moditen"
local haloperidol "haloperidol haldol halkid serenace dozic"
local levomepromazine "levomepromazine levorol nozinan levinan"
local loxapine "loxapine loxapac"
local lurasidone "lurasidone latuda"
local melperone "melperone"
local olanzapine "olanzapine ceyxa xyquila zyprexa zypadhera zalasta"
local oxypertine "oxypertine integrin"  //not listed on OpenPrescribing
local paliperidone "paliperidone invega byannli trevicta xeplion"
local pericyazine "pericyazine neulactil"
local perphenazine "perphenazine fentazin"
local pimozide "pimozide orap"
local promazine "promazine"
local quetiapine "quetiapine atrolak biquelle brancico mintreleq seroquel sondate zaluron tenprolide seotiapim ebesque psyquet"
local risperidone "risperidone okedi risperdal"
local sertindole "sertindole serdolect"  //not listed on OpenPrescribing
local sulpiride "sulpiride sulpor sulpitil dolmatil"
local thioridazine "thioridazine melleril"
local trifluoperazine "trifluoperazine stelazine"
local ziprasidone "ziprasidone zeldox"
local zotepine "zotepine zoleptil"
local zuclopenthixol "zuclopenthixol clopixol"

//BNF chapter 4.2.2 (excluding drugs in 4.2.1)
local pipotiazine "pipotiazine piportil"

//BNF chapter 4.2.3 (excluding lithium and valproate)
local asenapine "asenapine sycrest"

//Removed from old list (not an antipsychotic): isopropamide, tranylcypromine
//Removed from old list (not in any BNF lists): remoxipride, thiopropazate, thioproperazine, trifluperidol


// STEP 3. CREATE MACRO CONTAINING ALL DRUG MACROS CREATED IN STEP 2
//         AND SEARCH THE PRODUCT DICTIONARY FOR EACH DRUG
//===================================================================

local antipsychotics "amisulpride aripiprazole benperidol cariprazine chlorpromazine chlorprothixene clozapine droperidol flupentixol fluphenazine haloperidol levomepromazine loxapine lurasidone melperone olanzapine oxypertine paliperidone pericyazine perphenazine pimozide promazine quetiapine risperidone sertindole sulpiride thioridazine trifluoperazine ziprasidone zotepine zuclopenthixol pipotiazine asenapine"

generate byte antipsychotic = 0

foreach antipsychotic of local antipsychotics {
	
	//display "Macroname: `antipsychotic'"  //for debugging
	generate byte `antipsychotic' = 0
	
	foreach word of local `antipsychotic' {
		
		//display "Terms: `word'"  //for debugging
		foreach var of varlist termfromemis drugsubstancename bnfname {
		
			replace antipsychotic = antipsychotic | strpos(lower(`var'), "`word'")
			replace `antipsychotic' = 1 if strpos(lower(`var'), "`word'") > 0
		}
	}
}

tab antipsychotic, missing

tab1 amisulpride aripiprazole benperidol cariprazine chlorpromazine chlorprothixene clozapine droperidol flupentixol fluphenazine haloperidol levomepromazine loxapine lurasidone melperone olanzapine oxypertine paliperidone pericyazine perphenazine pimozide promazine quetiapine risperidone sertindole sulpiride thioridazine trifluoperazine ziprasidone zotepine zuclopenthixol pipotiazine asenapine, missing

keep if antipsychotic == 1
compress
count

//Fix erroneous labelling due to "promazine" being a suffix in other drugs
list termfromemis drugsubstancename promazine chlorpromazine levomepromazine ///
	if promazine == 1 & (chlorpromazine == 1 | levomepromazine == 1)
replace promazine = 0 if chlorpromazine == 1 | levomepromazine == 1
list termfromemis drugsubstancename promazine chlorpromazine levomepromazine ///
	if promazine == 1 & (chlorpromazine == 1 | levomepromazine == 1)

//Check included products for each drug
//(Also use this to go back and add any brand names that may have been missed)
foreach antipsychotic of local antipsychotics {
	
	display "Drug: `antipsychotic'"
	tab1 `antipsychotic'
	list prodcodeid termfromemis drugsubstancename bnfchapter bnfcode ///
		if `antipsychotic' == 1
}


// (OPTIONAL) STEP 4. PERFORM SECOND SEARCH TO EXCLUDE UNDESIRED PRODUCTS
//========================================================================

//Comment out this section if not required.

// **Exclusion terms**

local exclude " "*nortriptyline*" "*motival*" "*motipress*" "*chloraprep*" "*novorapid*" "

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
list prodcodeid termfromemis drugsubstancename bnfchapter bnfcode if exclude == 1
drop if exclude == 1
drop exclude
count
compress

//Check included products for each drug
//(Also use this to go back and add any brand names that may have been missed)
foreach antipsychotic of local antipsychotics {
	
	display "Drug: `antipsychotic'"
	tab1 `antipsychotic'
	list prodcodeid termfromemis drugsubstancename bnfchapter bnfcode ///
		if `antipsychotic' == 1
}


// (OPTIONAL) STEP 5. CATEGORISE DRUGS
//=====================================

//Check for any products containing multiple drugs (categorisation won't work otherwise)
egen ap_count = rowtotal(amisulpride aripiprazole benperidol cariprazine chlorpromazine chlorprothixene clozapine droperidol flupentixol fluphenazine haloperidol levomepromazine loxapine lurasidone melperone olanzapine oxypertine paliperidone pericyazine perphenazine pimozide promazine quetiapine risperidone sertindole sulpiride thioridazine trifluoperazine ziprasidone zotepine zuclopenthixol pipotiazine asenapine)

tab ap_count, missing
drop ap_count

generate byte antipsychotic_medication = 0
label define antipsychotic_medication, replace
label values antipsychotic_medication antipsychotic_medication
local count = 0
foreach drug of local antipsychotics {
	
	local count = `count'+1
	local capitalise = strproper("`drug'")  //makes first letter upper case
	
	label define antipsychotic_medication `count' "`capitalise'", add
	
	replace antipsychotic_medication = `count' if `drug' == 1
	
	tab antipsychotic_medication `drug', missing
	drop `drug'
}
recode antipsychotic_medication (0 = .)
tab1 antipsychotic_medication, missing


// (OPTIONAL) STEP 6. COMPARE AGAINST PRE-EXISTING LIST
//======================================================

//Compare against LSHTM list
preserve
	import delimited https://datacompass.lshtm.ac.uk/id/eprint/2796/2/antipsychotics_aurum_feb21.txt, stringcols(1 2) favorstrfixed clear
	
	tab1 bnfchapter drugsubstancename, missing
	keep prodcodeid termfromemis drugsubstancename
	
	local name "lshtm_2796"
	
	rename * *_ext
	rename prodcodeid_ext prodcodeid
	generate byte `name' = 1
	
	count
	merge 1:1 prodcodeid using `product'
	list prodcodeid termfromemis_ext drugsubstancename_ext if _merge == 1
	keep if _merge == 3
	keep prodcodeid `name'

	tempfile `name'
	compress
	save ``name''
restore

//Everything from LSHTM list is already included
merge 1:1 prodcodeid using `lshtm_2796'
list prodcodeid termfromemis drugsubstancename if _merge == 2
drop if _merge == 2
drop _merge


// STEP 7. SAVE AND EXPORT CODELIST
//==================================
drop bnf0402*  //these only label the codes with BNF codes so aren't perfect
gsort -drugissues dmdid
compress
save `filename', replace
export delimited `filename', replace quote


// STEP 8. GENERATE METADATA FILE
//================================

//=**Update details here, everything else is automated**========================
local description "Antipsychotics"
local code_type "prodcodeid (dm+d / SNOMED CT)"
local database "CPRD Aurum"
local database_version = ym(real(substr("`aurum_build'", 1, 4)), ///
							real(substr("`aurum_build'", 5, 2)))
local author "Philip Stone"
local date = ym(2025, 3)  //year, month
local clinical_reviewer ""
local date_approved = . //ym(2025, 3)  //year, month
local notes "Not reviewed by a clinician. Created for PRIORITY study"
local keywords "amisulpride aripiprazole benperidol cariprazine chlorpromazine chlorprothixene clozapine droperidol flupentixol fluphenazine haloperidol levomepromazine loxapine lurasidone melperone olanzapine oxypertine paliperidone pericyazine perphenazine pimozide promazine quetiapine risperidone sertindole sulpiride thioridazine trifluoperazine ziprasidone zotepine zuclopenthixol pipotiazine asenapine"
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
clear all
set more off

cd "C:\Users\rmjlton.AD\Documents\GitHub\priority\codelists"


//Merge codelists into one master codelist


// ANTIPSYCHOTICS
use antipsychotics, clear

keep prodcodeid antipsychotic antipsychotic_medication

//Compact version
save compact/antipsychotics, replace

//Combined master codelist
save _master_codelist_product, replace


// ANTIHYPERTENSIVES
use antihypertensives, clear

keep prodcodeid antihypertensive

//Compact version
save compact/antihypertensives, replace

//Combined master codelist
merge 1:1 prodcodeid using _master_codelist_product, nogenerate
save _master_codelist_product, replace


// STATINS
use statins, clear

keep prodcodeid statin

//Compact version
save compact/statins, replace

//Combined master codelist
merge 1:1 prodcodeid using _master_codelist_product, nogenerate
save _master_codelist_product, replace

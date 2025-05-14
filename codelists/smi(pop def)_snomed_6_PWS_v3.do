clear all
set more off

cd "C:\Users\rmjlton.AD\Documents\GitHub\priority\codelists"


local filename "smi(pop def)_snomed_6_PWS_v3"

//Open log file
capture log close
log using "`filename'", text replace


//Import Excel sheet with clinician/my classifications
import excel "smi(pop def)_snomed_6_PWS_v2_CCG_PWS_CCG_PWS", firstrow clear

keep medcodeid PWS_2

tempfile smi_v3
save `smi_v3'


//Open original DTA file
use "smi(pop def)_snomed_6_PWS_v2", clear

merge 1:1 medcodeid using `smi_v3'
drop _merge

tab PWS_2, missing
list medcodeid term if PWS_2 != 1
keep if PWS_2 == 1
drop PWS_2

tab1 family_history resolved_remission, missing
drop family_history resolved_remission


//Save updated version of SMI codelist
compress
save "`filename'", replace
export delimited "`filename'", replace quote
export excel "`filename'", firstrow(variables) replace

log close

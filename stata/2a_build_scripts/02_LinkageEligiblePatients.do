clear all
set more off

// Set working directory (project folder)
cd "S:\CALIBER_23_003266\Phil"

// Record start time to benchmark processing time of do file
local start = clock("$S_DATE $S_TIME", "DMY hms")
local date = subinstr("$S_DATE", " ", "", .)
local time = subinstr("$S_TIME", ":", "", .)


// Open log file
capture log close
log using "2b_build_logs/02_LinkageEligiblePatients_`date'_`time'", text replace

// Linkage directory
local linkage_dir "../3. Linked Data/January_2022_Source_Aurum"


// Import linkage eligibility
//============================
import delimited "`linkage_dir'/Aurum_enhanced_eligibility_January_2022.txt", ///
	clear stringcols(1)

// Remove unneeded vars (change as needed)
drop hes_apc_e ons_death_e /*lsoa_e*/ sgss_e chess_e hes_op_e hes_ae_e hes_did_e cr_e sact_e rtds_e mhds_e icnarc_e

// (Optional) Convert patid to numeric after removing pracid component

// Check last 5 digits of patid are the same as the pracid
assert real(substr(patid, -5, .)) == pracid

// Check last 5 digits of patid + patid minus last 5 digits = patid
assert substr(patid, 1, strlen(patid) - 5) + substr(patid, -5, .) == patid

// Check conversion to numeric and back to string loses no information
assert strofreal(real(substr(patid, 1, strlen(patid) - 5)), "%14.0f") ///
	+ strofreal(pracid) == patid

// Check conversion to numeric and back to string using destring/tostring
generate pat1 = substr(patid, 1, strlen(patid) - 5)
destring pat1, replace
tostring pat1, replace
replace pat1 = pat1 + strofreal(pracid)
assert pat1 == patid
drop pat1

// Remove last 5 digits from patid and convert to numeric to save storage space
replace patid = substr(patid, 1, strlen(patid) - 5)
destring patid, replace
format %14.0f patid   //after removing last 5 digits, max length is 14 characters

// Place patid and pracid next to each other as they need to be combined
order pracid, after(patid)

cprddate linkdate
tab linkdate, missing
drop linkdate  //they're all the same and this does not affect follow-up time

compress
tempfile linkage_eligibility
save `linkage_eligibility'


// Open Patient file & merge with linakge eligibility to create cohort
//=====================================================================
use 1b_formatted_data/Patient, clear
count

merge 1:1 pracid patid using `linkage_eligibility', nogenerate keep(master match)

tab1 eligible lsoa_e lsoa_e_22, missing
tab lsoa_e lsoa_e_22, missing

//Previous lsoa value doesn't add anything (neither does 'eligible')
drop lsoa_e_22 eligible

//Restrict to patients eligible for IMD linkage
keep if lsoa_e == 1


//This is our new linkage eligible cohort
count
compress
save 3_builds/linkage_eligible, replace


//Export tab delimited list of patids for linkage for upload to CPRD
//===================================================================
keep patid pracid lsoa_e

//Regenerate string patid
generate patid_str = strofreal(patid, "%14.0f") + strofreal(pracid)
drop patid pracid
rename patid_str patid
order patid, first

export delimited "1c_linked_data/23_003266_UCL_patientlist.txt", delimiter(tab) replace

//Add to zip file to compress
zipfile "1c_linked_data/23_003266_UCL_patientlist.txt", ///
	saving("1c_linked_data/23_003266_UCL_patientlist.zip", replace)


// Print time taken to run the do file
local runtime = clock("$S_DATE $S_TIME", "DMY hms") - `start'
display "Runtime: " floor(`runtime'/60000) " minutes " mod(`runtime'/1000, 60) " seconds"

log close
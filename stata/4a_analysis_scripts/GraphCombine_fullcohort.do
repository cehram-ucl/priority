clear all
set more off

// Set working directory (project folder)
cd "S:\CALIBER_23_003266\Phil"


local filetype "emf"


graph combine "5_outputs/hba1c_line.gph" ///
	"5_outputs/weight_line.gph", altshrink xcommon rows(2)

graph export "5_outputs/combined_main.`filetype'", replace


//By sex
graph combine "5_outputs/hba1c_gender_line.gph" ///
	"5_outputs/weight_gender_line.gph", altshrink xcommon rows(2)

graph export "5_outputs/combined_by_sex.`filetype'", replace


//By drug
graph combine "5_outputs/hba1c_ap_med_line.gph" ///
	"5_outputs/weight_ap_med_line.gph", altshrink xcommon rows(2)

graph export "5_outputs/combined_by_drug.`filetype'", replace


//By drug & sex
graph combine "5_outputs/hba1c_ap_medgender_line.gph" ///
	"5_outputs/weight_ap_medgender_line.gph", altshrink xcommon rows(2)

graph export "5_outputs/combined_by_sex_drug.`filetype'", replace


//By HbA1c status at baseline
graph combine "5_outputs/hba1c_bl_hba1c_cat_line.gph" ///
	"5_outputs/weight_bl_hba1c_cat_line.gph", altshrink xcommon rows(2)

graph export "5_outputs/combined_by_hba1cstat.`filetype'", replace

/*
//By age
graph combine "5_outputs/hba1c_agebands_line.gph" ///
	"5_outputs/weight_agebands_line.gph", altshrink xcommon rows(2)

graph export "5_outputs/combined_by_age.`filetype'", replace


//By IMD
graph combine "5_outputs/hba1c_e2019_imd_5_patient_line.gph" ///
	"5_outputs/weight_e2019_imd_5_patient_line.gph", altshrink xcommon rows(2)

graph export "5_outputs/combined_by_imd.`filetype'", replace
*/
/*
//By drug & above/below 60
graph combine "5_outputs/hba1c_ap_medage60_line.gph" ///
	"5_outputs/weight_ap_medage60_line.gph", altshrink xcommon rows(2)

graph export "5_outputs/combined_by_age60_drug.`filetype'", replace
*/
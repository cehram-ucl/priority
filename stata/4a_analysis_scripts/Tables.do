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
log using "4b_analysis_logs/Tables_`date'_`time'", smcl replace

// Study constants
local study_start = dmy(1, 1, 2000)
local study_end = dmy(31, 12, 2019)
local build_date = dmy(1, 9, 2023)  //Sep 2023 Build

local filetype "emf"


//Generate variables to indicate which cohorts a patient is in
foreach cohort in hba1c /*cholesterol_ldl bp_systolic*/ weight {
	
	use 3_builds/cohort_baseline_medication_`cohort', clear
	keep pracid patid
	bysort pracid patid: keep if _n == 1
	generate byte `cohort' = 1
	tempfile `cohort'
	save ``cohort''
}


//Start with baseline cohort
use 3_builds/cohort_baseline_medication, clear
count

tab gender, missing
label variable gender "Sex"
label list Gender
label define sex 1 "Male" 2 "Female"
label values gender sex
tab gender, missing

//Merge in cohort indicators
foreach cohort in hba1c /*cholesterol_ldl bp_systolic*/ weight {
	
	merge 1:1 pracid patid using ``cohort''
	drop _merge
	recode `cohort' (. = 0)
	label values `cohort' yn
	tab `cohort', missing
}
label variable hba1c "People with one or more HbA1c result"
//label variable cholesterol_ldl "People with one or more LDL cholesterol result"
//label variable bp_systolic "People with one or more systolic blood pressure result"
label variable weight "People with one or more weight result"

generate byte hba1cANDweight = (hba1c == 1 & weight == 1)
label values hba1cANDweight yn
label variable hba1cANDweight "People with HbA1c & weight results"
tab hba1cANDweight, missing


//Open Word document
putdocx begin
putdocx paragraph, style(Title)
putdocx text ("Antipsychotic initiation results")


//TABLE 1 - Baseline characteristics
putdocx paragraph, style(Heading1)
putdocx text ("Baseline characteristics (Table 1)")
dtable i.agebands i.gender i.ethnicity i.e2019_imd_5_patient i.region ///
	i.smoking_status /*i.alcstatus i.alclevel*/ i.unitcat i.alcohol_use_disorder ///
	i.ap_med i.ap_change i.smi_after_ap ///
	i.bl_onstatin i.initiatied_statin ///
	i.hba1c /*i.cholesterol_ldl i.bp_systolic*/ i.weight ///
	i.bl_hba1c_cat bl_hba1c bl_weight ///
	followup, ///
	define(iqrange = p25 p75, delimiter(-)) ///
	nformat(%9.0fc median iqrange) ///
	sformat("(%s)" iqrange) ///
	continuous(bl_hba1c bl_weight followup, ///
		statistics(median iqrange)) ///
	note("Continuous variables are summarised using median and IQR")
putdocx collect
/*
putdocx paragraph, style(Heading2)
putdocx text ("Sub-group: People with at least 1 HbA1c and Weight result")
dtable i.agebands i.gender i.ethnicity i.e2019_imd_5_patient i.region ///
	i.smoking_status /*i.alcstatus i.alclevel*/ i.unitcat i.alcohol_use_disorder ///
	i.ap_med i.ap_change i.smi_after_ap ///
	i.bl_onstatin i.initiatied_statin ///
	i.hba1c /*i.cholesterol_ldl i.bp_systolic*/ i.weight ///
	followup if hba1cANDweight == 1, ///
	define(iqrange = p25 p75, delimiter(-)) ///
	nformat(%9.0fc median iqrange) ///
	sformat("(%s)" iqrange) ///
	continuous(followup, ///
		statistics(median iqrange)) ///
	note("Continuous variables are summarised using median and IQR")
putdocx collect
*/
//STRATIFIED BASELINE CHARACTERISTICS
//By antipsychotic and sex
putdocx paragraph, style(Heading2)
putdocx text ("Stratified: By antipsychotic medication and sex")
egen med_sex = group(ap_med gender), label
label variable med_sex "Antipsychotic and sex"
tab med_sex, missing
dtable i.agebands i.ethnicity i.e2019_imd_5_patient i.region ///
	i.smoking_status /*i.alcstatus i.alclevel*/ i.unitcat i.alcohol_use_disorder ///
	i.ap_change i.smi_after_ap ///
	i.bl_onstatin i.initiatied_statin ///
	i.hba1c /*i.cholesterol_ldl i.bp_systolic*/ i.weight ///
	i.bl_hba1c_cat bl_hba1c bl_weight ///
	followup, ///
	define(iqrange = p25 p75, delimiter(-)) ///
	nformat(%9.0fc median iqrange) ///
	sformat("(%s)" iqrange) ///
	continuous(bl_hba1c bl_weight followup, ///
		statistics(median iqrange)) ///
	note("Continuous variables are summarised using median and IQR") ///
	by(med_sex, nototals)
putdocx collect
/*
//By antipsychotic and age above/below 60
putdocx paragraph, style(Heading2)
putdocx text ("Stratified: By antipsychotic medication and age")
egen med_age = group(ap_med age60), label
label variable med_age "Antipsychotic and age"
tab med_age, missing
dtable i.agebands i.gender i.ethnicity i.e2019_imd_5_patient i.region ///
	i.smoking_status /*i.alcstatus i.alclevel*/ i.unitcat i.alcohol_use_disorder ///
	i.ap_change i.smi_after_ap ///
	i.bl_onstatin i.initiatied_statin ///
	i.hba1c /*i.cholesterol_ldl i.bp_systolic*/ i.weight ///
	followup, ///
	define(iqrange = p25 p75, delimiter(-)) ///
	nformat(%9.0fc median iqrange) ///
	sformat("(%s)" iqrange) ///
	continuous(followup, ///
		statistics(median iqrange)) ///
	note("Continuous variables are summarised using median and IQR") ///
	by(med_age, nototals)
putdocx collect
*/
//By those with and without data for both HbA1c and weight
putdocx paragraph, style(Heading2)
putdocx text ("Stratified: By those with and without data for both HbA1c and weight")
dtable i.agebands i.gender i.ethnicity i.e2019_imd_5_patient i.region ///
	i.smoking_status /*i.alcstatus i.alclevel*/ i.unitcat i.alcohol_use_disorder ///
	i.ap_med i.ap_change i.smi_after_ap ///
	i.bl_onstatin i.initiatied_statin ///
	i.hba1c /*i.cholesterol_ldl i.bp_systolic*/ i.weight ///
	i.bl_hba1c_cat bl_hba1c bl_weight ///
	followup, ///
	define(iqrange = p25 p75, delimiter(-)) ///
	nformat(%9.0fc median iqrange) ///
	sformat("(%s)" iqrange) ///
	continuous(bl_hba1c bl_weight followup, ///
		statistics(median iqrange)) ///
	note("Continuous variables are summarised using median and IQR") ///
	by(hba1cANDweight)
putdocx collect

//By antipsychotic and sex (within HbA1c AND weight sub-group)
putdocx paragraph, style(Heading3)
putdocx text ("People with HbA1c and weight data stratified: By antipsychotic medication and sex")
tab med_sex if hba1cANDweight == 1, missing
dtable i.agebands i.ethnicity i.e2019_imd_5_patient i.region ///
	i.smoking_status /*i.alcstatus i.alclevel*/ i.unitcat i.alcohol_use_disorder ///
	i.ap_change i.smi_after_ap ///
	i.bl_onstatin i.initiatied_statin ///
	i.hba1c /*i.cholesterol_ldl i.bp_systolic*/ i.weight ///
	i.bl_hba1c_cat bl_hba1c bl_weight ///
	followup if hba1cANDweight == 1, ///
	define(iqrange = p25 p75, delimiter(-)) ///
	nformat(%9.0fc median iqrange) ///
	sformat("(%s)" iqrange) ///
	continuous(bl_hba1c bl_weight followup, ///
		statistics(median iqrange)) ///
	note("Continuous variables are summarised using median and IQR") ///
	by(med_sex, nototals)
putdocx collect
/*
//By antipsychotic and age (within HbA1c AND weight sub-group)
putdocx paragraph, style(Heading3)
putdocx text ("People with HbA1c and weight data stratified: By antipsychotic medication and age")
tab med_sex if hba1cANDweight == 1, missing
dtable i.agebands i.gender i.ethnicity i.e2019_imd_5_patient i.region ///
	i.smoking_status /*i.alcstatus i.alclevel*/ i.unitcat i.alcohol_use_disorder ///
	i.ap_change i.smi_after_ap ///
	i.bl_onstatin i.initiatied_statin ///
	i.hba1c /*i.cholesterol_ldl i.bp_systolic*/ i.weight ///
	followup if hba1cANDweight == 1, ///
	define(iqrange = p25 p75, delimiter(-)) ///
	nformat(%9.0fc median iqrange) ///
	sformat("(%s)" iqrange) ///
	continuous(followup, ///
		statistics(median iqrange)) ///
	note("Continuous variables are summarised using median and IQR") ///
	by(med_age, nototals)
putdocx collect
*/

//TABLE 2 - Outcomes
putdocx paragraph, style(Heading1)
putdocx text ("Outcomes (Table 2)")
dtable i.t2dm i.t2dm_cat /*i.t2dm_incprev i.t2dm_med*/ /*i.cardiovascular i.cv_event*/ i.dementia i.died
putdocx collect

dtable i.t2dm i.t2dm_cat /*i.t2dm_incprev i.t2dm_med*/ /*i.cardiovascular i.cv_event*/ i.dementia i.died ///
	if hba1cANDweight == 1
putdocx collect

dtable i.t2dm i.t2dm_cat /*i.t2dm_incprev i.t2dm_med*/ /*i.cardiovascular i.cv_event*/ i.dementia i.died, ///
	by(hba1cANDweight)
putdocx collect


//TABLE 1 & TABLE 2 for each cohort
putdocx paragraph, style(Heading1)
putdocx text ("Baseline characteristics and results by presence of outcome data")
foreach cohort in hba1c /*cholesterol_ldl bp_systolic*/ weight {
	
	putdocx paragraph, style(Heading2)
	if "`cohort'" == "hba1c" {
		putdocx text ("HbA1c")
	}
	else if "`cohort'" == "cholesterol_ldl" {
		putdocx text ("LDL Cholesterol")
	}
	else if "`cohort'" == "bp_systolic" {
		putdocx text ("Systolic blood pressure")
	}
	else if "`cohort'" == "weight" {
		putdocx text ("Weight")
	}
	else {
		error
	}
	
	//TABLE 1
	putdocx paragraph, style(Heading3)
	putdocx text ("Baseline characteristics")
	dtable i.agebands i.gender i.ethnicity i.e2019_imd_5_patient i.region ///
		i.smoking_status /*i.alcstatus i.alclevel*/ i.unitcat i.alcohol_use_disorder ///
		i.ap_med i.ap_change i.smi_after_ap ///
		i.bl_onstatin i.initiatied_statin ///
		i.bl_hba1c_cat bl_hba1c bl_weight ///
		followup, ///
		define(iqrange = p25 p75, delimiter(-)) ///
		nformat(%9.0fc median iqrange) ///
		sformat("(%s)" iqrange) ///
		continuous(bl_hba1c bl_weight followup, ///
			statistics(median iqrange)) ///
		note("Continuous variables are summarised using median and IQR") ///
		by(`cohort') ///
		/*export(5_outputs/Table1_`cohort'_`date'_`time'.docx)*/
	putdocx collect
		
	//Row % for baseline characteristics
	//(using suggestion from StataList)
	putdocx paragraph, style(Heading3)
	putdocx text ("Baseline characteristics (row %)")
	unab sumvars: agebands gender ethnicity e2019_imd_5_patient region ///
		smoking_status /*alcstatus alclevel*/ unitcat alcohol_use_disorder ///
		ap_med ap_change smi_after_ap ///
		bl_onstatin initiatied_statin bl_hba1c_cat  //all variables to summarise
	table () (`cohort'), ///  build overall sample table
		statistic(frequency) ///
		statistic(percent, across(`cohort')) ///
		name(N) replace
	collect addtags N[_hide]
	collect layout (N) (`cohort'#result)
	foreach var of local sumvars {  //loop over each var to calculate row % across cohort
		
		table (`var') (`cohort'), ///
			statistic(frequency) ///
			statistic(percent, across(`cohort')) ///
			totals(`var') ///
			name(`var') replace
	}
	collect combine tab1 = N `sumvars', replace  //"tab1" to combine results from loop
	collect composite define stats = frequency percent  //produce result similar to dtable
	collect style cell result[percent], nformat("%6.1f") sformat("(%s%%)")
	collect style header result[stats], title(hide) level(hide)  //hide column headers
	collect layout (N `sumvars') (`cohort'#result[stats])  //finished layout
	/*collect export 5_outputs/Table1_rowpc_`cohort'_`date'_`time'.docx*/
	putdocx collect
	
	
	//TABLE 2
	putdocx paragraph, style(Heading3)
	putdocx text ("Outcomes")
	dtable i.t2dm i.t2dm_cat /*i.t2dm_incprev i.t2dm_med*/ /*i.cardiovascular i.cv_event*/ i.dementia i.died, ///
		by(`cohort') ///
		/*export(5_outputs/Table2_`cohort'_`date'_`time'.docx)*/
	putdocx collect
		
	//Row % for outcomes
	//(using suggestion from StataList)
	putdocx paragraph, style(Heading3)
	putdocx text ("Outcomes (row %)")
	unab outcomevars: t2dm t2dm_cat /*t2dm_incprev t2dm_med*/ /*cardiovascular cv_event*/ dementia died
	foreach var of local outcomevars {
		
		table (`var') (`cohort'), ///
			statistic(frequency) ///
			statistic(percent, across(`cohort')) ///
			totals(`var') ///
			name(`var') replace
	}
	collect combine tab2 = N `outcomevars', replace
	collect composite define stats = frequency percent
	collect style cell result[percent], nformat("%6.1f") sformat("(%s%%)")
	collect style header result[stats], title(hide) level(hide)
	collect layout (N `outcomevars') (`cohort'#result[stats])
	/*collect export 5_outputs/Table2_rowpc_`cohort'_`date'_`time'.docx*/
	putdocx collect
}


putdocx paragraph, style(Heading1)
putdocx text ("Combined plots")
putdocx paragraph
putdocx image "5_outputs/combined_main.`filetype'", linebreak(1)
putdocx image "5_outputs/combined_by_sex.`filetype'", linebreak(1)
putdocx image "5_outputs/combined_by_drug.`filetype'", linebreak(1)
putdocx image "5_outputs/combined_by_sex_drug.`filetype'", linebreak(1)
putdocx image "5_outputs/combined_by_hba1cstat.`filetype'", linebreak(1)
//putdocx image "5_outputs/combined_by_age.`filetype'", linebreak(1)
//putdocx image "5_outputs/combined_by_imd.`filetype'", linebreak(1)
//putdocx image "5_outputs/combined_by_age60_drug.`filetype'", linebreak(1)

putdocx paragraph, style(Heading1)
putdocx text ("Time to diabetes diagnosis/prescription")
putdocx paragraph
putdocx image "5_outputs/KM_timetodiabetes_table.png", linebreak(1)


putdocx save "5_outputs/Tables", replace
copy "5_outputs/Tables.docx" "5_outputs/Tables_`date'_`time'.docx", replace

putdocx append "5_outputs/Tables" ///
	"5_outputs/hba1c_missingdata" ///
	"5_outputs/hba1c_results_randomslope_v4" ///
	"5_outputs/weight_missingdata" ///
	"5_outputs/weight_results_randomslope_v4" ///
	"5_outputs/hba1cinweight_missingdata" ///
	"5_outputs/hba1cinweight_results_randomslope_v4" ///
	"5_outputs/weightinhba1c_missingdata" ///
	"5_outputs/weightinhba1c_results_randomslope_v4", ///
	pagebreak saving("5_outputs/antipsychotics_results", replace)
copy "5_outputs/antipsychotics_results.docx" ///
	"5_outputs/antipsychotics_results_`date'_`time'.docx", replace


log close
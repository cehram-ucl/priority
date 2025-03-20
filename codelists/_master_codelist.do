clear all
set more off

cd "C:\Users\rmjlton.AD\Documents\GitHub\priority\codelists"


//Merge codelists into one master codelist


// TYPE 2 DIABETES MELLITUS
use type_2_diabetes, clear

keep medcodeid t2dm t2dm_incprev

//Compact version
save compact/type_2_diabetes, replace

//Combined master codelist
save _master_codelist, replace


// MYOCARDIAL INFARCTION
use myocardial_infarction, clear

rename prevalent mi_prevalent
rename incident mi_incident

keep medcodeid mi mi_prevalent mi_incident

//Compact version
save compact/myocardial_infarction, replace

//Combined master codelist
merge 1:1 medcodeid using _master_codelist, nogenerate
save _master_codelist, replace


// STROKE
use stroke, clear

rename prevalent stroke_prevalent
rename incident stroke_incident

keep medcodeid stroke stroke_prevalent stroke_incident

//Compact version
save compact/stroke, replace

//Combined master codelist
merge 1:1 medcodeid using _master_codelist, nogenerate
save _master_codelist, replace


// ISCHAEMIC HEART DISEASE
use ischaemic_heart_disease, clear

rename prevalent ihd_prevalent
rename incident ihd_incident

keep medcodeid ihd ihd_prevalent ihd_incident

//Compact version
save compact/ischaemic_heart_disease, replace

//Combined master codelist
merge 1:1 medcodeid using _master_codelist, nogenerate
save _master_codelist, replace


// MAJOR CARDIOVASCULAR SURGERY
use major_cardiovascular_surgery, clear

keep medcodeid cv_surgery cvsurgery_type

//Compact version
save compact/major_cardiovascular_surgery, replace

//Combined master codelist
merge 1:1 medcodeid using _master_codelist, nogenerate
save _master_codelist, replace


// SMOKING STATUS
use smoking_status, clear

keep medcodeid smoking_status

//Compact version
save compact/smoking_status, replace

//Combined master codelist
merge 1:1 medcodeid using _master_codelist, nogenerate
save _master_codelist, replace


// ALCOHOL USE DISORDER
use alcohol_use_disorder, clear

keep medcodeid alcohol_use_disorder

//Compact version
save compact/alcohol_use_disorder, replace

//Combined master codelist
merge 1:1 medcodeid using _master_codelist, nogenerate
save _master_codelist, replace


// ETHNICITY
use ethnicity, clear

keep medcodeid eth5 eth16

//Compact version
save compact/ethnicity, replace

//Combined master codelist
merge 1:1 medcodeid using _master_codelist, nogenerate
save _master_codelist, replace


// CHOLESTEROL
use cholesterol, clear

keep medcodeid cholesterol triglycerides ldl non_hdl hdl total ratio vldl ///
	cholesterol_type

//Compact version
save compact/cholesterol, replace

//Combined master codelist
merge 1:1 medcodeid using _master_codelist, nogenerate
save _master_codelist, replace


// BLOOD PRESSURE
use blood_pressure, clear

keep medcodeid bp systolic_bp diastolic_bp bp_type

//Compact version
save compact/blood_pressure, replace

//Combined master codelist
merge 1:1 medcodeid using _master_codelist, nogenerate
save _master_codelist, replace


// HbA1c
use HbA1c, clear

keep medcodeid hba1c target

//Compact version
save compact/HbA1c, replace

//Combined master codelist
merge 1:1 medcodeid using _master_codelist, nogenerate
save _master_codelist, replace


// BMI
use body_mass_index, clear

keep medcodeid height weight bmi

//Compact version
save compact/body_mass_index, replace

//Combined master codelist
merge 1:1 medcodeid using _master_codelist, nogenerate
save _master_codelist, replace


// SEVERE MENTAL ILLNESS (SMI)
use "smi(pop def)_snomed_6_PWS_v2", clear

keep medcodeid smi subtype_agreed family_history resolved_remission

//Compact version
save "compact/smi(pop def)_snomed_6_PWS_v2", replace

//Combined master codelist
merge 1:1 medcodeid using _master_codelist, nogenerate
save _master_codelist, replace
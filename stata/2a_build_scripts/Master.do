clear all
set more off

cd "S:\CALIBER_23_003266\Phil"


//do 2a_build_scripts/00_codelist_med_SMI_v2
//do 2a_build_scripts/00_codelist_prod_antipsychotic_v2
//do 2a_build_scripts/00_codelist_prod_statin_v2
//do 2a_build_scripts/00_codelist_prod_antihypertensive_v2
//do 2a_build_scripts/01a_ImportPractice
//do 2a_build_scripts/01b_ImportPatient
//do 2a_build_scripts/01c_ImportObservation
//python script 2a_build_scripts/split_observation.py
//python script 2a_build_scripts/remove_binary_zeroes.py
//do 2a_build_scripts/01c_ImportObservation_part2
//do 2a_build_scripts/01d_ImportDrugIssue
//python script 2a_build_scripts/split_drugissue.py
//do 2a_build_scripts/01d_ImportDrugIssue_part2
//do 2a_build_scripts/02_LinkageEligiblePatients
//do 2a_build_scripts/03_EventVars
//do 2a_build_scripts/04_ValueVars
//do 2a_build_scripts/05_DrugVars
//do 2a_build_scripts/06a_Cleaning_HbA1c
//do 2a_build_scripts/06b_Cleaning_LDL-C
//do 2a_build_scripts/06c_Cleaning_Systolic
//do 2a_build_scripts/06d_Cleaning_Weight
do 2a_build_scripts/07_BuildCohort
do 2a_build_scripts/08_BaselineCovariates
do 2a_build_scripts/09_OnMedication
do 2a_build_scripts/10a_GenerateHbA1cDataset
//do 2a_build_scripts/10b_GenerateLDLDataset
//do 2a_build_scripts/10c_GenerateSystolicDataset
do 2a_build_scripts/10d_GenerateWeightDataset
do 2a_build_scripts/10e_Sensitivity_WeightInHbA1c
//do 2a_build_scripts/10f_Sensitivity_WeightInHbA1c_byvars
do 2a_build_scripts/10g_Sensitivity_HbA1cInWeight
//do 2a_build_scripts/Antipsy_dosage_v2

do 4a_analysis_scripts/HbA1c_randomslope_v2
do 4a_analysis_scripts/Weight_randomslope_v2
do 4a_analysis_scripts/HbA1c_sensitivity_inweight_randomslope_v2
do 4a_analysis_scripts/Weight_sensitivity_inhba1c_randomslope_v2
do 4a_analysis_scripts/GraphCombine_fullcohort
do 4a_analysis_scripts/TimeToDiabetes
do 4a_analysis_scripts/Tables
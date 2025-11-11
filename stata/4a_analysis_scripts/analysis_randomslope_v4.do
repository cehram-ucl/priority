//Arguments: outcome variable; Name of variable in string format; Units
args outcome name units


local iterations = 20  //No. of iterations to use for inital suitable model check
local model1txt "Model 1: Random intercept, random slopes, unstructured covariance"
local model2txt "Model 2: Random intercept, random slopes, unstructured covariance only for short-term slope"
local model3txt "Model 3: Random intercept, random slopes, independent covariance"
local model4txt "Model 4: Random intercept only"


//Start with baseline cohort
use 3_builds/cohort_baseline_medication_`outcome', clear
count

//Open Word file for results
putdocx begin
putdocx paragraph, style(Heading1)
putdocx text ("`name' results (random slope)")
putdocx paragraph

//Generate average value per day since initiation
egen avg_`outcome'_pday = mean(`outcome'), by(`outcome'_day)
label variable avg_`outcome'_pday "Mean `name' at time point"

//Select model to use
local model = 1  //default to 1; desired model
display as result "`model`model'txt'"

//Linear mixed model
//`outcome' = HbA1c or weight (dependent on passed argument)
//ls1 = pre-baseline; ls2 = short-term post-baseline; ls3 = long=term post-baseline
capture noisily mixed `outcome' ls1 ls2 ls3 ///
	|| tspatid: ls1 ls2 ls3, ///
	covariance(unstructured) stddeviations reml ///
	iterate(`iterations')

//If first model doesn't coverge, try second
if e(converged) == 0 | _rc {
	
	local model = 2
	display as result "`model`model'txt'"
	
	capture noisily mixed `outcome' ls1 ls2 ls3 ///
		|| tspatid: ls1 ls3, covariance(independent) ///
		|| tspatid: ls2, ///
		covariance(unstructured) stddeviations reml ///
		iterate(`iterations')
	
	//If second model doesn't coverge, try third
	if e(converged) == 0 | _rc {
		
		local model = 3
		display as result "`model`model'txt'"
		
		capture noisily mixed `outcome' ls1 ls2 ls3 ///
			|| tspatid: ls1 ls2 ls3, ///
			covariance(independent) stddeviations reml ///
			iterate(`iterations')
				
		//If third model doesn't coverge, just use random intercept only model
		if e(converged) == 0 | _rc {
			
			local model = 4
			display as result "`model`model'txt'"
			
			capture noisily mixed `outcome' ls1 ls2 ls3 ///
				|| tspatid: , ///
				covariance(unstructured) stddeviations reml
			
			if e(converged) == 0 | _rc {
				
				display as error "Model did not converge."
				error
			}
		}
	}
}

//Format variable name so it can be used to store the estimates
local name_formatted = subinstr("`name'", " ", "_", .)
local name_formatted = subinstr("`name_formatted'", "(", "", .)
local name_formatted = subinstr("`name_formatted'", ")", "", .)
local name_formatted = subinstr("`name_formatted'", "_&_", "_", .)

estimates store `name_formatted'

//Generate estimates table that can be placed in a Word doc
etable, estimates(`name_formatted') ///
	cstat(_r_b, nformat(%6.4f)) ///
	cstat(_r_ci, nformat(%6.4f) cidelimiter(" - ")) ///
	showstars showstarsnote ///
	column(estimates) ///
	title("`name' coefficients") ///
	note("`model`model'txt'")
putdocx collect
putdocx paragraph

//Generate predicted values using coefficients
predict p_`outcome'

//Produce scatter plot of average value per day since initiation
//with the linear splines on top (and save to Word doc)
graph twoway (scatter avg_`outcome'_pday `outcome'_day) ///
	(line p_`outcome' `outcome'_day, sort), ///
	legend(off) ytitle("`name' (`units')") title("`name'") ///
	xline(0) xtitle("Days since antipsychotic initiation")
graph save "5_outputs/`outcome'", replace
graph export "5_outputs/`outcome'.png", replace
putdocx image "5_outputs/`outcome'.png", linebreak(1)


//Produce plot showing just the linear spline (and save to Word doc)
quietly summarize p_`outcome'
local p_max = r(max)
graph twoway (line p_`outcome' `outcome'_day, sort), ///
	legend(off) ytitle("`name' (`units')") title("`name'") ///
	xline(0) xtitle("Days since antipsychotic initiation") ///
	text(`p_max' -500 "Pre-antipsychotic", placement(n)) ///
	text(`p_max' 500 "Post-antipsychotic", placement(n))
graph save "5_outputs/`outcome'_line", replace
graph export "5_outputs/`outcome'_line.png", replace
putdocx image "5_outputs/`outcome'_line.png", linebreak(1)


//By sex
putdocx paragraph, style(Heading2)
putdocx text ("By sex")
putdocx paragraph
do 4a_analysis_scripts/its_rs_by "`outcome'" "`name'" "`units'" ///
	gender `iterations'


//By age
putdocx paragraph, style(Heading2)
putdocx text ("By age")
putdocx paragraph
do 4a_analysis_scripts/its_rs_by "`outcome'" "`name'" "`units'" ///
	agebands `iterations'


//By age and sex
putdocx paragraph, style(Heading2)
putdocx text ("By age and sex")
putdocx paragraph
do 4a_analysis_scripts/its_rs_by2d "`outcome'" "`name'" "`units'" ///
	agebands gender `iterations'


//By IMD
putdocx paragraph, style(Heading2)
putdocx text ("By Index of Multiple Deprivation")
putdocx paragraph
do 4a_analysis_scripts/its_rs_by "`outcome'" "`name'" "`units'" ///
	e2019_imd_5_patient `iterations'


//By ethnicity
putdocx paragraph, style(Heading2)
putdocx text ("By ethnicity")
putdocx paragraph
do 4a_analysis_scripts/its_rs_by "`outcome'" "`name'" "`units'" ///
	ethnicity `iterations'


//By antipsychotic
putdocx paragraph, style(Heading2)
putdocx text ("By antipsychotic medication")
putdocx paragraph
do 4a_analysis_scripts/its_rs_by "`outcome'" "`name'" "`units'" ///
	ap_med `iterations'


//By antipsychotic and sex
putdocx paragraph, style(Heading2)
putdocx text ("By antipsychotic medication and sex")
putdocx paragraph
do 4a_analysis_scripts/its_rs_by2d "`outcome'" "`name'" "`units'" ///
	ap_med gender `iterations'
	
	
//By HbA1c category at baseline
putdocx paragraph, style(Heading2)
putdocx text ("By HbA1c status at baseline")
putdocx paragraph
do 4a_analysis_scripts/its_rs_by "`outcome'" "`name'" "`units'" ///
	bl_hba1c_cat `iterations'

/*
//By antipsychotic and above/below 60 years old
putdocx paragraph, style(Heading2)
putdocx text ("By antipsychotic medication and age")
putdocx paragraph
do 4a_analysis_scripts/its_rs_by2d "`outcome'" "`name'" "`units'" ///
	ap_med age60 `iterations'
*/

// By statin status at baseline
//==============================
putdocx paragraph, style(Heading2)
putdocx text ("By statin status at baseline")
putdocx paragraph

label define bl_onstatin 0 "No statin" 1 "On statin"
label values bl_onstatin bl_onstatin

do 4a_analysis_scripts/its_rs_by "`outcome'" "`name'" "`units'" ///
	bl_onstatin `iterations'


//By statin status at baseline & age
putdocx paragraph, style(Heading2)
putdocx text ("By age and statin status at baseline")
putdocx paragraph
do 4a_analysis_scripts/its_rs_by2d "`outcome'" "`name'" "`units'" ///
	agebands bl_onstatin `iterations'


// By statin status near antipsychotic initiation
//================================================
putdocx paragraph, style(Heading2)
putdocx text ("By statin status within 90 days (pre-/post-) of antipsychotic initiation")
putdocx paragraph

rename initiatied_statin init_statin

label define init_statin 0 "No statin" ///
	1 "On statin"
label values init_statin init_statin

do 4a_analysis_scripts/its_rs_by "`outcome'" "`name'" "`units'" ///
	init_statin `iterations'


//By statin status within 90 days & age
putdocx paragraph, style(Heading2)
putdocx text ("By age and statin status within 90 days of initiation")
putdocx paragraph
do 4a_analysis_scripts/its_rs_by2d "`outcome'" "`name'" "`units'" ///
	agebands init_statin `iterations'

/*
// By antihypertensive status
//============================
putdocx paragraph, style(Heading2)
putdocx text ("By antihypertensive status")
putdocx paragraph
generate ah_on_`outcome' = (`outcome'_date >= antihypertensive_first ///
	& `outcome'_date <= antihypertensive_last)
label define ah_status 0 "Not on antihypertensive" 1 "On antihypertensive"
label values ah_on_`outcome' ah_status

tab ah_on_`outcome', missing
egen avgpday_ah = mean(`outcome'), by(`outcome'_day ah_on_`outcome')
forvalues i = 0/1 {
	
	mixed `outcome' ls1 ls2 ls3 ///
		|| tspatid: ls1 ls3, covariance(independent) ///
		|| tspatid: ls2 ///
		if ah_on_`outcome' == `i', ///
		covariance(unstructured) stddeviations reml
	local ahlab`i': label (ah_on_`outcome') `i'
	local ahlab`i' = subinstr("`ahlab`i''", " ", "_", .)
	estimates store `ahlab`i''
	predict p_ah`i' if ah_on_`outcome' == `i'
}
label variable p_ah0 "Not currently on antihypertensive"
label variable p_ah1 "Currently on antihypertensive"
etable, estimates(`ahlab0' `ahlab1') ///
	cstat(_r_b, nformat(%6.4f)) ///
	cstat(_r_ci, nformat(%6.4f) cidelimiter(" - ")) ///
	showstars showstarsnote ///
	column(estimates) ///
	title("`name' coefficients by antihypertensive status")
putdocx collect
putdocx paragraph

graph twoway line p_ah* `outcome'_day, sort ///
	ytitle("`name' (`units')") ///
	xline(0) xtitle("Days since antipsychotic initiation") ///
	title("`name' by antihypertensive status")
graph save "5_outputs/`outcome'_AH_line", replace
graph export "5_outputs/`outcome'_AH_line.png", replace
putdocx image "5_outputs/`outcome'_AH_line.png", linebreak(1)

graph twoway (scatter avgpday_ah `outcome'_day, by(ah_on_`outcome', legend(off))) ///
	(line p_ah0 `outcome'_day if ah_on_`outcome' == 0, sort) ///
	(line p_ah1 `outcome'_day if ah_on_`outcome' == 1, sort), ///
	ytitle("`name' (`units')")
graph save "5_outputs/`outcome'_AH", replace
graph export "5_outputs/`outcome'_AH.png", replace
putdocx image "5_outputs/`outcome'_AH.png", linebreak(1)


//By antihypertensive status & age
putdocx paragraph, style(Heading2)
putdocx text ("By antihypertensive status and age")
putdocx paragraph
tab agebands ah_on_`outcome', missing
tab agebands ah_on_`outcome', missing nolabel
egen avgpday_ahage = mean(`outcome'), by(`outcome'_day agebands ah_on_`outcome')
forvalues i = 1/7 {
	
	//local agelab`i': label (agebands) `i'
	//local agelab`i' = subinstr("`agelab`i''", " ", "_", .)
	
	forvalues j = 0/1 {
	
		mixed `outcome' ls1 ls2 ls3 ///
			|| tspatid: ls1 ls3, covariance(independent) ///
			|| tspatid: ls2 ///
			if agebands == `i' & ah_on_`outcome' == `j', ///
			covariance(unstructured) stddeviations reml
		//local ahlab`j': label (ah_on_`outcome') `j'
		//local ahlab`j' = subinstr("`ahlab`j''", " ", "_", .)
		//local ahage`i'_`j' = "`agelab`i''" + "_" + "`ahlab`j''"
		estimates store ahage`i'_`j'
		predict p_ahage`i'_`j' if agebands == `i' & ah_on_`outcome' == `j'
	}
}
label variable p_ahage1_0 "18-29 (Not on antihypertensive)"
label variable p_ahage2_0 "30-39 (Not on antihypertensive)"
label variable p_ahage3_0 "40-49 (Not on antihypertensive)"
label variable p_ahage4_0 "50-59 (Not on antihypertensive)"
label variable p_ahage5_0 "60-69 (Not on antihypertensive)"
label variable p_ahage6_0 "70-79 (Not on antihypertensive)"
label variable p_ahage7_0 "80+ (Not on antihypertensive)"
label variable p_ahage1_1 "18-29 (On antihypertensive)"
label variable p_ahage2_1 "30-39 (On antihypertensive)"
label variable p_ahage3_1 "40-49 (On antihypertensive)"
label variable p_ahage4_1 "50-59 (On antihypertensive)"
label variable p_ahage5_1 "60-69 (On antihypertensive)"
label variable p_ahage6_1 "70-79 (On antihypertensive)"
label variable p_ahage7_1 "80+ (On antihypertensive)"
etable, estimates(ahage*) ///
	cstat(_r_b, nformat(%6.4f)) ///
	cstat(_r_ci, nformat(%6.4f) cidelimiter(" - ")) ///
	showstars showstarsnote ///
	column(estimates) ///
	title("`name' coefficients by age group and antihypertensive status")
putdocx collect
putdocx paragraph

graph twoway line p_ahage* `outcome'_day, sort ///
	ytitle("`name' (`units')") ///
	xline(0) xtitle("Days since antipsychotic initiation") ///
	by(ah_on_`outcome', iscale(0.75) legend(position(6))) legend(size(small) cols(2))
graph save "5_outputs/`outcome'_AHage_line", replace
graph export "5_outputs/`outcome'_AHage_line.png", replace
putdocx image "5_outputs/`outcome'_AHage_line.png", linebreak(1)
*/

putdocx save "5_outputs/`outcome'_results_randomslope_v4", replace
copy "5_outputs/`outcome'_results_randomslope_v4.docx"  ///
	"5_outputs/`outcome'_results_randomslope_v4_$datetime.docx", replace
/*Arguments: outcome variable;
	Name of variable in string format;
	Units of outcome variable (string);
	Variable for which results should be stratified;
	How many iterations should be used to find best model
*/	
args outcome name units byvar iterations


tab `byvar', missing
egen avgpday_`byvar' = mean(`outcome'), by(`outcome'_day `byvar')

local model1 = 1
local model2 = 1
local model3 = 1
local model1txt "Model 1: Random intercept, random slopes, unstructured covariance"
local model2txt "Model 2: Random intercept, random slopes, unstructured covariance only for short-term slope"
local model3txt "Model 3: Random intercept, random slopes, independent covariance"
local model4txt "Model 4: Random intercept only"

//First, check if a model with random slopes can be used
levelsof `byvar', local(levels)
foreach i of local levels {
	
	local levellab`i': label (`byvar') `i'
	display as result "Category: `levellab`i''"
	
	if `model1' == 1 {
		
		display as result "Model 1: Unstructured covariance..."
		
		capture noisily mixed `outcome' ls1 ls2 ls3 ///
		|| tspatid: ls1 ls2 ls3 ///
		if `byvar' == `i', ///
		covariance(unstructured) stddeviations reml ///
		iterate(`iterations')
	
		local model1 = e(converged)
	}
	
	if `model2' == 1 {
		
		display as result "Model 2: Unstructured short-term covariance..."
		
		capture noisily mixed `outcome' ls1 ls2 ls3 ///
			|| tspatid: ls1 ls3, covariance(independent) ///
			|| tspatid: ls2 ///
			if `byvar' == `i', ///
			covariance(unstructured) stddeviations reml ///
			iterate(`iterations')
			
		local model2 = e(converged)
	}
	
	if `model3' == 1 {
		
		display as result "Model 3: independent covariance..."
		
		capture noisily mixed `outcome' ls1 ls2 ls3 ///
			|| tspatid: ls1 ls2 ls3 ///
			if `byvar' == `i', ///
			covariance(independent) stddeviations reml ///
			iterate(`iterations')
				
		local model3 = e(converged)
	}
}


//Store coefficients for each level of stratified variable using chosen model
local labels ""
generate double pred_`byvar' = .
foreach i of local levels {
	
	local levellab`i': label (`byvar') `i'
	local levellab`i'_clean = subinstr("`levellab`i''", " ", "_", .)
	if "`byvar'" == "agebands" {
		local levellab`i'_clean = "Age_" + "`levellab`i'_clean'"
	}
	else if "`byvar'" == "e2019_imd_5_patient" {
		local levellab`i'_clean = "Quintile" + "`levellab`i'_clean'"
	}
	local levellab`i'_clean = subinstr("`levellab`i'_clean'", "(", "", .)
	local levellab`i'_clean = subinstr("`levellab`i'_clean'", ")", "", .)
	local levellab`i'_clean = subinstr("`levellab`i'_clean'", "-", "_to_", .)
	local levellab`i'_clean = subinstr("`levellab`i'_clean'", "+", "_plus", .)
	local levellab`i'_clean = subinstr("`levellab`i'_clean'", "<", "under_", .)
	local levellab`i'_clean = subinstr("`levellab`i'_clean'", ">=", "over_", .)
	local levellab`i'_clean = subinstr("`levellab`i'_clean'", "_years_old", "", .)
	local levellab`i'_clean = subinstr("`levellab`i'_clean'", "/", "_", .)
	local labels "`labels' `levellab`i'_clean'"
	display as result "Category: `levellab`i''"
	
	if `model1' == 1 {
		
		local model = 1
		display as result "Unstructured covariance model (1)..."
		
		mixed `outcome' ls1 ls2 ls3 ///
			|| tspatid: ls1 ls2 ls3 ///
			if `byvar' == `i', ///
			covariance(unstructured) stddeviations reml
		
		if e(converged) == 0 {
			
			display as error "Model did not converge. This shouldn't have happened."
			error
		}
	}
	else if `model2' == 1 {
		
		local model = 2
		display as result "Unstructured short-term covariance model (2)..."
		
		mixed `outcome' ls1 ls2 ls3 ///
			|| tspatid: ls1 ls3, covariance(independent) ///
			|| tspatid: ls2 ///
			if `byvar' == `i', ///
			covariance(unstructured) stddeviations reml
		
		if e(converged) == 0 {
			
			display as error "Model did not converge. This shouldn't have happened."
			error
		}
	}
	else if `model3' == 1 {
		
		local model = 3
		display as result "Independent covariance model (3)..."
		
		mixed `outcome' ls1 ls2 ls3 ///
			|| tspatid: ls1 ls2 ls3 ///
			if `byvar' == `i', ///
			covariance(independent) stddeviations reml
		
		if e(converged) == 0 {
			
			display as error "Model did not converge. This shouldn't have happened."
			error
		}
	}
	else {
		
		local model = 4
		display as error "No model with random slopes would converge for all categories of `byvar'."
		display as result "Random intercept only model (4)..."
		
		mixed `outcome' ls1 ls2 ls3 ///
			|| tspatid: ///
			if `byvar' == `i', ///
			covariance(unstructured) stddeviations reml
		
		if e(converged) == 0 {
			
			display as error "Model did not converge. This shouldn't have happened."
			error
		}
	}
	
	estimates store `levellab`i'_clean'
	predict p_`byvar'`i' if `byvar' == `i'
	replace pred_`byvar' = p_`byvar'`i' if `byvar' == `i'
	label variable p_`byvar'`i' "`levellab`i''"
}

local byvar_lab: variable label `byvar'

etable, estimates(`labels') ///
	cstat(_r_b, nformat(%6.4f)) ///
	cstat(_r_ci, nformat(%6.4f) cidelimiter(" - ")) ///
	showstars showstarsnote ///
	column(estimates) ///
	title("`name' coefficients by `byvar_lab'") ///
	note("`model`model'txt'")
putdocx collect
putdocx paragraph

graph twoway line p_`byvar'* `outcome'_day, sort ///
	ytitle("`name' (`units')") ///
	xline(0) xtitle("Days since antipsychotic initiation") ///
	title("`name' by `byvar_lab'")
graph save "5_outputs/`outcome'_`byvar'_line", replace
graph export "5_outputs/`outcome'_`byvar'_line.png", replace
putdocx image "5_outputs/`outcome'_`byvar'_line.png", linebreak(1)

graph twoway (scatter avgpday_`byvar' `outcome'_day) ///
	(line pred_`byvar' `outcome'_day, sort), ///
	by(`byvar', legend(off)) ///
	ytitle("`name' (`units')") ///
	xline(0) xtitle("Days since antipsychotic initiation")
graph save "5_outputs/`outcome'_`byvar'", replace
graph export "5_outputs/`outcome'_`byvar'.png", replace
putdocx image "5_outputs/`outcome'_`byvar'.png", linebreak(1)

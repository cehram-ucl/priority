/*Arguments: outcome variable;
	Name of variable in string format;
	Units of outcome variable (string);
	1st variable by which results should be stratified;
	2nd variable by which results should be stratified;
	How many iterations should be used to find best model
*/	
args outcome name units by_x by_y iterations


tab `by_x' `by_y', missing
egen avgpday_`by_x'`by_y' = mean(`outcome'), by(`outcome'_day `by_x' `by_y')

local model1 = 1
local model2 = 1
local model3 = 1
local model1txt "Model 1: Random intercept, random slopes, unstructured covariance"
local model2txt "Model 2: Random intercept, random slopes, unstructured covariance only for short-term slope"
local model3txt "Model 3: Random intercept, random slopes, independent covariance"
local model4txt "Model 4: Random intercept only"

//First, check if a model with random slopes can be used
levelsof `by_x', local(x_levels)
levelsof `by_y', local(y_levels)
foreach i of local x_levels {
	
	local xlevellab`i': label (`by_x') `i'
	
	foreach j of local y_levels {
		
		local ylevellab`j': label (`by_y') `j'
		
		display as result "Category: `xlevellab`i'' (`ylevellab`j'')"
		
		if `model1' == 1 {
			
			display as result "Model 1: Unstructured covariance..."
			
			capture noisily mixed `outcome' ls1 ls2 ls3 ///
			|| tspatid: ls1 ls2 ls3 ///
			if `by_x' == `i' & `by_y' == `j', ///
			covariance(unstructured) stddeviations reml ///
			iterate(`iterations')
		
			local model1 = e(converged)
		}
		
		if `model2' == 1 {
			
			display as result "Model 2: Unstructured short-term covariance..."
			
			capture noisily mixed `outcome' ls1 ls2 ls3 ///
				|| tspatid: ls1 ls3, covariance(independent) ///
				|| tspatid: ls2 ///
				if `by_x' == `i' & `by_y' == `j', ///
				covariance(unstructured) stddeviations reml ///
				iterate(`iterations')
				
			local model2 = e(converged)
		}
		
		if `model3' == 1 {
			
			display as result "Model 3: independent covariance..."
			
			capture noisily mixed `outcome' ls1 ls2 ls3 ///
				|| tspatid: ls1 ls2 ls3 ///
				if `by_x' == `i' & `by_y' == `j', ///
				covariance(independent) stddeviations reml ///
				iterate(`iterations')
					
			local model3 = e(converged)
		}
	}
}


//Store coefficients for each level of stratified variable using chosen model
local labels ""
generate double pred_`by_x'`by_y' = .
foreach i of local x_levels {
	
	local xlevellab`i': label (`by_x') `i'
	local xlevellab`i'_clean = subinstr("`xlevellab`i''", " ", "_", .)
	if "`by_x'" == "agebands" {
		local xlevellab`i'_clean = "Age_" + "`xlevellab`i'_clean'"
	}
	else if "`by_x'" == "e2019_imd_5_patient" {
		local xlevellab`i'_clean = "Quintile" + "`xlevellab`i'_clean'"
	}
	local xlevellab`i'_clean = subinstr("`xlevellab`i'_clean'", "(", "", .)
	local xlevellab`i'_clean = subinstr("`xlevellab`i'_clean'", ")", "", .)
	local xlevellab`i'_clean = subinstr("`xlevellab`i'_clean'", "-", "_to_", .)
	local xlevellab`i'_clean = subinstr("`xlevellab`i'_clean'", "+", "_plus", .)
	local xlevellab`i'_clean = subinstr("`xlevellab`i'_clean'", "<", "under_", .)
	local xlevellab`i'_clean = subinstr("`xlevellab`i'_clean'", ">=", "over_", .)
	local xlevellab`i'_clean = subinstr("`xlevellab`i'_clean'", "_years_old", "", .)
	local xlevellab`i'_clean = subinstr("`xlevellab`i'_clean'", "/", "_", .)
	
	foreach j of local y_levels {
		
		local ylevellab`j': label (`by_y') `j'
		local ylevellab`j'_clean = subinstr("`ylevellab`j''", " ", "_", .)
		if "`by_y'" == "agebands" {
			local ylevellab`j'_clean = "Age_" + "`ylevellab`j'_clean'"
		}
		else if "`by_y'" == "e2019_imd_5_patient" {
			local ylevellab`j'_clean = "Quintile" + "`ylevellab`j'_clean'"
		}
		local ylevellab`j'_clean = subinstr("`ylevellab`j'_clean'", "(", "", .)
		local ylevellab`j'_clean = subinstr("`ylevellab`j'_clean'", ")", "", .)
		local ylevellab`j'_clean = subinstr("`ylevellab`j'_clean'", "-", "_to_", .)
		local ylevellab`j'_clean = subinstr("`ylevellab`j'_clean'", "+", "_plus", .)
		local ylevellab`j'_clean = subinstr("`ylevellab`j'_clean'", "<", "under_", .)
		local ylevellab`j'_clean = subinstr("`ylevellab`j'_clean'", ">=", "over_", .)
		local ylevellab`j'_clean = subinstr("`ylevellab`j'_clean'", "_years_old", "", .)
		local ylevellab`j'_clean = subinstr("`ylevellab`j'_clean'", "/", "_", .)
		
		local labels "`labels' `xlevellab`i'_clean'_`ylevellab`j'_clean'"
		display as result "Category: `xlevellab`i'' (`ylevellab`j'')"
		
		if `model1' == 1 {
			
			local model = 1
			display as result "Unstructured covariance model (1)..."
			
			mixed `outcome' ls1 ls2 ls3 ///
				|| tspatid: ls1 ls2 ls3 ///
				if `by_x' == `i' & `by_y' == `j', ///
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
				if `by_x' == `i' & `by_y' == `j', ///
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
				if `by_x' == `i' & `by_y' == `j', ///
				covariance(independent) stddeviations reml
			
			if e(converged) == 0 {
				
				display as error "Model did not converge. This shouldn't have happened."
				error
			}
		}
		else {
			
			local model = 4
			display as error "No model with random slopes would converge for all categories of `by_x' & `by_y'."
			display as result "Random intercept only model (4)..."
			
			mixed `outcome' ls1 ls2 ls3 ///
				|| tspatid: ///
				if `by_x' == `i' & `by_y' == `j', ///
				covariance(unstructured) stddeviations reml
			
			if e(converged) == 0 {
				
				display as error "Model did not converge. This shouldn't have happened."
				error
			}
		}
		
		estimates store `xlevellab`i'_clean'_`ylevellab`j'_clean'
		predict p_`by_x'`by_y'`i'_`j' if `by_x' == `i' & `by_y' == `j'
		replace pred_`by_x'`by_y' = p_`by_x'`by_y'`i'_`j' if `by_x' == `i' & `by_y' == `j'
		label variable p_`by_x'`by_y'`i'_`j' "`xlevellab`i'' (`ylevellab`j'')"
	}
}

local by_x_lab: variable label `by_x'
local by_y_lab: variable label `by_y'

etable, estimates(`labels') ///
	cstat(_r_b, nformat(%6.4f)) ///
	cstat(_r_ci, nformat(%6.4f) cidelimiter(" - ")) ///
	showstars showstarsnote ///
	column(estimates) ///
	title("`name' coefficients by `by_x_lab' & `by_y_lab'") ///
	note("`model`model'txt'")
putdocx collect
putdocx paragraph

graph twoway line p_`by_x'`by_y'* `outcome'_day, sort ///
	ytitle("`name' (`units')") ///
	xline(0) xtitle("Days since antipychotic initiation") ///
	/*title("`name' by `by_x_lab' & `by_y_lab'")*/ ///
	by(`by_y', iscale(0.75) legend(position(6))) legend(cols(2) size(small))
graph save "5_outputs/`outcome'_`by_x'`by_y'_line", replace
graph export "5_outputs/`outcome'_`by_x'`by_y'_line.png", replace
putdocx image "5_outputs/`outcome'_`by_x'`by_y'_line.png", linebreak(1)

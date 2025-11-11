args dose_equiv_var med_var med_value cutoff


tab `med_var' if `med_var' == `med_value', missing
tab `med_var' if `med_var' == `med_value' & `dose_equiv_var' != ., missing

tab `dose_equiv_var' if `med_var' == `med_value', sort
tab `dose_equiv_var' if `med_var' == `med_value' & no_dosage_lookup == 0, sort missing
tab `dose_equiv_var' if `med_var' == `med_value' & no_dosage_lookup == 1, sort missing

summarize `dose_equiv_var' if `med_var' == `med_value', detail
summarize `dose_equiv_var' if `med_var' == `med_value' & no_dosage_lookup == 0, detail
summarize `dose_equiv_var' if `med_var' == `med_value' & no_dosage_lookup == 1, detail


recode `dose_equiv_var' (min/`cutoff' = 1) (`cutoff'/max = 2) ///
	if `med_var' == `med_value'


tab `dose_equiv_var' if `med_var' == `med_value', missing
cap program drop treat_strat
program define treat_strat
    syntax varlist [if] [in], treat(varname) strata(varname)
    foreach var of varlist `varlist' {
        quietly {
        preserve
        reg `var' `treat' `strata'
        keep if e(sample)
        egen total_N = count(`var')
        bys `strata' `treat': egen strata_condition_mean = mean(`var')
        bys `strata' `treat': egen strata_condition_N = count(`var')
        gen strata_condition_dev = (`var' - strata_condition_mean)^2
        bys `strata' `treat': egen strata_condition_dev_var = sum(strata_condition_dev)
        replace strata_condition_dev_var = strata_condition_dev_var / strata_condition_N
        keep `strata' `treat' strata_condition_mean strata_condition_N strata_condition_dev_var total_N
        duplicates drop
        reshape wide strata_condition_mean strata_condition_N strata_condition_dev_var, i(`strata') j(`treat')
        gen strata_treat = (strata_condition_mean1 - strata_condition_mean0) * ((strata_condition_N0+strata_condition_N1) / total_N)
        gen strata_var =  ((strata_condition_dev_var0 / strata_condition_N0) + (strata_condition_dev_var1 / strata_condition_N1)) * ((strata_condition_N0+strata_condition_N1) / total_N)^2
        egen treat_effect = sum(strata_treat)
        egen treat_variance = sum(strata_var)
        gen treat_sd = sqrt(treat_variance)
        gen treat_t = abs(treat_effect)/treat_sd
        gen treat_p = ttail(total_N-2, abs(treat_t)) * 2
        }
        display _newline "Results for `var'"
        display "==="
        display "Treatment effect: " treat_effect[1] _newline "SE stratified: " treat_sd[1] _newline "t stratified: " treat_t[1] _newline "p estimates: " treat_p[1] _newline "N: " total_N[1]
        restore
    }
end

** Export balance table to excel
 * v2.1.0
program balanceTable
    syntax varlist using/ [aweight], BY(varlist max=1) [strata(varlist max=1) sheet(passthru) replace modify *]
    version 15.1

    local _weight = "`weight'"
    local _exl = "`exp'"

    if missing("`strata'") {
        tempvar strata
        gen `strata' = 1
    }

    local models = ""

    ** Open spreadsheet in memory
    putexcel set "`using'",  `sheet' `replace' `modify' open

    ** Set up headers
    putexcel B1 = "All" C1 = "Control" D1 = "Treatment" E1 = "Diff" F1 = "Effect Size", right
    local row = 2

    ** t-test for each variable
    foreach var in `varlist' {
        local lab: variable label `var'

        qui sum `var'
        local all_mean = r(mean)
        local all_N = r(N)

        qui ttest `var', by(`by')
        local control_N = r(N_1)
        local treat_N = r(N_2)
        ** Formula for pooled SD comes from this page: https://www.stata.com/statalist/archive/2002-09/msg00054.html
        local SD_pool = sqrt(((r(N_1)-1) * r(sd_1)^2 + (r(N_2)-1) * r(sd_2)^2 )/ r(df_t))

        qui areg `var' i.`by' [``_weight''``_exp''], a(`strata')

        qui lincom 1.`by'
        local diff = `r(estimate)'
        local p = `r(p)'

        qui lincom 1.`by' + _cons
        local treat_mean = `r(estimate)'
        qui lincom _cons
        local control_mean = `r(estimate)'

        ** This formula is from the Procedures and Standards Handbook: https://ies.ed.gov/ncee/wwc/Docs/referenceresources/wwc_procedures_handbook_v4.pdf
         * p. E-4 (Effect Sizes from Student-Level t-tests or ANCOVA): "WWC computes Hedges’ g as the
         * covariate-adjusted mean difference divided by the unadjusted pooled within-group SD"
        local omega = (1-3/(4*`all_N'-9))
        local eta = (`omega'*`diff')/`SD_pool'
        local eta = abs(`eta')
        local eta: di %4.3f `eta'

        if `p' < 0.001 {
            local eta = "`eta'***"
        }
        else if `p' < 0.01 {
            local eta = "`eta'**"
        }
        else if `p' < 0.05 {
            local eta = "`eta'*"
        }
        else if `p' < 0.1 {
            local eta = "`eta'+"
        }
        else {
            local eta = "`eta'"
        }

        putexcel A`row' = "`lab'" B`row' = (`all_mean') C`row' = (`control_mean') D`row' = (`treat_mean') E`row' = (`diff'), nformat(0.000)
        putexcel F`row' = ("`eta'"), right

        ** Go to the next row
        local row = `row' + 1
        ** Print N
        putexcel A`row' = "N" B`row' = (`all_N') C`row' = (`control_N') D`row' = (`treat_N')

        ** Go to the next row
        local row = `row' + 1
        tempname `var'

        qui eststo ``var'': qui regress `var' i.`by' i.`strata' [``_weight''``_exp'']
        local models = "`models' ``var''"
    }

    local row = `row' + 1
    ** Joint test
     * suest always uses robust standard errors, so I don't need to specify that option
     * here
    qui suest `models'
    test 1.`by'

    ** Print N
    putexcel A`row' = "N" B`row' = (`all_N') C`row' = (`control_N') D`row' = (`treat_N')
    local row = `row' + 1
    putexcel D`row' = "Chi Square" E`row' = `r(chi2)', nformat(0.000)
    local row = `row' + 1
    putexcel D`row' = "Degrees of Freedom" E`row' = `r(df)'
    local row = `row' + 1
    putexcel D`row' = "p" E`row' = `r(p)', nformat(0.000)
    local row = `row' + 1

    ** Write the excel spreadsheet
    putexcel close

end

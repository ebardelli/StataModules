/***
_v. 2022.09.29_

balanceTable
============

__balanceTable__ -- exports a balance table to an excel document.

Syntax
------

> __balanceTable__ _varlist_ [if] [in] [using _filename_], by(group) [ _options_]

- - -

 - **using**: Optional. This is the name of an excel spreadsheet that will report the
              balance table results.
 - **if** and **in**: Optional. These options do the same thing as they do in standard
                      Stata programs.
 - **by**: This option requires a binary variable, where `0` indicates the control
           group and `1` indicates the treatment group. The table will report and
           compare the means for these two grups.
 - **strata**:  Optional. It will adjust the means by stratifying on this varialbe.
 - **sheet**: Optional. Sets the name for the sheet in excel
 - **replace** or **modify**: Optional. Either replaces or modifies an existing
           excel sheet
 - any _putexcel_ option: You can pass any _putexcel_ option to ___balanceTable___

Return
------

This package returns a matrix with the balance table values and the chi square
test statistics. Use `ereturn list` for a full list of the return values.

- - -


Example(s)
----------

    Simple balance table
        . balanceTable gender gpa using "balance_table.xlsx", by(treat) replace

    Stratified balance table
        . balanceTable gender gpa using "balance_table_class.xlsx", by(treat) strata(classroom) replace


Author
------

Emabyuele Bardelli
Brown University
bardelli@brown.edu

- - -

This help file was dynamically produced by
[MarkDoc Literate Programming package](http://www.haghish.com/markdoc/)
***/

** Export balance table to excel
 * 2022.09.29
program balanceTable, eclass
    syntax varlist [using/] [if] [in] [aweight fweight pweight], BY(varlist max=1) [strata(varlist max=1) sheet(passthru) replace modify *]
    version 15.0

    local _weight = "`weight'"
    local _exp = "`exp'"

    if missing("`strata'") {
        tempvar strata
        gen `strata' = 1
    }

    local models = ""

    ** Setup return matrix
    tempname mat
    matrix `mat' = J(1,9,.)
    matrix colnames `mat' = overall_mean control_mean treat_mean diff e_size prob control_N treat_N all_N


    ** Open spreadsheet in memory
    if !missing("`using'") {
        if `c(version)' > 15 {
            putexcel set "`using'",  `sheet' `replace' `modify' open
        }
        else {
            putexcel set "`using'",  `sheet' `replace' `modify'
        }

        ** Set up headers
        putexcel B1 = "All" C1 = "Control" D1 = "Treatment" E1 = "Diff" F1 = "Effect Size", right
        local row = 2
    }

    di _newline
    di as text "   Variable  {c |}    All   Control   Treat.     Diff    Eff. Size"
    di as text "{hline 13}{c +}{hline 53}"

    ** t-test for each variable
    foreach var in `varlist' {
        local lab: variable label `var'

        qui sum `var' `if' `in'
        local all_mean = r(mean)
        local all_N = r(N)

        qui ttest `var' `if' `in', by(`by')
        local control_N = r(N_1)
        local treat_N = r(N_2)
        ** Formula for pooled SD comes from this page: https://www.stata.com/statalist/archive/2002-09/msg00054.html
        local SD_pool = sqrt(((r(N_1)-1) * r(sd_1)^2 + (r(N_2)-1) * r(sd_2)^2 )/ r(df_t))

        qui areg `var' i.`by'  `if' `in' [`_weight'`_exp'], a(`strata')

        qui lincom 1.`by'
        local diff = `r(estimate)'
        if "`r(p)'" == "" {
            local p = 2*ttail(`r(df)', `r(estimate)'/`r(se)')
        }
        else {
            local p = `r(p)'
        }

        qui lincom 1.`by' + _cons
        local treat_mean = `r(estimate)'
        qui lincom _cons
        local control_mean = `r(estimate)'

        ** This formula is from the Procedures and Standards Handbook: https://ies.ed.gov/ncee/wwc/Docs/referenceresources/wwc_procedures_handbook_v4.pdf
         * p. E-4 (Effect Sizes from Student-Level t-tests or ANCOVA): "WWC computes Hedges' g as the
         * covariate-adjusted mean difference divided by the unadjusted pooled within-group SD"
        local omega = (1-3/(4*`all_N'-9))
        local eta = (`omega'*`diff')/`SD_pool'
        local eta = abs(`eta')
        local eta: di %4.3f `eta'

        if `p' < 0.001 {
            local sig = "***"
        }
        else if `p' < 0.01 {
            local sig = "**"
        }
        else if `p' < 0.05 {
            local sig = "*"
        }
        else if `p' < 0.1 {
            local sig = "+"
        }
        else {
            local sig = ""
        }

         _output_line "`lab'" `all_mean' `control_mean' `treat_mean' `diff' `eta' "`sig'"

        local rnames : rownames `mat'
        matrix `mat' = (`mat' \ `all_mean', `control_mean', `treat_mean', `diff', `eta', `p', `control_N', `treat_N', `all_N')
        matrix rownames `mat' = `rnames' `var'

        if !missing("`using'") {
            quietly putexcel A`row' = "`lab'" B`row' = (`all_mean') C`row' = (`control_mean') D`row' = (`treat_mean') E`row' = (`diff'), nformat(0.000)
            quietly putexcel F`row' = ("`eta'`sig'"), right

            ** Go to the next row
            local row = `row' + 1
            ** Print N
            quietly putexcel A`row' = "N" B`row' = (`all_N') C`row' = (`control_N') D`row' = (`treat_N')

            ** Go to the next row
            local row = `row' + 1
        }
        tempname `var'

        qui eststo ``var'': qui regress `var' i.`by' i.`strata'  `if' `in' [`_weight'`_exp']
        local models = "`models' ``var''"
    }

    di as text "{hline 13}{c BT}{hline 53}"

    local row = `row' + 1
    ** Joint test
     * suest always uses robust standard errors, so I don't need to specify that option
     * here
    qui suest `models'
    qui test 1.`by'

    _output_line "N" `all_N' `control_N' `treat_N'

    di _newline
    display as text "Joint Test of Significance"
    display as text "Chi Square:" _col(25) as result %4.3f `r(chi2)'
    display as text "Degrees of Freedom:" _col(25) as result %4.0f `r(df)'
    display as text "p:"  _col(24) as result %4.3f `r(p)'
    display _newline

    if !missing("`using'") {
        ** Print N
        local row = `row' + 1
        quietly putexcel A`row' = "N" B`row' = (`all_N') C`row' = (`control_N') D`row' = (`treat_N')

        ** Print Chi square statistics
        local row = `row' + 1
        quietly putexcel D`row' = "Chi Square" E`row' = `r(chi2)', nformat(0.000)
        local row = `row' + 1
        quietly putexcel D`row' = "Degrees of Freedom" E`row' = `r(df)'

        local row = `row' + 1
        quietly putexcel D`row' = "p" E`row' = `r(p)', nformat(0.000)

        local row = `row' + 1

        ** Write the excel spreadsheet
        if `c(version)' > 15 {
            putexcel save
        }
    }

    ereturn clear
    tempname rmat
    matrix `rmat' = `mat'[2...,1...]

    ereturn matrix balance = `rmat'

    ereturn scalar chi_square = `r(chi2)'
    ereturn scalar df_chi_square = `r(df)'
    ereturn scalar p_chi_square = `r(p)'
    ereturn scalar N_tot = `all_N'
    ereturn scalar N_cont = `control_N'
    ereturn scalar N_treat = `treat_N'

end

program _output_line
    args vname all control treat diff eta sig
    display as text %12s abbrev("`vname'",12) " {c |}" ///
            as result %8.0g `all' " " ///
                      %8.0g `control' " " ///
                      %8.0g `treat' " " ///
                      %8.0g `diff' " " ///
                      %8.0g `eta' "`sig'"
end


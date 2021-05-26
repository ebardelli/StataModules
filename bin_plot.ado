** Binned Plot Program
program bin_plot
    quietly {
    syntax varlist(max=1) [if] [in] , running(varlist max=1) bandwidth(real) [ deg(integer 3) bin(real 0.2) * ]
    preserve

    gen count = 1
    replace `running' = floor(`running' / `bin') * `bin'

    if !missing("`if'") | !missing("`in'") {
        keep `if' `in'
    }

    local fun_form = "c.`running'"
    forval d = 2/`deg' {
        local fun_form = "`fun_form'" + "##c.`running'"
    }

    ** This creates the collapsed dataset
    collapse (mean) `varlist' (sum) count, by(`running')

    gen cut_off = `running' >= 0

    ** Fit line for graph
    eststo r: regress `varlist' i.cut_off i.cut_off#(`fun_form') [w = count]

    eststo m_below: margins, at(cut_off=0 `running'=(-`bandwidth'(0.1)0)) post
    est restore r
    eststo m_above: margins, at(cut_off=1 `running'=(0(0.1)`bandwidth')) post

    ** Plot
    coefplot m_below m_above , at `options'
    addplot: scatter `varlist' `running' [w = count] if abs(`running') <= `bandwidth' ///
        , msymbol(oh) mcolor(gs8) msize(*0.7)

    restore
    }
end

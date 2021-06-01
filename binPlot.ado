/***
_v. 2021.06.01_

bin_plot
========

binPlot -- exports a binned scatter plot with a regression line.

Syntax
------

> binPlot _varlist_ _[if]_ _[in]_, _running_(_varlist_) _bandwidth_(real) [_deg_(integer 3) _bin_(real 0.2) _options_]

- - -

 - **varlist**: Variable for the y-axis. Only pass one variable.
 - **running**: Running variable. Only pass one variable. Right now, this program
                only works with the running variable centered at `0`.
 - **bandwidth**: Bandwidth around `0` to plot.
 - **degree** or **deg**: Optional. Polynomial degree for the regression. Defaults to `3`.
 - **bin**: Optional. Bin size for the scatterplot. Defaults to `0.2`.
 - any _coefplot_ option: You can pass any _coefplot_ option to ___bin_plot___


- - -


Example(s)
----------

    Simple binned plot
        . sysuse auto
        . gen running = mpg - 21.2973
        . binPlot price, running(running) bandwidth(5)

    Better plot
        . binPlot price, running(running) bandwidth(5) recast(line) ciopts(recast(rarea) fintensity(30) lcolor(%30)) xline (0) legend(off) xtitle("MPG") ytitle("Price")

Author
------

Emabyuele Bardelli
University of Michigan - School of Education
bardelli@umich.edu

- - -

This help file was dynamically produced by
[MarkDoc Literate Programming package](http://www.haghish.com/markdoc/)
***/

** Binned Plot Program
program binPlot
    quietly {
    syntax varlist(max=1) [if] [in] , running(varlist max=1) bandwidth(real) [ DEGree(integer 3) bin(real 0.2) * ]
    preserve

    gen count = 1
    replace `running' = floor(`running' / `bin') * `bin'

    if !missing("`if'") | !missing("`in'") {
        keep `if' `in'
    }

    local fun_form = "c.`running'"
    forval d = 2/`degree' {
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

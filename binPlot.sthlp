{smcl}
{it:v. 2021.06.01}


{title:bin_plot}

{p 4 4 2}
bin_plot -- exports a binned scatter plot with a regression line.


{title:Syntax}

{p 8 8 2} bin_plot {it:varlist} {it:[if]} {it:[in]}, {it:running_({it:varlist}) {it:bandwidth_(real) [{it:deg_(integer 3) {it:bin_(real 0.2) {it:options}]

{space 4}{hline}

{break}    {space 1}- {ul:varlist}: Variable for the y-axis. Only pass one variable.
{break}    {space 1}- {ul:running}: Running variable. Only pass one variable. Right now, this program
                only works with the running variable centered at `0`.
{break}    {space 1}- {ul:bandwidth}: Bandwidth around {c 96}0{c 96} to plot.
{break}    {space 1}- {ul:degree} or {ul:deg}: Optional. Polynomial degree for the regression. Defaults to {c 96}3{c 96}.
{break}    {space 1}- {ul:bin}: Optional. Bin size for the scatterplot. Defaults to {c 96}0.2{c 96}.
{break}    {space 1}- any {it:coefplot} option: You can pass any {it:coefplot} option to {bf:_bin_plot}


{space 4}{hline}



{title:Example(s)}

    Simple binned plot
        . sysuse auto
        . gen running = mpg - 21.2973
        . bin_plot price, running(running) bandwidth(5)

    Better plot
        . bin_plot price, running(running) bandwidth(5) recast(line) ciopts(recast(rarea) fintensity(30) lcolor(%30)) xline (0) legend(off) xtitle("MPG") ytitle("Price")


{title:Author}

{p 4 4 2}
Emabyuele Bardelli
University of Michigan - School of Education
bardelli@umich.edu

{space 4}{hline}

{p 4 4 2}
This help file was dynamically produced by
{browse "http://www.haghish.com/markdoc/":MarkDoc Literate Programming package}



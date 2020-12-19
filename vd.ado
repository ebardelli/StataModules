/***

# vd

___vd___ is a wrapper to `visidata`, an interactive multitool for tabular data.

To use, please install `visidata` on your system. ___vd___ will call it when run.

***/

program vd
    syntax [varlist] [if] [in]
    quietly {
    preserve
    if !missing("`varlist'") {
        keep `varlist'     
    }
    if !missing("`if'") {
        keep `if'     
    }
    if !missing("`in'") {
        keep `in'     
    }
    tempfile vd
    save `vd'
    !vd -f dta `vd'
    restore
    }
end

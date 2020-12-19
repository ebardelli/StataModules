/***

# vd

___vd___ is a wrapper to `visidata`, an interactive multitool for tabular data.

To use, please install `visidata` on your system. ___vd___ will call it when run.

***/

program vd
    tempfile vd
    quietly save `vd'
    !vd -f dta `vd'
end

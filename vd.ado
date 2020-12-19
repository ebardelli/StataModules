program vd
    tempfile vd
    quietly save `vd'
    !vd -f dta `vd'
end

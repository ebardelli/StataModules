** Merge multiple models
*! version 1.0.0  14aug2007  Ben Jann
*! version 1.0.1  15feb2018  Emanuele Bardelli
*! version 1.0.2  02apr2018  Emanuele Bardelli
program appendModels, eclass
    // using first equation of model
    version 8
    syntax namelist
    tempname b V tmp N
    local `N' = .
    foreach name of local namelist {
        qui est restore `name'
        ** Save N
        if e(N) < ``N'' {
            local `N' = e(N)
        }
        ** Prepare point estimates
        mat `tmp' = e(b)
        ** Keep only first equation
        local eq1: coleq `tmp'
        gettoken eq1 : eq1
        mat `tmp' = `tmp'[1,"`eq1':"]
        ** Drop constant
        local cons = colnumb(`tmp',"_cons")
        if `cons'<. & `cons'>1 {
            mat `tmp' = `tmp'[1,1..`cons'-1]
        }
		** Set column names
		local names: colnames `tmp'
		local new_names  = ""
		foreach name of local names {
			if "`new_names'" == "" {
				local new_names = "`name'_`e(depvar)'"
			}
			else {
				local new_names  = "`new_names' `name'_`e(depvar)'"
			}
		}
		mat coln `tmp' = `new_names'
        ** Append to the point estimate matrix
        mat `b' = (nullmat(`b') , `tmp')
        ** Prepare variance matrix
        mat `tmp' = e(V)
        ** Keep only first equation
        mat `tmp' = `tmp'["`eq1':","`eq1':"]
        ** Drop constant
        if `cons'<. & `cons'>1 {
            mat `tmp' = `tmp'[1..`cons'-1,1..`cons'-1]
        }
        ** Append to the variance matrix
        capt confirm matrix `V'
        if _rc {
            mat `V' = `tmp'
        }
        else {
            mat `V' = ///
            ( `V' , J(rowsof(`V'),colsof(`tmp'),0) ) \ ///
            ( J(rowsof(`tmp'),colsof(`V'),0) , `tmp' )
        }
    }
    ** Copy over names
    local names: colnames `b'

    mat coln `V' = `names'
    mat rown `V' = `names'

    ** Post results
    eret post `b' `V'
    eret scalar N = ``N''
    eret local cmd "appendModels `namelist'"
end

** Merge multiple models
*! version 1.0.0  14aug2007  Ben Jann
*! version 1.0.1  15feb2018  Emanuele Bardelli
*! version 1.0.2  02apr2018  Emanuele Bardelli
program appendModels, eclass
    // using first equation of model
    * version 8
    syntax namelist, [outcome keep(varlist)]
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
        
        ** Process variables to keep
        if "`keep'" != "" {
            tempname tmp_keep
            foreach var of local keep {
                local names: colnames `tmp'
                if strpos("`names'", "`var'") {
                    capt confirm matrix `tmp_keep'
                    if _rc {
                        mat `tmp_keep' = `tmp'[1,"`eq1':`var'"]
                    }
                    else {
                        mat `tmp_keep' = ///
                        ( `tmp_keep' , J(rowsof(`tmp'[1,"`eq1':`var'"]),colsof(`tmp'[1,"`eq1':`var'"]),0) ) \ ///
                        ( J(rowsof(`tmp'[1,"`eq1':`var'"]),colsof(`tmp'[1,"`eq1':`var'"]),0) , `tmp' )
                    }
                }
            }
            mat `tmp' = `tmp_keep'
        }

        ** Drop constant
        local cons = colnumb(`tmp',"_cons")
        if `cons'<. & `cons'>1 {
            mat `tmp' = `tmp'[1,1..`cons'-1]
        }
		
        ** Set column names
		local names: colnames `tmp'
		local new_names  = ""
        if "`outcome'" != "" { 
            foreach name of local names {
                if "`new_names'" == "" {
                    local new_names = "`name'_`e(depvar)'"
                }
                else {
                    local new_names  = "`new_names' `name'_`e(depvar)'"
                }
            }
        }
        else {
            foreach name of local names {
                if "`new_names'" == "" {
                    local new_names = "`name'"
                }
                else {
                    local new_names  = "`new_names' `name'"
                }
            }
        }

		mat coln `tmp' = `new_names'
        
        ** Append to the point estimate matrix
        mat `b' = (nullmat(`b') , `tmp')
        
        ** Prepare variance matrix
        mat `tmp' = e(V)
        
        ** Keep only first equation
        mat `tmp' = `tmp'["`eq1':","`eq1':"]

        ** Process variables to keep
        if "`keep'" != "" {
            tempname tmp_keep
            foreach var of local keep {
                local names: colnames `tmp'
                if strpos("`names'", "`var'") {
                    capt confirm matrix `tmp_keep'
                    if _rc {
                        mat `tmp_keep' = `tmp'[1,"`eq1':`var'"]
                    }
                    else {
                        mat `tmp_keep' = ///
                        ( `tmp_keep' , J(rowsof(`tmp'[1,"`eq1':`var'"]),colsof(`tmp'[1,"`eq1':`var'"]),0) ) \ ///
                        ( J(rowsof(`tmp'[1,"`eq1':`var'"]),colsof(`tmp'[1,"`eq1':`var'"]),0) , `tmp' )
                    }
                }
            }
            mat `tmp' = `tmp_keep'
        }

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
    local cols: colnames `b'
    local eqs: coleq `b'

    mat coln `V' = `cols'
    mat rown `V' = `cols'
    mat coleq `V' = `eqs'
    mat roweq `V' = `eqs'

    ** Post results
    eret post `b' `V'
    eret scalar N = ``N''
    eret local depvar = "`e(depvar)'"
    eret local cmd "appendModels `namelist'"

    eret display
end

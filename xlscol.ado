*! version 1.0.0, 26feb2015, Robert Picard, picard@netbox.com
*! from: https://www.statalist.org/forums/forum/general-stata-discussion/general/911743-putexcel-loop-through-colunms?p=917518#post917518
program define xlscol, rclass
    version 9

    args j
    confirm integer number `j'
    
    while `j' > 0 {
        local i = mod(`j'-1,26)
        local letter = char(`i' + 65)
        local res `letter'`res'
        local j = int((`j'-`i') / 26)
    }
    
    dis as text "col = " as res "`res'"
    return local col `res'
end

** Save dataset
 * This program labels and saves the dataset. Plus, it sends a notification to the Slack
 * channel if sendtoslack is installed
cap program drop saveDataset
program saveDataset
    syntax using/, [label(string) version(string) author(string) timestamp compress]

    ** Regex for path from: https://stackoverflow.com/questions/169008/regex-for-parsing-directory-and-filename
    if regexm("`using'", "^(.*/)([^/]*)$") {
        local path = regexs(1)
        local filename = regexs(2)
    }

    ** Get current date
    local c_date = c(current_date)

    label data "`label'"
    notes drop _dta
    notes: Version `version'
    notes: `c_date'
    notes: `author'

    if !missing("`timestamp'") {
        ** Automatic filename code inspired by: https://stats.idre.ucla.edu/stata/faq/how-can-i-generate-automated-filenames-in-stata/
        local Y: display %td_CCYY date(c(current_date),"DMY")
        local c_year = subinstr("`Y'", " ", "", .)
        local MD: display %td_NN_DD date(c(current_date), "DMY")
        local c_md = subinstr("`MD'", " ", "", .)
        local YY_MD = "`c_year'"+"-" +"`c_md'"

        compress
        gzsave "`path'`YY_MD'_`filename'", replace s(9)
    }

    save "`path'`filename'", replace
    if !missing("`compress'") {
        gzsave "`path'`filename'", replace s(9)
    }

end

{smcl}
{it:v. 2022.08.27}


{title:balanceTable}

{p 4 4 2}
{bf:balanceTable} -- exports a balance table to an excel document.


{title:Syntax}

{p 8 8 2} {bf:balanceTable} {it:varlist} [using {it:filename}], by(group) [ {it:options}]

{space 4}{hline}

{break}    {space 1}- {ul:using}: Optional. This is the name of an excel spreadsheet that will report the
              balance table results.
{break}    {space 1}- {ul:by}: This option requires a binary variable, where {c 96}0{c 96} indicates the control
           group and `1` indicates the treatment group. The table will report and
           compare the means for these two grups.
{break}    {space 1}- {ul:strata}:  Optional. It will adjust the means by stratifying on this varialbe.
{break}    {space 1}- {ul:sheet}: Optional. Sets the name for the sheet in excel
{break}    {space 1}- {ul:replace} or {ul:modify}: Optional. Either replaces or modifies an existing
           excel sheet
{break}    {space 1}- any {it:putexcel} option: You can pass any {it:putexcel} option to {bf:_balanceTable}


{title:Return}

{p 4 4 2}
This package returns a matrix with the balance table values and the chi square
test statistics. Use {c 96}ereturn list{c 96} for a full list of the return values.

{space 4}{hline}



{title:Example(s)}

    Simple balance table
        . balanceTable gender gpa using "balance_table.xlsx", by(treat) replace

    Stratified balance table
        . balanceTable gender gpa using "balance_table_class.xlsx", by(treat) strata(classroom) replace



{title:Author}

{p 4 4 2}
Emabyuele Bardelli
Brown University
bardelli@brown.edu

{space 4}{hline}

{p 4 4 2}
This help file was dynamically produced by
{browse "http://www.haghish.com/markdoc/":MarkDoc Literate Programming package}



{smcl}

{title:balanceTable}

{p 4 4 2}
___balanceTable_} exports a balance table to an excel document.

{title:Syntax}

{p 8 8 2} {bf:_balanceTable_} varlist using {it:filename}, by(comparison) [options]

{p 4 4 2}{bf:Options}

{p 4 4 2}
The options are the following:

{break}    {space 1}- {ul:by}: This option requires a binary variable, where {c 96}0{c 96} indicates the control group and {c 96}1{c 96} indicates the treatment group. The table will report and compare the means for these two grups.
{break}    {space 1}- {ul:strata}:  Optional. It will adjust the means by stratifying on this varialbe. |
{break}    {space 1}- {ul:sheet}: Optional. Sets the name for the sheet in excel
{break}    {space 1}- {ul:replace} or {ul:modify}: Optional. Either replaces or modifies an existing excel sheet
{break}    {space 1}- any {it:putexcel} option: You can pass any {it:putexcel} option to {bf:_balanceTable}




{smcl}
{it:v. 2022.12.18}


{title:calculate_V_ccr}

{p 4 4 2}
calculate_V_ccr -- calculates the causal cluster variance matrix for a fixed effects regression model


{title:Syntax}

{p 8 8 2} calculate_V_ccr, est_robust(model name) est_cluster(model name) treat(varname) fe(varname)

{space 4}{hline}
{break}    {space 1}- {ul:est_robust} and {ul:est_cluster}: Model names for the regression models estimated
		with robust and clustered standard errors. Save these estimates with {c 96}est sto{c 39}
{break}    {space 1}- {ul:treat}: Variable name for the treatment indicator
{break}    {space 1}- {ul:fe}: Variable name for the fixed effects/cluster indicator


{title:Return}

{p 4 4 2}
This package returns regression estimates adjusted following the Causal Cluster
Variance calculations described in Abadie et al. (2023).
{space 4}{hline}


{title:Author}

{p 4 4 2}
Emabyuele Bardelli
Brown University
bardelli@brown.edu

{space 4}{hline}

{p 4 4 2}
This help file was dynamically produced by
{browse "http://www.haghish.com/markdoc/":MarkDoc Literate Programming package}



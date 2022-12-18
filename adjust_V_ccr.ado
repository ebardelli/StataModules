/***
_v. 2022.12.18_

calculate_V_ccr
===============

calculate_V_ccr -- calculates the causal cluster variance matrix for a fixed effects regression model

Syntax
------

> calculate_V_ccr, est_robust(model name) est_cluster(model name) treat(varname) fe(varname)

- - -
 - **est_robust** and **est_cluster**: Model names for the regression models estimated
		with robust and clustered standard errors. Save these estimates with `est sto'
 - **treat**: Variable name for the treatment indicator
 - **fe**: Variable name for the fixed effects/cluster indicator

Return
------

This package returns regression estimates adjusted following the Causal Cluster
Variance calculations described in Abadie et al. (2023).
- - -

Author
------

Emabyuele Bardelli
Brown University
bardelli@brown.edu

- - -

This help file was dynamically produced by
[MarkDoc Literate Programming package](http://www.haghish.com/markdoc/)
***/
program define calculate_V_ccr, eclass
    syntax, est_robust(string) est_cluster(string) treat(string) fe(string)
    quietly {
    ** Save variance matrices from robust and clustered models
    est restore `est_robust'
    mat V_r = e(V)
    mata: V_r = st_matrix("V_r")

    est restore `est_cluster'
    mat V_c = e(V)
    mata: V_c = st_matrix("V_c")

    ** Save coefficients
    mat b = e(b)

    ** Calculate cluster-level proportion in treatment
    gstats tab `treat', by(`fe') statistics(mean) matasave
    mata: W = GstatsOutput.output'
    mata: N = GstatsOutput.J

    ** Calculate percentage of cluster with treatment assignment
    mata: q = mean(ceil(W)')

    ** Calculate lambda using equation (20) in the paper
    mata lambda = 1 - (q * (((1/N) * (W * (1 :- W)'))^2) / ((1/N) * ((W :^ 2) * ((1 :- W) :^ 2)')))

    ** Calculate causal cluster variance matrix
    mata: V_ccr = (lambda * V_c) + ((1 - lambda) * V_r)

    ** Return causal cluster variance matrix and lambda to stata
    mata: st_matrix("V_ccr", V_ccr)
    mata: st_numscalar("lambda", lambda)

    ** Return adjusted estimates
    est restore `est_robust'
    ereturn repost b = b V = V_ccr
    ereturn scalar lambda = lambda
    ereturn local vcetype "CCV"
    noisily ereturn display
    }
end

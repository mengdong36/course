
***Preparation
ssc install center, replace
ssc install estout, replace
ssc install xtabond2, replace
ssc install ivreg2, replace
ssc install ranktest, replace
//The basic Stata static panel data estimator is xtreg. It will estimate FE, BE and RE models. 
//To estimate using POLS or FD, use regress.

webuse psidextract, clear


by id: center lwage ed exp union t, prefix(dm_) meansave double
// Generate group means and mean-deviations (within transformation).


***Bootstrap
reg lwage ed exp union
// Our basic model, estimated by POLS

reg lwage ed exp union, vce(bootstrap)
// Which is a shorthand for this, using the bootstrap command:

bootstrap _b : reg lwage ed exp union
// And bootstrapping the coeffs is the default, so we can omit _b:

bootstrap : reg lwage ed exp union

reg lwage ed exp union, vce(bootstrap, seed(1))
bootstrap, seed(1) : reg lwage ed exp union
//set seed.the results replicate

reg lwage ed exp union, vce(bootstrap, seed(1) reps(200))
// The default #reps is 50, which is low.  200 is better.

xtreg lwage ed exp union, re vce(bootstrap, seed(1) reps(200))
//Stata xt (panel) commands automatically implement a cluster bootstrap


xtset, clear
bootstrap, cluster(id) seed(1) reps(200):	reg lwage ed exp union
xtset id t
// But to implement the cluster bootstrap for a non-xt command like reg,
// we have to use the actual "bootstrap" command with various options.
// We also have to temporarily un-xtset the data.

xtset, clear
bootstrap, cluster(id) idcluster(newid) seed(1) reps(200):	xtreg lwage ed exp union, re i(newid)
xtset id t
//by hand cluster

// POLS
// VCEs: classical, cluster-robust, bootstrap, cluster-bootstrap
qui reg lwage ed exp union
est store POLS
qui reg lwage ed exp union, cluster(id)
est store POLS_CL
qui reg lwage ed exp union, vce(bootstrap)
est store POLS_BT
xtset, clear
qui bootstrap _b, cluster(id) idcluster(newid) seed(1) reps(200):	///
				reg lwage ed exp union
xtset id t
est store POLS_BTCL

// FE
// VCEs: classical, cluster-robust, cluster-bootstrap
qui xtreg lwage ed exp union, fe
est store FE
qui xtreg lwage ed exp union, fe cluster(id)
est store FE_CL
qui xtreg lwage ed exp union, fe vce(bootstrap, seed(1) reps(200))
est store FE_BTCL

// BE
// VCEs: classical, bootstrap
// Q: why not cluster or cluster-bootstrap?
// (Hint: the BE estimator is implemented by OLS on group means.)
qui xtreg lwage ed exp union, be
est store BE
qui xtreg lwage ed exp union, be vce(bootstrap, seed(1) reps(200))
est store BE_BT

// RE
// VCEs: classical, cluster-robust, cluster-bootstrap
qui xtreg lwage ed exp union, re
est store RE
qui xtreg lwage ed exp union, re cluster(id)
est store RE_CL
qui xtreg lwage ed exp union, re vce(bootstrap, seed(1) reps(200))
est store RE_BTCL

// FD
// We have to use a trick for the FD estimation.
// Below, we create FD variables and then give them
// the names of the level variables.  That means
// the coeffs appear nicely lined up in the table
// that combines the results of all 5 estimations.
// "preserve" and "restore" are Stata utilities that
// allow you to save a version of the dataset in
// memory temporarily and automatically return to it.
// Useful if you want to make temporary changes.
preserve
foreach var of varlist lwage ed exp union {
	qui gen D`var' = D.`var'
	qui replace `var' = D`var'
}
qui reg lwage ed exp union, nocons
est store FD
qui reg lwage ed exp union, nocons cluster(id)
est store FD_CL
xtset, clear
qui bootstrap, cluster(id) seed(1) reps(200):	///
				reg lwage ed exp union, nocons
xtset id t
est store FD_BTCL
restore

// Examine the results carefully.
// Which estimators use within (time-series) variation?
// Which estimators use between (cross-section) variation?
// Which estimators use both?
// Some coeff estimates are missing.  Why?
// Which estimators give similar coeff estimates?
// Which give different coeff estimates?  For which variables?
// Does cluster-robust make a difference?  Why?
// How do the classical and bootstrap SEs compare?
// How do the cluster-robust and cluster-bootstrap SEs compare?

// Summary table for POLS
esttab POLS POLS_BT POLS_CL POLS_BTCL,		///
		b(4) se(4)							///
		mtitles

// Summary table for FE and FD
esttab FE FE_CL FE_BTCL FD FD_CL FD_BTCL,	///
		b(4) se(4)							///
		mtitles

// Summary table for RE and BE
esttab RE RE_CL RE_BTCL BE BE_BT,			///
		b(4) se(4)							///
		mtitles



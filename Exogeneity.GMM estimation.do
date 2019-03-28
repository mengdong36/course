* Endogeneity problem #1: Measurement error in x
* What do to about measurement error in x?
* "errors-in-variables" (EIV) regression (the Stata
* command is eivreg). If we know the variance of the measurement error
* E(h2i), then we have available a "bias-adjusted" estimator (see the Stata
* manual), bbEIV . But we rarely know what E(h2i) is.


*** Preparation

ssc install ivreg2
//IV/GMM estimator

ssc install ranktest

*** Morte Calo 比较b_ols 和b_iv

* 1. set program
capture program drop mysimendog
program define mysimendog, rclass
	drop _all
	set obs $n
  drawnorm x z e, cov(V)
//specify covariance matrix and draw from the multicariate normal with zero mean.
  gen y = x + e
// Run the regression using OLS
	reg y x
	return scalar b_ols=_coef[x]
	if _coef[x] > 2 {return scalar b_ols=2}
	if _coef[x] < 0 {return scalar b_ols=0}

// Run the regression using IV
// Use the simple, old and now undocumented "ivreg" command - very fast.
	ivreg y (x = z)
	return scalar b_iv=_coef[x]
	if _coef[x] > 2 {return scalar b_iv=2}
	if _coef[x] < 0 {return scalar b_iv=0}

end

* 2. simulate
// Specification 1:
global simnumber=1
global simname "Cov(x,e)=0.3; Cov(x,z)=0.5; n=100"
global xe_cov=0.3
global xz_cov=0.5
global n=100

// Stata's "matrix mini-language":
mat V = (1, $xz_cov , $xe_cov \ $xz_cov, 1, 0 \ $xe_cov, 0, 1)
mat list V


// Simulate.  Obtain coefficient estimates and standard errors.
set more off
// Control the random number seed so that the results are replicatable.
set seed 1
simulate								///
			b_ols=r(b_ols)				///
			b_iv=r(b_iv)				///
			, reps(10000): mysimendog

// Are the estimates for b biased or unbiased?
twoway												///
		(kdensity b_iv if b_iv>0 & b_iv<2)			///
		(kdensity b_ols if b_ols>0 & b_ols<2)		///
		, xlabel(0 0.5 1 1.5 2) xline(1)			///
		title(Distribution of b)					///
		subtitle("$simname")						///
		name(bias$simnumber, replace)

// Which estimator performs better in terms of bias?
// Which estimator performs better in terms of variance?
// (Just look at the standard deviations.)
sum b_ols b_iv

// Which estimator performs better in terms of MSE?
cap drop mse*
gen mse_ols=(b_ols-1)^2
gen mse_iv =(b_iv -1)^2
sum mse_ols mse_iv


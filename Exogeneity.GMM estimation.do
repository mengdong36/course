*** 内生性问题-测量误差

* Endogeneity problem #1: Measurement error in x
* What do to about measurement error in x?
* "errors-in-variables" (EIV) regression (the Stata
* command is eivreg). If we know the variance of the measurement error
* E(h2i), then we have available a "bias-adjusted" estimator (see the Stata
* manual), βEIV . But we rarely know what E(η^2) is.


*** 控制变量的选择方法

pdslasso 
ivlasso 
* by Ahrens-Hansen-Scha¤er implement PDS(post-double selection) and related methods.



*** Preparation

ssc install ivreg2
// IV/GMM estimator
// ivreg <depvar> <exog vars> (<endog vars> = <instruments>)

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
//只有一个内生的regressor, 一个外生的工具。 没有外生的vars. 所以 ivreg y (x=z) 	
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


*** AJR 比较发展殖民起源

use maketable8, clear
keep if baseco==1

//ivreg2 <depvar> <exog vars> (<endog vars> = <instruments>), options

//The main options:
//robust Use the heteroskedastic-consistent SHC for the AVar
//gmm2s Use 2-step Feasible Efficient GMM
//cue Use continuously-updated (CUE) GMM
//small Use finite-sample formula for SEs (comparable to regress)
//first Report a full set of first-stage regressions
//ffirst Report a summary of the first-stage regression results and tests

//What the combinations mean:
//<nothing> OLS or IV as efficient GMM. Sclassical in Wn and in AVar.
//robust OLS or IV as inefficient GMM. Sclassical in Wn. SHC in AVar.
//robust gmm2s 2-step Feasible Efficient GMM. SHC in Wn and in AVar.


//GMM Distance tests (in options, after comma):
//endog(<endog vars>) Test if listed endogenous regressors can be treated as exogenous. Saved test stat: 
e(estat).
//orthog(<exog vars>) Test if listed exogenous regressors should be treated as endogenous. Saved test stat: 
c(estat).
//orthog(<instruments>) Test if listed excluded instruments are endogenous and should be dropped as excluded IVs. Saved test stat: 
c(estat).


// ivreg2 y x1 x2 x3 (v1 v2 = z1 z2 z3 z4), <options>
//     y  = dependent variable
//     xs = exogenous regressors
//     vs = endogenous regressors
//     zs = excluded instruments

// Covariance options:
//     nothing = classical S, homoskedasticity assumed
//     robust = robust S_HC, heteroskedasticity-consistent

// Estimator options:
//     nothing = OLS or IV
//     gmm2s = 2-step feasible efficient GMM
//     cue = CUE, continuously-updated GMM

// GMM Distance tests:
//   In options (after comma):
//     endog(v1 v2 ...) =  test if endogenous regressors
//                         v1, v2, etc. can be treated
//                         as exogenous.
//                         Saved test stat =e(estat).
//     orthog(x1 x2 ...) = test if exogenous regressors
//                         x1, x2, etc. should be treated
//                         as endogenous regressors.
//                         Saved test stat =e(cstat).
//     orthog(z1 z2 ...) = test if excluded instruments
//                         z1, z2, etc. are endogenous and
//                         should be dropped as excluded IVs.
//                         Saved test stat =e(cstat).






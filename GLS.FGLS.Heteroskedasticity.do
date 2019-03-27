*** 比较OLS，GLS，FGLS及 S(classical),S(HC)的Monte Carlo

// 1. set program and simulation

program define mysimhetgls, rclass
	drop _all
	set obs 100
	gen x = uniform()
	gen u = rnormal()
	gen epsilon = u*x
//vi(xi) = xi2
	gen y = x + epsilon
*	1.OLS
	reg y x
	return scalar b_ols=_coef[x]
	return scalar se_ols=_se[x]
	reg y x, robust
	return scalar se_rob = _se[x]


//'robust' option to get heteroskedasticity consistent error
// specify the option "cluster(clustvar)" or "vce(cluster clustvar)", where "clustvar"
// is the name of the variable identifying the di¤erent groups.


*	2.GLS
	reg y x [aw=1/x^2]
	return scalar b_gls = _coef[x]
	return scalar se_gls = _se[x]
	
//	GLS by hand
//	gen y_gls = y/x
//	gen x_gls = 1
//	gen cons_gls = 1/x
//	reg y_gls x_gls cons_gls, nocons
//	return scalar b_gls = _coef[x]
//	return scalar se_gls = _se[x]

*	3.FGLS with general skedastic fn
	reg y x
	predict double ehat, resid
	gen double logehatsq=ln(ehat^2)
	reg logehatsq x
	predict double ghat, xb
	gen double vhat=exp(ghat)
	reg y x [aw=1/vhat]
	return scalar b_fgls = _coef[x]
	return scalar se_fgls = _se[x]
	reg y x [aw=1/vhat], robust
	return scalar se_fglsrob = _se[x]

end

set more off
// A new trick - "set more off" means Stata won't stop and ask "More?"
// "more" will be off until the do file stops running.
set seed 1
// Control the random number seed so that the results are replicatable.

simulate	b_ols=r(b_ols)				        ///
			se_ols=r(se_ols)			///
			se_rob=r(se_rob)			///
			b_gls=r(b_gls)				///
			se_gls=r(se_gls)			///
			b_fgls=r(b_fgls)			///
			se_fgls=r(se_fgls)			///
			se_fglsrob=r(se_fglsrob)		///
			, reps(10000): mysimhetgls

// 2. comparison
sum b*, detail
twoway		(kdensity b_ols if b_ols>0 & b_ols<2)		///
		(kdensity b_gls if b_gls>0 & b_gls<2)		///
		(kdensity b_fgls if b_fgls>0 & b_fgls<2)	///
		, xlabel(0 0.5 1 1.5 2) xline(1)		///
		title(Distribution of b)			///
		name(bias, replace)
// 'kdensity' 画pdf
		

// 3. test power 

putmata	all_beta=(b_ols b_ols b_gls b_fgls b_fgls)			///
		all_se=(se_ols se_rob se_gls se_fgls se_fglsrob),	///
		replace

mata: POWER=J(0,6,.)		
//  a "void" matrix with 6 columns and no rows.
//  we collect our results in it
* all_beta is a matrix of all our MC betas
* and all_se is a matrix of all our MC SEs
* We use the :- operator to form the numerator for every z stat
* and the :/ to divide by the corresponding.
* The resulting matrix all_z is a matrix of all the z stats,
* and all_r is a matrix of all the rejection indicators (1 or 0).
* We complete the loop by calculating the rejection rate.
* colsum is the sum of rejections for each z stat;
* we divide by the number of MCs to get the rejection rate.
forvalues beta = 0(.01)2 {
	mata: all_z = abs(all_beta :- `beta') :/ all_se
	mata: all_r = (all_z :> 1.96)
	mata: new_row = (`beta' , (colsum(all_r)/rows(all_r)) )
	mata: POWER = POWER \ new_row
}

* We're done, so get the data from Mata and put into Stata.
* The force option is required because the number of rows doesn't match
* the number of rows in our dataset.
getmata (hypoth power_ols power_rob power_gls		///
		power_fgls power_fglsrob)=POWER		///
		, force replace

* Power curves
line power_ols power_rob power_gls power_fgls power_fglsrob hypoth,	///
	yline(0.05) xline(1)						///
	ytitle("Rejection frequency") title("Power")			///
	name(power, replace)

* Closeup of power curves
line power_ols power_rob power_gls power_fgls power_fglsrob hypoth	///
	if power_gls<0.2,						///										///
	yline(0.05) xline(1)						///
	ytitle("Rejection frequency") title("Power (closeup)")		///
	name(power_closeup, replace)


//GlS should be more precise--have a smaller variance.




	
	
	
	
	
	


*** Test heteroskedasticity

**1. White test
estat imtest, white

//H0：homoskedasticity
//卡方分布, A vector of constract.
//Stata’s estat imtest doesn’t accept weights.
//前一步regress如果Nocons, 也没办法做white检验？


2.Breusch-Pagan/Godfrey version test
estat hettest, iid rhs
estat hettest, iid
estat hettest yhat yhatsq, iid

//The 3 versions are (i) use the regressors on the RHS in the artificial regression (rhs option); 
//(ii) use the predicted value of y, on the RHS (Stata’s default); 
//(iii) use 𝑦hat and its square on the RHS. 
//For all of the B-P/G versions, use the iid option to get the nR2 test that does not require normality.


//the test statistics should have a 𝜒2 distribution under conditional homoskedasticity.
//A large (=“unlikely”) test statistic with a small p-value suggests the model is misspecified and heteroskedasticity is present


*** Deal with heteroskedastity

** 1. WLS
// Weighted estimation in Stata:
// 4 types of weights available: fw, aw, pw and iw.
// Put the weight option in [] at the end of the main command
// but before the , and the options, 
// reg y x [aweight=w]
// we use 'aw' or 'aweight',it will in effect multiply each observation by the square root of the weighting variable.
// 'fw':frequency wight,where the weight indicates that the observation
// actually represents several identical observations.
// true sample size is bigger than just the number of rows in the dataset.

// aweights solve the GLS problem where the variance of the error
// is proportional to v
// y = X*beta + epsilon, where u ~ N(0, sigma^2 * v)
// To estimate using WLS we use
// reg y x [aweight=1/v]
// and in effect we are weighting each ob by 1/sqrt(v).
// Observations with a larger variance get a smaller weight.

reg lnTCp3 lnQ lnp1p3 lnp2p3 [aw=output]
// we weight each variable by 1/sqrt(Q).
// the variance of the error is proportional to 1/Q
// (Larger firms have smaller variances.)


** 2. FGLS using a general skedastic fn (Greene,9.7;Wooldridge,8.4)

 // 1.Estimate and obtain squared residuals, then take logs
 
reg lnTCp3 lnQ lnQsq lnp1p3 lnp2p3

predict double ehat if e(sample), res
gen double ehatsq=ehat^2
gen double g=ln(ehatsq)
 // g is the log of ols squared residual.

// 2. skedastic function v(x)_hat
reg g lnQ lnQsq lnp1p3 lnp2p3
redict double ghat if e(sample), xb
capture drop vhat
gen double vhat=exp(ghat)

// 3. regress with weight
reg lnTCp3 lnQ lnQsq lnp1p3 lnp2p3 [aw=1/vhat]







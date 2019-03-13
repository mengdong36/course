
*** 一.关于假设检验的原理

** 1.蒙特卡洛模拟
capture program drop mysim
program define mysim, rclass
	drop _all
	set obs $obs
	gen e = rnormal(0, 2)
	gen x = runiform() - 0.5
	gen y = 1 + 2*x + e
	reg y x
	return scalar b=_coef[x]
	return scalar se = _se[x]
end
global obs = 25
simulate b=r(b) se=r(se), reps(10000): mysim
sum b, detail

//set obs number,x,y,error term.
//rnormal(mean,SD), runiform():[0,1]
//return scalar b:saves estimated slope in an r()macro.
//_coef[x]：saves coefficients of x; _se[x]：saves standard errors.

//H0: true b = 2
//Under H0, z = (b-2)/se should be distrib as t with df = N-K. 
//z统计量为t分布，每个取值都有概率.


** 2.Test size
gen z = (b-2)/se
//10000个b,10000个se,10000个z
//We know that if it's distributed as t with $obs-2 degrees of freedom,
//then 95% of the time z should be between -2.07 and 2.07. 

global CV = invttail($obs-2, 0.025)
//1个critical value，在t分布下，右边面积0.025.
count if z  >   $CV
count if z  <  -$CV
count if z  >  -$CV  &  z  <  $CV

gen p = 2*ttail($obs-2,abs(z))
//10000个p值，在t分布下。
//The Stata function ttail(n,t) is the reverse cumulative distribution function.
//ttail(n,t) = probability that the random variable T > t. 
//This is the area under the PDF to the right of critical value t. 右边的概率

hist p, bin(20) percent
cumul p, gen(cdf_p)
sum cdf_p, detail
line cdf_p p, sort
//看p值得直方图干什么？？

** 3. Test power
capture drop hypoth
gen hypoth = .
capture drop testpower
gen testpower = .
global CV = invttail($obs-2, 0.025)
local row 1
forvalues beta = -4(.05)8 {
	capture drop z
	qui gen z = (b - `beta')/se
	capture drop reject
	qui gen reject = (z < -$CV | z > $CV)
	qui sum reject
	qui replace hypoth = `beta' if _n == `row'
	qui replace testpower = r(mean) if _n == `row'
	local row = `row' + 1
        }
line testpower hypoth, yline(0.05) xline(2)	///
	xlab(-4 -2 0 2 4 6 8)			///
	name(power25, replace) title("N=25")

// '.' replaced later; '|' logical "or"; 'qui' quietly ;local macro `row' `beta'
// Referencing local macro needs `‘ 
// 循环语句'forvalue'.  β starts at -4，incremented by 0.05 each time through the loop, stop at 8.
// hypothesized β∈[-4,8]
// ’sum' the fraction of times we would have rejected z based on the t critical values


*** 二. 参数检验

** test command

reg y x1 x2 x3 x4
test x1+x2+x3 = 1
lincom x1+x2+x3
nlcom 1/_b[x4]
//汇报F statistics; 'test'report two sides test in default; Wald test??
//'lincom'95% confidence interval
//use delta method implemented in 'nlcom'

//'test' produces a Wald test that depends only on the estimate of the
//covariance matrix. Wald tests of simple and composite linear hypotheses about the parameters of the
//most recently fit model.


* Example 1/2: Testing for a single coefficient against zero or other value
test 3.region=0
test 3.region=21
//This result from test is identical to one presented in the output from regress, which indicates
//that the t statistic on the 3.region coefficient is 1.863 and that its significance level is 0.069

* Example 3/4: Testing the equality of two coefficients
test 2.region=4.region
test 2*(2.region-3*(3.region-4.region))=3.region+2.region+6*(4.region-3.region)

* Example 5: Testing joint hypotheses
test (2.region=0) (3.region=0) (4.region=0)

* Example 6: Quickly testing coefficients against zero
test 2.region 3.region 4.region

* Example
 testparm i(2/4).region, equal

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








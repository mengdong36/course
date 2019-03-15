*** heteroskedasticity consistent error
	reg y x, robust
	return scalar se_rob = _se[x]


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







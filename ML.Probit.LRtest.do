
vce(oim)

//second derivatives can sometimes be di¢ cult to derive
//and program, but this is not a problem with standard ML estimators that
//are built in to econometrics packages. This is usually Statas default for
//ML estimators. It can be specied by the option vce(oim) (for "observedinformation matrix")

vce(opg)

//this estimator is easy to calculate; we just need the
//score evaluated at bqML (no need for second derivatives). However, it may
//not perform well in small samples. This can be specied in Stata by the
//option vce(opg) (for "outer product of gradients").


*** probit model
use http://fmwww.bc.edu/ec-p/data/wooldridge/mroz.dta, clear
gen y=(wage<.)
gen youngkids = (kidslt6>0)
replace youngkids=. if kidslt6==.
probit y nwifeinc educ exper age youngkids

*** LR test
probit y nwifeinc educ exper age youngkids
estimates store Full
probit y nwifeinc      exper age youngkids
estimates store Restricted
lrtest Full Restricted

// LR test of whether education is significant.
// Estimate full model, restricted model, and compare LR.



*** Where does the reported log likelihood come from?

// Step 1: Estimate the model
probit y nwifeinc educ exper age youngkids

// Step 2: Use predict to get the predicted value of the latent
// variable.  Just like treating the coefficients as OLS coefficients
// and calculating the predicted value yhat
predict double ystarhat, xb

// Step 3: Contribution of ob i to the likelihood
//         = Normal CDF(y*) if y=1
//         = 1 - Normal CDF(y*) if y=0
gen double Fhat_i = normal(ystarhat) if y==1
replace Fhat_i    = 1 - normal(ystarhat) if y==0

// Step 4: Take logs = contribution of ob i to the log likelihood
gen double logFhat_i = ln(Fhat_i)

// Step 5: Sum of individual contributions to log likelihood
//         = reported total log likelihood
//         and confirm it matches
//         Note that the summarize command doesn't display the sum,
//         but instead it is saved as an r(.) class macro.
//         We say "summarize" instead of "sum" only for clarity.
summarize logFhat_i
di r(sum)
probit y nwifeinc educ exper age youngkids


*** Marginal effect

margins, dydx(*) atmeans post

// IMPORTANT - note the use of the post option of margins.
// “Post” means “store the estimation results”,
// This means that afterwards you can do Wald tests etc. of marginal
// effects by using the test, testparm, etc. commands.
// The atmeans option asks for marginal effects evaluated at the mean
// The * means report marginal effects for every regressor

margins, dydx(*) post

//“Average marginal effect”


probit y nwifeinc educ exper age i.youngkids
margins, dydx(youngkids) atmeans

//Marginal effect of discrete variables
//This means the marginal effect reported by Stata isn’t quite right because 
//youngkids is treated as continuous; it makes no sense to talk about the effect of 
//an infinitesimal increase in this dummy variable.


//Nonelinear estimator marginal effect 
//Margin reports chain rule之后的结果







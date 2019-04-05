
//残差为Euler equation左边
//信息矩阵的任何变量都可以作为工具
//常用工具lagged ct/ct-1 interest rate
//估计discount factor β 和 CRRA 的风险厌恶系数γ

// E { Z * epsilon } = 0
// And the instruments Z can be anything dated t or earlier.
// Note that one instrument can be a constant, meaning that one
// orthogonality condition would be
// E { epsilon } = 0

webuse cr, clear
// Tell Stata that the dataset is time-series
// and qtr is the time variable.
tsset qtr, quarterly
// qtr isn't formatted as quarterly, so fix this:
format qtr %tq

// Generate variables - clearer that way
// F is the Stata forward operator, so this is c(t+1)/c(t)
// as in the lecture notes.
gen Fcc = F.c/c
// And therefore L.Fcc will be c(t)/c(t-1)
// And therefore L2.Fcc will be c(t-1)/c(t-2)

// Satata's gmm estimator works as follows:
// Put parameters to estimate in {}.  We have beta and gamma.
// After "gmm", in (.) put the formula defining ehat (the residual)
// since we are using moment conditions of the form E(z*resid)=0.
// After the comma, list the IVs (the zs) in the "inst" option.
// We use 2 lags of Fcc, current r, and 2 lags of r.
// A constant is AUTOMATICALLY INCLUDED as one of the IVs.
// This gives us 2 + 1 + 2 + 1 = 6 moment conditions.
// After estimating, look at the Hansen-Sargan J statistic.

// Optional: we can provide the starting values for numerical
// optimization along with the parameter to estimator.  Here, we
// expect that the beta should be close to but less than 1, so we
// tell Stata to start at one: {beta=1}
// But we let gamma start at the default of zero: {gamma}

// 2-step FEGMM.
// Estimate using HC Shat - no serial correlation allowed.
// How do you interpret the parameters?
// [Hint: the estimate for beta is not unreasonable,
// but the estimate for gamma is completely crazy.]
// How do you interpret the Hansen-Sargan J statistic?
// [Hint: given the completely crazy estimate for gamma, you
// shouldn't be too surprised by evidence of other problems.]

gmm (1 - {beta=1}*(1+F.r)*(Fcc)^(-1*{gamma})),		///
	inst(L.Fcc L2.Fcc r L.r L2.r)
estat overid


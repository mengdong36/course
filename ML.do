
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

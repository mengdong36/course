
*** Test heteroskedasticity

**1. White test
estat imtest, white

//H0：homoskedasticity
//卡方分布, A vector of constract.

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




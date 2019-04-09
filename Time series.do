*** 时间序列的处理
gen trend =_n  
// t is 1,2,...,_N, a new column vector = time variable
// Stata neeeds the dates to be set up in a way it understands...

gen date=yq(year,quarter)
tsset date, quarterly 
//tells Stata that the data are quarterly time series


regr lgdp trend 
predict fitted /*stores fitted values*/
predict lgdp_xt, residuals /*stores residuals = deviations in lnGDP from trend*/
//被解释变量的去趋势处理

*** ACF 图形
ac lgdp, lags(8) saving(ch1,replace) ylabel(-1(1)1) title("full sample acf for lgdp") 

***自相关系数
ac lgdp, lag(10)
corrgram lgdp, lag(10)

*** 检验sub-sampele的mean是否相同 ttest

ttest lgdp_xta == lgdp_xtb, unpaired unequal
//test of equality of means
//with unequal variance 

*** 检验方差相同
sdtest lgdp_xta == lgdp_xtb
//test for equality of variances

*** ADF 检验/ PP 检验/Elliott 检验

dfuller lgdp, lags(5) trend reg 
dfuller lgdp, lags(4) trend reg 
dfuller lgdp, lags(3) trend reg
dfuller lgdp, lags(2) trend reg
dfuller lgdp, lags(1) trend reg
dfuller lgdp, lags(0) trend reg
dfsummary lgdp, lag(5) t reg

// null hypothesis: lgdp has a unit root, ie. is non-stationary
// alternative hypothesis: lgdp is stationary about a trend
// Augmented Dickey Fuller Tests 
// start with 5 lags in ADF testing regression
// include trend

dfuller dlgdp, lags(4)  reg
//ADF 检验 没有trend

pperron lgdp, trend reg
//Phillips and Perron test, with trend
//Phillips‐Perron (PP) statistics can be viewed as ADF statistics that have been made robust to
//serial correlation by using the Newey–West (1987) heteroskedasticity and autocorrelationconsistent
//covariance matrix estimator.

//There are two advantages of the Phillips and Perron (PP) tests over the ADF tests. First, the
//PP tests are robust to general forms of heteroskedasticity in the error term in the testing
//regression. Second, the user does not have to specify a lag length for the test regression.

//The ADF and PP tests are asymptotically equivalent but may differ substantially in finite
//samples due to the different ways in which they correct for serial correlation in the test regression.

dfgls lgdp, maxlag(5) trend 
//Elliott, Rothenberg and Stock's DF-GLS test, with trend
//For maximum power against very persistent alternatives, the DF‐GLS tests proposed by
//Elliot, Rothenberg and Stock (1996) should be used. These tests are referred to as efficient
//unit root tests since they have been shown to have substantially higher power than the ADF
//or PP unit root tests, especially when φ is close to unity.

//Ng and Perron stress that good size and power properties of the the DF‐GLS unit root tests
//rely on the proper choice of the lag length p used for specifying the test regression. They
//argue, however, that traditional model selection criteria such as AIC and BIC are not well
//suited for determining p with integrated data and suggest a minimising a modified AIC,
//shown as Min MAIC in the table produced by Stata. While it is necessary in Stata to run ADF
//tests for each p separately, the Stata command of the DF‐GLS test conveniently provides a whole set.




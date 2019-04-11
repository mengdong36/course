
*** 建立VAR

var inflation unrate fedfunds if date<=tq(2002q1), lags(1/6)


*** Choosing the number of lags in the VAR:
varsoc inflation unrate fedfunds if date<=tq(2002q1), maxlag(8)
varsoc inflation unrate fedfunds if date<=tq(2002q1), maxlag(8) lutstats

//LR test: H0: set the lag of all variables to zero
//看AIC BIC

quietly var inflation unrate fedfunds if date<=tq(2002q1), lags(1/4)
varlmar, mlag(5)
//Serial Correlation tests help choosing no. of lags the estimated VAR
//检验VAR（4）中残差的序列相关，at maximum of order 5
//H0：No SC at that oder
//不拒绝的越多说明模型越好


*** Diagnostic test 

varwle
varnorm
varstable, graph


*** 格兰因果检验
test [unrate] : L1.inflation L2.inflation L3.inflation L4.inflation L5.inflation L6.inflation
vargranger

//检验的不是因果，检验的是某个变量的历史数据是否对预测另一个变量有贡献
//X是Y的原因，但Y不是X的原因，X在Y的等式中是严格外生的
//H0：Set the lags of one variable in one equation to zero.


*** Prediction

predict f_inflation
predict s_inflation, equation(inflation) stdp

generate l_inflation = f_inflation - 2*s_inflation
generate u_inflation = f_inflation + 2*s_inflation

twoway (rarea u_inflation l_inflation date, fintensity(inten10)) ///
(line inflation f_inflation date, lpattern(solid dash)) in -40/l, yline(0) ///
legend(order(2 3 1) label(1 "95% CI")) name(inflation, replace) 







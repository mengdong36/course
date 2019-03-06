
* 画图
cumul p, gen(cdf_p)
// use'cumul'to create empirical CDF in a variable called cdf_d

line cdf_p p if p<0.20, sort xline(0.05) yline(0.05)
//横轴p,纵轴cdf_p,两条直线x=0.05,y=0.05
//use'sort' option so that p-valuses are plotted in ascending order.

graph twoway	(lfit y x) (scatter y x)	///
	      ,	title("aa") name(aa, replace)
//regress y on x, fitted values & scatter plot, 系统存储图形。连续命令换行。

hist b, bin(20) normal
//b的直方图；bin()：几个方块；覆盖一个normal distri

用forvale列表
forvalues i=1/5 {
	qui reg lnTCp3 lnQ lnp1p3 lnp2p3 if gid==`i'
	di "Group=`i'"					        ///
		_col(20) "beta2=" %6.3f _b[lnQ]			///
		_col(40) "sigma^2=" %6.3f e(rmse)^2		//
}


* 回归
reg
predict yhat, xb
//xb表示fitted value
predict ehat, res
//res表示residuals

use http://fmwww.bc.edu/ec-p/data/hayashi/nerlove63.dta, clear
//Nerlove's return to scale study

* Constraint regression
constraint 1 
constraint 1 x1+x2+x3 =1
cnsreg y x1 x2 x3, constraint(1)

* Frish-Wangh-Lovell theorem
reg y x1 x2
avlop x2
//1. regress y on x1, collect residuals,y_tilde
//2. regress x2 on x1, collect residuals x2_tilde
//3. regress y_tilda on x2_tilde
//Parcial out x1, uninterested 

* Variables
sort var
//变量值从小到大

gen gid=ceil(_n/10)
//对Var分为10组; _n: current number of observations; ceil(.): rounds up

gen double var
//变量值双精度

ereturn list
//list all saved estimation results; e(mss): saved model sum of squares; e(rss):residual sum of squares.

predict resid, resid
//把residuals提取出来

* Dummy variables/ IV 
gen gid=ceil(_n/30)
label var gid	"group identifier"
cap drop D*
xi i.gid, prefix(D) noomit
xi i.gid|x1 i.gid|x2 i.gid|x3, prefix(D) noomit
desc D*
sum D*
//creates dummies called Dgid_1, Dgid_2, .. based on our group id variable gid. 
//The noomit option says create all possible dummies and don’t omit the base category
//To create interactions. The | operator says create only interactions between the indicator variable and the continuous variable 
//(if we used the *operator instead, it would create the level dummies but we already have those from theprevious command).
reg y ibn.gid ibn.gid#c.(x1 x2 x3), nocons
//group regression in one single system
























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


*回归
reg
predict yhat, xb
//xb表示fitted value
predict ehat, res
//res表示residuals


* Frish-Wangh-Lovell theorem
reg y x1 x2
avlop x2
//1. regress y on x1, collect residuals,y_tilde
//2. regress x2 on x1, collect residuals x2_tilde
//3. regress y_tilda on x2_tilde
//Parcial out x1, uninterested 


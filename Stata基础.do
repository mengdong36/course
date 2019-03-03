
* 画图
line cdf_p p if p<0.20, sort xline(0.05) yline(0.05)
//横轴p,纵轴cdf_p,两条直线x=0.05,y=0.05

graph twoway	(lfit y x) (scatter y x)	///
				      ,	title("aa") name(aa, replace)
//连续命令换行。regress y on x, fitted values & scatter plot, 系统存储图形。




*回归
reg
predict yhat, xb
//xb表示fitted value
predict ehat, res
//res表示residuals

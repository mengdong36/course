
* 一.关于假设检验的原理

* 1.蒙特卡洛模拟
capture program drop mysim
program define mysim, rclass
	drop _all
	set obs $obs
	gen e = rnormal(0, 2)
	gen x = runiform() - 0.5
	gen y = 1 + 2*x + e
	reg y x
	return scalar b=_coef[x]
	return scalar se = _se[x]
end
global obs = 25
simulate b=r(b) se=r(se), reps(1000): mysim
sum b, detail

//H0: true b = 2
//Under H0, z = (b-2)/se should be distrib as t with df = N-K. 
//z统计量为t分布，每个取值都有概率

gen z = (b-2)/se
//10000个b,10000个se,10000个z
//We know that if it's distributed as t with 23 degrees of freedom,
//then 95% of the time z should be between -2.07 and 2.07. 

gen p = 2*ttail(23,abs(z))
//10000个p值，在t分布下。
//The Stata function ttail(n,t) is the reverse cumulative distribution function
//ttail(n,t) = probability that the random variable T > t. 
//This is the area under the PDF to the right of critical value t. 右边的概率

global CV = invttail($obs-2, 0.025)
//1个critical value，在t分布下，右边面积0.025.



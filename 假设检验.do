
*** 一.关于假设检验的原理

** 1.蒙特卡洛模拟
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
simulate b=r(b) se=r(se), reps(10000): mysim
sum b, detail

//set obs number,x,y,error term.
//rnormal(mean,SD), runiform():[0,1]
//return scalar b:saves estimated slope in an r()macro.
//_coef[x]：saves coefficients of x; _se[x]：saves standard errors.

//H0: true b = 2
//Under H0, z = (b-2)/se should be distrib as t with df = N-K. 
//z统计量为t分布，每个取值都有概率.


** 2.Test size
gen z = (b-2)/se
//10000个b,10000个se,10000个z
//We know that if it's distributed as t with $obs-2 degrees of freedom,
//then 95% of the time z should be between -2.07 and 2.07. 

global CV = invttail($obs-2, 0.025)
//1个critical value，在t分布下，右边面积0.025.
count if z  >   $CV
count if z  <  -$CV
count if z  >  -$CV  &  z  <  $CV

gen p = 2*ttail($obs-2,abs(z))
//10000个p值，在t分布下。
//The Stata function ttail(n,t) is the reverse cumulative distribution function.
//ttail(n,t) = probability that the random variable T > t. 
//This is the area under the PDF to the right of critical value t. 右边的概率

hist p, bin(20) percent
cumul p, gen(cdf_p)
sum cdf_p, detail
line cdf_p p, sort
//看p值得直方图干什么？？

** 3. Test power
capture drop hypoth
gen hypoth = .
capture drop testpower
gen testpower = .
global CV = invttail($obs-2, 0.025)
local row 1
forvalues beta = -4(.05)8 {
	capture drop z
	qui gen z = (b - `beta')/se
	capture drop reject
	qui gen reject = (z < -$CV | z > $CV)
	qui sum reject
	qui replace hypoth = `beta' if _n == `row'
	qui replace testpower = r(mean) if _n == `row'
	local row = `row' + 1
        }
line testpower hypoth, yline(0.05) xline(2)	///
	xlab(-4 -2 0 2 4 6 8)			///
	name(power25, replace) title("N=25")

// '.' replaced later; '|' logical "or"; 'qui' quietly ;local macro `row' `beta'
// Referencing local macro needs `‘ 
// 循环语句'forvalue'.  β starts at -4，incremented by 0.05 each time through the loop, stop at 8.
// hypothesized β∈[-4,8]
// ’sum' the fraction of times we would have rejected z based on the t critical values


*** 二. 参数检验

** Jointing test

reg y x1 x2 x3 x4
test x1+x2+x3 = 1
lincom x1+x2+x3
nlcom 1/_b[x4]
//汇报F statistics; 'test'report two sides test in default; Wald test??
//'lincom'95% confidence interval
//use delta method implemented in 'nlcom'


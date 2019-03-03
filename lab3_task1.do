capture cd M:\Econometrics\Lab3

use wine, clear

drop if country=="Freedonia"

reg liver alcohol

graph twoway	(lfit liver alcohol)		///
				(scatter liver alcohol)

reg liver alcohol europe


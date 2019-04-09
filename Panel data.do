***(Dynamic) Panel data 
** 1. preparation 
ssc install center, replace
ssc install xtabond2, replace
ssc install ivreg2, replace
ssc install ranktest, replace
//The basic Stata static panel data estimator is xtreg. It will estimate FE, BE and RE models. 
//To estimate using POLS or FD, use regress.

webuse psidextract, clear
//US Panel Study of Income Dynamics (PSID)
//examined how various panel data IV-type estimators performed in estimating a wage equation 
//with a particular focus on the return to education
//stydy error components structure

xtset id t
//set panel with id as the panel id and t as the time variable

** 2. within and group-mean transformation
reg lwage ed exp union
reg lwage ed exp union t

by id: center lwage ed exp union t, prefix(dm_) meansave double
//use 'center' generate m_lwage dm_lwage..
//Variables prefixed with m_ are group means; variables prefixed with dm_ are demeaned. 


xtset
// Check that the dataset is already set to be a panel

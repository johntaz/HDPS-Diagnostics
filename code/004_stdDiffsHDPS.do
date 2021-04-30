****************************************************************
*
*	Do-file:		004_stdDiffsHDPS.do
*
*	Author: 		John Tazare
*
*	Date:			21/04/2021
*
*	Description:    Absolute standardised differences 
*					between unweighted and HDPS weighted sample 
*					under the primary analysis, selecting the 
*					top 500 HDPS covariates. 
*
*****************************************************************

global data "insert-path-to-data"
global output "insert-path-to-output"

*****************************************************************
* Required variables:
*****************************************************************
* stddiff_unwt - absolute standardised difference in unweighted
*			     population
* stddiff_wt   - absolute standardised difference in weighted
*			   	 population (top 500 covariates)

* Load dataset with std diffs
use "$data/stdDiffsHDPS.dta", clear

* Keep top 500 HDPS covariates
keep if rank <=500 

* Data manipulation
gen dim=substr(code_id,1,2)
encode dim, gen(dim2)

*****************************************************************
* Plot
*****************************************************************

#delimit ;
twoway 
	// Plot unweighted vs weighted absolute standardised diff.
	(scatter stddiff_unwt stddiff_wt,
		msymbol(circle) mcolor(navy%70) msize(tiny))
		,
		xlabel(0(2)10, value angle(0) labsize(small))	 
		xtitle("ASD in HDPS weighted population (%)")  
		ytitle("ASD in unweighted population (%)")	
		ylabel(0 (10) 130, labsize(small) angle(0))	
		xscale(range(0 11) extend)	
		plotregion(color(white))
		scheme(uncluttered ) 
		graphregion(color(white))
		legend(off)
	 // 10% absolute standardised diff. lines
		yline(10, lwidth(thin) lpattern(dash) lcolor(black))  
		xline(10, lwidth(thin) lpattern(dash) lcolor(black))  

			;
#delimit cr
graph export "$output/stdDiffsHDPS.png", width(2000) replace


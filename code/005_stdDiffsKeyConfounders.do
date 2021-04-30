****************************************************************
*
*	Do-file:		005_stdDiffsKeyConfounders.do
*
*	Author: 		John Tazare
*
*	Date:			21/04/2021
*
*	Description:    absolute standardised differences in a set 
*					of key covariates between unweighted, 
*					pre-defined covariate weighted, and 
*					pre-defined and HDPS covariate weighted 
*					samples
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
*			   	 population (by pre-defined model)
* stddiff_wt_X - absolute standardised difference in weighted
*			   	 population (by pre-defined + X HDPS covariates 
*				 model)

* Load dataset with stddiffs
use "$data/stdDiffsHDPS.dta", clear

* Data management
gen order = 10 - (_n) + 1

* Create offset for unweighted and pre-defined weighted popns.
gen orderOffset = order + 0.3 

* Label variables
label define orderLab	///
	10  "Age"		///
	9  "Gender"		///
	8  "Diabetes"	///
	7  "Alcohol"	///
	6  "BMI"		///
	5  "Cancer"		///
	4  "Smoke"		///
	3  "PVD"		///
	2  "CHD"		///
	1 "Stroke"
label values order orderLab
label values orderOffset orderLab

*****************************************************************
* Plot
*****************************************************************

#delimit ;
graph twoway 
	// Unweighted absolute standardised diff.
   (scatter orderOffset stddiff_unwt,
	msymbol(circle) mcolor(black%70))
   	// Pre-defined weighted absolute standardised diff.
   (scatter orderOffset stddiff_wt, 
    msymbol(D) mcolor(black%70)) 
   	// Top 250 HDPS weighted absolute standardised diff.
   (scatter order stddiff_wt_250, 
	msymbol(triangle) mcolor(blue%70)) 
	// Top 500 HDPS weighted absolute standardised diff.
   (scatter order stddiff_wt_500, 
	msymbol(triangle) mcolor(red%70)) 
	// Top 750 HDPS weighted absolute standardised diff.
   (scatter order stddiff_wt_750, 
	msymbol(triangle) mcolor(green%70)) 
   , 
	ylabel(1(1)10, value angle(0) labsize(small))	
	ytitle("") 
	xtitle("Absolute standardised difference (%)")	
	xlabel(0 (5) 15, labsize(small))	
	xscale(range(0 15))
	xline(10, lwidth(thin) lpattern(dash) lcolor(black))  
	xline(0, lpattern(dash) lwidth(thin) lcolor(black)) 
	plotregion(color(white))
	scheme(uncluttered ) 
	graphregion(color(white))
	legend(
		order(1 "Unweighted" 2 "Pre-defined" 3 "HDPS 250" ///
			  4 "HDPS 500" 5 "HDPS 750")
		title("Weighting",size(small) col(black))
		cols(1)
		rows(5)
		pos(5)
		ring(0)
		symxsize(*0.4)
		size(small)
		)
	;
#delimit cr
graph export "$output/stdDiffs.png", width(2000) replace

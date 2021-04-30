****************************************************************
*
*	Do-file:		006_stdDiffsPredefinedPlusHDPSs.do
*
*	Author: 		John Tazare
*
*	Date:			21/04/2021
*
*	Description:    absolute standardised differences in 
*					pre-defined and top 250 HDPS covariates
*					between unweighted, pre-defined and HDPS 
*					(+500 covariates) weighted samples 
*
*****************************************************************

global data "insert-path-to-data"
global output "insert-path-to-output"

*****************************************************************
* Required variables:
*****************************************************************
* stddiff_unwt   - absolute standardised difference in unweighted
*			       population
* stddiff_wt   	 - absolute standardised difference in weighted
*			   	   population (pre-defined only)
* stddiff_wt_500 - absolute standardised difference in weighted
*			   	   population (pre-defined plus top 500 HDPS)
* rank 			 - HDPS bross-prioritised rank; negative values
*				   given to pre-defined variables for plotting 
*				   purposes

* Load dataset with bias information
use "$data/stdDiffsTop250.dta", clear
	
*****************************************************************
* Plot
*****************************************************************
#delimit ;
graph twoway 
	// Unweighted absolute standardised diff.
	(scatter stddiff_unwt rank ,
		msymbol(circle) mcolor(black%70) msize(tiny))
   	// Pre-defined weighted absolute standardised diff.
	(scatter stddiff_wt rank , 
		msymbol(D) mcolor(blue%70) msize(tiny)) 
	// Top 500 HDPS weighted absolute standardised diff.
	(scatter stddiff_wt_500 rank, 
		msymbol(triangle) mcolor(red%70) msize(tiny)) 	
	,
	xlabel(-60 "Gender"  -54 "Age"  -48 "Diabetes" 
		   -42 "Cancer"  -36 "CHD"  -30 "PVD"
           -24 "Stroke"  -18 "BMI"  -12 "Smoke" 
		   -6 "Alcohol" 0 "0" 50 "50" 100 "100" 
		   150 "150" 200 "200" 250 "250", 
		   angle(45) labsize(vsmall)
		   )
	xtitle("Rank of empirically selected covariates" )  
	ytitle("Absolute standardised difference (%)")	
	ylabel(0 (10) 130, labsize(small))	
	yscale(reverse extend range(-5 135))
	yline(10, lwidth(thin) lpattern(dash) lcolor(black))  
	yline(0, lpattern(dash) lwidth(thin) lcolor(black)) 
	xline(-0.5, lpattern(dash) lwidth(thin) lcolor(black)) 
	plotregion(color(white))
	scheme(uncluttered ) 
	graphregion(color(white))
	legend(
		  order(1 "Unweighted" 2 "Predefined" 3 "HDPS 500")
		  title("Weighting",size(small) col(black))
		  cols(1)
		  rows(5)
		  pos(5)
	      ring(0)
		  symxsize(*0.4)
		  size(small)
		  )
	 text( -10 -32  "Pre-defined covariates", size(*0.7))
	 text( -10 130 "Top 250 HDPS covariates", size(*0.7))
	;
#delimit cr
* manually fix labels
graph export "$output/stdDiffs_top250.png", width(2000) replace


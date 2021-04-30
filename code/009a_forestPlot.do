****************************************************************
*
*	Do-file:		009a_forestPlot.do
*
*	Author: 		John Tazare
*
*	Date:			21/04/2021
*
*	Description:    Forest plot for sensitivity analysis 
*					assessing the impact of the number of 
*					HDPS covariates selected 
*					
*   Note:           Propensity scores were estimated using 
*					logistic regression and treatment effects 
*					were estimated using an inverse probability 
*					of treatment weighted Cox model.
*
*****************************************************************

global data "insert-path-to-data"
global output "insert-path-to-output"

*****************************************************************
* Required variables:
*****************************************************************
* lhr 	- Log hazard ratio /effect estimate		    
* llci  - Log lower confidence interval limit
* luci	- Log upper confidence interval limit

clear all 
use "$data/resultsHDPS.dta", replace

* Data management 
gen order=1 if _n==1
replace order=4 if _n==2
replace order=7 if _n==3
replace order=10 if _n==4
replace order=13 if _n==5
replace order=16 if _n==6
replace order=19 if _n==7
replace order=22 if _n==8
replace order=25 if _n==9
replace order=28 if _n==10
replace order = order - 6 if order > 4

* Label the analyses
label define orderLab 1 "Crude" 4 "Pre-defined" 7 "HDPS 500" ///
10 "HDPS 100" 13 "HDPS 250" 16 "HDPS 750" 
label values order orderLab


*****************************************************************
* Plot
*****************************************************************
#delimit ;
graph twoway
	// Plot crude estimate / confidence interval
	(connected lhr order if order==1, 				 
		mcol(cranberry) lcol(cranberry) 
		msize(medium) msymbol(square))

	(rspike llci luci order if order==1, 				
		lcol(cranberry)) 
		
	// Plot pre-defined estimate / confidence interval
	(connected lhr order if order==4, 			
		mcol(cranberry) lcol(cranberry)  
		msize(medium) msymbol(square))
	
	(rspike llci luci order if order==4, 	
		lcol(cranberry)) 			 
	
	// Plot HDPS 500 estimate / confidence interval
	(scatter lhr order if order==7, 			 
		mcol(cranberry) lcol(cranberry)  
		msize(medium) msymbol(square))

	(rspike llci luci order if order==7, 	
		lcol(cranberry)) 		
	
	// Plot HDPS 100,250,750 estimates / confidence intervals
	(scatter lhr order if order<=16 & order>=10, 				
		mcol(cranberry) lcol(cranberry)  
		msize(medium) msymbol(square))

	(rspike llci luci order if order<=16 & order>=10, 				 
		lcol(cranberry)) 
	, 
	
	ytitle("Log Effect Estimate (95% CI)" )
	ylabel(-0.3(0.1)0.4, 
		labsize(medsmall) angle(horizontal))
	xtitle("Analysis" , margin(t+2) )
	xlabel(1(3)17.8, 
	labsize(small) valuelabel angle(45))
	xscale(  range(0.5 17.8) ) 
	yscale(  range(-0.3 0.5) ) 
	legend(off)
	plotregion(color(white))
	scheme(uncluttered ) 
	graphregion(color(white))
	// Add null value line
	yline(0, lcol(black) lpattern(solid) lwidth(thin))
	// Add vertical separators
	xline(8.5, lpattern(dash) lwidth(thin) lcol(black))
	xline(17.5, lpattern(dash) lwidth(thin) lcol(black))
 ;
#delimit cr
graph export "$output/simpleForestPlot.png", width(2000) replace

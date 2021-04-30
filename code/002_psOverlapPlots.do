****************************************************************
*
*	Do-file:		002_psOverlap.do
*
*	Author: 		John Tazare
*
*	Date:			21/04/2021
*
*	Description:    Overlap plot comparing the propensity score 
*					distirbutions under the following models:
*					1) pre-defined 
*					2) pre-defined + top 500 HDPS covariates 
*					   ranked by Bross
*
*****************************************************************

global data "insert-path-to-data"
global output "insert-path-to-output"

*****************************************************************
* 1) Pre-defined propensity score
*****************************************************************
* Note: 'ppi' is the treatment indicator variable 

* Load cohort dataset
use "$data/cohort", replace
 
* Macro containing model specification
local model age_baseline i.gender i.smoke i.bmicat i.alcohol /// 
		i.diabetes i.pvd i.chd i.stroke i.cancer 

* Logistic regression to estimate propensity score 
logit ppi `model' , or

* Predict probabilities
predict pscore, pr 

* Plot kdensitys
gen ppi2 = ppi+1
forvalues i=1/2 {
      capture drop x`i' d`i'
      kdensity pscore if ppi2== `i', generate(x`i'  d`i')
  }

gen zero= 0

* Combine for propensity score distribution under this model
#delimit ;
twoway rarea d1 zero x1, color("blue%30") 
		||  rarea d2 zero x2, color("green%30") 
		ytitle("")
		xtitle("") 
		ylabel(0(2)8, labsize(medsmall) )
		xlabel(0(0.1)1, labsize(medsmall))
		legend(off)    
		plotregion(color(white))
		scheme(uncluttered ) 
		graphregion(color(white))
		name(investigator, replace)
		title("Pre-defined", 
			box 
			bexpand 
			bcol(none)
			lcol(black) 
			size(medsmall)
			)
	;
#delimit cr		

*****************************************************************
* 2) Pre-defined + HDPS covariates propensity score
*****************************************************************

* Load cohort containing top 500 HDPS covariates 
use "$data/HDPS_cohort.dta", clear

set matsize 600 // increase matsize for large models

* Logistic regression to estimate propensity score using both 
* pre-defined and HDPS covariates 

logit ppi `model' d1* d2* d3* , or 
* Note: `model' is the same as defined above. d1* d2* d3* 
* are the 500 HDPS covariates 

* Follow previous steps

predict pscore, pr 

gen ppi2 = ppi+1
forvalues i=1/2 {
      capture drop x`i' d`i'
      kdensity pscore if ppi2== `i', generate(x`i'  d`i')
  }

gen zero = 0

#delimit ;
twoway rarea d1 zero x1, color("blue%30") 
		||  rarea d2 zero x2, color("green%30") 
		ytitle("")
		yla(, notick labcol(white)) 
		yscale(lstyle(none))
		xlabel(0(0.1)1, labsize(medsmall))
		xtitle("")
    	legend(
			ring(0) 
			pos(2) 
			col(1) 
			order( 1 "PPI users" 2 "Non-PPI users") 
			region(lcolor(white)) size(medsmall)
			)  
		plotregion(color(white))
		scheme(uncluttered ) 
		graphregion(color(white))
		title("HDPS", box 
		bexpand 
		bcol(none) 
		lcol(black) 
		size(medsmall))
		name(hdps, replace)
	;
#delimit cr

*****************************************************************
* Combine the overlap plots
*****************************************************************

#delimit ;
graph combine investigator hdps,
		ycommon 
		xcommon 
		rows(1) 
		plotregion(color(white)) 
		graphregion(color(white))  
		l1(Density, size(medsmall)) 
		b1(Probability of receiving therapy, size(medsmall))
		ysize(1)
		xsize(2)
		iscale(1)
		imargin(0 0 0 0)				
	;
#delimit cr

graph export "$output/combinedOverlap.png", replace width(2000)

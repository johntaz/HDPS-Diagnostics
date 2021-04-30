****************************************************************
*
*	Do-file:		009b_intensiveForestPlot.do
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
* Generic procedure for obtaining effect estimates from
* incrementally adding HDPS covariates to pre-defined model
*****************************************************************
tempname effectEsts

* Create a postfile to 'post' the number of variables added 
* effect estimates and 95% CI bounds
postfile `effectEsts' numVars hr lci uci  /// 
		using "intensivePlots.dta", replace


forvalues i = 1/750 { 

if mod(`i', 10) == 0 { 
noi di " Fitting model `i' out of 750" 
}

qui {

* Load dataset with bias information
use "$data/bias_info.dta", clear
gsort - abs_log_bias // sort by ranking metric
keep if rank <= `i' // keep the top `i' codes
qui levelsof code_id, local(final_selection)

* Load overall cohort with HDPS covariates 
use "$data/hdpsCohort.dta", replace

* Pre-defined model specification
local model age_baseline i.gender i.smoke i.bmicat /// 
	i.alcohol i.diabetes i.pvd i.chd i.stroke i.cancer 

* Add the selected HDPS covariates to this model
foreach item of local final_selection {
    local model `model' `item'
}

* Fit propensity score modoel 
logit ppi `model' , or

* Drop any previous pscore/weights
cap drop pscore 
cap drop wt

predict pscore, pr 

* Generate IPTW weights
gen wt=1/pscore if ppi==1 
replace wt=1/(1-pscore) if ppi==0

* Fit outcome model 
#delimit ;
stset exit_t [pw=wt], 
		origin(dob) 
		fail(inc_mi) 
		id(anonpatid) 
		enter(entry_t)   
		scale(365.25)
		; 
#delimit cr

stcox i.ppi, vce(robust)

* Capture and 'post' the HR and 95% CI limits
mat def A = r(table)
local hr = A[1,2]
local lci = A[5,2]
local uci = A[6,2]
post `effectEsts' (`i') (`hr') (`lci') (`uci')

}
	}	
postclose `effectEsts' 

clear 

* Load postfile with effect estimates
use "intensivePlots.dta", replace

* Transform effect estimates
gen llci = log(lci)
gen luci = log(uci)
gen lhr  = log(hr)

*****************************************************************
* Plot
*****************************************************************
 #delimit ;
twoway
 // Plot effect estimates
 (line lhr numVars, lwidth(medium) color(navy*1.2))
	
 // Plot confidence interval bounds
 (rarea llci luci numVars, color(blue%20)) 
 , 
  ytitle("log(Effect Estimate)" )
  ylabel(-0.4(0.2)0.4,  labsize(medsmall)  angle(horizontal))
  xtitle("Number of empirically selected HDPS covariates added")
  xlabel(0(100)750, labsize(medsmall) )
  legend(off)
  yline(0, lcol(black) lpattern(solid) lwidth(thin))
  plotregion(color(white))
  scheme(uncluttered ) 
  graphregion(color(white))
;
#delimit cr
graph export "$output/incremForestPlot.png", width(2000) replace


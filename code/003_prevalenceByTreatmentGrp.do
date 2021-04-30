****************************************************************
*
*	Do-file:		003_prevalenceByTreatmentGrp.do
*
*	Author: 		John Tazare
*
*	Date:			21/04/2021
*
*	Description:    Prevalence of the top 500 bross-prioritised 
* 					HDPS covariates by treatment group 
*
*****************************************************************

global data "insert-path-to-data"
global output "insert-path-to-output"

*****************************************************************
* Required variables:
*****************************************************************
* pc0 	- prevalence of confounder in Drug A group
* pc1 	- prevalence of confounder in Drug B group
* rank 	- bross-derived ranking
* dim 	- data dimension identifier (optional)

* Load dataset with bias information
use "$data/bias_info.dta", clear

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
	// Clinical dimension plot
	(scatter pc1 pc0 if dim2 ==1, 
		msize(small) msymbol(circle) mcolor(green%70))
	// Referral dimension plot	
	(scatter pc1 pc0 if dim2 ==2,
		msize(small) msymbol(circle) mcolor(blue%50)) 
	// Therapy dimension plot	
	(scatter pc1 pc0 if dim2 ==3, 
		msize(small) msymbol(circle) mcolor(orange%50)) 
	// Prevalence ratio = 0.5
	(function y=x/2, lcol(black*0.8) clpat(dash) range(0 1)) 
	// Prevalence ratio = 2.0
	(function y=2*x, lcol(black*0.8) clpat(dash) range(0 0.5)) 
	// Prevalence ratio = 1
	(function y=x, lcol(black*0.8)) 
		,
	   ytitle("Prevalence in PPI users" )  
	   xtitle("Prevalence in non-PPI users" ) 
	   ylabel(,angle(horizontal))
	   ylabel(0(0.2)1, labsize(medsmall) angle(horizontal))  
	   legend(
			order(1 "Clinical" 2 "Referral" 3 "Prescriptions")
			title("Data Dimensions",size(small))
			cols(1)
			rows(3)
			pos(4)
			ring(0)
			symxsize(*0.4)
			size(small)
	) 
	   plotregion(color(white))
	   graphregion(color(white))
	   name(prev, replace)
	// Prevalence ratio labels   
	   text(0.97 0.54  "PR = 2.0" , size(*0.9))
	   text(0.44 0.97  "PR = 0.5" , size(*0.9)) 
;
#delimit cr

graph export "$output/prevPlot.png", width(2000)  replace

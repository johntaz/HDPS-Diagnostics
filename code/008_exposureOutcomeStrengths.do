****************************************************************
*
*	Do-file:		008_exposureOutcomeStrengths.do
*
*	Author: 		John Tazare
*
*	Date:			21/04/2021
*
*	Description:    Comparison of the covariate-exposure and 
*					covariate-outcome associations for the 
*					top 500 HDPS covariates
*
*****************************************************************

global data "insert-path-to-data"
global output "insert-path-to-output"

*****************************************************************
* Required variables:
*****************************************************************
* ce_strength - covariate-exposure strength
* cd_strength - covariate-outcome strength
* rank		  - bross-derived ranking
* dim		  - data dimension identifier (optional)

* Load dataset with bias information
use "$data/bias_info.dta", clear

* Keep top 500 HDPS covariates
keep if rank <= 500 

* Data manipulation
gen dim=substr(code_id,1,2)
encode dim, gen(dim2)

*****************************************************************
* Plot
*****************************************************************
#delimit ;
twoway // Clinical dimension plot
	   (scatter ce_strength cd_strength if dim2 ==1, 
			msize(small) msymbol(circle) mcolor(green%70))
	   // Referral dimension plot
	   (scatter ce_strength cd_strength if dim2 ==2, 
			msize(small)  msymbol(circle) mcolor(blue%50)) 
	   // Therapy dimension plot
	   (scatter ce_strength cd_strength if dim2 ==3, 
			msize(small)  msymbol(circle) mcolor(orange%50))
	   , 
	   ytitle("Strength of confounder-exposure association")  
	   xlabel(0 0.1 0.2 0.5 1.0 2 3, 
			labsize(medsmall) angle(horizontal)
			)  
	   xscale(log)
	   xtitle("Strength of confounder-outcome association") 
	   ylabel(0 0.1 0.2 0.5 1.0  2 4 8, 
			labsize(medsmall) angle(horizontal)
			)  
	   yscale(log)
	   legend(
			order(1 "Clinical" 2 "Referral" 3 "Therapy")
			title("Data Dimensions",size(small))
			cols(1)
			rows(3)
			pos(7)
			ring(0)
			symxsize(*0.4)
			size(small)
		  ) 
	    plotregion(color(white))
	    scheme(uncluttered ) 
	    graphregion(color(white))
	    name(strength, replace)
;
#delimit cr

graph export "$output/empiricalIV.png", width(2000) replace

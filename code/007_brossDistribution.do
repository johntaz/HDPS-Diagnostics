****************************************************************
*
*	Do-file:		007_brossDistribution.do
*
*	Author: 		John Tazare
*
*	Date:			21/04/2021
*
*	Description:    Distribution of absolute log Bross bias 
*					values for each of the top 500 HDPS 
*					covariates 
*
*****************************************************************

global data "insert-path-to-data"
global output "insert-path-to-output"

*****************************************************************
* Required variables:
*****************************************************************
* abs_log_bias - bross ranking value
* rank - bross-derived ranking
* dim - data dimension identifier 

* Load dataset with bias information
use "$data/bias_info.dta", clear

* Data manipulation
gen dim=substr(code_id,1,2)
encode dim, gen(dim2)

* Label dimensions
label define dimLab 1 "Clinical" 2 "Referral" 3 "Prescription"
label values dim2 dimLab

* Generate counts of codes by dimensions
count if dim2 == 1 // clinical
local dim1 = round(`r(N)'/500*100, 1.0)

count if dim2 == 2 // referral
local dim2 = round(`r(N)'/500*100, 1.0)

count if dim2 == 3 // therapy
local dim3 = round(`r(N)'/500*100, 1.0)

*****************************************************************
* Plot
*****************************************************************
#delimit ;
twoway 
	 // Clinical dimension plot
	(bar abs_log_bias rank if rank<=500 & dim2==1,  
		 lwidth(vthin) color(blue%40) )
	 // Referral dimension plot
	(bar abs_log_bias rank if rank<=500 & dim2==2,  
		 lwidth(vthin) color(red%40)) 
	 // Therapy dimension plot
	(bar abs_log_bias rank if rank<=500 & dim2==3,  
		 lwidth(vthin) color(green%40)) 
			,
	ytitle("|log(bias)|" )
	ylabel(0(0.05)0.15, labsize(medsmall) angle(horizontal))
	xtitle("Rank of empirically selected covariates" )
	xlabel(0(100)500, labsize(medsmall))
	legend(
	order(1 "Clinical (`dim1'%)" 
		  2 "Referral (`dim2'%)"
		  3 "Therapy (`dim3'%)"
		   )
	title("Data Dimension (% of top 500)",
		  size(small) col(black)
		  )
		  cols(1)
		  symxsize(*0.4)
		  size(small)
		  pos(2)
		  ring(0)
		)
	 plotregion(color(white))
	 scheme(uncluttered ) 
	 graphregion(color(white))
	 name(bross, replace)
;
#delimit cr

graph export "$output/brossDistribution.png", width(2000) replace

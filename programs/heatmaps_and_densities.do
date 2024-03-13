

**************************************************************************************
* 
/*

	This script produces tile maps for number of establishment, and firms 
	in the early (1982), late(2015), and diff and 
	exports the figures in a format that can be placed 
	into a sectioned lyx/latex file

*/ 
***************************** Preliminaries ************************************
 

* begin by clearing the workspace
clear all 

* clear the output window
cls

* close any open log files
capture log close	  

* tell Stata not to stop for long output lines 
set more off 

* figures require maptile and cleanplots packages
cap which maptile
if _rc != 0 {
	disp "maptile package needs to be installed. enter 1 to install", _request(ans)
	if "$ans" == "1" {
		ssc install maptile
		}
	else {
		disp "maptile is not installed. do file cannot create maptile plots"
	}
	
}
cap set scheme cleanplots
if _rc != 0 {
	disp "cleanplots package needs to be installed. enter 1 to install", _request(ans)
	if "$ans" == "1" {
		ssc install cleanplots
		}
	else {
		disp "cleanplots package scheme not installed. do file cannot apply cleanplot scheme"
	}
}


************************** End Preliminaries ***********************************

************************** Figures Heatmaps Pass-Through Shares ***********************************
* Figures D.2a-Dc.

* Import data from Excel file
import excel "../data/restricted/disclosed/req10739_20230720/disclosure_output_post.xlsx", sheet("heatmap_state_T13T26") cellrange(A1:C52) firstrow clear 

* List all double variables
qui: ds, has(type double)

* Create percentages
foreach v of var `r(varlist)' { 
	qui: replace `v' = 100*`v'
} 

* generate difference in passthrough shares
gen diff = late - early
label var diff "diff"

* load the hex map for the US states
maptile_install using "http://files.michaelstepner.com/geo_statehex.zip", replace


* Figures D2a, D2b and D2c:

maptile early, geo(statehex) geoid(state) labelhex() fcolor(GnBu) cutvalues(40(10)80)  twopt(name("early")) legdecimals(1)
	
graph export "../output/figures/fig_d2a_passthrough_share_early.eps", as(eps) replace

maptile late, geo(statehex) geoid(state) labelhex() fcolor(GnBu) cutvalues(40(10)80)  twopt(name("late")) legdecimals(1)
	
graph export "../output/figures/fig_d2b_passthrough_share_late.eps", as(eps) replace

maptile diff, geo(statehex) geoid(state) labelhex() fcolor(GnBu) nq(6)  twopt(name("diff")) legdecimals(1)
	
graph export "../output/figures/fig_d2c_passthrough_share_diff.eps", as(eps) replace


************************** End Figures Heatmaps Pass-Through Shares ***********************************

************************** Figures Heatmaps Establishment Shares **************************************
* Figures D.3a-3c.

* Import data from csv file
import delimited "../data/bds/bds2020_st.csv", clear 

* Merge with the state code book, generated by inputing
merge m:1 st using "../data/crosswalk/state_codebook.dta"
drop _merge
order year state firms estabs emp
keep year state firms estabs emp

* Keep only interested years - 1982, 2015
keep if year == 1982 | year ==2015
sort year state

* Compute shares
** Compute the total
foreach var in firms estabs emp{
	bysort year: egen total_`var' = sum(`var')
}

** Compute the shares by dividing the totals
foreach var in firms estabs emp{
	gen `var'_share = `var' / total_`var'
	replace `var'_share = 100 * `var'_share
}

* Keep only the shares
keep state year *share
order state year

* Reshape to wide to graph
reshape wide *share, j(year) i(state)

* generate difference in each shares
foreach var in firms estabs emp{
	gen `var'_sharediff = `var'_share2015 - `var'_share1982
	label var `var'_sharediff "diff_`var'"
}

*rename to automate graphing
rename *1982 *early
rename *2015 *late

* Figures D3a, D3b and D3c:

maptile estabs_shareearly, geo(statehex) geoid(state) labelhex() fcolor(GnBu) cutvalues(0.5(2)10) twopt(name("estabs_shareearly")) legdecimals(1)
		
graph export "../output/figures/fig_d3a_sharebus_early.eps", as(eps) replace

maptile estabs_sharelate, geo(statehex) geoid(state) labelhex() fcolor(GnBu) cutvalues(0.5(2)10) twopt(name("estabs_sharelate")) legdecimals(1)
		
graph export "../output/figures/fig_d3b_sharebus_late.eps", as(eps) replace

maptile estabs_sharediff, geo(statehex) geoid(state) labelhex() fcolor(GnBu) nq(6) twopt(name("estabs_sharediff")) legdecimals(1)
		
graph export "../output/figures/fig_d3c_sharebus_diff.eps", as(eps) replace

************************** End Figures Establishment Shares ***************************************
clear


import excel "../data/restricted/disclosed/req10739_20230720/disclosure_output_post.xlsx", sheet("heatmap_state_T13T26") cellrange(A1:C52) firstrow 


* List all double variables
qui: ds, has(type double)

twoway (kdensity early8284, kernel(epan2 ) lwidth(thick)) (kdensity late1315, kernel(epan2 ) lwidth(thick)), ///
	legend(rows(1) label(1 "1982") label(2 "2015") size(*1.5) symxsize(*1.5) position(6) colgap(*4)) ///
	name(passthru_state) ///
	xlabel(0.25[.1].95, nogrid labsize(*1.5)) ylabel(, nogrid labsize(*1.5)) ///
	ytitle(Kernal Density,size(*1.5)) xtitle("") 
	
graph export "../output/figures/fig_d4a_states_ps_kernel.eps", as(eps) replace

clear

import excel "../data/restricted/disclosed/req10739_20230720/disclosure_output_post.xlsx", sheet("heatmap_naics_T13T26") cellrange(A1:C52) firstrow 


twoway (kdensity early8284, kernel(epan2 ) lwidth(thick)) (kdensity late1315, kernel(epan2 ) lwidth(thick)), ///
	legend(rows(1) label(1 "1982") label(2 "2015") size(*1.5) symxsize(*1.5) position(6) colgap(*4)) ///
	name(passthru_naics) ///
	xlabel(0.0[.1].9, nogrid labsize(*1.5)) ylabel(, nogrid labsize(*1.5)) ///
	ytitle(Kernal Density,size(*1.5)) xtitle("") 
	
graph export "../output/figures/fig_d4b_naics_ps_kernel.eps", as(eps) replace

clear

* Import data from csv file
import delimited "../data/bds/bds2020_st.csv", clear 

* Keep only relevant data
keep year st firms estabs emp

* Keep only interested years - 1982, 1990, 2000, 2015
keep if year == 1982 | year == 1990 | year == 2000 | year ==2015
sort year st

* Compute shares
** Compute the total
foreach var in firms estabs emp{
	bysort year: egen total_`var' = sum(`var')
}

** Compute the shares by dividing the totals
foreach var in firms estabs emp{
	gen `var'_share = `var' / total_`var'
	*replace `var'_share = 100 * `var'_share
}


twoway (kdensity estabs_share if year == 1982) (kdensity estabs_share if year == 1990) (kdensity estabs_share if year == 2000) (kdensity estabs_share if year == 2015), ///
	legend(rows(2) label(1 "1982") label(2 "1990") label(3 "2000") label(4 "2015") size(*1.5) symxsize(*1.5) position(6) colgap(*4)) ///
	xlabel(0[.01].13, nogrid) ylabel(, nogrid) ///
	name(est) ///
	ytitle(Kernal Density)  xtitle("")

graph export "../output/figures/fig_d4c_state_estabs_kernel.eps", as(eps) replace




*					Section 3.1: Business measures at naics level

* Import data from csv file - choose the specific level
local filename = "vcn4"

import delimited using "../data/bds/bds2020_`filename'.csv", clear  

* Keep only interested years - 1982, 1990, 2000, 2015
keep if year == 1982 | year == 1990 | year == 2000 | year ==2015
*sort year st

* Compute shares
** Compute the total
foreach var in firms estabs emp{
	bysort year: egen total_`var' = sum(`var')
}

** Compute the shares by dividing the totals
foreach var in firms estabs emp{
	gen `var'_share = `var' / total_`var'
	*replace `var'_share = 100 * `var'_share
}
	
* Set graph scheme
set scheme cleanplots 	
	
	twoway (kdensity estabs_share if year == 1982, lwidth(*1.5)) (kdensity estabs_share if year == 1990, lwidth(*1.5)) (kdensity estabs_share if year == 2000, lwidth(*1.5)) (kdensity estabs_share if year == 2015, lwidth(*1.5)), ///
	legend(rows(2) label(1 "1982") label(2 "1990") label(3 "2000") label(4 "2015") size(*1.5) symxsize(*1.5) position(6) colgap(*4)) ///
	xlabel(0[.02].08, nogrid labsize(*1.5)) ylabel(, nogrid labsize(*1.5)) ///
	name(`var') ///
	ytitle(Kernal Density, size(*1.5)) xtitle("")

graph export "../output/figures/fig_d4d_naics_estabs_kernel.eps", as(eps) replace




clear


import delimited using "../data/nes/combine12.txt", clear
keep if st == 0
keep if inlist(st, 0, 20)
keep if inlist(cty, "000", "-")
keep if strlen(naics) == 2 | strlen(naics) == 5
destring est, gen(est_num)
destring estab, gen(estab_num) ignore ("NA")

bysort st (naics) : gen empestabshr = est_num/est_num[1]
bysort st (naics) : gen nonempestabshr = estab_num/estab_num[1]

scatter nonempestabshr empestabshr if empestabshr != 1, mlabel(naics) ///
 || line empestabshr empestabshr if empestabshr != 1, sort ///
 || , ytitle("NAICS2 Share of Nonemployers") xtitle("NAICS2 Share of Employer Establishments") ///
 legend(off) scale(1.4) scheme(s1mono)

graph export ../output/figures/fig_b2_nes2012_comparison.eps, replace

destring cestab, gen(cestab_num) ignore ("N")
destring emp, gen(emp_num) ignore ("i")

local nonemp_bl = estab[1]
local total_bl = cestab[1]
local percent_bl = (estab_num[1] / cestab_num[1]) * 100

local nonemp_emp = estab[1]
local total_emp = estab_num[1] + emp_num[1]
local percent_emp = (estab_num[1] / (estab_num[1] + emp_num[1])) * 100

matrix business_locations = (`nonemp_bl', `total_bl', `percent_bl')
matrix employment = (`nonemp_emp', `total_emp', `percent_emp' )

putexcel set "../output/tables/table_b2.xlsx", replace
matrix table_data = (business_locations, employment)
matrix colnames table_data = Nonemp Total Percent Nonemp Total Percent
matrix list table_data
putexcel B1 = "Business Locations"
putexcel E1 = "Employment"
putexcel A2 = matrix(table_data), names
putexcel close

use ../data/nes/nes2012combinded_naics2, clear


scatter usnonemployers usemployers, mlabel(naics2) ///
 || line usemployers usemployers, sort ///
 || , ytitle("NAICS2 Share of Nonemployers") xtitle("NAICS2 Share of Employer Establishments") ///
 legend(off) scale(1.4) scheme(s1mono)
graph export ../output/figures/fig_b2_nes2012_comparison.eps, replace
 
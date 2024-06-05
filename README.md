# "The Rise of Pass-throughs: An Empirical Investigation" Replication Repository

This repository is dedicated to replicating the results from the paper titled **["The Rise of Pass-throughs: An Empirical Investigation"](https://www.dyrda.info/files/Dyrda_Pugsley_emplfo.pdf)** by [Sebastian Dyrda](https://www.dyrda.info/) (University of Toronto) and [Benjamin Pugsley](https://www.benjaminpugsley.com/) (University of Notre Dame).

## Overview

### Repository Contents

The repository contains the following folders for replication purposes:

1. **data**: Disclosed data from the Longitudinal Business Dynamics Tax Legal Form of Organization (LBD-TLFO) database, Business Dynamics Statistics Data (BDS), Statistics of US Businesses (SUSB), and other data sources used in the paper.
2. **nonproprietary_data** Copies of data folders with content in nonproprietary formats
3. **output**: Figures and Tables used in the paper.
4. **programs**: MATLAB and Stata files generating figures and tables used in the paper.

### How to Use

To replicate the results presented in the paper, follow these steps:

1. Ensure you have MATLAB and Stata installed on your computer.
2. Run the MATLAB file `run_all_matlab.m` from the `./programs` folder to replicate the figures and tables.
3. Run the Stata file `run_all_stata.do` from the `./programs` folder to generate the heatmaps, density plots, and nonemployer exhibits. The do file will install required packages, if prompted enter `1` at the command prompt to install each missing package.

## Data Availability and Provenance Statements

### Statement about Rights

- [x] I certify that the author(s) of the manuscript have legitimate access to and permission to use the data used in this manuscript.

### Summary of Availability

- [ ] All data **are** publicly available.
- [x] Some data **cannot be made** publicly available.
- [ ] **No data can be made** publicly available.

### Software Requirements

- Stata (code was run with version 15,17,18)
  - Necessary packages are `maptile`, `spmap`, and `cleanplots`. The code installs them during `run_all_stata.do`.
- MATLAB (code was run with MATLAB R2019b, R2023a, R2024a)

### Summary

Approximate time needed to reproduce the analyses on a standard (CURRENT YEAR) desktop machine:

- [x] <10 minutes
- [ ] 10-60 minutes
- [ ] 1-2 hours
- [ ] 2-8 hours
- [ ] 8-24 hours
- [ ] 1-3 days
- [ ] 3-14 days
- [ ] > 14 days

Approximate storage space needed:

- [ ] < 25 MBytes
- [x] 25 MB - 250 MB
- [ ] 250 MB - 2 GB
- [ ] 2 GB - 25 GB
- [ ] 25 GB - 250 GB
- [ ] > 250 GB

- [ ] Not feasible to run on a desktop machine, as described below.

### Confidential Data
The results in the paper depend on confidential data from the U.S. Census Bureau. The resulting estimates from the confidential data cleared for release are stored in `./data/restricted`. To gain access to the underlying Census microdata and replication programs, first follow the directions here on how to write a proposal for access to the data via a Federal Statistical Research Data Center: https://www.census.gov/ces/rdcresearch/howtoapply.html. You must request the following datasets in your proposal:
 - Longitudinal Business Database (LBD), 1979 to 2016
 - Standard Statistical Establishment List/Business Register (SSL) 1979 to 2016

Next, request the `replication/buslfo_ej` folder be transfered from FSRDC Project 1731 to your approved project. This directory contains a `run_all.sh` script that rebuilds all datasets from the raw Census microdata databases and runs the analysis that produces the released output.

The Census Bureau will maintain this directory for at least 10 years from publication. 

## List of tables and figures

The provided code reproduces:

- [x] All numbers provided in text in the paper
- [x] All tables and figures in the paper
- [ ] Selected tables and figures in the paper, as explained and justified below.

All figures are saved in the `./output/figures` folder, and all tables are saved in the `./output/tables` folder.

| Table/Figure # | File Name                           | Notes                 | Program                   |
|----------------|-------------------------------------|-----------------------|---------------------------|
| Figure 1(a)    | fig_1a_agg_passthru.eps             |                       | exhibits_risepassthru.m   |
| Figure 1(b)    | fig_1b_agg_constcomp.eps            |                       | exhibits_risepassthru.m   |
| Figure 1(c)    | fig_1c_agg_stateconv_lfit.eps       |                       | exhibits_risepassthru.m   |
| Figure 1(d)    | fig_1d_agg_indconv_lfit.eps         |                       | exhibits_risepassthru.m   |
| Figure 3(a)    | fig_3a_cf_main.eps                  |                       | exhibits_risepassthru.m   |
| Figure 4(a)    | fig_4a_cf_slow.eps                  |                       | exhibits_risepassthru.m   |
| Figiure 4(b)   | fig_4b_entrant_cf_slow.eps          |                       | exhibits_risepassthru.m   |
| Figure 4(c)    | fig_4c_reorg_ctop_cf_slow.eps       |                       | exhibits_risepassthru.m   |
| Figure 4(d)    | fig_4d_reorg_ptoc_cf_slow.eps       |                       | exhibits_risepassthru.m   |
| Figure 5(a)    | fig_5a_startup_rate.eps             |                       | exhibits_risepassthru.m   |
| Figure 5(b)    | fig_5b_cf_nostartupdef.eps          |                       | exhibits_risepassthru.m   |
| Figure 5(c)    | fig_5c_cp_pc_lifecycle_age.eps      |                       | exhibits_risepassthru.m   |
| Figure 5(d)    | fig_5d_cf_ageconst.eps              |                       | exhibits_risepassthru.m   |
| Figure B.1(a)  | fig_b1a_estabs_susb_lbd.eps         |                       | exhibits_risepassthru.m   |
| Figure B.1(b)  | fig_b1b_emp_susb_lbd.eps            |                       | exhibits_risepassthru.m   |
| Figure B.2     | fig_b2_nes2012_comparison.eps       |                       | nes2012_comparison.do     |
| Figure C.1     | fig_c1_actual_compare_noz.eps       |                       | exhibits_risepassthru.m   |
| Figure C.2     | fig_c2_cf_main_granular.eps         |                       | exhibits_risepassthru.m   |
| Figure C.3     | fig_c3_cf_main_granular_age.eps     |                       | exhibits_risepassthru.m   |
| Figure C.4     | fig_c4_cf_nostartupdef2.eps         |                       | exhibits_risepassthru.m   |
| Figure C.5(a)  | fig_c5a_agg_lr.eps                  |                       | exhibits_risepassthru.m   |
| Figure C.5(b)  | fig_c5b_cf_main_lr.eps              |                       | exhibits_risepassthru.m   |
| Figure D.1     | fig_d1_manufacturing_bds.eps        |                       | exhibits_risepassthru.m   |
| Figure D.2(a)  | fig_d2a_passthrough_share_early.eps |                       | heatmaps_and_densities.do |
| Figure D.2(b)  | fig_d2b_passthrough_share_late.eps  |                       | heatmaps_and_densities.do |
| Figure D.2(c)  | fig_d2c_passthrough_share_diff.eps  |                       | heatmaps_and_densities.do |
| Figure D.3(a)  | fig_d3a_sharebus_early.eps          |                       | heatmaps_and_densities.do |
| Figure D.3(b)  | fig_d3b_sharebus_late.eps           |                       | heatmaps_and_densities.do |
| Figure D.3(c)  | fig_d3c_sharebus_diff.eps           |                       | heatmaps_and_densities.do |
| Figure D.4(a)  | fig_d4a_states_ps_kernel.eps        |                       | heatmaps_and_densities.do |
| Figure D.4(b)  | fig_d4b_naics_ps_kernel.eps         |                       | heatmaps_and_densities.do |
| Figure D.4(c)  | fig_d4c_state_estabs_kernel.eps     |                       | heatmaps_and_densities.do |
| Figure D.4(d)  | fig_d4d_naics_estabs_kernel.eps     |                       | heatmaps_and_densities.do |
| Figure D.5     | fig_d5_exitrates.eps                |                       | exhibits_risepassthru.m   |
| Table 3(b)     | table_3b_main_decomp.txt            |                       | exhibits_risepassthru.m   |
| Table A1       | table_a1.xlsx                       |                       | Adapted from IRS table   |
| Table A2       | table_a2.xlsx                       |                       | Adapted from IRS table   |
| Table B1       | table_b1_summary.txt                |                       | exhibits_risepassthru.m   |
| Table B2       | table_b2.xlsx                       |                       | nes2012_comparison.do   |
| Table C1       | table_c1_main_decomp_granular.txt   |                       | exhibits_risepassthru.m   |
| Table C2       | table_c2_main_decomp_age.txt        |                       | exhibits_risepassthru.m   |

## Data Citations

**Internal Revenue Service.** 1909-2010. "US Corporation Income Tax: Tax Brackets and Rates." Internal Revenue Service. https://www.irs.gov/statistics/soi-tax-stats-historical-table-24 (accessed March 2024).

**U.S. Census Bureau.** 2020. "American National Standards Institute (ANSI), Federal Information Processing Series (FIPS), and Other Standardized Geographic Codes - 2020 Census Codes for States, the District of Columbia, Puerto Rico, and the Insular Areas of the United States." United States Census Bureau. <https://www2.census.gov/geo/docs/reference/codes2020/national_state2020.txt> (accessed March 2023).

**U.S. Census Bureau.** 2020. "Business Dynamics Statistics 2020 - One Way Datatsets: Sector." United States Census Bureau. <https://www.census.gov/data/datasets/time-series/econ/bds/bds-datasets.html> (accessed March 2023).

**U.S. Census Bureau.** 2020. "Business Dynamics Statistics 2020 - One Way Datatsets: State." United States Census Bureau. <https://www.census.gov/data/datasets/time-series/econ/bds/bds-datasets.html> (accessed March 2023).

**U.S. Census Bureau.** 2020. "Business Dynamics Statistics 2020 - One Way Datasets : 4-digit NAICS." United States Census Bureau. <https://www.census.gov/data/datasets/time-series/econ/bds/bds-datasets.html> (accessed March 2023).

**U.S. Census Bureau.** 2007. "Data by Enterprise and Employment Size: U.S., NAICS sectors, legal form of organization (LFO)." United States Census Bureau. <https://www.census.gov/data/tables/2007/econ/susb/2007-susb-annual.html> (accessed November 2023).

**U.S. Census Bureau.** 2008. "Data by Enterprise and Employment Size: U.S., NAICS sectors, legal form of organization (LFO)." United States Census Bureau. <https://www.census.gov/data/tables/2008/econ/susb/2008-susb-annual.html> (accessed November 2023).

**U.S. Census Bureau.** 2009. "Data by Enterprise and Employment Size: U.S., NAICS sectors, legal form of organization (LFO)." United States Census Bureau. <https://www.census.gov/data/tables/2009/econ/susb/2009-susb-annual.html> (accessed November 2023).

**U.S. Census Bureau.** 2010. "Data by Enterprise and Employment Size: U.S., NAICS sectors, legal form of organization (LFO)." United States Census Bureau. <https://www.census.gov/data/tables/2010/econ/susb/2010-susb-annual.html> (accessed November 2023).

**U.S. Census Bureau.** 2011. "Data by Enterprise and Employment Size: U.S., NAICS sectors, legal form of organization (LFO)." United States Census Bureau. <https://www.census.gov/data/tables/2011/econ/susb/2011-susb-annual.html> (accessed November 2023).

**U.S. Census Bureau.** 2012. "Data by Enterprise and Employment Size: U.S., NAICS sectors, legal form of organization (LFO)." United States Census Bureau. <https://www.census.gov/data/tables/2012/econ/susb/2012-susb-annual.html> (accessed November 2023).

**U.S. Census Bureau.** 2013. "Data by Enterprise and Employment Size: U.S., NAICS sectors, legal form of organization (LFO)." United States Census Bureau. <https://www.census.gov/data/tables/2013/econ/susb/2013-susb-annual.html> (accessed November 2023).

**U.S. Census Bureau.** 2014. "Data by Enterprise and Employment Size: U.S., NAICS sectors, legal form of organization (LFO)." United States Census Bureau. <https://www.census.gov/data/tables/2014/econ/susb/2014-susb-annual.html> (accessed November 2023).

**U.S. Census Bureau.** 2015. "Data by Enterprise and Employment Size: U.S., NAICS sectors, legal form of organization (LFO)." United States Census Bureau. <https://www.census.gov/data/tables/2015/econ/susb/2015-susb-annual.html> (accessed November 2023).

**U.S. Census Bureau.** 2016. "Data by Enterprise and Employment Size: U.S., NAICS sectors, legal form of organization (LFO)." United States Census Bureau. <https://www.census.gov/data/tables/2016/econ/susb/2016-susb-annual.html> (accessed November 2023).

**U.S. Census Bureau.** 2017. "Data by Enterprise and Employment Size: U.S., NAICS sectors, legal form of organization (LFO)." United States Census Bureau. <https://www.census.gov/data/tables/2017/econ/susb/2017-susb-annual.html> (accessed November 2023).

**U.S. Census Bureau.** 2020. "Nonemployer Statistics 2012 - Datasets: Complete U.S. File." United States Census Bureau. <https://www2.census.gov/programs-surveys/nonemployer-statistics/datasets/2012/historical-datasets/nonemp12us.txt>. (accessed December 2023).

**U.S. Census Bureau.**  1976-2021. Longitudinal Business Database. United States Census Bureau. <https://www.census.gov/programs-surveys/ces/data/restricted-use-data/longitudinal-business-database.html> (accessed August 2023).

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.

## Acknowledgments

We are grateful for the outstanding research assistance of Sean Miranda in preparing this replication package.

- [Sebastian Dyrda](https://www.dyrda.info/), University of Toronto
- [Benjamin Pugsley](https://www.benjaminpugsley.com/), University of Notre Dame

/*
========================================================================
File:     taught_task9.do
Purpose:  Native Stata 18 multiple-imputation stress-test fixture
Target:   >= 10000 lines of executable Stata code
Scope:    Native Stata 18 baseline only; do not use Stata Workbench here
========================================================================
This file is intentionally self-contained. It creates a synthetic longitudinal
research dataset and stresses Stata's MI stack through valid univariate,
chained, MVN, monotone, passive, survey, panel, graph, table, and document
workflows. Core MI creation, core MI estimation, and final output commands are
fail-fast. Optional dependency checks are explicit and never reported as run.
========================================================================
*/

version 18
clear all
set more off
set seed 20260512
set maxvar 32000
capture log close _all

local __taught_root "`c(pwd)'"
global workfolder "`__taught_root'"
global tempdir    "${workfolder}/7_temp"
global docdir     "${workfolder}/4_tables"

capture mkdir "${tempdir}"
capture mkdir "${docdir}"
capture mkdir "${tempdir}/taught_task9_graphs"

local t9_run_stamp = subinstr("`=c(current_date)'_`=c(current_time)'", " ", "_", .)
local t9_run_stamp = subinstr("`t9_run_stamp'", ":", "", .)
local t9_run_stamp = subinstr("`t9_run_stamp'", "/", "", .)
global figdir9 "${tempdir}/taught_task9_graphs/`t9_run_stamp'"
capture mkdir "$figdir9"

capture which p_tdocx
if _rc {
    capture program drop p_tdocx
    program define p_tdocx
        putdocx `0'
    end
}

capture which reghdfe
local t9_has_reghdfe = (_rc == 0)

display as text "===== TAUGHT TASK 9 NATIVE MI STRESS TEST START ====="
display as text "Stata version: " c(stata_version)
display as text "Date/time    : " c(current_date) " " c(current_time)
display as text "figdir9      : $figdir9"
display as text "reghdfe installed: `t9_has_reghdfe'"

// #region Section 1: synthetic longitudinal research data

display as text ">>> START Section 1: data generation"
sysuse auto, clear
expand 8
sort make
by make: gen int t9_rep = _n
gen long t9_base_id = _n
expand 3
bysort t9_base_id: gen byte t9_wave = _n
gen long t9_id = t9_base_id
gen int t9_year = 2016 + 2*t9_wave

label variable t9_id "Synthetic respondent ID"
label variable t9_wave "Panel wave"
label variable t9_year "Survey year"

* Complete demographic and design variables
gen double t9_age = round(22 + 0.18*length + 1.5*t9_wave + rnormal(0, 4))
replace t9_age = max(18, min(75, t9_age))
gen byte t9_female = (runiform() < 0.52)
gen byte t9_minority = (runiform() < 0.24 + 0.03*(foreign==1))
gen byte t9_region = 1 + mod(t9_base_id, 6)
gen byte t9_sector = 1 + mod(t9_base_id + foreign, 3)
gen byte t9_psu = 1 + mod(t9_base_id, 60)
gen byte t9_strata = 1 + mod(t9_region + t9_sector, 8)
gen double t9_pweight = 0.5 + runiform()*2.5
gen byte t9_policy = (t9_region <= 3)
gen byte t9_post = (t9_wave >= 2)
gen byte t9_treat = t9_policy*t9_post

gen double t9_educ = round(8 + 0.03*mpg + 0.015*price/100 + rnormal(0, 2))
replace t9_educ = max(6, min(20, t9_educ))
gen double t9_parent_educ = max(4, min(20, t9_educ + 0.15*t9_region + rnormal(0, 2)))
gen double t9_local_unemp = max(1, min(18, 5 + 0.7*t9_region - 0.25*t9_sector + rnormal(0, 2)))
gen double t9_distance_college = max(1, 30 - 1.2*t9_parent_educ + 2*t9_region + rnormal(0, 6))
gen double t9_exper = max(0, t9_age - t9_educ - 6 + rnormal(0, 2))
gen byte t9_married = (runiform() < invlogit(-2 + 0.06*t9_age + 0.25*t9_female))
gen byte t9_urban = (runiform() < invlogit(-0.4 + 0.3*t9_region + 0.2*foreign))

gen double t9_income = 15000 + 2200*t9_educ + 650*t9_exper + 1800*t9_treat + 450*price/100 + rnormal(0, 9000)
replace t9_income = max(1000, t9_income)
gen double t9_wage = 8 + 1.2*t9_educ + 0.35*t9_exper + 0.02*price + rnormal(0, 5)
replace t9_wage = max(1, t9_wage)
gen double t9_hours = 35 + 2*t9_married - 3*t9_female + 1.5*t9_treat + rnormal(0, 7)
replace t9_hours = max(5, min(80, t9_hours))
gen double t9_wealth = max(0, 2.5*t9_income + 1800*t9_age + rnormal(0, 35000))
gen double t9_savings = max(0, 0.14*t9_income + rnormal(0, 5000))
gen double t9_expenditure = max(200, 0.72*t9_income + rnormal(0, 6500))
gen double t9_exercise_base = max(0, 3 + 0.12*t9_educ - 0.05*t9_age + rnormal(0, 2))
gen double t9_health_score = max(0, min(100, 70 - 0.20*t9_age + 1.8*t9_exercise_base + 3*t9_urban + rnormal(0, 12)))
gen double t9_bmi = max(15, min(45, 24 + 0.06*t9_age - 0.25*t9_exercise_base + rnormal(0, 4)))
gen double t9_bp_sys = max(85, min(210, 105 + 0.45*t9_age + 0.7*t9_bmi + rnormal(0, 12)))
gen double t9_bp_dia = max(50, min(130, 65 + 0.22*t9_age + 0.35*t9_bmi + rnormal(0, 8)))
gen double t9_depression = max(0, min(60, 16 + 0.08*t9_age - 0.08*t9_income/1000 + 2*(t9_married==0) + rnormal(0, 7)))
gen double t9_stress = max(0, min(50, 20 + 0.12*t9_hours - 0.05*t9_income/1000 + rnormal(0, 6)))
gen double t9_satisfaction = max(1, min(10, 5.5 + 0.00004*t9_income - 0.08*t9_stress + rnormal(0, 1.5)))
gen double t9_sleep = max(3, min(12, 7.5 - 0.035*t9_stress + rnormal(0, 1.1)))
gen double t9_exercise = max(0, t9_exercise_base + 0.2*t9_wave + rnormal(0, 1.5))

gen byte t9_employed = (runiform() < invlogit(-2 + 0.18*t9_educ + 0.03*t9_exper + 0.4*t9_urban))
gen byte t9_homeowner = (runiform() < invlogit(-3 + 0.04*t9_age + 0.000025*t9_income))
gen byte t9_insured = (runiform() < invlogit(-1.2 + 0.14*t9_educ + 0.5*t9_employed))
gen byte t9_smoker = (runiform() < invlogit(-0.8 - 0.10*t9_educ + 0.04*t9_stress))

gen byte t9_educ_level = min(5, max(1, ceil((t9_educ + rnormal(0, 1.2))/4)))
gen byte t9_health_level = min(5, max(1, ceil((t9_health_score + rnormal(0, 8))/20)))
gen byte t9_job_sat = min(4, max(1, ceil((t9_satisfaction + rnormal(0, 1))/2.5)))
gen byte t9_occupation = 1 + mod(t9_base_id + t9_sector + t9_educ_level, 4)
gen byte t9_children = min(8, rpoisson(max(0.2, 0.4 + 0.02*(t9_age-25) + 0.8*t9_married)))
gen byte t9_doctor_visits = min(20, rpoisson(max(0.2, 2 + 0.04*t9_age + 0.08*(100-t9_health_score))))
gen byte t9_hosp_days = min(30, rpoisson(max(0.05, 0.2 + 0.02*(100-t9_health_score))))

gen double t9_income_ll = floor(t9_income/5000)*5000
gen double t9_income_ul = t9_income_ll + 5000
gen byte t9_income_q = .
xtile t9_income_q_tmp = t9_income, nq(4)
replace t9_income_q = t9_income_q_tmp
drop t9_income_q_tmp

gen double t9_age_sq = t9_age^2
gen double t9_exper_sq = t9_exper^2
gen double t9_educ_sq = t9_educ^2
gen double t9_log_income_full = ln(max(1,t9_income))
gen double t9_log_wage_full = ln(max(1,t9_wage))

label define t9_region_lbl 1 "North" 2 "Northeast" 3 "East" 4 "Central" 5 "West" 6 "South"
label values t9_region t9_region_lbl
label define t9_sector_lbl 1 "Manufacturing" 2 "Services" 3 "Government"
label values t9_sector t9_sector_lbl
label define t9_occ_lbl 1 "Professional" 2 "Clerical" 3 "Manual" 4 "Service"
label values t9_occupation t9_occ_lbl
label define t9_yesno 0 "No" 1 "Yes"
label values t9_female t9_minority t9_married t9_urban t9_employed t9_homeowner t9_insured t9_smoker t9_policy t9_post t9_treat t9_yesno

compress
isid t9_id t9_wave
xtset t9_id t9_wave
save "${tempdir}/t9_complete_base.dta", replace

display as result "<<< DONE Section 1: data generation"
// #endregion Section 1

// #region Section 2: missingness mechanisms

display as text ">>> START Section 2: missingness mechanisms"

use "${tempdir}/t9_complete_base.dta", clear
set seed 20260513

* MCAR, MAR, and MNAR-like flags
gen byte t9_miss_income = (runiform() < invlogit(-3.2 + 0.04*t9_age + 0.18*t9_female + 0.25*t9_region))
gen byte t9_miss_wage = (runiform() < invlogit(-3.0 + 0.20*(t9_employed==0) + 0.12*t9_sector))
gen byte t9_miss_hours = (runiform() < 0.12 + 0.04*t9_wave)
gen byte t9_miss_wealth = (runiform() < invlogit(-2.2 + 0.00002*t9_income + 0.02*t9_age))
gen byte t9_miss_savings = (runiform() < 0.14)
gen byte t9_miss_expenditure = (runiform() < 0.13 + 0.03*t9_urban)
gen byte t9_miss_health_score = (runiform() < invlogit(-3.0 + 0.03*t9_age + 0.25*t9_smoker))
gen byte t9_miss_bmi = (runiform() < 0.10 + 0.03*t9_female)
gen byte t9_miss_bp_sys = (runiform() < 0.11 + 0.03*(t9_age>55))
gen byte t9_miss_bp_dia = (runiform() < 0.11 + 0.03*(t9_age>55))
gen byte t9_miss_depression = (runiform() < invlogit(-2.8 + 0.04*t9_stress + 0.15*(t9_married==0)))
gen byte t9_miss_stress = (runiform() < invlogit(-3.0 + 0.05*t9_hours + 0.10*t9_female))
gen byte t9_miss_satisfaction = (runiform() < 0.12 + 0.02*(t9_income_q==1))
gen byte t9_miss_sleep = (runiform() < 0.10 + 0.02*(t9_stress>25))
gen byte t9_miss_exercise = (runiform() < 0.12)
gen byte t9_miss_employed = (runiform() < 0.08 + 0.02*t9_wave)
gen byte t9_miss_married = (runiform() < 0.07)
gen byte t9_miss_urban = (runiform() < 0.06)
gen byte t9_miss_homeowner = (runiform() < 0.08 + 0.02*(t9_income_q==1))
gen byte t9_miss_insured = (runiform() < 0.07 + 0.02*(t9_employed==0))
gen byte t9_miss_smoker = (runiform() < 0.09)
gen byte t9_miss_educ_level = (runiform() < 0.08)
gen byte t9_miss_health_level = (runiform() < 0.09)
gen byte t9_miss_job_sat = (runiform() < 0.10)
gen byte t9_miss_occupation = (runiform() < 0.09)
gen byte t9_miss_children = (runiform() < 0.07)
gen byte t9_miss_doctor_visits = (runiform() < 0.10)
gen byte t9_miss_hosp_days = (runiform() < 0.08)

replace t9_income = . if t9_miss_income
replace t9_wage = . if t9_miss_wage
replace t9_hours = . if t9_miss_hours
replace t9_wealth = . if t9_miss_wealth
replace t9_savings = . if t9_miss_savings
replace t9_expenditure = . if t9_miss_expenditure
replace t9_health_score = . if t9_miss_health_score
replace t9_bmi = . if t9_miss_bmi
replace t9_bp_sys = . if t9_miss_bp_sys
replace t9_bp_dia = . if t9_miss_bp_dia
replace t9_depression = . if t9_miss_depression
replace t9_stress = . if t9_miss_stress
replace t9_satisfaction = . if t9_miss_satisfaction
replace t9_sleep = . if t9_miss_sleep
replace t9_exercise = . if t9_miss_exercise
replace t9_employed = . if t9_miss_employed
replace t9_married = . if t9_miss_married
replace t9_urban = . if t9_miss_urban
replace t9_homeowner = . if t9_miss_homeowner
replace t9_insured = . if t9_miss_insured
replace t9_smoker = . if t9_miss_smoker
replace t9_educ_level = . if t9_miss_educ_level
replace t9_health_level = . if t9_miss_health_level
replace t9_job_sat = . if t9_miss_job_sat
replace t9_occupation = . if t9_miss_occupation
replace t9_children = . if t9_miss_children
replace t9_doctor_visits = . if t9_miss_doctor_visits
replace t9_hosp_days = . if t9_miss_hosp_days
replace t9_income_ll = . if missing(t9_income) | runiform() < 0.06
replace t9_income_ul = . if missing(t9_income) | runiform() < 0.06

misstable summarize t9_income t9_wage t9_hours t9_wealth t9_health_score t9_depression t9_employed t9_occupation
misstable patterns t9_income t9_wage t9_hours t9_depression t9_stress t9_employed t9_married, frequency
save "${tempdir}/t9_missing_base.dta", replace

display as result "<<< DONE Section 2: missingness mechanisms"
// #endregion Section 2

// #region Section 3: pre-imputation diagnostics

display as text ">>> START Section 3: diagnostics before MI"
codebook t9_income t9_wage t9_hours t9_wealth t9_health_score t9_depression t9_stress, compact
summarize t9_income t9_wage t9_hours t9_wealth t9_health_score t9_depression t9_stress t9_bmi t9_bp_sys t9_bp_dia
tabulate t9_region t9_miss_income, row
tabulate t9_sector t9_miss_wage, row
tabulate t9_wave t9_miss_depression, row
logit t9_miss_income t9_age t9_female t9_educ i.t9_region i.t9_sector, nolog
estimates store t9_missing_income_logit
logit t9_miss_depression t9_age t9_female t9_stress i.t9_wave, nolog
estimates store t9_missing_depression_logit

histogram t9_income, name(t9g_pre_income, replace) title("Observed income before MI")
graph export "$figdir9/t9g_pre_income.png", name(t9g_pre_income) replace width(1400)
histogram t9_depression, name(t9g_pre_depression, replace) title("Observed depression before MI")
graph export "$figdir9/t9g_pre_depression.png", name(t9g_pre_depression) replace width(1400)
graph bar (mean) t9_miss_income t9_miss_depression, over(t9_wave) name(t9g_pre_missing_wave, replace) title("Missingness by wave")
graph export "$figdir9/t9g_pre_missing_wave.png", name(t9g_pre_missing_wave) replace width(1400)

display as result "<<< DONE Section 3: diagnostics before MI"
// #endregion Section 3
// #region Section 4: MI set formats and valid univariate methods

display as text ">>> START Section 4: MI set formats and univariate methods"

* Format demonstrations are isolated in preserve/restore blocks.
preserve
    mi set wide
    mi register imputed t9_income t9_wage
    mi register regular t9_age t9_female t9_educ
    mi describe
    mi unset
restore

preserve
    mi set mlong
    mi register imputed t9_income t9_wage t9_depression
    mi register regular t9_age t9_female t9_educ
    mi describe
    mi unset
restore

preserve
    mi set flong
    mi register imputed t9_income t9_wage
    mi register regular t9_age t9_female t9_educ
    mi describe
    mi unset
restore

preserve
    mi set wide
    mi register imputed t9_income
    mi register regular t9_age t9_female t9_educ
    mi impute regress t9_income = t9_age t9_female t9_educ, add(3) rseed(41001) force
    mi convert mlong, clear
    mi describe
    mi convert flong, clear
    mi describe
    mi convert wide, clear
    mi describe
    mi unset
restore

preserve
    mi set mlong
    mi register imputed t9_income
    mi register regular t9_age t9_female t9_educ t9_exper
    mi impute regress t9_income = t9_age t9_female t9_educ t9_exper, add(5) rseed(42001) force
    mi estimate: regress t9_income t9_age t9_female t9_educ
    mi unset
restore

preserve
    mi set mlong
    mi register imputed t9_wage
    mi register regular t9_age t9_female t9_educ t9_exper
    mi impute pmm t9_wage = t9_age t9_female t9_educ t9_exper, add(5) rseed(42002) knn(5) force
    mi estimate: regress t9_wage t9_age t9_female t9_educ
    mi unset
restore

preserve
    mi set mlong
    mi register imputed t9_hours
    mi register regular t9_age t9_female t9_educ t9_exper
    mi impute truncreg t9_hours = t9_age t9_female t9_educ, ll(1) ul(90) add(5) rseed(42003) force
    mi estimate: regress t9_hours t9_age t9_female t9_educ
    mi unset
restore

preserve
    mi set mlong
    mi register imputed t9_employed
    mi register regular t9_age t9_female t9_educ t9_exper
    mi impute logit t9_employed = t9_age t9_female t9_educ t9_exper, add(5) rseed(42004) augment force
    mi estimate: logit t9_employed t9_age t9_female t9_educ
    mi unset
restore

preserve
    mi set mlong
    mi register imputed t9_job_sat
    mi register regular t9_age t9_female t9_educ t9_exper
    mi impute ologit t9_job_sat = t9_age t9_female t9_exper, add(5) rseed(42005) augment force
    mi estimate: ologit t9_job_sat t9_age t9_female t9_educ
    mi unset
restore

preserve
    mi set mlong
    mi register imputed t9_occupation
    mi register regular t9_age t9_female t9_educ t9_exper
    mi impute mlogit t9_occupation = t9_age t9_female t9_educ t9_exper, add(5) rseed(42006) augment force
    mi estimate: mlogit t9_occupation t9_age t9_female t9_educ
    mi unset
restore

preserve
    mi set mlong
    mi register imputed t9_children
    mi register regular t9_age t9_female t9_married t9_educ
    mi impute poisson t9_children = t9_age t9_female t9_married t9_educ, add(5) rseed(42007) force
    mi estimate: poisson t9_children t9_age t9_female t9_married
    mi unset
restore

preserve
    mi set mlong
    mi register imputed t9_doctor_visits
    mi register regular t9_age t9_female t9_insured t9_educ
    mi impute nbreg t9_doctor_visits = t9_age t9_female t9_insured t9_educ, add(5) rseed(42008) force
    mi estimate: nbreg t9_doctor_visits t9_age t9_female t9_insured
    mi unset
restore

preserve
    gen double t9_int_ll = floor((20000 + 1500*t9_educ + 600*t9_exper + rnormal(0, 3000))/5000)*5000
    gen double t9_int_ul = t9_int_ll + 5000
    mi set mlong
    mi register regular t9_age t9_female t9_educ t9_exper
    mi impute intreg t9_income_int = t9_age t9_female t9_educ t9_exper, ll(t9_int_ll) ul(t9_int_ul) add(5) rseed(42009) force
    mi describe
    mi unset
restore

preserve
    mi set mlong
    mi register imputed t9_income t9_wage t9_hours
    mi register regular t9_age t9_female t9_educ t9_exper
    mi impute mvn t9_income t9_wage t9_hours = t9_age t9_female t9_educ t9_exper, add(5) rseed(42010) force
    mi estimate: regress t9_income t9_wage t9_hours t9_age t9_female
    mi unset
restore

preserve
    clear
    set obs 240
    gen long t9_mono_id = _n
    gen double t9_age = 20 + mod(_n, 45)
    gen byte t9_female = mod(_n, 2)
    gen double t9_educ = 8 + mod(_n, 12)
    gen double t9_exper = max(0, t9_age - t9_educ - 6)
    gen double t9_income = 20000 + 1500*t9_educ + 500*t9_exper + rnormal(0, 4000)
    gen double t9_wage = 8 + 1.1*t9_educ + 0.25*t9_exper + rnormal(0, 3)
    gen double t9_hours = 35 + 0.3*t9_exper - 2*t9_female + rnormal(0, 4)
    replace t9_income = . if _n > 160
    replace t9_wage = . if _n > 180
    replace t9_hours = . if _n > 200
    mi set mlong
    mi register imputed t9_income t9_wage t9_hours
    mi register regular t9_age t9_female t9_educ t9_exper
    mi impute monotone (regress) t9_income t9_wage t9_hours = t9_age t9_female t9_educ t9_exper, add(3) rseed(42011) force
    mi describe
    mi unset
restore

display as result "<<< DONE Section 4: MI set formats and univariate methods"
// #endregion Section 4
// #region Section 5: production chained MI data

display as text ">>> START Section 5: production MICE"
use "${tempdir}/t9_missing_base.dta", clear
mi set mlong
mi register imputed t9_income t9_wage t9_hours t9_depression t9_stress t9_health_score t9_bmi
mi register imputed t9_employed t9_married
mi register imputed t9_job_sat
mi register imputed t9_occupation
mi register imputed t9_children
mi register regular t9_id t9_wave t9_year t9_age t9_female t9_minority t9_educ t9_parent_educ t9_local_unemp t9_distance_college t9_exper t9_region t9_sector t9_psu t9_strata t9_pweight t9_policy t9_post t9_treat t9_income_q
mi register regular t9_wealth t9_savings t9_expenditure t9_bp_sys t9_bp_dia t9_satisfaction t9_sleep t9_exercise
mi register regular t9_urban t9_homeowner t9_insured t9_smoker t9_educ_level t9_health_level t9_doctor_visits t9_hosp_days

capture erase "${tempdir}/taught_task9_trace.dta"
mi impute chained ///
    (pmm, knn(5)) t9_income t9_wage t9_hours ///
    (truncreg, ll(0) ul(100)) t9_health_score ///
    (truncreg, ll(15) ul(45)) t9_bmi ///
    (truncreg, ll(0) ul(60)) t9_depression ///
    (truncreg, ll(0) ul(50)) t9_stress ///
    (logit, augment) t9_employed t9_married ///
    (ologit, augment) t9_job_sat ///
    (mlogit, augment) t9_occupation ///
    (poisson) t9_children ///
    = t9_age t9_female t9_minority t9_educ t9_exper i.t9_region i.t9_sector i.t9_wave, ///
    add(20) rseed(50001) burnin(10) force chaindots savetrace("${tempdir}/taught_task9_trace.dta", replace)

mi describe
local t9_M = r(M)
mi varying
mi query
assert `t9_M' == 20
mi update
save "${tempdir}/t9_mi_production.dta", replace

display as result "<<< DONE Section 5: production MICE, M=`t9_M'"
// #endregion Section 5

// #region Section 6: passive variables and post-MI diagnostics

display as text ">>> START Section 6: passive variables"
mi passive: gen double t9_income_sq = t9_income^2
mi passive: gen double t9_wage_sq = t9_wage^2
mi passive: gen double t9_log_income = ln(max(1,t9_income))
mi passive: gen double t9_log_wage = ln(max(1,t9_wage))
mi passive: gen double t9_income_per_hour = t9_income/(52*max(1,t9_hours))
mi passive: gen double t9_health_index = (t9_health_score + 10*t9_satisfaction + (12-t9_sleep)*2)/3
mi passive: gen byte t9_high_income = (t9_income > 60000) if !missing(t9_income)
mi passive: gen byte t9_high_stress = (t9_stress > 25) if !missing(t9_stress)
mi passive: gen double t9_dep_stress = t9_depression + t9_stress
mi passive: gen double t9_income_educ = t9_income * t9_educ
mi passive: gen double t9_female_educ = t9_female * t9_educ
mi passive: gen double t9_treat_income = t9_treat * t9_income
mi passive: gen double t9_bmi_bp = t9_bmi * t9_bp_sys
mi passive: gen byte t9_unhealthy = (t9_health_score < 50 | t9_depression > 25) if !missing(t9_health_score, t9_depression)
mi passive: gen double t9_income_topcoded = min(t9_income, 120000)
mi passive: gen double t9_hours_censored = max(5, min(t9_hours, 65))
mi passive: gen byte t9_any_hosp = (t9_hosp_days > 0) if !missing(t9_hosp_days)
mi passive: gen byte t9_many_visits = (t9_doctor_visits >= 4) if !missing(t9_doctor_visits)
mi passive: gen byte t9_high_bp = (t9_bp_sys >= 140 | t9_bp_dia >= 90) if !missing(t9_bp_sys, t9_bp_dia)
mi passive: gen double t9_count_risk = t9_doctor_visits + t9_hosp_days + t9_smoker + t9_high_stress
mi update
mi describe
misstable summarize t9_income t9_wage t9_hours t9_depression t9_stress t9_health_score

display as result "<<< DONE Section 6: passive variables"
// #endregion Section 6
// #region Section 7: required MI analysis models

display as text ">>> START Section 7: required MI estimates"
mi estimate, post: regress t9_income t9_age t9_female t9_educ t9_exper i.t9_region i.t9_wave
estimates store t9_req_income_ols
mi test t9_age t9_female
mi estimate, post: regress t9_wage t9_age t9_female t9_educ t9_exper i.t9_sector i.t9_wave, vce(cluster t9_id)
estimates store t9_req_wage_cluster
mi estimate, post: logit t9_employed t9_age t9_female t9_educ t9_exper i.t9_region
estimates store t9_req_employed_logit
mi estimate, post: ologit t9_health_level t9_age t9_female t9_income t9_bmi
estimates store t9_req_health_ologit
mi estimate, post: mlogit t9_occupation t9_age t9_female t9_educ t9_income
estimates store t9_req_occupation_mlogit
mi estimate, post: poisson t9_doctor_visits t9_age t9_female t9_insured t9_health_score
estimates store t9_req_doctor_poisson
mi estimate, post: poisson t9_children t9_age t9_female t9_married t9_income
estimates store t9_req_children_poisson
mi estimate, vartable post: regress t9_depression t9_age t9_female t9_income t9_stress
estimates store t9_req_depression_vartable
mi estimate, mcerror post: regress t9_health_score t9_age t9_female t9_bmi t9_income
estimates store t9_req_health_mcerror
mi estimate, post: regress t9_income c.t9_educ##i.t9_female t9_age t9_exper i.t9_region
estimates store t9_req_interaction
mi test 1.t9_female#c.t9_educ
lincom t9_educ + 1.t9_female#c.t9_educ

if `t9_has_reghdfe' {
    display as text "--- reghdfe installed: running MI + reghdfe block with cmdok ---"
    mi estimate, cmdok post: reghdfe t9_income t9_treat t9_age t9_female t9_educ, absorb(t9_region t9_wave) vce(cluster t9_id)
    estimates store t9_req_reghdfe_income
    mi estimate, cmdok post: reghdfe t9_wage t9_treat t9_age t9_female t9_educ, absorb(t9_region t9_wave) vce(cluster t9_id)
    estimates store t9_req_reghdfe_wage
}
else {
    display as text "--- reghdfe not installed: running built-in FE fallback ---"
    mi estimate, post: regress t9_income t9_treat t9_age t9_female t9_educ i.t9_region i.t9_wave, vce(cluster t9_id)
    estimates store t9_req_fe_income_fallback
    mi estimate, post: regress t9_wage t9_treat t9_age t9_female t9_educ i.t9_region i.t9_wave, vce(cluster t9_id)
    estimates store t9_req_fe_wage_fallback
}

mi svyset t9_psu [pweight=t9_pweight], strata(t9_strata)
mi estimate, post: svy: mean t9_income t9_wage t9_health_score
estimates store t9_req_svy_mean
mi estimate, post: svy: regress t9_income t9_age t9_female t9_educ
estimates store t9_req_svy_regress

mi xtset t9_id t9_wave
mi estimate, post: xtreg t9_income t9_treat t9_age t9_female t9_educ, re
estimates store t9_req_xtreg_re
mi estimate, post: regress t9_income t9_treat t9_age t9_female t9_educ i.t9_id i.t9_wave, vce(cluster t9_id)
estimates store t9_req_twfe_regress

display as result "<<< DONE Section 7: required MI estimates"
// #endregion Section 7

// #region Section 8: MI estimate marathon
display as text ">>> START Section 8: MI estimate marathon"
display as text "  OLS model 1: t9_income spec 1"
mi estimate, post: regress t9_income t9_age t9_female
estimates store t9_ols_001
display as text "  completed OLS model 1"

display as text "  OLS model 2: t9_income spec 2"
mi estimate, post: regress t9_income t9_age t9_female t9_educ
estimates store t9_ols_002
display as text "  completed OLS model 2"

display as text "  OLS model 3: t9_income spec 3"
mi estimate, post: regress t9_income t9_age t9_female t9_educ t9_exper
estimates store t9_ols_003
display as text "  completed OLS model 3"

display as text "  OLS model 4: t9_income spec 4"
mi estimate, post: regress t9_income t9_age t9_female t9_educ t9_exper i.t9_region
estimates store t9_ols_004
display as text "  completed OLS model 4"

display as text "  OLS model 5: t9_income spec 5"
mi estimate, post: regress t9_income t9_age t9_female t9_educ t9_exper i.t9_sector i.t9_wave
estimates store t9_ols_005
display as text "  completed OLS model 5"

display as text "  OLS model 6: t9_income spec 6"
mi estimate, post: regress t9_income t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
estimates store t9_ols_006
display as text "  completed OLS model 6"

display as text "  OLS model 7: t9_wage spec 1"
mi estimate, post: regress t9_wage t9_age t9_female
estimates store t9_ols_007
display as text "  completed OLS model 7"

display as text "  OLS model 8: t9_wage spec 2"
mi estimate, post: regress t9_wage t9_age t9_female t9_educ
estimates store t9_ols_008
display as text "  completed OLS model 8"

display as text "  OLS model 9: t9_wage spec 3"
mi estimate, post: regress t9_wage t9_age t9_female t9_educ t9_exper
estimates store t9_ols_009
display as text "  completed OLS model 9"

display as text "  OLS model 10: t9_wage spec 4"
mi estimate, post: regress t9_wage t9_age t9_female t9_educ t9_exper i.t9_region
estimates store t9_ols_010
display as text "  completed OLS model 10"

display as text "  OLS model 11: t9_wage spec 5"
mi estimate, post: regress t9_wage t9_age t9_female t9_educ t9_exper i.t9_sector i.t9_wave
estimates store t9_ols_011
display as text "  completed OLS model 11"

display as text "  OLS model 12: t9_wage spec 6"
mi estimate, post: regress t9_wage t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
estimates store t9_ols_012
display as text "  completed OLS model 12"

display as text "  OLS model 13: t9_hours spec 1"
mi estimate, post: regress t9_hours t9_age t9_female
estimates store t9_ols_013
display as text "  completed OLS model 13"

display as text "  OLS model 14: t9_hours spec 2"
mi estimate, post: regress t9_hours t9_age t9_female t9_educ
estimates store t9_ols_014
display as text "  completed OLS model 14"

display as text "  OLS model 15: t9_hours spec 3"
mi estimate, post: regress t9_hours t9_age t9_female t9_educ t9_exper
estimates store t9_ols_015
display as text "  completed OLS model 15"

display as text "  OLS model 16: t9_hours spec 4"
mi estimate, post: regress t9_hours t9_age t9_female t9_educ t9_exper i.t9_region
estimates store t9_ols_016
display as text "  completed OLS model 16"

display as text "  OLS model 17: t9_hours spec 5"
mi estimate, post: regress t9_hours t9_age t9_female t9_educ t9_exper i.t9_sector i.t9_wave
estimates store t9_ols_017
display as text "  completed OLS model 17"

display as text "  OLS model 18: t9_hours spec 6"
mi estimate, post: regress t9_hours t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
estimates store t9_ols_018
display as text "  completed OLS model 18"

display as text "  OLS model 19: t9_wealth spec 1"
mi estimate, post: regress t9_wealth t9_age t9_female
estimates store t9_ols_019
display as text "  completed OLS model 19"

display as text "  OLS model 20: t9_wealth spec 2"
mi estimate, post: regress t9_wealth t9_age t9_female t9_educ
estimates store t9_ols_020
display as text "  completed OLS model 20"

display as text "  OLS model 21: t9_wealth spec 3"
mi estimate, post: regress t9_wealth t9_age t9_female t9_educ t9_exper
estimates store t9_ols_021
display as text "  completed OLS model 21"

display as text "  OLS model 22: t9_wealth spec 4"
mi estimate, post: regress t9_wealth t9_age t9_female t9_educ t9_exper i.t9_region
estimates store t9_ols_022
display as text "  completed OLS model 22"

display as text "  OLS model 23: t9_wealth spec 5"
mi estimate, post: regress t9_wealth t9_age t9_female t9_educ t9_exper i.t9_sector i.t9_wave
estimates store t9_ols_023
display as text "  completed OLS model 23"

display as text "  OLS model 24: t9_wealth spec 6"
mi estimate, post: regress t9_wealth t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
estimates store t9_ols_024
display as text "  completed OLS model 24"

display as text "  OLS model 25: t9_savings spec 1"
mi estimate, post: regress t9_savings t9_age t9_female
estimates store t9_ols_025
display as text "  completed OLS model 25"

display as text "  OLS model 26: t9_savings spec 2"
mi estimate, post: regress t9_savings t9_age t9_female t9_educ
estimates store t9_ols_026
display as text "  completed OLS model 26"

display as text "  OLS model 27: t9_savings spec 3"
mi estimate, post: regress t9_savings t9_age t9_female t9_educ t9_exper
estimates store t9_ols_027
display as text "  completed OLS model 27"

display as text "  OLS model 28: t9_savings spec 4"
mi estimate, post: regress t9_savings t9_age t9_female t9_educ t9_exper i.t9_region
estimates store t9_ols_028
display as text "  completed OLS model 28"

display as text "  OLS model 29: t9_savings spec 5"
mi estimate, post: regress t9_savings t9_age t9_female t9_educ t9_exper i.t9_sector i.t9_wave
estimates store t9_ols_029
display as text "  completed OLS model 29"

display as text "  OLS model 30: t9_savings spec 6"
mi estimate, post: regress t9_savings t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
estimates store t9_ols_030
display as text "  completed OLS model 30"

display as text "  OLS model 31: t9_expenditure spec 1"
mi estimate, post: regress t9_expenditure t9_age t9_female
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 31"

display as text "  OLS model 32: t9_expenditure spec 2"
mi estimate, post: regress t9_expenditure t9_age t9_female t9_educ
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 32"

display as text "  OLS model 33: t9_expenditure spec 3"
mi estimate, post: regress t9_expenditure t9_age t9_female t9_educ t9_exper
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 33"

display as text "  OLS model 34: t9_expenditure spec 4"
mi estimate, post: regress t9_expenditure t9_age t9_female t9_educ t9_exper i.t9_region
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 34"

display as text "  OLS model 35: t9_expenditure spec 5"
mi estimate, post: regress t9_expenditure t9_age t9_female t9_educ t9_exper i.t9_sector i.t9_wave
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 35"

display as text "  OLS model 36: t9_expenditure spec 6"
mi estimate, post: regress t9_expenditure t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 36"

display as text "  OLS model 37: t9_health_score spec 1"
mi estimate, post: regress t9_health_score t9_age t9_female
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 37"

display as text "  OLS model 38: t9_health_score spec 2"
mi estimate, post: regress t9_health_score t9_age t9_female t9_educ
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 38"

display as text "  OLS model 39: t9_health_score spec 3"
mi estimate, post: regress t9_health_score t9_age t9_female t9_educ t9_exper
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 39"

display as text "  OLS model 40: t9_health_score spec 4"
mi estimate, post: regress t9_health_score t9_age t9_female t9_educ t9_exper i.t9_region
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 40"

display as text "  OLS model 41: t9_health_score spec 5"
mi estimate, post: regress t9_health_score t9_age t9_female t9_educ t9_exper i.t9_sector i.t9_wave
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 41"

display as text "  OLS model 42: t9_health_score spec 6"
mi estimate, post: regress t9_health_score t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 42"

display as text "  OLS model 43: t9_bmi spec 1"
mi estimate, post: regress t9_bmi t9_age t9_female
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 43"

display as text "  OLS model 44: t9_bmi spec 2"
mi estimate, post: regress t9_bmi t9_age t9_female t9_educ
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 44"

display as text "  OLS model 45: t9_bmi spec 3"
mi estimate, post: regress t9_bmi t9_age t9_female t9_educ t9_exper
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 45"

display as text "  OLS model 46: t9_bmi spec 4"
mi estimate, post: regress t9_bmi t9_age t9_female t9_educ t9_exper i.t9_region
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 46"

display as text "  OLS model 47: t9_bmi spec 5"
mi estimate, post: regress t9_bmi t9_age t9_female t9_educ t9_exper i.t9_sector i.t9_wave
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 47"

display as text "  OLS model 48: t9_bmi spec 6"
mi estimate, post: regress t9_bmi t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 48"

display as text "  OLS model 49: t9_bp_sys spec 1"
mi estimate, post: regress t9_bp_sys t9_age t9_female
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 49"

display as text "  OLS model 50: t9_bp_sys spec 2"
mi estimate, post: regress t9_bp_sys t9_age t9_female t9_educ
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 50"

display as text "  OLS model 51: t9_bp_sys spec 3"
mi estimate, post: regress t9_bp_sys t9_age t9_female t9_educ t9_exper
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 51"

display as text "  OLS model 52: t9_bp_sys spec 4"
mi estimate, post: regress t9_bp_sys t9_age t9_female t9_educ t9_exper i.t9_region
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 52"

display as text "  OLS model 53: t9_bp_sys spec 5"
mi estimate, post: regress t9_bp_sys t9_age t9_female t9_educ t9_exper i.t9_sector i.t9_wave
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 53"

display as text "  OLS model 54: t9_bp_sys spec 6"
mi estimate, post: regress t9_bp_sys t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 54"

display as text "  OLS model 55: t9_bp_dia spec 1"
mi estimate, post: regress t9_bp_dia t9_age t9_female
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 55"

display as text "  OLS model 56: t9_bp_dia spec 2"
mi estimate, post: regress t9_bp_dia t9_age t9_female t9_educ
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 56"

display as text "  OLS model 57: t9_bp_dia spec 3"
mi estimate, post: regress t9_bp_dia t9_age t9_female t9_educ t9_exper
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 57"

display as text "  OLS model 58: t9_bp_dia spec 4"
mi estimate, post: regress t9_bp_dia t9_age t9_female t9_educ t9_exper i.t9_region
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 58"

display as text "  OLS model 59: t9_bp_dia spec 5"
mi estimate, post: regress t9_bp_dia t9_age t9_female t9_educ t9_exper i.t9_sector i.t9_wave
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 59"

display as text "  OLS model 60: t9_bp_dia spec 6"
mi estimate, post: regress t9_bp_dia t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 60"

display as text "  OLS model 61: t9_depression spec 1"
mi estimate, post: regress t9_depression t9_age t9_female
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 61"

display as text "  OLS model 62: t9_depression spec 2"
mi estimate, post: regress t9_depression t9_age t9_female t9_educ
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 62"

display as text "  OLS model 63: t9_depression spec 3"
mi estimate, post: regress t9_depression t9_age t9_female t9_educ t9_exper
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 63"

display as text "  OLS model 64: t9_depression spec 4"
mi estimate, post: regress t9_depression t9_age t9_female t9_educ t9_exper i.t9_region
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 64"

display as text "  OLS model 65: t9_depression spec 5"
mi estimate, post: regress t9_depression t9_age t9_female t9_educ t9_exper i.t9_sector i.t9_wave
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 65"

display as text "  OLS model 66: t9_depression spec 6"
mi estimate, post: regress t9_depression t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 66"

display as text "  OLS model 67: t9_stress spec 1"
mi estimate, post: regress t9_stress t9_age t9_female
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 67"

display as text "  OLS model 68: t9_stress spec 2"
mi estimate, post: regress t9_stress t9_age t9_female t9_educ
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 68"

display as text "  OLS model 69: t9_stress spec 3"
mi estimate, post: regress t9_stress t9_age t9_female t9_educ t9_exper
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 69"

display as text "  OLS model 70: t9_stress spec 4"
mi estimate, post: regress t9_stress t9_age t9_female t9_educ t9_exper i.t9_region
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 70"

display as text "  OLS model 71: t9_stress spec 5"
mi estimate, post: regress t9_stress t9_age t9_female t9_educ t9_exper i.t9_sector i.t9_wave
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 71"

display as text "  OLS model 72: t9_stress spec 6"
mi estimate, post: regress t9_stress t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 72"

display as text "  OLS model 73: t9_satisfaction spec 1"
mi estimate, post: regress t9_satisfaction t9_age t9_female
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 73"

display as text "  OLS model 74: t9_satisfaction spec 2"
mi estimate, post: regress t9_satisfaction t9_age t9_female t9_educ
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 74"

display as text "  OLS model 75: t9_satisfaction spec 3"
mi estimate, post: regress t9_satisfaction t9_age t9_female t9_educ t9_exper
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 75"

display as text "  OLS model 76: t9_satisfaction spec 4"
mi estimate, post: regress t9_satisfaction t9_age t9_female t9_educ t9_exper i.t9_region
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 76"

display as text "  OLS model 77: t9_satisfaction spec 5"
mi estimate, post: regress t9_satisfaction t9_age t9_female t9_educ t9_exper i.t9_sector i.t9_wave
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 77"

display as text "  OLS model 78: t9_satisfaction spec 6"
mi estimate, post: regress t9_satisfaction t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 78"

display as text "  OLS model 79: t9_sleep spec 1"
mi estimate, post: regress t9_sleep t9_age t9_female
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 79"

display as text "  OLS model 80: t9_sleep spec 2"
mi estimate, post: regress t9_sleep t9_age t9_female t9_educ
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 80"

display as text "  OLS model 81: t9_sleep spec 3"
mi estimate, post: regress t9_sleep t9_age t9_female t9_educ t9_exper
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 81"

display as text "  OLS model 82: t9_sleep spec 4"
mi estimate, post: regress t9_sleep t9_age t9_female t9_educ t9_exper i.t9_region
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 82"

display as text "  OLS model 83: t9_sleep spec 5"
mi estimate, post: regress t9_sleep t9_age t9_female t9_educ t9_exper i.t9_sector i.t9_wave
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 83"

display as text "  OLS model 84: t9_sleep spec 6"
mi estimate, post: regress t9_sleep t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 84"

display as text "  OLS model 85: t9_exercise spec 1"
mi estimate, post: regress t9_exercise t9_age t9_female
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 85"

display as text "  OLS model 86: t9_exercise spec 2"
mi estimate, post: regress t9_exercise t9_age t9_female t9_educ
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 86"

display as text "  OLS model 87: t9_exercise spec 3"
mi estimate, post: regress t9_exercise t9_age t9_female t9_educ t9_exper
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 87"

display as text "  OLS model 88: t9_exercise spec 4"
mi estimate, post: regress t9_exercise t9_age t9_female t9_educ t9_exper i.t9_region
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 88"

display as text "  OLS model 89: t9_exercise spec 5"
mi estimate, post: regress t9_exercise t9_age t9_female t9_educ t9_exper i.t9_sector i.t9_wave
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 89"

display as text "  OLS model 90: t9_exercise spec 6"
mi estimate, post: regress t9_exercise t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_tmp_b = e(b)
display as text "  completed OLS model 90"

display as text "  LOGIT model 91: t9_employed spec 1"
mi estimate, post: logit t9_employed t9_age t9_female
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 91"

display as text "  LOGIT model 92: t9_employed spec 2"
mi estimate, post: logit t9_employed t9_age t9_female t9_educ
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 92"

display as text "  LOGIT model 93: t9_employed spec 3"
mi estimate, post: logit t9_employed t9_age t9_female t9_educ t9_exper
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 93"

display as text "  LOGIT model 94: t9_employed spec 4"
mi estimate, post: logit t9_employed t9_age t9_female t9_educ t9_exper i.t9_region
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 94"

display as text "  LOGIT model 95: t9_married spec 1"
mi estimate, post: logit t9_married t9_age t9_female
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 95"

display as text "  LOGIT model 96: t9_married spec 2"
mi estimate, post: logit t9_married t9_age t9_female t9_educ
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 96"

display as text "  LOGIT model 97: t9_married spec 3"
mi estimate, post: logit t9_married t9_age t9_female t9_educ t9_exper
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 97"

display as text "  LOGIT model 98: t9_married spec 4"
mi estimate, post: logit t9_married t9_age t9_female t9_educ t9_exper i.t9_region
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 98"

display as text "  LOGIT model 99: t9_urban spec 1"
mi estimate, post: logit t9_urban t9_age t9_female
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 99"

display as text "  LOGIT model 100: t9_urban spec 2"
mi estimate, post: logit t9_urban t9_age t9_female t9_educ
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 100"

display as text "  LOGIT model 101: t9_urban spec 3"
mi estimate, post: logit t9_urban t9_age t9_female t9_educ t9_exper
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 101"

display as text "  LOGIT model 102: t9_urban spec 4"
mi estimate, post: logit t9_urban t9_age t9_female t9_educ t9_exper i.t9_region
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 102"

display as text "  LOGIT model 103: t9_homeowner spec 1"
mi estimate, post: logit t9_homeowner t9_age t9_female
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 103"

display as text "  LOGIT model 104: t9_homeowner spec 2"
mi estimate, post: logit t9_homeowner t9_age t9_female t9_educ
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 104"

display as text "  LOGIT model 105: t9_homeowner spec 3"
mi estimate, post: logit t9_homeowner t9_age t9_female t9_educ t9_exper
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 105"

display as text "  LOGIT model 106: t9_homeowner spec 4"
mi estimate, post: logit t9_homeowner t9_age t9_female t9_educ t9_exper i.t9_region
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 106"

display as text "  LOGIT model 107: t9_insured spec 1"
mi estimate, post: logit t9_insured t9_age t9_female
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 107"

display as text "  LOGIT model 108: t9_insured spec 2"
mi estimate, post: logit t9_insured t9_age t9_female t9_educ
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 108"

display as text "  LOGIT model 109: t9_insured spec 3"
mi estimate, post: logit t9_insured t9_age t9_female t9_educ t9_exper
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 109"

display as text "  LOGIT model 110: t9_insured spec 4"
mi estimate, post: logit t9_insured t9_age t9_female t9_educ t9_exper i.t9_region
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 110"

display as text "  LOGIT model 111: t9_smoker spec 1"
mi estimate, post: logit t9_smoker t9_age t9_female
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 111"

display as text "  LOGIT model 112: t9_smoker spec 2"
mi estimate, post: logit t9_smoker t9_age t9_female t9_educ
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 112"

display as text "  LOGIT model 113: t9_smoker spec 3"
mi estimate, post: logit t9_smoker t9_age t9_female t9_educ t9_exper
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 113"

display as text "  LOGIT model 114: t9_smoker spec 4"
mi estimate, post: logit t9_smoker t9_age t9_female t9_educ t9_exper i.t9_region
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 114"

display as text "  LOGIT model 115: t9_high_income spec 1"
mi estimate, post: logit t9_high_income t9_age t9_female
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 115"

display as text "  LOGIT model 116: t9_high_income spec 2"
mi estimate, post: logit t9_high_income t9_age t9_female t9_educ
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 116"

display as text "  LOGIT model 117: t9_high_income spec 3"
mi estimate, post: logit t9_high_income t9_age t9_female t9_educ t9_exper
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 117"

display as text "  LOGIT model 118: t9_high_income spec 4"
mi estimate, post: logit t9_high_income t9_age t9_female t9_educ t9_exper t9_local_unemp
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 118"

display as text "  LOGIT model 119: t9_high_stress spec 1"
mi estimate, post: logit t9_high_stress t9_age t9_female
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 119"

display as text "  LOGIT model 120: t9_high_stress spec 2"
mi estimate, post: logit t9_high_stress t9_age t9_female t9_educ
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 120"

display as text "  LOGIT model 121: t9_high_stress spec 3"
mi estimate, post: logit t9_high_stress t9_age t9_female t9_educ t9_exper
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 121"

display as text "  LOGIT model 122: t9_high_stress spec 4"
mi estimate, post: logit t9_high_stress t9_age t9_female t9_educ t9_exper t9_local_unemp
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 122"

display as text "  LOGIT model 123: t9_unhealthy spec 1"
mi estimate, post: logit t9_unhealthy t9_age t9_female
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 123"

display as text "  LOGIT model 124: t9_unhealthy spec 2"
mi estimate, post: logit t9_unhealthy t9_age t9_female t9_educ
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 124"

display as text "  LOGIT model 125: t9_unhealthy spec 3"
mi estimate, post: logit t9_unhealthy t9_age t9_female t9_educ t9_exper
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 125"

display as text "  LOGIT model 126: t9_unhealthy spec 4"
mi estimate, post: logit t9_unhealthy t9_age t9_female t9_educ t9_exper t9_local_unemp
matrix t9_tmp_b = e(b)
display as text "  completed LOGIT model 126"

display as text "  OLOGIT model 127: t9_educ_level spec 1"
mi estimate, post: ologit t9_educ_level t9_age t9_female
matrix t9_tmp_b = e(b)
display as text "  completed OLOGIT model 127"

display as text "  OLOGIT model 128: t9_educ_level spec 2"
mi estimate, post: ologit t9_educ_level t9_age t9_female t9_educ
matrix t9_tmp_b = e(b)
display as text "  completed OLOGIT model 128"

display as text "  OLOGIT model 129: t9_educ_level spec 3"
mi estimate, post: ologit t9_educ_level t9_age t9_female t9_educ t9_exper
matrix t9_tmp_b = e(b)
display as text "  completed OLOGIT model 129"

display as text "  OLOGIT model 130: t9_educ_level spec 4"
mi estimate, post: ologit t9_educ_level t9_age t9_female t9_educ t9_exper i.t9_region
matrix t9_tmp_b = e(b)
display as text "  completed OLOGIT model 130"

display as text "  OLOGIT model 131: t9_health_level spec 1"
mi estimate, post: ologit t9_health_level t9_age t9_female
matrix t9_tmp_b = e(b)
display as text "  completed OLOGIT model 131"

display as text "  OLOGIT model 132: t9_health_level spec 2"
mi estimate, post: ologit t9_health_level t9_age t9_female t9_educ
matrix t9_tmp_b = e(b)
display as text "  completed OLOGIT model 132"

display as text "  OLOGIT model 133: t9_health_level spec 3"
mi estimate, post: ologit t9_health_level t9_age t9_female t9_educ t9_exper
matrix t9_tmp_b = e(b)
display as text "  completed OLOGIT model 133"

display as text "  OLOGIT model 134: t9_health_level spec 4"
mi estimate, post: ologit t9_health_level t9_age t9_female t9_educ t9_exper i.t9_region
matrix t9_tmp_b = e(b)
display as text "  completed OLOGIT model 134"

display as text "  OLOGIT model 135: t9_job_sat spec 1"
mi estimate, post: ologit t9_job_sat t9_age t9_female
matrix t9_tmp_b = e(b)
display as text "  completed OLOGIT model 135"

display as text "  OLOGIT model 136: t9_job_sat spec 2"
mi estimate, post: ologit t9_job_sat t9_age t9_female t9_educ
matrix t9_tmp_b = e(b)
display as text "  completed OLOGIT model 136"

display as text "  OLOGIT model 137: t9_job_sat spec 3"
mi estimate, post: ologit t9_job_sat t9_age t9_female t9_educ t9_exper
matrix t9_tmp_b = e(b)
display as text "  completed OLOGIT model 137"

display as text "  OLOGIT model 138: t9_job_sat spec 4"
mi estimate, post: ologit t9_job_sat t9_age t9_female t9_educ t9_exper i.t9_region
matrix t9_tmp_b = e(b)
display as text "  completed OLOGIT model 138"

display as text "  POISSON model 139: t9_children spec 1"
mi estimate, post: poisson t9_children t9_age t9_female
matrix t9_tmp_b = e(b)
display as text "  completed POISSON model 139"

display as text "  POISSON model 140: t9_children spec 2"
mi estimate, post: poisson t9_children t9_age t9_female t9_educ
matrix t9_tmp_b = e(b)
display as text "  completed POISSON model 140"

display as text "  POISSON model 141: t9_children spec 3"
mi estimate, post: poisson t9_children t9_age t9_female t9_educ t9_exper
matrix t9_tmp_b = e(b)
display as text "  completed POISSON model 141"

display as text "  POISSON model 142: t9_children spec 4"
mi estimate, post: poisson t9_children t9_age t9_female t9_educ t9_exper i.t9_region
matrix t9_tmp_b = e(b)
display as text "  completed POISSON model 142"

display as text "  POISSON model 143: t9_doctor_visits spec 1"
mi estimate, post: poisson t9_doctor_visits t9_age t9_female
matrix t9_tmp_b = e(b)
display as text "  completed POISSON model 143"

display as text "  POISSON model 144: t9_doctor_visits spec 2"
mi estimate, post: poisson t9_doctor_visits t9_age t9_female t9_educ
matrix t9_tmp_b = e(b)
display as text "  completed POISSON model 144"

display as text "  POISSON model 145: t9_doctor_visits spec 3"
mi estimate, post: poisson t9_doctor_visits t9_age t9_female t9_educ t9_exper
matrix t9_tmp_b = e(b)
display as text "  completed POISSON model 145"

display as text "  POISSON model 146: t9_doctor_visits spec 4"
mi estimate, post: poisson t9_doctor_visits t9_age t9_female t9_educ t9_exper i.t9_region
matrix t9_tmp_b = e(b)
display as text "  completed POISSON model 146"

display as text "  POISSON model 147: t9_hosp_days spec 1"
mi estimate, post: poisson t9_hosp_days t9_age t9_female
matrix t9_tmp_b = e(b)
display as text "  completed POISSON model 147"

display as text "  POISSON model 148: t9_hosp_days spec 2"
mi estimate, post: poisson t9_hosp_days t9_age t9_female t9_educ
matrix t9_tmp_b = e(b)
display as text "  completed POISSON model 148"

display as text "  POISSON model 149: t9_hosp_days spec 3"
mi estimate, post: poisson t9_hosp_days t9_age t9_female t9_educ t9_exper
matrix t9_tmp_b = e(b)
display as text "  completed POISSON model 149"

display as text "  POISSON model 150: t9_hosp_days spec 4"
mi estimate, post: poisson t9_hosp_days t9_age t9_female t9_educ t9_exper i.t9_region
matrix t9_tmp_b = e(b)
display as text "  completed POISSON model 150"

display as text "--- Section 8 complete: 150 systematic MI models ---"
// #endregion Section 8
// #region Section 9: trace diagnostics and MI xeq

display as text ">>> START Section 9: trace diagnostics and mi xeq"
preserve
    use "${tempdir}/taught_task9_trace.dta", clear
    describe
    capture confirm variable t9_income_mean
    if _rc == 0 {
        twoway line t9_income_mean iter if m==1, sort name(t9g_trace_income, replace) title("Trace: income mean")
        graph export "$figdir9/t9g_trace_income.png", name(t9g_trace_income) replace width(1400)
    }
    capture confirm variable t9_wage_mean
    if _rc == 0 {
        twoway line t9_wage_mean iter if m==1, sort name(t9g_trace_wage, replace) title("Trace: wage mean")
        graph export "$figdir9/t9g_trace_wage.png", name(t9g_trace_wage) replace width(1400)
    }
restore

mi xeq 0: summarize t9_income t9_wage t9_depression t9_health_score
mi xeq 1: summarize t9_income t9_wage t9_depression t9_health_score
mi xeq 2: summarize t9_income t9_wage t9_depression t9_health_score
mi xeq 3: summarize t9_income t9_wage t9_depression t9_health_score
mi xeq 4: summarize t9_income t9_wage t9_depression t9_health_score
mi xeq 5: summarize t9_income t9_wage t9_depression t9_health_score
mi xeq 1/5: regress t9_income t9_age t9_female t9_educ
mi xeq 1/5: regress t9_depression t9_age t9_female t9_income

display as result "<<< DONE Section 9: trace diagnostics and mi xeq"
// #endregion Section 9

// #region Section 10: graph stress output
display as text ">>> START Section 10: graph stress output"
display as text "  Graph 1: histogram t9_income"
histogram t9_income if _mi_m == 0, name(t9g_hist_001, replace) title("m0 histogram: t9_income")
graph export "$figdir9/t9g_hist_001.png", name(t9g_hist_001) replace width(1200)

display as text "  Graph 2: box by imputation t9_income"
graph box t9_income if _mi_m <= 5, over(_mi_m) name(t9g_box_002, replace) title("By imputation: t9_income")
graph export "$figdir9/t9g_box_002.png", name(t9g_box_002) replace width(1200)

display as text "  Graph 3: histogram t9_wage"
histogram t9_wage if _mi_m == 0, name(t9g_hist_003, replace) title("m0 histogram: t9_wage")
graph export "$figdir9/t9g_hist_003.png", name(t9g_hist_003) replace width(1200)

display as text "  Graph 4: box by imputation t9_wage"
graph box t9_wage if _mi_m <= 5, over(_mi_m) name(t9g_box_004, replace) title("By imputation: t9_wage")
graph export "$figdir9/t9g_box_004.png", name(t9g_box_004) replace width(1200)

display as text "  Graph 5: histogram t9_hours"
histogram t9_hours if _mi_m == 0, name(t9g_hist_005, replace) title("m0 histogram: t9_hours")
graph export "$figdir9/t9g_hist_005.png", name(t9g_hist_005) replace width(1200)

display as text "  Graph 6: box by imputation t9_hours"
graph box t9_hours if _mi_m <= 5, over(_mi_m) name(t9g_box_006, replace) title("By imputation: t9_hours")
graph export "$figdir9/t9g_box_006.png", name(t9g_box_006) replace width(1200)

display as text "  Graph 7: histogram t9_wealth"
histogram t9_wealth if _mi_m == 0, name(t9g_hist_007, replace) title("m0 histogram: t9_wealth")
graph export "$figdir9/t9g_hist_007.png", name(t9g_hist_007) replace width(1200)

display as text "  Graph 8: box by imputation t9_wealth"
graph box t9_wealth if _mi_m <= 5, over(_mi_m) name(t9g_box_008, replace) title("By imputation: t9_wealth")
graph export "$figdir9/t9g_box_008.png", name(t9g_box_008) replace width(1200)

display as text "  Graph 9: histogram t9_savings"
histogram t9_savings if _mi_m == 0, name(t9g_hist_009, replace) title("m0 histogram: t9_savings")
graph export "$figdir9/t9g_hist_009.png", name(t9g_hist_009) replace width(1200)

display as text "  Graph 10: box by imputation t9_savings"
graph box t9_savings if _mi_m <= 5, over(_mi_m) name(t9g_box_010, replace) title("By imputation: t9_savings")
graph export "$figdir9/t9g_box_010.png", name(t9g_box_010) replace width(1200)

display as text "  Graph 11: histogram t9_expenditure"
histogram t9_expenditure if _mi_m == 0, name(t9g_hist_011, replace) title("m0 histogram: t9_expenditure")
graph export "$figdir9/t9g_hist_011.png", name(t9g_hist_011) replace width(1200)

display as text "  Graph 12: box by imputation t9_expenditure"
graph box t9_expenditure if _mi_m <= 5, over(_mi_m) name(t9g_box_012, replace) title("By imputation: t9_expenditure")
graph export "$figdir9/t9g_box_012.png", name(t9g_box_012) replace width(1200)

display as text "  Graph 13: histogram t9_health_score"
histogram t9_health_score if _mi_m == 0, name(t9g_hist_013, replace) title("m0 histogram: t9_health_score")
graph export "$figdir9/t9g_hist_013.png", name(t9g_hist_013) replace width(1200)

display as text "  Graph 14: box by imputation t9_health_score"
graph box t9_health_score if _mi_m <= 5, over(_mi_m) name(t9g_box_014, replace) title("By imputation: t9_health_score")
graph export "$figdir9/t9g_box_014.png", name(t9g_box_014) replace width(1200)

display as text "  Graph 15: histogram t9_bmi"
histogram t9_bmi if _mi_m == 0, name(t9g_hist_015, replace) title("m0 histogram: t9_bmi")
graph export "$figdir9/t9g_hist_015.png", name(t9g_hist_015) replace width(1200)

display as text "  Graph 16: box by imputation t9_bmi"
graph box t9_bmi if _mi_m <= 5, over(_mi_m) name(t9g_box_016, replace) title("By imputation: t9_bmi")
graph export "$figdir9/t9g_box_016.png", name(t9g_box_016) replace width(1200)

display as text "  Graph 17: histogram t9_bp_sys"
histogram t9_bp_sys if _mi_m == 0, name(t9g_hist_017, replace) title("m0 histogram: t9_bp_sys")
graph export "$figdir9/t9g_hist_017.png", name(t9g_hist_017) replace width(1200)

display as text "  Graph 18: box by imputation t9_bp_sys"
graph box t9_bp_sys if _mi_m <= 5, over(_mi_m) name(t9g_box_018, replace) title("By imputation: t9_bp_sys")
graph export "$figdir9/t9g_box_018.png", name(t9g_box_018) replace width(1200)

display as text "  Graph 19: histogram t9_bp_dia"
histogram t9_bp_dia if _mi_m == 0, name(t9g_hist_019, replace) title("m0 histogram: t9_bp_dia")
graph export "$figdir9/t9g_hist_019.png", name(t9g_hist_019) replace width(1200)

display as text "  Graph 20: box by imputation t9_bp_dia"
graph box t9_bp_dia if _mi_m <= 5, over(_mi_m) name(t9g_box_020, replace) title("By imputation: t9_bp_dia")
graph export "$figdir9/t9g_box_020.png", name(t9g_box_020) replace width(1200)

display as text "  Graph 21: histogram t9_depression"
histogram t9_depression if _mi_m == 0, name(t9g_hist_021, replace) title("m0 histogram: t9_depression")
graph export "$figdir9/t9g_hist_021.png", name(t9g_hist_021) replace width(1200)

display as text "  Graph 22: box by imputation t9_depression"
graph box t9_depression if _mi_m <= 5, over(_mi_m) name(t9g_box_022, replace) title("By imputation: t9_depression")
graph export "$figdir9/t9g_box_022.png", name(t9g_box_022) replace width(1200)

display as text "  Graph 23: histogram t9_stress"
histogram t9_stress if _mi_m == 0, name(t9g_hist_023, replace) title("m0 histogram: t9_stress")
graph export "$figdir9/t9g_hist_023.png", name(t9g_hist_023) replace width(1200)

display as text "  Graph 24: box by imputation t9_stress"
graph box t9_stress if _mi_m <= 5, over(_mi_m) name(t9g_box_024, replace) title("By imputation: t9_stress")
graph export "$figdir9/t9g_box_024.png", name(t9g_box_024) replace width(1200)

display as text "  Graph 25: histogram t9_satisfaction"
histogram t9_satisfaction if _mi_m == 0, name(t9g_hist_025, replace) title("m0 histogram: t9_satisfaction")
graph export "$figdir9/t9g_hist_025.png", name(t9g_hist_025) replace width(1200)

display as text "  Graph 26: box by imputation t9_satisfaction"
graph box t9_satisfaction if _mi_m <= 5, over(_mi_m) name(t9g_box_026, replace) title("By imputation: t9_satisfaction")
graph export "$figdir9/t9g_box_026.png", name(t9g_box_026) replace width(1200)

display as text "  Graph 27: histogram t9_sleep"
histogram t9_sleep if _mi_m == 0, name(t9g_hist_027, replace) title("m0 histogram: t9_sleep")
graph export "$figdir9/t9g_hist_027.png", name(t9g_hist_027) replace width(1200)

display as text "  Graph 28: box by imputation t9_sleep"
graph box t9_sleep if _mi_m <= 5, over(_mi_m) name(t9g_box_028, replace) title("By imputation: t9_sleep")
graph export "$figdir9/t9g_box_028.png", name(t9g_box_028) replace width(1200)

display as text "  Graph 29: histogram t9_exercise"
histogram t9_exercise if _mi_m == 0, name(t9g_hist_029, replace) title("m0 histogram: t9_exercise")
graph export "$figdir9/t9g_hist_029.png", name(t9g_hist_029) replace width(1200)

display as text "  Graph 30: box by imputation t9_exercise"
graph box t9_exercise if _mi_m <= 5, over(_mi_m) name(t9g_box_030, replace) title("By imputation: t9_exercise")
graph export "$figdir9/t9g_box_030.png", name(t9g_box_030) replace width(1200)

display as text "  Graph 31: observed vs imputed scatter t9_income"
twoway (scatter t9_income t9_age if _mi_m == 0, mcolor(blue%35) msymbol(o)) (scatter t9_income t9_age if _mi_m == 1, mcolor(red%35) msymbol(x)), legend(label(1 "m=0") label(2 "m=1")) title("t9_income by age") name(t9g_scatter_031, replace)
graph export "$figdir9/t9g_scatter_031.png", name(t9g_scatter_031) replace width(1200)

display as text "  Graph 32: observed vs imputed scatter t9_wage"
twoway (scatter t9_wage t9_age if _mi_m == 0, mcolor(blue%35) msymbol(o)) (scatter t9_wage t9_age if _mi_m == 1, mcolor(red%35) msymbol(x)), legend(label(1 "m=0") label(2 "m=1")) title("t9_wage by age") name(t9g_scatter_032, replace)
graph export "$figdir9/t9g_scatter_032.png", name(t9g_scatter_032) replace width(1200)

display as text "  Graph 33: observed vs imputed scatter t9_hours"
twoway (scatter t9_hours t9_age if _mi_m == 0, mcolor(blue%35) msymbol(o)) (scatter t9_hours t9_age if _mi_m == 1, mcolor(red%35) msymbol(x)), legend(label(1 "m=0") label(2 "m=1")) title("t9_hours by age") name(t9g_scatter_033, replace)
graph export "$figdir9/t9g_scatter_033.png", name(t9g_scatter_033) replace width(1200)

display as text "  Graph 34: observed vs imputed scatter t9_wealth"
twoway (scatter t9_wealth t9_age if _mi_m == 0, mcolor(blue%35) msymbol(o)) (scatter t9_wealth t9_age if _mi_m == 1, mcolor(red%35) msymbol(x)), legend(label(1 "m=0") label(2 "m=1")) title("t9_wealth by age") name(t9g_scatter_034, replace)
graph export "$figdir9/t9g_scatter_034.png", name(t9g_scatter_034) replace width(1200)

display as text "  Graph 35: observed vs imputed scatter t9_savings"
twoway (scatter t9_savings t9_age if _mi_m == 0, mcolor(blue%35) msymbol(o)) (scatter t9_savings t9_age if _mi_m == 1, mcolor(red%35) msymbol(x)), legend(label(1 "m=0") label(2 "m=1")) title("t9_savings by age") name(t9g_scatter_035, replace)
graph export "$figdir9/t9g_scatter_035.png", name(t9g_scatter_035) replace width(1200)

display as text "  Graph 36: observed vs imputed scatter t9_expenditure"
twoway (scatter t9_expenditure t9_age if _mi_m == 0, mcolor(blue%35) msymbol(o)) (scatter t9_expenditure t9_age if _mi_m == 1, mcolor(red%35) msymbol(x)), legend(label(1 "m=0") label(2 "m=1")) title("t9_expenditure by age") name(t9g_scatter_036, replace)
graph export "$figdir9/t9g_scatter_036.png", name(t9g_scatter_036) replace width(1200)

display as text "  Graph 37: observed vs imputed scatter t9_health_score"
twoway (scatter t9_health_score t9_age if _mi_m == 0, mcolor(blue%35) msymbol(o)) (scatter t9_health_score t9_age if _mi_m == 1, mcolor(red%35) msymbol(x)), legend(label(1 "m=0") label(2 "m=1")) title("t9_health_score by age") name(t9g_scatter_037, replace)
graph export "$figdir9/t9g_scatter_037.png", name(t9g_scatter_037) replace width(1200)

display as text "  Graph 38: observed vs imputed scatter t9_bmi"
twoway (scatter t9_bmi t9_age if _mi_m == 0, mcolor(blue%35) msymbol(o)) (scatter t9_bmi t9_age if _mi_m == 1, mcolor(red%35) msymbol(x)), legend(label(1 "m=0") label(2 "m=1")) title("t9_bmi by age") name(t9g_scatter_038, replace)
graph export "$figdir9/t9g_scatter_038.png", name(t9g_scatter_038) replace width(1200)

display as text "  Graph 39: observed vs imputed scatter t9_bp_sys"
twoway (scatter t9_bp_sys t9_age if _mi_m == 0, mcolor(blue%35) msymbol(o)) (scatter t9_bp_sys t9_age if _mi_m == 1, mcolor(red%35) msymbol(x)), legend(label(1 "m=0") label(2 "m=1")) title("t9_bp_sys by age") name(t9g_scatter_039, replace)
graph export "$figdir9/t9g_scatter_039.png", name(t9g_scatter_039) replace width(1200)

display as text "  Graph 40: observed vs imputed scatter t9_bp_dia"
twoway (scatter t9_bp_dia t9_age if _mi_m == 0, mcolor(blue%35) msymbol(o)) (scatter t9_bp_dia t9_age if _mi_m == 1, mcolor(red%35) msymbol(x)), legend(label(1 "m=0") label(2 "m=1")) title("t9_bp_dia by age") name(t9g_scatter_040, replace)
graph export "$figdir9/t9g_scatter_040.png", name(t9g_scatter_040) replace width(1200)

display as text "  Graph 41: observed vs imputed scatter t9_depression"
twoway (scatter t9_depression t9_age if _mi_m == 0, mcolor(blue%35) msymbol(o)) (scatter t9_depression t9_age if _mi_m == 1, mcolor(red%35) msymbol(x)), legend(label(1 "m=0") label(2 "m=1")) title("t9_depression by age") name(t9g_scatter_041, replace)
graph export "$figdir9/t9g_scatter_041.png", name(t9g_scatter_041) replace width(1200)

display as text "  Graph 42: observed vs imputed scatter t9_stress"
twoway (scatter t9_stress t9_age if _mi_m == 0, mcolor(blue%35) msymbol(o)) (scatter t9_stress t9_age if _mi_m == 1, mcolor(red%35) msymbol(x)), legend(label(1 "m=0") label(2 "m=1")) title("t9_stress by age") name(t9g_scatter_042, replace)
graph export "$figdir9/t9g_scatter_042.png", name(t9g_scatter_042) replace width(1200)

display as text "  Graph 43: wave bar t9_income"
graph bar (mean) t9_income if _mi_m == 0, over(t9_wave) name(t9g_wave_043, replace) title("Wave means: t9_income")
graph export "$figdir9/t9g_wave_043.png", name(t9g_wave_043) replace width(1200)

display as text "  Graph 44: wave bar t9_wage"
graph bar (mean) t9_wage if _mi_m == 0, over(t9_wave) name(t9g_wave_044, replace) title("Wave means: t9_wage")
graph export "$figdir9/t9g_wave_044.png", name(t9g_wave_044) replace width(1200)

display as text "  Graph 45: wave bar t9_hours"
graph bar (mean) t9_hours if _mi_m == 0, over(t9_wave) name(t9g_wave_045, replace) title("Wave means: t9_hours")
graph export "$figdir9/t9g_wave_045.png", name(t9g_wave_045) replace width(1200)

display as text "  Graph 46: wave bar t9_wealth"
graph bar (mean) t9_wealth if _mi_m == 0, over(t9_wave) name(t9g_wave_046, replace) title("Wave means: t9_wealth")
graph export "$figdir9/t9g_wave_046.png", name(t9g_wave_046) replace width(1200)

display as text "  Graph 47: wave bar t9_savings"
graph bar (mean) t9_savings if _mi_m == 0, over(t9_wave) name(t9g_wave_047, replace) title("Wave means: t9_savings")
graph export "$figdir9/t9g_wave_047.png", name(t9g_wave_047) replace width(1200)

display as text "  Graph 48: wave bar t9_expenditure"
graph bar (mean) t9_expenditure if _mi_m == 0, over(t9_wave) name(t9g_wave_048, replace) title("Wave means: t9_expenditure")
graph export "$figdir9/t9g_wave_048.png", name(t9g_wave_048) replace width(1200)

display as text "  Graph 49: wave bar t9_health_score"
graph bar (mean) t9_health_score if _mi_m == 0, over(t9_wave) name(t9g_wave_049, replace) title("Wave means: t9_health_score")
graph export "$figdir9/t9g_wave_049.png", name(t9g_wave_049) replace width(1200)

display as text "  Graph 50: wave bar t9_bmi"
graph bar (mean) t9_bmi if _mi_m == 0, over(t9_wave) name(t9g_wave_050, replace) title("Wave means: t9_bmi")
graph export "$figdir9/t9g_wave_050.png", name(t9g_wave_050) replace width(1200)

display as text "  Graph 51: wave bar t9_bp_sys"
graph bar (mean) t9_bp_sys if _mi_m == 0, over(t9_wave) name(t9g_wave_051, replace) title("Wave means: t9_bp_sys")
graph export "$figdir9/t9g_wave_051.png", name(t9g_wave_051) replace width(1200)

display as text "  Graph 52: wave bar t9_bp_dia"
graph bar (mean) t9_bp_dia if _mi_m == 0, over(t9_wave) name(t9g_wave_052, replace) title("Wave means: t9_bp_dia")
graph export "$figdir9/t9g_wave_052.png", name(t9g_wave_052) replace width(1200)

display as text "--- Section 10 complete: 52 graphs exported ---"
// #endregion Section 10
// #region Section 11: tables and documents

display as text ">>> START Section 11: tables and documents"
putexcel set "${docdir}/taught_task9_summary.xlsx", replace
putexcel A1 = "taught_task9 native MI summary"
putexcel A2 = "run" B2 = "`t9_run_stamp'"
putexcel A4 = "variable" B4 = "mean_m0" C4 = "sd_m0"
quietly summarize t9_income if _mi_m == 0
local t9_mean = r(mean)
local t9_sd = r(sd)
putexcel A5 = "t9_income" B5 = `t9_mean' C5 = `t9_sd'
quietly summarize t9_wage if _mi_m == 0
local t9_mean = r(mean)
local t9_sd = r(sd)
putexcel A6 = "t9_wage" B6 = `t9_mean' C6 = `t9_sd'
quietly summarize t9_depression if _mi_m == 0
local t9_mean = r(mean)
local t9_sd = r(sd)
putexcel A7 = "t9_depression" B7 = `t9_mean' C7 = `t9_sd'
quietly summarize t9_health_score if _mi_m == 0
local t9_mean = r(mean)
local t9_sd = r(sd)
putexcel A8 = "t9_health_score" B8 = `t9_mean' C8 = `t9_sd'

putdocx clear
putdocx begin
putdocx paragraph, style(Title)
putdocx text ("taught_task9 native Stata 18 MI stress fixture")
putdocx paragraph
putdocx text ("This document is generated after successful production MI and MI estimation.")
putdocx paragraph
putdocx text ("M = 20 imputations; file is designed for later Stata Workbench pressure testing.")
putdocx paragraph
putdocx text ("Key stored estimates include income, wage, binary, ordinal, count, survey, and panel models.")
putdocx save "${docdir}/taught_task9_report.docx", replace

p_tdocx clear
p_tdocx begin
p_tdocx paragraph, style(Title)
p_tdocx text ("taught_task9 p_tdocx compatibility report")
p_tdocx paragraph
p_tdocx text ("Generated through p_tdocx wrapper to stress document-output compatibility.")
p_tdocx save "${docdir}/taught_task9_ptdocx_report.docx", replace

display as result "<<< DONE Section 11: tables and documents"
// #endregion Section 11
// #region Section 12: preserve restore subgroup analyses

display as text ">>> START Section 12: subgroup analyses"
preserve
    mi estimate, post: regress t9_income t9_age t9_educ t9_exper i.t9_wave if t9_female == 1
    estimates store t9_sub_female_income
    mi estimate, post: regress t9_depression t9_age t9_income t9_stress if t9_female == 1
    estimates store t9_sub_female_depression
restore
preserve
    mi estimate, post: regress t9_income t9_age t9_educ t9_exper i.t9_wave if t9_female == 0
    estimates store t9_sub_male_income
    mi estimate, post: regress t9_depression t9_age t9_income t9_stress if t9_female == 0
    estimates store t9_sub_male_depression
restore
preserve
    mi estimate, post: regress t9_income t9_age t9_female t9_educ if t9_wave == 1
    estimates store t9_sub_wave1_income
restore
preserve
    mi estimate, post: regress t9_income t9_age t9_female t9_educ if t9_wave == 2
    estimates store t9_sub_wave2_income
restore
preserve
    mi estimate, post: regress t9_income t9_age t9_female t9_educ if t9_wave == 3
    estimates store t9_sub_wave3_income
restore

display as result "<<< DONE Section 12: subgroup analyses"
// #endregion Section 12

// #region Section 13: large anonymous brace block

display as text ">>> START Section 13: large brace stress block"
if 1 {
    foreach depvar in t9_income t9_wage t9_hours t9_wealth t9_depression t9_stress t9_health_score {
        forvalues m = 0/5 {
            quietly summarize `depvar' if _mi_m == `m'
            local t9_n = r(N)
            local t9_mean = r(mean)
            display as text "  brace summary `depvar' m=`m': N=`t9_n' mean=" %9.3f `t9_mean'
        }
    }
    foreach y in t9_income t9_wage t9_depression {
        foreach x in t9_age t9_educ t9_exper {
            quietly correlate `y' `x' if _mi_m == 0
            local t9_r = r(rho)
            display as text "  brace corr `y' `x': " %8.4f `t9_r'
        }
    }
    forvalues s = 1/3 {
        if `s' == 1 {
            mi estimate, post: regress t9_income t9_age t9_female t9_educ
            matrix t9_brace_b = e(b)
        }
        else if `s' == 2 {
            mi estimate, post: regress t9_wage t9_age t9_female t9_educ
            matrix t9_brace_b = e(b)
        }
        else {
            mi estimate, post: regress t9_depression t9_age t9_female t9_income
            matrix t9_brace_b = e(b)
        }
    }
}

display as result "<<< DONE Section 13: large brace stress block"
// #endregion Section 13
// #region Section 14: loop-heavy MI model family grid

display as text ">>> START Section 14: loop-heavy MI model family grid"
tempname t9_gridpost
tempfile t9_model_ledger
postfile `t9_gridpost' str18 family str24 command str32 dv int spec double nobs using `t9_model_ledger', replace

local t9_grid_models = 0
local t9_rhs1 "t9_age t9_female"
local t9_rhs2 "t9_age t9_female t9_educ"
local t9_rhs3 "t9_age t9_female t9_educ t9_exper i.t9_region"
local t9_rhs4 "t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave"
local t9_rhs5 "t9_age t9_female t9_educ t9_exper t9_treat t9_local_unemp i.t9_region i.t9_sector"
local t9_rhs6 "c.t9_age##i.t9_female t9_educ t9_exper t9_treat t9_local_unemp i.t9_region i.t9_wave"

display as text "--- Section 14A: continuous models in nested loops ---"
local t9_cont_dvs "t9_income t9_wage t9_hours t9_wealth t9_savings t9_expenditure t9_health_score t9_bmi"
foreach dv of local t9_cont_dvs {
    forvalues spec = 1/6 {
        local rhs "`t9_rhs`spec''"
        local t9_grid_models = `t9_grid_models' + 1
        local modeltag : display %03.0f `t9_grid_models'
        display as text "  GRID continuous regress model `modeltag': `dv' spec `spec'"
        if inlist(`spec', 5, 6) {
            mi estimate, post: regress `dv' `rhs', vce(cluster t9_id)
        }
        else {
            mi estimate, post: regress `dv' `rhs'
        }
        estimates store t9gm_`modeltag'
        post `t9_gridpost' ("continuous") ("regress") ("`dv'") (`spec') (e(N))
    }
}

display as text "--- Section 14B: binary logit/probit models in nested loops ---"
local t9_binary_dvs "t9_employed t9_married t9_insured t9_smoker t9_high_income t9_high_stress t9_unhealthy t9_any_hosp t9_many_visits t9_high_bp"
local t9_bin_rhs1 "t9_age t9_female"
local t9_bin_rhs2 "t9_age t9_female t9_educ"
local t9_bin_rhs3 "t9_age t9_female t9_educ t9_exper t9_local_unemp"
foreach dv of local t9_binary_dvs {
    forvalues spec = 1/3 {
        local rhs "`t9_bin_rhs`spec''"
        foreach cmd in logit probit {
            local t9_grid_models = `t9_grid_models' + 1
            local modeltag : display %03.0f `t9_grid_models'
            display as text "  GRID binary `cmd' model `modeltag': `dv' spec `spec'"
            mi estimate, post: `cmd' `dv' `rhs'
            estimates store t9gm_`modeltag'
            post `t9_gridpost' ("binary") ("`cmd'") ("`dv'") (`spec') (e(N))
        }
    }
}

display as text "--- Section 14C: ordinal ologit/oprobit models in nested loops ---"
local t9_ordinal_dvs "t9_health_level t9_job_sat t9_educ_level"
foreach dv of local t9_ordinal_dvs {
    forvalues spec = 1/3 {
        local rhs "`t9_rhs`spec''"
        foreach cmd in ologit oprobit {
            local t9_grid_models = `t9_grid_models' + 1
            local modeltag : display %03.0f `t9_grid_models'
            display as text "  GRID ordinal `cmd' model `modeltag': `dv' spec `spec'"
            mi estimate, post: `cmd' `dv' `rhs'
            estimates store t9gm_`modeltag'
            post `t9_gridpost' ("ordinal") ("`cmd'") ("`dv'") (`spec') (e(N))
        }
    }
}

display as text "--- Section 14D: nominal mlogit models in nested loops ---"
local t9_nominal_dvs "t9_occupation t9_income_q"
foreach dv of local t9_nominal_dvs {
    forvalues spec = 1/3 {
        local rhs "`t9_rhs`spec''"
        local t9_grid_models = `t9_grid_models' + 1
        local modeltag : display %03.0f `t9_grid_models'
        display as text "  GRID nominal mlogit model `modeltag': `dv' spec `spec'"
        mi estimate, post: mlogit `dv' `rhs'
        estimates store t9gm_`modeltag'
        post `t9_gridpost' ("nominal") ("mlogit") ("`dv'") (`spec') (e(N))
    }
}

display as text "--- Section 14E: count poisson/nbreg/glm models in nested loops ---"
local t9_count_dvs "t9_children t9_doctor_visits t9_hosp_days"
foreach dv of local t9_count_dvs {
    forvalues spec = 1/3 {
        local rhs "`t9_rhs`spec''"
        local t9_grid_models = `t9_grid_models' + 1
        local modeltag : display %03.0f `t9_grid_models'
        display as text "  GRID count poisson model `modeltag': `dv' spec `spec'"
        mi estimate, post: poisson `dv' `rhs'
        estimates store t9gm_`modeltag'
        post `t9_gridpost' ("count") ("poisson") ("`dv'") (`spec') (e(N))
    }
}
foreach dv in t9_doctor_visits t9_hosp_days {
    forvalues spec = 1/2 {
        local rhs "`t9_rhs`spec''"
        local t9_grid_models = `t9_grid_models' + 1
        local modeltag : display %03.0f `t9_grid_models'
        display as text "  GRID count nbreg model `modeltag': `dv' spec `spec'"
        mi estimate, post: nbreg `dv' `rhs'
        estimates store t9gm_`modeltag'
        post `t9_gridpost' ("count") ("nbreg") ("`dv'") (`spec') (e(N))
    }
}
foreach dv in t9_doctor_visits t9_hosp_days {
    local rhs "`t9_rhs3'"
    local t9_grid_models = `t9_grid_models' + 1
    local modeltag : display %03.0f `t9_grid_models'
    display as text "  GRID count glm-poisson model `modeltag': `dv'"
    mi estimate, post: glm `dv' `rhs', family(poisson) link(log)
    estimates store t9gm_`modeltag'
    post `t9_gridpost' ("count") ("glm_poisson") ("`dv'") (3) (e(N))
}

display as text "--- Section 14F: censored tobit models in nested loops ---"
foreach dv in t9_income_topcoded t9_hours_censored {
    forvalues spec = 1/3 {
        local rhs "`t9_rhs`spec''"
        local t9_grid_models = `t9_grid_models' + 1
        local modeltag : display %03.0f `t9_grid_models'
        display as text "  GRID censored tobit model `modeltag': `dv' spec `spec'"
        if "`dv'" == "t9_income_topcoded" {
            mi estimate, cmdok post: tobit `dv' `rhs', ul(120000)
        }
        else {
            mi estimate, cmdok post: tobit `dv' `rhs', ll(5) ul(65)
        }
        estimates store t9gm_`modeltag'
        post `t9_gridpost' ("censored") ("tobit") ("`dv'") (`spec') (e(N))
    }
}

display as text "--- Section 14G: panel, survey, IV, and FE-style models ---"
mi xtset t9_id t9_wave
foreach dv in t9_income t9_wage t9_depression {
    forvalues spec = 2/4 {
        local rhs "`t9_rhs`spec''"
        local t9_grid_models = `t9_grid_models' + 1
        local modeltag : display %03.0f `t9_grid_models'
        display as text "  GRID panel xtreg model `modeltag': `dv' spec `spec'"
        mi estimate, post: xtreg `dv' `rhs', re
        estimates store t9gm_`modeltag'
        post `t9_gridpost' ("panel") ("xtreg_re") ("`dv'") (`spec') (e(N))
    }
}

mi svyset t9_psu [pweight=t9_pweight], strata(t9_strata)
foreach dv in t9_income t9_wage t9_health_score {
    local rhs "`t9_rhs3'"
    local t9_grid_models = `t9_grid_models' + 1
    local modeltag : display %03.0f `t9_grid_models'
    display as text "  GRID survey regress model `modeltag': `dv'"
    mi estimate, post: svy: regress `dv' `rhs'
    estimates store t9gm_`modeltag'
    post `t9_gridpost' ("survey") ("svy_regress") ("`dv'") (3) (e(N))
}
foreach dv in t9_employed t9_high_income {
    local rhs "t9_age t9_female t9_educ t9_exper t9_local_unemp"
    local t9_grid_models = `t9_grid_models' + 1
    local modeltag : display %03.0f `t9_grid_models'
    display as text "  GRID survey logistic model `modeltag': `dv'"
    mi estimate, post: svy: logistic `dv' `rhs'
    estimates store t9gm_`modeltag'
    post `t9_gridpost' ("survey") ("svy_logistic") ("`dv'") (3) (e(N))
}

foreach dv in t9_income t9_wage {
    forvalues spec = 1/2 {
        local t9_grid_models = `t9_grid_models' + 1
        local modeltag : display %03.0f `t9_grid_models'
        display as text "  GRID IV 2SLS model `modeltag': `dv' spec `spec'"
        if `spec' == 1 {
            mi estimate, cmdok post: ivregress 2sls `dv' t9_age t9_female t9_exper (t9_educ = t9_parent_educ t9_distance_college)
        }
        else {
            mi estimate, cmdok post: ivregress 2sls `dv' t9_age t9_female t9_exper t9_local_unemp i.t9_region (t9_educ = t9_parent_educ t9_distance_college)
        }
        estimates store t9gm_`modeltag'
        post `t9_gridpost' ("iv") ("ivregress") ("`dv'") (`spec') (e(N))
    }
}

foreach dv in t9_income t9_wage t9_health_score {
    local rhs "`t9_rhs4'"
    local t9_grid_models = `t9_grid_models' + 1
    local modeltag : display %03.0f `t9_grid_models'
    display as text "  GRID FE fallback model `modeltag': `dv'"
    mi estimate, post: regress `dv' `rhs', vce(cluster t9_id)
    estimates store t9gm_`modeltag'
    post `t9_gridpost' ("fe") ("regress_fe") ("`dv'") (4) (e(N))
}

postclose `t9_gridpost'
preserve
    use `t9_model_ledger', clear
    compress
    save "${tempdir}/taught_task9_model_ledger.dta", replace
    export delimited using "${tempdir}/taught_task9_model_ledger.csv", replace
restore
display as result "<<< DONE Section 14: loop-heavy MI model family grid, models=`t9_grid_models'"
// #endregion Section 14

// #region Section 15: loop-generated MI graph stress

display as text ">>> START Section 15: loop-generated MI graph stress"
local t9_loop_graph = 0
local t9_loop_graph_vars "t9_income t9_wage t9_hours t9_depression t9_stress t9_health_score t9_bmi t9_bp_sys"
foreach var of local t9_loop_graph_vars {
    forvalues m = 0/3 {
        quietly summarize `var' if _mi_m == `m'
        if r(N) > 20 {
            local t9_loop_graph = `t9_loop_graph' + 1
            local graphtag : display %03.0f `t9_loop_graph'
            display as text "  Graph loop histogram `graphtag': `var' m=`m'"
            histogram `var' if _mi_m == `m', name(t9gl_hist_`graphtag', replace) title("`var' distribution, m=`m'")
            graph export "$figdir9/t9g_loop_hist_`graphtag'.png", name(t9gl_hist_`graphtag') replace width(1200)
        }
    }
}

foreach y in t9_income t9_wage t9_health_score t9_depression {
    foreach x in t9_age t9_educ t9_exper {
        local t9_loop_graph = `t9_loop_graph' + 1
        local graphtag : display %03.0f `t9_loop_graph'
        display as text "  Graph loop scatter `graphtag': `y' by `x'"
        twoway (scatter `y' `x' if _mi_m == 0, mcolor(navy%35) msymbol(o)) ///
               (lfit `y' `x' if _mi_m == 0, lcolor(maroon)), ///
               name(t9gl_scatter_`graphtag', replace) ///
               title("Observed `y' by `x'")
        graph export "$figdir9/t9g_loop_scatter_`graphtag'.png", name(t9gl_scatter_`graphtag') replace width(1400)
    }
}

graph combine t9gl_hist_001 t9gl_hist_002 t9gl_hist_003 t9gl_hist_004, name(t9gl_hist_panel, replace) title("Loop histogram panel")
graph export "$figdir9/t9g_loop_hist_panel.png", name(t9gl_hist_panel) replace width(1800)
display as result "<<< DONE Section 15: loop-generated MI graph stress, graphs=`t9_loop_graph'"
// #endregion Section 15

// #region Section 16: MI administrative commands

display as text ">>> START Section 16: MI administrative commands"
mi describe
mi query
mi varying
mi update
mi xeq 0: count
mi xeq 1: count
mi xeq 2: count
mi xeq 3: count
mi xeq 4: count
mi xeq 5: count
preserve
    mi extract 0, clear
    summarize t9_income t9_wage t9_depression t9_health_score
restore
preserve
    mi extract 1, clear
    summarize t9_income t9_wage t9_depression t9_health_score
restore
preserve
    mi convert wide, clear
    mi describe
    mi convert mlong, clear
    mi describe
restore

display as result "<<< DONE Section 16: MI administrative commands"
// #endregion Section 16

// #region Section 17: generated diagnostic stress code
display as text ">>> START Section 17: generated diagnostics"
display as text "  Diagnostic block 0001: t9_income m=0"
quietly summarize t9_income if _mi_m == 0
scalar t9_diag_n_0001 = r(N)
scalar t9_diag_mean_0001 = r(mean)
scalar t9_diag_sd_0001 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0001) " mean=" %12.4f scalar(t9_diag_mean_0001) " sd=" %12.4f scalar(t9_diag_sd_0001)

display as text "  Diagnostic block 0002: t9_wage m=1"
quietly summarize t9_wage if _mi_m == 1
scalar t9_diag_n_0002 = r(N)
scalar t9_diag_mean_0002 = r(mean)
scalar t9_diag_sd_0002 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0002) " mean=" %12.4f scalar(t9_diag_mean_0002) " sd=" %12.4f scalar(t9_diag_sd_0002)

display as text "  Diagnostic block 0003: t9_hours m=2"
quietly summarize t9_hours if _mi_m == 2
scalar t9_diag_n_0003 = r(N)
scalar t9_diag_mean_0003 = r(mean)
scalar t9_diag_sd_0003 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0003) " mean=" %12.4f scalar(t9_diag_mean_0003) " sd=" %12.4f scalar(t9_diag_sd_0003)

display as text "  Diagnostic block 0004: t9_wealth m=3"
quietly summarize t9_wealth if _mi_m == 3
scalar t9_diag_n_0004 = r(N)
scalar t9_diag_mean_0004 = r(mean)
scalar t9_diag_sd_0004 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0004) " mean=" %12.4f scalar(t9_diag_mean_0004) " sd=" %12.4f scalar(t9_diag_sd_0004)

display as text "  Diagnostic block 0005: t9_savings m=4"
quietly summarize t9_savings if _mi_m == 4
scalar t9_diag_n_0005 = r(N)
scalar t9_diag_mean_0005 = r(mean)
scalar t9_diag_sd_0005 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0005) " mean=" %12.4f scalar(t9_diag_mean_0005) " sd=" %12.4f scalar(t9_diag_sd_0005)

display as text "  Diagnostic block 0006: t9_expenditure m=5"
quietly summarize t9_expenditure if _mi_m == 5
scalar t9_diag_n_0006 = r(N)
scalar t9_diag_mean_0006 = r(mean)
scalar t9_diag_sd_0006 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0006) " mean=" %12.4f scalar(t9_diag_mean_0006) " sd=" %12.4f scalar(t9_diag_sd_0006)

display as text "  Diagnostic block 0007: t9_health_score m=0"
quietly summarize t9_health_score if _mi_m == 0
scalar t9_diag_n_0007 = r(N)
scalar t9_diag_mean_0007 = r(mean)
scalar t9_diag_sd_0007 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0007) " mean=" %12.4f scalar(t9_diag_mean_0007) " sd=" %12.4f scalar(t9_diag_sd_0007)

display as text "  Diagnostic block 0008: t9_bmi m=1"
quietly summarize t9_bmi if _mi_m == 1
scalar t9_diag_n_0008 = r(N)
scalar t9_diag_mean_0008 = r(mean)
scalar t9_diag_sd_0008 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0008) " mean=" %12.4f scalar(t9_diag_mean_0008) " sd=" %12.4f scalar(t9_diag_sd_0008)

display as text "  Diagnostic block 0009: t9_bp_sys m=2"
quietly summarize t9_bp_sys if _mi_m == 2
scalar t9_diag_n_0009 = r(N)
scalar t9_diag_mean_0009 = r(mean)
scalar t9_diag_sd_0009 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0009) " mean=" %12.4f scalar(t9_diag_mean_0009) " sd=" %12.4f scalar(t9_diag_sd_0009)

display as text "  Diagnostic block 0010: t9_bp_dia m=3"
quietly summarize t9_bp_dia if _mi_m == 3
scalar t9_diag_n_0010 = r(N)
scalar t9_diag_mean_0010 = r(mean)
scalar t9_diag_sd_0010 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0010) " mean=" %12.4f scalar(t9_diag_mean_0010) " sd=" %12.4f scalar(t9_diag_sd_0010)

display as text "  Diagnostic block 0011: t9_depression m=4"
quietly summarize t9_depression if _mi_m == 4
scalar t9_diag_n_0011 = r(N)
scalar t9_diag_mean_0011 = r(mean)
scalar t9_diag_sd_0011 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0011) " mean=" %12.4f scalar(t9_diag_mean_0011) " sd=" %12.4f scalar(t9_diag_sd_0011)

display as text "  Diagnostic block 0012: t9_stress m=5"
quietly summarize t9_stress if _mi_m == 5
scalar t9_diag_n_0012 = r(N)
scalar t9_diag_mean_0012 = r(mean)
scalar t9_diag_sd_0012 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0012) " mean=" %12.4f scalar(t9_diag_mean_0012) " sd=" %12.4f scalar(t9_diag_sd_0012)

display as text "  Diagnostic block 0013: t9_satisfaction m=0"
quietly summarize t9_satisfaction if _mi_m == 0
scalar t9_diag_n_0013 = r(N)
scalar t9_diag_mean_0013 = r(mean)
scalar t9_diag_sd_0013 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0013) " mean=" %12.4f scalar(t9_diag_mean_0013) " sd=" %12.4f scalar(t9_diag_sd_0013)

display as text "  Diagnostic block 0014: t9_sleep m=1"
quietly summarize t9_sleep if _mi_m == 1
scalar t9_diag_n_0014 = r(N)
scalar t9_diag_mean_0014 = r(mean)
scalar t9_diag_sd_0014 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0014) " mean=" %12.4f scalar(t9_diag_mean_0014) " sd=" %12.4f scalar(t9_diag_sd_0014)

display as text "  Diagnostic block 0015: t9_exercise m=2"
quietly summarize t9_exercise if _mi_m == 2
scalar t9_diag_n_0015 = r(N)
scalar t9_diag_mean_0015 = r(mean)
scalar t9_diag_sd_0015 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0015) " mean=" %12.4f scalar(t9_diag_mean_0015) " sd=" %12.4f scalar(t9_diag_sd_0015)

display as text "  Diagnostic block 0016: t9_employed m=3"
quietly summarize t9_employed if _mi_m == 3
scalar t9_diag_n_0016 = r(N)
scalar t9_diag_mean_0016 = r(mean)
scalar t9_diag_sd_0016 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0016) " mean=" %12.4f scalar(t9_diag_mean_0016) " sd=" %12.4f scalar(t9_diag_sd_0016)

display as text "  Diagnostic block 0017: t9_married m=4"
quietly summarize t9_married if _mi_m == 4
scalar t9_diag_n_0017 = r(N)
scalar t9_diag_mean_0017 = r(mean)
scalar t9_diag_sd_0017 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0017) " mean=" %12.4f scalar(t9_diag_mean_0017) " sd=" %12.4f scalar(t9_diag_sd_0017)

display as text "  Diagnostic block 0018: t9_urban m=5"
quietly summarize t9_urban if _mi_m == 5
scalar t9_diag_n_0018 = r(N)
scalar t9_diag_mean_0018 = r(mean)
scalar t9_diag_sd_0018 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0018) " mean=" %12.4f scalar(t9_diag_mean_0018) " sd=" %12.4f scalar(t9_diag_sd_0018)

display as text "  Diagnostic block 0019: t9_homeowner m=0"
quietly summarize t9_homeowner if _mi_m == 0
scalar t9_diag_n_0019 = r(N)
scalar t9_diag_mean_0019 = r(mean)
scalar t9_diag_sd_0019 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0019) " mean=" %12.4f scalar(t9_diag_mean_0019) " sd=" %12.4f scalar(t9_diag_sd_0019)

display as text "  Diagnostic block 0020: t9_insured m=1"
quietly summarize t9_insured if _mi_m == 1
scalar t9_diag_n_0020 = r(N)
scalar t9_diag_mean_0020 = r(mean)
scalar t9_diag_sd_0020 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0020) " mean=" %12.4f scalar(t9_diag_mean_0020) " sd=" %12.4f scalar(t9_diag_sd_0020)

display as text "  Diagnostic block 0021: t9_smoker m=2"
quietly summarize t9_smoker if _mi_m == 2
scalar t9_diag_n_0021 = r(N)
scalar t9_diag_mean_0021 = r(mean)
scalar t9_diag_sd_0021 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0021) " mean=" %12.4f scalar(t9_diag_mean_0021) " sd=" %12.4f scalar(t9_diag_sd_0021)

display as text "  Diagnostic block 0022: t9_high_income m=3"
quietly summarize t9_high_income if _mi_m == 3
scalar t9_diag_n_0022 = r(N)
scalar t9_diag_mean_0022 = r(mean)
scalar t9_diag_sd_0022 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0022) " mean=" %12.4f scalar(t9_diag_mean_0022) " sd=" %12.4f scalar(t9_diag_sd_0022)

display as text "  Diagnostic block 0023: t9_high_stress m=4"
quietly summarize t9_high_stress if _mi_m == 4
scalar t9_diag_n_0023 = r(N)
scalar t9_diag_mean_0023 = r(mean)
scalar t9_diag_sd_0023 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0023) " mean=" %12.4f scalar(t9_diag_mean_0023) " sd=" %12.4f scalar(t9_diag_sd_0023)

display as text "  Diagnostic block 0024: t9_unhealthy m=5"
quietly summarize t9_unhealthy if _mi_m == 5
scalar t9_diag_n_0024 = r(N)
scalar t9_diag_mean_0024 = r(mean)
scalar t9_diag_sd_0024 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0024) " mean=" %12.4f scalar(t9_diag_mean_0024) " sd=" %12.4f scalar(t9_diag_sd_0024)

display as text "  Diagnostic block 0025: t9_educ_level m=0"
quietly summarize t9_educ_level if _mi_m == 0
scalar t9_diag_n_0025 = r(N)
scalar t9_diag_mean_0025 = r(mean)
scalar t9_diag_sd_0025 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0025) " mean=" %12.4f scalar(t9_diag_mean_0025) " sd=" %12.4f scalar(t9_diag_sd_0025)

display as text "  Diagnostic block 0026: t9_health_level m=1"
quietly summarize t9_health_level if _mi_m == 1
scalar t9_diag_n_0026 = r(N)
scalar t9_diag_mean_0026 = r(mean)
scalar t9_diag_sd_0026 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0026) " mean=" %12.4f scalar(t9_diag_mean_0026) " sd=" %12.4f scalar(t9_diag_sd_0026)

display as text "  Diagnostic block 0027: t9_job_sat m=2"
quietly summarize t9_job_sat if _mi_m == 2
scalar t9_diag_n_0027 = r(N)
scalar t9_diag_mean_0027 = r(mean)
scalar t9_diag_sd_0027 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0027) " mean=" %12.4f scalar(t9_diag_mean_0027) " sd=" %12.4f scalar(t9_diag_sd_0027)

display as text "  Diagnostic block 0028: t9_children m=3"
quietly summarize t9_children if _mi_m == 3
scalar t9_diag_n_0028 = r(N)
scalar t9_diag_mean_0028 = r(mean)
scalar t9_diag_sd_0028 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0028) " mean=" %12.4f scalar(t9_diag_mean_0028) " sd=" %12.4f scalar(t9_diag_sd_0028)

display as text "  Diagnostic block 0029: t9_doctor_visits m=4"
quietly summarize t9_doctor_visits if _mi_m == 4
scalar t9_diag_n_0029 = r(N)
scalar t9_diag_mean_0029 = r(mean)
scalar t9_diag_sd_0029 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0029) " mean=" %12.4f scalar(t9_diag_mean_0029) " sd=" %12.4f scalar(t9_diag_sd_0029)

display as text "  Diagnostic block 0030: t9_hosp_days m=5"
quietly summarize t9_hosp_days if _mi_m == 5
scalar t9_diag_n_0030 = r(N)
scalar t9_diag_mean_0030 = r(mean)
scalar t9_diag_sd_0030 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0030) " mean=" %12.4f scalar(t9_diag_mean_0030) " sd=" %12.4f scalar(t9_diag_sd_0030)

display as text "  Diagnostic block 0031: t9_log_income m=0"
quietly summarize t9_log_income if _mi_m == 0
scalar t9_diag_n_0031 = r(N)
scalar t9_diag_mean_0031 = r(mean)
scalar t9_diag_sd_0031 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0031) " mean=" %12.4f scalar(t9_diag_mean_0031) " sd=" %12.4f scalar(t9_diag_sd_0031)

display as text "  Diagnostic block 0032: t9_log_wage m=1"
quietly summarize t9_log_wage if _mi_m == 1
scalar t9_diag_n_0032 = r(N)
scalar t9_diag_mean_0032 = r(mean)
scalar t9_diag_sd_0032 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0032) " mean=" %12.4f scalar(t9_diag_mean_0032) " sd=" %12.4f scalar(t9_diag_sd_0032)

display as text "  Diagnostic block 0033: t9_income_per_hour m=2"
quietly summarize t9_income_per_hour if _mi_m == 2
scalar t9_diag_n_0033 = r(N)
scalar t9_diag_mean_0033 = r(mean)
scalar t9_diag_sd_0033 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0033) " mean=" %12.4f scalar(t9_diag_mean_0033) " sd=" %12.4f scalar(t9_diag_sd_0033)

display as text "  Diagnostic block 0034: t9_health_index m=3"
quietly summarize t9_health_index if _mi_m == 3
scalar t9_diag_n_0034 = r(N)
scalar t9_diag_mean_0034 = r(mean)
scalar t9_diag_sd_0034 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0034) " mean=" %12.4f scalar(t9_diag_mean_0034) " sd=" %12.4f scalar(t9_diag_sd_0034)

display as text "  Diagnostic block 0035: t9_dep_stress m=4"
quietly summarize t9_dep_stress if _mi_m == 4
scalar t9_diag_n_0035 = r(N)
scalar t9_diag_mean_0035 = r(mean)
scalar t9_diag_sd_0035 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0035) " mean=" %12.4f scalar(t9_diag_mean_0035) " sd=" %12.4f scalar(t9_diag_sd_0035)

display as text "  Diagnostic block 0036: t9_income m=5"
quietly summarize t9_income if _mi_m == 5
scalar t9_diag_n_0036 = r(N)
scalar t9_diag_mean_0036 = r(mean)
scalar t9_diag_sd_0036 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0036) " mean=" %12.4f scalar(t9_diag_mean_0036) " sd=" %12.4f scalar(t9_diag_sd_0036)

display as text "  Diagnostic block 0037: t9_wage m=0"
quietly summarize t9_wage if _mi_m == 0
scalar t9_diag_n_0037 = r(N)
scalar t9_diag_mean_0037 = r(mean)
scalar t9_diag_sd_0037 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0037) " mean=" %12.4f scalar(t9_diag_mean_0037) " sd=" %12.4f scalar(t9_diag_sd_0037)

display as text "  Diagnostic block 0038: t9_hours m=1"
quietly summarize t9_hours if _mi_m == 1
scalar t9_diag_n_0038 = r(N)
scalar t9_diag_mean_0038 = r(mean)
scalar t9_diag_sd_0038 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0038) " mean=" %12.4f scalar(t9_diag_mean_0038) " sd=" %12.4f scalar(t9_diag_sd_0038)

display as text "  Diagnostic block 0039: t9_wealth m=2"
quietly summarize t9_wealth if _mi_m == 2
scalar t9_diag_n_0039 = r(N)
scalar t9_diag_mean_0039 = r(mean)
scalar t9_diag_sd_0039 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0039) " mean=" %12.4f scalar(t9_diag_mean_0039) " sd=" %12.4f scalar(t9_diag_sd_0039)

display as text "  Diagnostic block 0040: t9_savings m=3"
quietly summarize t9_savings if _mi_m == 3
scalar t9_diag_n_0040 = r(N)
scalar t9_diag_mean_0040 = r(mean)
scalar t9_diag_sd_0040 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0040) " mean=" %12.4f scalar(t9_diag_mean_0040) " sd=" %12.4f scalar(t9_diag_sd_0040)

display as text "  Diagnostic block 0041: t9_expenditure m=4"
quietly summarize t9_expenditure if _mi_m == 4
scalar t9_diag_n_0041 = r(N)
scalar t9_diag_mean_0041 = r(mean)
scalar t9_diag_sd_0041 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0041) " mean=" %12.4f scalar(t9_diag_mean_0041) " sd=" %12.4f scalar(t9_diag_sd_0041)

display as text "  Diagnostic block 0042: t9_health_score m=5"
quietly summarize t9_health_score if _mi_m == 5
scalar t9_diag_n_0042 = r(N)
scalar t9_diag_mean_0042 = r(mean)
scalar t9_diag_sd_0042 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0042) " mean=" %12.4f scalar(t9_diag_mean_0042) " sd=" %12.4f scalar(t9_diag_sd_0042)

display as text "  Diagnostic block 0043: t9_bmi m=0"
quietly summarize t9_bmi if _mi_m == 0
scalar t9_diag_n_0043 = r(N)
scalar t9_diag_mean_0043 = r(mean)
scalar t9_diag_sd_0043 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0043) " mean=" %12.4f scalar(t9_diag_mean_0043) " sd=" %12.4f scalar(t9_diag_sd_0043)

display as text "  Diagnostic block 0044: t9_bp_sys m=1"
quietly summarize t9_bp_sys if _mi_m == 1
scalar t9_diag_n_0044 = r(N)
scalar t9_diag_mean_0044 = r(mean)
scalar t9_diag_sd_0044 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0044) " mean=" %12.4f scalar(t9_diag_mean_0044) " sd=" %12.4f scalar(t9_diag_sd_0044)

display as text "  Diagnostic block 0045: t9_bp_dia m=2"
quietly summarize t9_bp_dia if _mi_m == 2
scalar t9_diag_n_0045 = r(N)
scalar t9_diag_mean_0045 = r(mean)
scalar t9_diag_sd_0045 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0045) " mean=" %12.4f scalar(t9_diag_mean_0045) " sd=" %12.4f scalar(t9_diag_sd_0045)

display as text "  Diagnostic block 0046: t9_depression m=3"
quietly summarize t9_depression if _mi_m == 3
scalar t9_diag_n_0046 = r(N)
scalar t9_diag_mean_0046 = r(mean)
scalar t9_diag_sd_0046 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0046) " mean=" %12.4f scalar(t9_diag_mean_0046) " sd=" %12.4f scalar(t9_diag_sd_0046)

display as text "  Diagnostic block 0047: t9_stress m=4"
quietly summarize t9_stress if _mi_m == 4
scalar t9_diag_n_0047 = r(N)
scalar t9_diag_mean_0047 = r(mean)
scalar t9_diag_sd_0047 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0047) " mean=" %12.4f scalar(t9_diag_mean_0047) " sd=" %12.4f scalar(t9_diag_sd_0047)

display as text "  Diagnostic block 0048: t9_satisfaction m=5"
quietly summarize t9_satisfaction if _mi_m == 5
scalar t9_diag_n_0048 = r(N)
scalar t9_diag_mean_0048 = r(mean)
scalar t9_diag_sd_0048 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0048) " mean=" %12.4f scalar(t9_diag_mean_0048) " sd=" %12.4f scalar(t9_diag_sd_0048)

display as text "  Diagnostic block 0049: t9_sleep m=0"
quietly summarize t9_sleep if _mi_m == 0
scalar t9_diag_n_0049 = r(N)
scalar t9_diag_mean_0049 = r(mean)
scalar t9_diag_sd_0049 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0049) " mean=" %12.4f scalar(t9_diag_mean_0049) " sd=" %12.4f scalar(t9_diag_sd_0049)

display as text "  Diagnostic block 0050: t9_exercise m=1"
quietly summarize t9_exercise if _mi_m == 1
scalar t9_diag_n_0050 = r(N)
scalar t9_diag_mean_0050 = r(mean)
scalar t9_diag_sd_0050 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0050) " mean=" %12.4f scalar(t9_diag_mean_0050) " sd=" %12.4f scalar(t9_diag_sd_0050)

display as text "  Diagnostic block 0051: t9_employed m=2"
quietly summarize t9_employed if _mi_m == 2
scalar t9_diag_n_0051 = r(N)
scalar t9_diag_mean_0051 = r(mean)
scalar t9_diag_sd_0051 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0051) " mean=" %12.4f scalar(t9_diag_mean_0051) " sd=" %12.4f scalar(t9_diag_sd_0051)

display as text "  Diagnostic block 0052: t9_married m=3"
quietly summarize t9_married if _mi_m == 3
scalar t9_diag_n_0052 = r(N)
scalar t9_diag_mean_0052 = r(mean)
scalar t9_diag_sd_0052 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0052) " mean=" %12.4f scalar(t9_diag_mean_0052) " sd=" %12.4f scalar(t9_diag_sd_0052)

display as text "  Diagnostic block 0053: t9_urban m=4"
quietly summarize t9_urban if _mi_m == 4
scalar t9_diag_n_0053 = r(N)
scalar t9_diag_mean_0053 = r(mean)
scalar t9_diag_sd_0053 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0053) " mean=" %12.4f scalar(t9_diag_mean_0053) " sd=" %12.4f scalar(t9_diag_sd_0053)

display as text "  Diagnostic block 0054: t9_homeowner m=5"
quietly summarize t9_homeowner if _mi_m == 5
scalar t9_diag_n_0054 = r(N)
scalar t9_diag_mean_0054 = r(mean)
scalar t9_diag_sd_0054 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0054) " mean=" %12.4f scalar(t9_diag_mean_0054) " sd=" %12.4f scalar(t9_diag_sd_0054)

display as text "  Diagnostic block 0055: t9_insured m=0"
quietly summarize t9_insured if _mi_m == 0
scalar t9_diag_n_0055 = r(N)
scalar t9_diag_mean_0055 = r(mean)
scalar t9_diag_sd_0055 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0055) " mean=" %12.4f scalar(t9_diag_mean_0055) " sd=" %12.4f scalar(t9_diag_sd_0055)

display as text "  Diagnostic block 0056: t9_smoker m=1"
quietly summarize t9_smoker if _mi_m == 1
scalar t9_diag_n_0056 = r(N)
scalar t9_diag_mean_0056 = r(mean)
scalar t9_diag_sd_0056 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0056) " mean=" %12.4f scalar(t9_diag_mean_0056) " sd=" %12.4f scalar(t9_diag_sd_0056)

display as text "  Diagnostic block 0057: t9_high_income m=2"
quietly summarize t9_high_income if _mi_m == 2
scalar t9_diag_n_0057 = r(N)
scalar t9_diag_mean_0057 = r(mean)
scalar t9_diag_sd_0057 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0057) " mean=" %12.4f scalar(t9_diag_mean_0057) " sd=" %12.4f scalar(t9_diag_sd_0057)

display as text "  Diagnostic block 0058: t9_high_stress m=3"
quietly summarize t9_high_stress if _mi_m == 3
scalar t9_diag_n_0058 = r(N)
scalar t9_diag_mean_0058 = r(mean)
scalar t9_diag_sd_0058 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0058) " mean=" %12.4f scalar(t9_diag_mean_0058) " sd=" %12.4f scalar(t9_diag_sd_0058)

display as text "  Diagnostic block 0059: t9_unhealthy m=4"
quietly summarize t9_unhealthy if _mi_m == 4
scalar t9_diag_n_0059 = r(N)
scalar t9_diag_mean_0059 = r(mean)
scalar t9_diag_sd_0059 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0059) " mean=" %12.4f scalar(t9_diag_mean_0059) " sd=" %12.4f scalar(t9_diag_sd_0059)

display as text "  Diagnostic block 0060: t9_educ_level m=5"
quietly summarize t9_educ_level if _mi_m == 5
scalar t9_diag_n_0060 = r(N)
scalar t9_diag_mean_0060 = r(mean)
scalar t9_diag_sd_0060 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0060) " mean=" %12.4f scalar(t9_diag_mean_0060) " sd=" %12.4f scalar(t9_diag_sd_0060)

display as text "  Diagnostic block 0061: t9_health_level m=0"
quietly summarize t9_health_level if _mi_m == 0
scalar t9_diag_n_0061 = r(N)
scalar t9_diag_mean_0061 = r(mean)
scalar t9_diag_sd_0061 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0061) " mean=" %12.4f scalar(t9_diag_mean_0061) " sd=" %12.4f scalar(t9_diag_sd_0061)

display as text "  Diagnostic block 0062: t9_job_sat m=1"
quietly summarize t9_job_sat if _mi_m == 1
scalar t9_diag_n_0062 = r(N)
scalar t9_diag_mean_0062 = r(mean)
scalar t9_diag_sd_0062 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0062) " mean=" %12.4f scalar(t9_diag_mean_0062) " sd=" %12.4f scalar(t9_diag_sd_0062)

display as text "  Diagnostic block 0063: t9_children m=2"
quietly summarize t9_children if _mi_m == 2
scalar t9_diag_n_0063 = r(N)
scalar t9_diag_mean_0063 = r(mean)
scalar t9_diag_sd_0063 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0063) " mean=" %12.4f scalar(t9_diag_mean_0063) " sd=" %12.4f scalar(t9_diag_sd_0063)

display as text "  Diagnostic block 0064: t9_doctor_visits m=3"
quietly summarize t9_doctor_visits if _mi_m == 3
scalar t9_diag_n_0064 = r(N)
scalar t9_diag_mean_0064 = r(mean)
scalar t9_diag_sd_0064 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0064) " mean=" %12.4f scalar(t9_diag_mean_0064) " sd=" %12.4f scalar(t9_diag_sd_0064)

display as text "  Diagnostic block 0065: t9_hosp_days m=4"
quietly summarize t9_hosp_days if _mi_m == 4
scalar t9_diag_n_0065 = r(N)
scalar t9_diag_mean_0065 = r(mean)
scalar t9_diag_sd_0065 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0065) " mean=" %12.4f scalar(t9_diag_mean_0065) " sd=" %12.4f scalar(t9_diag_sd_0065)

display as text "  Diagnostic block 0066: t9_log_income m=5"
quietly summarize t9_log_income if _mi_m == 5
scalar t9_diag_n_0066 = r(N)
scalar t9_diag_mean_0066 = r(mean)
scalar t9_diag_sd_0066 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0066) " mean=" %12.4f scalar(t9_diag_mean_0066) " sd=" %12.4f scalar(t9_diag_sd_0066)

display as text "  Diagnostic block 0067: t9_log_wage m=0"
quietly summarize t9_log_wage if _mi_m == 0
scalar t9_diag_n_0067 = r(N)
scalar t9_diag_mean_0067 = r(mean)
scalar t9_diag_sd_0067 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0067) " mean=" %12.4f scalar(t9_diag_mean_0067) " sd=" %12.4f scalar(t9_diag_sd_0067)

display as text "  Diagnostic block 0068: t9_income_per_hour m=1"
quietly summarize t9_income_per_hour if _mi_m == 1
scalar t9_diag_n_0068 = r(N)
scalar t9_diag_mean_0068 = r(mean)
scalar t9_diag_sd_0068 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0068) " mean=" %12.4f scalar(t9_diag_mean_0068) " sd=" %12.4f scalar(t9_diag_sd_0068)

display as text "  Diagnostic block 0069: t9_health_index m=2"
quietly summarize t9_health_index if _mi_m == 2
scalar t9_diag_n_0069 = r(N)
scalar t9_diag_mean_0069 = r(mean)
scalar t9_diag_sd_0069 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0069) " mean=" %12.4f scalar(t9_diag_mean_0069) " sd=" %12.4f scalar(t9_diag_sd_0069)

display as text "  Diagnostic block 0070: t9_dep_stress m=3"
quietly summarize t9_dep_stress if _mi_m == 3
scalar t9_diag_n_0070 = r(N)
scalar t9_diag_mean_0070 = r(mean)
scalar t9_diag_sd_0070 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0070) " mean=" %12.4f scalar(t9_diag_mean_0070) " sd=" %12.4f scalar(t9_diag_sd_0070)

display as text "  Diagnostic block 0071: t9_income m=4"
quietly summarize t9_income if _mi_m == 4
scalar t9_diag_n_0071 = r(N)
scalar t9_diag_mean_0071 = r(mean)
scalar t9_diag_sd_0071 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0071) " mean=" %12.4f scalar(t9_diag_mean_0071) " sd=" %12.4f scalar(t9_diag_sd_0071)

display as text "  Diagnostic block 0072: t9_wage m=5"
quietly summarize t9_wage if _mi_m == 5
scalar t9_diag_n_0072 = r(N)
scalar t9_diag_mean_0072 = r(mean)
scalar t9_diag_sd_0072 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0072) " mean=" %12.4f scalar(t9_diag_mean_0072) " sd=" %12.4f scalar(t9_diag_sd_0072)

display as text "  Diagnostic block 0073: t9_hours m=0"
quietly summarize t9_hours if _mi_m == 0
scalar t9_diag_n_0073 = r(N)
scalar t9_diag_mean_0073 = r(mean)
scalar t9_diag_sd_0073 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0073) " mean=" %12.4f scalar(t9_diag_mean_0073) " sd=" %12.4f scalar(t9_diag_sd_0073)

display as text "  Diagnostic block 0074: t9_wealth m=1"
quietly summarize t9_wealth if _mi_m == 1
scalar t9_diag_n_0074 = r(N)
scalar t9_diag_mean_0074 = r(mean)
scalar t9_diag_sd_0074 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0074) " mean=" %12.4f scalar(t9_diag_mean_0074) " sd=" %12.4f scalar(t9_diag_sd_0074)

display as text "  Diagnostic block 0075: t9_savings m=2"
quietly summarize t9_savings if _mi_m == 2
scalar t9_diag_n_0075 = r(N)
scalar t9_diag_mean_0075 = r(mean)
scalar t9_diag_sd_0075 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0075) " mean=" %12.4f scalar(t9_diag_mean_0075) " sd=" %12.4f scalar(t9_diag_sd_0075)

display as text "  Diagnostic block 0076: t9_expenditure m=3"
quietly summarize t9_expenditure if _mi_m == 3
scalar t9_diag_n_0076 = r(N)
scalar t9_diag_mean_0076 = r(mean)
scalar t9_diag_sd_0076 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0076) " mean=" %12.4f scalar(t9_diag_mean_0076) " sd=" %12.4f scalar(t9_diag_sd_0076)

display as text "  Diagnostic block 0077: t9_health_score m=4"
quietly summarize t9_health_score if _mi_m == 4
scalar t9_diag_n_0077 = r(N)
scalar t9_diag_mean_0077 = r(mean)
scalar t9_diag_sd_0077 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0077) " mean=" %12.4f scalar(t9_diag_mean_0077) " sd=" %12.4f scalar(t9_diag_sd_0077)

display as text "  Diagnostic block 0078: t9_bmi m=5"
quietly summarize t9_bmi if _mi_m == 5
scalar t9_diag_n_0078 = r(N)
scalar t9_diag_mean_0078 = r(mean)
scalar t9_diag_sd_0078 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0078) " mean=" %12.4f scalar(t9_diag_mean_0078) " sd=" %12.4f scalar(t9_diag_sd_0078)

display as text "  Diagnostic block 0079: t9_bp_sys m=0"
quietly summarize t9_bp_sys if _mi_m == 0
scalar t9_diag_n_0079 = r(N)
scalar t9_diag_mean_0079 = r(mean)
scalar t9_diag_sd_0079 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0079) " mean=" %12.4f scalar(t9_diag_mean_0079) " sd=" %12.4f scalar(t9_diag_sd_0079)

display as text "  Diagnostic block 0080: t9_bp_dia m=1"
quietly summarize t9_bp_dia if _mi_m == 1
scalar t9_diag_n_0080 = r(N)
scalar t9_diag_mean_0080 = r(mean)
scalar t9_diag_sd_0080 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0080) " mean=" %12.4f scalar(t9_diag_mean_0080) " sd=" %12.4f scalar(t9_diag_sd_0080)

display as text "  Diagnostic block 0081: t9_depression m=2"
quietly summarize t9_depression if _mi_m == 2
scalar t9_diag_n_0081 = r(N)
scalar t9_diag_mean_0081 = r(mean)
scalar t9_diag_sd_0081 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0081) " mean=" %12.4f scalar(t9_diag_mean_0081) " sd=" %12.4f scalar(t9_diag_sd_0081)

display as text "  Diagnostic block 0082: t9_stress m=3"
quietly summarize t9_stress if _mi_m == 3
scalar t9_diag_n_0082 = r(N)
scalar t9_diag_mean_0082 = r(mean)
scalar t9_diag_sd_0082 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0082) " mean=" %12.4f scalar(t9_diag_mean_0082) " sd=" %12.4f scalar(t9_diag_sd_0082)

display as text "  Diagnostic block 0083: t9_satisfaction m=4"
quietly summarize t9_satisfaction if _mi_m == 4
scalar t9_diag_n_0083 = r(N)
scalar t9_diag_mean_0083 = r(mean)
scalar t9_diag_sd_0083 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0083) " mean=" %12.4f scalar(t9_diag_mean_0083) " sd=" %12.4f scalar(t9_diag_sd_0083)

display as text "  Diagnostic block 0084: t9_sleep m=5"
quietly summarize t9_sleep if _mi_m == 5
scalar t9_diag_n_0084 = r(N)
scalar t9_diag_mean_0084 = r(mean)
scalar t9_diag_sd_0084 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0084) " mean=" %12.4f scalar(t9_diag_mean_0084) " sd=" %12.4f scalar(t9_diag_sd_0084)

display as text "  Diagnostic block 0085: t9_exercise m=0"
quietly summarize t9_exercise if _mi_m == 0
scalar t9_diag_n_0085 = r(N)
scalar t9_diag_mean_0085 = r(mean)
scalar t9_diag_sd_0085 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0085) " mean=" %12.4f scalar(t9_diag_mean_0085) " sd=" %12.4f scalar(t9_diag_sd_0085)

display as text "  Diagnostic block 0086: t9_employed m=1"
quietly summarize t9_employed if _mi_m == 1
scalar t9_diag_n_0086 = r(N)
scalar t9_diag_mean_0086 = r(mean)
scalar t9_diag_sd_0086 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0086) " mean=" %12.4f scalar(t9_diag_mean_0086) " sd=" %12.4f scalar(t9_diag_sd_0086)

display as text "  Diagnostic block 0087: t9_married m=2"
quietly summarize t9_married if _mi_m == 2
scalar t9_diag_n_0087 = r(N)
scalar t9_diag_mean_0087 = r(mean)
scalar t9_diag_sd_0087 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0087) " mean=" %12.4f scalar(t9_diag_mean_0087) " sd=" %12.4f scalar(t9_diag_sd_0087)

display as text "  Diagnostic block 0088: t9_urban m=3"
quietly summarize t9_urban if _mi_m == 3
scalar t9_diag_n_0088 = r(N)
scalar t9_diag_mean_0088 = r(mean)
scalar t9_diag_sd_0088 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0088) " mean=" %12.4f scalar(t9_diag_mean_0088) " sd=" %12.4f scalar(t9_diag_sd_0088)

display as text "  Diagnostic block 0089: t9_homeowner m=4"
quietly summarize t9_homeowner if _mi_m == 4
scalar t9_diag_n_0089 = r(N)
scalar t9_diag_mean_0089 = r(mean)
scalar t9_diag_sd_0089 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0089) " mean=" %12.4f scalar(t9_diag_mean_0089) " sd=" %12.4f scalar(t9_diag_sd_0089)

display as text "  Diagnostic block 0090: t9_insured m=5"
quietly summarize t9_insured if _mi_m == 5
scalar t9_diag_n_0090 = r(N)
scalar t9_diag_mean_0090 = r(mean)
scalar t9_diag_sd_0090 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0090) " mean=" %12.4f scalar(t9_diag_mean_0090) " sd=" %12.4f scalar(t9_diag_sd_0090)

display as text "  Diagnostic block 0091: t9_smoker m=0"
quietly summarize t9_smoker if _mi_m == 0
scalar t9_diag_n_0091 = r(N)
scalar t9_diag_mean_0091 = r(mean)
scalar t9_diag_sd_0091 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0091) " mean=" %12.4f scalar(t9_diag_mean_0091) " sd=" %12.4f scalar(t9_diag_sd_0091)

display as text "  Diagnostic block 0092: t9_high_income m=1"
quietly summarize t9_high_income if _mi_m == 1
scalar t9_diag_n_0092 = r(N)
scalar t9_diag_mean_0092 = r(mean)
scalar t9_diag_sd_0092 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0092) " mean=" %12.4f scalar(t9_diag_mean_0092) " sd=" %12.4f scalar(t9_diag_sd_0092)

display as text "  Diagnostic block 0093: t9_high_stress m=2"
quietly summarize t9_high_stress if _mi_m == 2
scalar t9_diag_n_0093 = r(N)
scalar t9_diag_mean_0093 = r(mean)
scalar t9_diag_sd_0093 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0093) " mean=" %12.4f scalar(t9_diag_mean_0093) " sd=" %12.4f scalar(t9_diag_sd_0093)

display as text "  Diagnostic block 0094: t9_unhealthy m=3"
quietly summarize t9_unhealthy if _mi_m == 3
scalar t9_diag_n_0094 = r(N)
scalar t9_diag_mean_0094 = r(mean)
scalar t9_diag_sd_0094 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0094) " mean=" %12.4f scalar(t9_diag_mean_0094) " sd=" %12.4f scalar(t9_diag_sd_0094)

display as text "  Diagnostic block 0095: t9_educ_level m=4"
quietly summarize t9_educ_level if _mi_m == 4
scalar t9_diag_n_0095 = r(N)
scalar t9_diag_mean_0095 = r(mean)
scalar t9_diag_sd_0095 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0095) " mean=" %12.4f scalar(t9_diag_mean_0095) " sd=" %12.4f scalar(t9_diag_sd_0095)

display as text "  Diagnostic block 0096: t9_health_level m=5"
quietly summarize t9_health_level if _mi_m == 5
scalar t9_diag_n_0096 = r(N)
scalar t9_diag_mean_0096 = r(mean)
scalar t9_diag_sd_0096 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0096) " mean=" %12.4f scalar(t9_diag_mean_0096) " sd=" %12.4f scalar(t9_diag_sd_0096)

display as text "  Diagnostic block 0097: t9_job_sat m=0"
quietly summarize t9_job_sat if _mi_m == 0
scalar t9_diag_n_0097 = r(N)
scalar t9_diag_mean_0097 = r(mean)
scalar t9_diag_sd_0097 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0097) " mean=" %12.4f scalar(t9_diag_mean_0097) " sd=" %12.4f scalar(t9_diag_sd_0097)

display as text "  Diagnostic block 0098: t9_children m=1"
quietly summarize t9_children if _mi_m == 1
scalar t9_diag_n_0098 = r(N)
scalar t9_diag_mean_0098 = r(mean)
scalar t9_diag_sd_0098 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0098) " mean=" %12.4f scalar(t9_diag_mean_0098) " sd=" %12.4f scalar(t9_diag_sd_0098)

display as text "  Diagnostic block 0099: t9_doctor_visits m=2"
quietly summarize t9_doctor_visits if _mi_m == 2
scalar t9_diag_n_0099 = r(N)
scalar t9_diag_mean_0099 = r(mean)
scalar t9_diag_sd_0099 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0099) " mean=" %12.4f scalar(t9_diag_mean_0099) " sd=" %12.4f scalar(t9_diag_sd_0099)

display as text "  Diagnostic block 0100: t9_hosp_days m=3"
quietly summarize t9_hosp_days if _mi_m == 3
scalar t9_diag_n_0100 = r(N)
scalar t9_diag_mean_0100 = r(mean)
scalar t9_diag_sd_0100 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0100) " mean=" %12.4f scalar(t9_diag_mean_0100) " sd=" %12.4f scalar(t9_diag_sd_0100)

display as text "  Diagnostic block 0101: t9_log_income m=4"
quietly summarize t9_log_income if _mi_m == 4
scalar t9_diag_n_0101 = r(N)
scalar t9_diag_mean_0101 = r(mean)
scalar t9_diag_sd_0101 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0101) " mean=" %12.4f scalar(t9_diag_mean_0101) " sd=" %12.4f scalar(t9_diag_sd_0101)

display as text "  Diagnostic block 0102: t9_log_wage m=5"
quietly summarize t9_log_wage if _mi_m == 5
scalar t9_diag_n_0102 = r(N)
scalar t9_diag_mean_0102 = r(mean)
scalar t9_diag_sd_0102 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0102) " mean=" %12.4f scalar(t9_diag_mean_0102) " sd=" %12.4f scalar(t9_diag_sd_0102)

display as text "  Diagnostic block 0103: t9_income_per_hour m=0"
quietly summarize t9_income_per_hour if _mi_m == 0
scalar t9_diag_n_0103 = r(N)
scalar t9_diag_mean_0103 = r(mean)
scalar t9_diag_sd_0103 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0103) " mean=" %12.4f scalar(t9_diag_mean_0103) " sd=" %12.4f scalar(t9_diag_sd_0103)

display as text "  Diagnostic block 0104: t9_health_index m=1"
quietly summarize t9_health_index if _mi_m == 1
scalar t9_diag_n_0104 = r(N)
scalar t9_diag_mean_0104 = r(mean)
scalar t9_diag_sd_0104 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0104) " mean=" %12.4f scalar(t9_diag_mean_0104) " sd=" %12.4f scalar(t9_diag_sd_0104)

display as text "  Diagnostic block 0105: t9_dep_stress m=2"
quietly summarize t9_dep_stress if _mi_m == 2
scalar t9_diag_n_0105 = r(N)
scalar t9_diag_mean_0105 = r(mean)
scalar t9_diag_sd_0105 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0105) " mean=" %12.4f scalar(t9_diag_mean_0105) " sd=" %12.4f scalar(t9_diag_sd_0105)

display as text "  Diagnostic block 0106: t9_income m=3"
quietly summarize t9_income if _mi_m == 3
scalar t9_diag_n_0106 = r(N)
scalar t9_diag_mean_0106 = r(mean)
scalar t9_diag_sd_0106 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0106) " mean=" %12.4f scalar(t9_diag_mean_0106) " sd=" %12.4f scalar(t9_diag_sd_0106)

display as text "  Diagnostic block 0107: t9_wage m=4"
quietly summarize t9_wage if _mi_m == 4
scalar t9_diag_n_0107 = r(N)
scalar t9_diag_mean_0107 = r(mean)
scalar t9_diag_sd_0107 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0107) " mean=" %12.4f scalar(t9_diag_mean_0107) " sd=" %12.4f scalar(t9_diag_sd_0107)

display as text "  Diagnostic block 0108: t9_hours m=5"
quietly summarize t9_hours if _mi_m == 5
scalar t9_diag_n_0108 = r(N)
scalar t9_diag_mean_0108 = r(mean)
scalar t9_diag_sd_0108 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0108) " mean=" %12.4f scalar(t9_diag_mean_0108) " sd=" %12.4f scalar(t9_diag_sd_0108)

display as text "  Diagnostic block 0109: t9_wealth m=0"
quietly summarize t9_wealth if _mi_m == 0
scalar t9_diag_n_0109 = r(N)
scalar t9_diag_mean_0109 = r(mean)
scalar t9_diag_sd_0109 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0109) " mean=" %12.4f scalar(t9_diag_mean_0109) " sd=" %12.4f scalar(t9_diag_sd_0109)

display as text "  Diagnostic block 0110: t9_savings m=1"
quietly summarize t9_savings if _mi_m == 1
scalar t9_diag_n_0110 = r(N)
scalar t9_diag_mean_0110 = r(mean)
scalar t9_diag_sd_0110 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0110) " mean=" %12.4f scalar(t9_diag_mean_0110) " sd=" %12.4f scalar(t9_diag_sd_0110)

display as text "  Diagnostic block 0111: t9_expenditure m=2"
quietly summarize t9_expenditure if _mi_m == 2
scalar t9_diag_n_0111 = r(N)
scalar t9_diag_mean_0111 = r(mean)
scalar t9_diag_sd_0111 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0111) " mean=" %12.4f scalar(t9_diag_mean_0111) " sd=" %12.4f scalar(t9_diag_sd_0111)

display as text "  Diagnostic block 0112: t9_health_score m=3"
quietly summarize t9_health_score if _mi_m == 3
scalar t9_diag_n_0112 = r(N)
scalar t9_diag_mean_0112 = r(mean)
scalar t9_diag_sd_0112 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0112) " mean=" %12.4f scalar(t9_diag_mean_0112) " sd=" %12.4f scalar(t9_diag_sd_0112)

display as text "  Diagnostic block 0113: t9_bmi m=4"
quietly summarize t9_bmi if _mi_m == 4
scalar t9_diag_n_0113 = r(N)
scalar t9_diag_mean_0113 = r(mean)
scalar t9_diag_sd_0113 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0113) " mean=" %12.4f scalar(t9_diag_mean_0113) " sd=" %12.4f scalar(t9_diag_sd_0113)

display as text "  Diagnostic block 0114: t9_bp_sys m=5"
quietly summarize t9_bp_sys if _mi_m == 5
scalar t9_diag_n_0114 = r(N)
scalar t9_diag_mean_0114 = r(mean)
scalar t9_diag_sd_0114 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0114) " mean=" %12.4f scalar(t9_diag_mean_0114) " sd=" %12.4f scalar(t9_diag_sd_0114)

display as text "  Diagnostic block 0115: t9_bp_dia m=0"
quietly summarize t9_bp_dia if _mi_m == 0
scalar t9_diag_n_0115 = r(N)
scalar t9_diag_mean_0115 = r(mean)
scalar t9_diag_sd_0115 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0115) " mean=" %12.4f scalar(t9_diag_mean_0115) " sd=" %12.4f scalar(t9_diag_sd_0115)

display as text "  Diagnostic block 0116: t9_depression m=1"
quietly summarize t9_depression if _mi_m == 1
scalar t9_diag_n_0116 = r(N)
scalar t9_diag_mean_0116 = r(mean)
scalar t9_diag_sd_0116 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0116) " mean=" %12.4f scalar(t9_diag_mean_0116) " sd=" %12.4f scalar(t9_diag_sd_0116)

display as text "  Diagnostic block 0117: t9_stress m=2"
quietly summarize t9_stress if _mi_m == 2
scalar t9_diag_n_0117 = r(N)
scalar t9_diag_mean_0117 = r(mean)
scalar t9_diag_sd_0117 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0117) " mean=" %12.4f scalar(t9_diag_mean_0117) " sd=" %12.4f scalar(t9_diag_sd_0117)

display as text "  Diagnostic block 0118: t9_satisfaction m=3"
quietly summarize t9_satisfaction if _mi_m == 3
scalar t9_diag_n_0118 = r(N)
scalar t9_diag_mean_0118 = r(mean)
scalar t9_diag_sd_0118 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0118) " mean=" %12.4f scalar(t9_diag_mean_0118) " sd=" %12.4f scalar(t9_diag_sd_0118)

display as text "  Diagnostic block 0119: t9_sleep m=4"
quietly summarize t9_sleep if _mi_m == 4
scalar t9_diag_n_0119 = r(N)
scalar t9_diag_mean_0119 = r(mean)
scalar t9_diag_sd_0119 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0119) " mean=" %12.4f scalar(t9_diag_mean_0119) " sd=" %12.4f scalar(t9_diag_sd_0119)

display as text "  Diagnostic block 0120: t9_exercise m=5"
quietly summarize t9_exercise if _mi_m == 5
scalar t9_diag_n_0120 = r(N)
scalar t9_diag_mean_0120 = r(mean)
scalar t9_diag_sd_0120 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0120) " mean=" %12.4f scalar(t9_diag_mean_0120) " sd=" %12.4f scalar(t9_diag_sd_0120)

display as text "  Diagnostic block 0121: t9_employed m=0"
quietly summarize t9_employed if _mi_m == 0
scalar t9_diag_n_0121 = r(N)
scalar t9_diag_mean_0121 = r(mean)
scalar t9_diag_sd_0121 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0121) " mean=" %12.4f scalar(t9_diag_mean_0121) " sd=" %12.4f scalar(t9_diag_sd_0121)

display as text "  Diagnostic block 0122: t9_married m=1"
quietly summarize t9_married if _mi_m == 1
scalar t9_diag_n_0122 = r(N)
scalar t9_diag_mean_0122 = r(mean)
scalar t9_diag_sd_0122 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0122) " mean=" %12.4f scalar(t9_diag_mean_0122) " sd=" %12.4f scalar(t9_diag_sd_0122)

display as text "  Diagnostic block 0123: t9_urban m=2"
quietly summarize t9_urban if _mi_m == 2
scalar t9_diag_n_0123 = r(N)
scalar t9_diag_mean_0123 = r(mean)
scalar t9_diag_sd_0123 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0123) " mean=" %12.4f scalar(t9_diag_mean_0123) " sd=" %12.4f scalar(t9_diag_sd_0123)

display as text "  Diagnostic block 0124: t9_homeowner m=3"
quietly summarize t9_homeowner if _mi_m == 3
scalar t9_diag_n_0124 = r(N)
scalar t9_diag_mean_0124 = r(mean)
scalar t9_diag_sd_0124 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0124) " mean=" %12.4f scalar(t9_diag_mean_0124) " sd=" %12.4f scalar(t9_diag_sd_0124)

display as text "  Diagnostic block 0125: t9_insured m=4"
quietly summarize t9_insured if _mi_m == 4
scalar t9_diag_n_0125 = r(N)
scalar t9_diag_mean_0125 = r(mean)
scalar t9_diag_sd_0125 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0125) " mean=" %12.4f scalar(t9_diag_mean_0125) " sd=" %12.4f scalar(t9_diag_sd_0125)

display as text "  Diagnostic block 0126: t9_smoker m=5"
quietly summarize t9_smoker if _mi_m == 5
scalar t9_diag_n_0126 = r(N)
scalar t9_diag_mean_0126 = r(mean)
scalar t9_diag_sd_0126 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0126) " mean=" %12.4f scalar(t9_diag_mean_0126) " sd=" %12.4f scalar(t9_diag_sd_0126)

display as text "  Diagnostic block 0127: t9_high_income m=0"
quietly summarize t9_high_income if _mi_m == 0
scalar t9_diag_n_0127 = r(N)
scalar t9_diag_mean_0127 = r(mean)
scalar t9_diag_sd_0127 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0127) " mean=" %12.4f scalar(t9_diag_mean_0127) " sd=" %12.4f scalar(t9_diag_sd_0127)

display as text "  Diagnostic block 0128: t9_high_stress m=1"
quietly summarize t9_high_stress if _mi_m == 1
scalar t9_diag_n_0128 = r(N)
scalar t9_diag_mean_0128 = r(mean)
scalar t9_diag_sd_0128 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0128) " mean=" %12.4f scalar(t9_diag_mean_0128) " sd=" %12.4f scalar(t9_diag_sd_0128)

display as text "  Diagnostic block 0129: t9_unhealthy m=2"
quietly summarize t9_unhealthy if _mi_m == 2
scalar t9_diag_n_0129 = r(N)
scalar t9_diag_mean_0129 = r(mean)
scalar t9_diag_sd_0129 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0129) " mean=" %12.4f scalar(t9_diag_mean_0129) " sd=" %12.4f scalar(t9_diag_sd_0129)

display as text "  Diagnostic block 0130: t9_educ_level m=3"
quietly summarize t9_educ_level if _mi_m == 3
scalar t9_diag_n_0130 = r(N)
scalar t9_diag_mean_0130 = r(mean)
scalar t9_diag_sd_0130 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0130) " mean=" %12.4f scalar(t9_diag_mean_0130) " sd=" %12.4f scalar(t9_diag_sd_0130)

display as text "  Diagnostic block 0131: t9_health_level m=4"
quietly summarize t9_health_level if _mi_m == 4
scalar t9_diag_n_0131 = r(N)
scalar t9_diag_mean_0131 = r(mean)
scalar t9_diag_sd_0131 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0131) " mean=" %12.4f scalar(t9_diag_mean_0131) " sd=" %12.4f scalar(t9_diag_sd_0131)

display as text "  Diagnostic block 0132: t9_job_sat m=5"
quietly summarize t9_job_sat if _mi_m == 5
scalar t9_diag_n_0132 = r(N)
scalar t9_diag_mean_0132 = r(mean)
scalar t9_diag_sd_0132 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0132) " mean=" %12.4f scalar(t9_diag_mean_0132) " sd=" %12.4f scalar(t9_diag_sd_0132)

display as text "  Diagnostic block 0133: t9_children m=0"
quietly summarize t9_children if _mi_m == 0
scalar t9_diag_n_0133 = r(N)
scalar t9_diag_mean_0133 = r(mean)
scalar t9_diag_sd_0133 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0133) " mean=" %12.4f scalar(t9_diag_mean_0133) " sd=" %12.4f scalar(t9_diag_sd_0133)

display as text "  Diagnostic block 0134: t9_doctor_visits m=1"
quietly summarize t9_doctor_visits if _mi_m == 1
scalar t9_diag_n_0134 = r(N)
scalar t9_diag_mean_0134 = r(mean)
scalar t9_diag_sd_0134 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0134) " mean=" %12.4f scalar(t9_diag_mean_0134) " sd=" %12.4f scalar(t9_diag_sd_0134)

display as text "  Diagnostic block 0135: t9_hosp_days m=2"
quietly summarize t9_hosp_days if _mi_m == 2
scalar t9_diag_n_0135 = r(N)
scalar t9_diag_mean_0135 = r(mean)
scalar t9_diag_sd_0135 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0135) " mean=" %12.4f scalar(t9_diag_mean_0135) " sd=" %12.4f scalar(t9_diag_sd_0135)

display as text "  Diagnostic block 0136: t9_log_income m=3"
quietly summarize t9_log_income if _mi_m == 3
scalar t9_diag_n_0136 = r(N)
scalar t9_diag_mean_0136 = r(mean)
scalar t9_diag_sd_0136 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0136) " mean=" %12.4f scalar(t9_diag_mean_0136) " sd=" %12.4f scalar(t9_diag_sd_0136)

display as text "  Diagnostic block 0137: t9_log_wage m=4"
quietly summarize t9_log_wage if _mi_m == 4
scalar t9_diag_n_0137 = r(N)
scalar t9_diag_mean_0137 = r(mean)
scalar t9_diag_sd_0137 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0137) " mean=" %12.4f scalar(t9_diag_mean_0137) " sd=" %12.4f scalar(t9_diag_sd_0137)

display as text "  Diagnostic block 0138: t9_income_per_hour m=5"
quietly summarize t9_income_per_hour if _mi_m == 5
scalar t9_diag_n_0138 = r(N)
scalar t9_diag_mean_0138 = r(mean)
scalar t9_diag_sd_0138 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0138) " mean=" %12.4f scalar(t9_diag_mean_0138) " sd=" %12.4f scalar(t9_diag_sd_0138)

display as text "  Diagnostic block 0139: t9_health_index m=0"
quietly summarize t9_health_index if _mi_m == 0
scalar t9_diag_n_0139 = r(N)
scalar t9_diag_mean_0139 = r(mean)
scalar t9_diag_sd_0139 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0139) " mean=" %12.4f scalar(t9_diag_mean_0139) " sd=" %12.4f scalar(t9_diag_sd_0139)

display as text "  Diagnostic block 0140: t9_dep_stress m=1"
quietly summarize t9_dep_stress if _mi_m == 1
scalar t9_diag_n_0140 = r(N)
scalar t9_diag_mean_0140 = r(mean)
scalar t9_diag_sd_0140 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0140) " mean=" %12.4f scalar(t9_diag_mean_0140) " sd=" %12.4f scalar(t9_diag_sd_0140)

display as text "  Diagnostic block 0141: t9_income m=2"
quietly summarize t9_income if _mi_m == 2
scalar t9_diag_n_0141 = r(N)
scalar t9_diag_mean_0141 = r(mean)
scalar t9_diag_sd_0141 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0141) " mean=" %12.4f scalar(t9_diag_mean_0141) " sd=" %12.4f scalar(t9_diag_sd_0141)

display as text "  Diagnostic block 0142: t9_wage m=3"
quietly summarize t9_wage if _mi_m == 3
scalar t9_diag_n_0142 = r(N)
scalar t9_diag_mean_0142 = r(mean)
scalar t9_diag_sd_0142 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0142) " mean=" %12.4f scalar(t9_diag_mean_0142) " sd=" %12.4f scalar(t9_diag_sd_0142)

display as text "  Diagnostic block 0143: t9_hours m=4"
quietly summarize t9_hours if _mi_m == 4
scalar t9_diag_n_0143 = r(N)
scalar t9_diag_mean_0143 = r(mean)
scalar t9_diag_sd_0143 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0143) " mean=" %12.4f scalar(t9_diag_mean_0143) " sd=" %12.4f scalar(t9_diag_sd_0143)

display as text "  Diagnostic block 0144: t9_wealth m=5"
quietly summarize t9_wealth if _mi_m == 5
scalar t9_diag_n_0144 = r(N)
scalar t9_diag_mean_0144 = r(mean)
scalar t9_diag_sd_0144 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0144) " mean=" %12.4f scalar(t9_diag_mean_0144) " sd=" %12.4f scalar(t9_diag_sd_0144)

display as text "  Diagnostic block 0145: t9_savings m=0"
quietly summarize t9_savings if _mi_m == 0
scalar t9_diag_n_0145 = r(N)
scalar t9_diag_mean_0145 = r(mean)
scalar t9_diag_sd_0145 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0145) " mean=" %12.4f scalar(t9_diag_mean_0145) " sd=" %12.4f scalar(t9_diag_sd_0145)

display as text "  Diagnostic block 0146: t9_expenditure m=1"
quietly summarize t9_expenditure if _mi_m == 1
scalar t9_diag_n_0146 = r(N)
scalar t9_diag_mean_0146 = r(mean)
scalar t9_diag_sd_0146 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0146) " mean=" %12.4f scalar(t9_diag_mean_0146) " sd=" %12.4f scalar(t9_diag_sd_0146)

display as text "  Diagnostic block 0147: t9_health_score m=2"
quietly summarize t9_health_score if _mi_m == 2
scalar t9_diag_n_0147 = r(N)
scalar t9_diag_mean_0147 = r(mean)
scalar t9_diag_sd_0147 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0147) " mean=" %12.4f scalar(t9_diag_mean_0147) " sd=" %12.4f scalar(t9_diag_sd_0147)

display as text "  Diagnostic block 0148: t9_bmi m=3"
quietly summarize t9_bmi if _mi_m == 3
scalar t9_diag_n_0148 = r(N)
scalar t9_diag_mean_0148 = r(mean)
scalar t9_diag_sd_0148 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0148) " mean=" %12.4f scalar(t9_diag_mean_0148) " sd=" %12.4f scalar(t9_diag_sd_0148)

display as text "  Diagnostic block 0149: t9_bp_sys m=4"
quietly summarize t9_bp_sys if _mi_m == 4
scalar t9_diag_n_0149 = r(N)
scalar t9_diag_mean_0149 = r(mean)
scalar t9_diag_sd_0149 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0149) " mean=" %12.4f scalar(t9_diag_mean_0149) " sd=" %12.4f scalar(t9_diag_sd_0149)

display as text "  Diagnostic block 0150: t9_bp_dia m=5"
quietly summarize t9_bp_dia if _mi_m == 5
scalar t9_diag_n_0150 = r(N)
scalar t9_diag_mean_0150 = r(mean)
scalar t9_diag_sd_0150 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0150) " mean=" %12.4f scalar(t9_diag_mean_0150) " sd=" %12.4f scalar(t9_diag_sd_0150)

display as text "  Diagnostic block 0151: t9_depression m=0"
quietly summarize t9_depression if _mi_m == 0
scalar t9_diag_n_0151 = r(N)
scalar t9_diag_mean_0151 = r(mean)
scalar t9_diag_sd_0151 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0151) " mean=" %12.4f scalar(t9_diag_mean_0151) " sd=" %12.4f scalar(t9_diag_sd_0151)

display as text "  Diagnostic block 0152: t9_stress m=1"
quietly summarize t9_stress if _mi_m == 1
scalar t9_diag_n_0152 = r(N)
scalar t9_diag_mean_0152 = r(mean)
scalar t9_diag_sd_0152 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0152) " mean=" %12.4f scalar(t9_diag_mean_0152) " sd=" %12.4f scalar(t9_diag_sd_0152)

display as text "  Diagnostic block 0153: t9_satisfaction m=2"
quietly summarize t9_satisfaction if _mi_m == 2
scalar t9_diag_n_0153 = r(N)
scalar t9_diag_mean_0153 = r(mean)
scalar t9_diag_sd_0153 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0153) " mean=" %12.4f scalar(t9_diag_mean_0153) " sd=" %12.4f scalar(t9_diag_sd_0153)

display as text "  Diagnostic block 0154: t9_sleep m=3"
quietly summarize t9_sleep if _mi_m == 3
scalar t9_diag_n_0154 = r(N)
scalar t9_diag_mean_0154 = r(mean)
scalar t9_diag_sd_0154 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0154) " mean=" %12.4f scalar(t9_diag_mean_0154) " sd=" %12.4f scalar(t9_diag_sd_0154)

display as text "  Diagnostic block 0155: t9_exercise m=4"
quietly summarize t9_exercise if _mi_m == 4
scalar t9_diag_n_0155 = r(N)
scalar t9_diag_mean_0155 = r(mean)
scalar t9_diag_sd_0155 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0155) " mean=" %12.4f scalar(t9_diag_mean_0155) " sd=" %12.4f scalar(t9_diag_sd_0155)

display as text "  Diagnostic block 0156: t9_employed m=5"
quietly summarize t9_employed if _mi_m == 5
scalar t9_diag_n_0156 = r(N)
scalar t9_diag_mean_0156 = r(mean)
scalar t9_diag_sd_0156 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0156) " mean=" %12.4f scalar(t9_diag_mean_0156) " sd=" %12.4f scalar(t9_diag_sd_0156)

display as text "  Diagnostic block 0157: t9_married m=0"
quietly summarize t9_married if _mi_m == 0
scalar t9_diag_n_0157 = r(N)
scalar t9_diag_mean_0157 = r(mean)
scalar t9_diag_sd_0157 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0157) " mean=" %12.4f scalar(t9_diag_mean_0157) " sd=" %12.4f scalar(t9_diag_sd_0157)

display as text "  Diagnostic block 0158: t9_urban m=1"
quietly summarize t9_urban if _mi_m == 1
scalar t9_diag_n_0158 = r(N)
scalar t9_diag_mean_0158 = r(mean)
scalar t9_diag_sd_0158 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0158) " mean=" %12.4f scalar(t9_diag_mean_0158) " sd=" %12.4f scalar(t9_diag_sd_0158)

display as text "  Diagnostic block 0159: t9_homeowner m=2"
quietly summarize t9_homeowner if _mi_m == 2
scalar t9_diag_n_0159 = r(N)
scalar t9_diag_mean_0159 = r(mean)
scalar t9_diag_sd_0159 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0159) " mean=" %12.4f scalar(t9_diag_mean_0159) " sd=" %12.4f scalar(t9_diag_sd_0159)

display as text "  Diagnostic block 0160: t9_insured m=3"
quietly summarize t9_insured if _mi_m == 3
scalar t9_diag_n_0160 = r(N)
scalar t9_diag_mean_0160 = r(mean)
scalar t9_diag_sd_0160 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0160) " mean=" %12.4f scalar(t9_diag_mean_0160) " sd=" %12.4f scalar(t9_diag_sd_0160)

display as text "  Diagnostic block 0161: t9_smoker m=4"
quietly summarize t9_smoker if _mi_m == 4
scalar t9_diag_n_0161 = r(N)
scalar t9_diag_mean_0161 = r(mean)
scalar t9_diag_sd_0161 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0161) " mean=" %12.4f scalar(t9_diag_mean_0161) " sd=" %12.4f scalar(t9_diag_sd_0161)

display as text "  Diagnostic block 0162: t9_high_income m=5"
quietly summarize t9_high_income if _mi_m == 5
scalar t9_diag_n_0162 = r(N)
scalar t9_diag_mean_0162 = r(mean)
scalar t9_diag_sd_0162 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0162) " mean=" %12.4f scalar(t9_diag_mean_0162) " sd=" %12.4f scalar(t9_diag_sd_0162)

display as text "  Diagnostic block 0163: t9_high_stress m=0"
quietly summarize t9_high_stress if _mi_m == 0
scalar t9_diag_n_0163 = r(N)
scalar t9_diag_mean_0163 = r(mean)
scalar t9_diag_sd_0163 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0163) " mean=" %12.4f scalar(t9_diag_mean_0163) " sd=" %12.4f scalar(t9_diag_sd_0163)

display as text "  Diagnostic block 0164: t9_unhealthy m=1"
quietly summarize t9_unhealthy if _mi_m == 1
scalar t9_diag_n_0164 = r(N)
scalar t9_diag_mean_0164 = r(mean)
scalar t9_diag_sd_0164 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0164) " mean=" %12.4f scalar(t9_diag_mean_0164) " sd=" %12.4f scalar(t9_diag_sd_0164)

display as text "  Diagnostic block 0165: t9_educ_level m=2"
quietly summarize t9_educ_level if _mi_m == 2
scalar t9_diag_n_0165 = r(N)
scalar t9_diag_mean_0165 = r(mean)
scalar t9_diag_sd_0165 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0165) " mean=" %12.4f scalar(t9_diag_mean_0165) " sd=" %12.4f scalar(t9_diag_sd_0165)

display as text "  Diagnostic block 0166: t9_health_level m=3"
quietly summarize t9_health_level if _mi_m == 3
scalar t9_diag_n_0166 = r(N)
scalar t9_diag_mean_0166 = r(mean)
scalar t9_diag_sd_0166 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0166) " mean=" %12.4f scalar(t9_diag_mean_0166) " sd=" %12.4f scalar(t9_diag_sd_0166)

display as text "  Diagnostic block 0167: t9_job_sat m=4"
quietly summarize t9_job_sat if _mi_m == 4
scalar t9_diag_n_0167 = r(N)
scalar t9_diag_mean_0167 = r(mean)
scalar t9_diag_sd_0167 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0167) " mean=" %12.4f scalar(t9_diag_mean_0167) " sd=" %12.4f scalar(t9_diag_sd_0167)

display as text "  Diagnostic block 0168: t9_children m=5"
quietly summarize t9_children if _mi_m == 5
scalar t9_diag_n_0168 = r(N)
scalar t9_diag_mean_0168 = r(mean)
scalar t9_diag_sd_0168 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0168) " mean=" %12.4f scalar(t9_diag_mean_0168) " sd=" %12.4f scalar(t9_diag_sd_0168)

display as text "  Diagnostic block 0169: t9_doctor_visits m=0"
quietly summarize t9_doctor_visits if _mi_m == 0
scalar t9_diag_n_0169 = r(N)
scalar t9_diag_mean_0169 = r(mean)
scalar t9_diag_sd_0169 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0169) " mean=" %12.4f scalar(t9_diag_mean_0169) " sd=" %12.4f scalar(t9_diag_sd_0169)

display as text "  Diagnostic block 0170: t9_hosp_days m=1"
quietly summarize t9_hosp_days if _mi_m == 1
scalar t9_diag_n_0170 = r(N)
scalar t9_diag_mean_0170 = r(mean)
scalar t9_diag_sd_0170 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0170) " mean=" %12.4f scalar(t9_diag_mean_0170) " sd=" %12.4f scalar(t9_diag_sd_0170)

display as text "  Diagnostic block 0171: t9_log_income m=2"
quietly summarize t9_log_income if _mi_m == 2
scalar t9_diag_n_0171 = r(N)
scalar t9_diag_mean_0171 = r(mean)
scalar t9_diag_sd_0171 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0171) " mean=" %12.4f scalar(t9_diag_mean_0171) " sd=" %12.4f scalar(t9_diag_sd_0171)

display as text "  Diagnostic block 0172: t9_log_wage m=3"
quietly summarize t9_log_wage if _mi_m == 3
scalar t9_diag_n_0172 = r(N)
scalar t9_diag_mean_0172 = r(mean)
scalar t9_diag_sd_0172 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0172) " mean=" %12.4f scalar(t9_diag_mean_0172) " sd=" %12.4f scalar(t9_diag_sd_0172)

display as text "  Diagnostic block 0173: t9_income_per_hour m=4"
quietly summarize t9_income_per_hour if _mi_m == 4
scalar t9_diag_n_0173 = r(N)
scalar t9_diag_mean_0173 = r(mean)
scalar t9_diag_sd_0173 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0173) " mean=" %12.4f scalar(t9_diag_mean_0173) " sd=" %12.4f scalar(t9_diag_sd_0173)

display as text "  Diagnostic block 0174: t9_health_index m=5"
quietly summarize t9_health_index if _mi_m == 5
scalar t9_diag_n_0174 = r(N)
scalar t9_diag_mean_0174 = r(mean)
scalar t9_diag_sd_0174 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0174) " mean=" %12.4f scalar(t9_diag_mean_0174) " sd=" %12.4f scalar(t9_diag_sd_0174)

display as text "  Diagnostic block 0175: t9_dep_stress m=0"
quietly summarize t9_dep_stress if _mi_m == 0
scalar t9_diag_n_0175 = r(N)
scalar t9_diag_mean_0175 = r(mean)
scalar t9_diag_sd_0175 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0175) " mean=" %12.4f scalar(t9_diag_mean_0175) " sd=" %12.4f scalar(t9_diag_sd_0175)

display as text "  Diagnostic block 0176: t9_income m=1"
quietly summarize t9_income if _mi_m == 1
scalar t9_diag_n_0176 = r(N)
scalar t9_diag_mean_0176 = r(mean)
scalar t9_diag_sd_0176 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0176) " mean=" %12.4f scalar(t9_diag_mean_0176) " sd=" %12.4f scalar(t9_diag_sd_0176)

display as text "  Diagnostic block 0177: t9_wage m=2"
quietly summarize t9_wage if _mi_m == 2
scalar t9_diag_n_0177 = r(N)
scalar t9_diag_mean_0177 = r(mean)
scalar t9_diag_sd_0177 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0177) " mean=" %12.4f scalar(t9_diag_mean_0177) " sd=" %12.4f scalar(t9_diag_sd_0177)

display as text "  Diagnostic block 0178: t9_hours m=3"
quietly summarize t9_hours if _mi_m == 3
scalar t9_diag_n_0178 = r(N)
scalar t9_diag_mean_0178 = r(mean)
scalar t9_diag_sd_0178 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0178) " mean=" %12.4f scalar(t9_diag_mean_0178) " sd=" %12.4f scalar(t9_diag_sd_0178)

display as text "  Diagnostic block 0179: t9_wealth m=4"
quietly summarize t9_wealth if _mi_m == 4
scalar t9_diag_n_0179 = r(N)
scalar t9_diag_mean_0179 = r(mean)
scalar t9_diag_sd_0179 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0179) " mean=" %12.4f scalar(t9_diag_mean_0179) " sd=" %12.4f scalar(t9_diag_sd_0179)

display as text "  Diagnostic block 0180: t9_savings m=5"
quietly summarize t9_savings if _mi_m == 5
scalar t9_diag_n_0180 = r(N)
scalar t9_diag_mean_0180 = r(mean)
scalar t9_diag_sd_0180 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0180) " mean=" %12.4f scalar(t9_diag_mean_0180) " sd=" %12.4f scalar(t9_diag_sd_0180)

display as text "  Diagnostic block 0181: t9_expenditure m=0"
quietly summarize t9_expenditure if _mi_m == 0
scalar t9_diag_n_0181 = r(N)
scalar t9_diag_mean_0181 = r(mean)
scalar t9_diag_sd_0181 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0181) " mean=" %12.4f scalar(t9_diag_mean_0181) " sd=" %12.4f scalar(t9_diag_sd_0181)

display as text "  Diagnostic block 0182: t9_health_score m=1"
quietly summarize t9_health_score if _mi_m == 1
scalar t9_diag_n_0182 = r(N)
scalar t9_diag_mean_0182 = r(mean)
scalar t9_diag_sd_0182 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0182) " mean=" %12.4f scalar(t9_diag_mean_0182) " sd=" %12.4f scalar(t9_diag_sd_0182)

display as text "  Diagnostic block 0183: t9_bmi m=2"
quietly summarize t9_bmi if _mi_m == 2
scalar t9_diag_n_0183 = r(N)
scalar t9_diag_mean_0183 = r(mean)
scalar t9_diag_sd_0183 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0183) " mean=" %12.4f scalar(t9_diag_mean_0183) " sd=" %12.4f scalar(t9_diag_sd_0183)

display as text "  Diagnostic block 0184: t9_bp_sys m=3"
quietly summarize t9_bp_sys if _mi_m == 3
scalar t9_diag_n_0184 = r(N)
scalar t9_diag_mean_0184 = r(mean)
scalar t9_diag_sd_0184 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0184) " mean=" %12.4f scalar(t9_diag_mean_0184) " sd=" %12.4f scalar(t9_diag_sd_0184)

display as text "  Diagnostic block 0185: t9_bp_dia m=4"
quietly summarize t9_bp_dia if _mi_m == 4
scalar t9_diag_n_0185 = r(N)
scalar t9_diag_mean_0185 = r(mean)
scalar t9_diag_sd_0185 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0185) " mean=" %12.4f scalar(t9_diag_mean_0185) " sd=" %12.4f scalar(t9_diag_sd_0185)

display as text "  Diagnostic block 0186: t9_depression m=5"
quietly summarize t9_depression if _mi_m == 5
scalar t9_diag_n_0186 = r(N)
scalar t9_diag_mean_0186 = r(mean)
scalar t9_diag_sd_0186 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0186) " mean=" %12.4f scalar(t9_diag_mean_0186) " sd=" %12.4f scalar(t9_diag_sd_0186)

display as text "  Diagnostic block 0187: t9_stress m=0"
quietly summarize t9_stress if _mi_m == 0
scalar t9_diag_n_0187 = r(N)
scalar t9_diag_mean_0187 = r(mean)
scalar t9_diag_sd_0187 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0187) " mean=" %12.4f scalar(t9_diag_mean_0187) " sd=" %12.4f scalar(t9_diag_sd_0187)

display as text "  Diagnostic block 0188: t9_satisfaction m=1"
quietly summarize t9_satisfaction if _mi_m == 1
scalar t9_diag_n_0188 = r(N)
scalar t9_diag_mean_0188 = r(mean)
scalar t9_diag_sd_0188 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0188) " mean=" %12.4f scalar(t9_diag_mean_0188) " sd=" %12.4f scalar(t9_diag_sd_0188)

display as text "  Diagnostic block 0189: t9_sleep m=2"
quietly summarize t9_sleep if _mi_m == 2
scalar t9_diag_n_0189 = r(N)
scalar t9_diag_mean_0189 = r(mean)
scalar t9_diag_sd_0189 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0189) " mean=" %12.4f scalar(t9_diag_mean_0189) " sd=" %12.4f scalar(t9_diag_sd_0189)

display as text "  Diagnostic block 0190: t9_exercise m=3"
quietly summarize t9_exercise if _mi_m == 3
scalar t9_diag_n_0190 = r(N)
scalar t9_diag_mean_0190 = r(mean)
scalar t9_diag_sd_0190 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0190) " mean=" %12.4f scalar(t9_diag_mean_0190) " sd=" %12.4f scalar(t9_diag_sd_0190)

display as text "  Diagnostic block 0191: t9_employed m=4"
quietly summarize t9_employed if _mi_m == 4
scalar t9_diag_n_0191 = r(N)
scalar t9_diag_mean_0191 = r(mean)
scalar t9_diag_sd_0191 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0191) " mean=" %12.4f scalar(t9_diag_mean_0191) " sd=" %12.4f scalar(t9_diag_sd_0191)

display as text "  Diagnostic block 0192: t9_married m=5"
quietly summarize t9_married if _mi_m == 5
scalar t9_diag_n_0192 = r(N)
scalar t9_diag_mean_0192 = r(mean)
scalar t9_diag_sd_0192 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0192) " mean=" %12.4f scalar(t9_diag_mean_0192) " sd=" %12.4f scalar(t9_diag_sd_0192)

display as text "  Diagnostic block 0193: t9_urban m=0"
quietly summarize t9_urban if _mi_m == 0
scalar t9_diag_n_0193 = r(N)
scalar t9_diag_mean_0193 = r(mean)
scalar t9_diag_sd_0193 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0193) " mean=" %12.4f scalar(t9_diag_mean_0193) " sd=" %12.4f scalar(t9_diag_sd_0193)

display as text "  Diagnostic block 0194: t9_homeowner m=1"
quietly summarize t9_homeowner if _mi_m == 1
scalar t9_diag_n_0194 = r(N)
scalar t9_diag_mean_0194 = r(mean)
scalar t9_diag_sd_0194 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0194) " mean=" %12.4f scalar(t9_diag_mean_0194) " sd=" %12.4f scalar(t9_diag_sd_0194)

display as text "  Diagnostic block 0195: t9_insured m=2"
quietly summarize t9_insured if _mi_m == 2
scalar t9_diag_n_0195 = r(N)
scalar t9_diag_mean_0195 = r(mean)
scalar t9_diag_sd_0195 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0195) " mean=" %12.4f scalar(t9_diag_mean_0195) " sd=" %12.4f scalar(t9_diag_sd_0195)

display as text "  Diagnostic block 0196: t9_smoker m=3"
quietly summarize t9_smoker if _mi_m == 3
scalar t9_diag_n_0196 = r(N)
scalar t9_diag_mean_0196 = r(mean)
scalar t9_diag_sd_0196 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0196) " mean=" %12.4f scalar(t9_diag_mean_0196) " sd=" %12.4f scalar(t9_diag_sd_0196)

display as text "  Diagnostic block 0197: t9_high_income m=4"
quietly summarize t9_high_income if _mi_m == 4
scalar t9_diag_n_0197 = r(N)
scalar t9_diag_mean_0197 = r(mean)
scalar t9_diag_sd_0197 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0197) " mean=" %12.4f scalar(t9_diag_mean_0197) " sd=" %12.4f scalar(t9_diag_sd_0197)

display as text "  Diagnostic block 0198: t9_high_stress m=5"
quietly summarize t9_high_stress if _mi_m == 5
scalar t9_diag_n_0198 = r(N)
scalar t9_diag_mean_0198 = r(mean)
scalar t9_diag_sd_0198 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0198) " mean=" %12.4f scalar(t9_diag_mean_0198) " sd=" %12.4f scalar(t9_diag_sd_0198)

display as text "  Diagnostic block 0199: t9_unhealthy m=0"
quietly summarize t9_unhealthy if _mi_m == 0
scalar t9_diag_n_0199 = r(N)
scalar t9_diag_mean_0199 = r(mean)
scalar t9_diag_sd_0199 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0199) " mean=" %12.4f scalar(t9_diag_mean_0199) " sd=" %12.4f scalar(t9_diag_sd_0199)

display as text "  Diagnostic block 0200: t9_educ_level m=1"
quietly summarize t9_educ_level if _mi_m == 1
scalar t9_diag_n_0200 = r(N)
scalar t9_diag_mean_0200 = r(mean)
scalar t9_diag_sd_0200 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0200) " mean=" %12.4f scalar(t9_diag_mean_0200) " sd=" %12.4f scalar(t9_diag_sd_0200)

display as text "  Diagnostic block 0201: t9_health_level m=2"
quietly summarize t9_health_level if _mi_m == 2
scalar t9_diag_n_0201 = r(N)
scalar t9_diag_mean_0201 = r(mean)
scalar t9_diag_sd_0201 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0201) " mean=" %12.4f scalar(t9_diag_mean_0201) " sd=" %12.4f scalar(t9_diag_sd_0201)

display as text "  Diagnostic block 0202: t9_job_sat m=3"
quietly summarize t9_job_sat if _mi_m == 3
scalar t9_diag_n_0202 = r(N)
scalar t9_diag_mean_0202 = r(mean)
scalar t9_diag_sd_0202 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0202) " mean=" %12.4f scalar(t9_diag_mean_0202) " sd=" %12.4f scalar(t9_diag_sd_0202)

display as text "  Diagnostic block 0203: t9_children m=4"
quietly summarize t9_children if _mi_m == 4
scalar t9_diag_n_0203 = r(N)
scalar t9_diag_mean_0203 = r(mean)
scalar t9_diag_sd_0203 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0203) " mean=" %12.4f scalar(t9_diag_mean_0203) " sd=" %12.4f scalar(t9_diag_sd_0203)

display as text "  Diagnostic block 0204: t9_doctor_visits m=5"
quietly summarize t9_doctor_visits if _mi_m == 5
scalar t9_diag_n_0204 = r(N)
scalar t9_diag_mean_0204 = r(mean)
scalar t9_diag_sd_0204 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0204) " mean=" %12.4f scalar(t9_diag_mean_0204) " sd=" %12.4f scalar(t9_diag_sd_0204)

display as text "  Diagnostic block 0205: t9_hosp_days m=0"
quietly summarize t9_hosp_days if _mi_m == 0
scalar t9_diag_n_0205 = r(N)
scalar t9_diag_mean_0205 = r(mean)
scalar t9_diag_sd_0205 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0205) " mean=" %12.4f scalar(t9_diag_mean_0205) " sd=" %12.4f scalar(t9_diag_sd_0205)

display as text "  Diagnostic block 0206: t9_log_income m=1"
quietly summarize t9_log_income if _mi_m == 1
scalar t9_diag_n_0206 = r(N)
scalar t9_diag_mean_0206 = r(mean)
scalar t9_diag_sd_0206 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0206) " mean=" %12.4f scalar(t9_diag_mean_0206) " sd=" %12.4f scalar(t9_diag_sd_0206)

display as text "  Diagnostic block 0207: t9_log_wage m=2"
quietly summarize t9_log_wage if _mi_m == 2
scalar t9_diag_n_0207 = r(N)
scalar t9_diag_mean_0207 = r(mean)
scalar t9_diag_sd_0207 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0207) " mean=" %12.4f scalar(t9_diag_mean_0207) " sd=" %12.4f scalar(t9_diag_sd_0207)

display as text "  Diagnostic block 0208: t9_income_per_hour m=3"
quietly summarize t9_income_per_hour if _mi_m == 3
scalar t9_diag_n_0208 = r(N)
scalar t9_diag_mean_0208 = r(mean)
scalar t9_diag_sd_0208 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0208) " mean=" %12.4f scalar(t9_diag_mean_0208) " sd=" %12.4f scalar(t9_diag_sd_0208)

display as text "  Diagnostic block 0209: t9_health_index m=4"
quietly summarize t9_health_index if _mi_m == 4
scalar t9_diag_n_0209 = r(N)
scalar t9_diag_mean_0209 = r(mean)
scalar t9_diag_sd_0209 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0209) " mean=" %12.4f scalar(t9_diag_mean_0209) " sd=" %12.4f scalar(t9_diag_sd_0209)

display as text "  Diagnostic block 0210: t9_dep_stress m=5"
quietly summarize t9_dep_stress if _mi_m == 5
scalar t9_diag_n_0210 = r(N)
scalar t9_diag_mean_0210 = r(mean)
scalar t9_diag_sd_0210 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0210) " mean=" %12.4f scalar(t9_diag_mean_0210) " sd=" %12.4f scalar(t9_diag_sd_0210)

display as text "  Diagnostic block 0211: t9_income m=0"
quietly summarize t9_income if _mi_m == 0
scalar t9_diag_n_0211 = r(N)
scalar t9_diag_mean_0211 = r(mean)
scalar t9_diag_sd_0211 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0211) " mean=" %12.4f scalar(t9_diag_mean_0211) " sd=" %12.4f scalar(t9_diag_sd_0211)

display as text "  Diagnostic block 0212: t9_wage m=1"
quietly summarize t9_wage if _mi_m == 1
scalar t9_diag_n_0212 = r(N)
scalar t9_diag_mean_0212 = r(mean)
scalar t9_diag_sd_0212 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0212) " mean=" %12.4f scalar(t9_diag_mean_0212) " sd=" %12.4f scalar(t9_diag_sd_0212)

display as text "  Diagnostic block 0213: t9_hours m=2"
quietly summarize t9_hours if _mi_m == 2
scalar t9_diag_n_0213 = r(N)
scalar t9_diag_mean_0213 = r(mean)
scalar t9_diag_sd_0213 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0213) " mean=" %12.4f scalar(t9_diag_mean_0213) " sd=" %12.4f scalar(t9_diag_sd_0213)

display as text "  Diagnostic block 0214: t9_wealth m=3"
quietly summarize t9_wealth if _mi_m == 3
scalar t9_diag_n_0214 = r(N)
scalar t9_diag_mean_0214 = r(mean)
scalar t9_diag_sd_0214 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0214) " mean=" %12.4f scalar(t9_diag_mean_0214) " sd=" %12.4f scalar(t9_diag_sd_0214)

display as text "  Diagnostic block 0215: t9_savings m=4"
quietly summarize t9_savings if _mi_m == 4
scalar t9_diag_n_0215 = r(N)
scalar t9_diag_mean_0215 = r(mean)
scalar t9_diag_sd_0215 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0215) " mean=" %12.4f scalar(t9_diag_mean_0215) " sd=" %12.4f scalar(t9_diag_sd_0215)

display as text "  Diagnostic block 0216: t9_expenditure m=5"
quietly summarize t9_expenditure if _mi_m == 5
scalar t9_diag_n_0216 = r(N)
scalar t9_diag_mean_0216 = r(mean)
scalar t9_diag_sd_0216 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0216) " mean=" %12.4f scalar(t9_diag_mean_0216) " sd=" %12.4f scalar(t9_diag_sd_0216)

display as text "  Diagnostic block 0217: t9_health_score m=0"
quietly summarize t9_health_score if _mi_m == 0
scalar t9_diag_n_0217 = r(N)
scalar t9_diag_mean_0217 = r(mean)
scalar t9_diag_sd_0217 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0217) " mean=" %12.4f scalar(t9_diag_mean_0217) " sd=" %12.4f scalar(t9_diag_sd_0217)

display as text "  Diagnostic block 0218: t9_bmi m=1"
quietly summarize t9_bmi if _mi_m == 1
scalar t9_diag_n_0218 = r(N)
scalar t9_diag_mean_0218 = r(mean)
scalar t9_diag_sd_0218 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0218) " mean=" %12.4f scalar(t9_diag_mean_0218) " sd=" %12.4f scalar(t9_diag_sd_0218)

display as text "  Diagnostic block 0219: t9_bp_sys m=2"
quietly summarize t9_bp_sys if _mi_m == 2
scalar t9_diag_n_0219 = r(N)
scalar t9_diag_mean_0219 = r(mean)
scalar t9_diag_sd_0219 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0219) " mean=" %12.4f scalar(t9_diag_mean_0219) " sd=" %12.4f scalar(t9_diag_sd_0219)

display as text "  Diagnostic block 0220: t9_bp_dia m=3"
quietly summarize t9_bp_dia if _mi_m == 3
scalar t9_diag_n_0220 = r(N)
scalar t9_diag_mean_0220 = r(mean)
scalar t9_diag_sd_0220 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0220) " mean=" %12.4f scalar(t9_diag_mean_0220) " sd=" %12.4f scalar(t9_diag_sd_0220)

display as text "  Diagnostic block 0221: t9_depression m=4"
quietly summarize t9_depression if _mi_m == 4
scalar t9_diag_n_0221 = r(N)
scalar t9_diag_mean_0221 = r(mean)
scalar t9_diag_sd_0221 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0221) " mean=" %12.4f scalar(t9_diag_mean_0221) " sd=" %12.4f scalar(t9_diag_sd_0221)

display as text "  Diagnostic block 0222: t9_stress m=5"
quietly summarize t9_stress if _mi_m == 5
scalar t9_diag_n_0222 = r(N)
scalar t9_diag_mean_0222 = r(mean)
scalar t9_diag_sd_0222 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0222) " mean=" %12.4f scalar(t9_diag_mean_0222) " sd=" %12.4f scalar(t9_diag_sd_0222)

display as text "  Diagnostic block 0223: t9_satisfaction m=0"
quietly summarize t9_satisfaction if _mi_m == 0
scalar t9_diag_n_0223 = r(N)
scalar t9_diag_mean_0223 = r(mean)
scalar t9_diag_sd_0223 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0223) " mean=" %12.4f scalar(t9_diag_mean_0223) " sd=" %12.4f scalar(t9_diag_sd_0223)

display as text "  Diagnostic block 0224: t9_sleep m=1"
quietly summarize t9_sleep if _mi_m == 1
scalar t9_diag_n_0224 = r(N)
scalar t9_diag_mean_0224 = r(mean)
scalar t9_diag_sd_0224 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0224) " mean=" %12.4f scalar(t9_diag_mean_0224) " sd=" %12.4f scalar(t9_diag_sd_0224)

display as text "  Diagnostic block 0225: t9_exercise m=2"
quietly summarize t9_exercise if _mi_m == 2
scalar t9_diag_n_0225 = r(N)
scalar t9_diag_mean_0225 = r(mean)
scalar t9_diag_sd_0225 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0225) " mean=" %12.4f scalar(t9_diag_mean_0225) " sd=" %12.4f scalar(t9_diag_sd_0225)

display as text "  Diagnostic block 0226: t9_employed m=3"
quietly summarize t9_employed if _mi_m == 3
scalar t9_diag_n_0226 = r(N)
scalar t9_diag_mean_0226 = r(mean)
scalar t9_diag_sd_0226 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0226) " mean=" %12.4f scalar(t9_diag_mean_0226) " sd=" %12.4f scalar(t9_diag_sd_0226)

display as text "  Diagnostic block 0227: t9_married m=4"
quietly summarize t9_married if _mi_m == 4
scalar t9_diag_n_0227 = r(N)
scalar t9_diag_mean_0227 = r(mean)
scalar t9_diag_sd_0227 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0227) " mean=" %12.4f scalar(t9_diag_mean_0227) " sd=" %12.4f scalar(t9_diag_sd_0227)

display as text "  Diagnostic block 0228: t9_urban m=5"
quietly summarize t9_urban if _mi_m == 5
scalar t9_diag_n_0228 = r(N)
scalar t9_diag_mean_0228 = r(mean)
scalar t9_diag_sd_0228 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0228) " mean=" %12.4f scalar(t9_diag_mean_0228) " sd=" %12.4f scalar(t9_diag_sd_0228)

display as text "  Diagnostic block 0229: t9_homeowner m=0"
quietly summarize t9_homeowner if _mi_m == 0
scalar t9_diag_n_0229 = r(N)
scalar t9_diag_mean_0229 = r(mean)
scalar t9_diag_sd_0229 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0229) " mean=" %12.4f scalar(t9_diag_mean_0229) " sd=" %12.4f scalar(t9_diag_sd_0229)

display as text "  Diagnostic block 0230: t9_insured m=1"
quietly summarize t9_insured if _mi_m == 1
scalar t9_diag_n_0230 = r(N)
scalar t9_diag_mean_0230 = r(mean)
scalar t9_diag_sd_0230 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0230) " mean=" %12.4f scalar(t9_diag_mean_0230) " sd=" %12.4f scalar(t9_diag_sd_0230)

display as text "  Diagnostic block 0231: t9_smoker m=2"
quietly summarize t9_smoker if _mi_m == 2
scalar t9_diag_n_0231 = r(N)
scalar t9_diag_mean_0231 = r(mean)
scalar t9_diag_sd_0231 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0231) " mean=" %12.4f scalar(t9_diag_mean_0231) " sd=" %12.4f scalar(t9_diag_sd_0231)

display as text "  Diagnostic block 0232: t9_high_income m=3"
quietly summarize t9_high_income if _mi_m == 3
scalar t9_diag_n_0232 = r(N)
scalar t9_diag_mean_0232 = r(mean)
scalar t9_diag_sd_0232 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0232) " mean=" %12.4f scalar(t9_diag_mean_0232) " sd=" %12.4f scalar(t9_diag_sd_0232)

display as text "  Diagnostic block 0233: t9_high_stress m=4"
quietly summarize t9_high_stress if _mi_m == 4
scalar t9_diag_n_0233 = r(N)
scalar t9_diag_mean_0233 = r(mean)
scalar t9_diag_sd_0233 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0233) " mean=" %12.4f scalar(t9_diag_mean_0233) " sd=" %12.4f scalar(t9_diag_sd_0233)

display as text "  Diagnostic block 0234: t9_unhealthy m=5"
quietly summarize t9_unhealthy if _mi_m == 5
scalar t9_diag_n_0234 = r(N)
scalar t9_diag_mean_0234 = r(mean)
scalar t9_diag_sd_0234 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0234) " mean=" %12.4f scalar(t9_diag_mean_0234) " sd=" %12.4f scalar(t9_diag_sd_0234)

display as text "  Diagnostic block 0235: t9_educ_level m=0"
quietly summarize t9_educ_level if _mi_m == 0
scalar t9_diag_n_0235 = r(N)
scalar t9_diag_mean_0235 = r(mean)
scalar t9_diag_sd_0235 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0235) " mean=" %12.4f scalar(t9_diag_mean_0235) " sd=" %12.4f scalar(t9_diag_sd_0235)

display as text "  Diagnostic block 0236: t9_health_level m=1"
quietly summarize t9_health_level if _mi_m == 1
scalar t9_diag_n_0236 = r(N)
scalar t9_diag_mean_0236 = r(mean)
scalar t9_diag_sd_0236 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0236) " mean=" %12.4f scalar(t9_diag_mean_0236) " sd=" %12.4f scalar(t9_diag_sd_0236)

display as text "  Diagnostic block 0237: t9_job_sat m=2"
quietly summarize t9_job_sat if _mi_m == 2
scalar t9_diag_n_0237 = r(N)
scalar t9_diag_mean_0237 = r(mean)
scalar t9_diag_sd_0237 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0237) " mean=" %12.4f scalar(t9_diag_mean_0237) " sd=" %12.4f scalar(t9_diag_sd_0237)

display as text "  Diagnostic block 0238: t9_children m=3"
quietly summarize t9_children if _mi_m == 3
scalar t9_diag_n_0238 = r(N)
scalar t9_diag_mean_0238 = r(mean)
scalar t9_diag_sd_0238 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0238) " mean=" %12.4f scalar(t9_diag_mean_0238) " sd=" %12.4f scalar(t9_diag_sd_0238)

display as text "  Diagnostic block 0239: t9_doctor_visits m=4"
quietly summarize t9_doctor_visits if _mi_m == 4
scalar t9_diag_n_0239 = r(N)
scalar t9_diag_mean_0239 = r(mean)
scalar t9_diag_sd_0239 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0239) " mean=" %12.4f scalar(t9_diag_mean_0239) " sd=" %12.4f scalar(t9_diag_sd_0239)

display as text "  Diagnostic block 0240: t9_hosp_days m=5"
quietly summarize t9_hosp_days if _mi_m == 5
scalar t9_diag_n_0240 = r(N)
scalar t9_diag_mean_0240 = r(mean)
scalar t9_diag_sd_0240 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0240) " mean=" %12.4f scalar(t9_diag_mean_0240) " sd=" %12.4f scalar(t9_diag_sd_0240)

display as text "  Diagnostic block 0241: t9_log_income m=0"
quietly summarize t9_log_income if _mi_m == 0
scalar t9_diag_n_0241 = r(N)
scalar t9_diag_mean_0241 = r(mean)
scalar t9_diag_sd_0241 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0241) " mean=" %12.4f scalar(t9_diag_mean_0241) " sd=" %12.4f scalar(t9_diag_sd_0241)

display as text "  Diagnostic block 0242: t9_log_wage m=1"
quietly summarize t9_log_wage if _mi_m == 1
scalar t9_diag_n_0242 = r(N)
scalar t9_diag_mean_0242 = r(mean)
scalar t9_diag_sd_0242 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0242) " mean=" %12.4f scalar(t9_diag_mean_0242) " sd=" %12.4f scalar(t9_diag_sd_0242)

display as text "  Diagnostic block 0243: t9_income_per_hour m=2"
quietly summarize t9_income_per_hour if _mi_m == 2
scalar t9_diag_n_0243 = r(N)
scalar t9_diag_mean_0243 = r(mean)
scalar t9_diag_sd_0243 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0243) " mean=" %12.4f scalar(t9_diag_mean_0243) " sd=" %12.4f scalar(t9_diag_sd_0243)

display as text "  Diagnostic block 0244: t9_health_index m=3"
quietly summarize t9_health_index if _mi_m == 3
scalar t9_diag_n_0244 = r(N)
scalar t9_diag_mean_0244 = r(mean)
scalar t9_diag_sd_0244 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0244) " mean=" %12.4f scalar(t9_diag_mean_0244) " sd=" %12.4f scalar(t9_diag_sd_0244)

display as text "  Diagnostic block 0245: t9_dep_stress m=4"
quietly summarize t9_dep_stress if _mi_m == 4
scalar t9_diag_n_0245 = r(N)
scalar t9_diag_mean_0245 = r(mean)
scalar t9_diag_sd_0245 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0245) " mean=" %12.4f scalar(t9_diag_mean_0245) " sd=" %12.4f scalar(t9_diag_sd_0245)

display as text "  Diagnostic block 0246: t9_income m=5"
quietly summarize t9_income if _mi_m == 5
scalar t9_diag_n_0246 = r(N)
scalar t9_diag_mean_0246 = r(mean)
scalar t9_diag_sd_0246 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0246) " mean=" %12.4f scalar(t9_diag_mean_0246) " sd=" %12.4f scalar(t9_diag_sd_0246)

display as text "  Diagnostic block 0247: t9_wage m=0"
quietly summarize t9_wage if _mi_m == 0
scalar t9_diag_n_0247 = r(N)
scalar t9_diag_mean_0247 = r(mean)
scalar t9_diag_sd_0247 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0247) " mean=" %12.4f scalar(t9_diag_mean_0247) " sd=" %12.4f scalar(t9_diag_sd_0247)

display as text "  Diagnostic block 0248: t9_hours m=1"
quietly summarize t9_hours if _mi_m == 1
scalar t9_diag_n_0248 = r(N)
scalar t9_diag_mean_0248 = r(mean)
scalar t9_diag_sd_0248 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0248) " mean=" %12.4f scalar(t9_diag_mean_0248) " sd=" %12.4f scalar(t9_diag_sd_0248)

display as text "  Diagnostic block 0249: t9_wealth m=2"
quietly summarize t9_wealth if _mi_m == 2
scalar t9_diag_n_0249 = r(N)
scalar t9_diag_mean_0249 = r(mean)
scalar t9_diag_sd_0249 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0249) " mean=" %12.4f scalar(t9_diag_mean_0249) " sd=" %12.4f scalar(t9_diag_sd_0249)

display as text "  Diagnostic block 0250: t9_savings m=3"
quietly summarize t9_savings if _mi_m == 3
scalar t9_diag_n_0250 = r(N)
scalar t9_diag_mean_0250 = r(mean)
scalar t9_diag_sd_0250 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0250) " mean=" %12.4f scalar(t9_diag_mean_0250) " sd=" %12.4f scalar(t9_diag_sd_0250)

display as text "  Diagnostic block 0251: t9_expenditure m=4"
quietly summarize t9_expenditure if _mi_m == 4
scalar t9_diag_n_0251 = r(N)
scalar t9_diag_mean_0251 = r(mean)
scalar t9_diag_sd_0251 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0251) " mean=" %12.4f scalar(t9_diag_mean_0251) " sd=" %12.4f scalar(t9_diag_sd_0251)

display as text "  Diagnostic block 0252: t9_health_score m=5"
quietly summarize t9_health_score if _mi_m == 5
scalar t9_diag_n_0252 = r(N)
scalar t9_diag_mean_0252 = r(mean)
scalar t9_diag_sd_0252 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0252) " mean=" %12.4f scalar(t9_diag_mean_0252) " sd=" %12.4f scalar(t9_diag_sd_0252)

display as text "  Diagnostic block 0253: t9_bmi m=0"
quietly summarize t9_bmi if _mi_m == 0
scalar t9_diag_n_0253 = r(N)
scalar t9_diag_mean_0253 = r(mean)
scalar t9_diag_sd_0253 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0253) " mean=" %12.4f scalar(t9_diag_mean_0253) " sd=" %12.4f scalar(t9_diag_sd_0253)

display as text "  Diagnostic block 0254: t9_bp_sys m=1"
quietly summarize t9_bp_sys if _mi_m == 1
scalar t9_diag_n_0254 = r(N)
scalar t9_diag_mean_0254 = r(mean)
scalar t9_diag_sd_0254 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0254) " mean=" %12.4f scalar(t9_diag_mean_0254) " sd=" %12.4f scalar(t9_diag_sd_0254)

display as text "  Diagnostic block 0255: t9_bp_dia m=2"
quietly summarize t9_bp_dia if _mi_m == 2
scalar t9_diag_n_0255 = r(N)
scalar t9_diag_mean_0255 = r(mean)
scalar t9_diag_sd_0255 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0255) " mean=" %12.4f scalar(t9_diag_mean_0255) " sd=" %12.4f scalar(t9_diag_sd_0255)

display as text "  Diagnostic block 0256: t9_depression m=3"
quietly summarize t9_depression if _mi_m == 3
scalar t9_diag_n_0256 = r(N)
scalar t9_diag_mean_0256 = r(mean)
scalar t9_diag_sd_0256 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0256) " mean=" %12.4f scalar(t9_diag_mean_0256) " sd=" %12.4f scalar(t9_diag_sd_0256)

display as text "  Diagnostic block 0257: t9_stress m=4"
quietly summarize t9_stress if _mi_m == 4
scalar t9_diag_n_0257 = r(N)
scalar t9_diag_mean_0257 = r(mean)
scalar t9_diag_sd_0257 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0257) " mean=" %12.4f scalar(t9_diag_mean_0257) " sd=" %12.4f scalar(t9_diag_sd_0257)

display as text "  Diagnostic block 0258: t9_satisfaction m=5"
quietly summarize t9_satisfaction if _mi_m == 5
scalar t9_diag_n_0258 = r(N)
scalar t9_diag_mean_0258 = r(mean)
scalar t9_diag_sd_0258 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0258) " mean=" %12.4f scalar(t9_diag_mean_0258) " sd=" %12.4f scalar(t9_diag_sd_0258)

display as text "  Diagnostic block 0259: t9_sleep m=0"
quietly summarize t9_sleep if _mi_m == 0
scalar t9_diag_n_0259 = r(N)
scalar t9_diag_mean_0259 = r(mean)
scalar t9_diag_sd_0259 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0259) " mean=" %12.4f scalar(t9_diag_mean_0259) " sd=" %12.4f scalar(t9_diag_sd_0259)

display as text "  Diagnostic block 0260: t9_exercise m=1"
quietly summarize t9_exercise if _mi_m == 1
scalar t9_diag_n_0260 = r(N)
scalar t9_diag_mean_0260 = r(mean)
scalar t9_diag_sd_0260 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0260) " mean=" %12.4f scalar(t9_diag_mean_0260) " sd=" %12.4f scalar(t9_diag_sd_0260)

display as text "  Diagnostic block 0261: t9_employed m=2"
quietly summarize t9_employed if _mi_m == 2
scalar t9_diag_n_0261 = r(N)
scalar t9_diag_mean_0261 = r(mean)
scalar t9_diag_sd_0261 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0261) " mean=" %12.4f scalar(t9_diag_mean_0261) " sd=" %12.4f scalar(t9_diag_sd_0261)

display as text "  Diagnostic block 0262: t9_married m=3"
quietly summarize t9_married if _mi_m == 3
scalar t9_diag_n_0262 = r(N)
scalar t9_diag_mean_0262 = r(mean)
scalar t9_diag_sd_0262 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0262) " mean=" %12.4f scalar(t9_diag_mean_0262) " sd=" %12.4f scalar(t9_diag_sd_0262)

display as text "  Diagnostic block 0263: t9_urban m=4"
quietly summarize t9_urban if _mi_m == 4
scalar t9_diag_n_0263 = r(N)
scalar t9_diag_mean_0263 = r(mean)
scalar t9_diag_sd_0263 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0263) " mean=" %12.4f scalar(t9_diag_mean_0263) " sd=" %12.4f scalar(t9_diag_sd_0263)

display as text "  Diagnostic block 0264: t9_homeowner m=5"
quietly summarize t9_homeowner if _mi_m == 5
scalar t9_diag_n_0264 = r(N)
scalar t9_diag_mean_0264 = r(mean)
scalar t9_diag_sd_0264 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0264) " mean=" %12.4f scalar(t9_diag_mean_0264) " sd=" %12.4f scalar(t9_diag_sd_0264)

display as text "  Diagnostic block 0265: t9_insured m=0"
quietly summarize t9_insured if _mi_m == 0
scalar t9_diag_n_0265 = r(N)
scalar t9_diag_mean_0265 = r(mean)
scalar t9_diag_sd_0265 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0265) " mean=" %12.4f scalar(t9_diag_mean_0265) " sd=" %12.4f scalar(t9_diag_sd_0265)

display as text "  Diagnostic block 0266: t9_smoker m=1"
quietly summarize t9_smoker if _mi_m == 1
scalar t9_diag_n_0266 = r(N)
scalar t9_diag_mean_0266 = r(mean)
scalar t9_diag_sd_0266 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0266) " mean=" %12.4f scalar(t9_diag_mean_0266) " sd=" %12.4f scalar(t9_diag_sd_0266)

display as text "  Diagnostic block 0267: t9_high_income m=2"
quietly summarize t9_high_income if _mi_m == 2
scalar t9_diag_n_0267 = r(N)
scalar t9_diag_mean_0267 = r(mean)
scalar t9_diag_sd_0267 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0267) " mean=" %12.4f scalar(t9_diag_mean_0267) " sd=" %12.4f scalar(t9_diag_sd_0267)

display as text "  Diagnostic block 0268: t9_high_stress m=3"
quietly summarize t9_high_stress if _mi_m == 3
scalar t9_diag_n_0268 = r(N)
scalar t9_diag_mean_0268 = r(mean)
scalar t9_diag_sd_0268 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0268) " mean=" %12.4f scalar(t9_diag_mean_0268) " sd=" %12.4f scalar(t9_diag_sd_0268)

display as text "  Diagnostic block 0269: t9_unhealthy m=4"
quietly summarize t9_unhealthy if _mi_m == 4
scalar t9_diag_n_0269 = r(N)
scalar t9_diag_mean_0269 = r(mean)
scalar t9_diag_sd_0269 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0269) " mean=" %12.4f scalar(t9_diag_mean_0269) " sd=" %12.4f scalar(t9_diag_sd_0269)

display as text "  Diagnostic block 0270: t9_educ_level m=5"
quietly summarize t9_educ_level if _mi_m == 5
scalar t9_diag_n_0270 = r(N)
scalar t9_diag_mean_0270 = r(mean)
scalar t9_diag_sd_0270 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0270) " mean=" %12.4f scalar(t9_diag_mean_0270) " sd=" %12.4f scalar(t9_diag_sd_0270)

display as text "  Diagnostic block 0271: t9_health_level m=0"
quietly summarize t9_health_level if _mi_m == 0
scalar t9_diag_n_0271 = r(N)
scalar t9_diag_mean_0271 = r(mean)
scalar t9_diag_sd_0271 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0271) " mean=" %12.4f scalar(t9_diag_mean_0271) " sd=" %12.4f scalar(t9_diag_sd_0271)

display as text "  Diagnostic block 0272: t9_job_sat m=1"
quietly summarize t9_job_sat if _mi_m == 1
scalar t9_diag_n_0272 = r(N)
scalar t9_diag_mean_0272 = r(mean)
scalar t9_diag_sd_0272 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0272) " mean=" %12.4f scalar(t9_diag_mean_0272) " sd=" %12.4f scalar(t9_diag_sd_0272)

display as text "  Diagnostic block 0273: t9_children m=2"
quietly summarize t9_children if _mi_m == 2
scalar t9_diag_n_0273 = r(N)
scalar t9_diag_mean_0273 = r(mean)
scalar t9_diag_sd_0273 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0273) " mean=" %12.4f scalar(t9_diag_mean_0273) " sd=" %12.4f scalar(t9_diag_sd_0273)

display as text "  Diagnostic block 0274: t9_doctor_visits m=3"
quietly summarize t9_doctor_visits if _mi_m == 3
scalar t9_diag_n_0274 = r(N)
scalar t9_diag_mean_0274 = r(mean)
scalar t9_diag_sd_0274 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0274) " mean=" %12.4f scalar(t9_diag_mean_0274) " sd=" %12.4f scalar(t9_diag_sd_0274)

display as text "  Diagnostic block 0275: t9_hosp_days m=4"
quietly summarize t9_hosp_days if _mi_m == 4
scalar t9_diag_n_0275 = r(N)
scalar t9_diag_mean_0275 = r(mean)
scalar t9_diag_sd_0275 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0275) " mean=" %12.4f scalar(t9_diag_mean_0275) " sd=" %12.4f scalar(t9_diag_sd_0275)

display as text "  Diagnostic block 0276: t9_log_income m=5"
quietly summarize t9_log_income if _mi_m == 5
scalar t9_diag_n_0276 = r(N)
scalar t9_diag_mean_0276 = r(mean)
scalar t9_diag_sd_0276 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0276) " mean=" %12.4f scalar(t9_diag_mean_0276) " sd=" %12.4f scalar(t9_diag_sd_0276)

display as text "  Diagnostic block 0277: t9_log_wage m=0"
quietly summarize t9_log_wage if _mi_m == 0
scalar t9_diag_n_0277 = r(N)
scalar t9_diag_mean_0277 = r(mean)
scalar t9_diag_sd_0277 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0277) " mean=" %12.4f scalar(t9_diag_mean_0277) " sd=" %12.4f scalar(t9_diag_sd_0277)

display as text "  Diagnostic block 0278: t9_income_per_hour m=1"
quietly summarize t9_income_per_hour if _mi_m == 1
scalar t9_diag_n_0278 = r(N)
scalar t9_diag_mean_0278 = r(mean)
scalar t9_diag_sd_0278 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0278) " mean=" %12.4f scalar(t9_diag_mean_0278) " sd=" %12.4f scalar(t9_diag_sd_0278)

display as text "  Diagnostic block 0279: t9_health_index m=2"
quietly summarize t9_health_index if _mi_m == 2
scalar t9_diag_n_0279 = r(N)
scalar t9_diag_mean_0279 = r(mean)
scalar t9_diag_sd_0279 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0279) " mean=" %12.4f scalar(t9_diag_mean_0279) " sd=" %12.4f scalar(t9_diag_sd_0279)

display as text "  Diagnostic block 0280: t9_dep_stress m=3"
quietly summarize t9_dep_stress if _mi_m == 3
scalar t9_diag_n_0280 = r(N)
scalar t9_diag_mean_0280 = r(mean)
scalar t9_diag_sd_0280 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0280) " mean=" %12.4f scalar(t9_diag_mean_0280) " sd=" %12.4f scalar(t9_diag_sd_0280)

display as text "  Diagnostic block 0281: t9_income m=4"
quietly summarize t9_income if _mi_m == 4
scalar t9_diag_n_0281 = r(N)
scalar t9_diag_mean_0281 = r(mean)
scalar t9_diag_sd_0281 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0281) " mean=" %12.4f scalar(t9_diag_mean_0281) " sd=" %12.4f scalar(t9_diag_sd_0281)

display as text "  Diagnostic block 0282: t9_wage m=5"
quietly summarize t9_wage if _mi_m == 5
scalar t9_diag_n_0282 = r(N)
scalar t9_diag_mean_0282 = r(mean)
scalar t9_diag_sd_0282 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0282) " mean=" %12.4f scalar(t9_diag_mean_0282) " sd=" %12.4f scalar(t9_diag_sd_0282)

display as text "  Diagnostic block 0283: t9_hours m=0"
quietly summarize t9_hours if _mi_m == 0
scalar t9_diag_n_0283 = r(N)
scalar t9_diag_mean_0283 = r(mean)
scalar t9_diag_sd_0283 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0283) " mean=" %12.4f scalar(t9_diag_mean_0283) " sd=" %12.4f scalar(t9_diag_sd_0283)

display as text "  Diagnostic block 0284: t9_wealth m=1"
quietly summarize t9_wealth if _mi_m == 1
scalar t9_diag_n_0284 = r(N)
scalar t9_diag_mean_0284 = r(mean)
scalar t9_diag_sd_0284 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0284) " mean=" %12.4f scalar(t9_diag_mean_0284) " sd=" %12.4f scalar(t9_diag_sd_0284)

display as text "  Diagnostic block 0285: t9_savings m=2"
quietly summarize t9_savings if _mi_m == 2
scalar t9_diag_n_0285 = r(N)
scalar t9_diag_mean_0285 = r(mean)
scalar t9_diag_sd_0285 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0285) " mean=" %12.4f scalar(t9_diag_mean_0285) " sd=" %12.4f scalar(t9_diag_sd_0285)

display as text "  Diagnostic block 0286: t9_expenditure m=3"
quietly summarize t9_expenditure if _mi_m == 3
scalar t9_diag_n_0286 = r(N)
scalar t9_diag_mean_0286 = r(mean)
scalar t9_diag_sd_0286 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0286) " mean=" %12.4f scalar(t9_diag_mean_0286) " sd=" %12.4f scalar(t9_diag_sd_0286)

display as text "  Diagnostic block 0287: t9_health_score m=4"
quietly summarize t9_health_score if _mi_m == 4
scalar t9_diag_n_0287 = r(N)
scalar t9_diag_mean_0287 = r(mean)
scalar t9_diag_sd_0287 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0287) " mean=" %12.4f scalar(t9_diag_mean_0287) " sd=" %12.4f scalar(t9_diag_sd_0287)

display as text "  Diagnostic block 0288: t9_bmi m=5"
quietly summarize t9_bmi if _mi_m == 5
scalar t9_diag_n_0288 = r(N)
scalar t9_diag_mean_0288 = r(mean)
scalar t9_diag_sd_0288 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0288) " mean=" %12.4f scalar(t9_diag_mean_0288) " sd=" %12.4f scalar(t9_diag_sd_0288)

display as text "  Diagnostic block 0289: t9_bp_sys m=0"
quietly summarize t9_bp_sys if _mi_m == 0
scalar t9_diag_n_0289 = r(N)
scalar t9_diag_mean_0289 = r(mean)
scalar t9_diag_sd_0289 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0289) " mean=" %12.4f scalar(t9_diag_mean_0289) " sd=" %12.4f scalar(t9_diag_sd_0289)

display as text "  Diagnostic block 0290: t9_bp_dia m=1"
quietly summarize t9_bp_dia if _mi_m == 1
scalar t9_diag_n_0290 = r(N)
scalar t9_diag_mean_0290 = r(mean)
scalar t9_diag_sd_0290 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0290) " mean=" %12.4f scalar(t9_diag_mean_0290) " sd=" %12.4f scalar(t9_diag_sd_0290)

display as text "  Diagnostic block 0291: t9_depression m=2"
quietly summarize t9_depression if _mi_m == 2
scalar t9_diag_n_0291 = r(N)
scalar t9_diag_mean_0291 = r(mean)
scalar t9_diag_sd_0291 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0291) " mean=" %12.4f scalar(t9_diag_mean_0291) " sd=" %12.4f scalar(t9_diag_sd_0291)

display as text "  Diagnostic block 0292: t9_stress m=3"
quietly summarize t9_stress if _mi_m == 3
scalar t9_diag_n_0292 = r(N)
scalar t9_diag_mean_0292 = r(mean)
scalar t9_diag_sd_0292 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0292) " mean=" %12.4f scalar(t9_diag_mean_0292) " sd=" %12.4f scalar(t9_diag_sd_0292)

display as text "  Diagnostic block 0293: t9_satisfaction m=4"
quietly summarize t9_satisfaction if _mi_m == 4
scalar t9_diag_n_0293 = r(N)
scalar t9_diag_mean_0293 = r(mean)
scalar t9_diag_sd_0293 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0293) " mean=" %12.4f scalar(t9_diag_mean_0293) " sd=" %12.4f scalar(t9_diag_sd_0293)

display as text "  Diagnostic block 0294: t9_sleep m=5"
quietly summarize t9_sleep if _mi_m == 5
scalar t9_diag_n_0294 = r(N)
scalar t9_diag_mean_0294 = r(mean)
scalar t9_diag_sd_0294 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0294) " mean=" %12.4f scalar(t9_diag_mean_0294) " sd=" %12.4f scalar(t9_diag_sd_0294)

display as text "  Diagnostic block 0295: t9_exercise m=0"
quietly summarize t9_exercise if _mi_m == 0
scalar t9_diag_n_0295 = r(N)
scalar t9_diag_mean_0295 = r(mean)
scalar t9_diag_sd_0295 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0295) " mean=" %12.4f scalar(t9_diag_mean_0295) " sd=" %12.4f scalar(t9_diag_sd_0295)

display as text "  Diagnostic block 0296: t9_employed m=1"
quietly summarize t9_employed if _mi_m == 1
scalar t9_diag_n_0296 = r(N)
scalar t9_diag_mean_0296 = r(mean)
scalar t9_diag_sd_0296 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0296) " mean=" %12.4f scalar(t9_diag_mean_0296) " sd=" %12.4f scalar(t9_diag_sd_0296)

display as text "  Diagnostic block 0297: t9_married m=2"
quietly summarize t9_married if _mi_m == 2
scalar t9_diag_n_0297 = r(N)
scalar t9_diag_mean_0297 = r(mean)
scalar t9_diag_sd_0297 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0297) " mean=" %12.4f scalar(t9_diag_mean_0297) " sd=" %12.4f scalar(t9_diag_sd_0297)

display as text "  Diagnostic block 0298: t9_urban m=3"
quietly summarize t9_urban if _mi_m == 3
scalar t9_diag_n_0298 = r(N)
scalar t9_diag_mean_0298 = r(mean)
scalar t9_diag_sd_0298 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0298) " mean=" %12.4f scalar(t9_diag_mean_0298) " sd=" %12.4f scalar(t9_diag_sd_0298)

display as text "  Diagnostic block 0299: t9_homeowner m=4"
quietly summarize t9_homeowner if _mi_m == 4
scalar t9_diag_n_0299 = r(N)
scalar t9_diag_mean_0299 = r(mean)
scalar t9_diag_sd_0299 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0299) " mean=" %12.4f scalar(t9_diag_mean_0299) " sd=" %12.4f scalar(t9_diag_sd_0299)

display as text "  Diagnostic block 0300: t9_insured m=5"
quietly summarize t9_insured if _mi_m == 5
scalar t9_diag_n_0300 = r(N)
scalar t9_diag_mean_0300 = r(mean)
scalar t9_diag_sd_0300 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0300) " mean=" %12.4f scalar(t9_diag_mean_0300) " sd=" %12.4f scalar(t9_diag_sd_0300)

display as text "  Diagnostic block 0301: t9_smoker m=0"
quietly summarize t9_smoker if _mi_m == 0
scalar t9_diag_n_0301 = r(N)
scalar t9_diag_mean_0301 = r(mean)
scalar t9_diag_sd_0301 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0301) " mean=" %12.4f scalar(t9_diag_mean_0301) " sd=" %12.4f scalar(t9_diag_sd_0301)

display as text "  Diagnostic block 0302: t9_high_income m=1"
quietly summarize t9_high_income if _mi_m == 1
scalar t9_diag_n_0302 = r(N)
scalar t9_diag_mean_0302 = r(mean)
scalar t9_diag_sd_0302 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0302) " mean=" %12.4f scalar(t9_diag_mean_0302) " sd=" %12.4f scalar(t9_diag_sd_0302)

display as text "  Diagnostic block 0303: t9_high_stress m=2"
quietly summarize t9_high_stress if _mi_m == 2
scalar t9_diag_n_0303 = r(N)
scalar t9_diag_mean_0303 = r(mean)
scalar t9_diag_sd_0303 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0303) " mean=" %12.4f scalar(t9_diag_mean_0303) " sd=" %12.4f scalar(t9_diag_sd_0303)

display as text "  Diagnostic block 0304: t9_unhealthy m=3"
quietly summarize t9_unhealthy if _mi_m == 3
scalar t9_diag_n_0304 = r(N)
scalar t9_diag_mean_0304 = r(mean)
scalar t9_diag_sd_0304 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0304) " mean=" %12.4f scalar(t9_diag_mean_0304) " sd=" %12.4f scalar(t9_diag_sd_0304)

display as text "  Diagnostic block 0305: t9_educ_level m=4"
quietly summarize t9_educ_level if _mi_m == 4
scalar t9_diag_n_0305 = r(N)
scalar t9_diag_mean_0305 = r(mean)
scalar t9_diag_sd_0305 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0305) " mean=" %12.4f scalar(t9_diag_mean_0305) " sd=" %12.4f scalar(t9_diag_sd_0305)

display as text "  Diagnostic block 0306: t9_health_level m=5"
quietly summarize t9_health_level if _mi_m == 5
scalar t9_diag_n_0306 = r(N)
scalar t9_diag_mean_0306 = r(mean)
scalar t9_diag_sd_0306 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0306) " mean=" %12.4f scalar(t9_diag_mean_0306) " sd=" %12.4f scalar(t9_diag_sd_0306)

display as text "  Diagnostic block 0307: t9_job_sat m=0"
quietly summarize t9_job_sat if _mi_m == 0
scalar t9_diag_n_0307 = r(N)
scalar t9_diag_mean_0307 = r(mean)
scalar t9_diag_sd_0307 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0307) " mean=" %12.4f scalar(t9_diag_mean_0307) " sd=" %12.4f scalar(t9_diag_sd_0307)

display as text "  Diagnostic block 0308: t9_children m=1"
quietly summarize t9_children if _mi_m == 1
scalar t9_diag_n_0308 = r(N)
scalar t9_diag_mean_0308 = r(mean)
scalar t9_diag_sd_0308 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0308) " mean=" %12.4f scalar(t9_diag_mean_0308) " sd=" %12.4f scalar(t9_diag_sd_0308)

display as text "  Diagnostic block 0309: t9_doctor_visits m=2"
quietly summarize t9_doctor_visits if _mi_m == 2
scalar t9_diag_n_0309 = r(N)
scalar t9_diag_mean_0309 = r(mean)
scalar t9_diag_sd_0309 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0309) " mean=" %12.4f scalar(t9_diag_mean_0309) " sd=" %12.4f scalar(t9_diag_sd_0309)

display as text "  Diagnostic block 0310: t9_hosp_days m=3"
quietly summarize t9_hosp_days if _mi_m == 3
scalar t9_diag_n_0310 = r(N)
scalar t9_diag_mean_0310 = r(mean)
scalar t9_diag_sd_0310 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0310) " mean=" %12.4f scalar(t9_diag_mean_0310) " sd=" %12.4f scalar(t9_diag_sd_0310)

display as text "  Diagnostic block 0311: t9_log_income m=4"
quietly summarize t9_log_income if _mi_m == 4
scalar t9_diag_n_0311 = r(N)
scalar t9_diag_mean_0311 = r(mean)
scalar t9_diag_sd_0311 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0311) " mean=" %12.4f scalar(t9_diag_mean_0311) " sd=" %12.4f scalar(t9_diag_sd_0311)

display as text "  Diagnostic block 0312: t9_log_wage m=5"
quietly summarize t9_log_wage if _mi_m == 5
scalar t9_diag_n_0312 = r(N)
scalar t9_diag_mean_0312 = r(mean)
scalar t9_diag_sd_0312 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0312) " mean=" %12.4f scalar(t9_diag_mean_0312) " sd=" %12.4f scalar(t9_diag_sd_0312)

display as text "  Diagnostic block 0313: t9_income_per_hour m=0"
quietly summarize t9_income_per_hour if _mi_m == 0
scalar t9_diag_n_0313 = r(N)
scalar t9_diag_mean_0313 = r(mean)
scalar t9_diag_sd_0313 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0313) " mean=" %12.4f scalar(t9_diag_mean_0313) " sd=" %12.4f scalar(t9_diag_sd_0313)

display as text "  Diagnostic block 0314: t9_health_index m=1"
quietly summarize t9_health_index if _mi_m == 1
scalar t9_diag_n_0314 = r(N)
scalar t9_diag_mean_0314 = r(mean)
scalar t9_diag_sd_0314 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0314) " mean=" %12.4f scalar(t9_diag_mean_0314) " sd=" %12.4f scalar(t9_diag_sd_0314)

display as text "  Diagnostic block 0315: t9_dep_stress m=2"
quietly summarize t9_dep_stress if _mi_m == 2
scalar t9_diag_n_0315 = r(N)
scalar t9_diag_mean_0315 = r(mean)
scalar t9_diag_sd_0315 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0315) " mean=" %12.4f scalar(t9_diag_mean_0315) " sd=" %12.4f scalar(t9_diag_sd_0315)

display as text "  Diagnostic block 0316: t9_income m=3"
quietly summarize t9_income if _mi_m == 3
scalar t9_diag_n_0316 = r(N)
scalar t9_diag_mean_0316 = r(mean)
scalar t9_diag_sd_0316 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0316) " mean=" %12.4f scalar(t9_diag_mean_0316) " sd=" %12.4f scalar(t9_diag_sd_0316)

display as text "  Diagnostic block 0317: t9_wage m=4"
quietly summarize t9_wage if _mi_m == 4
scalar t9_diag_n_0317 = r(N)
scalar t9_diag_mean_0317 = r(mean)
scalar t9_diag_sd_0317 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0317) " mean=" %12.4f scalar(t9_diag_mean_0317) " sd=" %12.4f scalar(t9_diag_sd_0317)

display as text "  Diagnostic block 0318: t9_hours m=5"
quietly summarize t9_hours if _mi_m == 5
scalar t9_diag_n_0318 = r(N)
scalar t9_diag_mean_0318 = r(mean)
scalar t9_diag_sd_0318 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0318) " mean=" %12.4f scalar(t9_diag_mean_0318) " sd=" %12.4f scalar(t9_diag_sd_0318)

display as text "  Diagnostic block 0319: t9_wealth m=0"
quietly summarize t9_wealth if _mi_m == 0
scalar t9_diag_n_0319 = r(N)
scalar t9_diag_mean_0319 = r(mean)
scalar t9_diag_sd_0319 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0319) " mean=" %12.4f scalar(t9_diag_mean_0319) " sd=" %12.4f scalar(t9_diag_sd_0319)

display as text "  Diagnostic block 0320: t9_savings m=1"
quietly summarize t9_savings if _mi_m == 1
scalar t9_diag_n_0320 = r(N)
scalar t9_diag_mean_0320 = r(mean)
scalar t9_diag_sd_0320 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0320) " mean=" %12.4f scalar(t9_diag_mean_0320) " sd=" %12.4f scalar(t9_diag_sd_0320)

display as text "  Diagnostic block 0321: t9_expenditure m=2"
quietly summarize t9_expenditure if _mi_m == 2
scalar t9_diag_n_0321 = r(N)
scalar t9_diag_mean_0321 = r(mean)
scalar t9_diag_sd_0321 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0321) " mean=" %12.4f scalar(t9_diag_mean_0321) " sd=" %12.4f scalar(t9_diag_sd_0321)

display as text "  Diagnostic block 0322: t9_health_score m=3"
quietly summarize t9_health_score if _mi_m == 3
scalar t9_diag_n_0322 = r(N)
scalar t9_diag_mean_0322 = r(mean)
scalar t9_diag_sd_0322 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0322) " mean=" %12.4f scalar(t9_diag_mean_0322) " sd=" %12.4f scalar(t9_diag_sd_0322)

display as text "  Diagnostic block 0323: t9_bmi m=4"
quietly summarize t9_bmi if _mi_m == 4
scalar t9_diag_n_0323 = r(N)
scalar t9_diag_mean_0323 = r(mean)
scalar t9_diag_sd_0323 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0323) " mean=" %12.4f scalar(t9_diag_mean_0323) " sd=" %12.4f scalar(t9_diag_sd_0323)

display as text "  Diagnostic block 0324: t9_bp_sys m=5"
quietly summarize t9_bp_sys if _mi_m == 5
scalar t9_diag_n_0324 = r(N)
scalar t9_diag_mean_0324 = r(mean)
scalar t9_diag_sd_0324 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0324) " mean=" %12.4f scalar(t9_diag_mean_0324) " sd=" %12.4f scalar(t9_diag_sd_0324)

display as text "  Diagnostic block 0325: t9_bp_dia m=0"
quietly summarize t9_bp_dia if _mi_m == 0
scalar t9_diag_n_0325 = r(N)
scalar t9_diag_mean_0325 = r(mean)
scalar t9_diag_sd_0325 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0325) " mean=" %12.4f scalar(t9_diag_mean_0325) " sd=" %12.4f scalar(t9_diag_sd_0325)

display as text "  Diagnostic block 0326: t9_depression m=1"
quietly summarize t9_depression if _mi_m == 1
scalar t9_diag_n_0326 = r(N)
scalar t9_diag_mean_0326 = r(mean)
scalar t9_diag_sd_0326 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0326) " mean=" %12.4f scalar(t9_diag_mean_0326) " sd=" %12.4f scalar(t9_diag_sd_0326)

display as text "  Diagnostic block 0327: t9_stress m=2"
quietly summarize t9_stress if _mi_m == 2
scalar t9_diag_n_0327 = r(N)
scalar t9_diag_mean_0327 = r(mean)
scalar t9_diag_sd_0327 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0327) " mean=" %12.4f scalar(t9_diag_mean_0327) " sd=" %12.4f scalar(t9_diag_sd_0327)

display as text "  Diagnostic block 0328: t9_satisfaction m=3"
quietly summarize t9_satisfaction if _mi_m == 3
scalar t9_diag_n_0328 = r(N)
scalar t9_diag_mean_0328 = r(mean)
scalar t9_diag_sd_0328 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0328) " mean=" %12.4f scalar(t9_diag_mean_0328) " sd=" %12.4f scalar(t9_diag_sd_0328)

display as text "  Diagnostic block 0329: t9_sleep m=4"
quietly summarize t9_sleep if _mi_m == 4
scalar t9_diag_n_0329 = r(N)
scalar t9_diag_mean_0329 = r(mean)
scalar t9_diag_sd_0329 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0329) " mean=" %12.4f scalar(t9_diag_mean_0329) " sd=" %12.4f scalar(t9_diag_sd_0329)

display as text "  Diagnostic block 0330: t9_exercise m=5"
quietly summarize t9_exercise if _mi_m == 5
scalar t9_diag_n_0330 = r(N)
scalar t9_diag_mean_0330 = r(mean)
scalar t9_diag_sd_0330 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0330) " mean=" %12.4f scalar(t9_diag_mean_0330) " sd=" %12.4f scalar(t9_diag_sd_0330)

display as text "  Diagnostic block 0331: t9_employed m=0"
quietly summarize t9_employed if _mi_m == 0
scalar t9_diag_n_0331 = r(N)
scalar t9_diag_mean_0331 = r(mean)
scalar t9_diag_sd_0331 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0331) " mean=" %12.4f scalar(t9_diag_mean_0331) " sd=" %12.4f scalar(t9_diag_sd_0331)

display as text "  Diagnostic block 0332: t9_married m=1"
quietly summarize t9_married if _mi_m == 1
scalar t9_diag_n_0332 = r(N)
scalar t9_diag_mean_0332 = r(mean)
scalar t9_diag_sd_0332 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0332) " mean=" %12.4f scalar(t9_diag_mean_0332) " sd=" %12.4f scalar(t9_diag_sd_0332)

display as text "  Diagnostic block 0333: t9_urban m=2"
quietly summarize t9_urban if _mi_m == 2
scalar t9_diag_n_0333 = r(N)
scalar t9_diag_mean_0333 = r(mean)
scalar t9_diag_sd_0333 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0333) " mean=" %12.4f scalar(t9_diag_mean_0333) " sd=" %12.4f scalar(t9_diag_sd_0333)

display as text "  Diagnostic block 0334: t9_homeowner m=3"
quietly summarize t9_homeowner if _mi_m == 3
scalar t9_diag_n_0334 = r(N)
scalar t9_diag_mean_0334 = r(mean)
scalar t9_diag_sd_0334 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0334) " mean=" %12.4f scalar(t9_diag_mean_0334) " sd=" %12.4f scalar(t9_diag_sd_0334)

display as text "  Diagnostic block 0335: t9_insured m=4"
quietly summarize t9_insured if _mi_m == 4
scalar t9_diag_n_0335 = r(N)
scalar t9_diag_mean_0335 = r(mean)
scalar t9_diag_sd_0335 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0335) " mean=" %12.4f scalar(t9_diag_mean_0335) " sd=" %12.4f scalar(t9_diag_sd_0335)

display as text "  Diagnostic block 0336: t9_smoker m=5"
quietly summarize t9_smoker if _mi_m == 5
scalar t9_diag_n_0336 = r(N)
scalar t9_diag_mean_0336 = r(mean)
scalar t9_diag_sd_0336 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0336) " mean=" %12.4f scalar(t9_diag_mean_0336) " sd=" %12.4f scalar(t9_diag_sd_0336)

display as text "  Diagnostic block 0337: t9_high_income m=0"
quietly summarize t9_high_income if _mi_m == 0
scalar t9_diag_n_0337 = r(N)
scalar t9_diag_mean_0337 = r(mean)
scalar t9_diag_sd_0337 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0337) " mean=" %12.4f scalar(t9_diag_mean_0337) " sd=" %12.4f scalar(t9_diag_sd_0337)

display as text "  Diagnostic block 0338: t9_high_stress m=1"
quietly summarize t9_high_stress if _mi_m == 1
scalar t9_diag_n_0338 = r(N)
scalar t9_diag_mean_0338 = r(mean)
scalar t9_diag_sd_0338 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0338) " mean=" %12.4f scalar(t9_diag_mean_0338) " sd=" %12.4f scalar(t9_diag_sd_0338)

display as text "  Diagnostic block 0339: t9_unhealthy m=2"
quietly summarize t9_unhealthy if _mi_m == 2
scalar t9_diag_n_0339 = r(N)
scalar t9_diag_mean_0339 = r(mean)
scalar t9_diag_sd_0339 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0339) " mean=" %12.4f scalar(t9_diag_mean_0339) " sd=" %12.4f scalar(t9_diag_sd_0339)

display as text "  Diagnostic block 0340: t9_educ_level m=3"
quietly summarize t9_educ_level if _mi_m == 3
scalar t9_diag_n_0340 = r(N)
scalar t9_diag_mean_0340 = r(mean)
scalar t9_diag_sd_0340 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0340) " mean=" %12.4f scalar(t9_diag_mean_0340) " sd=" %12.4f scalar(t9_diag_sd_0340)

display as text "  Diagnostic block 0341: t9_health_level m=4"
quietly summarize t9_health_level if _mi_m == 4
scalar t9_diag_n_0341 = r(N)
scalar t9_diag_mean_0341 = r(mean)
scalar t9_diag_sd_0341 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0341) " mean=" %12.4f scalar(t9_diag_mean_0341) " sd=" %12.4f scalar(t9_diag_sd_0341)

display as text "  Diagnostic block 0342: t9_job_sat m=5"
quietly summarize t9_job_sat if _mi_m == 5
scalar t9_diag_n_0342 = r(N)
scalar t9_diag_mean_0342 = r(mean)
scalar t9_diag_sd_0342 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0342) " mean=" %12.4f scalar(t9_diag_mean_0342) " sd=" %12.4f scalar(t9_diag_sd_0342)

display as text "  Diagnostic block 0343: t9_children m=0"
quietly summarize t9_children if _mi_m == 0
scalar t9_diag_n_0343 = r(N)
scalar t9_diag_mean_0343 = r(mean)
scalar t9_diag_sd_0343 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0343) " mean=" %12.4f scalar(t9_diag_mean_0343) " sd=" %12.4f scalar(t9_diag_sd_0343)

display as text "  Diagnostic block 0344: t9_doctor_visits m=1"
quietly summarize t9_doctor_visits if _mi_m == 1
scalar t9_diag_n_0344 = r(N)
scalar t9_diag_mean_0344 = r(mean)
scalar t9_diag_sd_0344 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0344) " mean=" %12.4f scalar(t9_diag_mean_0344) " sd=" %12.4f scalar(t9_diag_sd_0344)

display as text "  Diagnostic block 0345: t9_hosp_days m=2"
quietly summarize t9_hosp_days if _mi_m == 2
scalar t9_diag_n_0345 = r(N)
scalar t9_diag_mean_0345 = r(mean)
scalar t9_diag_sd_0345 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0345) " mean=" %12.4f scalar(t9_diag_mean_0345) " sd=" %12.4f scalar(t9_diag_sd_0345)

display as text "  Diagnostic block 0346: t9_log_income m=3"
quietly summarize t9_log_income if _mi_m == 3
scalar t9_diag_n_0346 = r(N)
scalar t9_diag_mean_0346 = r(mean)
scalar t9_diag_sd_0346 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0346) " mean=" %12.4f scalar(t9_diag_mean_0346) " sd=" %12.4f scalar(t9_diag_sd_0346)

display as text "  Diagnostic block 0347: t9_log_wage m=4"
quietly summarize t9_log_wage if _mi_m == 4
scalar t9_diag_n_0347 = r(N)
scalar t9_diag_mean_0347 = r(mean)
scalar t9_diag_sd_0347 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0347) " mean=" %12.4f scalar(t9_diag_mean_0347) " sd=" %12.4f scalar(t9_diag_sd_0347)

display as text "  Diagnostic block 0348: t9_income_per_hour m=5"
quietly summarize t9_income_per_hour if _mi_m == 5
scalar t9_diag_n_0348 = r(N)
scalar t9_diag_mean_0348 = r(mean)
scalar t9_diag_sd_0348 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0348) " mean=" %12.4f scalar(t9_diag_mean_0348) " sd=" %12.4f scalar(t9_diag_sd_0348)

display as text "  Diagnostic block 0349: t9_health_index m=0"
quietly summarize t9_health_index if _mi_m == 0
scalar t9_diag_n_0349 = r(N)
scalar t9_diag_mean_0349 = r(mean)
scalar t9_diag_sd_0349 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0349) " mean=" %12.4f scalar(t9_diag_mean_0349) " sd=" %12.4f scalar(t9_diag_sd_0349)

display as text "  Diagnostic block 0350: t9_dep_stress m=1"
quietly summarize t9_dep_stress if _mi_m == 1
scalar t9_diag_n_0350 = r(N)
scalar t9_diag_mean_0350 = r(mean)
scalar t9_diag_sd_0350 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0350) " mean=" %12.4f scalar(t9_diag_mean_0350) " sd=" %12.4f scalar(t9_diag_sd_0350)

display as text "  Diagnostic block 0351: t9_income m=2"
quietly summarize t9_income if _mi_m == 2
scalar t9_diag_n_0351 = r(N)
scalar t9_diag_mean_0351 = r(mean)
scalar t9_diag_sd_0351 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0351) " mean=" %12.4f scalar(t9_diag_mean_0351) " sd=" %12.4f scalar(t9_diag_sd_0351)

display as text "  Diagnostic block 0352: t9_wage m=3"
quietly summarize t9_wage if _mi_m == 3
scalar t9_diag_n_0352 = r(N)
scalar t9_diag_mean_0352 = r(mean)
scalar t9_diag_sd_0352 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0352) " mean=" %12.4f scalar(t9_diag_mean_0352) " sd=" %12.4f scalar(t9_diag_sd_0352)

display as text "  Diagnostic block 0353: t9_hours m=4"
quietly summarize t9_hours if _mi_m == 4
scalar t9_diag_n_0353 = r(N)
scalar t9_diag_mean_0353 = r(mean)
scalar t9_diag_sd_0353 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0353) " mean=" %12.4f scalar(t9_diag_mean_0353) " sd=" %12.4f scalar(t9_diag_sd_0353)

display as text "  Diagnostic block 0354: t9_wealth m=5"
quietly summarize t9_wealth if _mi_m == 5
scalar t9_diag_n_0354 = r(N)
scalar t9_diag_mean_0354 = r(mean)
scalar t9_diag_sd_0354 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0354) " mean=" %12.4f scalar(t9_diag_mean_0354) " sd=" %12.4f scalar(t9_diag_sd_0354)

display as text "  Diagnostic block 0355: t9_savings m=0"
quietly summarize t9_savings if _mi_m == 0
scalar t9_diag_n_0355 = r(N)
scalar t9_diag_mean_0355 = r(mean)
scalar t9_diag_sd_0355 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0355) " mean=" %12.4f scalar(t9_diag_mean_0355) " sd=" %12.4f scalar(t9_diag_sd_0355)

display as text "  Diagnostic block 0356: t9_expenditure m=1"
quietly summarize t9_expenditure if _mi_m == 1
scalar t9_diag_n_0356 = r(N)
scalar t9_diag_mean_0356 = r(mean)
scalar t9_diag_sd_0356 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0356) " mean=" %12.4f scalar(t9_diag_mean_0356) " sd=" %12.4f scalar(t9_diag_sd_0356)

display as text "  Diagnostic block 0357: t9_health_score m=2"
quietly summarize t9_health_score if _mi_m == 2
scalar t9_diag_n_0357 = r(N)
scalar t9_diag_mean_0357 = r(mean)
scalar t9_diag_sd_0357 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0357) " mean=" %12.4f scalar(t9_diag_mean_0357) " sd=" %12.4f scalar(t9_diag_sd_0357)

display as text "  Diagnostic block 0358: t9_bmi m=3"
quietly summarize t9_bmi if _mi_m == 3
scalar t9_diag_n_0358 = r(N)
scalar t9_diag_mean_0358 = r(mean)
scalar t9_diag_sd_0358 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0358) " mean=" %12.4f scalar(t9_diag_mean_0358) " sd=" %12.4f scalar(t9_diag_sd_0358)

display as text "  Diagnostic block 0359: t9_bp_sys m=4"
quietly summarize t9_bp_sys if _mi_m == 4
scalar t9_diag_n_0359 = r(N)
scalar t9_diag_mean_0359 = r(mean)
scalar t9_diag_sd_0359 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0359) " mean=" %12.4f scalar(t9_diag_mean_0359) " sd=" %12.4f scalar(t9_diag_sd_0359)

display as text "  Diagnostic block 0360: t9_bp_dia m=5"
quietly summarize t9_bp_dia if _mi_m == 5
scalar t9_diag_n_0360 = r(N)
scalar t9_diag_mean_0360 = r(mean)
scalar t9_diag_sd_0360 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0360) " mean=" %12.4f scalar(t9_diag_mean_0360) " sd=" %12.4f scalar(t9_diag_sd_0360)

display as text "  Diagnostic block 0361: t9_depression m=0"
quietly summarize t9_depression if _mi_m == 0
scalar t9_diag_n_0361 = r(N)
scalar t9_diag_mean_0361 = r(mean)
scalar t9_diag_sd_0361 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0361) " mean=" %12.4f scalar(t9_diag_mean_0361) " sd=" %12.4f scalar(t9_diag_sd_0361)

display as text "  Diagnostic block 0362: t9_stress m=1"
quietly summarize t9_stress if _mi_m == 1
scalar t9_diag_n_0362 = r(N)
scalar t9_diag_mean_0362 = r(mean)
scalar t9_diag_sd_0362 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0362) " mean=" %12.4f scalar(t9_diag_mean_0362) " sd=" %12.4f scalar(t9_diag_sd_0362)

display as text "  Diagnostic block 0363: t9_satisfaction m=2"
quietly summarize t9_satisfaction if _mi_m == 2
scalar t9_diag_n_0363 = r(N)
scalar t9_diag_mean_0363 = r(mean)
scalar t9_diag_sd_0363 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0363) " mean=" %12.4f scalar(t9_diag_mean_0363) " sd=" %12.4f scalar(t9_diag_sd_0363)

display as text "  Diagnostic block 0364: t9_sleep m=3"
quietly summarize t9_sleep if _mi_m == 3
scalar t9_diag_n_0364 = r(N)
scalar t9_diag_mean_0364 = r(mean)
scalar t9_diag_sd_0364 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0364) " mean=" %12.4f scalar(t9_diag_mean_0364) " sd=" %12.4f scalar(t9_diag_sd_0364)

display as text "  Diagnostic block 0365: t9_exercise m=4"
quietly summarize t9_exercise if _mi_m == 4
scalar t9_diag_n_0365 = r(N)
scalar t9_diag_mean_0365 = r(mean)
scalar t9_diag_sd_0365 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0365) " mean=" %12.4f scalar(t9_diag_mean_0365) " sd=" %12.4f scalar(t9_diag_sd_0365)

display as text "  Diagnostic block 0366: t9_employed m=5"
quietly summarize t9_employed if _mi_m == 5
scalar t9_diag_n_0366 = r(N)
scalar t9_diag_mean_0366 = r(mean)
scalar t9_diag_sd_0366 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0366) " mean=" %12.4f scalar(t9_diag_mean_0366) " sd=" %12.4f scalar(t9_diag_sd_0366)

display as text "  Diagnostic block 0367: t9_married m=0"
quietly summarize t9_married if _mi_m == 0
scalar t9_diag_n_0367 = r(N)
scalar t9_diag_mean_0367 = r(mean)
scalar t9_diag_sd_0367 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0367) " mean=" %12.4f scalar(t9_diag_mean_0367) " sd=" %12.4f scalar(t9_diag_sd_0367)

display as text "  Diagnostic block 0368: t9_urban m=1"
quietly summarize t9_urban if _mi_m == 1
scalar t9_diag_n_0368 = r(N)
scalar t9_diag_mean_0368 = r(mean)
scalar t9_diag_sd_0368 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0368) " mean=" %12.4f scalar(t9_diag_mean_0368) " sd=" %12.4f scalar(t9_diag_sd_0368)

display as text "  Diagnostic block 0369: t9_homeowner m=2"
quietly summarize t9_homeowner if _mi_m == 2
scalar t9_diag_n_0369 = r(N)
scalar t9_diag_mean_0369 = r(mean)
scalar t9_diag_sd_0369 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0369) " mean=" %12.4f scalar(t9_diag_mean_0369) " sd=" %12.4f scalar(t9_diag_sd_0369)

display as text "  Diagnostic block 0370: t9_insured m=3"
quietly summarize t9_insured if _mi_m == 3
scalar t9_diag_n_0370 = r(N)
scalar t9_diag_mean_0370 = r(mean)
scalar t9_diag_sd_0370 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0370) " mean=" %12.4f scalar(t9_diag_mean_0370) " sd=" %12.4f scalar(t9_diag_sd_0370)

display as text "  Diagnostic block 0371: t9_smoker m=4"
quietly summarize t9_smoker if _mi_m == 4
scalar t9_diag_n_0371 = r(N)
scalar t9_diag_mean_0371 = r(mean)
scalar t9_diag_sd_0371 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0371) " mean=" %12.4f scalar(t9_diag_mean_0371) " sd=" %12.4f scalar(t9_diag_sd_0371)

display as text "  Diagnostic block 0372: t9_high_income m=5"
quietly summarize t9_high_income if _mi_m == 5
scalar t9_diag_n_0372 = r(N)
scalar t9_diag_mean_0372 = r(mean)
scalar t9_diag_sd_0372 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0372) " mean=" %12.4f scalar(t9_diag_mean_0372) " sd=" %12.4f scalar(t9_diag_sd_0372)

display as text "  Diagnostic block 0373: t9_high_stress m=0"
quietly summarize t9_high_stress if _mi_m == 0
scalar t9_diag_n_0373 = r(N)
scalar t9_diag_mean_0373 = r(mean)
scalar t9_diag_sd_0373 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0373) " mean=" %12.4f scalar(t9_diag_mean_0373) " sd=" %12.4f scalar(t9_diag_sd_0373)

display as text "  Diagnostic block 0374: t9_unhealthy m=1"
quietly summarize t9_unhealthy if _mi_m == 1
scalar t9_diag_n_0374 = r(N)
scalar t9_diag_mean_0374 = r(mean)
scalar t9_diag_sd_0374 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0374) " mean=" %12.4f scalar(t9_diag_mean_0374) " sd=" %12.4f scalar(t9_diag_sd_0374)

display as text "  Diagnostic block 0375: t9_educ_level m=2"
quietly summarize t9_educ_level if _mi_m == 2
scalar t9_diag_n_0375 = r(N)
scalar t9_diag_mean_0375 = r(mean)
scalar t9_diag_sd_0375 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0375) " mean=" %12.4f scalar(t9_diag_mean_0375) " sd=" %12.4f scalar(t9_diag_sd_0375)

display as text "  Diagnostic block 0376: t9_health_level m=3"
quietly summarize t9_health_level if _mi_m == 3
scalar t9_diag_n_0376 = r(N)
scalar t9_diag_mean_0376 = r(mean)
scalar t9_diag_sd_0376 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0376) " mean=" %12.4f scalar(t9_diag_mean_0376) " sd=" %12.4f scalar(t9_diag_sd_0376)

display as text "  Diagnostic block 0377: t9_job_sat m=4"
quietly summarize t9_job_sat if _mi_m == 4
scalar t9_diag_n_0377 = r(N)
scalar t9_diag_mean_0377 = r(mean)
scalar t9_diag_sd_0377 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0377) " mean=" %12.4f scalar(t9_diag_mean_0377) " sd=" %12.4f scalar(t9_diag_sd_0377)

display as text "  Diagnostic block 0378: t9_children m=5"
quietly summarize t9_children if _mi_m == 5
scalar t9_diag_n_0378 = r(N)
scalar t9_diag_mean_0378 = r(mean)
scalar t9_diag_sd_0378 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0378) " mean=" %12.4f scalar(t9_diag_mean_0378) " sd=" %12.4f scalar(t9_diag_sd_0378)

display as text "  Diagnostic block 0379: t9_doctor_visits m=0"
quietly summarize t9_doctor_visits if _mi_m == 0
scalar t9_diag_n_0379 = r(N)
scalar t9_diag_mean_0379 = r(mean)
scalar t9_diag_sd_0379 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0379) " mean=" %12.4f scalar(t9_diag_mean_0379) " sd=" %12.4f scalar(t9_diag_sd_0379)

display as text "  Diagnostic block 0380: t9_hosp_days m=1"
quietly summarize t9_hosp_days if _mi_m == 1
scalar t9_diag_n_0380 = r(N)
scalar t9_diag_mean_0380 = r(mean)
scalar t9_diag_sd_0380 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0380) " mean=" %12.4f scalar(t9_diag_mean_0380) " sd=" %12.4f scalar(t9_diag_sd_0380)

display as text "  Diagnostic block 0381: t9_log_income m=2"
quietly summarize t9_log_income if _mi_m == 2
scalar t9_diag_n_0381 = r(N)
scalar t9_diag_mean_0381 = r(mean)
scalar t9_diag_sd_0381 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0381) " mean=" %12.4f scalar(t9_diag_mean_0381) " sd=" %12.4f scalar(t9_diag_sd_0381)

display as text "  Diagnostic block 0382: t9_log_wage m=3"
quietly summarize t9_log_wage if _mi_m == 3
scalar t9_diag_n_0382 = r(N)
scalar t9_diag_mean_0382 = r(mean)
scalar t9_diag_sd_0382 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0382) " mean=" %12.4f scalar(t9_diag_mean_0382) " sd=" %12.4f scalar(t9_diag_sd_0382)

display as text "  Diagnostic block 0383: t9_income_per_hour m=4"
quietly summarize t9_income_per_hour if _mi_m == 4
scalar t9_diag_n_0383 = r(N)
scalar t9_diag_mean_0383 = r(mean)
scalar t9_diag_sd_0383 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0383) " mean=" %12.4f scalar(t9_diag_mean_0383) " sd=" %12.4f scalar(t9_diag_sd_0383)

display as text "  Diagnostic block 0384: t9_health_index m=5"
quietly summarize t9_health_index if _mi_m == 5
scalar t9_diag_n_0384 = r(N)
scalar t9_diag_mean_0384 = r(mean)
scalar t9_diag_sd_0384 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0384) " mean=" %12.4f scalar(t9_diag_mean_0384) " sd=" %12.4f scalar(t9_diag_sd_0384)

display as text "  Diagnostic block 0385: t9_dep_stress m=0"
quietly summarize t9_dep_stress if _mi_m == 0
scalar t9_diag_n_0385 = r(N)
scalar t9_diag_mean_0385 = r(mean)
scalar t9_diag_sd_0385 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0385) " mean=" %12.4f scalar(t9_diag_mean_0385) " sd=" %12.4f scalar(t9_diag_sd_0385)

display as text "  Diagnostic block 0386: t9_income m=1"
quietly summarize t9_income if _mi_m == 1
scalar t9_diag_n_0386 = r(N)
scalar t9_diag_mean_0386 = r(mean)
scalar t9_diag_sd_0386 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0386) " mean=" %12.4f scalar(t9_diag_mean_0386) " sd=" %12.4f scalar(t9_diag_sd_0386)

display as text "  Diagnostic block 0387: t9_wage m=2"
quietly summarize t9_wage if _mi_m == 2
scalar t9_diag_n_0387 = r(N)
scalar t9_diag_mean_0387 = r(mean)
scalar t9_diag_sd_0387 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0387) " mean=" %12.4f scalar(t9_diag_mean_0387) " sd=" %12.4f scalar(t9_diag_sd_0387)

display as text "  Diagnostic block 0388: t9_hours m=3"
quietly summarize t9_hours if _mi_m == 3
scalar t9_diag_n_0388 = r(N)
scalar t9_diag_mean_0388 = r(mean)
scalar t9_diag_sd_0388 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0388) " mean=" %12.4f scalar(t9_diag_mean_0388) " sd=" %12.4f scalar(t9_diag_sd_0388)

display as text "  Diagnostic block 0389: t9_wealth m=4"
quietly summarize t9_wealth if _mi_m == 4
scalar t9_diag_n_0389 = r(N)
scalar t9_diag_mean_0389 = r(mean)
scalar t9_diag_sd_0389 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0389) " mean=" %12.4f scalar(t9_diag_mean_0389) " sd=" %12.4f scalar(t9_diag_sd_0389)

display as text "  Diagnostic block 0390: t9_savings m=5"
quietly summarize t9_savings if _mi_m == 5
scalar t9_diag_n_0390 = r(N)
scalar t9_diag_mean_0390 = r(mean)
scalar t9_diag_sd_0390 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0390) " mean=" %12.4f scalar(t9_diag_mean_0390) " sd=" %12.4f scalar(t9_diag_sd_0390)

display as text "  Diagnostic block 0391: t9_expenditure m=0"
quietly summarize t9_expenditure if _mi_m == 0
scalar t9_diag_n_0391 = r(N)
scalar t9_diag_mean_0391 = r(mean)
scalar t9_diag_sd_0391 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0391) " mean=" %12.4f scalar(t9_diag_mean_0391) " sd=" %12.4f scalar(t9_diag_sd_0391)

display as text "  Diagnostic block 0392: t9_health_score m=1"
quietly summarize t9_health_score if _mi_m == 1
scalar t9_diag_n_0392 = r(N)
scalar t9_diag_mean_0392 = r(mean)
scalar t9_diag_sd_0392 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0392) " mean=" %12.4f scalar(t9_diag_mean_0392) " sd=" %12.4f scalar(t9_diag_sd_0392)

display as text "  Diagnostic block 0393: t9_bmi m=2"
quietly summarize t9_bmi if _mi_m == 2
scalar t9_diag_n_0393 = r(N)
scalar t9_diag_mean_0393 = r(mean)
scalar t9_diag_sd_0393 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0393) " mean=" %12.4f scalar(t9_diag_mean_0393) " sd=" %12.4f scalar(t9_diag_sd_0393)

display as text "  Diagnostic block 0394: t9_bp_sys m=3"
quietly summarize t9_bp_sys if _mi_m == 3
scalar t9_diag_n_0394 = r(N)
scalar t9_diag_mean_0394 = r(mean)
scalar t9_diag_sd_0394 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0394) " mean=" %12.4f scalar(t9_diag_mean_0394) " sd=" %12.4f scalar(t9_diag_sd_0394)

display as text "  Diagnostic block 0395: t9_bp_dia m=4"
quietly summarize t9_bp_dia if _mi_m == 4
scalar t9_diag_n_0395 = r(N)
scalar t9_diag_mean_0395 = r(mean)
scalar t9_diag_sd_0395 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0395) " mean=" %12.4f scalar(t9_diag_mean_0395) " sd=" %12.4f scalar(t9_diag_sd_0395)

display as text "  Diagnostic block 0396: t9_depression m=5"
quietly summarize t9_depression if _mi_m == 5
scalar t9_diag_n_0396 = r(N)
scalar t9_diag_mean_0396 = r(mean)
scalar t9_diag_sd_0396 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0396) " mean=" %12.4f scalar(t9_diag_mean_0396) " sd=" %12.4f scalar(t9_diag_sd_0396)

display as text "  Diagnostic block 0397: t9_stress m=0"
quietly summarize t9_stress if _mi_m == 0
scalar t9_diag_n_0397 = r(N)
scalar t9_diag_mean_0397 = r(mean)
scalar t9_diag_sd_0397 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0397) " mean=" %12.4f scalar(t9_diag_mean_0397) " sd=" %12.4f scalar(t9_diag_sd_0397)

display as text "  Diagnostic block 0398: t9_satisfaction m=1"
quietly summarize t9_satisfaction if _mi_m == 1
scalar t9_diag_n_0398 = r(N)
scalar t9_diag_mean_0398 = r(mean)
scalar t9_diag_sd_0398 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0398) " mean=" %12.4f scalar(t9_diag_mean_0398) " sd=" %12.4f scalar(t9_diag_sd_0398)

display as text "  Diagnostic block 0399: t9_sleep m=2"
quietly summarize t9_sleep if _mi_m == 2
scalar t9_diag_n_0399 = r(N)
scalar t9_diag_mean_0399 = r(mean)
scalar t9_diag_sd_0399 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0399) " mean=" %12.4f scalar(t9_diag_mean_0399) " sd=" %12.4f scalar(t9_diag_sd_0399)

display as text "  Diagnostic block 0400: t9_exercise m=3"
quietly summarize t9_exercise if _mi_m == 3
scalar t9_diag_n_0400 = r(N)
scalar t9_diag_mean_0400 = r(mean)
scalar t9_diag_sd_0400 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0400) " mean=" %12.4f scalar(t9_diag_mean_0400) " sd=" %12.4f scalar(t9_diag_sd_0400)

display as text "  Diagnostic block 0401: t9_employed m=4"
quietly summarize t9_employed if _mi_m == 4
scalar t9_diag_n_0401 = r(N)
scalar t9_diag_mean_0401 = r(mean)
scalar t9_diag_sd_0401 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0401) " mean=" %12.4f scalar(t9_diag_mean_0401) " sd=" %12.4f scalar(t9_diag_sd_0401)

display as text "  Diagnostic block 0402: t9_married m=5"
quietly summarize t9_married if _mi_m == 5
scalar t9_diag_n_0402 = r(N)
scalar t9_diag_mean_0402 = r(mean)
scalar t9_diag_sd_0402 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0402) " mean=" %12.4f scalar(t9_diag_mean_0402) " sd=" %12.4f scalar(t9_diag_sd_0402)

display as text "  Diagnostic block 0403: t9_urban m=0"
quietly summarize t9_urban if _mi_m == 0
scalar t9_diag_n_0403 = r(N)
scalar t9_diag_mean_0403 = r(mean)
scalar t9_diag_sd_0403 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0403) " mean=" %12.4f scalar(t9_diag_mean_0403) " sd=" %12.4f scalar(t9_diag_sd_0403)

display as text "  Diagnostic block 0404: t9_homeowner m=1"
quietly summarize t9_homeowner if _mi_m == 1
scalar t9_diag_n_0404 = r(N)
scalar t9_diag_mean_0404 = r(mean)
scalar t9_diag_sd_0404 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0404) " mean=" %12.4f scalar(t9_diag_mean_0404) " sd=" %12.4f scalar(t9_diag_sd_0404)

display as text "  Diagnostic block 0405: t9_insured m=2"
quietly summarize t9_insured if _mi_m == 2
scalar t9_diag_n_0405 = r(N)
scalar t9_diag_mean_0405 = r(mean)
scalar t9_diag_sd_0405 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0405) " mean=" %12.4f scalar(t9_diag_mean_0405) " sd=" %12.4f scalar(t9_diag_sd_0405)

display as text "  Diagnostic block 0406: t9_smoker m=3"
quietly summarize t9_smoker if _mi_m == 3
scalar t9_diag_n_0406 = r(N)
scalar t9_diag_mean_0406 = r(mean)
scalar t9_diag_sd_0406 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0406) " mean=" %12.4f scalar(t9_diag_mean_0406) " sd=" %12.4f scalar(t9_diag_sd_0406)

display as text "  Diagnostic block 0407: t9_high_income m=4"
quietly summarize t9_high_income if _mi_m == 4
scalar t9_diag_n_0407 = r(N)
scalar t9_diag_mean_0407 = r(mean)
scalar t9_diag_sd_0407 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0407) " mean=" %12.4f scalar(t9_diag_mean_0407) " sd=" %12.4f scalar(t9_diag_sd_0407)

display as text "  Diagnostic block 0408: t9_high_stress m=5"
quietly summarize t9_high_stress if _mi_m == 5
scalar t9_diag_n_0408 = r(N)
scalar t9_diag_mean_0408 = r(mean)
scalar t9_diag_sd_0408 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0408) " mean=" %12.4f scalar(t9_diag_mean_0408) " sd=" %12.4f scalar(t9_diag_sd_0408)

display as text "  Diagnostic block 0409: t9_unhealthy m=0"
quietly summarize t9_unhealthy if _mi_m == 0
scalar t9_diag_n_0409 = r(N)
scalar t9_diag_mean_0409 = r(mean)
scalar t9_diag_sd_0409 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0409) " mean=" %12.4f scalar(t9_diag_mean_0409) " sd=" %12.4f scalar(t9_diag_sd_0409)

display as text "  Diagnostic block 0410: t9_educ_level m=1"
quietly summarize t9_educ_level if _mi_m == 1
scalar t9_diag_n_0410 = r(N)
scalar t9_diag_mean_0410 = r(mean)
scalar t9_diag_sd_0410 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0410) " mean=" %12.4f scalar(t9_diag_mean_0410) " sd=" %12.4f scalar(t9_diag_sd_0410)

display as text "  Diagnostic block 0411: t9_health_level m=2"
quietly summarize t9_health_level if _mi_m == 2
scalar t9_diag_n_0411 = r(N)
scalar t9_diag_mean_0411 = r(mean)
scalar t9_diag_sd_0411 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0411) " mean=" %12.4f scalar(t9_diag_mean_0411) " sd=" %12.4f scalar(t9_diag_sd_0411)

display as text "  Diagnostic block 0412: t9_job_sat m=3"
quietly summarize t9_job_sat if _mi_m == 3
scalar t9_diag_n_0412 = r(N)
scalar t9_diag_mean_0412 = r(mean)
scalar t9_diag_sd_0412 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0412) " mean=" %12.4f scalar(t9_diag_mean_0412) " sd=" %12.4f scalar(t9_diag_sd_0412)

display as text "  Diagnostic block 0413: t9_children m=4"
quietly summarize t9_children if _mi_m == 4
scalar t9_diag_n_0413 = r(N)
scalar t9_diag_mean_0413 = r(mean)
scalar t9_diag_sd_0413 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0413) " mean=" %12.4f scalar(t9_diag_mean_0413) " sd=" %12.4f scalar(t9_diag_sd_0413)

display as text "  Diagnostic block 0414: t9_doctor_visits m=5"
quietly summarize t9_doctor_visits if _mi_m == 5
scalar t9_diag_n_0414 = r(N)
scalar t9_diag_mean_0414 = r(mean)
scalar t9_diag_sd_0414 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0414) " mean=" %12.4f scalar(t9_diag_mean_0414) " sd=" %12.4f scalar(t9_diag_sd_0414)

display as text "  Diagnostic block 0415: t9_hosp_days m=0"
quietly summarize t9_hosp_days if _mi_m == 0
scalar t9_diag_n_0415 = r(N)
scalar t9_diag_mean_0415 = r(mean)
scalar t9_diag_sd_0415 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0415) " mean=" %12.4f scalar(t9_diag_mean_0415) " sd=" %12.4f scalar(t9_diag_sd_0415)

display as text "  Diagnostic block 0416: t9_log_income m=1"
quietly summarize t9_log_income if _mi_m == 1
scalar t9_diag_n_0416 = r(N)
scalar t9_diag_mean_0416 = r(mean)
scalar t9_diag_sd_0416 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0416) " mean=" %12.4f scalar(t9_diag_mean_0416) " sd=" %12.4f scalar(t9_diag_sd_0416)

display as text "  Diagnostic block 0417: t9_log_wage m=2"
quietly summarize t9_log_wage if _mi_m == 2
scalar t9_diag_n_0417 = r(N)
scalar t9_diag_mean_0417 = r(mean)
scalar t9_diag_sd_0417 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0417) " mean=" %12.4f scalar(t9_diag_mean_0417) " sd=" %12.4f scalar(t9_diag_sd_0417)

display as text "  Diagnostic block 0418: t9_income_per_hour m=3"
quietly summarize t9_income_per_hour if _mi_m == 3
scalar t9_diag_n_0418 = r(N)
scalar t9_diag_mean_0418 = r(mean)
scalar t9_diag_sd_0418 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0418) " mean=" %12.4f scalar(t9_diag_mean_0418) " sd=" %12.4f scalar(t9_diag_sd_0418)

display as text "  Diagnostic block 0419: t9_health_index m=4"
quietly summarize t9_health_index if _mi_m == 4
scalar t9_diag_n_0419 = r(N)
scalar t9_diag_mean_0419 = r(mean)
scalar t9_diag_sd_0419 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0419) " mean=" %12.4f scalar(t9_diag_mean_0419) " sd=" %12.4f scalar(t9_diag_sd_0419)

display as text "  Diagnostic block 0420: t9_dep_stress m=5"
quietly summarize t9_dep_stress if _mi_m == 5
scalar t9_diag_n_0420 = r(N)
scalar t9_diag_mean_0420 = r(mean)
scalar t9_diag_sd_0420 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0420) " mean=" %12.4f scalar(t9_diag_mean_0420) " sd=" %12.4f scalar(t9_diag_sd_0420)

display as text "  Diagnostic block 0421: t9_income m=0"
quietly summarize t9_income if _mi_m == 0
scalar t9_diag_n_0421 = r(N)
scalar t9_diag_mean_0421 = r(mean)
scalar t9_diag_sd_0421 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0421) " mean=" %12.4f scalar(t9_diag_mean_0421) " sd=" %12.4f scalar(t9_diag_sd_0421)

display as text "  Diagnostic block 0422: t9_wage m=1"
quietly summarize t9_wage if _mi_m == 1
scalar t9_diag_n_0422 = r(N)
scalar t9_diag_mean_0422 = r(mean)
scalar t9_diag_sd_0422 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0422) " mean=" %12.4f scalar(t9_diag_mean_0422) " sd=" %12.4f scalar(t9_diag_sd_0422)

display as text "  Diagnostic block 0423: t9_hours m=2"
quietly summarize t9_hours if _mi_m == 2
scalar t9_diag_n_0423 = r(N)
scalar t9_diag_mean_0423 = r(mean)
scalar t9_diag_sd_0423 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0423) " mean=" %12.4f scalar(t9_diag_mean_0423) " sd=" %12.4f scalar(t9_diag_sd_0423)

display as text "  Diagnostic block 0424: t9_wealth m=3"
quietly summarize t9_wealth if _mi_m == 3
scalar t9_diag_n_0424 = r(N)
scalar t9_diag_mean_0424 = r(mean)
scalar t9_diag_sd_0424 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0424) " mean=" %12.4f scalar(t9_diag_mean_0424) " sd=" %12.4f scalar(t9_diag_sd_0424)

display as text "  Diagnostic block 0425: t9_savings m=4"
quietly summarize t9_savings if _mi_m == 4
scalar t9_diag_n_0425 = r(N)
scalar t9_diag_mean_0425 = r(mean)
scalar t9_diag_sd_0425 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0425) " mean=" %12.4f scalar(t9_diag_mean_0425) " sd=" %12.4f scalar(t9_diag_sd_0425)

display as text "  Diagnostic block 0426: t9_expenditure m=5"
quietly summarize t9_expenditure if _mi_m == 5
scalar t9_diag_n_0426 = r(N)
scalar t9_diag_mean_0426 = r(mean)
scalar t9_diag_sd_0426 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0426) " mean=" %12.4f scalar(t9_diag_mean_0426) " sd=" %12.4f scalar(t9_diag_sd_0426)

display as text "  Diagnostic block 0427: t9_health_score m=0"
quietly summarize t9_health_score if _mi_m == 0
scalar t9_diag_n_0427 = r(N)
scalar t9_diag_mean_0427 = r(mean)
scalar t9_diag_sd_0427 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0427) " mean=" %12.4f scalar(t9_diag_mean_0427) " sd=" %12.4f scalar(t9_diag_sd_0427)

display as text "  Diagnostic block 0428: t9_bmi m=1"
quietly summarize t9_bmi if _mi_m == 1
scalar t9_diag_n_0428 = r(N)
scalar t9_diag_mean_0428 = r(mean)
scalar t9_diag_sd_0428 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0428) " mean=" %12.4f scalar(t9_diag_mean_0428) " sd=" %12.4f scalar(t9_diag_sd_0428)

display as text "  Diagnostic block 0429: t9_bp_sys m=2"
quietly summarize t9_bp_sys if _mi_m == 2
scalar t9_diag_n_0429 = r(N)
scalar t9_diag_mean_0429 = r(mean)
scalar t9_diag_sd_0429 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0429) " mean=" %12.4f scalar(t9_diag_mean_0429) " sd=" %12.4f scalar(t9_diag_sd_0429)

display as text "  Diagnostic block 0430: t9_bp_dia m=3"
quietly summarize t9_bp_dia if _mi_m == 3
scalar t9_diag_n_0430 = r(N)
scalar t9_diag_mean_0430 = r(mean)
scalar t9_diag_sd_0430 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0430) " mean=" %12.4f scalar(t9_diag_mean_0430) " sd=" %12.4f scalar(t9_diag_sd_0430)

display as text "  Diagnostic block 0431: t9_depression m=4"
quietly summarize t9_depression if _mi_m == 4
scalar t9_diag_n_0431 = r(N)
scalar t9_diag_mean_0431 = r(mean)
scalar t9_diag_sd_0431 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0431) " mean=" %12.4f scalar(t9_diag_mean_0431) " sd=" %12.4f scalar(t9_diag_sd_0431)

display as text "  Diagnostic block 0432: t9_stress m=5"
quietly summarize t9_stress if _mi_m == 5
scalar t9_diag_n_0432 = r(N)
scalar t9_diag_mean_0432 = r(mean)
scalar t9_diag_sd_0432 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0432) " mean=" %12.4f scalar(t9_diag_mean_0432) " sd=" %12.4f scalar(t9_diag_sd_0432)

display as text "  Diagnostic block 0433: t9_satisfaction m=0"
quietly summarize t9_satisfaction if _mi_m == 0
scalar t9_diag_n_0433 = r(N)
scalar t9_diag_mean_0433 = r(mean)
scalar t9_diag_sd_0433 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0433) " mean=" %12.4f scalar(t9_diag_mean_0433) " sd=" %12.4f scalar(t9_diag_sd_0433)

display as text "  Diagnostic block 0434: t9_sleep m=1"
quietly summarize t9_sleep if _mi_m == 1
scalar t9_diag_n_0434 = r(N)
scalar t9_diag_mean_0434 = r(mean)
scalar t9_diag_sd_0434 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0434) " mean=" %12.4f scalar(t9_diag_mean_0434) " sd=" %12.4f scalar(t9_diag_sd_0434)

display as text "  Diagnostic block 0435: t9_exercise m=2"
quietly summarize t9_exercise if _mi_m == 2
scalar t9_diag_n_0435 = r(N)
scalar t9_diag_mean_0435 = r(mean)
scalar t9_diag_sd_0435 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0435) " mean=" %12.4f scalar(t9_diag_mean_0435) " sd=" %12.4f scalar(t9_diag_sd_0435)

display as text "  Diagnostic block 0436: t9_employed m=3"
quietly summarize t9_employed if _mi_m == 3
scalar t9_diag_n_0436 = r(N)
scalar t9_diag_mean_0436 = r(mean)
scalar t9_diag_sd_0436 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0436) " mean=" %12.4f scalar(t9_diag_mean_0436) " sd=" %12.4f scalar(t9_diag_sd_0436)

display as text "  Diagnostic block 0437: t9_married m=4"
quietly summarize t9_married if _mi_m == 4
scalar t9_diag_n_0437 = r(N)
scalar t9_diag_mean_0437 = r(mean)
scalar t9_diag_sd_0437 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0437) " mean=" %12.4f scalar(t9_diag_mean_0437) " sd=" %12.4f scalar(t9_diag_sd_0437)

display as text "  Diagnostic block 0438: t9_urban m=5"
quietly summarize t9_urban if _mi_m == 5
scalar t9_diag_n_0438 = r(N)
scalar t9_diag_mean_0438 = r(mean)
scalar t9_diag_sd_0438 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0438) " mean=" %12.4f scalar(t9_diag_mean_0438) " sd=" %12.4f scalar(t9_diag_sd_0438)

display as text "  Diagnostic block 0439: t9_homeowner m=0"
quietly summarize t9_homeowner if _mi_m == 0
scalar t9_diag_n_0439 = r(N)
scalar t9_diag_mean_0439 = r(mean)
scalar t9_diag_sd_0439 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0439) " mean=" %12.4f scalar(t9_diag_mean_0439) " sd=" %12.4f scalar(t9_diag_sd_0439)

display as text "  Diagnostic block 0440: t9_insured m=1"
quietly summarize t9_insured if _mi_m == 1
scalar t9_diag_n_0440 = r(N)
scalar t9_diag_mean_0440 = r(mean)
scalar t9_diag_sd_0440 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0440) " mean=" %12.4f scalar(t9_diag_mean_0440) " sd=" %12.4f scalar(t9_diag_sd_0440)

display as text "  Diagnostic block 0441: t9_smoker m=2"
quietly summarize t9_smoker if _mi_m == 2
scalar t9_diag_n_0441 = r(N)
scalar t9_diag_mean_0441 = r(mean)
scalar t9_diag_sd_0441 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0441) " mean=" %12.4f scalar(t9_diag_mean_0441) " sd=" %12.4f scalar(t9_diag_sd_0441)

display as text "  Diagnostic block 0442: t9_high_income m=3"
quietly summarize t9_high_income if _mi_m == 3
scalar t9_diag_n_0442 = r(N)
scalar t9_diag_mean_0442 = r(mean)
scalar t9_diag_sd_0442 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0442) " mean=" %12.4f scalar(t9_diag_mean_0442) " sd=" %12.4f scalar(t9_diag_sd_0442)

display as text "  Diagnostic block 0443: t9_high_stress m=4"
quietly summarize t9_high_stress if _mi_m == 4
scalar t9_diag_n_0443 = r(N)
scalar t9_diag_mean_0443 = r(mean)
scalar t9_diag_sd_0443 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0443) " mean=" %12.4f scalar(t9_diag_mean_0443) " sd=" %12.4f scalar(t9_diag_sd_0443)

display as text "  Diagnostic block 0444: t9_unhealthy m=5"
quietly summarize t9_unhealthy if _mi_m == 5
scalar t9_diag_n_0444 = r(N)
scalar t9_diag_mean_0444 = r(mean)
scalar t9_diag_sd_0444 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0444) " mean=" %12.4f scalar(t9_diag_mean_0444) " sd=" %12.4f scalar(t9_diag_sd_0444)

display as text "  Diagnostic block 0445: t9_educ_level m=0"
quietly summarize t9_educ_level if _mi_m == 0
scalar t9_diag_n_0445 = r(N)
scalar t9_diag_mean_0445 = r(mean)
scalar t9_diag_sd_0445 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0445) " mean=" %12.4f scalar(t9_diag_mean_0445) " sd=" %12.4f scalar(t9_diag_sd_0445)

display as text "  Diagnostic block 0446: t9_health_level m=1"
quietly summarize t9_health_level if _mi_m == 1
scalar t9_diag_n_0446 = r(N)
scalar t9_diag_mean_0446 = r(mean)
scalar t9_diag_sd_0446 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0446) " mean=" %12.4f scalar(t9_diag_mean_0446) " sd=" %12.4f scalar(t9_diag_sd_0446)

display as text "  Diagnostic block 0447: t9_job_sat m=2"
quietly summarize t9_job_sat if _mi_m == 2
scalar t9_diag_n_0447 = r(N)
scalar t9_diag_mean_0447 = r(mean)
scalar t9_diag_sd_0447 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0447) " mean=" %12.4f scalar(t9_diag_mean_0447) " sd=" %12.4f scalar(t9_diag_sd_0447)

display as text "  Diagnostic block 0448: t9_children m=3"
quietly summarize t9_children if _mi_m == 3
scalar t9_diag_n_0448 = r(N)
scalar t9_diag_mean_0448 = r(mean)
scalar t9_diag_sd_0448 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0448) " mean=" %12.4f scalar(t9_diag_mean_0448) " sd=" %12.4f scalar(t9_diag_sd_0448)

display as text "  Diagnostic block 0449: t9_doctor_visits m=4"
quietly summarize t9_doctor_visits if _mi_m == 4
scalar t9_diag_n_0449 = r(N)
scalar t9_diag_mean_0449 = r(mean)
scalar t9_diag_sd_0449 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0449) " mean=" %12.4f scalar(t9_diag_mean_0449) " sd=" %12.4f scalar(t9_diag_sd_0449)

display as text "  Diagnostic block 0450: t9_hosp_days m=5"
quietly summarize t9_hosp_days if _mi_m == 5
scalar t9_diag_n_0450 = r(N)
scalar t9_diag_mean_0450 = r(mean)
scalar t9_diag_sd_0450 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0450) " mean=" %12.4f scalar(t9_diag_mean_0450) " sd=" %12.4f scalar(t9_diag_sd_0450)

display as text "  Diagnostic block 0451: t9_log_income m=0"
quietly summarize t9_log_income if _mi_m == 0
scalar t9_diag_n_0451 = r(N)
scalar t9_diag_mean_0451 = r(mean)
scalar t9_diag_sd_0451 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0451) " mean=" %12.4f scalar(t9_diag_mean_0451) " sd=" %12.4f scalar(t9_diag_sd_0451)

display as text "  Diagnostic block 0452: t9_log_wage m=1"
quietly summarize t9_log_wage if _mi_m == 1
scalar t9_diag_n_0452 = r(N)
scalar t9_diag_mean_0452 = r(mean)
scalar t9_diag_sd_0452 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0452) " mean=" %12.4f scalar(t9_diag_mean_0452) " sd=" %12.4f scalar(t9_diag_sd_0452)

display as text "  Diagnostic block 0453: t9_income_per_hour m=2"
quietly summarize t9_income_per_hour if _mi_m == 2
scalar t9_diag_n_0453 = r(N)
scalar t9_diag_mean_0453 = r(mean)
scalar t9_diag_sd_0453 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0453) " mean=" %12.4f scalar(t9_diag_mean_0453) " sd=" %12.4f scalar(t9_diag_sd_0453)

display as text "  Diagnostic block 0454: t9_health_index m=3"
quietly summarize t9_health_index if _mi_m == 3
scalar t9_diag_n_0454 = r(N)
scalar t9_diag_mean_0454 = r(mean)
scalar t9_diag_sd_0454 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0454) " mean=" %12.4f scalar(t9_diag_mean_0454) " sd=" %12.4f scalar(t9_diag_sd_0454)

display as text "  Diagnostic block 0455: t9_dep_stress m=4"
quietly summarize t9_dep_stress if _mi_m == 4
scalar t9_diag_n_0455 = r(N)
scalar t9_diag_mean_0455 = r(mean)
scalar t9_diag_sd_0455 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0455) " mean=" %12.4f scalar(t9_diag_mean_0455) " sd=" %12.4f scalar(t9_diag_sd_0455)

display as text "  Diagnostic block 0456: t9_income m=5"
quietly summarize t9_income if _mi_m == 5
scalar t9_diag_n_0456 = r(N)
scalar t9_diag_mean_0456 = r(mean)
scalar t9_diag_sd_0456 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0456) " mean=" %12.4f scalar(t9_diag_mean_0456) " sd=" %12.4f scalar(t9_diag_sd_0456)

display as text "  Diagnostic block 0457: t9_wage m=0"
quietly summarize t9_wage if _mi_m == 0
scalar t9_diag_n_0457 = r(N)
scalar t9_diag_mean_0457 = r(mean)
scalar t9_diag_sd_0457 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0457) " mean=" %12.4f scalar(t9_diag_mean_0457) " sd=" %12.4f scalar(t9_diag_sd_0457)

display as text "  Diagnostic block 0458: t9_hours m=1"
quietly summarize t9_hours if _mi_m == 1
scalar t9_diag_n_0458 = r(N)
scalar t9_diag_mean_0458 = r(mean)
scalar t9_diag_sd_0458 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0458) " mean=" %12.4f scalar(t9_diag_mean_0458) " sd=" %12.4f scalar(t9_diag_sd_0458)

display as text "  Diagnostic block 0459: t9_wealth m=2"
quietly summarize t9_wealth if _mi_m == 2
scalar t9_diag_n_0459 = r(N)
scalar t9_diag_mean_0459 = r(mean)
scalar t9_diag_sd_0459 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0459) " mean=" %12.4f scalar(t9_diag_mean_0459) " sd=" %12.4f scalar(t9_diag_sd_0459)

display as text "  Diagnostic block 0460: t9_savings m=3"
quietly summarize t9_savings if _mi_m == 3
scalar t9_diag_n_0460 = r(N)
scalar t9_diag_mean_0460 = r(mean)
scalar t9_diag_sd_0460 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0460) " mean=" %12.4f scalar(t9_diag_mean_0460) " sd=" %12.4f scalar(t9_diag_sd_0460)

display as text "  Diagnostic block 0461: t9_expenditure m=4"
quietly summarize t9_expenditure if _mi_m == 4
scalar t9_diag_n_0461 = r(N)
scalar t9_diag_mean_0461 = r(mean)
scalar t9_diag_sd_0461 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0461) " mean=" %12.4f scalar(t9_diag_mean_0461) " sd=" %12.4f scalar(t9_diag_sd_0461)

display as text "  Diagnostic block 0462: t9_health_score m=5"
quietly summarize t9_health_score if _mi_m == 5
scalar t9_diag_n_0462 = r(N)
scalar t9_diag_mean_0462 = r(mean)
scalar t9_diag_sd_0462 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0462) " mean=" %12.4f scalar(t9_diag_mean_0462) " sd=" %12.4f scalar(t9_diag_sd_0462)

display as text "  Diagnostic block 0463: t9_bmi m=0"
quietly summarize t9_bmi if _mi_m == 0
scalar t9_diag_n_0463 = r(N)
scalar t9_diag_mean_0463 = r(mean)
scalar t9_diag_sd_0463 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0463) " mean=" %12.4f scalar(t9_diag_mean_0463) " sd=" %12.4f scalar(t9_diag_sd_0463)

display as text "  Diagnostic block 0464: t9_bp_sys m=1"
quietly summarize t9_bp_sys if _mi_m == 1
scalar t9_diag_n_0464 = r(N)
scalar t9_diag_mean_0464 = r(mean)
scalar t9_diag_sd_0464 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0464) " mean=" %12.4f scalar(t9_diag_mean_0464) " sd=" %12.4f scalar(t9_diag_sd_0464)

display as text "  Diagnostic block 0465: t9_bp_dia m=2"
quietly summarize t9_bp_dia if _mi_m == 2
scalar t9_diag_n_0465 = r(N)
scalar t9_diag_mean_0465 = r(mean)
scalar t9_diag_sd_0465 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0465) " mean=" %12.4f scalar(t9_diag_mean_0465) " sd=" %12.4f scalar(t9_diag_sd_0465)

display as text "  Diagnostic block 0466: t9_depression m=3"
quietly summarize t9_depression if _mi_m == 3
scalar t9_diag_n_0466 = r(N)
scalar t9_diag_mean_0466 = r(mean)
scalar t9_diag_sd_0466 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0466) " mean=" %12.4f scalar(t9_diag_mean_0466) " sd=" %12.4f scalar(t9_diag_sd_0466)

display as text "  Diagnostic block 0467: t9_stress m=4"
quietly summarize t9_stress if _mi_m == 4
scalar t9_diag_n_0467 = r(N)
scalar t9_diag_mean_0467 = r(mean)
scalar t9_diag_sd_0467 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0467) " mean=" %12.4f scalar(t9_diag_mean_0467) " sd=" %12.4f scalar(t9_diag_sd_0467)

display as text "  Diagnostic block 0468: t9_satisfaction m=5"
quietly summarize t9_satisfaction if _mi_m == 5
scalar t9_diag_n_0468 = r(N)
scalar t9_diag_mean_0468 = r(mean)
scalar t9_diag_sd_0468 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0468) " mean=" %12.4f scalar(t9_diag_mean_0468) " sd=" %12.4f scalar(t9_diag_sd_0468)

display as text "  Diagnostic block 0469: t9_sleep m=0"
quietly summarize t9_sleep if _mi_m == 0
scalar t9_diag_n_0469 = r(N)
scalar t9_diag_mean_0469 = r(mean)
scalar t9_diag_sd_0469 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0469) " mean=" %12.4f scalar(t9_diag_mean_0469) " sd=" %12.4f scalar(t9_diag_sd_0469)

display as text "  Diagnostic block 0470: t9_exercise m=1"
quietly summarize t9_exercise if _mi_m == 1
scalar t9_diag_n_0470 = r(N)
scalar t9_diag_mean_0470 = r(mean)
scalar t9_diag_sd_0470 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0470) " mean=" %12.4f scalar(t9_diag_mean_0470) " sd=" %12.4f scalar(t9_diag_sd_0470)

display as text "  Diagnostic block 0471: t9_employed m=2"
quietly summarize t9_employed if _mi_m == 2
scalar t9_diag_n_0471 = r(N)
scalar t9_diag_mean_0471 = r(mean)
scalar t9_diag_sd_0471 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0471) " mean=" %12.4f scalar(t9_diag_mean_0471) " sd=" %12.4f scalar(t9_diag_sd_0471)

display as text "  Diagnostic block 0472: t9_married m=3"
quietly summarize t9_married if _mi_m == 3
scalar t9_diag_n_0472 = r(N)
scalar t9_diag_mean_0472 = r(mean)
scalar t9_diag_sd_0472 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0472) " mean=" %12.4f scalar(t9_diag_mean_0472) " sd=" %12.4f scalar(t9_diag_sd_0472)

display as text "  Diagnostic block 0473: t9_urban m=4"
quietly summarize t9_urban if _mi_m == 4
scalar t9_diag_n_0473 = r(N)
scalar t9_diag_mean_0473 = r(mean)
scalar t9_diag_sd_0473 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0473) " mean=" %12.4f scalar(t9_diag_mean_0473) " sd=" %12.4f scalar(t9_diag_sd_0473)

display as text "  Diagnostic block 0474: t9_homeowner m=5"
quietly summarize t9_homeowner if _mi_m == 5
scalar t9_diag_n_0474 = r(N)
scalar t9_diag_mean_0474 = r(mean)
scalar t9_diag_sd_0474 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0474) " mean=" %12.4f scalar(t9_diag_mean_0474) " sd=" %12.4f scalar(t9_diag_sd_0474)

display as text "  Diagnostic block 0475: t9_insured m=0"
quietly summarize t9_insured if _mi_m == 0
scalar t9_diag_n_0475 = r(N)
scalar t9_diag_mean_0475 = r(mean)
scalar t9_diag_sd_0475 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0475) " mean=" %12.4f scalar(t9_diag_mean_0475) " sd=" %12.4f scalar(t9_diag_sd_0475)

display as text "  Diagnostic block 0476: t9_smoker m=1"
quietly summarize t9_smoker if _mi_m == 1
scalar t9_diag_n_0476 = r(N)
scalar t9_diag_mean_0476 = r(mean)
scalar t9_diag_sd_0476 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0476) " mean=" %12.4f scalar(t9_diag_mean_0476) " sd=" %12.4f scalar(t9_diag_sd_0476)

display as text "  Diagnostic block 0477: t9_high_income m=2"
quietly summarize t9_high_income if _mi_m == 2
scalar t9_diag_n_0477 = r(N)
scalar t9_diag_mean_0477 = r(mean)
scalar t9_diag_sd_0477 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0477) " mean=" %12.4f scalar(t9_diag_mean_0477) " sd=" %12.4f scalar(t9_diag_sd_0477)

display as text "  Diagnostic block 0478: t9_high_stress m=3"
quietly summarize t9_high_stress if _mi_m == 3
scalar t9_diag_n_0478 = r(N)
scalar t9_diag_mean_0478 = r(mean)
scalar t9_diag_sd_0478 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0478) " mean=" %12.4f scalar(t9_diag_mean_0478) " sd=" %12.4f scalar(t9_diag_sd_0478)

display as text "  Diagnostic block 0479: t9_unhealthy m=4"
quietly summarize t9_unhealthy if _mi_m == 4
scalar t9_diag_n_0479 = r(N)
scalar t9_diag_mean_0479 = r(mean)
scalar t9_diag_sd_0479 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0479) " mean=" %12.4f scalar(t9_diag_mean_0479) " sd=" %12.4f scalar(t9_diag_sd_0479)

display as text "  Diagnostic block 0480: t9_educ_level m=5"
quietly summarize t9_educ_level if _mi_m == 5
scalar t9_diag_n_0480 = r(N)
scalar t9_diag_mean_0480 = r(mean)
scalar t9_diag_sd_0480 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0480) " mean=" %12.4f scalar(t9_diag_mean_0480) " sd=" %12.4f scalar(t9_diag_sd_0480)

display as text "  Diagnostic block 0481: t9_health_level m=0"
quietly summarize t9_health_level if _mi_m == 0
scalar t9_diag_n_0481 = r(N)
scalar t9_diag_mean_0481 = r(mean)
scalar t9_diag_sd_0481 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0481) " mean=" %12.4f scalar(t9_diag_mean_0481) " sd=" %12.4f scalar(t9_diag_sd_0481)

display as text "  Diagnostic block 0482: t9_job_sat m=1"
quietly summarize t9_job_sat if _mi_m == 1
scalar t9_diag_n_0482 = r(N)
scalar t9_diag_mean_0482 = r(mean)
scalar t9_diag_sd_0482 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0482) " mean=" %12.4f scalar(t9_diag_mean_0482) " sd=" %12.4f scalar(t9_diag_sd_0482)

display as text "  Diagnostic block 0483: t9_children m=2"
quietly summarize t9_children if _mi_m == 2
scalar t9_diag_n_0483 = r(N)
scalar t9_diag_mean_0483 = r(mean)
scalar t9_diag_sd_0483 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0483) " mean=" %12.4f scalar(t9_diag_mean_0483) " sd=" %12.4f scalar(t9_diag_sd_0483)

display as text "  Diagnostic block 0484: t9_doctor_visits m=3"
quietly summarize t9_doctor_visits if _mi_m == 3
scalar t9_diag_n_0484 = r(N)
scalar t9_diag_mean_0484 = r(mean)
scalar t9_diag_sd_0484 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0484) " mean=" %12.4f scalar(t9_diag_mean_0484) " sd=" %12.4f scalar(t9_diag_sd_0484)

display as text "  Diagnostic block 0485: t9_hosp_days m=4"
quietly summarize t9_hosp_days if _mi_m == 4
scalar t9_diag_n_0485 = r(N)
scalar t9_diag_mean_0485 = r(mean)
scalar t9_diag_sd_0485 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0485) " mean=" %12.4f scalar(t9_diag_mean_0485) " sd=" %12.4f scalar(t9_diag_sd_0485)

display as text "  Diagnostic block 0486: t9_log_income m=5"
quietly summarize t9_log_income if _mi_m == 5
scalar t9_diag_n_0486 = r(N)
scalar t9_diag_mean_0486 = r(mean)
scalar t9_diag_sd_0486 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0486) " mean=" %12.4f scalar(t9_diag_mean_0486) " sd=" %12.4f scalar(t9_diag_sd_0486)

display as text "  Diagnostic block 0487: t9_log_wage m=0"
quietly summarize t9_log_wage if _mi_m == 0
scalar t9_diag_n_0487 = r(N)
scalar t9_diag_mean_0487 = r(mean)
scalar t9_diag_sd_0487 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0487) " mean=" %12.4f scalar(t9_diag_mean_0487) " sd=" %12.4f scalar(t9_diag_sd_0487)

display as text "  Diagnostic block 0488: t9_income_per_hour m=1"
quietly summarize t9_income_per_hour if _mi_m == 1
scalar t9_diag_n_0488 = r(N)
scalar t9_diag_mean_0488 = r(mean)
scalar t9_diag_sd_0488 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0488) " mean=" %12.4f scalar(t9_diag_mean_0488) " sd=" %12.4f scalar(t9_diag_sd_0488)

display as text "  Diagnostic block 0489: t9_health_index m=2"
quietly summarize t9_health_index if _mi_m == 2
scalar t9_diag_n_0489 = r(N)
scalar t9_diag_mean_0489 = r(mean)
scalar t9_diag_sd_0489 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0489) " mean=" %12.4f scalar(t9_diag_mean_0489) " sd=" %12.4f scalar(t9_diag_sd_0489)

display as text "  Diagnostic block 0490: t9_dep_stress m=3"
quietly summarize t9_dep_stress if _mi_m == 3
scalar t9_diag_n_0490 = r(N)
scalar t9_diag_mean_0490 = r(mean)
scalar t9_diag_sd_0490 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0490) " mean=" %12.4f scalar(t9_diag_mean_0490) " sd=" %12.4f scalar(t9_diag_sd_0490)

display as text "  Diagnostic block 0491: t9_income m=4"
quietly summarize t9_income if _mi_m == 4
scalar t9_diag_n_0491 = r(N)
scalar t9_diag_mean_0491 = r(mean)
scalar t9_diag_sd_0491 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0491) " mean=" %12.4f scalar(t9_diag_mean_0491) " sd=" %12.4f scalar(t9_diag_sd_0491)

display as text "  Diagnostic block 0492: t9_wage m=5"
quietly summarize t9_wage if _mi_m == 5
scalar t9_diag_n_0492 = r(N)
scalar t9_diag_mean_0492 = r(mean)
scalar t9_diag_sd_0492 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0492) " mean=" %12.4f scalar(t9_diag_mean_0492) " sd=" %12.4f scalar(t9_diag_sd_0492)

display as text "  Diagnostic block 0493: t9_hours m=0"
quietly summarize t9_hours if _mi_m == 0
scalar t9_diag_n_0493 = r(N)
scalar t9_diag_mean_0493 = r(mean)
scalar t9_diag_sd_0493 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0493) " mean=" %12.4f scalar(t9_diag_mean_0493) " sd=" %12.4f scalar(t9_diag_sd_0493)

display as text "  Diagnostic block 0494: t9_wealth m=1"
quietly summarize t9_wealth if _mi_m == 1
scalar t9_diag_n_0494 = r(N)
scalar t9_diag_mean_0494 = r(mean)
scalar t9_diag_sd_0494 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0494) " mean=" %12.4f scalar(t9_diag_mean_0494) " sd=" %12.4f scalar(t9_diag_sd_0494)

display as text "  Diagnostic block 0495: t9_savings m=2"
quietly summarize t9_savings if _mi_m == 2
scalar t9_diag_n_0495 = r(N)
scalar t9_diag_mean_0495 = r(mean)
scalar t9_diag_sd_0495 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0495) " mean=" %12.4f scalar(t9_diag_mean_0495) " sd=" %12.4f scalar(t9_diag_sd_0495)

display as text "  Diagnostic block 0496: t9_expenditure m=3"
quietly summarize t9_expenditure if _mi_m == 3
scalar t9_diag_n_0496 = r(N)
scalar t9_diag_mean_0496 = r(mean)
scalar t9_diag_sd_0496 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0496) " mean=" %12.4f scalar(t9_diag_mean_0496) " sd=" %12.4f scalar(t9_diag_sd_0496)

display as text "  Diagnostic block 0497: t9_health_score m=4"
quietly summarize t9_health_score if _mi_m == 4
scalar t9_diag_n_0497 = r(N)
scalar t9_diag_mean_0497 = r(mean)
scalar t9_diag_sd_0497 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0497) " mean=" %12.4f scalar(t9_diag_mean_0497) " sd=" %12.4f scalar(t9_diag_sd_0497)

display as text "  Diagnostic block 0498: t9_bmi m=5"
quietly summarize t9_bmi if _mi_m == 5
scalar t9_diag_n_0498 = r(N)
scalar t9_diag_mean_0498 = r(mean)
scalar t9_diag_sd_0498 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0498) " mean=" %12.4f scalar(t9_diag_mean_0498) " sd=" %12.4f scalar(t9_diag_sd_0498)

display as text "  Diagnostic block 0499: t9_bp_sys m=0"
quietly summarize t9_bp_sys if _mi_m == 0
scalar t9_diag_n_0499 = r(N)
scalar t9_diag_mean_0499 = r(mean)
scalar t9_diag_sd_0499 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0499) " mean=" %12.4f scalar(t9_diag_mean_0499) " sd=" %12.4f scalar(t9_diag_sd_0499)

display as text "  Diagnostic block 0500: t9_bp_dia m=1"
quietly summarize t9_bp_dia if _mi_m == 1
scalar t9_diag_n_0500 = r(N)
scalar t9_diag_mean_0500 = r(mean)
scalar t9_diag_sd_0500 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0500) " mean=" %12.4f scalar(t9_diag_mean_0500) " sd=" %12.4f scalar(t9_diag_sd_0500)

display as text "  Diagnostic block 0501: t9_depression m=2"
quietly summarize t9_depression if _mi_m == 2
scalar t9_diag_n_0501 = r(N)
scalar t9_diag_mean_0501 = r(mean)
scalar t9_diag_sd_0501 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0501) " mean=" %12.4f scalar(t9_diag_mean_0501) " sd=" %12.4f scalar(t9_diag_sd_0501)

display as text "  Diagnostic block 0502: t9_stress m=3"
quietly summarize t9_stress if _mi_m == 3
scalar t9_diag_n_0502 = r(N)
scalar t9_diag_mean_0502 = r(mean)
scalar t9_diag_sd_0502 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0502) " mean=" %12.4f scalar(t9_diag_mean_0502) " sd=" %12.4f scalar(t9_diag_sd_0502)

display as text "  Diagnostic block 0503: t9_satisfaction m=4"
quietly summarize t9_satisfaction if _mi_m == 4
scalar t9_diag_n_0503 = r(N)
scalar t9_diag_mean_0503 = r(mean)
scalar t9_diag_sd_0503 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0503) " mean=" %12.4f scalar(t9_diag_mean_0503) " sd=" %12.4f scalar(t9_diag_sd_0503)

display as text "  Diagnostic block 0504: t9_sleep m=5"
quietly summarize t9_sleep if _mi_m == 5
scalar t9_diag_n_0504 = r(N)
scalar t9_diag_mean_0504 = r(mean)
scalar t9_diag_sd_0504 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0504) " mean=" %12.4f scalar(t9_diag_mean_0504) " sd=" %12.4f scalar(t9_diag_sd_0504)

display as text "  Diagnostic block 0505: t9_exercise m=0"
quietly summarize t9_exercise if _mi_m == 0
scalar t9_diag_n_0505 = r(N)
scalar t9_diag_mean_0505 = r(mean)
scalar t9_diag_sd_0505 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0505) " mean=" %12.4f scalar(t9_diag_mean_0505) " sd=" %12.4f scalar(t9_diag_sd_0505)

display as text "  Diagnostic block 0506: t9_employed m=1"
quietly summarize t9_employed if _mi_m == 1
scalar t9_diag_n_0506 = r(N)
scalar t9_diag_mean_0506 = r(mean)
scalar t9_diag_sd_0506 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0506) " mean=" %12.4f scalar(t9_diag_mean_0506) " sd=" %12.4f scalar(t9_diag_sd_0506)

display as text "  Diagnostic block 0507: t9_married m=2"
quietly summarize t9_married if _mi_m == 2
scalar t9_diag_n_0507 = r(N)
scalar t9_diag_mean_0507 = r(mean)
scalar t9_diag_sd_0507 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0507) " mean=" %12.4f scalar(t9_diag_mean_0507) " sd=" %12.4f scalar(t9_diag_sd_0507)

display as text "  Diagnostic block 0508: t9_urban m=3"
quietly summarize t9_urban if _mi_m == 3
scalar t9_diag_n_0508 = r(N)
scalar t9_diag_mean_0508 = r(mean)
scalar t9_diag_sd_0508 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0508) " mean=" %12.4f scalar(t9_diag_mean_0508) " sd=" %12.4f scalar(t9_diag_sd_0508)

display as text "  Diagnostic block 0509: t9_homeowner m=4"
quietly summarize t9_homeowner if _mi_m == 4
scalar t9_diag_n_0509 = r(N)
scalar t9_diag_mean_0509 = r(mean)
scalar t9_diag_sd_0509 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0509) " mean=" %12.4f scalar(t9_diag_mean_0509) " sd=" %12.4f scalar(t9_diag_sd_0509)

display as text "  Diagnostic block 0510: t9_insured m=5"
quietly summarize t9_insured if _mi_m == 5
scalar t9_diag_n_0510 = r(N)
scalar t9_diag_mean_0510 = r(mean)
scalar t9_diag_sd_0510 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0510) " mean=" %12.4f scalar(t9_diag_mean_0510) " sd=" %12.4f scalar(t9_diag_sd_0510)

display as text "  Diagnostic block 0511: t9_smoker m=0"
quietly summarize t9_smoker if _mi_m == 0
scalar t9_diag_n_0511 = r(N)
scalar t9_diag_mean_0511 = r(mean)
scalar t9_diag_sd_0511 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0511) " mean=" %12.4f scalar(t9_diag_mean_0511) " sd=" %12.4f scalar(t9_diag_sd_0511)

display as text "  Diagnostic block 0512: t9_high_income m=1"
quietly summarize t9_high_income if _mi_m == 1
scalar t9_diag_n_0512 = r(N)
scalar t9_diag_mean_0512 = r(mean)
scalar t9_diag_sd_0512 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0512) " mean=" %12.4f scalar(t9_diag_mean_0512) " sd=" %12.4f scalar(t9_diag_sd_0512)

display as text "  Diagnostic block 0513: t9_high_stress m=2"
quietly summarize t9_high_stress if _mi_m == 2
scalar t9_diag_n_0513 = r(N)
scalar t9_diag_mean_0513 = r(mean)
scalar t9_diag_sd_0513 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0513) " mean=" %12.4f scalar(t9_diag_mean_0513) " sd=" %12.4f scalar(t9_diag_sd_0513)

display as text "  Diagnostic block 0514: t9_unhealthy m=3"
quietly summarize t9_unhealthy if _mi_m == 3
scalar t9_diag_n_0514 = r(N)
scalar t9_diag_mean_0514 = r(mean)
scalar t9_diag_sd_0514 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0514) " mean=" %12.4f scalar(t9_diag_mean_0514) " sd=" %12.4f scalar(t9_diag_sd_0514)

display as text "  Diagnostic block 0515: t9_educ_level m=4"
quietly summarize t9_educ_level if _mi_m == 4
scalar t9_diag_n_0515 = r(N)
scalar t9_diag_mean_0515 = r(mean)
scalar t9_diag_sd_0515 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0515) " mean=" %12.4f scalar(t9_diag_mean_0515) " sd=" %12.4f scalar(t9_diag_sd_0515)

display as text "  Diagnostic block 0516: t9_health_level m=5"
quietly summarize t9_health_level if _mi_m == 5
scalar t9_diag_n_0516 = r(N)
scalar t9_diag_mean_0516 = r(mean)
scalar t9_diag_sd_0516 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0516) " mean=" %12.4f scalar(t9_diag_mean_0516) " sd=" %12.4f scalar(t9_diag_sd_0516)

display as text "  Diagnostic block 0517: t9_job_sat m=0"
quietly summarize t9_job_sat if _mi_m == 0
scalar t9_diag_n_0517 = r(N)
scalar t9_diag_mean_0517 = r(mean)
scalar t9_diag_sd_0517 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0517) " mean=" %12.4f scalar(t9_diag_mean_0517) " sd=" %12.4f scalar(t9_diag_sd_0517)

display as text "  Diagnostic block 0518: t9_children m=1"
quietly summarize t9_children if _mi_m == 1
scalar t9_diag_n_0518 = r(N)
scalar t9_diag_mean_0518 = r(mean)
scalar t9_diag_sd_0518 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0518) " mean=" %12.4f scalar(t9_diag_mean_0518) " sd=" %12.4f scalar(t9_diag_sd_0518)

display as text "  Diagnostic block 0519: t9_doctor_visits m=2"
quietly summarize t9_doctor_visits if _mi_m == 2
scalar t9_diag_n_0519 = r(N)
scalar t9_diag_mean_0519 = r(mean)
scalar t9_diag_sd_0519 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0519) " mean=" %12.4f scalar(t9_diag_mean_0519) " sd=" %12.4f scalar(t9_diag_sd_0519)

display as text "  Diagnostic block 0520: t9_hosp_days m=3"
quietly summarize t9_hosp_days if _mi_m == 3
scalar t9_diag_n_0520 = r(N)
scalar t9_diag_mean_0520 = r(mean)
scalar t9_diag_sd_0520 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0520) " mean=" %12.4f scalar(t9_diag_mean_0520) " sd=" %12.4f scalar(t9_diag_sd_0520)

display as text "  Diagnostic block 0521: t9_log_income m=4"
quietly summarize t9_log_income if _mi_m == 4
scalar t9_diag_n_0521 = r(N)
scalar t9_diag_mean_0521 = r(mean)
scalar t9_diag_sd_0521 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0521) " mean=" %12.4f scalar(t9_diag_mean_0521) " sd=" %12.4f scalar(t9_diag_sd_0521)

display as text "  Diagnostic block 0522: t9_log_wage m=5"
quietly summarize t9_log_wage if _mi_m == 5
scalar t9_diag_n_0522 = r(N)
scalar t9_diag_mean_0522 = r(mean)
scalar t9_diag_sd_0522 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0522) " mean=" %12.4f scalar(t9_diag_mean_0522) " sd=" %12.4f scalar(t9_diag_sd_0522)

display as text "  Diagnostic block 0523: t9_income_per_hour m=0"
quietly summarize t9_income_per_hour if _mi_m == 0
scalar t9_diag_n_0523 = r(N)
scalar t9_diag_mean_0523 = r(mean)
scalar t9_diag_sd_0523 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0523) " mean=" %12.4f scalar(t9_diag_mean_0523) " sd=" %12.4f scalar(t9_diag_sd_0523)

display as text "  Diagnostic block 0524: t9_health_index m=1"
quietly summarize t9_health_index if _mi_m == 1
scalar t9_diag_n_0524 = r(N)
scalar t9_diag_mean_0524 = r(mean)
scalar t9_diag_sd_0524 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0524) " mean=" %12.4f scalar(t9_diag_mean_0524) " sd=" %12.4f scalar(t9_diag_sd_0524)

display as text "  Diagnostic block 0525: t9_dep_stress m=2"
quietly summarize t9_dep_stress if _mi_m == 2
scalar t9_diag_n_0525 = r(N)
scalar t9_diag_mean_0525 = r(mean)
scalar t9_diag_sd_0525 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0525) " mean=" %12.4f scalar(t9_diag_mean_0525) " sd=" %12.4f scalar(t9_diag_sd_0525)

display as text "  Diagnostic block 0526: t9_income m=3"
quietly summarize t9_income if _mi_m == 3
scalar t9_diag_n_0526 = r(N)
scalar t9_diag_mean_0526 = r(mean)
scalar t9_diag_sd_0526 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0526) " mean=" %12.4f scalar(t9_diag_mean_0526) " sd=" %12.4f scalar(t9_diag_sd_0526)

display as text "  Diagnostic block 0527: t9_wage m=4"
quietly summarize t9_wage if _mi_m == 4
scalar t9_diag_n_0527 = r(N)
scalar t9_diag_mean_0527 = r(mean)
scalar t9_diag_sd_0527 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0527) " mean=" %12.4f scalar(t9_diag_mean_0527) " sd=" %12.4f scalar(t9_diag_sd_0527)

display as text "  Diagnostic block 0528: t9_hours m=5"
quietly summarize t9_hours if _mi_m == 5
scalar t9_diag_n_0528 = r(N)
scalar t9_diag_mean_0528 = r(mean)
scalar t9_diag_sd_0528 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0528) " mean=" %12.4f scalar(t9_diag_mean_0528) " sd=" %12.4f scalar(t9_diag_sd_0528)

display as text "  Diagnostic block 0529: t9_wealth m=0"
quietly summarize t9_wealth if _mi_m == 0
scalar t9_diag_n_0529 = r(N)
scalar t9_diag_mean_0529 = r(mean)
scalar t9_diag_sd_0529 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0529) " mean=" %12.4f scalar(t9_diag_mean_0529) " sd=" %12.4f scalar(t9_diag_sd_0529)

display as text "  Diagnostic block 0530: t9_savings m=1"
quietly summarize t9_savings if _mi_m == 1
scalar t9_diag_n_0530 = r(N)
scalar t9_diag_mean_0530 = r(mean)
scalar t9_diag_sd_0530 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0530) " mean=" %12.4f scalar(t9_diag_mean_0530) " sd=" %12.4f scalar(t9_diag_sd_0530)

display as text "  Diagnostic block 0531: t9_expenditure m=2"
quietly summarize t9_expenditure if _mi_m == 2
scalar t9_diag_n_0531 = r(N)
scalar t9_diag_mean_0531 = r(mean)
scalar t9_diag_sd_0531 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0531) " mean=" %12.4f scalar(t9_diag_mean_0531) " sd=" %12.4f scalar(t9_diag_sd_0531)

display as text "  Diagnostic block 0532: t9_health_score m=3"
quietly summarize t9_health_score if _mi_m == 3
scalar t9_diag_n_0532 = r(N)
scalar t9_diag_mean_0532 = r(mean)
scalar t9_diag_sd_0532 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0532) " mean=" %12.4f scalar(t9_diag_mean_0532) " sd=" %12.4f scalar(t9_diag_sd_0532)

display as text "  Diagnostic block 0533: t9_bmi m=4"
quietly summarize t9_bmi if _mi_m == 4
scalar t9_diag_n_0533 = r(N)
scalar t9_diag_mean_0533 = r(mean)
scalar t9_diag_sd_0533 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0533) " mean=" %12.4f scalar(t9_diag_mean_0533) " sd=" %12.4f scalar(t9_diag_sd_0533)

display as text "  Diagnostic block 0534: t9_bp_sys m=5"
quietly summarize t9_bp_sys if _mi_m == 5
scalar t9_diag_n_0534 = r(N)
scalar t9_diag_mean_0534 = r(mean)
scalar t9_diag_sd_0534 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0534) " mean=" %12.4f scalar(t9_diag_mean_0534) " sd=" %12.4f scalar(t9_diag_sd_0534)

display as text "  Diagnostic block 0535: t9_bp_dia m=0"
quietly summarize t9_bp_dia if _mi_m == 0
scalar t9_diag_n_0535 = r(N)
scalar t9_diag_mean_0535 = r(mean)
scalar t9_diag_sd_0535 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0535) " mean=" %12.4f scalar(t9_diag_mean_0535) " sd=" %12.4f scalar(t9_diag_sd_0535)

display as text "  Diagnostic block 0536: t9_depression m=1"
quietly summarize t9_depression if _mi_m == 1
scalar t9_diag_n_0536 = r(N)
scalar t9_diag_mean_0536 = r(mean)
scalar t9_diag_sd_0536 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0536) " mean=" %12.4f scalar(t9_diag_mean_0536) " sd=" %12.4f scalar(t9_diag_sd_0536)

display as text "  Diagnostic block 0537: t9_stress m=2"
quietly summarize t9_stress if _mi_m == 2
scalar t9_diag_n_0537 = r(N)
scalar t9_diag_mean_0537 = r(mean)
scalar t9_diag_sd_0537 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0537) " mean=" %12.4f scalar(t9_diag_mean_0537) " sd=" %12.4f scalar(t9_diag_sd_0537)

display as text "  Diagnostic block 0538: t9_satisfaction m=3"
quietly summarize t9_satisfaction if _mi_m == 3
scalar t9_diag_n_0538 = r(N)
scalar t9_diag_mean_0538 = r(mean)
scalar t9_diag_sd_0538 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0538) " mean=" %12.4f scalar(t9_diag_mean_0538) " sd=" %12.4f scalar(t9_diag_sd_0538)

display as text "  Diagnostic block 0539: t9_sleep m=4"
quietly summarize t9_sleep if _mi_m == 4
scalar t9_diag_n_0539 = r(N)
scalar t9_diag_mean_0539 = r(mean)
scalar t9_diag_sd_0539 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0539) " mean=" %12.4f scalar(t9_diag_mean_0539) " sd=" %12.4f scalar(t9_diag_sd_0539)

display as text "  Diagnostic block 0540: t9_exercise m=5"
quietly summarize t9_exercise if _mi_m == 5
scalar t9_diag_n_0540 = r(N)
scalar t9_diag_mean_0540 = r(mean)
scalar t9_diag_sd_0540 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0540) " mean=" %12.4f scalar(t9_diag_mean_0540) " sd=" %12.4f scalar(t9_diag_sd_0540)

display as text "  Diagnostic block 0541: t9_employed m=0"
quietly summarize t9_employed if _mi_m == 0
scalar t9_diag_n_0541 = r(N)
scalar t9_diag_mean_0541 = r(mean)
scalar t9_diag_sd_0541 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0541) " mean=" %12.4f scalar(t9_diag_mean_0541) " sd=" %12.4f scalar(t9_diag_sd_0541)

display as text "  Diagnostic block 0542: t9_married m=1"
quietly summarize t9_married if _mi_m == 1
scalar t9_diag_n_0542 = r(N)
scalar t9_diag_mean_0542 = r(mean)
scalar t9_diag_sd_0542 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0542) " mean=" %12.4f scalar(t9_diag_mean_0542) " sd=" %12.4f scalar(t9_diag_sd_0542)

display as text "  Diagnostic block 0543: t9_urban m=2"
quietly summarize t9_urban if _mi_m == 2
scalar t9_diag_n_0543 = r(N)
scalar t9_diag_mean_0543 = r(mean)
scalar t9_diag_sd_0543 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0543) " mean=" %12.4f scalar(t9_diag_mean_0543) " sd=" %12.4f scalar(t9_diag_sd_0543)

display as text "  Diagnostic block 0544: t9_homeowner m=3"
quietly summarize t9_homeowner if _mi_m == 3
scalar t9_diag_n_0544 = r(N)
scalar t9_diag_mean_0544 = r(mean)
scalar t9_diag_sd_0544 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0544) " mean=" %12.4f scalar(t9_diag_mean_0544) " sd=" %12.4f scalar(t9_diag_sd_0544)

display as text "  Diagnostic block 0545: t9_insured m=4"
quietly summarize t9_insured if _mi_m == 4
scalar t9_diag_n_0545 = r(N)
scalar t9_diag_mean_0545 = r(mean)
scalar t9_diag_sd_0545 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0545) " mean=" %12.4f scalar(t9_diag_mean_0545) " sd=" %12.4f scalar(t9_diag_sd_0545)

display as text "  Diagnostic block 0546: t9_smoker m=5"
quietly summarize t9_smoker if _mi_m == 5
scalar t9_diag_n_0546 = r(N)
scalar t9_diag_mean_0546 = r(mean)
scalar t9_diag_sd_0546 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0546) " mean=" %12.4f scalar(t9_diag_mean_0546) " sd=" %12.4f scalar(t9_diag_sd_0546)

display as text "  Diagnostic block 0547: t9_high_income m=0"
quietly summarize t9_high_income if _mi_m == 0
scalar t9_diag_n_0547 = r(N)
scalar t9_diag_mean_0547 = r(mean)
scalar t9_diag_sd_0547 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0547) " mean=" %12.4f scalar(t9_diag_mean_0547) " sd=" %12.4f scalar(t9_diag_sd_0547)

display as text "  Diagnostic block 0548: t9_high_stress m=1"
quietly summarize t9_high_stress if _mi_m == 1
scalar t9_diag_n_0548 = r(N)
scalar t9_diag_mean_0548 = r(mean)
scalar t9_diag_sd_0548 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0548) " mean=" %12.4f scalar(t9_diag_mean_0548) " sd=" %12.4f scalar(t9_diag_sd_0548)

display as text "  Diagnostic block 0549: t9_unhealthy m=2"
quietly summarize t9_unhealthy if _mi_m == 2
scalar t9_diag_n_0549 = r(N)
scalar t9_diag_mean_0549 = r(mean)
scalar t9_diag_sd_0549 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0549) " mean=" %12.4f scalar(t9_diag_mean_0549) " sd=" %12.4f scalar(t9_diag_sd_0549)

display as text "  Diagnostic block 0550: t9_educ_level m=3"
quietly summarize t9_educ_level if _mi_m == 3
scalar t9_diag_n_0550 = r(N)
scalar t9_diag_mean_0550 = r(mean)
scalar t9_diag_sd_0550 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0550) " mean=" %12.4f scalar(t9_diag_mean_0550) " sd=" %12.4f scalar(t9_diag_sd_0550)

display as text "  Diagnostic block 0551: t9_health_level m=4"
quietly summarize t9_health_level if _mi_m == 4
scalar t9_diag_n_0551 = r(N)
scalar t9_diag_mean_0551 = r(mean)
scalar t9_diag_sd_0551 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0551) " mean=" %12.4f scalar(t9_diag_mean_0551) " sd=" %12.4f scalar(t9_diag_sd_0551)

display as text "  Diagnostic block 0552: t9_job_sat m=5"
quietly summarize t9_job_sat if _mi_m == 5
scalar t9_diag_n_0552 = r(N)
scalar t9_diag_mean_0552 = r(mean)
scalar t9_diag_sd_0552 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0552) " mean=" %12.4f scalar(t9_diag_mean_0552) " sd=" %12.4f scalar(t9_diag_sd_0552)

display as text "  Diagnostic block 0553: t9_children m=0"
quietly summarize t9_children if _mi_m == 0
scalar t9_diag_n_0553 = r(N)
scalar t9_diag_mean_0553 = r(mean)
scalar t9_diag_sd_0553 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0553) " mean=" %12.4f scalar(t9_diag_mean_0553) " sd=" %12.4f scalar(t9_diag_sd_0553)

display as text "  Diagnostic block 0554: t9_doctor_visits m=1"
quietly summarize t9_doctor_visits if _mi_m == 1
scalar t9_diag_n_0554 = r(N)
scalar t9_diag_mean_0554 = r(mean)
scalar t9_diag_sd_0554 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0554) " mean=" %12.4f scalar(t9_diag_mean_0554) " sd=" %12.4f scalar(t9_diag_sd_0554)

display as text "  Diagnostic block 0555: t9_hosp_days m=2"
quietly summarize t9_hosp_days if _mi_m == 2
scalar t9_diag_n_0555 = r(N)
scalar t9_diag_mean_0555 = r(mean)
scalar t9_diag_sd_0555 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0555) " mean=" %12.4f scalar(t9_diag_mean_0555) " sd=" %12.4f scalar(t9_diag_sd_0555)

display as text "  Diagnostic block 0556: t9_log_income m=3"
quietly summarize t9_log_income if _mi_m == 3
scalar t9_diag_n_0556 = r(N)
scalar t9_diag_mean_0556 = r(mean)
scalar t9_diag_sd_0556 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0556) " mean=" %12.4f scalar(t9_diag_mean_0556) " sd=" %12.4f scalar(t9_diag_sd_0556)

display as text "  Diagnostic block 0557: t9_log_wage m=4"
quietly summarize t9_log_wage if _mi_m == 4
scalar t9_diag_n_0557 = r(N)
scalar t9_diag_mean_0557 = r(mean)
scalar t9_diag_sd_0557 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0557) " mean=" %12.4f scalar(t9_diag_mean_0557) " sd=" %12.4f scalar(t9_diag_sd_0557)

display as text "  Diagnostic block 0558: t9_income_per_hour m=5"
quietly summarize t9_income_per_hour if _mi_m == 5
scalar t9_diag_n_0558 = r(N)
scalar t9_diag_mean_0558 = r(mean)
scalar t9_diag_sd_0558 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0558) " mean=" %12.4f scalar(t9_diag_mean_0558) " sd=" %12.4f scalar(t9_diag_sd_0558)

display as text "  Diagnostic block 0559: t9_health_index m=0"
quietly summarize t9_health_index if _mi_m == 0
scalar t9_diag_n_0559 = r(N)
scalar t9_diag_mean_0559 = r(mean)
scalar t9_diag_sd_0559 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0559) " mean=" %12.4f scalar(t9_diag_mean_0559) " sd=" %12.4f scalar(t9_diag_sd_0559)

display as text "  Diagnostic block 0560: t9_dep_stress m=1"
quietly summarize t9_dep_stress if _mi_m == 1
scalar t9_diag_n_0560 = r(N)
scalar t9_diag_mean_0560 = r(mean)
scalar t9_diag_sd_0560 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0560) " mean=" %12.4f scalar(t9_diag_mean_0560) " sd=" %12.4f scalar(t9_diag_sd_0560)

display as text "  Diagnostic block 0561: t9_income m=2"
quietly summarize t9_income if _mi_m == 2
scalar t9_diag_n_0561 = r(N)
scalar t9_diag_mean_0561 = r(mean)
scalar t9_diag_sd_0561 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0561) " mean=" %12.4f scalar(t9_diag_mean_0561) " sd=" %12.4f scalar(t9_diag_sd_0561)

display as text "  Diagnostic block 0562: t9_wage m=3"
quietly summarize t9_wage if _mi_m == 3
scalar t9_diag_n_0562 = r(N)
scalar t9_diag_mean_0562 = r(mean)
scalar t9_diag_sd_0562 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0562) " mean=" %12.4f scalar(t9_diag_mean_0562) " sd=" %12.4f scalar(t9_diag_sd_0562)

display as text "  Diagnostic block 0563: t9_hours m=4"
quietly summarize t9_hours if _mi_m == 4
scalar t9_diag_n_0563 = r(N)
scalar t9_diag_mean_0563 = r(mean)
scalar t9_diag_sd_0563 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0563) " mean=" %12.4f scalar(t9_diag_mean_0563) " sd=" %12.4f scalar(t9_diag_sd_0563)

display as text "  Diagnostic block 0564: t9_wealth m=5"
quietly summarize t9_wealth if _mi_m == 5
scalar t9_diag_n_0564 = r(N)
scalar t9_diag_mean_0564 = r(mean)
scalar t9_diag_sd_0564 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0564) " mean=" %12.4f scalar(t9_diag_mean_0564) " sd=" %12.4f scalar(t9_diag_sd_0564)

display as text "  Diagnostic block 0565: t9_savings m=0"
quietly summarize t9_savings if _mi_m == 0
scalar t9_diag_n_0565 = r(N)
scalar t9_diag_mean_0565 = r(mean)
scalar t9_diag_sd_0565 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0565) " mean=" %12.4f scalar(t9_diag_mean_0565) " sd=" %12.4f scalar(t9_diag_sd_0565)

display as text "  Diagnostic block 0566: t9_expenditure m=1"
quietly summarize t9_expenditure if _mi_m == 1
scalar t9_diag_n_0566 = r(N)
scalar t9_diag_mean_0566 = r(mean)
scalar t9_diag_sd_0566 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0566) " mean=" %12.4f scalar(t9_diag_mean_0566) " sd=" %12.4f scalar(t9_diag_sd_0566)

display as text "  Diagnostic block 0567: t9_health_score m=2"
quietly summarize t9_health_score if _mi_m == 2
scalar t9_diag_n_0567 = r(N)
scalar t9_diag_mean_0567 = r(mean)
scalar t9_diag_sd_0567 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0567) " mean=" %12.4f scalar(t9_diag_mean_0567) " sd=" %12.4f scalar(t9_diag_sd_0567)

display as text "  Diagnostic block 0568: t9_bmi m=3"
quietly summarize t9_bmi if _mi_m == 3
scalar t9_diag_n_0568 = r(N)
scalar t9_diag_mean_0568 = r(mean)
scalar t9_diag_sd_0568 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0568) " mean=" %12.4f scalar(t9_diag_mean_0568) " sd=" %12.4f scalar(t9_diag_sd_0568)

display as text "  Diagnostic block 0569: t9_bp_sys m=4"
quietly summarize t9_bp_sys if _mi_m == 4
scalar t9_diag_n_0569 = r(N)
scalar t9_diag_mean_0569 = r(mean)
scalar t9_diag_sd_0569 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0569) " mean=" %12.4f scalar(t9_diag_mean_0569) " sd=" %12.4f scalar(t9_diag_sd_0569)

display as text "  Diagnostic block 0570: t9_bp_dia m=5"
quietly summarize t9_bp_dia if _mi_m == 5
scalar t9_diag_n_0570 = r(N)
scalar t9_diag_mean_0570 = r(mean)
scalar t9_diag_sd_0570 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0570) " mean=" %12.4f scalar(t9_diag_mean_0570) " sd=" %12.4f scalar(t9_diag_sd_0570)

display as text "  Diagnostic block 0571: t9_depression m=0"
quietly summarize t9_depression if _mi_m == 0
scalar t9_diag_n_0571 = r(N)
scalar t9_diag_mean_0571 = r(mean)
scalar t9_diag_sd_0571 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0571) " mean=" %12.4f scalar(t9_diag_mean_0571) " sd=" %12.4f scalar(t9_diag_sd_0571)

display as text "  Diagnostic block 0572: t9_stress m=1"
quietly summarize t9_stress if _mi_m == 1
scalar t9_diag_n_0572 = r(N)
scalar t9_diag_mean_0572 = r(mean)
scalar t9_diag_sd_0572 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0572) " mean=" %12.4f scalar(t9_diag_mean_0572) " sd=" %12.4f scalar(t9_diag_sd_0572)

display as text "  Diagnostic block 0573: t9_satisfaction m=2"
quietly summarize t9_satisfaction if _mi_m == 2
scalar t9_diag_n_0573 = r(N)
scalar t9_diag_mean_0573 = r(mean)
scalar t9_diag_sd_0573 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0573) " mean=" %12.4f scalar(t9_diag_mean_0573) " sd=" %12.4f scalar(t9_diag_sd_0573)

display as text "  Diagnostic block 0574: t9_sleep m=3"
quietly summarize t9_sleep if _mi_m == 3
scalar t9_diag_n_0574 = r(N)
scalar t9_diag_mean_0574 = r(mean)
scalar t9_diag_sd_0574 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0574) " mean=" %12.4f scalar(t9_diag_mean_0574) " sd=" %12.4f scalar(t9_diag_sd_0574)

display as text "  Diagnostic block 0575: t9_exercise m=4"
quietly summarize t9_exercise if _mi_m == 4
scalar t9_diag_n_0575 = r(N)
scalar t9_diag_mean_0575 = r(mean)
scalar t9_diag_sd_0575 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0575) " mean=" %12.4f scalar(t9_diag_mean_0575) " sd=" %12.4f scalar(t9_diag_sd_0575)

display as text "  Diagnostic block 0576: t9_employed m=5"
quietly summarize t9_employed if _mi_m == 5
scalar t9_diag_n_0576 = r(N)
scalar t9_diag_mean_0576 = r(mean)
scalar t9_diag_sd_0576 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0576) " mean=" %12.4f scalar(t9_diag_mean_0576) " sd=" %12.4f scalar(t9_diag_sd_0576)

display as text "  Diagnostic block 0577: t9_married m=0"
quietly summarize t9_married if _mi_m == 0
scalar t9_diag_n_0577 = r(N)
scalar t9_diag_mean_0577 = r(mean)
scalar t9_diag_sd_0577 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0577) " mean=" %12.4f scalar(t9_diag_mean_0577) " sd=" %12.4f scalar(t9_diag_sd_0577)

display as text "  Diagnostic block 0578: t9_urban m=1"
quietly summarize t9_urban if _mi_m == 1
scalar t9_diag_n_0578 = r(N)
scalar t9_diag_mean_0578 = r(mean)
scalar t9_diag_sd_0578 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0578) " mean=" %12.4f scalar(t9_diag_mean_0578) " sd=" %12.4f scalar(t9_diag_sd_0578)

display as text "  Diagnostic block 0579: t9_homeowner m=2"
quietly summarize t9_homeowner if _mi_m == 2
scalar t9_diag_n_0579 = r(N)
scalar t9_diag_mean_0579 = r(mean)
scalar t9_diag_sd_0579 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0579) " mean=" %12.4f scalar(t9_diag_mean_0579) " sd=" %12.4f scalar(t9_diag_sd_0579)

display as text "  Diagnostic block 0580: t9_insured m=3"
quietly summarize t9_insured if _mi_m == 3
scalar t9_diag_n_0580 = r(N)
scalar t9_diag_mean_0580 = r(mean)
scalar t9_diag_sd_0580 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0580) " mean=" %12.4f scalar(t9_diag_mean_0580) " sd=" %12.4f scalar(t9_diag_sd_0580)

display as text "  Diagnostic block 0581: t9_smoker m=4"
quietly summarize t9_smoker if _mi_m == 4
scalar t9_diag_n_0581 = r(N)
scalar t9_diag_mean_0581 = r(mean)
scalar t9_diag_sd_0581 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0581) " mean=" %12.4f scalar(t9_diag_mean_0581) " sd=" %12.4f scalar(t9_diag_sd_0581)

display as text "  Diagnostic block 0582: t9_high_income m=5"
quietly summarize t9_high_income if _mi_m == 5
scalar t9_diag_n_0582 = r(N)
scalar t9_diag_mean_0582 = r(mean)
scalar t9_diag_sd_0582 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0582) " mean=" %12.4f scalar(t9_diag_mean_0582) " sd=" %12.4f scalar(t9_diag_sd_0582)

display as text "  Diagnostic block 0583: t9_high_stress m=0"
quietly summarize t9_high_stress if _mi_m == 0
scalar t9_diag_n_0583 = r(N)
scalar t9_diag_mean_0583 = r(mean)
scalar t9_diag_sd_0583 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0583) " mean=" %12.4f scalar(t9_diag_mean_0583) " sd=" %12.4f scalar(t9_diag_sd_0583)

display as text "  Diagnostic block 0584: t9_unhealthy m=1"
quietly summarize t9_unhealthy if _mi_m == 1
scalar t9_diag_n_0584 = r(N)
scalar t9_diag_mean_0584 = r(mean)
scalar t9_diag_sd_0584 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0584) " mean=" %12.4f scalar(t9_diag_mean_0584) " sd=" %12.4f scalar(t9_diag_sd_0584)

display as text "  Diagnostic block 0585: t9_educ_level m=2"
quietly summarize t9_educ_level if _mi_m == 2
scalar t9_diag_n_0585 = r(N)
scalar t9_diag_mean_0585 = r(mean)
scalar t9_diag_sd_0585 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0585) " mean=" %12.4f scalar(t9_diag_mean_0585) " sd=" %12.4f scalar(t9_diag_sd_0585)

display as text "  Diagnostic block 0586: t9_health_level m=3"
quietly summarize t9_health_level if _mi_m == 3
scalar t9_diag_n_0586 = r(N)
scalar t9_diag_mean_0586 = r(mean)
scalar t9_diag_sd_0586 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0586) " mean=" %12.4f scalar(t9_diag_mean_0586) " sd=" %12.4f scalar(t9_diag_sd_0586)

display as text "  Diagnostic block 0587: t9_job_sat m=4"
quietly summarize t9_job_sat if _mi_m == 4
scalar t9_diag_n_0587 = r(N)
scalar t9_diag_mean_0587 = r(mean)
scalar t9_diag_sd_0587 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0587) " mean=" %12.4f scalar(t9_diag_mean_0587) " sd=" %12.4f scalar(t9_diag_sd_0587)

display as text "  Diagnostic block 0588: t9_children m=5"
quietly summarize t9_children if _mi_m == 5
scalar t9_diag_n_0588 = r(N)
scalar t9_diag_mean_0588 = r(mean)
scalar t9_diag_sd_0588 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0588) " mean=" %12.4f scalar(t9_diag_mean_0588) " sd=" %12.4f scalar(t9_diag_sd_0588)

display as text "  Diagnostic block 0589: t9_doctor_visits m=0"
quietly summarize t9_doctor_visits if _mi_m == 0
scalar t9_diag_n_0589 = r(N)
scalar t9_diag_mean_0589 = r(mean)
scalar t9_diag_sd_0589 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0589) " mean=" %12.4f scalar(t9_diag_mean_0589) " sd=" %12.4f scalar(t9_diag_sd_0589)

display as text "  Diagnostic block 0590: t9_hosp_days m=1"
quietly summarize t9_hosp_days if _mi_m == 1
scalar t9_diag_n_0590 = r(N)
scalar t9_diag_mean_0590 = r(mean)
scalar t9_diag_sd_0590 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0590) " mean=" %12.4f scalar(t9_diag_mean_0590) " sd=" %12.4f scalar(t9_diag_sd_0590)

display as text "  Diagnostic block 0591: t9_log_income m=2"
quietly summarize t9_log_income if _mi_m == 2
scalar t9_diag_n_0591 = r(N)
scalar t9_diag_mean_0591 = r(mean)
scalar t9_diag_sd_0591 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0591) " mean=" %12.4f scalar(t9_diag_mean_0591) " sd=" %12.4f scalar(t9_diag_sd_0591)

display as text "  Diagnostic block 0592: t9_log_wage m=3"
quietly summarize t9_log_wage if _mi_m == 3
scalar t9_diag_n_0592 = r(N)
scalar t9_diag_mean_0592 = r(mean)
scalar t9_diag_sd_0592 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0592) " mean=" %12.4f scalar(t9_diag_mean_0592) " sd=" %12.4f scalar(t9_diag_sd_0592)

display as text "  Diagnostic block 0593: t9_income_per_hour m=4"
quietly summarize t9_income_per_hour if _mi_m == 4
scalar t9_diag_n_0593 = r(N)
scalar t9_diag_mean_0593 = r(mean)
scalar t9_diag_sd_0593 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0593) " mean=" %12.4f scalar(t9_diag_mean_0593) " sd=" %12.4f scalar(t9_diag_sd_0593)

display as text "  Diagnostic block 0594: t9_health_index m=5"
quietly summarize t9_health_index if _mi_m == 5
scalar t9_diag_n_0594 = r(N)
scalar t9_diag_mean_0594 = r(mean)
scalar t9_diag_sd_0594 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0594) " mean=" %12.4f scalar(t9_diag_mean_0594) " sd=" %12.4f scalar(t9_diag_sd_0594)

display as text "  Diagnostic block 0595: t9_dep_stress m=0"
quietly summarize t9_dep_stress if _mi_m == 0
scalar t9_diag_n_0595 = r(N)
scalar t9_diag_mean_0595 = r(mean)
scalar t9_diag_sd_0595 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0595) " mean=" %12.4f scalar(t9_diag_mean_0595) " sd=" %12.4f scalar(t9_diag_sd_0595)

display as text "  Diagnostic block 0596: t9_income m=1"
quietly summarize t9_income if _mi_m == 1
scalar t9_diag_n_0596 = r(N)
scalar t9_diag_mean_0596 = r(mean)
scalar t9_diag_sd_0596 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0596) " mean=" %12.4f scalar(t9_diag_mean_0596) " sd=" %12.4f scalar(t9_diag_sd_0596)

display as text "  Diagnostic block 0597: t9_wage m=2"
quietly summarize t9_wage if _mi_m == 2
scalar t9_diag_n_0597 = r(N)
scalar t9_diag_mean_0597 = r(mean)
scalar t9_diag_sd_0597 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0597) " mean=" %12.4f scalar(t9_diag_mean_0597) " sd=" %12.4f scalar(t9_diag_sd_0597)

display as text "  Diagnostic block 0598: t9_hours m=3"
quietly summarize t9_hours if _mi_m == 3
scalar t9_diag_n_0598 = r(N)
scalar t9_diag_mean_0598 = r(mean)
scalar t9_diag_sd_0598 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0598) " mean=" %12.4f scalar(t9_diag_mean_0598) " sd=" %12.4f scalar(t9_diag_sd_0598)

display as text "  Diagnostic block 0599: t9_wealth m=4"
quietly summarize t9_wealth if _mi_m == 4
scalar t9_diag_n_0599 = r(N)
scalar t9_diag_mean_0599 = r(mean)
scalar t9_diag_sd_0599 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0599) " mean=" %12.4f scalar(t9_diag_mean_0599) " sd=" %12.4f scalar(t9_diag_sd_0599)

display as text "  Diagnostic block 0600: t9_savings m=5"
quietly summarize t9_savings if _mi_m == 5
scalar t9_diag_n_0600 = r(N)
scalar t9_diag_mean_0600 = r(mean)
scalar t9_diag_sd_0600 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0600) " mean=" %12.4f scalar(t9_diag_mean_0600) " sd=" %12.4f scalar(t9_diag_sd_0600)

display as text "  Diagnostic block 0601: t9_expenditure m=0"
quietly summarize t9_expenditure if _mi_m == 0
scalar t9_diag_n_0601 = r(N)
scalar t9_diag_mean_0601 = r(mean)
scalar t9_diag_sd_0601 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0601) " mean=" %12.4f scalar(t9_diag_mean_0601) " sd=" %12.4f scalar(t9_diag_sd_0601)

display as text "  Diagnostic block 0602: t9_health_score m=1"
quietly summarize t9_health_score if _mi_m == 1
scalar t9_diag_n_0602 = r(N)
scalar t9_diag_mean_0602 = r(mean)
scalar t9_diag_sd_0602 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0602) " mean=" %12.4f scalar(t9_diag_mean_0602) " sd=" %12.4f scalar(t9_diag_sd_0602)

display as text "  Diagnostic block 0603: t9_bmi m=2"
quietly summarize t9_bmi if _mi_m == 2
scalar t9_diag_n_0603 = r(N)
scalar t9_diag_mean_0603 = r(mean)
scalar t9_diag_sd_0603 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0603) " mean=" %12.4f scalar(t9_diag_mean_0603) " sd=" %12.4f scalar(t9_diag_sd_0603)

display as text "  Diagnostic block 0604: t9_bp_sys m=3"
quietly summarize t9_bp_sys if _mi_m == 3
scalar t9_diag_n_0604 = r(N)
scalar t9_diag_mean_0604 = r(mean)
scalar t9_diag_sd_0604 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0604) " mean=" %12.4f scalar(t9_diag_mean_0604) " sd=" %12.4f scalar(t9_diag_sd_0604)

display as text "  Diagnostic block 0605: t9_bp_dia m=4"
quietly summarize t9_bp_dia if _mi_m == 4
scalar t9_diag_n_0605 = r(N)
scalar t9_diag_mean_0605 = r(mean)
scalar t9_diag_sd_0605 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0605) " mean=" %12.4f scalar(t9_diag_mean_0605) " sd=" %12.4f scalar(t9_diag_sd_0605)

display as text "  Diagnostic block 0606: t9_depression m=5"
quietly summarize t9_depression if _mi_m == 5
scalar t9_diag_n_0606 = r(N)
scalar t9_diag_mean_0606 = r(mean)
scalar t9_diag_sd_0606 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0606) " mean=" %12.4f scalar(t9_diag_mean_0606) " sd=" %12.4f scalar(t9_diag_sd_0606)

display as text "  Diagnostic block 0607: t9_stress m=0"
quietly summarize t9_stress if _mi_m == 0
scalar t9_diag_n_0607 = r(N)
scalar t9_diag_mean_0607 = r(mean)
scalar t9_diag_sd_0607 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0607) " mean=" %12.4f scalar(t9_diag_mean_0607) " sd=" %12.4f scalar(t9_diag_sd_0607)

display as text "  Diagnostic block 0608: t9_satisfaction m=1"
quietly summarize t9_satisfaction if _mi_m == 1
scalar t9_diag_n_0608 = r(N)
scalar t9_diag_mean_0608 = r(mean)
scalar t9_diag_sd_0608 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0608) " mean=" %12.4f scalar(t9_diag_mean_0608) " sd=" %12.4f scalar(t9_diag_sd_0608)

display as text "  Diagnostic block 0609: t9_sleep m=2"
quietly summarize t9_sleep if _mi_m == 2
scalar t9_diag_n_0609 = r(N)
scalar t9_diag_mean_0609 = r(mean)
scalar t9_diag_sd_0609 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0609) " mean=" %12.4f scalar(t9_diag_mean_0609) " sd=" %12.4f scalar(t9_diag_sd_0609)

display as text "  Diagnostic block 0610: t9_exercise m=3"
quietly summarize t9_exercise if _mi_m == 3
scalar t9_diag_n_0610 = r(N)
scalar t9_diag_mean_0610 = r(mean)
scalar t9_diag_sd_0610 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0610) " mean=" %12.4f scalar(t9_diag_mean_0610) " sd=" %12.4f scalar(t9_diag_sd_0610)

display as text "  Diagnostic block 0611: t9_employed m=4"
quietly summarize t9_employed if _mi_m == 4
scalar t9_diag_n_0611 = r(N)
scalar t9_diag_mean_0611 = r(mean)
scalar t9_diag_sd_0611 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0611) " mean=" %12.4f scalar(t9_diag_mean_0611) " sd=" %12.4f scalar(t9_diag_sd_0611)

display as text "  Diagnostic block 0612: t9_married m=5"
quietly summarize t9_married if _mi_m == 5
scalar t9_diag_n_0612 = r(N)
scalar t9_diag_mean_0612 = r(mean)
scalar t9_diag_sd_0612 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0612) " mean=" %12.4f scalar(t9_diag_mean_0612) " sd=" %12.4f scalar(t9_diag_sd_0612)

display as text "  Diagnostic block 0613: t9_urban m=0"
quietly summarize t9_urban if _mi_m == 0
scalar t9_diag_n_0613 = r(N)
scalar t9_diag_mean_0613 = r(mean)
scalar t9_diag_sd_0613 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0613) " mean=" %12.4f scalar(t9_diag_mean_0613) " sd=" %12.4f scalar(t9_diag_sd_0613)

display as text "  Diagnostic block 0614: t9_homeowner m=1"
quietly summarize t9_homeowner if _mi_m == 1
scalar t9_diag_n_0614 = r(N)
scalar t9_diag_mean_0614 = r(mean)
scalar t9_diag_sd_0614 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0614) " mean=" %12.4f scalar(t9_diag_mean_0614) " sd=" %12.4f scalar(t9_diag_sd_0614)

display as text "  Diagnostic block 0615: t9_insured m=2"
quietly summarize t9_insured if _mi_m == 2
scalar t9_diag_n_0615 = r(N)
scalar t9_diag_mean_0615 = r(mean)
scalar t9_diag_sd_0615 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0615) " mean=" %12.4f scalar(t9_diag_mean_0615) " sd=" %12.4f scalar(t9_diag_sd_0615)

display as text "  Diagnostic block 0616: t9_smoker m=3"
quietly summarize t9_smoker if _mi_m == 3
scalar t9_diag_n_0616 = r(N)
scalar t9_diag_mean_0616 = r(mean)
scalar t9_diag_sd_0616 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0616) " mean=" %12.4f scalar(t9_diag_mean_0616) " sd=" %12.4f scalar(t9_diag_sd_0616)

display as text "  Diagnostic block 0617: t9_high_income m=4"
quietly summarize t9_high_income if _mi_m == 4
scalar t9_diag_n_0617 = r(N)
scalar t9_diag_mean_0617 = r(mean)
scalar t9_diag_sd_0617 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0617) " mean=" %12.4f scalar(t9_diag_mean_0617) " sd=" %12.4f scalar(t9_diag_sd_0617)

display as text "  Diagnostic block 0618: t9_high_stress m=5"
quietly summarize t9_high_stress if _mi_m == 5
scalar t9_diag_n_0618 = r(N)
scalar t9_diag_mean_0618 = r(mean)
scalar t9_diag_sd_0618 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0618) " mean=" %12.4f scalar(t9_diag_mean_0618) " sd=" %12.4f scalar(t9_diag_sd_0618)

display as text "  Diagnostic block 0619: t9_unhealthy m=0"
quietly summarize t9_unhealthy if _mi_m == 0
scalar t9_diag_n_0619 = r(N)
scalar t9_diag_mean_0619 = r(mean)
scalar t9_diag_sd_0619 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0619) " mean=" %12.4f scalar(t9_diag_mean_0619) " sd=" %12.4f scalar(t9_diag_sd_0619)

display as text "  Diagnostic block 0620: t9_educ_level m=1"
quietly summarize t9_educ_level if _mi_m == 1
scalar t9_diag_n_0620 = r(N)
scalar t9_diag_mean_0620 = r(mean)
scalar t9_diag_sd_0620 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0620) " mean=" %12.4f scalar(t9_diag_mean_0620) " sd=" %12.4f scalar(t9_diag_sd_0620)

display as text "  Diagnostic block 0621: t9_health_level m=2"
quietly summarize t9_health_level if _mi_m == 2
scalar t9_diag_n_0621 = r(N)
scalar t9_diag_mean_0621 = r(mean)
scalar t9_diag_sd_0621 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0621) " mean=" %12.4f scalar(t9_diag_mean_0621) " sd=" %12.4f scalar(t9_diag_sd_0621)

display as text "  Diagnostic block 0622: t9_job_sat m=3"
quietly summarize t9_job_sat if _mi_m == 3
scalar t9_diag_n_0622 = r(N)
scalar t9_diag_mean_0622 = r(mean)
scalar t9_diag_sd_0622 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0622) " mean=" %12.4f scalar(t9_diag_mean_0622) " sd=" %12.4f scalar(t9_diag_sd_0622)

display as text "  Diagnostic block 0623: t9_children m=4"
quietly summarize t9_children if _mi_m == 4
scalar t9_diag_n_0623 = r(N)
scalar t9_diag_mean_0623 = r(mean)
scalar t9_diag_sd_0623 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0623) " mean=" %12.4f scalar(t9_diag_mean_0623) " sd=" %12.4f scalar(t9_diag_sd_0623)

display as text "  Diagnostic block 0624: t9_doctor_visits m=5"
quietly summarize t9_doctor_visits if _mi_m == 5
scalar t9_diag_n_0624 = r(N)
scalar t9_diag_mean_0624 = r(mean)
scalar t9_diag_sd_0624 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0624) " mean=" %12.4f scalar(t9_diag_mean_0624) " sd=" %12.4f scalar(t9_diag_sd_0624)

display as text "  Diagnostic block 0625: t9_hosp_days m=0"
quietly summarize t9_hosp_days if _mi_m == 0
scalar t9_diag_n_0625 = r(N)
scalar t9_diag_mean_0625 = r(mean)
scalar t9_diag_sd_0625 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0625) " mean=" %12.4f scalar(t9_diag_mean_0625) " sd=" %12.4f scalar(t9_diag_sd_0625)

display as text "  Diagnostic block 0626: t9_log_income m=1"
quietly summarize t9_log_income if _mi_m == 1
scalar t9_diag_n_0626 = r(N)
scalar t9_diag_mean_0626 = r(mean)
scalar t9_diag_sd_0626 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0626) " mean=" %12.4f scalar(t9_diag_mean_0626) " sd=" %12.4f scalar(t9_diag_sd_0626)

display as text "  Diagnostic block 0627: t9_log_wage m=2"
quietly summarize t9_log_wage if _mi_m == 2
scalar t9_diag_n_0627 = r(N)
scalar t9_diag_mean_0627 = r(mean)
scalar t9_diag_sd_0627 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0627) " mean=" %12.4f scalar(t9_diag_mean_0627) " sd=" %12.4f scalar(t9_diag_sd_0627)

display as text "  Diagnostic block 0628: t9_income_per_hour m=3"
quietly summarize t9_income_per_hour if _mi_m == 3
scalar t9_diag_n_0628 = r(N)
scalar t9_diag_mean_0628 = r(mean)
scalar t9_diag_sd_0628 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0628) " mean=" %12.4f scalar(t9_diag_mean_0628) " sd=" %12.4f scalar(t9_diag_sd_0628)

display as text "  Diagnostic block 0629: t9_health_index m=4"
quietly summarize t9_health_index if _mi_m == 4
scalar t9_diag_n_0629 = r(N)
scalar t9_diag_mean_0629 = r(mean)
scalar t9_diag_sd_0629 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0629) " mean=" %12.4f scalar(t9_diag_mean_0629) " sd=" %12.4f scalar(t9_diag_sd_0629)

display as text "  Diagnostic block 0630: t9_dep_stress m=5"
quietly summarize t9_dep_stress if _mi_m == 5
scalar t9_diag_n_0630 = r(N)
scalar t9_diag_mean_0630 = r(mean)
scalar t9_diag_sd_0630 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0630) " mean=" %12.4f scalar(t9_diag_mean_0630) " sd=" %12.4f scalar(t9_diag_sd_0630)

display as text "  Diagnostic block 0631: t9_income m=0"
quietly summarize t9_income if _mi_m == 0
scalar t9_diag_n_0631 = r(N)
scalar t9_diag_mean_0631 = r(mean)
scalar t9_diag_sd_0631 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0631) " mean=" %12.4f scalar(t9_diag_mean_0631) " sd=" %12.4f scalar(t9_diag_sd_0631)

display as text "  Diagnostic block 0632: t9_wage m=1"
quietly summarize t9_wage if _mi_m == 1
scalar t9_diag_n_0632 = r(N)
scalar t9_diag_mean_0632 = r(mean)
scalar t9_diag_sd_0632 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0632) " mean=" %12.4f scalar(t9_diag_mean_0632) " sd=" %12.4f scalar(t9_diag_sd_0632)

display as text "  Diagnostic block 0633: t9_hours m=2"
quietly summarize t9_hours if _mi_m == 2
scalar t9_diag_n_0633 = r(N)
scalar t9_diag_mean_0633 = r(mean)
scalar t9_diag_sd_0633 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0633) " mean=" %12.4f scalar(t9_diag_mean_0633) " sd=" %12.4f scalar(t9_diag_sd_0633)

display as text "  Diagnostic block 0634: t9_wealth m=3"
quietly summarize t9_wealth if _mi_m == 3
scalar t9_diag_n_0634 = r(N)
scalar t9_diag_mean_0634 = r(mean)
scalar t9_diag_sd_0634 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0634) " mean=" %12.4f scalar(t9_diag_mean_0634) " sd=" %12.4f scalar(t9_diag_sd_0634)

display as text "  Diagnostic block 0635: t9_savings m=4"
quietly summarize t9_savings if _mi_m == 4
scalar t9_diag_n_0635 = r(N)
scalar t9_diag_mean_0635 = r(mean)
scalar t9_diag_sd_0635 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0635) " mean=" %12.4f scalar(t9_diag_mean_0635) " sd=" %12.4f scalar(t9_diag_sd_0635)

display as text "  Diagnostic block 0636: t9_expenditure m=5"
quietly summarize t9_expenditure if _mi_m == 5
scalar t9_diag_n_0636 = r(N)
scalar t9_diag_mean_0636 = r(mean)
scalar t9_diag_sd_0636 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0636) " mean=" %12.4f scalar(t9_diag_mean_0636) " sd=" %12.4f scalar(t9_diag_sd_0636)

display as text "  Diagnostic block 0637: t9_health_score m=0"
quietly summarize t9_health_score if _mi_m == 0
scalar t9_diag_n_0637 = r(N)
scalar t9_diag_mean_0637 = r(mean)
scalar t9_diag_sd_0637 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0637) " mean=" %12.4f scalar(t9_diag_mean_0637) " sd=" %12.4f scalar(t9_diag_sd_0637)

display as text "  Diagnostic block 0638: t9_bmi m=1"
quietly summarize t9_bmi if _mi_m == 1
scalar t9_diag_n_0638 = r(N)
scalar t9_diag_mean_0638 = r(mean)
scalar t9_diag_sd_0638 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0638) " mean=" %12.4f scalar(t9_diag_mean_0638) " sd=" %12.4f scalar(t9_diag_sd_0638)

display as text "  Diagnostic block 0639: t9_bp_sys m=2"
quietly summarize t9_bp_sys if _mi_m == 2
scalar t9_diag_n_0639 = r(N)
scalar t9_diag_mean_0639 = r(mean)
scalar t9_diag_sd_0639 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0639) " mean=" %12.4f scalar(t9_diag_mean_0639) " sd=" %12.4f scalar(t9_diag_sd_0639)

display as text "  Diagnostic block 0640: t9_bp_dia m=3"
quietly summarize t9_bp_dia if _mi_m == 3
scalar t9_diag_n_0640 = r(N)
scalar t9_diag_mean_0640 = r(mean)
scalar t9_diag_sd_0640 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0640) " mean=" %12.4f scalar(t9_diag_mean_0640) " sd=" %12.4f scalar(t9_diag_sd_0640)

display as text "  Diagnostic block 0641: t9_depression m=4"
quietly summarize t9_depression if _mi_m == 4
scalar t9_diag_n_0641 = r(N)
scalar t9_diag_mean_0641 = r(mean)
scalar t9_diag_sd_0641 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0641) " mean=" %12.4f scalar(t9_diag_mean_0641) " sd=" %12.4f scalar(t9_diag_sd_0641)

display as text "  Diagnostic block 0642: t9_stress m=5"
quietly summarize t9_stress if _mi_m == 5
scalar t9_diag_n_0642 = r(N)
scalar t9_diag_mean_0642 = r(mean)
scalar t9_diag_sd_0642 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0642) " mean=" %12.4f scalar(t9_diag_mean_0642) " sd=" %12.4f scalar(t9_diag_sd_0642)

display as text "  Diagnostic block 0643: t9_satisfaction m=0"
quietly summarize t9_satisfaction if _mi_m == 0
scalar t9_diag_n_0643 = r(N)
scalar t9_diag_mean_0643 = r(mean)
scalar t9_diag_sd_0643 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0643) " mean=" %12.4f scalar(t9_diag_mean_0643) " sd=" %12.4f scalar(t9_diag_sd_0643)

display as text "  Diagnostic block 0644: t9_sleep m=1"
quietly summarize t9_sleep if _mi_m == 1
scalar t9_diag_n_0644 = r(N)
scalar t9_diag_mean_0644 = r(mean)
scalar t9_diag_sd_0644 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0644) " mean=" %12.4f scalar(t9_diag_mean_0644) " sd=" %12.4f scalar(t9_diag_sd_0644)

display as text "  Diagnostic block 0645: t9_exercise m=2"
quietly summarize t9_exercise if _mi_m == 2
scalar t9_diag_n_0645 = r(N)
scalar t9_diag_mean_0645 = r(mean)
scalar t9_diag_sd_0645 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0645) " mean=" %12.4f scalar(t9_diag_mean_0645) " sd=" %12.4f scalar(t9_diag_sd_0645)

display as text "  Diagnostic block 0646: t9_employed m=3"
quietly summarize t9_employed if _mi_m == 3
scalar t9_diag_n_0646 = r(N)
scalar t9_diag_mean_0646 = r(mean)
scalar t9_diag_sd_0646 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0646) " mean=" %12.4f scalar(t9_diag_mean_0646) " sd=" %12.4f scalar(t9_diag_sd_0646)

display as text "  Diagnostic block 0647: t9_married m=4"
quietly summarize t9_married if _mi_m == 4
scalar t9_diag_n_0647 = r(N)
scalar t9_diag_mean_0647 = r(mean)
scalar t9_diag_sd_0647 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0647) " mean=" %12.4f scalar(t9_diag_mean_0647) " sd=" %12.4f scalar(t9_diag_sd_0647)

display as text "  Diagnostic block 0648: t9_urban m=5"
quietly summarize t9_urban if _mi_m == 5
scalar t9_diag_n_0648 = r(N)
scalar t9_diag_mean_0648 = r(mean)
scalar t9_diag_sd_0648 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0648) " mean=" %12.4f scalar(t9_diag_mean_0648) " sd=" %12.4f scalar(t9_diag_sd_0648)

display as text "  Diagnostic block 0649: t9_homeowner m=0"
quietly summarize t9_homeowner if _mi_m == 0
scalar t9_diag_n_0649 = r(N)
scalar t9_diag_mean_0649 = r(mean)
scalar t9_diag_sd_0649 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0649) " mean=" %12.4f scalar(t9_diag_mean_0649) " sd=" %12.4f scalar(t9_diag_sd_0649)

display as text "  Diagnostic block 0650: t9_insured m=1"
quietly summarize t9_insured if _mi_m == 1
scalar t9_diag_n_0650 = r(N)
scalar t9_diag_mean_0650 = r(mean)
scalar t9_diag_sd_0650 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0650) " mean=" %12.4f scalar(t9_diag_mean_0650) " sd=" %12.4f scalar(t9_diag_sd_0650)

display as text "  Diagnostic block 0651: t9_smoker m=2"
quietly summarize t9_smoker if _mi_m == 2
scalar t9_diag_n_0651 = r(N)
scalar t9_diag_mean_0651 = r(mean)
scalar t9_diag_sd_0651 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0651) " mean=" %12.4f scalar(t9_diag_mean_0651) " sd=" %12.4f scalar(t9_diag_sd_0651)

display as text "  Diagnostic block 0652: t9_high_income m=3"
quietly summarize t9_high_income if _mi_m == 3
scalar t9_diag_n_0652 = r(N)
scalar t9_diag_mean_0652 = r(mean)
scalar t9_diag_sd_0652 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0652) " mean=" %12.4f scalar(t9_diag_mean_0652) " sd=" %12.4f scalar(t9_diag_sd_0652)

display as text "  Diagnostic block 0653: t9_high_stress m=4"
quietly summarize t9_high_stress if _mi_m == 4
scalar t9_diag_n_0653 = r(N)
scalar t9_diag_mean_0653 = r(mean)
scalar t9_diag_sd_0653 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0653) " mean=" %12.4f scalar(t9_diag_mean_0653) " sd=" %12.4f scalar(t9_diag_sd_0653)

display as text "  Diagnostic block 0654: t9_unhealthy m=5"
quietly summarize t9_unhealthy if _mi_m == 5
scalar t9_diag_n_0654 = r(N)
scalar t9_diag_mean_0654 = r(mean)
scalar t9_diag_sd_0654 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0654) " mean=" %12.4f scalar(t9_diag_mean_0654) " sd=" %12.4f scalar(t9_diag_sd_0654)

display as text "  Diagnostic block 0655: t9_educ_level m=0"
quietly summarize t9_educ_level if _mi_m == 0
scalar t9_diag_n_0655 = r(N)
scalar t9_diag_mean_0655 = r(mean)
scalar t9_diag_sd_0655 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0655) " mean=" %12.4f scalar(t9_diag_mean_0655) " sd=" %12.4f scalar(t9_diag_sd_0655)

display as text "  Diagnostic block 0656: t9_health_level m=1"
quietly summarize t9_health_level if _mi_m == 1
scalar t9_diag_n_0656 = r(N)
scalar t9_diag_mean_0656 = r(mean)
scalar t9_diag_sd_0656 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0656) " mean=" %12.4f scalar(t9_diag_mean_0656) " sd=" %12.4f scalar(t9_diag_sd_0656)

display as text "  Diagnostic block 0657: t9_job_sat m=2"
quietly summarize t9_job_sat if _mi_m == 2
scalar t9_diag_n_0657 = r(N)
scalar t9_diag_mean_0657 = r(mean)
scalar t9_diag_sd_0657 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0657) " mean=" %12.4f scalar(t9_diag_mean_0657) " sd=" %12.4f scalar(t9_diag_sd_0657)

display as text "  Diagnostic block 0658: t9_children m=3"
quietly summarize t9_children if _mi_m == 3
scalar t9_diag_n_0658 = r(N)
scalar t9_diag_mean_0658 = r(mean)
scalar t9_diag_sd_0658 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0658) " mean=" %12.4f scalar(t9_diag_mean_0658) " sd=" %12.4f scalar(t9_diag_sd_0658)

display as text "  Diagnostic block 0659: t9_doctor_visits m=4"
quietly summarize t9_doctor_visits if _mi_m == 4
scalar t9_diag_n_0659 = r(N)
scalar t9_diag_mean_0659 = r(mean)
scalar t9_diag_sd_0659 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0659) " mean=" %12.4f scalar(t9_diag_mean_0659) " sd=" %12.4f scalar(t9_diag_sd_0659)

display as text "  Diagnostic block 0660: t9_hosp_days m=5"
quietly summarize t9_hosp_days if _mi_m == 5
scalar t9_diag_n_0660 = r(N)
scalar t9_diag_mean_0660 = r(mean)
scalar t9_diag_sd_0660 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0660) " mean=" %12.4f scalar(t9_diag_mean_0660) " sd=" %12.4f scalar(t9_diag_sd_0660)

display as text "  Diagnostic block 0661: t9_log_income m=0"
quietly summarize t9_log_income if _mi_m == 0
scalar t9_diag_n_0661 = r(N)
scalar t9_diag_mean_0661 = r(mean)
scalar t9_diag_sd_0661 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0661) " mean=" %12.4f scalar(t9_diag_mean_0661) " sd=" %12.4f scalar(t9_diag_sd_0661)

display as text "  Diagnostic block 0662: t9_log_wage m=1"
quietly summarize t9_log_wage if _mi_m == 1
scalar t9_diag_n_0662 = r(N)
scalar t9_diag_mean_0662 = r(mean)
scalar t9_diag_sd_0662 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0662) " mean=" %12.4f scalar(t9_diag_mean_0662) " sd=" %12.4f scalar(t9_diag_sd_0662)

display as text "  Diagnostic block 0663: t9_income_per_hour m=2"
quietly summarize t9_income_per_hour if _mi_m == 2
scalar t9_diag_n_0663 = r(N)
scalar t9_diag_mean_0663 = r(mean)
scalar t9_diag_sd_0663 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0663) " mean=" %12.4f scalar(t9_diag_mean_0663) " sd=" %12.4f scalar(t9_diag_sd_0663)

display as text "  Diagnostic block 0664: t9_health_index m=3"
quietly summarize t9_health_index if _mi_m == 3
scalar t9_diag_n_0664 = r(N)
scalar t9_diag_mean_0664 = r(mean)
scalar t9_diag_sd_0664 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0664) " mean=" %12.4f scalar(t9_diag_mean_0664) " sd=" %12.4f scalar(t9_diag_sd_0664)

display as text "  Diagnostic block 0665: t9_dep_stress m=4"
quietly summarize t9_dep_stress if _mi_m == 4
scalar t9_diag_n_0665 = r(N)
scalar t9_diag_mean_0665 = r(mean)
scalar t9_diag_sd_0665 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0665) " mean=" %12.4f scalar(t9_diag_mean_0665) " sd=" %12.4f scalar(t9_diag_sd_0665)

display as text "  Diagnostic block 0666: t9_income m=5"
quietly summarize t9_income if _mi_m == 5
scalar t9_diag_n_0666 = r(N)
scalar t9_diag_mean_0666 = r(mean)
scalar t9_diag_sd_0666 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0666) " mean=" %12.4f scalar(t9_diag_mean_0666) " sd=" %12.4f scalar(t9_diag_sd_0666)

display as text "  Diagnostic block 0667: t9_wage m=0"
quietly summarize t9_wage if _mi_m == 0
scalar t9_diag_n_0667 = r(N)
scalar t9_diag_mean_0667 = r(mean)
scalar t9_diag_sd_0667 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0667) " mean=" %12.4f scalar(t9_diag_mean_0667) " sd=" %12.4f scalar(t9_diag_sd_0667)

display as text "  Diagnostic block 0668: t9_hours m=1"
quietly summarize t9_hours if _mi_m == 1
scalar t9_diag_n_0668 = r(N)
scalar t9_diag_mean_0668 = r(mean)
scalar t9_diag_sd_0668 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0668) " mean=" %12.4f scalar(t9_diag_mean_0668) " sd=" %12.4f scalar(t9_diag_sd_0668)

display as text "  Diagnostic block 0669: t9_wealth m=2"
quietly summarize t9_wealth if _mi_m == 2
scalar t9_diag_n_0669 = r(N)
scalar t9_diag_mean_0669 = r(mean)
scalar t9_diag_sd_0669 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0669) " mean=" %12.4f scalar(t9_diag_mean_0669) " sd=" %12.4f scalar(t9_diag_sd_0669)

display as text "  Diagnostic block 0670: t9_savings m=3"
quietly summarize t9_savings if _mi_m == 3
scalar t9_diag_n_0670 = r(N)
scalar t9_diag_mean_0670 = r(mean)
scalar t9_diag_sd_0670 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0670) " mean=" %12.4f scalar(t9_diag_mean_0670) " sd=" %12.4f scalar(t9_diag_sd_0670)

display as text "  Diagnostic block 0671: t9_expenditure m=4"
quietly summarize t9_expenditure if _mi_m == 4
scalar t9_diag_n_0671 = r(N)
scalar t9_diag_mean_0671 = r(mean)
scalar t9_diag_sd_0671 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0671) " mean=" %12.4f scalar(t9_diag_mean_0671) " sd=" %12.4f scalar(t9_diag_sd_0671)

display as text "  Diagnostic block 0672: t9_health_score m=5"
quietly summarize t9_health_score if _mi_m == 5
scalar t9_diag_n_0672 = r(N)
scalar t9_diag_mean_0672 = r(mean)
scalar t9_diag_sd_0672 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0672) " mean=" %12.4f scalar(t9_diag_mean_0672) " sd=" %12.4f scalar(t9_diag_sd_0672)

display as text "  Diagnostic block 0673: t9_bmi m=0"
quietly summarize t9_bmi if _mi_m == 0
scalar t9_diag_n_0673 = r(N)
scalar t9_diag_mean_0673 = r(mean)
scalar t9_diag_sd_0673 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0673) " mean=" %12.4f scalar(t9_diag_mean_0673) " sd=" %12.4f scalar(t9_diag_sd_0673)

display as text "  Diagnostic block 0674: t9_bp_sys m=1"
quietly summarize t9_bp_sys if _mi_m == 1
scalar t9_diag_n_0674 = r(N)
scalar t9_diag_mean_0674 = r(mean)
scalar t9_diag_sd_0674 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0674) " mean=" %12.4f scalar(t9_diag_mean_0674) " sd=" %12.4f scalar(t9_diag_sd_0674)

display as text "  Diagnostic block 0675: t9_bp_dia m=2"
quietly summarize t9_bp_dia if _mi_m == 2
scalar t9_diag_n_0675 = r(N)
scalar t9_diag_mean_0675 = r(mean)
scalar t9_diag_sd_0675 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0675) " mean=" %12.4f scalar(t9_diag_mean_0675) " sd=" %12.4f scalar(t9_diag_sd_0675)

display as text "  Diagnostic block 0676: t9_depression m=3"
quietly summarize t9_depression if _mi_m == 3
scalar t9_diag_n_0676 = r(N)
scalar t9_diag_mean_0676 = r(mean)
scalar t9_diag_sd_0676 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0676) " mean=" %12.4f scalar(t9_diag_mean_0676) " sd=" %12.4f scalar(t9_diag_sd_0676)

display as text "  Diagnostic block 0677: t9_stress m=4"
quietly summarize t9_stress if _mi_m == 4
scalar t9_diag_n_0677 = r(N)
scalar t9_diag_mean_0677 = r(mean)
scalar t9_diag_sd_0677 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0677) " mean=" %12.4f scalar(t9_diag_mean_0677) " sd=" %12.4f scalar(t9_diag_sd_0677)

display as text "  Diagnostic block 0678: t9_satisfaction m=5"
quietly summarize t9_satisfaction if _mi_m == 5
scalar t9_diag_n_0678 = r(N)
scalar t9_diag_mean_0678 = r(mean)
scalar t9_diag_sd_0678 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0678) " mean=" %12.4f scalar(t9_diag_mean_0678) " sd=" %12.4f scalar(t9_diag_sd_0678)

display as text "  Diagnostic block 0679: t9_sleep m=0"
quietly summarize t9_sleep if _mi_m == 0
scalar t9_diag_n_0679 = r(N)
scalar t9_diag_mean_0679 = r(mean)
scalar t9_diag_sd_0679 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0679) " mean=" %12.4f scalar(t9_diag_mean_0679) " sd=" %12.4f scalar(t9_diag_sd_0679)

display as text "  Diagnostic block 0680: t9_exercise m=1"
quietly summarize t9_exercise if _mi_m == 1
scalar t9_diag_n_0680 = r(N)
scalar t9_diag_mean_0680 = r(mean)
scalar t9_diag_sd_0680 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0680) " mean=" %12.4f scalar(t9_diag_mean_0680) " sd=" %12.4f scalar(t9_diag_sd_0680)

display as text "  Diagnostic block 0681: t9_employed m=2"
quietly summarize t9_employed if _mi_m == 2
scalar t9_diag_n_0681 = r(N)
scalar t9_diag_mean_0681 = r(mean)
scalar t9_diag_sd_0681 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0681) " mean=" %12.4f scalar(t9_diag_mean_0681) " sd=" %12.4f scalar(t9_diag_sd_0681)

display as text "  Diagnostic block 0682: t9_married m=3"
quietly summarize t9_married if _mi_m == 3
scalar t9_diag_n_0682 = r(N)
scalar t9_diag_mean_0682 = r(mean)
scalar t9_diag_sd_0682 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0682) " mean=" %12.4f scalar(t9_diag_mean_0682) " sd=" %12.4f scalar(t9_diag_sd_0682)

display as text "  Diagnostic block 0683: t9_urban m=4"
quietly summarize t9_urban if _mi_m == 4
scalar t9_diag_n_0683 = r(N)
scalar t9_diag_mean_0683 = r(mean)
scalar t9_diag_sd_0683 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0683) " mean=" %12.4f scalar(t9_diag_mean_0683) " sd=" %12.4f scalar(t9_diag_sd_0683)

display as text "  Diagnostic block 0684: t9_homeowner m=5"
quietly summarize t9_homeowner if _mi_m == 5
scalar t9_diag_n_0684 = r(N)
scalar t9_diag_mean_0684 = r(mean)
scalar t9_diag_sd_0684 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0684) " mean=" %12.4f scalar(t9_diag_mean_0684) " sd=" %12.4f scalar(t9_diag_sd_0684)

display as text "  Diagnostic block 0685: t9_insured m=0"
quietly summarize t9_insured if _mi_m == 0
scalar t9_diag_n_0685 = r(N)
scalar t9_diag_mean_0685 = r(mean)
scalar t9_diag_sd_0685 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0685) " mean=" %12.4f scalar(t9_diag_mean_0685) " sd=" %12.4f scalar(t9_diag_sd_0685)

display as text "  Diagnostic block 0686: t9_smoker m=1"
quietly summarize t9_smoker if _mi_m == 1
scalar t9_diag_n_0686 = r(N)
scalar t9_diag_mean_0686 = r(mean)
scalar t9_diag_sd_0686 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0686) " mean=" %12.4f scalar(t9_diag_mean_0686) " sd=" %12.4f scalar(t9_diag_sd_0686)

display as text "  Diagnostic block 0687: t9_high_income m=2"
quietly summarize t9_high_income if _mi_m == 2
scalar t9_diag_n_0687 = r(N)
scalar t9_diag_mean_0687 = r(mean)
scalar t9_diag_sd_0687 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0687) " mean=" %12.4f scalar(t9_diag_mean_0687) " sd=" %12.4f scalar(t9_diag_sd_0687)

display as text "  Diagnostic block 0688: t9_high_stress m=3"
quietly summarize t9_high_stress if _mi_m == 3
scalar t9_diag_n_0688 = r(N)
scalar t9_diag_mean_0688 = r(mean)
scalar t9_diag_sd_0688 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0688) " mean=" %12.4f scalar(t9_diag_mean_0688) " sd=" %12.4f scalar(t9_diag_sd_0688)

display as text "  Diagnostic block 0689: t9_unhealthy m=4"
quietly summarize t9_unhealthy if _mi_m == 4
scalar t9_diag_n_0689 = r(N)
scalar t9_diag_mean_0689 = r(mean)
scalar t9_diag_sd_0689 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0689) " mean=" %12.4f scalar(t9_diag_mean_0689) " sd=" %12.4f scalar(t9_diag_sd_0689)

display as text "  Diagnostic block 0690: t9_educ_level m=5"
quietly summarize t9_educ_level if _mi_m == 5
scalar t9_diag_n_0690 = r(N)
scalar t9_diag_mean_0690 = r(mean)
scalar t9_diag_sd_0690 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0690) " mean=" %12.4f scalar(t9_diag_mean_0690) " sd=" %12.4f scalar(t9_diag_sd_0690)

display as text "  Diagnostic block 0691: t9_health_level m=0"
quietly summarize t9_health_level if _mi_m == 0
scalar t9_diag_n_0691 = r(N)
scalar t9_diag_mean_0691 = r(mean)
scalar t9_diag_sd_0691 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0691) " mean=" %12.4f scalar(t9_diag_mean_0691) " sd=" %12.4f scalar(t9_diag_sd_0691)

display as text "  Diagnostic block 0692: t9_job_sat m=1"
quietly summarize t9_job_sat if _mi_m == 1
scalar t9_diag_n_0692 = r(N)
scalar t9_diag_mean_0692 = r(mean)
scalar t9_diag_sd_0692 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0692) " mean=" %12.4f scalar(t9_diag_mean_0692) " sd=" %12.4f scalar(t9_diag_sd_0692)

display as text "  Diagnostic block 0693: t9_children m=2"
quietly summarize t9_children if _mi_m == 2
scalar t9_diag_n_0693 = r(N)
scalar t9_diag_mean_0693 = r(mean)
scalar t9_diag_sd_0693 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0693) " mean=" %12.4f scalar(t9_diag_mean_0693) " sd=" %12.4f scalar(t9_diag_sd_0693)

display as text "  Diagnostic block 0694: t9_doctor_visits m=3"
quietly summarize t9_doctor_visits if _mi_m == 3
scalar t9_diag_n_0694 = r(N)
scalar t9_diag_mean_0694 = r(mean)
scalar t9_diag_sd_0694 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0694) " mean=" %12.4f scalar(t9_diag_mean_0694) " sd=" %12.4f scalar(t9_diag_sd_0694)

display as text "  Diagnostic block 0695: t9_hosp_days m=4"
quietly summarize t9_hosp_days if _mi_m == 4
scalar t9_diag_n_0695 = r(N)
scalar t9_diag_mean_0695 = r(mean)
scalar t9_diag_sd_0695 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0695) " mean=" %12.4f scalar(t9_diag_mean_0695) " sd=" %12.4f scalar(t9_diag_sd_0695)

display as text "  Diagnostic block 0696: t9_log_income m=5"
quietly summarize t9_log_income if _mi_m == 5
scalar t9_diag_n_0696 = r(N)
scalar t9_diag_mean_0696 = r(mean)
scalar t9_diag_sd_0696 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0696) " mean=" %12.4f scalar(t9_diag_mean_0696) " sd=" %12.4f scalar(t9_diag_sd_0696)

display as text "  Diagnostic block 0697: t9_log_wage m=0"
quietly summarize t9_log_wage if _mi_m == 0
scalar t9_diag_n_0697 = r(N)
scalar t9_diag_mean_0697 = r(mean)
scalar t9_diag_sd_0697 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0697) " mean=" %12.4f scalar(t9_diag_mean_0697) " sd=" %12.4f scalar(t9_diag_sd_0697)

display as text "  Diagnostic block 0698: t9_income_per_hour m=1"
quietly summarize t9_income_per_hour if _mi_m == 1
scalar t9_diag_n_0698 = r(N)
scalar t9_diag_mean_0698 = r(mean)
scalar t9_diag_sd_0698 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0698) " mean=" %12.4f scalar(t9_diag_mean_0698) " sd=" %12.4f scalar(t9_diag_sd_0698)

display as text "  Diagnostic block 0699: t9_health_index m=2"
quietly summarize t9_health_index if _mi_m == 2
scalar t9_diag_n_0699 = r(N)
scalar t9_diag_mean_0699 = r(mean)
scalar t9_diag_sd_0699 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0699) " mean=" %12.4f scalar(t9_diag_mean_0699) " sd=" %12.4f scalar(t9_diag_sd_0699)

display as text "  Diagnostic block 0700: t9_dep_stress m=3"
quietly summarize t9_dep_stress if _mi_m == 3
scalar t9_diag_n_0700 = r(N)
scalar t9_diag_mean_0700 = r(mean)
scalar t9_diag_sd_0700 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0700) " mean=" %12.4f scalar(t9_diag_mean_0700) " sd=" %12.4f scalar(t9_diag_sd_0700)

display as text "  Diagnostic block 0701: t9_income m=4"
quietly summarize t9_income if _mi_m == 4
scalar t9_diag_n_0701 = r(N)
scalar t9_diag_mean_0701 = r(mean)
scalar t9_diag_sd_0701 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0701) " mean=" %12.4f scalar(t9_diag_mean_0701) " sd=" %12.4f scalar(t9_diag_sd_0701)

display as text "  Diagnostic block 0702: t9_wage m=5"
quietly summarize t9_wage if _mi_m == 5
scalar t9_diag_n_0702 = r(N)
scalar t9_diag_mean_0702 = r(mean)
scalar t9_diag_sd_0702 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0702) " mean=" %12.4f scalar(t9_diag_mean_0702) " sd=" %12.4f scalar(t9_diag_sd_0702)

display as text "  Diagnostic block 0703: t9_hours m=0"
quietly summarize t9_hours if _mi_m == 0
scalar t9_diag_n_0703 = r(N)
scalar t9_diag_mean_0703 = r(mean)
scalar t9_diag_sd_0703 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0703) " mean=" %12.4f scalar(t9_diag_mean_0703) " sd=" %12.4f scalar(t9_diag_sd_0703)

display as text "  Diagnostic block 0704: t9_wealth m=1"
quietly summarize t9_wealth if _mi_m == 1
scalar t9_diag_n_0704 = r(N)
scalar t9_diag_mean_0704 = r(mean)
scalar t9_diag_sd_0704 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0704) " mean=" %12.4f scalar(t9_diag_mean_0704) " sd=" %12.4f scalar(t9_diag_sd_0704)

display as text "  Diagnostic block 0705: t9_savings m=2"
quietly summarize t9_savings if _mi_m == 2
scalar t9_diag_n_0705 = r(N)
scalar t9_diag_mean_0705 = r(mean)
scalar t9_diag_sd_0705 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0705) " mean=" %12.4f scalar(t9_diag_mean_0705) " sd=" %12.4f scalar(t9_diag_sd_0705)

display as text "  Diagnostic block 0706: t9_expenditure m=3"
quietly summarize t9_expenditure if _mi_m == 3
scalar t9_diag_n_0706 = r(N)
scalar t9_diag_mean_0706 = r(mean)
scalar t9_diag_sd_0706 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0706) " mean=" %12.4f scalar(t9_diag_mean_0706) " sd=" %12.4f scalar(t9_diag_sd_0706)

display as text "  Diagnostic block 0707: t9_health_score m=4"
quietly summarize t9_health_score if _mi_m == 4
scalar t9_diag_n_0707 = r(N)
scalar t9_diag_mean_0707 = r(mean)
scalar t9_diag_sd_0707 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0707) " mean=" %12.4f scalar(t9_diag_mean_0707) " sd=" %12.4f scalar(t9_diag_sd_0707)

display as text "  Diagnostic block 0708: t9_bmi m=5"
quietly summarize t9_bmi if _mi_m == 5
scalar t9_diag_n_0708 = r(N)
scalar t9_diag_mean_0708 = r(mean)
scalar t9_diag_sd_0708 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0708) " mean=" %12.4f scalar(t9_diag_mean_0708) " sd=" %12.4f scalar(t9_diag_sd_0708)

display as text "  Diagnostic block 0709: t9_bp_sys m=0"
quietly summarize t9_bp_sys if _mi_m == 0
scalar t9_diag_n_0709 = r(N)
scalar t9_diag_mean_0709 = r(mean)
scalar t9_diag_sd_0709 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0709) " mean=" %12.4f scalar(t9_diag_mean_0709) " sd=" %12.4f scalar(t9_diag_sd_0709)

display as text "  Diagnostic block 0710: t9_bp_dia m=1"
quietly summarize t9_bp_dia if _mi_m == 1
scalar t9_diag_n_0710 = r(N)
scalar t9_diag_mean_0710 = r(mean)
scalar t9_diag_sd_0710 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0710) " mean=" %12.4f scalar(t9_diag_mean_0710) " sd=" %12.4f scalar(t9_diag_sd_0710)

display as text "  Diagnostic block 0711: t9_depression m=2"
quietly summarize t9_depression if _mi_m == 2
scalar t9_diag_n_0711 = r(N)
scalar t9_diag_mean_0711 = r(mean)
scalar t9_diag_sd_0711 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0711) " mean=" %12.4f scalar(t9_diag_mean_0711) " sd=" %12.4f scalar(t9_diag_sd_0711)

display as text "  Diagnostic block 0712: t9_stress m=3"
quietly summarize t9_stress if _mi_m == 3
scalar t9_diag_n_0712 = r(N)
scalar t9_diag_mean_0712 = r(mean)
scalar t9_diag_sd_0712 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0712) " mean=" %12.4f scalar(t9_diag_mean_0712) " sd=" %12.4f scalar(t9_diag_sd_0712)

display as text "  Diagnostic block 0713: t9_satisfaction m=4"
quietly summarize t9_satisfaction if _mi_m == 4
scalar t9_diag_n_0713 = r(N)
scalar t9_diag_mean_0713 = r(mean)
scalar t9_diag_sd_0713 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0713) " mean=" %12.4f scalar(t9_diag_mean_0713) " sd=" %12.4f scalar(t9_diag_sd_0713)

display as text "  Diagnostic block 0714: t9_sleep m=5"
quietly summarize t9_sleep if _mi_m == 5
scalar t9_diag_n_0714 = r(N)
scalar t9_diag_mean_0714 = r(mean)
scalar t9_diag_sd_0714 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0714) " mean=" %12.4f scalar(t9_diag_mean_0714) " sd=" %12.4f scalar(t9_diag_sd_0714)

display as text "  Diagnostic block 0715: t9_exercise m=0"
quietly summarize t9_exercise if _mi_m == 0
scalar t9_diag_n_0715 = r(N)
scalar t9_diag_mean_0715 = r(mean)
scalar t9_diag_sd_0715 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0715) " mean=" %12.4f scalar(t9_diag_mean_0715) " sd=" %12.4f scalar(t9_diag_sd_0715)

display as text "  Diagnostic block 0716: t9_employed m=1"
quietly summarize t9_employed if _mi_m == 1
scalar t9_diag_n_0716 = r(N)
scalar t9_diag_mean_0716 = r(mean)
scalar t9_diag_sd_0716 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0716) " mean=" %12.4f scalar(t9_diag_mean_0716) " sd=" %12.4f scalar(t9_diag_sd_0716)

display as text "  Diagnostic block 0717: t9_married m=2"
quietly summarize t9_married if _mi_m == 2
scalar t9_diag_n_0717 = r(N)
scalar t9_diag_mean_0717 = r(mean)
scalar t9_diag_sd_0717 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0717) " mean=" %12.4f scalar(t9_diag_mean_0717) " sd=" %12.4f scalar(t9_diag_sd_0717)

display as text "  Diagnostic block 0718: t9_urban m=3"
quietly summarize t9_urban if _mi_m == 3
scalar t9_diag_n_0718 = r(N)
scalar t9_diag_mean_0718 = r(mean)
scalar t9_diag_sd_0718 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0718) " mean=" %12.4f scalar(t9_diag_mean_0718) " sd=" %12.4f scalar(t9_diag_sd_0718)

display as text "  Diagnostic block 0719: t9_homeowner m=4"
quietly summarize t9_homeowner if _mi_m == 4
scalar t9_diag_n_0719 = r(N)
scalar t9_diag_mean_0719 = r(mean)
scalar t9_diag_sd_0719 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0719) " mean=" %12.4f scalar(t9_diag_mean_0719) " sd=" %12.4f scalar(t9_diag_sd_0719)

display as text "  Diagnostic block 0720: t9_insured m=5"
quietly summarize t9_insured if _mi_m == 5
scalar t9_diag_n_0720 = r(N)
scalar t9_diag_mean_0720 = r(mean)
scalar t9_diag_sd_0720 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0720) " mean=" %12.4f scalar(t9_diag_mean_0720) " sd=" %12.4f scalar(t9_diag_sd_0720)

display as text "  Diagnostic block 0721: t9_smoker m=0"
quietly summarize t9_smoker if _mi_m == 0
scalar t9_diag_n_0721 = r(N)
scalar t9_diag_mean_0721 = r(mean)
scalar t9_diag_sd_0721 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0721) " mean=" %12.4f scalar(t9_diag_mean_0721) " sd=" %12.4f scalar(t9_diag_sd_0721)

display as text "  Diagnostic block 0722: t9_high_income m=1"
quietly summarize t9_high_income if _mi_m == 1
scalar t9_diag_n_0722 = r(N)
scalar t9_diag_mean_0722 = r(mean)
scalar t9_diag_sd_0722 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0722) " mean=" %12.4f scalar(t9_diag_mean_0722) " sd=" %12.4f scalar(t9_diag_sd_0722)

display as text "  Diagnostic block 0723: t9_high_stress m=2"
quietly summarize t9_high_stress if _mi_m == 2
scalar t9_diag_n_0723 = r(N)
scalar t9_diag_mean_0723 = r(mean)
scalar t9_diag_sd_0723 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0723) " mean=" %12.4f scalar(t9_diag_mean_0723) " sd=" %12.4f scalar(t9_diag_sd_0723)

display as text "  Diagnostic block 0724: t9_unhealthy m=3"
quietly summarize t9_unhealthy if _mi_m == 3
scalar t9_diag_n_0724 = r(N)
scalar t9_diag_mean_0724 = r(mean)
scalar t9_diag_sd_0724 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0724) " mean=" %12.4f scalar(t9_diag_mean_0724) " sd=" %12.4f scalar(t9_diag_sd_0724)

display as text "  Diagnostic block 0725: t9_educ_level m=4"
quietly summarize t9_educ_level if _mi_m == 4
scalar t9_diag_n_0725 = r(N)
scalar t9_diag_mean_0725 = r(mean)
scalar t9_diag_sd_0725 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0725) " mean=" %12.4f scalar(t9_diag_mean_0725) " sd=" %12.4f scalar(t9_diag_sd_0725)

display as text "  Diagnostic block 0726: t9_health_level m=5"
quietly summarize t9_health_level if _mi_m == 5
scalar t9_diag_n_0726 = r(N)
scalar t9_diag_mean_0726 = r(mean)
scalar t9_diag_sd_0726 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0726) " mean=" %12.4f scalar(t9_diag_mean_0726) " sd=" %12.4f scalar(t9_diag_sd_0726)

display as text "  Diagnostic block 0727: t9_job_sat m=0"
quietly summarize t9_job_sat if _mi_m == 0
scalar t9_diag_n_0727 = r(N)
scalar t9_diag_mean_0727 = r(mean)
scalar t9_diag_sd_0727 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0727) " mean=" %12.4f scalar(t9_diag_mean_0727) " sd=" %12.4f scalar(t9_diag_sd_0727)

display as text "  Diagnostic block 0728: t9_children m=1"
quietly summarize t9_children if _mi_m == 1
scalar t9_diag_n_0728 = r(N)
scalar t9_diag_mean_0728 = r(mean)
scalar t9_diag_sd_0728 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0728) " mean=" %12.4f scalar(t9_diag_mean_0728) " sd=" %12.4f scalar(t9_diag_sd_0728)

display as text "  Diagnostic block 0729: t9_doctor_visits m=2"
quietly summarize t9_doctor_visits if _mi_m == 2
scalar t9_diag_n_0729 = r(N)
scalar t9_diag_mean_0729 = r(mean)
scalar t9_diag_sd_0729 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0729) " mean=" %12.4f scalar(t9_diag_mean_0729) " sd=" %12.4f scalar(t9_diag_sd_0729)

display as text "  Diagnostic block 0730: t9_hosp_days m=3"
quietly summarize t9_hosp_days if _mi_m == 3
scalar t9_diag_n_0730 = r(N)
scalar t9_diag_mean_0730 = r(mean)
scalar t9_diag_sd_0730 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0730) " mean=" %12.4f scalar(t9_diag_mean_0730) " sd=" %12.4f scalar(t9_diag_sd_0730)

display as text "  Diagnostic block 0731: t9_log_income m=4"
quietly summarize t9_log_income if _mi_m == 4
scalar t9_diag_n_0731 = r(N)
scalar t9_diag_mean_0731 = r(mean)
scalar t9_diag_sd_0731 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0731) " mean=" %12.4f scalar(t9_diag_mean_0731) " sd=" %12.4f scalar(t9_diag_sd_0731)

display as text "  Diagnostic block 0732: t9_log_wage m=5"
quietly summarize t9_log_wage if _mi_m == 5
scalar t9_diag_n_0732 = r(N)
scalar t9_diag_mean_0732 = r(mean)
scalar t9_diag_sd_0732 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0732) " mean=" %12.4f scalar(t9_diag_mean_0732) " sd=" %12.4f scalar(t9_diag_sd_0732)

display as text "  Diagnostic block 0733: t9_income_per_hour m=0"
quietly summarize t9_income_per_hour if _mi_m == 0
scalar t9_diag_n_0733 = r(N)
scalar t9_diag_mean_0733 = r(mean)
scalar t9_diag_sd_0733 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0733) " mean=" %12.4f scalar(t9_diag_mean_0733) " sd=" %12.4f scalar(t9_diag_sd_0733)

display as text "  Diagnostic block 0734: t9_health_index m=1"
quietly summarize t9_health_index if _mi_m == 1
scalar t9_diag_n_0734 = r(N)
scalar t9_diag_mean_0734 = r(mean)
scalar t9_diag_sd_0734 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0734) " mean=" %12.4f scalar(t9_diag_mean_0734) " sd=" %12.4f scalar(t9_diag_sd_0734)

display as text "  Diagnostic block 0735: t9_dep_stress m=2"
quietly summarize t9_dep_stress if _mi_m == 2
scalar t9_diag_n_0735 = r(N)
scalar t9_diag_mean_0735 = r(mean)
scalar t9_diag_sd_0735 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0735) " mean=" %12.4f scalar(t9_diag_mean_0735) " sd=" %12.4f scalar(t9_diag_sd_0735)

display as text "  Diagnostic block 0736: t9_income m=3"
quietly summarize t9_income if _mi_m == 3
scalar t9_diag_n_0736 = r(N)
scalar t9_diag_mean_0736 = r(mean)
scalar t9_diag_sd_0736 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0736) " mean=" %12.4f scalar(t9_diag_mean_0736) " sd=" %12.4f scalar(t9_diag_sd_0736)

display as text "  Diagnostic block 0737: t9_wage m=4"
quietly summarize t9_wage if _mi_m == 4
scalar t9_diag_n_0737 = r(N)
scalar t9_diag_mean_0737 = r(mean)
scalar t9_diag_sd_0737 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0737) " mean=" %12.4f scalar(t9_diag_mean_0737) " sd=" %12.4f scalar(t9_diag_sd_0737)

display as text "  Diagnostic block 0738: t9_hours m=5"
quietly summarize t9_hours if _mi_m == 5
scalar t9_diag_n_0738 = r(N)
scalar t9_diag_mean_0738 = r(mean)
scalar t9_diag_sd_0738 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0738) " mean=" %12.4f scalar(t9_diag_mean_0738) " sd=" %12.4f scalar(t9_diag_sd_0738)

display as text "  Diagnostic block 0739: t9_wealth m=0"
quietly summarize t9_wealth if _mi_m == 0
scalar t9_diag_n_0739 = r(N)
scalar t9_diag_mean_0739 = r(mean)
scalar t9_diag_sd_0739 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0739) " mean=" %12.4f scalar(t9_diag_mean_0739) " sd=" %12.4f scalar(t9_diag_sd_0739)

display as text "  Diagnostic block 0740: t9_savings m=1"
quietly summarize t9_savings if _mi_m == 1
scalar t9_diag_n_0740 = r(N)
scalar t9_diag_mean_0740 = r(mean)
scalar t9_diag_sd_0740 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0740) " mean=" %12.4f scalar(t9_diag_mean_0740) " sd=" %12.4f scalar(t9_diag_sd_0740)

display as text "  Diagnostic block 0741: t9_expenditure m=2"
quietly summarize t9_expenditure if _mi_m == 2
scalar t9_diag_n_0741 = r(N)
scalar t9_diag_mean_0741 = r(mean)
scalar t9_diag_sd_0741 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0741) " mean=" %12.4f scalar(t9_diag_mean_0741) " sd=" %12.4f scalar(t9_diag_sd_0741)

display as text "  Diagnostic block 0742: t9_health_score m=3"
quietly summarize t9_health_score if _mi_m == 3
scalar t9_diag_n_0742 = r(N)
scalar t9_diag_mean_0742 = r(mean)
scalar t9_diag_sd_0742 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0742) " mean=" %12.4f scalar(t9_diag_mean_0742) " sd=" %12.4f scalar(t9_diag_sd_0742)

display as text "  Diagnostic block 0743: t9_bmi m=4"
quietly summarize t9_bmi if _mi_m == 4
scalar t9_diag_n_0743 = r(N)
scalar t9_diag_mean_0743 = r(mean)
scalar t9_diag_sd_0743 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0743) " mean=" %12.4f scalar(t9_diag_mean_0743) " sd=" %12.4f scalar(t9_diag_sd_0743)

display as text "  Diagnostic block 0744: t9_bp_sys m=5"
quietly summarize t9_bp_sys if _mi_m == 5
scalar t9_diag_n_0744 = r(N)
scalar t9_diag_mean_0744 = r(mean)
scalar t9_diag_sd_0744 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0744) " mean=" %12.4f scalar(t9_diag_mean_0744) " sd=" %12.4f scalar(t9_diag_sd_0744)

display as text "  Diagnostic block 0745: t9_bp_dia m=0"
quietly summarize t9_bp_dia if _mi_m == 0
scalar t9_diag_n_0745 = r(N)
scalar t9_diag_mean_0745 = r(mean)
scalar t9_diag_sd_0745 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0745) " mean=" %12.4f scalar(t9_diag_mean_0745) " sd=" %12.4f scalar(t9_diag_sd_0745)

display as text "  Diagnostic block 0746: t9_depression m=1"
quietly summarize t9_depression if _mi_m == 1
scalar t9_diag_n_0746 = r(N)
scalar t9_diag_mean_0746 = r(mean)
scalar t9_diag_sd_0746 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0746) " mean=" %12.4f scalar(t9_diag_mean_0746) " sd=" %12.4f scalar(t9_diag_sd_0746)

display as text "  Diagnostic block 0747: t9_stress m=2"
quietly summarize t9_stress if _mi_m == 2
scalar t9_diag_n_0747 = r(N)
scalar t9_diag_mean_0747 = r(mean)
scalar t9_diag_sd_0747 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0747) " mean=" %12.4f scalar(t9_diag_mean_0747) " sd=" %12.4f scalar(t9_diag_sd_0747)

display as text "  Diagnostic block 0748: t9_satisfaction m=3"
quietly summarize t9_satisfaction if _mi_m == 3
scalar t9_diag_n_0748 = r(N)
scalar t9_diag_mean_0748 = r(mean)
scalar t9_diag_sd_0748 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0748) " mean=" %12.4f scalar(t9_diag_mean_0748) " sd=" %12.4f scalar(t9_diag_sd_0748)

display as text "  Diagnostic block 0749: t9_sleep m=4"
quietly summarize t9_sleep if _mi_m == 4
scalar t9_diag_n_0749 = r(N)
scalar t9_diag_mean_0749 = r(mean)
scalar t9_diag_sd_0749 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0749) " mean=" %12.4f scalar(t9_diag_mean_0749) " sd=" %12.4f scalar(t9_diag_sd_0749)

display as text "  Diagnostic block 0750: t9_exercise m=5"
quietly summarize t9_exercise if _mi_m == 5
scalar t9_diag_n_0750 = r(N)
scalar t9_diag_mean_0750 = r(mean)
scalar t9_diag_sd_0750 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0750) " mean=" %12.4f scalar(t9_diag_mean_0750) " sd=" %12.4f scalar(t9_diag_sd_0750)

display as text "  Diagnostic block 0751: t9_employed m=0"
quietly summarize t9_employed if _mi_m == 0
scalar t9_diag_n_0751 = r(N)
scalar t9_diag_mean_0751 = r(mean)
scalar t9_diag_sd_0751 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0751) " mean=" %12.4f scalar(t9_diag_mean_0751) " sd=" %12.4f scalar(t9_diag_sd_0751)

display as text "  Diagnostic block 0752: t9_married m=1"
quietly summarize t9_married if _mi_m == 1
scalar t9_diag_n_0752 = r(N)
scalar t9_diag_mean_0752 = r(mean)
scalar t9_diag_sd_0752 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0752) " mean=" %12.4f scalar(t9_diag_mean_0752) " sd=" %12.4f scalar(t9_diag_sd_0752)

display as text "  Diagnostic block 0753: t9_urban m=2"
quietly summarize t9_urban if _mi_m == 2
scalar t9_diag_n_0753 = r(N)
scalar t9_diag_mean_0753 = r(mean)
scalar t9_diag_sd_0753 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0753) " mean=" %12.4f scalar(t9_diag_mean_0753) " sd=" %12.4f scalar(t9_diag_sd_0753)

display as text "  Diagnostic block 0754: t9_homeowner m=3"
quietly summarize t9_homeowner if _mi_m == 3
scalar t9_diag_n_0754 = r(N)
scalar t9_diag_mean_0754 = r(mean)
scalar t9_diag_sd_0754 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0754) " mean=" %12.4f scalar(t9_diag_mean_0754) " sd=" %12.4f scalar(t9_diag_sd_0754)

display as text "  Diagnostic block 0755: t9_insured m=4"
quietly summarize t9_insured if _mi_m == 4
scalar t9_diag_n_0755 = r(N)
scalar t9_diag_mean_0755 = r(mean)
scalar t9_diag_sd_0755 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0755) " mean=" %12.4f scalar(t9_diag_mean_0755) " sd=" %12.4f scalar(t9_diag_sd_0755)

display as text "  Diagnostic block 0756: t9_smoker m=5"
quietly summarize t9_smoker if _mi_m == 5
scalar t9_diag_n_0756 = r(N)
scalar t9_diag_mean_0756 = r(mean)
scalar t9_diag_sd_0756 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0756) " mean=" %12.4f scalar(t9_diag_mean_0756) " sd=" %12.4f scalar(t9_diag_sd_0756)

display as text "  Diagnostic block 0757: t9_high_income m=0"
quietly summarize t9_high_income if _mi_m == 0
scalar t9_diag_n_0757 = r(N)
scalar t9_diag_mean_0757 = r(mean)
scalar t9_diag_sd_0757 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0757) " mean=" %12.4f scalar(t9_diag_mean_0757) " sd=" %12.4f scalar(t9_diag_sd_0757)

display as text "  Diagnostic block 0758: t9_high_stress m=1"
quietly summarize t9_high_stress if _mi_m == 1
scalar t9_diag_n_0758 = r(N)
scalar t9_diag_mean_0758 = r(mean)
scalar t9_diag_sd_0758 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0758) " mean=" %12.4f scalar(t9_diag_mean_0758) " sd=" %12.4f scalar(t9_diag_sd_0758)

display as text "  Diagnostic block 0759: t9_unhealthy m=2"
quietly summarize t9_unhealthy if _mi_m == 2
scalar t9_diag_n_0759 = r(N)
scalar t9_diag_mean_0759 = r(mean)
scalar t9_diag_sd_0759 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0759) " mean=" %12.4f scalar(t9_diag_mean_0759) " sd=" %12.4f scalar(t9_diag_sd_0759)

display as text "  Diagnostic block 0760: t9_educ_level m=3"
quietly summarize t9_educ_level if _mi_m == 3
scalar t9_diag_n_0760 = r(N)
scalar t9_diag_mean_0760 = r(mean)
scalar t9_diag_sd_0760 = r(sd)
display as text "    N=" %9.0f scalar(t9_diag_n_0760) " mean=" %12.4f scalar(t9_diag_mean_0760) " sd=" %12.4f scalar(t9_diag_sd_0760)

display as result "<<< DONE Section 17: generated diagnostics"
// #endregion Section 17

// #region Section 18: generated sensitivity models
display as text ">>> START Section 18: generated sensitivity models"
display as text "  Sensitivity model 001: t9_income"
mi estimate, post: regress t9_income t9_age t9_female t9_educ
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 001 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 002: t9_wage"
mi estimate, post: regress t9_wage t9_age t9_female t9_educ t9_exper
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 002 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 003: t9_hours"
mi estimate, post: regress t9_hours t9_age t9_female t9_educ t9_exper t9_treat
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 003 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 004: t9_wealth"
mi estimate, post: regress t9_wealth t9_age t9_female t9_educ t9_exper t9_treat i.t9_region
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 004 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 005: t9_savings"
mi estimate, post: regress t9_savings t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 005 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 006: t9_expenditure"
mi estimate, post: regress t9_expenditure t9_age t9_female t9_educ
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 006 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 007: t9_health_score"
mi estimate, post: regress t9_health_score t9_age t9_female t9_educ t9_exper
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 007 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 008: t9_bmi"
mi estimate, post: regress t9_bmi t9_age t9_female t9_educ t9_exper t9_treat
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 008 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 009: t9_bp_sys"
mi estimate, post: regress t9_bp_sys t9_age t9_female t9_educ t9_exper t9_treat i.t9_region
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 009 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 010: t9_bp_dia"
mi estimate, post: regress t9_bp_dia t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 010 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 011: t9_depression"
mi estimate, post: regress t9_depression t9_age t9_female t9_educ
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 011 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 012: t9_stress"
mi estimate, post: regress t9_stress t9_age t9_female t9_educ t9_exper
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 012 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 013: t9_satisfaction"
mi estimate, post: regress t9_satisfaction t9_age t9_female t9_educ t9_exper t9_treat
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 013 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 014: t9_sleep"
mi estimate, post: regress t9_sleep t9_age t9_female t9_educ t9_exper t9_treat i.t9_region
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 014 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 015: t9_exercise"
mi estimate, post: regress t9_exercise t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 015 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 016: t9_income"
mi estimate, post: regress t9_income t9_age t9_female t9_educ
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 016 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 017: t9_wage"
mi estimate, post: regress t9_wage t9_age t9_female t9_educ t9_exper
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 017 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 018: t9_hours"
mi estimate, post: regress t9_hours t9_age t9_female t9_educ t9_exper t9_treat
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 018 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 019: t9_wealth"
mi estimate, post: regress t9_wealth t9_age t9_female t9_educ t9_exper t9_treat i.t9_region
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 019 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 020: t9_savings"
mi estimate, post: regress t9_savings t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 020 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 021: t9_expenditure"
mi estimate, post: regress t9_expenditure t9_age t9_female t9_educ
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 021 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 022: t9_health_score"
mi estimate, post: regress t9_health_score t9_age t9_female t9_educ t9_exper
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 022 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 023: t9_bmi"
mi estimate, post: regress t9_bmi t9_age t9_female t9_educ t9_exper t9_treat
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 023 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 024: t9_bp_sys"
mi estimate, post: regress t9_bp_sys t9_age t9_female t9_educ t9_exper t9_treat i.t9_region
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 024 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 025: t9_bp_dia"
mi estimate, post: regress t9_bp_dia t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 025 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 026: t9_depression"
mi estimate, post: regress t9_depression t9_age t9_female t9_educ
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 026 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 027: t9_stress"
mi estimate, post: regress t9_stress t9_age t9_female t9_educ t9_exper
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 027 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 028: t9_satisfaction"
mi estimate, post: regress t9_satisfaction t9_age t9_female t9_educ t9_exper t9_treat
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 028 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 029: t9_sleep"
mi estimate, post: regress t9_sleep t9_age t9_female t9_educ t9_exper t9_treat i.t9_region
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 029 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 030: t9_exercise"
mi estimate, post: regress t9_exercise t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 030 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 031: t9_income"
mi estimate, post: regress t9_income t9_age t9_female t9_educ
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 031 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 032: t9_wage"
mi estimate, post: regress t9_wage t9_age t9_female t9_educ t9_exper
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 032 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 033: t9_hours"
mi estimate, post: regress t9_hours t9_age t9_female t9_educ t9_exper t9_treat
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 033 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 034: t9_wealth"
mi estimate, post: regress t9_wealth t9_age t9_female t9_educ t9_exper t9_treat i.t9_region
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 034 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 035: t9_savings"
mi estimate, post: regress t9_savings t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 035 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 036: t9_expenditure"
mi estimate, post: regress t9_expenditure t9_age t9_female t9_educ
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 036 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 037: t9_health_score"
mi estimate, post: regress t9_health_score t9_age t9_female t9_educ t9_exper
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 037 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 038: t9_bmi"
mi estimate, post: regress t9_bmi t9_age t9_female t9_educ t9_exper t9_treat
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 038 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 039: t9_bp_sys"
mi estimate, post: regress t9_bp_sys t9_age t9_female t9_educ t9_exper t9_treat i.t9_region
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 039 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 040: t9_bp_dia"
mi estimate, post: regress t9_bp_dia t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 040 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 041: t9_depression"
mi estimate, post: regress t9_depression t9_age t9_female t9_educ
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 041 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 042: t9_stress"
mi estimate, post: regress t9_stress t9_age t9_female t9_educ t9_exper
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 042 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 043: t9_satisfaction"
mi estimate, post: regress t9_satisfaction t9_age t9_female t9_educ t9_exper t9_treat
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 043 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 044: t9_sleep"
mi estimate, post: regress t9_sleep t9_age t9_female t9_educ t9_exper t9_treat i.t9_region
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 044 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 045: t9_exercise"
mi estimate, post: regress t9_exercise t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 045 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 046: t9_income"
mi estimate, post: regress t9_income t9_age t9_female t9_educ
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 046 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 047: t9_wage"
mi estimate, post: regress t9_wage t9_age t9_female t9_educ t9_exper
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 047 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 048: t9_hours"
mi estimate, post: regress t9_hours t9_age t9_female t9_educ t9_exper t9_treat
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 048 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 049: t9_wealth"
mi estimate, post: regress t9_wealth t9_age t9_female t9_educ t9_exper t9_treat i.t9_region
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 049 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 050: t9_savings"
mi estimate, post: regress t9_savings t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 050 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 051: t9_expenditure"
mi estimate, post: regress t9_expenditure t9_age t9_female t9_educ
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 051 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 052: t9_health_score"
mi estimate, post: regress t9_health_score t9_age t9_female t9_educ t9_exper
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 052 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 053: t9_bmi"
mi estimate, post: regress t9_bmi t9_age t9_female t9_educ t9_exper t9_treat
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 053 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 054: t9_bp_sys"
mi estimate, post: regress t9_bp_sys t9_age t9_female t9_educ t9_exper t9_treat i.t9_region
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 054 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 055: t9_bp_dia"
mi estimate, post: regress t9_bp_dia t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 055 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 056: t9_depression"
mi estimate, post: regress t9_depression t9_age t9_female t9_educ
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 056 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 057: t9_stress"
mi estimate, post: regress t9_stress t9_age t9_female t9_educ t9_exper
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 057 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 058: t9_satisfaction"
mi estimate, post: regress t9_satisfaction t9_age t9_female t9_educ t9_exper t9_treat
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 058 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 059: t9_sleep"
mi estimate, post: regress t9_sleep t9_age t9_female t9_educ t9_exper t9_treat i.t9_region
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 059 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 060: t9_exercise"
mi estimate, post: regress t9_exercise t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 060 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 061: t9_income"
mi estimate, post: regress t9_income t9_age t9_female t9_educ
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 061 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 062: t9_wage"
mi estimate, post: regress t9_wage t9_age t9_female t9_educ t9_exper
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 062 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 063: t9_hours"
mi estimate, post: regress t9_hours t9_age t9_female t9_educ t9_exper t9_treat
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 063 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 064: t9_wealth"
mi estimate, post: regress t9_wealth t9_age t9_female t9_educ t9_exper t9_treat i.t9_region
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 064 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 065: t9_savings"
mi estimate, post: regress t9_savings t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 065 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 066: t9_expenditure"
mi estimate, post: regress t9_expenditure t9_age t9_female t9_educ
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 066 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 067: t9_health_score"
mi estimate, post: regress t9_health_score t9_age t9_female t9_educ t9_exper
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 067 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 068: t9_bmi"
mi estimate, post: regress t9_bmi t9_age t9_female t9_educ t9_exper t9_treat
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 068 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 069: t9_bp_sys"
mi estimate, post: regress t9_bp_sys t9_age t9_female t9_educ t9_exper t9_treat i.t9_region
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 069 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 070: t9_bp_dia"
mi estimate, post: regress t9_bp_dia t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 070 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 071: t9_depression"
mi estimate, post: regress t9_depression t9_age t9_female t9_educ
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 071 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 072: t9_stress"
mi estimate, post: regress t9_stress t9_age t9_female t9_educ t9_exper
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 072 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 073: t9_satisfaction"
mi estimate, post: regress t9_satisfaction t9_age t9_female t9_educ t9_exper t9_treat
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 073 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 074: t9_sleep"
mi estimate, post: regress t9_sleep t9_age t9_female t9_educ t9_exper t9_treat i.t9_region
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 074 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 075: t9_exercise"
mi estimate, post: regress t9_exercise t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 075 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 076: t9_income"
mi estimate, post: regress t9_income t9_age t9_female t9_educ
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 076 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 077: t9_wage"
mi estimate, post: regress t9_wage t9_age t9_female t9_educ t9_exper
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 077 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 078: t9_hours"
mi estimate, post: regress t9_hours t9_age t9_female t9_educ t9_exper t9_treat
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 078 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 079: t9_wealth"
mi estimate, post: regress t9_wealth t9_age t9_female t9_educ t9_exper t9_treat i.t9_region
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 079 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 080: t9_savings"
mi estimate, post: regress t9_savings t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 080 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 081: t9_expenditure"
mi estimate, post: regress t9_expenditure t9_age t9_female t9_educ
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 081 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 082: t9_health_score"
mi estimate, post: regress t9_health_score t9_age t9_female t9_educ t9_exper
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 082 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 083: t9_bmi"
mi estimate, post: regress t9_bmi t9_age t9_female t9_educ t9_exper t9_treat
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 083 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 084: t9_bp_sys"
mi estimate, post: regress t9_bp_sys t9_age t9_female t9_educ t9_exper t9_treat i.t9_region
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 084 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 085: t9_bp_dia"
mi estimate, post: regress t9_bp_dia t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 085 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 086: t9_depression"
mi estimate, post: regress t9_depression t9_age t9_female t9_educ
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 086 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 087: t9_stress"
mi estimate, post: regress t9_stress t9_age t9_female t9_educ t9_exper
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 087 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 088: t9_satisfaction"
mi estimate, post: regress t9_satisfaction t9_age t9_female t9_educ t9_exper t9_treat
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 088 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 089: t9_sleep"
mi estimate, post: regress t9_sleep t9_age t9_female t9_educ t9_exper t9_treat i.t9_region
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 089 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 090: t9_exercise"
mi estimate, post: regress t9_exercise t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 090 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 091: t9_income"
mi estimate, post: regress t9_income t9_age t9_female t9_educ
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 091 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 092: t9_wage"
mi estimate, post: regress t9_wage t9_age t9_female t9_educ t9_exper
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 092 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 093: t9_hours"
mi estimate, post: regress t9_hours t9_age t9_female t9_educ t9_exper t9_treat
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 093 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 094: t9_wealth"
mi estimate, post: regress t9_wealth t9_age t9_female t9_educ t9_exper t9_treat i.t9_region
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 094 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 095: t9_savings"
mi estimate, post: regress t9_savings t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 095 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 096: t9_expenditure"
mi estimate, post: regress t9_expenditure t9_age t9_female t9_educ
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 096 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 097: t9_health_score"
mi estimate, post: regress t9_health_score t9_age t9_female t9_educ t9_exper
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 097 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 098: t9_bmi"
mi estimate, post: regress t9_bmi t9_age t9_female t9_educ t9_exper t9_treat
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 098 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 099: t9_bp_sys"
mi estimate, post: regress t9_bp_sys t9_age t9_female t9_educ t9_exper t9_treat i.t9_region
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 099 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 100: t9_bp_dia"
mi estimate, post: regress t9_bp_dia t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 100 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 101: t9_depression"
mi estimate, post: regress t9_depression t9_age t9_female t9_educ
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 101 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 102: t9_stress"
mi estimate, post: regress t9_stress t9_age t9_female t9_educ t9_exper
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 102 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 103: t9_satisfaction"
mi estimate, post: regress t9_satisfaction t9_age t9_female t9_educ t9_exper t9_treat
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 103 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 104: t9_sleep"
mi estimate, post: regress t9_sleep t9_age t9_female t9_educ t9_exper t9_treat i.t9_region
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 104 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 105: t9_exercise"
mi estimate, post: regress t9_exercise t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 105 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 106: t9_income"
mi estimate, post: regress t9_income t9_age t9_female t9_educ
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 106 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 107: t9_wage"
mi estimate, post: regress t9_wage t9_age t9_female t9_educ t9_exper
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 107 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 108: t9_hours"
mi estimate, post: regress t9_hours t9_age t9_female t9_educ t9_exper t9_treat
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 108 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 109: t9_wealth"
mi estimate, post: regress t9_wealth t9_age t9_female t9_educ t9_exper t9_treat i.t9_region
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 109 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 110: t9_savings"
mi estimate, post: regress t9_savings t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 110 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 111: t9_expenditure"
mi estimate, post: regress t9_expenditure t9_age t9_female t9_educ
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 111 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 112: t9_health_score"
mi estimate, post: regress t9_health_score t9_age t9_female t9_educ t9_exper
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 112 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 113: t9_bmi"
mi estimate, post: regress t9_bmi t9_age t9_female t9_educ t9_exper t9_treat
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 113 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 114: t9_bp_sys"
mi estimate, post: regress t9_bp_sys t9_age t9_female t9_educ t9_exper t9_treat i.t9_region
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 114 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 115: t9_bp_dia"
mi estimate, post: regress t9_bp_dia t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 115 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 116: t9_depression"
mi estimate, post: regress t9_depression t9_age t9_female t9_educ
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 116 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 117: t9_stress"
mi estimate, post: regress t9_stress t9_age t9_female t9_educ t9_exper
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 117 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 118: t9_satisfaction"
mi estimate, post: regress t9_satisfaction t9_age t9_female t9_educ t9_exper t9_treat
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 118 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 119: t9_sleep"
mi estimate, post: regress t9_sleep t9_age t9_female t9_educ t9_exper t9_treat i.t9_region
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 119 completed with columns=" colsof(t9_sens_b)

display as text "  Sensitivity model 120: t9_exercise"
mi estimate, post: regress t9_exercise t9_age t9_female t9_educ t9_exper t9_treat i.t9_region i.t9_wave
matrix t9_sens_b = e(b)
display as text "  Sensitivity model 120 completed with columns=" colsof(t9_sens_b)

display as result "<<< DONE Section 18: generated sensitivity models"
// #endregion Section 18
// #region Section 19: final save and exports

display as text ">>> START Section 19: final save and exports"
compress
save "${tempdir}/taught_task9_final.dta", replace
preserve
    mi extract 0, clear
    export delimited using "${tempdir}/taught_task9_m0.csv", replace
restore
preserve
    mi extract 1, clear
    export delimited using "${tempdir}/taught_task9_m1.csv", replace
restore

quietly summarize t9_income if _mi_m == 0
local t9_final_n = r(N)
local t9_final_mean = r(mean)

display as text ""
display as text "===== TAUGHT TASK 9 NATIVE MI STRESS TEST COMPLETE ====="
display as text "Date/time: " c(current_date) " " c(current_time)
display as text "Final m=0 N: `t9_final_n'"
display as text "Final m=0 mean income: " %12.4f `t9_final_mean'
display as text "Output files:"
display as text "  ${tempdir}/taught_task9_final.dta"
display as text "  ${tempdir}/taught_task9_m0.csv"
display as text "  ${tempdir}/taught_task9_m1.csv"
display as text "  ${docdir}/taught_task9_report.docx"
display as text "  ${docdir}/taught_task9_ptdocx_report.docx"
display as text "  ${docdir}/taught_task9_summary.xlsx"
display as text "  ${figdir9}/"
display as text "===== TAUGHT TASK 9 NATIVE MI STRESS TEST END ====="
// #endregion Section 19

// #region Section 20: additional fast scalar diagnostics
display as text ">>> START Section 20: additional scalar diagnostics"
display as text "  Extra scalar diagnostic 0001: t9_income m=1"
quietly summarize t9_income if _mi_m == 1
scalar t9_extra_mean_0001 = r(mean)
scalar t9_extra_min_0001 = r(min)
scalar t9_extra_max_0001 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0001) " / " %12.4f scalar(t9_extra_min_0001) " / " %12.4f scalar(t9_extra_max_0001)

display as text "  Extra scalar diagnostic 0002: t9_wage m=2"
quietly summarize t9_wage if _mi_m == 2
scalar t9_extra_mean_0002 = r(mean)
scalar t9_extra_min_0002 = r(min)
scalar t9_extra_max_0002 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0002) " / " %12.4f scalar(t9_extra_min_0002) " / " %12.4f scalar(t9_extra_max_0002)

display as text "  Extra scalar diagnostic 0003: t9_hours m=3"
quietly summarize t9_hours if _mi_m == 3
scalar t9_extra_mean_0003 = r(mean)
scalar t9_extra_min_0003 = r(min)
scalar t9_extra_max_0003 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0003) " / " %12.4f scalar(t9_extra_min_0003) " / " %12.4f scalar(t9_extra_max_0003)

display as text "  Extra scalar diagnostic 0004: t9_wealth m=0"
quietly summarize t9_wealth if _mi_m == 0
scalar t9_extra_mean_0004 = r(mean)
scalar t9_extra_min_0004 = r(min)
scalar t9_extra_max_0004 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0004) " / " %12.4f scalar(t9_extra_min_0004) " / " %12.4f scalar(t9_extra_max_0004)

display as text "  Extra scalar diagnostic 0005: t9_savings m=1"
quietly summarize t9_savings if _mi_m == 1
scalar t9_extra_mean_0005 = r(mean)
scalar t9_extra_min_0005 = r(min)
scalar t9_extra_max_0005 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0005) " / " %12.4f scalar(t9_extra_min_0005) " / " %12.4f scalar(t9_extra_max_0005)

display as text "  Extra scalar diagnostic 0006: t9_expenditure m=2"
quietly summarize t9_expenditure if _mi_m == 2
scalar t9_extra_mean_0006 = r(mean)
scalar t9_extra_min_0006 = r(min)
scalar t9_extra_max_0006 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0006) " / " %12.4f scalar(t9_extra_min_0006) " / " %12.4f scalar(t9_extra_max_0006)

display as text "  Extra scalar diagnostic 0007: t9_health_score m=3"
quietly summarize t9_health_score if _mi_m == 3
scalar t9_extra_mean_0007 = r(mean)
scalar t9_extra_min_0007 = r(min)
scalar t9_extra_max_0007 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0007) " / " %12.4f scalar(t9_extra_min_0007) " / " %12.4f scalar(t9_extra_max_0007)

display as text "  Extra scalar diagnostic 0008: t9_bmi m=0"
quietly summarize t9_bmi if _mi_m == 0
scalar t9_extra_mean_0008 = r(mean)
scalar t9_extra_min_0008 = r(min)
scalar t9_extra_max_0008 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0008) " / " %12.4f scalar(t9_extra_min_0008) " / " %12.4f scalar(t9_extra_max_0008)

display as text "  Extra scalar diagnostic 0009: t9_bp_sys m=1"
quietly summarize t9_bp_sys if _mi_m == 1
scalar t9_extra_mean_0009 = r(mean)
scalar t9_extra_min_0009 = r(min)
scalar t9_extra_max_0009 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0009) " / " %12.4f scalar(t9_extra_min_0009) " / " %12.4f scalar(t9_extra_max_0009)

display as text "  Extra scalar diagnostic 0010: t9_bp_dia m=2"
quietly summarize t9_bp_dia if _mi_m == 2
scalar t9_extra_mean_0010 = r(mean)
scalar t9_extra_min_0010 = r(min)
scalar t9_extra_max_0010 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0010) " / " %12.4f scalar(t9_extra_min_0010) " / " %12.4f scalar(t9_extra_max_0010)

display as text "  Extra scalar diagnostic 0011: t9_depression m=3"
quietly summarize t9_depression if _mi_m == 3
scalar t9_extra_mean_0011 = r(mean)
scalar t9_extra_min_0011 = r(min)
scalar t9_extra_max_0011 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0011) " / " %12.4f scalar(t9_extra_min_0011) " / " %12.4f scalar(t9_extra_max_0011)

display as text "  Extra scalar diagnostic 0012: t9_stress m=0"
quietly summarize t9_stress if _mi_m == 0
scalar t9_extra_mean_0012 = r(mean)
scalar t9_extra_min_0012 = r(min)
scalar t9_extra_max_0012 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0012) " / " %12.4f scalar(t9_extra_min_0012) " / " %12.4f scalar(t9_extra_max_0012)

display as text "  Extra scalar diagnostic 0013: t9_satisfaction m=1"
quietly summarize t9_satisfaction if _mi_m == 1
scalar t9_extra_mean_0013 = r(mean)
scalar t9_extra_min_0013 = r(min)
scalar t9_extra_max_0013 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0013) " / " %12.4f scalar(t9_extra_min_0013) " / " %12.4f scalar(t9_extra_max_0013)

display as text "  Extra scalar diagnostic 0014: t9_sleep m=2"
quietly summarize t9_sleep if _mi_m == 2
scalar t9_extra_mean_0014 = r(mean)
scalar t9_extra_min_0014 = r(min)
scalar t9_extra_max_0014 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0014) " / " %12.4f scalar(t9_extra_min_0014) " / " %12.4f scalar(t9_extra_max_0014)

display as text "  Extra scalar diagnostic 0015: t9_exercise m=3"
quietly summarize t9_exercise if _mi_m == 3
scalar t9_extra_mean_0015 = r(mean)
scalar t9_extra_min_0015 = r(min)
scalar t9_extra_max_0015 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0015) " / " %12.4f scalar(t9_extra_min_0015) " / " %12.4f scalar(t9_extra_max_0015)

display as text "  Extra scalar diagnostic 0016: t9_employed m=0"
quietly summarize t9_employed if _mi_m == 0
scalar t9_extra_mean_0016 = r(mean)
scalar t9_extra_min_0016 = r(min)
scalar t9_extra_max_0016 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0016) " / " %12.4f scalar(t9_extra_min_0016) " / " %12.4f scalar(t9_extra_max_0016)

display as text "  Extra scalar diagnostic 0017: t9_married m=1"
quietly summarize t9_married if _mi_m == 1
scalar t9_extra_mean_0017 = r(mean)
scalar t9_extra_min_0017 = r(min)
scalar t9_extra_max_0017 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0017) " / " %12.4f scalar(t9_extra_min_0017) " / " %12.4f scalar(t9_extra_max_0017)

display as text "  Extra scalar diagnostic 0018: t9_urban m=2"
quietly summarize t9_urban if _mi_m == 2
scalar t9_extra_mean_0018 = r(mean)
scalar t9_extra_min_0018 = r(min)
scalar t9_extra_max_0018 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0018) " / " %12.4f scalar(t9_extra_min_0018) " / " %12.4f scalar(t9_extra_max_0018)

display as text "  Extra scalar diagnostic 0019: t9_homeowner m=3"
quietly summarize t9_homeowner if _mi_m == 3
scalar t9_extra_mean_0019 = r(mean)
scalar t9_extra_min_0019 = r(min)
scalar t9_extra_max_0019 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0019) " / " %12.4f scalar(t9_extra_min_0019) " / " %12.4f scalar(t9_extra_max_0019)

display as text "  Extra scalar diagnostic 0020: t9_insured m=0"
quietly summarize t9_insured if _mi_m == 0
scalar t9_extra_mean_0020 = r(mean)
scalar t9_extra_min_0020 = r(min)
scalar t9_extra_max_0020 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0020) " / " %12.4f scalar(t9_extra_min_0020) " / " %12.4f scalar(t9_extra_max_0020)

display as text "  Extra scalar diagnostic 0021: t9_smoker m=1"
quietly summarize t9_smoker if _mi_m == 1
scalar t9_extra_mean_0021 = r(mean)
scalar t9_extra_min_0021 = r(min)
scalar t9_extra_max_0021 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0021) " / " %12.4f scalar(t9_extra_min_0021) " / " %12.4f scalar(t9_extra_max_0021)

display as text "  Extra scalar diagnostic 0022: t9_high_income m=2"
quietly summarize t9_high_income if _mi_m == 2
scalar t9_extra_mean_0022 = r(mean)
scalar t9_extra_min_0022 = r(min)
scalar t9_extra_max_0022 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0022) " / " %12.4f scalar(t9_extra_min_0022) " / " %12.4f scalar(t9_extra_max_0022)

display as text "  Extra scalar diagnostic 0023: t9_high_stress m=3"
quietly summarize t9_high_stress if _mi_m == 3
scalar t9_extra_mean_0023 = r(mean)
scalar t9_extra_min_0023 = r(min)
scalar t9_extra_max_0023 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0023) " / " %12.4f scalar(t9_extra_min_0023) " / " %12.4f scalar(t9_extra_max_0023)

display as text "  Extra scalar diagnostic 0024: t9_unhealthy m=0"
quietly summarize t9_unhealthy if _mi_m == 0
scalar t9_extra_mean_0024 = r(mean)
scalar t9_extra_min_0024 = r(min)
scalar t9_extra_max_0024 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0024) " / " %12.4f scalar(t9_extra_min_0024) " / " %12.4f scalar(t9_extra_max_0024)

display as text "  Extra scalar diagnostic 0025: t9_educ_level m=1"
quietly summarize t9_educ_level if _mi_m == 1
scalar t9_extra_mean_0025 = r(mean)
scalar t9_extra_min_0025 = r(min)
scalar t9_extra_max_0025 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0025) " / " %12.4f scalar(t9_extra_min_0025) " / " %12.4f scalar(t9_extra_max_0025)

display as text "  Extra scalar diagnostic 0026: t9_health_level m=2"
quietly summarize t9_health_level if _mi_m == 2
scalar t9_extra_mean_0026 = r(mean)
scalar t9_extra_min_0026 = r(min)
scalar t9_extra_max_0026 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0026) " / " %12.4f scalar(t9_extra_min_0026) " / " %12.4f scalar(t9_extra_max_0026)

display as text "  Extra scalar diagnostic 0027: t9_job_sat m=3"
quietly summarize t9_job_sat if _mi_m == 3
scalar t9_extra_mean_0027 = r(mean)
scalar t9_extra_min_0027 = r(min)
scalar t9_extra_max_0027 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0027) " / " %12.4f scalar(t9_extra_min_0027) " / " %12.4f scalar(t9_extra_max_0027)

display as text "  Extra scalar diagnostic 0028: t9_children m=0"
quietly summarize t9_children if _mi_m == 0
scalar t9_extra_mean_0028 = r(mean)
scalar t9_extra_min_0028 = r(min)
scalar t9_extra_max_0028 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0028) " / " %12.4f scalar(t9_extra_min_0028) " / " %12.4f scalar(t9_extra_max_0028)

display as text "  Extra scalar diagnostic 0029: t9_doctor_visits m=1"
quietly summarize t9_doctor_visits if _mi_m == 1
scalar t9_extra_mean_0029 = r(mean)
scalar t9_extra_min_0029 = r(min)
scalar t9_extra_max_0029 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0029) " / " %12.4f scalar(t9_extra_min_0029) " / " %12.4f scalar(t9_extra_max_0029)

display as text "  Extra scalar diagnostic 0030: t9_hosp_days m=2"
quietly summarize t9_hosp_days if _mi_m == 2
scalar t9_extra_mean_0030 = r(mean)
scalar t9_extra_min_0030 = r(min)
scalar t9_extra_max_0030 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0030) " / " %12.4f scalar(t9_extra_min_0030) " / " %12.4f scalar(t9_extra_max_0030)

display as text "  Extra scalar diagnostic 0031: t9_log_income m=3"
quietly summarize t9_log_income if _mi_m == 3
scalar t9_extra_mean_0031 = r(mean)
scalar t9_extra_min_0031 = r(min)
scalar t9_extra_max_0031 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0031) " / " %12.4f scalar(t9_extra_min_0031) " / " %12.4f scalar(t9_extra_max_0031)

display as text "  Extra scalar diagnostic 0032: t9_log_wage m=0"
quietly summarize t9_log_wage if _mi_m == 0
scalar t9_extra_mean_0032 = r(mean)
scalar t9_extra_min_0032 = r(min)
scalar t9_extra_max_0032 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0032) " / " %12.4f scalar(t9_extra_min_0032) " / " %12.4f scalar(t9_extra_max_0032)

display as text "  Extra scalar diagnostic 0033: t9_income_per_hour m=1"
quietly summarize t9_income_per_hour if _mi_m == 1
scalar t9_extra_mean_0033 = r(mean)
scalar t9_extra_min_0033 = r(min)
scalar t9_extra_max_0033 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0033) " / " %12.4f scalar(t9_extra_min_0033) " / " %12.4f scalar(t9_extra_max_0033)

display as text "  Extra scalar diagnostic 0034: t9_health_index m=2"
quietly summarize t9_health_index if _mi_m == 2
scalar t9_extra_mean_0034 = r(mean)
scalar t9_extra_min_0034 = r(min)
scalar t9_extra_max_0034 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0034) " / " %12.4f scalar(t9_extra_min_0034) " / " %12.4f scalar(t9_extra_max_0034)

display as text "  Extra scalar diagnostic 0035: t9_dep_stress m=3"
quietly summarize t9_dep_stress if _mi_m == 3
scalar t9_extra_mean_0035 = r(mean)
scalar t9_extra_min_0035 = r(min)
scalar t9_extra_max_0035 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0035) " / " %12.4f scalar(t9_extra_min_0035) " / " %12.4f scalar(t9_extra_max_0035)

display as text "  Extra scalar diagnostic 0036: t9_income m=0"
quietly summarize t9_income if _mi_m == 0
scalar t9_extra_mean_0036 = r(mean)
scalar t9_extra_min_0036 = r(min)
scalar t9_extra_max_0036 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0036) " / " %12.4f scalar(t9_extra_min_0036) " / " %12.4f scalar(t9_extra_max_0036)

display as text "  Extra scalar diagnostic 0037: t9_wage m=1"
quietly summarize t9_wage if _mi_m == 1
scalar t9_extra_mean_0037 = r(mean)
scalar t9_extra_min_0037 = r(min)
scalar t9_extra_max_0037 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0037) " / " %12.4f scalar(t9_extra_min_0037) " / " %12.4f scalar(t9_extra_max_0037)

display as text "  Extra scalar diagnostic 0038: t9_hours m=2"
quietly summarize t9_hours if _mi_m == 2
scalar t9_extra_mean_0038 = r(mean)
scalar t9_extra_min_0038 = r(min)
scalar t9_extra_max_0038 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0038) " / " %12.4f scalar(t9_extra_min_0038) " / " %12.4f scalar(t9_extra_max_0038)

display as text "  Extra scalar diagnostic 0039: t9_wealth m=3"
quietly summarize t9_wealth if _mi_m == 3
scalar t9_extra_mean_0039 = r(mean)
scalar t9_extra_min_0039 = r(min)
scalar t9_extra_max_0039 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0039) " / " %12.4f scalar(t9_extra_min_0039) " / " %12.4f scalar(t9_extra_max_0039)

display as text "  Extra scalar diagnostic 0040: t9_savings m=0"
quietly summarize t9_savings if _mi_m == 0
scalar t9_extra_mean_0040 = r(mean)
scalar t9_extra_min_0040 = r(min)
scalar t9_extra_max_0040 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0040) " / " %12.4f scalar(t9_extra_min_0040) " / " %12.4f scalar(t9_extra_max_0040)

display as text "  Extra scalar diagnostic 0041: t9_expenditure m=1"
quietly summarize t9_expenditure if _mi_m == 1
scalar t9_extra_mean_0041 = r(mean)
scalar t9_extra_min_0041 = r(min)
scalar t9_extra_max_0041 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0041) " / " %12.4f scalar(t9_extra_min_0041) " / " %12.4f scalar(t9_extra_max_0041)

display as text "  Extra scalar diagnostic 0042: t9_health_score m=2"
quietly summarize t9_health_score if _mi_m == 2
scalar t9_extra_mean_0042 = r(mean)
scalar t9_extra_min_0042 = r(min)
scalar t9_extra_max_0042 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0042) " / " %12.4f scalar(t9_extra_min_0042) " / " %12.4f scalar(t9_extra_max_0042)

display as text "  Extra scalar diagnostic 0043: t9_bmi m=3"
quietly summarize t9_bmi if _mi_m == 3
scalar t9_extra_mean_0043 = r(mean)
scalar t9_extra_min_0043 = r(min)
scalar t9_extra_max_0043 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0043) " / " %12.4f scalar(t9_extra_min_0043) " / " %12.4f scalar(t9_extra_max_0043)

display as text "  Extra scalar diagnostic 0044: t9_bp_sys m=0"
quietly summarize t9_bp_sys if _mi_m == 0
scalar t9_extra_mean_0044 = r(mean)
scalar t9_extra_min_0044 = r(min)
scalar t9_extra_max_0044 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0044) " / " %12.4f scalar(t9_extra_min_0044) " / " %12.4f scalar(t9_extra_max_0044)

display as text "  Extra scalar diagnostic 0045: t9_bp_dia m=1"
quietly summarize t9_bp_dia if _mi_m == 1
scalar t9_extra_mean_0045 = r(mean)
scalar t9_extra_min_0045 = r(min)
scalar t9_extra_max_0045 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0045) " / " %12.4f scalar(t9_extra_min_0045) " / " %12.4f scalar(t9_extra_max_0045)

display as text "  Extra scalar diagnostic 0046: t9_depression m=2"
quietly summarize t9_depression if _mi_m == 2
scalar t9_extra_mean_0046 = r(mean)
scalar t9_extra_min_0046 = r(min)
scalar t9_extra_max_0046 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0046) " / " %12.4f scalar(t9_extra_min_0046) " / " %12.4f scalar(t9_extra_max_0046)

display as text "  Extra scalar diagnostic 0047: t9_stress m=3"
quietly summarize t9_stress if _mi_m == 3
scalar t9_extra_mean_0047 = r(mean)
scalar t9_extra_min_0047 = r(min)
scalar t9_extra_max_0047 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0047) " / " %12.4f scalar(t9_extra_min_0047) " / " %12.4f scalar(t9_extra_max_0047)

display as text "  Extra scalar diagnostic 0048: t9_satisfaction m=0"
quietly summarize t9_satisfaction if _mi_m == 0
scalar t9_extra_mean_0048 = r(mean)
scalar t9_extra_min_0048 = r(min)
scalar t9_extra_max_0048 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0048) " / " %12.4f scalar(t9_extra_min_0048) " / " %12.4f scalar(t9_extra_max_0048)

display as text "  Extra scalar diagnostic 0049: t9_sleep m=1"
quietly summarize t9_sleep if _mi_m == 1
scalar t9_extra_mean_0049 = r(mean)
scalar t9_extra_min_0049 = r(min)
scalar t9_extra_max_0049 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0049) " / " %12.4f scalar(t9_extra_min_0049) " / " %12.4f scalar(t9_extra_max_0049)

display as text "  Extra scalar diagnostic 0050: t9_exercise m=2"
quietly summarize t9_exercise if _mi_m == 2
scalar t9_extra_mean_0050 = r(mean)
scalar t9_extra_min_0050 = r(min)
scalar t9_extra_max_0050 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0050) " / " %12.4f scalar(t9_extra_min_0050) " / " %12.4f scalar(t9_extra_max_0050)

display as text "  Extra scalar diagnostic 0051: t9_employed m=3"
quietly summarize t9_employed if _mi_m == 3
scalar t9_extra_mean_0051 = r(mean)
scalar t9_extra_min_0051 = r(min)
scalar t9_extra_max_0051 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0051) " / " %12.4f scalar(t9_extra_min_0051) " / " %12.4f scalar(t9_extra_max_0051)

display as text "  Extra scalar diagnostic 0052: t9_married m=0"
quietly summarize t9_married if _mi_m == 0
scalar t9_extra_mean_0052 = r(mean)
scalar t9_extra_min_0052 = r(min)
scalar t9_extra_max_0052 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0052) " / " %12.4f scalar(t9_extra_min_0052) " / " %12.4f scalar(t9_extra_max_0052)

display as text "  Extra scalar diagnostic 0053: t9_urban m=1"
quietly summarize t9_urban if _mi_m == 1
scalar t9_extra_mean_0053 = r(mean)
scalar t9_extra_min_0053 = r(min)
scalar t9_extra_max_0053 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0053) " / " %12.4f scalar(t9_extra_min_0053) " / " %12.4f scalar(t9_extra_max_0053)

display as text "  Extra scalar diagnostic 0054: t9_homeowner m=2"
quietly summarize t9_homeowner if _mi_m == 2
scalar t9_extra_mean_0054 = r(mean)
scalar t9_extra_min_0054 = r(min)
scalar t9_extra_max_0054 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0054) " / " %12.4f scalar(t9_extra_min_0054) " / " %12.4f scalar(t9_extra_max_0054)

display as text "  Extra scalar diagnostic 0055: t9_insured m=3"
quietly summarize t9_insured if _mi_m == 3
scalar t9_extra_mean_0055 = r(mean)
scalar t9_extra_min_0055 = r(min)
scalar t9_extra_max_0055 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0055) " / " %12.4f scalar(t9_extra_min_0055) " / " %12.4f scalar(t9_extra_max_0055)

display as text "  Extra scalar diagnostic 0056: t9_smoker m=0"
quietly summarize t9_smoker if _mi_m == 0
scalar t9_extra_mean_0056 = r(mean)
scalar t9_extra_min_0056 = r(min)
scalar t9_extra_max_0056 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0056) " / " %12.4f scalar(t9_extra_min_0056) " / " %12.4f scalar(t9_extra_max_0056)

display as text "  Extra scalar diagnostic 0057: t9_high_income m=1"
quietly summarize t9_high_income if _mi_m == 1
scalar t9_extra_mean_0057 = r(mean)
scalar t9_extra_min_0057 = r(min)
scalar t9_extra_max_0057 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0057) " / " %12.4f scalar(t9_extra_min_0057) " / " %12.4f scalar(t9_extra_max_0057)

display as text "  Extra scalar diagnostic 0058: t9_high_stress m=2"
quietly summarize t9_high_stress if _mi_m == 2
scalar t9_extra_mean_0058 = r(mean)
scalar t9_extra_min_0058 = r(min)
scalar t9_extra_max_0058 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0058) " / " %12.4f scalar(t9_extra_min_0058) " / " %12.4f scalar(t9_extra_max_0058)

display as text "  Extra scalar diagnostic 0059: t9_unhealthy m=3"
quietly summarize t9_unhealthy if _mi_m == 3
scalar t9_extra_mean_0059 = r(mean)
scalar t9_extra_min_0059 = r(min)
scalar t9_extra_max_0059 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0059) " / " %12.4f scalar(t9_extra_min_0059) " / " %12.4f scalar(t9_extra_max_0059)

display as text "  Extra scalar diagnostic 0060: t9_educ_level m=0"
quietly summarize t9_educ_level if _mi_m == 0
scalar t9_extra_mean_0060 = r(mean)
scalar t9_extra_min_0060 = r(min)
scalar t9_extra_max_0060 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0060) " / " %12.4f scalar(t9_extra_min_0060) " / " %12.4f scalar(t9_extra_max_0060)

display as text "  Extra scalar diagnostic 0061: t9_health_level m=1"
quietly summarize t9_health_level if _mi_m == 1
scalar t9_extra_mean_0061 = r(mean)
scalar t9_extra_min_0061 = r(min)
scalar t9_extra_max_0061 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0061) " / " %12.4f scalar(t9_extra_min_0061) " / " %12.4f scalar(t9_extra_max_0061)

display as text "  Extra scalar diagnostic 0062: t9_job_sat m=2"
quietly summarize t9_job_sat if _mi_m == 2
scalar t9_extra_mean_0062 = r(mean)
scalar t9_extra_min_0062 = r(min)
scalar t9_extra_max_0062 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0062) " / " %12.4f scalar(t9_extra_min_0062) " / " %12.4f scalar(t9_extra_max_0062)

display as text "  Extra scalar diagnostic 0063: t9_children m=3"
quietly summarize t9_children if _mi_m == 3
scalar t9_extra_mean_0063 = r(mean)
scalar t9_extra_min_0063 = r(min)
scalar t9_extra_max_0063 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0063) " / " %12.4f scalar(t9_extra_min_0063) " / " %12.4f scalar(t9_extra_max_0063)

display as text "  Extra scalar diagnostic 0064: t9_doctor_visits m=0"
quietly summarize t9_doctor_visits if _mi_m == 0
scalar t9_extra_mean_0064 = r(mean)
scalar t9_extra_min_0064 = r(min)
scalar t9_extra_max_0064 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0064) " / " %12.4f scalar(t9_extra_min_0064) " / " %12.4f scalar(t9_extra_max_0064)

display as text "  Extra scalar diagnostic 0065: t9_hosp_days m=1"
quietly summarize t9_hosp_days if _mi_m == 1
scalar t9_extra_mean_0065 = r(mean)
scalar t9_extra_min_0065 = r(min)
scalar t9_extra_max_0065 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0065) " / " %12.4f scalar(t9_extra_min_0065) " / " %12.4f scalar(t9_extra_max_0065)

display as text "  Extra scalar diagnostic 0066: t9_log_income m=2"
quietly summarize t9_log_income if _mi_m == 2
scalar t9_extra_mean_0066 = r(mean)
scalar t9_extra_min_0066 = r(min)
scalar t9_extra_max_0066 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0066) " / " %12.4f scalar(t9_extra_min_0066) " / " %12.4f scalar(t9_extra_max_0066)

display as text "  Extra scalar diagnostic 0067: t9_log_wage m=3"
quietly summarize t9_log_wage if _mi_m == 3
scalar t9_extra_mean_0067 = r(mean)
scalar t9_extra_min_0067 = r(min)
scalar t9_extra_max_0067 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0067) " / " %12.4f scalar(t9_extra_min_0067) " / " %12.4f scalar(t9_extra_max_0067)

display as text "  Extra scalar diagnostic 0068: t9_income_per_hour m=0"
quietly summarize t9_income_per_hour if _mi_m == 0
scalar t9_extra_mean_0068 = r(mean)
scalar t9_extra_min_0068 = r(min)
scalar t9_extra_max_0068 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0068) " / " %12.4f scalar(t9_extra_min_0068) " / " %12.4f scalar(t9_extra_max_0068)

display as text "  Extra scalar diagnostic 0069: t9_health_index m=1"
quietly summarize t9_health_index if _mi_m == 1
scalar t9_extra_mean_0069 = r(mean)
scalar t9_extra_min_0069 = r(min)
scalar t9_extra_max_0069 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0069) " / " %12.4f scalar(t9_extra_min_0069) " / " %12.4f scalar(t9_extra_max_0069)

display as text "  Extra scalar diagnostic 0070: t9_dep_stress m=2"
quietly summarize t9_dep_stress if _mi_m == 2
scalar t9_extra_mean_0070 = r(mean)
scalar t9_extra_min_0070 = r(min)
scalar t9_extra_max_0070 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0070) " / " %12.4f scalar(t9_extra_min_0070) " / " %12.4f scalar(t9_extra_max_0070)

display as text "  Extra scalar diagnostic 0071: t9_income m=3"
quietly summarize t9_income if _mi_m == 3
scalar t9_extra_mean_0071 = r(mean)
scalar t9_extra_min_0071 = r(min)
scalar t9_extra_max_0071 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0071) " / " %12.4f scalar(t9_extra_min_0071) " / " %12.4f scalar(t9_extra_max_0071)

display as text "  Extra scalar diagnostic 0072: t9_wage m=0"
quietly summarize t9_wage if _mi_m == 0
scalar t9_extra_mean_0072 = r(mean)
scalar t9_extra_min_0072 = r(min)
scalar t9_extra_max_0072 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0072) " / " %12.4f scalar(t9_extra_min_0072) " / " %12.4f scalar(t9_extra_max_0072)

display as text "  Extra scalar diagnostic 0073: t9_hours m=1"
quietly summarize t9_hours if _mi_m == 1
scalar t9_extra_mean_0073 = r(mean)
scalar t9_extra_min_0073 = r(min)
scalar t9_extra_max_0073 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0073) " / " %12.4f scalar(t9_extra_min_0073) " / " %12.4f scalar(t9_extra_max_0073)

display as text "  Extra scalar diagnostic 0074: t9_wealth m=2"
quietly summarize t9_wealth if _mi_m == 2
scalar t9_extra_mean_0074 = r(mean)
scalar t9_extra_min_0074 = r(min)
scalar t9_extra_max_0074 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0074) " / " %12.4f scalar(t9_extra_min_0074) " / " %12.4f scalar(t9_extra_max_0074)

display as text "  Extra scalar diagnostic 0075: t9_savings m=3"
quietly summarize t9_savings if _mi_m == 3
scalar t9_extra_mean_0075 = r(mean)
scalar t9_extra_min_0075 = r(min)
scalar t9_extra_max_0075 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0075) " / " %12.4f scalar(t9_extra_min_0075) " / " %12.4f scalar(t9_extra_max_0075)

display as text "  Extra scalar diagnostic 0076: t9_expenditure m=0"
quietly summarize t9_expenditure if _mi_m == 0
scalar t9_extra_mean_0076 = r(mean)
scalar t9_extra_min_0076 = r(min)
scalar t9_extra_max_0076 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0076) " / " %12.4f scalar(t9_extra_min_0076) " / " %12.4f scalar(t9_extra_max_0076)

display as text "  Extra scalar diagnostic 0077: t9_health_score m=1"
quietly summarize t9_health_score if _mi_m == 1
scalar t9_extra_mean_0077 = r(mean)
scalar t9_extra_min_0077 = r(min)
scalar t9_extra_max_0077 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0077) " / " %12.4f scalar(t9_extra_min_0077) " / " %12.4f scalar(t9_extra_max_0077)

display as text "  Extra scalar diagnostic 0078: t9_bmi m=2"
quietly summarize t9_bmi if _mi_m == 2
scalar t9_extra_mean_0078 = r(mean)
scalar t9_extra_min_0078 = r(min)
scalar t9_extra_max_0078 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0078) " / " %12.4f scalar(t9_extra_min_0078) " / " %12.4f scalar(t9_extra_max_0078)

display as text "  Extra scalar diagnostic 0079: t9_bp_sys m=3"
quietly summarize t9_bp_sys if _mi_m == 3
scalar t9_extra_mean_0079 = r(mean)
scalar t9_extra_min_0079 = r(min)
scalar t9_extra_max_0079 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0079) " / " %12.4f scalar(t9_extra_min_0079) " / " %12.4f scalar(t9_extra_max_0079)

display as text "  Extra scalar diagnostic 0080: t9_bp_dia m=0"
quietly summarize t9_bp_dia if _mi_m == 0
scalar t9_extra_mean_0080 = r(mean)
scalar t9_extra_min_0080 = r(min)
scalar t9_extra_max_0080 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0080) " / " %12.4f scalar(t9_extra_min_0080) " / " %12.4f scalar(t9_extra_max_0080)

display as text "  Extra scalar diagnostic 0081: t9_depression m=1"
quietly summarize t9_depression if _mi_m == 1
scalar t9_extra_mean_0081 = r(mean)
scalar t9_extra_min_0081 = r(min)
scalar t9_extra_max_0081 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0081) " / " %12.4f scalar(t9_extra_min_0081) " / " %12.4f scalar(t9_extra_max_0081)

display as text "  Extra scalar diagnostic 0082: t9_stress m=2"
quietly summarize t9_stress if _mi_m == 2
scalar t9_extra_mean_0082 = r(mean)
scalar t9_extra_min_0082 = r(min)
scalar t9_extra_max_0082 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0082) " / " %12.4f scalar(t9_extra_min_0082) " / " %12.4f scalar(t9_extra_max_0082)

display as text "  Extra scalar diagnostic 0083: t9_satisfaction m=3"
quietly summarize t9_satisfaction if _mi_m == 3
scalar t9_extra_mean_0083 = r(mean)
scalar t9_extra_min_0083 = r(min)
scalar t9_extra_max_0083 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0083) " / " %12.4f scalar(t9_extra_min_0083) " / " %12.4f scalar(t9_extra_max_0083)

display as text "  Extra scalar diagnostic 0084: t9_sleep m=0"
quietly summarize t9_sleep if _mi_m == 0
scalar t9_extra_mean_0084 = r(mean)
scalar t9_extra_min_0084 = r(min)
scalar t9_extra_max_0084 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0084) " / " %12.4f scalar(t9_extra_min_0084) " / " %12.4f scalar(t9_extra_max_0084)

display as text "  Extra scalar diagnostic 0085: t9_exercise m=1"
quietly summarize t9_exercise if _mi_m == 1
scalar t9_extra_mean_0085 = r(mean)
scalar t9_extra_min_0085 = r(min)
scalar t9_extra_max_0085 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0085) " / " %12.4f scalar(t9_extra_min_0085) " / " %12.4f scalar(t9_extra_max_0085)

display as text "  Extra scalar diagnostic 0086: t9_employed m=2"
quietly summarize t9_employed if _mi_m == 2
scalar t9_extra_mean_0086 = r(mean)
scalar t9_extra_min_0086 = r(min)
scalar t9_extra_max_0086 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0086) " / " %12.4f scalar(t9_extra_min_0086) " / " %12.4f scalar(t9_extra_max_0086)

display as text "  Extra scalar diagnostic 0087: t9_married m=3"
quietly summarize t9_married if _mi_m == 3
scalar t9_extra_mean_0087 = r(mean)
scalar t9_extra_min_0087 = r(min)
scalar t9_extra_max_0087 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0087) " / " %12.4f scalar(t9_extra_min_0087) " / " %12.4f scalar(t9_extra_max_0087)

display as text "  Extra scalar diagnostic 0088: t9_urban m=0"
quietly summarize t9_urban if _mi_m == 0
scalar t9_extra_mean_0088 = r(mean)
scalar t9_extra_min_0088 = r(min)
scalar t9_extra_max_0088 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0088) " / " %12.4f scalar(t9_extra_min_0088) " / " %12.4f scalar(t9_extra_max_0088)

display as text "  Extra scalar diagnostic 0089: t9_homeowner m=1"
quietly summarize t9_homeowner if _mi_m == 1
scalar t9_extra_mean_0089 = r(mean)
scalar t9_extra_min_0089 = r(min)
scalar t9_extra_max_0089 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0089) " / " %12.4f scalar(t9_extra_min_0089) " / " %12.4f scalar(t9_extra_max_0089)

display as text "  Extra scalar diagnostic 0090: t9_insured m=2"
quietly summarize t9_insured if _mi_m == 2
scalar t9_extra_mean_0090 = r(mean)
scalar t9_extra_min_0090 = r(min)
scalar t9_extra_max_0090 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0090) " / " %12.4f scalar(t9_extra_min_0090) " / " %12.4f scalar(t9_extra_max_0090)

display as text "  Extra scalar diagnostic 0091: t9_smoker m=3"
quietly summarize t9_smoker if _mi_m == 3
scalar t9_extra_mean_0091 = r(mean)
scalar t9_extra_min_0091 = r(min)
scalar t9_extra_max_0091 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0091) " / " %12.4f scalar(t9_extra_min_0091) " / " %12.4f scalar(t9_extra_max_0091)

display as text "  Extra scalar diagnostic 0092: t9_high_income m=0"
quietly summarize t9_high_income if _mi_m == 0
scalar t9_extra_mean_0092 = r(mean)
scalar t9_extra_min_0092 = r(min)
scalar t9_extra_max_0092 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0092) " / " %12.4f scalar(t9_extra_min_0092) " / " %12.4f scalar(t9_extra_max_0092)

display as text "  Extra scalar diagnostic 0093: t9_high_stress m=1"
quietly summarize t9_high_stress if _mi_m == 1
scalar t9_extra_mean_0093 = r(mean)
scalar t9_extra_min_0093 = r(min)
scalar t9_extra_max_0093 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0093) " / " %12.4f scalar(t9_extra_min_0093) " / " %12.4f scalar(t9_extra_max_0093)

display as text "  Extra scalar diagnostic 0094: t9_unhealthy m=2"
quietly summarize t9_unhealthy if _mi_m == 2
scalar t9_extra_mean_0094 = r(mean)
scalar t9_extra_min_0094 = r(min)
scalar t9_extra_max_0094 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0094) " / " %12.4f scalar(t9_extra_min_0094) " / " %12.4f scalar(t9_extra_max_0094)

display as text "  Extra scalar diagnostic 0095: t9_educ_level m=3"
quietly summarize t9_educ_level if _mi_m == 3
scalar t9_extra_mean_0095 = r(mean)
scalar t9_extra_min_0095 = r(min)
scalar t9_extra_max_0095 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0095) " / " %12.4f scalar(t9_extra_min_0095) " / " %12.4f scalar(t9_extra_max_0095)

display as text "  Extra scalar diagnostic 0096: t9_health_level m=0"
quietly summarize t9_health_level if _mi_m == 0
scalar t9_extra_mean_0096 = r(mean)
scalar t9_extra_min_0096 = r(min)
scalar t9_extra_max_0096 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0096) " / " %12.4f scalar(t9_extra_min_0096) " / " %12.4f scalar(t9_extra_max_0096)

display as text "  Extra scalar diagnostic 0097: t9_job_sat m=1"
quietly summarize t9_job_sat if _mi_m == 1
scalar t9_extra_mean_0097 = r(mean)
scalar t9_extra_min_0097 = r(min)
scalar t9_extra_max_0097 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0097) " / " %12.4f scalar(t9_extra_min_0097) " / " %12.4f scalar(t9_extra_max_0097)

display as text "  Extra scalar diagnostic 0098: t9_children m=2"
quietly summarize t9_children if _mi_m == 2
scalar t9_extra_mean_0098 = r(mean)
scalar t9_extra_min_0098 = r(min)
scalar t9_extra_max_0098 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0098) " / " %12.4f scalar(t9_extra_min_0098) " / " %12.4f scalar(t9_extra_max_0098)

display as text "  Extra scalar diagnostic 0099: t9_doctor_visits m=3"
quietly summarize t9_doctor_visits if _mi_m == 3
scalar t9_extra_mean_0099 = r(mean)
scalar t9_extra_min_0099 = r(min)
scalar t9_extra_max_0099 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0099) " / " %12.4f scalar(t9_extra_min_0099) " / " %12.4f scalar(t9_extra_max_0099)

display as text "  Extra scalar diagnostic 0100: t9_hosp_days m=0"
quietly summarize t9_hosp_days if _mi_m == 0
scalar t9_extra_mean_0100 = r(mean)
scalar t9_extra_min_0100 = r(min)
scalar t9_extra_max_0100 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0100) " / " %12.4f scalar(t9_extra_min_0100) " / " %12.4f scalar(t9_extra_max_0100)

display as text "  Extra scalar diagnostic 0101: t9_log_income m=1"
quietly summarize t9_log_income if _mi_m == 1
scalar t9_extra_mean_0101 = r(mean)
scalar t9_extra_min_0101 = r(min)
scalar t9_extra_max_0101 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0101) " / " %12.4f scalar(t9_extra_min_0101) " / " %12.4f scalar(t9_extra_max_0101)

display as text "  Extra scalar diagnostic 0102: t9_log_wage m=2"
quietly summarize t9_log_wage if _mi_m == 2
scalar t9_extra_mean_0102 = r(mean)
scalar t9_extra_min_0102 = r(min)
scalar t9_extra_max_0102 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0102) " / " %12.4f scalar(t9_extra_min_0102) " / " %12.4f scalar(t9_extra_max_0102)

display as text "  Extra scalar diagnostic 0103: t9_income_per_hour m=3"
quietly summarize t9_income_per_hour if _mi_m == 3
scalar t9_extra_mean_0103 = r(mean)
scalar t9_extra_min_0103 = r(min)
scalar t9_extra_max_0103 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0103) " / " %12.4f scalar(t9_extra_min_0103) " / " %12.4f scalar(t9_extra_max_0103)

display as text "  Extra scalar diagnostic 0104: t9_health_index m=0"
quietly summarize t9_health_index if _mi_m == 0
scalar t9_extra_mean_0104 = r(mean)
scalar t9_extra_min_0104 = r(min)
scalar t9_extra_max_0104 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0104) " / " %12.4f scalar(t9_extra_min_0104) " / " %12.4f scalar(t9_extra_max_0104)

display as text "  Extra scalar diagnostic 0105: t9_dep_stress m=1"
quietly summarize t9_dep_stress if _mi_m == 1
scalar t9_extra_mean_0105 = r(mean)
scalar t9_extra_min_0105 = r(min)
scalar t9_extra_max_0105 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0105) " / " %12.4f scalar(t9_extra_min_0105) " / " %12.4f scalar(t9_extra_max_0105)

display as text "  Extra scalar diagnostic 0106: t9_income m=2"
quietly summarize t9_income if _mi_m == 2
scalar t9_extra_mean_0106 = r(mean)
scalar t9_extra_min_0106 = r(min)
scalar t9_extra_max_0106 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0106) " / " %12.4f scalar(t9_extra_min_0106) " / " %12.4f scalar(t9_extra_max_0106)

display as text "  Extra scalar diagnostic 0107: t9_wage m=3"
quietly summarize t9_wage if _mi_m == 3
scalar t9_extra_mean_0107 = r(mean)
scalar t9_extra_min_0107 = r(min)
scalar t9_extra_max_0107 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0107) " / " %12.4f scalar(t9_extra_min_0107) " / " %12.4f scalar(t9_extra_max_0107)

display as text "  Extra scalar diagnostic 0108: t9_hours m=0"
quietly summarize t9_hours if _mi_m == 0
scalar t9_extra_mean_0108 = r(mean)
scalar t9_extra_min_0108 = r(min)
scalar t9_extra_max_0108 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0108) " / " %12.4f scalar(t9_extra_min_0108) " / " %12.4f scalar(t9_extra_max_0108)

display as text "  Extra scalar diagnostic 0109: t9_wealth m=1"
quietly summarize t9_wealth if _mi_m == 1
scalar t9_extra_mean_0109 = r(mean)
scalar t9_extra_min_0109 = r(min)
scalar t9_extra_max_0109 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0109) " / " %12.4f scalar(t9_extra_min_0109) " / " %12.4f scalar(t9_extra_max_0109)

display as text "  Extra scalar diagnostic 0110: t9_savings m=2"
quietly summarize t9_savings if _mi_m == 2
scalar t9_extra_mean_0110 = r(mean)
scalar t9_extra_min_0110 = r(min)
scalar t9_extra_max_0110 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0110) " / " %12.4f scalar(t9_extra_min_0110) " / " %12.4f scalar(t9_extra_max_0110)

display as text "  Extra scalar diagnostic 0111: t9_expenditure m=3"
quietly summarize t9_expenditure if _mi_m == 3
scalar t9_extra_mean_0111 = r(mean)
scalar t9_extra_min_0111 = r(min)
scalar t9_extra_max_0111 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0111) " / " %12.4f scalar(t9_extra_min_0111) " / " %12.4f scalar(t9_extra_max_0111)

display as text "  Extra scalar diagnostic 0112: t9_health_score m=0"
quietly summarize t9_health_score if _mi_m == 0
scalar t9_extra_mean_0112 = r(mean)
scalar t9_extra_min_0112 = r(min)
scalar t9_extra_max_0112 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0112) " / " %12.4f scalar(t9_extra_min_0112) " / " %12.4f scalar(t9_extra_max_0112)

display as text "  Extra scalar diagnostic 0113: t9_bmi m=1"
quietly summarize t9_bmi if _mi_m == 1
scalar t9_extra_mean_0113 = r(mean)
scalar t9_extra_min_0113 = r(min)
scalar t9_extra_max_0113 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0113) " / " %12.4f scalar(t9_extra_min_0113) " / " %12.4f scalar(t9_extra_max_0113)

display as text "  Extra scalar diagnostic 0114: t9_bp_sys m=2"
quietly summarize t9_bp_sys if _mi_m == 2
scalar t9_extra_mean_0114 = r(mean)
scalar t9_extra_min_0114 = r(min)
scalar t9_extra_max_0114 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0114) " / " %12.4f scalar(t9_extra_min_0114) " / " %12.4f scalar(t9_extra_max_0114)

display as text "  Extra scalar diagnostic 0115: t9_bp_dia m=3"
quietly summarize t9_bp_dia if _mi_m == 3
scalar t9_extra_mean_0115 = r(mean)
scalar t9_extra_min_0115 = r(min)
scalar t9_extra_max_0115 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0115) " / " %12.4f scalar(t9_extra_min_0115) " / " %12.4f scalar(t9_extra_max_0115)

display as text "  Extra scalar diagnostic 0116: t9_depression m=0"
quietly summarize t9_depression if _mi_m == 0
scalar t9_extra_mean_0116 = r(mean)
scalar t9_extra_min_0116 = r(min)
scalar t9_extra_max_0116 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0116) " / " %12.4f scalar(t9_extra_min_0116) " / " %12.4f scalar(t9_extra_max_0116)

display as text "  Extra scalar diagnostic 0117: t9_stress m=1"
quietly summarize t9_stress if _mi_m == 1
scalar t9_extra_mean_0117 = r(mean)
scalar t9_extra_min_0117 = r(min)
scalar t9_extra_max_0117 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0117) " / " %12.4f scalar(t9_extra_min_0117) " / " %12.4f scalar(t9_extra_max_0117)

display as text "  Extra scalar diagnostic 0118: t9_satisfaction m=2"
quietly summarize t9_satisfaction if _mi_m == 2
scalar t9_extra_mean_0118 = r(mean)
scalar t9_extra_min_0118 = r(min)
scalar t9_extra_max_0118 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0118) " / " %12.4f scalar(t9_extra_min_0118) " / " %12.4f scalar(t9_extra_max_0118)

display as text "  Extra scalar diagnostic 0119: t9_sleep m=3"
quietly summarize t9_sleep if _mi_m == 3
scalar t9_extra_mean_0119 = r(mean)
scalar t9_extra_min_0119 = r(min)
scalar t9_extra_max_0119 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0119) " / " %12.4f scalar(t9_extra_min_0119) " / " %12.4f scalar(t9_extra_max_0119)

display as text "  Extra scalar diagnostic 0120: t9_exercise m=0"
quietly summarize t9_exercise if _mi_m == 0
scalar t9_extra_mean_0120 = r(mean)
scalar t9_extra_min_0120 = r(min)
scalar t9_extra_max_0120 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0120) " / " %12.4f scalar(t9_extra_min_0120) " / " %12.4f scalar(t9_extra_max_0120)

display as text "  Extra scalar diagnostic 0121: t9_employed m=1"
quietly summarize t9_employed if _mi_m == 1
scalar t9_extra_mean_0121 = r(mean)
scalar t9_extra_min_0121 = r(min)
scalar t9_extra_max_0121 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0121) " / " %12.4f scalar(t9_extra_min_0121) " / " %12.4f scalar(t9_extra_max_0121)

display as text "  Extra scalar diagnostic 0122: t9_married m=2"
quietly summarize t9_married if _mi_m == 2
scalar t9_extra_mean_0122 = r(mean)
scalar t9_extra_min_0122 = r(min)
scalar t9_extra_max_0122 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0122) " / " %12.4f scalar(t9_extra_min_0122) " / " %12.4f scalar(t9_extra_max_0122)

display as text "  Extra scalar diagnostic 0123: t9_urban m=3"
quietly summarize t9_urban if _mi_m == 3
scalar t9_extra_mean_0123 = r(mean)
scalar t9_extra_min_0123 = r(min)
scalar t9_extra_max_0123 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0123) " / " %12.4f scalar(t9_extra_min_0123) " / " %12.4f scalar(t9_extra_max_0123)

display as text "  Extra scalar diagnostic 0124: t9_homeowner m=0"
quietly summarize t9_homeowner if _mi_m == 0
scalar t9_extra_mean_0124 = r(mean)
scalar t9_extra_min_0124 = r(min)
scalar t9_extra_max_0124 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0124) " / " %12.4f scalar(t9_extra_min_0124) " / " %12.4f scalar(t9_extra_max_0124)

display as text "  Extra scalar diagnostic 0125: t9_insured m=1"
quietly summarize t9_insured if _mi_m == 1
scalar t9_extra_mean_0125 = r(mean)
scalar t9_extra_min_0125 = r(min)
scalar t9_extra_max_0125 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0125) " / " %12.4f scalar(t9_extra_min_0125) " / " %12.4f scalar(t9_extra_max_0125)

display as text "  Extra scalar diagnostic 0126: t9_smoker m=2"
quietly summarize t9_smoker if _mi_m == 2
scalar t9_extra_mean_0126 = r(mean)
scalar t9_extra_min_0126 = r(min)
scalar t9_extra_max_0126 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0126) " / " %12.4f scalar(t9_extra_min_0126) " / " %12.4f scalar(t9_extra_max_0126)

display as text "  Extra scalar diagnostic 0127: t9_high_income m=3"
quietly summarize t9_high_income if _mi_m == 3
scalar t9_extra_mean_0127 = r(mean)
scalar t9_extra_min_0127 = r(min)
scalar t9_extra_max_0127 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0127) " / " %12.4f scalar(t9_extra_min_0127) " / " %12.4f scalar(t9_extra_max_0127)

display as text "  Extra scalar diagnostic 0128: t9_high_stress m=0"
quietly summarize t9_high_stress if _mi_m == 0
scalar t9_extra_mean_0128 = r(mean)
scalar t9_extra_min_0128 = r(min)
scalar t9_extra_max_0128 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0128) " / " %12.4f scalar(t9_extra_min_0128) " / " %12.4f scalar(t9_extra_max_0128)

display as text "  Extra scalar diagnostic 0129: t9_unhealthy m=1"
quietly summarize t9_unhealthy if _mi_m == 1
scalar t9_extra_mean_0129 = r(mean)
scalar t9_extra_min_0129 = r(min)
scalar t9_extra_max_0129 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0129) " / " %12.4f scalar(t9_extra_min_0129) " / " %12.4f scalar(t9_extra_max_0129)

display as text "  Extra scalar diagnostic 0130: t9_educ_level m=2"
quietly summarize t9_educ_level if _mi_m == 2
scalar t9_extra_mean_0130 = r(mean)
scalar t9_extra_min_0130 = r(min)
scalar t9_extra_max_0130 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0130) " / " %12.4f scalar(t9_extra_min_0130) " / " %12.4f scalar(t9_extra_max_0130)

display as text "  Extra scalar diagnostic 0131: t9_health_level m=3"
quietly summarize t9_health_level if _mi_m == 3
scalar t9_extra_mean_0131 = r(mean)
scalar t9_extra_min_0131 = r(min)
scalar t9_extra_max_0131 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0131) " / " %12.4f scalar(t9_extra_min_0131) " / " %12.4f scalar(t9_extra_max_0131)

display as text "  Extra scalar diagnostic 0132: t9_job_sat m=0"
quietly summarize t9_job_sat if _mi_m == 0
scalar t9_extra_mean_0132 = r(mean)
scalar t9_extra_min_0132 = r(min)
scalar t9_extra_max_0132 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0132) " / " %12.4f scalar(t9_extra_min_0132) " / " %12.4f scalar(t9_extra_max_0132)

display as text "  Extra scalar diagnostic 0133: t9_children m=1"
quietly summarize t9_children if _mi_m == 1
scalar t9_extra_mean_0133 = r(mean)
scalar t9_extra_min_0133 = r(min)
scalar t9_extra_max_0133 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0133) " / " %12.4f scalar(t9_extra_min_0133) " / " %12.4f scalar(t9_extra_max_0133)

display as text "  Extra scalar diagnostic 0134: t9_doctor_visits m=2"
quietly summarize t9_doctor_visits if _mi_m == 2
scalar t9_extra_mean_0134 = r(mean)
scalar t9_extra_min_0134 = r(min)
scalar t9_extra_max_0134 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0134) " / " %12.4f scalar(t9_extra_min_0134) " / " %12.4f scalar(t9_extra_max_0134)

display as text "  Extra scalar diagnostic 0135: t9_hosp_days m=3"
quietly summarize t9_hosp_days if _mi_m == 3
scalar t9_extra_mean_0135 = r(mean)
scalar t9_extra_min_0135 = r(min)
scalar t9_extra_max_0135 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0135) " / " %12.4f scalar(t9_extra_min_0135) " / " %12.4f scalar(t9_extra_max_0135)

display as text "  Extra scalar diagnostic 0136: t9_log_income m=0"
quietly summarize t9_log_income if _mi_m == 0
scalar t9_extra_mean_0136 = r(mean)
scalar t9_extra_min_0136 = r(min)
scalar t9_extra_max_0136 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0136) " / " %12.4f scalar(t9_extra_min_0136) " / " %12.4f scalar(t9_extra_max_0136)

display as text "  Extra scalar diagnostic 0137: t9_log_wage m=1"
quietly summarize t9_log_wage if _mi_m == 1
scalar t9_extra_mean_0137 = r(mean)
scalar t9_extra_min_0137 = r(min)
scalar t9_extra_max_0137 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0137) " / " %12.4f scalar(t9_extra_min_0137) " / " %12.4f scalar(t9_extra_max_0137)

display as text "  Extra scalar diagnostic 0138: t9_income_per_hour m=2"
quietly summarize t9_income_per_hour if _mi_m == 2
scalar t9_extra_mean_0138 = r(mean)
scalar t9_extra_min_0138 = r(min)
scalar t9_extra_max_0138 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0138) " / " %12.4f scalar(t9_extra_min_0138) " / " %12.4f scalar(t9_extra_max_0138)

display as text "  Extra scalar diagnostic 0139: t9_health_index m=3"
quietly summarize t9_health_index if _mi_m == 3
scalar t9_extra_mean_0139 = r(mean)
scalar t9_extra_min_0139 = r(min)
scalar t9_extra_max_0139 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0139) " / " %12.4f scalar(t9_extra_min_0139) " / " %12.4f scalar(t9_extra_max_0139)

display as text "  Extra scalar diagnostic 0140: t9_dep_stress m=0"
quietly summarize t9_dep_stress if _mi_m == 0
scalar t9_extra_mean_0140 = r(mean)
scalar t9_extra_min_0140 = r(min)
scalar t9_extra_max_0140 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0140) " / " %12.4f scalar(t9_extra_min_0140) " / " %12.4f scalar(t9_extra_max_0140)

display as text "  Extra scalar diagnostic 0141: t9_income m=1"
quietly summarize t9_income if _mi_m == 1
scalar t9_extra_mean_0141 = r(mean)
scalar t9_extra_min_0141 = r(min)
scalar t9_extra_max_0141 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0141) " / " %12.4f scalar(t9_extra_min_0141) " / " %12.4f scalar(t9_extra_max_0141)

display as text "  Extra scalar diagnostic 0142: t9_wage m=2"
quietly summarize t9_wage if _mi_m == 2
scalar t9_extra_mean_0142 = r(mean)
scalar t9_extra_min_0142 = r(min)
scalar t9_extra_max_0142 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0142) " / " %12.4f scalar(t9_extra_min_0142) " / " %12.4f scalar(t9_extra_max_0142)

display as text "  Extra scalar diagnostic 0143: t9_hours m=3"
quietly summarize t9_hours if _mi_m == 3
scalar t9_extra_mean_0143 = r(mean)
scalar t9_extra_min_0143 = r(min)
scalar t9_extra_max_0143 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0143) " / " %12.4f scalar(t9_extra_min_0143) " / " %12.4f scalar(t9_extra_max_0143)

display as text "  Extra scalar diagnostic 0144: t9_wealth m=0"
quietly summarize t9_wealth if _mi_m == 0
scalar t9_extra_mean_0144 = r(mean)
scalar t9_extra_min_0144 = r(min)
scalar t9_extra_max_0144 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0144) " / " %12.4f scalar(t9_extra_min_0144) " / " %12.4f scalar(t9_extra_max_0144)

display as text "  Extra scalar diagnostic 0145: t9_savings m=1"
quietly summarize t9_savings if _mi_m == 1
scalar t9_extra_mean_0145 = r(mean)
scalar t9_extra_min_0145 = r(min)
scalar t9_extra_max_0145 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0145) " / " %12.4f scalar(t9_extra_min_0145) " / " %12.4f scalar(t9_extra_max_0145)

display as text "  Extra scalar diagnostic 0146: t9_expenditure m=2"
quietly summarize t9_expenditure if _mi_m == 2
scalar t9_extra_mean_0146 = r(mean)
scalar t9_extra_min_0146 = r(min)
scalar t9_extra_max_0146 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0146) " / " %12.4f scalar(t9_extra_min_0146) " / " %12.4f scalar(t9_extra_max_0146)

display as text "  Extra scalar diagnostic 0147: t9_health_score m=3"
quietly summarize t9_health_score if _mi_m == 3
scalar t9_extra_mean_0147 = r(mean)
scalar t9_extra_min_0147 = r(min)
scalar t9_extra_max_0147 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0147) " / " %12.4f scalar(t9_extra_min_0147) " / " %12.4f scalar(t9_extra_max_0147)

display as text "  Extra scalar diagnostic 0148: t9_bmi m=0"
quietly summarize t9_bmi if _mi_m == 0
scalar t9_extra_mean_0148 = r(mean)
scalar t9_extra_min_0148 = r(min)
scalar t9_extra_max_0148 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0148) " / " %12.4f scalar(t9_extra_min_0148) " / " %12.4f scalar(t9_extra_max_0148)

display as text "  Extra scalar diagnostic 0149: t9_bp_sys m=1"
quietly summarize t9_bp_sys if _mi_m == 1
scalar t9_extra_mean_0149 = r(mean)
scalar t9_extra_min_0149 = r(min)
scalar t9_extra_max_0149 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0149) " / " %12.4f scalar(t9_extra_min_0149) " / " %12.4f scalar(t9_extra_max_0149)

display as text "  Extra scalar diagnostic 0150: t9_bp_dia m=2"
quietly summarize t9_bp_dia if _mi_m == 2
scalar t9_extra_mean_0150 = r(mean)
scalar t9_extra_min_0150 = r(min)
scalar t9_extra_max_0150 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0150) " / " %12.4f scalar(t9_extra_min_0150) " / " %12.4f scalar(t9_extra_max_0150)

display as text "  Extra scalar diagnostic 0151: t9_depression m=3"
quietly summarize t9_depression if _mi_m == 3
scalar t9_extra_mean_0151 = r(mean)
scalar t9_extra_min_0151 = r(min)
scalar t9_extra_max_0151 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0151) " / " %12.4f scalar(t9_extra_min_0151) " / " %12.4f scalar(t9_extra_max_0151)

display as text "  Extra scalar diagnostic 0152: t9_stress m=0"
quietly summarize t9_stress if _mi_m == 0
scalar t9_extra_mean_0152 = r(mean)
scalar t9_extra_min_0152 = r(min)
scalar t9_extra_max_0152 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0152) " / " %12.4f scalar(t9_extra_min_0152) " / " %12.4f scalar(t9_extra_max_0152)

display as text "  Extra scalar diagnostic 0153: t9_satisfaction m=1"
quietly summarize t9_satisfaction if _mi_m == 1
scalar t9_extra_mean_0153 = r(mean)
scalar t9_extra_min_0153 = r(min)
scalar t9_extra_max_0153 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0153) " / " %12.4f scalar(t9_extra_min_0153) " / " %12.4f scalar(t9_extra_max_0153)

display as text "  Extra scalar diagnostic 0154: t9_sleep m=2"
quietly summarize t9_sleep if _mi_m == 2
scalar t9_extra_mean_0154 = r(mean)
scalar t9_extra_min_0154 = r(min)
scalar t9_extra_max_0154 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0154) " / " %12.4f scalar(t9_extra_min_0154) " / " %12.4f scalar(t9_extra_max_0154)

display as text "  Extra scalar diagnostic 0155: t9_exercise m=3"
quietly summarize t9_exercise if _mi_m == 3
scalar t9_extra_mean_0155 = r(mean)
scalar t9_extra_min_0155 = r(min)
scalar t9_extra_max_0155 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0155) " / " %12.4f scalar(t9_extra_min_0155) " / " %12.4f scalar(t9_extra_max_0155)

display as text "  Extra scalar diagnostic 0156: t9_employed m=0"
quietly summarize t9_employed if _mi_m == 0
scalar t9_extra_mean_0156 = r(mean)
scalar t9_extra_min_0156 = r(min)
scalar t9_extra_max_0156 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0156) " / " %12.4f scalar(t9_extra_min_0156) " / " %12.4f scalar(t9_extra_max_0156)

display as text "  Extra scalar diagnostic 0157: t9_married m=1"
quietly summarize t9_married if _mi_m == 1
scalar t9_extra_mean_0157 = r(mean)
scalar t9_extra_min_0157 = r(min)
scalar t9_extra_max_0157 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0157) " / " %12.4f scalar(t9_extra_min_0157) " / " %12.4f scalar(t9_extra_max_0157)

display as text "  Extra scalar diagnostic 0158: t9_urban m=2"
quietly summarize t9_urban if _mi_m == 2
scalar t9_extra_mean_0158 = r(mean)
scalar t9_extra_min_0158 = r(min)
scalar t9_extra_max_0158 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0158) " / " %12.4f scalar(t9_extra_min_0158) " / " %12.4f scalar(t9_extra_max_0158)

display as text "  Extra scalar diagnostic 0159: t9_homeowner m=3"
quietly summarize t9_homeowner if _mi_m == 3
scalar t9_extra_mean_0159 = r(mean)
scalar t9_extra_min_0159 = r(min)
scalar t9_extra_max_0159 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0159) " / " %12.4f scalar(t9_extra_min_0159) " / " %12.4f scalar(t9_extra_max_0159)

display as text "  Extra scalar diagnostic 0160: t9_insured m=0"
quietly summarize t9_insured if _mi_m == 0
scalar t9_extra_mean_0160 = r(mean)
scalar t9_extra_min_0160 = r(min)
scalar t9_extra_max_0160 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0160) " / " %12.4f scalar(t9_extra_min_0160) " / " %12.4f scalar(t9_extra_max_0160)

display as text "  Extra scalar diagnostic 0161: t9_smoker m=1"
quietly summarize t9_smoker if _mi_m == 1
scalar t9_extra_mean_0161 = r(mean)
scalar t9_extra_min_0161 = r(min)
scalar t9_extra_max_0161 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0161) " / " %12.4f scalar(t9_extra_min_0161) " / " %12.4f scalar(t9_extra_max_0161)

display as text "  Extra scalar diagnostic 0162: t9_high_income m=2"
quietly summarize t9_high_income if _mi_m == 2
scalar t9_extra_mean_0162 = r(mean)
scalar t9_extra_min_0162 = r(min)
scalar t9_extra_max_0162 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0162) " / " %12.4f scalar(t9_extra_min_0162) " / " %12.4f scalar(t9_extra_max_0162)

display as text "  Extra scalar diagnostic 0163: t9_high_stress m=3"
quietly summarize t9_high_stress if _mi_m == 3
scalar t9_extra_mean_0163 = r(mean)
scalar t9_extra_min_0163 = r(min)
scalar t9_extra_max_0163 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0163) " / " %12.4f scalar(t9_extra_min_0163) " / " %12.4f scalar(t9_extra_max_0163)

display as text "  Extra scalar diagnostic 0164: t9_unhealthy m=0"
quietly summarize t9_unhealthy if _mi_m == 0
scalar t9_extra_mean_0164 = r(mean)
scalar t9_extra_min_0164 = r(min)
scalar t9_extra_max_0164 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0164) " / " %12.4f scalar(t9_extra_min_0164) " / " %12.4f scalar(t9_extra_max_0164)

display as text "  Extra scalar diagnostic 0165: t9_educ_level m=1"
quietly summarize t9_educ_level if _mi_m == 1
scalar t9_extra_mean_0165 = r(mean)
scalar t9_extra_min_0165 = r(min)
scalar t9_extra_max_0165 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0165) " / " %12.4f scalar(t9_extra_min_0165) " / " %12.4f scalar(t9_extra_max_0165)

display as text "  Extra scalar diagnostic 0166: t9_health_level m=2"
quietly summarize t9_health_level if _mi_m == 2
scalar t9_extra_mean_0166 = r(mean)
scalar t9_extra_min_0166 = r(min)
scalar t9_extra_max_0166 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0166) " / " %12.4f scalar(t9_extra_min_0166) " / " %12.4f scalar(t9_extra_max_0166)

display as text "  Extra scalar diagnostic 0167: t9_job_sat m=3"
quietly summarize t9_job_sat if _mi_m == 3
scalar t9_extra_mean_0167 = r(mean)
scalar t9_extra_min_0167 = r(min)
scalar t9_extra_max_0167 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0167) " / " %12.4f scalar(t9_extra_min_0167) " / " %12.4f scalar(t9_extra_max_0167)

display as text "  Extra scalar diagnostic 0168: t9_children m=0"
quietly summarize t9_children if _mi_m == 0
scalar t9_extra_mean_0168 = r(mean)
scalar t9_extra_min_0168 = r(min)
scalar t9_extra_max_0168 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0168) " / " %12.4f scalar(t9_extra_min_0168) " / " %12.4f scalar(t9_extra_max_0168)

display as text "  Extra scalar diagnostic 0169: t9_doctor_visits m=1"
quietly summarize t9_doctor_visits if _mi_m == 1
scalar t9_extra_mean_0169 = r(mean)
scalar t9_extra_min_0169 = r(min)
scalar t9_extra_max_0169 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0169) " / " %12.4f scalar(t9_extra_min_0169) " / " %12.4f scalar(t9_extra_max_0169)

display as text "  Extra scalar diagnostic 0170: t9_hosp_days m=2"
quietly summarize t9_hosp_days if _mi_m == 2
scalar t9_extra_mean_0170 = r(mean)
scalar t9_extra_min_0170 = r(min)
scalar t9_extra_max_0170 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0170) " / " %12.4f scalar(t9_extra_min_0170) " / " %12.4f scalar(t9_extra_max_0170)

display as text "  Extra scalar diagnostic 0171: t9_log_income m=3"
quietly summarize t9_log_income if _mi_m == 3
scalar t9_extra_mean_0171 = r(mean)
scalar t9_extra_min_0171 = r(min)
scalar t9_extra_max_0171 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0171) " / " %12.4f scalar(t9_extra_min_0171) " / " %12.4f scalar(t9_extra_max_0171)

display as text "  Extra scalar diagnostic 0172: t9_log_wage m=0"
quietly summarize t9_log_wage if _mi_m == 0
scalar t9_extra_mean_0172 = r(mean)
scalar t9_extra_min_0172 = r(min)
scalar t9_extra_max_0172 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0172) " / " %12.4f scalar(t9_extra_min_0172) " / " %12.4f scalar(t9_extra_max_0172)

display as text "  Extra scalar diagnostic 0173: t9_income_per_hour m=1"
quietly summarize t9_income_per_hour if _mi_m == 1
scalar t9_extra_mean_0173 = r(mean)
scalar t9_extra_min_0173 = r(min)
scalar t9_extra_max_0173 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0173) " / " %12.4f scalar(t9_extra_min_0173) " / " %12.4f scalar(t9_extra_max_0173)

display as text "  Extra scalar diagnostic 0174: t9_health_index m=2"
quietly summarize t9_health_index if _mi_m == 2
scalar t9_extra_mean_0174 = r(mean)
scalar t9_extra_min_0174 = r(min)
scalar t9_extra_max_0174 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0174) " / " %12.4f scalar(t9_extra_min_0174) " / " %12.4f scalar(t9_extra_max_0174)

display as text "  Extra scalar diagnostic 0175: t9_dep_stress m=3"
quietly summarize t9_dep_stress if _mi_m == 3
scalar t9_extra_mean_0175 = r(mean)
scalar t9_extra_min_0175 = r(min)
scalar t9_extra_max_0175 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0175) " / " %12.4f scalar(t9_extra_min_0175) " / " %12.4f scalar(t9_extra_max_0175)

display as text "  Extra scalar diagnostic 0176: t9_income m=0"
quietly summarize t9_income if _mi_m == 0
scalar t9_extra_mean_0176 = r(mean)
scalar t9_extra_min_0176 = r(min)
scalar t9_extra_max_0176 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0176) " / " %12.4f scalar(t9_extra_min_0176) " / " %12.4f scalar(t9_extra_max_0176)

display as text "  Extra scalar diagnostic 0177: t9_wage m=1"
quietly summarize t9_wage if _mi_m == 1
scalar t9_extra_mean_0177 = r(mean)
scalar t9_extra_min_0177 = r(min)
scalar t9_extra_max_0177 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0177) " / " %12.4f scalar(t9_extra_min_0177) " / " %12.4f scalar(t9_extra_max_0177)

display as text "  Extra scalar diagnostic 0178: t9_hours m=2"
quietly summarize t9_hours if _mi_m == 2
scalar t9_extra_mean_0178 = r(mean)
scalar t9_extra_min_0178 = r(min)
scalar t9_extra_max_0178 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0178) " / " %12.4f scalar(t9_extra_min_0178) " / " %12.4f scalar(t9_extra_max_0178)

display as text "  Extra scalar diagnostic 0179: t9_wealth m=3"
quietly summarize t9_wealth if _mi_m == 3
scalar t9_extra_mean_0179 = r(mean)
scalar t9_extra_min_0179 = r(min)
scalar t9_extra_max_0179 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0179) " / " %12.4f scalar(t9_extra_min_0179) " / " %12.4f scalar(t9_extra_max_0179)

display as text "  Extra scalar diagnostic 0180: t9_savings m=0"
quietly summarize t9_savings if _mi_m == 0
scalar t9_extra_mean_0180 = r(mean)
scalar t9_extra_min_0180 = r(min)
scalar t9_extra_max_0180 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0180) " / " %12.4f scalar(t9_extra_min_0180) " / " %12.4f scalar(t9_extra_max_0180)

display as text "  Extra scalar diagnostic 0181: t9_expenditure m=1"
quietly summarize t9_expenditure if _mi_m == 1
scalar t9_extra_mean_0181 = r(mean)
scalar t9_extra_min_0181 = r(min)
scalar t9_extra_max_0181 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0181) " / " %12.4f scalar(t9_extra_min_0181) " / " %12.4f scalar(t9_extra_max_0181)

display as text "  Extra scalar diagnostic 0182: t9_health_score m=2"
quietly summarize t9_health_score if _mi_m == 2
scalar t9_extra_mean_0182 = r(mean)
scalar t9_extra_min_0182 = r(min)
scalar t9_extra_max_0182 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0182) " / " %12.4f scalar(t9_extra_min_0182) " / " %12.4f scalar(t9_extra_max_0182)

display as text "  Extra scalar diagnostic 0183: t9_bmi m=3"
quietly summarize t9_bmi if _mi_m == 3
scalar t9_extra_mean_0183 = r(mean)
scalar t9_extra_min_0183 = r(min)
scalar t9_extra_max_0183 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0183) " / " %12.4f scalar(t9_extra_min_0183) " / " %12.4f scalar(t9_extra_max_0183)

display as text "  Extra scalar diagnostic 0184: t9_bp_sys m=0"
quietly summarize t9_bp_sys if _mi_m == 0
scalar t9_extra_mean_0184 = r(mean)
scalar t9_extra_min_0184 = r(min)
scalar t9_extra_max_0184 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0184) " / " %12.4f scalar(t9_extra_min_0184) " / " %12.4f scalar(t9_extra_max_0184)

display as text "  Extra scalar diagnostic 0185: t9_bp_dia m=1"
quietly summarize t9_bp_dia if _mi_m == 1
scalar t9_extra_mean_0185 = r(mean)
scalar t9_extra_min_0185 = r(min)
scalar t9_extra_max_0185 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0185) " / " %12.4f scalar(t9_extra_min_0185) " / " %12.4f scalar(t9_extra_max_0185)

display as text "  Extra scalar diagnostic 0186: t9_depression m=2"
quietly summarize t9_depression if _mi_m == 2
scalar t9_extra_mean_0186 = r(mean)
scalar t9_extra_min_0186 = r(min)
scalar t9_extra_max_0186 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0186) " / " %12.4f scalar(t9_extra_min_0186) " / " %12.4f scalar(t9_extra_max_0186)

display as text "  Extra scalar diagnostic 0187: t9_stress m=3"
quietly summarize t9_stress if _mi_m == 3
scalar t9_extra_mean_0187 = r(mean)
scalar t9_extra_min_0187 = r(min)
scalar t9_extra_max_0187 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0187) " / " %12.4f scalar(t9_extra_min_0187) " / " %12.4f scalar(t9_extra_max_0187)

display as text "  Extra scalar diagnostic 0188: t9_satisfaction m=0"
quietly summarize t9_satisfaction if _mi_m == 0
scalar t9_extra_mean_0188 = r(mean)
scalar t9_extra_min_0188 = r(min)
scalar t9_extra_max_0188 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0188) " / " %12.4f scalar(t9_extra_min_0188) " / " %12.4f scalar(t9_extra_max_0188)

display as text "  Extra scalar diagnostic 0189: t9_sleep m=1"
quietly summarize t9_sleep if _mi_m == 1
scalar t9_extra_mean_0189 = r(mean)
scalar t9_extra_min_0189 = r(min)
scalar t9_extra_max_0189 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0189) " / " %12.4f scalar(t9_extra_min_0189) " / " %12.4f scalar(t9_extra_max_0189)

display as text "  Extra scalar diagnostic 0190: t9_exercise m=2"
quietly summarize t9_exercise if _mi_m == 2
scalar t9_extra_mean_0190 = r(mean)
scalar t9_extra_min_0190 = r(min)
scalar t9_extra_max_0190 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0190) " / " %12.4f scalar(t9_extra_min_0190) " / " %12.4f scalar(t9_extra_max_0190)

display as text "  Extra scalar diagnostic 0191: t9_employed m=3"
quietly summarize t9_employed if _mi_m == 3
scalar t9_extra_mean_0191 = r(mean)
scalar t9_extra_min_0191 = r(min)
scalar t9_extra_max_0191 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0191) " / " %12.4f scalar(t9_extra_min_0191) " / " %12.4f scalar(t9_extra_max_0191)

display as text "  Extra scalar diagnostic 0192: t9_married m=0"
quietly summarize t9_married if _mi_m == 0
scalar t9_extra_mean_0192 = r(mean)
scalar t9_extra_min_0192 = r(min)
scalar t9_extra_max_0192 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0192) " / " %12.4f scalar(t9_extra_min_0192) " / " %12.4f scalar(t9_extra_max_0192)

display as text "  Extra scalar diagnostic 0193: t9_urban m=1"
quietly summarize t9_urban if _mi_m == 1
scalar t9_extra_mean_0193 = r(mean)
scalar t9_extra_min_0193 = r(min)
scalar t9_extra_max_0193 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0193) " / " %12.4f scalar(t9_extra_min_0193) " / " %12.4f scalar(t9_extra_max_0193)

display as text "  Extra scalar diagnostic 0194: t9_homeowner m=2"
quietly summarize t9_homeowner if _mi_m == 2
scalar t9_extra_mean_0194 = r(mean)
scalar t9_extra_min_0194 = r(min)
scalar t9_extra_max_0194 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0194) " / " %12.4f scalar(t9_extra_min_0194) " / " %12.4f scalar(t9_extra_max_0194)

display as text "  Extra scalar diagnostic 0195: t9_insured m=3"
quietly summarize t9_insured if _mi_m == 3
scalar t9_extra_mean_0195 = r(mean)
scalar t9_extra_min_0195 = r(min)
scalar t9_extra_max_0195 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0195) " / " %12.4f scalar(t9_extra_min_0195) " / " %12.4f scalar(t9_extra_max_0195)

display as text "  Extra scalar diagnostic 0196: t9_smoker m=0"
quietly summarize t9_smoker if _mi_m == 0
scalar t9_extra_mean_0196 = r(mean)
scalar t9_extra_min_0196 = r(min)
scalar t9_extra_max_0196 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0196) " / " %12.4f scalar(t9_extra_min_0196) " / " %12.4f scalar(t9_extra_max_0196)

display as text "  Extra scalar diagnostic 0197: t9_high_income m=1"
quietly summarize t9_high_income if _mi_m == 1
scalar t9_extra_mean_0197 = r(mean)
scalar t9_extra_min_0197 = r(min)
scalar t9_extra_max_0197 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0197) " / " %12.4f scalar(t9_extra_min_0197) " / " %12.4f scalar(t9_extra_max_0197)

display as text "  Extra scalar diagnostic 0198: t9_high_stress m=2"
quietly summarize t9_high_stress if _mi_m == 2
scalar t9_extra_mean_0198 = r(mean)
scalar t9_extra_min_0198 = r(min)
scalar t9_extra_max_0198 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0198) " / " %12.4f scalar(t9_extra_min_0198) " / " %12.4f scalar(t9_extra_max_0198)

display as text "  Extra scalar diagnostic 0199: t9_unhealthy m=3"
quietly summarize t9_unhealthy if _mi_m == 3
scalar t9_extra_mean_0199 = r(mean)
scalar t9_extra_min_0199 = r(min)
scalar t9_extra_max_0199 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0199) " / " %12.4f scalar(t9_extra_min_0199) " / " %12.4f scalar(t9_extra_max_0199)

display as text "  Extra scalar diagnostic 0200: t9_educ_level m=0"
quietly summarize t9_educ_level if _mi_m == 0
scalar t9_extra_mean_0200 = r(mean)
scalar t9_extra_min_0200 = r(min)
scalar t9_extra_max_0200 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0200) " / " %12.4f scalar(t9_extra_min_0200) " / " %12.4f scalar(t9_extra_max_0200)

display as text "  Extra scalar diagnostic 0201: t9_health_level m=1"
quietly summarize t9_health_level if _mi_m == 1
scalar t9_extra_mean_0201 = r(mean)
scalar t9_extra_min_0201 = r(min)
scalar t9_extra_max_0201 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0201) " / " %12.4f scalar(t9_extra_min_0201) " / " %12.4f scalar(t9_extra_max_0201)

display as text "  Extra scalar diagnostic 0202: t9_job_sat m=2"
quietly summarize t9_job_sat if _mi_m == 2
scalar t9_extra_mean_0202 = r(mean)
scalar t9_extra_min_0202 = r(min)
scalar t9_extra_max_0202 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0202) " / " %12.4f scalar(t9_extra_min_0202) " / " %12.4f scalar(t9_extra_max_0202)

display as text "  Extra scalar diagnostic 0203: t9_children m=3"
quietly summarize t9_children if _mi_m == 3
scalar t9_extra_mean_0203 = r(mean)
scalar t9_extra_min_0203 = r(min)
scalar t9_extra_max_0203 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0203) " / " %12.4f scalar(t9_extra_min_0203) " / " %12.4f scalar(t9_extra_max_0203)

display as text "  Extra scalar diagnostic 0204: t9_doctor_visits m=0"
quietly summarize t9_doctor_visits if _mi_m == 0
scalar t9_extra_mean_0204 = r(mean)
scalar t9_extra_min_0204 = r(min)
scalar t9_extra_max_0204 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0204) " / " %12.4f scalar(t9_extra_min_0204) " / " %12.4f scalar(t9_extra_max_0204)

display as text "  Extra scalar diagnostic 0205: t9_hosp_days m=1"
quietly summarize t9_hosp_days if _mi_m == 1
scalar t9_extra_mean_0205 = r(mean)
scalar t9_extra_min_0205 = r(min)
scalar t9_extra_max_0205 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0205) " / " %12.4f scalar(t9_extra_min_0205) " / " %12.4f scalar(t9_extra_max_0205)

display as text "  Extra scalar diagnostic 0206: t9_log_income m=2"
quietly summarize t9_log_income if _mi_m == 2
scalar t9_extra_mean_0206 = r(mean)
scalar t9_extra_min_0206 = r(min)
scalar t9_extra_max_0206 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0206) " / " %12.4f scalar(t9_extra_min_0206) " / " %12.4f scalar(t9_extra_max_0206)

display as text "  Extra scalar diagnostic 0207: t9_log_wage m=3"
quietly summarize t9_log_wage if _mi_m == 3
scalar t9_extra_mean_0207 = r(mean)
scalar t9_extra_min_0207 = r(min)
scalar t9_extra_max_0207 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0207) " / " %12.4f scalar(t9_extra_min_0207) " / " %12.4f scalar(t9_extra_max_0207)

display as text "  Extra scalar diagnostic 0208: t9_income_per_hour m=0"
quietly summarize t9_income_per_hour if _mi_m == 0
scalar t9_extra_mean_0208 = r(mean)
scalar t9_extra_min_0208 = r(min)
scalar t9_extra_max_0208 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0208) " / " %12.4f scalar(t9_extra_min_0208) " / " %12.4f scalar(t9_extra_max_0208)

display as text "  Extra scalar diagnostic 0209: t9_health_index m=1"
quietly summarize t9_health_index if _mi_m == 1
scalar t9_extra_mean_0209 = r(mean)
scalar t9_extra_min_0209 = r(min)
scalar t9_extra_max_0209 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0209) " / " %12.4f scalar(t9_extra_min_0209) " / " %12.4f scalar(t9_extra_max_0209)

display as text "  Extra scalar diagnostic 0210: t9_dep_stress m=2"
quietly summarize t9_dep_stress if _mi_m == 2
scalar t9_extra_mean_0210 = r(mean)
scalar t9_extra_min_0210 = r(min)
scalar t9_extra_max_0210 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0210) " / " %12.4f scalar(t9_extra_min_0210) " / " %12.4f scalar(t9_extra_max_0210)

display as text "  Extra scalar diagnostic 0211: t9_income m=3"
quietly summarize t9_income if _mi_m == 3
scalar t9_extra_mean_0211 = r(mean)
scalar t9_extra_min_0211 = r(min)
scalar t9_extra_max_0211 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0211) " / " %12.4f scalar(t9_extra_min_0211) " / " %12.4f scalar(t9_extra_max_0211)

display as text "  Extra scalar diagnostic 0212: t9_wage m=0"
quietly summarize t9_wage if _mi_m == 0
scalar t9_extra_mean_0212 = r(mean)
scalar t9_extra_min_0212 = r(min)
scalar t9_extra_max_0212 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0212) " / " %12.4f scalar(t9_extra_min_0212) " / " %12.4f scalar(t9_extra_max_0212)

display as text "  Extra scalar diagnostic 0213: t9_hours m=1"
quietly summarize t9_hours if _mi_m == 1
scalar t9_extra_mean_0213 = r(mean)
scalar t9_extra_min_0213 = r(min)
scalar t9_extra_max_0213 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0213) " / " %12.4f scalar(t9_extra_min_0213) " / " %12.4f scalar(t9_extra_max_0213)

display as text "  Extra scalar diagnostic 0214: t9_wealth m=2"
quietly summarize t9_wealth if _mi_m == 2
scalar t9_extra_mean_0214 = r(mean)
scalar t9_extra_min_0214 = r(min)
scalar t9_extra_max_0214 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0214) " / " %12.4f scalar(t9_extra_min_0214) " / " %12.4f scalar(t9_extra_max_0214)

display as text "  Extra scalar diagnostic 0215: t9_savings m=3"
quietly summarize t9_savings if _mi_m == 3
scalar t9_extra_mean_0215 = r(mean)
scalar t9_extra_min_0215 = r(min)
scalar t9_extra_max_0215 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0215) " / " %12.4f scalar(t9_extra_min_0215) " / " %12.4f scalar(t9_extra_max_0215)

display as text "  Extra scalar diagnostic 0216: t9_expenditure m=0"
quietly summarize t9_expenditure if _mi_m == 0
scalar t9_extra_mean_0216 = r(mean)
scalar t9_extra_min_0216 = r(min)
scalar t9_extra_max_0216 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0216) " / " %12.4f scalar(t9_extra_min_0216) " / " %12.4f scalar(t9_extra_max_0216)

display as text "  Extra scalar diagnostic 0217: t9_health_score m=1"
quietly summarize t9_health_score if _mi_m == 1
scalar t9_extra_mean_0217 = r(mean)
scalar t9_extra_min_0217 = r(min)
scalar t9_extra_max_0217 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0217) " / " %12.4f scalar(t9_extra_min_0217) " / " %12.4f scalar(t9_extra_max_0217)

display as text "  Extra scalar diagnostic 0218: t9_bmi m=2"
quietly summarize t9_bmi if _mi_m == 2
scalar t9_extra_mean_0218 = r(mean)
scalar t9_extra_min_0218 = r(min)
scalar t9_extra_max_0218 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0218) " / " %12.4f scalar(t9_extra_min_0218) " / " %12.4f scalar(t9_extra_max_0218)

display as text "  Extra scalar diagnostic 0219: t9_bp_sys m=3"
quietly summarize t9_bp_sys if _mi_m == 3
scalar t9_extra_mean_0219 = r(mean)
scalar t9_extra_min_0219 = r(min)
scalar t9_extra_max_0219 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0219) " / " %12.4f scalar(t9_extra_min_0219) " / " %12.4f scalar(t9_extra_max_0219)

display as text "  Extra scalar diagnostic 0220: t9_bp_dia m=0"
quietly summarize t9_bp_dia if _mi_m == 0
scalar t9_extra_mean_0220 = r(mean)
scalar t9_extra_min_0220 = r(min)
scalar t9_extra_max_0220 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0220) " / " %12.4f scalar(t9_extra_min_0220) " / " %12.4f scalar(t9_extra_max_0220)

display as text "  Extra scalar diagnostic 0221: t9_depression m=1"
quietly summarize t9_depression if _mi_m == 1
scalar t9_extra_mean_0221 = r(mean)
scalar t9_extra_min_0221 = r(min)
scalar t9_extra_max_0221 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0221) " / " %12.4f scalar(t9_extra_min_0221) " / " %12.4f scalar(t9_extra_max_0221)

display as text "  Extra scalar diagnostic 0222: t9_stress m=2"
quietly summarize t9_stress if _mi_m == 2
scalar t9_extra_mean_0222 = r(mean)
scalar t9_extra_min_0222 = r(min)
scalar t9_extra_max_0222 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0222) " / " %12.4f scalar(t9_extra_min_0222) " / " %12.4f scalar(t9_extra_max_0222)

display as text "  Extra scalar diagnostic 0223: t9_satisfaction m=3"
quietly summarize t9_satisfaction if _mi_m == 3
scalar t9_extra_mean_0223 = r(mean)
scalar t9_extra_min_0223 = r(min)
scalar t9_extra_max_0223 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0223) " / " %12.4f scalar(t9_extra_min_0223) " / " %12.4f scalar(t9_extra_max_0223)

display as text "  Extra scalar diagnostic 0224: t9_sleep m=0"
quietly summarize t9_sleep if _mi_m == 0
scalar t9_extra_mean_0224 = r(mean)
scalar t9_extra_min_0224 = r(min)
scalar t9_extra_max_0224 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0224) " / " %12.4f scalar(t9_extra_min_0224) " / " %12.4f scalar(t9_extra_max_0224)

display as text "  Extra scalar diagnostic 0225: t9_exercise m=1"
quietly summarize t9_exercise if _mi_m == 1
scalar t9_extra_mean_0225 = r(mean)
scalar t9_extra_min_0225 = r(min)
scalar t9_extra_max_0225 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0225) " / " %12.4f scalar(t9_extra_min_0225) " / " %12.4f scalar(t9_extra_max_0225)

display as text "  Extra scalar diagnostic 0226: t9_employed m=2"
quietly summarize t9_employed if _mi_m == 2
scalar t9_extra_mean_0226 = r(mean)
scalar t9_extra_min_0226 = r(min)
scalar t9_extra_max_0226 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0226) " / " %12.4f scalar(t9_extra_min_0226) " / " %12.4f scalar(t9_extra_max_0226)

display as text "  Extra scalar diagnostic 0227: t9_married m=3"
quietly summarize t9_married if _mi_m == 3
scalar t9_extra_mean_0227 = r(mean)
scalar t9_extra_min_0227 = r(min)
scalar t9_extra_max_0227 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0227) " / " %12.4f scalar(t9_extra_min_0227) " / " %12.4f scalar(t9_extra_max_0227)

display as text "  Extra scalar diagnostic 0228: t9_urban m=0"
quietly summarize t9_urban if _mi_m == 0
scalar t9_extra_mean_0228 = r(mean)
scalar t9_extra_min_0228 = r(min)
scalar t9_extra_max_0228 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0228) " / " %12.4f scalar(t9_extra_min_0228) " / " %12.4f scalar(t9_extra_max_0228)

display as text "  Extra scalar diagnostic 0229: t9_homeowner m=1"
quietly summarize t9_homeowner if _mi_m == 1
scalar t9_extra_mean_0229 = r(mean)
scalar t9_extra_min_0229 = r(min)
scalar t9_extra_max_0229 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0229) " / " %12.4f scalar(t9_extra_min_0229) " / " %12.4f scalar(t9_extra_max_0229)

display as text "  Extra scalar diagnostic 0230: t9_insured m=2"
quietly summarize t9_insured if _mi_m == 2
scalar t9_extra_mean_0230 = r(mean)
scalar t9_extra_min_0230 = r(min)
scalar t9_extra_max_0230 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0230) " / " %12.4f scalar(t9_extra_min_0230) " / " %12.4f scalar(t9_extra_max_0230)

display as text "  Extra scalar diagnostic 0231: t9_smoker m=3"
quietly summarize t9_smoker if _mi_m == 3
scalar t9_extra_mean_0231 = r(mean)
scalar t9_extra_min_0231 = r(min)
scalar t9_extra_max_0231 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0231) " / " %12.4f scalar(t9_extra_min_0231) " / " %12.4f scalar(t9_extra_max_0231)

display as text "  Extra scalar diagnostic 0232: t9_high_income m=0"
quietly summarize t9_high_income if _mi_m == 0
scalar t9_extra_mean_0232 = r(mean)
scalar t9_extra_min_0232 = r(min)
scalar t9_extra_max_0232 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0232) " / " %12.4f scalar(t9_extra_min_0232) " / " %12.4f scalar(t9_extra_max_0232)

display as text "  Extra scalar diagnostic 0233: t9_high_stress m=1"
quietly summarize t9_high_stress if _mi_m == 1
scalar t9_extra_mean_0233 = r(mean)
scalar t9_extra_min_0233 = r(min)
scalar t9_extra_max_0233 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0233) " / " %12.4f scalar(t9_extra_min_0233) " / " %12.4f scalar(t9_extra_max_0233)

display as text "  Extra scalar diagnostic 0234: t9_unhealthy m=2"
quietly summarize t9_unhealthy if _mi_m == 2
scalar t9_extra_mean_0234 = r(mean)
scalar t9_extra_min_0234 = r(min)
scalar t9_extra_max_0234 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0234) " / " %12.4f scalar(t9_extra_min_0234) " / " %12.4f scalar(t9_extra_max_0234)

display as text "  Extra scalar diagnostic 0235: t9_educ_level m=3"
quietly summarize t9_educ_level if _mi_m == 3
scalar t9_extra_mean_0235 = r(mean)
scalar t9_extra_min_0235 = r(min)
scalar t9_extra_max_0235 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0235) " / " %12.4f scalar(t9_extra_min_0235) " / " %12.4f scalar(t9_extra_max_0235)

display as text "  Extra scalar diagnostic 0236: t9_health_level m=0"
quietly summarize t9_health_level if _mi_m == 0
scalar t9_extra_mean_0236 = r(mean)
scalar t9_extra_min_0236 = r(min)
scalar t9_extra_max_0236 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0236) " / " %12.4f scalar(t9_extra_min_0236) " / " %12.4f scalar(t9_extra_max_0236)

display as text "  Extra scalar diagnostic 0237: t9_job_sat m=1"
quietly summarize t9_job_sat if _mi_m == 1
scalar t9_extra_mean_0237 = r(mean)
scalar t9_extra_min_0237 = r(min)
scalar t9_extra_max_0237 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0237) " / " %12.4f scalar(t9_extra_min_0237) " / " %12.4f scalar(t9_extra_max_0237)

display as text "  Extra scalar diagnostic 0238: t9_children m=2"
quietly summarize t9_children if _mi_m == 2
scalar t9_extra_mean_0238 = r(mean)
scalar t9_extra_min_0238 = r(min)
scalar t9_extra_max_0238 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0238) " / " %12.4f scalar(t9_extra_min_0238) " / " %12.4f scalar(t9_extra_max_0238)

display as text "  Extra scalar diagnostic 0239: t9_doctor_visits m=3"
quietly summarize t9_doctor_visits if _mi_m == 3
scalar t9_extra_mean_0239 = r(mean)
scalar t9_extra_min_0239 = r(min)
scalar t9_extra_max_0239 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0239) " / " %12.4f scalar(t9_extra_min_0239) " / " %12.4f scalar(t9_extra_max_0239)

display as text "  Extra scalar diagnostic 0240: t9_hosp_days m=0"
quietly summarize t9_hosp_days if _mi_m == 0
scalar t9_extra_mean_0240 = r(mean)
scalar t9_extra_min_0240 = r(min)
scalar t9_extra_max_0240 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0240) " / " %12.4f scalar(t9_extra_min_0240) " / " %12.4f scalar(t9_extra_max_0240)

display as text "  Extra scalar diagnostic 0241: t9_log_income m=1"
quietly summarize t9_log_income if _mi_m == 1
scalar t9_extra_mean_0241 = r(mean)
scalar t9_extra_min_0241 = r(min)
scalar t9_extra_max_0241 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0241) " / " %12.4f scalar(t9_extra_min_0241) " / " %12.4f scalar(t9_extra_max_0241)

display as text "  Extra scalar diagnostic 0242: t9_log_wage m=2"
quietly summarize t9_log_wage if _mi_m == 2
scalar t9_extra_mean_0242 = r(mean)
scalar t9_extra_min_0242 = r(min)
scalar t9_extra_max_0242 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0242) " / " %12.4f scalar(t9_extra_min_0242) " / " %12.4f scalar(t9_extra_max_0242)

display as text "  Extra scalar diagnostic 0243: t9_income_per_hour m=3"
quietly summarize t9_income_per_hour if _mi_m == 3
scalar t9_extra_mean_0243 = r(mean)
scalar t9_extra_min_0243 = r(min)
scalar t9_extra_max_0243 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0243) " / " %12.4f scalar(t9_extra_min_0243) " / " %12.4f scalar(t9_extra_max_0243)

display as text "  Extra scalar diagnostic 0244: t9_health_index m=0"
quietly summarize t9_health_index if _mi_m == 0
scalar t9_extra_mean_0244 = r(mean)
scalar t9_extra_min_0244 = r(min)
scalar t9_extra_max_0244 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0244) " / " %12.4f scalar(t9_extra_min_0244) " / " %12.4f scalar(t9_extra_max_0244)

display as text "  Extra scalar diagnostic 0245: t9_dep_stress m=1"
quietly summarize t9_dep_stress if _mi_m == 1
scalar t9_extra_mean_0245 = r(mean)
scalar t9_extra_min_0245 = r(min)
scalar t9_extra_max_0245 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0245) " / " %12.4f scalar(t9_extra_min_0245) " / " %12.4f scalar(t9_extra_max_0245)

display as text "  Extra scalar diagnostic 0246: t9_income m=2"
quietly summarize t9_income if _mi_m == 2
scalar t9_extra_mean_0246 = r(mean)
scalar t9_extra_min_0246 = r(min)
scalar t9_extra_max_0246 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0246) " / " %12.4f scalar(t9_extra_min_0246) " / " %12.4f scalar(t9_extra_max_0246)

display as text "  Extra scalar diagnostic 0247: t9_wage m=3"
quietly summarize t9_wage if _mi_m == 3
scalar t9_extra_mean_0247 = r(mean)
scalar t9_extra_min_0247 = r(min)
scalar t9_extra_max_0247 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0247) " / " %12.4f scalar(t9_extra_min_0247) " / " %12.4f scalar(t9_extra_max_0247)

display as text "  Extra scalar diagnostic 0248: t9_hours m=0"
quietly summarize t9_hours if _mi_m == 0
scalar t9_extra_mean_0248 = r(mean)
scalar t9_extra_min_0248 = r(min)
scalar t9_extra_max_0248 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0248) " / " %12.4f scalar(t9_extra_min_0248) " / " %12.4f scalar(t9_extra_max_0248)

display as text "  Extra scalar diagnostic 0249: t9_wealth m=1"
quietly summarize t9_wealth if _mi_m == 1
scalar t9_extra_mean_0249 = r(mean)
scalar t9_extra_min_0249 = r(min)
scalar t9_extra_max_0249 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0249) " / " %12.4f scalar(t9_extra_min_0249) " / " %12.4f scalar(t9_extra_max_0249)

display as text "  Extra scalar diagnostic 0250: t9_savings m=2"
quietly summarize t9_savings if _mi_m == 2
scalar t9_extra_mean_0250 = r(mean)
scalar t9_extra_min_0250 = r(min)
scalar t9_extra_max_0250 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0250) " / " %12.4f scalar(t9_extra_min_0250) " / " %12.4f scalar(t9_extra_max_0250)

display as text "  Extra scalar diagnostic 0251: t9_expenditure m=3"
quietly summarize t9_expenditure if _mi_m == 3
scalar t9_extra_mean_0251 = r(mean)
scalar t9_extra_min_0251 = r(min)
scalar t9_extra_max_0251 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0251) " / " %12.4f scalar(t9_extra_min_0251) " / " %12.4f scalar(t9_extra_max_0251)

display as text "  Extra scalar diagnostic 0252: t9_health_score m=0"
quietly summarize t9_health_score if _mi_m == 0
scalar t9_extra_mean_0252 = r(mean)
scalar t9_extra_min_0252 = r(min)
scalar t9_extra_max_0252 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0252) " / " %12.4f scalar(t9_extra_min_0252) " / " %12.4f scalar(t9_extra_max_0252)

display as text "  Extra scalar diagnostic 0253: t9_bmi m=1"
quietly summarize t9_bmi if _mi_m == 1
scalar t9_extra_mean_0253 = r(mean)
scalar t9_extra_min_0253 = r(min)
scalar t9_extra_max_0253 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0253) " / " %12.4f scalar(t9_extra_min_0253) " / " %12.4f scalar(t9_extra_max_0253)

display as text "  Extra scalar diagnostic 0254: t9_bp_sys m=2"
quietly summarize t9_bp_sys if _mi_m == 2
scalar t9_extra_mean_0254 = r(mean)
scalar t9_extra_min_0254 = r(min)
scalar t9_extra_max_0254 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0254) " / " %12.4f scalar(t9_extra_min_0254) " / " %12.4f scalar(t9_extra_max_0254)

display as text "  Extra scalar diagnostic 0255: t9_bp_dia m=3"
quietly summarize t9_bp_dia if _mi_m == 3
scalar t9_extra_mean_0255 = r(mean)
scalar t9_extra_min_0255 = r(min)
scalar t9_extra_max_0255 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0255) " / " %12.4f scalar(t9_extra_min_0255) " / " %12.4f scalar(t9_extra_max_0255)

display as text "  Extra scalar diagnostic 0256: t9_depression m=0"
quietly summarize t9_depression if _mi_m == 0
scalar t9_extra_mean_0256 = r(mean)
scalar t9_extra_min_0256 = r(min)
scalar t9_extra_max_0256 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0256) " / " %12.4f scalar(t9_extra_min_0256) " / " %12.4f scalar(t9_extra_max_0256)

display as text "  Extra scalar diagnostic 0257: t9_stress m=1"
quietly summarize t9_stress if _mi_m == 1
scalar t9_extra_mean_0257 = r(mean)
scalar t9_extra_min_0257 = r(min)
scalar t9_extra_max_0257 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0257) " / " %12.4f scalar(t9_extra_min_0257) " / " %12.4f scalar(t9_extra_max_0257)

display as text "  Extra scalar diagnostic 0258: t9_satisfaction m=2"
quietly summarize t9_satisfaction if _mi_m == 2
scalar t9_extra_mean_0258 = r(mean)
scalar t9_extra_min_0258 = r(min)
scalar t9_extra_max_0258 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0258) " / " %12.4f scalar(t9_extra_min_0258) " / " %12.4f scalar(t9_extra_max_0258)

display as text "  Extra scalar diagnostic 0259: t9_sleep m=3"
quietly summarize t9_sleep if _mi_m == 3
scalar t9_extra_mean_0259 = r(mean)
scalar t9_extra_min_0259 = r(min)
scalar t9_extra_max_0259 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0259) " / " %12.4f scalar(t9_extra_min_0259) " / " %12.4f scalar(t9_extra_max_0259)

display as text "  Extra scalar diagnostic 0260: t9_exercise m=0"
quietly summarize t9_exercise if _mi_m == 0
scalar t9_extra_mean_0260 = r(mean)
scalar t9_extra_min_0260 = r(min)
scalar t9_extra_max_0260 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0260) " / " %12.4f scalar(t9_extra_min_0260) " / " %12.4f scalar(t9_extra_max_0260)

display as text "  Extra scalar diagnostic 0261: t9_employed m=1"
quietly summarize t9_employed if _mi_m == 1
scalar t9_extra_mean_0261 = r(mean)
scalar t9_extra_min_0261 = r(min)
scalar t9_extra_max_0261 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0261) " / " %12.4f scalar(t9_extra_min_0261) " / " %12.4f scalar(t9_extra_max_0261)

display as text "  Extra scalar diagnostic 0262: t9_married m=2"
quietly summarize t9_married if _mi_m == 2
scalar t9_extra_mean_0262 = r(mean)
scalar t9_extra_min_0262 = r(min)
scalar t9_extra_max_0262 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0262) " / " %12.4f scalar(t9_extra_min_0262) " / " %12.4f scalar(t9_extra_max_0262)

display as text "  Extra scalar diagnostic 0263: t9_urban m=3"
quietly summarize t9_urban if _mi_m == 3
scalar t9_extra_mean_0263 = r(mean)
scalar t9_extra_min_0263 = r(min)
scalar t9_extra_max_0263 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0263) " / " %12.4f scalar(t9_extra_min_0263) " / " %12.4f scalar(t9_extra_max_0263)

display as text "  Extra scalar diagnostic 0264: t9_homeowner m=0"
quietly summarize t9_homeowner if _mi_m == 0
scalar t9_extra_mean_0264 = r(mean)
scalar t9_extra_min_0264 = r(min)
scalar t9_extra_max_0264 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0264) " / " %12.4f scalar(t9_extra_min_0264) " / " %12.4f scalar(t9_extra_max_0264)

display as text "  Extra scalar diagnostic 0265: t9_insured m=1"
quietly summarize t9_insured if _mi_m == 1
scalar t9_extra_mean_0265 = r(mean)
scalar t9_extra_min_0265 = r(min)
scalar t9_extra_max_0265 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0265) " / " %12.4f scalar(t9_extra_min_0265) " / " %12.4f scalar(t9_extra_max_0265)

display as text "  Extra scalar diagnostic 0266: t9_smoker m=2"
quietly summarize t9_smoker if _mi_m == 2
scalar t9_extra_mean_0266 = r(mean)
scalar t9_extra_min_0266 = r(min)
scalar t9_extra_max_0266 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0266) " / " %12.4f scalar(t9_extra_min_0266) " / " %12.4f scalar(t9_extra_max_0266)

display as text "  Extra scalar diagnostic 0267: t9_high_income m=3"
quietly summarize t9_high_income if _mi_m == 3
scalar t9_extra_mean_0267 = r(mean)
scalar t9_extra_min_0267 = r(min)
scalar t9_extra_max_0267 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0267) " / " %12.4f scalar(t9_extra_min_0267) " / " %12.4f scalar(t9_extra_max_0267)

display as text "  Extra scalar diagnostic 0268: t9_high_stress m=0"
quietly summarize t9_high_stress if _mi_m == 0
scalar t9_extra_mean_0268 = r(mean)
scalar t9_extra_min_0268 = r(min)
scalar t9_extra_max_0268 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0268) " / " %12.4f scalar(t9_extra_min_0268) " / " %12.4f scalar(t9_extra_max_0268)

display as text "  Extra scalar diagnostic 0269: t9_unhealthy m=1"
quietly summarize t9_unhealthy if _mi_m == 1
scalar t9_extra_mean_0269 = r(mean)
scalar t9_extra_min_0269 = r(min)
scalar t9_extra_max_0269 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0269) " / " %12.4f scalar(t9_extra_min_0269) " / " %12.4f scalar(t9_extra_max_0269)

display as text "  Extra scalar diagnostic 0270: t9_educ_level m=2"
quietly summarize t9_educ_level if _mi_m == 2
scalar t9_extra_mean_0270 = r(mean)
scalar t9_extra_min_0270 = r(min)
scalar t9_extra_max_0270 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0270) " / " %12.4f scalar(t9_extra_min_0270) " / " %12.4f scalar(t9_extra_max_0270)

display as text "  Extra scalar diagnostic 0271: t9_health_level m=3"
quietly summarize t9_health_level if _mi_m == 3
scalar t9_extra_mean_0271 = r(mean)
scalar t9_extra_min_0271 = r(min)
scalar t9_extra_max_0271 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0271) " / " %12.4f scalar(t9_extra_min_0271) " / " %12.4f scalar(t9_extra_max_0271)

display as text "  Extra scalar diagnostic 0272: t9_job_sat m=0"
quietly summarize t9_job_sat if _mi_m == 0
scalar t9_extra_mean_0272 = r(mean)
scalar t9_extra_min_0272 = r(min)
scalar t9_extra_max_0272 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0272) " / " %12.4f scalar(t9_extra_min_0272) " / " %12.4f scalar(t9_extra_max_0272)

display as text "  Extra scalar diagnostic 0273: t9_children m=1"
quietly summarize t9_children if _mi_m == 1
scalar t9_extra_mean_0273 = r(mean)
scalar t9_extra_min_0273 = r(min)
scalar t9_extra_max_0273 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0273) " / " %12.4f scalar(t9_extra_min_0273) " / " %12.4f scalar(t9_extra_max_0273)

display as text "  Extra scalar diagnostic 0274: t9_doctor_visits m=2"
quietly summarize t9_doctor_visits if _mi_m == 2
scalar t9_extra_mean_0274 = r(mean)
scalar t9_extra_min_0274 = r(min)
scalar t9_extra_max_0274 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0274) " / " %12.4f scalar(t9_extra_min_0274) " / " %12.4f scalar(t9_extra_max_0274)

display as text "  Extra scalar diagnostic 0275: t9_hosp_days m=3"
quietly summarize t9_hosp_days if _mi_m == 3
scalar t9_extra_mean_0275 = r(mean)
scalar t9_extra_min_0275 = r(min)
scalar t9_extra_max_0275 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0275) " / " %12.4f scalar(t9_extra_min_0275) " / " %12.4f scalar(t9_extra_max_0275)

display as text "  Extra scalar diagnostic 0276: t9_log_income m=0"
quietly summarize t9_log_income if _mi_m == 0
scalar t9_extra_mean_0276 = r(mean)
scalar t9_extra_min_0276 = r(min)
scalar t9_extra_max_0276 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0276) " / " %12.4f scalar(t9_extra_min_0276) " / " %12.4f scalar(t9_extra_max_0276)

display as text "  Extra scalar diagnostic 0277: t9_log_wage m=1"
quietly summarize t9_log_wage if _mi_m == 1
scalar t9_extra_mean_0277 = r(mean)
scalar t9_extra_min_0277 = r(min)
scalar t9_extra_max_0277 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0277) " / " %12.4f scalar(t9_extra_min_0277) " / " %12.4f scalar(t9_extra_max_0277)

display as text "  Extra scalar diagnostic 0278: t9_income_per_hour m=2"
quietly summarize t9_income_per_hour if _mi_m == 2
scalar t9_extra_mean_0278 = r(mean)
scalar t9_extra_min_0278 = r(min)
scalar t9_extra_max_0278 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0278) " / " %12.4f scalar(t9_extra_min_0278) " / " %12.4f scalar(t9_extra_max_0278)

display as text "  Extra scalar diagnostic 0279: t9_health_index m=3"
quietly summarize t9_health_index if _mi_m == 3
scalar t9_extra_mean_0279 = r(mean)
scalar t9_extra_min_0279 = r(min)
scalar t9_extra_max_0279 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0279) " / " %12.4f scalar(t9_extra_min_0279) " / " %12.4f scalar(t9_extra_max_0279)

display as text "  Extra scalar diagnostic 0280: t9_dep_stress m=0"
quietly summarize t9_dep_stress if _mi_m == 0
scalar t9_extra_mean_0280 = r(mean)
scalar t9_extra_min_0280 = r(min)
scalar t9_extra_max_0280 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0280) " / " %12.4f scalar(t9_extra_min_0280) " / " %12.4f scalar(t9_extra_max_0280)

display as text "  Extra scalar diagnostic 0281: t9_income m=1"
quietly summarize t9_income if _mi_m == 1
scalar t9_extra_mean_0281 = r(mean)
scalar t9_extra_min_0281 = r(min)
scalar t9_extra_max_0281 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0281) " / " %12.4f scalar(t9_extra_min_0281) " / " %12.4f scalar(t9_extra_max_0281)

display as text "  Extra scalar diagnostic 0282: t9_wage m=2"
quietly summarize t9_wage if _mi_m == 2
scalar t9_extra_mean_0282 = r(mean)
scalar t9_extra_min_0282 = r(min)
scalar t9_extra_max_0282 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0282) " / " %12.4f scalar(t9_extra_min_0282) " / " %12.4f scalar(t9_extra_max_0282)

display as text "  Extra scalar diagnostic 0283: t9_hours m=3"
quietly summarize t9_hours if _mi_m == 3
scalar t9_extra_mean_0283 = r(mean)
scalar t9_extra_min_0283 = r(min)
scalar t9_extra_max_0283 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0283) " / " %12.4f scalar(t9_extra_min_0283) " / " %12.4f scalar(t9_extra_max_0283)

display as text "  Extra scalar diagnostic 0284: t9_wealth m=0"
quietly summarize t9_wealth if _mi_m == 0
scalar t9_extra_mean_0284 = r(mean)
scalar t9_extra_min_0284 = r(min)
scalar t9_extra_max_0284 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0284) " / " %12.4f scalar(t9_extra_min_0284) " / " %12.4f scalar(t9_extra_max_0284)

display as text "  Extra scalar diagnostic 0285: t9_savings m=1"
quietly summarize t9_savings if _mi_m == 1
scalar t9_extra_mean_0285 = r(mean)
scalar t9_extra_min_0285 = r(min)
scalar t9_extra_max_0285 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0285) " / " %12.4f scalar(t9_extra_min_0285) " / " %12.4f scalar(t9_extra_max_0285)

display as text "  Extra scalar diagnostic 0286: t9_expenditure m=2"
quietly summarize t9_expenditure if _mi_m == 2
scalar t9_extra_mean_0286 = r(mean)
scalar t9_extra_min_0286 = r(min)
scalar t9_extra_max_0286 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0286) " / " %12.4f scalar(t9_extra_min_0286) " / " %12.4f scalar(t9_extra_max_0286)

display as text "  Extra scalar diagnostic 0287: t9_health_score m=3"
quietly summarize t9_health_score if _mi_m == 3
scalar t9_extra_mean_0287 = r(mean)
scalar t9_extra_min_0287 = r(min)
scalar t9_extra_max_0287 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0287) " / " %12.4f scalar(t9_extra_min_0287) " / " %12.4f scalar(t9_extra_max_0287)

display as text "  Extra scalar diagnostic 0288: t9_bmi m=0"
quietly summarize t9_bmi if _mi_m == 0
scalar t9_extra_mean_0288 = r(mean)
scalar t9_extra_min_0288 = r(min)
scalar t9_extra_max_0288 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0288) " / " %12.4f scalar(t9_extra_min_0288) " / " %12.4f scalar(t9_extra_max_0288)

display as text "  Extra scalar diagnostic 0289: t9_bp_sys m=1"
quietly summarize t9_bp_sys if _mi_m == 1
scalar t9_extra_mean_0289 = r(mean)
scalar t9_extra_min_0289 = r(min)
scalar t9_extra_max_0289 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0289) " / " %12.4f scalar(t9_extra_min_0289) " / " %12.4f scalar(t9_extra_max_0289)

display as text "  Extra scalar diagnostic 0290: t9_bp_dia m=2"
quietly summarize t9_bp_dia if _mi_m == 2
scalar t9_extra_mean_0290 = r(mean)
scalar t9_extra_min_0290 = r(min)
scalar t9_extra_max_0290 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0290) " / " %12.4f scalar(t9_extra_min_0290) " / " %12.4f scalar(t9_extra_max_0290)

display as text "  Extra scalar diagnostic 0291: t9_depression m=3"
quietly summarize t9_depression if _mi_m == 3
scalar t9_extra_mean_0291 = r(mean)
scalar t9_extra_min_0291 = r(min)
scalar t9_extra_max_0291 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0291) " / " %12.4f scalar(t9_extra_min_0291) " / " %12.4f scalar(t9_extra_max_0291)

display as text "  Extra scalar diagnostic 0292: t9_stress m=0"
quietly summarize t9_stress if _mi_m == 0
scalar t9_extra_mean_0292 = r(mean)
scalar t9_extra_min_0292 = r(min)
scalar t9_extra_max_0292 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0292) " / " %12.4f scalar(t9_extra_min_0292) " / " %12.4f scalar(t9_extra_max_0292)

display as text "  Extra scalar diagnostic 0293: t9_satisfaction m=1"
quietly summarize t9_satisfaction if _mi_m == 1
scalar t9_extra_mean_0293 = r(mean)
scalar t9_extra_min_0293 = r(min)
scalar t9_extra_max_0293 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0293) " / " %12.4f scalar(t9_extra_min_0293) " / " %12.4f scalar(t9_extra_max_0293)

display as text "  Extra scalar diagnostic 0294: t9_sleep m=2"
quietly summarize t9_sleep if _mi_m == 2
scalar t9_extra_mean_0294 = r(mean)
scalar t9_extra_min_0294 = r(min)
scalar t9_extra_max_0294 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0294) " / " %12.4f scalar(t9_extra_min_0294) " / " %12.4f scalar(t9_extra_max_0294)

display as text "  Extra scalar diagnostic 0295: t9_exercise m=3"
quietly summarize t9_exercise if _mi_m == 3
scalar t9_extra_mean_0295 = r(mean)
scalar t9_extra_min_0295 = r(min)
scalar t9_extra_max_0295 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0295) " / " %12.4f scalar(t9_extra_min_0295) " / " %12.4f scalar(t9_extra_max_0295)

display as text "  Extra scalar diagnostic 0296: t9_employed m=0"
quietly summarize t9_employed if _mi_m == 0
scalar t9_extra_mean_0296 = r(mean)
scalar t9_extra_min_0296 = r(min)
scalar t9_extra_max_0296 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0296) " / " %12.4f scalar(t9_extra_min_0296) " / " %12.4f scalar(t9_extra_max_0296)

display as text "  Extra scalar diagnostic 0297: t9_married m=1"
quietly summarize t9_married if _mi_m == 1
scalar t9_extra_mean_0297 = r(mean)
scalar t9_extra_min_0297 = r(min)
scalar t9_extra_max_0297 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0297) " / " %12.4f scalar(t9_extra_min_0297) " / " %12.4f scalar(t9_extra_max_0297)

display as text "  Extra scalar diagnostic 0298: t9_urban m=2"
quietly summarize t9_urban if _mi_m == 2
scalar t9_extra_mean_0298 = r(mean)
scalar t9_extra_min_0298 = r(min)
scalar t9_extra_max_0298 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0298) " / " %12.4f scalar(t9_extra_min_0298) " / " %12.4f scalar(t9_extra_max_0298)

display as text "  Extra scalar diagnostic 0299: t9_homeowner m=3"
quietly summarize t9_homeowner if _mi_m == 3
scalar t9_extra_mean_0299 = r(mean)
scalar t9_extra_min_0299 = r(min)
scalar t9_extra_max_0299 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0299) " / " %12.4f scalar(t9_extra_min_0299) " / " %12.4f scalar(t9_extra_max_0299)

display as text "  Extra scalar diagnostic 0300: t9_insured m=0"
quietly summarize t9_insured if _mi_m == 0
scalar t9_extra_mean_0300 = r(mean)
scalar t9_extra_min_0300 = r(min)
scalar t9_extra_max_0300 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0300) " / " %12.4f scalar(t9_extra_min_0300) " / " %12.4f scalar(t9_extra_max_0300)

display as text "  Extra scalar diagnostic 0301: t9_smoker m=1"
quietly summarize t9_smoker if _mi_m == 1
scalar t9_extra_mean_0301 = r(mean)
scalar t9_extra_min_0301 = r(min)
scalar t9_extra_max_0301 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0301) " / " %12.4f scalar(t9_extra_min_0301) " / " %12.4f scalar(t9_extra_max_0301)

display as text "  Extra scalar diagnostic 0302: t9_high_income m=2"
quietly summarize t9_high_income if _mi_m == 2
scalar t9_extra_mean_0302 = r(mean)
scalar t9_extra_min_0302 = r(min)
scalar t9_extra_max_0302 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0302) " / " %12.4f scalar(t9_extra_min_0302) " / " %12.4f scalar(t9_extra_max_0302)

display as text "  Extra scalar diagnostic 0303: t9_high_stress m=3"
quietly summarize t9_high_stress if _mi_m == 3
scalar t9_extra_mean_0303 = r(mean)
scalar t9_extra_min_0303 = r(min)
scalar t9_extra_max_0303 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0303) " / " %12.4f scalar(t9_extra_min_0303) " / " %12.4f scalar(t9_extra_max_0303)

display as text "  Extra scalar diagnostic 0304: t9_unhealthy m=0"
quietly summarize t9_unhealthy if _mi_m == 0
scalar t9_extra_mean_0304 = r(mean)
scalar t9_extra_min_0304 = r(min)
scalar t9_extra_max_0304 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0304) " / " %12.4f scalar(t9_extra_min_0304) " / " %12.4f scalar(t9_extra_max_0304)

display as text "  Extra scalar diagnostic 0305: t9_educ_level m=1"
quietly summarize t9_educ_level if _mi_m == 1
scalar t9_extra_mean_0305 = r(mean)
scalar t9_extra_min_0305 = r(min)
scalar t9_extra_max_0305 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0305) " / " %12.4f scalar(t9_extra_min_0305) " / " %12.4f scalar(t9_extra_max_0305)

display as text "  Extra scalar diagnostic 0306: t9_health_level m=2"
quietly summarize t9_health_level if _mi_m == 2
scalar t9_extra_mean_0306 = r(mean)
scalar t9_extra_min_0306 = r(min)
scalar t9_extra_max_0306 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0306) " / " %12.4f scalar(t9_extra_min_0306) " / " %12.4f scalar(t9_extra_max_0306)

display as text "  Extra scalar diagnostic 0307: t9_job_sat m=3"
quietly summarize t9_job_sat if _mi_m == 3
scalar t9_extra_mean_0307 = r(mean)
scalar t9_extra_min_0307 = r(min)
scalar t9_extra_max_0307 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0307) " / " %12.4f scalar(t9_extra_min_0307) " / " %12.4f scalar(t9_extra_max_0307)

display as text "  Extra scalar diagnostic 0308: t9_children m=0"
quietly summarize t9_children if _mi_m == 0
scalar t9_extra_mean_0308 = r(mean)
scalar t9_extra_min_0308 = r(min)
scalar t9_extra_max_0308 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0308) " / " %12.4f scalar(t9_extra_min_0308) " / " %12.4f scalar(t9_extra_max_0308)

display as text "  Extra scalar diagnostic 0309: t9_doctor_visits m=1"
quietly summarize t9_doctor_visits if _mi_m == 1
scalar t9_extra_mean_0309 = r(mean)
scalar t9_extra_min_0309 = r(min)
scalar t9_extra_max_0309 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0309) " / " %12.4f scalar(t9_extra_min_0309) " / " %12.4f scalar(t9_extra_max_0309)

display as text "  Extra scalar diagnostic 0310: t9_hosp_days m=2"
quietly summarize t9_hosp_days if _mi_m == 2
scalar t9_extra_mean_0310 = r(mean)
scalar t9_extra_min_0310 = r(min)
scalar t9_extra_max_0310 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0310) " / " %12.4f scalar(t9_extra_min_0310) " / " %12.4f scalar(t9_extra_max_0310)

display as text "  Extra scalar diagnostic 0311: t9_log_income m=3"
quietly summarize t9_log_income if _mi_m == 3
scalar t9_extra_mean_0311 = r(mean)
scalar t9_extra_min_0311 = r(min)
scalar t9_extra_max_0311 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0311) " / " %12.4f scalar(t9_extra_min_0311) " / " %12.4f scalar(t9_extra_max_0311)

display as text "  Extra scalar diagnostic 0312: t9_log_wage m=0"
quietly summarize t9_log_wage if _mi_m == 0
scalar t9_extra_mean_0312 = r(mean)
scalar t9_extra_min_0312 = r(min)
scalar t9_extra_max_0312 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0312) " / " %12.4f scalar(t9_extra_min_0312) " / " %12.4f scalar(t9_extra_max_0312)

display as text "  Extra scalar diagnostic 0313: t9_income_per_hour m=1"
quietly summarize t9_income_per_hour if _mi_m == 1
scalar t9_extra_mean_0313 = r(mean)
scalar t9_extra_min_0313 = r(min)
scalar t9_extra_max_0313 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0313) " / " %12.4f scalar(t9_extra_min_0313) " / " %12.4f scalar(t9_extra_max_0313)

display as text "  Extra scalar diagnostic 0314: t9_health_index m=2"
quietly summarize t9_health_index if _mi_m == 2
scalar t9_extra_mean_0314 = r(mean)
scalar t9_extra_min_0314 = r(min)
scalar t9_extra_max_0314 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0314) " / " %12.4f scalar(t9_extra_min_0314) " / " %12.4f scalar(t9_extra_max_0314)

display as text "  Extra scalar diagnostic 0315: t9_dep_stress m=3"
quietly summarize t9_dep_stress if _mi_m == 3
scalar t9_extra_mean_0315 = r(mean)
scalar t9_extra_min_0315 = r(min)
scalar t9_extra_max_0315 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0315) " / " %12.4f scalar(t9_extra_min_0315) " / " %12.4f scalar(t9_extra_max_0315)

display as text "  Extra scalar diagnostic 0316: t9_income m=0"
quietly summarize t9_income if _mi_m == 0
scalar t9_extra_mean_0316 = r(mean)
scalar t9_extra_min_0316 = r(min)
scalar t9_extra_max_0316 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0316) " / " %12.4f scalar(t9_extra_min_0316) " / " %12.4f scalar(t9_extra_max_0316)

display as text "  Extra scalar diagnostic 0317: t9_wage m=1"
quietly summarize t9_wage if _mi_m == 1
scalar t9_extra_mean_0317 = r(mean)
scalar t9_extra_min_0317 = r(min)
scalar t9_extra_max_0317 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0317) " / " %12.4f scalar(t9_extra_min_0317) " / " %12.4f scalar(t9_extra_max_0317)

display as text "  Extra scalar diagnostic 0318: t9_hours m=2"
quietly summarize t9_hours if _mi_m == 2
scalar t9_extra_mean_0318 = r(mean)
scalar t9_extra_min_0318 = r(min)
scalar t9_extra_max_0318 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0318) " / " %12.4f scalar(t9_extra_min_0318) " / " %12.4f scalar(t9_extra_max_0318)

display as text "  Extra scalar diagnostic 0319: t9_wealth m=3"
quietly summarize t9_wealth if _mi_m == 3
scalar t9_extra_mean_0319 = r(mean)
scalar t9_extra_min_0319 = r(min)
scalar t9_extra_max_0319 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0319) " / " %12.4f scalar(t9_extra_min_0319) " / " %12.4f scalar(t9_extra_max_0319)

display as text "  Extra scalar diagnostic 0320: t9_savings m=0"
quietly summarize t9_savings if _mi_m == 0
scalar t9_extra_mean_0320 = r(mean)
scalar t9_extra_min_0320 = r(min)
scalar t9_extra_max_0320 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0320) " / " %12.4f scalar(t9_extra_min_0320) " / " %12.4f scalar(t9_extra_max_0320)

display as text "  Extra scalar diagnostic 0321: t9_expenditure m=1"
quietly summarize t9_expenditure if _mi_m == 1
scalar t9_extra_mean_0321 = r(mean)
scalar t9_extra_min_0321 = r(min)
scalar t9_extra_max_0321 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0321) " / " %12.4f scalar(t9_extra_min_0321) " / " %12.4f scalar(t9_extra_max_0321)

display as text "  Extra scalar diagnostic 0322: t9_health_score m=2"
quietly summarize t9_health_score if _mi_m == 2
scalar t9_extra_mean_0322 = r(mean)
scalar t9_extra_min_0322 = r(min)
scalar t9_extra_max_0322 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0322) " / " %12.4f scalar(t9_extra_min_0322) " / " %12.4f scalar(t9_extra_max_0322)

display as text "  Extra scalar diagnostic 0323: t9_bmi m=3"
quietly summarize t9_bmi if _mi_m == 3
scalar t9_extra_mean_0323 = r(mean)
scalar t9_extra_min_0323 = r(min)
scalar t9_extra_max_0323 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0323) " / " %12.4f scalar(t9_extra_min_0323) " / " %12.4f scalar(t9_extra_max_0323)

display as text "  Extra scalar diagnostic 0324: t9_bp_sys m=0"
quietly summarize t9_bp_sys if _mi_m == 0
scalar t9_extra_mean_0324 = r(mean)
scalar t9_extra_min_0324 = r(min)
scalar t9_extra_max_0324 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0324) " / " %12.4f scalar(t9_extra_min_0324) " / " %12.4f scalar(t9_extra_max_0324)

display as text "  Extra scalar diagnostic 0325: t9_bp_dia m=1"
quietly summarize t9_bp_dia if _mi_m == 1
scalar t9_extra_mean_0325 = r(mean)
scalar t9_extra_min_0325 = r(min)
scalar t9_extra_max_0325 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0325) " / " %12.4f scalar(t9_extra_min_0325) " / " %12.4f scalar(t9_extra_max_0325)

display as text "  Extra scalar diagnostic 0326: t9_depression m=2"
quietly summarize t9_depression if _mi_m == 2
scalar t9_extra_mean_0326 = r(mean)
scalar t9_extra_min_0326 = r(min)
scalar t9_extra_max_0326 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0326) " / " %12.4f scalar(t9_extra_min_0326) " / " %12.4f scalar(t9_extra_max_0326)

display as text "  Extra scalar diagnostic 0327: t9_stress m=3"
quietly summarize t9_stress if _mi_m == 3
scalar t9_extra_mean_0327 = r(mean)
scalar t9_extra_min_0327 = r(min)
scalar t9_extra_max_0327 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0327) " / " %12.4f scalar(t9_extra_min_0327) " / " %12.4f scalar(t9_extra_max_0327)

display as text "  Extra scalar diagnostic 0328: t9_satisfaction m=0"
quietly summarize t9_satisfaction if _mi_m == 0
scalar t9_extra_mean_0328 = r(mean)
scalar t9_extra_min_0328 = r(min)
scalar t9_extra_max_0328 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0328) " / " %12.4f scalar(t9_extra_min_0328) " / " %12.4f scalar(t9_extra_max_0328)

display as text "  Extra scalar diagnostic 0329: t9_sleep m=1"
quietly summarize t9_sleep if _mi_m == 1
scalar t9_extra_mean_0329 = r(mean)
scalar t9_extra_min_0329 = r(min)
scalar t9_extra_max_0329 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0329) " / " %12.4f scalar(t9_extra_min_0329) " / " %12.4f scalar(t9_extra_max_0329)

display as text "  Extra scalar diagnostic 0330: t9_exercise m=2"
quietly summarize t9_exercise if _mi_m == 2
scalar t9_extra_mean_0330 = r(mean)
scalar t9_extra_min_0330 = r(min)
scalar t9_extra_max_0330 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0330) " / " %12.4f scalar(t9_extra_min_0330) " / " %12.4f scalar(t9_extra_max_0330)

display as text "  Extra scalar diagnostic 0331: t9_employed m=3"
quietly summarize t9_employed if _mi_m == 3
scalar t9_extra_mean_0331 = r(mean)
scalar t9_extra_min_0331 = r(min)
scalar t9_extra_max_0331 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0331) " / " %12.4f scalar(t9_extra_min_0331) " / " %12.4f scalar(t9_extra_max_0331)

display as text "  Extra scalar diagnostic 0332: t9_married m=0"
quietly summarize t9_married if _mi_m == 0
scalar t9_extra_mean_0332 = r(mean)
scalar t9_extra_min_0332 = r(min)
scalar t9_extra_max_0332 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0332) " / " %12.4f scalar(t9_extra_min_0332) " / " %12.4f scalar(t9_extra_max_0332)

display as text "  Extra scalar diagnostic 0333: t9_urban m=1"
quietly summarize t9_urban if _mi_m == 1
scalar t9_extra_mean_0333 = r(mean)
scalar t9_extra_min_0333 = r(min)
scalar t9_extra_max_0333 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0333) " / " %12.4f scalar(t9_extra_min_0333) " / " %12.4f scalar(t9_extra_max_0333)

display as text "  Extra scalar diagnostic 0334: t9_homeowner m=2"
quietly summarize t9_homeowner if _mi_m == 2
scalar t9_extra_mean_0334 = r(mean)
scalar t9_extra_min_0334 = r(min)
scalar t9_extra_max_0334 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0334) " / " %12.4f scalar(t9_extra_min_0334) " / " %12.4f scalar(t9_extra_max_0334)

display as text "  Extra scalar diagnostic 0335: t9_insured m=3"
quietly summarize t9_insured if _mi_m == 3
scalar t9_extra_mean_0335 = r(mean)
scalar t9_extra_min_0335 = r(min)
scalar t9_extra_max_0335 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0335) " / " %12.4f scalar(t9_extra_min_0335) " / " %12.4f scalar(t9_extra_max_0335)

display as text "  Extra scalar diagnostic 0336: t9_smoker m=0"
quietly summarize t9_smoker if _mi_m == 0
scalar t9_extra_mean_0336 = r(mean)
scalar t9_extra_min_0336 = r(min)
scalar t9_extra_max_0336 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0336) " / " %12.4f scalar(t9_extra_min_0336) " / " %12.4f scalar(t9_extra_max_0336)

display as text "  Extra scalar diagnostic 0337: t9_high_income m=1"
quietly summarize t9_high_income if _mi_m == 1
scalar t9_extra_mean_0337 = r(mean)
scalar t9_extra_min_0337 = r(min)
scalar t9_extra_max_0337 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0337) " / " %12.4f scalar(t9_extra_min_0337) " / " %12.4f scalar(t9_extra_max_0337)

display as text "  Extra scalar diagnostic 0338: t9_high_stress m=2"
quietly summarize t9_high_stress if _mi_m == 2
scalar t9_extra_mean_0338 = r(mean)
scalar t9_extra_min_0338 = r(min)
scalar t9_extra_max_0338 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0338) " / " %12.4f scalar(t9_extra_min_0338) " / " %12.4f scalar(t9_extra_max_0338)

display as text "  Extra scalar diagnostic 0339: t9_unhealthy m=3"
quietly summarize t9_unhealthy if _mi_m == 3
scalar t9_extra_mean_0339 = r(mean)
scalar t9_extra_min_0339 = r(min)
scalar t9_extra_max_0339 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0339) " / " %12.4f scalar(t9_extra_min_0339) " / " %12.4f scalar(t9_extra_max_0339)

display as text "  Extra scalar diagnostic 0340: t9_educ_level m=0"
quietly summarize t9_educ_level if _mi_m == 0
scalar t9_extra_mean_0340 = r(mean)
scalar t9_extra_min_0340 = r(min)
scalar t9_extra_max_0340 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0340) " / " %12.4f scalar(t9_extra_min_0340) " / " %12.4f scalar(t9_extra_max_0340)

display as text "  Extra scalar diagnostic 0341: t9_health_level m=1"
quietly summarize t9_health_level if _mi_m == 1
scalar t9_extra_mean_0341 = r(mean)
scalar t9_extra_min_0341 = r(min)
scalar t9_extra_max_0341 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0341) " / " %12.4f scalar(t9_extra_min_0341) " / " %12.4f scalar(t9_extra_max_0341)

display as text "  Extra scalar diagnostic 0342: t9_job_sat m=2"
quietly summarize t9_job_sat if _mi_m == 2
scalar t9_extra_mean_0342 = r(mean)
scalar t9_extra_min_0342 = r(min)
scalar t9_extra_max_0342 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0342) " / " %12.4f scalar(t9_extra_min_0342) " / " %12.4f scalar(t9_extra_max_0342)

display as text "  Extra scalar diagnostic 0343: t9_children m=3"
quietly summarize t9_children if _mi_m == 3
scalar t9_extra_mean_0343 = r(mean)
scalar t9_extra_min_0343 = r(min)
scalar t9_extra_max_0343 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0343) " / " %12.4f scalar(t9_extra_min_0343) " / " %12.4f scalar(t9_extra_max_0343)

display as text "  Extra scalar diagnostic 0344: t9_doctor_visits m=0"
quietly summarize t9_doctor_visits if _mi_m == 0
scalar t9_extra_mean_0344 = r(mean)
scalar t9_extra_min_0344 = r(min)
scalar t9_extra_max_0344 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0344) " / " %12.4f scalar(t9_extra_min_0344) " / " %12.4f scalar(t9_extra_max_0344)

display as text "  Extra scalar diagnostic 0345: t9_hosp_days m=1"
quietly summarize t9_hosp_days if _mi_m == 1
scalar t9_extra_mean_0345 = r(mean)
scalar t9_extra_min_0345 = r(min)
scalar t9_extra_max_0345 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0345) " / " %12.4f scalar(t9_extra_min_0345) " / " %12.4f scalar(t9_extra_max_0345)

display as text "  Extra scalar diagnostic 0346: t9_log_income m=2"
quietly summarize t9_log_income if _mi_m == 2
scalar t9_extra_mean_0346 = r(mean)
scalar t9_extra_min_0346 = r(min)
scalar t9_extra_max_0346 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0346) " / " %12.4f scalar(t9_extra_min_0346) " / " %12.4f scalar(t9_extra_max_0346)

display as text "  Extra scalar diagnostic 0347: t9_log_wage m=3"
quietly summarize t9_log_wage if _mi_m == 3
scalar t9_extra_mean_0347 = r(mean)
scalar t9_extra_min_0347 = r(min)
scalar t9_extra_max_0347 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0347) " / " %12.4f scalar(t9_extra_min_0347) " / " %12.4f scalar(t9_extra_max_0347)

display as text "  Extra scalar diagnostic 0348: t9_income_per_hour m=0"
quietly summarize t9_income_per_hour if _mi_m == 0
scalar t9_extra_mean_0348 = r(mean)
scalar t9_extra_min_0348 = r(min)
scalar t9_extra_max_0348 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0348) " / " %12.4f scalar(t9_extra_min_0348) " / " %12.4f scalar(t9_extra_max_0348)

display as text "  Extra scalar diagnostic 0349: t9_health_index m=1"
quietly summarize t9_health_index if _mi_m == 1
scalar t9_extra_mean_0349 = r(mean)
scalar t9_extra_min_0349 = r(min)
scalar t9_extra_max_0349 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0349) " / " %12.4f scalar(t9_extra_min_0349) " / " %12.4f scalar(t9_extra_max_0349)

display as text "  Extra scalar diagnostic 0350: t9_dep_stress m=2"
quietly summarize t9_dep_stress if _mi_m == 2
scalar t9_extra_mean_0350 = r(mean)
scalar t9_extra_min_0350 = r(min)
scalar t9_extra_max_0350 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0350) " / " %12.4f scalar(t9_extra_min_0350) " / " %12.4f scalar(t9_extra_max_0350)

display as text "  Extra scalar diagnostic 0351: t9_income m=3"
quietly summarize t9_income if _mi_m == 3
scalar t9_extra_mean_0351 = r(mean)
scalar t9_extra_min_0351 = r(min)
scalar t9_extra_max_0351 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0351) " / " %12.4f scalar(t9_extra_min_0351) " / " %12.4f scalar(t9_extra_max_0351)

display as text "  Extra scalar diagnostic 0352: t9_wage m=0"
quietly summarize t9_wage if _mi_m == 0
scalar t9_extra_mean_0352 = r(mean)
scalar t9_extra_min_0352 = r(min)
scalar t9_extra_max_0352 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0352) " / " %12.4f scalar(t9_extra_min_0352) " / " %12.4f scalar(t9_extra_max_0352)

display as text "  Extra scalar diagnostic 0353: t9_hours m=1"
quietly summarize t9_hours if _mi_m == 1
scalar t9_extra_mean_0353 = r(mean)
scalar t9_extra_min_0353 = r(min)
scalar t9_extra_max_0353 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0353) " / " %12.4f scalar(t9_extra_min_0353) " / " %12.4f scalar(t9_extra_max_0353)

display as text "  Extra scalar diagnostic 0354: t9_wealth m=2"
quietly summarize t9_wealth if _mi_m == 2
scalar t9_extra_mean_0354 = r(mean)
scalar t9_extra_min_0354 = r(min)
scalar t9_extra_max_0354 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0354) " / " %12.4f scalar(t9_extra_min_0354) " / " %12.4f scalar(t9_extra_max_0354)

display as text "  Extra scalar diagnostic 0355: t9_savings m=3"
quietly summarize t9_savings if _mi_m == 3
scalar t9_extra_mean_0355 = r(mean)
scalar t9_extra_min_0355 = r(min)
scalar t9_extra_max_0355 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0355) " / " %12.4f scalar(t9_extra_min_0355) " / " %12.4f scalar(t9_extra_max_0355)

display as text "  Extra scalar diagnostic 0356: t9_expenditure m=0"
quietly summarize t9_expenditure if _mi_m == 0
scalar t9_extra_mean_0356 = r(mean)
scalar t9_extra_min_0356 = r(min)
scalar t9_extra_max_0356 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0356) " / " %12.4f scalar(t9_extra_min_0356) " / " %12.4f scalar(t9_extra_max_0356)

display as text "  Extra scalar diagnostic 0357: t9_health_score m=1"
quietly summarize t9_health_score if _mi_m == 1
scalar t9_extra_mean_0357 = r(mean)
scalar t9_extra_min_0357 = r(min)
scalar t9_extra_max_0357 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0357) " / " %12.4f scalar(t9_extra_min_0357) " / " %12.4f scalar(t9_extra_max_0357)

display as text "  Extra scalar diagnostic 0358: t9_bmi m=2"
quietly summarize t9_bmi if _mi_m == 2
scalar t9_extra_mean_0358 = r(mean)
scalar t9_extra_min_0358 = r(min)
scalar t9_extra_max_0358 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0358) " / " %12.4f scalar(t9_extra_min_0358) " / " %12.4f scalar(t9_extra_max_0358)

display as text "  Extra scalar diagnostic 0359: t9_bp_sys m=3"
quietly summarize t9_bp_sys if _mi_m == 3
scalar t9_extra_mean_0359 = r(mean)
scalar t9_extra_min_0359 = r(min)
scalar t9_extra_max_0359 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0359) " / " %12.4f scalar(t9_extra_min_0359) " / " %12.4f scalar(t9_extra_max_0359)

display as text "  Extra scalar diagnostic 0360: t9_bp_dia m=0"
quietly summarize t9_bp_dia if _mi_m == 0
scalar t9_extra_mean_0360 = r(mean)
scalar t9_extra_min_0360 = r(min)
scalar t9_extra_max_0360 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0360) " / " %12.4f scalar(t9_extra_min_0360) " / " %12.4f scalar(t9_extra_max_0360)

display as text "  Extra scalar diagnostic 0361: t9_depression m=1"
quietly summarize t9_depression if _mi_m == 1
scalar t9_extra_mean_0361 = r(mean)
scalar t9_extra_min_0361 = r(min)
scalar t9_extra_max_0361 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0361) " / " %12.4f scalar(t9_extra_min_0361) " / " %12.4f scalar(t9_extra_max_0361)

display as text "  Extra scalar diagnostic 0362: t9_stress m=2"
quietly summarize t9_stress if _mi_m == 2
scalar t9_extra_mean_0362 = r(mean)
scalar t9_extra_min_0362 = r(min)
scalar t9_extra_max_0362 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0362) " / " %12.4f scalar(t9_extra_min_0362) " / " %12.4f scalar(t9_extra_max_0362)

display as text "  Extra scalar diagnostic 0363: t9_satisfaction m=3"
quietly summarize t9_satisfaction if _mi_m == 3
scalar t9_extra_mean_0363 = r(mean)
scalar t9_extra_min_0363 = r(min)
scalar t9_extra_max_0363 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0363) " / " %12.4f scalar(t9_extra_min_0363) " / " %12.4f scalar(t9_extra_max_0363)

display as text "  Extra scalar diagnostic 0364: t9_sleep m=0"
quietly summarize t9_sleep if _mi_m == 0
scalar t9_extra_mean_0364 = r(mean)
scalar t9_extra_min_0364 = r(min)
scalar t9_extra_max_0364 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0364) " / " %12.4f scalar(t9_extra_min_0364) " / " %12.4f scalar(t9_extra_max_0364)

display as text "  Extra scalar diagnostic 0365: t9_exercise m=1"
quietly summarize t9_exercise if _mi_m == 1
scalar t9_extra_mean_0365 = r(mean)
scalar t9_extra_min_0365 = r(min)
scalar t9_extra_max_0365 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0365) " / " %12.4f scalar(t9_extra_min_0365) " / " %12.4f scalar(t9_extra_max_0365)

display as text "  Extra scalar diagnostic 0366: t9_employed m=2"
quietly summarize t9_employed if _mi_m == 2
scalar t9_extra_mean_0366 = r(mean)
scalar t9_extra_min_0366 = r(min)
scalar t9_extra_max_0366 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0366) " / " %12.4f scalar(t9_extra_min_0366) " / " %12.4f scalar(t9_extra_max_0366)

display as text "  Extra scalar diagnostic 0367: t9_married m=3"
quietly summarize t9_married if _mi_m == 3
scalar t9_extra_mean_0367 = r(mean)
scalar t9_extra_min_0367 = r(min)
scalar t9_extra_max_0367 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0367) " / " %12.4f scalar(t9_extra_min_0367) " / " %12.4f scalar(t9_extra_max_0367)

display as text "  Extra scalar diagnostic 0368: t9_urban m=0"
quietly summarize t9_urban if _mi_m == 0
scalar t9_extra_mean_0368 = r(mean)
scalar t9_extra_min_0368 = r(min)
scalar t9_extra_max_0368 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0368) " / " %12.4f scalar(t9_extra_min_0368) " / " %12.4f scalar(t9_extra_max_0368)

display as text "  Extra scalar diagnostic 0369: t9_homeowner m=1"
quietly summarize t9_homeowner if _mi_m == 1
scalar t9_extra_mean_0369 = r(mean)
scalar t9_extra_min_0369 = r(min)
scalar t9_extra_max_0369 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0369) " / " %12.4f scalar(t9_extra_min_0369) " / " %12.4f scalar(t9_extra_max_0369)

display as text "  Extra scalar diagnostic 0370: t9_insured m=2"
quietly summarize t9_insured if _mi_m == 2
scalar t9_extra_mean_0370 = r(mean)
scalar t9_extra_min_0370 = r(min)
scalar t9_extra_max_0370 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0370) " / " %12.4f scalar(t9_extra_min_0370) " / " %12.4f scalar(t9_extra_max_0370)

display as text "  Extra scalar diagnostic 0371: t9_smoker m=3"
quietly summarize t9_smoker if _mi_m == 3
scalar t9_extra_mean_0371 = r(mean)
scalar t9_extra_min_0371 = r(min)
scalar t9_extra_max_0371 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0371) " / " %12.4f scalar(t9_extra_min_0371) " / " %12.4f scalar(t9_extra_max_0371)

display as text "  Extra scalar diagnostic 0372: t9_high_income m=0"
quietly summarize t9_high_income if _mi_m == 0
scalar t9_extra_mean_0372 = r(mean)
scalar t9_extra_min_0372 = r(min)
scalar t9_extra_max_0372 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0372) " / " %12.4f scalar(t9_extra_min_0372) " / " %12.4f scalar(t9_extra_max_0372)

display as text "  Extra scalar diagnostic 0373: t9_high_stress m=1"
quietly summarize t9_high_stress if _mi_m == 1
scalar t9_extra_mean_0373 = r(mean)
scalar t9_extra_min_0373 = r(min)
scalar t9_extra_max_0373 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0373) " / " %12.4f scalar(t9_extra_min_0373) " / " %12.4f scalar(t9_extra_max_0373)

display as text "  Extra scalar diagnostic 0374: t9_unhealthy m=2"
quietly summarize t9_unhealthy if _mi_m == 2
scalar t9_extra_mean_0374 = r(mean)
scalar t9_extra_min_0374 = r(min)
scalar t9_extra_max_0374 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0374) " / " %12.4f scalar(t9_extra_min_0374) " / " %12.4f scalar(t9_extra_max_0374)

display as text "  Extra scalar diagnostic 0375: t9_educ_level m=3"
quietly summarize t9_educ_level if _mi_m == 3
scalar t9_extra_mean_0375 = r(mean)
scalar t9_extra_min_0375 = r(min)
scalar t9_extra_max_0375 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0375) " / " %12.4f scalar(t9_extra_min_0375) " / " %12.4f scalar(t9_extra_max_0375)

display as text "  Extra scalar diagnostic 0376: t9_health_level m=0"
quietly summarize t9_health_level if _mi_m == 0
scalar t9_extra_mean_0376 = r(mean)
scalar t9_extra_min_0376 = r(min)
scalar t9_extra_max_0376 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0376) " / " %12.4f scalar(t9_extra_min_0376) " / " %12.4f scalar(t9_extra_max_0376)

display as text "  Extra scalar diagnostic 0377: t9_job_sat m=1"
quietly summarize t9_job_sat if _mi_m == 1
scalar t9_extra_mean_0377 = r(mean)
scalar t9_extra_min_0377 = r(min)
scalar t9_extra_max_0377 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0377) " / " %12.4f scalar(t9_extra_min_0377) " / " %12.4f scalar(t9_extra_max_0377)

display as text "  Extra scalar diagnostic 0378: t9_children m=2"
quietly summarize t9_children if _mi_m == 2
scalar t9_extra_mean_0378 = r(mean)
scalar t9_extra_min_0378 = r(min)
scalar t9_extra_max_0378 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0378) " / " %12.4f scalar(t9_extra_min_0378) " / " %12.4f scalar(t9_extra_max_0378)

display as text "  Extra scalar diagnostic 0379: t9_doctor_visits m=3"
quietly summarize t9_doctor_visits if _mi_m == 3
scalar t9_extra_mean_0379 = r(mean)
scalar t9_extra_min_0379 = r(min)
scalar t9_extra_max_0379 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0379) " / " %12.4f scalar(t9_extra_min_0379) " / " %12.4f scalar(t9_extra_max_0379)

display as text "  Extra scalar diagnostic 0380: t9_hosp_days m=0"
quietly summarize t9_hosp_days if _mi_m == 0
scalar t9_extra_mean_0380 = r(mean)
scalar t9_extra_min_0380 = r(min)
scalar t9_extra_max_0380 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0380) " / " %12.4f scalar(t9_extra_min_0380) " / " %12.4f scalar(t9_extra_max_0380)

display as text "  Extra scalar diagnostic 0381: t9_log_income m=1"
quietly summarize t9_log_income if _mi_m == 1
scalar t9_extra_mean_0381 = r(mean)
scalar t9_extra_min_0381 = r(min)
scalar t9_extra_max_0381 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0381) " / " %12.4f scalar(t9_extra_min_0381) " / " %12.4f scalar(t9_extra_max_0381)

display as text "  Extra scalar diagnostic 0382: t9_log_wage m=2"
quietly summarize t9_log_wage if _mi_m == 2
scalar t9_extra_mean_0382 = r(mean)
scalar t9_extra_min_0382 = r(min)
scalar t9_extra_max_0382 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0382) " / " %12.4f scalar(t9_extra_min_0382) " / " %12.4f scalar(t9_extra_max_0382)

display as text "  Extra scalar diagnostic 0383: t9_income_per_hour m=3"
quietly summarize t9_income_per_hour if _mi_m == 3
scalar t9_extra_mean_0383 = r(mean)
scalar t9_extra_min_0383 = r(min)
scalar t9_extra_max_0383 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0383) " / " %12.4f scalar(t9_extra_min_0383) " / " %12.4f scalar(t9_extra_max_0383)

display as text "  Extra scalar diagnostic 0384: t9_health_index m=0"
quietly summarize t9_health_index if _mi_m == 0
scalar t9_extra_mean_0384 = r(mean)
scalar t9_extra_min_0384 = r(min)
scalar t9_extra_max_0384 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0384) " / " %12.4f scalar(t9_extra_min_0384) " / " %12.4f scalar(t9_extra_max_0384)

display as text "  Extra scalar diagnostic 0385: t9_dep_stress m=1"
quietly summarize t9_dep_stress if _mi_m == 1
scalar t9_extra_mean_0385 = r(mean)
scalar t9_extra_min_0385 = r(min)
scalar t9_extra_max_0385 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0385) " / " %12.4f scalar(t9_extra_min_0385) " / " %12.4f scalar(t9_extra_max_0385)

display as text "  Extra scalar diagnostic 0386: t9_income m=2"
quietly summarize t9_income if _mi_m == 2
scalar t9_extra_mean_0386 = r(mean)
scalar t9_extra_min_0386 = r(min)
scalar t9_extra_max_0386 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0386) " / " %12.4f scalar(t9_extra_min_0386) " / " %12.4f scalar(t9_extra_max_0386)

display as text "  Extra scalar diagnostic 0387: t9_wage m=3"
quietly summarize t9_wage if _mi_m == 3
scalar t9_extra_mean_0387 = r(mean)
scalar t9_extra_min_0387 = r(min)
scalar t9_extra_max_0387 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0387) " / " %12.4f scalar(t9_extra_min_0387) " / " %12.4f scalar(t9_extra_max_0387)

display as text "  Extra scalar diagnostic 0388: t9_hours m=0"
quietly summarize t9_hours if _mi_m == 0
scalar t9_extra_mean_0388 = r(mean)
scalar t9_extra_min_0388 = r(min)
scalar t9_extra_max_0388 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0388) " / " %12.4f scalar(t9_extra_min_0388) " / " %12.4f scalar(t9_extra_max_0388)

display as text "  Extra scalar diagnostic 0389: t9_wealth m=1"
quietly summarize t9_wealth if _mi_m == 1
scalar t9_extra_mean_0389 = r(mean)
scalar t9_extra_min_0389 = r(min)
scalar t9_extra_max_0389 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0389) " / " %12.4f scalar(t9_extra_min_0389) " / " %12.4f scalar(t9_extra_max_0389)

display as text "  Extra scalar diagnostic 0390: t9_savings m=2"
quietly summarize t9_savings if _mi_m == 2
scalar t9_extra_mean_0390 = r(mean)
scalar t9_extra_min_0390 = r(min)
scalar t9_extra_max_0390 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0390) " / " %12.4f scalar(t9_extra_min_0390) " / " %12.4f scalar(t9_extra_max_0390)

display as text "  Extra scalar diagnostic 0391: t9_expenditure m=3"
quietly summarize t9_expenditure if _mi_m == 3
scalar t9_extra_mean_0391 = r(mean)
scalar t9_extra_min_0391 = r(min)
scalar t9_extra_max_0391 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0391) " / " %12.4f scalar(t9_extra_min_0391) " / " %12.4f scalar(t9_extra_max_0391)

display as text "  Extra scalar diagnostic 0392: t9_health_score m=0"
quietly summarize t9_health_score if _mi_m == 0
scalar t9_extra_mean_0392 = r(mean)
scalar t9_extra_min_0392 = r(min)
scalar t9_extra_max_0392 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0392) " / " %12.4f scalar(t9_extra_min_0392) " / " %12.4f scalar(t9_extra_max_0392)

display as text "  Extra scalar diagnostic 0393: t9_bmi m=1"
quietly summarize t9_bmi if _mi_m == 1
scalar t9_extra_mean_0393 = r(mean)
scalar t9_extra_min_0393 = r(min)
scalar t9_extra_max_0393 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0393) " / " %12.4f scalar(t9_extra_min_0393) " / " %12.4f scalar(t9_extra_max_0393)

display as text "  Extra scalar diagnostic 0394: t9_bp_sys m=2"
quietly summarize t9_bp_sys if _mi_m == 2
scalar t9_extra_mean_0394 = r(mean)
scalar t9_extra_min_0394 = r(min)
scalar t9_extra_max_0394 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0394) " / " %12.4f scalar(t9_extra_min_0394) " / " %12.4f scalar(t9_extra_max_0394)

display as text "  Extra scalar diagnostic 0395: t9_bp_dia m=3"
quietly summarize t9_bp_dia if _mi_m == 3
scalar t9_extra_mean_0395 = r(mean)
scalar t9_extra_min_0395 = r(min)
scalar t9_extra_max_0395 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0395) " / " %12.4f scalar(t9_extra_min_0395) " / " %12.4f scalar(t9_extra_max_0395)

display as text "  Extra scalar diagnostic 0396: t9_depression m=0"
quietly summarize t9_depression if _mi_m == 0
scalar t9_extra_mean_0396 = r(mean)
scalar t9_extra_min_0396 = r(min)
scalar t9_extra_max_0396 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0396) " / " %12.4f scalar(t9_extra_min_0396) " / " %12.4f scalar(t9_extra_max_0396)

display as text "  Extra scalar diagnostic 0397: t9_stress m=1"
quietly summarize t9_stress if _mi_m == 1
scalar t9_extra_mean_0397 = r(mean)
scalar t9_extra_min_0397 = r(min)
scalar t9_extra_max_0397 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0397) " / " %12.4f scalar(t9_extra_min_0397) " / " %12.4f scalar(t9_extra_max_0397)

display as text "  Extra scalar diagnostic 0398: t9_satisfaction m=2"
quietly summarize t9_satisfaction if _mi_m == 2
scalar t9_extra_mean_0398 = r(mean)
scalar t9_extra_min_0398 = r(min)
scalar t9_extra_max_0398 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0398) " / " %12.4f scalar(t9_extra_min_0398) " / " %12.4f scalar(t9_extra_max_0398)

display as text "  Extra scalar diagnostic 0399: t9_sleep m=3"
quietly summarize t9_sleep if _mi_m == 3
scalar t9_extra_mean_0399 = r(mean)
scalar t9_extra_min_0399 = r(min)
scalar t9_extra_max_0399 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0399) " / " %12.4f scalar(t9_extra_min_0399) " / " %12.4f scalar(t9_extra_max_0399)

display as text "  Extra scalar diagnostic 0400: t9_exercise m=0"
quietly summarize t9_exercise if _mi_m == 0
scalar t9_extra_mean_0400 = r(mean)
scalar t9_extra_min_0400 = r(min)
scalar t9_extra_max_0400 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0400) " / " %12.4f scalar(t9_extra_min_0400) " / " %12.4f scalar(t9_extra_max_0400)

display as text "  Extra scalar diagnostic 0401: t9_employed m=1"
quietly summarize t9_employed if _mi_m == 1
scalar t9_extra_mean_0401 = r(mean)
scalar t9_extra_min_0401 = r(min)
scalar t9_extra_max_0401 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0401) " / " %12.4f scalar(t9_extra_min_0401) " / " %12.4f scalar(t9_extra_max_0401)

display as text "  Extra scalar diagnostic 0402: t9_married m=2"
quietly summarize t9_married if _mi_m == 2
scalar t9_extra_mean_0402 = r(mean)
scalar t9_extra_min_0402 = r(min)
scalar t9_extra_max_0402 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0402) " / " %12.4f scalar(t9_extra_min_0402) " / " %12.4f scalar(t9_extra_max_0402)

display as text "  Extra scalar diagnostic 0403: t9_urban m=3"
quietly summarize t9_urban if _mi_m == 3
scalar t9_extra_mean_0403 = r(mean)
scalar t9_extra_min_0403 = r(min)
scalar t9_extra_max_0403 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0403) " / " %12.4f scalar(t9_extra_min_0403) " / " %12.4f scalar(t9_extra_max_0403)

display as text "  Extra scalar diagnostic 0404: t9_homeowner m=0"
quietly summarize t9_homeowner if _mi_m == 0
scalar t9_extra_mean_0404 = r(mean)
scalar t9_extra_min_0404 = r(min)
scalar t9_extra_max_0404 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0404) " / " %12.4f scalar(t9_extra_min_0404) " / " %12.4f scalar(t9_extra_max_0404)

display as text "  Extra scalar diagnostic 0405: t9_insured m=1"
quietly summarize t9_insured if _mi_m == 1
scalar t9_extra_mean_0405 = r(mean)
scalar t9_extra_min_0405 = r(min)
scalar t9_extra_max_0405 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0405) " / " %12.4f scalar(t9_extra_min_0405) " / " %12.4f scalar(t9_extra_max_0405)

display as text "  Extra scalar diagnostic 0406: t9_smoker m=2"
quietly summarize t9_smoker if _mi_m == 2
scalar t9_extra_mean_0406 = r(mean)
scalar t9_extra_min_0406 = r(min)
scalar t9_extra_max_0406 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0406) " / " %12.4f scalar(t9_extra_min_0406) " / " %12.4f scalar(t9_extra_max_0406)

display as text "  Extra scalar diagnostic 0407: t9_high_income m=3"
quietly summarize t9_high_income if _mi_m == 3
scalar t9_extra_mean_0407 = r(mean)
scalar t9_extra_min_0407 = r(min)
scalar t9_extra_max_0407 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0407) " / " %12.4f scalar(t9_extra_min_0407) " / " %12.4f scalar(t9_extra_max_0407)

display as text "  Extra scalar diagnostic 0408: t9_high_stress m=0"
quietly summarize t9_high_stress if _mi_m == 0
scalar t9_extra_mean_0408 = r(mean)
scalar t9_extra_min_0408 = r(min)
scalar t9_extra_max_0408 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0408) " / " %12.4f scalar(t9_extra_min_0408) " / " %12.4f scalar(t9_extra_max_0408)

display as text "  Extra scalar diagnostic 0409: t9_unhealthy m=1"
quietly summarize t9_unhealthy if _mi_m == 1
scalar t9_extra_mean_0409 = r(mean)
scalar t9_extra_min_0409 = r(min)
scalar t9_extra_max_0409 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0409) " / " %12.4f scalar(t9_extra_min_0409) " / " %12.4f scalar(t9_extra_max_0409)

display as text "  Extra scalar diagnostic 0410: t9_educ_level m=2"
quietly summarize t9_educ_level if _mi_m == 2
scalar t9_extra_mean_0410 = r(mean)
scalar t9_extra_min_0410 = r(min)
scalar t9_extra_max_0410 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0410) " / " %12.4f scalar(t9_extra_min_0410) " / " %12.4f scalar(t9_extra_max_0410)

display as text "  Extra scalar diagnostic 0411: t9_health_level m=3"
quietly summarize t9_health_level if _mi_m == 3
scalar t9_extra_mean_0411 = r(mean)
scalar t9_extra_min_0411 = r(min)
scalar t9_extra_max_0411 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0411) " / " %12.4f scalar(t9_extra_min_0411) " / " %12.4f scalar(t9_extra_max_0411)

display as text "  Extra scalar diagnostic 0412: t9_job_sat m=0"
quietly summarize t9_job_sat if _mi_m == 0
scalar t9_extra_mean_0412 = r(mean)
scalar t9_extra_min_0412 = r(min)
scalar t9_extra_max_0412 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0412) " / " %12.4f scalar(t9_extra_min_0412) " / " %12.4f scalar(t9_extra_max_0412)

display as text "  Extra scalar diagnostic 0413: t9_children m=1"
quietly summarize t9_children if _mi_m == 1
scalar t9_extra_mean_0413 = r(mean)
scalar t9_extra_min_0413 = r(min)
scalar t9_extra_max_0413 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0413) " / " %12.4f scalar(t9_extra_min_0413) " / " %12.4f scalar(t9_extra_max_0413)

display as text "  Extra scalar diagnostic 0414: t9_doctor_visits m=2"
quietly summarize t9_doctor_visits if _mi_m == 2
scalar t9_extra_mean_0414 = r(mean)
scalar t9_extra_min_0414 = r(min)
scalar t9_extra_max_0414 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0414) " / " %12.4f scalar(t9_extra_min_0414) " / " %12.4f scalar(t9_extra_max_0414)

display as text "  Extra scalar diagnostic 0415: t9_hosp_days m=3"
quietly summarize t9_hosp_days if _mi_m == 3
scalar t9_extra_mean_0415 = r(mean)
scalar t9_extra_min_0415 = r(min)
scalar t9_extra_max_0415 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0415) " / " %12.4f scalar(t9_extra_min_0415) " / " %12.4f scalar(t9_extra_max_0415)

display as text "  Extra scalar diagnostic 0416: t9_log_income m=0"
quietly summarize t9_log_income if _mi_m == 0
scalar t9_extra_mean_0416 = r(mean)
scalar t9_extra_min_0416 = r(min)
scalar t9_extra_max_0416 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0416) " / " %12.4f scalar(t9_extra_min_0416) " / " %12.4f scalar(t9_extra_max_0416)

display as text "  Extra scalar diagnostic 0417: t9_log_wage m=1"
quietly summarize t9_log_wage if _mi_m == 1
scalar t9_extra_mean_0417 = r(mean)
scalar t9_extra_min_0417 = r(min)
scalar t9_extra_max_0417 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0417) " / " %12.4f scalar(t9_extra_min_0417) " / " %12.4f scalar(t9_extra_max_0417)

display as text "  Extra scalar diagnostic 0418: t9_income_per_hour m=2"
quietly summarize t9_income_per_hour if _mi_m == 2
scalar t9_extra_mean_0418 = r(mean)
scalar t9_extra_min_0418 = r(min)
scalar t9_extra_max_0418 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0418) " / " %12.4f scalar(t9_extra_min_0418) " / " %12.4f scalar(t9_extra_max_0418)

display as text "  Extra scalar diagnostic 0419: t9_health_index m=3"
quietly summarize t9_health_index if _mi_m == 3
scalar t9_extra_mean_0419 = r(mean)
scalar t9_extra_min_0419 = r(min)
scalar t9_extra_max_0419 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0419) " / " %12.4f scalar(t9_extra_min_0419) " / " %12.4f scalar(t9_extra_max_0419)

display as text "  Extra scalar diagnostic 0420: t9_dep_stress m=0"
quietly summarize t9_dep_stress if _mi_m == 0
scalar t9_extra_mean_0420 = r(mean)
scalar t9_extra_min_0420 = r(min)
scalar t9_extra_max_0420 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0420) " / " %12.4f scalar(t9_extra_min_0420) " / " %12.4f scalar(t9_extra_max_0420)

display as text "  Extra scalar diagnostic 0421: t9_income m=1"
quietly summarize t9_income if _mi_m == 1
scalar t9_extra_mean_0421 = r(mean)
scalar t9_extra_min_0421 = r(min)
scalar t9_extra_max_0421 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0421) " / " %12.4f scalar(t9_extra_min_0421) " / " %12.4f scalar(t9_extra_max_0421)

display as text "  Extra scalar diagnostic 0422: t9_wage m=2"
quietly summarize t9_wage if _mi_m == 2
scalar t9_extra_mean_0422 = r(mean)
scalar t9_extra_min_0422 = r(min)
scalar t9_extra_max_0422 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0422) " / " %12.4f scalar(t9_extra_min_0422) " / " %12.4f scalar(t9_extra_max_0422)

display as text "  Extra scalar diagnostic 0423: t9_hours m=3"
quietly summarize t9_hours if _mi_m == 3
scalar t9_extra_mean_0423 = r(mean)
scalar t9_extra_min_0423 = r(min)
scalar t9_extra_max_0423 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0423) " / " %12.4f scalar(t9_extra_min_0423) " / " %12.4f scalar(t9_extra_max_0423)

display as text "  Extra scalar diagnostic 0424: t9_wealth m=0"
quietly summarize t9_wealth if _mi_m == 0
scalar t9_extra_mean_0424 = r(mean)
scalar t9_extra_min_0424 = r(min)
scalar t9_extra_max_0424 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0424) " / " %12.4f scalar(t9_extra_min_0424) " / " %12.4f scalar(t9_extra_max_0424)

display as text "  Extra scalar diagnostic 0425: t9_savings m=1"
quietly summarize t9_savings if _mi_m == 1
scalar t9_extra_mean_0425 = r(mean)
scalar t9_extra_min_0425 = r(min)
scalar t9_extra_max_0425 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0425) " / " %12.4f scalar(t9_extra_min_0425) " / " %12.4f scalar(t9_extra_max_0425)

display as text "  Extra scalar diagnostic 0426: t9_expenditure m=2"
quietly summarize t9_expenditure if _mi_m == 2
scalar t9_extra_mean_0426 = r(mean)
scalar t9_extra_min_0426 = r(min)
scalar t9_extra_max_0426 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0426) " / " %12.4f scalar(t9_extra_min_0426) " / " %12.4f scalar(t9_extra_max_0426)

display as text "  Extra scalar diagnostic 0427: t9_health_score m=3"
quietly summarize t9_health_score if _mi_m == 3
scalar t9_extra_mean_0427 = r(mean)
scalar t9_extra_min_0427 = r(min)
scalar t9_extra_max_0427 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0427) " / " %12.4f scalar(t9_extra_min_0427) " / " %12.4f scalar(t9_extra_max_0427)

display as text "  Extra scalar diagnostic 0428: t9_bmi m=0"
quietly summarize t9_bmi if _mi_m == 0
scalar t9_extra_mean_0428 = r(mean)
scalar t9_extra_min_0428 = r(min)
scalar t9_extra_max_0428 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0428) " / " %12.4f scalar(t9_extra_min_0428) " / " %12.4f scalar(t9_extra_max_0428)

display as text "  Extra scalar diagnostic 0429: t9_bp_sys m=1"
quietly summarize t9_bp_sys if _mi_m == 1
scalar t9_extra_mean_0429 = r(mean)
scalar t9_extra_min_0429 = r(min)
scalar t9_extra_max_0429 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0429) " / " %12.4f scalar(t9_extra_min_0429) " / " %12.4f scalar(t9_extra_max_0429)

display as text "  Extra scalar diagnostic 0430: t9_bp_dia m=2"
quietly summarize t9_bp_dia if _mi_m == 2
scalar t9_extra_mean_0430 = r(mean)
scalar t9_extra_min_0430 = r(min)
scalar t9_extra_max_0430 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0430) " / " %12.4f scalar(t9_extra_min_0430) " / " %12.4f scalar(t9_extra_max_0430)

display as text "  Extra scalar diagnostic 0431: t9_depression m=3"
quietly summarize t9_depression if _mi_m == 3
scalar t9_extra_mean_0431 = r(mean)
scalar t9_extra_min_0431 = r(min)
scalar t9_extra_max_0431 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0431) " / " %12.4f scalar(t9_extra_min_0431) " / " %12.4f scalar(t9_extra_max_0431)

display as text "  Extra scalar diagnostic 0432: t9_stress m=0"
quietly summarize t9_stress if _mi_m == 0
scalar t9_extra_mean_0432 = r(mean)
scalar t9_extra_min_0432 = r(min)
scalar t9_extra_max_0432 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0432) " / " %12.4f scalar(t9_extra_min_0432) " / " %12.4f scalar(t9_extra_max_0432)

display as text "  Extra scalar diagnostic 0433: t9_satisfaction m=1"
quietly summarize t9_satisfaction if _mi_m == 1
scalar t9_extra_mean_0433 = r(mean)
scalar t9_extra_min_0433 = r(min)
scalar t9_extra_max_0433 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0433) " / " %12.4f scalar(t9_extra_min_0433) " / " %12.4f scalar(t9_extra_max_0433)

display as text "  Extra scalar diagnostic 0434: t9_sleep m=2"
quietly summarize t9_sleep if _mi_m == 2
scalar t9_extra_mean_0434 = r(mean)
scalar t9_extra_min_0434 = r(min)
scalar t9_extra_max_0434 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0434) " / " %12.4f scalar(t9_extra_min_0434) " / " %12.4f scalar(t9_extra_max_0434)

display as text "  Extra scalar diagnostic 0435: t9_exercise m=3"
quietly summarize t9_exercise if _mi_m == 3
scalar t9_extra_mean_0435 = r(mean)
scalar t9_extra_min_0435 = r(min)
scalar t9_extra_max_0435 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0435) " / " %12.4f scalar(t9_extra_min_0435) " / " %12.4f scalar(t9_extra_max_0435)

display as text "  Extra scalar diagnostic 0436: t9_employed m=0"
quietly summarize t9_employed if _mi_m == 0
scalar t9_extra_mean_0436 = r(mean)
scalar t9_extra_min_0436 = r(min)
scalar t9_extra_max_0436 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0436) " / " %12.4f scalar(t9_extra_min_0436) " / " %12.4f scalar(t9_extra_max_0436)

display as text "  Extra scalar diagnostic 0437: t9_married m=1"
quietly summarize t9_married if _mi_m == 1
scalar t9_extra_mean_0437 = r(mean)
scalar t9_extra_min_0437 = r(min)
scalar t9_extra_max_0437 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0437) " / " %12.4f scalar(t9_extra_min_0437) " / " %12.4f scalar(t9_extra_max_0437)

display as text "  Extra scalar diagnostic 0438: t9_urban m=2"
quietly summarize t9_urban if _mi_m == 2
scalar t9_extra_mean_0438 = r(mean)
scalar t9_extra_min_0438 = r(min)
scalar t9_extra_max_0438 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0438) " / " %12.4f scalar(t9_extra_min_0438) " / " %12.4f scalar(t9_extra_max_0438)

display as text "  Extra scalar diagnostic 0439: t9_homeowner m=3"
quietly summarize t9_homeowner if _mi_m == 3
scalar t9_extra_mean_0439 = r(mean)
scalar t9_extra_min_0439 = r(min)
scalar t9_extra_max_0439 = r(max)
display as text "    mean/min/max=" %12.4f scalar(t9_extra_mean_0439) " / " %12.4f scalar(t9_extra_min_0439) " / " %12.4f scalar(t9_extra_max_0439)

display as result "<<< DONE Section 20: additional scalar diagnostics"
// #endregion Section 20
display as text "===== TAUGHT TASK 9 FILE END CONFIRMED ====="

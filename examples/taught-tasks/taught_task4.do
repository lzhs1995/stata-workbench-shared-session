/*
================================================================================
File: taught_task4.do
Purpose: self-authored Stata Workbench/native Stata 18 stress test
Goal: expose gaps against realtime shared session, low latency, no hangs,
      unchanged source do-files, and native-like graph/table/document output.
Design: generated self-contained script, target >= 7000 executable-rich lines.
================================================================================
*/

version 18
cls
clear all
set more off
set seed 20260503
set maxvar 12000

local __taught_root "`c(pwd)'"
global workfolder "`__taught_root'"
global tempdir "${workfolder}/7_temp"
global docdir "${workfolder}/4_tables"
local t4_run_stamp = subinstr("`=c(current_date)'_`=c(current_time)'", " ", "_", .)
local t4_run_stamp = subinstr("`t4_run_stamp'", ":", "", .)
global figdir4 "${tempdir}/taught_task4_graphs/`t4_run_stamp'"
cap mkdir "${tempdir}/taught_task4_graphs"
cap mkdir "$figdir4"
cap mkdir "$docdir"

display as text "===== TAUGHT TASK 4 SELF-CHECK START ====="
display as text "Stata version: " c(stata_version)
display as text "Date: " c(current_date) " Time: " c(current_time)

// #region ===== Section 1: setup data expansion =====
display as text ">>> START Section 1: setup data expansion"
sysuse auto, clear
expand 5
sort make
gen obs_id = _n
gen price_ln = ln(price)
gen mpg_sq = mpg^2
gen weight_ton = weight / 1000
gen price_per_lb = price / weight
gen length_sq = length^2
gen turn_sq = turn^2
gen displacement_ln = ln(displacement)
gen gear_inv = 1 / gear_ratio
egen price_quart = cut(price), group(4)
egen mpg_tert = cut(mpg), group(3)
egen weight_tert = cut(weight), group(3)
label define tq_price 0 "Q1" 1 "Q2" 2 "Q3" 3 "Q4", replace
label values price_quart tq_price
label define tq_mpg 0 "Low" 1 "Mid" 2 "High", replace
label values mpg_tert tq_mpg
label define tq_weight 0 "Light" 1 "Medium" 2 "Heavy", replace
label values weight_tert tq_weight
gen group_id = mod(obs_id, 10) + 1
gen high_price = price > 8000
gen high_mpg = mpg > 25
gen heavy_car = weight > 3000
compress
describe
summarize price mpg weight length turn displacement gear_ratio
display as result "<<< DONE Section 1: setup data expansion"
// #endregion ===== Section 1: setup data expansion =====


// #region ===== Section 2: generated variables marathon =====
display as text ">>> START Section 2: generated variables marathon"
gen t4v0001 = mpg + rnormal(0, 0.2)
replace t4v0001 = t4v0001 + group_id/3
gen t4v0002 = weight + rnormal(0, 0.3)
replace t4v0002 = t4v0002 + group_id/4
gen t4v0003 = length + rnormal(0, 0.4)
replace t4v0003 = t4v0003 + group_id/5
gen t4v0004 = turn + rnormal(0, 0.5)
replace t4v0004 = t4v0004 + group_id/6
gen t4v0005 = displacement + rnormal(0, 0.6)
replace t4v0005 = t4v0005 + group_id/7
label variable t4v0005 "Generated stress variable 0005"
gen t4v0006 = gear_ratio + rnormal(0, 0.7)
replace t4v0006 = t4v0006 + group_id/8
gen t4v0007 = price + rnormal(0, 0.8)
replace t4v0007 = t4v0007 + group_id/9
gen t4v0008 = mpg + rnormal(0, 0.9)
replace t4v0008 = t4v0008 + group_id/10
gen t4v0009 = weight + rnormal(0, 0.1)
replace t4v0009 = t4v0009 + group_id/11
gen t4v0010 = length + rnormal(0, 0.2)
replace t4v0010 = t4v0010 + group_id/12
label variable t4v0010 "Generated stress variable 0010"
gen t4v0011 = turn + rnormal(0, 0.3)
replace t4v0011 = t4v0011 + group_id/2
gen t4v0012 = displacement + rnormal(0, 0.4)
replace t4v0012 = t4v0012 + group_id/3
gen t4v0013 = gear_ratio + rnormal(0, 0.5)
replace t4v0013 = t4v0013 + group_id/4
gen t4v0014 = price + rnormal(0, 0.6)
replace t4v0014 = t4v0014 + group_id/5
gen t4v0015 = mpg + rnormal(0, 0.7)
replace t4v0015 = t4v0015 + group_id/6
label variable t4v0015 "Generated stress variable 0015"
gen t4v0016 = weight + rnormal(0, 0.8)
replace t4v0016 = t4v0016 + group_id/7
gen t4v0017 = length + rnormal(0, 0.9)
replace t4v0017 = t4v0017 + group_id/8
gen t4v0018 = turn + rnormal(0, 0.1)
replace t4v0018 = t4v0018 + group_id/9
gen t4v0019 = displacement + rnormal(0, 0.2)
replace t4v0019 = t4v0019 + group_id/10
gen t4v0020 = gear_ratio + rnormal(0, 0.3)
replace t4v0020 = t4v0020 + group_id/11
label variable t4v0020 "Generated stress variable 0020"
quietly summarize t4v0020
display as text "[VAR] t4v0020 mean=" %9.4f r(mean)
gen t4v0021 = price + rnormal(0, 0.4)
replace t4v0021 = t4v0021 + group_id/12
gen t4v0022 = mpg + rnormal(0, 0.5)
replace t4v0022 = t4v0022 + group_id/2
gen t4v0023 = weight + rnormal(0, 0.6)
replace t4v0023 = t4v0023 + group_id/3
gen t4v0024 = length + rnormal(0, 0.7)
replace t4v0024 = t4v0024 + group_id/4
gen t4v0025 = turn + rnormal(0, 0.8)
replace t4v0025 = t4v0025 + group_id/5
label variable t4v0025 "Generated stress variable 0025"
gen t4v0026 = displacement + rnormal(0, 0.9)
replace t4v0026 = t4v0026 + group_id/6
gen t4v0027 = gear_ratio + rnormal(0, 0.1)
replace t4v0027 = t4v0027 + group_id/7
gen t4v0028 = price + rnormal(0, 0.2)
replace t4v0028 = t4v0028 + group_id/8
gen t4v0029 = mpg + rnormal(0, 0.3)
replace t4v0029 = t4v0029 + group_id/9
gen t4v0030 = weight + rnormal(0, 0.4)
replace t4v0030 = t4v0030 + group_id/10
label variable t4v0030 "Generated stress variable 0030"
gen t4v0031 = length + rnormal(0, 0.5)
replace t4v0031 = t4v0031 + group_id/11
gen t4v0032 = turn + rnormal(0, 0.6)
replace t4v0032 = t4v0032 + group_id/12
gen t4v0033 = displacement + rnormal(0, 0.7)
replace t4v0033 = t4v0033 + group_id/2
gen t4v0034 = gear_ratio + rnormal(0, 0.8)
replace t4v0034 = t4v0034 + group_id/3
gen t4v0035 = price + rnormal(0, 0.9)
replace t4v0035 = t4v0035 + group_id/4
label variable t4v0035 "Generated stress variable 0035"
gen t4v0036 = mpg + rnormal(0, 0.1)
replace t4v0036 = t4v0036 + group_id/5
gen t4v0037 = weight + rnormal(0, 0.2)
replace t4v0037 = t4v0037 + group_id/6
gen t4v0038 = length + rnormal(0, 0.3)
replace t4v0038 = t4v0038 + group_id/7
gen t4v0039 = turn + rnormal(0, 0.4)
replace t4v0039 = t4v0039 + group_id/8
gen t4v0040 = displacement + rnormal(0, 0.5)
replace t4v0040 = t4v0040 + group_id/9
label variable t4v0040 "Generated stress variable 0040"
quietly summarize t4v0040
display as text "[VAR] t4v0040 mean=" %9.4f r(mean)
gen t4v0041 = gear_ratio + rnormal(0, 0.6)
replace t4v0041 = t4v0041 + group_id/10
gen t4v0042 = price + rnormal(0, 0.7)
replace t4v0042 = t4v0042 + group_id/11
gen t4v0043 = mpg + rnormal(0, 0.8)
replace t4v0043 = t4v0043 + group_id/12
gen t4v0044 = weight + rnormal(0, 0.9)
replace t4v0044 = t4v0044 + group_id/2
gen t4v0045 = length + rnormal(0, 0.1)
replace t4v0045 = t4v0045 + group_id/3
label variable t4v0045 "Generated stress variable 0045"
gen t4v0046 = turn + rnormal(0, 0.2)
replace t4v0046 = t4v0046 + group_id/4
gen t4v0047 = displacement + rnormal(0, 0.3)
replace t4v0047 = t4v0047 + group_id/5
gen t4v0048 = gear_ratio + rnormal(0, 0.4)
replace t4v0048 = t4v0048 + group_id/6
gen t4v0049 = price + rnormal(0, 0.5)
replace t4v0049 = t4v0049 + group_id/7
gen t4v0050 = mpg + rnormal(0, 0.6)
replace t4v0050 = t4v0050 + group_id/8
label variable t4v0050 "Generated stress variable 0050"
gen t4v0051 = weight + rnormal(0, 0.7)
replace t4v0051 = t4v0051 + group_id/9
gen t4v0052 = length + rnormal(0, 0.8)
replace t4v0052 = t4v0052 + group_id/10
gen t4v0053 = turn + rnormal(0, 0.9)
replace t4v0053 = t4v0053 + group_id/11
gen t4v0054 = displacement + rnormal(0, 0.1)
replace t4v0054 = t4v0054 + group_id/12
gen t4v0055 = gear_ratio + rnormal(0, 0.2)
replace t4v0055 = t4v0055 + group_id/2
label variable t4v0055 "Generated stress variable 0055"
gen t4v0056 = price + rnormal(0, 0.3)
replace t4v0056 = t4v0056 + group_id/3
gen t4v0057 = mpg + rnormal(0, 0.4)
replace t4v0057 = t4v0057 + group_id/4
gen t4v0058 = weight + rnormal(0, 0.5)
replace t4v0058 = t4v0058 + group_id/5
gen t4v0059 = length + rnormal(0, 0.6)
replace t4v0059 = t4v0059 + group_id/6
gen t4v0060 = turn + rnormal(0, 0.7)
replace t4v0060 = t4v0060 + group_id/7
label variable t4v0060 "Generated stress variable 0060"
quietly summarize t4v0060
display as text "[VAR] t4v0060 mean=" %9.4f r(mean)
gen t4v0061 = displacement + rnormal(0, 0.8)
replace t4v0061 = t4v0061 + group_id/8
gen t4v0062 = gear_ratio + rnormal(0, 0.9)
replace t4v0062 = t4v0062 + group_id/9
gen t4v0063 = price + rnormal(0, 0.1)
replace t4v0063 = t4v0063 + group_id/10
gen t4v0064 = mpg + rnormal(0, 0.2)
replace t4v0064 = t4v0064 + group_id/11
gen t4v0065 = weight + rnormal(0, 0.3)
replace t4v0065 = t4v0065 + group_id/12
label variable t4v0065 "Generated stress variable 0065"
gen t4v0066 = length + rnormal(0, 0.4)
replace t4v0066 = t4v0066 + group_id/2
gen t4v0067 = turn + rnormal(0, 0.5)
replace t4v0067 = t4v0067 + group_id/3
gen t4v0068 = displacement + rnormal(0, 0.6)
replace t4v0068 = t4v0068 + group_id/4
gen t4v0069 = gear_ratio + rnormal(0, 0.7)
replace t4v0069 = t4v0069 + group_id/5
gen t4v0070 = price + rnormal(0, 0.8)
replace t4v0070 = t4v0070 + group_id/6
label variable t4v0070 "Generated stress variable 0070"
gen t4v0071 = mpg + rnormal(0, 0.9)
replace t4v0071 = t4v0071 + group_id/7
gen t4v0072 = weight + rnormal(0, 0.1)
replace t4v0072 = t4v0072 + group_id/8
gen t4v0073 = length + rnormal(0, 0.2)
replace t4v0073 = t4v0073 + group_id/9
gen t4v0074 = turn + rnormal(0, 0.3)
replace t4v0074 = t4v0074 + group_id/10
gen t4v0075 = displacement + rnormal(0, 0.4)
replace t4v0075 = t4v0075 + group_id/11
label variable t4v0075 "Generated stress variable 0075"
gen t4v0076 = gear_ratio + rnormal(0, 0.5)
replace t4v0076 = t4v0076 + group_id/12
gen t4v0077 = price + rnormal(0, 0.6)
replace t4v0077 = t4v0077 + group_id/2
gen t4v0078 = mpg + rnormal(0, 0.7)
replace t4v0078 = t4v0078 + group_id/3
gen t4v0079 = weight + rnormal(0, 0.8)
replace t4v0079 = t4v0079 + group_id/4
gen t4v0080 = length + rnormal(0, 0.9)
replace t4v0080 = t4v0080 + group_id/5
label variable t4v0080 "Generated stress variable 0080"
quietly summarize t4v0080
display as text "[VAR] t4v0080 mean=" %9.4f r(mean)
gen t4v0081 = turn + rnormal(0, 0.1)
replace t4v0081 = t4v0081 + group_id/6
gen t4v0082 = displacement + rnormal(0, 0.2)
replace t4v0082 = t4v0082 + group_id/7
gen t4v0083 = gear_ratio + rnormal(0, 0.3)
replace t4v0083 = t4v0083 + group_id/8
gen t4v0084 = price + rnormal(0, 0.4)
replace t4v0084 = t4v0084 + group_id/9
gen t4v0085 = mpg + rnormal(0, 0.5)
replace t4v0085 = t4v0085 + group_id/10
label variable t4v0085 "Generated stress variable 0085"
gen t4v0086 = weight + rnormal(0, 0.6)
replace t4v0086 = t4v0086 + group_id/11
gen t4v0087 = length + rnormal(0, 0.7)
replace t4v0087 = t4v0087 + group_id/12
gen t4v0088 = turn + rnormal(0, 0.8)
replace t4v0088 = t4v0088 + group_id/2
gen t4v0089 = displacement + rnormal(0, 0.9)
replace t4v0089 = t4v0089 + group_id/3
gen t4v0090 = gear_ratio + rnormal(0, 0.1)
replace t4v0090 = t4v0090 + group_id/4
label variable t4v0090 "Generated stress variable 0090"
gen t4v0091 = price + rnormal(0, 0.2)
replace t4v0091 = t4v0091 + group_id/5
gen t4v0092 = mpg + rnormal(0, 0.3)
replace t4v0092 = t4v0092 + group_id/6
gen t4v0093 = weight + rnormal(0, 0.4)
replace t4v0093 = t4v0093 + group_id/7
gen t4v0094 = length + rnormal(0, 0.5)
replace t4v0094 = t4v0094 + group_id/8
gen t4v0095 = turn + rnormal(0, 0.6)
replace t4v0095 = t4v0095 + group_id/9
label variable t4v0095 "Generated stress variable 0095"
gen t4v0096 = displacement + rnormal(0, 0.7)
replace t4v0096 = t4v0096 + group_id/10
gen t4v0097 = gear_ratio + rnormal(0, 0.8)
replace t4v0097 = t4v0097 + group_id/11
gen t4v0098 = price + rnormal(0, 0.9)
replace t4v0098 = t4v0098 + group_id/12
gen t4v0099 = mpg + rnormal(0, 0.1)
replace t4v0099 = t4v0099 + group_id/2
gen t4v0100 = weight + rnormal(0, 0.2)
replace t4v0100 = t4v0100 + group_id/3
label variable t4v0100 "Generated stress variable 0100"
quietly summarize t4v0100
display as text "[VAR] t4v0100 mean=" %9.4f r(mean)
gen t4v0101 = length + rnormal(0, 0.3)
replace t4v0101 = t4v0101 + group_id/4
gen t4v0102 = turn + rnormal(0, 0.4)
replace t4v0102 = t4v0102 + group_id/5
gen t4v0103 = displacement + rnormal(0, 0.5)
replace t4v0103 = t4v0103 + group_id/6
gen t4v0104 = gear_ratio + rnormal(0, 0.6)
replace t4v0104 = t4v0104 + group_id/7
gen t4v0105 = price + rnormal(0, 0.7)
replace t4v0105 = t4v0105 + group_id/8
label variable t4v0105 "Generated stress variable 0105"
gen t4v0106 = mpg + rnormal(0, 0.8)
replace t4v0106 = t4v0106 + group_id/9
gen t4v0107 = weight + rnormal(0, 0.9)
replace t4v0107 = t4v0107 + group_id/10
gen t4v0108 = length + rnormal(0, 0.1)
replace t4v0108 = t4v0108 + group_id/11
gen t4v0109 = turn + rnormal(0, 0.2)
replace t4v0109 = t4v0109 + group_id/12
gen t4v0110 = displacement + rnormal(0, 0.3)
replace t4v0110 = t4v0110 + group_id/2
label variable t4v0110 "Generated stress variable 0110"
gen t4v0111 = gear_ratio + rnormal(0, 0.4)
replace t4v0111 = t4v0111 + group_id/3
gen t4v0112 = price + rnormal(0, 0.5)
replace t4v0112 = t4v0112 + group_id/4
gen t4v0113 = mpg + rnormal(0, 0.6)
replace t4v0113 = t4v0113 + group_id/5
gen t4v0114 = weight + rnormal(0, 0.7)
replace t4v0114 = t4v0114 + group_id/6
gen t4v0115 = length + rnormal(0, 0.8)
replace t4v0115 = t4v0115 + group_id/7
label variable t4v0115 "Generated stress variable 0115"
gen t4v0116 = turn + rnormal(0, 0.9)
replace t4v0116 = t4v0116 + group_id/8
gen t4v0117 = displacement + rnormal(0, 0.1)
replace t4v0117 = t4v0117 + group_id/9
gen t4v0118 = gear_ratio + rnormal(0, 0.2)
replace t4v0118 = t4v0118 + group_id/10
gen t4v0119 = price + rnormal(0, 0.3)
replace t4v0119 = t4v0119 + group_id/11
gen t4v0120 = mpg + rnormal(0, 0.4)
replace t4v0120 = t4v0120 + group_id/12
label variable t4v0120 "Generated stress variable 0120"
quietly summarize t4v0120
display as text "[VAR] t4v0120 mean=" %9.4f r(mean)
gen t4v0121 = weight + rnormal(0, 0.5)
replace t4v0121 = t4v0121 + group_id/2
gen t4v0122 = length + rnormal(0, 0.6)
replace t4v0122 = t4v0122 + group_id/3
gen t4v0123 = turn + rnormal(0, 0.7)
replace t4v0123 = t4v0123 + group_id/4
gen t4v0124 = displacement + rnormal(0, 0.8)
replace t4v0124 = t4v0124 + group_id/5
gen t4v0125 = gear_ratio + rnormal(0, 0.9)
replace t4v0125 = t4v0125 + group_id/6
label variable t4v0125 "Generated stress variable 0125"
gen t4v0126 = price + rnormal(0, 0.1)
replace t4v0126 = t4v0126 + group_id/7
gen t4v0127 = mpg + rnormal(0, 0.2)
replace t4v0127 = t4v0127 + group_id/8
gen t4v0128 = weight + rnormal(0, 0.3)
replace t4v0128 = t4v0128 + group_id/9
gen t4v0129 = length + rnormal(0, 0.4)
replace t4v0129 = t4v0129 + group_id/10
gen t4v0130 = turn + rnormal(0, 0.5)
replace t4v0130 = t4v0130 + group_id/11
label variable t4v0130 "Generated stress variable 0130"
gen t4v0131 = displacement + rnormal(0, 0.6)
replace t4v0131 = t4v0131 + group_id/12
gen t4v0132 = gear_ratio + rnormal(0, 0.7)
replace t4v0132 = t4v0132 + group_id/2
gen t4v0133 = price + rnormal(0, 0.8)
replace t4v0133 = t4v0133 + group_id/3
gen t4v0134 = mpg + rnormal(0, 0.9)
replace t4v0134 = t4v0134 + group_id/4
gen t4v0135 = weight + rnormal(0, 0.1)
replace t4v0135 = t4v0135 + group_id/5
label variable t4v0135 "Generated stress variable 0135"
gen t4v0136 = length + rnormal(0, 0.2)
replace t4v0136 = t4v0136 + group_id/6
gen t4v0137 = turn + rnormal(0, 0.3)
replace t4v0137 = t4v0137 + group_id/7
gen t4v0138 = displacement + rnormal(0, 0.4)
replace t4v0138 = t4v0138 + group_id/8
gen t4v0139 = gear_ratio + rnormal(0, 0.5)
replace t4v0139 = t4v0139 + group_id/9
gen t4v0140 = price + rnormal(0, 0.6)
replace t4v0140 = t4v0140 + group_id/10
label variable t4v0140 "Generated stress variable 0140"
quietly summarize t4v0140
display as text "[VAR] t4v0140 mean=" %9.4f r(mean)
gen t4v0141 = mpg + rnormal(0, 0.7)
replace t4v0141 = t4v0141 + group_id/11
gen t4v0142 = weight + rnormal(0, 0.8)
replace t4v0142 = t4v0142 + group_id/12
gen t4v0143 = length + rnormal(0, 0.9)
replace t4v0143 = t4v0143 + group_id/2
gen t4v0144 = turn + rnormal(0, 0.1)
replace t4v0144 = t4v0144 + group_id/3
gen t4v0145 = displacement + rnormal(0, 0.2)
replace t4v0145 = t4v0145 + group_id/4
label variable t4v0145 "Generated stress variable 0145"
gen t4v0146 = gear_ratio + rnormal(0, 0.3)
replace t4v0146 = t4v0146 + group_id/5
gen t4v0147 = price + rnormal(0, 0.4)
replace t4v0147 = t4v0147 + group_id/6
gen t4v0148 = mpg + rnormal(0, 0.5)
replace t4v0148 = t4v0148 + group_id/7
gen t4v0149 = weight + rnormal(0, 0.6)
replace t4v0149 = t4v0149 + group_id/8
gen t4v0150 = length + rnormal(0, 0.7)
replace t4v0150 = t4v0150 + group_id/9
label variable t4v0150 "Generated stress variable 0150"
gen t4v0151 = turn + rnormal(0, 0.8)
replace t4v0151 = t4v0151 + group_id/10
gen t4v0152 = displacement + rnormal(0, 0.9)
replace t4v0152 = t4v0152 + group_id/11
gen t4v0153 = gear_ratio + rnormal(0, 0.1)
replace t4v0153 = t4v0153 + group_id/12
gen t4v0154 = price + rnormal(0, 0.2)
replace t4v0154 = t4v0154 + group_id/2
gen t4v0155 = mpg + rnormal(0, 0.3)
replace t4v0155 = t4v0155 + group_id/3
label variable t4v0155 "Generated stress variable 0155"
gen t4v0156 = weight + rnormal(0, 0.4)
replace t4v0156 = t4v0156 + group_id/4
gen t4v0157 = length + rnormal(0, 0.5)
replace t4v0157 = t4v0157 + group_id/5
gen t4v0158 = turn + rnormal(0, 0.6)
replace t4v0158 = t4v0158 + group_id/6
gen t4v0159 = displacement + rnormal(0, 0.7)
replace t4v0159 = t4v0159 + group_id/7
gen t4v0160 = gear_ratio + rnormal(0, 0.8)
replace t4v0160 = t4v0160 + group_id/8
label variable t4v0160 "Generated stress variable 0160"
quietly summarize t4v0160
display as text "[VAR] t4v0160 mean=" %9.4f r(mean)
gen t4v0161 = price + rnormal(0, 0.9)
replace t4v0161 = t4v0161 + group_id/9
gen t4v0162 = mpg + rnormal(0, 0.1)
replace t4v0162 = t4v0162 + group_id/10
gen t4v0163 = weight + rnormal(0, 0.2)
replace t4v0163 = t4v0163 + group_id/11
gen t4v0164 = length + rnormal(0, 0.3)
replace t4v0164 = t4v0164 + group_id/12
gen t4v0165 = turn + rnormal(0, 0.4)
replace t4v0165 = t4v0165 + group_id/2
label variable t4v0165 "Generated stress variable 0165"
gen t4v0166 = displacement + rnormal(0, 0.5)
replace t4v0166 = t4v0166 + group_id/3
gen t4v0167 = gear_ratio + rnormal(0, 0.6)
replace t4v0167 = t4v0167 + group_id/4
gen t4v0168 = price + rnormal(0, 0.7)
replace t4v0168 = t4v0168 + group_id/5
gen t4v0169 = mpg + rnormal(0, 0.8)
replace t4v0169 = t4v0169 + group_id/6
gen t4v0170 = weight + rnormal(0, 0.9)
replace t4v0170 = t4v0170 + group_id/7
label variable t4v0170 "Generated stress variable 0170"
gen t4v0171 = length + rnormal(0, 0.1)
replace t4v0171 = t4v0171 + group_id/8
gen t4v0172 = turn + rnormal(0, 0.2)
replace t4v0172 = t4v0172 + group_id/9
gen t4v0173 = displacement + rnormal(0, 0.3)
replace t4v0173 = t4v0173 + group_id/10
gen t4v0174 = gear_ratio + rnormal(0, 0.4)
replace t4v0174 = t4v0174 + group_id/11
gen t4v0175 = price + rnormal(0, 0.5)
replace t4v0175 = t4v0175 + group_id/12
label variable t4v0175 "Generated stress variable 0175"
gen t4v0176 = mpg + rnormal(0, 0.6)
replace t4v0176 = t4v0176 + group_id/2
gen t4v0177 = weight + rnormal(0, 0.7)
replace t4v0177 = t4v0177 + group_id/3
gen t4v0178 = length + rnormal(0, 0.8)
replace t4v0178 = t4v0178 + group_id/4
gen t4v0179 = turn + rnormal(0, 0.9)
replace t4v0179 = t4v0179 + group_id/5
gen t4v0180 = displacement + rnormal(0, 0.1)
replace t4v0180 = t4v0180 + group_id/6
label variable t4v0180 "Generated stress variable 0180"
quietly summarize t4v0180
display as text "[VAR] t4v0180 mean=" %9.4f r(mean)
gen t4v0181 = gear_ratio + rnormal(0, 0.2)
replace t4v0181 = t4v0181 + group_id/7
gen t4v0182 = price + rnormal(0, 0.3)
replace t4v0182 = t4v0182 + group_id/8
gen t4v0183 = mpg + rnormal(0, 0.4)
replace t4v0183 = t4v0183 + group_id/9
gen t4v0184 = weight + rnormal(0, 0.5)
replace t4v0184 = t4v0184 + group_id/10
gen t4v0185 = length + rnormal(0, 0.6)
replace t4v0185 = t4v0185 + group_id/11
label variable t4v0185 "Generated stress variable 0185"
gen t4v0186 = turn + rnormal(0, 0.7)
replace t4v0186 = t4v0186 + group_id/12
gen t4v0187 = displacement + rnormal(0, 0.8)
replace t4v0187 = t4v0187 + group_id/2
gen t4v0188 = gear_ratio + rnormal(0, 0.9)
replace t4v0188 = t4v0188 + group_id/3
gen t4v0189 = price + rnormal(0, 0.1)
replace t4v0189 = t4v0189 + group_id/4
gen t4v0190 = mpg + rnormal(0, 0.2)
replace t4v0190 = t4v0190 + group_id/5
label variable t4v0190 "Generated stress variable 0190"
gen t4v0191 = weight + rnormal(0, 0.3)
replace t4v0191 = t4v0191 + group_id/6
gen t4v0192 = length + rnormal(0, 0.4)
replace t4v0192 = t4v0192 + group_id/7
gen t4v0193 = turn + rnormal(0, 0.5)
replace t4v0193 = t4v0193 + group_id/8
gen t4v0194 = displacement + rnormal(0, 0.6)
replace t4v0194 = t4v0194 + group_id/9
gen t4v0195 = gear_ratio + rnormal(0, 0.7)
replace t4v0195 = t4v0195 + group_id/10
label variable t4v0195 "Generated stress variable 0195"
gen t4v0196 = price + rnormal(0, 0.8)
replace t4v0196 = t4v0196 + group_id/11
gen t4v0197 = mpg + rnormal(0, 0.9)
replace t4v0197 = t4v0197 + group_id/12
gen t4v0198 = weight + rnormal(0, 0.1)
replace t4v0198 = t4v0198 + group_id/2
gen t4v0199 = length + rnormal(0, 0.2)
replace t4v0199 = t4v0199 + group_id/3
gen t4v0200 = turn + rnormal(0, 0.3)
replace t4v0200 = t4v0200 + group_id/4
label variable t4v0200 "Generated stress variable 0200"
quietly summarize t4v0200
display as text "[VAR] t4v0200 mean=" %9.4f r(mean)
gen t4v0201 = displacement + rnormal(0, 0.4)
replace t4v0201 = t4v0201 + group_id/5
gen t4v0202 = gear_ratio + rnormal(0, 0.5)
replace t4v0202 = t4v0202 + group_id/6
gen t4v0203 = price + rnormal(0, 0.6)
replace t4v0203 = t4v0203 + group_id/7
gen t4v0204 = mpg + rnormal(0, 0.7)
replace t4v0204 = t4v0204 + group_id/8
gen t4v0205 = weight + rnormal(0, 0.8)
replace t4v0205 = t4v0205 + group_id/9
label variable t4v0205 "Generated stress variable 0205"
gen t4v0206 = length + rnormal(0, 0.9)
replace t4v0206 = t4v0206 + group_id/10
gen t4v0207 = turn + rnormal(0, 0.1)
replace t4v0207 = t4v0207 + group_id/11
gen t4v0208 = displacement + rnormal(0, 0.2)
replace t4v0208 = t4v0208 + group_id/12
gen t4v0209 = gear_ratio + rnormal(0, 0.3)
replace t4v0209 = t4v0209 + group_id/2
gen t4v0210 = price + rnormal(0, 0.4)
replace t4v0210 = t4v0210 + group_id/3
label variable t4v0210 "Generated stress variable 0210"
gen t4v0211 = mpg + rnormal(0, 0.5)
replace t4v0211 = t4v0211 + group_id/4
gen t4v0212 = weight + rnormal(0, 0.6)
replace t4v0212 = t4v0212 + group_id/5
gen t4v0213 = length + rnormal(0, 0.7)
replace t4v0213 = t4v0213 + group_id/6
gen t4v0214 = turn + rnormal(0, 0.8)
replace t4v0214 = t4v0214 + group_id/7
gen t4v0215 = displacement + rnormal(0, 0.9)
replace t4v0215 = t4v0215 + group_id/8
label variable t4v0215 "Generated stress variable 0215"
gen t4v0216 = gear_ratio + rnormal(0, 0.1)
replace t4v0216 = t4v0216 + group_id/9
gen t4v0217 = price + rnormal(0, 0.2)
replace t4v0217 = t4v0217 + group_id/10
gen t4v0218 = mpg + rnormal(0, 0.3)
replace t4v0218 = t4v0218 + group_id/11
gen t4v0219 = weight + rnormal(0, 0.4)
replace t4v0219 = t4v0219 + group_id/12
gen t4v0220 = length + rnormal(0, 0.5)
replace t4v0220 = t4v0220 + group_id/2
label variable t4v0220 "Generated stress variable 0220"
quietly summarize t4v0220
display as text "[VAR] t4v0220 mean=" %9.4f r(mean)
gen t4v0221 = turn + rnormal(0, 0.6)
replace t4v0221 = t4v0221 + group_id/3
gen t4v0222 = displacement + rnormal(0, 0.7)
replace t4v0222 = t4v0222 + group_id/4
gen t4v0223 = gear_ratio + rnormal(0, 0.8)
replace t4v0223 = t4v0223 + group_id/5
gen t4v0224 = price + rnormal(0, 0.9)
replace t4v0224 = t4v0224 + group_id/6
gen t4v0225 = mpg + rnormal(0, 0.1)
replace t4v0225 = t4v0225 + group_id/7
label variable t4v0225 "Generated stress variable 0225"
gen t4v0226 = weight + rnormal(0, 0.2)
replace t4v0226 = t4v0226 + group_id/8
gen t4v0227 = length + rnormal(0, 0.3)
replace t4v0227 = t4v0227 + group_id/9
gen t4v0228 = turn + rnormal(0, 0.4)
replace t4v0228 = t4v0228 + group_id/10
gen t4v0229 = displacement + rnormal(0, 0.5)
replace t4v0229 = t4v0229 + group_id/11
gen t4v0230 = gear_ratio + rnormal(0, 0.6)
replace t4v0230 = t4v0230 + group_id/12
label variable t4v0230 "Generated stress variable 0230"
gen t4v0231 = price + rnormal(0, 0.7)
replace t4v0231 = t4v0231 + group_id/2
gen t4v0232 = mpg + rnormal(0, 0.8)
replace t4v0232 = t4v0232 + group_id/3
gen t4v0233 = weight + rnormal(0, 0.9)
replace t4v0233 = t4v0233 + group_id/4
gen t4v0234 = length + rnormal(0, 0.1)
replace t4v0234 = t4v0234 + group_id/5
gen t4v0235 = turn + rnormal(0, 0.2)
replace t4v0235 = t4v0235 + group_id/6
label variable t4v0235 "Generated stress variable 0235"
gen t4v0236 = displacement + rnormal(0, 0.3)
replace t4v0236 = t4v0236 + group_id/7
gen t4v0237 = gear_ratio + rnormal(0, 0.4)
replace t4v0237 = t4v0237 + group_id/8
gen t4v0238 = price + rnormal(0, 0.5)
replace t4v0238 = t4v0238 + group_id/9
gen t4v0239 = mpg + rnormal(0, 0.6)
replace t4v0239 = t4v0239 + group_id/10
gen t4v0240 = weight + rnormal(0, 0.7)
replace t4v0240 = t4v0240 + group_id/11
label variable t4v0240 "Generated stress variable 0240"
quietly summarize t4v0240
display as text "[VAR] t4v0240 mean=" %9.4f r(mean)
gen t4v0241 = length + rnormal(0, 0.8)
replace t4v0241 = t4v0241 + group_id/12
gen t4v0242 = turn + rnormal(0, 0.9)
replace t4v0242 = t4v0242 + group_id/2
gen t4v0243 = displacement + rnormal(0, 0.1)
replace t4v0243 = t4v0243 + group_id/3
gen t4v0244 = gear_ratio + rnormal(0, 0.2)
replace t4v0244 = t4v0244 + group_id/4
gen t4v0245 = price + rnormal(0, 0.3)
replace t4v0245 = t4v0245 + group_id/5
label variable t4v0245 "Generated stress variable 0245"
gen t4v0246 = mpg + rnormal(0, 0.4)
replace t4v0246 = t4v0246 + group_id/6
gen t4v0247 = weight + rnormal(0, 0.5)
replace t4v0247 = t4v0247 + group_id/7
gen t4v0248 = length + rnormal(0, 0.6)
replace t4v0248 = t4v0248 + group_id/8
gen t4v0249 = turn + rnormal(0, 0.7)
replace t4v0249 = t4v0249 + group_id/9
gen t4v0250 = displacement + rnormal(0, 0.8)
replace t4v0250 = t4v0250 + group_id/10
label variable t4v0250 "Generated stress variable 0250"
gen t4v0251 = gear_ratio + rnormal(0, 0.9)
replace t4v0251 = t4v0251 + group_id/11
gen t4v0252 = price + rnormal(0, 0.1)
replace t4v0252 = t4v0252 + group_id/12
gen t4v0253 = mpg + rnormal(0, 0.2)
replace t4v0253 = t4v0253 + group_id/2
gen t4v0254 = weight + rnormal(0, 0.3)
replace t4v0254 = t4v0254 + group_id/3
gen t4v0255 = length + rnormal(0, 0.4)
replace t4v0255 = t4v0255 + group_id/4
label variable t4v0255 "Generated stress variable 0255"
gen t4v0256 = turn + rnormal(0, 0.5)
replace t4v0256 = t4v0256 + group_id/5
gen t4v0257 = displacement + rnormal(0, 0.6)
replace t4v0257 = t4v0257 + group_id/6
gen t4v0258 = gear_ratio + rnormal(0, 0.7)
replace t4v0258 = t4v0258 + group_id/7
gen t4v0259 = price + rnormal(0, 0.8)
replace t4v0259 = t4v0259 + group_id/8
gen t4v0260 = mpg + rnormal(0, 0.9)
replace t4v0260 = t4v0260 + group_id/9
label variable t4v0260 "Generated stress variable 0260"
quietly summarize t4v0260
display as text "[VAR] t4v0260 mean=" %9.4f r(mean)
gen t4v0261 = weight + rnormal(0, 0.1)
replace t4v0261 = t4v0261 + group_id/10
gen t4v0262 = length + rnormal(0, 0.2)
replace t4v0262 = t4v0262 + group_id/11
gen t4v0263 = turn + rnormal(0, 0.3)
replace t4v0263 = t4v0263 + group_id/12
gen t4v0264 = displacement + rnormal(0, 0.4)
replace t4v0264 = t4v0264 + group_id/2
gen t4v0265 = gear_ratio + rnormal(0, 0.5)
replace t4v0265 = t4v0265 + group_id/3
label variable t4v0265 "Generated stress variable 0265"
gen t4v0266 = price + rnormal(0, 0.6)
replace t4v0266 = t4v0266 + group_id/4
gen t4v0267 = mpg + rnormal(0, 0.7)
replace t4v0267 = t4v0267 + group_id/5
gen t4v0268 = weight + rnormal(0, 0.8)
replace t4v0268 = t4v0268 + group_id/6
gen t4v0269 = length + rnormal(0, 0.9)
replace t4v0269 = t4v0269 + group_id/7
gen t4v0270 = turn + rnormal(0, 0.1)
replace t4v0270 = t4v0270 + group_id/8
label variable t4v0270 "Generated stress variable 0270"
gen t4v0271 = displacement + rnormal(0, 0.2)
replace t4v0271 = t4v0271 + group_id/9
gen t4v0272 = gear_ratio + rnormal(0, 0.3)
replace t4v0272 = t4v0272 + group_id/10
gen t4v0273 = price + rnormal(0, 0.4)
replace t4v0273 = t4v0273 + group_id/11
gen t4v0274 = mpg + rnormal(0, 0.5)
replace t4v0274 = t4v0274 + group_id/12
gen t4v0275 = weight + rnormal(0, 0.6)
replace t4v0275 = t4v0275 + group_id/2
label variable t4v0275 "Generated stress variable 0275"
gen t4v0276 = length + rnormal(0, 0.7)
replace t4v0276 = t4v0276 + group_id/3
gen t4v0277 = turn + rnormal(0, 0.8)
replace t4v0277 = t4v0277 + group_id/4
gen t4v0278 = displacement + rnormal(0, 0.9)
replace t4v0278 = t4v0278 + group_id/5
gen t4v0279 = gear_ratio + rnormal(0, 0.1)
replace t4v0279 = t4v0279 + group_id/6
gen t4v0280 = price + rnormal(0, 0.2)
replace t4v0280 = t4v0280 + group_id/7
label variable t4v0280 "Generated stress variable 0280"
quietly summarize t4v0280
display as text "[VAR] t4v0280 mean=" %9.4f r(mean)
gen t4v0281 = mpg + rnormal(0, 0.3)
replace t4v0281 = t4v0281 + group_id/8
gen t4v0282 = weight + rnormal(0, 0.4)
replace t4v0282 = t4v0282 + group_id/9
gen t4v0283 = length + rnormal(0, 0.5)
replace t4v0283 = t4v0283 + group_id/10
gen t4v0284 = turn + rnormal(0, 0.6)
replace t4v0284 = t4v0284 + group_id/11
gen t4v0285 = displacement + rnormal(0, 0.7)
replace t4v0285 = t4v0285 + group_id/12
label variable t4v0285 "Generated stress variable 0285"
gen t4v0286 = gear_ratio + rnormal(0, 0.8)
replace t4v0286 = t4v0286 + group_id/2
gen t4v0287 = price + rnormal(0, 0.9)
replace t4v0287 = t4v0287 + group_id/3
gen t4v0288 = mpg + rnormal(0, 0.1)
replace t4v0288 = t4v0288 + group_id/4
gen t4v0289 = weight + rnormal(0, 0.2)
replace t4v0289 = t4v0289 + group_id/5
gen t4v0290 = length + rnormal(0, 0.3)
replace t4v0290 = t4v0290 + group_id/6
label variable t4v0290 "Generated stress variable 0290"
gen t4v0291 = turn + rnormal(0, 0.4)
replace t4v0291 = t4v0291 + group_id/7
gen t4v0292 = displacement + rnormal(0, 0.5)
replace t4v0292 = t4v0292 + group_id/8
gen t4v0293 = gear_ratio + rnormal(0, 0.6)
replace t4v0293 = t4v0293 + group_id/9
gen t4v0294 = price + rnormal(0, 0.7)
replace t4v0294 = t4v0294 + group_id/10
gen t4v0295 = mpg + rnormal(0, 0.8)
replace t4v0295 = t4v0295 + group_id/11
label variable t4v0295 "Generated stress variable 0295"
gen t4v0296 = weight + rnormal(0, 0.9)
replace t4v0296 = t4v0296 + group_id/12
gen t4v0297 = length + rnormal(0, 0.1)
replace t4v0297 = t4v0297 + group_id/2
gen t4v0298 = turn + rnormal(0, 0.2)
replace t4v0298 = t4v0298 + group_id/3
gen t4v0299 = displacement + rnormal(0, 0.3)
replace t4v0299 = t4v0299 + group_id/4
gen t4v0300 = gear_ratio + rnormal(0, 0.4)
replace t4v0300 = t4v0300 + group_id/5
label variable t4v0300 "Generated stress variable 0300"
quietly summarize t4v0300
display as text "[VAR] t4v0300 mean=" %9.4f r(mean)
gen t4v0301 = price + rnormal(0, 0.5)
replace t4v0301 = t4v0301 + group_id/6
gen t4v0302 = mpg + rnormal(0, 0.6)
replace t4v0302 = t4v0302 + group_id/7
gen t4v0303 = weight + rnormal(0, 0.7)
replace t4v0303 = t4v0303 + group_id/8
gen t4v0304 = length + rnormal(0, 0.8)
replace t4v0304 = t4v0304 + group_id/9
gen t4v0305 = turn + rnormal(0, 0.9)
replace t4v0305 = t4v0305 + group_id/10
label variable t4v0305 "Generated stress variable 0305"
gen t4v0306 = displacement + rnormal(0, 0.1)
replace t4v0306 = t4v0306 + group_id/11
gen t4v0307 = gear_ratio + rnormal(0, 0.2)
replace t4v0307 = t4v0307 + group_id/12
gen t4v0308 = price + rnormal(0, 0.3)
replace t4v0308 = t4v0308 + group_id/2
gen t4v0309 = mpg + rnormal(0, 0.4)
replace t4v0309 = t4v0309 + group_id/3
gen t4v0310 = weight + rnormal(0, 0.5)
replace t4v0310 = t4v0310 + group_id/4
label variable t4v0310 "Generated stress variable 0310"
gen t4v0311 = length + rnormal(0, 0.6)
replace t4v0311 = t4v0311 + group_id/5
gen t4v0312 = turn + rnormal(0, 0.7)
replace t4v0312 = t4v0312 + group_id/6
gen t4v0313 = displacement + rnormal(0, 0.8)
replace t4v0313 = t4v0313 + group_id/7
gen t4v0314 = gear_ratio + rnormal(0, 0.9)
replace t4v0314 = t4v0314 + group_id/8
gen t4v0315 = price + rnormal(0, 0.1)
replace t4v0315 = t4v0315 + group_id/9
label variable t4v0315 "Generated stress variable 0315"
gen t4v0316 = mpg + rnormal(0, 0.2)
replace t4v0316 = t4v0316 + group_id/10
gen t4v0317 = weight + rnormal(0, 0.3)
replace t4v0317 = t4v0317 + group_id/11
gen t4v0318 = length + rnormal(0, 0.4)
replace t4v0318 = t4v0318 + group_id/12
gen t4v0319 = turn + rnormal(0, 0.5)
replace t4v0319 = t4v0319 + group_id/2
gen t4v0320 = displacement + rnormal(0, 0.6)
replace t4v0320 = t4v0320 + group_id/3
label variable t4v0320 "Generated stress variable 0320"
quietly summarize t4v0320
display as text "[VAR] t4v0320 mean=" %9.4f r(mean)
gen t4v0321 = gear_ratio + rnormal(0, 0.7)
replace t4v0321 = t4v0321 + group_id/4
gen t4v0322 = price + rnormal(0, 0.8)
replace t4v0322 = t4v0322 + group_id/5
gen t4v0323 = mpg + rnormal(0, 0.9)
replace t4v0323 = t4v0323 + group_id/6
gen t4v0324 = weight + rnormal(0, 0.1)
replace t4v0324 = t4v0324 + group_id/7
gen t4v0325 = length + rnormal(0, 0.2)
replace t4v0325 = t4v0325 + group_id/8
label variable t4v0325 "Generated stress variable 0325"
gen t4v0326 = turn + rnormal(0, 0.3)
replace t4v0326 = t4v0326 + group_id/9
gen t4v0327 = displacement + rnormal(0, 0.4)
replace t4v0327 = t4v0327 + group_id/10
gen t4v0328 = gear_ratio + rnormal(0, 0.5)
replace t4v0328 = t4v0328 + group_id/11
gen t4v0329 = price + rnormal(0, 0.6)
replace t4v0329 = t4v0329 + group_id/12
gen t4v0330 = mpg + rnormal(0, 0.7)
replace t4v0330 = t4v0330 + group_id/2
label variable t4v0330 "Generated stress variable 0330"
gen t4v0331 = weight + rnormal(0, 0.8)
replace t4v0331 = t4v0331 + group_id/3
gen t4v0332 = length + rnormal(0, 0.9)
replace t4v0332 = t4v0332 + group_id/4
gen t4v0333 = turn + rnormal(0, 0.1)
replace t4v0333 = t4v0333 + group_id/5
gen t4v0334 = displacement + rnormal(0, 0.2)
replace t4v0334 = t4v0334 + group_id/6
gen t4v0335 = gear_ratio + rnormal(0, 0.3)
replace t4v0335 = t4v0335 + group_id/7
label variable t4v0335 "Generated stress variable 0335"
gen t4v0336 = price + rnormal(0, 0.4)
replace t4v0336 = t4v0336 + group_id/8
gen t4v0337 = mpg + rnormal(0, 0.5)
replace t4v0337 = t4v0337 + group_id/9
gen t4v0338 = weight + rnormal(0, 0.6)
replace t4v0338 = t4v0338 + group_id/10
gen t4v0339 = length + rnormal(0, 0.7)
replace t4v0339 = t4v0339 + group_id/11
gen t4v0340 = turn + rnormal(0, 0.8)
replace t4v0340 = t4v0340 + group_id/12
label variable t4v0340 "Generated stress variable 0340"
quietly summarize t4v0340
display as text "[VAR] t4v0340 mean=" %9.4f r(mean)
gen t4v0341 = displacement + rnormal(0, 0.9)
replace t4v0341 = t4v0341 + group_id/2
gen t4v0342 = gear_ratio + rnormal(0, 0.1)
replace t4v0342 = t4v0342 + group_id/3
gen t4v0343 = price + rnormal(0, 0.2)
replace t4v0343 = t4v0343 + group_id/4
gen t4v0344 = mpg + rnormal(0, 0.3)
replace t4v0344 = t4v0344 + group_id/5
gen t4v0345 = weight + rnormal(0, 0.4)
replace t4v0345 = t4v0345 + group_id/6
label variable t4v0345 "Generated stress variable 0345"
gen t4v0346 = length + rnormal(0, 0.5)
replace t4v0346 = t4v0346 + group_id/7
gen t4v0347 = turn + rnormal(0, 0.6)
replace t4v0347 = t4v0347 + group_id/8
gen t4v0348 = displacement + rnormal(0, 0.7)
replace t4v0348 = t4v0348 + group_id/9
gen t4v0349 = gear_ratio + rnormal(0, 0.8)
replace t4v0349 = t4v0349 + group_id/10
gen t4v0350 = price + rnormal(0, 0.9)
replace t4v0350 = t4v0350 + group_id/11
label variable t4v0350 "Generated stress variable 0350"
gen t4v0351 = mpg + rnormal(0, 0.1)
replace t4v0351 = t4v0351 + group_id/12
gen t4v0352 = weight + rnormal(0, 0.2)
replace t4v0352 = t4v0352 + group_id/2
gen t4v0353 = length + rnormal(0, 0.3)
replace t4v0353 = t4v0353 + group_id/3
gen t4v0354 = turn + rnormal(0, 0.4)
replace t4v0354 = t4v0354 + group_id/4
gen t4v0355 = displacement + rnormal(0, 0.5)
replace t4v0355 = t4v0355 + group_id/5
label variable t4v0355 "Generated stress variable 0355"
gen t4v0356 = gear_ratio + rnormal(0, 0.6)
replace t4v0356 = t4v0356 + group_id/6
gen t4v0357 = price + rnormal(0, 0.7)
replace t4v0357 = t4v0357 + group_id/7
gen t4v0358 = mpg + rnormal(0, 0.8)
replace t4v0358 = t4v0358 + group_id/8
gen t4v0359 = weight + rnormal(0, 0.9)
replace t4v0359 = t4v0359 + group_id/9
gen t4v0360 = length + rnormal(0, 0.1)
replace t4v0360 = t4v0360 + group_id/10
label variable t4v0360 "Generated stress variable 0360"
quietly summarize t4v0360
display as text "[VAR] t4v0360 mean=" %9.4f r(mean)
gen t4v0361 = turn + rnormal(0, 0.2)
replace t4v0361 = t4v0361 + group_id/11
gen t4v0362 = displacement + rnormal(0, 0.3)
replace t4v0362 = t4v0362 + group_id/12
gen t4v0363 = gear_ratio + rnormal(0, 0.4)
replace t4v0363 = t4v0363 + group_id/2
gen t4v0364 = price + rnormal(0, 0.5)
replace t4v0364 = t4v0364 + group_id/3
gen t4v0365 = mpg + rnormal(0, 0.6)
replace t4v0365 = t4v0365 + group_id/4
label variable t4v0365 "Generated stress variable 0365"
gen t4v0366 = weight + rnormal(0, 0.7)
replace t4v0366 = t4v0366 + group_id/5
gen t4v0367 = length + rnormal(0, 0.8)
replace t4v0367 = t4v0367 + group_id/6
gen t4v0368 = turn + rnormal(0, 0.9)
replace t4v0368 = t4v0368 + group_id/7
gen t4v0369 = displacement + rnormal(0, 0.1)
replace t4v0369 = t4v0369 + group_id/8
gen t4v0370 = gear_ratio + rnormal(0, 0.2)
replace t4v0370 = t4v0370 + group_id/9
label variable t4v0370 "Generated stress variable 0370"
gen t4v0371 = price + rnormal(0, 0.3)
replace t4v0371 = t4v0371 + group_id/10
gen t4v0372 = mpg + rnormal(0, 0.4)
replace t4v0372 = t4v0372 + group_id/11
gen t4v0373 = weight + rnormal(0, 0.5)
replace t4v0373 = t4v0373 + group_id/12
gen t4v0374 = length + rnormal(0, 0.6)
replace t4v0374 = t4v0374 + group_id/2
gen t4v0375 = turn + rnormal(0, 0.7)
replace t4v0375 = t4v0375 + group_id/3
label variable t4v0375 "Generated stress variable 0375"
gen t4v0376 = displacement + rnormal(0, 0.8)
replace t4v0376 = t4v0376 + group_id/4
gen t4v0377 = gear_ratio + rnormal(0, 0.9)
replace t4v0377 = t4v0377 + group_id/5
gen t4v0378 = price + rnormal(0, 0.1)
replace t4v0378 = t4v0378 + group_id/6
gen t4v0379 = mpg + rnormal(0, 0.2)
replace t4v0379 = t4v0379 + group_id/7
gen t4v0380 = weight + rnormal(0, 0.3)
replace t4v0380 = t4v0380 + group_id/8
label variable t4v0380 "Generated stress variable 0380"
quietly summarize t4v0380
display as text "[VAR] t4v0380 mean=" %9.4f r(mean)
gen t4v0381 = length + rnormal(0, 0.4)
replace t4v0381 = t4v0381 + group_id/9
gen t4v0382 = turn + rnormal(0, 0.5)
replace t4v0382 = t4v0382 + group_id/10
gen t4v0383 = displacement + rnormal(0, 0.6)
replace t4v0383 = t4v0383 + group_id/11
gen t4v0384 = gear_ratio + rnormal(0, 0.7)
replace t4v0384 = t4v0384 + group_id/12
gen t4v0385 = price + rnormal(0, 0.8)
replace t4v0385 = t4v0385 + group_id/2
label variable t4v0385 "Generated stress variable 0385"
gen t4v0386 = mpg + rnormal(0, 0.9)
replace t4v0386 = t4v0386 + group_id/3
gen t4v0387 = weight + rnormal(0, 0.1)
replace t4v0387 = t4v0387 + group_id/4
gen t4v0388 = length + rnormal(0, 0.2)
replace t4v0388 = t4v0388 + group_id/5
gen t4v0389 = turn + rnormal(0, 0.3)
replace t4v0389 = t4v0389 + group_id/6
gen t4v0390 = displacement + rnormal(0, 0.4)
replace t4v0390 = t4v0390 + group_id/7
label variable t4v0390 "Generated stress variable 0390"
gen t4v0391 = gear_ratio + rnormal(0, 0.5)
replace t4v0391 = t4v0391 + group_id/8
gen t4v0392 = price + rnormal(0, 0.6)
replace t4v0392 = t4v0392 + group_id/9
gen t4v0393 = mpg + rnormal(0, 0.7)
replace t4v0393 = t4v0393 + group_id/10
gen t4v0394 = weight + rnormal(0, 0.8)
replace t4v0394 = t4v0394 + group_id/11
gen t4v0395 = length + rnormal(0, 0.9)
replace t4v0395 = t4v0395 + group_id/12
label variable t4v0395 "Generated stress variable 0395"
gen t4v0396 = turn + rnormal(0, 0.1)
replace t4v0396 = t4v0396 + group_id/2
gen t4v0397 = displacement + rnormal(0, 0.2)
replace t4v0397 = t4v0397 + group_id/3
gen t4v0398 = gear_ratio + rnormal(0, 0.3)
replace t4v0398 = t4v0398 + group_id/4
gen t4v0399 = price + rnormal(0, 0.4)
replace t4v0399 = t4v0399 + group_id/5
gen t4v0400 = mpg + rnormal(0, 0.5)
replace t4v0400 = t4v0400 + group_id/6
label variable t4v0400 "Generated stress variable 0400"
quietly summarize t4v0400
display as text "[VAR] t4v0400 mean=" %9.4f r(mean)
gen t4v0401 = weight + rnormal(0, 0.6)
replace t4v0401 = t4v0401 + group_id/7
gen t4v0402 = length + rnormal(0, 0.7)
replace t4v0402 = t4v0402 + group_id/8
gen t4v0403 = turn + rnormal(0, 0.8)
replace t4v0403 = t4v0403 + group_id/9
gen t4v0404 = displacement + rnormal(0, 0.9)
replace t4v0404 = t4v0404 + group_id/10
gen t4v0405 = gear_ratio + rnormal(0, 0.1)
replace t4v0405 = t4v0405 + group_id/11
label variable t4v0405 "Generated stress variable 0405"
gen t4v0406 = price + rnormal(0, 0.2)
replace t4v0406 = t4v0406 + group_id/12
gen t4v0407 = mpg + rnormal(0, 0.3)
replace t4v0407 = t4v0407 + group_id/2
gen t4v0408 = weight + rnormal(0, 0.4)
replace t4v0408 = t4v0408 + group_id/3
gen t4v0409 = length + rnormal(0, 0.5)
replace t4v0409 = t4v0409 + group_id/4
gen t4v0410 = turn + rnormal(0, 0.6)
replace t4v0410 = t4v0410 + group_id/5
label variable t4v0410 "Generated stress variable 0410"
gen t4v0411 = displacement + rnormal(0, 0.7)
replace t4v0411 = t4v0411 + group_id/6
gen t4v0412 = gear_ratio + rnormal(0, 0.8)
replace t4v0412 = t4v0412 + group_id/7
gen t4v0413 = price + rnormal(0, 0.9)
replace t4v0413 = t4v0413 + group_id/8
gen t4v0414 = mpg + rnormal(0, 0.1)
replace t4v0414 = t4v0414 + group_id/9
gen t4v0415 = weight + rnormal(0, 0.2)
replace t4v0415 = t4v0415 + group_id/10
label variable t4v0415 "Generated stress variable 0415"
gen t4v0416 = length + rnormal(0, 0.3)
replace t4v0416 = t4v0416 + group_id/11
gen t4v0417 = turn + rnormal(0, 0.4)
replace t4v0417 = t4v0417 + group_id/12
gen t4v0418 = displacement + rnormal(0, 0.5)
replace t4v0418 = t4v0418 + group_id/2
gen t4v0419 = gear_ratio + rnormal(0, 0.6)
replace t4v0419 = t4v0419 + group_id/3
gen t4v0420 = price + rnormal(0, 0.7)
replace t4v0420 = t4v0420 + group_id/4
label variable t4v0420 "Generated stress variable 0420"
quietly summarize t4v0420
display as text "[VAR] t4v0420 mean=" %9.4f r(mean)
gen t4v0421 = mpg + rnormal(0, 0.8)
replace t4v0421 = t4v0421 + group_id/5
gen t4v0422 = weight + rnormal(0, 0.9)
replace t4v0422 = t4v0422 + group_id/6
gen t4v0423 = length + rnormal(0, 0.1)
replace t4v0423 = t4v0423 + group_id/7
gen t4v0424 = turn + rnormal(0, 0.2)
replace t4v0424 = t4v0424 + group_id/8
gen t4v0425 = displacement + rnormal(0, 0.3)
replace t4v0425 = t4v0425 + group_id/9
label variable t4v0425 "Generated stress variable 0425"
gen t4v0426 = gear_ratio + rnormal(0, 0.4)
replace t4v0426 = t4v0426 + group_id/10
gen t4v0427 = price + rnormal(0, 0.5)
replace t4v0427 = t4v0427 + group_id/11
gen t4v0428 = mpg + rnormal(0, 0.6)
replace t4v0428 = t4v0428 + group_id/12
gen t4v0429 = weight + rnormal(0, 0.7)
replace t4v0429 = t4v0429 + group_id/2
gen t4v0430 = length + rnormal(0, 0.8)
replace t4v0430 = t4v0430 + group_id/3
label variable t4v0430 "Generated stress variable 0430"
gen t4v0431 = turn + rnormal(0, 0.9)
replace t4v0431 = t4v0431 + group_id/4
gen t4v0432 = displacement + rnormal(0, 0.1)
replace t4v0432 = t4v0432 + group_id/5
gen t4v0433 = gear_ratio + rnormal(0, 0.2)
replace t4v0433 = t4v0433 + group_id/6
gen t4v0434 = price + rnormal(0, 0.3)
replace t4v0434 = t4v0434 + group_id/7
gen t4v0435 = mpg + rnormal(0, 0.4)
replace t4v0435 = t4v0435 + group_id/8
label variable t4v0435 "Generated stress variable 0435"
gen t4v0436 = weight + rnormal(0, 0.5)
replace t4v0436 = t4v0436 + group_id/9
gen t4v0437 = length + rnormal(0, 0.6)
replace t4v0437 = t4v0437 + group_id/10
gen t4v0438 = turn + rnormal(0, 0.7)
replace t4v0438 = t4v0438 + group_id/11
gen t4v0439 = displacement + rnormal(0, 0.8)
replace t4v0439 = t4v0439 + group_id/12
gen t4v0440 = gear_ratio + rnormal(0, 0.9)
replace t4v0440 = t4v0440 + group_id/2
label variable t4v0440 "Generated stress variable 0440"
quietly summarize t4v0440
display as text "[VAR] t4v0440 mean=" %9.4f r(mean)
gen t4v0441 = price + rnormal(0, 0.1)
replace t4v0441 = t4v0441 + group_id/3
gen t4v0442 = mpg + rnormal(0, 0.2)
replace t4v0442 = t4v0442 + group_id/4
gen t4v0443 = weight + rnormal(0, 0.3)
replace t4v0443 = t4v0443 + group_id/5
gen t4v0444 = length + rnormal(0, 0.4)
replace t4v0444 = t4v0444 + group_id/6
gen t4v0445 = turn + rnormal(0, 0.5)
replace t4v0445 = t4v0445 + group_id/7
label variable t4v0445 "Generated stress variable 0445"
gen t4v0446 = displacement + rnormal(0, 0.6)
replace t4v0446 = t4v0446 + group_id/8
gen t4v0447 = gear_ratio + rnormal(0, 0.7)
replace t4v0447 = t4v0447 + group_id/9
gen t4v0448 = price + rnormal(0, 0.8)
replace t4v0448 = t4v0448 + group_id/10
gen t4v0449 = mpg + rnormal(0, 0.9)
replace t4v0449 = t4v0449 + group_id/11
gen t4v0450 = weight + rnormal(0, 0.1)
replace t4v0450 = t4v0450 + group_id/12
label variable t4v0450 "Generated stress variable 0450"
gen t4v0451 = length + rnormal(0, 0.2)
replace t4v0451 = t4v0451 + group_id/2
gen t4v0452 = turn + rnormal(0, 0.3)
replace t4v0452 = t4v0452 + group_id/3
gen t4v0453 = displacement + rnormal(0, 0.4)
replace t4v0453 = t4v0453 + group_id/4
gen t4v0454 = gear_ratio + rnormal(0, 0.5)
replace t4v0454 = t4v0454 + group_id/5
gen t4v0455 = price + rnormal(0, 0.6)
replace t4v0455 = t4v0455 + group_id/6
label variable t4v0455 "Generated stress variable 0455"
gen t4v0456 = mpg + rnormal(0, 0.7)
replace t4v0456 = t4v0456 + group_id/7
gen t4v0457 = weight + rnormal(0, 0.8)
replace t4v0457 = t4v0457 + group_id/8
gen t4v0458 = length + rnormal(0, 0.9)
replace t4v0458 = t4v0458 + group_id/9
gen t4v0459 = turn + rnormal(0, 0.1)
replace t4v0459 = t4v0459 + group_id/10
gen t4v0460 = displacement + rnormal(0, 0.2)
replace t4v0460 = t4v0460 + group_id/11
label variable t4v0460 "Generated stress variable 0460"
quietly summarize t4v0460
display as text "[VAR] t4v0460 mean=" %9.4f r(mean)
gen t4v0461 = gear_ratio + rnormal(0, 0.3)
replace t4v0461 = t4v0461 + group_id/12
gen t4v0462 = price + rnormal(0, 0.4)
replace t4v0462 = t4v0462 + group_id/2
gen t4v0463 = mpg + rnormal(0, 0.5)
replace t4v0463 = t4v0463 + group_id/3
gen t4v0464 = weight + rnormal(0, 0.6)
replace t4v0464 = t4v0464 + group_id/4
gen t4v0465 = length + rnormal(0, 0.7)
replace t4v0465 = t4v0465 + group_id/5
label variable t4v0465 "Generated stress variable 0465"
gen t4v0466 = turn + rnormal(0, 0.8)
replace t4v0466 = t4v0466 + group_id/6
gen t4v0467 = displacement + rnormal(0, 0.9)
replace t4v0467 = t4v0467 + group_id/7
gen t4v0468 = gear_ratio + rnormal(0, 0.1)
replace t4v0468 = t4v0468 + group_id/8
gen t4v0469 = price + rnormal(0, 0.2)
replace t4v0469 = t4v0469 + group_id/9
gen t4v0470 = mpg + rnormal(0, 0.3)
replace t4v0470 = t4v0470 + group_id/10
label variable t4v0470 "Generated stress variable 0470"
gen t4v0471 = weight + rnormal(0, 0.4)
replace t4v0471 = t4v0471 + group_id/11
gen t4v0472 = length + rnormal(0, 0.5)
replace t4v0472 = t4v0472 + group_id/12
gen t4v0473 = turn + rnormal(0, 0.6)
replace t4v0473 = t4v0473 + group_id/2
gen t4v0474 = displacement + rnormal(0, 0.7)
replace t4v0474 = t4v0474 + group_id/3
gen t4v0475 = gear_ratio + rnormal(0, 0.8)
replace t4v0475 = t4v0475 + group_id/4
label variable t4v0475 "Generated stress variable 0475"
gen t4v0476 = price + rnormal(0, 0.9)
replace t4v0476 = t4v0476 + group_id/5
gen t4v0477 = mpg + rnormal(0, 0.1)
replace t4v0477 = t4v0477 + group_id/6
gen t4v0478 = weight + rnormal(0, 0.2)
replace t4v0478 = t4v0478 + group_id/7
gen t4v0479 = length + rnormal(0, 0.3)
replace t4v0479 = t4v0479 + group_id/8
gen t4v0480 = turn + rnormal(0, 0.4)
replace t4v0480 = t4v0480 + group_id/9
label variable t4v0480 "Generated stress variable 0480"
quietly summarize t4v0480
display as text "[VAR] t4v0480 mean=" %9.4f r(mean)
gen t4v0481 = displacement + rnormal(0, 0.5)
replace t4v0481 = t4v0481 + group_id/10
gen t4v0482 = gear_ratio + rnormal(0, 0.6)
replace t4v0482 = t4v0482 + group_id/11
gen t4v0483 = price + rnormal(0, 0.7)
replace t4v0483 = t4v0483 + group_id/12
gen t4v0484 = mpg + rnormal(0, 0.8)
replace t4v0484 = t4v0484 + group_id/2
gen t4v0485 = weight + rnormal(0, 0.9)
replace t4v0485 = t4v0485 + group_id/3
label variable t4v0485 "Generated stress variable 0485"
gen t4v0486 = length + rnormal(0, 0.1)
replace t4v0486 = t4v0486 + group_id/4
gen t4v0487 = turn + rnormal(0, 0.2)
replace t4v0487 = t4v0487 + group_id/5
gen t4v0488 = displacement + rnormal(0, 0.3)
replace t4v0488 = t4v0488 + group_id/6
gen t4v0489 = gear_ratio + rnormal(0, 0.4)
replace t4v0489 = t4v0489 + group_id/7
gen t4v0490 = price + rnormal(0, 0.5)
replace t4v0490 = t4v0490 + group_id/8
label variable t4v0490 "Generated stress variable 0490"
gen t4v0491 = mpg + rnormal(0, 0.6)
replace t4v0491 = t4v0491 + group_id/9
gen t4v0492 = weight + rnormal(0, 0.7)
replace t4v0492 = t4v0492 + group_id/10
gen t4v0493 = length + rnormal(0, 0.8)
replace t4v0493 = t4v0493 + group_id/11
gen t4v0494 = turn + rnormal(0, 0.9)
replace t4v0494 = t4v0494 + group_id/12
gen t4v0495 = displacement + rnormal(0, 0.1)
replace t4v0495 = t4v0495 + group_id/2
label variable t4v0495 "Generated stress variable 0495"
gen t4v0496 = gear_ratio + rnormal(0, 0.2)
replace t4v0496 = t4v0496 + group_id/3
gen t4v0497 = price + rnormal(0, 0.3)
replace t4v0497 = t4v0497 + group_id/4
gen t4v0498 = mpg + rnormal(0, 0.4)
replace t4v0498 = t4v0498 + group_id/5
gen t4v0499 = weight + rnormal(0, 0.5)
replace t4v0499 = t4v0499 + group_id/6
gen t4v0500 = length + rnormal(0, 0.6)
replace t4v0500 = t4v0500 + group_id/7
label variable t4v0500 "Generated stress variable 0500"
quietly summarize t4v0500
display as text "[VAR] t4v0500 mean=" %9.4f r(mean)
gen t4v0501 = turn + rnormal(0, 0.7)
replace t4v0501 = t4v0501 + group_id/8
gen t4v0502 = displacement + rnormal(0, 0.8)
replace t4v0502 = t4v0502 + group_id/9
gen t4v0503 = gear_ratio + rnormal(0, 0.9)
replace t4v0503 = t4v0503 + group_id/10
gen t4v0504 = price + rnormal(0, 0.1)
replace t4v0504 = t4v0504 + group_id/11
gen t4v0505 = mpg + rnormal(0, 0.2)
replace t4v0505 = t4v0505 + group_id/12
label variable t4v0505 "Generated stress variable 0505"
gen t4v0506 = weight + rnormal(0, 0.3)
replace t4v0506 = t4v0506 + group_id/2
gen t4v0507 = length + rnormal(0, 0.4)
replace t4v0507 = t4v0507 + group_id/3
gen t4v0508 = turn + rnormal(0, 0.5)
replace t4v0508 = t4v0508 + group_id/4
gen t4v0509 = displacement + rnormal(0, 0.6)
replace t4v0509 = t4v0509 + group_id/5
gen t4v0510 = gear_ratio + rnormal(0, 0.7)
replace t4v0510 = t4v0510 + group_id/6
label variable t4v0510 "Generated stress variable 0510"
gen t4v0511 = price + rnormal(0, 0.8)
replace t4v0511 = t4v0511 + group_id/7
gen t4v0512 = mpg + rnormal(0, 0.9)
replace t4v0512 = t4v0512 + group_id/8
gen t4v0513 = weight + rnormal(0, 0.1)
replace t4v0513 = t4v0513 + group_id/9
gen t4v0514 = length + rnormal(0, 0.2)
replace t4v0514 = t4v0514 + group_id/10
gen t4v0515 = turn + rnormal(0, 0.3)
replace t4v0515 = t4v0515 + group_id/11
label variable t4v0515 "Generated stress variable 0515"
gen t4v0516 = displacement + rnormal(0, 0.4)
replace t4v0516 = t4v0516 + group_id/12
gen t4v0517 = gear_ratio + rnormal(0, 0.5)
replace t4v0517 = t4v0517 + group_id/2
gen t4v0518 = price + rnormal(0, 0.6)
replace t4v0518 = t4v0518 + group_id/3
gen t4v0519 = mpg + rnormal(0, 0.7)
replace t4v0519 = t4v0519 + group_id/4
gen t4v0520 = weight + rnormal(0, 0.8)
replace t4v0520 = t4v0520 + group_id/5
label variable t4v0520 "Generated stress variable 0520"
quietly summarize t4v0520
display as text "[VAR] t4v0520 mean=" %9.4f r(mean)
gen t4v0521 = length + rnormal(0, 0.9)
replace t4v0521 = t4v0521 + group_id/6
gen t4v0522 = turn + rnormal(0, 0.1)
replace t4v0522 = t4v0522 + group_id/7
gen t4v0523 = displacement + rnormal(0, 0.2)
replace t4v0523 = t4v0523 + group_id/8
gen t4v0524 = gear_ratio + rnormal(0, 0.3)
replace t4v0524 = t4v0524 + group_id/9
gen t4v0525 = price + rnormal(0, 0.4)
replace t4v0525 = t4v0525 + group_id/10
label variable t4v0525 "Generated stress variable 0525"
gen t4v0526 = mpg + rnormal(0, 0.5)
replace t4v0526 = t4v0526 + group_id/11
gen t4v0527 = weight + rnormal(0, 0.6)
replace t4v0527 = t4v0527 + group_id/12
gen t4v0528 = length + rnormal(0, 0.7)
replace t4v0528 = t4v0528 + group_id/2
gen t4v0529 = turn + rnormal(0, 0.8)
replace t4v0529 = t4v0529 + group_id/3
gen t4v0530 = displacement + rnormal(0, 0.9)
replace t4v0530 = t4v0530 + group_id/4
label variable t4v0530 "Generated stress variable 0530"
gen t4v0531 = gear_ratio + rnormal(0, 0.1)
replace t4v0531 = t4v0531 + group_id/5
gen t4v0532 = price + rnormal(0, 0.2)
replace t4v0532 = t4v0532 + group_id/6
gen t4v0533 = mpg + rnormal(0, 0.3)
replace t4v0533 = t4v0533 + group_id/7
gen t4v0534 = weight + rnormal(0, 0.4)
replace t4v0534 = t4v0534 + group_id/8
gen t4v0535 = length + rnormal(0, 0.5)
replace t4v0535 = t4v0535 + group_id/9
label variable t4v0535 "Generated stress variable 0535"
gen t4v0536 = turn + rnormal(0, 0.6)
replace t4v0536 = t4v0536 + group_id/10
gen t4v0537 = displacement + rnormal(0, 0.7)
replace t4v0537 = t4v0537 + group_id/11
gen t4v0538 = gear_ratio + rnormal(0, 0.8)
replace t4v0538 = t4v0538 + group_id/12
gen t4v0539 = price + rnormal(0, 0.9)
replace t4v0539 = t4v0539 + group_id/2
gen t4v0540 = mpg + rnormal(0, 0.1)
replace t4v0540 = t4v0540 + group_id/3
label variable t4v0540 "Generated stress variable 0540"
quietly summarize t4v0540
display as text "[VAR] t4v0540 mean=" %9.4f r(mean)
gen t4v0541 = weight + rnormal(0, 0.2)
replace t4v0541 = t4v0541 + group_id/4
gen t4v0542 = length + rnormal(0, 0.3)
replace t4v0542 = t4v0542 + group_id/5
gen t4v0543 = turn + rnormal(0, 0.4)
replace t4v0543 = t4v0543 + group_id/6
gen t4v0544 = displacement + rnormal(0, 0.5)
replace t4v0544 = t4v0544 + group_id/7
gen t4v0545 = gear_ratio + rnormal(0, 0.6)
replace t4v0545 = t4v0545 + group_id/8
label variable t4v0545 "Generated stress variable 0545"
gen t4v0546 = price + rnormal(0, 0.7)
replace t4v0546 = t4v0546 + group_id/9
gen t4v0547 = mpg + rnormal(0, 0.8)
replace t4v0547 = t4v0547 + group_id/10
gen t4v0548 = weight + rnormal(0, 0.9)
replace t4v0548 = t4v0548 + group_id/11
gen t4v0549 = length + rnormal(0, 0.1)
replace t4v0549 = t4v0549 + group_id/12
gen t4v0550 = turn + rnormal(0, 0.2)
replace t4v0550 = t4v0550 + group_id/2
label variable t4v0550 "Generated stress variable 0550"
gen t4v0551 = displacement + rnormal(0, 0.3)
replace t4v0551 = t4v0551 + group_id/3
gen t4v0552 = gear_ratio + rnormal(0, 0.4)
replace t4v0552 = t4v0552 + group_id/4
gen t4v0553 = price + rnormal(0, 0.5)
replace t4v0553 = t4v0553 + group_id/5
gen t4v0554 = mpg + rnormal(0, 0.6)
replace t4v0554 = t4v0554 + group_id/6
gen t4v0555 = weight + rnormal(0, 0.7)
replace t4v0555 = t4v0555 + group_id/7
label variable t4v0555 "Generated stress variable 0555"
gen t4v0556 = length + rnormal(0, 0.8)
replace t4v0556 = t4v0556 + group_id/8
gen t4v0557 = turn + rnormal(0, 0.9)
replace t4v0557 = t4v0557 + group_id/9
gen t4v0558 = displacement + rnormal(0, 0.1)
replace t4v0558 = t4v0558 + group_id/10
gen t4v0559 = gear_ratio + rnormal(0, 0.2)
replace t4v0559 = t4v0559 + group_id/11
gen t4v0560 = price + rnormal(0, 0.3)
replace t4v0560 = t4v0560 + group_id/12
label variable t4v0560 "Generated stress variable 0560"
quietly summarize t4v0560
display as text "[VAR] t4v0560 mean=" %9.4f r(mean)
gen t4v0561 = mpg + rnormal(0, 0.4)
replace t4v0561 = t4v0561 + group_id/2
gen t4v0562 = weight + rnormal(0, 0.5)
replace t4v0562 = t4v0562 + group_id/3
gen t4v0563 = length + rnormal(0, 0.6)
replace t4v0563 = t4v0563 + group_id/4
gen t4v0564 = turn + rnormal(0, 0.7)
replace t4v0564 = t4v0564 + group_id/5
gen t4v0565 = displacement + rnormal(0, 0.8)
replace t4v0565 = t4v0565 + group_id/6
label variable t4v0565 "Generated stress variable 0565"
gen t4v0566 = gear_ratio + rnormal(0, 0.9)
replace t4v0566 = t4v0566 + group_id/7
gen t4v0567 = price + rnormal(0, 0.1)
replace t4v0567 = t4v0567 + group_id/8
gen t4v0568 = mpg + rnormal(0, 0.2)
replace t4v0568 = t4v0568 + group_id/9
gen t4v0569 = weight + rnormal(0, 0.3)
replace t4v0569 = t4v0569 + group_id/10
gen t4v0570 = length + rnormal(0, 0.4)
replace t4v0570 = t4v0570 + group_id/11
label variable t4v0570 "Generated stress variable 0570"
gen t4v0571 = turn + rnormal(0, 0.5)
replace t4v0571 = t4v0571 + group_id/12
gen t4v0572 = displacement + rnormal(0, 0.6)
replace t4v0572 = t4v0572 + group_id/2
gen t4v0573 = gear_ratio + rnormal(0, 0.7)
replace t4v0573 = t4v0573 + group_id/3
gen t4v0574 = price + rnormal(0, 0.8)
replace t4v0574 = t4v0574 + group_id/4
gen t4v0575 = mpg + rnormal(0, 0.9)
replace t4v0575 = t4v0575 + group_id/5
label variable t4v0575 "Generated stress variable 0575"
gen t4v0576 = weight + rnormal(0, 0.1)
replace t4v0576 = t4v0576 + group_id/6
gen t4v0577 = length + rnormal(0, 0.2)
replace t4v0577 = t4v0577 + group_id/7
gen t4v0578 = turn + rnormal(0, 0.3)
replace t4v0578 = t4v0578 + group_id/8
gen t4v0579 = displacement + rnormal(0, 0.4)
replace t4v0579 = t4v0579 + group_id/9
gen t4v0580 = gear_ratio + rnormal(0, 0.5)
replace t4v0580 = t4v0580 + group_id/10
label variable t4v0580 "Generated stress variable 0580"
quietly summarize t4v0580
display as text "[VAR] t4v0580 mean=" %9.4f r(mean)
gen t4v0581 = price + rnormal(0, 0.6)
replace t4v0581 = t4v0581 + group_id/11
gen t4v0582 = mpg + rnormal(0, 0.7)
replace t4v0582 = t4v0582 + group_id/12
gen t4v0583 = weight + rnormal(0, 0.8)
replace t4v0583 = t4v0583 + group_id/2
gen t4v0584 = length + rnormal(0, 0.9)
replace t4v0584 = t4v0584 + group_id/3
gen t4v0585 = turn + rnormal(0, 0.1)
replace t4v0585 = t4v0585 + group_id/4
label variable t4v0585 "Generated stress variable 0585"
gen t4v0586 = displacement + rnormal(0, 0.2)
replace t4v0586 = t4v0586 + group_id/5
gen t4v0587 = gear_ratio + rnormal(0, 0.3)
replace t4v0587 = t4v0587 + group_id/6
gen t4v0588 = price + rnormal(0, 0.4)
replace t4v0588 = t4v0588 + group_id/7
gen t4v0589 = mpg + rnormal(0, 0.5)
replace t4v0589 = t4v0589 + group_id/8
gen t4v0590 = weight + rnormal(0, 0.6)
replace t4v0590 = t4v0590 + group_id/9
label variable t4v0590 "Generated stress variable 0590"
gen t4v0591 = length + rnormal(0, 0.7)
replace t4v0591 = t4v0591 + group_id/10
gen t4v0592 = turn + rnormal(0, 0.8)
replace t4v0592 = t4v0592 + group_id/11
gen t4v0593 = displacement + rnormal(0, 0.9)
replace t4v0593 = t4v0593 + group_id/12
gen t4v0594 = gear_ratio + rnormal(0, 0.1)
replace t4v0594 = t4v0594 + group_id/2
gen t4v0595 = price + rnormal(0, 0.2)
replace t4v0595 = t4v0595 + group_id/3
label variable t4v0595 "Generated stress variable 0595"
gen t4v0596 = mpg + rnormal(0, 0.3)
replace t4v0596 = t4v0596 + group_id/4
gen t4v0597 = weight + rnormal(0, 0.4)
replace t4v0597 = t4v0597 + group_id/5
gen t4v0598 = length + rnormal(0, 0.5)
replace t4v0598 = t4v0598 + group_id/6
gen t4v0599 = turn + rnormal(0, 0.6)
replace t4v0599 = t4v0599 + group_id/7
gen t4v0600 = displacement + rnormal(0, 0.7)
replace t4v0600 = t4v0600 + group_id/8
label variable t4v0600 "Generated stress variable 0600"
quietly summarize t4v0600
display as text "[VAR] t4v0600 mean=" %9.4f r(mean)
gen t4v0601 = gear_ratio + rnormal(0, 0.8)
replace t4v0601 = t4v0601 + group_id/9
gen t4v0602 = price + rnormal(0, 0.9)
replace t4v0602 = t4v0602 + group_id/10
gen t4v0603 = mpg + rnormal(0, 0.1)
replace t4v0603 = t4v0603 + group_id/11
gen t4v0604 = weight + rnormal(0, 0.2)
replace t4v0604 = t4v0604 + group_id/12
gen t4v0605 = length + rnormal(0, 0.3)
replace t4v0605 = t4v0605 + group_id/2
label variable t4v0605 "Generated stress variable 0605"
gen t4v0606 = turn + rnormal(0, 0.4)
replace t4v0606 = t4v0606 + group_id/3
gen t4v0607 = displacement + rnormal(0, 0.5)
replace t4v0607 = t4v0607 + group_id/4
gen t4v0608 = gear_ratio + rnormal(0, 0.6)
replace t4v0608 = t4v0608 + group_id/5
gen t4v0609 = price + rnormal(0, 0.7)
replace t4v0609 = t4v0609 + group_id/6
gen t4v0610 = mpg + rnormal(0, 0.8)
replace t4v0610 = t4v0610 + group_id/7
label variable t4v0610 "Generated stress variable 0610"
gen t4v0611 = weight + rnormal(0, 0.9)
replace t4v0611 = t4v0611 + group_id/8
gen t4v0612 = length + rnormal(0, 0.1)
replace t4v0612 = t4v0612 + group_id/9
gen t4v0613 = turn + rnormal(0, 0.2)
replace t4v0613 = t4v0613 + group_id/10
gen t4v0614 = displacement + rnormal(0, 0.3)
replace t4v0614 = t4v0614 + group_id/11
gen t4v0615 = gear_ratio + rnormal(0, 0.4)
replace t4v0615 = t4v0615 + group_id/12
label variable t4v0615 "Generated stress variable 0615"
gen t4v0616 = price + rnormal(0, 0.5)
replace t4v0616 = t4v0616 + group_id/2
gen t4v0617 = mpg + rnormal(0, 0.6)
replace t4v0617 = t4v0617 + group_id/3
gen t4v0618 = weight + rnormal(0, 0.7)
replace t4v0618 = t4v0618 + group_id/4
gen t4v0619 = length + rnormal(0, 0.8)
replace t4v0619 = t4v0619 + group_id/5
gen t4v0620 = turn + rnormal(0, 0.9)
replace t4v0620 = t4v0620 + group_id/6
label variable t4v0620 "Generated stress variable 0620"
quietly summarize t4v0620
display as text "[VAR] t4v0620 mean=" %9.4f r(mean)
gen t4v0621 = displacement + rnormal(0, 0.1)
replace t4v0621 = t4v0621 + group_id/7
gen t4v0622 = gear_ratio + rnormal(0, 0.2)
replace t4v0622 = t4v0622 + group_id/8
gen t4v0623 = price + rnormal(0, 0.3)
replace t4v0623 = t4v0623 + group_id/9
gen t4v0624 = mpg + rnormal(0, 0.4)
replace t4v0624 = t4v0624 + group_id/10
gen t4v0625 = weight + rnormal(0, 0.5)
replace t4v0625 = t4v0625 + group_id/11
label variable t4v0625 "Generated stress variable 0625"
gen t4v0626 = length + rnormal(0, 0.6)
replace t4v0626 = t4v0626 + group_id/12
gen t4v0627 = turn + rnormal(0, 0.7)
replace t4v0627 = t4v0627 + group_id/2
gen t4v0628 = displacement + rnormal(0, 0.8)
replace t4v0628 = t4v0628 + group_id/3
gen t4v0629 = gear_ratio + rnormal(0, 0.9)
replace t4v0629 = t4v0629 + group_id/4
gen t4v0630 = price + rnormal(0, 0.1)
replace t4v0630 = t4v0630 + group_id/5
label variable t4v0630 "Generated stress variable 0630"
gen t4v0631 = mpg + rnormal(0, 0.2)
replace t4v0631 = t4v0631 + group_id/6
gen t4v0632 = weight + rnormal(0, 0.3)
replace t4v0632 = t4v0632 + group_id/7
gen t4v0633 = length + rnormal(0, 0.4)
replace t4v0633 = t4v0633 + group_id/8
gen t4v0634 = turn + rnormal(0, 0.5)
replace t4v0634 = t4v0634 + group_id/9
gen t4v0635 = displacement + rnormal(0, 0.6)
replace t4v0635 = t4v0635 + group_id/10
label variable t4v0635 "Generated stress variable 0635"
gen t4v0636 = gear_ratio + rnormal(0, 0.7)
replace t4v0636 = t4v0636 + group_id/11
gen t4v0637 = price + rnormal(0, 0.8)
replace t4v0637 = t4v0637 + group_id/12
gen t4v0638 = mpg + rnormal(0, 0.9)
replace t4v0638 = t4v0638 + group_id/2
gen t4v0639 = weight + rnormal(0, 0.1)
replace t4v0639 = t4v0639 + group_id/3
gen t4v0640 = length + rnormal(0, 0.2)
replace t4v0640 = t4v0640 + group_id/4
label variable t4v0640 "Generated stress variable 0640"
quietly summarize t4v0640
display as text "[VAR] t4v0640 mean=" %9.4f r(mean)
gen t4v0641 = turn + rnormal(0, 0.3)
replace t4v0641 = t4v0641 + group_id/5
gen t4v0642 = displacement + rnormal(0, 0.4)
replace t4v0642 = t4v0642 + group_id/6
gen t4v0643 = gear_ratio + rnormal(0, 0.5)
replace t4v0643 = t4v0643 + group_id/7
gen t4v0644 = price + rnormal(0, 0.6)
replace t4v0644 = t4v0644 + group_id/8
gen t4v0645 = mpg + rnormal(0, 0.7)
replace t4v0645 = t4v0645 + group_id/9
label variable t4v0645 "Generated stress variable 0645"
gen t4v0646 = weight + rnormal(0, 0.8)
replace t4v0646 = t4v0646 + group_id/10
gen t4v0647 = length + rnormal(0, 0.9)
replace t4v0647 = t4v0647 + group_id/11
gen t4v0648 = turn + rnormal(0, 0.1)
replace t4v0648 = t4v0648 + group_id/12
gen t4v0649 = displacement + rnormal(0, 0.2)
replace t4v0649 = t4v0649 + group_id/2
gen t4v0650 = gear_ratio + rnormal(0, 0.3)
replace t4v0650 = t4v0650 + group_id/3
label variable t4v0650 "Generated stress variable 0650"
gen t4v0651 = price + rnormal(0, 0.4)
replace t4v0651 = t4v0651 + group_id/4
gen t4v0652 = mpg + rnormal(0, 0.5)
replace t4v0652 = t4v0652 + group_id/5
gen t4v0653 = weight + rnormal(0, 0.6)
replace t4v0653 = t4v0653 + group_id/6
gen t4v0654 = length + rnormal(0, 0.7)
replace t4v0654 = t4v0654 + group_id/7
gen t4v0655 = turn + rnormal(0, 0.8)
replace t4v0655 = t4v0655 + group_id/8
label variable t4v0655 "Generated stress variable 0655"
gen t4v0656 = displacement + rnormal(0, 0.9)
replace t4v0656 = t4v0656 + group_id/9
gen t4v0657 = gear_ratio + rnormal(0, 0.1)
replace t4v0657 = t4v0657 + group_id/10
gen t4v0658 = price + rnormal(0, 0.2)
replace t4v0658 = t4v0658 + group_id/11
gen t4v0659 = mpg + rnormal(0, 0.3)
replace t4v0659 = t4v0659 + group_id/12
gen t4v0660 = weight + rnormal(0, 0.4)
replace t4v0660 = t4v0660 + group_id/2
label variable t4v0660 "Generated stress variable 0660"
quietly summarize t4v0660
display as text "[VAR] t4v0660 mean=" %9.4f r(mean)
gen t4v0661 = length + rnormal(0, 0.5)
replace t4v0661 = t4v0661 + group_id/3
gen t4v0662 = turn + rnormal(0, 0.6)
replace t4v0662 = t4v0662 + group_id/4
gen t4v0663 = displacement + rnormal(0, 0.7)
replace t4v0663 = t4v0663 + group_id/5
gen t4v0664 = gear_ratio + rnormal(0, 0.8)
replace t4v0664 = t4v0664 + group_id/6
gen t4v0665 = price + rnormal(0, 0.9)
replace t4v0665 = t4v0665 + group_id/7
label variable t4v0665 "Generated stress variable 0665"
gen t4v0666 = mpg + rnormal(0, 0.1)
replace t4v0666 = t4v0666 + group_id/8
gen t4v0667 = weight + rnormal(0, 0.2)
replace t4v0667 = t4v0667 + group_id/9
gen t4v0668 = length + rnormal(0, 0.3)
replace t4v0668 = t4v0668 + group_id/10
gen t4v0669 = turn + rnormal(0, 0.4)
replace t4v0669 = t4v0669 + group_id/11
gen t4v0670 = displacement + rnormal(0, 0.5)
replace t4v0670 = t4v0670 + group_id/12
label variable t4v0670 "Generated stress variable 0670"
gen t4v0671 = gear_ratio + rnormal(0, 0.6)
replace t4v0671 = t4v0671 + group_id/2
gen t4v0672 = price + rnormal(0, 0.7)
replace t4v0672 = t4v0672 + group_id/3
gen t4v0673 = mpg + rnormal(0, 0.8)
replace t4v0673 = t4v0673 + group_id/4
gen t4v0674 = weight + rnormal(0, 0.9)
replace t4v0674 = t4v0674 + group_id/5
gen t4v0675 = length + rnormal(0, 0.1)
replace t4v0675 = t4v0675 + group_id/6
label variable t4v0675 "Generated stress variable 0675"
gen t4v0676 = turn + rnormal(0, 0.2)
replace t4v0676 = t4v0676 + group_id/7
gen t4v0677 = displacement + rnormal(0, 0.3)
replace t4v0677 = t4v0677 + group_id/8
gen t4v0678 = gear_ratio + rnormal(0, 0.4)
replace t4v0678 = t4v0678 + group_id/9
gen t4v0679 = price + rnormal(0, 0.5)
replace t4v0679 = t4v0679 + group_id/10
gen t4v0680 = mpg + rnormal(0, 0.6)
replace t4v0680 = t4v0680 + group_id/11
label variable t4v0680 "Generated stress variable 0680"
quietly summarize t4v0680
display as text "[VAR] t4v0680 mean=" %9.4f r(mean)
gen t4v0681 = weight + rnormal(0, 0.7)
replace t4v0681 = t4v0681 + group_id/12
gen t4v0682 = length + rnormal(0, 0.8)
replace t4v0682 = t4v0682 + group_id/2
gen t4v0683 = turn + rnormal(0, 0.9)
replace t4v0683 = t4v0683 + group_id/3
gen t4v0684 = displacement + rnormal(0, 0.1)
replace t4v0684 = t4v0684 + group_id/4
gen t4v0685 = gear_ratio + rnormal(0, 0.2)
replace t4v0685 = t4v0685 + group_id/5
label variable t4v0685 "Generated stress variable 0685"
gen t4v0686 = price + rnormal(0, 0.3)
replace t4v0686 = t4v0686 + group_id/6
gen t4v0687 = mpg + rnormal(0, 0.4)
replace t4v0687 = t4v0687 + group_id/7
gen t4v0688 = weight + rnormal(0, 0.5)
replace t4v0688 = t4v0688 + group_id/8
gen t4v0689 = length + rnormal(0, 0.6)
replace t4v0689 = t4v0689 + group_id/9
gen t4v0690 = turn + rnormal(0, 0.7)
replace t4v0690 = t4v0690 + group_id/10
label variable t4v0690 "Generated stress variable 0690"
gen t4v0691 = displacement + rnormal(0, 0.8)
replace t4v0691 = t4v0691 + group_id/11
gen t4v0692 = gear_ratio + rnormal(0, 0.9)
replace t4v0692 = t4v0692 + group_id/12
gen t4v0693 = price + rnormal(0, 0.1)
replace t4v0693 = t4v0693 + group_id/2
gen t4v0694 = mpg + rnormal(0, 0.2)
replace t4v0694 = t4v0694 + group_id/3
gen t4v0695 = weight + rnormal(0, 0.3)
replace t4v0695 = t4v0695 + group_id/4
label variable t4v0695 "Generated stress variable 0695"
gen t4v0696 = length + rnormal(0, 0.4)
replace t4v0696 = t4v0696 + group_id/5
gen t4v0697 = turn + rnormal(0, 0.5)
replace t4v0697 = t4v0697 + group_id/6
gen t4v0698 = displacement + rnormal(0, 0.6)
replace t4v0698 = t4v0698 + group_id/7
gen t4v0699 = gear_ratio + rnormal(0, 0.7)
replace t4v0699 = t4v0699 + group_id/8
gen t4v0700 = price + rnormal(0, 0.8)
replace t4v0700 = t4v0700 + group_id/9
label variable t4v0700 "Generated stress variable 0700"
quietly summarize t4v0700
display as text "[VAR] t4v0700 mean=" %9.4f r(mean)
gen t4v0701 = mpg + rnormal(0, 0.9)
replace t4v0701 = t4v0701 + group_id/10
gen t4v0702 = weight + rnormal(0, 0.1)
replace t4v0702 = t4v0702 + group_id/11
gen t4v0703 = length + rnormal(0, 0.2)
replace t4v0703 = t4v0703 + group_id/12
gen t4v0704 = turn + rnormal(0, 0.3)
replace t4v0704 = t4v0704 + group_id/2
gen t4v0705 = displacement + rnormal(0, 0.4)
replace t4v0705 = t4v0705 + group_id/3
label variable t4v0705 "Generated stress variable 0705"
gen t4v0706 = gear_ratio + rnormal(0, 0.5)
replace t4v0706 = t4v0706 + group_id/4
gen t4v0707 = price + rnormal(0, 0.6)
replace t4v0707 = t4v0707 + group_id/5
gen t4v0708 = mpg + rnormal(0, 0.7)
replace t4v0708 = t4v0708 + group_id/6
gen t4v0709 = weight + rnormal(0, 0.8)
replace t4v0709 = t4v0709 + group_id/7
gen t4v0710 = length + rnormal(0, 0.9)
replace t4v0710 = t4v0710 + group_id/8
label variable t4v0710 "Generated stress variable 0710"
gen t4v0711 = turn + rnormal(0, 0.1)
replace t4v0711 = t4v0711 + group_id/9
gen t4v0712 = displacement + rnormal(0, 0.2)
replace t4v0712 = t4v0712 + group_id/10
gen t4v0713 = gear_ratio + rnormal(0, 0.3)
replace t4v0713 = t4v0713 + group_id/11
gen t4v0714 = price + rnormal(0, 0.4)
replace t4v0714 = t4v0714 + group_id/12
gen t4v0715 = mpg + rnormal(0, 0.5)
replace t4v0715 = t4v0715 + group_id/2
label variable t4v0715 "Generated stress variable 0715"
gen t4v0716 = weight + rnormal(0, 0.6)
replace t4v0716 = t4v0716 + group_id/3
gen t4v0717 = length + rnormal(0, 0.7)
replace t4v0717 = t4v0717 + group_id/4
gen t4v0718 = turn + rnormal(0, 0.8)
replace t4v0718 = t4v0718 + group_id/5
gen t4v0719 = displacement + rnormal(0, 0.9)
replace t4v0719 = t4v0719 + group_id/6
gen t4v0720 = gear_ratio + rnormal(0, 0.1)
replace t4v0720 = t4v0720 + group_id/7
label variable t4v0720 "Generated stress variable 0720"
quietly summarize t4v0720
display as text "[VAR] t4v0720 mean=" %9.4f r(mean)
gen t4v0721 = price + rnormal(0, 0.2)
replace t4v0721 = t4v0721 + group_id/8
gen t4v0722 = mpg + rnormal(0, 0.3)
replace t4v0722 = t4v0722 + group_id/9
gen t4v0723 = weight + rnormal(0, 0.4)
replace t4v0723 = t4v0723 + group_id/10
gen t4v0724 = length + rnormal(0, 0.5)
replace t4v0724 = t4v0724 + group_id/11
gen t4v0725 = turn + rnormal(0, 0.6)
replace t4v0725 = t4v0725 + group_id/12
label variable t4v0725 "Generated stress variable 0725"
gen t4v0726 = displacement + rnormal(0, 0.7)
replace t4v0726 = t4v0726 + group_id/2
gen t4v0727 = gear_ratio + rnormal(0, 0.8)
replace t4v0727 = t4v0727 + group_id/3
gen t4v0728 = price + rnormal(0, 0.9)
replace t4v0728 = t4v0728 + group_id/4
gen t4v0729 = mpg + rnormal(0, 0.1)
replace t4v0729 = t4v0729 + group_id/5
gen t4v0730 = weight + rnormal(0, 0.2)
replace t4v0730 = t4v0730 + group_id/6
label variable t4v0730 "Generated stress variable 0730"
gen t4v0731 = length + rnormal(0, 0.3)
replace t4v0731 = t4v0731 + group_id/7
gen t4v0732 = turn + rnormal(0, 0.4)
replace t4v0732 = t4v0732 + group_id/8
gen t4v0733 = displacement + rnormal(0, 0.5)
replace t4v0733 = t4v0733 + group_id/9
gen t4v0734 = gear_ratio + rnormal(0, 0.6)
replace t4v0734 = t4v0734 + group_id/10
gen t4v0735 = price + rnormal(0, 0.7)
replace t4v0735 = t4v0735 + group_id/11
label variable t4v0735 "Generated stress variable 0735"
gen t4v0736 = mpg + rnormal(0, 0.8)
replace t4v0736 = t4v0736 + group_id/12
gen t4v0737 = weight + rnormal(0, 0.9)
replace t4v0737 = t4v0737 + group_id/2
gen t4v0738 = length + rnormal(0, 0.1)
replace t4v0738 = t4v0738 + group_id/3
gen t4v0739 = turn + rnormal(0, 0.2)
replace t4v0739 = t4v0739 + group_id/4
gen t4v0740 = displacement + rnormal(0, 0.3)
replace t4v0740 = t4v0740 + group_id/5
label variable t4v0740 "Generated stress variable 0740"
quietly summarize t4v0740
display as text "[VAR] t4v0740 mean=" %9.4f r(mean)
gen t4v0741 = gear_ratio + rnormal(0, 0.4)
replace t4v0741 = t4v0741 + group_id/6
gen t4v0742 = price + rnormal(0, 0.5)
replace t4v0742 = t4v0742 + group_id/7
gen t4v0743 = mpg + rnormal(0, 0.6)
replace t4v0743 = t4v0743 + group_id/8
gen t4v0744 = weight + rnormal(0, 0.7)
replace t4v0744 = t4v0744 + group_id/9
gen t4v0745 = length + rnormal(0, 0.8)
replace t4v0745 = t4v0745 + group_id/10
label variable t4v0745 "Generated stress variable 0745"
gen t4v0746 = turn + rnormal(0, 0.9)
replace t4v0746 = t4v0746 + group_id/11
gen t4v0747 = displacement + rnormal(0, 0.1)
replace t4v0747 = t4v0747 + group_id/12
gen t4v0748 = gear_ratio + rnormal(0, 0.2)
replace t4v0748 = t4v0748 + group_id/2
gen t4v0749 = price + rnormal(0, 0.3)
replace t4v0749 = t4v0749 + group_id/3
gen t4v0750 = mpg + rnormal(0, 0.4)
replace t4v0750 = t4v0750 + group_id/4
label variable t4v0750 "Generated stress variable 0750"
gen t4v0751 = weight + rnormal(0, 0.5)
replace t4v0751 = t4v0751 + group_id/5
gen t4v0752 = length + rnormal(0, 0.6)
replace t4v0752 = t4v0752 + group_id/6
gen t4v0753 = turn + rnormal(0, 0.7)
replace t4v0753 = t4v0753 + group_id/7
gen t4v0754 = displacement + rnormal(0, 0.8)
replace t4v0754 = t4v0754 + group_id/8
gen t4v0755 = gear_ratio + rnormal(0, 0.9)
replace t4v0755 = t4v0755 + group_id/9
label variable t4v0755 "Generated stress variable 0755"
gen t4v0756 = price + rnormal(0, 0.1)
replace t4v0756 = t4v0756 + group_id/10
gen t4v0757 = mpg + rnormal(0, 0.2)
replace t4v0757 = t4v0757 + group_id/11
gen t4v0758 = weight + rnormal(0, 0.3)
replace t4v0758 = t4v0758 + group_id/12
gen t4v0759 = length + rnormal(0, 0.4)
replace t4v0759 = t4v0759 + group_id/2
gen t4v0760 = turn + rnormal(0, 0.5)
replace t4v0760 = t4v0760 + group_id/3
label variable t4v0760 "Generated stress variable 0760"
quietly summarize t4v0760
display as text "[VAR] t4v0760 mean=" %9.4f r(mean)
gen t4v0761 = displacement + rnormal(0, 0.6)
replace t4v0761 = t4v0761 + group_id/4
gen t4v0762 = gear_ratio + rnormal(0, 0.7)
replace t4v0762 = t4v0762 + group_id/5
gen t4v0763 = price + rnormal(0, 0.8)
replace t4v0763 = t4v0763 + group_id/6
gen t4v0764 = mpg + rnormal(0, 0.9)
replace t4v0764 = t4v0764 + group_id/7
gen t4v0765 = weight + rnormal(0, 0.1)
replace t4v0765 = t4v0765 + group_id/8
label variable t4v0765 "Generated stress variable 0765"
gen t4v0766 = length + rnormal(0, 0.2)
replace t4v0766 = t4v0766 + group_id/9
gen t4v0767 = turn + rnormal(0, 0.3)
replace t4v0767 = t4v0767 + group_id/10
gen t4v0768 = displacement + rnormal(0, 0.4)
replace t4v0768 = t4v0768 + group_id/11
gen t4v0769 = gear_ratio + rnormal(0, 0.5)
replace t4v0769 = t4v0769 + group_id/12
gen t4v0770 = price + rnormal(0, 0.6)
replace t4v0770 = t4v0770 + group_id/2
label variable t4v0770 "Generated stress variable 0770"
gen t4v0771 = mpg + rnormal(0, 0.7)
replace t4v0771 = t4v0771 + group_id/3
gen t4v0772 = weight + rnormal(0, 0.8)
replace t4v0772 = t4v0772 + group_id/4
gen t4v0773 = length + rnormal(0, 0.9)
replace t4v0773 = t4v0773 + group_id/5
gen t4v0774 = turn + rnormal(0, 0.1)
replace t4v0774 = t4v0774 + group_id/6
gen t4v0775 = displacement + rnormal(0, 0.2)
replace t4v0775 = t4v0775 + group_id/7
label variable t4v0775 "Generated stress variable 0775"
gen t4v0776 = gear_ratio + rnormal(0, 0.3)
replace t4v0776 = t4v0776 + group_id/8
gen t4v0777 = price + rnormal(0, 0.4)
replace t4v0777 = t4v0777 + group_id/9
gen t4v0778 = mpg + rnormal(0, 0.5)
replace t4v0778 = t4v0778 + group_id/10
gen t4v0779 = weight + rnormal(0, 0.6)
replace t4v0779 = t4v0779 + group_id/11
gen t4v0780 = length + rnormal(0, 0.7)
replace t4v0780 = t4v0780 + group_id/12
label variable t4v0780 "Generated stress variable 0780"
quietly summarize t4v0780
display as text "[VAR] t4v0780 mean=" %9.4f r(mean)
gen t4v0781 = turn + rnormal(0, 0.8)
replace t4v0781 = t4v0781 + group_id/2
gen t4v0782 = displacement + rnormal(0, 0.9)
replace t4v0782 = t4v0782 + group_id/3
gen t4v0783 = gear_ratio + rnormal(0, 0.1)
replace t4v0783 = t4v0783 + group_id/4
gen t4v0784 = price + rnormal(0, 0.2)
replace t4v0784 = t4v0784 + group_id/5
gen t4v0785 = mpg + rnormal(0, 0.3)
replace t4v0785 = t4v0785 + group_id/6
label variable t4v0785 "Generated stress variable 0785"
gen t4v0786 = weight + rnormal(0, 0.4)
replace t4v0786 = t4v0786 + group_id/7
gen t4v0787 = length + rnormal(0, 0.5)
replace t4v0787 = t4v0787 + group_id/8
gen t4v0788 = turn + rnormal(0, 0.6)
replace t4v0788 = t4v0788 + group_id/9
gen t4v0789 = displacement + rnormal(0, 0.7)
replace t4v0789 = t4v0789 + group_id/10
gen t4v0790 = gear_ratio + rnormal(0, 0.8)
replace t4v0790 = t4v0790 + group_id/11
label variable t4v0790 "Generated stress variable 0790"
gen t4v0791 = price + rnormal(0, 0.9)
replace t4v0791 = t4v0791 + group_id/12
gen t4v0792 = mpg + rnormal(0, 0.1)
replace t4v0792 = t4v0792 + group_id/2
gen t4v0793 = weight + rnormal(0, 0.2)
replace t4v0793 = t4v0793 + group_id/3
gen t4v0794 = length + rnormal(0, 0.3)
replace t4v0794 = t4v0794 + group_id/4
gen t4v0795 = turn + rnormal(0, 0.4)
replace t4v0795 = t4v0795 + group_id/5
label variable t4v0795 "Generated stress variable 0795"
gen t4v0796 = displacement + rnormal(0, 0.5)
replace t4v0796 = t4v0796 + group_id/6
gen t4v0797 = gear_ratio + rnormal(0, 0.6)
replace t4v0797 = t4v0797 + group_id/7
gen t4v0798 = price + rnormal(0, 0.7)
replace t4v0798 = t4v0798 + group_id/8
gen t4v0799 = mpg + rnormal(0, 0.8)
replace t4v0799 = t4v0799 + group_id/9
gen t4v0800 = weight + rnormal(0, 0.9)
replace t4v0800 = t4v0800 + group_id/10
label variable t4v0800 "Generated stress variable 0800"
quietly summarize t4v0800
display as text "[VAR] t4v0800 mean=" %9.4f r(mean)
gen t4v0801 = length + rnormal(0, 0.1)
replace t4v0801 = t4v0801 + group_id/11
gen t4v0802 = turn + rnormal(0, 0.2)
replace t4v0802 = t4v0802 + group_id/12
gen t4v0803 = displacement + rnormal(0, 0.3)
replace t4v0803 = t4v0803 + group_id/2
gen t4v0804 = gear_ratio + rnormal(0, 0.4)
replace t4v0804 = t4v0804 + group_id/3
gen t4v0805 = price + rnormal(0, 0.5)
replace t4v0805 = t4v0805 + group_id/4
label variable t4v0805 "Generated stress variable 0805"
gen t4v0806 = mpg + rnormal(0, 0.6)
replace t4v0806 = t4v0806 + group_id/5
gen t4v0807 = weight + rnormal(0, 0.7)
replace t4v0807 = t4v0807 + group_id/6
gen t4v0808 = length + rnormal(0, 0.8)
replace t4v0808 = t4v0808 + group_id/7
gen t4v0809 = turn + rnormal(0, 0.9)
replace t4v0809 = t4v0809 + group_id/8
gen t4v0810 = displacement + rnormal(0, 0.1)
replace t4v0810 = t4v0810 + group_id/9
label variable t4v0810 "Generated stress variable 0810"
gen t4v0811 = gear_ratio + rnormal(0, 0.2)
replace t4v0811 = t4v0811 + group_id/10
gen t4v0812 = price + rnormal(0, 0.3)
replace t4v0812 = t4v0812 + group_id/11
gen t4v0813 = mpg + rnormal(0, 0.4)
replace t4v0813 = t4v0813 + group_id/12
gen t4v0814 = weight + rnormal(0, 0.5)
replace t4v0814 = t4v0814 + group_id/2
gen t4v0815 = length + rnormal(0, 0.6)
replace t4v0815 = t4v0815 + group_id/3
label variable t4v0815 "Generated stress variable 0815"
gen t4v0816 = turn + rnormal(0, 0.7)
replace t4v0816 = t4v0816 + group_id/4
gen t4v0817 = displacement + rnormal(0, 0.8)
replace t4v0817 = t4v0817 + group_id/5
gen t4v0818 = gear_ratio + rnormal(0, 0.9)
replace t4v0818 = t4v0818 + group_id/6
gen t4v0819 = price + rnormal(0, 0.1)
replace t4v0819 = t4v0819 + group_id/7
gen t4v0820 = mpg + rnormal(0, 0.2)
replace t4v0820 = t4v0820 + group_id/8
label variable t4v0820 "Generated stress variable 0820"
quietly summarize t4v0820
display as text "[VAR] t4v0820 mean=" %9.4f r(mean)
gen t4v0821 = weight + rnormal(0, 0.3)
replace t4v0821 = t4v0821 + group_id/9
gen t4v0822 = length + rnormal(0, 0.4)
replace t4v0822 = t4v0822 + group_id/10
gen t4v0823 = turn + rnormal(0, 0.5)
replace t4v0823 = t4v0823 + group_id/11
gen t4v0824 = displacement + rnormal(0, 0.6)
replace t4v0824 = t4v0824 + group_id/12
gen t4v0825 = gear_ratio + rnormal(0, 0.7)
replace t4v0825 = t4v0825 + group_id/2
label variable t4v0825 "Generated stress variable 0825"
gen t4v0826 = price + rnormal(0, 0.8)
replace t4v0826 = t4v0826 + group_id/3
gen t4v0827 = mpg + rnormal(0, 0.9)
replace t4v0827 = t4v0827 + group_id/4
gen t4v0828 = weight + rnormal(0, 0.1)
replace t4v0828 = t4v0828 + group_id/5
gen t4v0829 = length + rnormal(0, 0.2)
replace t4v0829 = t4v0829 + group_id/6
gen t4v0830 = turn + rnormal(0, 0.3)
replace t4v0830 = t4v0830 + group_id/7
label variable t4v0830 "Generated stress variable 0830"
gen t4v0831 = displacement + rnormal(0, 0.4)
replace t4v0831 = t4v0831 + group_id/8
gen t4v0832 = gear_ratio + rnormal(0, 0.5)
replace t4v0832 = t4v0832 + group_id/9
gen t4v0833 = price + rnormal(0, 0.6)
replace t4v0833 = t4v0833 + group_id/10
gen t4v0834 = mpg + rnormal(0, 0.7)
replace t4v0834 = t4v0834 + group_id/11
gen t4v0835 = weight + rnormal(0, 0.8)
replace t4v0835 = t4v0835 + group_id/12
label variable t4v0835 "Generated stress variable 0835"
gen t4v0836 = length + rnormal(0, 0.9)
replace t4v0836 = t4v0836 + group_id/2
gen t4v0837 = turn + rnormal(0, 0.1)
replace t4v0837 = t4v0837 + group_id/3
gen t4v0838 = displacement + rnormal(0, 0.2)
replace t4v0838 = t4v0838 + group_id/4
gen t4v0839 = gear_ratio + rnormal(0, 0.3)
replace t4v0839 = t4v0839 + group_id/5
gen t4v0840 = price + rnormal(0, 0.4)
replace t4v0840 = t4v0840 + group_id/6
label variable t4v0840 "Generated stress variable 0840"
quietly summarize t4v0840
display as text "[VAR] t4v0840 mean=" %9.4f r(mean)
gen t4v0841 = mpg + rnormal(0, 0.5)
replace t4v0841 = t4v0841 + group_id/7
gen t4v0842 = weight + rnormal(0, 0.6)
replace t4v0842 = t4v0842 + group_id/8
gen t4v0843 = length + rnormal(0, 0.7)
replace t4v0843 = t4v0843 + group_id/9
gen t4v0844 = turn + rnormal(0, 0.8)
replace t4v0844 = t4v0844 + group_id/10
gen t4v0845 = displacement + rnormal(0, 0.9)
replace t4v0845 = t4v0845 + group_id/11
label variable t4v0845 "Generated stress variable 0845"
gen t4v0846 = gear_ratio + rnormal(0, 0.1)
replace t4v0846 = t4v0846 + group_id/12
gen t4v0847 = price + rnormal(0, 0.2)
replace t4v0847 = t4v0847 + group_id/2
gen t4v0848 = mpg + rnormal(0, 0.3)
replace t4v0848 = t4v0848 + group_id/3
gen t4v0849 = weight + rnormal(0, 0.4)
replace t4v0849 = t4v0849 + group_id/4
gen t4v0850 = length + rnormal(0, 0.5)
replace t4v0850 = t4v0850 + group_id/5
label variable t4v0850 "Generated stress variable 0850"
gen t4v0851 = turn + rnormal(0, 0.6)
replace t4v0851 = t4v0851 + group_id/6
gen t4v0852 = displacement + rnormal(0, 0.7)
replace t4v0852 = t4v0852 + group_id/7
gen t4v0853 = gear_ratio + rnormal(0, 0.8)
replace t4v0853 = t4v0853 + group_id/8
gen t4v0854 = price + rnormal(0, 0.9)
replace t4v0854 = t4v0854 + group_id/9
gen t4v0855 = mpg + rnormal(0, 0.1)
replace t4v0855 = t4v0855 + group_id/10
label variable t4v0855 "Generated stress variable 0855"
gen t4v0856 = weight + rnormal(0, 0.2)
replace t4v0856 = t4v0856 + group_id/11
gen t4v0857 = length + rnormal(0, 0.3)
replace t4v0857 = t4v0857 + group_id/12
gen t4v0858 = turn + rnormal(0, 0.4)
replace t4v0858 = t4v0858 + group_id/2
gen t4v0859 = displacement + rnormal(0, 0.5)
replace t4v0859 = t4v0859 + group_id/3
gen t4v0860 = gear_ratio + rnormal(0, 0.6)
replace t4v0860 = t4v0860 + group_id/4
label variable t4v0860 "Generated stress variable 0860"
quietly summarize t4v0860
display as text "[VAR] t4v0860 mean=" %9.4f r(mean)
gen t4v0861 = price + rnormal(0, 0.7)
replace t4v0861 = t4v0861 + group_id/5
gen t4v0862 = mpg + rnormal(0, 0.8)
replace t4v0862 = t4v0862 + group_id/6
gen t4v0863 = weight + rnormal(0, 0.9)
replace t4v0863 = t4v0863 + group_id/7
gen t4v0864 = length + rnormal(0, 0.1)
replace t4v0864 = t4v0864 + group_id/8
gen t4v0865 = turn + rnormal(0, 0.2)
replace t4v0865 = t4v0865 + group_id/9
label variable t4v0865 "Generated stress variable 0865"
gen t4v0866 = displacement + rnormal(0, 0.3)
replace t4v0866 = t4v0866 + group_id/10
gen t4v0867 = gear_ratio + rnormal(0, 0.4)
replace t4v0867 = t4v0867 + group_id/11
gen t4v0868 = price + rnormal(0, 0.5)
replace t4v0868 = t4v0868 + group_id/12
gen t4v0869 = mpg + rnormal(0, 0.6)
replace t4v0869 = t4v0869 + group_id/2
gen t4v0870 = weight + rnormal(0, 0.7)
replace t4v0870 = t4v0870 + group_id/3
label variable t4v0870 "Generated stress variable 0870"
gen t4v0871 = length + rnormal(0, 0.8)
replace t4v0871 = t4v0871 + group_id/4
gen t4v0872 = turn + rnormal(0, 0.9)
replace t4v0872 = t4v0872 + group_id/5
gen t4v0873 = displacement + rnormal(0, 0.1)
replace t4v0873 = t4v0873 + group_id/6
gen t4v0874 = gear_ratio + rnormal(0, 0.2)
replace t4v0874 = t4v0874 + group_id/7
gen t4v0875 = price + rnormal(0, 0.3)
replace t4v0875 = t4v0875 + group_id/8
label variable t4v0875 "Generated stress variable 0875"
gen t4v0876 = mpg + rnormal(0, 0.4)
replace t4v0876 = t4v0876 + group_id/9
gen t4v0877 = weight + rnormal(0, 0.5)
replace t4v0877 = t4v0877 + group_id/10
gen t4v0878 = length + rnormal(0, 0.6)
replace t4v0878 = t4v0878 + group_id/11
gen t4v0879 = turn + rnormal(0, 0.7)
replace t4v0879 = t4v0879 + group_id/12
gen t4v0880 = displacement + rnormal(0, 0.8)
replace t4v0880 = t4v0880 + group_id/2
label variable t4v0880 "Generated stress variable 0880"
quietly summarize t4v0880
display as text "[VAR] t4v0880 mean=" %9.4f r(mean)
gen t4v0881 = gear_ratio + rnormal(0, 0.9)
replace t4v0881 = t4v0881 + group_id/3
gen t4v0882 = price + rnormal(0, 0.1)
replace t4v0882 = t4v0882 + group_id/4
gen t4v0883 = mpg + rnormal(0, 0.2)
replace t4v0883 = t4v0883 + group_id/5
gen t4v0884 = weight + rnormal(0, 0.3)
replace t4v0884 = t4v0884 + group_id/6
gen t4v0885 = length + rnormal(0, 0.4)
replace t4v0885 = t4v0885 + group_id/7
label variable t4v0885 "Generated stress variable 0885"
gen t4v0886 = turn + rnormal(0, 0.5)
replace t4v0886 = t4v0886 + group_id/8
gen t4v0887 = displacement + rnormal(0, 0.6)
replace t4v0887 = t4v0887 + group_id/9
gen t4v0888 = gear_ratio + rnormal(0, 0.7)
replace t4v0888 = t4v0888 + group_id/10
gen t4v0889 = price + rnormal(0, 0.8)
replace t4v0889 = t4v0889 + group_id/11
gen t4v0890 = mpg + rnormal(0, 0.9)
replace t4v0890 = t4v0890 + group_id/12
label variable t4v0890 "Generated stress variable 0890"
gen t4v0891 = weight + rnormal(0, 0.1)
replace t4v0891 = t4v0891 + group_id/2
gen t4v0892 = length + rnormal(0, 0.2)
replace t4v0892 = t4v0892 + group_id/3
gen t4v0893 = turn + rnormal(0, 0.3)
replace t4v0893 = t4v0893 + group_id/4
gen t4v0894 = displacement + rnormal(0, 0.4)
replace t4v0894 = t4v0894 + group_id/5
gen t4v0895 = gear_ratio + rnormal(0, 0.5)
replace t4v0895 = t4v0895 + group_id/6
label variable t4v0895 "Generated stress variable 0895"
gen t4v0896 = price + rnormal(0, 0.6)
replace t4v0896 = t4v0896 + group_id/7
gen t4v0897 = mpg + rnormal(0, 0.7)
replace t4v0897 = t4v0897 + group_id/8
gen t4v0898 = weight + rnormal(0, 0.8)
replace t4v0898 = t4v0898 + group_id/9
gen t4v0899 = length + rnormal(0, 0.9)
replace t4v0899 = t4v0899 + group_id/10
gen t4v0900 = turn + rnormal(0, 0.1)
replace t4v0900 = t4v0900 + group_id/11
label variable t4v0900 "Generated stress variable 0900"
quietly summarize t4v0900
display as text "[VAR] t4v0900 mean=" %9.4f r(mean)
gen t4v0901 = displacement + rnormal(0, 0.2)
replace t4v0901 = t4v0901 + group_id/12
gen t4v0902 = gear_ratio + rnormal(0, 0.3)
replace t4v0902 = t4v0902 + group_id/2
gen t4v0903 = price + rnormal(0, 0.4)
replace t4v0903 = t4v0903 + group_id/3
gen t4v0904 = mpg + rnormal(0, 0.5)
replace t4v0904 = t4v0904 + group_id/4
gen t4v0905 = weight + rnormal(0, 0.6)
replace t4v0905 = t4v0905 + group_id/5
label variable t4v0905 "Generated stress variable 0905"
gen t4v0906 = length + rnormal(0, 0.7)
replace t4v0906 = t4v0906 + group_id/6
gen t4v0907 = turn + rnormal(0, 0.8)
replace t4v0907 = t4v0907 + group_id/7
gen t4v0908 = displacement + rnormal(0, 0.9)
replace t4v0908 = t4v0908 + group_id/8
gen t4v0909 = gear_ratio + rnormal(0, 0.1)
replace t4v0909 = t4v0909 + group_id/9
gen t4v0910 = price + rnormal(0, 0.2)
replace t4v0910 = t4v0910 + group_id/10
label variable t4v0910 "Generated stress variable 0910"
gen t4v0911 = mpg + rnormal(0, 0.3)
replace t4v0911 = t4v0911 + group_id/11
gen t4v0912 = weight + rnormal(0, 0.4)
replace t4v0912 = t4v0912 + group_id/12
gen t4v0913 = length + rnormal(0, 0.5)
replace t4v0913 = t4v0913 + group_id/2
gen t4v0914 = turn + rnormal(0, 0.6)
replace t4v0914 = t4v0914 + group_id/3
gen t4v0915 = displacement + rnormal(0, 0.7)
replace t4v0915 = t4v0915 + group_id/4
label variable t4v0915 "Generated stress variable 0915"
gen t4v0916 = gear_ratio + rnormal(0, 0.8)
replace t4v0916 = t4v0916 + group_id/5
gen t4v0917 = price + rnormal(0, 0.9)
replace t4v0917 = t4v0917 + group_id/6
gen t4v0918 = mpg + rnormal(0, 0.1)
replace t4v0918 = t4v0918 + group_id/7
gen t4v0919 = weight + rnormal(0, 0.2)
replace t4v0919 = t4v0919 + group_id/8
gen t4v0920 = length + rnormal(0, 0.3)
replace t4v0920 = t4v0920 + group_id/9
label variable t4v0920 "Generated stress variable 0920"
quietly summarize t4v0920
display as text "[VAR] t4v0920 mean=" %9.4f r(mean)
gen t4v0921 = turn + rnormal(0, 0.4)
replace t4v0921 = t4v0921 + group_id/10
gen t4v0922 = displacement + rnormal(0, 0.5)
replace t4v0922 = t4v0922 + group_id/11
gen t4v0923 = gear_ratio + rnormal(0, 0.6)
replace t4v0923 = t4v0923 + group_id/12
gen t4v0924 = price + rnormal(0, 0.7)
replace t4v0924 = t4v0924 + group_id/2
gen t4v0925 = mpg + rnormal(0, 0.8)
replace t4v0925 = t4v0925 + group_id/3
label variable t4v0925 "Generated stress variable 0925"
gen t4v0926 = weight + rnormal(0, 0.9)
replace t4v0926 = t4v0926 + group_id/4
gen t4v0927 = length + rnormal(0, 0.1)
replace t4v0927 = t4v0927 + group_id/5
gen t4v0928 = turn + rnormal(0, 0.2)
replace t4v0928 = t4v0928 + group_id/6
gen t4v0929 = displacement + rnormal(0, 0.3)
replace t4v0929 = t4v0929 + group_id/7
gen t4v0930 = gear_ratio + rnormal(0, 0.4)
replace t4v0930 = t4v0930 + group_id/8
label variable t4v0930 "Generated stress variable 0930"
gen t4v0931 = price + rnormal(0, 0.5)
replace t4v0931 = t4v0931 + group_id/9
gen t4v0932 = mpg + rnormal(0, 0.6)
replace t4v0932 = t4v0932 + group_id/10
gen t4v0933 = weight + rnormal(0, 0.7)
replace t4v0933 = t4v0933 + group_id/11
gen t4v0934 = length + rnormal(0, 0.8)
replace t4v0934 = t4v0934 + group_id/12
gen t4v0935 = turn + rnormal(0, 0.9)
replace t4v0935 = t4v0935 + group_id/2
label variable t4v0935 "Generated stress variable 0935"
gen t4v0936 = displacement + rnormal(0, 0.1)
replace t4v0936 = t4v0936 + group_id/3
gen t4v0937 = gear_ratio + rnormal(0, 0.2)
replace t4v0937 = t4v0937 + group_id/4
gen t4v0938 = price + rnormal(0, 0.3)
replace t4v0938 = t4v0938 + group_id/5
gen t4v0939 = mpg + rnormal(0, 0.4)
replace t4v0939 = t4v0939 + group_id/6
gen t4v0940 = weight + rnormal(0, 0.5)
replace t4v0940 = t4v0940 + group_id/7
label variable t4v0940 "Generated stress variable 0940"
quietly summarize t4v0940
display as text "[VAR] t4v0940 mean=" %9.4f r(mean)
gen t4v0941 = length + rnormal(0, 0.6)
replace t4v0941 = t4v0941 + group_id/8
gen t4v0942 = turn + rnormal(0, 0.7)
replace t4v0942 = t4v0942 + group_id/9
gen t4v0943 = displacement + rnormal(0, 0.8)
replace t4v0943 = t4v0943 + group_id/10
gen t4v0944 = gear_ratio + rnormal(0, 0.9)
replace t4v0944 = t4v0944 + group_id/11
gen t4v0945 = price + rnormal(0, 0.1)
replace t4v0945 = t4v0945 + group_id/12
label variable t4v0945 "Generated stress variable 0945"
gen t4v0946 = mpg + rnormal(0, 0.2)
replace t4v0946 = t4v0946 + group_id/2
gen t4v0947 = weight + rnormal(0, 0.3)
replace t4v0947 = t4v0947 + group_id/3
gen t4v0948 = length + rnormal(0, 0.4)
replace t4v0948 = t4v0948 + group_id/4
gen t4v0949 = turn + rnormal(0, 0.5)
replace t4v0949 = t4v0949 + group_id/5
gen t4v0950 = displacement + rnormal(0, 0.6)
replace t4v0950 = t4v0950 + group_id/6
label variable t4v0950 "Generated stress variable 0950"
gen t4v0951 = gear_ratio + rnormal(0, 0.7)
replace t4v0951 = t4v0951 + group_id/7
gen t4v0952 = price + rnormal(0, 0.8)
replace t4v0952 = t4v0952 + group_id/8
gen t4v0953 = mpg + rnormal(0, 0.9)
replace t4v0953 = t4v0953 + group_id/9
gen t4v0954 = weight + rnormal(0, 0.1)
replace t4v0954 = t4v0954 + group_id/10
gen t4v0955 = length + rnormal(0, 0.2)
replace t4v0955 = t4v0955 + group_id/11
label variable t4v0955 "Generated stress variable 0955"
gen t4v0956 = turn + rnormal(0, 0.3)
replace t4v0956 = t4v0956 + group_id/12
gen t4v0957 = displacement + rnormal(0, 0.4)
replace t4v0957 = t4v0957 + group_id/2
gen t4v0958 = gear_ratio + rnormal(0, 0.5)
replace t4v0958 = t4v0958 + group_id/3
gen t4v0959 = price + rnormal(0, 0.6)
replace t4v0959 = t4v0959 + group_id/4
gen t4v0960 = mpg + rnormal(0, 0.7)
replace t4v0960 = t4v0960 + group_id/5
label variable t4v0960 "Generated stress variable 0960"
quietly summarize t4v0960
display as text "[VAR] t4v0960 mean=" %9.4f r(mean)
gen t4v0961 = weight + rnormal(0, 0.8)
replace t4v0961 = t4v0961 + group_id/6
gen t4v0962 = length + rnormal(0, 0.9)
replace t4v0962 = t4v0962 + group_id/7
gen t4v0963 = turn + rnormal(0, 0.1)
replace t4v0963 = t4v0963 + group_id/8
gen t4v0964 = displacement + rnormal(0, 0.2)
replace t4v0964 = t4v0964 + group_id/9
gen t4v0965 = gear_ratio + rnormal(0, 0.3)
replace t4v0965 = t4v0965 + group_id/10
label variable t4v0965 "Generated stress variable 0965"
gen t4v0966 = price + rnormal(0, 0.4)
replace t4v0966 = t4v0966 + group_id/11
gen t4v0967 = mpg + rnormal(0, 0.5)
replace t4v0967 = t4v0967 + group_id/12
gen t4v0968 = weight + rnormal(0, 0.6)
replace t4v0968 = t4v0968 + group_id/2
gen t4v0969 = length + rnormal(0, 0.7)
replace t4v0969 = t4v0969 + group_id/3
gen t4v0970 = turn + rnormal(0, 0.8)
replace t4v0970 = t4v0970 + group_id/4
label variable t4v0970 "Generated stress variable 0970"
gen t4v0971 = displacement + rnormal(0, 0.9)
replace t4v0971 = t4v0971 + group_id/5
gen t4v0972 = gear_ratio + rnormal(0, 0.1)
replace t4v0972 = t4v0972 + group_id/6
gen t4v0973 = price + rnormal(0, 0.2)
replace t4v0973 = t4v0973 + group_id/7
gen t4v0974 = mpg + rnormal(0, 0.3)
replace t4v0974 = t4v0974 + group_id/8
gen t4v0975 = weight + rnormal(0, 0.4)
replace t4v0975 = t4v0975 + group_id/9
label variable t4v0975 "Generated stress variable 0975"
gen t4v0976 = length + rnormal(0, 0.5)
replace t4v0976 = t4v0976 + group_id/10
gen t4v0977 = turn + rnormal(0, 0.6)
replace t4v0977 = t4v0977 + group_id/11
gen t4v0978 = displacement + rnormal(0, 0.7)
replace t4v0978 = t4v0978 + group_id/12
gen t4v0979 = gear_ratio + rnormal(0, 0.8)
replace t4v0979 = t4v0979 + group_id/2
gen t4v0980 = price + rnormal(0, 0.9)
replace t4v0980 = t4v0980 + group_id/3
label variable t4v0980 "Generated stress variable 0980"
quietly summarize t4v0980
display as text "[VAR] t4v0980 mean=" %9.4f r(mean)
display as result "<<< DONE Section 2: generated variables marathon"
// #endregion ===== Section 2: generated variables marathon =====


// #region ===== Section 3: unnamed transient graph gauntlet =====
display as text ">>> START Section 3: unnamed transient graph gauntlet"
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T4 hist Graph 001: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t4 graph stress 001")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 001 produced"
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T4 bar Graph 002: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t4 graph stress 002")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 002 produced"
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T4 line Graph 003: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t4 graph stress 003")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 003 produced"
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T4 qfit Graph 004: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t4 graph stress 004")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 004 produced"
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T4 scatter Graph 005: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t4 graph stress 005")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 005 produced"
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T4 hist Graph 006: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t4 graph stress 006")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 006 produced"
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T4 bar Graph 007: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t4 graph stress 007")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 007 produced"
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T4 line Graph 008: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t4 graph stress 008")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 008 produced"
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T4 qfit Graph 009: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t4 graph stress 009")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 009 produced"
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T4 scatter Graph 010: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t4 graph stress 010")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 010 produced"
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T4 hist Graph 011: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t4 graph stress 011")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 011 produced"
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T4 bar Graph 012: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t4 graph stress 012")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 012 produced"
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T4 line Graph 013: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t4 graph stress 013")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 013 produced"
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T4 qfit Graph 014: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t4 graph stress 014")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 014 produced"
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T4 scatter Graph 015: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t4 graph stress 015")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 015 produced"
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T4 hist Graph 016: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t4 graph stress 016")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 016 produced"
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T4 bar Graph 017: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t4 graph stress 017")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 017 produced"
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T4 line Graph 018: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t4 graph stress 018")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 018 produced"
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T4 qfit Graph 019: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t4 graph stress 019")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 019 produced"
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T4 scatter Graph 020: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t4 graph stress 020")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 020 produced"
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T4 hist Graph 021: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t4 graph stress 021")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 021 produced"
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T4 bar Graph 022: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t4 graph stress 022")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 022 produced"
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T4 line Graph 023: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t4 graph stress 023")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 023 produced"
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T4 qfit Graph 024: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t4 graph stress 024")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 024 produced"
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T4 scatter Graph 025: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t4 graph stress 025")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 025 produced"
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T4 hist Graph 026: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t4 graph stress 026")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 026 produced"
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T4 bar Graph 027: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t4 graph stress 027")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 027 produced"
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T4 line Graph 028: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t4 graph stress 028")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 028 produced"
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T4 qfit Graph 029: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t4 graph stress 029")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 029 produced"
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T4 scatter Graph 030: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t4 graph stress 030")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 030 produced"
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T4 hist Graph 031: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t4 graph stress 031")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 031 produced"
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T4 bar Graph 032: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t4 graph stress 032")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 032 produced"
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T4 line Graph 033: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t4 graph stress 033")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 033 produced"
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T4 qfit Graph 034: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t4 graph stress 034")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 034 produced"
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T4 scatter Graph 035: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t4 graph stress 035")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 035 produced"
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T4 hist Graph 036: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t4 graph stress 036")
display as text "[GRAPH-UNNAMED] t4 unnamed graph 036 produced"
graph drop _all
display as text "[GRAPH-UNNAMED] graph drop _all after 36 transient graphs"
display as result "<<< DONE Section 3: unnamed transient graph gauntlet"
// #endregion ===== Section 3: unnamed transient graph gauntlet =====


// #region ===== Section 4: named graph loop and export activation =====
display as text ">>> START Section 4: named graph loop and export activation"
forvalues i = 1/120 {
    local gname = "t4loop" + string(`i', "%03.0f")
    local color = cond(mod(`i', 3)==0, "navy", cond(mod(`i', 3)==1, "maroon", "forest_green"))
    twoway (scatter price mpg if group_id == mod(`i', 8)+1, mcolor(`color'%35)) ///
        (lfit price mpg if group_id == mod(`i', 8)+1, lcolor(`color')), ///
        title("Named loop graph `i'") subtitle("Workbench batch hydrate stress") ///
        name(`gname', replace)
    graph export "$figdir4/`gname'.svg", name(`gname') replace
    display as text "[GRAPH-NAMED] exported `gname'"
}
display as result "<<< DONE Section 4: named graph loop and export activation"
// #endregion ===== Section 4: named graph loop and export activation =====


// #region ===== Section 5: large anonymous brace block =====
display as text ">>> START Section 5: large anonymous brace block"
if 1 {
    tempfile anonbase
    save `anonbase', replace
    quietly summarize t4v0001
    display as text "[ANON 0001] t4v0001 mean=" %9.4f r(mean)
    quietly summarize t4v0002
    display as text "[ANON 0002] t4v0002 mean=" %9.4f r(mean)
    quietly summarize t4v0003
    display as text "[ANON 0003] t4v0003 mean=" %9.4f r(mean)
    quietly summarize t4v0004
    display as text "[ANON 0004] t4v0004 mean=" %9.4f r(mean)
    quietly summarize t4v0005
    display as text "[ANON 0005] t4v0005 mean=" %9.4f r(mean)
    quietly summarize t4v0006
    display as text "[ANON 0006] t4v0006 mean=" %9.4f r(mean)
    quietly summarize t4v0007
    display as text "[ANON 0007] t4v0007 mean=" %9.4f r(mean)
    quietly summarize t4v0008
    display as text "[ANON 0008] t4v0008 mean=" %9.4f r(mean)
    quietly summarize t4v0009
    display as text "[ANON 0009] t4v0009 mean=" %9.4f r(mean)
    quietly summarize t4v0010
    display as text "[ANON 0010] t4v0010 mean=" %9.4f r(mean)
    quietly summarize t4v0011
    display as text "[ANON 0011] t4v0011 mean=" %9.4f r(mean)
    quietly summarize t4v0012
    display as text "[ANON 0012] t4v0012 mean=" %9.4f r(mean)
    quietly summarize t4v0013
    display as text "[ANON 0013] t4v0013 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0013
    quietly summarize t4v0014
    display as text "[ANON 0014] t4v0014 mean=" %9.4f r(mean)
    quietly summarize t4v0015
    display as text "[ANON 0015] t4v0015 mean=" %9.4f r(mean)
    quietly summarize t4v0016
    display as text "[ANON 0016] t4v0016 mean=" %9.4f r(mean)
    quietly summarize t4v0017
    display as text "[ANON 0017] t4v0017 mean=" %9.4f r(mean)
    quietly summarize t4v0018
    display as text "[ANON 0018] t4v0018 mean=" %9.4f r(mean)
    quietly summarize t4v0019
    display as text "[ANON 0019] t4v0019 mean=" %9.4f r(mean)
    quietly summarize t4v0020
    display as text "[ANON 0020] t4v0020 mean=" %9.4f r(mean)
    quietly summarize t4v0021
    display as text "[ANON 0021] t4v0021 mean=" %9.4f r(mean)
    quietly summarize t4v0022
    display as text "[ANON 0022] t4v0022 mean=" %9.4f r(mean)
    quietly summarize t4v0023
    display as text "[ANON 0023] t4v0023 mean=" %9.4f r(mean)
    quietly summarize t4v0024
    display as text "[ANON 0024] t4v0024 mean=" %9.4f r(mean)
    quietly summarize t4v0025
    display as text "[ANON 0025] t4v0025 mean=" %9.4f r(mean)
    quietly summarize t4v0026
    display as text "[ANON 0026] t4v0026 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0026
    quietly summarize t4v0027
    display as text "[ANON 0027] t4v0027 mean=" %9.4f r(mean)
    quietly summarize t4v0028
    display as text "[ANON 0028] t4v0028 mean=" %9.4f r(mean)
    quietly summarize t4v0029
    display as text "[ANON 0029] t4v0029 mean=" %9.4f r(mean)
    preserve
    keep if !missing(price, mpg, weight)
    count
    restore
    quietly summarize t4v0030
    display as text "[ANON 0030] t4v0030 mean=" %9.4f r(mean)
    quietly summarize t4v0031
    display as text "[ANON 0031] t4v0031 mean=" %9.4f r(mean)
    quietly summarize t4v0032
    display as text "[ANON 0032] t4v0032 mean=" %9.4f r(mean)
    quietly summarize t4v0033
    display as text "[ANON 0033] t4v0033 mean=" %9.4f r(mean)
    quietly summarize t4v0034
    display as text "[ANON 0034] t4v0034 mean=" %9.4f r(mean)
    quietly summarize t4v0035
    display as text "[ANON 0035] t4v0035 mean=" %9.4f r(mean)
    quietly summarize t4v0036
    display as text "[ANON 0036] t4v0036 mean=" %9.4f r(mean)
    quietly summarize t4v0037
    display as text "[ANON 0037] t4v0037 mean=" %9.4f r(mean)
    quietly summarize t4v0038
    display as text "[ANON 0038] t4v0038 mean=" %9.4f r(mean)
    quietly summarize t4v0039
    display as text "[ANON 0039] t4v0039 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0039
    quietly summarize t4v0040
    display as text "[ANON 0040] t4v0040 mean=" %9.4f r(mean)
    quietly summarize t4v0041
    display as text "[ANON 0041] t4v0041 mean=" %9.4f r(mean)
    quietly summarize t4v0042
    display as text "[ANON 0042] t4v0042 mean=" %9.4f r(mean)
    quietly summarize t4v0043
    display as text "[ANON 0043] t4v0043 mean=" %9.4f r(mean)
    quietly summarize t4v0044
    display as text "[ANON 0044] t4v0044 mean=" %9.4f r(mean)
    quietly summarize t4v0045
    display as text "[ANON 0045] t4v0045 mean=" %9.4f r(mean)
    quietly summarize t4v0046
    display as text "[ANON 0046] t4v0046 mean=" %9.4f r(mean)
    quietly summarize t4v0047
    display as text "[ANON 0047] t4v0047 mean=" %9.4f r(mean)
    quietly summarize t4v0048
    display as text "[ANON 0048] t4v0048 mean=" %9.4f r(mean)
    quietly summarize t4v0049
    display as text "[ANON 0049] t4v0049 mean=" %9.4f r(mean)
    quietly summarize t4v0050
    display as text "[ANON 0050] t4v0050 mean=" %9.4f r(mean)
    quietly summarize t4v0051
    display as text "[ANON 0051] t4v0051 mean=" %9.4f r(mean)
    quietly summarize t4v0052
    display as text "[ANON 0052] t4v0052 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0052
    quietly summarize t4v0053
    display as text "[ANON 0053] t4v0053 mean=" %9.4f r(mean)
    quietly summarize t4v0054
    display as text "[ANON 0054] t4v0054 mean=" %9.4f r(mean)
    quietly summarize t4v0055
    display as text "[ANON 0055] t4v0055 mean=" %9.4f r(mean)
    quietly summarize t4v0056
    display as text "[ANON 0056] t4v0056 mean=" %9.4f r(mean)
    quietly summarize t4v0057
    display as text "[ANON 0057] t4v0057 mean=" %9.4f r(mean)
    quietly summarize t4v0058
    display as text "[ANON 0058] t4v0058 mean=" %9.4f r(mean)
    preserve
    keep if !missing(price, mpg, weight)
    count
    restore
    quietly summarize t4v0059
    display as text "[ANON 0059] t4v0059 mean=" %9.4f r(mean)
    quietly summarize t4v0060
    display as text "[ANON 0060] t4v0060 mean=" %9.4f r(mean)
    quietly summarize t4v0061
    display as text "[ANON 0061] t4v0061 mean=" %9.4f r(mean)
    quietly summarize t4v0062
    display as text "[ANON 0062] t4v0062 mean=" %9.4f r(mean)
    quietly summarize t4v0063
    display as text "[ANON 0063] t4v0063 mean=" %9.4f r(mean)
    quietly summarize t4v0064
    display as text "[ANON 0064] t4v0064 mean=" %9.4f r(mean)
    quietly summarize t4v0065
    display as text "[ANON 0065] t4v0065 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0065
    quietly summarize t4v0066
    display as text "[ANON 0066] t4v0066 mean=" %9.4f r(mean)
    quietly summarize t4v0067
    display as text "[ANON 0067] t4v0067 mean=" %9.4f r(mean)
    quietly summarize t4v0068
    display as text "[ANON 0068] t4v0068 mean=" %9.4f r(mean)
    quietly summarize t4v0069
    display as text "[ANON 0069] t4v0069 mean=" %9.4f r(mean)
    quietly summarize t4v0070
    display as text "[ANON 0070] t4v0070 mean=" %9.4f r(mean)
    quietly summarize t4v0071
    display as text "[ANON 0071] t4v0071 mean=" %9.4f r(mean)
    quietly summarize t4v0072
    display as text "[ANON 0072] t4v0072 mean=" %9.4f r(mean)
    quietly summarize t4v0073
    display as text "[ANON 0073] t4v0073 mean=" %9.4f r(mean)
    quietly summarize t4v0074
    display as text "[ANON 0074] t4v0074 mean=" %9.4f r(mean)
    quietly summarize t4v0075
    display as text "[ANON 0075] t4v0075 mean=" %9.4f r(mean)
    quietly summarize t4v0076
    display as text "[ANON 0076] t4v0076 mean=" %9.4f r(mean)
    quietly summarize t4v0077
    display as text "[ANON 0077] t4v0077 mean=" %9.4f r(mean)
    quietly summarize t4v0078
    display as text "[ANON 0078] t4v0078 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0078
    quietly summarize t4v0079
    display as text "[ANON 0079] t4v0079 mean=" %9.4f r(mean)
    quietly summarize t4v0080
    display as text "[ANON 0080] t4v0080 mean=" %9.4f r(mean)
    quietly summarize t4v0081
    display as text "[ANON 0081] t4v0081 mean=" %9.4f r(mean)
    quietly summarize t4v0082
    display as text "[ANON 0082] t4v0082 mean=" %9.4f r(mean)
    quietly summarize t4v0083
    display as text "[ANON 0083] t4v0083 mean=" %9.4f r(mean)
    quietly summarize t4v0084
    display as text "[ANON 0084] t4v0084 mean=" %9.4f r(mean)
    quietly summarize t4v0085
    display as text "[ANON 0085] t4v0085 mean=" %9.4f r(mean)
    quietly summarize t4v0086
    display as text "[ANON 0086] t4v0086 mean=" %9.4f r(mean)
    quietly summarize t4v0087
    display as text "[ANON 0087] t4v0087 mean=" %9.4f r(mean)
    preserve
    keep if !missing(price, mpg, weight)
    count
    restore
    quietly summarize t4v0088
    display as text "[ANON 0088] t4v0088 mean=" %9.4f r(mean)
    quietly summarize t4v0089
    display as text "[ANON 0089] t4v0089 mean=" %9.4f r(mean)
    quietly summarize t4v0090
    display as text "[ANON 0090] t4v0090 mean=" %9.4f r(mean)
    quietly summarize t4v0091
    display as text "[ANON 0091] t4v0091 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0091
    quietly summarize t4v0092
    display as text "[ANON 0092] t4v0092 mean=" %9.4f r(mean)
    quietly summarize t4v0093
    display as text "[ANON 0093] t4v0093 mean=" %9.4f r(mean)
    quietly summarize t4v0094
    display as text "[ANON 0094] t4v0094 mean=" %9.4f r(mean)
    quietly summarize t4v0095
    display as text "[ANON 0095] t4v0095 mean=" %9.4f r(mean)
    quietly summarize t4v0096
    display as text "[ANON 0096] t4v0096 mean=" %9.4f r(mean)
    quietly summarize t4v0097
    display as text "[ANON 0097] t4v0097 mean=" %9.4f r(mean)
    quietly summarize t4v0098
    display as text "[ANON 0098] t4v0098 mean=" %9.4f r(mean)
    quietly summarize t4v0099
    display as text "[ANON 0099] t4v0099 mean=" %9.4f r(mean)
    quietly summarize t4v0100
    display as text "[ANON 0100] t4v0100 mean=" %9.4f r(mean)
    quietly summarize t4v0101
    display as text "[ANON 0101] t4v0101 mean=" %9.4f r(mean)
    quietly summarize t4v0102
    display as text "[ANON 0102] t4v0102 mean=" %9.4f r(mean)
    quietly summarize t4v0103
    display as text "[ANON 0103] t4v0103 mean=" %9.4f r(mean)
    quietly summarize t4v0104
    display as text "[ANON 0104] t4v0104 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0104
    quietly summarize t4v0105
    display as text "[ANON 0105] t4v0105 mean=" %9.4f r(mean)
    quietly summarize t4v0106
    display as text "[ANON 0106] t4v0106 mean=" %9.4f r(mean)
    quietly summarize t4v0107
    display as text "[ANON 0107] t4v0107 mean=" %9.4f r(mean)
    quietly summarize t4v0108
    display as text "[ANON 0108] t4v0108 mean=" %9.4f r(mean)
    quietly summarize t4v0109
    display as text "[ANON 0109] t4v0109 mean=" %9.4f r(mean)
    quietly summarize t4v0110
    display as text "[ANON 0110] t4v0110 mean=" %9.4f r(mean)
    quietly summarize t4v0111
    display as text "[ANON 0111] t4v0111 mean=" %9.4f r(mean)
    quietly summarize t4v0112
    display as text "[ANON 0112] t4v0112 mean=" %9.4f r(mean)
    quietly summarize t4v0113
    display as text "[ANON 0113] t4v0113 mean=" %9.4f r(mean)
    quietly summarize t4v0114
    display as text "[ANON 0114] t4v0114 mean=" %9.4f r(mean)
    quietly summarize t4v0115
    display as text "[ANON 0115] t4v0115 mean=" %9.4f r(mean)
    quietly summarize t4v0116
    display as text "[ANON 0116] t4v0116 mean=" %9.4f r(mean)
    preserve
    keep if !missing(price, mpg, weight)
    count
    restore
    quietly summarize t4v0117
    display as text "[ANON 0117] t4v0117 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0117
    quietly summarize t4v0118
    display as text "[ANON 0118] t4v0118 mean=" %9.4f r(mean)
    quietly summarize t4v0119
    display as text "[ANON 0119] t4v0119 mean=" %9.4f r(mean)
    quietly summarize t4v0120
    display as text "[ANON 0120] t4v0120 mean=" %9.4f r(mean)
    quietly summarize t4v0121
    display as text "[ANON 0121] t4v0121 mean=" %9.4f r(mean)
    quietly summarize t4v0122
    display as text "[ANON 0122] t4v0122 mean=" %9.4f r(mean)
    quietly summarize t4v0123
    display as text "[ANON 0123] t4v0123 mean=" %9.4f r(mean)
    quietly summarize t4v0124
    display as text "[ANON 0124] t4v0124 mean=" %9.4f r(mean)
    quietly summarize t4v0125
    display as text "[ANON 0125] t4v0125 mean=" %9.4f r(mean)
    quietly summarize t4v0126
    display as text "[ANON 0126] t4v0126 mean=" %9.4f r(mean)
    quietly summarize t4v0127
    display as text "[ANON 0127] t4v0127 mean=" %9.4f r(mean)
    quietly summarize t4v0128
    display as text "[ANON 0128] t4v0128 mean=" %9.4f r(mean)
    quietly summarize t4v0129
    display as text "[ANON 0129] t4v0129 mean=" %9.4f r(mean)
    quietly summarize t4v0130
    display as text "[ANON 0130] t4v0130 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0130
    quietly summarize t4v0131
    display as text "[ANON 0131] t4v0131 mean=" %9.4f r(mean)
    quietly summarize t4v0132
    display as text "[ANON 0132] t4v0132 mean=" %9.4f r(mean)
    quietly summarize t4v0133
    display as text "[ANON 0133] t4v0133 mean=" %9.4f r(mean)
    quietly summarize t4v0134
    display as text "[ANON 0134] t4v0134 mean=" %9.4f r(mean)
    quietly summarize t4v0135
    display as text "[ANON 0135] t4v0135 mean=" %9.4f r(mean)
    quietly summarize t4v0136
    display as text "[ANON 0136] t4v0136 mean=" %9.4f r(mean)
    quietly summarize t4v0137
    display as text "[ANON 0137] t4v0137 mean=" %9.4f r(mean)
    quietly summarize t4v0138
    display as text "[ANON 0138] t4v0138 mean=" %9.4f r(mean)
    quietly summarize t4v0139
    display as text "[ANON 0139] t4v0139 mean=" %9.4f r(mean)
    quietly summarize t4v0140
    display as text "[ANON 0140] t4v0140 mean=" %9.4f r(mean)
    quietly summarize t4v0141
    display as text "[ANON 0141] t4v0141 mean=" %9.4f r(mean)
    quietly summarize t4v0142
    display as text "[ANON 0142] t4v0142 mean=" %9.4f r(mean)
    quietly summarize t4v0143
    display as text "[ANON 0143] t4v0143 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0143
    quietly summarize t4v0144
    display as text "[ANON 0144] t4v0144 mean=" %9.4f r(mean)
    quietly summarize t4v0145
    display as text "[ANON 0145] t4v0145 mean=" %9.4f r(mean)
    preserve
    keep if !missing(price, mpg, weight)
    count
    restore
    quietly summarize t4v0146
    display as text "[ANON 0146] t4v0146 mean=" %9.4f r(mean)
    quietly summarize t4v0147
    display as text "[ANON 0147] t4v0147 mean=" %9.4f r(mean)
    quietly summarize t4v0148
    display as text "[ANON 0148] t4v0148 mean=" %9.4f r(mean)
    quietly summarize t4v0149
    display as text "[ANON 0149] t4v0149 mean=" %9.4f r(mean)
    quietly summarize t4v0150
    display as text "[ANON 0150] t4v0150 mean=" %9.4f r(mean)
    quietly summarize t4v0151
    display as text "[ANON 0151] t4v0151 mean=" %9.4f r(mean)
    quietly summarize t4v0152
    display as text "[ANON 0152] t4v0152 mean=" %9.4f r(mean)
    quietly summarize t4v0153
    display as text "[ANON 0153] t4v0153 mean=" %9.4f r(mean)
    quietly summarize t4v0154
    display as text "[ANON 0154] t4v0154 mean=" %9.4f r(mean)
    quietly summarize t4v0155
    display as text "[ANON 0155] t4v0155 mean=" %9.4f r(mean)
    quietly summarize t4v0156
    display as text "[ANON 0156] t4v0156 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0156
    quietly summarize t4v0157
    display as text "[ANON 0157] t4v0157 mean=" %9.4f r(mean)
    quietly summarize t4v0158
    display as text "[ANON 0158] t4v0158 mean=" %9.4f r(mean)
    quietly summarize t4v0159
    display as text "[ANON 0159] t4v0159 mean=" %9.4f r(mean)
    quietly summarize t4v0160
    display as text "[ANON 0160] t4v0160 mean=" %9.4f r(mean)
    quietly summarize t4v0161
    display as text "[ANON 0161] t4v0161 mean=" %9.4f r(mean)
    quietly summarize t4v0162
    display as text "[ANON 0162] t4v0162 mean=" %9.4f r(mean)
    quietly summarize t4v0163
    display as text "[ANON 0163] t4v0163 mean=" %9.4f r(mean)
    quietly summarize t4v0164
    display as text "[ANON 0164] t4v0164 mean=" %9.4f r(mean)
    quietly summarize t4v0165
    display as text "[ANON 0165] t4v0165 mean=" %9.4f r(mean)
    quietly summarize t4v0166
    display as text "[ANON 0166] t4v0166 mean=" %9.4f r(mean)
    quietly summarize t4v0167
    display as text "[ANON 0167] t4v0167 mean=" %9.4f r(mean)
    quietly summarize t4v0168
    display as text "[ANON 0168] t4v0168 mean=" %9.4f r(mean)
    quietly summarize t4v0169
    display as text "[ANON 0169] t4v0169 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0169
    quietly summarize t4v0170
    display as text "[ANON 0170] t4v0170 mean=" %9.4f r(mean)
    quietly summarize t4v0171
    display as text "[ANON 0171] t4v0171 mean=" %9.4f r(mean)
    quietly summarize t4v0172
    display as text "[ANON 0172] t4v0172 mean=" %9.4f r(mean)
    quietly summarize t4v0173
    display as text "[ANON 0173] t4v0173 mean=" %9.4f r(mean)
    quietly summarize t4v0174
    display as text "[ANON 0174] t4v0174 mean=" %9.4f r(mean)
    preserve
    keep if !missing(price, mpg, weight)
    count
    restore
    quietly summarize t4v0175
    display as text "[ANON 0175] t4v0175 mean=" %9.4f r(mean)
    quietly summarize t4v0176
    display as text "[ANON 0176] t4v0176 mean=" %9.4f r(mean)
    quietly summarize t4v0177
    display as text "[ANON 0177] t4v0177 mean=" %9.4f r(mean)
    quietly summarize t4v0178
    display as text "[ANON 0178] t4v0178 mean=" %9.4f r(mean)
    quietly summarize t4v0179
    display as text "[ANON 0179] t4v0179 mean=" %9.4f r(mean)
    quietly summarize t4v0180
    display as text "[ANON 0180] t4v0180 mean=" %9.4f r(mean)
    quietly summarize t4v0181
    display as text "[ANON 0181] t4v0181 mean=" %9.4f r(mean)
    quietly summarize t4v0182
    display as text "[ANON 0182] t4v0182 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0182
    quietly summarize t4v0183
    display as text "[ANON 0183] t4v0183 mean=" %9.4f r(mean)
    quietly summarize t4v0184
    display as text "[ANON 0184] t4v0184 mean=" %9.4f r(mean)
    quietly summarize t4v0185
    display as text "[ANON 0185] t4v0185 mean=" %9.4f r(mean)
    quietly summarize t4v0186
    display as text "[ANON 0186] t4v0186 mean=" %9.4f r(mean)
    quietly summarize t4v0187
    display as text "[ANON 0187] t4v0187 mean=" %9.4f r(mean)
    quietly summarize t4v0188
    display as text "[ANON 0188] t4v0188 mean=" %9.4f r(mean)
    quietly summarize t4v0189
    display as text "[ANON 0189] t4v0189 mean=" %9.4f r(mean)
    quietly summarize t4v0190
    display as text "[ANON 0190] t4v0190 mean=" %9.4f r(mean)
    quietly summarize t4v0191
    display as text "[ANON 0191] t4v0191 mean=" %9.4f r(mean)
    quietly summarize t4v0192
    display as text "[ANON 0192] t4v0192 mean=" %9.4f r(mean)
    quietly summarize t4v0193
    display as text "[ANON 0193] t4v0193 mean=" %9.4f r(mean)
    quietly summarize t4v0194
    display as text "[ANON 0194] t4v0194 mean=" %9.4f r(mean)
    quietly summarize t4v0195
    display as text "[ANON 0195] t4v0195 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0195
    quietly summarize t4v0196
    display as text "[ANON 0196] t4v0196 mean=" %9.4f r(mean)
    quietly summarize t4v0197
    display as text "[ANON 0197] t4v0197 mean=" %9.4f r(mean)
    quietly summarize t4v0198
    display as text "[ANON 0198] t4v0198 mean=" %9.4f r(mean)
    quietly summarize t4v0199
    display as text "[ANON 0199] t4v0199 mean=" %9.4f r(mean)
    quietly summarize t4v0200
    display as text "[ANON 0200] t4v0200 mean=" %9.4f r(mean)
    quietly summarize t4v0201
    display as text "[ANON 0201] t4v0201 mean=" %9.4f r(mean)
    quietly summarize t4v0202
    display as text "[ANON 0202] t4v0202 mean=" %9.4f r(mean)
    quietly summarize t4v0203
    display as text "[ANON 0203] t4v0203 mean=" %9.4f r(mean)
    preserve
    keep if !missing(price, mpg, weight)
    count
    restore
    quietly summarize t4v0204
    display as text "[ANON 0204] t4v0204 mean=" %9.4f r(mean)
    quietly summarize t4v0205
    display as text "[ANON 0205] t4v0205 mean=" %9.4f r(mean)
    quietly summarize t4v0206
    display as text "[ANON 0206] t4v0206 mean=" %9.4f r(mean)
    quietly summarize t4v0207
    display as text "[ANON 0207] t4v0207 mean=" %9.4f r(mean)
    quietly summarize t4v0208
    display as text "[ANON 0208] t4v0208 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0208
    quietly summarize t4v0209
    display as text "[ANON 0209] t4v0209 mean=" %9.4f r(mean)
    quietly summarize t4v0210
    display as text "[ANON 0210] t4v0210 mean=" %9.4f r(mean)
    quietly summarize t4v0211
    display as text "[ANON 0211] t4v0211 mean=" %9.4f r(mean)
    quietly summarize t4v0212
    display as text "[ANON 0212] t4v0212 mean=" %9.4f r(mean)
    quietly summarize t4v0213
    display as text "[ANON 0213] t4v0213 mean=" %9.4f r(mean)
    quietly summarize t4v0214
    display as text "[ANON 0214] t4v0214 mean=" %9.4f r(mean)
    quietly summarize t4v0215
    display as text "[ANON 0215] t4v0215 mean=" %9.4f r(mean)
    quietly summarize t4v0216
    display as text "[ANON 0216] t4v0216 mean=" %9.4f r(mean)
    quietly summarize t4v0217
    display as text "[ANON 0217] t4v0217 mean=" %9.4f r(mean)
    quietly summarize t4v0218
    display as text "[ANON 0218] t4v0218 mean=" %9.4f r(mean)
    quietly summarize t4v0219
    display as text "[ANON 0219] t4v0219 mean=" %9.4f r(mean)
    quietly summarize t4v0220
    display as text "[ANON 0220] t4v0220 mean=" %9.4f r(mean)
    quietly summarize t4v0221
    display as text "[ANON 0221] t4v0221 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0221
    quietly summarize t4v0222
    display as text "[ANON 0222] t4v0222 mean=" %9.4f r(mean)
    quietly summarize t4v0223
    display as text "[ANON 0223] t4v0223 mean=" %9.4f r(mean)
    quietly summarize t4v0224
    display as text "[ANON 0224] t4v0224 mean=" %9.4f r(mean)
    quietly summarize t4v0225
    display as text "[ANON 0225] t4v0225 mean=" %9.4f r(mean)
    quietly summarize t4v0226
    display as text "[ANON 0226] t4v0226 mean=" %9.4f r(mean)
    quietly summarize t4v0227
    display as text "[ANON 0227] t4v0227 mean=" %9.4f r(mean)
    quietly summarize t4v0228
    display as text "[ANON 0228] t4v0228 mean=" %9.4f r(mean)
    quietly summarize t4v0229
    display as text "[ANON 0229] t4v0229 mean=" %9.4f r(mean)
    quietly summarize t4v0230
    display as text "[ANON 0230] t4v0230 mean=" %9.4f r(mean)
    quietly summarize t4v0231
    display as text "[ANON 0231] t4v0231 mean=" %9.4f r(mean)
    quietly summarize t4v0232
    display as text "[ANON 0232] t4v0232 mean=" %9.4f r(mean)
    preserve
    keep if !missing(price, mpg, weight)
    count
    restore
    quietly summarize t4v0233
    display as text "[ANON 0233] t4v0233 mean=" %9.4f r(mean)
    quietly summarize t4v0234
    display as text "[ANON 0234] t4v0234 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0234
    quietly summarize t4v0235
    display as text "[ANON 0235] t4v0235 mean=" %9.4f r(mean)
    quietly summarize t4v0236
    display as text "[ANON 0236] t4v0236 mean=" %9.4f r(mean)
    quietly summarize t4v0237
    display as text "[ANON 0237] t4v0237 mean=" %9.4f r(mean)
    quietly summarize t4v0238
    display as text "[ANON 0238] t4v0238 mean=" %9.4f r(mean)
    quietly summarize t4v0239
    display as text "[ANON 0239] t4v0239 mean=" %9.4f r(mean)
    quietly summarize t4v0240
    display as text "[ANON 0240] t4v0240 mean=" %9.4f r(mean)
    quietly summarize t4v0241
    display as text "[ANON 0241] t4v0241 mean=" %9.4f r(mean)
    quietly summarize t4v0242
    display as text "[ANON 0242] t4v0242 mean=" %9.4f r(mean)
    quietly summarize t4v0243
    display as text "[ANON 0243] t4v0243 mean=" %9.4f r(mean)
    quietly summarize t4v0244
    display as text "[ANON 0244] t4v0244 mean=" %9.4f r(mean)
    quietly summarize t4v0245
    display as text "[ANON 0245] t4v0245 mean=" %9.4f r(mean)
    quietly summarize t4v0246
    display as text "[ANON 0246] t4v0246 mean=" %9.4f r(mean)
    quietly summarize t4v0247
    display as text "[ANON 0247] t4v0247 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0247
    quietly summarize t4v0248
    display as text "[ANON 0248] t4v0248 mean=" %9.4f r(mean)
    quietly summarize t4v0249
    display as text "[ANON 0249] t4v0249 mean=" %9.4f r(mean)
    quietly summarize t4v0250
    display as text "[ANON 0250] t4v0250 mean=" %9.4f r(mean)
    quietly summarize t4v0251
    display as text "[ANON 0251] t4v0251 mean=" %9.4f r(mean)
    quietly summarize t4v0252
    display as text "[ANON 0252] t4v0252 mean=" %9.4f r(mean)
    quietly summarize t4v0253
    display as text "[ANON 0253] t4v0253 mean=" %9.4f r(mean)
    quietly summarize t4v0254
    display as text "[ANON 0254] t4v0254 mean=" %9.4f r(mean)
    quietly summarize t4v0255
    display as text "[ANON 0255] t4v0255 mean=" %9.4f r(mean)
    quietly summarize t4v0256
    display as text "[ANON 0256] t4v0256 mean=" %9.4f r(mean)
    quietly summarize t4v0257
    display as text "[ANON 0257] t4v0257 mean=" %9.4f r(mean)
    quietly summarize t4v0258
    display as text "[ANON 0258] t4v0258 mean=" %9.4f r(mean)
    quietly summarize t4v0259
    display as text "[ANON 0259] t4v0259 mean=" %9.4f r(mean)
    quietly summarize t4v0260
    display as text "[ANON 0260] t4v0260 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0260
    quietly summarize t4v0261
    display as text "[ANON 0261] t4v0261 mean=" %9.4f r(mean)
    preserve
    keep if !missing(price, mpg, weight)
    count
    restore
    quietly summarize t4v0262
    display as text "[ANON 0262] t4v0262 mean=" %9.4f r(mean)
    quietly summarize t4v0263
    display as text "[ANON 0263] t4v0263 mean=" %9.4f r(mean)
    quietly summarize t4v0264
    display as text "[ANON 0264] t4v0264 mean=" %9.4f r(mean)
    quietly summarize t4v0265
    display as text "[ANON 0265] t4v0265 mean=" %9.4f r(mean)
    quietly summarize t4v0266
    display as text "[ANON 0266] t4v0266 mean=" %9.4f r(mean)
    quietly summarize t4v0267
    display as text "[ANON 0267] t4v0267 mean=" %9.4f r(mean)
    quietly summarize t4v0268
    display as text "[ANON 0268] t4v0268 mean=" %9.4f r(mean)
    quietly summarize t4v0269
    display as text "[ANON 0269] t4v0269 mean=" %9.4f r(mean)
    quietly summarize t4v0270
    display as text "[ANON 0270] t4v0270 mean=" %9.4f r(mean)
    quietly summarize t4v0271
    display as text "[ANON 0271] t4v0271 mean=" %9.4f r(mean)
    quietly summarize t4v0272
    display as text "[ANON 0272] t4v0272 mean=" %9.4f r(mean)
    quietly summarize t4v0273
    display as text "[ANON 0273] t4v0273 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0273
    quietly summarize t4v0274
    display as text "[ANON 0274] t4v0274 mean=" %9.4f r(mean)
    quietly summarize t4v0275
    display as text "[ANON 0275] t4v0275 mean=" %9.4f r(mean)
    quietly summarize t4v0276
    display as text "[ANON 0276] t4v0276 mean=" %9.4f r(mean)
    quietly summarize t4v0277
    display as text "[ANON 0277] t4v0277 mean=" %9.4f r(mean)
    quietly summarize t4v0278
    display as text "[ANON 0278] t4v0278 mean=" %9.4f r(mean)
    quietly summarize t4v0279
    display as text "[ANON 0279] t4v0279 mean=" %9.4f r(mean)
    quietly summarize t4v0280
    display as text "[ANON 0280] t4v0280 mean=" %9.4f r(mean)
    quietly summarize t4v0281
    display as text "[ANON 0281] t4v0281 mean=" %9.4f r(mean)
    quietly summarize t4v0282
    display as text "[ANON 0282] t4v0282 mean=" %9.4f r(mean)
    quietly summarize t4v0283
    display as text "[ANON 0283] t4v0283 mean=" %9.4f r(mean)
    quietly summarize t4v0284
    display as text "[ANON 0284] t4v0284 mean=" %9.4f r(mean)
    quietly summarize t4v0285
    display as text "[ANON 0285] t4v0285 mean=" %9.4f r(mean)
    quietly summarize t4v0286
    display as text "[ANON 0286] t4v0286 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0286
    quietly summarize t4v0287
    display as text "[ANON 0287] t4v0287 mean=" %9.4f r(mean)
    quietly summarize t4v0288
    display as text "[ANON 0288] t4v0288 mean=" %9.4f r(mean)
    quietly summarize t4v0289
    display as text "[ANON 0289] t4v0289 mean=" %9.4f r(mean)
    quietly summarize t4v0290
    display as text "[ANON 0290] t4v0290 mean=" %9.4f r(mean)
    preserve
    keep if !missing(price, mpg, weight)
    count
    restore
    quietly summarize t4v0291
    display as text "[ANON 0291] t4v0291 mean=" %9.4f r(mean)
    quietly summarize t4v0292
    display as text "[ANON 0292] t4v0292 mean=" %9.4f r(mean)
    quietly summarize t4v0293
    display as text "[ANON 0293] t4v0293 mean=" %9.4f r(mean)
    quietly summarize t4v0294
    display as text "[ANON 0294] t4v0294 mean=" %9.4f r(mean)
    quietly summarize t4v0295
    display as text "[ANON 0295] t4v0295 mean=" %9.4f r(mean)
    quietly summarize t4v0296
    display as text "[ANON 0296] t4v0296 mean=" %9.4f r(mean)
    quietly summarize t4v0297
    display as text "[ANON 0297] t4v0297 mean=" %9.4f r(mean)
    quietly summarize t4v0298
    display as text "[ANON 0298] t4v0298 mean=" %9.4f r(mean)
    quietly summarize t4v0299
    display as text "[ANON 0299] t4v0299 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0299
    quietly summarize t4v0300
    display as text "[ANON 0300] t4v0300 mean=" %9.4f r(mean)
    quietly summarize t4v0301
    display as text "[ANON 0301] t4v0301 mean=" %9.4f r(mean)
    quietly summarize t4v0302
    display as text "[ANON 0302] t4v0302 mean=" %9.4f r(mean)
    quietly summarize t4v0303
    display as text "[ANON 0303] t4v0303 mean=" %9.4f r(mean)
    quietly summarize t4v0304
    display as text "[ANON 0304] t4v0304 mean=" %9.4f r(mean)
    quietly summarize t4v0305
    display as text "[ANON 0305] t4v0305 mean=" %9.4f r(mean)
    quietly summarize t4v0306
    display as text "[ANON 0306] t4v0306 mean=" %9.4f r(mean)
    quietly summarize t4v0307
    display as text "[ANON 0307] t4v0307 mean=" %9.4f r(mean)
    quietly summarize t4v0308
    display as text "[ANON 0308] t4v0308 mean=" %9.4f r(mean)
    quietly summarize t4v0309
    display as text "[ANON 0309] t4v0309 mean=" %9.4f r(mean)
    quietly summarize t4v0310
    display as text "[ANON 0310] t4v0310 mean=" %9.4f r(mean)
    quietly summarize t4v0311
    display as text "[ANON 0311] t4v0311 mean=" %9.4f r(mean)
    quietly summarize t4v0312
    display as text "[ANON 0312] t4v0312 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0312
    quietly summarize t4v0313
    display as text "[ANON 0313] t4v0313 mean=" %9.4f r(mean)
    quietly summarize t4v0314
    display as text "[ANON 0314] t4v0314 mean=" %9.4f r(mean)
    quietly summarize t4v0315
    display as text "[ANON 0315] t4v0315 mean=" %9.4f r(mean)
    quietly summarize t4v0316
    display as text "[ANON 0316] t4v0316 mean=" %9.4f r(mean)
    quietly summarize t4v0317
    display as text "[ANON 0317] t4v0317 mean=" %9.4f r(mean)
    quietly summarize t4v0318
    display as text "[ANON 0318] t4v0318 mean=" %9.4f r(mean)
    quietly summarize t4v0319
    display as text "[ANON 0319] t4v0319 mean=" %9.4f r(mean)
    preserve
    keep if !missing(price, mpg, weight)
    count
    restore
    quietly summarize t4v0320
    display as text "[ANON 0320] t4v0320 mean=" %9.4f r(mean)
    quietly summarize t4v0321
    display as text "[ANON 0321] t4v0321 mean=" %9.4f r(mean)
    quietly summarize t4v0322
    display as text "[ANON 0322] t4v0322 mean=" %9.4f r(mean)
    quietly summarize t4v0323
    display as text "[ANON 0323] t4v0323 mean=" %9.4f r(mean)
    quietly summarize t4v0324
    display as text "[ANON 0324] t4v0324 mean=" %9.4f r(mean)
    quietly summarize t4v0325
    display as text "[ANON 0325] t4v0325 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0325
    quietly summarize t4v0326
    display as text "[ANON 0326] t4v0326 mean=" %9.4f r(mean)
    quietly summarize t4v0327
    display as text "[ANON 0327] t4v0327 mean=" %9.4f r(mean)
    quietly summarize t4v0328
    display as text "[ANON 0328] t4v0328 mean=" %9.4f r(mean)
    quietly summarize t4v0329
    display as text "[ANON 0329] t4v0329 mean=" %9.4f r(mean)
    quietly summarize t4v0330
    display as text "[ANON 0330] t4v0330 mean=" %9.4f r(mean)
    quietly summarize t4v0331
    display as text "[ANON 0331] t4v0331 mean=" %9.4f r(mean)
    quietly summarize t4v0332
    display as text "[ANON 0332] t4v0332 mean=" %9.4f r(mean)
    quietly summarize t4v0333
    display as text "[ANON 0333] t4v0333 mean=" %9.4f r(mean)
    quietly summarize t4v0334
    display as text "[ANON 0334] t4v0334 mean=" %9.4f r(mean)
    quietly summarize t4v0335
    display as text "[ANON 0335] t4v0335 mean=" %9.4f r(mean)
    quietly summarize t4v0336
    display as text "[ANON 0336] t4v0336 mean=" %9.4f r(mean)
    quietly summarize t4v0337
    display as text "[ANON 0337] t4v0337 mean=" %9.4f r(mean)
    quietly summarize t4v0338
    display as text "[ANON 0338] t4v0338 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0338
    quietly summarize t4v0339
    display as text "[ANON 0339] t4v0339 mean=" %9.4f r(mean)
    quietly summarize t4v0340
    display as text "[ANON 0340] t4v0340 mean=" %9.4f r(mean)
    quietly summarize t4v0341
    display as text "[ANON 0341] t4v0341 mean=" %9.4f r(mean)
    quietly summarize t4v0342
    display as text "[ANON 0342] t4v0342 mean=" %9.4f r(mean)
    quietly summarize t4v0343
    display as text "[ANON 0343] t4v0343 mean=" %9.4f r(mean)
    quietly summarize t4v0344
    display as text "[ANON 0344] t4v0344 mean=" %9.4f r(mean)
    quietly summarize t4v0345
    display as text "[ANON 0345] t4v0345 mean=" %9.4f r(mean)
    quietly summarize t4v0346
    display as text "[ANON 0346] t4v0346 mean=" %9.4f r(mean)
    quietly summarize t4v0347
    display as text "[ANON 0347] t4v0347 mean=" %9.4f r(mean)
    quietly summarize t4v0348
    display as text "[ANON 0348] t4v0348 mean=" %9.4f r(mean)
    preserve
    keep if !missing(price, mpg, weight)
    count
    restore
    quietly summarize t4v0349
    display as text "[ANON 0349] t4v0349 mean=" %9.4f r(mean)
    quietly summarize t4v0350
    display as text "[ANON 0350] t4v0350 mean=" %9.4f r(mean)
    quietly summarize t4v0351
    display as text "[ANON 0351] t4v0351 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0351
    quietly summarize t4v0352
    display as text "[ANON 0352] t4v0352 mean=" %9.4f r(mean)
    quietly summarize t4v0353
    display as text "[ANON 0353] t4v0353 mean=" %9.4f r(mean)
    quietly summarize t4v0354
    display as text "[ANON 0354] t4v0354 mean=" %9.4f r(mean)
    quietly summarize t4v0355
    display as text "[ANON 0355] t4v0355 mean=" %9.4f r(mean)
    quietly summarize t4v0356
    display as text "[ANON 0356] t4v0356 mean=" %9.4f r(mean)
    quietly summarize t4v0357
    display as text "[ANON 0357] t4v0357 mean=" %9.4f r(mean)
    quietly summarize t4v0358
    display as text "[ANON 0358] t4v0358 mean=" %9.4f r(mean)
    quietly summarize t4v0359
    display as text "[ANON 0359] t4v0359 mean=" %9.4f r(mean)
    quietly summarize t4v0360
    display as text "[ANON 0360] t4v0360 mean=" %9.4f r(mean)
    quietly summarize t4v0361
    display as text "[ANON 0361] t4v0361 mean=" %9.4f r(mean)
    quietly summarize t4v0362
    display as text "[ANON 0362] t4v0362 mean=" %9.4f r(mean)
    quietly summarize t4v0363
    display as text "[ANON 0363] t4v0363 mean=" %9.4f r(mean)
    quietly summarize t4v0364
    display as text "[ANON 0364] t4v0364 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0364
    quietly summarize t4v0365
    display as text "[ANON 0365] t4v0365 mean=" %9.4f r(mean)
    quietly summarize t4v0366
    display as text "[ANON 0366] t4v0366 mean=" %9.4f r(mean)
    quietly summarize t4v0367
    display as text "[ANON 0367] t4v0367 mean=" %9.4f r(mean)
    quietly summarize t4v0368
    display as text "[ANON 0368] t4v0368 mean=" %9.4f r(mean)
    quietly summarize t4v0369
    display as text "[ANON 0369] t4v0369 mean=" %9.4f r(mean)
    quietly summarize t4v0370
    display as text "[ANON 0370] t4v0370 mean=" %9.4f r(mean)
    quietly summarize t4v0371
    display as text "[ANON 0371] t4v0371 mean=" %9.4f r(mean)
    quietly summarize t4v0372
    display as text "[ANON 0372] t4v0372 mean=" %9.4f r(mean)
    quietly summarize t4v0373
    display as text "[ANON 0373] t4v0373 mean=" %9.4f r(mean)
    quietly summarize t4v0374
    display as text "[ANON 0374] t4v0374 mean=" %9.4f r(mean)
    quietly summarize t4v0375
    display as text "[ANON 0375] t4v0375 mean=" %9.4f r(mean)
    quietly summarize t4v0376
    display as text "[ANON 0376] t4v0376 mean=" %9.4f r(mean)
    quietly summarize t4v0377
    display as text "[ANON 0377] t4v0377 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0377
    preserve
    keep if !missing(price, mpg, weight)
    count
    restore
    quietly summarize t4v0378
    display as text "[ANON 0378] t4v0378 mean=" %9.4f r(mean)
    quietly summarize t4v0379
    display as text "[ANON 0379] t4v0379 mean=" %9.4f r(mean)
    quietly summarize t4v0380
    display as text "[ANON 0380] t4v0380 mean=" %9.4f r(mean)
    quietly summarize t4v0381
    display as text "[ANON 0381] t4v0381 mean=" %9.4f r(mean)
    quietly summarize t4v0382
    display as text "[ANON 0382] t4v0382 mean=" %9.4f r(mean)
    quietly summarize t4v0383
    display as text "[ANON 0383] t4v0383 mean=" %9.4f r(mean)
    quietly summarize t4v0384
    display as text "[ANON 0384] t4v0384 mean=" %9.4f r(mean)
    quietly summarize t4v0385
    display as text "[ANON 0385] t4v0385 mean=" %9.4f r(mean)
    quietly summarize t4v0386
    display as text "[ANON 0386] t4v0386 mean=" %9.4f r(mean)
    quietly summarize t4v0387
    display as text "[ANON 0387] t4v0387 mean=" %9.4f r(mean)
    quietly summarize t4v0388
    display as text "[ANON 0388] t4v0388 mean=" %9.4f r(mean)
    quietly summarize t4v0389
    display as text "[ANON 0389] t4v0389 mean=" %9.4f r(mean)
    quietly summarize t4v0390
    display as text "[ANON 0390] t4v0390 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0390
    quietly summarize t4v0391
    display as text "[ANON 0391] t4v0391 mean=" %9.4f r(mean)
    quietly summarize t4v0392
    display as text "[ANON 0392] t4v0392 mean=" %9.4f r(mean)
    quietly summarize t4v0393
    display as text "[ANON 0393] t4v0393 mean=" %9.4f r(mean)
    quietly summarize t4v0394
    display as text "[ANON 0394] t4v0394 mean=" %9.4f r(mean)
    quietly summarize t4v0395
    display as text "[ANON 0395] t4v0395 mean=" %9.4f r(mean)
    quietly summarize t4v0396
    display as text "[ANON 0396] t4v0396 mean=" %9.4f r(mean)
    quietly summarize t4v0397
    display as text "[ANON 0397] t4v0397 mean=" %9.4f r(mean)
    quietly summarize t4v0398
    display as text "[ANON 0398] t4v0398 mean=" %9.4f r(mean)
    quietly summarize t4v0399
    display as text "[ANON 0399] t4v0399 mean=" %9.4f r(mean)
    quietly summarize t4v0400
    display as text "[ANON 0400] t4v0400 mean=" %9.4f r(mean)
    quietly summarize t4v0401
    display as text "[ANON 0401] t4v0401 mean=" %9.4f r(mean)
    quietly summarize t4v0402
    display as text "[ANON 0402] t4v0402 mean=" %9.4f r(mean)
    quietly summarize t4v0403
    display as text "[ANON 0403] t4v0403 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0403
    quietly summarize t4v0404
    display as text "[ANON 0404] t4v0404 mean=" %9.4f r(mean)
    quietly summarize t4v0405
    display as text "[ANON 0405] t4v0405 mean=" %9.4f r(mean)
    quietly summarize t4v0406
    display as text "[ANON 0406] t4v0406 mean=" %9.4f r(mean)
    preserve
    keep if !missing(price, mpg, weight)
    count
    restore
    quietly summarize t4v0407
    display as text "[ANON 0407] t4v0407 mean=" %9.4f r(mean)
    quietly summarize t4v0408
    display as text "[ANON 0408] t4v0408 mean=" %9.4f r(mean)
    quietly summarize t4v0409
    display as text "[ANON 0409] t4v0409 mean=" %9.4f r(mean)
    quietly summarize t4v0410
    display as text "[ANON 0410] t4v0410 mean=" %9.4f r(mean)
    quietly summarize t4v0411
    display as text "[ANON 0411] t4v0411 mean=" %9.4f r(mean)
    quietly summarize t4v0412
    display as text "[ANON 0412] t4v0412 mean=" %9.4f r(mean)
    quietly summarize t4v0413
    display as text "[ANON 0413] t4v0413 mean=" %9.4f r(mean)
    quietly summarize t4v0414
    display as text "[ANON 0414] t4v0414 mean=" %9.4f r(mean)
    quietly summarize t4v0415
    display as text "[ANON 0415] t4v0415 mean=" %9.4f r(mean)
    quietly summarize t4v0416
    display as text "[ANON 0416] t4v0416 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0416
    quietly summarize t4v0417
    display as text "[ANON 0417] t4v0417 mean=" %9.4f r(mean)
    quietly summarize t4v0418
    display as text "[ANON 0418] t4v0418 mean=" %9.4f r(mean)
    quietly summarize t4v0419
    display as text "[ANON 0419] t4v0419 mean=" %9.4f r(mean)
    quietly summarize t4v0420
    display as text "[ANON 0420] t4v0420 mean=" %9.4f r(mean)
    quietly summarize t4v0421
    display as text "[ANON 0421] t4v0421 mean=" %9.4f r(mean)
    quietly summarize t4v0422
    display as text "[ANON 0422] t4v0422 mean=" %9.4f r(mean)
    quietly summarize t4v0423
    display as text "[ANON 0423] t4v0423 mean=" %9.4f r(mean)
    quietly summarize t4v0424
    display as text "[ANON 0424] t4v0424 mean=" %9.4f r(mean)
    quietly summarize t4v0425
    display as text "[ANON 0425] t4v0425 mean=" %9.4f r(mean)
    quietly summarize t4v0426
    display as text "[ANON 0426] t4v0426 mean=" %9.4f r(mean)
    quietly summarize t4v0427
    display as text "[ANON 0427] t4v0427 mean=" %9.4f r(mean)
    quietly summarize t4v0428
    display as text "[ANON 0428] t4v0428 mean=" %9.4f r(mean)
    quietly summarize t4v0429
    display as text "[ANON 0429] t4v0429 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0429
    quietly summarize t4v0430
    display as text "[ANON 0430] t4v0430 mean=" %9.4f r(mean)
    quietly summarize t4v0431
    display as text "[ANON 0431] t4v0431 mean=" %9.4f r(mean)
    quietly summarize t4v0432
    display as text "[ANON 0432] t4v0432 mean=" %9.4f r(mean)
    quietly summarize t4v0433
    display as text "[ANON 0433] t4v0433 mean=" %9.4f r(mean)
    quietly summarize t4v0434
    display as text "[ANON 0434] t4v0434 mean=" %9.4f r(mean)
    quietly summarize t4v0435
    display as text "[ANON 0435] t4v0435 mean=" %9.4f r(mean)
    preserve
    keep if !missing(price, mpg, weight)
    count
    restore
    quietly summarize t4v0436
    display as text "[ANON 0436] t4v0436 mean=" %9.4f r(mean)
    quietly summarize t4v0437
    display as text "[ANON 0437] t4v0437 mean=" %9.4f r(mean)
    quietly summarize t4v0438
    display as text "[ANON 0438] t4v0438 mean=" %9.4f r(mean)
    quietly summarize t4v0439
    display as text "[ANON 0439] t4v0439 mean=" %9.4f r(mean)
    quietly summarize t4v0440
    display as text "[ANON 0440] t4v0440 mean=" %9.4f r(mean)
    quietly summarize t4v0441
    display as text "[ANON 0441] t4v0441 mean=" %9.4f r(mean)
    quietly summarize t4v0442
    display as text "[ANON 0442] t4v0442 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0442
    quietly summarize t4v0443
    display as text "[ANON 0443] t4v0443 mean=" %9.4f r(mean)
    quietly summarize t4v0444
    display as text "[ANON 0444] t4v0444 mean=" %9.4f r(mean)
    quietly summarize t4v0445
    display as text "[ANON 0445] t4v0445 mean=" %9.4f r(mean)
    quietly summarize t4v0446
    display as text "[ANON 0446] t4v0446 mean=" %9.4f r(mean)
    quietly summarize t4v0447
    display as text "[ANON 0447] t4v0447 mean=" %9.4f r(mean)
    quietly summarize t4v0448
    display as text "[ANON 0448] t4v0448 mean=" %9.4f r(mean)
    quietly summarize t4v0449
    display as text "[ANON 0449] t4v0449 mean=" %9.4f r(mean)
    quietly summarize t4v0450
    display as text "[ANON 0450] t4v0450 mean=" %9.4f r(mean)
    quietly summarize t4v0451
    display as text "[ANON 0451] t4v0451 mean=" %9.4f r(mean)
    quietly summarize t4v0452
    display as text "[ANON 0452] t4v0452 mean=" %9.4f r(mean)
    quietly summarize t4v0453
    display as text "[ANON 0453] t4v0453 mean=" %9.4f r(mean)
    quietly summarize t4v0454
    display as text "[ANON 0454] t4v0454 mean=" %9.4f r(mean)
    quietly summarize t4v0455
    display as text "[ANON 0455] t4v0455 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0455
    quietly summarize t4v0456
    display as text "[ANON 0456] t4v0456 mean=" %9.4f r(mean)
    quietly summarize t4v0457
    display as text "[ANON 0457] t4v0457 mean=" %9.4f r(mean)
    quietly summarize t4v0458
    display as text "[ANON 0458] t4v0458 mean=" %9.4f r(mean)
    quietly summarize t4v0459
    display as text "[ANON 0459] t4v0459 mean=" %9.4f r(mean)
    quietly summarize t4v0460
    display as text "[ANON 0460] t4v0460 mean=" %9.4f r(mean)
    quietly summarize t4v0461
    display as text "[ANON 0461] t4v0461 mean=" %9.4f r(mean)
    quietly summarize t4v0462
    display as text "[ANON 0462] t4v0462 mean=" %9.4f r(mean)
    quietly summarize t4v0463
    display as text "[ANON 0463] t4v0463 mean=" %9.4f r(mean)
    quietly summarize t4v0464
    display as text "[ANON 0464] t4v0464 mean=" %9.4f r(mean)
    preserve
    keep if !missing(price, mpg, weight)
    count
    restore
    quietly summarize t4v0465
    display as text "[ANON 0465] t4v0465 mean=" %9.4f r(mean)
    quietly summarize t4v0466
    display as text "[ANON 0466] t4v0466 mean=" %9.4f r(mean)
    quietly summarize t4v0467
    display as text "[ANON 0467] t4v0467 mean=" %9.4f r(mean)
    quietly summarize t4v0468
    display as text "[ANON 0468] t4v0468 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0468
    quietly summarize t4v0469
    display as text "[ANON 0469] t4v0469 mean=" %9.4f r(mean)
    quietly summarize t4v0470
    display as text "[ANON 0470] t4v0470 mean=" %9.4f r(mean)
    quietly summarize t4v0471
    display as text "[ANON 0471] t4v0471 mean=" %9.4f r(mean)
    quietly summarize t4v0472
    display as text "[ANON 0472] t4v0472 mean=" %9.4f r(mean)
    quietly summarize t4v0473
    display as text "[ANON 0473] t4v0473 mean=" %9.4f r(mean)
    quietly summarize t4v0474
    display as text "[ANON 0474] t4v0474 mean=" %9.4f r(mean)
    quietly summarize t4v0475
    display as text "[ANON 0475] t4v0475 mean=" %9.4f r(mean)
    quietly summarize t4v0476
    display as text "[ANON 0476] t4v0476 mean=" %9.4f r(mean)
    quietly summarize t4v0477
    display as text "[ANON 0477] t4v0477 mean=" %9.4f r(mean)
    quietly summarize t4v0478
    display as text "[ANON 0478] t4v0478 mean=" %9.4f r(mean)
    quietly summarize t4v0479
    display as text "[ANON 0479] t4v0479 mean=" %9.4f r(mean)
    quietly summarize t4v0480
    display as text "[ANON 0480] t4v0480 mean=" %9.4f r(mean)
    quietly summarize t4v0481
    display as text "[ANON 0481] t4v0481 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0481
    quietly summarize t4v0482
    display as text "[ANON 0482] t4v0482 mean=" %9.4f r(mean)
    quietly summarize t4v0483
    display as text "[ANON 0483] t4v0483 mean=" %9.4f r(mean)
    quietly summarize t4v0484
    display as text "[ANON 0484] t4v0484 mean=" %9.4f r(mean)
    quietly summarize t4v0485
    display as text "[ANON 0485] t4v0485 mean=" %9.4f r(mean)
    quietly summarize t4v0486
    display as text "[ANON 0486] t4v0486 mean=" %9.4f r(mean)
    quietly summarize t4v0487
    display as text "[ANON 0487] t4v0487 mean=" %9.4f r(mean)
    quietly summarize t4v0488
    display as text "[ANON 0488] t4v0488 mean=" %9.4f r(mean)
    quietly summarize t4v0489
    display as text "[ANON 0489] t4v0489 mean=" %9.4f r(mean)
    quietly summarize t4v0490
    display as text "[ANON 0490] t4v0490 mean=" %9.4f r(mean)
    quietly summarize t4v0491
    display as text "[ANON 0491] t4v0491 mean=" %9.4f r(mean)
    quietly summarize t4v0492
    display as text "[ANON 0492] t4v0492 mean=" %9.4f r(mean)
    quietly summarize t4v0493
    display as text "[ANON 0493] t4v0493 mean=" %9.4f r(mean)
    preserve
    keep if !missing(price, mpg, weight)
    count
    restore
    quietly summarize t4v0494
    display as text "[ANON 0494] t4v0494 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0494
    quietly summarize t4v0495
    display as text "[ANON 0495] t4v0495 mean=" %9.4f r(mean)
    quietly summarize t4v0496
    display as text "[ANON 0496] t4v0496 mean=" %9.4f r(mean)
    quietly summarize t4v0497
    display as text "[ANON 0497] t4v0497 mean=" %9.4f r(mean)
    quietly summarize t4v0498
    display as text "[ANON 0498] t4v0498 mean=" %9.4f r(mean)
    quietly summarize t4v0499
    display as text "[ANON 0499] t4v0499 mean=" %9.4f r(mean)
    quietly summarize t4v0500
    display as text "[ANON 0500] t4v0500 mean=" %9.4f r(mean)
    quietly summarize t4v0501
    display as text "[ANON 0501] t4v0501 mean=" %9.4f r(mean)
    quietly summarize t4v0502
    display as text "[ANON 0502] t4v0502 mean=" %9.4f r(mean)
    quietly summarize t4v0503
    display as text "[ANON 0503] t4v0503 mean=" %9.4f r(mean)
    quietly summarize t4v0504
    display as text "[ANON 0504] t4v0504 mean=" %9.4f r(mean)
    quietly summarize t4v0505
    display as text "[ANON 0505] t4v0505 mean=" %9.4f r(mean)
    quietly summarize t4v0506
    display as text "[ANON 0506] t4v0506 mean=" %9.4f r(mean)
    quietly summarize t4v0507
    display as text "[ANON 0507] t4v0507 mean=" %9.4f r(mean)
    quietly regress price mpg weight t4v0507
    quietly summarize t4v0508
    display as text "[ANON 0508] t4v0508 mean=" %9.4f r(mean)
    quietly summarize t4v0509
    display as text "[ANON 0509] t4v0509 mean=" %9.4f r(mean)
    quietly summarize t4v0510
    display as text "[ANON 0510] t4v0510 mean=" %9.4f r(mean)
    quietly summarize t4v0511
    display as text "[ANON 0511] t4v0511 mean=" %9.4f r(mean)
    quietly summarize t4v0512
    display as text "[ANON 0512] t4v0512 mean=" %9.4f r(mean)
    quietly summarize t4v0513
    display as text "[ANON 0513] t4v0513 mean=" %9.4f r(mean)
    quietly summarize t4v0514
    display as text "[ANON 0514] t4v0514 mean=" %9.4f r(mean)
    quietly summarize t4v0515
    display as text "[ANON 0515] t4v0515 mean=" %9.4f r(mean)
    quietly summarize t4v0516
    display as text "[ANON 0516] t4v0516 mean=" %9.4f r(mean)
    quietly summarize t4v0517
    display as text "[ANON 0517] t4v0517 mean=" %9.4f r(mean)
    quietly summarize t4v0518
    display as text "[ANON 0518] t4v0518 mean=" %9.4f r(mean)
    quietly summarize t4v0519
    display as text "[ANON 0519] t4v0519 mean=" %9.4f r(mean)
    use `anonbase', clear
}
display as result "<<< DONE Section 5: large anonymous brace block"
// #endregion ===== Section 5: large anonymous brace block =====


// #region ===== Section 6: diagnostics and table output =====
display as text ">>> START Section 6: diagnostics and table output"
tab1 foreign price_quart mpg_tert weight_tert group_id high_price high_mpg heavy_car
tabstat price mpg weight length turn displacement gear_ratio, stat(n mean sd min p50 max) columns(statistics)
correlate price mpg weight length turn displacement gear_ratio
putexcel set "$docdir/taught_task4_summary.xlsx", replace
putexcel A1=("metric") B1=("value")
quietly summarize price
putexcel A2=("price_mean") B2=(r(mean))
putexcel C2=("price_sd") D2=(r(sd))
quietly summarize mpg
putexcel A3=("mpg_mean") B3=(r(mean))
putexcel C3=("mpg_sd") D3=(r(sd))
quietly summarize weight
putexcel A4=("weight_mean") B4=(r(mean))
putexcel C4=("weight_sd") D4=(r(sd))
quietly summarize length
putexcel A5=("length_mean") B5=(r(mean))
putexcel C5=("length_sd") D5=(r(sd))
quietly summarize turn
putexcel A6=("turn_mean") B6=(r(mean))
putexcel C6=("turn_sd") D6=(r(sd))
quietly summarize displacement
putexcel A7=("displacement_mean") B7=(r(mean))
putexcel C7=("displacement_sd") D7=(r(sd))
quietly summarize gear_ratio
putexcel A8=("gear_ratio_mean") B8=(r(mean))
putexcel C8=("gear_ratio_sd") D8=(r(sd))
quietly summarize price_ln
putexcel A9=("price_ln_mean") B9=(r(mean))
putexcel C9=("price_ln_sd") D9=(r(sd))
quietly summarize weight_ton
putexcel A10=("weight_ton_mean") B10=(r(mean))
putexcel C10=("weight_ton_sd") D10=(r(sd))
quietly summarize price_per_lb
putexcel A11=("price_per_lb_mean") B11=(r(mean))
putexcel C11=("price_per_lb_sd") D11=(r(sd))
quietly summarize t4v0001
display as text "[DIAG 0001] t4v0001 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0002
display as text "[DIAG 0002] t4v0002 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0003
display as text "[DIAG 0003] t4v0003 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0004
display as text "[DIAG 0004] t4v0004 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0005
display as text "[DIAG 0005] t4v0005 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0006
display as text "[DIAG 0006] t4v0006 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0007
display as text "[DIAG 0007] t4v0007 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0008
display as text "[DIAG 0008] t4v0008 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0009
display as text "[DIAG 0009] t4v0009 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0010
display as text "[DIAG 0010] t4v0010 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0011
display as text "[DIAG 0011] t4v0011 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0012
display as text "[DIAG 0012] t4v0012 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0013
display as text "[DIAG 0013] t4v0013 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0014
display as text "[DIAG 0014] t4v0014 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0015
display as text "[DIAG 0015] t4v0015 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0016
display as text "[DIAG 0016] t4v0016 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0017
display as text "[DIAG 0017] t4v0017 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0018
display as text "[DIAG 0018] t4v0018 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0019
display as text "[DIAG 0019] t4v0019 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0020
display as text "[DIAG 0020] t4v0020 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0021
display as text "[DIAG 0021] t4v0021 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0022
display as text "[DIAG 0022] t4v0022 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0023
display as text "[DIAG 0023] t4v0023 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0024
display as text "[DIAG 0024] t4v0024 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0025
display as text "[DIAG 0025] t4v0025 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0026
display as text "[DIAG 0026] t4v0026 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0027
display as text "[DIAG 0027] t4v0027 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0028
display as text "[DIAG 0028] t4v0028 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0029
display as text "[DIAG 0029] t4v0029 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0030
display as text "[DIAG 0030] t4v0030 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0031
display as text "[DIAG 0031] t4v0031 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0032
display as text "[DIAG 0032] t4v0032 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0033
display as text "[DIAG 0033] t4v0033 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0034
display as text "[DIAG 0034] t4v0034 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0035
display as text "[DIAG 0035] t4v0035 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0036
display as text "[DIAG 0036] t4v0036 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0037
display as text "[DIAG 0037] t4v0037 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0038
display as text "[DIAG 0038] t4v0038 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0039
display as text "[DIAG 0039] t4v0039 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0040
display as text "[DIAG 0040] t4v0040 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0041
display as text "[DIAG 0041] t4v0041 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0042
display as text "[DIAG 0042] t4v0042 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0043
display as text "[DIAG 0043] t4v0043 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0044
display as text "[DIAG 0044] t4v0044 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0045
display as text "[DIAG 0045] t4v0045 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0046
display as text "[DIAG 0046] t4v0046 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0047
display as text "[DIAG 0047] t4v0047 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0048
display as text "[DIAG 0048] t4v0048 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0049
display as text "[DIAG 0049] t4v0049 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0050
display as text "[DIAG 0050] t4v0050 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0051
display as text "[DIAG 0051] t4v0051 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0052
display as text "[DIAG 0052] t4v0052 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0053
display as text "[DIAG 0053] t4v0053 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0054
display as text "[DIAG 0054] t4v0054 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0055
display as text "[DIAG 0055] t4v0055 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0056
display as text "[DIAG 0056] t4v0056 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0057
display as text "[DIAG 0057] t4v0057 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0058
display as text "[DIAG 0058] t4v0058 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0059
display as text "[DIAG 0059] t4v0059 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0060
display as text "[DIAG 0060] t4v0060 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0061
display as text "[DIAG 0061] t4v0061 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0062
display as text "[DIAG 0062] t4v0062 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0063
display as text "[DIAG 0063] t4v0063 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0064
display as text "[DIAG 0064] t4v0064 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0065
display as text "[DIAG 0065] t4v0065 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0066
display as text "[DIAG 0066] t4v0066 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0067
display as text "[DIAG 0067] t4v0067 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0068
display as text "[DIAG 0068] t4v0068 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0069
display as text "[DIAG 0069] t4v0069 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0070
display as text "[DIAG 0070] t4v0070 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0071
display as text "[DIAG 0071] t4v0071 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0072
display as text "[DIAG 0072] t4v0072 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0073
display as text "[DIAG 0073] t4v0073 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0074
display as text "[DIAG 0074] t4v0074 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0075
display as text "[DIAG 0075] t4v0075 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0076
display as text "[DIAG 0076] t4v0076 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0077
display as text "[DIAG 0077] t4v0077 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0078
display as text "[DIAG 0078] t4v0078 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0079
display as text "[DIAG 0079] t4v0079 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0080
display as text "[DIAG 0080] t4v0080 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0081
display as text "[DIAG 0081] t4v0081 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0082
display as text "[DIAG 0082] t4v0082 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0083
display as text "[DIAG 0083] t4v0083 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0084
display as text "[DIAG 0084] t4v0084 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0085
display as text "[DIAG 0085] t4v0085 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0086
display as text "[DIAG 0086] t4v0086 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0087
display as text "[DIAG 0087] t4v0087 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0088
display as text "[DIAG 0088] t4v0088 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0089
display as text "[DIAG 0089] t4v0089 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0090
display as text "[DIAG 0090] t4v0090 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0091
display as text "[DIAG 0091] t4v0091 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0092
display as text "[DIAG 0092] t4v0092 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0093
display as text "[DIAG 0093] t4v0093 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0094
display as text "[DIAG 0094] t4v0094 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0095
display as text "[DIAG 0095] t4v0095 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0096
display as text "[DIAG 0096] t4v0096 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0097
display as text "[DIAG 0097] t4v0097 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0098
display as text "[DIAG 0098] t4v0098 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0099
display as text "[DIAG 0099] t4v0099 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0100
display as text "[DIAG 0100] t4v0100 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0101
display as text "[DIAG 0101] t4v0101 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0102
display as text "[DIAG 0102] t4v0102 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0103
display as text "[DIAG 0103] t4v0103 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0104
display as text "[DIAG 0104] t4v0104 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0105
display as text "[DIAG 0105] t4v0105 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0106
display as text "[DIAG 0106] t4v0106 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0107
display as text "[DIAG 0107] t4v0107 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0108
display as text "[DIAG 0108] t4v0108 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0109
display as text "[DIAG 0109] t4v0109 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0110
display as text "[DIAG 0110] t4v0110 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0111
display as text "[DIAG 0111] t4v0111 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0112
display as text "[DIAG 0112] t4v0112 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0113
display as text "[DIAG 0113] t4v0113 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0114
display as text "[DIAG 0114] t4v0114 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0115
display as text "[DIAG 0115] t4v0115 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0116
display as text "[DIAG 0116] t4v0116 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0117
display as text "[DIAG 0117] t4v0117 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0118
display as text "[DIAG 0118] t4v0118 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0119
display as text "[DIAG 0119] t4v0119 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0120
display as text "[DIAG 0120] t4v0120 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0121
display as text "[DIAG 0121] t4v0121 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0122
display as text "[DIAG 0122] t4v0122 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0123
display as text "[DIAG 0123] t4v0123 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0124
display as text "[DIAG 0124] t4v0124 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0125
display as text "[DIAG 0125] t4v0125 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0126
display as text "[DIAG 0126] t4v0126 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0127
display as text "[DIAG 0127] t4v0127 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0128
display as text "[DIAG 0128] t4v0128 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0129
display as text "[DIAG 0129] t4v0129 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0130
display as text "[DIAG 0130] t4v0130 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0131
display as text "[DIAG 0131] t4v0131 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0132
display as text "[DIAG 0132] t4v0132 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0133
display as text "[DIAG 0133] t4v0133 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0134
display as text "[DIAG 0134] t4v0134 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0135
display as text "[DIAG 0135] t4v0135 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0136
display as text "[DIAG 0136] t4v0136 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0137
display as text "[DIAG 0137] t4v0137 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0138
display as text "[DIAG 0138] t4v0138 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0139
display as text "[DIAG 0139] t4v0139 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0140
display as text "[DIAG 0140] t4v0140 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0141
display as text "[DIAG 0141] t4v0141 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0142
display as text "[DIAG 0142] t4v0142 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0143
display as text "[DIAG 0143] t4v0143 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0144
display as text "[DIAG 0144] t4v0144 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0145
display as text "[DIAG 0145] t4v0145 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0146
display as text "[DIAG 0146] t4v0146 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0147
display as text "[DIAG 0147] t4v0147 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0148
display as text "[DIAG 0148] t4v0148 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0149
display as text "[DIAG 0149] t4v0149 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0150
display as text "[DIAG 0150] t4v0150 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0151
display as text "[DIAG 0151] t4v0151 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0152
display as text "[DIAG 0152] t4v0152 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0153
display as text "[DIAG 0153] t4v0153 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0154
display as text "[DIAG 0154] t4v0154 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0155
display as text "[DIAG 0155] t4v0155 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0156
display as text "[DIAG 0156] t4v0156 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0157
display as text "[DIAG 0157] t4v0157 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0158
display as text "[DIAG 0158] t4v0158 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0159
display as text "[DIAG 0159] t4v0159 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0160
display as text "[DIAG 0160] t4v0160 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0161
display as text "[DIAG 0161] t4v0161 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0162
display as text "[DIAG 0162] t4v0162 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0163
display as text "[DIAG 0163] t4v0163 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0164
display as text "[DIAG 0164] t4v0164 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0165
display as text "[DIAG 0165] t4v0165 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0166
display as text "[DIAG 0166] t4v0166 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0167
display as text "[DIAG 0167] t4v0167 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0168
display as text "[DIAG 0168] t4v0168 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0169
display as text "[DIAG 0169] t4v0169 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0170
display as text "[DIAG 0170] t4v0170 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0171
display as text "[DIAG 0171] t4v0171 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0172
display as text "[DIAG 0172] t4v0172 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0173
display as text "[DIAG 0173] t4v0173 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0174
display as text "[DIAG 0174] t4v0174 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0175
display as text "[DIAG 0175] t4v0175 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0176
display as text "[DIAG 0176] t4v0176 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0177
display as text "[DIAG 0177] t4v0177 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0178
display as text "[DIAG 0178] t4v0178 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0179
display as text "[DIAG 0179] t4v0179 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0180
display as text "[DIAG 0180] t4v0180 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0181
display as text "[DIAG 0181] t4v0181 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0182
display as text "[DIAG 0182] t4v0182 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0183
display as text "[DIAG 0183] t4v0183 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0184
display as text "[DIAG 0184] t4v0184 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0185
display as text "[DIAG 0185] t4v0185 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0186
display as text "[DIAG 0186] t4v0186 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0187
display as text "[DIAG 0187] t4v0187 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0188
display as text "[DIAG 0188] t4v0188 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0189
display as text "[DIAG 0189] t4v0189 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0190
display as text "[DIAG 0190] t4v0190 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0191
display as text "[DIAG 0191] t4v0191 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0192
display as text "[DIAG 0192] t4v0192 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0193
display as text "[DIAG 0193] t4v0193 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0194
display as text "[DIAG 0194] t4v0194 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0195
display as text "[DIAG 0195] t4v0195 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0196
display as text "[DIAG 0196] t4v0196 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0197
display as text "[DIAG 0197] t4v0197 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0198
display as text "[DIAG 0198] t4v0198 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0199
display as text "[DIAG 0199] t4v0199 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0200
display as text "[DIAG 0200] t4v0200 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0201
display as text "[DIAG 0201] t4v0201 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0202
display as text "[DIAG 0202] t4v0202 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0203
display as text "[DIAG 0203] t4v0203 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0204
display as text "[DIAG 0204] t4v0204 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0205
display as text "[DIAG 0205] t4v0205 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0206
display as text "[DIAG 0206] t4v0206 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0207
display as text "[DIAG 0207] t4v0207 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0208
display as text "[DIAG 0208] t4v0208 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0209
display as text "[DIAG 0209] t4v0209 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0210
display as text "[DIAG 0210] t4v0210 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0211
display as text "[DIAG 0211] t4v0211 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0212
display as text "[DIAG 0212] t4v0212 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0213
display as text "[DIAG 0213] t4v0213 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0214
display as text "[DIAG 0214] t4v0214 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0215
display as text "[DIAG 0215] t4v0215 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0216
display as text "[DIAG 0216] t4v0216 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0217
display as text "[DIAG 0217] t4v0217 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0218
display as text "[DIAG 0218] t4v0218 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0219
display as text "[DIAG 0219] t4v0219 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0220
display as text "[DIAG 0220] t4v0220 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0221
display as text "[DIAG 0221] t4v0221 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0222
display as text "[DIAG 0222] t4v0222 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0223
display as text "[DIAG 0223] t4v0223 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0224
display as text "[DIAG 0224] t4v0224 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0225
display as text "[DIAG 0225] t4v0225 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0226
display as text "[DIAG 0226] t4v0226 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0227
display as text "[DIAG 0227] t4v0227 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0228
display as text "[DIAG 0228] t4v0228 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0229
display as text "[DIAG 0229] t4v0229 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0230
display as text "[DIAG 0230] t4v0230 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0231
display as text "[DIAG 0231] t4v0231 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0232
display as text "[DIAG 0232] t4v0232 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0233
display as text "[DIAG 0233] t4v0233 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0234
display as text "[DIAG 0234] t4v0234 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0235
display as text "[DIAG 0235] t4v0235 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0236
display as text "[DIAG 0236] t4v0236 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0237
display as text "[DIAG 0237] t4v0237 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0238
display as text "[DIAG 0238] t4v0238 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0239
display as text "[DIAG 0239] t4v0239 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0240
display as text "[DIAG 0240] t4v0240 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0241
display as text "[DIAG 0241] t4v0241 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0242
display as text "[DIAG 0242] t4v0242 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0243
display as text "[DIAG 0243] t4v0243 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0244
display as text "[DIAG 0244] t4v0244 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0245
display as text "[DIAG 0245] t4v0245 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0246
display as text "[DIAG 0246] t4v0246 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0247
display as text "[DIAG 0247] t4v0247 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0248
display as text "[DIAG 0248] t4v0248 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0249
display as text "[DIAG 0249] t4v0249 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0250
display as text "[DIAG 0250] t4v0250 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0251
display as text "[DIAG 0251] t4v0251 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0252
display as text "[DIAG 0252] t4v0252 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0253
display as text "[DIAG 0253] t4v0253 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0254
display as text "[DIAG 0254] t4v0254 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0255
display as text "[DIAG 0255] t4v0255 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0256
display as text "[DIAG 0256] t4v0256 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0257
display as text "[DIAG 0257] t4v0257 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0258
display as text "[DIAG 0258] t4v0258 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0259
display as text "[DIAG 0259] t4v0259 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0260
display as text "[DIAG 0260] t4v0260 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0261
display as text "[DIAG 0261] t4v0261 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0262
display as text "[DIAG 0262] t4v0262 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0263
display as text "[DIAG 0263] t4v0263 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0264
display as text "[DIAG 0264] t4v0264 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0265
display as text "[DIAG 0265] t4v0265 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0266
display as text "[DIAG 0266] t4v0266 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0267
display as text "[DIAG 0267] t4v0267 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0268
display as text "[DIAG 0268] t4v0268 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0269
display as text "[DIAG 0269] t4v0269 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0270
display as text "[DIAG 0270] t4v0270 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0271
display as text "[DIAG 0271] t4v0271 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0272
display as text "[DIAG 0272] t4v0272 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0273
display as text "[DIAG 0273] t4v0273 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0274
display as text "[DIAG 0274] t4v0274 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0275
display as text "[DIAG 0275] t4v0275 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0276
display as text "[DIAG 0276] t4v0276 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0277
display as text "[DIAG 0277] t4v0277 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0278
display as text "[DIAG 0278] t4v0278 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0279
display as text "[DIAG 0279] t4v0279 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0280
display as text "[DIAG 0280] t4v0280 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0281
display as text "[DIAG 0281] t4v0281 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0282
display as text "[DIAG 0282] t4v0282 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0283
display as text "[DIAG 0283] t4v0283 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0284
display as text "[DIAG 0284] t4v0284 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0285
display as text "[DIAG 0285] t4v0285 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0286
display as text "[DIAG 0286] t4v0286 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0287
display as text "[DIAG 0287] t4v0287 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0288
display as text "[DIAG 0288] t4v0288 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0289
display as text "[DIAG 0289] t4v0289 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0290
display as text "[DIAG 0290] t4v0290 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0291
display as text "[DIAG 0291] t4v0291 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0292
display as text "[DIAG 0292] t4v0292 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0293
display as text "[DIAG 0293] t4v0293 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0294
display as text "[DIAG 0294] t4v0294 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0295
display as text "[DIAG 0295] t4v0295 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0296
display as text "[DIAG 0296] t4v0296 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0297
display as text "[DIAG 0297] t4v0297 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0298
display as text "[DIAG 0298] t4v0298 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0299
display as text "[DIAG 0299] t4v0299 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0300
display as text "[DIAG 0300] t4v0300 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0301
display as text "[DIAG 0301] t4v0301 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0302
display as text "[DIAG 0302] t4v0302 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0303
display as text "[DIAG 0303] t4v0303 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0304
display as text "[DIAG 0304] t4v0304 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0305
display as text "[DIAG 0305] t4v0305 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0306
display as text "[DIAG 0306] t4v0306 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0307
display as text "[DIAG 0307] t4v0307 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0308
display as text "[DIAG 0308] t4v0308 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0309
display as text "[DIAG 0309] t4v0309 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0310
display as text "[DIAG 0310] t4v0310 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0311
display as text "[DIAG 0311] t4v0311 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0312
display as text "[DIAG 0312] t4v0312 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0313
display as text "[DIAG 0313] t4v0313 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0314
display as text "[DIAG 0314] t4v0314 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0315
display as text "[DIAG 0315] t4v0315 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0316
display as text "[DIAG 0316] t4v0316 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0317
display as text "[DIAG 0317] t4v0317 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0318
display as text "[DIAG 0318] t4v0318 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0319
display as text "[DIAG 0319] t4v0319 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0320
display as text "[DIAG 0320] t4v0320 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0321
display as text "[DIAG 0321] t4v0321 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0322
display as text "[DIAG 0322] t4v0322 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0323
display as text "[DIAG 0323] t4v0323 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0324
display as text "[DIAG 0324] t4v0324 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0325
display as text "[DIAG 0325] t4v0325 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0326
display as text "[DIAG 0326] t4v0326 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0327
display as text "[DIAG 0327] t4v0327 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0328
display as text "[DIAG 0328] t4v0328 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0329
display as text "[DIAG 0329] t4v0329 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0330
display as text "[DIAG 0330] t4v0330 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0331
display as text "[DIAG 0331] t4v0331 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0332
display as text "[DIAG 0332] t4v0332 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0333
display as text "[DIAG 0333] t4v0333 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0334
display as text "[DIAG 0334] t4v0334 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0335
display as text "[DIAG 0335] t4v0335 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0336
display as text "[DIAG 0336] t4v0336 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0337
display as text "[DIAG 0337] t4v0337 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0338
display as text "[DIAG 0338] t4v0338 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0339
display as text "[DIAG 0339] t4v0339 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0340
display as text "[DIAG 0340] t4v0340 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0341
display as text "[DIAG 0341] t4v0341 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0342
display as text "[DIAG 0342] t4v0342 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0343
display as text "[DIAG 0343] t4v0343 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0344
display as text "[DIAG 0344] t4v0344 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0345
display as text "[DIAG 0345] t4v0345 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0346
display as text "[DIAG 0346] t4v0346 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0347
display as text "[DIAG 0347] t4v0347 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0348
display as text "[DIAG 0348] t4v0348 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0349
display as text "[DIAG 0349] t4v0349 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0350
display as text "[DIAG 0350] t4v0350 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0351
display as text "[DIAG 0351] t4v0351 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0352
display as text "[DIAG 0352] t4v0352 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0353
display as text "[DIAG 0353] t4v0353 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0354
display as text "[DIAG 0354] t4v0354 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0355
display as text "[DIAG 0355] t4v0355 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0356
display as text "[DIAG 0356] t4v0356 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0357
display as text "[DIAG 0357] t4v0357 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0358
display as text "[DIAG 0358] t4v0358 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0359
display as text "[DIAG 0359] t4v0359 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0360
display as text "[DIAG 0360] t4v0360 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0361
display as text "[DIAG 0361] t4v0361 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0362
display as text "[DIAG 0362] t4v0362 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0363
display as text "[DIAG 0363] t4v0363 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0364
display as text "[DIAG 0364] t4v0364 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0365
display as text "[DIAG 0365] t4v0365 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0366
display as text "[DIAG 0366] t4v0366 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0367
display as text "[DIAG 0367] t4v0367 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0368
display as text "[DIAG 0368] t4v0368 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0369
display as text "[DIAG 0369] t4v0369 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0370
display as text "[DIAG 0370] t4v0370 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0371
display as text "[DIAG 0371] t4v0371 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0372
display as text "[DIAG 0372] t4v0372 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0373
display as text "[DIAG 0373] t4v0373 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0374
display as text "[DIAG 0374] t4v0374 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0375
display as text "[DIAG 0375] t4v0375 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0376
display as text "[DIAG 0376] t4v0376 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0377
display as text "[DIAG 0377] t4v0377 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0378
display as text "[DIAG 0378] t4v0378 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0379
display as text "[DIAG 0379] t4v0379 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0380
display as text "[DIAG 0380] t4v0380 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0381
display as text "[DIAG 0381] t4v0381 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0382
display as text "[DIAG 0382] t4v0382 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0383
display as text "[DIAG 0383] t4v0383 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0384
display as text "[DIAG 0384] t4v0384 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0385
display as text "[DIAG 0385] t4v0385 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0386
display as text "[DIAG 0386] t4v0386 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0387
display as text "[DIAG 0387] t4v0387 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0388
display as text "[DIAG 0388] t4v0388 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0389
display as text "[DIAG 0389] t4v0389 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0390
display as text "[DIAG 0390] t4v0390 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0391
display as text "[DIAG 0391] t4v0391 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0392
display as text "[DIAG 0392] t4v0392 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0393
display as text "[DIAG 0393] t4v0393 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0394
display as text "[DIAG 0394] t4v0394 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0395
display as text "[DIAG 0395] t4v0395 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0396
display as text "[DIAG 0396] t4v0396 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0397
display as text "[DIAG 0397] t4v0397 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0398
display as text "[DIAG 0398] t4v0398 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0399
display as text "[DIAG 0399] t4v0399 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0400
display as text "[DIAG 0400] t4v0400 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0401
display as text "[DIAG 0401] t4v0401 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0402
display as text "[DIAG 0402] t4v0402 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0403
display as text "[DIAG 0403] t4v0403 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0404
display as text "[DIAG 0404] t4v0404 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0405
display as text "[DIAG 0405] t4v0405 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0406
display as text "[DIAG 0406] t4v0406 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0407
display as text "[DIAG 0407] t4v0407 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0408
display as text "[DIAG 0408] t4v0408 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0409
display as text "[DIAG 0409] t4v0409 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0410
display as text "[DIAG 0410] t4v0410 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0411
display as text "[DIAG 0411] t4v0411 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0412
display as text "[DIAG 0412] t4v0412 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0413
display as text "[DIAG 0413] t4v0413 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0414
display as text "[DIAG 0414] t4v0414 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0415
display as text "[DIAG 0415] t4v0415 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0416
display as text "[DIAG 0416] t4v0416 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0417
display as text "[DIAG 0417] t4v0417 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0418
display as text "[DIAG 0418] t4v0418 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t4v0419
display as text "[DIAG 0419] t4v0419 N=" r(N) " mean=" %9.4f r(mean)
display as result "<<< DONE Section 6: diagnostics and table output"
// #endregion ===== Section 6: diagnostics and table output =====


// #region ===== Section 7: document-output mixed graph block =====
display as text ">>> START Section 7: document-output mixed graph block"
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T4 hist Graph 001: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t4 graph stress 001") name(t4doc01, replace)
graph export "$figdir4/t4doc01.png", name(t4doc01) replace width(1600)
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T4 bar Graph 002: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t4 graph stress 002") name(t4doc02, replace)
graph export "$figdir4/t4doc02.png", name(t4doc02) replace width(1600)
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T4 line Graph 003: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t4 graph stress 003") name(t4doc03, replace)
graph export "$figdir4/t4doc03.png", name(t4doc03) replace width(1600)
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T4 qfit Graph 004: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t4 graph stress 004") name(t4doc04, replace)
graph export "$figdir4/t4doc04.png", name(t4doc04) replace width(1600)
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T4 scatter Graph 005: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t4 graph stress 005") name(t4doc05, replace)
graph export "$figdir4/t4doc05.png", name(t4doc05) replace width(1600)
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T4 hist Graph 006: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t4 graph stress 006") name(t4doc06, replace)
graph export "$figdir4/t4doc06.png", name(t4doc06) replace width(1600)
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T4 bar Graph 007: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t4 graph stress 007") name(t4doc07, replace)
graph export "$figdir4/t4doc07.png", name(t4doc07) replace width(1600)
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T4 line Graph 008: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t4 graph stress 008") name(t4doc08, replace)
graph export "$figdir4/t4doc08.png", name(t4doc08) replace width(1600)
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T4 qfit Graph 009: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t4 graph stress 009") name(t4doc09, replace)
graph export "$figdir4/t4doc09.png", name(t4doc09) replace width(1600)
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T4 scatter Graph 010: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t4 graph stress 010") name(t4doc10, replace)
graph export "$figdir4/t4doc10.png", name(t4doc10) replace width(1600)
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T4 hist Graph 011: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t4 graph stress 011") name(t4doc11, replace)
graph export "$figdir4/t4doc11.png", name(t4doc11) replace width(1600)
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T4 bar Graph 012: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t4 graph stress 012") name(t4doc12, replace)
graph export "$figdir4/t4doc12.png", name(t4doc12) replace width(1600)
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T4 line Graph 013: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t4 graph stress 013") name(t4doc13, replace)
graph export "$figdir4/t4doc13.png", name(t4doc13) replace width(1600)
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T4 qfit Graph 014: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t4 graph stress 014") name(t4doc14, replace)
graph export "$figdir4/t4doc14.png", name(t4doc14) replace width(1600)
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T4 scatter Graph 015: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t4 graph stress 015") name(t4doc15, replace)
graph export "$figdir4/t4doc15.png", name(t4doc15) replace width(1600)
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T4 hist Graph 016: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t4 graph stress 016") name(t4doc16, replace)
graph export "$figdir4/t4doc16.png", name(t4doc16) replace width(1600)
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T4 bar Graph 017: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t4 graph stress 017") name(t4doc17, replace)
graph export "$figdir4/t4doc17.png", name(t4doc17) replace width(1600)
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T4 line Graph 018: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t4 graph stress 018") name(t4doc18, replace)
graph export "$figdir4/t4doc18.png", name(t4doc18) replace width(1600)
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T4 qfit Graph 019: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t4 graph stress 019") name(t4doc19, replace)
graph export "$figdir4/t4doc19.png", name(t4doc19) replace width(1600)
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T4 scatter Graph 020: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t4 graph stress 020") name(t4doc20, replace)
graph export "$figdir4/t4doc20.png", name(t4doc20) replace width(1600)
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T4 hist Graph 021: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t4 graph stress 021") name(t4doc21, replace)
graph export "$figdir4/t4doc21.png", name(t4doc21) replace width(1600)
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T4 bar Graph 022: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t4 graph stress 022") name(t4doc22, replace)
graph export "$figdir4/t4doc22.png", name(t4doc22) replace width(1600)
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T4 line Graph 023: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t4 graph stress 023") name(t4doc23, replace)
graph export "$figdir4/t4doc23.png", name(t4doc23) replace width(1600)
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T4 qfit Graph 024: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t4 graph stress 024") name(t4doc24, replace)
graph export "$figdir4/t4doc24.png", name(t4doc24) replace width(1600)
putdocx clear
putdocx begin
putdocx paragraph, style(Title)
putdocx text ("taught_task4: putdocx graph/document stress")
putdocx paragraph
putdocx text ("This document verifies that graph exports, named graph activation, and document completion all survive Workbench routing.")
putdocx paragraph
putdocx text ("Figure 1: t4doc01")
putdocx image "$figdir4/t4doc01.png", width(4)
putdocx paragraph
putdocx text ("Figure 2: t4doc02")
putdocx image "$figdir4/t4doc02.png", width(4)
putdocx paragraph
putdocx text ("Figure 3: t4doc03")
putdocx image "$figdir4/t4doc03.png", width(4)
putdocx paragraph
putdocx text ("Figure 4: t4doc04")
putdocx image "$figdir4/t4doc04.png", width(4)
putdocx paragraph
putdocx text ("Figure 5: t4doc05")
putdocx image "$figdir4/t4doc05.png", width(4)
putdocx paragraph
putdocx text ("Figure 6: t4doc06")
putdocx image "$figdir4/t4doc06.png", width(4)
putdocx paragraph
putdocx text ("Figure 7: t4doc07")
putdocx image "$figdir4/t4doc07.png", width(4)
putdocx paragraph
putdocx text ("Figure 8: t4doc08")
putdocx image "$figdir4/t4doc08.png", width(4)
putdocx paragraph
putdocx text ("Figure 9: t4doc09")
putdocx image "$figdir4/t4doc09.png", width(4)
putdocx paragraph
putdocx text ("Figure 10: t4doc10")
putdocx image "$figdir4/t4doc10.png", width(4)
putdocx paragraph
putdocx text ("Figure 11: t4doc11")
putdocx image "$figdir4/t4doc11.png", width(4)
putdocx paragraph
putdocx text ("Figure 12: t4doc12")
putdocx image "$figdir4/t4doc12.png", width(4)
putdocx save "$docdir/taught_task4_report.docx", replace
capture which p_tdocx
if _rc == 0 {
    p_tdocx clear
    p_tdocx begin
    p_tdocx paragraph, style(Title)
    p_tdocx text ("taught_task4: p_tdocx compatibility path")
    p_tdocx paragraph
    p_tdocx text ("p_tdocx is intentionally treated like document-output code.")
    p_tdocx save "$docdir/taught_task4_ptdocx.docx", replace
}
display as result "<<< DONE Section 7: document-output mixed graph block"
// #endregion ===== Section 7: document-output mixed graph block =====


// #region ===== Section 8: model marathon =====
display as text ">>> START Section 8: model marathon"
estimates clear
quietly regress mpg weight length t4v0004, robust
estimates store t4m01
quietly logit foreign price mpg weight t4v0007
estimates store t4m02
quietly regress price c.mpg##c.weight t4v0010, robust
estimates store t4m03
quietly regress price mpg weight t4v0013 t4v0029, robust
estimates store t4m04
quietly regress mpg weight length t4v0016, robust
estimates store t4m05
quietly logit foreign price mpg weight t4v0019
estimates store t4m06
quietly regress price c.mpg##c.weight t4v0022, robust
estimates store t4m07
quietly regress price mpg weight t4v0025 t4v0057, robust
estimates store t4m08
quietly regress mpg weight length t4v0028, robust
estimates store t4m09
quietly logit foreign price mpg weight t4v0031
estimates store t4m10
quietly regress price c.mpg##c.weight t4v0034, robust
estimates store t4m11
quietly regress price mpg weight t4v0037 t4v0085, robust
estimates store t4m12
quietly regress mpg weight length t4v0040, robust
estimates store t4m13
quietly logit foreign price mpg weight t4v0043
estimates store t4m14
quietly regress price c.mpg##c.weight t4v0046, robust
estimates store t4m15
quietly regress price mpg weight t4v0049 t4v0113, robust
estimates store t4m16
quietly regress mpg weight length t4v0052, robust
estimates store t4m17
quietly logit foreign price mpg weight t4v0055
estimates store t4m18
quietly regress price c.mpg##c.weight t4v0058, robust
estimates store t4m19
quietly regress price mpg weight t4v0061 t4v0141, robust
estimates store t4m20
quietly regress mpg weight length t4v0064, robust
estimates store t4m21
quietly logit foreign price mpg weight t4v0067
estimates store t4m22
quietly regress price c.mpg##c.weight t4v0070, robust
estimates store t4m23
quietly regress price mpg weight t4v0073 t4v0169, robust
estimates store t4m24
quietly regress mpg weight length t4v0076, robust
estimates store t4m25
display as result "[MODEL] 0025 models estimated; last N=" e(N)
quietly logit foreign price mpg weight t4v0079
estimates store t4m26
quietly regress price c.mpg##c.weight t4v0082, robust
estimates store t4m27
quietly regress price mpg weight t4v0085 t4v0197, robust
estimates store t4m28
quietly regress mpg weight length t4v0088, robust
estimates store t4m29
quietly logit foreign price mpg weight t4v0091
estimates store t4m30
quietly regress price c.mpg##c.weight t4v0094, robust
quietly regress price mpg weight t4v0097 t4v0225, robust
quietly regress mpg weight length t4v0100, robust
quietly logit foreign price mpg weight t4v0103
quietly regress price c.mpg##c.weight t4v0106, robust
quietly regress price mpg weight t4v0109 t4v0253, robust
quietly regress mpg weight length t4v0112, robust
quietly logit foreign price mpg weight t4v0115
quietly regress price c.mpg##c.weight t4v0118, robust
quietly regress price mpg weight t4v0121 t4v0281, robust
quietly regress mpg weight length t4v0124, robust
quietly logit foreign price mpg weight t4v0127
quietly regress price c.mpg##c.weight t4v0130, robust
quietly regress price mpg weight t4v0133 t4v0309, robust
quietly regress mpg weight length t4v0136, robust
quietly logit foreign price mpg weight t4v0139
quietly regress price c.mpg##c.weight t4v0142, robust
quietly regress price mpg weight t4v0145 t4v0337, robust
quietly regress mpg weight length t4v0148, robust
quietly logit foreign price mpg weight t4v0151
display as result "[MODEL] 0050 models estimated; last N=" e(N)
quietly regress price c.mpg##c.weight t4v0154, robust
quietly regress price mpg weight t4v0157 t4v0365, robust
quietly regress mpg weight length t4v0160, robust
quietly logit foreign price mpg weight t4v0163
quietly regress price c.mpg##c.weight t4v0166, robust
quietly regress price mpg weight t4v0169 t4v0393, robust
quietly regress mpg weight length t4v0172, robust
quietly logit foreign price mpg weight t4v0175
quietly regress price c.mpg##c.weight t4v0178, robust
quietly regress price mpg weight t4v0181 t4v0421, robust
quietly regress mpg weight length t4v0184, robust
quietly logit foreign price mpg weight t4v0187
quietly regress price c.mpg##c.weight t4v0190, robust
quietly regress price mpg weight t4v0193 t4v0449, robust
quietly regress mpg weight length t4v0196, robust
quietly logit foreign price mpg weight t4v0199
quietly regress price c.mpg##c.weight t4v0202, robust
quietly regress price mpg weight t4v0205 t4v0477, robust
quietly regress mpg weight length t4v0208, robust
quietly logit foreign price mpg weight t4v0211
quietly regress price c.mpg##c.weight t4v0214, robust
quietly regress price mpg weight t4v0217 t4v0505, robust
quietly regress mpg weight length t4v0220, robust
quietly logit foreign price mpg weight t4v0223
quietly regress price c.mpg##c.weight t4v0226, robust
display as result "[MODEL] 0075 models estimated; last N=" e(N)
quietly regress price mpg weight t4v0229 t4v0533, robust
quietly regress mpg weight length t4v0232, robust
quietly logit foreign price mpg weight t4v0235
quietly regress price c.mpg##c.weight t4v0238, robust
quietly regress price mpg weight t4v0241 t4v0561, robust
quietly regress mpg weight length t4v0244, robust
quietly logit foreign price mpg weight t4v0247
quietly regress price c.mpg##c.weight t4v0250, robust
quietly regress price mpg weight t4v0253 t4v0589, robust
quietly regress mpg weight length t4v0256, robust
quietly logit foreign price mpg weight t4v0259
quietly regress price c.mpg##c.weight t4v0262, robust
quietly regress price mpg weight t4v0265 t4v0617, robust
quietly regress mpg weight length t4v0268, robust
quietly logit foreign price mpg weight t4v0271
quietly regress price c.mpg##c.weight t4v0274, robust
quietly regress price mpg weight t4v0277 t4v0645, robust
quietly regress mpg weight length t4v0280, robust
quietly logit foreign price mpg weight t4v0283
quietly regress price c.mpg##c.weight t4v0286, robust
quietly regress price mpg weight t4v0289 t4v0673, robust
quietly regress mpg weight length t4v0292, robust
quietly logit foreign price mpg weight t4v0295
quietly regress price c.mpg##c.weight t4v0298, robust
quietly regress price mpg weight t4v0301 t4v0701, robust
display as result "[MODEL] 0100 models estimated; last N=" e(N)
quietly regress mpg weight length t4v0304, robust
quietly logit foreign price mpg weight t4v0307
quietly regress price c.mpg##c.weight t4v0310, robust
quietly regress price mpg weight t4v0313 t4v0729, robust
quietly regress mpg weight length t4v0316, robust
quietly logit foreign price mpg weight t4v0319
quietly regress price c.mpg##c.weight t4v0322, robust
quietly regress price mpg weight t4v0325 t4v0757, robust
quietly regress mpg weight length t4v0328, robust
quietly logit foreign price mpg weight t4v0331
quietly regress price c.mpg##c.weight t4v0334, robust
quietly regress price mpg weight t4v0337 t4v0785, robust
quietly regress mpg weight length t4v0340, robust
quietly logit foreign price mpg weight t4v0343
quietly regress price c.mpg##c.weight t4v0346, robust
quietly regress price mpg weight t4v0349 t4v0813, robust
quietly regress mpg weight length t4v0352, robust
quietly logit foreign price mpg weight t4v0355
quietly regress price c.mpg##c.weight t4v0358, robust
quietly regress price mpg weight t4v0361 t4v0841, robust
quietly regress mpg weight length t4v0364, robust
quietly logit foreign price mpg weight t4v0367
quietly regress price c.mpg##c.weight t4v0370, robust
quietly regress price mpg weight t4v0373 t4v0869, robust
quietly regress mpg weight length t4v0376, robust
display as result "[MODEL] 0125 models estimated; last N=" e(N)
quietly logit foreign price mpg weight t4v0379
quietly regress price c.mpg##c.weight t4v0382, robust
quietly regress price mpg weight t4v0385 t4v0897, robust
quietly regress mpg weight length t4v0388, robust
quietly logit foreign price mpg weight t4v0391
quietly regress price c.mpg##c.weight t4v0394, robust
quietly regress price mpg weight t4v0397 t4v0925, robust
quietly regress mpg weight length t4v0400, robust
quietly logit foreign price mpg weight t4v0403
quietly regress price c.mpg##c.weight t4v0406, robust
quietly regress price mpg weight t4v0409 t4v0953, robust
quietly regress mpg weight length t4v0412, robust
quietly logit foreign price mpg weight t4v0415
quietly regress price c.mpg##c.weight t4v0418, robust
quietly regress price mpg weight t4v0421 t4v0001, robust
quietly regress mpg weight length t4v0424, robust
quietly logit foreign price mpg weight t4v0427
quietly regress price c.mpg##c.weight t4v0430, robust
quietly regress price mpg weight t4v0433 t4v0029, robust
quietly regress mpg weight length t4v0436, robust
quietly logit foreign price mpg weight t4v0439
quietly regress price c.mpg##c.weight t4v0442, robust
quietly regress price mpg weight t4v0445 t4v0057, robust
quietly regress mpg weight length t4v0448, robust
quietly logit foreign price mpg weight t4v0451
display as result "[MODEL] 0150 models estimated; last N=" e(N)
quietly regress price c.mpg##c.weight t4v0454, robust
quietly regress price mpg weight t4v0457 t4v0085, robust
quietly regress mpg weight length t4v0460, robust
quietly logit foreign price mpg weight t4v0463
quietly regress price c.mpg##c.weight t4v0466, robust
quietly regress price mpg weight t4v0469 t4v0113, robust
quietly regress mpg weight length t4v0472, robust
quietly logit foreign price mpg weight t4v0475
quietly regress price c.mpg##c.weight t4v0478, robust
quietly regress price mpg weight t4v0481 t4v0141, robust
quietly regress mpg weight length t4v0484, robust
quietly logit foreign price mpg weight t4v0487
quietly regress price c.mpg##c.weight t4v0490, robust
quietly regress price mpg weight t4v0493 t4v0169, robust
quietly regress mpg weight length t4v0496, robust
quietly logit foreign price mpg weight t4v0499
quietly regress price c.mpg##c.weight t4v0502, robust
quietly regress price mpg weight t4v0505 t4v0197, robust
quietly regress mpg weight length t4v0508, robust
quietly logit foreign price mpg weight t4v0511
quietly regress price c.mpg##c.weight t4v0514, robust
quietly regress price mpg weight t4v0517 t4v0225, robust
quietly regress mpg weight length t4v0520, robust
quietly logit foreign price mpg weight t4v0523
quietly regress price c.mpg##c.weight t4v0526, robust
display as result "[MODEL] 0175 models estimated; last N=" e(N)
quietly regress price mpg weight t4v0529 t4v0253, robust
quietly regress mpg weight length t4v0532, robust
quietly logit foreign price mpg weight t4v0535
quietly regress price c.mpg##c.weight t4v0538, robust
quietly regress price mpg weight t4v0541 t4v0281, robust
quietly regress mpg weight length t4v0544, robust
quietly logit foreign price mpg weight t4v0547
quietly regress price c.mpg##c.weight t4v0550, robust
quietly regress price mpg weight t4v0553 t4v0309, robust
quietly regress mpg weight length t4v0556, robust
quietly logit foreign price mpg weight t4v0559
quietly regress price c.mpg##c.weight t4v0562, robust
quietly regress price mpg weight t4v0565 t4v0337, robust
quietly regress mpg weight length t4v0568, robust
quietly logit foreign price mpg weight t4v0571
quietly regress price c.mpg##c.weight t4v0574, robust
quietly regress price mpg weight t4v0577 t4v0365, robust
quietly regress mpg weight length t4v0580, robust
quietly logit foreign price mpg weight t4v0583
quietly regress price c.mpg##c.weight t4v0586, robust
quietly regress price mpg weight t4v0589 t4v0393, robust
quietly regress mpg weight length t4v0592, robust
quietly logit foreign price mpg weight t4v0595
quietly regress price c.mpg##c.weight t4v0598, robust
quietly regress price mpg weight t4v0601 t4v0421, robust
display as result "[MODEL] 0200 models estimated; last N=" e(N)
quietly regress mpg weight length t4v0604, robust
quietly logit foreign price mpg weight t4v0607
quietly regress price c.mpg##c.weight t4v0610, robust
quietly regress price mpg weight t4v0613 t4v0449, robust
quietly regress mpg weight length t4v0616, robust
quietly logit foreign price mpg weight t4v0619
quietly regress price c.mpg##c.weight t4v0622, robust
quietly regress price mpg weight t4v0625 t4v0477, robust
quietly regress mpg weight length t4v0628, robust
quietly logit foreign price mpg weight t4v0631
quietly regress price c.mpg##c.weight t4v0634, robust
quietly regress price mpg weight t4v0637 t4v0505, robust
quietly regress mpg weight length t4v0640, robust
quietly logit foreign price mpg weight t4v0643
quietly regress price c.mpg##c.weight t4v0646, robust
quietly regress price mpg weight t4v0649 t4v0533, robust
quietly regress mpg weight length t4v0652, robust
quietly logit foreign price mpg weight t4v0655
quietly regress price c.mpg##c.weight t4v0658, robust
quietly regress price mpg weight t4v0661 t4v0561, robust
quietly regress mpg weight length t4v0664, robust
quietly logit foreign price mpg weight t4v0667
quietly regress price c.mpg##c.weight t4v0670, robust
quietly regress price mpg weight t4v0673 t4v0589, robust
quietly regress mpg weight length t4v0676, robust
display as result "[MODEL] 0225 models estimated; last N=" e(N)
quietly logit foreign price mpg weight t4v0679
quietly regress price c.mpg##c.weight t4v0682, robust
quietly regress price mpg weight t4v0685 t4v0617, robust
quietly regress mpg weight length t4v0688, robust
quietly logit foreign price mpg weight t4v0691
quietly regress price c.mpg##c.weight t4v0694, robust
quietly regress price mpg weight t4v0697 t4v0645, robust
quietly regress mpg weight length t4v0700, robust
quietly logit foreign price mpg weight t4v0703
quietly regress price c.mpg##c.weight t4v0706, robust
quietly regress price mpg weight t4v0709 t4v0673, robust
quietly regress mpg weight length t4v0712, robust
quietly logit foreign price mpg weight t4v0715
quietly regress price c.mpg##c.weight t4v0718, robust
quietly regress price mpg weight t4v0721 t4v0701, robust
quietly regress mpg weight length t4v0724, robust
quietly logit foreign price mpg weight t4v0727
quietly regress price c.mpg##c.weight t4v0730, robust
quietly regress price mpg weight t4v0733 t4v0729, robust
quietly regress mpg weight length t4v0736, robust
quietly logit foreign price mpg weight t4v0739
quietly regress price c.mpg##c.weight t4v0742, robust
quietly regress price mpg weight t4v0745 t4v0757, robust
quietly regress mpg weight length t4v0748, robust
quietly logit foreign price mpg weight t4v0751
display as result "[MODEL] 0250 models estimated; last N=" e(N)
quietly regress price c.mpg##c.weight t4v0754, robust
quietly regress price mpg weight t4v0757 t4v0785, robust
quietly regress mpg weight length t4v0760, robust
quietly logit foreign price mpg weight t4v0763
quietly regress price c.mpg##c.weight t4v0766, robust
quietly regress price mpg weight t4v0769 t4v0813, robust
quietly regress mpg weight length t4v0772, robust
quietly logit foreign price mpg weight t4v0775
quietly regress price c.mpg##c.weight t4v0778, robust
quietly regress price mpg weight t4v0781 t4v0841, robust
quietly regress mpg weight length t4v0784, robust
quietly logit foreign price mpg weight t4v0787
quietly regress price c.mpg##c.weight t4v0790, robust
quietly regress price mpg weight t4v0793 t4v0869, robust
quietly regress mpg weight length t4v0796, robust
quietly logit foreign price mpg weight t4v0799
quietly regress price c.mpg##c.weight t4v0802, robust
quietly regress price mpg weight t4v0805 t4v0897, robust
quietly regress mpg weight length t4v0808, robust
quietly logit foreign price mpg weight t4v0811
quietly regress price c.mpg##c.weight t4v0814, robust
quietly regress price mpg weight t4v0817 t4v0925, robust
quietly regress mpg weight length t4v0820, robust
quietly logit foreign price mpg weight t4v0823
quietly regress price c.mpg##c.weight t4v0826, robust
display as result "[MODEL] 0275 models estimated; last N=" e(N)
quietly regress price mpg weight t4v0829 t4v0953, robust
quietly regress mpg weight length t4v0832, robust
quietly logit foreign price mpg weight t4v0835
quietly regress price c.mpg##c.weight t4v0838, robust
quietly regress price mpg weight t4v0841 t4v0001, robust
quietly regress mpg weight length t4v0844, robust
quietly logit foreign price mpg weight t4v0847
quietly regress price c.mpg##c.weight t4v0850, robust
quietly regress price mpg weight t4v0853 t4v0029, robust
quietly regress mpg weight length t4v0856, robust
quietly logit foreign price mpg weight t4v0859
quietly regress price c.mpg##c.weight t4v0862, robust
quietly regress price mpg weight t4v0865 t4v0057, robust
quietly regress mpg weight length t4v0868, robust
quietly logit foreign price mpg weight t4v0871
quietly regress price c.mpg##c.weight t4v0874, robust
quietly regress price mpg weight t4v0877 t4v0085, robust
quietly regress mpg weight length t4v0880, robust
quietly logit foreign price mpg weight t4v0883
quietly regress price c.mpg##c.weight t4v0886, robust
quietly regress price mpg weight t4v0889 t4v0113, robust
quietly regress mpg weight length t4v0892, robust
quietly logit foreign price mpg weight t4v0895
quietly regress price c.mpg##c.weight t4v0898, robust
quietly regress price mpg weight t4v0901 t4v0141, robust
display as result "[MODEL] 0300 models estimated; last N=" e(N)
quietly regress mpg weight length t4v0904, robust
quietly logit foreign price mpg weight t4v0907
quietly regress price c.mpg##c.weight t4v0910, robust
quietly regress price mpg weight t4v0913 t4v0169, robust
quietly regress mpg weight length t4v0916, robust
quietly logit foreign price mpg weight t4v0919
quietly regress price c.mpg##c.weight t4v0922, robust
quietly regress price mpg weight t4v0925 t4v0197, robust
quietly regress mpg weight length t4v0928, robust
quietly logit foreign price mpg weight t4v0931
quietly regress price c.mpg##c.weight t4v0934, robust
quietly regress price mpg weight t4v0937 t4v0225, robust
quietly regress mpg weight length t4v0940, robust
quietly logit foreign price mpg weight t4v0943
quietly regress price c.mpg##c.weight t4v0946, robust
quietly regress price mpg weight t4v0949 t4v0253, robust
quietly regress mpg weight length t4v0952, robust
quietly logit foreign price mpg weight t4v0955
quietly regress price c.mpg##c.weight t4v0958, robust
quietly regress price mpg weight t4v0961 t4v0281, robust
quietly regress mpg weight length t4v0964, robust
quietly logit foreign price mpg weight t4v0967
quietly regress price c.mpg##c.weight t4v0970, robust
quietly regress price mpg weight t4v0973 t4v0309, robust
quietly regress mpg weight length t4v0976, robust
display as result "[MODEL] 0325 models estimated; last N=" e(N)
quietly logit foreign price mpg weight t4v0979
quietly regress price c.mpg##c.weight t4v0002, robust
quietly regress price mpg weight t4v0005 t4v0337, robust
quietly regress mpg weight length t4v0008, robust
quietly logit foreign price mpg weight t4v0011
quietly regress price c.mpg##c.weight t4v0014, robust
quietly regress price mpg weight t4v0017 t4v0365, robust
quietly regress mpg weight length t4v0020, robust
quietly logit foreign price mpg weight t4v0023
quietly regress price c.mpg##c.weight t4v0026, robust
quietly regress price mpg weight t4v0029 t4v0393, robust
quietly regress mpg weight length t4v0032, robust
quietly logit foreign price mpg weight t4v0035
quietly regress price c.mpg##c.weight t4v0038, robust
quietly regress price mpg weight t4v0041 t4v0421, robust
quietly regress mpg weight length t4v0044, robust
quietly logit foreign price mpg weight t4v0047
quietly regress price c.mpg##c.weight t4v0050, robust
quietly regress price mpg weight t4v0053 t4v0449, robust
quietly regress mpg weight length t4v0056, robust
quietly logit foreign price mpg weight t4v0059
quietly regress price c.mpg##c.weight t4v0062, robust
quietly regress price mpg weight t4v0065 t4v0477, robust
quietly regress mpg weight length t4v0068, robust
quietly logit foreign price mpg weight t4v0071
display as result "[MODEL] 0350 models estimated; last N=" e(N)
quietly regress price c.mpg##c.weight t4v0074, robust
quietly regress price mpg weight t4v0077 t4v0505, robust
quietly regress mpg weight length t4v0080, robust
quietly logit foreign price mpg weight t4v0083
quietly regress price c.mpg##c.weight t4v0086, robust
quietly regress price mpg weight t4v0089 t4v0533, robust
quietly regress mpg weight length t4v0092, robust
quietly logit foreign price mpg weight t4v0095
quietly regress price c.mpg##c.weight t4v0098, robust
quietly regress price mpg weight t4v0101 t4v0561, robust
quietly regress mpg weight length t4v0104, robust
quietly logit foreign price mpg weight t4v0107
quietly regress price c.mpg##c.weight t4v0110, robust
quietly regress price mpg weight t4v0113 t4v0589, robust
quietly regress mpg weight length t4v0116, robust
quietly logit foreign price mpg weight t4v0119
quietly regress price c.mpg##c.weight t4v0122, robust
quietly regress price mpg weight t4v0125 t4v0617, robust
quietly regress mpg weight length t4v0128, robust
quietly logit foreign price mpg weight t4v0131
quietly regress price c.mpg##c.weight t4v0134, robust
quietly regress price mpg weight t4v0137 t4v0645, robust
quietly regress mpg weight length t4v0140, robust
quietly logit foreign price mpg weight t4v0143
quietly regress price c.mpg##c.weight t4v0146, robust
display as result "[MODEL] 0375 models estimated; last N=" e(N)
quietly regress price mpg weight t4v0149 t4v0673, robust
quietly regress mpg weight length t4v0152, robust
quietly logit foreign price mpg weight t4v0155
quietly regress price c.mpg##c.weight t4v0158, robust
quietly regress price mpg weight t4v0161 t4v0701, robust
quietly regress mpg weight length t4v0164, robust
quietly logit foreign price mpg weight t4v0167
quietly regress price c.mpg##c.weight t4v0170, robust
quietly regress price mpg weight t4v0173 t4v0729, robust
quietly regress mpg weight length t4v0176, robust
quietly logit foreign price mpg weight t4v0179
quietly regress price c.mpg##c.weight t4v0182, robust
quietly regress price mpg weight t4v0185 t4v0757, robust
quietly regress mpg weight length t4v0188, robust
quietly logit foreign price mpg weight t4v0191
quietly regress price c.mpg##c.weight t4v0194, robust
quietly regress price mpg weight t4v0197 t4v0785, robust
quietly regress mpg weight length t4v0200, robust
quietly logit foreign price mpg weight t4v0203
quietly regress price c.mpg##c.weight t4v0206, robust
quietly regress price mpg weight t4v0209 t4v0813, robust
quietly regress mpg weight length t4v0212, robust
quietly logit foreign price mpg weight t4v0215
quietly regress price c.mpg##c.weight t4v0218, robust
quietly regress price mpg weight t4v0221 t4v0841, robust
display as result "[MODEL] 0400 models estimated; last N=" e(N)
quietly regress mpg weight length t4v0224, robust
quietly logit foreign price mpg weight t4v0227
quietly regress price c.mpg##c.weight t4v0230, robust
quietly regress price mpg weight t4v0233 t4v0869, robust
quietly regress mpg weight length t4v0236, robust
quietly logit foreign price mpg weight t4v0239
quietly regress price c.mpg##c.weight t4v0242, robust
quietly regress price mpg weight t4v0245 t4v0897, robust
quietly regress mpg weight length t4v0248, robust
quietly logit foreign price mpg weight t4v0251
quietly regress price c.mpg##c.weight t4v0254, robust
quietly regress price mpg weight t4v0257 t4v0925, robust
quietly regress mpg weight length t4v0260, robust
quietly logit foreign price mpg weight t4v0263
quietly regress price c.mpg##c.weight t4v0266, robust
quietly regress price mpg weight t4v0269 t4v0953, robust
quietly regress mpg weight length t4v0272, robust
quietly logit foreign price mpg weight t4v0275
quietly regress price c.mpg##c.weight t4v0278, robust
quietly regress price mpg weight t4v0281 t4v0001, robust
quietly regress mpg weight length t4v0284, robust
quietly logit foreign price mpg weight t4v0287
quietly regress price c.mpg##c.weight t4v0290, robust
quietly regress price mpg weight t4v0293 t4v0029, robust
quietly regress mpg weight length t4v0296, robust
display as result "[MODEL] 0425 models estimated; last N=" e(N)
quietly logit foreign price mpg weight t4v0299
quietly regress price c.mpg##c.weight t4v0302, robust
quietly regress price mpg weight t4v0305 t4v0057, robust
quietly regress mpg weight length t4v0308, robust
quietly logit foreign price mpg weight t4v0311
quietly regress price c.mpg##c.weight t4v0314, robust
quietly regress price mpg weight t4v0317 t4v0085, robust
quietly regress mpg weight length t4v0320, robust
quietly logit foreign price mpg weight t4v0323
quietly regress price c.mpg##c.weight t4v0326, robust
quietly regress price mpg weight t4v0329 t4v0113, robust
quietly regress mpg weight length t4v0332, robust
quietly logit foreign price mpg weight t4v0335
quietly regress price c.mpg##c.weight t4v0338, robust
quietly regress price mpg weight t4v0341 t4v0141, robust
quietly regress mpg weight length t4v0344, robust
quietly logit foreign price mpg weight t4v0347
quietly regress price c.mpg##c.weight t4v0350, robust
quietly regress price mpg weight t4v0353 t4v0169, robust
quietly regress mpg weight length t4v0356, robust
quietly logit foreign price mpg weight t4v0359
quietly regress price c.mpg##c.weight t4v0362, robust
quietly regress price mpg weight t4v0365 t4v0197, robust
quietly regress mpg weight length t4v0368, robust
quietly logit foreign price mpg weight t4v0371
display as result "[MODEL] 0450 models estimated; last N=" e(N)
quietly regress price c.mpg##c.weight t4v0374, robust
quietly regress price mpg weight t4v0377 t4v0225, robust
quietly regress mpg weight length t4v0380, robust
quietly logit foreign price mpg weight t4v0383
quietly regress price c.mpg##c.weight t4v0386, robust
quietly regress price mpg weight t4v0389 t4v0253, robust
quietly regress mpg weight length t4v0392, robust
quietly logit foreign price mpg weight t4v0395
quietly regress price c.mpg##c.weight t4v0398, robust
quietly regress price mpg weight t4v0401 t4v0281, robust
quietly regress mpg weight length t4v0404, robust
quietly logit foreign price mpg weight t4v0407
quietly regress price c.mpg##c.weight t4v0410, robust
quietly regress price mpg weight t4v0413 t4v0309, robust
quietly regress mpg weight length t4v0416, robust
quietly logit foreign price mpg weight t4v0419
quietly regress price c.mpg##c.weight t4v0422, robust
quietly regress price mpg weight t4v0425 t4v0337, robust
quietly regress mpg weight length t4v0428, robust
quietly logit foreign price mpg weight t4v0431
quietly regress price c.mpg##c.weight t4v0434, robust
quietly regress price mpg weight t4v0437 t4v0365, robust
quietly regress mpg weight length t4v0440, robust
quietly logit foreign price mpg weight t4v0443
quietly regress price c.mpg##c.weight t4v0446, robust
display as result "[MODEL] 0475 models estimated; last N=" e(N)
quietly regress price mpg weight t4v0449 t4v0393, robust
quietly regress mpg weight length t4v0452, robust
quietly logit foreign price mpg weight t4v0455
quietly regress price c.mpg##c.weight t4v0458, robust
quietly regress price mpg weight t4v0461 t4v0421, robust
quietly regress mpg weight length t4v0464, robust
quietly logit foreign price mpg weight t4v0467
quietly regress price c.mpg##c.weight t4v0470, robust
quietly regress price mpg weight t4v0473 t4v0449, robust
quietly regress mpg weight length t4v0476, robust
quietly logit foreign price mpg weight t4v0479
quietly regress price c.mpg##c.weight t4v0482, robust
quietly regress price mpg weight t4v0485 t4v0477, robust
quietly regress mpg weight length t4v0488, robust
quietly logit foreign price mpg weight t4v0491
quietly regress price c.mpg##c.weight t4v0494, robust
quietly regress price mpg weight t4v0497 t4v0505, robust
quietly regress mpg weight length t4v0500, robust
quietly logit foreign price mpg weight t4v0503
quietly regress price c.mpg##c.weight t4v0506, robust
quietly regress price mpg weight t4v0509 t4v0533, robust
quietly regress mpg weight length t4v0512, robust
quietly logit foreign price mpg weight t4v0515
quietly regress price c.mpg##c.weight t4v0518, robust
quietly regress price mpg weight t4v0521 t4v0561, robust
display as result "[MODEL] 0500 models estimated; last N=" e(N)
quietly regress mpg weight length t4v0524, robust
quietly logit foreign price mpg weight t4v0527
quietly regress price c.mpg##c.weight t4v0530, robust
quietly regress price mpg weight t4v0533 t4v0589, robust
quietly regress mpg weight length t4v0536, robust
quietly logit foreign price mpg weight t4v0539
quietly regress price c.mpg##c.weight t4v0542, robust
quietly regress price mpg weight t4v0545 t4v0617, robust
quietly regress mpg weight length t4v0548, robust
quietly logit foreign price mpg weight t4v0551
quietly regress price c.mpg##c.weight t4v0554, robust
quietly regress price mpg weight t4v0557 t4v0645, robust
quietly regress mpg weight length t4v0560, robust
quietly logit foreign price mpg weight t4v0563
quietly regress price c.mpg##c.weight t4v0566, robust
quietly regress price mpg weight t4v0569 t4v0673, robust
quietly regress mpg weight length t4v0572, robust
quietly logit foreign price mpg weight t4v0575
quietly regress price c.mpg##c.weight t4v0578, robust
quietly regress price mpg weight t4v0581 t4v0701, robust
estimates table t4m01 t4m02 t4m03 t4m04 t4m05, b(%9.3f) se stats(N r2)
display as result "<<< DONE Section 8: model marathon"
// #endregion ===== Section 8: model marathon =====


// #region ===== Section 9: preserve restore and reshape-like stress =====
display as text ">>> START Section 9: preserve restore and reshape-like stress"
preserve
keep make price mpg weight foreign group_id obs_id
tempfile slim
save `slim', replace
collapse (mean) price mpg weight, by(group_id foreign)
export delimited using "$docdir/taught_task4_collapsed.csv", replace
use `slim', clear
restore
preserve
keep if group_id == 1
quietly count
display as text "[PRESERVE 0001] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0002] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0003] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0004] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0005] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0006] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0007] group count=" r(N)
restore
preserve
keep if group_id == 8
quietly count
display as text "[PRESERVE 0008] group count=" r(N)
restore
preserve
keep if group_id == 9
quietly count
display as text "[PRESERVE 0009] group count=" r(N)
restore
preserve
keep if group_id == 10
quietly count
display as text "[PRESERVE 0010] group count=" r(N)
restore
preserve
keep if group_id == 1
quietly count
display as text "[PRESERVE 0011] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0012] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0013] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0014] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0015] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0016] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0017] group count=" r(N)
restore
preserve
keep if group_id == 8
quietly count
display as text "[PRESERVE 0018] group count=" r(N)
restore
preserve
keep if group_id == 9
quietly count
display as text "[PRESERVE 0019] group count=" r(N)
restore
preserve
keep if group_id == 10
quietly count
display as text "[PRESERVE 0020] group count=" r(N)
restore
preserve
keep if group_id == 1
quietly count
display as text "[PRESERVE 0021] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0022] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0023] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0024] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0025] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0026] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0027] group count=" r(N)
restore
preserve
keep if group_id == 8
quietly count
display as text "[PRESERVE 0028] group count=" r(N)
restore
preserve
keep if group_id == 9
quietly count
display as text "[PRESERVE 0029] group count=" r(N)
restore
preserve
keep if group_id == 10
quietly count
display as text "[PRESERVE 0030] group count=" r(N)
restore
preserve
keep if group_id == 1
quietly count
display as text "[PRESERVE 0031] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0032] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0033] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0034] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0035] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0036] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0037] group count=" r(N)
restore
preserve
keep if group_id == 8
quietly count
display as text "[PRESERVE 0038] group count=" r(N)
restore
preserve
keep if group_id == 9
quietly count
display as text "[PRESERVE 0039] group count=" r(N)
restore
preserve
keep if group_id == 10
quietly count
display as text "[PRESERVE 0040] group count=" r(N)
restore
preserve
keep if group_id == 1
quietly count
display as text "[PRESERVE 0041] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0042] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0043] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0044] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0045] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0046] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0047] group count=" r(N)
restore
preserve
keep if group_id == 8
quietly count
display as text "[PRESERVE 0048] group count=" r(N)
restore
preserve
keep if group_id == 9
quietly count
display as text "[PRESERVE 0049] group count=" r(N)
restore
preserve
keep if group_id == 10
quietly count
display as text "[PRESERVE 0050] group count=" r(N)
restore
preserve
keep if group_id == 1
quietly count
display as text "[PRESERVE 0051] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0052] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0053] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0054] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0055] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0056] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0057] group count=" r(N)
restore
preserve
keep if group_id == 8
quietly count
display as text "[PRESERVE 0058] group count=" r(N)
restore
preserve
keep if group_id == 9
quietly count
display as text "[PRESERVE 0059] group count=" r(N)
restore
preserve
keep if group_id == 10
quietly count
display as text "[PRESERVE 0060] group count=" r(N)
restore
preserve
keep if group_id == 1
quietly count
display as text "[PRESERVE 0061] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0062] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0063] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0064] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0065] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0066] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0067] group count=" r(N)
restore
preserve
keep if group_id == 8
quietly count
display as text "[PRESERVE 0068] group count=" r(N)
restore
preserve
keep if group_id == 9
quietly count
display as text "[PRESERVE 0069] group count=" r(N)
restore
preserve
keep if group_id == 10
quietly count
display as text "[PRESERVE 0070] group count=" r(N)
restore
preserve
keep if group_id == 1
quietly count
display as text "[PRESERVE 0071] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0072] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0073] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0074] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0075] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0076] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0077] group count=" r(N)
restore
preserve
keep if group_id == 8
quietly count
display as text "[PRESERVE 0078] group count=" r(N)
restore
preserve
keep if group_id == 9
quietly count
display as text "[PRESERVE 0079] group count=" r(N)
restore
preserve
keep if group_id == 10
quietly count
display as text "[PRESERVE 0080] group count=" r(N)
restore
preserve
keep if group_id == 1
quietly count
display as text "[PRESERVE 0081] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0082] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0083] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0084] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0085] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0086] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0087] group count=" r(N)
restore
preserve
keep if group_id == 8
quietly count
display as text "[PRESERVE 0088] group count=" r(N)
restore
preserve
keep if group_id == 9
quietly count
display as text "[PRESERVE 0089] group count=" r(N)
restore
preserve
keep if group_id == 10
quietly count
display as text "[PRESERVE 0090] group count=" r(N)
restore
preserve
keep if group_id == 1
quietly count
display as text "[PRESERVE 0091] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0092] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0093] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0094] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0095] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0096] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0097] group count=" r(N)
restore
preserve
keep if group_id == 8
quietly count
display as text "[PRESERVE 0098] group count=" r(N)
restore
preserve
keep if group_id == 9
quietly count
display as text "[PRESERVE 0099] group count=" r(N)
restore
preserve
keep if group_id == 10
quietly count
display as text "[PRESERVE 0100] group count=" r(N)
restore
preserve
keep if group_id == 1
quietly count
display as text "[PRESERVE 0101] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0102] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0103] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0104] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0105] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0106] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0107] group count=" r(N)
restore
preserve
keep if group_id == 8
quietly count
display as text "[PRESERVE 0108] group count=" r(N)
restore
preserve
keep if group_id == 9
quietly count
display as text "[PRESERVE 0109] group count=" r(N)
restore
preserve
keep if group_id == 10
quietly count
display as text "[PRESERVE 0110] group count=" r(N)
restore
preserve
keep if group_id == 1
quietly count
display as text "[PRESERVE 0111] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0112] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0113] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0114] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0115] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0116] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0117] group count=" r(N)
restore
preserve
keep if group_id == 8
quietly count
display as text "[PRESERVE 0118] group count=" r(N)
restore
preserve
keep if group_id == 9
quietly count
display as text "[PRESERVE 0119] group count=" r(N)
restore
preserve
keep if group_id == 10
quietly count
display as text "[PRESERVE 0120] group count=" r(N)
restore
preserve
keep if group_id == 1
quietly count
display as text "[PRESERVE 0121] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0122] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0123] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0124] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0125] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0126] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0127] group count=" r(N)
restore
preserve
keep if group_id == 8
quietly count
display as text "[PRESERVE 0128] group count=" r(N)
restore
preserve
keep if group_id == 9
quietly count
display as text "[PRESERVE 0129] group count=" r(N)
restore
preserve
keep if group_id == 10
quietly count
display as text "[PRESERVE 0130] group count=" r(N)
restore
preserve
keep if group_id == 1
quietly count
display as text "[PRESERVE 0131] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0132] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0133] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0134] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0135] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0136] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0137] group count=" r(N)
restore
preserve
keep if group_id == 8
quietly count
display as text "[PRESERVE 0138] group count=" r(N)
restore
preserve
keep if group_id == 9
quietly count
display as text "[PRESERVE 0139] group count=" r(N)
restore
preserve
keep if group_id == 10
quietly count
display as text "[PRESERVE 0140] group count=" r(N)
restore
preserve
keep if group_id == 1
quietly count
display as text "[PRESERVE 0141] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0142] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0143] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0144] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0145] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0146] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0147] group count=" r(N)
restore
preserve
keep if group_id == 8
quietly count
display as text "[PRESERVE 0148] group count=" r(N)
restore
preserve
keep if group_id == 9
quietly count
display as text "[PRESERVE 0149] group count=" r(N)
restore
preserve
keep if group_id == 10
quietly count
display as text "[PRESERVE 0150] group count=" r(N)
restore
preserve
keep if group_id == 1
quietly count
display as text "[PRESERVE 0151] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0152] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0153] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0154] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0155] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0156] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0157] group count=" r(N)
restore
preserve
keep if group_id == 8
quietly count
display as text "[PRESERVE 0158] group count=" r(N)
restore
preserve
keep if group_id == 9
quietly count
display as text "[PRESERVE 0159] group count=" r(N)
restore
preserve
keep if group_id == 10
quietly count
display as text "[PRESERVE 0160] group count=" r(N)
restore
preserve
keep if group_id == 1
quietly count
display as text "[PRESERVE 0161] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0162] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0163] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0164] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0165] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0166] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0167] group count=" r(N)
restore
preserve
keep if group_id == 8
quietly count
display as text "[PRESERVE 0168] group count=" r(N)
restore
preserve
keep if group_id == 9
quietly count
display as text "[PRESERVE 0169] group count=" r(N)
restore
preserve
keep if group_id == 10
quietly count
display as text "[PRESERVE 0170] group count=" r(N)
restore
preserve
keep if group_id == 1
quietly count
display as text "[PRESERVE 0171] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0172] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0173] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0174] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0175] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0176] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0177] group count=" r(N)
restore
preserve
keep if group_id == 8
quietly count
display as text "[PRESERVE 0178] group count=" r(N)
restore
preserve
keep if group_id == 9
quietly count
display as text "[PRESERVE 0179] group count=" r(N)
restore
display as result "<<< DONE Section 9: preserve restore and reshape-like stress"
// #endregion ===== Section 9: preserve restore and reshape-like stress =====


// #region ===== Section 10: final graph regression after document output =====
display as text ">>> START Section 10: final graph regression after document output"
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T4 hist Graph 001: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t4 graph stress 001") name(t4post01, replace)
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T4 bar Graph 002: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t4 graph stress 002") name(t4post02, replace)
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T4 line Graph 003: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t4 graph stress 003") name(t4post03, replace)
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T4 qfit Graph 004: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t4 graph stress 004") name(t4post04, replace)
graph export "$figdir4/t4post04.svg", name(t4post04) replace
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T4 scatter Graph 005: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t4 graph stress 005") name(t4post05, replace)
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T4 hist Graph 006: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t4 graph stress 006") name(t4post06, replace)
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T4 bar Graph 007: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t4 graph stress 007") name(t4post07, replace)
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T4 line Graph 008: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t4 graph stress 008") name(t4post08, replace)
graph export "$figdir4/t4post08.svg", name(t4post08) replace
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T4 qfit Graph 009: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t4 graph stress 009") name(t4post09, replace)
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T4 scatter Graph 010: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t4 graph stress 010") name(t4post10, replace)
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T4 hist Graph 011: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t4 graph stress 011") name(t4post11, replace)
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T4 bar Graph 012: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t4 graph stress 012") name(t4post12, replace)
graph export "$figdir4/t4post12.svg", name(t4post12) replace
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T4 line Graph 013: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t4 graph stress 013") name(t4post13, replace)
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T4 qfit Graph 014: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t4 graph stress 014") name(t4post14, replace)
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T4 scatter Graph 015: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t4 graph stress 015") name(t4post15, replace)
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T4 hist Graph 016: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t4 graph stress 016") name(t4post16, replace)
graph export "$figdir4/t4post16.svg", name(t4post16) replace
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T4 bar Graph 017: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t4 graph stress 017") name(t4post17, replace)
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T4 line Graph 018: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t4 graph stress 018") name(t4post18, replace)
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T4 qfit Graph 019: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t4 graph stress 019") name(t4post19, replace)
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T4 scatter Graph 020: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t4 graph stress 020") name(t4post20, replace)
graph export "$figdir4/t4post20.svg", name(t4post20) replace
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T4 hist Graph 021: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t4 graph stress 021") name(t4post21, replace)
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T4 bar Graph 022: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t4 graph stress 022") name(t4post22, replace)
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T4 line Graph 023: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t4 graph stress 023") name(t4post23, replace)
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T4 qfit Graph 024: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t4 graph stress 024") name(t4post24, replace)
graph export "$figdir4/t4post24.svg", name(t4post24) replace
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T4 scatter Graph 025: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t4 graph stress 025") name(t4post25, replace)
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T4 hist Graph 026: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t4 graph stress 026") name(t4post26, replace)
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T4 bar Graph 027: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t4 graph stress 027") name(t4post27, replace)
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T4 line Graph 028: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t4 graph stress 028") name(t4post28, replace)
graph export "$figdir4/t4post28.svg", name(t4post28) replace
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T4 qfit Graph 029: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t4 graph stress 029") name(t4post29, replace)
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T4 scatter Graph 030: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t4 graph stress 030") name(t4post30, replace)
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T4 hist Graph 031: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t4 graph stress 031") name(t4post31, replace)
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T4 bar Graph 032: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t4 graph stress 032") name(t4post32, replace)
graph export "$figdir4/t4post32.svg", name(t4post32) replace
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T4 line Graph 033: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t4 graph stress 033") name(t4post33, replace)
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T4 qfit Graph 034: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t4 graph stress 034") name(t4post34, replace)
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T4 scatter Graph 035: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t4 graph stress 035") name(t4post35, replace)
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T4 hist Graph 036: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t4 graph stress 036") name(t4post36, replace)
graph export "$figdir4/t4post36.svg", name(t4post36) replace
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T4 bar Graph 037: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t4 graph stress 037") name(t4post37, replace)
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T4 line Graph 038: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t4 graph stress 038") name(t4post38, replace)
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T4 qfit Graph 039: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t4 graph stress 039") name(t4post39, replace)
display as result "<<< DONE Section 10: final graph regression after document output"
// #endregion ===== Section 10: final graph regression after document output =====


// #region ===== Section 11: trace output and low-latency sentinels =====
display as text ">>> START Section 11: trace output and low-latency sentinels"
quietly count if !missing(t4v0012)
display as text "[TRACE t4 0001] count for t4v0012 = " r(N)
quietly count if !missing(t4v0023)
display as text "[TRACE t4 0002] count for t4v0023 = " r(N)
quietly count if !missing(t4v0034)
display as text "[TRACE t4 0003] count for t4v0034 = " r(N)
quietly count if !missing(t4v0045)
display as text "[TRACE t4 0004] count for t4v0045 = " r(N)
quietly count if !missing(t4v0056)
display as text "[TRACE t4 0005] count for t4v0056 = " r(N)
quietly count if !missing(t4v0067)
display as text "[TRACE t4 0006] count for t4v0067 = " r(N)
quietly count if !missing(t4v0078)
display as text "[TRACE t4 0007] count for t4v0078 = " r(N)
quietly count if !missing(t4v0089)
display as text "[TRACE t4 0008] count for t4v0089 = " r(N)
quietly count if !missing(t4v0100)
display as text "[TRACE t4 0009] count for t4v0100 = " r(N)
quietly count if !missing(t4v0111)
display as text "[TRACE t4 0010] count for t4v0111 = " r(N)
quietly count if !missing(t4v0122)
display as text "[TRACE t4 0011] count for t4v0122 = " r(N)
quietly count if !missing(t4v0133)
display as text "[TRACE t4 0012] count for t4v0133 = " r(N)
quietly count if !missing(t4v0144)
display as text "[TRACE t4 0013] count for t4v0144 = " r(N)
quietly count if !missing(t4v0155)
display as text "[TRACE t4 0014] count for t4v0155 = " r(N)
quietly count if !missing(t4v0166)
display as text "[TRACE t4 0015] count for t4v0166 = " r(N)
quietly count if !missing(t4v0177)
display as text "[TRACE t4 0016] count for t4v0177 = " r(N)
quietly count if !missing(t4v0188)
display as text "[TRACE t4 0017] count for t4v0188 = " r(N)
quietly summarize t4v0188, detail
display as text "[TRACE-DETAIL t4 0017] p50=" %9.4f r(p50)
quietly count if !missing(t4v0199)
display as text "[TRACE t4 0018] count for t4v0199 = " r(N)
quietly count if !missing(t4v0210)
display as text "[TRACE t4 0019] count for t4v0210 = " r(N)
quietly count if !missing(t4v0221)
display as text "[TRACE t4 0020] count for t4v0221 = " r(N)
quietly count if !missing(t4v0232)
display as text "[TRACE t4 0021] count for t4v0232 = " r(N)
quietly count if !missing(t4v0243)
display as text "[TRACE t4 0022] count for t4v0243 = " r(N)
quietly count if !missing(t4v0254)
display as text "[TRACE t4 0023] count for t4v0254 = " r(N)
quietly count if !missing(t4v0265)
display as text "[TRACE t4 0024] count for t4v0265 = " r(N)
quietly count if !missing(t4v0276)
display as text "[TRACE t4 0025] count for t4v0276 = " r(N)
quietly count if !missing(t4v0287)
display as text "[TRACE t4 0026] count for t4v0287 = " r(N)
quietly count if !missing(t4v0298)
display as text "[TRACE t4 0027] count for t4v0298 = " r(N)
quietly count if !missing(t4v0309)
display as text "[TRACE t4 0028] count for t4v0309 = " r(N)
quietly count if !missing(t4v0320)
display as text "[TRACE t4 0029] count for t4v0320 = " r(N)
quietly count if !missing(t4v0331)
display as text "[TRACE t4 0030] count for t4v0331 = " r(N)
quietly count if !missing(t4v0342)
display as text "[TRACE t4 0031] count for t4v0342 = " r(N)
quietly count if !missing(t4v0353)
display as text "[TRACE t4 0032] count for t4v0353 = " r(N)
quietly count if !missing(t4v0364)
display as text "[TRACE t4 0033] count for t4v0364 = " r(N)
quietly count if !missing(t4v0375)
display as text "[TRACE t4 0034] count for t4v0375 = " r(N)
quietly summarize t4v0375, detail
display as text "[TRACE-DETAIL t4 0034] p50=" %9.4f r(p50)
quietly count if !missing(t4v0386)
display as text "[TRACE t4 0035] count for t4v0386 = " r(N)
quietly count if !missing(t4v0397)
display as text "[TRACE t4 0036] count for t4v0397 = " r(N)
quietly count if !missing(t4v0408)
display as text "[TRACE t4 0037] count for t4v0408 = " r(N)
quietly count if !missing(t4v0419)
display as text "[TRACE t4 0038] count for t4v0419 = " r(N)
quietly count if !missing(t4v0430)
display as text "[TRACE t4 0039] count for t4v0430 = " r(N)
quietly count if !missing(t4v0441)
display as text "[TRACE t4 0040] count for t4v0441 = " r(N)
quietly count if !missing(t4v0452)
display as text "[TRACE t4 0041] count for t4v0452 = " r(N)
quietly count if !missing(t4v0463)
display as text "[TRACE t4 0042] count for t4v0463 = " r(N)
quietly count if !missing(t4v0474)
display as text "[TRACE t4 0043] count for t4v0474 = " r(N)
quietly count if !missing(t4v0485)
display as text "[TRACE t4 0044] count for t4v0485 = " r(N)
quietly count if !missing(t4v0496)
display as text "[TRACE t4 0045] count for t4v0496 = " r(N)
quietly count if !missing(t4v0507)
display as text "[TRACE t4 0046] count for t4v0507 = " r(N)
quietly count if !missing(t4v0518)
display as text "[TRACE t4 0047] count for t4v0518 = " r(N)
quietly count if !missing(t4v0529)
display as text "[TRACE t4 0048] count for t4v0529 = " r(N)
quietly count if !missing(t4v0540)
display as text "[TRACE t4 0049] count for t4v0540 = " r(N)
quietly count if !missing(t4v0551)
display as text "[TRACE t4 0050] count for t4v0551 = " r(N)
quietly count if !missing(t4v0562)
display as text "[TRACE t4 0051] count for t4v0562 = " r(N)
quietly summarize t4v0562, detail
display as text "[TRACE-DETAIL t4 0051] p50=" %9.4f r(p50)
quietly count if !missing(t4v0573)
display as text "[TRACE t4 0052] count for t4v0573 = " r(N)
quietly count if !missing(t4v0584)
display as text "[TRACE t4 0053] count for t4v0584 = " r(N)
quietly count if !missing(t4v0595)
display as text "[TRACE t4 0054] count for t4v0595 = " r(N)
quietly count if !missing(t4v0606)
display as text "[TRACE t4 0055] count for t4v0606 = " r(N)
quietly count if !missing(t4v0617)
display as text "[TRACE t4 0056] count for t4v0617 = " r(N)
quietly count if !missing(t4v0628)
display as text "[TRACE t4 0057] count for t4v0628 = " r(N)
quietly count if !missing(t4v0639)
display as text "[TRACE t4 0058] count for t4v0639 = " r(N)
quietly count if !missing(t4v0650)
display as text "[TRACE t4 0059] count for t4v0650 = " r(N)
quietly count if !missing(t4v0661)
display as text "[TRACE t4 0060] count for t4v0661 = " r(N)
quietly count if !missing(t4v0672)
display as text "[TRACE t4 0061] count for t4v0672 = " r(N)
quietly count if !missing(t4v0683)
display as text "[TRACE t4 0062] count for t4v0683 = " r(N)
quietly count if !missing(t4v0694)
display as text "[TRACE t4 0063] count for t4v0694 = " r(N)
quietly count if !missing(t4v0705)
display as text "[TRACE t4 0064] count for t4v0705 = " r(N)
quietly count if !missing(t4v0716)
display as text "[TRACE t4 0065] count for t4v0716 = " r(N)
quietly count if !missing(t4v0727)
display as text "[TRACE t4 0066] count for t4v0727 = " r(N)
quietly count if !missing(t4v0738)
display as text "[TRACE t4 0067] count for t4v0738 = " r(N)
quietly count if !missing(t4v0749)
display as text "[TRACE t4 0068] count for t4v0749 = " r(N)
quietly summarize t4v0749, detail
display as text "[TRACE-DETAIL t4 0068] p50=" %9.4f r(p50)
quietly count if !missing(t4v0760)
display as text "[TRACE t4 0069] count for t4v0760 = " r(N)
quietly count if !missing(t4v0771)
display as text "[TRACE t4 0070] count for t4v0771 = " r(N)
quietly count if !missing(t4v0782)
display as text "[TRACE t4 0071] count for t4v0782 = " r(N)
quietly count if !missing(t4v0793)
display as text "[TRACE t4 0072] count for t4v0793 = " r(N)
quietly count if !missing(t4v0804)
display as text "[TRACE t4 0073] count for t4v0804 = " r(N)
quietly count if !missing(t4v0815)
display as text "[TRACE t4 0074] count for t4v0815 = " r(N)
quietly count if !missing(t4v0826)
display as text "[TRACE t4 0075] count for t4v0826 = " r(N)
quietly count if !missing(t4v0837)
display as text "[TRACE t4 0076] count for t4v0837 = " r(N)
quietly count if !missing(t4v0848)
display as text "[TRACE t4 0077] count for t4v0848 = " r(N)
quietly count if !missing(t4v0859)
display as text "[TRACE t4 0078] count for t4v0859 = " r(N)
quietly count if !missing(t4v0870)
display as text "[TRACE t4 0079] count for t4v0870 = " r(N)
quietly count if !missing(t4v0881)
display as text "[TRACE t4 0080] count for t4v0881 = " r(N)
quietly count if !missing(t4v0892)
display as text "[TRACE t4 0081] count for t4v0892 = " r(N)
quietly count if !missing(t4v0903)
display as text "[TRACE t4 0082] count for t4v0903 = " r(N)
quietly count if !missing(t4v0914)
display as text "[TRACE t4 0083] count for t4v0914 = " r(N)
quietly count if !missing(t4v0925)
display as text "[TRACE t4 0084] count for t4v0925 = " r(N)
quietly count if !missing(t4v0936)
display as text "[TRACE t4 0085] count for t4v0936 = " r(N)
quietly summarize t4v0936, detail
display as text "[TRACE-DETAIL t4 0085] p50=" %9.4f r(p50)
quietly count if !missing(t4v0947)
display as text "[TRACE t4 0086] count for t4v0947 = " r(N)
quietly count if !missing(t4v0958)
display as text "[TRACE t4 0087] count for t4v0958 = " r(N)
quietly count if !missing(t4v0969)
display as text "[TRACE t4 0088] count for t4v0969 = " r(N)
quietly count if !missing(t4v0980)
display as text "[TRACE t4 0089] count for t4v0980 = " r(N)
quietly count if !missing(t4v0011)
display as text "[TRACE t4 0090] count for t4v0011 = " r(N)
quietly count if !missing(t4v0022)
display as text "[TRACE t4 0091] count for t4v0022 = " r(N)
quietly count if !missing(t4v0033)
display as text "[TRACE t4 0092] count for t4v0033 = " r(N)
quietly count if !missing(t4v0044)
display as text "[TRACE t4 0093] count for t4v0044 = " r(N)
quietly count if !missing(t4v0055)
display as text "[TRACE t4 0094] count for t4v0055 = " r(N)
quietly count if !missing(t4v0066)
display as text "[TRACE t4 0095] count for t4v0066 = " r(N)
quietly count if !missing(t4v0077)
display as text "[TRACE t4 0096] count for t4v0077 = " r(N)
quietly count if !missing(t4v0088)
display as text "[TRACE t4 0097] count for t4v0088 = " r(N)
quietly count if !missing(t4v0099)
display as text "[TRACE t4 0098] count for t4v0099 = " r(N)
quietly count if !missing(t4v0110)
display as text "[TRACE t4 0099] count for t4v0110 = " r(N)
quietly count if !missing(t4v0121)
display as text "[TRACE t4 0100] count for t4v0121 = " r(N)
quietly count if !missing(t4v0132)
display as text "[TRACE t4 0101] count for t4v0132 = " r(N)
quietly count if !missing(t4v0143)
display as text "[TRACE t4 0102] count for t4v0143 = " r(N)
quietly summarize t4v0143, detail
display as text "[TRACE-DETAIL t4 0102] p50=" %9.4f r(p50)
quietly count if !missing(t4v0154)
display as text "[TRACE t4 0103] count for t4v0154 = " r(N)
quietly count if !missing(t4v0165)
display as text "[TRACE t4 0104] count for t4v0165 = " r(N)
quietly count if !missing(t4v0176)
display as text "[TRACE t4 0105] count for t4v0176 = " r(N)
quietly count if !missing(t4v0187)
display as text "[TRACE t4 0106] count for t4v0187 = " r(N)
quietly count if !missing(t4v0198)
display as text "[TRACE t4 0107] count for t4v0198 = " r(N)
quietly count if !missing(t4v0209)
display as text "[TRACE t4 0108] count for t4v0209 = " r(N)
quietly count if !missing(t4v0220)
display as text "[TRACE t4 0109] count for t4v0220 = " r(N)
quietly count if !missing(t4v0231)
display as text "[TRACE t4 0110] count for t4v0231 = " r(N)
quietly count if !missing(t4v0242)
display as text "[TRACE t4 0111] count for t4v0242 = " r(N)
quietly count if !missing(t4v0253)
display as text "[TRACE t4 0112] count for t4v0253 = " r(N)
quietly count if !missing(t4v0264)
display as text "[TRACE t4 0113] count for t4v0264 = " r(N)
quietly count if !missing(t4v0275)
display as text "[TRACE t4 0114] count for t4v0275 = " r(N)
quietly count if !missing(t4v0286)
display as text "[TRACE t4 0115] count for t4v0286 = " r(N)
quietly count if !missing(t4v0297)
display as text "[TRACE t4 0116] count for t4v0297 = " r(N)
quietly count if !missing(t4v0308)
display as text "[TRACE t4 0117] count for t4v0308 = " r(N)
quietly count if !missing(t4v0319)
display as text "[TRACE t4 0118] count for t4v0319 = " r(N)
quietly count if !missing(t4v0330)
display as text "[TRACE t4 0119] count for t4v0330 = " r(N)
quietly summarize t4v0330, detail
display as text "[TRACE-DETAIL t4 0119] p50=" %9.4f r(p50)
quietly count if !missing(t4v0341)
display as text "[TRACE t4 0120] count for t4v0341 = " r(N)
quietly count if !missing(t4v0352)
display as text "[TRACE t4 0121] count for t4v0352 = " r(N)
quietly count if !missing(t4v0363)
display as text "[TRACE t4 0122] count for t4v0363 = " r(N)
quietly count if !missing(t4v0374)
display as text "[TRACE t4 0123] count for t4v0374 = " r(N)
quietly count if !missing(t4v0385)
display as text "[TRACE t4 0124] count for t4v0385 = " r(N)
quietly count if !missing(t4v0396)
display as text "[TRACE t4 0125] count for t4v0396 = " r(N)
quietly count if !missing(t4v0407)
display as text "[TRACE t4 0126] count for t4v0407 = " r(N)
quietly count if !missing(t4v0418)
display as text "[TRACE t4 0127] count for t4v0418 = " r(N)
quietly count if !missing(t4v0429)
display as text "[TRACE t4 0128] count for t4v0429 = " r(N)
quietly count if !missing(t4v0440)
display as text "[TRACE t4 0129] count for t4v0440 = " r(N)
quietly count if !missing(t4v0451)
display as text "[TRACE t4 0130] count for t4v0451 = " r(N)
quietly count if !missing(t4v0462)
display as text "[TRACE t4 0131] count for t4v0462 = " r(N)
quietly count if !missing(t4v0473)
display as text "[TRACE t4 0132] count for t4v0473 = " r(N)
quietly count if !missing(t4v0484)
display as text "[TRACE t4 0133] count for t4v0484 = " r(N)
quietly count if !missing(t4v0495)
display as text "[TRACE t4 0134] count for t4v0495 = " r(N)
quietly count if !missing(t4v0506)
display as text "[TRACE t4 0135] count for t4v0506 = " r(N)
quietly count if !missing(t4v0517)
display as text "[TRACE t4 0136] count for t4v0517 = " r(N)
quietly summarize t4v0517, detail
display as text "[TRACE-DETAIL t4 0136] p50=" %9.4f r(p50)
quietly count if !missing(t4v0528)
display as text "[TRACE t4 0137] count for t4v0528 = " r(N)
quietly count if !missing(t4v0539)
display as text "[TRACE t4 0138] count for t4v0539 = " r(N)
quietly count if !missing(t4v0550)
display as text "[TRACE t4 0139] count for t4v0550 = " r(N)
quietly count if !missing(t4v0561)
display as text "[TRACE t4 0140] count for t4v0561 = " r(N)
quietly count if !missing(t4v0572)
display as text "[TRACE t4 0141] count for t4v0572 = " r(N)
quietly count if !missing(t4v0583)
display as text "[TRACE t4 0142] count for t4v0583 = " r(N)
quietly count if !missing(t4v0594)
display as text "[TRACE t4 0143] count for t4v0594 = " r(N)
quietly count if !missing(t4v0605)
display as text "[TRACE t4 0144] count for t4v0605 = " r(N)
quietly count if !missing(t4v0616)
display as text "[TRACE t4 0145] count for t4v0616 = " r(N)
quietly count if !missing(t4v0627)
display as text "[TRACE t4 0146] count for t4v0627 = " r(N)
quietly count if !missing(t4v0638)
display as text "[TRACE t4 0147] count for t4v0638 = " r(N)
quietly count if !missing(t4v0649)
display as text "[TRACE t4 0148] count for t4v0649 = " r(N)
quietly count if !missing(t4v0660)
display as text "[TRACE t4 0149] count for t4v0660 = " r(N)
quietly count if !missing(t4v0671)
display as text "[TRACE t4 0150] count for t4v0671 = " r(N)
quietly count if !missing(t4v0682)
display as text "[TRACE t4 0151] count for t4v0682 = " r(N)
quietly count if !missing(t4v0693)
display as text "[TRACE t4 0152] count for t4v0693 = " r(N)
quietly count if !missing(t4v0704)
display as text "[TRACE t4 0153] count for t4v0704 = " r(N)
quietly summarize t4v0704, detail
display as text "[TRACE-DETAIL t4 0153] p50=" %9.4f r(p50)
quietly count if !missing(t4v0715)
display as text "[TRACE t4 0154] count for t4v0715 = " r(N)
quietly count if !missing(t4v0726)
display as text "[TRACE t4 0155] count for t4v0726 = " r(N)
quietly count if !missing(t4v0737)
display as text "[TRACE t4 0156] count for t4v0737 = " r(N)
quietly count if !missing(t4v0748)
display as text "[TRACE t4 0157] count for t4v0748 = " r(N)
quietly count if !missing(t4v0759)
display as text "[TRACE t4 0158] count for t4v0759 = " r(N)
quietly count if !missing(t4v0770)
display as text "[TRACE t4 0159] count for t4v0770 = " r(N)
quietly count if !missing(t4v0781)
display as text "[TRACE t4 0160] count for t4v0781 = " r(N)
quietly count if !missing(t4v0792)
display as text "[TRACE t4 0161] count for t4v0792 = " r(N)
quietly count if !missing(t4v0803)
display as text "[TRACE t4 0162] count for t4v0803 = " r(N)
quietly count if !missing(t4v0814)
display as text "[TRACE t4 0163] count for t4v0814 = " r(N)
quietly count if !missing(t4v0825)
display as text "[TRACE t4 0164] count for t4v0825 = " r(N)
quietly count if !missing(t4v0836)
display as text "[TRACE t4 0165] count for t4v0836 = " r(N)
quietly count if !missing(t4v0847)
display as text "[TRACE t4 0166] count for t4v0847 = " r(N)
quietly count if !missing(t4v0858)
display as text "[TRACE t4 0167] count for t4v0858 = " r(N)
quietly count if !missing(t4v0869)
display as text "[TRACE t4 0168] count for t4v0869 = " r(N)
quietly count if !missing(t4v0880)
display as text "[TRACE t4 0169] count for t4v0880 = " r(N)
quietly count if !missing(t4v0891)
display as text "[TRACE t4 0170] count for t4v0891 = " r(N)
quietly summarize t4v0891, detail
display as text "[TRACE-DETAIL t4 0170] p50=" %9.4f r(p50)
quietly count if !missing(t4v0902)
display as text "[TRACE t4 0171] count for t4v0902 = " r(N)
quietly count if !missing(t4v0913)
display as text "[TRACE t4 0172] count for t4v0913 = " r(N)
quietly count if !missing(t4v0924)
display as text "[TRACE t4 0173] count for t4v0924 = " r(N)
quietly count if !missing(t4v0935)
display as text "[TRACE t4 0174] count for t4v0935 = " r(N)
quietly count if !missing(t4v0946)
display as text "[TRACE t4 0175] count for t4v0946 = " r(N)
quietly count if !missing(t4v0957)
display as text "[TRACE t4 0176] count for t4v0957 = " r(N)
quietly count if !missing(t4v0968)
display as text "[TRACE t4 0177] count for t4v0968 = " r(N)
quietly count if !missing(t4v0979)
display as text "[TRACE t4 0178] count for t4v0979 = " r(N)
quietly count if !missing(t4v0010)
display as text "[TRACE t4 0179] count for t4v0010 = " r(N)
quietly count if !missing(t4v0021)
display as text "[TRACE t4 0180] count for t4v0021 = " r(N)
quietly count if !missing(t4v0032)
display as text "[TRACE t4 0181] count for t4v0032 = " r(N)
quietly count if !missing(t4v0043)
display as text "[TRACE t4 0182] count for t4v0043 = " r(N)
quietly count if !missing(t4v0054)
display as text "[TRACE t4 0183] count for t4v0054 = " r(N)
quietly count if !missing(t4v0065)
display as text "[TRACE t4 0184] count for t4v0065 = " r(N)
quietly count if !missing(t4v0076)
display as text "[TRACE t4 0185] count for t4v0076 = " r(N)
quietly count if !missing(t4v0087)
display as text "[TRACE t4 0186] count for t4v0087 = " r(N)
quietly count if !missing(t4v0098)
display as text "[TRACE t4 0187] count for t4v0098 = " r(N)
quietly summarize t4v0098, detail
display as text "[TRACE-DETAIL t4 0187] p50=" %9.4f r(p50)
quietly count if !missing(t4v0109)
display as text "[TRACE t4 0188] count for t4v0109 = " r(N)
quietly count if !missing(t4v0120)
display as text "[TRACE t4 0189] count for t4v0120 = " r(N)
quietly count if !missing(t4v0131)
display as text "[TRACE t4 0190] count for t4v0131 = " r(N)
quietly count if !missing(t4v0142)
display as text "[TRACE t4 0191] count for t4v0142 = " r(N)
quietly count if !missing(t4v0153)
display as text "[TRACE t4 0192] count for t4v0153 = " r(N)
quietly count if !missing(t4v0164)
display as text "[TRACE t4 0193] count for t4v0164 = " r(N)
quietly count if !missing(t4v0175)
display as text "[TRACE t4 0194] count for t4v0175 = " r(N)
quietly count if !missing(t4v0186)
display as text "[TRACE t4 0195] count for t4v0186 = " r(N)
quietly count if !missing(t4v0197)
display as text "[TRACE t4 0196] count for t4v0197 = " r(N)
quietly count if !missing(t4v0208)
display as text "[TRACE t4 0197] count for t4v0208 = " r(N)
quietly count if !missing(t4v0219)
display as text "[TRACE t4 0198] count for t4v0219 = " r(N)
quietly count if !missing(t4v0230)
display as text "[TRACE t4 0199] count for t4v0230 = " r(N)
quietly count if !missing(t4v0241)
display as text "[TRACE t4 0200] count for t4v0241 = " r(N)
quietly count if !missing(t4v0252)
display as text "[TRACE t4 0201] count for t4v0252 = " r(N)
quietly count if !missing(t4v0263)
display as text "[TRACE t4 0202] count for t4v0263 = " r(N)
quietly count if !missing(t4v0274)
display as text "[TRACE t4 0203] count for t4v0274 = " r(N)
quietly count if !missing(t4v0285)
display as text "[TRACE t4 0204] count for t4v0285 = " r(N)
quietly summarize t4v0285, detail
display as text "[TRACE-DETAIL t4 0204] p50=" %9.4f r(p50)
quietly count if !missing(t4v0296)
display as text "[TRACE t4 0205] count for t4v0296 = " r(N)
quietly count if !missing(t4v0307)
display as text "[TRACE t4 0206] count for t4v0307 = " r(N)
quietly count if !missing(t4v0318)
display as text "[TRACE t4 0207] count for t4v0318 = " r(N)
quietly count if !missing(t4v0329)
display as text "[TRACE t4 0208] count for t4v0329 = " r(N)
quietly count if !missing(t4v0340)
display as text "[TRACE t4 0209] count for t4v0340 = " r(N)
quietly count if !missing(t4v0351)
display as text "[TRACE t4 0210] count for t4v0351 = " r(N)
quietly count if !missing(t4v0362)
display as text "[TRACE t4 0211] count for t4v0362 = " r(N)
quietly count if !missing(t4v0373)
display as text "[TRACE t4 0212] count for t4v0373 = " r(N)
quietly count if !missing(t4v0384)
display as text "[TRACE t4 0213] count for t4v0384 = " r(N)
quietly count if !missing(t4v0395)
display as text "[TRACE t4 0214] count for t4v0395 = " r(N)
quietly count if !missing(t4v0406)
display as text "[TRACE t4 0215] count for t4v0406 = " r(N)
quietly count if !missing(t4v0417)
display as text "[TRACE t4 0216] count for t4v0417 = " r(N)
quietly count if !missing(t4v0428)
display as text "[TRACE t4 0217] count for t4v0428 = " r(N)
quietly count if !missing(t4v0439)
display as text "[TRACE t4 0218] count for t4v0439 = " r(N)
quietly count if !missing(t4v0450)
display as text "[TRACE t4 0219] count for t4v0450 = " r(N)
quietly count if !missing(t4v0461)
display as text "[TRACE t4 0220] count for t4v0461 = " r(N)
quietly count if !missing(t4v0472)
display as text "[TRACE t4 0221] count for t4v0472 = " r(N)
quietly summarize t4v0472, detail
display as text "[TRACE-DETAIL t4 0221] p50=" %9.4f r(p50)
quietly count if !missing(t4v0483)
display as text "[TRACE t4 0222] count for t4v0483 = " r(N)
quietly count if !missing(t4v0494)
display as text "[TRACE t4 0223] count for t4v0494 = " r(N)
quietly count if !missing(t4v0505)
display as text "[TRACE t4 0224] count for t4v0505 = " r(N)
quietly count if !missing(t4v0516)
display as text "[TRACE t4 0225] count for t4v0516 = " r(N)
quietly count if !missing(t4v0527)
display as text "[TRACE t4 0226] count for t4v0527 = " r(N)
quietly count if !missing(t4v0538)
display as text "[TRACE t4 0227] count for t4v0538 = " r(N)
quietly count if !missing(t4v0549)
display as text "[TRACE t4 0228] count for t4v0549 = " r(N)
quietly count if !missing(t4v0560)
display as text "[TRACE t4 0229] count for t4v0560 = " r(N)
quietly count if !missing(t4v0571)
display as text "[TRACE t4 0230] count for t4v0571 = " r(N)
quietly count if !missing(t4v0582)
display as text "[TRACE t4 0231] count for t4v0582 = " r(N)
quietly count if !missing(t4v0593)
display as text "[TRACE t4 0232] count for t4v0593 = " r(N)
quietly count if !missing(t4v0604)
display as text "[TRACE t4 0233] count for t4v0604 = " r(N)
quietly count if !missing(t4v0615)
display as text "[TRACE t4 0234] count for t4v0615 = " r(N)
quietly count if !missing(t4v0626)
display as text "[TRACE t4 0235] count for t4v0626 = " r(N)
quietly count if !missing(t4v0637)
display as text "[TRACE t4 0236] count for t4v0637 = " r(N)
quietly count if !missing(t4v0648)
display as text "[TRACE t4 0237] count for t4v0648 = " r(N)
quietly count if !missing(t4v0659)
display as text "[TRACE t4 0238] count for t4v0659 = " r(N)
quietly summarize t4v0659, detail
display as text "[TRACE-DETAIL t4 0238] p50=" %9.4f r(p50)
quietly count if !missing(t4v0670)
display as text "[TRACE t4 0239] count for t4v0670 = " r(N)
quietly count if !missing(t4v0681)
display as text "[TRACE t4 0240] count for t4v0681 = " r(N)
quietly count if !missing(t4v0692)
display as text "[TRACE t4 0241] count for t4v0692 = " r(N)
quietly count if !missing(t4v0703)
display as text "[TRACE t4 0242] count for t4v0703 = " r(N)
quietly count if !missing(t4v0714)
display as text "[TRACE t4 0243] count for t4v0714 = " r(N)
quietly count if !missing(t4v0725)
display as text "[TRACE t4 0244] count for t4v0725 = " r(N)
quietly count if !missing(t4v0736)
display as text "[TRACE t4 0245] count for t4v0736 = " r(N)
quietly count if !missing(t4v0747)
display as text "[TRACE t4 0246] count for t4v0747 = " r(N)
quietly count if !missing(t4v0758)
display as text "[TRACE t4 0247] count for t4v0758 = " r(N)
quietly count if !missing(t4v0769)
display as text "[TRACE t4 0248] count for t4v0769 = " r(N)
quietly count if !missing(t4v0780)
display as text "[TRACE t4 0249] count for t4v0780 = " r(N)
quietly count if !missing(t4v0791)
display as text "[TRACE t4 0250] count for t4v0791 = " r(N)
quietly count if !missing(t4v0802)
display as text "[TRACE t4 0251] count for t4v0802 = " r(N)
quietly count if !missing(t4v0813)
display as text "[TRACE t4 0252] count for t4v0813 = " r(N)
quietly count if !missing(t4v0824)
display as text "[TRACE t4 0253] count for t4v0824 = " r(N)
quietly count if !missing(t4v0835)
display as text "[TRACE t4 0254] count for t4v0835 = " r(N)
quietly count if !missing(t4v0846)
display as text "[TRACE t4 0255] count for t4v0846 = " r(N)
quietly summarize t4v0846, detail
display as text "[TRACE-DETAIL t4 0255] p50=" %9.4f r(p50)
quietly count if !missing(t4v0857)
display as text "[TRACE t4 0256] count for t4v0857 = " r(N)
quietly count if !missing(t4v0868)
display as text "[TRACE t4 0257] count for t4v0868 = " r(N)
quietly count if !missing(t4v0879)
display as text "[TRACE t4 0258] count for t4v0879 = " r(N)
quietly count if !missing(t4v0890)
display as text "[TRACE t4 0259] count for t4v0890 = " r(N)
quietly count if !missing(t4v0901)
display as text "[TRACE t4 0260] count for t4v0901 = " r(N)
quietly count if !missing(t4v0912)
display as text "[TRACE t4 0261] count for t4v0912 = " r(N)
quietly count if !missing(t4v0923)
display as text "[TRACE t4 0262] count for t4v0923 = " r(N)
quietly count if !missing(t4v0934)
display as text "[TRACE t4 0263] count for t4v0934 = " r(N)
quietly count if !missing(t4v0945)
display as text "[TRACE t4 0264] count for t4v0945 = " r(N)
quietly count if !missing(t4v0956)
display as text "[TRACE t4 0265] count for t4v0956 = " r(N)
quietly count if !missing(t4v0967)
display as text "[TRACE t4 0266] count for t4v0967 = " r(N)
quietly count if !missing(t4v0978)
display as text "[TRACE t4 0267] count for t4v0978 = " r(N)
quietly count if !missing(t4v0009)
display as text "[TRACE t4 0268] count for t4v0009 = " r(N)
quietly count if !missing(t4v0020)
display as text "[TRACE t4 0269] count for t4v0020 = " r(N)
quietly count if !missing(t4v0031)
display as text "[TRACE t4 0270] count for t4v0031 = " r(N)
quietly count if !missing(t4v0042)
display as text "[TRACE t4 0271] count for t4v0042 = " r(N)
quietly count if !missing(t4v0053)
display as text "[TRACE t4 0272] count for t4v0053 = " r(N)
quietly summarize t4v0053, detail
display as text "[TRACE-DETAIL t4 0272] p50=" %9.4f r(p50)
quietly count if !missing(t4v0064)
display as text "[TRACE t4 0273] count for t4v0064 = " r(N)
quietly count if !missing(t4v0075)
display as text "[TRACE t4 0274] count for t4v0075 = " r(N)
quietly count if !missing(t4v0086)
display as text "[TRACE t4 0275] count for t4v0086 = " r(N)
quietly count if !missing(t4v0097)
display as text "[TRACE t4 0276] count for t4v0097 = " r(N)
quietly count if !missing(t4v0108)
display as text "[TRACE t4 0277] count for t4v0108 = " r(N)
quietly count if !missing(t4v0119)
display as text "[TRACE t4 0278] count for t4v0119 = " r(N)
quietly count if !missing(t4v0130)
display as text "[TRACE t4 0279] count for t4v0130 = " r(N)
quietly count if !missing(t4v0141)
display as text "[TRACE t4 0280] count for t4v0141 = " r(N)
quietly count if !missing(t4v0152)
display as text "[TRACE t4 0281] count for t4v0152 = " r(N)
quietly count if !missing(t4v0163)
display as text "[TRACE t4 0282] count for t4v0163 = " r(N)
quietly count if !missing(t4v0174)
display as text "[TRACE t4 0283] count for t4v0174 = " r(N)
quietly count if !missing(t4v0185)
display as text "[TRACE t4 0284] count for t4v0185 = " r(N)
quietly count if !missing(t4v0196)
display as text "[TRACE t4 0285] count for t4v0196 = " r(N)
quietly count if !missing(t4v0207)
display as text "[TRACE t4 0286] count for t4v0207 = " r(N)
quietly count if !missing(t4v0218)
display as text "[TRACE t4 0287] count for t4v0218 = " r(N)
quietly count if !missing(t4v0229)
display as text "[TRACE t4 0288] count for t4v0229 = " r(N)
quietly count if !missing(t4v0240)
display as text "[TRACE t4 0289] count for t4v0240 = " r(N)
quietly summarize t4v0240, detail
display as text "[TRACE-DETAIL t4 0289] p50=" %9.4f r(p50)
quietly count if !missing(t4v0251)
display as text "[TRACE t4 0290] count for t4v0251 = " r(N)
quietly count if !missing(t4v0262)
display as text "[TRACE t4 0291] count for t4v0262 = " r(N)
quietly count if !missing(t4v0273)
display as text "[TRACE t4 0292] count for t4v0273 = " r(N)
quietly count if !missing(t4v0284)
display as text "[TRACE t4 0293] count for t4v0284 = " r(N)
quietly count if !missing(t4v0295)
display as text "[TRACE t4 0294] count for t4v0295 = " r(N)
quietly count if !missing(t4v0306)
display as text "[TRACE t4 0295] count for t4v0306 = " r(N)
quietly count if !missing(t4v0317)
display as text "[TRACE t4 0296] count for t4v0317 = " r(N)
quietly count if !missing(t4v0328)
display as text "[TRACE t4 0297] count for t4v0328 = " r(N)
quietly count if !missing(t4v0339)
display as text "[TRACE t4 0298] count for t4v0339 = " r(N)
quietly count if !missing(t4v0350)
display as text "[TRACE t4 0299] count for t4v0350 = " r(N)
quietly count if !missing(t4v0361)
display as text "[TRACE t4 0300] count for t4v0361 = " r(N)
quietly count if !missing(t4v0372)
display as text "[TRACE t4 0301] count for t4v0372 = " r(N)
quietly count if !missing(t4v0383)
display as text "[TRACE t4 0302] count for t4v0383 = " r(N)
quietly count if !missing(t4v0394)
display as text "[TRACE t4 0303] count for t4v0394 = " r(N)
quietly count if !missing(t4v0405)
display as text "[TRACE t4 0304] count for t4v0405 = " r(N)
quietly count if !missing(t4v0416)
display as text "[TRACE t4 0305] count for t4v0416 = " r(N)
quietly count if !missing(t4v0427)
display as text "[TRACE t4 0306] count for t4v0427 = " r(N)
quietly summarize t4v0427, detail
display as text "[TRACE-DETAIL t4 0306] p50=" %9.4f r(p50)
quietly count if !missing(t4v0438)
display as text "[TRACE t4 0307] count for t4v0438 = " r(N)
quietly count if !missing(t4v0449)
display as text "[TRACE t4 0308] count for t4v0449 = " r(N)
quietly count if !missing(t4v0460)
display as text "[TRACE t4 0309] count for t4v0460 = " r(N)
quietly count if !missing(t4v0471)
display as text "[TRACE t4 0310] count for t4v0471 = " r(N)
quietly count if !missing(t4v0482)
display as text "[TRACE t4 0311] count for t4v0482 = " r(N)
quietly count if !missing(t4v0493)
display as text "[TRACE t4 0312] count for t4v0493 = " r(N)
quietly count if !missing(t4v0504)
display as text "[TRACE t4 0313] count for t4v0504 = " r(N)
quietly count if !missing(t4v0515)
display as text "[TRACE t4 0314] count for t4v0515 = " r(N)
quietly count if !missing(t4v0526)
display as text "[TRACE t4 0315] count for t4v0526 = " r(N)
quietly count if !missing(t4v0537)
display as text "[TRACE t4 0316] count for t4v0537 = " r(N)
quietly count if !missing(t4v0548)
display as text "[TRACE t4 0317] count for t4v0548 = " r(N)
quietly count if !missing(t4v0559)
display as text "[TRACE t4 0318] count for t4v0559 = " r(N)
quietly count if !missing(t4v0570)
display as text "[TRACE t4 0319] count for t4v0570 = " r(N)
quietly count if !missing(t4v0581)
display as text "[TRACE t4 0320] count for t4v0581 = " r(N)
quietly count if !missing(t4v0592)
display as text "[TRACE t4 0321] count for t4v0592 = " r(N)
quietly count if !missing(t4v0603)
display as text "[TRACE t4 0322] count for t4v0603 = " r(N)
quietly count if !missing(t4v0614)
display as text "[TRACE t4 0323] count for t4v0614 = " r(N)
quietly summarize t4v0614, detail
display as text "[TRACE-DETAIL t4 0323] p50=" %9.4f r(p50)
quietly count if !missing(t4v0625)
display as text "[TRACE t4 0324] count for t4v0625 = " r(N)
quietly count if !missing(t4v0636)
display as text "[TRACE t4 0325] count for t4v0636 = " r(N)
quietly count if !missing(t4v0647)
display as text "[TRACE t4 0326] count for t4v0647 = " r(N)
quietly count if !missing(t4v0658)
display as text "[TRACE t4 0327] count for t4v0658 = " r(N)
quietly count if !missing(t4v0669)
display as text "[TRACE t4 0328] count for t4v0669 = " r(N)
quietly count if !missing(t4v0680)
display as text "[TRACE t4 0329] count for t4v0680 = " r(N)
quietly count if !missing(t4v0691)
display as text "[TRACE t4 0330] count for t4v0691 = " r(N)
quietly count if !missing(t4v0702)
display as text "[TRACE t4 0331] count for t4v0702 = " r(N)
quietly count if !missing(t4v0713)
display as text "[TRACE t4 0332] count for t4v0713 = " r(N)
quietly count if !missing(t4v0724)
display as text "[TRACE t4 0333] count for t4v0724 = " r(N)
quietly count if !missing(t4v0735)
display as text "[TRACE t4 0334] count for t4v0735 = " r(N)
quietly count if !missing(t4v0746)
display as text "[TRACE t4 0335] count for t4v0746 = " r(N)
quietly count if !missing(t4v0757)
display as text "[TRACE t4 0336] count for t4v0757 = " r(N)
quietly count if !missing(t4v0768)
display as text "[TRACE t4 0337] count for t4v0768 = " r(N)
quietly count if !missing(t4v0779)
display as text "[TRACE t4 0338] count for t4v0779 = " r(N)
quietly count if !missing(t4v0790)
display as text "[TRACE t4 0339] count for t4v0790 = " r(N)
quietly count if !missing(t4v0801)
display as text "[TRACE t4 0340] count for t4v0801 = " r(N)
quietly summarize t4v0801, detail
display as text "[TRACE-DETAIL t4 0340] p50=" %9.4f r(p50)
quietly count if !missing(t4v0812)
display as text "[TRACE t4 0341] count for t4v0812 = " r(N)
quietly count if !missing(t4v0823)
display as text "[TRACE t4 0342] count for t4v0823 = " r(N)
quietly count if !missing(t4v0834)
display as text "[TRACE t4 0343] count for t4v0834 = " r(N)
quietly count if !missing(t4v0845)
display as text "[TRACE t4 0344] count for t4v0845 = " r(N)
quietly count if !missing(t4v0856)
display as text "[TRACE t4 0345] count for t4v0856 = " r(N)
quietly count if !missing(t4v0867)
display as text "[TRACE t4 0346] count for t4v0867 = " r(N)
quietly count if !missing(t4v0878)
display as text "[TRACE t4 0347] count for t4v0878 = " r(N)
quietly count if !missing(t4v0889)
display as text "[TRACE t4 0348] count for t4v0889 = " r(N)
quietly count if !missing(t4v0900)
display as text "[TRACE t4 0349] count for t4v0900 = " r(N)
quietly count if !missing(t4v0911)
display as text "[TRACE t4 0350] count for t4v0911 = " r(N)
quietly count if !missing(t4v0922)
display as text "[TRACE t4 0351] count for t4v0922 = " r(N)
quietly count if !missing(t4v0933)
display as text "[TRACE t4 0352] count for t4v0933 = " r(N)
quietly count if !missing(t4v0944)
display as text "[TRACE t4 0353] count for t4v0944 = " r(N)
quietly count if !missing(t4v0955)
display as text "[TRACE t4 0354] count for t4v0955 = " r(N)
quietly count if !missing(t4v0966)
display as text "[TRACE t4 0355] count for t4v0966 = " r(N)
quietly count if !missing(t4v0977)
display as text "[TRACE t4 0356] count for t4v0977 = " r(N)
quietly count if !missing(t4v0008)
display as text "[TRACE t4 0357] count for t4v0008 = " r(N)
quietly summarize t4v0008, detail
display as text "[TRACE-DETAIL t4 0357] p50=" %9.4f r(p50)
quietly count if !missing(t4v0019)
display as text "[TRACE t4 0358] count for t4v0019 = " r(N)
quietly count if !missing(t4v0030)
display as text "[TRACE t4 0359] count for t4v0030 = " r(N)
quietly count if !missing(t4v0041)
display as text "[TRACE t4 0360] count for t4v0041 = " r(N)
quietly count if !missing(t4v0052)
display as text "[TRACE t4 0361] count for t4v0052 = " r(N)
quietly count if !missing(t4v0063)
display as text "[TRACE t4 0362] count for t4v0063 = " r(N)
quietly count if !missing(t4v0074)
display as text "[TRACE t4 0363] count for t4v0074 = " r(N)
quietly count if !missing(t4v0085)
display as text "[TRACE t4 0364] count for t4v0085 = " r(N)
quietly count if !missing(t4v0096)
display as text "[TRACE t4 0365] count for t4v0096 = " r(N)
quietly count if !missing(t4v0107)
display as text "[TRACE t4 0366] count for t4v0107 = " r(N)
quietly count if !missing(t4v0118)
display as text "[TRACE t4 0367] count for t4v0118 = " r(N)
quietly count if !missing(t4v0129)
display as text "[TRACE t4 0368] count for t4v0129 = " r(N)
quietly count if !missing(t4v0140)
display as text "[TRACE t4 0369] count for t4v0140 = " r(N)
quietly count if !missing(t4v0151)
display as text "[TRACE t4 0370] count for t4v0151 = " r(N)
quietly count if !missing(t4v0162)
display as text "[TRACE t4 0371] count for t4v0162 = " r(N)
quietly count if !missing(t4v0173)
display as text "[TRACE t4 0372] count for t4v0173 = " r(N)
quietly count if !missing(t4v0184)
display as text "[TRACE t4 0373] count for t4v0184 = " r(N)
quietly count if !missing(t4v0195)
display as text "[TRACE t4 0374] count for t4v0195 = " r(N)
quietly summarize t4v0195, detail
display as text "[TRACE-DETAIL t4 0374] p50=" %9.4f r(p50)
quietly count if !missing(t4v0206)
display as text "[TRACE t4 0375] count for t4v0206 = " r(N)
quietly count if !missing(t4v0217)
display as text "[TRACE t4 0376] count for t4v0217 = " r(N)
quietly count if !missing(t4v0228)
display as text "[TRACE t4 0377] count for t4v0228 = " r(N)
quietly count if !missing(t4v0239)
display as text "[TRACE t4 0378] count for t4v0239 = " r(N)
quietly count if !missing(t4v0250)
display as text "[TRACE t4 0379] count for t4v0250 = " r(N)
quietly count if !missing(t4v0261)
display as text "[TRACE t4 0380] count for t4v0261 = " r(N)
quietly count if !missing(t4v0272)
display as text "[TRACE t4 0381] count for t4v0272 = " r(N)
quietly count if !missing(t4v0283)
display as text "[TRACE t4 0382] count for t4v0283 = " r(N)
quietly count if !missing(t4v0294)
display as text "[TRACE t4 0383] count for t4v0294 = " r(N)
quietly count if !missing(t4v0305)
display as text "[TRACE t4 0384] count for t4v0305 = " r(N)
quietly count if !missing(t4v0316)
display as text "[TRACE t4 0385] count for t4v0316 = " r(N)
quietly count if !missing(t4v0327)
display as text "[TRACE t4 0386] count for t4v0327 = " r(N)
quietly count if !missing(t4v0338)
display as text "[TRACE t4 0387] count for t4v0338 = " r(N)
quietly count if !missing(t4v0349)
display as text "[TRACE t4 0388] count for t4v0349 = " r(N)
quietly count if !missing(t4v0360)
display as text "[TRACE t4 0389] count for t4v0360 = " r(N)
quietly count if !missing(t4v0371)
display as text "[TRACE t4 0390] count for t4v0371 = " r(N)
quietly count if !missing(t4v0382)
display as text "[TRACE t4 0391] count for t4v0382 = " r(N)
quietly summarize t4v0382, detail
display as text "[TRACE-DETAIL t4 0391] p50=" %9.4f r(p50)
quietly count if !missing(t4v0393)
display as text "[TRACE t4 0392] count for t4v0393 = " r(N)
quietly count if !missing(t4v0404)
display as text "[TRACE t4 0393] count for t4v0404 = " r(N)
quietly count if !missing(t4v0415)
display as text "[TRACE t4 0394] count for t4v0415 = " r(N)
quietly count if !missing(t4v0426)
display as text "[TRACE t4 0395] count for t4v0426 = " r(N)
quietly count if !missing(t4v0437)
display as text "[TRACE t4 0396] count for t4v0437 = " r(N)
quietly count if !missing(t4v0448)
display as text "[TRACE t4 0397] count for t4v0448 = " r(N)
quietly count if !missing(t4v0459)
display as text "[TRACE t4 0398] count for t4v0459 = " r(N)
quietly count if !missing(t4v0470)
display as text "[TRACE t4 0399] count for t4v0470 = " r(N)
quietly count if !missing(t4v0481)
display as text "[TRACE t4 0400] count for t4v0481 = " r(N)
quietly count if !missing(t4v0492)
display as text "[TRACE t4 0401] count for t4v0492 = " r(N)
quietly count if !missing(t4v0503)
display as text "[TRACE t4 0402] count for t4v0503 = " r(N)
quietly count if !missing(t4v0514)
display as text "[TRACE t4 0403] count for t4v0514 = " r(N)
quietly count if !missing(t4v0525)
display as text "[TRACE t4 0404] count for t4v0525 = " r(N)
quietly count if !missing(t4v0536)
display as text "[TRACE t4 0405] count for t4v0536 = " r(N)
quietly count if !missing(t4v0547)
display as text "[TRACE t4 0406] count for t4v0547 = " r(N)
quietly count if !missing(t4v0558)
display as text "[TRACE t4 0407] count for t4v0558 = " r(N)
quietly count if !missing(t4v0569)
display as text "[TRACE t4 0408] count for t4v0569 = " r(N)
quietly summarize t4v0569, detail
display as text "[TRACE-DETAIL t4 0408] p50=" %9.4f r(p50)
quietly count if !missing(t4v0580)
display as text "[TRACE t4 0409] count for t4v0580 = " r(N)
quietly count if !missing(t4v0591)
display as text "[TRACE t4 0410] count for t4v0591 = " r(N)
quietly count if !missing(t4v0602)
display as text "[TRACE t4 0411] count for t4v0602 = " r(N)
quietly count if !missing(t4v0613)
display as text "[TRACE t4 0412] count for t4v0613 = " r(N)
quietly count if !missing(t4v0624)
display as text "[TRACE t4 0413] count for t4v0624 = " r(N)
quietly count if !missing(t4v0635)
display as text "[TRACE t4 0414] count for t4v0635 = " r(N)
quietly count if !missing(t4v0646)
display as text "[TRACE t4 0415] count for t4v0646 = " r(N)
quietly count if !missing(t4v0657)
display as text "[TRACE t4 0416] count for t4v0657 = " r(N)
quietly count if !missing(t4v0668)
display as text "[TRACE t4 0417] count for t4v0668 = " r(N)
quietly count if !missing(t4v0679)
display as text "[TRACE t4 0418] count for t4v0679 = " r(N)
quietly count if !missing(t4v0690)
display as text "[TRACE t4 0419] count for t4v0690 = " r(N)
quietly count if !missing(t4v0701)
display as text "[TRACE t4 0420] count for t4v0701 = " r(N)
quietly count if !missing(t4v0712)
display as text "[TRACE t4 0421] count for t4v0712 = " r(N)
quietly count if !missing(t4v0723)
display as text "[TRACE t4 0422] count for t4v0723 = " r(N)
quietly count if !missing(t4v0734)
display as text "[TRACE t4 0423] count for t4v0734 = " r(N)
quietly count if !missing(t4v0745)
display as text "[TRACE t4 0424] count for t4v0745 = " r(N)
quietly count if !missing(t4v0756)
display as text "[TRACE t4 0425] count for t4v0756 = " r(N)
quietly summarize t4v0756, detail
display as text "[TRACE-DETAIL t4 0425] p50=" %9.4f r(p50)
quietly count if !missing(t4v0767)
display as text "[TRACE t4 0426] count for t4v0767 = " r(N)
quietly count if !missing(t4v0778)
display as text "[TRACE t4 0427] count for t4v0778 = " r(N)
quietly count if !missing(t4v0789)
display as text "[TRACE t4 0428] count for t4v0789 = " r(N)
quietly count if !missing(t4v0800)
display as text "[TRACE t4 0429] count for t4v0800 = " r(N)
quietly count if !missing(t4v0811)
display as text "[TRACE t4 0430] count for t4v0811 = " r(N)
quietly count if !missing(t4v0822)
display as text "[TRACE t4 0431] count for t4v0822 = " r(N)
quietly count if !missing(t4v0833)
display as text "[TRACE t4 0432] count for t4v0833 = " r(N)
quietly count if !missing(t4v0844)
display as text "[TRACE t4 0433] count for t4v0844 = " r(N)
quietly count if !missing(t4v0855)
display as text "[TRACE t4 0434] count for t4v0855 = " r(N)
quietly count if !missing(t4v0866)
display as text "[TRACE t4 0435] count for t4v0866 = " r(N)
quietly count if !missing(t4v0877)
display as text "[TRACE t4 0436] count for t4v0877 = " r(N)
quietly count if !missing(t4v0888)
display as text "[TRACE t4 0437] count for t4v0888 = " r(N)
quietly count if !missing(t4v0899)
display as text "[TRACE t4 0438] count for t4v0899 = " r(N)
quietly count if !missing(t4v0910)
display as text "[TRACE t4 0439] count for t4v0910 = " r(N)
quietly count if !missing(t4v0921)
display as text "[TRACE t4 0440] count for t4v0921 = " r(N)
quietly count if !missing(t4v0932)
display as text "[TRACE t4 0441] count for t4v0932 = " r(N)
quietly count if !missing(t4v0943)
display as text "[TRACE t4 0442] count for t4v0943 = " r(N)
quietly summarize t4v0943, detail
display as text "[TRACE-DETAIL t4 0442] p50=" %9.4f r(p50)
quietly count if !missing(t4v0954)
display as text "[TRACE t4 0443] count for t4v0954 = " r(N)
quietly count if !missing(t4v0965)
display as text "[TRACE t4 0444] count for t4v0965 = " r(N)
quietly count if !missing(t4v0976)
display as text "[TRACE t4 0445] count for t4v0976 = " r(N)
quietly count if !missing(t4v0007)
display as text "[TRACE t4 0446] count for t4v0007 = " r(N)
quietly count if !missing(t4v0018)
display as text "[TRACE t4 0447] count for t4v0018 = " r(N)
quietly count if !missing(t4v0029)
display as text "[TRACE t4 0448] count for t4v0029 = " r(N)
quietly count if !missing(t4v0040)
display as text "[TRACE t4 0449] count for t4v0040 = " r(N)
quietly count if !missing(t4v0051)
display as text "[TRACE t4 0450] count for t4v0051 = " r(N)
quietly count if !missing(t4v0062)
display as text "[TRACE t4 0451] count for t4v0062 = " r(N)
quietly count if !missing(t4v0073)
display as text "[TRACE t4 0452] count for t4v0073 = " r(N)
quietly count if !missing(t4v0084)
display as text "[TRACE t4 0453] count for t4v0084 = " r(N)
quietly count if !missing(t4v0095)
display as text "[TRACE t4 0454] count for t4v0095 = " r(N)
quietly count if !missing(t4v0106)
display as text "[TRACE t4 0455] count for t4v0106 = " r(N)
quietly count if !missing(t4v0117)
display as text "[TRACE t4 0456] count for t4v0117 = " r(N)
quietly count if !missing(t4v0128)
display as text "[TRACE t4 0457] count for t4v0128 = " r(N)
quietly count if !missing(t4v0139)
display as text "[TRACE t4 0458] count for t4v0139 = " r(N)
quietly count if !missing(t4v0150)
display as text "[TRACE t4 0459] count for t4v0150 = " r(N)
quietly summarize t4v0150, detail
display as text "[TRACE-DETAIL t4 0459] p50=" %9.4f r(p50)
quietly count if !missing(t4v0161)
display as text "[TRACE t4 0460] count for t4v0161 = " r(N)
quietly count if !missing(t4v0172)
display as text "[TRACE t4 0461] count for t4v0172 = " r(N)
quietly count if !missing(t4v0183)
display as text "[TRACE t4 0462] count for t4v0183 = " r(N)
quietly count if !missing(t4v0194)
display as text "[TRACE t4 0463] count for t4v0194 = " r(N)
quietly count if !missing(t4v0205)
display as text "[TRACE t4 0464] count for t4v0205 = " r(N)
quietly count if !missing(t4v0216)
display as text "[TRACE t4 0465] count for t4v0216 = " r(N)
quietly count if !missing(t4v0227)
display as text "[TRACE t4 0466] count for t4v0227 = " r(N)
quietly count if !missing(t4v0238)
display as text "[TRACE t4 0467] count for t4v0238 = " r(N)
quietly count if !missing(t4v0249)
display as text "[TRACE t4 0468] count for t4v0249 = " r(N)
quietly count if !missing(t4v0260)
display as text "[TRACE t4 0469] count for t4v0260 = " r(N)
quietly count if !missing(t4v0271)
display as text "[TRACE t4 0470] count for t4v0271 = " r(N)
quietly count if !missing(t4v0282)
display as text "[TRACE t4 0471] count for t4v0282 = " r(N)
quietly count if !missing(t4v0293)
display as text "[TRACE t4 0472] count for t4v0293 = " r(N)
quietly count if !missing(t4v0304)
display as text "[TRACE t4 0473] count for t4v0304 = " r(N)
quietly count if !missing(t4v0315)
display as text "[TRACE t4 0474] count for t4v0315 = " r(N)
quietly count if !missing(t4v0326)
display as text "[TRACE t4 0475] count for t4v0326 = " r(N)
quietly count if !missing(t4v0337)
display as text "[TRACE t4 0476] count for t4v0337 = " r(N)
quietly summarize t4v0337, detail
display as text "[TRACE-DETAIL t4 0476] p50=" %9.4f r(p50)
quietly count if !missing(t4v0348)
display as text "[TRACE t4 0477] count for t4v0348 = " r(N)
quietly count if !missing(t4v0359)
display as text "[TRACE t4 0478] count for t4v0359 = " r(N)
quietly count if !missing(t4v0370)
display as text "[TRACE t4 0479] count for t4v0370 = " r(N)
quietly count if !missing(t4v0381)
display as text "[TRACE t4 0480] count for t4v0381 = " r(N)
quietly count if !missing(t4v0392)
display as text "[TRACE t4 0481] count for t4v0392 = " r(N)
quietly count if !missing(t4v0403)
display as text "[TRACE t4 0482] count for t4v0403 = " r(N)
quietly count if !missing(t4v0414)
display as text "[TRACE t4 0483] count for t4v0414 = " r(N)
quietly count if !missing(t4v0425)
display as text "[TRACE t4 0484] count for t4v0425 = " r(N)
quietly count if !missing(t4v0436)
display as text "[TRACE t4 0485] count for t4v0436 = " r(N)
quietly count if !missing(t4v0447)
display as text "[TRACE t4 0486] count for t4v0447 = " r(N)
quietly count if !missing(t4v0458)
display as text "[TRACE t4 0487] count for t4v0458 = " r(N)
quietly count if !missing(t4v0469)
display as text "[TRACE t4 0488] count for t4v0469 = " r(N)
quietly count if !missing(t4v0480)
display as text "[TRACE t4 0489] count for t4v0480 = " r(N)
quietly count if !missing(t4v0491)
display as text "[TRACE t4 0490] count for t4v0491 = " r(N)
quietly count if !missing(t4v0502)
display as text "[TRACE t4 0491] count for t4v0502 = " r(N)
quietly count if !missing(t4v0513)
display as text "[TRACE t4 0492] count for t4v0513 = " r(N)
quietly count if !missing(t4v0524)
display as text "[TRACE t4 0493] count for t4v0524 = " r(N)
quietly summarize t4v0524, detail
display as text "[TRACE-DETAIL t4 0493] p50=" %9.4f r(p50)
quietly count if !missing(t4v0535)
display as text "[TRACE t4 0494] count for t4v0535 = " r(N)
quietly count if !missing(t4v0546)
display as text "[TRACE t4 0495] count for t4v0546 = " r(N)
quietly count if !missing(t4v0557)
display as text "[TRACE t4 0496] count for t4v0557 = " r(N)
quietly count if !missing(t4v0568)
display as text "[TRACE t4 0497] count for t4v0568 = " r(N)
quietly count if !missing(t4v0579)
display as text "[TRACE t4 0498] count for t4v0579 = " r(N)
quietly count if !missing(t4v0590)
display as text "[TRACE t4 0499] count for t4v0590 = " r(N)
quietly count if !missing(t4v0601)
display as text "[TRACE t4 0500] count for t4v0601 = " r(N)
quietly count if !missing(t4v0612)
display as text "[TRACE t4 0501] count for t4v0612 = " r(N)
quietly count if !missing(t4v0623)
display as text "[TRACE t4 0502] count for t4v0623 = " r(N)
quietly count if !missing(t4v0634)
display as text "[TRACE t4 0503] count for t4v0634 = " r(N)
quietly count if !missing(t4v0645)
display as text "[TRACE t4 0504] count for t4v0645 = " r(N)
quietly count if !missing(t4v0656)
display as text "[TRACE t4 0505] count for t4v0656 = " r(N)
quietly count if !missing(t4v0667)
display as text "[TRACE t4 0506] count for t4v0667 = " r(N)
quietly count if !missing(t4v0678)
display as text "[TRACE t4 0507] count for t4v0678 = " r(N)
quietly count if !missing(t4v0689)
display as text "[TRACE t4 0508] count for t4v0689 = " r(N)
quietly count if !missing(t4v0700)
display as text "[TRACE t4 0509] count for t4v0700 = " r(N)
quietly count if !missing(t4v0711)
display as text "[TRACE t4 0510] count for t4v0711 = " r(N)
quietly summarize t4v0711, detail
display as text "[TRACE-DETAIL t4 0510] p50=" %9.4f r(p50)
quietly count if !missing(t4v0722)
display as text "[TRACE t4 0511] count for t4v0722 = " r(N)
quietly count if !missing(t4v0733)
display as text "[TRACE t4 0512] count for t4v0733 = " r(N)
quietly count if !missing(t4v0744)
display as text "[TRACE t4 0513] count for t4v0744 = " r(N)
quietly count if !missing(t4v0755)
display as text "[TRACE t4 0514] count for t4v0755 = " r(N)
quietly count if !missing(t4v0766)
display as text "[TRACE t4 0515] count for t4v0766 = " r(N)
quietly count if !missing(t4v0777)
display as text "[TRACE t4 0516] count for t4v0777 = " r(N)
quietly count if !missing(t4v0788)
display as text "[TRACE t4 0517] count for t4v0788 = " r(N)
quietly count if !missing(t4v0799)
display as text "[TRACE t4 0518] count for t4v0799 = " r(N)
quietly count if !missing(t4v0810)
display as text "[TRACE t4 0519] count for t4v0810 = " r(N)
quietly count if !missing(t4v0821)
display as text "[TRACE t4 0520] count for t4v0821 = " r(N)
quietly count if !missing(t4v0832)
display as text "[TRACE t4 0521] count for t4v0832 = " r(N)
quietly count if !missing(t4v0843)
display as text "[TRACE t4 0522] count for t4v0843 = " r(N)
quietly count if !missing(t4v0854)
display as text "[TRACE t4 0523] count for t4v0854 = " r(N)
quietly count if !missing(t4v0865)
display as text "[TRACE t4 0524] count for t4v0865 = " r(N)
quietly count if !missing(t4v0876)
display as text "[TRACE t4 0525] count for t4v0876 = " r(N)
quietly count if !missing(t4v0887)
display as text "[TRACE t4 0526] count for t4v0887 = " r(N)
quietly count if !missing(t4v0898)
display as text "[TRACE t4 0527] count for t4v0898 = " r(N)
quietly summarize t4v0898, detail
display as text "[TRACE-DETAIL t4 0527] p50=" %9.4f r(p50)
quietly count if !missing(t4v0909)
display as text "[TRACE t4 0528] count for t4v0909 = " r(N)
quietly count if !missing(t4v0920)
display as text "[TRACE t4 0529] count for t4v0920 = " r(N)
quietly count if !missing(t4v0931)
display as text "[TRACE t4 0530] count for t4v0931 = " r(N)
quietly count if !missing(t4v0942)
display as text "[TRACE t4 0531] count for t4v0942 = " r(N)
quietly count if !missing(t4v0953)
display as text "[TRACE t4 0532] count for t4v0953 = " r(N)
quietly count if !missing(t4v0964)
display as text "[TRACE t4 0533] count for t4v0964 = " r(N)
quietly count if !missing(t4v0975)
display as text "[TRACE t4 0534] count for t4v0975 = " r(N)
quietly count if !missing(t4v0006)
display as text "[TRACE t4 0535] count for t4v0006 = " r(N)
quietly count if !missing(t4v0017)
display as text "[TRACE t4 0536] count for t4v0017 = " r(N)
quietly count if !missing(t4v0028)
display as text "[TRACE t4 0537] count for t4v0028 = " r(N)
quietly count if !missing(t4v0039)
display as text "[TRACE t4 0538] count for t4v0039 = " r(N)
quietly count if !missing(t4v0050)
display as text "[TRACE t4 0539] count for t4v0050 = " r(N)
quietly count if !missing(t4v0061)
display as text "[TRACE t4 0540] count for t4v0061 = " r(N)
quietly count if !missing(t4v0072)
display as text "[TRACE t4 0541] count for t4v0072 = " r(N)
quietly count if !missing(t4v0083)
display as text "[TRACE t4 0542] count for t4v0083 = " r(N)
quietly count if !missing(t4v0094)
display as text "[TRACE t4 0543] count for t4v0094 = " r(N)
quietly count if !missing(t4v0105)
display as text "[TRACE t4 0544] count for t4v0105 = " r(N)
quietly summarize t4v0105, detail
display as text "[TRACE-DETAIL t4 0544] p50=" %9.4f r(p50)
quietly count if !missing(t4v0116)
display as text "[TRACE t4 0545] count for t4v0116 = " r(N)
quietly count if !missing(t4v0127)
display as text "[TRACE t4 0546] count for t4v0127 = " r(N)
quietly count if !missing(t4v0138)
display as text "[TRACE t4 0547] count for t4v0138 = " r(N)
quietly count if !missing(t4v0149)
display as text "[TRACE t4 0548] count for t4v0149 = " r(N)
quietly count if !missing(t4v0160)
display as text "[TRACE t4 0549] count for t4v0160 = " r(N)
quietly count if !missing(t4v0171)
display as text "[TRACE t4 0550] count for t4v0171 = " r(N)
quietly count if !missing(t4v0182)
display as text "[TRACE t4 0551] count for t4v0182 = " r(N)
quietly count if !missing(t4v0193)
display as text "[TRACE t4 0552] count for t4v0193 = " r(N)
quietly count if !missing(t4v0204)
display as text "[TRACE t4 0553] count for t4v0204 = " r(N)
quietly count if !missing(t4v0215)
display as text "[TRACE t4 0554] count for t4v0215 = " r(N)
quietly count if !missing(t4v0226)
display as text "[TRACE t4 0555] count for t4v0226 = " r(N)
quietly count if !missing(t4v0237)
display as text "[TRACE t4 0556] count for t4v0237 = " r(N)
quietly count if !missing(t4v0248)
display as text "[TRACE t4 0557] count for t4v0248 = " r(N)
quietly count if !missing(t4v0259)
display as text "[TRACE t4 0558] count for t4v0259 = " r(N)
quietly count if !missing(t4v0270)
display as text "[TRACE t4 0559] count for t4v0270 = " r(N)
quietly count if !missing(t4v0281)
display as text "[TRACE t4 0560] count for t4v0281 = " r(N)
quietly count if !missing(t4v0292)
display as text "[TRACE t4 0561] count for t4v0292 = " r(N)
quietly summarize t4v0292, detail
display as text "[TRACE-DETAIL t4 0561] p50=" %9.4f r(p50)
quietly count if !missing(t4v0303)
display as text "[TRACE t4 0562] count for t4v0303 = " r(N)
quietly count if !missing(t4v0314)
display as text "[TRACE t4 0563] count for t4v0314 = " r(N)
quietly count if !missing(t4v0325)
display as text "[TRACE t4 0564] count for t4v0325 = " r(N)
quietly count if !missing(t4v0336)
display as text "[TRACE t4 0565] count for t4v0336 = " r(N)
quietly count if !missing(t4v0347)
display as text "[TRACE t4 0566] count for t4v0347 = " r(N)
quietly count if !missing(t4v0358)
display as text "[TRACE t4 0567] count for t4v0358 = " r(N)
quietly count if !missing(t4v0369)
display as text "[TRACE t4 0568] count for t4v0369 = " r(N)
quietly count if !missing(t4v0380)
display as text "[TRACE t4 0569] count for t4v0380 = " r(N)
quietly count if !missing(t4v0391)
display as text "[TRACE t4 0570] count for t4v0391 = " r(N)
quietly count if !missing(t4v0402)
display as text "[TRACE t4 0571] count for t4v0402 = " r(N)
quietly count if !missing(t4v0413)
display as text "[TRACE t4 0572] count for t4v0413 = " r(N)
quietly count if !missing(t4v0424)
display as text "[TRACE t4 0573] count for t4v0424 = " r(N)
quietly count if !missing(t4v0435)
display as text "[TRACE t4 0574] count for t4v0435 = " r(N)
quietly count if !missing(t4v0446)
display as text "[TRACE t4 0575] count for t4v0446 = " r(N)
quietly count if !missing(t4v0457)
display as text "[TRACE t4 0576] count for t4v0457 = " r(N)
quietly count if !missing(t4v0468)
display as text "[TRACE t4 0577] count for t4v0468 = " r(N)
quietly count if !missing(t4v0479)
display as text "[TRACE t4 0578] count for t4v0479 = " r(N)
quietly summarize t4v0479, detail
display as text "[TRACE-DETAIL t4 0578] p50=" %9.4f r(p50)
quietly count if !missing(t4v0490)
display as text "[TRACE t4 0579] count for t4v0490 = " r(N)
quietly count if !missing(t4v0501)
display as text "[TRACE t4 0580] count for t4v0501 = " r(N)
quietly count if !missing(t4v0512)
display as text "[TRACE t4 0581] count for t4v0512 = " r(N)
quietly count if !missing(t4v0523)
display as text "[TRACE t4 0582] count for t4v0523 = " r(N)
quietly count if !missing(t4v0534)
display as text "[TRACE t4 0583] count for t4v0534 = " r(N)
quietly count if !missing(t4v0545)
display as text "[TRACE t4 0584] count for t4v0545 = " r(N)
quietly count if !missing(t4v0556)
display as text "[TRACE t4 0585] count for t4v0556 = " r(N)
quietly count if !missing(t4v0567)
display as text "[TRACE t4 0586] count for t4v0567 = " r(N)
quietly count if !missing(t4v0578)
display as text "[TRACE t4 0587] count for t4v0578 = " r(N)
quietly count if !missing(t4v0589)
display as text "[TRACE t4 0588] count for t4v0589 = " r(N)
quietly count if !missing(t4v0600)
display as text "[TRACE t4 0589] count for t4v0600 = " r(N)
quietly count if !missing(t4v0611)
display as text "[TRACE t4 0590] count for t4v0611 = " r(N)
quietly count if !missing(t4v0622)
display as text "[TRACE t4 0591] count for t4v0622 = " r(N)
quietly count if !missing(t4v0633)
display as text "[TRACE t4 0592] count for t4v0633 = " r(N)
quietly count if !missing(t4v0644)
display as text "[TRACE t4 0593] count for t4v0644 = " r(N)
quietly count if !missing(t4v0655)
display as text "[TRACE t4 0594] count for t4v0655 = " r(N)
quietly count if !missing(t4v0666)
display as text "[TRACE t4 0595] count for t4v0666 = " r(N)
quietly summarize t4v0666, detail
display as text "[TRACE-DETAIL t4 0595] p50=" %9.4f r(p50)
quietly count if !missing(t4v0677)
display as text "[TRACE t4 0596] count for t4v0677 = " r(N)
quietly count if !missing(t4v0688)
display as text "[TRACE t4 0597] count for t4v0688 = " r(N)
quietly count if !missing(t4v0699)
display as text "[TRACE t4 0598] count for t4v0699 = " r(N)
quietly count if !missing(t4v0710)
display as text "[TRACE t4 0599] count for t4v0710 = " r(N)
quietly count if !missing(t4v0721)
display as text "[TRACE t4 0600] count for t4v0721 = " r(N)
quietly count if !missing(t4v0732)
display as text "[TRACE t4 0601] count for t4v0732 = " r(N)
quietly count if !missing(t4v0743)
display as text "[TRACE t4 0602] count for t4v0743 = " r(N)
quietly count if !missing(t4v0754)
display as text "[TRACE t4 0603] count for t4v0754 = " r(N)
quietly count if !missing(t4v0765)
display as text "[TRACE t4 0604] count for t4v0765 = " r(N)
quietly count if !missing(t4v0776)
display as text "[TRACE t4 0605] count for t4v0776 = " r(N)
quietly count if !missing(t4v0787)
display as text "[TRACE t4 0606] count for t4v0787 = " r(N)
quietly count if !missing(t4v0798)
display as text "[TRACE t4 0607] count for t4v0798 = " r(N)
quietly count if !missing(t4v0809)
display as text "[TRACE t4 0608] count for t4v0809 = " r(N)
quietly count if !missing(t4v0820)
display as text "[TRACE t4 0609] count for t4v0820 = " r(N)
quietly count if !missing(t4v0831)
display as text "[TRACE t4 0610] count for t4v0831 = " r(N)
quietly count if !missing(t4v0842)
display as text "[TRACE t4 0611] count for t4v0842 = " r(N)
quietly count if !missing(t4v0853)
display as text "[TRACE t4 0612] count for t4v0853 = " r(N)
quietly summarize t4v0853, detail
display as text "[TRACE-DETAIL t4 0612] p50=" %9.4f r(p50)
quietly count if !missing(t4v0864)
display as text "[TRACE t4 0613] count for t4v0864 = " r(N)
quietly count if !missing(t4v0875)
display as text "[TRACE t4 0614] count for t4v0875 = " r(N)
quietly count if !missing(t4v0886)
display as text "[TRACE t4 0615] count for t4v0886 = " r(N)
quietly count if !missing(t4v0897)
display as text "[TRACE t4 0616] count for t4v0897 = " r(N)
quietly count if !missing(t4v0908)
display as text "[TRACE t4 0617] count for t4v0908 = " r(N)
quietly count if !missing(t4v0919)
display as text "[TRACE t4 0618] count for t4v0919 = " r(N)
quietly count if !missing(t4v0930)
display as text "[TRACE t4 0619] count for t4v0930 = " r(N)
quietly count if !missing(t4v0941)
display as text "[TRACE t4 0620] count for t4v0941 = " r(N)
quietly count if !missing(t4v0952)
display as text "[TRACE t4 0621] count for t4v0952 = " r(N)
quietly count if !missing(t4v0963)
display as text "[TRACE t4 0622] count for t4v0963 = " r(N)
quietly count if !missing(t4v0974)
display as text "[TRACE t4 0623] count for t4v0974 = " r(N)
quietly count if !missing(t4v0005)
display as text "[TRACE t4 0624] count for t4v0005 = " r(N)
quietly count if !missing(t4v0016)
display as text "[TRACE t4 0625] count for t4v0016 = " r(N)
quietly count if !missing(t4v0027)
display as text "[TRACE t4 0626] count for t4v0027 = " r(N)
quietly count if !missing(t4v0038)
display as text "[TRACE t4 0627] count for t4v0038 = " r(N)
quietly count if !missing(t4v0049)
display as text "[TRACE t4 0628] count for t4v0049 = " r(N)
quietly count if !missing(t4v0060)
display as text "[TRACE t4 0629] count for t4v0060 = " r(N)
quietly summarize t4v0060, detail
display as text "[TRACE-DETAIL t4 0629] p50=" %9.4f r(p50)
quietly count if !missing(t4v0071)
display as text "[TRACE t4 0630] count for t4v0071 = " r(N)
quietly count if !missing(t4v0082)
display as text "[TRACE t4 0631] count for t4v0082 = " r(N)
quietly count if !missing(t4v0093)
display as text "[TRACE t4 0632] count for t4v0093 = " r(N)
quietly count if !missing(t4v0104)
display as text "[TRACE t4 0633] count for t4v0104 = " r(N)
quietly count if !missing(t4v0115)
display as text "[TRACE t4 0634] count for t4v0115 = " r(N)
quietly count if !missing(t4v0126)
display as text "[TRACE t4 0635] count for t4v0126 = " r(N)
quietly count if !missing(t4v0137)
display as text "[TRACE t4 0636] count for t4v0137 = " r(N)
quietly count if !missing(t4v0148)
display as text "[TRACE t4 0637] count for t4v0148 = " r(N)
quietly count if !missing(t4v0159)
display as text "[TRACE t4 0638] count for t4v0159 = " r(N)
quietly count if !missing(t4v0170)
display as text "[TRACE t4 0639] count for t4v0170 = " r(N)
quietly count if !missing(t4v0181)
display as text "[TRACE t4 0640] count for t4v0181 = " r(N)
quietly count if !missing(t4v0192)
display as text "[TRACE t4 0641] count for t4v0192 = " r(N)
quietly count if !missing(t4v0203)
display as text "[TRACE t4 0642] count for t4v0203 = " r(N)
quietly count if !missing(t4v0214)
display as text "[TRACE t4 0643] count for t4v0214 = " r(N)
quietly count if !missing(t4v0225)
display as text "[TRACE t4 0644] count for t4v0225 = " r(N)
quietly count if !missing(t4v0236)
display as text "[TRACE t4 0645] count for t4v0236 = " r(N)
quietly count if !missing(t4v0247)
display as text "[TRACE t4 0646] count for t4v0247 = " r(N)
quietly summarize t4v0247, detail
display as text "[TRACE-DETAIL t4 0646] p50=" %9.4f r(p50)
quietly count if !missing(t4v0258)
display as text "[TRACE t4 0647] count for t4v0258 = " r(N)
quietly count if !missing(t4v0269)
display as text "[TRACE t4 0648] count for t4v0269 = " r(N)
quietly count if !missing(t4v0280)
display as text "[TRACE t4 0649] count for t4v0280 = " r(N)
quietly count if !missing(t4v0291)
display as text "[TRACE t4 0650] count for t4v0291 = " r(N)
quietly count if !missing(t4v0302)
display as text "[TRACE t4 0651] count for t4v0302 = " r(N)
quietly count if !missing(t4v0313)
display as text "[TRACE t4 0652] count for t4v0313 = " r(N)
quietly count if !missing(t4v0324)
display as text "[TRACE t4 0653] count for t4v0324 = " r(N)
quietly count if !missing(t4v0335)
display as text "[TRACE t4 0654] count for t4v0335 = " r(N)
quietly count if !missing(t4v0346)
display as text "[TRACE t4 0655] count for t4v0346 = " r(N)
quietly count if !missing(t4v0357)
display as text "[TRACE t4 0656] count for t4v0357 = " r(N)
quietly count if !missing(t4v0368)
display as text "[TRACE t4 0657] count for t4v0368 = " r(N)
quietly count if !missing(t4v0379)
display as text "[TRACE t4 0658] count for t4v0379 = " r(N)
quietly count if !missing(t4v0390)
display as text "[TRACE t4 0659] count for t4v0390 = " r(N)
quietly count if !missing(t4v0401)
display as text "[TRACE t4 0660] count for t4v0401 = " r(N)
quietly count if !missing(t4v0412)
display as text "[TRACE t4 0661] count for t4v0412 = " r(N)
quietly count if !missing(t4v0423)
display as text "[TRACE t4 0662] count for t4v0423 = " r(N)
quietly count if !missing(t4v0434)
display as text "[TRACE t4 0663] count for t4v0434 = " r(N)
quietly summarize t4v0434, detail
display as text "[TRACE-DETAIL t4 0663] p50=" %9.4f r(p50)
quietly count if !missing(t4v0445)
display as text "[TRACE t4 0664] count for t4v0445 = " r(N)
quietly count if !missing(t4v0456)
display as text "[TRACE t4 0665] count for t4v0456 = " r(N)
quietly count if !missing(t4v0467)
display as text "[TRACE t4 0666] count for t4v0467 = " r(N)
quietly count if !missing(t4v0478)
display as text "[TRACE t4 0667] count for t4v0478 = " r(N)
quietly count if !missing(t4v0489)
display as text "[TRACE t4 0668] count for t4v0489 = " r(N)
quietly count if !missing(t4v0500)
display as text "[TRACE t4 0669] count for t4v0500 = " r(N)
quietly count if !missing(t4v0511)
display as text "[TRACE t4 0670] count for t4v0511 = " r(N)
quietly count if !missing(t4v0522)
display as text "[TRACE t4 0671] count for t4v0522 = " r(N)
quietly count if !missing(t4v0533)
display as text "[TRACE t4 0672] count for t4v0533 = " r(N)
quietly count if !missing(t4v0544)
display as text "[TRACE t4 0673] count for t4v0544 = " r(N)
quietly count if !missing(t4v0555)
display as text "[TRACE t4 0674] count for t4v0555 = " r(N)
quietly count if !missing(t4v0566)
display as text "[TRACE t4 0675] count for t4v0566 = " r(N)
quietly count if !missing(t4v0577)
display as text "[TRACE t4 0676] count for t4v0577 = " r(N)
quietly count if !missing(t4v0588)
display as text "[TRACE t4 0677] count for t4v0588 = " r(N)
quietly count if !missing(t4v0599)
display as text "[TRACE t4 0678] count for t4v0599 = " r(N)
quietly count if !missing(t4v0610)
display as text "[TRACE t4 0679] count for t4v0610 = " r(N)
quietly count if !missing(t4v0621)
display as text "[TRACE t4 0680] count for t4v0621 = " r(N)
quietly summarize t4v0621, detail
display as text "[TRACE-DETAIL t4 0680] p50=" %9.4f r(p50)
quietly count if !missing(t4v0632)
display as text "[TRACE t4 0681] count for t4v0632 = " r(N)
quietly count if !missing(t4v0643)
display as text "[TRACE t4 0682] count for t4v0643 = " r(N)
quietly count if !missing(t4v0654)
display as text "[TRACE t4 0683] count for t4v0654 = " r(N)
quietly count if !missing(t4v0665)
display as text "[TRACE t4 0684] count for t4v0665 = " r(N)
quietly count if !missing(t4v0676)
display as text "[TRACE t4 0685] count for t4v0676 = " r(N)
quietly count if !missing(t4v0687)
display as text "[TRACE t4 0686] count for t4v0687 = " r(N)
quietly count if !missing(t4v0698)
display as text "[TRACE t4 0687] count for t4v0698 = " r(N)
quietly count if !missing(t4v0709)
display as text "[TRACE t4 0688] count for t4v0709 = " r(N)
quietly count if !missing(t4v0720)
display as text "[TRACE t4 0689] count for t4v0720 = " r(N)
quietly count if !missing(t4v0731)
display as text "[TRACE t4 0690] count for t4v0731 = " r(N)
quietly count if !missing(t4v0742)
display as text "[TRACE t4 0691] count for t4v0742 = " r(N)
quietly count if !missing(t4v0753)
display as text "[TRACE t4 0692] count for t4v0753 = " r(N)
quietly count if !missing(t4v0764)
display as text "[TRACE t4 0693] count for t4v0764 = " r(N)
quietly count if !missing(t4v0775)
display as text "[TRACE t4 0694] count for t4v0775 = " r(N)
quietly count if !missing(t4v0786)
display as text "[TRACE t4 0695] count for t4v0786 = " r(N)
quietly count if !missing(t4v0797)
display as text "[TRACE t4 0696] count for t4v0797 = " r(N)
quietly count if !missing(t4v0808)
display as text "[TRACE t4 0697] count for t4v0808 = " r(N)
quietly summarize t4v0808, detail
display as text "[TRACE-DETAIL t4 0697] p50=" %9.4f r(p50)
quietly count if !missing(t4v0819)
display as text "[TRACE t4 0698] count for t4v0819 = " r(N)
quietly count if !missing(t4v0830)
display as text "[TRACE t4 0699] count for t4v0830 = " r(N)
quietly count if !missing(t4v0841)
display as text "[TRACE t4 0700] count for t4v0841 = " r(N)
quietly count if !missing(t4v0852)
display as text "[TRACE t4 0701] count for t4v0852 = " r(N)
quietly count if !missing(t4v0863)
display as text "[TRACE t4 0702] count for t4v0863 = " r(N)
quietly count if !missing(t4v0874)
display as text "[TRACE t4 0703] count for t4v0874 = " r(N)
quietly count if !missing(t4v0885)
display as text "[TRACE t4 0704] count for t4v0885 = " r(N)
quietly count if !missing(t4v0896)
display as text "[TRACE t4 0705] count for t4v0896 = " r(N)
quietly count if !missing(t4v0907)
display as text "[TRACE t4 0706] count for t4v0907 = " r(N)
quietly count if !missing(t4v0918)
display as text "[TRACE t4 0707] count for t4v0918 = " r(N)
quietly count if !missing(t4v0929)
display as text "[TRACE t4 0708] count for t4v0929 = " r(N)
quietly count if !missing(t4v0940)
display as text "[TRACE t4 0709] count for t4v0940 = " r(N)
quietly count if !missing(t4v0951)
display as text "[TRACE t4 0710] count for t4v0951 = " r(N)
quietly count if !missing(t4v0962)
display as text "[TRACE t4 0711] count for t4v0962 = " r(N)
quietly count if !missing(t4v0973)
display as text "[TRACE t4 0712] count for t4v0973 = " r(N)
quietly count if !missing(t4v0004)
display as text "[TRACE t4 0713] count for t4v0004 = " r(N)
quietly count if !missing(t4v0015)
display as text "[TRACE t4 0714] count for t4v0015 = " r(N)
quietly summarize t4v0015, detail
display as text "[TRACE-DETAIL t4 0714] p50=" %9.4f r(p50)
quietly count if !missing(t4v0026)
display as text "[TRACE t4 0715] count for t4v0026 = " r(N)
quietly count if !missing(t4v0037)
display as text "[TRACE t4 0716] count for t4v0037 = " r(N)
quietly count if !missing(t4v0048)
display as text "[TRACE t4 0717] count for t4v0048 = " r(N)
quietly count if !missing(t4v0059)
display as text "[TRACE t4 0718] count for t4v0059 = " r(N)
quietly count if !missing(t4v0070)
display as text "[TRACE t4 0719] count for t4v0070 = " r(N)
quietly count if !missing(t4v0081)
display as text "[TRACE t4 0720] count for t4v0081 = " r(N)
quietly count if !missing(t4v0092)
display as text "[TRACE t4 0721] count for t4v0092 = " r(N)
quietly count if !missing(t4v0103)
display as text "[TRACE t4 0722] count for t4v0103 = " r(N)
quietly count if !missing(t4v0114)
display as text "[TRACE t4 0723] count for t4v0114 = " r(N)
quietly count if !missing(t4v0125)
display as text "[TRACE t4 0724] count for t4v0125 = " r(N)
quietly count if !missing(t4v0136)
display as text "[TRACE t4 0725] count for t4v0136 = " r(N)
quietly count if !missing(t4v0147)
display as text "[TRACE t4 0726] count for t4v0147 = " r(N)
quietly count if !missing(t4v0158)
display as text "[TRACE t4 0727] count for t4v0158 = " r(N)
quietly count if !missing(t4v0169)
display as text "[TRACE t4 0728] count for t4v0169 = " r(N)
quietly count if !missing(t4v0180)
display as text "[TRACE t4 0729] count for t4v0180 = " r(N)
quietly count if !missing(t4v0191)
display as text "[TRACE t4 0730] count for t4v0191 = " r(N)
quietly count if !missing(t4v0202)
display as text "[TRACE t4 0731] count for t4v0202 = " r(N)
quietly summarize t4v0202, detail
display as text "[TRACE-DETAIL t4 0731] p50=" %9.4f r(p50)
quietly count if !missing(t4v0213)
display as text "[TRACE t4 0732] count for t4v0213 = " r(N)
quietly count if !missing(t4v0224)
display as text "[TRACE t4 0733] count for t4v0224 = " r(N)
quietly count if !missing(t4v0235)
display as text "[TRACE t4 0734] count for t4v0235 = " r(N)
quietly count if !missing(t4v0246)
display as text "[TRACE t4 0735] count for t4v0246 = " r(N)
quietly count if !missing(t4v0257)
display as text "[TRACE t4 0736] count for t4v0257 = " r(N)
quietly count if !missing(t4v0268)
display as text "[TRACE t4 0737] count for t4v0268 = " r(N)
quietly count if !missing(t4v0279)
display as text "[TRACE t4 0738] count for t4v0279 = " r(N)
quietly count if !missing(t4v0290)
display as text "[TRACE t4 0739] count for t4v0290 = " r(N)
quietly count if !missing(t4v0301)
display as text "[TRACE t4 0740] count for t4v0301 = " r(N)
quietly count if !missing(t4v0312)
display as text "[TRACE t4 0741] count for t4v0312 = " r(N)
quietly count if !missing(t4v0323)
display as text "[TRACE t4 0742] count for t4v0323 = " r(N)
quietly count if !missing(t4v0334)
display as text "[TRACE t4 0743] count for t4v0334 = " r(N)
quietly count if !missing(t4v0345)
display as text "[TRACE t4 0744] count for t4v0345 = " r(N)
quietly count if !missing(t4v0356)
display as text "[TRACE t4 0745] count for t4v0356 = " r(N)
quietly count if !missing(t4v0367)
display as text "[TRACE t4 0746] count for t4v0367 = " r(N)
quietly count if !missing(t4v0378)
display as text "[TRACE t4 0747] count for t4v0378 = " r(N)
quietly count if !missing(t4v0389)
display as text "[TRACE t4 0748] count for t4v0389 = " r(N)
quietly summarize t4v0389, detail
display as text "[TRACE-DETAIL t4 0748] p50=" %9.4f r(p50)
quietly count if !missing(t4v0400)
display as text "[TRACE t4 0749] count for t4v0400 = " r(N)
quietly count if !missing(t4v0411)
display as text "[TRACE t4 0750] count for t4v0411 = " r(N)
quietly count if !missing(t4v0422)
display as text "[TRACE t4 0751] count for t4v0422 = " r(N)
quietly count if !missing(t4v0433)
display as text "[TRACE t4 0752] count for t4v0433 = " r(N)
quietly count if !missing(t4v0444)
display as text "[TRACE t4 0753] count for t4v0444 = " r(N)
quietly count if !missing(t4v0455)
display as text "[TRACE t4 0754] count for t4v0455 = " r(N)
quietly count if !missing(t4v0466)
display as text "[TRACE t4 0755] count for t4v0466 = " r(N)
quietly count if !missing(t4v0477)
display as text "[TRACE t4 0756] count for t4v0477 = " r(N)
quietly count if !missing(t4v0488)
display as text "[TRACE t4 0757] count for t4v0488 = " r(N)
quietly count if !missing(t4v0499)
display as text "[TRACE t4 0758] count for t4v0499 = " r(N)
quietly count if !missing(t4v0510)
display as text "[TRACE t4 0759] count for t4v0510 = " r(N)
quietly count if !missing(t4v0521)
display as text "[TRACE t4 0760] count for t4v0521 = " r(N)
quietly count if !missing(t4v0532)
display as text "[TRACE t4 0761] count for t4v0532 = " r(N)
quietly count if !missing(t4v0543)
display as text "[TRACE t4 0762] count for t4v0543 = " r(N)
quietly count if !missing(t4v0554)
display as text "[TRACE t4 0763] count for t4v0554 = " r(N)
quietly count if !missing(t4v0565)
display as text "[TRACE t4 0764] count for t4v0565 = " r(N)
quietly count if !missing(t4v0576)
display as text "[TRACE t4 0765] count for t4v0576 = " r(N)
quietly summarize t4v0576, detail
display as text "[TRACE-DETAIL t4 0765] p50=" %9.4f r(p50)
quietly count if !missing(t4v0587)
display as text "[TRACE t4 0766] count for t4v0587 = " r(N)
quietly count if !missing(t4v0598)
display as text "[TRACE t4 0767] count for t4v0598 = " r(N)
quietly count if !missing(t4v0609)
display as text "[TRACE t4 0768] count for t4v0609 = " r(N)
quietly count if !missing(t4v0620)
display as text "[TRACE t4 0769] count for t4v0620 = " r(N)
quietly count if !missing(t4v0631)
display as text "[TRACE t4 0770] count for t4v0631 = " r(N)
quietly count if !missing(t4v0642)
display as text "[TRACE t4 0771] count for t4v0642 = " r(N)
quietly count if !missing(t4v0653)
display as text "[TRACE t4 0772] count for t4v0653 = " r(N)
quietly count if !missing(t4v0664)
display as text "[TRACE t4 0773] count for t4v0664 = " r(N)
quietly count if !missing(t4v0675)
display as text "[TRACE t4 0774] count for t4v0675 = " r(N)
quietly count if !missing(t4v0686)
display as text "[TRACE t4 0775] count for t4v0686 = " r(N)
quietly count if !missing(t4v0697)
display as text "[TRACE t4 0776] count for t4v0697 = " r(N)
quietly count if !missing(t4v0708)
display as text "[TRACE t4 0777] count for t4v0708 = " r(N)
quietly count if !missing(t4v0719)
display as text "[TRACE t4 0778] count for t4v0719 = " r(N)
quietly count if !missing(t4v0730)
display as text "[TRACE t4 0779] count for t4v0730 = " r(N)
quietly count if !missing(t4v0741)
display as text "[TRACE t4 0780] count for t4v0741 = " r(N)
quietly count if !missing(t4v0752)
display as text "[TRACE t4 0781] count for t4v0752 = " r(N)
quietly count if !missing(t4v0763)
display as text "[TRACE t4 0782] count for t4v0763 = " r(N)
quietly summarize t4v0763, detail
display as text "[TRACE-DETAIL t4 0782] p50=" %9.4f r(p50)
quietly count if !missing(t4v0774)
display as text "[TRACE t4 0783] count for t4v0774 = " r(N)
quietly count if !missing(t4v0785)
display as text "[TRACE t4 0784] count for t4v0785 = " r(N)
quietly count if !missing(t4v0796)
display as text "[TRACE t4 0785] count for t4v0796 = " r(N)
quietly count if !missing(t4v0807)
display as text "[TRACE t4 0786] count for t4v0807 = " r(N)
quietly count if !missing(t4v0818)
display as text "[TRACE t4 0787] count for t4v0818 = " r(N)
quietly count if !missing(t4v0829)
display as text "[TRACE t4 0788] count for t4v0829 = " r(N)
quietly count if !missing(t4v0840)
display as text "[TRACE t4 0789] count for t4v0840 = " r(N)
quietly count if !missing(t4v0851)
display as text "[TRACE t4 0790] count for t4v0851 = " r(N)
quietly count if !missing(t4v0862)
display as text "[TRACE t4 0791] count for t4v0862 = " r(N)
quietly count if !missing(t4v0873)
display as text "[TRACE t4 0792] count for t4v0873 = " r(N)
quietly count if !missing(t4v0884)
display as text "[TRACE t4 0793] count for t4v0884 = " r(N)
quietly count if !missing(t4v0895)
display as text "[TRACE t4 0794] count for t4v0895 = " r(N)
quietly count if !missing(t4v0906)
display as text "[TRACE t4 0795] count for t4v0906 = " r(N)
quietly count if !missing(t4v0917)
display as text "[TRACE t4 0796] count for t4v0917 = " r(N)
quietly count if !missing(t4v0928)
display as text "[TRACE t4 0797] count for t4v0928 = " r(N)
quietly count if !missing(t4v0939)
display as text "[TRACE t4 0798] count for t4v0939 = " r(N)
quietly count if !missing(t4v0950)
display as text "[TRACE t4 0799] count for t4v0950 = " r(N)
quietly summarize t4v0950, detail
display as text "[TRACE-DETAIL t4 0799] p50=" %9.4f r(p50)
quietly count if !missing(t4v0961)
display as text "[TRACE t4 0800] count for t4v0961 = " r(N)
quietly count if !missing(t4v0972)
display as text "[TRACE t4 0801] count for t4v0972 = " r(N)
quietly count if !missing(t4v0003)
display as text "[TRACE t4 0802] count for t4v0003 = " r(N)
quietly count if !missing(t4v0014)
display as text "[TRACE t4 0803] count for t4v0014 = " r(N)
quietly count if !missing(t4v0025)
display as text "[TRACE t4 0804] count for t4v0025 = " r(N)
quietly count if !missing(t4v0036)
display as text "[TRACE t4 0805] count for t4v0036 = " r(N)
quietly count if !missing(t4v0047)
display as text "[TRACE t4 0806] count for t4v0047 = " r(N)
quietly count if !missing(t4v0058)
display as text "[TRACE t4 0807] count for t4v0058 = " r(N)
quietly count if !missing(t4v0069)
display as text "[TRACE t4 0808] count for t4v0069 = " r(N)
quietly count if !missing(t4v0080)
display as text "[TRACE t4 0809] count for t4v0080 = " r(N)
quietly count if !missing(t4v0091)
display as text "[TRACE t4 0810] count for t4v0091 = " r(N)
quietly count if !missing(t4v0102)
display as text "[TRACE t4 0811] count for t4v0102 = " r(N)
quietly count if !missing(t4v0113)
display as text "[TRACE t4 0812] count for t4v0113 = " r(N)
quietly count if !missing(t4v0124)
display as text "[TRACE t4 0813] count for t4v0124 = " r(N)
quietly count if !missing(t4v0135)
display as text "[TRACE t4 0814] count for t4v0135 = " r(N)
quietly count if !missing(t4v0146)
display as text "[TRACE t4 0815] count for t4v0146 = " r(N)
quietly count if !missing(t4v0157)
display as text "[TRACE t4 0816] count for t4v0157 = " r(N)
quietly summarize t4v0157, detail
display as text "[TRACE-DETAIL t4 0816] p50=" %9.4f r(p50)
quietly count if !missing(t4v0168)
display as text "[TRACE t4 0817] count for t4v0168 = " r(N)
quietly count if !missing(t4v0179)
display as text "[TRACE t4 0818] count for t4v0179 = " r(N)
quietly count if !missing(t4v0190)
display as text "[TRACE t4 0819] count for t4v0190 = " r(N)
quietly count if !missing(t4v0201)
display as text "[TRACE t4 0820] count for t4v0201 = " r(N)
quietly count if !missing(t4v0212)
display as text "[TRACE t4 0821] count for t4v0212 = " r(N)
quietly count if !missing(t4v0223)
display as text "[TRACE t4 0822] count for t4v0223 = " r(N)
quietly count if !missing(t4v0234)
display as text "[TRACE t4 0823] count for t4v0234 = " r(N)
quietly count if !missing(t4v0245)
display as text "[TRACE t4 0824] count for t4v0245 = " r(N)
quietly count if !missing(t4v0256)
display as text "[TRACE t4 0825] count for t4v0256 = " r(N)
quietly count if !missing(t4v0267)
display as text "[TRACE t4 0826] count for t4v0267 = " r(N)
quietly count if !missing(t4v0278)
display as text "[TRACE t4 0827] count for t4v0278 = " r(N)
quietly count if !missing(t4v0289)
display as text "[TRACE t4 0828] count for t4v0289 = " r(N)
quietly count if !missing(t4v0300)
display as text "[TRACE t4 0829] count for t4v0300 = " r(N)
quietly count if !missing(t4v0311)
display as text "[TRACE t4 0830] count for t4v0311 = " r(N)
quietly count if !missing(t4v0322)
display as text "[TRACE t4 0831] count for t4v0322 = " r(N)
quietly count if !missing(t4v0333)
display as text "[TRACE t4 0832] count for t4v0333 = " r(N)
quietly count if !missing(t4v0344)
display as text "[TRACE t4 0833] count for t4v0344 = " r(N)
quietly summarize t4v0344, detail
display as text "[TRACE-DETAIL t4 0833] p50=" %9.4f r(p50)
quietly count if !missing(t4v0355)
display as text "[TRACE t4 0834] count for t4v0355 = " r(N)
quietly count if !missing(t4v0366)
display as text "[TRACE t4 0835] count for t4v0366 = " r(N)
quietly count if !missing(t4v0377)
display as text "[TRACE t4 0836] count for t4v0377 = " r(N)
quietly count if !missing(t4v0388)
display as text "[TRACE t4 0837] count for t4v0388 = " r(N)
quietly count if !missing(t4v0399)
display as text "[TRACE t4 0838] count for t4v0399 = " r(N)
quietly count if !missing(t4v0410)
display as text "[TRACE t4 0839] count for t4v0410 = " r(N)
quietly count if !missing(t4v0421)
display as text "[TRACE t4 0840] count for t4v0421 = " r(N)
quietly count if !missing(t4v0432)
display as text "[TRACE t4 0841] count for t4v0432 = " r(N)
quietly count if !missing(t4v0443)
display as text "[TRACE t4 0842] count for t4v0443 = " r(N)
quietly count if !missing(t4v0454)
display as text "[TRACE t4 0843] count for t4v0454 = " r(N)
quietly count if !missing(t4v0465)
display as text "[TRACE t4 0844] count for t4v0465 = " r(N)
quietly count if !missing(t4v0476)
display as text "[TRACE t4 0845] count for t4v0476 = " r(N)
quietly count if !missing(t4v0487)
display as text "[TRACE t4 0846] count for t4v0487 = " r(N)
quietly count if !missing(t4v0498)
display as text "[TRACE t4 0847] count for t4v0498 = " r(N)
quietly count if !missing(t4v0509)
display as text "[TRACE t4 0848] count for t4v0509 = " r(N)
quietly count if !missing(t4v0520)
display as text "[TRACE t4 0849] count for t4v0520 = " r(N)
quietly count if !missing(t4v0531)
display as text "[TRACE t4 0850] count for t4v0531 = " r(N)
quietly summarize t4v0531, detail
display as text "[TRACE-DETAIL t4 0850] p50=" %9.4f r(p50)
quietly count if !missing(t4v0542)
display as text "[TRACE t4 0851] count for t4v0542 = " r(N)
quietly count if !missing(t4v0553)
display as text "[TRACE t4 0852] count for t4v0553 = " r(N)
quietly count if !missing(t4v0564)
display as text "[TRACE t4 0853] count for t4v0564 = " r(N)
quietly count if !missing(t4v0575)
display as text "[TRACE t4 0854] count for t4v0575 = " r(N)
quietly count if !missing(t4v0586)
display as text "[TRACE t4 0855] count for t4v0586 = " r(N)
quietly count if !missing(t4v0597)
display as text "[TRACE t4 0856] count for t4v0597 = " r(N)
quietly count if !missing(t4v0608)
display as text "[TRACE t4 0857] count for t4v0608 = " r(N)
quietly count if !missing(t4v0619)
display as text "[TRACE t4 0858] count for t4v0619 = " r(N)
quietly count if !missing(t4v0630)
display as text "[TRACE t4 0859] count for t4v0630 = " r(N)
quietly count if !missing(t4v0641)
display as text "[TRACE t4 0860] count for t4v0641 = " r(N)
quietly count if !missing(t4v0652)
display as text "[TRACE t4 0861] count for t4v0652 = " r(N)
quietly count if !missing(t4v0663)
display as text "[TRACE t4 0862] count for t4v0663 = " r(N)
quietly count if !missing(t4v0674)
display as text "[TRACE t4 0863] count for t4v0674 = " r(N)
quietly count if !missing(t4v0685)
display as text "[TRACE t4 0864] count for t4v0685 = " r(N)
quietly count if !missing(t4v0696)
display as text "[TRACE t4 0865] count for t4v0696 = " r(N)
quietly count if !missing(t4v0707)
display as text "[TRACE t4 0866] count for t4v0707 = " r(N)
quietly count if !missing(t4v0718)
display as text "[TRACE t4 0867] count for t4v0718 = " r(N)
quietly summarize t4v0718, detail
display as text "[TRACE-DETAIL t4 0867] p50=" %9.4f r(p50)
quietly count if !missing(t4v0729)
display as text "[TRACE t4 0868] count for t4v0729 = " r(N)
quietly count if !missing(t4v0740)
display as text "[TRACE t4 0869] count for t4v0740 = " r(N)
quietly count if !missing(t4v0751)
display as text "[TRACE t4 0870] count for t4v0751 = " r(N)
quietly count if !missing(t4v0762)
display as text "[TRACE t4 0871] count for t4v0762 = " r(N)
quietly count if !missing(t4v0773)
display as text "[TRACE t4 0872] count for t4v0773 = " r(N)
quietly count if !missing(t4v0784)
display as text "[TRACE t4 0873] count for t4v0784 = " r(N)
quietly count if !missing(t4v0795)
display as text "[TRACE t4 0874] count for t4v0795 = " r(N)
quietly count if !missing(t4v0806)
display as text "[TRACE t4 0875] count for t4v0806 = " r(N)
quietly count if !missing(t4v0817)
display as text "[TRACE t4 0876] count for t4v0817 = " r(N)
quietly count if !missing(t4v0828)
display as text "[TRACE t4 0877] count for t4v0828 = " r(N)
quietly count if !missing(t4v0839)
display as text "[TRACE t4 0878] count for t4v0839 = " r(N)
quietly count if !missing(t4v0850)
display as text "[TRACE t4 0879] count for t4v0850 = " r(N)
quietly count if !missing(t4v0861)
display as text "[TRACE t4 0880] count for t4v0861 = " r(N)
quietly count if !missing(t4v0872)
display as text "[TRACE t4 0881] count for t4v0872 = " r(N)
quietly count if !missing(t4v0883)
display as text "[TRACE t4 0882] count for t4v0883 = " r(N)
quietly count if !missing(t4v0894)
display as text "[TRACE t4 0883] count for t4v0894 = " r(N)
quietly count if !missing(t4v0905)
display as text "[TRACE t4 0884] count for t4v0905 = " r(N)
quietly summarize t4v0905, detail
display as text "[TRACE-DETAIL t4 0884] p50=" %9.4f r(p50)
quietly count if !missing(t4v0916)
display as text "[TRACE t4 0885] count for t4v0916 = " r(N)
quietly count if !missing(t4v0927)
display as text "[TRACE t4 0886] count for t4v0927 = " r(N)
quietly count if !missing(t4v0938)
display as text "[TRACE t4 0887] count for t4v0938 = " r(N)
quietly count if !missing(t4v0949)
display as text "[TRACE t4 0888] count for t4v0949 = " r(N)
quietly count if !missing(t4v0960)
display as text "[TRACE t4 0889] count for t4v0960 = " r(N)
quietly count if !missing(t4v0971)
display as text "[TRACE t4 0890] count for t4v0971 = " r(N)
quietly count if !missing(t4v0002)
display as text "[TRACE t4 0891] count for t4v0002 = " r(N)
quietly count if !missing(t4v0013)
display as text "[TRACE t4 0892] count for t4v0013 = " r(N)
quietly count if !missing(t4v0024)
display as text "[TRACE t4 0893] count for t4v0024 = " r(N)
quietly count if !missing(t4v0035)
display as text "[TRACE t4 0894] count for t4v0035 = " r(N)
quietly count if !missing(t4v0046)
display as text "[TRACE t4 0895] count for t4v0046 = " r(N)
quietly count if !missing(t4v0057)
display as text "[TRACE t4 0896] count for t4v0057 = " r(N)
quietly count if !missing(t4v0068)
display as text "[TRACE t4 0897] count for t4v0068 = " r(N)
quietly count if !missing(t4v0079)
display as text "[TRACE t4 0898] count for t4v0079 = " r(N)
quietly count if !missing(t4v0090)
display as text "[TRACE t4 0899] count for t4v0090 = " r(N)
quietly count if !missing(t4v0101)
display as text "[TRACE t4 0900] count for t4v0101 = " r(N)
quietly count if !missing(t4v0112)
display as text "[TRACE t4 0901] count for t4v0112 = " r(N)
quietly summarize t4v0112, detail
display as text "[TRACE-DETAIL t4 0901] p50=" %9.4f r(p50)
quietly count if !missing(t4v0123)
display as text "[TRACE t4 0902] count for t4v0123 = " r(N)
quietly count if !missing(t4v0134)
display as text "[TRACE t4 0903] count for t4v0134 = " r(N)
quietly count if !missing(t4v0145)
display as text "[TRACE t4 0904] count for t4v0145 = " r(N)
quietly count if !missing(t4v0156)
display as text "[TRACE t4 0905] count for t4v0156 = " r(N)
quietly count if !missing(t4v0167)
display as text "[TRACE t4 0906] count for t4v0167 = " r(N)
quietly count if !missing(t4v0178)
display as text "[TRACE t4 0907] count for t4v0178 = " r(N)
quietly count if !missing(t4v0189)
display as text "[TRACE t4 0908] count for t4v0189 = " r(N)
quietly count if !missing(t4v0200)
display as text "[TRACE t4 0909] count for t4v0200 = " r(N)
quietly count if !missing(t4v0211)
display as text "[TRACE t4 0910] count for t4v0211 = " r(N)
quietly count if !missing(t4v0222)
display as text "[TRACE t4 0911] count for t4v0222 = " r(N)
quietly count if !missing(t4v0233)
display as text "[TRACE t4 0912] count for t4v0233 = " r(N)
quietly count if !missing(t4v0244)
display as text "[TRACE t4 0913] count for t4v0244 = " r(N)
quietly count if !missing(t4v0255)
display as text "[TRACE t4 0914] count for t4v0255 = " r(N)
quietly count if !missing(t4v0266)
display as text "[TRACE t4 0915] count for t4v0266 = " r(N)
quietly count if !missing(t4v0277)
display as text "[TRACE t4 0916] count for t4v0277 = " r(N)
quietly count if !missing(t4v0288)
display as text "[TRACE t4 0917] count for t4v0288 = " r(N)
quietly count if !missing(t4v0299)
display as text "[TRACE t4 0918] count for t4v0299 = " r(N)
quietly summarize t4v0299, detail
display as text "[TRACE-DETAIL t4 0918] p50=" %9.4f r(p50)
quietly count if !missing(t4v0310)
display as text "[TRACE t4 0919] count for t4v0310 = " r(N)
quietly count if !missing(t4v0321)
display as text "[TRACE t4 0920] count for t4v0321 = " r(N)
quietly count if !missing(t4v0332)
display as text "[TRACE t4 0921] count for t4v0332 = " r(N)
quietly count if !missing(t4v0343)
display as text "[TRACE t4 0922] count for t4v0343 = " r(N)
quietly count if !missing(t4v0354)
display as text "[TRACE t4 0923] count for t4v0354 = " r(N)
quietly count if !missing(t4v0365)
display as text "[TRACE t4 0924] count for t4v0365 = " r(N)
quietly count if !missing(t4v0376)
display as text "[TRACE t4 0925] count for t4v0376 = " r(N)
quietly count if !missing(t4v0387)
display as text "[TRACE t4 0926] count for t4v0387 = " r(N)
quietly count if !missing(t4v0398)
display as text "[TRACE t4 0927] count for t4v0398 = " r(N)
quietly count if !missing(t4v0409)
display as text "[TRACE t4 0928] count for t4v0409 = " r(N)
quietly count if !missing(t4v0420)
display as text "[TRACE t4 0929] count for t4v0420 = " r(N)
quietly count if !missing(t4v0431)
display as text "[TRACE t4 0930] count for t4v0431 = " r(N)
quietly count if !missing(t4v0442)
display as text "[TRACE t4 0931] count for t4v0442 = " r(N)
quietly count if !missing(t4v0453)
display as text "[TRACE t4 0932] count for t4v0453 = " r(N)
quietly count if !missing(t4v0464)
display as text "[TRACE t4 0933] count for t4v0464 = " r(N)
quietly count if !missing(t4v0475)
display as text "[TRACE t4 0934] count for t4v0475 = " r(N)
quietly count if !missing(t4v0486)
display as text "[TRACE t4 0935] count for t4v0486 = " r(N)
quietly summarize t4v0486, detail
display as text "[TRACE-DETAIL t4 0935] p50=" %9.4f r(p50)
quietly count if !missing(t4v0497)
display as text "[TRACE t4 0936] count for t4v0497 = " r(N)
quietly count if !missing(t4v0508)
display as text "[TRACE t4 0937] count for t4v0508 = " r(N)
quietly count if !missing(t4v0519)
display as text "[TRACE t4 0938] count for t4v0519 = " r(N)
quietly count if !missing(t4v0530)
display as text "[TRACE t4 0939] count for t4v0530 = " r(N)
quietly count if !missing(t4v0541)
display as text "[TRACE t4 0940] count for t4v0541 = " r(N)
quietly count if !missing(t4v0552)
display as text "[TRACE t4 0941] count for t4v0552 = " r(N)
quietly count if !missing(t4v0563)
display as text "[TRACE t4 0942] count for t4v0563 = " r(N)
quietly count if !missing(t4v0574)
display as text "[TRACE t4 0943] count for t4v0574 = " r(N)
quietly count if !missing(t4v0585)
display as text "[TRACE t4 0944] count for t4v0585 = " r(N)
quietly count if !missing(t4v0596)
display as text "[TRACE t4 0945] count for t4v0596 = " r(N)
quietly count if !missing(t4v0607)
display as text "[TRACE t4 0946] count for t4v0607 = " r(N)
quietly count if !missing(t4v0618)
display as text "[TRACE t4 0947] count for t4v0618 = " r(N)
quietly count if !missing(t4v0629)
display as text "[TRACE t4 0948] count for t4v0629 = " r(N)
quietly count if !missing(t4v0640)
display as text "[TRACE t4 0949] count for t4v0640 = " r(N)
quietly count if !missing(t4v0651)
display as text "[TRACE t4 0950] count for t4v0651 = " r(N)
quietly count if !missing(t4v0662)
display as text "[TRACE t4 0951] count for t4v0662 = " r(N)
quietly count if !missing(t4v0673)
display as text "[TRACE t4 0952] count for t4v0673 = " r(N)
quietly summarize t4v0673, detail
display as text "[TRACE-DETAIL t4 0952] p50=" %9.4f r(p50)
quietly count if !missing(t4v0684)
display as text "[TRACE t4 0953] count for t4v0684 = " r(N)
quietly count if !missing(t4v0695)
display as text "[TRACE t4 0954] count for t4v0695 = " r(N)
quietly count if !missing(t4v0706)
display as text "[TRACE t4 0955] count for t4v0706 = " r(N)
quietly count if !missing(t4v0717)
display as text "[TRACE t4 0956] count for t4v0717 = " r(N)
quietly count if !missing(t4v0728)
display as text "[TRACE t4 0957] count for t4v0728 = " r(N)
quietly count if !missing(t4v0739)
display as text "[TRACE t4 0958] count for t4v0739 = " r(N)
quietly count if !missing(t4v0750)
display as text "[TRACE t4 0959] count for t4v0750 = " r(N)
quietly count if !missing(t4v0761)
display as text "[TRACE t4 0960] count for t4v0761 = " r(N)
quietly count if !missing(t4v0772)
display as text "[TRACE t4 0961] count for t4v0772 = " r(N)
quietly count if !missing(t4v0783)
display as text "[TRACE t4 0962] count for t4v0783 = " r(N)
quietly count if !missing(t4v0794)
display as text "[TRACE t4 0963] count for t4v0794 = " r(N)
quietly count if !missing(t4v0805)
display as text "[TRACE t4 0964] count for t4v0805 = " r(N)
quietly count if !missing(t4v0816)
display as text "[TRACE t4 0965] count for t4v0816 = " r(N)
quietly count if !missing(t4v0827)
display as text "[TRACE t4 0966] count for t4v0827 = " r(N)
quietly count if !missing(t4v0838)
display as text "[TRACE t4 0967] count for t4v0838 = " r(N)
quietly count if !missing(t4v0849)
display as text "[TRACE t4 0968] count for t4v0849 = " r(N)
quietly count if !missing(t4v0860)
display as text "[TRACE t4 0969] count for t4v0860 = " r(N)
quietly summarize t4v0860, detail
display as text "[TRACE-DETAIL t4 0969] p50=" %9.4f r(p50)
quietly count if !missing(t4v0871)
display as text "[TRACE t4 0970] count for t4v0871 = " r(N)
quietly count if !missing(t4v0882)
display as text "[TRACE t4 0971] count for t4v0882 = " r(N)
quietly count if !missing(t4v0893)
display as text "[TRACE t4 0972] count for t4v0893 = " r(N)
quietly count if !missing(t4v0904)
display as text "[TRACE t4 0973] count for t4v0904 = " r(N)
quietly count if !missing(t4v0915)
display as text "[TRACE t4 0974] count for t4v0915 = " r(N)
quietly count if !missing(t4v0926)
display as text "[TRACE t4 0975] count for t4v0926 = " r(N)
quietly count if !missing(t4v0937)
display as text "[TRACE t4 0976] count for t4v0937 = " r(N)
quietly count if !missing(t4v0948)
display as text "[TRACE t4 0977] count for t4v0948 = " r(N)
quietly count if !missing(t4v0959)
display as text "[TRACE t4 0978] count for t4v0959 = " r(N)
quietly count if !missing(t4v0970)
display as text "[TRACE t4 0979] count for t4v0970 = " r(N)
quietly count if !missing(t4v0001)
display as text "[TRACE t4 0980] count for t4v0001 = " r(N)
quietly count if !missing(t4v0012)
display as text "[TRACE t4 0981] count for t4v0012 = " r(N)
quietly count if !missing(t4v0023)
display as text "[TRACE t4 0982] count for t4v0023 = " r(N)
quietly count if !missing(t4v0034)
display as text "[TRACE t4 0983] count for t4v0034 = " r(N)
quietly count if !missing(t4v0045)
display as text "[TRACE t4 0984] count for t4v0045 = " r(N)
quietly count if !missing(t4v0056)
display as text "[TRACE t4 0985] count for t4v0056 = " r(N)
quietly count if !missing(t4v0067)
display as text "[TRACE t4 0986] count for t4v0067 = " r(N)
quietly summarize t4v0067, detail
display as text "[TRACE-DETAIL t4 0986] p50=" %9.4f r(p50)
quietly count if !missing(t4v0078)
display as text "[TRACE t4 0987] count for t4v0078 = " r(N)
quietly count if !missing(t4v0089)
display as text "[TRACE t4 0988] count for t4v0089 = " r(N)
quietly count if !missing(t4v0100)
display as text "[TRACE t4 0989] count for t4v0100 = " r(N)
quietly count if !missing(t4v0111)
display as text "[TRACE t4 0990] count for t4v0111 = " r(N)
quietly count if !missing(t4v0122)
display as text "[TRACE t4 0991] count for t4v0122 = " r(N)
quietly count if !missing(t4v0133)
display as text "[TRACE t4 0992] count for t4v0133 = " r(N)
quietly count if !missing(t4v0144)
display as text "[TRACE t4 0993] count for t4v0144 = " r(N)
quietly count if !missing(t4v0155)
display as text "[TRACE t4 0994] count for t4v0155 = " r(N)
quietly count if !missing(t4v0166)
display as text "[TRACE t4 0995] count for t4v0166 = " r(N)
quietly count if !missing(t4v0177)
display as text "[TRACE t4 0996] count for t4v0177 = " r(N)
quietly count if !missing(t4v0188)
display as text "[TRACE t4 0997] count for t4v0188 = " r(N)
quietly count if !missing(t4v0199)
display as text "[TRACE t4 0998] count for t4v0199 = " r(N)
quietly count if !missing(t4v0210)
display as text "[TRACE t4 0999] count for t4v0210 = " r(N)
quietly count if !missing(t4v0221)
display as text "[TRACE t4 1000] count for t4v0221 = " r(N)
quietly count if !missing(t4v0232)
display as text "[TRACE t4 1001] count for t4v0232 = " r(N)
quietly count if !missing(t4v0243)
display as text "[TRACE t4 1002] count for t4v0243 = " r(N)
quietly count if !missing(t4v0254)
display as text "[TRACE t4 1003] count for t4v0254 = " r(N)
quietly summarize t4v0254, detail
display as text "[TRACE-DETAIL t4 1003] p50=" %9.4f r(p50)
quietly count if !missing(t4v0265)
display as text "[TRACE t4 1004] count for t4v0265 = " r(N)
quietly count if !missing(t4v0276)
display as text "[TRACE t4 1005] count for t4v0276 = " r(N)
quietly count if !missing(t4v0287)
display as text "[TRACE t4 1006] count for t4v0287 = " r(N)
quietly count if !missing(t4v0298)
display as text "[TRACE t4 1007] count for t4v0298 = " r(N)
quietly count if !missing(t4v0309)
display as text "[TRACE t4 1008] count for t4v0309 = " r(N)
quietly count if !missing(t4v0320)
display as text "[TRACE t4 1009] count for t4v0320 = " r(N)
quietly count if !missing(t4v0331)
display as text "[TRACE t4 1010] count for t4v0331 = " r(N)
quietly count if !missing(t4v0342)
display as text "[TRACE t4 1011] count for t4v0342 = " r(N)
quietly count if !missing(t4v0353)
display as text "[TRACE t4 1012] count for t4v0353 = " r(N)
quietly count if !missing(t4v0364)
display as text "[TRACE t4 1013] count for t4v0364 = " r(N)
quietly count if !missing(t4v0375)
display as text "[TRACE t4 1014] count for t4v0375 = " r(N)
quietly count if !missing(t4v0386)
display as text "[TRACE t4 1015] count for t4v0386 = " r(N)
quietly count if !missing(t4v0397)
display as text "[TRACE t4 1016] count for t4v0397 = " r(N)
quietly count if !missing(t4v0408)
display as text "[TRACE t4 1017] count for t4v0408 = " r(N)
quietly count if !missing(t4v0419)
display as text "[TRACE t4 1018] count for t4v0419 = " r(N)
quietly count if !missing(t4v0430)
display as text "[TRACE t4 1019] count for t4v0430 = " r(N)
quietly count if !missing(t4v0441)
display as text "[TRACE t4 1020] count for t4v0441 = " r(N)
quietly summarize t4v0441, detail
display as text "[TRACE-DETAIL t4 1020] p50=" %9.4f r(p50)
quietly count if !missing(t4v0452)
display as text "[TRACE t4 1021] count for t4v0452 = " r(N)
quietly count if !missing(t4v0463)
display as text "[TRACE t4 1022] count for t4v0463 = " r(N)
quietly count if !missing(t4v0474)
display as text "[TRACE t4 1023] count for t4v0474 = " r(N)
quietly count if !missing(t4v0485)
display as text "[TRACE t4 1024] count for t4v0485 = " r(N)
quietly count if !missing(t4v0496)
display as text "[TRACE t4 1025] count for t4v0496 = " r(N)
quietly count if !missing(t4v0507)
display as text "[TRACE t4 1026] count for t4v0507 = " r(N)
quietly count if !missing(t4v0518)
display as text "[TRACE t4 1027] count for t4v0518 = " r(N)
quietly count if !missing(t4v0529)
display as text "[TRACE t4 1028] count for t4v0529 = " r(N)
quietly count if !missing(t4v0540)
display as text "[TRACE t4 1029] count for t4v0540 = " r(N)
quietly count if !missing(t4v0551)
display as text "[TRACE t4 1030] count for t4v0551 = " r(N)
quietly count if !missing(t4v0562)
display as text "[TRACE t4 1031] count for t4v0562 = " r(N)
quietly count if !missing(t4v0573)
display as text "[TRACE t4 1032] count for t4v0573 = " r(N)
quietly count if !missing(t4v0584)
display as text "[TRACE t4 1033] count for t4v0584 = " r(N)
quietly count if !missing(t4v0595)
display as text "[TRACE t4 1034] count for t4v0595 = " r(N)
quietly count if !missing(t4v0606)
display as text "[TRACE t4 1035] count for t4v0606 = " r(N)
quietly count if !missing(t4v0617)
display as text "[TRACE t4 1036] count for t4v0617 = " r(N)
quietly count if !missing(t4v0628)
display as text "[TRACE t4 1037] count for t4v0628 = " r(N)
quietly summarize t4v0628, detail
display as text "[TRACE-DETAIL t4 1037] p50=" %9.4f r(p50)
quietly count if !missing(t4v0639)
display as text "[TRACE t4 1038] count for t4v0639 = " r(N)
quietly count if !missing(t4v0650)
display as text "[TRACE t4 1039] count for t4v0650 = " r(N)
quietly count if !missing(t4v0661)
display as text "[TRACE t4 1040] count for t4v0661 = " r(N)
quietly count if !missing(t4v0672)
display as text "[TRACE t4 1041] count for t4v0672 = " r(N)
quietly count if !missing(t4v0683)
display as text "[TRACE t4 1042] count for t4v0683 = " r(N)
quietly count if !missing(t4v0694)
display as text "[TRACE t4 1043] count for t4v0694 = " r(N)
quietly count if !missing(t4v0705)
display as text "[TRACE t4 1044] count for t4v0705 = " r(N)
quietly count if !missing(t4v0716)
display as text "[TRACE t4 1045] count for t4v0716 = " r(N)
quietly count if !missing(t4v0727)
display as text "[TRACE t4 1046] count for t4v0727 = " r(N)
quietly count if !missing(t4v0738)
display as text "[TRACE t4 1047] count for t4v0738 = " r(N)
quietly count if !missing(t4v0749)
display as text "[TRACE t4 1048] count for t4v0749 = " r(N)
quietly count if !missing(t4v0760)
display as text "[TRACE t4 1049] count for t4v0760 = " r(N)
quietly count if !missing(t4v0771)
display as text "[TRACE t4 1050] count for t4v0771 = " r(N)
quietly count if !missing(t4v0782)
display as text "[TRACE t4 1051] count for t4v0782 = " r(N)
quietly count if !missing(t4v0793)
display as text "[TRACE t4 1052] count for t4v0793 = " r(N)
quietly count if !missing(t4v0804)
display as text "[TRACE t4 1053] count for t4v0804 = " r(N)
quietly count if !missing(t4v0815)
display as text "[TRACE t4 1054] count for t4v0815 = " r(N)
quietly summarize t4v0815, detail
display as text "[TRACE-DETAIL t4 1054] p50=" %9.4f r(p50)
quietly count if !missing(t4v0826)
display as text "[TRACE t4 1055] count for t4v0826 = " r(N)
quietly count if !missing(t4v0837)
display as text "[TRACE t4 1056] count for t4v0837 = " r(N)
quietly count if !missing(t4v0848)
display as text "[TRACE t4 1057] count for t4v0848 = " r(N)
quietly count if !missing(t4v0859)
display as text "[TRACE t4 1058] count for t4v0859 = " r(N)
quietly count if !missing(t4v0870)
display as text "[TRACE t4 1059] count for t4v0870 = " r(N)
quietly count if !missing(t4v0881)
display as text "[TRACE t4 1060] count for t4v0881 = " r(N)
quietly count if !missing(t4v0892)
display as text "[TRACE t4 1061] count for t4v0892 = " r(N)
quietly count if !missing(t4v0903)
display as text "[TRACE t4 1062] count for t4v0903 = " r(N)
quietly count if !missing(t4v0914)
display as text "[TRACE t4 1063] count for t4v0914 = " r(N)
quietly count if !missing(t4v0925)
display as text "[TRACE t4 1064] count for t4v0925 = " r(N)
quietly count if !missing(t4v0936)
display as text "[TRACE t4 1065] count for t4v0936 = " r(N)
quietly count if !missing(t4v0947)
display as text "[TRACE t4 1066] count for t4v0947 = " r(N)
quietly count if !missing(t4v0958)
display as text "[TRACE t4 1067] count for t4v0958 = " r(N)
quietly count if !missing(t4v0969)
display as text "[TRACE t4 1068] count for t4v0969 = " r(N)
quietly count if !missing(t4v0980)
display as text "[TRACE t4 1069] count for t4v0980 = " r(N)
quietly count if !missing(t4v0011)
display as text "[TRACE t4 1070] count for t4v0011 = " r(N)
quietly count if !missing(t4v0022)
display as text "[TRACE t4 1071] count for t4v0022 = " r(N)
quietly summarize t4v0022, detail
display as text "[TRACE-DETAIL t4 1071] p50=" %9.4f r(p50)
quietly count if !missing(t4v0033)
display as text "[TRACE t4 1072] count for t4v0033 = " r(N)
quietly count if !missing(t4v0044)
display as text "[TRACE t4 1073] count for t4v0044 = " r(N)
quietly count if !missing(t4v0055)
display as text "[TRACE t4 1074] count for t4v0055 = " r(N)
quietly count if !missing(t4v0066)
display as text "[TRACE t4 1075] count for t4v0066 = " r(N)
quietly count if !missing(t4v0077)
display as text "[TRACE t4 1076] count for t4v0077 = " r(N)
quietly count if !missing(t4v0088)
display as text "[TRACE t4 1077] count for t4v0088 = " r(N)
quietly count if !missing(t4v0099)
display as text "[TRACE t4 1078] count for t4v0099 = " r(N)
quietly count if !missing(t4v0110)
display as text "[TRACE t4 1079] count for t4v0110 = " r(N)
quietly count if !missing(t4v0121)
display as text "[TRACE t4 1080] count for t4v0121 = " r(N)
quietly count if !missing(t4v0132)
display as text "[TRACE t4 1081] count for t4v0132 = " r(N)
quietly count if !missing(t4v0143)
display as text "[TRACE t4 1082] count for t4v0143 = " r(N)
quietly count if !missing(t4v0154)
display as text "[TRACE t4 1083] count for t4v0154 = " r(N)
quietly count if !missing(t4v0165)
display as text "[TRACE t4 1084] count for t4v0165 = " r(N)
quietly count if !missing(t4v0176)
display as text "[TRACE t4 1085] count for t4v0176 = " r(N)
quietly count if !missing(t4v0187)
display as text "[TRACE t4 1086] count for t4v0187 = " r(N)
quietly count if !missing(t4v0198)
display as text "[TRACE t4 1087] count for t4v0198 = " r(N)
quietly count if !missing(t4v0209)
display as text "[TRACE t4 1088] count for t4v0209 = " r(N)
quietly summarize t4v0209, detail
display as text "[TRACE-DETAIL t4 1088] p50=" %9.4f r(p50)
quietly count if !missing(t4v0220)
display as text "[TRACE t4 1089] count for t4v0220 = " r(N)
quietly count if !missing(t4v0231)
display as text "[TRACE t4 1090] count for t4v0231 = " r(N)
quietly count if !missing(t4v0242)
display as text "[TRACE t4 1091] count for t4v0242 = " r(N)
quietly count if !missing(t4v0253)
display as text "[TRACE t4 1092] count for t4v0253 = " r(N)
quietly count if !missing(t4v0264)
display as text "[TRACE t4 1093] count for t4v0264 = " r(N)
quietly count if !missing(t4v0275)
display as text "[TRACE t4 1094] count for t4v0275 = " r(N)
quietly count if !missing(t4v0286)
display as text "[TRACE t4 1095] count for t4v0286 = " r(N)
quietly count if !missing(t4v0297)
display as text "[TRACE t4 1096] count for t4v0297 = " r(N)
quietly count if !missing(t4v0308)
display as text "[TRACE t4 1097] count for t4v0308 = " r(N)
quietly count if !missing(t4v0319)
display as text "[TRACE t4 1098] count for t4v0319 = " r(N)
quietly count if !missing(t4v0330)
display as text "[TRACE t4 1099] count for t4v0330 = " r(N)
quietly count if !missing(t4v0341)
display as text "[TRACE t4 1100] count for t4v0341 = " r(N)
quietly count if !missing(t4v0352)
display as text "[TRACE t4 1101] count for t4v0352 = " r(N)
quietly count if !missing(t4v0363)
display as text "[TRACE t4 1102] count for t4v0363 = " r(N)
quietly count if !missing(t4v0374)
display as text "[TRACE t4 1103] count for t4v0374 = " r(N)
quietly count if !missing(t4v0385)
display as text "[TRACE t4 1104] count for t4v0385 = " r(N)
quietly count if !missing(t4v0396)
display as text "[TRACE t4 1105] count for t4v0396 = " r(N)
quietly summarize t4v0396, detail
display as text "[TRACE-DETAIL t4 1105] p50=" %9.4f r(p50)
quietly count if !missing(t4v0407)
display as text "[TRACE t4 1106] count for t4v0407 = " r(N)
quietly count if !missing(t4v0418)
display as text "[TRACE t4 1107] count for t4v0418 = " r(N)
quietly count if !missing(t4v0429)
display as text "[TRACE t4 1108] count for t4v0429 = " r(N)
quietly count if !missing(t4v0440)
display as text "[TRACE t4 1109] count for t4v0440 = " r(N)
quietly count if !missing(t4v0451)
display as text "[TRACE t4 1110] count for t4v0451 = " r(N)
quietly count if !missing(t4v0462)
display as text "[TRACE t4 1111] count for t4v0462 = " r(N)
quietly count if !missing(t4v0473)
display as text "[TRACE t4 1112] count for t4v0473 = " r(N)
quietly count if !missing(t4v0484)
display as text "[TRACE t4 1113] count for t4v0484 = " r(N)
quietly count if !missing(t4v0495)
display as text "[TRACE t4 1114] count for t4v0495 = " r(N)
quietly count if !missing(t4v0506)
display as text "[TRACE t4 1115] count for t4v0506 = " r(N)
quietly count if !missing(t4v0517)
display as text "[TRACE t4 1116] count for t4v0517 = " r(N)
quietly count if !missing(t4v0528)
display as text "[TRACE t4 1117] count for t4v0528 = " r(N)
quietly count if !missing(t4v0539)
display as text "[TRACE t4 1118] count for t4v0539 = " r(N)
quietly count if !missing(t4v0550)
display as text "[TRACE t4 1119] count for t4v0550 = " r(N)
quietly count if !missing(t4v0561)
display as text "[TRACE t4 1120] count for t4v0561 = " r(N)
quietly count if !missing(t4v0572)
display as text "[TRACE t4 1121] count for t4v0572 = " r(N)
quietly count if !missing(t4v0583)
display as text "[TRACE t4 1122] count for t4v0583 = " r(N)
quietly summarize t4v0583, detail
display as text "[TRACE-DETAIL t4 1122] p50=" %9.4f r(p50)
quietly count if !missing(t4v0594)
display as text "[TRACE t4 1123] count for t4v0594 = " r(N)
quietly count if !missing(t4v0605)
display as text "[TRACE t4 1124] count for t4v0605 = " r(N)
quietly count if !missing(t4v0616)
display as text "[TRACE t4 1125] count for t4v0616 = " r(N)
quietly count if !missing(t4v0627)
display as text "[TRACE t4 1126] count for t4v0627 = " r(N)
quietly count if !missing(t4v0638)
display as text "[TRACE t4 1127] count for t4v0638 = " r(N)
quietly count if !missing(t4v0649)
display as text "[TRACE t4 1128] count for t4v0649 = " r(N)
quietly count if !missing(t4v0660)
display as text "[TRACE t4 1129] count for t4v0660 = " r(N)
quietly count if !missing(t4v0671)
display as text "[TRACE t4 1130] count for t4v0671 = " r(N)
quietly count if !missing(t4v0682)
display as text "[TRACE t4 1131] count for t4v0682 = " r(N)
quietly count if !missing(t4v0693)
display as text "[TRACE t4 1132] count for t4v0693 = " r(N)
quietly count if !missing(t4v0704)
display as text "[TRACE t4 1133] count for t4v0704 = " r(N)
quietly count if !missing(t4v0715)
display as text "[TRACE t4 1134] count for t4v0715 = " r(N)
quietly count if !missing(t4v0726)
display as text "[TRACE t4 1135] count for t4v0726 = " r(N)
quietly count if !missing(t4v0737)
display as text "[TRACE t4 1136] count for t4v0737 = " r(N)
quietly count if !missing(t4v0748)
display as text "[TRACE t4 1137] count for t4v0748 = " r(N)
quietly count if !missing(t4v0759)
display as text "[TRACE t4 1138] count for t4v0759 = " r(N)
quietly count if !missing(t4v0770)
display as text "[TRACE t4 1139] count for t4v0770 = " r(N)
quietly summarize t4v0770, detail
display as text "[TRACE-DETAIL t4 1139] p50=" %9.4f r(p50)
quietly count if !missing(t4v0781)
display as text "[TRACE t4 1140] count for t4v0781 = " r(N)
quietly count if !missing(t4v0792)
display as text "[TRACE t4 1141] count for t4v0792 = " r(N)
quietly count if !missing(t4v0803)
display as text "[TRACE t4 1142] count for t4v0803 = " r(N)
quietly count if !missing(t4v0814)
display as text "[TRACE t4 1143] count for t4v0814 = " r(N)
quietly count if !missing(t4v0825)
display as text "[TRACE t4 1144] count for t4v0825 = " r(N)
quietly count if !missing(t4v0836)
display as text "[TRACE t4 1145] count for t4v0836 = " r(N)
quietly count if !missing(t4v0847)
display as text "[TRACE t4 1146] count for t4v0847 = " r(N)
quietly count if !missing(t4v0858)
display as text "[TRACE t4 1147] count for t4v0858 = " r(N)
quietly count if !missing(t4v0869)
display as text "[TRACE t4 1148] count for t4v0869 = " r(N)
quietly count if !missing(t4v0880)
display as text "[TRACE t4 1149] count for t4v0880 = " r(N)
quietly count if !missing(t4v0891)
display as text "[TRACE t4 1150] count for t4v0891 = " r(N)
quietly count if !missing(t4v0902)
display as text "[TRACE t4 1151] count for t4v0902 = " r(N)
quietly count if !missing(t4v0913)
display as text "[TRACE t4 1152] count for t4v0913 = " r(N)
quietly count if !missing(t4v0924)
display as text "[TRACE t4 1153] count for t4v0924 = " r(N)
quietly count if !missing(t4v0935)
display as text "[TRACE t4 1154] count for t4v0935 = " r(N)
quietly count if !missing(t4v0946)
display as text "[TRACE t4 1155] count for t4v0946 = " r(N)
quietly count if !missing(t4v0957)
display as text "[TRACE t4 1156] count for t4v0957 = " r(N)
quietly summarize t4v0957, detail
display as text "[TRACE-DETAIL t4 1156] p50=" %9.4f r(p50)
quietly count if !missing(t4v0968)
display as text "[TRACE t4 1157] count for t4v0968 = " r(N)
quietly count if !missing(t4v0979)
display as text "[TRACE t4 1158] count for t4v0979 = " r(N)
quietly count if !missing(t4v0010)
display as text "[TRACE t4 1159] count for t4v0010 = " r(N)
quietly count if !missing(t4v0021)
display as text "[TRACE t4 1160] count for t4v0021 = " r(N)
quietly count if !missing(t4v0032)
display as text "[TRACE t4 1161] count for t4v0032 = " r(N)
quietly count if !missing(t4v0043)
display as text "[TRACE t4 1162] count for t4v0043 = " r(N)
quietly count if !missing(t4v0054)
display as text "[TRACE t4 1163] count for t4v0054 = " r(N)
quietly count if !missing(t4v0065)
display as text "[TRACE t4 1164] count for t4v0065 = " r(N)
quietly count if !missing(t4v0076)
display as text "[TRACE t4 1165] count for t4v0076 = " r(N)
quietly count if !missing(t4v0087)
display as text "[TRACE t4 1166] count for t4v0087 = " r(N)
quietly count if !missing(t4v0098)
display as text "[TRACE t4 1167] count for t4v0098 = " r(N)
quietly count if !missing(t4v0109)
display as text "[TRACE t4 1168] count for t4v0109 = " r(N)
quietly count if !missing(t4v0120)
display as text "[TRACE t4 1169] count for t4v0120 = " r(N)
quietly count if !missing(t4v0131)
display as text "[TRACE t4 1170] count for t4v0131 = " r(N)
quietly count if !missing(t4v0142)
display as text "[TRACE t4 1171] count for t4v0142 = " r(N)
quietly count if !missing(t4v0153)
display as text "[TRACE t4 1172] count for t4v0153 = " r(N)
quietly count if !missing(t4v0164)
display as text "[TRACE t4 1173] count for t4v0164 = " r(N)
quietly summarize t4v0164, detail
display as text "[TRACE-DETAIL t4 1173] p50=" %9.4f r(p50)
quietly count if !missing(t4v0175)
display as text "[TRACE t4 1174] count for t4v0175 = " r(N)
quietly count if !missing(t4v0186)
display as text "[TRACE t4 1175] count for t4v0186 = " r(N)
quietly count if !missing(t4v0197)
display as text "[TRACE t4 1176] count for t4v0197 = " r(N)
quietly count if !missing(t4v0208)
display as text "[TRACE t4 1177] count for t4v0208 = " r(N)
quietly count if !missing(t4v0219)
display as text "[TRACE t4 1178] count for t4v0219 = " r(N)
quietly count if !missing(t4v0230)
display as text "[TRACE t4 1179] count for t4v0230 = " r(N)
quietly count if !missing(t4v0241)
display as text "[TRACE t4 1180] count for t4v0241 = " r(N)
quietly count if !missing(t4v0252)
display as text "[TRACE t4 1181] count for t4v0252 = " r(N)
quietly count if !missing(t4v0263)
display as text "[TRACE t4 1182] count for t4v0263 = " r(N)
quietly count if !missing(t4v0274)
display as text "[TRACE t4 1183] count for t4v0274 = " r(N)
quietly count if !missing(t4v0285)
display as text "[TRACE t4 1184] count for t4v0285 = " r(N)
quietly count if !missing(t4v0296)
display as text "[TRACE t4 1185] count for t4v0296 = " r(N)
quietly count if !missing(t4v0307)
display as text "[TRACE t4 1186] count for t4v0307 = " r(N)
quietly count if !missing(t4v0318)
display as text "[TRACE t4 1187] count for t4v0318 = " r(N)
quietly count if !missing(t4v0329)
display as text "[TRACE t4 1188] count for t4v0329 = " r(N)
quietly count if !missing(t4v0340)
display as text "[TRACE t4 1189] count for t4v0340 = " r(N)
quietly count if !missing(t4v0351)
display as text "[TRACE t4 1190] count for t4v0351 = " r(N)
quietly summarize t4v0351, detail
display as text "[TRACE-DETAIL t4 1190] p50=" %9.4f r(p50)
quietly count if !missing(t4v0362)
display as text "[TRACE t4 1191] count for t4v0362 = " r(N)
quietly count if !missing(t4v0373)
display as text "[TRACE t4 1192] count for t4v0373 = " r(N)
quietly count if !missing(t4v0384)
display as text "[TRACE t4 1193] count for t4v0384 = " r(N)
quietly count if !missing(t4v0395)
display as text "[TRACE t4 1194] count for t4v0395 = " r(N)
quietly count if !missing(t4v0406)
display as text "[TRACE t4 1195] count for t4v0406 = " r(N)
quietly count if !missing(t4v0417)
display as text "[TRACE t4 1196] count for t4v0417 = " r(N)
quietly count if !missing(t4v0428)
display as text "[TRACE t4 1197] count for t4v0428 = " r(N)
quietly count if !missing(t4v0439)
display as text "[TRACE t4 1198] count for t4v0439 = " r(N)
quietly count if !missing(t4v0450)
display as text "[TRACE t4 1199] count for t4v0450 = " r(N)
quietly count if !missing(t4v0461)
display as text "[TRACE t4 1200] count for t4v0461 = " r(N)
quietly count if !missing(t4v0472)
display as text "[TRACE t4 1201] count for t4v0472 = " r(N)
quietly count if !missing(t4v0483)
display as text "[TRACE t4 1202] count for t4v0483 = " r(N)
quietly count if !missing(t4v0494)
display as text "[TRACE t4 1203] count for t4v0494 = " r(N)
quietly count if !missing(t4v0505)
display as text "[TRACE t4 1204] count for t4v0505 = " r(N)
quietly count if !missing(t4v0516)
display as text "[TRACE t4 1205] count for t4v0516 = " r(N)
quietly count if !missing(t4v0527)
display as text "[TRACE t4 1206] count for t4v0527 = " r(N)
quietly count if !missing(t4v0538)
display as text "[TRACE t4 1207] count for t4v0538 = " r(N)
quietly summarize t4v0538, detail
display as text "[TRACE-DETAIL t4 1207] p50=" %9.4f r(p50)
quietly count if !missing(t4v0549)
display as text "[TRACE t4 1208] count for t4v0549 = " r(N)
quietly count if !missing(t4v0560)
display as text "[TRACE t4 1209] count for t4v0560 = " r(N)
quietly count if !missing(t4v0571)
display as text "[TRACE t4 1210] count for t4v0571 = " r(N)
quietly count if !missing(t4v0582)
display as text "[TRACE t4 1211] count for t4v0582 = " r(N)
quietly count if !missing(t4v0593)
display as text "[TRACE t4 1212] count for t4v0593 = " r(N)
quietly count if !missing(t4v0604)
display as text "[TRACE t4 1213] count for t4v0604 = " r(N)
quietly count if !missing(t4v0615)
display as text "[TRACE t4 1214] count for t4v0615 = " r(N)
quietly count if !missing(t4v0626)
display as text "[TRACE t4 1215] count for t4v0626 = " r(N)
quietly count if !missing(t4v0637)
display as text "[TRACE t4 1216] count for t4v0637 = " r(N)
quietly count if !missing(t4v0648)
display as text "[TRACE t4 1217] count for t4v0648 = " r(N)
quietly count if !missing(t4v0659)
display as text "[TRACE t4 1218] count for t4v0659 = " r(N)
quietly count if !missing(t4v0670)
display as text "[TRACE t4 1219] count for t4v0670 = " r(N)
quietly count if !missing(t4v0681)
display as text "[TRACE t4 1220] count for t4v0681 = " r(N)
quietly count if !missing(t4v0692)
display as text "[TRACE t4 1221] count for t4v0692 = " r(N)
quietly count if !missing(t4v0703)
display as text "[TRACE t4 1222] count for t4v0703 = " r(N)
quietly count if !missing(t4v0714)
display as text "[TRACE t4 1223] count for t4v0714 = " r(N)
quietly count if !missing(t4v0725)
display as text "[TRACE t4 1224] count for t4v0725 = " r(N)
quietly summarize t4v0725, detail
display as text "[TRACE-DETAIL t4 1224] p50=" %9.4f r(p50)
quietly count if !missing(t4v0736)
display as text "[TRACE t4 1225] count for t4v0736 = " r(N)
quietly count if !missing(t4v0747)
display as text "[TRACE t4 1226] count for t4v0747 = " r(N)
quietly count if !missing(t4v0758)
display as text "[TRACE t4 1227] count for t4v0758 = " r(N)
quietly count if !missing(t4v0769)
display as text "[TRACE t4 1228] count for t4v0769 = " r(N)
quietly count if !missing(t4v0780)
display as text "[TRACE t4 1229] count for t4v0780 = " r(N)
quietly count if !missing(t4v0791)
display as text "[TRACE t4 1230] count for t4v0791 = " r(N)
quietly count if !missing(t4v0802)
display as text "[TRACE t4 1231] count for t4v0802 = " r(N)
quietly count if !missing(t4v0813)
display as text "[TRACE t4 1232] count for t4v0813 = " r(N)
quietly count if !missing(t4v0824)
display as text "[TRACE t4 1233] count for t4v0824 = " r(N)
quietly count if !missing(t4v0835)
display as text "[TRACE t4 1234] count for t4v0835 = " r(N)
quietly count if !missing(t4v0846)
display as text "[TRACE t4 1235] count for t4v0846 = " r(N)
quietly count if !missing(t4v0857)
display as text "[TRACE t4 1236] count for t4v0857 = " r(N)
quietly count if !missing(t4v0868)
display as text "[TRACE t4 1237] count for t4v0868 = " r(N)
quietly count if !missing(t4v0879)
display as text "[TRACE t4 1238] count for t4v0879 = " r(N)
quietly count if !missing(t4v0890)
display as text "[TRACE t4 1239] count for t4v0890 = " r(N)
quietly count if !missing(t4v0901)
display as text "[TRACE t4 1240] count for t4v0901 = " r(N)
quietly count if !missing(t4v0912)
display as text "[TRACE t4 1241] count for t4v0912 = " r(N)
quietly summarize t4v0912, detail
display as text "[TRACE-DETAIL t4 1241] p50=" %9.4f r(p50)
quietly count if !missing(t4v0923)
display as text "[TRACE t4 1242] count for t4v0923 = " r(N)
quietly count if !missing(t4v0934)
display as text "[TRACE t4 1243] count for t4v0934 = " r(N)
quietly count if !missing(t4v0945)
display as text "[TRACE t4 1244] count for t4v0945 = " r(N)
quietly count if !missing(t4v0956)
display as text "[TRACE t4 1245] count for t4v0956 = " r(N)
quietly count if !missing(t4v0967)
display as text "[TRACE t4 1246] count for t4v0967 = " r(N)
quietly count if !missing(t4v0978)
display as text "[TRACE t4 1247] count for t4v0978 = " r(N)
quietly count if !missing(t4v0009)
display as text "[TRACE t4 1248] count for t4v0009 = " r(N)
quietly count if !missing(t4v0020)
display as text "[TRACE t4 1249] count for t4v0020 = " r(N)
quietly count if !missing(t4v0031)
display as text "[TRACE t4 1250] count for t4v0031 = " r(N)
quietly count if !missing(t4v0042)
display as text "[TRACE t4 1251] count for t4v0042 = " r(N)
quietly count if !missing(t4v0053)
display as text "[TRACE t4 1252] count for t4v0053 = " r(N)
quietly count if !missing(t4v0064)
display as text "[TRACE t4 1253] count for t4v0064 = " r(N)
quietly count if !missing(t4v0075)
display as text "[TRACE t4 1254] count for t4v0075 = " r(N)
quietly count if !missing(t4v0086)
display as text "[TRACE t4 1255] count for t4v0086 = " r(N)
quietly count if !missing(t4v0097)
display as text "[TRACE t4 1256] count for t4v0097 = " r(N)
quietly count if !missing(t4v0108)
display as text "[TRACE t4 1257] count for t4v0108 = " r(N)
quietly count if !missing(t4v0119)
display as text "[TRACE t4 1258] count for t4v0119 = " r(N)
quietly summarize t4v0119, detail
display as text "[TRACE-DETAIL t4 1258] p50=" %9.4f r(p50)
quietly count if !missing(t4v0130)
display as text "[TRACE t4 1259] count for t4v0130 = " r(N)
quietly count if !missing(t4v0141)
display as text "[TRACE t4 1260] count for t4v0141 = " r(N)
quietly count if !missing(t4v0152)
display as text "[TRACE t4 1261] count for t4v0152 = " r(N)
quietly count if !missing(t4v0163)
display as text "[TRACE t4 1262] count for t4v0163 = " r(N)
quietly count if !missing(t4v0174)
display as text "[TRACE t4 1263] count for t4v0174 = " r(N)
quietly count if !missing(t4v0185)
display as text "[TRACE t4 1264] count for t4v0185 = " r(N)
quietly count if !missing(t4v0196)
display as text "[TRACE t4 1265] count for t4v0196 = " r(N)
quietly count if !missing(t4v0207)
display as text "[TRACE t4 1266] count for t4v0207 = " r(N)
quietly count if !missing(t4v0218)
display as text "[TRACE t4 1267] count for t4v0218 = " r(N)
quietly count if !missing(t4v0229)
display as text "[TRACE t4 1268] count for t4v0229 = " r(N)
quietly count if !missing(t4v0240)
display as text "[TRACE t4 1269] count for t4v0240 = " r(N)
quietly count if !missing(t4v0251)
display as text "[TRACE t4 1270] count for t4v0251 = " r(N)
quietly count if !missing(t4v0262)
display as text "[TRACE t4 1271] count for t4v0262 = " r(N)
quietly count if !missing(t4v0273)
display as text "[TRACE t4 1272] count for t4v0273 = " r(N)
quietly count if !missing(t4v0284)
display as text "[TRACE t4 1273] count for t4v0284 = " r(N)
quietly count if !missing(t4v0295)
display as text "[TRACE t4 1274] count for t4v0295 = " r(N)
quietly count if !missing(t4v0306)
display as text "[TRACE t4 1275] count for t4v0306 = " r(N)
quietly summarize t4v0306, detail
display as text "[TRACE-DETAIL t4 1275] p50=" %9.4f r(p50)
quietly count if !missing(t4v0317)
display as text "[TRACE t4 1276] count for t4v0317 = " r(N)
quietly count if !missing(t4v0328)
display as text "[TRACE t4 1277] count for t4v0328 = " r(N)
quietly count if !missing(t4v0339)
display as text "[TRACE t4 1278] count for t4v0339 = " r(N)
quietly count if !missing(t4v0350)
display as text "[TRACE t4 1279] count for t4v0350 = " r(N)
quietly count if !missing(t4v0361)
display as text "[TRACE t4 1280] count for t4v0361 = " r(N)
quietly count if !missing(t4v0372)
display as text "[TRACE t4 1281] count for t4v0372 = " r(N)
quietly count if !missing(t4v0383)
display as text "[TRACE t4 1282] count for t4v0383 = " r(N)
quietly count if !missing(t4v0394)
display as text "[TRACE t4 1283] count for t4v0394 = " r(N)
quietly count if !missing(t4v0405)
display as text "[TRACE t4 1284] count for t4v0405 = " r(N)
quietly count if !missing(t4v0416)
display as text "[TRACE t4 1285] count for t4v0416 = " r(N)
quietly count if !missing(t4v0427)
display as text "[TRACE t4 1286] count for t4v0427 = " r(N)
quietly count if !missing(t4v0438)
display as text "[TRACE t4 1287] count for t4v0438 = " r(N)
quietly count if !missing(t4v0449)
display as text "[TRACE t4 1288] count for t4v0449 = " r(N)
quietly count if !missing(t4v0460)
display as text "[TRACE t4 1289] count for t4v0460 = " r(N)
quietly count if !missing(t4v0471)
display as text "[TRACE t4 1290] count for t4v0471 = " r(N)
quietly count if !missing(t4v0482)
display as text "[TRACE t4 1291] count for t4v0482 = " r(N)
quietly count if !missing(t4v0493)
display as text "[TRACE t4 1292] count for t4v0493 = " r(N)
quietly summarize t4v0493, detail
display as text "[TRACE-DETAIL t4 1292] p50=" %9.4f r(p50)
quietly count if !missing(t4v0504)
display as text "[TRACE t4 1293] count for t4v0504 = " r(N)
quietly count if !missing(t4v0515)
display as text "[TRACE t4 1294] count for t4v0515 = " r(N)
quietly count if !missing(t4v0526)
display as text "[TRACE t4 1295] count for t4v0526 = " r(N)
quietly count if !missing(t4v0537)
display as text "[TRACE t4 1296] count for t4v0537 = " r(N)
quietly count if !missing(t4v0548)
display as text "[TRACE t4 1297] count for t4v0548 = " r(N)
quietly count if !missing(t4v0559)
display as text "[TRACE t4 1298] count for t4v0559 = " r(N)
quietly count if !missing(t4v0570)
display as text "[TRACE t4 1299] count for t4v0570 = " r(N)
quietly count if !missing(t4v0581)
display as text "[TRACE t4 1300] count for t4v0581 = " r(N)
display as result "<<< DONE Section 11: trace output and low-latency sentinels"
// #endregion ===== Section 11: trace output and low-latency sentinels =====


// #region ===== Section 12: final save export anchors =====
display as text ">>> START Section 12: final save export anchors"
export delimited using "$docdir/taught_task4_final.csv", replace
save "$tempdir/taught_task4_final.dta", replace
display as result "===== TAUGHT TASK 4 FINAL DONE ====="
display as result "Expected outputs: taught_task4_report.docx, taught_task4_summary.xlsx, taught_task4_final.dta/csv, graphs under figdir"
display as result "<<< DONE Section 12: final save export anchors"
// #endregion ===== Section 12: final save export anchors =====

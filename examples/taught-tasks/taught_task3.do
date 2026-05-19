/*
================================================================================
File: taught_task3.do
Purpose: self-authored Stata Workbench/native Stata 18 stress test
Goal: expose gaps against realtime shared session, low latency, no hangs,
      unchanged source do-files, and native-like graph/table/document output.
Design: generated self-contained script, target >= 5000 executable-rich lines.
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
local t3_run_stamp = subinstr("`=c(current_date)'_`=c(current_time)'", " ", "_", .)
local t3_run_stamp = subinstr("`t3_run_stamp'", ":", "", .)
global figdir3 "${tempdir}/taught_task3_graphs/`t3_run_stamp'"
cap mkdir "${tempdir}/taught_task3_graphs"
cap mkdir "$figdir3"
cap mkdir "$docdir"

display as text "===== TAUGHT TASK 3 SELF-CHECK START ====="
display as text "Stata version: " c(stata_version)
display as text "Date: " c(current_date) " Time: " c(current_time)

// #region ===== Section 1: setup data expansion =====
display as text ">>> START Section 1: setup data expansion"
sysuse auto, clear
expand 4
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
gen group_id = mod(obs_id, 8) + 1
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
gen t3v0001 = mpg + rnormal(0, 0.2)
replace t3v0001 = t3v0001 + group_id/3
gen t3v0002 = weight + rnormal(0, 0.3)
replace t3v0002 = t3v0002 + group_id/4
gen t3v0003 = length + rnormal(0, 0.4)
replace t3v0003 = t3v0003 + group_id/5
gen t3v0004 = turn + rnormal(0, 0.5)
replace t3v0004 = t3v0004 + group_id/6
gen t3v0005 = displacement + rnormal(0, 0.6)
replace t3v0005 = t3v0005 + group_id/7
label variable t3v0005 "Generated stress variable 0005"
gen t3v0006 = gear_ratio + rnormal(0, 0.7)
replace t3v0006 = t3v0006 + group_id/8
gen t3v0007 = price + rnormal(0, 0.8)
replace t3v0007 = t3v0007 + group_id/9
gen t3v0008 = mpg + rnormal(0, 0.9)
replace t3v0008 = t3v0008 + group_id/10
gen t3v0009 = weight + rnormal(0, 0.1)
replace t3v0009 = t3v0009 + group_id/11
gen t3v0010 = length + rnormal(0, 0.2)
replace t3v0010 = t3v0010 + group_id/12
label variable t3v0010 "Generated stress variable 0010"
gen t3v0011 = turn + rnormal(0, 0.3)
replace t3v0011 = t3v0011 + group_id/2
gen t3v0012 = displacement + rnormal(0, 0.4)
replace t3v0012 = t3v0012 + group_id/3
gen t3v0013 = gear_ratio + rnormal(0, 0.5)
replace t3v0013 = t3v0013 + group_id/4
gen t3v0014 = price + rnormal(0, 0.6)
replace t3v0014 = t3v0014 + group_id/5
gen t3v0015 = mpg + rnormal(0, 0.7)
replace t3v0015 = t3v0015 + group_id/6
label variable t3v0015 "Generated stress variable 0015"
gen t3v0016 = weight + rnormal(0, 0.8)
replace t3v0016 = t3v0016 + group_id/7
gen t3v0017 = length + rnormal(0, 0.9)
replace t3v0017 = t3v0017 + group_id/8
gen t3v0018 = turn + rnormal(0, 0.1)
replace t3v0018 = t3v0018 + group_id/9
gen t3v0019 = displacement + rnormal(0, 0.2)
replace t3v0019 = t3v0019 + group_id/10
gen t3v0020 = gear_ratio + rnormal(0, 0.3)
replace t3v0020 = t3v0020 + group_id/11
label variable t3v0020 "Generated stress variable 0020"
quietly summarize t3v0020
display as text "[VAR] t3v0020 mean=" %9.4f r(mean)
gen t3v0021 = price + rnormal(0, 0.4)
replace t3v0021 = t3v0021 + group_id/12
gen t3v0022 = mpg + rnormal(0, 0.5)
replace t3v0022 = t3v0022 + group_id/2
gen t3v0023 = weight + rnormal(0, 0.6)
replace t3v0023 = t3v0023 + group_id/3
gen t3v0024 = length + rnormal(0, 0.7)
replace t3v0024 = t3v0024 + group_id/4
gen t3v0025 = turn + rnormal(0, 0.8)
replace t3v0025 = t3v0025 + group_id/5
label variable t3v0025 "Generated stress variable 0025"
gen t3v0026 = displacement + rnormal(0, 0.9)
replace t3v0026 = t3v0026 + group_id/6
gen t3v0027 = gear_ratio + rnormal(0, 0.1)
replace t3v0027 = t3v0027 + group_id/7
gen t3v0028 = price + rnormal(0, 0.2)
replace t3v0028 = t3v0028 + group_id/8
gen t3v0029 = mpg + rnormal(0, 0.3)
replace t3v0029 = t3v0029 + group_id/9
gen t3v0030 = weight + rnormal(0, 0.4)
replace t3v0030 = t3v0030 + group_id/10
label variable t3v0030 "Generated stress variable 0030"
gen t3v0031 = length + rnormal(0, 0.5)
replace t3v0031 = t3v0031 + group_id/11
gen t3v0032 = turn + rnormal(0, 0.6)
replace t3v0032 = t3v0032 + group_id/12
gen t3v0033 = displacement + rnormal(0, 0.7)
replace t3v0033 = t3v0033 + group_id/2
gen t3v0034 = gear_ratio + rnormal(0, 0.8)
replace t3v0034 = t3v0034 + group_id/3
gen t3v0035 = price + rnormal(0, 0.9)
replace t3v0035 = t3v0035 + group_id/4
label variable t3v0035 "Generated stress variable 0035"
gen t3v0036 = mpg + rnormal(0, 0.1)
replace t3v0036 = t3v0036 + group_id/5
gen t3v0037 = weight + rnormal(0, 0.2)
replace t3v0037 = t3v0037 + group_id/6
gen t3v0038 = length + rnormal(0, 0.3)
replace t3v0038 = t3v0038 + group_id/7
gen t3v0039 = turn + rnormal(0, 0.4)
replace t3v0039 = t3v0039 + group_id/8
gen t3v0040 = displacement + rnormal(0, 0.5)
replace t3v0040 = t3v0040 + group_id/9
label variable t3v0040 "Generated stress variable 0040"
quietly summarize t3v0040
display as text "[VAR] t3v0040 mean=" %9.4f r(mean)
gen t3v0041 = gear_ratio + rnormal(0, 0.6)
replace t3v0041 = t3v0041 + group_id/10
gen t3v0042 = price + rnormal(0, 0.7)
replace t3v0042 = t3v0042 + group_id/11
gen t3v0043 = mpg + rnormal(0, 0.8)
replace t3v0043 = t3v0043 + group_id/12
gen t3v0044 = weight + rnormal(0, 0.9)
replace t3v0044 = t3v0044 + group_id/2
gen t3v0045 = length + rnormal(0, 0.1)
replace t3v0045 = t3v0045 + group_id/3
label variable t3v0045 "Generated stress variable 0045"
gen t3v0046 = turn + rnormal(0, 0.2)
replace t3v0046 = t3v0046 + group_id/4
gen t3v0047 = displacement + rnormal(0, 0.3)
replace t3v0047 = t3v0047 + group_id/5
gen t3v0048 = gear_ratio + rnormal(0, 0.4)
replace t3v0048 = t3v0048 + group_id/6
gen t3v0049 = price + rnormal(0, 0.5)
replace t3v0049 = t3v0049 + group_id/7
gen t3v0050 = mpg + rnormal(0, 0.6)
replace t3v0050 = t3v0050 + group_id/8
label variable t3v0050 "Generated stress variable 0050"
gen t3v0051 = weight + rnormal(0, 0.7)
replace t3v0051 = t3v0051 + group_id/9
gen t3v0052 = length + rnormal(0, 0.8)
replace t3v0052 = t3v0052 + group_id/10
gen t3v0053 = turn + rnormal(0, 0.9)
replace t3v0053 = t3v0053 + group_id/11
gen t3v0054 = displacement + rnormal(0, 0.1)
replace t3v0054 = t3v0054 + group_id/12
gen t3v0055 = gear_ratio + rnormal(0, 0.2)
replace t3v0055 = t3v0055 + group_id/2
label variable t3v0055 "Generated stress variable 0055"
gen t3v0056 = price + rnormal(0, 0.3)
replace t3v0056 = t3v0056 + group_id/3
gen t3v0057 = mpg + rnormal(0, 0.4)
replace t3v0057 = t3v0057 + group_id/4
gen t3v0058 = weight + rnormal(0, 0.5)
replace t3v0058 = t3v0058 + group_id/5
gen t3v0059 = length + rnormal(0, 0.6)
replace t3v0059 = t3v0059 + group_id/6
gen t3v0060 = turn + rnormal(0, 0.7)
replace t3v0060 = t3v0060 + group_id/7
label variable t3v0060 "Generated stress variable 0060"
quietly summarize t3v0060
display as text "[VAR] t3v0060 mean=" %9.4f r(mean)
gen t3v0061 = displacement + rnormal(0, 0.8)
replace t3v0061 = t3v0061 + group_id/8
gen t3v0062 = gear_ratio + rnormal(0, 0.9)
replace t3v0062 = t3v0062 + group_id/9
gen t3v0063 = price + rnormal(0, 0.1)
replace t3v0063 = t3v0063 + group_id/10
gen t3v0064 = mpg + rnormal(0, 0.2)
replace t3v0064 = t3v0064 + group_id/11
gen t3v0065 = weight + rnormal(0, 0.3)
replace t3v0065 = t3v0065 + group_id/12
label variable t3v0065 "Generated stress variable 0065"
gen t3v0066 = length + rnormal(0, 0.4)
replace t3v0066 = t3v0066 + group_id/2
gen t3v0067 = turn + rnormal(0, 0.5)
replace t3v0067 = t3v0067 + group_id/3
gen t3v0068 = displacement + rnormal(0, 0.6)
replace t3v0068 = t3v0068 + group_id/4
gen t3v0069 = gear_ratio + rnormal(0, 0.7)
replace t3v0069 = t3v0069 + group_id/5
gen t3v0070 = price + rnormal(0, 0.8)
replace t3v0070 = t3v0070 + group_id/6
label variable t3v0070 "Generated stress variable 0070"
gen t3v0071 = mpg + rnormal(0, 0.9)
replace t3v0071 = t3v0071 + group_id/7
gen t3v0072 = weight + rnormal(0, 0.1)
replace t3v0072 = t3v0072 + group_id/8
gen t3v0073 = length + rnormal(0, 0.2)
replace t3v0073 = t3v0073 + group_id/9
gen t3v0074 = turn + rnormal(0, 0.3)
replace t3v0074 = t3v0074 + group_id/10
gen t3v0075 = displacement + rnormal(0, 0.4)
replace t3v0075 = t3v0075 + group_id/11
label variable t3v0075 "Generated stress variable 0075"
gen t3v0076 = gear_ratio + rnormal(0, 0.5)
replace t3v0076 = t3v0076 + group_id/12
gen t3v0077 = price + rnormal(0, 0.6)
replace t3v0077 = t3v0077 + group_id/2
gen t3v0078 = mpg + rnormal(0, 0.7)
replace t3v0078 = t3v0078 + group_id/3
gen t3v0079 = weight + rnormal(0, 0.8)
replace t3v0079 = t3v0079 + group_id/4
gen t3v0080 = length + rnormal(0, 0.9)
replace t3v0080 = t3v0080 + group_id/5
label variable t3v0080 "Generated stress variable 0080"
quietly summarize t3v0080
display as text "[VAR] t3v0080 mean=" %9.4f r(mean)
gen t3v0081 = turn + rnormal(0, 0.1)
replace t3v0081 = t3v0081 + group_id/6
gen t3v0082 = displacement + rnormal(0, 0.2)
replace t3v0082 = t3v0082 + group_id/7
gen t3v0083 = gear_ratio + rnormal(0, 0.3)
replace t3v0083 = t3v0083 + group_id/8
gen t3v0084 = price + rnormal(0, 0.4)
replace t3v0084 = t3v0084 + group_id/9
gen t3v0085 = mpg + rnormal(0, 0.5)
replace t3v0085 = t3v0085 + group_id/10
label variable t3v0085 "Generated stress variable 0085"
gen t3v0086 = weight + rnormal(0, 0.6)
replace t3v0086 = t3v0086 + group_id/11
gen t3v0087 = length + rnormal(0, 0.7)
replace t3v0087 = t3v0087 + group_id/12
gen t3v0088 = turn + rnormal(0, 0.8)
replace t3v0088 = t3v0088 + group_id/2
gen t3v0089 = displacement + rnormal(0, 0.9)
replace t3v0089 = t3v0089 + group_id/3
gen t3v0090 = gear_ratio + rnormal(0, 0.1)
replace t3v0090 = t3v0090 + group_id/4
label variable t3v0090 "Generated stress variable 0090"
gen t3v0091 = price + rnormal(0, 0.2)
replace t3v0091 = t3v0091 + group_id/5
gen t3v0092 = mpg + rnormal(0, 0.3)
replace t3v0092 = t3v0092 + group_id/6
gen t3v0093 = weight + rnormal(0, 0.4)
replace t3v0093 = t3v0093 + group_id/7
gen t3v0094 = length + rnormal(0, 0.5)
replace t3v0094 = t3v0094 + group_id/8
gen t3v0095 = turn + rnormal(0, 0.6)
replace t3v0095 = t3v0095 + group_id/9
label variable t3v0095 "Generated stress variable 0095"
gen t3v0096 = displacement + rnormal(0, 0.7)
replace t3v0096 = t3v0096 + group_id/10
gen t3v0097 = gear_ratio + rnormal(0, 0.8)
replace t3v0097 = t3v0097 + group_id/11
gen t3v0098 = price + rnormal(0, 0.9)
replace t3v0098 = t3v0098 + group_id/12
gen t3v0099 = mpg + rnormal(0, 0.1)
replace t3v0099 = t3v0099 + group_id/2
gen t3v0100 = weight + rnormal(0, 0.2)
replace t3v0100 = t3v0100 + group_id/3
label variable t3v0100 "Generated stress variable 0100"
quietly summarize t3v0100
display as text "[VAR] t3v0100 mean=" %9.4f r(mean)
gen t3v0101 = length + rnormal(0, 0.3)
replace t3v0101 = t3v0101 + group_id/4
gen t3v0102 = turn + rnormal(0, 0.4)
replace t3v0102 = t3v0102 + group_id/5
gen t3v0103 = displacement + rnormal(0, 0.5)
replace t3v0103 = t3v0103 + group_id/6
gen t3v0104 = gear_ratio + rnormal(0, 0.6)
replace t3v0104 = t3v0104 + group_id/7
gen t3v0105 = price + rnormal(0, 0.7)
replace t3v0105 = t3v0105 + group_id/8
label variable t3v0105 "Generated stress variable 0105"
gen t3v0106 = mpg + rnormal(0, 0.8)
replace t3v0106 = t3v0106 + group_id/9
gen t3v0107 = weight + rnormal(0, 0.9)
replace t3v0107 = t3v0107 + group_id/10
gen t3v0108 = length + rnormal(0, 0.1)
replace t3v0108 = t3v0108 + group_id/11
gen t3v0109 = turn + rnormal(0, 0.2)
replace t3v0109 = t3v0109 + group_id/12
gen t3v0110 = displacement + rnormal(0, 0.3)
replace t3v0110 = t3v0110 + group_id/2
label variable t3v0110 "Generated stress variable 0110"
gen t3v0111 = gear_ratio + rnormal(0, 0.4)
replace t3v0111 = t3v0111 + group_id/3
gen t3v0112 = price + rnormal(0, 0.5)
replace t3v0112 = t3v0112 + group_id/4
gen t3v0113 = mpg + rnormal(0, 0.6)
replace t3v0113 = t3v0113 + group_id/5
gen t3v0114 = weight + rnormal(0, 0.7)
replace t3v0114 = t3v0114 + group_id/6
gen t3v0115 = length + rnormal(0, 0.8)
replace t3v0115 = t3v0115 + group_id/7
label variable t3v0115 "Generated stress variable 0115"
gen t3v0116 = turn + rnormal(0, 0.9)
replace t3v0116 = t3v0116 + group_id/8
gen t3v0117 = displacement + rnormal(0, 0.1)
replace t3v0117 = t3v0117 + group_id/9
gen t3v0118 = gear_ratio + rnormal(0, 0.2)
replace t3v0118 = t3v0118 + group_id/10
gen t3v0119 = price + rnormal(0, 0.3)
replace t3v0119 = t3v0119 + group_id/11
gen t3v0120 = mpg + rnormal(0, 0.4)
replace t3v0120 = t3v0120 + group_id/12
label variable t3v0120 "Generated stress variable 0120"
quietly summarize t3v0120
display as text "[VAR] t3v0120 mean=" %9.4f r(mean)
gen t3v0121 = weight + rnormal(0, 0.5)
replace t3v0121 = t3v0121 + group_id/2
gen t3v0122 = length + rnormal(0, 0.6)
replace t3v0122 = t3v0122 + group_id/3
gen t3v0123 = turn + rnormal(0, 0.7)
replace t3v0123 = t3v0123 + group_id/4
gen t3v0124 = displacement + rnormal(0, 0.8)
replace t3v0124 = t3v0124 + group_id/5
gen t3v0125 = gear_ratio + rnormal(0, 0.9)
replace t3v0125 = t3v0125 + group_id/6
label variable t3v0125 "Generated stress variable 0125"
gen t3v0126 = price + rnormal(0, 0.1)
replace t3v0126 = t3v0126 + group_id/7
gen t3v0127 = mpg + rnormal(0, 0.2)
replace t3v0127 = t3v0127 + group_id/8
gen t3v0128 = weight + rnormal(0, 0.3)
replace t3v0128 = t3v0128 + group_id/9
gen t3v0129 = length + rnormal(0, 0.4)
replace t3v0129 = t3v0129 + group_id/10
gen t3v0130 = turn + rnormal(0, 0.5)
replace t3v0130 = t3v0130 + group_id/11
label variable t3v0130 "Generated stress variable 0130"
gen t3v0131 = displacement + rnormal(0, 0.6)
replace t3v0131 = t3v0131 + group_id/12
gen t3v0132 = gear_ratio + rnormal(0, 0.7)
replace t3v0132 = t3v0132 + group_id/2
gen t3v0133 = price + rnormal(0, 0.8)
replace t3v0133 = t3v0133 + group_id/3
gen t3v0134 = mpg + rnormal(0, 0.9)
replace t3v0134 = t3v0134 + group_id/4
gen t3v0135 = weight + rnormal(0, 0.1)
replace t3v0135 = t3v0135 + group_id/5
label variable t3v0135 "Generated stress variable 0135"
gen t3v0136 = length + rnormal(0, 0.2)
replace t3v0136 = t3v0136 + group_id/6
gen t3v0137 = turn + rnormal(0, 0.3)
replace t3v0137 = t3v0137 + group_id/7
gen t3v0138 = displacement + rnormal(0, 0.4)
replace t3v0138 = t3v0138 + group_id/8
gen t3v0139 = gear_ratio + rnormal(0, 0.5)
replace t3v0139 = t3v0139 + group_id/9
gen t3v0140 = price + rnormal(0, 0.6)
replace t3v0140 = t3v0140 + group_id/10
label variable t3v0140 "Generated stress variable 0140"
quietly summarize t3v0140
display as text "[VAR] t3v0140 mean=" %9.4f r(mean)
gen t3v0141 = mpg + rnormal(0, 0.7)
replace t3v0141 = t3v0141 + group_id/11
gen t3v0142 = weight + rnormal(0, 0.8)
replace t3v0142 = t3v0142 + group_id/12
gen t3v0143 = length + rnormal(0, 0.9)
replace t3v0143 = t3v0143 + group_id/2
gen t3v0144 = turn + rnormal(0, 0.1)
replace t3v0144 = t3v0144 + group_id/3
gen t3v0145 = displacement + rnormal(0, 0.2)
replace t3v0145 = t3v0145 + group_id/4
label variable t3v0145 "Generated stress variable 0145"
gen t3v0146 = gear_ratio + rnormal(0, 0.3)
replace t3v0146 = t3v0146 + group_id/5
gen t3v0147 = price + rnormal(0, 0.4)
replace t3v0147 = t3v0147 + group_id/6
gen t3v0148 = mpg + rnormal(0, 0.5)
replace t3v0148 = t3v0148 + group_id/7
gen t3v0149 = weight + rnormal(0, 0.6)
replace t3v0149 = t3v0149 + group_id/8
gen t3v0150 = length + rnormal(0, 0.7)
replace t3v0150 = t3v0150 + group_id/9
label variable t3v0150 "Generated stress variable 0150"
gen t3v0151 = turn + rnormal(0, 0.8)
replace t3v0151 = t3v0151 + group_id/10
gen t3v0152 = displacement + rnormal(0, 0.9)
replace t3v0152 = t3v0152 + group_id/11
gen t3v0153 = gear_ratio + rnormal(0, 0.1)
replace t3v0153 = t3v0153 + group_id/12
gen t3v0154 = price + rnormal(0, 0.2)
replace t3v0154 = t3v0154 + group_id/2
gen t3v0155 = mpg + rnormal(0, 0.3)
replace t3v0155 = t3v0155 + group_id/3
label variable t3v0155 "Generated stress variable 0155"
gen t3v0156 = weight + rnormal(0, 0.4)
replace t3v0156 = t3v0156 + group_id/4
gen t3v0157 = length + rnormal(0, 0.5)
replace t3v0157 = t3v0157 + group_id/5
gen t3v0158 = turn + rnormal(0, 0.6)
replace t3v0158 = t3v0158 + group_id/6
gen t3v0159 = displacement + rnormal(0, 0.7)
replace t3v0159 = t3v0159 + group_id/7
gen t3v0160 = gear_ratio + rnormal(0, 0.8)
replace t3v0160 = t3v0160 + group_id/8
label variable t3v0160 "Generated stress variable 0160"
quietly summarize t3v0160
display as text "[VAR] t3v0160 mean=" %9.4f r(mean)
gen t3v0161 = price + rnormal(0, 0.9)
replace t3v0161 = t3v0161 + group_id/9
gen t3v0162 = mpg + rnormal(0, 0.1)
replace t3v0162 = t3v0162 + group_id/10
gen t3v0163 = weight + rnormal(0, 0.2)
replace t3v0163 = t3v0163 + group_id/11
gen t3v0164 = length + rnormal(0, 0.3)
replace t3v0164 = t3v0164 + group_id/12
gen t3v0165 = turn + rnormal(0, 0.4)
replace t3v0165 = t3v0165 + group_id/2
label variable t3v0165 "Generated stress variable 0165"
gen t3v0166 = displacement + rnormal(0, 0.5)
replace t3v0166 = t3v0166 + group_id/3
gen t3v0167 = gear_ratio + rnormal(0, 0.6)
replace t3v0167 = t3v0167 + group_id/4
gen t3v0168 = price + rnormal(0, 0.7)
replace t3v0168 = t3v0168 + group_id/5
gen t3v0169 = mpg + rnormal(0, 0.8)
replace t3v0169 = t3v0169 + group_id/6
gen t3v0170 = weight + rnormal(0, 0.9)
replace t3v0170 = t3v0170 + group_id/7
label variable t3v0170 "Generated stress variable 0170"
gen t3v0171 = length + rnormal(0, 0.1)
replace t3v0171 = t3v0171 + group_id/8
gen t3v0172 = turn + rnormal(0, 0.2)
replace t3v0172 = t3v0172 + group_id/9
gen t3v0173 = displacement + rnormal(0, 0.3)
replace t3v0173 = t3v0173 + group_id/10
gen t3v0174 = gear_ratio + rnormal(0, 0.4)
replace t3v0174 = t3v0174 + group_id/11
gen t3v0175 = price + rnormal(0, 0.5)
replace t3v0175 = t3v0175 + group_id/12
label variable t3v0175 "Generated stress variable 0175"
gen t3v0176 = mpg + rnormal(0, 0.6)
replace t3v0176 = t3v0176 + group_id/2
gen t3v0177 = weight + rnormal(0, 0.7)
replace t3v0177 = t3v0177 + group_id/3
gen t3v0178 = length + rnormal(0, 0.8)
replace t3v0178 = t3v0178 + group_id/4
gen t3v0179 = turn + rnormal(0, 0.9)
replace t3v0179 = t3v0179 + group_id/5
gen t3v0180 = displacement + rnormal(0, 0.1)
replace t3v0180 = t3v0180 + group_id/6
label variable t3v0180 "Generated stress variable 0180"
quietly summarize t3v0180
display as text "[VAR] t3v0180 mean=" %9.4f r(mean)
gen t3v0181 = gear_ratio + rnormal(0, 0.2)
replace t3v0181 = t3v0181 + group_id/7
gen t3v0182 = price + rnormal(0, 0.3)
replace t3v0182 = t3v0182 + group_id/8
gen t3v0183 = mpg + rnormal(0, 0.4)
replace t3v0183 = t3v0183 + group_id/9
gen t3v0184 = weight + rnormal(0, 0.5)
replace t3v0184 = t3v0184 + group_id/10
gen t3v0185 = length + rnormal(0, 0.6)
replace t3v0185 = t3v0185 + group_id/11
label variable t3v0185 "Generated stress variable 0185"
gen t3v0186 = turn + rnormal(0, 0.7)
replace t3v0186 = t3v0186 + group_id/12
gen t3v0187 = displacement + rnormal(0, 0.8)
replace t3v0187 = t3v0187 + group_id/2
gen t3v0188 = gear_ratio + rnormal(0, 0.9)
replace t3v0188 = t3v0188 + group_id/3
gen t3v0189 = price + rnormal(0, 0.1)
replace t3v0189 = t3v0189 + group_id/4
gen t3v0190 = mpg + rnormal(0, 0.2)
replace t3v0190 = t3v0190 + group_id/5
label variable t3v0190 "Generated stress variable 0190"
gen t3v0191 = weight + rnormal(0, 0.3)
replace t3v0191 = t3v0191 + group_id/6
gen t3v0192 = length + rnormal(0, 0.4)
replace t3v0192 = t3v0192 + group_id/7
gen t3v0193 = turn + rnormal(0, 0.5)
replace t3v0193 = t3v0193 + group_id/8
gen t3v0194 = displacement + rnormal(0, 0.6)
replace t3v0194 = t3v0194 + group_id/9
gen t3v0195 = gear_ratio + rnormal(0, 0.7)
replace t3v0195 = t3v0195 + group_id/10
label variable t3v0195 "Generated stress variable 0195"
gen t3v0196 = price + rnormal(0, 0.8)
replace t3v0196 = t3v0196 + group_id/11
gen t3v0197 = mpg + rnormal(0, 0.9)
replace t3v0197 = t3v0197 + group_id/12
gen t3v0198 = weight + rnormal(0, 0.1)
replace t3v0198 = t3v0198 + group_id/2
gen t3v0199 = length + rnormal(0, 0.2)
replace t3v0199 = t3v0199 + group_id/3
gen t3v0200 = turn + rnormal(0, 0.3)
replace t3v0200 = t3v0200 + group_id/4
label variable t3v0200 "Generated stress variable 0200"
quietly summarize t3v0200
display as text "[VAR] t3v0200 mean=" %9.4f r(mean)
gen t3v0201 = displacement + rnormal(0, 0.4)
replace t3v0201 = t3v0201 + group_id/5
gen t3v0202 = gear_ratio + rnormal(0, 0.5)
replace t3v0202 = t3v0202 + group_id/6
gen t3v0203 = price + rnormal(0, 0.6)
replace t3v0203 = t3v0203 + group_id/7
gen t3v0204 = mpg + rnormal(0, 0.7)
replace t3v0204 = t3v0204 + group_id/8
gen t3v0205 = weight + rnormal(0, 0.8)
replace t3v0205 = t3v0205 + group_id/9
label variable t3v0205 "Generated stress variable 0205"
gen t3v0206 = length + rnormal(0, 0.9)
replace t3v0206 = t3v0206 + group_id/10
gen t3v0207 = turn + rnormal(0, 0.1)
replace t3v0207 = t3v0207 + group_id/11
gen t3v0208 = displacement + rnormal(0, 0.2)
replace t3v0208 = t3v0208 + group_id/12
gen t3v0209 = gear_ratio + rnormal(0, 0.3)
replace t3v0209 = t3v0209 + group_id/2
gen t3v0210 = price + rnormal(0, 0.4)
replace t3v0210 = t3v0210 + group_id/3
label variable t3v0210 "Generated stress variable 0210"
gen t3v0211 = mpg + rnormal(0, 0.5)
replace t3v0211 = t3v0211 + group_id/4
gen t3v0212 = weight + rnormal(0, 0.6)
replace t3v0212 = t3v0212 + group_id/5
gen t3v0213 = length + rnormal(0, 0.7)
replace t3v0213 = t3v0213 + group_id/6
gen t3v0214 = turn + rnormal(0, 0.8)
replace t3v0214 = t3v0214 + group_id/7
gen t3v0215 = displacement + rnormal(0, 0.9)
replace t3v0215 = t3v0215 + group_id/8
label variable t3v0215 "Generated stress variable 0215"
gen t3v0216 = gear_ratio + rnormal(0, 0.1)
replace t3v0216 = t3v0216 + group_id/9
gen t3v0217 = price + rnormal(0, 0.2)
replace t3v0217 = t3v0217 + group_id/10
gen t3v0218 = mpg + rnormal(0, 0.3)
replace t3v0218 = t3v0218 + group_id/11
gen t3v0219 = weight + rnormal(0, 0.4)
replace t3v0219 = t3v0219 + group_id/12
gen t3v0220 = length + rnormal(0, 0.5)
replace t3v0220 = t3v0220 + group_id/2
label variable t3v0220 "Generated stress variable 0220"
quietly summarize t3v0220
display as text "[VAR] t3v0220 mean=" %9.4f r(mean)
gen t3v0221 = turn + rnormal(0, 0.6)
replace t3v0221 = t3v0221 + group_id/3
gen t3v0222 = displacement + rnormal(0, 0.7)
replace t3v0222 = t3v0222 + group_id/4
gen t3v0223 = gear_ratio + rnormal(0, 0.8)
replace t3v0223 = t3v0223 + group_id/5
gen t3v0224 = price + rnormal(0, 0.9)
replace t3v0224 = t3v0224 + group_id/6
gen t3v0225 = mpg + rnormal(0, 0.1)
replace t3v0225 = t3v0225 + group_id/7
label variable t3v0225 "Generated stress variable 0225"
gen t3v0226 = weight + rnormal(0, 0.2)
replace t3v0226 = t3v0226 + group_id/8
gen t3v0227 = length + rnormal(0, 0.3)
replace t3v0227 = t3v0227 + group_id/9
gen t3v0228 = turn + rnormal(0, 0.4)
replace t3v0228 = t3v0228 + group_id/10
gen t3v0229 = displacement + rnormal(0, 0.5)
replace t3v0229 = t3v0229 + group_id/11
gen t3v0230 = gear_ratio + rnormal(0, 0.6)
replace t3v0230 = t3v0230 + group_id/12
label variable t3v0230 "Generated stress variable 0230"
gen t3v0231 = price + rnormal(0, 0.7)
replace t3v0231 = t3v0231 + group_id/2
gen t3v0232 = mpg + rnormal(0, 0.8)
replace t3v0232 = t3v0232 + group_id/3
gen t3v0233 = weight + rnormal(0, 0.9)
replace t3v0233 = t3v0233 + group_id/4
gen t3v0234 = length + rnormal(0, 0.1)
replace t3v0234 = t3v0234 + group_id/5
gen t3v0235 = turn + rnormal(0, 0.2)
replace t3v0235 = t3v0235 + group_id/6
label variable t3v0235 "Generated stress variable 0235"
gen t3v0236 = displacement + rnormal(0, 0.3)
replace t3v0236 = t3v0236 + group_id/7
gen t3v0237 = gear_ratio + rnormal(0, 0.4)
replace t3v0237 = t3v0237 + group_id/8
gen t3v0238 = price + rnormal(0, 0.5)
replace t3v0238 = t3v0238 + group_id/9
gen t3v0239 = mpg + rnormal(0, 0.6)
replace t3v0239 = t3v0239 + group_id/10
gen t3v0240 = weight + rnormal(0, 0.7)
replace t3v0240 = t3v0240 + group_id/11
label variable t3v0240 "Generated stress variable 0240"
quietly summarize t3v0240
display as text "[VAR] t3v0240 mean=" %9.4f r(mean)
gen t3v0241 = length + rnormal(0, 0.8)
replace t3v0241 = t3v0241 + group_id/12
gen t3v0242 = turn + rnormal(0, 0.9)
replace t3v0242 = t3v0242 + group_id/2
gen t3v0243 = displacement + rnormal(0, 0.1)
replace t3v0243 = t3v0243 + group_id/3
gen t3v0244 = gear_ratio + rnormal(0, 0.2)
replace t3v0244 = t3v0244 + group_id/4
gen t3v0245 = price + rnormal(0, 0.3)
replace t3v0245 = t3v0245 + group_id/5
label variable t3v0245 "Generated stress variable 0245"
gen t3v0246 = mpg + rnormal(0, 0.4)
replace t3v0246 = t3v0246 + group_id/6
gen t3v0247 = weight + rnormal(0, 0.5)
replace t3v0247 = t3v0247 + group_id/7
gen t3v0248 = length + rnormal(0, 0.6)
replace t3v0248 = t3v0248 + group_id/8
gen t3v0249 = turn + rnormal(0, 0.7)
replace t3v0249 = t3v0249 + group_id/9
gen t3v0250 = displacement + rnormal(0, 0.8)
replace t3v0250 = t3v0250 + group_id/10
label variable t3v0250 "Generated stress variable 0250"
gen t3v0251 = gear_ratio + rnormal(0, 0.9)
replace t3v0251 = t3v0251 + group_id/11
gen t3v0252 = price + rnormal(0, 0.1)
replace t3v0252 = t3v0252 + group_id/12
gen t3v0253 = mpg + rnormal(0, 0.2)
replace t3v0253 = t3v0253 + group_id/2
gen t3v0254 = weight + rnormal(0, 0.3)
replace t3v0254 = t3v0254 + group_id/3
gen t3v0255 = length + rnormal(0, 0.4)
replace t3v0255 = t3v0255 + group_id/4
label variable t3v0255 "Generated stress variable 0255"
gen t3v0256 = turn + rnormal(0, 0.5)
replace t3v0256 = t3v0256 + group_id/5
gen t3v0257 = displacement + rnormal(0, 0.6)
replace t3v0257 = t3v0257 + group_id/6
gen t3v0258 = gear_ratio + rnormal(0, 0.7)
replace t3v0258 = t3v0258 + group_id/7
gen t3v0259 = price + rnormal(0, 0.8)
replace t3v0259 = t3v0259 + group_id/8
gen t3v0260 = mpg + rnormal(0, 0.9)
replace t3v0260 = t3v0260 + group_id/9
label variable t3v0260 "Generated stress variable 0260"
quietly summarize t3v0260
display as text "[VAR] t3v0260 mean=" %9.4f r(mean)
gen t3v0261 = weight + rnormal(0, 0.1)
replace t3v0261 = t3v0261 + group_id/10
gen t3v0262 = length + rnormal(0, 0.2)
replace t3v0262 = t3v0262 + group_id/11
gen t3v0263 = turn + rnormal(0, 0.3)
replace t3v0263 = t3v0263 + group_id/12
gen t3v0264 = displacement + rnormal(0, 0.4)
replace t3v0264 = t3v0264 + group_id/2
gen t3v0265 = gear_ratio + rnormal(0, 0.5)
replace t3v0265 = t3v0265 + group_id/3
label variable t3v0265 "Generated stress variable 0265"
gen t3v0266 = price + rnormal(0, 0.6)
replace t3v0266 = t3v0266 + group_id/4
gen t3v0267 = mpg + rnormal(0, 0.7)
replace t3v0267 = t3v0267 + group_id/5
gen t3v0268 = weight + rnormal(0, 0.8)
replace t3v0268 = t3v0268 + group_id/6
gen t3v0269 = length + rnormal(0, 0.9)
replace t3v0269 = t3v0269 + group_id/7
gen t3v0270 = turn + rnormal(0, 0.1)
replace t3v0270 = t3v0270 + group_id/8
label variable t3v0270 "Generated stress variable 0270"
gen t3v0271 = displacement + rnormal(0, 0.2)
replace t3v0271 = t3v0271 + group_id/9
gen t3v0272 = gear_ratio + rnormal(0, 0.3)
replace t3v0272 = t3v0272 + group_id/10
gen t3v0273 = price + rnormal(0, 0.4)
replace t3v0273 = t3v0273 + group_id/11
gen t3v0274 = mpg + rnormal(0, 0.5)
replace t3v0274 = t3v0274 + group_id/12
gen t3v0275 = weight + rnormal(0, 0.6)
replace t3v0275 = t3v0275 + group_id/2
label variable t3v0275 "Generated stress variable 0275"
gen t3v0276 = length + rnormal(0, 0.7)
replace t3v0276 = t3v0276 + group_id/3
gen t3v0277 = turn + rnormal(0, 0.8)
replace t3v0277 = t3v0277 + group_id/4
gen t3v0278 = displacement + rnormal(0, 0.9)
replace t3v0278 = t3v0278 + group_id/5
gen t3v0279 = gear_ratio + rnormal(0, 0.1)
replace t3v0279 = t3v0279 + group_id/6
gen t3v0280 = price + rnormal(0, 0.2)
replace t3v0280 = t3v0280 + group_id/7
label variable t3v0280 "Generated stress variable 0280"
quietly summarize t3v0280
display as text "[VAR] t3v0280 mean=" %9.4f r(mean)
gen t3v0281 = mpg + rnormal(0, 0.3)
replace t3v0281 = t3v0281 + group_id/8
gen t3v0282 = weight + rnormal(0, 0.4)
replace t3v0282 = t3v0282 + group_id/9
gen t3v0283 = length + rnormal(0, 0.5)
replace t3v0283 = t3v0283 + group_id/10
gen t3v0284 = turn + rnormal(0, 0.6)
replace t3v0284 = t3v0284 + group_id/11
gen t3v0285 = displacement + rnormal(0, 0.7)
replace t3v0285 = t3v0285 + group_id/12
label variable t3v0285 "Generated stress variable 0285"
gen t3v0286 = gear_ratio + rnormal(0, 0.8)
replace t3v0286 = t3v0286 + group_id/2
gen t3v0287 = price + rnormal(0, 0.9)
replace t3v0287 = t3v0287 + group_id/3
gen t3v0288 = mpg + rnormal(0, 0.1)
replace t3v0288 = t3v0288 + group_id/4
gen t3v0289 = weight + rnormal(0, 0.2)
replace t3v0289 = t3v0289 + group_id/5
gen t3v0290 = length + rnormal(0, 0.3)
replace t3v0290 = t3v0290 + group_id/6
label variable t3v0290 "Generated stress variable 0290"
gen t3v0291 = turn + rnormal(0, 0.4)
replace t3v0291 = t3v0291 + group_id/7
gen t3v0292 = displacement + rnormal(0, 0.5)
replace t3v0292 = t3v0292 + group_id/8
gen t3v0293 = gear_ratio + rnormal(0, 0.6)
replace t3v0293 = t3v0293 + group_id/9
gen t3v0294 = price + rnormal(0, 0.7)
replace t3v0294 = t3v0294 + group_id/10
gen t3v0295 = mpg + rnormal(0, 0.8)
replace t3v0295 = t3v0295 + group_id/11
label variable t3v0295 "Generated stress variable 0295"
gen t3v0296 = weight + rnormal(0, 0.9)
replace t3v0296 = t3v0296 + group_id/12
gen t3v0297 = length + rnormal(0, 0.1)
replace t3v0297 = t3v0297 + group_id/2
gen t3v0298 = turn + rnormal(0, 0.2)
replace t3v0298 = t3v0298 + group_id/3
gen t3v0299 = displacement + rnormal(0, 0.3)
replace t3v0299 = t3v0299 + group_id/4
gen t3v0300 = gear_ratio + rnormal(0, 0.4)
replace t3v0300 = t3v0300 + group_id/5
label variable t3v0300 "Generated stress variable 0300"
quietly summarize t3v0300
display as text "[VAR] t3v0300 mean=" %9.4f r(mean)
gen t3v0301 = price + rnormal(0, 0.5)
replace t3v0301 = t3v0301 + group_id/6
gen t3v0302 = mpg + rnormal(0, 0.6)
replace t3v0302 = t3v0302 + group_id/7
gen t3v0303 = weight + rnormal(0, 0.7)
replace t3v0303 = t3v0303 + group_id/8
gen t3v0304 = length + rnormal(0, 0.8)
replace t3v0304 = t3v0304 + group_id/9
gen t3v0305 = turn + rnormal(0, 0.9)
replace t3v0305 = t3v0305 + group_id/10
label variable t3v0305 "Generated stress variable 0305"
gen t3v0306 = displacement + rnormal(0, 0.1)
replace t3v0306 = t3v0306 + group_id/11
gen t3v0307 = gear_ratio + rnormal(0, 0.2)
replace t3v0307 = t3v0307 + group_id/12
gen t3v0308 = price + rnormal(0, 0.3)
replace t3v0308 = t3v0308 + group_id/2
gen t3v0309 = mpg + rnormal(0, 0.4)
replace t3v0309 = t3v0309 + group_id/3
gen t3v0310 = weight + rnormal(0, 0.5)
replace t3v0310 = t3v0310 + group_id/4
label variable t3v0310 "Generated stress variable 0310"
gen t3v0311 = length + rnormal(0, 0.6)
replace t3v0311 = t3v0311 + group_id/5
gen t3v0312 = turn + rnormal(0, 0.7)
replace t3v0312 = t3v0312 + group_id/6
gen t3v0313 = displacement + rnormal(0, 0.8)
replace t3v0313 = t3v0313 + group_id/7
gen t3v0314 = gear_ratio + rnormal(0, 0.9)
replace t3v0314 = t3v0314 + group_id/8
gen t3v0315 = price + rnormal(0, 0.1)
replace t3v0315 = t3v0315 + group_id/9
label variable t3v0315 "Generated stress variable 0315"
gen t3v0316 = mpg + rnormal(0, 0.2)
replace t3v0316 = t3v0316 + group_id/10
gen t3v0317 = weight + rnormal(0, 0.3)
replace t3v0317 = t3v0317 + group_id/11
gen t3v0318 = length + rnormal(0, 0.4)
replace t3v0318 = t3v0318 + group_id/12
gen t3v0319 = turn + rnormal(0, 0.5)
replace t3v0319 = t3v0319 + group_id/2
gen t3v0320 = displacement + rnormal(0, 0.6)
replace t3v0320 = t3v0320 + group_id/3
label variable t3v0320 "Generated stress variable 0320"
quietly summarize t3v0320
display as text "[VAR] t3v0320 mean=" %9.4f r(mean)
gen t3v0321 = gear_ratio + rnormal(0, 0.7)
replace t3v0321 = t3v0321 + group_id/4
gen t3v0322 = price + rnormal(0, 0.8)
replace t3v0322 = t3v0322 + group_id/5
gen t3v0323 = mpg + rnormal(0, 0.9)
replace t3v0323 = t3v0323 + group_id/6
gen t3v0324 = weight + rnormal(0, 0.1)
replace t3v0324 = t3v0324 + group_id/7
gen t3v0325 = length + rnormal(0, 0.2)
replace t3v0325 = t3v0325 + group_id/8
label variable t3v0325 "Generated stress variable 0325"
gen t3v0326 = turn + rnormal(0, 0.3)
replace t3v0326 = t3v0326 + group_id/9
gen t3v0327 = displacement + rnormal(0, 0.4)
replace t3v0327 = t3v0327 + group_id/10
gen t3v0328 = gear_ratio + rnormal(0, 0.5)
replace t3v0328 = t3v0328 + group_id/11
gen t3v0329 = price + rnormal(0, 0.6)
replace t3v0329 = t3v0329 + group_id/12
gen t3v0330 = mpg + rnormal(0, 0.7)
replace t3v0330 = t3v0330 + group_id/2
label variable t3v0330 "Generated stress variable 0330"
gen t3v0331 = weight + rnormal(0, 0.8)
replace t3v0331 = t3v0331 + group_id/3
gen t3v0332 = length + rnormal(0, 0.9)
replace t3v0332 = t3v0332 + group_id/4
gen t3v0333 = turn + rnormal(0, 0.1)
replace t3v0333 = t3v0333 + group_id/5
gen t3v0334 = displacement + rnormal(0, 0.2)
replace t3v0334 = t3v0334 + group_id/6
gen t3v0335 = gear_ratio + rnormal(0, 0.3)
replace t3v0335 = t3v0335 + group_id/7
label variable t3v0335 "Generated stress variable 0335"
gen t3v0336 = price + rnormal(0, 0.4)
replace t3v0336 = t3v0336 + group_id/8
gen t3v0337 = mpg + rnormal(0, 0.5)
replace t3v0337 = t3v0337 + group_id/9
gen t3v0338 = weight + rnormal(0, 0.6)
replace t3v0338 = t3v0338 + group_id/10
gen t3v0339 = length + rnormal(0, 0.7)
replace t3v0339 = t3v0339 + group_id/11
gen t3v0340 = turn + rnormal(0, 0.8)
replace t3v0340 = t3v0340 + group_id/12
label variable t3v0340 "Generated stress variable 0340"
quietly summarize t3v0340
display as text "[VAR] t3v0340 mean=" %9.4f r(mean)
gen t3v0341 = displacement + rnormal(0, 0.9)
replace t3v0341 = t3v0341 + group_id/2
gen t3v0342 = gear_ratio + rnormal(0, 0.1)
replace t3v0342 = t3v0342 + group_id/3
gen t3v0343 = price + rnormal(0, 0.2)
replace t3v0343 = t3v0343 + group_id/4
gen t3v0344 = mpg + rnormal(0, 0.3)
replace t3v0344 = t3v0344 + group_id/5
gen t3v0345 = weight + rnormal(0, 0.4)
replace t3v0345 = t3v0345 + group_id/6
label variable t3v0345 "Generated stress variable 0345"
gen t3v0346 = length + rnormal(0, 0.5)
replace t3v0346 = t3v0346 + group_id/7
gen t3v0347 = turn + rnormal(0, 0.6)
replace t3v0347 = t3v0347 + group_id/8
gen t3v0348 = displacement + rnormal(0, 0.7)
replace t3v0348 = t3v0348 + group_id/9
gen t3v0349 = gear_ratio + rnormal(0, 0.8)
replace t3v0349 = t3v0349 + group_id/10
gen t3v0350 = price + rnormal(0, 0.9)
replace t3v0350 = t3v0350 + group_id/11
label variable t3v0350 "Generated stress variable 0350"
gen t3v0351 = mpg + rnormal(0, 0.1)
replace t3v0351 = t3v0351 + group_id/12
gen t3v0352 = weight + rnormal(0, 0.2)
replace t3v0352 = t3v0352 + group_id/2
gen t3v0353 = length + rnormal(0, 0.3)
replace t3v0353 = t3v0353 + group_id/3
gen t3v0354 = turn + rnormal(0, 0.4)
replace t3v0354 = t3v0354 + group_id/4
gen t3v0355 = displacement + rnormal(0, 0.5)
replace t3v0355 = t3v0355 + group_id/5
label variable t3v0355 "Generated stress variable 0355"
gen t3v0356 = gear_ratio + rnormal(0, 0.6)
replace t3v0356 = t3v0356 + group_id/6
gen t3v0357 = price + rnormal(0, 0.7)
replace t3v0357 = t3v0357 + group_id/7
gen t3v0358 = mpg + rnormal(0, 0.8)
replace t3v0358 = t3v0358 + group_id/8
gen t3v0359 = weight + rnormal(0, 0.9)
replace t3v0359 = t3v0359 + group_id/9
gen t3v0360 = length + rnormal(0, 0.1)
replace t3v0360 = t3v0360 + group_id/10
label variable t3v0360 "Generated stress variable 0360"
quietly summarize t3v0360
display as text "[VAR] t3v0360 mean=" %9.4f r(mean)
gen t3v0361 = turn + rnormal(0, 0.2)
replace t3v0361 = t3v0361 + group_id/11
gen t3v0362 = displacement + rnormal(0, 0.3)
replace t3v0362 = t3v0362 + group_id/12
gen t3v0363 = gear_ratio + rnormal(0, 0.4)
replace t3v0363 = t3v0363 + group_id/2
gen t3v0364 = price + rnormal(0, 0.5)
replace t3v0364 = t3v0364 + group_id/3
gen t3v0365 = mpg + rnormal(0, 0.6)
replace t3v0365 = t3v0365 + group_id/4
label variable t3v0365 "Generated stress variable 0365"
gen t3v0366 = weight + rnormal(0, 0.7)
replace t3v0366 = t3v0366 + group_id/5
gen t3v0367 = length + rnormal(0, 0.8)
replace t3v0367 = t3v0367 + group_id/6
gen t3v0368 = turn + rnormal(0, 0.9)
replace t3v0368 = t3v0368 + group_id/7
gen t3v0369 = displacement + rnormal(0, 0.1)
replace t3v0369 = t3v0369 + group_id/8
gen t3v0370 = gear_ratio + rnormal(0, 0.2)
replace t3v0370 = t3v0370 + group_id/9
label variable t3v0370 "Generated stress variable 0370"
gen t3v0371 = price + rnormal(0, 0.3)
replace t3v0371 = t3v0371 + group_id/10
gen t3v0372 = mpg + rnormal(0, 0.4)
replace t3v0372 = t3v0372 + group_id/11
gen t3v0373 = weight + rnormal(0, 0.5)
replace t3v0373 = t3v0373 + group_id/12
gen t3v0374 = length + rnormal(0, 0.6)
replace t3v0374 = t3v0374 + group_id/2
gen t3v0375 = turn + rnormal(0, 0.7)
replace t3v0375 = t3v0375 + group_id/3
label variable t3v0375 "Generated stress variable 0375"
gen t3v0376 = displacement + rnormal(0, 0.8)
replace t3v0376 = t3v0376 + group_id/4
gen t3v0377 = gear_ratio + rnormal(0, 0.9)
replace t3v0377 = t3v0377 + group_id/5
gen t3v0378 = price + rnormal(0, 0.1)
replace t3v0378 = t3v0378 + group_id/6
gen t3v0379 = mpg + rnormal(0, 0.2)
replace t3v0379 = t3v0379 + group_id/7
gen t3v0380 = weight + rnormal(0, 0.3)
replace t3v0380 = t3v0380 + group_id/8
label variable t3v0380 "Generated stress variable 0380"
quietly summarize t3v0380
display as text "[VAR] t3v0380 mean=" %9.4f r(mean)
gen t3v0381 = length + rnormal(0, 0.4)
replace t3v0381 = t3v0381 + group_id/9
gen t3v0382 = turn + rnormal(0, 0.5)
replace t3v0382 = t3v0382 + group_id/10
gen t3v0383 = displacement + rnormal(0, 0.6)
replace t3v0383 = t3v0383 + group_id/11
gen t3v0384 = gear_ratio + rnormal(0, 0.7)
replace t3v0384 = t3v0384 + group_id/12
gen t3v0385 = price + rnormal(0, 0.8)
replace t3v0385 = t3v0385 + group_id/2
label variable t3v0385 "Generated stress variable 0385"
gen t3v0386 = mpg + rnormal(0, 0.9)
replace t3v0386 = t3v0386 + group_id/3
gen t3v0387 = weight + rnormal(0, 0.1)
replace t3v0387 = t3v0387 + group_id/4
gen t3v0388 = length + rnormal(0, 0.2)
replace t3v0388 = t3v0388 + group_id/5
gen t3v0389 = turn + rnormal(0, 0.3)
replace t3v0389 = t3v0389 + group_id/6
gen t3v0390 = displacement + rnormal(0, 0.4)
replace t3v0390 = t3v0390 + group_id/7
label variable t3v0390 "Generated stress variable 0390"
gen t3v0391 = gear_ratio + rnormal(0, 0.5)
replace t3v0391 = t3v0391 + group_id/8
gen t3v0392 = price + rnormal(0, 0.6)
replace t3v0392 = t3v0392 + group_id/9
gen t3v0393 = mpg + rnormal(0, 0.7)
replace t3v0393 = t3v0393 + group_id/10
gen t3v0394 = weight + rnormal(0, 0.8)
replace t3v0394 = t3v0394 + group_id/11
gen t3v0395 = length + rnormal(0, 0.9)
replace t3v0395 = t3v0395 + group_id/12
label variable t3v0395 "Generated stress variable 0395"
gen t3v0396 = turn + rnormal(0, 0.1)
replace t3v0396 = t3v0396 + group_id/2
gen t3v0397 = displacement + rnormal(0, 0.2)
replace t3v0397 = t3v0397 + group_id/3
gen t3v0398 = gear_ratio + rnormal(0, 0.3)
replace t3v0398 = t3v0398 + group_id/4
gen t3v0399 = price + rnormal(0, 0.4)
replace t3v0399 = t3v0399 + group_id/5
gen t3v0400 = mpg + rnormal(0, 0.5)
replace t3v0400 = t3v0400 + group_id/6
label variable t3v0400 "Generated stress variable 0400"
quietly summarize t3v0400
display as text "[VAR] t3v0400 mean=" %9.4f r(mean)
gen t3v0401 = weight + rnormal(0, 0.6)
replace t3v0401 = t3v0401 + group_id/7
gen t3v0402 = length + rnormal(0, 0.7)
replace t3v0402 = t3v0402 + group_id/8
gen t3v0403 = turn + rnormal(0, 0.8)
replace t3v0403 = t3v0403 + group_id/9
gen t3v0404 = displacement + rnormal(0, 0.9)
replace t3v0404 = t3v0404 + group_id/10
gen t3v0405 = gear_ratio + rnormal(0, 0.1)
replace t3v0405 = t3v0405 + group_id/11
label variable t3v0405 "Generated stress variable 0405"
gen t3v0406 = price + rnormal(0, 0.2)
replace t3v0406 = t3v0406 + group_id/12
gen t3v0407 = mpg + rnormal(0, 0.3)
replace t3v0407 = t3v0407 + group_id/2
gen t3v0408 = weight + rnormal(0, 0.4)
replace t3v0408 = t3v0408 + group_id/3
gen t3v0409 = length + rnormal(0, 0.5)
replace t3v0409 = t3v0409 + group_id/4
gen t3v0410 = turn + rnormal(0, 0.6)
replace t3v0410 = t3v0410 + group_id/5
label variable t3v0410 "Generated stress variable 0410"
gen t3v0411 = displacement + rnormal(0, 0.7)
replace t3v0411 = t3v0411 + group_id/6
gen t3v0412 = gear_ratio + rnormal(0, 0.8)
replace t3v0412 = t3v0412 + group_id/7
gen t3v0413 = price + rnormal(0, 0.9)
replace t3v0413 = t3v0413 + group_id/8
gen t3v0414 = mpg + rnormal(0, 0.1)
replace t3v0414 = t3v0414 + group_id/9
gen t3v0415 = weight + rnormal(0, 0.2)
replace t3v0415 = t3v0415 + group_id/10
label variable t3v0415 "Generated stress variable 0415"
gen t3v0416 = length + rnormal(0, 0.3)
replace t3v0416 = t3v0416 + group_id/11
gen t3v0417 = turn + rnormal(0, 0.4)
replace t3v0417 = t3v0417 + group_id/12
gen t3v0418 = displacement + rnormal(0, 0.5)
replace t3v0418 = t3v0418 + group_id/2
gen t3v0419 = gear_ratio + rnormal(0, 0.6)
replace t3v0419 = t3v0419 + group_id/3
gen t3v0420 = price + rnormal(0, 0.7)
replace t3v0420 = t3v0420 + group_id/4
label variable t3v0420 "Generated stress variable 0420"
quietly summarize t3v0420
display as text "[VAR] t3v0420 mean=" %9.4f r(mean)
gen t3v0421 = mpg + rnormal(0, 0.8)
replace t3v0421 = t3v0421 + group_id/5
gen t3v0422 = weight + rnormal(0, 0.9)
replace t3v0422 = t3v0422 + group_id/6
gen t3v0423 = length + rnormal(0, 0.1)
replace t3v0423 = t3v0423 + group_id/7
gen t3v0424 = turn + rnormal(0, 0.2)
replace t3v0424 = t3v0424 + group_id/8
gen t3v0425 = displacement + rnormal(0, 0.3)
replace t3v0425 = t3v0425 + group_id/9
label variable t3v0425 "Generated stress variable 0425"
gen t3v0426 = gear_ratio + rnormal(0, 0.4)
replace t3v0426 = t3v0426 + group_id/10
gen t3v0427 = price + rnormal(0, 0.5)
replace t3v0427 = t3v0427 + group_id/11
gen t3v0428 = mpg + rnormal(0, 0.6)
replace t3v0428 = t3v0428 + group_id/12
gen t3v0429 = weight + rnormal(0, 0.7)
replace t3v0429 = t3v0429 + group_id/2
gen t3v0430 = length + rnormal(0, 0.8)
replace t3v0430 = t3v0430 + group_id/3
label variable t3v0430 "Generated stress variable 0430"
gen t3v0431 = turn + rnormal(0, 0.9)
replace t3v0431 = t3v0431 + group_id/4
gen t3v0432 = displacement + rnormal(0, 0.1)
replace t3v0432 = t3v0432 + group_id/5
gen t3v0433 = gear_ratio + rnormal(0, 0.2)
replace t3v0433 = t3v0433 + group_id/6
gen t3v0434 = price + rnormal(0, 0.3)
replace t3v0434 = t3v0434 + group_id/7
gen t3v0435 = mpg + rnormal(0, 0.4)
replace t3v0435 = t3v0435 + group_id/8
label variable t3v0435 "Generated stress variable 0435"
gen t3v0436 = weight + rnormal(0, 0.5)
replace t3v0436 = t3v0436 + group_id/9
gen t3v0437 = length + rnormal(0, 0.6)
replace t3v0437 = t3v0437 + group_id/10
gen t3v0438 = turn + rnormal(0, 0.7)
replace t3v0438 = t3v0438 + group_id/11
gen t3v0439 = displacement + rnormal(0, 0.8)
replace t3v0439 = t3v0439 + group_id/12
gen t3v0440 = gear_ratio + rnormal(0, 0.9)
replace t3v0440 = t3v0440 + group_id/2
label variable t3v0440 "Generated stress variable 0440"
quietly summarize t3v0440
display as text "[VAR] t3v0440 mean=" %9.4f r(mean)
gen t3v0441 = price + rnormal(0, 0.1)
replace t3v0441 = t3v0441 + group_id/3
gen t3v0442 = mpg + rnormal(0, 0.2)
replace t3v0442 = t3v0442 + group_id/4
gen t3v0443 = weight + rnormal(0, 0.3)
replace t3v0443 = t3v0443 + group_id/5
gen t3v0444 = length + rnormal(0, 0.4)
replace t3v0444 = t3v0444 + group_id/6
gen t3v0445 = turn + rnormal(0, 0.5)
replace t3v0445 = t3v0445 + group_id/7
label variable t3v0445 "Generated stress variable 0445"
gen t3v0446 = displacement + rnormal(0, 0.6)
replace t3v0446 = t3v0446 + group_id/8
gen t3v0447 = gear_ratio + rnormal(0, 0.7)
replace t3v0447 = t3v0447 + group_id/9
gen t3v0448 = price + rnormal(0, 0.8)
replace t3v0448 = t3v0448 + group_id/10
gen t3v0449 = mpg + rnormal(0, 0.9)
replace t3v0449 = t3v0449 + group_id/11
gen t3v0450 = weight + rnormal(0, 0.1)
replace t3v0450 = t3v0450 + group_id/12
label variable t3v0450 "Generated stress variable 0450"
gen t3v0451 = length + rnormal(0, 0.2)
replace t3v0451 = t3v0451 + group_id/2
gen t3v0452 = turn + rnormal(0, 0.3)
replace t3v0452 = t3v0452 + group_id/3
gen t3v0453 = displacement + rnormal(0, 0.4)
replace t3v0453 = t3v0453 + group_id/4
gen t3v0454 = gear_ratio + rnormal(0, 0.5)
replace t3v0454 = t3v0454 + group_id/5
gen t3v0455 = price + rnormal(0, 0.6)
replace t3v0455 = t3v0455 + group_id/6
label variable t3v0455 "Generated stress variable 0455"
gen t3v0456 = mpg + rnormal(0, 0.7)
replace t3v0456 = t3v0456 + group_id/7
gen t3v0457 = weight + rnormal(0, 0.8)
replace t3v0457 = t3v0457 + group_id/8
gen t3v0458 = length + rnormal(0, 0.9)
replace t3v0458 = t3v0458 + group_id/9
gen t3v0459 = turn + rnormal(0, 0.1)
replace t3v0459 = t3v0459 + group_id/10
gen t3v0460 = displacement + rnormal(0, 0.2)
replace t3v0460 = t3v0460 + group_id/11
label variable t3v0460 "Generated stress variable 0460"
quietly summarize t3v0460
display as text "[VAR] t3v0460 mean=" %9.4f r(mean)
gen t3v0461 = gear_ratio + rnormal(0, 0.3)
replace t3v0461 = t3v0461 + group_id/12
gen t3v0462 = price + rnormal(0, 0.4)
replace t3v0462 = t3v0462 + group_id/2
gen t3v0463 = mpg + rnormal(0, 0.5)
replace t3v0463 = t3v0463 + group_id/3
gen t3v0464 = weight + rnormal(0, 0.6)
replace t3v0464 = t3v0464 + group_id/4
gen t3v0465 = length + rnormal(0, 0.7)
replace t3v0465 = t3v0465 + group_id/5
label variable t3v0465 "Generated stress variable 0465"
gen t3v0466 = turn + rnormal(0, 0.8)
replace t3v0466 = t3v0466 + group_id/6
gen t3v0467 = displacement + rnormal(0, 0.9)
replace t3v0467 = t3v0467 + group_id/7
gen t3v0468 = gear_ratio + rnormal(0, 0.1)
replace t3v0468 = t3v0468 + group_id/8
gen t3v0469 = price + rnormal(0, 0.2)
replace t3v0469 = t3v0469 + group_id/9
gen t3v0470 = mpg + rnormal(0, 0.3)
replace t3v0470 = t3v0470 + group_id/10
label variable t3v0470 "Generated stress variable 0470"
gen t3v0471 = weight + rnormal(0, 0.4)
replace t3v0471 = t3v0471 + group_id/11
gen t3v0472 = length + rnormal(0, 0.5)
replace t3v0472 = t3v0472 + group_id/12
gen t3v0473 = turn + rnormal(0, 0.6)
replace t3v0473 = t3v0473 + group_id/2
gen t3v0474 = displacement + rnormal(0, 0.7)
replace t3v0474 = t3v0474 + group_id/3
gen t3v0475 = gear_ratio + rnormal(0, 0.8)
replace t3v0475 = t3v0475 + group_id/4
label variable t3v0475 "Generated stress variable 0475"
gen t3v0476 = price + rnormal(0, 0.9)
replace t3v0476 = t3v0476 + group_id/5
gen t3v0477 = mpg + rnormal(0, 0.1)
replace t3v0477 = t3v0477 + group_id/6
gen t3v0478 = weight + rnormal(0, 0.2)
replace t3v0478 = t3v0478 + group_id/7
gen t3v0479 = length + rnormal(0, 0.3)
replace t3v0479 = t3v0479 + group_id/8
gen t3v0480 = turn + rnormal(0, 0.4)
replace t3v0480 = t3v0480 + group_id/9
label variable t3v0480 "Generated stress variable 0480"
quietly summarize t3v0480
display as text "[VAR] t3v0480 mean=" %9.4f r(mean)
gen t3v0481 = displacement + rnormal(0, 0.5)
replace t3v0481 = t3v0481 + group_id/10
gen t3v0482 = gear_ratio + rnormal(0, 0.6)
replace t3v0482 = t3v0482 + group_id/11
gen t3v0483 = price + rnormal(0, 0.7)
replace t3v0483 = t3v0483 + group_id/12
gen t3v0484 = mpg + rnormal(0, 0.8)
replace t3v0484 = t3v0484 + group_id/2
gen t3v0485 = weight + rnormal(0, 0.9)
replace t3v0485 = t3v0485 + group_id/3
label variable t3v0485 "Generated stress variable 0485"
gen t3v0486 = length + rnormal(0, 0.1)
replace t3v0486 = t3v0486 + group_id/4
gen t3v0487 = turn + rnormal(0, 0.2)
replace t3v0487 = t3v0487 + group_id/5
gen t3v0488 = displacement + rnormal(0, 0.3)
replace t3v0488 = t3v0488 + group_id/6
gen t3v0489 = gear_ratio + rnormal(0, 0.4)
replace t3v0489 = t3v0489 + group_id/7
gen t3v0490 = price + rnormal(0, 0.5)
replace t3v0490 = t3v0490 + group_id/8
label variable t3v0490 "Generated stress variable 0490"
gen t3v0491 = mpg + rnormal(0, 0.6)
replace t3v0491 = t3v0491 + group_id/9
gen t3v0492 = weight + rnormal(0, 0.7)
replace t3v0492 = t3v0492 + group_id/10
gen t3v0493 = length + rnormal(0, 0.8)
replace t3v0493 = t3v0493 + group_id/11
gen t3v0494 = turn + rnormal(0, 0.9)
replace t3v0494 = t3v0494 + group_id/12
gen t3v0495 = displacement + rnormal(0, 0.1)
replace t3v0495 = t3v0495 + group_id/2
label variable t3v0495 "Generated stress variable 0495"
gen t3v0496 = gear_ratio + rnormal(0, 0.2)
replace t3v0496 = t3v0496 + group_id/3
gen t3v0497 = price + rnormal(0, 0.3)
replace t3v0497 = t3v0497 + group_id/4
gen t3v0498 = mpg + rnormal(0, 0.4)
replace t3v0498 = t3v0498 + group_id/5
gen t3v0499 = weight + rnormal(0, 0.5)
replace t3v0499 = t3v0499 + group_id/6
gen t3v0500 = length + rnormal(0, 0.6)
replace t3v0500 = t3v0500 + group_id/7
label variable t3v0500 "Generated stress variable 0500"
quietly summarize t3v0500
display as text "[VAR] t3v0500 mean=" %9.4f r(mean)
gen t3v0501 = turn + rnormal(0, 0.7)
replace t3v0501 = t3v0501 + group_id/8
gen t3v0502 = displacement + rnormal(0, 0.8)
replace t3v0502 = t3v0502 + group_id/9
gen t3v0503 = gear_ratio + rnormal(0, 0.9)
replace t3v0503 = t3v0503 + group_id/10
gen t3v0504 = price + rnormal(0, 0.1)
replace t3v0504 = t3v0504 + group_id/11
gen t3v0505 = mpg + rnormal(0, 0.2)
replace t3v0505 = t3v0505 + group_id/12
label variable t3v0505 "Generated stress variable 0505"
gen t3v0506 = weight + rnormal(0, 0.3)
replace t3v0506 = t3v0506 + group_id/2
gen t3v0507 = length + rnormal(0, 0.4)
replace t3v0507 = t3v0507 + group_id/3
gen t3v0508 = turn + rnormal(0, 0.5)
replace t3v0508 = t3v0508 + group_id/4
gen t3v0509 = displacement + rnormal(0, 0.6)
replace t3v0509 = t3v0509 + group_id/5
gen t3v0510 = gear_ratio + rnormal(0, 0.7)
replace t3v0510 = t3v0510 + group_id/6
label variable t3v0510 "Generated stress variable 0510"
gen t3v0511 = price + rnormal(0, 0.8)
replace t3v0511 = t3v0511 + group_id/7
gen t3v0512 = mpg + rnormal(0, 0.9)
replace t3v0512 = t3v0512 + group_id/8
gen t3v0513 = weight + rnormal(0, 0.1)
replace t3v0513 = t3v0513 + group_id/9
gen t3v0514 = length + rnormal(0, 0.2)
replace t3v0514 = t3v0514 + group_id/10
gen t3v0515 = turn + rnormal(0, 0.3)
replace t3v0515 = t3v0515 + group_id/11
label variable t3v0515 "Generated stress variable 0515"
gen t3v0516 = displacement + rnormal(0, 0.4)
replace t3v0516 = t3v0516 + group_id/12
gen t3v0517 = gear_ratio + rnormal(0, 0.5)
replace t3v0517 = t3v0517 + group_id/2
gen t3v0518 = price + rnormal(0, 0.6)
replace t3v0518 = t3v0518 + group_id/3
gen t3v0519 = mpg + rnormal(0, 0.7)
replace t3v0519 = t3v0519 + group_id/4
gen t3v0520 = weight + rnormal(0, 0.8)
replace t3v0520 = t3v0520 + group_id/5
label variable t3v0520 "Generated stress variable 0520"
quietly summarize t3v0520
display as text "[VAR] t3v0520 mean=" %9.4f r(mean)
gen t3v0521 = length + rnormal(0, 0.9)
replace t3v0521 = t3v0521 + group_id/6
gen t3v0522 = turn + rnormal(0, 0.1)
replace t3v0522 = t3v0522 + group_id/7
gen t3v0523 = displacement + rnormal(0, 0.2)
replace t3v0523 = t3v0523 + group_id/8
gen t3v0524 = gear_ratio + rnormal(0, 0.3)
replace t3v0524 = t3v0524 + group_id/9
gen t3v0525 = price + rnormal(0, 0.4)
replace t3v0525 = t3v0525 + group_id/10
label variable t3v0525 "Generated stress variable 0525"
gen t3v0526 = mpg + rnormal(0, 0.5)
replace t3v0526 = t3v0526 + group_id/11
gen t3v0527 = weight + rnormal(0, 0.6)
replace t3v0527 = t3v0527 + group_id/12
gen t3v0528 = length + rnormal(0, 0.7)
replace t3v0528 = t3v0528 + group_id/2
gen t3v0529 = turn + rnormal(0, 0.8)
replace t3v0529 = t3v0529 + group_id/3
gen t3v0530 = displacement + rnormal(0, 0.9)
replace t3v0530 = t3v0530 + group_id/4
label variable t3v0530 "Generated stress variable 0530"
gen t3v0531 = gear_ratio + rnormal(0, 0.1)
replace t3v0531 = t3v0531 + group_id/5
gen t3v0532 = price + rnormal(0, 0.2)
replace t3v0532 = t3v0532 + group_id/6
gen t3v0533 = mpg + rnormal(0, 0.3)
replace t3v0533 = t3v0533 + group_id/7
gen t3v0534 = weight + rnormal(0, 0.4)
replace t3v0534 = t3v0534 + group_id/8
gen t3v0535 = length + rnormal(0, 0.5)
replace t3v0535 = t3v0535 + group_id/9
label variable t3v0535 "Generated stress variable 0535"
gen t3v0536 = turn + rnormal(0, 0.6)
replace t3v0536 = t3v0536 + group_id/10
gen t3v0537 = displacement + rnormal(0, 0.7)
replace t3v0537 = t3v0537 + group_id/11
gen t3v0538 = gear_ratio + rnormal(0, 0.8)
replace t3v0538 = t3v0538 + group_id/12
gen t3v0539 = price + rnormal(0, 0.9)
replace t3v0539 = t3v0539 + group_id/2
gen t3v0540 = mpg + rnormal(0, 0.1)
replace t3v0540 = t3v0540 + group_id/3
label variable t3v0540 "Generated stress variable 0540"
quietly summarize t3v0540
display as text "[VAR] t3v0540 mean=" %9.4f r(mean)
gen t3v0541 = weight + rnormal(0, 0.2)
replace t3v0541 = t3v0541 + group_id/4
gen t3v0542 = length + rnormal(0, 0.3)
replace t3v0542 = t3v0542 + group_id/5
gen t3v0543 = turn + rnormal(0, 0.4)
replace t3v0543 = t3v0543 + group_id/6
gen t3v0544 = displacement + rnormal(0, 0.5)
replace t3v0544 = t3v0544 + group_id/7
gen t3v0545 = gear_ratio + rnormal(0, 0.6)
replace t3v0545 = t3v0545 + group_id/8
label variable t3v0545 "Generated stress variable 0545"
gen t3v0546 = price + rnormal(0, 0.7)
replace t3v0546 = t3v0546 + group_id/9
gen t3v0547 = mpg + rnormal(0, 0.8)
replace t3v0547 = t3v0547 + group_id/10
gen t3v0548 = weight + rnormal(0, 0.9)
replace t3v0548 = t3v0548 + group_id/11
gen t3v0549 = length + rnormal(0, 0.1)
replace t3v0549 = t3v0549 + group_id/12
gen t3v0550 = turn + rnormal(0, 0.2)
replace t3v0550 = t3v0550 + group_id/2
label variable t3v0550 "Generated stress variable 0550"
gen t3v0551 = displacement + rnormal(0, 0.3)
replace t3v0551 = t3v0551 + group_id/3
gen t3v0552 = gear_ratio + rnormal(0, 0.4)
replace t3v0552 = t3v0552 + group_id/4
gen t3v0553 = price + rnormal(0, 0.5)
replace t3v0553 = t3v0553 + group_id/5
gen t3v0554 = mpg + rnormal(0, 0.6)
replace t3v0554 = t3v0554 + group_id/6
gen t3v0555 = weight + rnormal(0, 0.7)
replace t3v0555 = t3v0555 + group_id/7
label variable t3v0555 "Generated stress variable 0555"
gen t3v0556 = length + rnormal(0, 0.8)
replace t3v0556 = t3v0556 + group_id/8
gen t3v0557 = turn + rnormal(0, 0.9)
replace t3v0557 = t3v0557 + group_id/9
gen t3v0558 = displacement + rnormal(0, 0.1)
replace t3v0558 = t3v0558 + group_id/10
gen t3v0559 = gear_ratio + rnormal(0, 0.2)
replace t3v0559 = t3v0559 + group_id/11
gen t3v0560 = price + rnormal(0, 0.3)
replace t3v0560 = t3v0560 + group_id/12
label variable t3v0560 "Generated stress variable 0560"
quietly summarize t3v0560
display as text "[VAR] t3v0560 mean=" %9.4f r(mean)
gen t3v0561 = mpg + rnormal(0, 0.4)
replace t3v0561 = t3v0561 + group_id/2
gen t3v0562 = weight + rnormal(0, 0.5)
replace t3v0562 = t3v0562 + group_id/3
gen t3v0563 = length + rnormal(0, 0.6)
replace t3v0563 = t3v0563 + group_id/4
gen t3v0564 = turn + rnormal(0, 0.7)
replace t3v0564 = t3v0564 + group_id/5
gen t3v0565 = displacement + rnormal(0, 0.8)
replace t3v0565 = t3v0565 + group_id/6
label variable t3v0565 "Generated stress variable 0565"
gen t3v0566 = gear_ratio + rnormal(0, 0.9)
replace t3v0566 = t3v0566 + group_id/7
gen t3v0567 = price + rnormal(0, 0.1)
replace t3v0567 = t3v0567 + group_id/8
gen t3v0568 = mpg + rnormal(0, 0.2)
replace t3v0568 = t3v0568 + group_id/9
gen t3v0569 = weight + rnormal(0, 0.3)
replace t3v0569 = t3v0569 + group_id/10
gen t3v0570 = length + rnormal(0, 0.4)
replace t3v0570 = t3v0570 + group_id/11
label variable t3v0570 "Generated stress variable 0570"
gen t3v0571 = turn + rnormal(0, 0.5)
replace t3v0571 = t3v0571 + group_id/12
gen t3v0572 = displacement + rnormal(0, 0.6)
replace t3v0572 = t3v0572 + group_id/2
gen t3v0573 = gear_ratio + rnormal(0, 0.7)
replace t3v0573 = t3v0573 + group_id/3
gen t3v0574 = price + rnormal(0, 0.8)
replace t3v0574 = t3v0574 + group_id/4
gen t3v0575 = mpg + rnormal(0, 0.9)
replace t3v0575 = t3v0575 + group_id/5
label variable t3v0575 "Generated stress variable 0575"
gen t3v0576 = weight + rnormal(0, 0.1)
replace t3v0576 = t3v0576 + group_id/6
gen t3v0577 = length + rnormal(0, 0.2)
replace t3v0577 = t3v0577 + group_id/7
gen t3v0578 = turn + rnormal(0, 0.3)
replace t3v0578 = t3v0578 + group_id/8
gen t3v0579 = displacement + rnormal(0, 0.4)
replace t3v0579 = t3v0579 + group_id/9
gen t3v0580 = gear_ratio + rnormal(0, 0.5)
replace t3v0580 = t3v0580 + group_id/10
label variable t3v0580 "Generated stress variable 0580"
quietly summarize t3v0580
display as text "[VAR] t3v0580 mean=" %9.4f r(mean)
gen t3v0581 = price + rnormal(0, 0.6)
replace t3v0581 = t3v0581 + group_id/11
gen t3v0582 = mpg + rnormal(0, 0.7)
replace t3v0582 = t3v0582 + group_id/12
gen t3v0583 = weight + rnormal(0, 0.8)
replace t3v0583 = t3v0583 + group_id/2
gen t3v0584 = length + rnormal(0, 0.9)
replace t3v0584 = t3v0584 + group_id/3
gen t3v0585 = turn + rnormal(0, 0.1)
replace t3v0585 = t3v0585 + group_id/4
label variable t3v0585 "Generated stress variable 0585"
gen t3v0586 = displacement + rnormal(0, 0.2)
replace t3v0586 = t3v0586 + group_id/5
gen t3v0587 = gear_ratio + rnormal(0, 0.3)
replace t3v0587 = t3v0587 + group_id/6
gen t3v0588 = price + rnormal(0, 0.4)
replace t3v0588 = t3v0588 + group_id/7
gen t3v0589 = mpg + rnormal(0, 0.5)
replace t3v0589 = t3v0589 + group_id/8
gen t3v0590 = weight + rnormal(0, 0.6)
replace t3v0590 = t3v0590 + group_id/9
label variable t3v0590 "Generated stress variable 0590"
gen t3v0591 = length + rnormal(0, 0.7)
replace t3v0591 = t3v0591 + group_id/10
gen t3v0592 = turn + rnormal(0, 0.8)
replace t3v0592 = t3v0592 + group_id/11
gen t3v0593 = displacement + rnormal(0, 0.9)
replace t3v0593 = t3v0593 + group_id/12
gen t3v0594 = gear_ratio + rnormal(0, 0.1)
replace t3v0594 = t3v0594 + group_id/2
gen t3v0595 = price + rnormal(0, 0.2)
replace t3v0595 = t3v0595 + group_id/3
label variable t3v0595 "Generated stress variable 0595"
gen t3v0596 = mpg + rnormal(0, 0.3)
replace t3v0596 = t3v0596 + group_id/4
gen t3v0597 = weight + rnormal(0, 0.4)
replace t3v0597 = t3v0597 + group_id/5
gen t3v0598 = length + rnormal(0, 0.5)
replace t3v0598 = t3v0598 + group_id/6
gen t3v0599 = turn + rnormal(0, 0.6)
replace t3v0599 = t3v0599 + group_id/7
gen t3v0600 = displacement + rnormal(0, 0.7)
replace t3v0600 = t3v0600 + group_id/8
label variable t3v0600 "Generated stress variable 0600"
quietly summarize t3v0600
display as text "[VAR] t3v0600 mean=" %9.4f r(mean)
gen t3v0601 = gear_ratio + rnormal(0, 0.8)
replace t3v0601 = t3v0601 + group_id/9
gen t3v0602 = price + rnormal(0, 0.9)
replace t3v0602 = t3v0602 + group_id/10
gen t3v0603 = mpg + rnormal(0, 0.1)
replace t3v0603 = t3v0603 + group_id/11
gen t3v0604 = weight + rnormal(0, 0.2)
replace t3v0604 = t3v0604 + group_id/12
gen t3v0605 = length + rnormal(0, 0.3)
replace t3v0605 = t3v0605 + group_id/2
label variable t3v0605 "Generated stress variable 0605"
gen t3v0606 = turn + rnormal(0, 0.4)
replace t3v0606 = t3v0606 + group_id/3
gen t3v0607 = displacement + rnormal(0, 0.5)
replace t3v0607 = t3v0607 + group_id/4
gen t3v0608 = gear_ratio + rnormal(0, 0.6)
replace t3v0608 = t3v0608 + group_id/5
gen t3v0609 = price + rnormal(0, 0.7)
replace t3v0609 = t3v0609 + group_id/6
gen t3v0610 = mpg + rnormal(0, 0.8)
replace t3v0610 = t3v0610 + group_id/7
label variable t3v0610 "Generated stress variable 0610"
gen t3v0611 = weight + rnormal(0, 0.9)
replace t3v0611 = t3v0611 + group_id/8
gen t3v0612 = length + rnormal(0, 0.1)
replace t3v0612 = t3v0612 + group_id/9
gen t3v0613 = turn + rnormal(0, 0.2)
replace t3v0613 = t3v0613 + group_id/10
gen t3v0614 = displacement + rnormal(0, 0.3)
replace t3v0614 = t3v0614 + group_id/11
gen t3v0615 = gear_ratio + rnormal(0, 0.4)
replace t3v0615 = t3v0615 + group_id/12
label variable t3v0615 "Generated stress variable 0615"
gen t3v0616 = price + rnormal(0, 0.5)
replace t3v0616 = t3v0616 + group_id/2
gen t3v0617 = mpg + rnormal(0, 0.6)
replace t3v0617 = t3v0617 + group_id/3
gen t3v0618 = weight + rnormal(0, 0.7)
replace t3v0618 = t3v0618 + group_id/4
gen t3v0619 = length + rnormal(0, 0.8)
replace t3v0619 = t3v0619 + group_id/5
gen t3v0620 = turn + rnormal(0, 0.9)
replace t3v0620 = t3v0620 + group_id/6
label variable t3v0620 "Generated stress variable 0620"
quietly summarize t3v0620
display as text "[VAR] t3v0620 mean=" %9.4f r(mean)
gen t3v0621 = displacement + rnormal(0, 0.1)
replace t3v0621 = t3v0621 + group_id/7
gen t3v0622 = gear_ratio + rnormal(0, 0.2)
replace t3v0622 = t3v0622 + group_id/8
gen t3v0623 = price + rnormal(0, 0.3)
replace t3v0623 = t3v0623 + group_id/9
gen t3v0624 = mpg + rnormal(0, 0.4)
replace t3v0624 = t3v0624 + group_id/10
gen t3v0625 = weight + rnormal(0, 0.5)
replace t3v0625 = t3v0625 + group_id/11
label variable t3v0625 "Generated stress variable 0625"
gen t3v0626 = length + rnormal(0, 0.6)
replace t3v0626 = t3v0626 + group_id/12
gen t3v0627 = turn + rnormal(0, 0.7)
replace t3v0627 = t3v0627 + group_id/2
gen t3v0628 = displacement + rnormal(0, 0.8)
replace t3v0628 = t3v0628 + group_id/3
gen t3v0629 = gear_ratio + rnormal(0, 0.9)
replace t3v0629 = t3v0629 + group_id/4
gen t3v0630 = price + rnormal(0, 0.1)
replace t3v0630 = t3v0630 + group_id/5
label variable t3v0630 "Generated stress variable 0630"
gen t3v0631 = mpg + rnormal(0, 0.2)
replace t3v0631 = t3v0631 + group_id/6
gen t3v0632 = weight + rnormal(0, 0.3)
replace t3v0632 = t3v0632 + group_id/7
gen t3v0633 = length + rnormal(0, 0.4)
replace t3v0633 = t3v0633 + group_id/8
gen t3v0634 = turn + rnormal(0, 0.5)
replace t3v0634 = t3v0634 + group_id/9
gen t3v0635 = displacement + rnormal(0, 0.6)
replace t3v0635 = t3v0635 + group_id/10
label variable t3v0635 "Generated stress variable 0635"
gen t3v0636 = gear_ratio + rnormal(0, 0.7)
replace t3v0636 = t3v0636 + group_id/11
gen t3v0637 = price + rnormal(0, 0.8)
replace t3v0637 = t3v0637 + group_id/12
gen t3v0638 = mpg + rnormal(0, 0.9)
replace t3v0638 = t3v0638 + group_id/2
gen t3v0639 = weight + rnormal(0, 0.1)
replace t3v0639 = t3v0639 + group_id/3
gen t3v0640 = length + rnormal(0, 0.2)
replace t3v0640 = t3v0640 + group_id/4
label variable t3v0640 "Generated stress variable 0640"
quietly summarize t3v0640
display as text "[VAR] t3v0640 mean=" %9.4f r(mean)
gen t3v0641 = turn + rnormal(0, 0.3)
replace t3v0641 = t3v0641 + group_id/5
gen t3v0642 = displacement + rnormal(0, 0.4)
replace t3v0642 = t3v0642 + group_id/6
gen t3v0643 = gear_ratio + rnormal(0, 0.5)
replace t3v0643 = t3v0643 + group_id/7
gen t3v0644 = price + rnormal(0, 0.6)
replace t3v0644 = t3v0644 + group_id/8
gen t3v0645 = mpg + rnormal(0, 0.7)
replace t3v0645 = t3v0645 + group_id/9
label variable t3v0645 "Generated stress variable 0645"
gen t3v0646 = weight + rnormal(0, 0.8)
replace t3v0646 = t3v0646 + group_id/10
gen t3v0647 = length + rnormal(0, 0.9)
replace t3v0647 = t3v0647 + group_id/11
gen t3v0648 = turn + rnormal(0, 0.1)
replace t3v0648 = t3v0648 + group_id/12
gen t3v0649 = displacement + rnormal(0, 0.2)
replace t3v0649 = t3v0649 + group_id/2
gen t3v0650 = gear_ratio + rnormal(0, 0.3)
replace t3v0650 = t3v0650 + group_id/3
label variable t3v0650 "Generated stress variable 0650"
gen t3v0651 = price + rnormal(0, 0.4)
replace t3v0651 = t3v0651 + group_id/4
gen t3v0652 = mpg + rnormal(0, 0.5)
replace t3v0652 = t3v0652 + group_id/5
gen t3v0653 = weight + rnormal(0, 0.6)
replace t3v0653 = t3v0653 + group_id/6
gen t3v0654 = length + rnormal(0, 0.7)
replace t3v0654 = t3v0654 + group_id/7
gen t3v0655 = turn + rnormal(0, 0.8)
replace t3v0655 = t3v0655 + group_id/8
label variable t3v0655 "Generated stress variable 0655"
gen t3v0656 = displacement + rnormal(0, 0.9)
replace t3v0656 = t3v0656 + group_id/9
gen t3v0657 = gear_ratio + rnormal(0, 0.1)
replace t3v0657 = t3v0657 + group_id/10
gen t3v0658 = price + rnormal(0, 0.2)
replace t3v0658 = t3v0658 + group_id/11
gen t3v0659 = mpg + rnormal(0, 0.3)
replace t3v0659 = t3v0659 + group_id/12
gen t3v0660 = weight + rnormal(0, 0.4)
replace t3v0660 = t3v0660 + group_id/2
label variable t3v0660 "Generated stress variable 0660"
quietly summarize t3v0660
display as text "[VAR] t3v0660 mean=" %9.4f r(mean)
gen t3v0661 = length + rnormal(0, 0.5)
replace t3v0661 = t3v0661 + group_id/3
gen t3v0662 = turn + rnormal(0, 0.6)
replace t3v0662 = t3v0662 + group_id/4
gen t3v0663 = displacement + rnormal(0, 0.7)
replace t3v0663 = t3v0663 + group_id/5
gen t3v0664 = gear_ratio + rnormal(0, 0.8)
replace t3v0664 = t3v0664 + group_id/6
gen t3v0665 = price + rnormal(0, 0.9)
replace t3v0665 = t3v0665 + group_id/7
label variable t3v0665 "Generated stress variable 0665"
gen t3v0666 = mpg + rnormal(0, 0.1)
replace t3v0666 = t3v0666 + group_id/8
gen t3v0667 = weight + rnormal(0, 0.2)
replace t3v0667 = t3v0667 + group_id/9
gen t3v0668 = length + rnormal(0, 0.3)
replace t3v0668 = t3v0668 + group_id/10
gen t3v0669 = turn + rnormal(0, 0.4)
replace t3v0669 = t3v0669 + group_id/11
gen t3v0670 = displacement + rnormal(0, 0.5)
replace t3v0670 = t3v0670 + group_id/12
label variable t3v0670 "Generated stress variable 0670"
gen t3v0671 = gear_ratio + rnormal(0, 0.6)
replace t3v0671 = t3v0671 + group_id/2
gen t3v0672 = price + rnormal(0, 0.7)
replace t3v0672 = t3v0672 + group_id/3
gen t3v0673 = mpg + rnormal(0, 0.8)
replace t3v0673 = t3v0673 + group_id/4
gen t3v0674 = weight + rnormal(0, 0.9)
replace t3v0674 = t3v0674 + group_id/5
gen t3v0675 = length + rnormal(0, 0.1)
replace t3v0675 = t3v0675 + group_id/6
label variable t3v0675 "Generated stress variable 0675"
gen t3v0676 = turn + rnormal(0, 0.2)
replace t3v0676 = t3v0676 + group_id/7
gen t3v0677 = displacement + rnormal(0, 0.3)
replace t3v0677 = t3v0677 + group_id/8
gen t3v0678 = gear_ratio + rnormal(0, 0.4)
replace t3v0678 = t3v0678 + group_id/9
gen t3v0679 = price + rnormal(0, 0.5)
replace t3v0679 = t3v0679 + group_id/10
gen t3v0680 = mpg + rnormal(0, 0.6)
replace t3v0680 = t3v0680 + group_id/11
label variable t3v0680 "Generated stress variable 0680"
quietly summarize t3v0680
display as text "[VAR] t3v0680 mean=" %9.4f r(mean)
gen t3v0681 = weight + rnormal(0, 0.7)
replace t3v0681 = t3v0681 + group_id/12
gen t3v0682 = length + rnormal(0, 0.8)
replace t3v0682 = t3v0682 + group_id/2
gen t3v0683 = turn + rnormal(0, 0.9)
replace t3v0683 = t3v0683 + group_id/3
gen t3v0684 = displacement + rnormal(0, 0.1)
replace t3v0684 = t3v0684 + group_id/4
gen t3v0685 = gear_ratio + rnormal(0, 0.2)
replace t3v0685 = t3v0685 + group_id/5
label variable t3v0685 "Generated stress variable 0685"
gen t3v0686 = price + rnormal(0, 0.3)
replace t3v0686 = t3v0686 + group_id/6
gen t3v0687 = mpg + rnormal(0, 0.4)
replace t3v0687 = t3v0687 + group_id/7
gen t3v0688 = weight + rnormal(0, 0.5)
replace t3v0688 = t3v0688 + group_id/8
gen t3v0689 = length + rnormal(0, 0.6)
replace t3v0689 = t3v0689 + group_id/9
gen t3v0690 = turn + rnormal(0, 0.7)
replace t3v0690 = t3v0690 + group_id/10
label variable t3v0690 "Generated stress variable 0690"
gen t3v0691 = displacement + rnormal(0, 0.8)
replace t3v0691 = t3v0691 + group_id/11
gen t3v0692 = gear_ratio + rnormal(0, 0.9)
replace t3v0692 = t3v0692 + group_id/12
gen t3v0693 = price + rnormal(0, 0.1)
replace t3v0693 = t3v0693 + group_id/2
gen t3v0694 = mpg + rnormal(0, 0.2)
replace t3v0694 = t3v0694 + group_id/3
gen t3v0695 = weight + rnormal(0, 0.3)
replace t3v0695 = t3v0695 + group_id/4
label variable t3v0695 "Generated stress variable 0695"
gen t3v0696 = length + rnormal(0, 0.4)
replace t3v0696 = t3v0696 + group_id/5
gen t3v0697 = turn + rnormal(0, 0.5)
replace t3v0697 = t3v0697 + group_id/6
gen t3v0698 = displacement + rnormal(0, 0.6)
replace t3v0698 = t3v0698 + group_id/7
gen t3v0699 = gear_ratio + rnormal(0, 0.7)
replace t3v0699 = t3v0699 + group_id/8
gen t3v0700 = price + rnormal(0, 0.8)
replace t3v0700 = t3v0700 + group_id/9
label variable t3v0700 "Generated stress variable 0700"
quietly summarize t3v0700
display as text "[VAR] t3v0700 mean=" %9.4f r(mean)
gen t3v0701 = mpg + rnormal(0, 0.9)
replace t3v0701 = t3v0701 + group_id/10
gen t3v0702 = weight + rnormal(0, 0.1)
replace t3v0702 = t3v0702 + group_id/11
gen t3v0703 = length + rnormal(0, 0.2)
replace t3v0703 = t3v0703 + group_id/12
gen t3v0704 = turn + rnormal(0, 0.3)
replace t3v0704 = t3v0704 + group_id/2
gen t3v0705 = displacement + rnormal(0, 0.4)
replace t3v0705 = t3v0705 + group_id/3
label variable t3v0705 "Generated stress variable 0705"
gen t3v0706 = gear_ratio + rnormal(0, 0.5)
replace t3v0706 = t3v0706 + group_id/4
gen t3v0707 = price + rnormal(0, 0.6)
replace t3v0707 = t3v0707 + group_id/5
gen t3v0708 = mpg + rnormal(0, 0.7)
replace t3v0708 = t3v0708 + group_id/6
gen t3v0709 = weight + rnormal(0, 0.8)
replace t3v0709 = t3v0709 + group_id/7
gen t3v0710 = length + rnormal(0, 0.9)
replace t3v0710 = t3v0710 + group_id/8
label variable t3v0710 "Generated stress variable 0710"
gen t3v0711 = turn + rnormal(0, 0.1)
replace t3v0711 = t3v0711 + group_id/9
gen t3v0712 = displacement + rnormal(0, 0.2)
replace t3v0712 = t3v0712 + group_id/10
gen t3v0713 = gear_ratio + rnormal(0, 0.3)
replace t3v0713 = t3v0713 + group_id/11
gen t3v0714 = price + rnormal(0, 0.4)
replace t3v0714 = t3v0714 + group_id/12
gen t3v0715 = mpg + rnormal(0, 0.5)
replace t3v0715 = t3v0715 + group_id/2
label variable t3v0715 "Generated stress variable 0715"
gen t3v0716 = weight + rnormal(0, 0.6)
replace t3v0716 = t3v0716 + group_id/3
gen t3v0717 = length + rnormal(0, 0.7)
replace t3v0717 = t3v0717 + group_id/4
gen t3v0718 = turn + rnormal(0, 0.8)
replace t3v0718 = t3v0718 + group_id/5
gen t3v0719 = displacement + rnormal(0, 0.9)
replace t3v0719 = t3v0719 + group_id/6
gen t3v0720 = gear_ratio + rnormal(0, 0.1)
replace t3v0720 = t3v0720 + group_id/7
label variable t3v0720 "Generated stress variable 0720"
quietly summarize t3v0720
display as text "[VAR] t3v0720 mean=" %9.4f r(mean)
display as result "<<< DONE Section 2: generated variables marathon"
// #endregion ===== Section 2: generated variables marathon =====


// #region ===== Section 3: unnamed transient graph gauntlet =====
display as text ">>> START Section 3: unnamed transient graph gauntlet"
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T3 hist Graph 001: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t3 graph stress 001")
display as text "[GRAPH-UNNAMED] t3 unnamed graph 001 produced"
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T3 bar Graph 002: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t3 graph stress 002")
display as text "[GRAPH-UNNAMED] t3 unnamed graph 002 produced"
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T3 line Graph 003: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t3 graph stress 003")
display as text "[GRAPH-UNNAMED] t3 unnamed graph 003 produced"
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T3 qfit Graph 004: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t3 graph stress 004")
display as text "[GRAPH-UNNAMED] t3 unnamed graph 004 produced"
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T3 scatter Graph 005: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t3 graph stress 005")
display as text "[GRAPH-UNNAMED] t3 unnamed graph 005 produced"
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T3 hist Graph 006: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t3 graph stress 006")
display as text "[GRAPH-UNNAMED] t3 unnamed graph 006 produced"
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T3 bar Graph 007: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t3 graph stress 007")
display as text "[GRAPH-UNNAMED] t3 unnamed graph 007 produced"
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T3 line Graph 008: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t3 graph stress 008")
display as text "[GRAPH-UNNAMED] t3 unnamed graph 008 produced"
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T3 qfit Graph 009: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t3 graph stress 009")
display as text "[GRAPH-UNNAMED] t3 unnamed graph 009 produced"
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T3 scatter Graph 010: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t3 graph stress 010")
display as text "[GRAPH-UNNAMED] t3 unnamed graph 010 produced"
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T3 hist Graph 011: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t3 graph stress 011")
display as text "[GRAPH-UNNAMED] t3 unnamed graph 011 produced"
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T3 bar Graph 012: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t3 graph stress 012")
display as text "[GRAPH-UNNAMED] t3 unnamed graph 012 produced"
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T3 line Graph 013: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t3 graph stress 013")
display as text "[GRAPH-UNNAMED] t3 unnamed graph 013 produced"
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T3 qfit Graph 014: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t3 graph stress 014")
display as text "[GRAPH-UNNAMED] t3 unnamed graph 014 produced"
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T3 scatter Graph 015: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t3 graph stress 015")
display as text "[GRAPH-UNNAMED] t3 unnamed graph 015 produced"
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T3 hist Graph 016: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t3 graph stress 016")
display as text "[GRAPH-UNNAMED] t3 unnamed graph 016 produced"
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T3 bar Graph 017: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t3 graph stress 017")
display as text "[GRAPH-UNNAMED] t3 unnamed graph 017 produced"
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T3 line Graph 018: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t3 graph stress 018")
display as text "[GRAPH-UNNAMED] t3 unnamed graph 018 produced"
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T3 qfit Graph 019: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t3 graph stress 019")
display as text "[GRAPH-UNNAMED] t3 unnamed graph 019 produced"
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T3 scatter Graph 020: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t3 graph stress 020")
display as text "[GRAPH-UNNAMED] t3 unnamed graph 020 produced"
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T3 hist Graph 021: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t3 graph stress 021")
display as text "[GRAPH-UNNAMED] t3 unnamed graph 021 produced"
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T3 bar Graph 022: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t3 graph stress 022")
display as text "[GRAPH-UNNAMED] t3 unnamed graph 022 produced"
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T3 line Graph 023: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t3 graph stress 023")
display as text "[GRAPH-UNNAMED] t3 unnamed graph 023 produced"
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T3 qfit Graph 024: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t3 graph stress 024")
display as text "[GRAPH-UNNAMED] t3 unnamed graph 024 produced"
graph drop _all
display as text "[GRAPH-UNNAMED] graph drop _all after 24 transient graphs"
display as result "<<< DONE Section 3: unnamed transient graph gauntlet"
// #endregion ===== Section 3: unnamed transient graph gauntlet =====


// #region ===== Section 4: named graph loop and export activation =====
display as text ">>> START Section 4: named graph loop and export activation"
forvalues i = 1/80 {
    local gname = "t3loop" + string(`i', "%03.0f")
    local color = cond(mod(`i', 3)==0, "navy", cond(mod(`i', 3)==1, "maroon", "forest_green"))
    twoway (scatter price mpg if group_id == mod(`i', 8)+1, mcolor(`color'%35)) ///
        (lfit price mpg if group_id == mod(`i', 8)+1, lcolor(`color')), ///
        title("Named loop graph `i'") subtitle("Workbench batch hydrate stress") ///
        name(`gname', replace)
    graph export "$figdir3/`gname'.svg", name(`gname') replace
    display as text "[GRAPH-NAMED] exported `gname'"
}
display as result "<<< DONE Section 4: named graph loop and export activation"
// #endregion ===== Section 4: named graph loop and export activation =====


// #region ===== Section 5: large anonymous brace block =====
display as text ">>> START Section 5: large anonymous brace block"
if 1 {
    tempfile anonbase
    save `anonbase', replace
    quietly summarize t3v0001
    display as text "[ANON 0001] t3v0001 mean=" %9.4f r(mean)
    quietly summarize t3v0002
    display as text "[ANON 0002] t3v0002 mean=" %9.4f r(mean)
    quietly summarize t3v0003
    display as text "[ANON 0003] t3v0003 mean=" %9.4f r(mean)
    quietly summarize t3v0004
    display as text "[ANON 0004] t3v0004 mean=" %9.4f r(mean)
    quietly summarize t3v0005
    display as text "[ANON 0005] t3v0005 mean=" %9.4f r(mean)
    quietly summarize t3v0006
    display as text "[ANON 0006] t3v0006 mean=" %9.4f r(mean)
    quietly summarize t3v0007
    display as text "[ANON 0007] t3v0007 mean=" %9.4f r(mean)
    quietly summarize t3v0008
    display as text "[ANON 0008] t3v0008 mean=" %9.4f r(mean)
    quietly summarize t3v0009
    display as text "[ANON 0009] t3v0009 mean=" %9.4f r(mean)
    quietly summarize t3v0010
    display as text "[ANON 0010] t3v0010 mean=" %9.4f r(mean)
    quietly summarize t3v0011
    display as text "[ANON 0011] t3v0011 mean=" %9.4f r(mean)
    quietly summarize t3v0012
    display as text "[ANON 0012] t3v0012 mean=" %9.4f r(mean)
    quietly summarize t3v0013
    display as text "[ANON 0013] t3v0013 mean=" %9.4f r(mean)
    quietly regress price mpg weight t3v0013
    quietly summarize t3v0014
    display as text "[ANON 0014] t3v0014 mean=" %9.4f r(mean)
    quietly summarize t3v0015
    display as text "[ANON 0015] t3v0015 mean=" %9.4f r(mean)
    quietly summarize t3v0016
    display as text "[ANON 0016] t3v0016 mean=" %9.4f r(mean)
    quietly summarize t3v0017
    display as text "[ANON 0017] t3v0017 mean=" %9.4f r(mean)
    quietly summarize t3v0018
    display as text "[ANON 0018] t3v0018 mean=" %9.4f r(mean)
    quietly summarize t3v0019
    display as text "[ANON 0019] t3v0019 mean=" %9.4f r(mean)
    quietly summarize t3v0020
    display as text "[ANON 0020] t3v0020 mean=" %9.4f r(mean)
    quietly summarize t3v0021
    display as text "[ANON 0021] t3v0021 mean=" %9.4f r(mean)
    quietly summarize t3v0022
    display as text "[ANON 0022] t3v0022 mean=" %9.4f r(mean)
    quietly summarize t3v0023
    display as text "[ANON 0023] t3v0023 mean=" %9.4f r(mean)
    quietly summarize t3v0024
    display as text "[ANON 0024] t3v0024 mean=" %9.4f r(mean)
    quietly summarize t3v0025
    display as text "[ANON 0025] t3v0025 mean=" %9.4f r(mean)
    quietly summarize t3v0026
    display as text "[ANON 0026] t3v0026 mean=" %9.4f r(mean)
    quietly regress price mpg weight t3v0026
    quietly summarize t3v0027
    display as text "[ANON 0027] t3v0027 mean=" %9.4f r(mean)
    quietly summarize t3v0028
    display as text "[ANON 0028] t3v0028 mean=" %9.4f r(mean)
    quietly summarize t3v0029
    display as text "[ANON 0029] t3v0029 mean=" %9.4f r(mean)
    preserve
    keep if !missing(price, mpg, weight)
    count
    restore
    quietly summarize t3v0030
    display as text "[ANON 0030] t3v0030 mean=" %9.4f r(mean)
    quietly summarize t3v0031
    display as text "[ANON 0031] t3v0031 mean=" %9.4f r(mean)
    quietly summarize t3v0032
    display as text "[ANON 0032] t3v0032 mean=" %9.4f r(mean)
    quietly summarize t3v0033
    display as text "[ANON 0033] t3v0033 mean=" %9.4f r(mean)
    quietly summarize t3v0034
    display as text "[ANON 0034] t3v0034 mean=" %9.4f r(mean)
    quietly summarize t3v0035
    display as text "[ANON 0035] t3v0035 mean=" %9.4f r(mean)
    quietly summarize t3v0036
    display as text "[ANON 0036] t3v0036 mean=" %9.4f r(mean)
    quietly summarize t3v0037
    display as text "[ANON 0037] t3v0037 mean=" %9.4f r(mean)
    quietly summarize t3v0038
    display as text "[ANON 0038] t3v0038 mean=" %9.4f r(mean)
    quietly summarize t3v0039
    display as text "[ANON 0039] t3v0039 mean=" %9.4f r(mean)
    quietly regress price mpg weight t3v0039
    quietly summarize t3v0040
    display as text "[ANON 0040] t3v0040 mean=" %9.4f r(mean)
    quietly summarize t3v0041
    display as text "[ANON 0041] t3v0041 mean=" %9.4f r(mean)
    quietly summarize t3v0042
    display as text "[ANON 0042] t3v0042 mean=" %9.4f r(mean)
    quietly summarize t3v0043
    display as text "[ANON 0043] t3v0043 mean=" %9.4f r(mean)
    quietly summarize t3v0044
    display as text "[ANON 0044] t3v0044 mean=" %9.4f r(mean)
    quietly summarize t3v0045
    display as text "[ANON 0045] t3v0045 mean=" %9.4f r(mean)
    quietly summarize t3v0046
    display as text "[ANON 0046] t3v0046 mean=" %9.4f r(mean)
    quietly summarize t3v0047
    display as text "[ANON 0047] t3v0047 mean=" %9.4f r(mean)
    quietly summarize t3v0048
    display as text "[ANON 0048] t3v0048 mean=" %9.4f r(mean)
    quietly summarize t3v0049
    display as text "[ANON 0049] t3v0049 mean=" %9.4f r(mean)
    quietly summarize t3v0050
    display as text "[ANON 0050] t3v0050 mean=" %9.4f r(mean)
    quietly summarize t3v0051
    display as text "[ANON 0051] t3v0051 mean=" %9.4f r(mean)
    quietly summarize t3v0052
    display as text "[ANON 0052] t3v0052 mean=" %9.4f r(mean)
    quietly regress price mpg weight t3v0052
    quietly summarize t3v0053
    display as text "[ANON 0053] t3v0053 mean=" %9.4f r(mean)
    quietly summarize t3v0054
    display as text "[ANON 0054] t3v0054 mean=" %9.4f r(mean)
    quietly summarize t3v0055
    display as text "[ANON 0055] t3v0055 mean=" %9.4f r(mean)
    quietly summarize t3v0056
    display as text "[ANON 0056] t3v0056 mean=" %9.4f r(mean)
    quietly summarize t3v0057
    display as text "[ANON 0057] t3v0057 mean=" %9.4f r(mean)
    quietly summarize t3v0058
    display as text "[ANON 0058] t3v0058 mean=" %9.4f r(mean)
    preserve
    keep if !missing(price, mpg, weight)
    count
    restore
    quietly summarize t3v0059
    display as text "[ANON 0059] t3v0059 mean=" %9.4f r(mean)
    quietly summarize t3v0060
    display as text "[ANON 0060] t3v0060 mean=" %9.4f r(mean)
    quietly summarize t3v0061
    display as text "[ANON 0061] t3v0061 mean=" %9.4f r(mean)
    quietly summarize t3v0062
    display as text "[ANON 0062] t3v0062 mean=" %9.4f r(mean)
    quietly summarize t3v0063
    display as text "[ANON 0063] t3v0063 mean=" %9.4f r(mean)
    quietly summarize t3v0064
    display as text "[ANON 0064] t3v0064 mean=" %9.4f r(mean)
    quietly summarize t3v0065
    display as text "[ANON 0065] t3v0065 mean=" %9.4f r(mean)
    quietly regress price mpg weight t3v0065
    quietly summarize t3v0066
    display as text "[ANON 0066] t3v0066 mean=" %9.4f r(mean)
    quietly summarize t3v0067
    display as text "[ANON 0067] t3v0067 mean=" %9.4f r(mean)
    quietly summarize t3v0068
    display as text "[ANON 0068] t3v0068 mean=" %9.4f r(mean)
    quietly summarize t3v0069
    display as text "[ANON 0069] t3v0069 mean=" %9.4f r(mean)
    quietly summarize t3v0070
    display as text "[ANON 0070] t3v0070 mean=" %9.4f r(mean)
    quietly summarize t3v0071
    display as text "[ANON 0071] t3v0071 mean=" %9.4f r(mean)
    quietly summarize t3v0072
    display as text "[ANON 0072] t3v0072 mean=" %9.4f r(mean)
    quietly summarize t3v0073
    display as text "[ANON 0073] t3v0073 mean=" %9.4f r(mean)
    quietly summarize t3v0074
    display as text "[ANON 0074] t3v0074 mean=" %9.4f r(mean)
    quietly summarize t3v0075
    display as text "[ANON 0075] t3v0075 mean=" %9.4f r(mean)
    quietly summarize t3v0076
    display as text "[ANON 0076] t3v0076 mean=" %9.4f r(mean)
    quietly summarize t3v0077
    display as text "[ANON 0077] t3v0077 mean=" %9.4f r(mean)
    quietly summarize t3v0078
    display as text "[ANON 0078] t3v0078 mean=" %9.4f r(mean)
    quietly regress price mpg weight t3v0078
    quietly summarize t3v0079
    display as text "[ANON 0079] t3v0079 mean=" %9.4f r(mean)
    quietly summarize t3v0080
    display as text "[ANON 0080] t3v0080 mean=" %9.4f r(mean)
    quietly summarize t3v0081
    display as text "[ANON 0081] t3v0081 mean=" %9.4f r(mean)
    quietly summarize t3v0082
    display as text "[ANON 0082] t3v0082 mean=" %9.4f r(mean)
    quietly summarize t3v0083
    display as text "[ANON 0083] t3v0083 mean=" %9.4f r(mean)
    quietly summarize t3v0084
    display as text "[ANON 0084] t3v0084 mean=" %9.4f r(mean)
    quietly summarize t3v0085
    display as text "[ANON 0085] t3v0085 mean=" %9.4f r(mean)
    quietly summarize t3v0086
    display as text "[ANON 0086] t3v0086 mean=" %9.4f r(mean)
    quietly summarize t3v0087
    display as text "[ANON 0087] t3v0087 mean=" %9.4f r(mean)
    preserve
    keep if !missing(price, mpg, weight)
    count
    restore
    quietly summarize t3v0088
    display as text "[ANON 0088] t3v0088 mean=" %9.4f r(mean)
    quietly summarize t3v0089
    display as text "[ANON 0089] t3v0089 mean=" %9.4f r(mean)
    quietly summarize t3v0090
    display as text "[ANON 0090] t3v0090 mean=" %9.4f r(mean)
    quietly summarize t3v0091
    display as text "[ANON 0091] t3v0091 mean=" %9.4f r(mean)
    quietly regress price mpg weight t3v0091
    quietly summarize t3v0092
    display as text "[ANON 0092] t3v0092 mean=" %9.4f r(mean)
    quietly summarize t3v0093
    display as text "[ANON 0093] t3v0093 mean=" %9.4f r(mean)
    quietly summarize t3v0094
    display as text "[ANON 0094] t3v0094 mean=" %9.4f r(mean)
    quietly summarize t3v0095
    display as text "[ANON 0095] t3v0095 mean=" %9.4f r(mean)
    quietly summarize t3v0096
    display as text "[ANON 0096] t3v0096 mean=" %9.4f r(mean)
    quietly summarize t3v0097
    display as text "[ANON 0097] t3v0097 mean=" %9.4f r(mean)
    quietly summarize t3v0098
    display as text "[ANON 0098] t3v0098 mean=" %9.4f r(mean)
    quietly summarize t3v0099
    display as text "[ANON 0099] t3v0099 mean=" %9.4f r(mean)
    quietly summarize t3v0100
    display as text "[ANON 0100] t3v0100 mean=" %9.4f r(mean)
    quietly summarize t3v0101
    display as text "[ANON 0101] t3v0101 mean=" %9.4f r(mean)
    quietly summarize t3v0102
    display as text "[ANON 0102] t3v0102 mean=" %9.4f r(mean)
    quietly summarize t3v0103
    display as text "[ANON 0103] t3v0103 mean=" %9.4f r(mean)
    quietly summarize t3v0104
    display as text "[ANON 0104] t3v0104 mean=" %9.4f r(mean)
    quietly regress price mpg weight t3v0104
    quietly summarize t3v0105
    display as text "[ANON 0105] t3v0105 mean=" %9.4f r(mean)
    quietly summarize t3v0106
    display as text "[ANON 0106] t3v0106 mean=" %9.4f r(mean)
    quietly summarize t3v0107
    display as text "[ANON 0107] t3v0107 mean=" %9.4f r(mean)
    quietly summarize t3v0108
    display as text "[ANON 0108] t3v0108 mean=" %9.4f r(mean)
    quietly summarize t3v0109
    display as text "[ANON 0109] t3v0109 mean=" %9.4f r(mean)
    quietly summarize t3v0110
    display as text "[ANON 0110] t3v0110 mean=" %9.4f r(mean)
    quietly summarize t3v0111
    display as text "[ANON 0111] t3v0111 mean=" %9.4f r(mean)
    quietly summarize t3v0112
    display as text "[ANON 0112] t3v0112 mean=" %9.4f r(mean)
    quietly summarize t3v0113
    display as text "[ANON 0113] t3v0113 mean=" %9.4f r(mean)
    quietly summarize t3v0114
    display as text "[ANON 0114] t3v0114 mean=" %9.4f r(mean)
    quietly summarize t3v0115
    display as text "[ANON 0115] t3v0115 mean=" %9.4f r(mean)
    quietly summarize t3v0116
    display as text "[ANON 0116] t3v0116 mean=" %9.4f r(mean)
    preserve
    keep if !missing(price, mpg, weight)
    count
    restore
    quietly summarize t3v0117
    display as text "[ANON 0117] t3v0117 mean=" %9.4f r(mean)
    quietly regress price mpg weight t3v0117
    quietly summarize t3v0118
    display as text "[ANON 0118] t3v0118 mean=" %9.4f r(mean)
    quietly summarize t3v0119
    display as text "[ANON 0119] t3v0119 mean=" %9.4f r(mean)
    quietly summarize t3v0120
    display as text "[ANON 0120] t3v0120 mean=" %9.4f r(mean)
    quietly summarize t3v0121
    display as text "[ANON 0121] t3v0121 mean=" %9.4f r(mean)
    quietly summarize t3v0122
    display as text "[ANON 0122] t3v0122 mean=" %9.4f r(mean)
    quietly summarize t3v0123
    display as text "[ANON 0123] t3v0123 mean=" %9.4f r(mean)
    quietly summarize t3v0124
    display as text "[ANON 0124] t3v0124 mean=" %9.4f r(mean)
    quietly summarize t3v0125
    display as text "[ANON 0125] t3v0125 mean=" %9.4f r(mean)
    quietly summarize t3v0126
    display as text "[ANON 0126] t3v0126 mean=" %9.4f r(mean)
    quietly summarize t3v0127
    display as text "[ANON 0127] t3v0127 mean=" %9.4f r(mean)
    quietly summarize t3v0128
    display as text "[ANON 0128] t3v0128 mean=" %9.4f r(mean)
    quietly summarize t3v0129
    display as text "[ANON 0129] t3v0129 mean=" %9.4f r(mean)
    quietly summarize t3v0130
    display as text "[ANON 0130] t3v0130 mean=" %9.4f r(mean)
    quietly regress price mpg weight t3v0130
    quietly summarize t3v0131
    display as text "[ANON 0131] t3v0131 mean=" %9.4f r(mean)
    quietly summarize t3v0132
    display as text "[ANON 0132] t3v0132 mean=" %9.4f r(mean)
    quietly summarize t3v0133
    display as text "[ANON 0133] t3v0133 mean=" %9.4f r(mean)
    quietly summarize t3v0134
    display as text "[ANON 0134] t3v0134 mean=" %9.4f r(mean)
    quietly summarize t3v0135
    display as text "[ANON 0135] t3v0135 mean=" %9.4f r(mean)
    quietly summarize t3v0136
    display as text "[ANON 0136] t3v0136 mean=" %9.4f r(mean)
    quietly summarize t3v0137
    display as text "[ANON 0137] t3v0137 mean=" %9.4f r(mean)
    quietly summarize t3v0138
    display as text "[ANON 0138] t3v0138 mean=" %9.4f r(mean)
    quietly summarize t3v0139
    display as text "[ANON 0139] t3v0139 mean=" %9.4f r(mean)
    quietly summarize t3v0140
    display as text "[ANON 0140] t3v0140 mean=" %9.4f r(mean)
    quietly summarize t3v0141
    display as text "[ANON 0141] t3v0141 mean=" %9.4f r(mean)
    quietly summarize t3v0142
    display as text "[ANON 0142] t3v0142 mean=" %9.4f r(mean)
    quietly summarize t3v0143
    display as text "[ANON 0143] t3v0143 mean=" %9.4f r(mean)
    quietly regress price mpg weight t3v0143
    quietly summarize t3v0144
    display as text "[ANON 0144] t3v0144 mean=" %9.4f r(mean)
    quietly summarize t3v0145
    display as text "[ANON 0145] t3v0145 mean=" %9.4f r(mean)
    preserve
    keep if !missing(price, mpg, weight)
    count
    restore
    quietly summarize t3v0146
    display as text "[ANON 0146] t3v0146 mean=" %9.4f r(mean)
    quietly summarize t3v0147
    display as text "[ANON 0147] t3v0147 mean=" %9.4f r(mean)
    quietly summarize t3v0148
    display as text "[ANON 0148] t3v0148 mean=" %9.4f r(mean)
    quietly summarize t3v0149
    display as text "[ANON 0149] t3v0149 mean=" %9.4f r(mean)
    quietly summarize t3v0150
    display as text "[ANON 0150] t3v0150 mean=" %9.4f r(mean)
    quietly summarize t3v0151
    display as text "[ANON 0151] t3v0151 mean=" %9.4f r(mean)
    quietly summarize t3v0152
    display as text "[ANON 0152] t3v0152 mean=" %9.4f r(mean)
    quietly summarize t3v0153
    display as text "[ANON 0153] t3v0153 mean=" %9.4f r(mean)
    quietly summarize t3v0154
    display as text "[ANON 0154] t3v0154 mean=" %9.4f r(mean)
    quietly summarize t3v0155
    display as text "[ANON 0155] t3v0155 mean=" %9.4f r(mean)
    quietly summarize t3v0156
    display as text "[ANON 0156] t3v0156 mean=" %9.4f r(mean)
    quietly regress price mpg weight t3v0156
    quietly summarize t3v0157
    display as text "[ANON 0157] t3v0157 mean=" %9.4f r(mean)
    quietly summarize t3v0158
    display as text "[ANON 0158] t3v0158 mean=" %9.4f r(mean)
    quietly summarize t3v0159
    display as text "[ANON 0159] t3v0159 mean=" %9.4f r(mean)
    quietly summarize t3v0160
    display as text "[ANON 0160] t3v0160 mean=" %9.4f r(mean)
    quietly summarize t3v0161
    display as text "[ANON 0161] t3v0161 mean=" %9.4f r(mean)
    quietly summarize t3v0162
    display as text "[ANON 0162] t3v0162 mean=" %9.4f r(mean)
    quietly summarize t3v0163
    display as text "[ANON 0163] t3v0163 mean=" %9.4f r(mean)
    quietly summarize t3v0164
    display as text "[ANON 0164] t3v0164 mean=" %9.4f r(mean)
    quietly summarize t3v0165
    display as text "[ANON 0165] t3v0165 mean=" %9.4f r(mean)
    quietly summarize t3v0166
    display as text "[ANON 0166] t3v0166 mean=" %9.4f r(mean)
    quietly summarize t3v0167
    display as text "[ANON 0167] t3v0167 mean=" %9.4f r(mean)
    quietly summarize t3v0168
    display as text "[ANON 0168] t3v0168 mean=" %9.4f r(mean)
    quietly summarize t3v0169
    display as text "[ANON 0169] t3v0169 mean=" %9.4f r(mean)
    quietly regress price mpg weight t3v0169
    quietly summarize t3v0170
    display as text "[ANON 0170] t3v0170 mean=" %9.4f r(mean)
    quietly summarize t3v0171
    display as text "[ANON 0171] t3v0171 mean=" %9.4f r(mean)
    quietly summarize t3v0172
    display as text "[ANON 0172] t3v0172 mean=" %9.4f r(mean)
    quietly summarize t3v0173
    display as text "[ANON 0173] t3v0173 mean=" %9.4f r(mean)
    quietly summarize t3v0174
    display as text "[ANON 0174] t3v0174 mean=" %9.4f r(mean)
    preserve
    keep if !missing(price, mpg, weight)
    count
    restore
    quietly summarize t3v0175
    display as text "[ANON 0175] t3v0175 mean=" %9.4f r(mean)
    quietly summarize t3v0176
    display as text "[ANON 0176] t3v0176 mean=" %9.4f r(mean)
    quietly summarize t3v0177
    display as text "[ANON 0177] t3v0177 mean=" %9.4f r(mean)
    quietly summarize t3v0178
    display as text "[ANON 0178] t3v0178 mean=" %9.4f r(mean)
    quietly summarize t3v0179
    display as text "[ANON 0179] t3v0179 mean=" %9.4f r(mean)
    quietly summarize t3v0180
    display as text "[ANON 0180] t3v0180 mean=" %9.4f r(mean)
    quietly summarize t3v0181
    display as text "[ANON 0181] t3v0181 mean=" %9.4f r(mean)
    quietly summarize t3v0182
    display as text "[ANON 0182] t3v0182 mean=" %9.4f r(mean)
    quietly regress price mpg weight t3v0182
    quietly summarize t3v0183
    display as text "[ANON 0183] t3v0183 mean=" %9.4f r(mean)
    quietly summarize t3v0184
    display as text "[ANON 0184] t3v0184 mean=" %9.4f r(mean)
    quietly summarize t3v0185
    display as text "[ANON 0185] t3v0185 mean=" %9.4f r(mean)
    quietly summarize t3v0186
    display as text "[ANON 0186] t3v0186 mean=" %9.4f r(mean)
    quietly summarize t3v0187
    display as text "[ANON 0187] t3v0187 mean=" %9.4f r(mean)
    quietly summarize t3v0188
    display as text "[ANON 0188] t3v0188 mean=" %9.4f r(mean)
    quietly summarize t3v0189
    display as text "[ANON 0189] t3v0189 mean=" %9.4f r(mean)
    quietly summarize t3v0190
    display as text "[ANON 0190] t3v0190 mean=" %9.4f r(mean)
    quietly summarize t3v0191
    display as text "[ANON 0191] t3v0191 mean=" %9.4f r(mean)
    quietly summarize t3v0192
    display as text "[ANON 0192] t3v0192 mean=" %9.4f r(mean)
    quietly summarize t3v0193
    display as text "[ANON 0193] t3v0193 mean=" %9.4f r(mean)
    quietly summarize t3v0194
    display as text "[ANON 0194] t3v0194 mean=" %9.4f r(mean)
    quietly summarize t3v0195
    display as text "[ANON 0195] t3v0195 mean=" %9.4f r(mean)
    quietly regress price mpg weight t3v0195
    quietly summarize t3v0196
    display as text "[ANON 0196] t3v0196 mean=" %9.4f r(mean)
    quietly summarize t3v0197
    display as text "[ANON 0197] t3v0197 mean=" %9.4f r(mean)
    quietly summarize t3v0198
    display as text "[ANON 0198] t3v0198 mean=" %9.4f r(mean)
    quietly summarize t3v0199
    display as text "[ANON 0199] t3v0199 mean=" %9.4f r(mean)
    quietly summarize t3v0200
    display as text "[ANON 0200] t3v0200 mean=" %9.4f r(mean)
    quietly summarize t3v0201
    display as text "[ANON 0201] t3v0201 mean=" %9.4f r(mean)
    quietly summarize t3v0202
    display as text "[ANON 0202] t3v0202 mean=" %9.4f r(mean)
    quietly summarize t3v0203
    display as text "[ANON 0203] t3v0203 mean=" %9.4f r(mean)
    preserve
    keep if !missing(price, mpg, weight)
    count
    restore
    quietly summarize t3v0204
    display as text "[ANON 0204] t3v0204 mean=" %9.4f r(mean)
    quietly summarize t3v0205
    display as text "[ANON 0205] t3v0205 mean=" %9.4f r(mean)
    quietly summarize t3v0206
    display as text "[ANON 0206] t3v0206 mean=" %9.4f r(mean)
    quietly summarize t3v0207
    display as text "[ANON 0207] t3v0207 mean=" %9.4f r(mean)
    quietly summarize t3v0208
    display as text "[ANON 0208] t3v0208 mean=" %9.4f r(mean)
    quietly regress price mpg weight t3v0208
    quietly summarize t3v0209
    display as text "[ANON 0209] t3v0209 mean=" %9.4f r(mean)
    quietly summarize t3v0210
    display as text "[ANON 0210] t3v0210 mean=" %9.4f r(mean)
    quietly summarize t3v0211
    display as text "[ANON 0211] t3v0211 mean=" %9.4f r(mean)
    quietly summarize t3v0212
    display as text "[ANON 0212] t3v0212 mean=" %9.4f r(mean)
    quietly summarize t3v0213
    display as text "[ANON 0213] t3v0213 mean=" %9.4f r(mean)
    quietly summarize t3v0214
    display as text "[ANON 0214] t3v0214 mean=" %9.4f r(mean)
    quietly summarize t3v0215
    display as text "[ANON 0215] t3v0215 mean=" %9.4f r(mean)
    quietly summarize t3v0216
    display as text "[ANON 0216] t3v0216 mean=" %9.4f r(mean)
    quietly summarize t3v0217
    display as text "[ANON 0217] t3v0217 mean=" %9.4f r(mean)
    quietly summarize t3v0218
    display as text "[ANON 0218] t3v0218 mean=" %9.4f r(mean)
    quietly summarize t3v0219
    display as text "[ANON 0219] t3v0219 mean=" %9.4f r(mean)
    quietly summarize t3v0220
    display as text "[ANON 0220] t3v0220 mean=" %9.4f r(mean)
    quietly summarize t3v0221
    display as text "[ANON 0221] t3v0221 mean=" %9.4f r(mean)
    quietly regress price mpg weight t3v0221
    quietly summarize t3v0222
    display as text "[ANON 0222] t3v0222 mean=" %9.4f r(mean)
    quietly summarize t3v0223
    display as text "[ANON 0223] t3v0223 mean=" %9.4f r(mean)
    quietly summarize t3v0224
    display as text "[ANON 0224] t3v0224 mean=" %9.4f r(mean)
    quietly summarize t3v0225
    display as text "[ANON 0225] t3v0225 mean=" %9.4f r(mean)
    quietly summarize t3v0226
    display as text "[ANON 0226] t3v0226 mean=" %9.4f r(mean)
    quietly summarize t3v0227
    display as text "[ANON 0227] t3v0227 mean=" %9.4f r(mean)
    quietly summarize t3v0228
    display as text "[ANON 0228] t3v0228 mean=" %9.4f r(mean)
    quietly summarize t3v0229
    display as text "[ANON 0229] t3v0229 mean=" %9.4f r(mean)
    quietly summarize t3v0230
    display as text "[ANON 0230] t3v0230 mean=" %9.4f r(mean)
    quietly summarize t3v0231
    display as text "[ANON 0231] t3v0231 mean=" %9.4f r(mean)
    quietly summarize t3v0232
    display as text "[ANON 0232] t3v0232 mean=" %9.4f r(mean)
    preserve
    keep if !missing(price, mpg, weight)
    count
    restore
    quietly summarize t3v0233
    display as text "[ANON 0233] t3v0233 mean=" %9.4f r(mean)
    quietly summarize t3v0234
    display as text "[ANON 0234] t3v0234 mean=" %9.4f r(mean)
    quietly regress price mpg weight t3v0234
    quietly summarize t3v0235
    display as text "[ANON 0235] t3v0235 mean=" %9.4f r(mean)
    quietly summarize t3v0236
    display as text "[ANON 0236] t3v0236 mean=" %9.4f r(mean)
    quietly summarize t3v0237
    display as text "[ANON 0237] t3v0237 mean=" %9.4f r(mean)
    quietly summarize t3v0238
    display as text "[ANON 0238] t3v0238 mean=" %9.4f r(mean)
    quietly summarize t3v0239
    display as text "[ANON 0239] t3v0239 mean=" %9.4f r(mean)
    quietly summarize t3v0240
    display as text "[ANON 0240] t3v0240 mean=" %9.4f r(mean)
    quietly summarize t3v0241
    display as text "[ANON 0241] t3v0241 mean=" %9.4f r(mean)
    quietly summarize t3v0242
    display as text "[ANON 0242] t3v0242 mean=" %9.4f r(mean)
    quietly summarize t3v0243
    display as text "[ANON 0243] t3v0243 mean=" %9.4f r(mean)
    quietly summarize t3v0244
    display as text "[ANON 0244] t3v0244 mean=" %9.4f r(mean)
    quietly summarize t3v0245
    display as text "[ANON 0245] t3v0245 mean=" %9.4f r(mean)
    quietly summarize t3v0246
    display as text "[ANON 0246] t3v0246 mean=" %9.4f r(mean)
    quietly summarize t3v0247
    display as text "[ANON 0247] t3v0247 mean=" %9.4f r(mean)
    quietly regress price mpg weight t3v0247
    quietly summarize t3v0248
    display as text "[ANON 0248] t3v0248 mean=" %9.4f r(mean)
    quietly summarize t3v0249
    display as text "[ANON 0249] t3v0249 mean=" %9.4f r(mean)
    quietly summarize t3v0250
    display as text "[ANON 0250] t3v0250 mean=" %9.4f r(mean)
    quietly summarize t3v0251
    display as text "[ANON 0251] t3v0251 mean=" %9.4f r(mean)
    quietly summarize t3v0252
    display as text "[ANON 0252] t3v0252 mean=" %9.4f r(mean)
    quietly summarize t3v0253
    display as text "[ANON 0253] t3v0253 mean=" %9.4f r(mean)
    quietly summarize t3v0254
    display as text "[ANON 0254] t3v0254 mean=" %9.4f r(mean)
    quietly summarize t3v0255
    display as text "[ANON 0255] t3v0255 mean=" %9.4f r(mean)
    quietly summarize t3v0256
    display as text "[ANON 0256] t3v0256 mean=" %9.4f r(mean)
    quietly summarize t3v0257
    display as text "[ANON 0257] t3v0257 mean=" %9.4f r(mean)
    quietly summarize t3v0258
    display as text "[ANON 0258] t3v0258 mean=" %9.4f r(mean)
    quietly summarize t3v0259
    display as text "[ANON 0259] t3v0259 mean=" %9.4f r(mean)
    quietly summarize t3v0260
    display as text "[ANON 0260] t3v0260 mean=" %9.4f r(mean)
    quietly regress price mpg weight t3v0260
    quietly summarize t3v0261
    display as text "[ANON 0261] t3v0261 mean=" %9.4f r(mean)
    preserve
    keep if !missing(price, mpg, weight)
    count
    restore
    quietly summarize t3v0262
    display as text "[ANON 0262] t3v0262 mean=" %9.4f r(mean)
    quietly summarize t3v0263
    display as text "[ANON 0263] t3v0263 mean=" %9.4f r(mean)
    quietly summarize t3v0264
    display as text "[ANON 0264] t3v0264 mean=" %9.4f r(mean)
    quietly summarize t3v0265
    display as text "[ANON 0265] t3v0265 mean=" %9.4f r(mean)
    quietly summarize t3v0266
    display as text "[ANON 0266] t3v0266 mean=" %9.4f r(mean)
    quietly summarize t3v0267
    display as text "[ANON 0267] t3v0267 mean=" %9.4f r(mean)
    quietly summarize t3v0268
    display as text "[ANON 0268] t3v0268 mean=" %9.4f r(mean)
    quietly summarize t3v0269
    display as text "[ANON 0269] t3v0269 mean=" %9.4f r(mean)
    quietly summarize t3v0270
    display as text "[ANON 0270] t3v0270 mean=" %9.4f r(mean)
    quietly summarize t3v0271
    display as text "[ANON 0271] t3v0271 mean=" %9.4f r(mean)
    quietly summarize t3v0272
    display as text "[ANON 0272] t3v0272 mean=" %9.4f r(mean)
    quietly summarize t3v0273
    display as text "[ANON 0273] t3v0273 mean=" %9.4f r(mean)
    quietly regress price mpg weight t3v0273
    quietly summarize t3v0274
    display as text "[ANON 0274] t3v0274 mean=" %9.4f r(mean)
    quietly summarize t3v0275
    display as text "[ANON 0275] t3v0275 mean=" %9.4f r(mean)
    quietly summarize t3v0276
    display as text "[ANON 0276] t3v0276 mean=" %9.4f r(mean)
    quietly summarize t3v0277
    display as text "[ANON 0277] t3v0277 mean=" %9.4f r(mean)
    quietly summarize t3v0278
    display as text "[ANON 0278] t3v0278 mean=" %9.4f r(mean)
    quietly summarize t3v0279
    display as text "[ANON 0279] t3v0279 mean=" %9.4f r(mean)
    quietly summarize t3v0280
    display as text "[ANON 0280] t3v0280 mean=" %9.4f r(mean)
    quietly summarize t3v0281
    display as text "[ANON 0281] t3v0281 mean=" %9.4f r(mean)
    quietly summarize t3v0282
    display as text "[ANON 0282] t3v0282 mean=" %9.4f r(mean)
    quietly summarize t3v0283
    display as text "[ANON 0283] t3v0283 mean=" %9.4f r(mean)
    quietly summarize t3v0284
    display as text "[ANON 0284] t3v0284 mean=" %9.4f r(mean)
    quietly summarize t3v0285
    display as text "[ANON 0285] t3v0285 mean=" %9.4f r(mean)
    quietly summarize t3v0286
    display as text "[ANON 0286] t3v0286 mean=" %9.4f r(mean)
    quietly regress price mpg weight t3v0286
    quietly summarize t3v0287
    display as text "[ANON 0287] t3v0287 mean=" %9.4f r(mean)
    quietly summarize t3v0288
    display as text "[ANON 0288] t3v0288 mean=" %9.4f r(mean)
    quietly summarize t3v0289
    display as text "[ANON 0289] t3v0289 mean=" %9.4f r(mean)
    quietly summarize t3v0290
    display as text "[ANON 0290] t3v0290 mean=" %9.4f r(mean)
    preserve
    keep if !missing(price, mpg, weight)
    count
    restore
    quietly summarize t3v0291
    display as text "[ANON 0291] t3v0291 mean=" %9.4f r(mean)
    quietly summarize t3v0292
    display as text "[ANON 0292] t3v0292 mean=" %9.4f r(mean)
    quietly summarize t3v0293
    display as text "[ANON 0293] t3v0293 mean=" %9.4f r(mean)
    quietly summarize t3v0294
    display as text "[ANON 0294] t3v0294 mean=" %9.4f r(mean)
    quietly summarize t3v0295
    display as text "[ANON 0295] t3v0295 mean=" %9.4f r(mean)
    quietly summarize t3v0296
    display as text "[ANON 0296] t3v0296 mean=" %9.4f r(mean)
    quietly summarize t3v0297
    display as text "[ANON 0297] t3v0297 mean=" %9.4f r(mean)
    quietly summarize t3v0298
    display as text "[ANON 0298] t3v0298 mean=" %9.4f r(mean)
    quietly summarize t3v0299
    display as text "[ANON 0299] t3v0299 mean=" %9.4f r(mean)
    quietly regress price mpg weight t3v0299
    quietly summarize t3v0300
    display as text "[ANON 0300] t3v0300 mean=" %9.4f r(mean)
    quietly summarize t3v0301
    display as text "[ANON 0301] t3v0301 mean=" %9.4f r(mean)
    quietly summarize t3v0302
    display as text "[ANON 0302] t3v0302 mean=" %9.4f r(mean)
    quietly summarize t3v0303
    display as text "[ANON 0303] t3v0303 mean=" %9.4f r(mean)
    quietly summarize t3v0304
    display as text "[ANON 0304] t3v0304 mean=" %9.4f r(mean)
    quietly summarize t3v0305
    display as text "[ANON 0305] t3v0305 mean=" %9.4f r(mean)
    quietly summarize t3v0306
    display as text "[ANON 0306] t3v0306 mean=" %9.4f r(mean)
    quietly summarize t3v0307
    display as text "[ANON 0307] t3v0307 mean=" %9.4f r(mean)
    quietly summarize t3v0308
    display as text "[ANON 0308] t3v0308 mean=" %9.4f r(mean)
    quietly summarize t3v0309
    display as text "[ANON 0309] t3v0309 mean=" %9.4f r(mean)
    quietly summarize t3v0310
    display as text "[ANON 0310] t3v0310 mean=" %9.4f r(mean)
    quietly summarize t3v0311
    display as text "[ANON 0311] t3v0311 mean=" %9.4f r(mean)
    quietly summarize t3v0312
    display as text "[ANON 0312] t3v0312 mean=" %9.4f r(mean)
    quietly regress price mpg weight t3v0312
    quietly summarize t3v0313
    display as text "[ANON 0313] t3v0313 mean=" %9.4f r(mean)
    quietly summarize t3v0314
    display as text "[ANON 0314] t3v0314 mean=" %9.4f r(mean)
    quietly summarize t3v0315
    display as text "[ANON 0315] t3v0315 mean=" %9.4f r(mean)
    quietly summarize t3v0316
    display as text "[ANON 0316] t3v0316 mean=" %9.4f r(mean)
    quietly summarize t3v0317
    display as text "[ANON 0317] t3v0317 mean=" %9.4f r(mean)
    quietly summarize t3v0318
    display as text "[ANON 0318] t3v0318 mean=" %9.4f r(mean)
    quietly summarize t3v0319
    display as text "[ANON 0319] t3v0319 mean=" %9.4f r(mean)
    preserve
    keep if !missing(price, mpg, weight)
    count
    restore
    quietly summarize t3v0320
    display as text "[ANON 0320] t3v0320 mean=" %9.4f r(mean)
    quietly summarize t3v0321
    display as text "[ANON 0321] t3v0321 mean=" %9.4f r(mean)
    quietly summarize t3v0322
    display as text "[ANON 0322] t3v0322 mean=" %9.4f r(mean)
    quietly summarize t3v0323
    display as text "[ANON 0323] t3v0323 mean=" %9.4f r(mean)
    quietly summarize t3v0324
    display as text "[ANON 0324] t3v0324 mean=" %9.4f r(mean)
    quietly summarize t3v0325
    display as text "[ANON 0325] t3v0325 mean=" %9.4f r(mean)
    quietly regress price mpg weight t3v0325
    quietly summarize t3v0326
    display as text "[ANON 0326] t3v0326 mean=" %9.4f r(mean)
    quietly summarize t3v0327
    display as text "[ANON 0327] t3v0327 mean=" %9.4f r(mean)
    quietly summarize t3v0328
    display as text "[ANON 0328] t3v0328 mean=" %9.4f r(mean)
    quietly summarize t3v0329
    display as text "[ANON 0329] t3v0329 mean=" %9.4f r(mean)
    quietly summarize t3v0330
    display as text "[ANON 0330] t3v0330 mean=" %9.4f r(mean)
    quietly summarize t3v0331
    display as text "[ANON 0331] t3v0331 mean=" %9.4f r(mean)
    quietly summarize t3v0332
    display as text "[ANON 0332] t3v0332 mean=" %9.4f r(mean)
    quietly summarize t3v0333
    display as text "[ANON 0333] t3v0333 mean=" %9.4f r(mean)
    quietly summarize t3v0334
    display as text "[ANON 0334] t3v0334 mean=" %9.4f r(mean)
    quietly summarize t3v0335
    display as text "[ANON 0335] t3v0335 mean=" %9.4f r(mean)
    quietly summarize t3v0336
    display as text "[ANON 0336] t3v0336 mean=" %9.4f r(mean)
    quietly summarize t3v0337
    display as text "[ANON 0337] t3v0337 mean=" %9.4f r(mean)
    quietly summarize t3v0338
    display as text "[ANON 0338] t3v0338 mean=" %9.4f r(mean)
    quietly regress price mpg weight t3v0338
    quietly summarize t3v0339
    display as text "[ANON 0339] t3v0339 mean=" %9.4f r(mean)
    quietly summarize t3v0340
    display as text "[ANON 0340] t3v0340 mean=" %9.4f r(mean)
    quietly summarize t3v0341
    display as text "[ANON 0341] t3v0341 mean=" %9.4f r(mean)
    quietly summarize t3v0342
    display as text "[ANON 0342] t3v0342 mean=" %9.4f r(mean)
    quietly summarize t3v0343
    display as text "[ANON 0343] t3v0343 mean=" %9.4f r(mean)
    quietly summarize t3v0344
    display as text "[ANON 0344] t3v0344 mean=" %9.4f r(mean)
    quietly summarize t3v0345
    display as text "[ANON 0345] t3v0345 mean=" %9.4f r(mean)
    quietly summarize t3v0346
    display as text "[ANON 0346] t3v0346 mean=" %9.4f r(mean)
    quietly summarize t3v0347
    display as text "[ANON 0347] t3v0347 mean=" %9.4f r(mean)
    quietly summarize t3v0348
    display as text "[ANON 0348] t3v0348 mean=" %9.4f r(mean)
    preserve
    keep if !missing(price, mpg, weight)
    count
    restore
    quietly summarize t3v0349
    display as text "[ANON 0349] t3v0349 mean=" %9.4f r(mean)
    quietly summarize t3v0350
    display as text "[ANON 0350] t3v0350 mean=" %9.4f r(mean)
    quietly summarize t3v0351
    display as text "[ANON 0351] t3v0351 mean=" %9.4f r(mean)
    quietly regress price mpg weight t3v0351
    quietly summarize t3v0352
    display as text "[ANON 0352] t3v0352 mean=" %9.4f r(mean)
    quietly summarize t3v0353
    display as text "[ANON 0353] t3v0353 mean=" %9.4f r(mean)
    quietly summarize t3v0354
    display as text "[ANON 0354] t3v0354 mean=" %9.4f r(mean)
    quietly summarize t3v0355
    display as text "[ANON 0355] t3v0355 mean=" %9.4f r(mean)
    quietly summarize t3v0356
    display as text "[ANON 0356] t3v0356 mean=" %9.4f r(mean)
    quietly summarize t3v0357
    display as text "[ANON 0357] t3v0357 mean=" %9.4f r(mean)
    quietly summarize t3v0358
    display as text "[ANON 0358] t3v0358 mean=" %9.4f r(mean)
    quietly summarize t3v0359
    display as text "[ANON 0359] t3v0359 mean=" %9.4f r(mean)
    use `anonbase', clear
}
display as result "<<< DONE Section 5: large anonymous brace block"
// #endregion ===== Section 5: large anonymous brace block =====


// #region ===== Section 6: diagnostics and table output =====
display as text ">>> START Section 6: diagnostics and table output"
tab1 foreign price_quart mpg_tert weight_tert group_id high_price high_mpg heavy_car
tabstat price mpg weight length turn displacement gear_ratio, stat(n mean sd min p50 max) columns(statistics)
correlate price mpg weight length turn displacement gear_ratio
putexcel set "$docdir/taught_task3_summary.xlsx", replace
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
quietly summarize t3v0001
display as text "[DIAG 0001] t3v0001 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0002
display as text "[DIAG 0002] t3v0002 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0003
display as text "[DIAG 0003] t3v0003 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0004
display as text "[DIAG 0004] t3v0004 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0005
display as text "[DIAG 0005] t3v0005 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0006
display as text "[DIAG 0006] t3v0006 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0007
display as text "[DIAG 0007] t3v0007 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0008
display as text "[DIAG 0008] t3v0008 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0009
display as text "[DIAG 0009] t3v0009 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0010
display as text "[DIAG 0010] t3v0010 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0011
display as text "[DIAG 0011] t3v0011 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0012
display as text "[DIAG 0012] t3v0012 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0013
display as text "[DIAG 0013] t3v0013 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0014
display as text "[DIAG 0014] t3v0014 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0015
display as text "[DIAG 0015] t3v0015 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0016
display as text "[DIAG 0016] t3v0016 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0017
display as text "[DIAG 0017] t3v0017 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0018
display as text "[DIAG 0018] t3v0018 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0019
display as text "[DIAG 0019] t3v0019 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0020
display as text "[DIAG 0020] t3v0020 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0021
display as text "[DIAG 0021] t3v0021 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0022
display as text "[DIAG 0022] t3v0022 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0023
display as text "[DIAG 0023] t3v0023 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0024
display as text "[DIAG 0024] t3v0024 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0025
display as text "[DIAG 0025] t3v0025 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0026
display as text "[DIAG 0026] t3v0026 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0027
display as text "[DIAG 0027] t3v0027 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0028
display as text "[DIAG 0028] t3v0028 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0029
display as text "[DIAG 0029] t3v0029 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0030
display as text "[DIAG 0030] t3v0030 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0031
display as text "[DIAG 0031] t3v0031 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0032
display as text "[DIAG 0032] t3v0032 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0033
display as text "[DIAG 0033] t3v0033 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0034
display as text "[DIAG 0034] t3v0034 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0035
display as text "[DIAG 0035] t3v0035 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0036
display as text "[DIAG 0036] t3v0036 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0037
display as text "[DIAG 0037] t3v0037 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0038
display as text "[DIAG 0038] t3v0038 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0039
display as text "[DIAG 0039] t3v0039 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0040
display as text "[DIAG 0040] t3v0040 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0041
display as text "[DIAG 0041] t3v0041 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0042
display as text "[DIAG 0042] t3v0042 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0043
display as text "[DIAG 0043] t3v0043 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0044
display as text "[DIAG 0044] t3v0044 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0045
display as text "[DIAG 0045] t3v0045 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0046
display as text "[DIAG 0046] t3v0046 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0047
display as text "[DIAG 0047] t3v0047 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0048
display as text "[DIAG 0048] t3v0048 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0049
display as text "[DIAG 0049] t3v0049 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0050
display as text "[DIAG 0050] t3v0050 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0051
display as text "[DIAG 0051] t3v0051 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0052
display as text "[DIAG 0052] t3v0052 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0053
display as text "[DIAG 0053] t3v0053 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0054
display as text "[DIAG 0054] t3v0054 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0055
display as text "[DIAG 0055] t3v0055 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0056
display as text "[DIAG 0056] t3v0056 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0057
display as text "[DIAG 0057] t3v0057 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0058
display as text "[DIAG 0058] t3v0058 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0059
display as text "[DIAG 0059] t3v0059 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0060
display as text "[DIAG 0060] t3v0060 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0061
display as text "[DIAG 0061] t3v0061 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0062
display as text "[DIAG 0062] t3v0062 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0063
display as text "[DIAG 0063] t3v0063 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0064
display as text "[DIAG 0064] t3v0064 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0065
display as text "[DIAG 0065] t3v0065 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0066
display as text "[DIAG 0066] t3v0066 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0067
display as text "[DIAG 0067] t3v0067 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0068
display as text "[DIAG 0068] t3v0068 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0069
display as text "[DIAG 0069] t3v0069 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0070
display as text "[DIAG 0070] t3v0070 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0071
display as text "[DIAG 0071] t3v0071 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0072
display as text "[DIAG 0072] t3v0072 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0073
display as text "[DIAG 0073] t3v0073 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0074
display as text "[DIAG 0074] t3v0074 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0075
display as text "[DIAG 0075] t3v0075 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0076
display as text "[DIAG 0076] t3v0076 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0077
display as text "[DIAG 0077] t3v0077 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0078
display as text "[DIAG 0078] t3v0078 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0079
display as text "[DIAG 0079] t3v0079 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0080
display as text "[DIAG 0080] t3v0080 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0081
display as text "[DIAG 0081] t3v0081 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0082
display as text "[DIAG 0082] t3v0082 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0083
display as text "[DIAG 0083] t3v0083 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0084
display as text "[DIAG 0084] t3v0084 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0085
display as text "[DIAG 0085] t3v0085 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0086
display as text "[DIAG 0086] t3v0086 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0087
display as text "[DIAG 0087] t3v0087 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0088
display as text "[DIAG 0088] t3v0088 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0089
display as text "[DIAG 0089] t3v0089 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0090
display as text "[DIAG 0090] t3v0090 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0091
display as text "[DIAG 0091] t3v0091 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0092
display as text "[DIAG 0092] t3v0092 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0093
display as text "[DIAG 0093] t3v0093 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0094
display as text "[DIAG 0094] t3v0094 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0095
display as text "[DIAG 0095] t3v0095 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0096
display as text "[DIAG 0096] t3v0096 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0097
display as text "[DIAG 0097] t3v0097 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0098
display as text "[DIAG 0098] t3v0098 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0099
display as text "[DIAG 0099] t3v0099 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0100
display as text "[DIAG 0100] t3v0100 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0101
display as text "[DIAG 0101] t3v0101 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0102
display as text "[DIAG 0102] t3v0102 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0103
display as text "[DIAG 0103] t3v0103 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0104
display as text "[DIAG 0104] t3v0104 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0105
display as text "[DIAG 0105] t3v0105 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0106
display as text "[DIAG 0106] t3v0106 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0107
display as text "[DIAG 0107] t3v0107 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0108
display as text "[DIAG 0108] t3v0108 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0109
display as text "[DIAG 0109] t3v0109 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0110
display as text "[DIAG 0110] t3v0110 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0111
display as text "[DIAG 0111] t3v0111 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0112
display as text "[DIAG 0112] t3v0112 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0113
display as text "[DIAG 0113] t3v0113 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0114
display as text "[DIAG 0114] t3v0114 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0115
display as text "[DIAG 0115] t3v0115 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0116
display as text "[DIAG 0116] t3v0116 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0117
display as text "[DIAG 0117] t3v0117 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0118
display as text "[DIAG 0118] t3v0118 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0119
display as text "[DIAG 0119] t3v0119 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0120
display as text "[DIAG 0120] t3v0120 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0121
display as text "[DIAG 0121] t3v0121 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0122
display as text "[DIAG 0122] t3v0122 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0123
display as text "[DIAG 0123] t3v0123 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0124
display as text "[DIAG 0124] t3v0124 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0125
display as text "[DIAG 0125] t3v0125 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0126
display as text "[DIAG 0126] t3v0126 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0127
display as text "[DIAG 0127] t3v0127 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0128
display as text "[DIAG 0128] t3v0128 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0129
display as text "[DIAG 0129] t3v0129 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0130
display as text "[DIAG 0130] t3v0130 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0131
display as text "[DIAG 0131] t3v0131 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0132
display as text "[DIAG 0132] t3v0132 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0133
display as text "[DIAG 0133] t3v0133 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0134
display as text "[DIAG 0134] t3v0134 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0135
display as text "[DIAG 0135] t3v0135 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0136
display as text "[DIAG 0136] t3v0136 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0137
display as text "[DIAG 0137] t3v0137 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0138
display as text "[DIAG 0138] t3v0138 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0139
display as text "[DIAG 0139] t3v0139 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0140
display as text "[DIAG 0140] t3v0140 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0141
display as text "[DIAG 0141] t3v0141 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0142
display as text "[DIAG 0142] t3v0142 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0143
display as text "[DIAG 0143] t3v0143 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0144
display as text "[DIAG 0144] t3v0144 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0145
display as text "[DIAG 0145] t3v0145 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0146
display as text "[DIAG 0146] t3v0146 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0147
display as text "[DIAG 0147] t3v0147 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0148
display as text "[DIAG 0148] t3v0148 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0149
display as text "[DIAG 0149] t3v0149 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0150
display as text "[DIAG 0150] t3v0150 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0151
display as text "[DIAG 0151] t3v0151 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0152
display as text "[DIAG 0152] t3v0152 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0153
display as text "[DIAG 0153] t3v0153 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0154
display as text "[DIAG 0154] t3v0154 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0155
display as text "[DIAG 0155] t3v0155 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0156
display as text "[DIAG 0156] t3v0156 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0157
display as text "[DIAG 0157] t3v0157 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0158
display as text "[DIAG 0158] t3v0158 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0159
display as text "[DIAG 0159] t3v0159 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0160
display as text "[DIAG 0160] t3v0160 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0161
display as text "[DIAG 0161] t3v0161 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0162
display as text "[DIAG 0162] t3v0162 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0163
display as text "[DIAG 0163] t3v0163 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0164
display as text "[DIAG 0164] t3v0164 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0165
display as text "[DIAG 0165] t3v0165 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0166
display as text "[DIAG 0166] t3v0166 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0167
display as text "[DIAG 0167] t3v0167 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0168
display as text "[DIAG 0168] t3v0168 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0169
display as text "[DIAG 0169] t3v0169 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0170
display as text "[DIAG 0170] t3v0170 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0171
display as text "[DIAG 0171] t3v0171 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0172
display as text "[DIAG 0172] t3v0172 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0173
display as text "[DIAG 0173] t3v0173 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0174
display as text "[DIAG 0174] t3v0174 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0175
display as text "[DIAG 0175] t3v0175 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0176
display as text "[DIAG 0176] t3v0176 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0177
display as text "[DIAG 0177] t3v0177 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0178
display as text "[DIAG 0178] t3v0178 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0179
display as text "[DIAG 0179] t3v0179 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0180
display as text "[DIAG 0180] t3v0180 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0181
display as text "[DIAG 0181] t3v0181 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0182
display as text "[DIAG 0182] t3v0182 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0183
display as text "[DIAG 0183] t3v0183 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0184
display as text "[DIAG 0184] t3v0184 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0185
display as text "[DIAG 0185] t3v0185 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0186
display as text "[DIAG 0186] t3v0186 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0187
display as text "[DIAG 0187] t3v0187 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0188
display as text "[DIAG 0188] t3v0188 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0189
display as text "[DIAG 0189] t3v0189 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0190
display as text "[DIAG 0190] t3v0190 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0191
display as text "[DIAG 0191] t3v0191 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0192
display as text "[DIAG 0192] t3v0192 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0193
display as text "[DIAG 0193] t3v0193 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0194
display as text "[DIAG 0194] t3v0194 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0195
display as text "[DIAG 0195] t3v0195 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0196
display as text "[DIAG 0196] t3v0196 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0197
display as text "[DIAG 0197] t3v0197 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0198
display as text "[DIAG 0198] t3v0198 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0199
display as text "[DIAG 0199] t3v0199 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0200
display as text "[DIAG 0200] t3v0200 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0201
display as text "[DIAG 0201] t3v0201 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0202
display as text "[DIAG 0202] t3v0202 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0203
display as text "[DIAG 0203] t3v0203 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0204
display as text "[DIAG 0204] t3v0204 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0205
display as text "[DIAG 0205] t3v0205 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0206
display as text "[DIAG 0206] t3v0206 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0207
display as text "[DIAG 0207] t3v0207 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0208
display as text "[DIAG 0208] t3v0208 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0209
display as text "[DIAG 0209] t3v0209 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0210
display as text "[DIAG 0210] t3v0210 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0211
display as text "[DIAG 0211] t3v0211 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0212
display as text "[DIAG 0212] t3v0212 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0213
display as text "[DIAG 0213] t3v0213 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0214
display as text "[DIAG 0214] t3v0214 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0215
display as text "[DIAG 0215] t3v0215 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0216
display as text "[DIAG 0216] t3v0216 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0217
display as text "[DIAG 0217] t3v0217 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0218
display as text "[DIAG 0218] t3v0218 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0219
display as text "[DIAG 0219] t3v0219 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0220
display as text "[DIAG 0220] t3v0220 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0221
display as text "[DIAG 0221] t3v0221 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0222
display as text "[DIAG 0222] t3v0222 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0223
display as text "[DIAG 0223] t3v0223 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0224
display as text "[DIAG 0224] t3v0224 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0225
display as text "[DIAG 0225] t3v0225 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0226
display as text "[DIAG 0226] t3v0226 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0227
display as text "[DIAG 0227] t3v0227 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0228
display as text "[DIAG 0228] t3v0228 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0229
display as text "[DIAG 0229] t3v0229 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0230
display as text "[DIAG 0230] t3v0230 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0231
display as text "[DIAG 0231] t3v0231 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0232
display as text "[DIAG 0232] t3v0232 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0233
display as text "[DIAG 0233] t3v0233 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0234
display as text "[DIAG 0234] t3v0234 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0235
display as text "[DIAG 0235] t3v0235 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0236
display as text "[DIAG 0236] t3v0236 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0237
display as text "[DIAG 0237] t3v0237 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0238
display as text "[DIAG 0238] t3v0238 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0239
display as text "[DIAG 0239] t3v0239 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0240
display as text "[DIAG 0240] t3v0240 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0241
display as text "[DIAG 0241] t3v0241 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0242
display as text "[DIAG 0242] t3v0242 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0243
display as text "[DIAG 0243] t3v0243 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0244
display as text "[DIAG 0244] t3v0244 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0245
display as text "[DIAG 0245] t3v0245 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0246
display as text "[DIAG 0246] t3v0246 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0247
display as text "[DIAG 0247] t3v0247 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0248
display as text "[DIAG 0248] t3v0248 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0249
display as text "[DIAG 0249] t3v0249 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0250
display as text "[DIAG 0250] t3v0250 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0251
display as text "[DIAG 0251] t3v0251 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0252
display as text "[DIAG 0252] t3v0252 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0253
display as text "[DIAG 0253] t3v0253 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0254
display as text "[DIAG 0254] t3v0254 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0255
display as text "[DIAG 0255] t3v0255 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0256
display as text "[DIAG 0256] t3v0256 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0257
display as text "[DIAG 0257] t3v0257 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0258
display as text "[DIAG 0258] t3v0258 N=" r(N) " mean=" %9.4f r(mean)
quietly summarize t3v0259
display as text "[DIAG 0259] t3v0259 N=" r(N) " mean=" %9.4f r(mean)
display as result "<<< DONE Section 6: diagnostics and table output"
// #endregion ===== Section 6: diagnostics and table output =====


// #region ===== Section 7: document-output mixed graph block =====
display as text ">>> START Section 7: document-output mixed graph block"
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T3 hist Graph 001: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t3 graph stress 001") name(t3doc01, replace)
graph export "$figdir3/t3doc01.png", name(t3doc01) replace width(1600)
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T3 bar Graph 002: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t3 graph stress 002") name(t3doc02, replace)
graph export "$figdir3/t3doc02.png", name(t3doc02) replace width(1600)
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T3 line Graph 003: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t3 graph stress 003") name(t3doc03, replace)
graph export "$figdir3/t3doc03.png", name(t3doc03) replace width(1600)
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T3 qfit Graph 004: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t3 graph stress 004") name(t3doc04, replace)
graph export "$figdir3/t3doc04.png", name(t3doc04) replace width(1600)
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T3 scatter Graph 005: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t3 graph stress 005") name(t3doc05, replace)
graph export "$figdir3/t3doc05.png", name(t3doc05) replace width(1600)
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T3 hist Graph 006: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t3 graph stress 006") name(t3doc06, replace)
graph export "$figdir3/t3doc06.png", name(t3doc06) replace width(1600)
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T3 bar Graph 007: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t3 graph stress 007") name(t3doc07, replace)
graph export "$figdir3/t3doc07.png", name(t3doc07) replace width(1600)
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T3 line Graph 008: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t3 graph stress 008") name(t3doc08, replace)
graph export "$figdir3/t3doc08.png", name(t3doc08) replace width(1600)
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T3 qfit Graph 009: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t3 graph stress 009") name(t3doc09, replace)
graph export "$figdir3/t3doc09.png", name(t3doc09) replace width(1600)
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T3 scatter Graph 010: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t3 graph stress 010") name(t3doc10, replace)
graph export "$figdir3/t3doc10.png", name(t3doc10) replace width(1600)
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T3 hist Graph 011: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t3 graph stress 011") name(t3doc11, replace)
graph export "$figdir3/t3doc11.png", name(t3doc11) replace width(1600)
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T3 bar Graph 012: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t3 graph stress 012") name(t3doc12, replace)
graph export "$figdir3/t3doc12.png", name(t3doc12) replace width(1600)
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T3 line Graph 013: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t3 graph stress 013") name(t3doc13, replace)
graph export "$figdir3/t3doc13.png", name(t3doc13) replace width(1600)
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T3 qfit Graph 014: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t3 graph stress 014") name(t3doc14, replace)
graph export "$figdir3/t3doc14.png", name(t3doc14) replace width(1600)
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T3 scatter Graph 015: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t3 graph stress 015") name(t3doc15, replace)
graph export "$figdir3/t3doc15.png", name(t3doc15) replace width(1600)
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T3 hist Graph 016: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t3 graph stress 016") name(t3doc16, replace)
graph export "$figdir3/t3doc16.png", name(t3doc16) replace width(1600)
putdocx clear
putdocx begin
putdocx paragraph, style(Title)
putdocx text ("taught_task3: putdocx graph/document stress")
putdocx paragraph
putdocx text ("This document verifies that graph exports, named graph activation, and document completion all survive Workbench routing.")
putdocx paragraph
putdocx text ("Figure 1: t3doc01")
putdocx image "$figdir3/t3doc01.png", width(4)
putdocx paragraph
putdocx text ("Figure 2: t3doc02")
putdocx image "$figdir3/t3doc02.png", width(4)
putdocx paragraph
putdocx text ("Figure 3: t3doc03")
putdocx image "$figdir3/t3doc03.png", width(4)
putdocx paragraph
putdocx text ("Figure 4: t3doc04")
putdocx image "$figdir3/t3doc04.png", width(4)
putdocx paragraph
putdocx text ("Figure 5: t3doc05")
putdocx image "$figdir3/t3doc05.png", width(4)
putdocx paragraph
putdocx text ("Figure 6: t3doc06")
putdocx image "$figdir3/t3doc06.png", width(4)
putdocx paragraph
putdocx text ("Figure 7: t3doc07")
putdocx image "$figdir3/t3doc07.png", width(4)
putdocx paragraph
putdocx text ("Figure 8: t3doc08")
putdocx image "$figdir3/t3doc08.png", width(4)
putdocx paragraph
putdocx text ("Figure 9: t3doc09")
putdocx image "$figdir3/t3doc09.png", width(4)
putdocx paragraph
putdocx text ("Figure 10: t3doc10")
putdocx image "$figdir3/t3doc10.png", width(4)
putdocx paragraph
putdocx text ("Figure 11: t3doc11")
putdocx image "$figdir3/t3doc11.png", width(4)
putdocx paragraph
putdocx text ("Figure 12: t3doc12")
putdocx image "$figdir3/t3doc12.png", width(4)
putdocx save "$docdir/taught_task3_report.docx", replace
capture which p_tdocx
if _rc == 0 {
    p_tdocx clear
    p_tdocx begin
    p_tdocx paragraph, style(Title)
    p_tdocx text ("taught_task3: p_tdocx compatibility path")
    p_tdocx paragraph
    p_tdocx text ("p_tdocx is intentionally treated like document-output code.")
    p_tdocx save "$docdir/taught_task3_ptdocx.docx", replace
}
display as result "<<< DONE Section 7: document-output mixed graph block"
// #endregion ===== Section 7: document-output mixed graph block =====


// #region ===== Section 8: model marathon =====
display as text ">>> START Section 8: model marathon"
estimates clear
quietly regress mpg weight length t3v0004, robust
estimates store t3m01
quietly logit foreign price mpg weight t3v0007
estimates store t3m02
quietly regress price c.mpg##c.weight t3v0010, robust
estimates store t3m03
quietly regress price mpg weight t3v0013 t3v0029, robust
estimates store t3m04
quietly regress mpg weight length t3v0016, robust
estimates store t3m05
quietly logit foreign price mpg weight t3v0019
estimates store t3m06
quietly regress price c.mpg##c.weight t3v0022, robust
estimates store t3m07
quietly regress price mpg weight t3v0025 t3v0057, robust
estimates store t3m08
quietly regress mpg weight length t3v0028, robust
estimates store t3m09
quietly logit foreign price mpg weight t3v0031
estimates store t3m10
quietly regress price c.mpg##c.weight t3v0034, robust
estimates store t3m11
quietly regress price mpg weight t3v0037 t3v0085, robust
estimates store t3m12
quietly regress mpg weight length t3v0040, robust
estimates store t3m13
quietly logit foreign price mpg weight t3v0043
estimates store t3m14
quietly regress price c.mpg##c.weight t3v0046, robust
estimates store t3m15
quietly regress price mpg weight t3v0049 t3v0113, robust
estimates store t3m16
quietly regress mpg weight length t3v0052, robust
estimates store t3m17
quietly logit foreign price mpg weight t3v0055
estimates store t3m18
quietly regress price c.mpg##c.weight t3v0058, robust
estimates store t3m19
quietly regress price mpg weight t3v0061 t3v0141, robust
estimates store t3m20
quietly regress mpg weight length t3v0064, robust
estimates store t3m21
quietly logit foreign price mpg weight t3v0067
estimates store t3m22
quietly regress price c.mpg##c.weight t3v0070, robust
estimates store t3m23
quietly regress price mpg weight t3v0073 t3v0169, robust
estimates store t3m24
quietly regress mpg weight length t3v0076, robust
estimates store t3m25
display as result "[MODEL] 0025 models estimated; last N=" e(N)
quietly logit foreign price mpg weight t3v0079
estimates store t3m26
quietly regress price c.mpg##c.weight t3v0082, robust
estimates store t3m27
quietly regress price mpg weight t3v0085 t3v0197, robust
estimates store t3m28
quietly regress mpg weight length t3v0088, robust
estimates store t3m29
quietly logit foreign price mpg weight t3v0091
estimates store t3m30
quietly regress price c.mpg##c.weight t3v0094, robust
quietly regress price mpg weight t3v0097 t3v0225, robust
quietly regress mpg weight length t3v0100, robust
quietly logit foreign price mpg weight t3v0103
quietly regress price c.mpg##c.weight t3v0106, robust
quietly regress price mpg weight t3v0109 t3v0253, robust
quietly regress mpg weight length t3v0112, robust
quietly logit foreign price mpg weight t3v0115
quietly regress price c.mpg##c.weight t3v0118, robust
quietly regress price mpg weight t3v0121 t3v0281, robust
quietly regress mpg weight length t3v0124, robust
quietly logit foreign price mpg weight t3v0127
quietly regress price c.mpg##c.weight t3v0130, robust
quietly regress price mpg weight t3v0133 t3v0309, robust
quietly regress mpg weight length t3v0136, robust
quietly logit foreign price mpg weight t3v0139
quietly regress price c.mpg##c.weight t3v0142, robust
quietly regress price mpg weight t3v0145 t3v0337, robust
quietly regress mpg weight length t3v0148, robust
quietly logit foreign price mpg weight t3v0151
display as result "[MODEL] 0050 models estimated; last N=" e(N)
quietly regress price c.mpg##c.weight t3v0154, robust
quietly regress price mpg weight t3v0157 t3v0365, robust
quietly regress mpg weight length t3v0160, robust
quietly logit foreign price mpg weight t3v0163
quietly regress price c.mpg##c.weight t3v0166, robust
quietly regress price mpg weight t3v0169 t3v0393, robust
quietly regress mpg weight length t3v0172, robust
quietly logit foreign price mpg weight t3v0175
quietly regress price c.mpg##c.weight t3v0178, robust
quietly regress price mpg weight t3v0181 t3v0421, robust
quietly regress mpg weight length t3v0184, robust
quietly logit foreign price mpg weight t3v0187
quietly regress price c.mpg##c.weight t3v0190, robust
quietly regress price mpg weight t3v0193 t3v0449, robust
quietly regress mpg weight length t3v0196, robust
quietly logit foreign price mpg weight t3v0199
quietly regress price c.mpg##c.weight t3v0202, robust
quietly regress price mpg weight t3v0205 t3v0477, robust
quietly regress mpg weight length t3v0208, robust
quietly logit foreign price mpg weight t3v0211
quietly regress price c.mpg##c.weight t3v0214, robust
quietly regress price mpg weight t3v0217 t3v0505, robust
quietly regress mpg weight length t3v0220, robust
quietly logit foreign price mpg weight t3v0223
quietly regress price c.mpg##c.weight t3v0226, robust
display as result "[MODEL] 0075 models estimated; last N=" e(N)
quietly regress price mpg weight t3v0229 t3v0533, robust
quietly regress mpg weight length t3v0232, robust
quietly logit foreign price mpg weight t3v0235
quietly regress price c.mpg##c.weight t3v0238, robust
quietly regress price mpg weight t3v0241 t3v0561, robust
quietly regress mpg weight length t3v0244, robust
quietly logit foreign price mpg weight t3v0247
quietly regress price c.mpg##c.weight t3v0250, robust
quietly regress price mpg weight t3v0253 t3v0589, robust
quietly regress mpg weight length t3v0256, robust
quietly logit foreign price mpg weight t3v0259
quietly regress price c.mpg##c.weight t3v0262, robust
quietly regress price mpg weight t3v0265 t3v0617, robust
quietly regress mpg weight length t3v0268, robust
quietly logit foreign price mpg weight t3v0271
quietly regress price c.mpg##c.weight t3v0274, robust
quietly regress price mpg weight t3v0277 t3v0645, robust
quietly regress mpg weight length t3v0280, robust
quietly logit foreign price mpg weight t3v0283
quietly regress price c.mpg##c.weight t3v0286, robust
quietly regress price mpg weight t3v0289 t3v0673, robust
quietly regress mpg weight length t3v0292, robust
quietly logit foreign price mpg weight t3v0295
quietly regress price c.mpg##c.weight t3v0298, robust
quietly regress price mpg weight t3v0301 t3v0701, robust
display as result "[MODEL] 0100 models estimated; last N=" e(N)
quietly regress mpg weight length t3v0304, robust
quietly logit foreign price mpg weight t3v0307
quietly regress price c.mpg##c.weight t3v0310, robust
quietly regress price mpg weight t3v0313 t3v0009, robust
quietly regress mpg weight length t3v0316, robust
quietly logit foreign price mpg weight t3v0319
quietly regress price c.mpg##c.weight t3v0322, robust
quietly regress price mpg weight t3v0325 t3v0037, robust
quietly regress mpg weight length t3v0328, robust
quietly logit foreign price mpg weight t3v0331
quietly regress price c.mpg##c.weight t3v0334, robust
quietly regress price mpg weight t3v0337 t3v0065, robust
quietly regress mpg weight length t3v0340, robust
quietly logit foreign price mpg weight t3v0343
quietly regress price c.mpg##c.weight t3v0346, robust
quietly regress price mpg weight t3v0349 t3v0093, robust
quietly regress mpg weight length t3v0352, robust
quietly logit foreign price mpg weight t3v0355
quietly regress price c.mpg##c.weight t3v0358, robust
quietly regress price mpg weight t3v0361 t3v0121, robust
quietly regress mpg weight length t3v0364, robust
quietly logit foreign price mpg weight t3v0367
quietly regress price c.mpg##c.weight t3v0370, robust
quietly regress price mpg weight t3v0373 t3v0149, robust
quietly regress mpg weight length t3v0376, robust
display as result "[MODEL] 0125 models estimated; last N=" e(N)
quietly logit foreign price mpg weight t3v0379
quietly regress price c.mpg##c.weight t3v0382, robust
quietly regress price mpg weight t3v0385 t3v0177, robust
quietly regress mpg weight length t3v0388, robust
quietly logit foreign price mpg weight t3v0391
quietly regress price c.mpg##c.weight t3v0394, robust
quietly regress price mpg weight t3v0397 t3v0205, robust
quietly regress mpg weight length t3v0400, robust
quietly logit foreign price mpg weight t3v0403
quietly regress price c.mpg##c.weight t3v0406, robust
quietly regress price mpg weight t3v0409 t3v0233, robust
quietly regress mpg weight length t3v0412, robust
quietly logit foreign price mpg weight t3v0415
quietly regress price c.mpg##c.weight t3v0418, robust
quietly regress price mpg weight t3v0421 t3v0261, robust
quietly regress mpg weight length t3v0424, robust
quietly logit foreign price mpg weight t3v0427
quietly regress price c.mpg##c.weight t3v0430, robust
quietly regress price mpg weight t3v0433 t3v0289, robust
quietly regress mpg weight length t3v0436, robust
quietly logit foreign price mpg weight t3v0439
quietly regress price c.mpg##c.weight t3v0442, robust
quietly regress price mpg weight t3v0445 t3v0317, robust
quietly regress mpg weight length t3v0448, robust
quietly logit foreign price mpg weight t3v0451
display as result "[MODEL] 0150 models estimated; last N=" e(N)
quietly regress price c.mpg##c.weight t3v0454, robust
quietly regress price mpg weight t3v0457 t3v0345, robust
quietly regress mpg weight length t3v0460, robust
quietly logit foreign price mpg weight t3v0463
quietly regress price c.mpg##c.weight t3v0466, robust
quietly regress price mpg weight t3v0469 t3v0373, robust
quietly regress mpg weight length t3v0472, robust
quietly logit foreign price mpg weight t3v0475
quietly regress price c.mpg##c.weight t3v0478, robust
quietly regress price mpg weight t3v0481 t3v0401, robust
quietly regress mpg weight length t3v0484, robust
quietly logit foreign price mpg weight t3v0487
quietly regress price c.mpg##c.weight t3v0490, robust
quietly regress price mpg weight t3v0493 t3v0429, robust
quietly regress mpg weight length t3v0496, robust
quietly logit foreign price mpg weight t3v0499
quietly regress price c.mpg##c.weight t3v0502, robust
quietly regress price mpg weight t3v0505 t3v0457, robust
quietly regress mpg weight length t3v0508, robust
quietly logit foreign price mpg weight t3v0511
quietly regress price c.mpg##c.weight t3v0514, robust
quietly regress price mpg weight t3v0517 t3v0485, robust
quietly regress mpg weight length t3v0520, robust
quietly logit foreign price mpg weight t3v0523
quietly regress price c.mpg##c.weight t3v0526, robust
display as result "[MODEL] 0175 models estimated; last N=" e(N)
quietly regress price mpg weight t3v0529 t3v0513, robust
quietly regress mpg weight length t3v0532, robust
quietly logit foreign price mpg weight t3v0535
quietly regress price c.mpg##c.weight t3v0538, robust
quietly regress price mpg weight t3v0541 t3v0541, robust
quietly regress mpg weight length t3v0544, robust
quietly logit foreign price mpg weight t3v0547
quietly regress price c.mpg##c.weight t3v0550, robust
quietly regress price mpg weight t3v0553 t3v0569, robust
quietly regress mpg weight length t3v0556, robust
quietly logit foreign price mpg weight t3v0559
quietly regress price c.mpg##c.weight t3v0562, robust
quietly regress price mpg weight t3v0565 t3v0597, robust
quietly regress mpg weight length t3v0568, robust
quietly logit foreign price mpg weight t3v0571
quietly regress price c.mpg##c.weight t3v0574, robust
quietly regress price mpg weight t3v0577 t3v0625, robust
quietly regress mpg weight length t3v0580, robust
quietly logit foreign price mpg weight t3v0583
quietly regress price c.mpg##c.weight t3v0586, robust
quietly regress price mpg weight t3v0589 t3v0653, robust
quietly regress mpg weight length t3v0592, robust
quietly logit foreign price mpg weight t3v0595
quietly regress price c.mpg##c.weight t3v0598, robust
quietly regress price mpg weight t3v0601 t3v0681, robust
display as result "[MODEL] 0200 models estimated; last N=" e(N)
quietly regress mpg weight length t3v0604, robust
quietly logit foreign price mpg weight t3v0607
quietly regress price c.mpg##c.weight t3v0610, robust
quietly regress price mpg weight t3v0613 t3v0709, robust
quietly regress mpg weight length t3v0616, robust
quietly logit foreign price mpg weight t3v0619
quietly regress price c.mpg##c.weight t3v0622, robust
quietly regress price mpg weight t3v0625 t3v0017, robust
quietly regress mpg weight length t3v0628, robust
quietly logit foreign price mpg weight t3v0631
quietly regress price c.mpg##c.weight t3v0634, robust
quietly regress price mpg weight t3v0637 t3v0045, robust
quietly regress mpg weight length t3v0640, robust
quietly logit foreign price mpg weight t3v0643
quietly regress price c.mpg##c.weight t3v0646, robust
quietly regress price mpg weight t3v0649 t3v0073, robust
quietly regress mpg weight length t3v0652, robust
quietly logit foreign price mpg weight t3v0655
quietly regress price c.mpg##c.weight t3v0658, robust
quietly regress price mpg weight t3v0661 t3v0101, robust
quietly regress mpg weight length t3v0664, robust
quietly logit foreign price mpg weight t3v0667
quietly regress price c.mpg##c.weight t3v0670, robust
quietly regress price mpg weight t3v0673 t3v0129, robust
quietly regress mpg weight length t3v0676, robust
display as result "[MODEL] 0225 models estimated; last N=" e(N)
quietly logit foreign price mpg weight t3v0679
quietly regress price c.mpg##c.weight t3v0682, robust
quietly regress price mpg weight t3v0685 t3v0157, robust
quietly regress mpg weight length t3v0688, robust
quietly logit foreign price mpg weight t3v0691
quietly regress price c.mpg##c.weight t3v0694, robust
quietly regress price mpg weight t3v0697 t3v0185, robust
quietly regress mpg weight length t3v0700, robust
quietly logit foreign price mpg weight t3v0703
quietly regress price c.mpg##c.weight t3v0706, robust
quietly regress price mpg weight t3v0709 t3v0213, robust
quietly regress mpg weight length t3v0712, robust
quietly logit foreign price mpg weight t3v0715
quietly regress price c.mpg##c.weight t3v0718, robust
quietly regress price mpg weight t3v0001 t3v0241, robust
quietly regress mpg weight length t3v0004, robust
quietly logit foreign price mpg weight t3v0007
quietly regress price c.mpg##c.weight t3v0010, robust
quietly regress price mpg weight t3v0013 t3v0269, robust
quietly regress mpg weight length t3v0016, robust
quietly logit foreign price mpg weight t3v0019
quietly regress price c.mpg##c.weight t3v0022, robust
quietly regress price mpg weight t3v0025 t3v0297, robust
quietly regress mpg weight length t3v0028, robust
quietly logit foreign price mpg weight t3v0031
display as result "[MODEL] 0250 models estimated; last N=" e(N)
quietly regress price c.mpg##c.weight t3v0034, robust
quietly regress price mpg weight t3v0037 t3v0325, robust
quietly regress mpg weight length t3v0040, robust
quietly logit foreign price mpg weight t3v0043
quietly regress price c.mpg##c.weight t3v0046, robust
quietly regress price mpg weight t3v0049 t3v0353, robust
quietly regress mpg weight length t3v0052, robust
quietly logit foreign price mpg weight t3v0055
quietly regress price c.mpg##c.weight t3v0058, robust
quietly regress price mpg weight t3v0061 t3v0381, robust
quietly regress mpg weight length t3v0064, robust
quietly logit foreign price mpg weight t3v0067
quietly regress price c.mpg##c.weight t3v0070, robust
quietly regress price mpg weight t3v0073 t3v0409, robust
quietly regress mpg weight length t3v0076, robust
quietly logit foreign price mpg weight t3v0079
quietly regress price c.mpg##c.weight t3v0082, robust
quietly regress price mpg weight t3v0085 t3v0437, robust
quietly regress mpg weight length t3v0088, robust
quietly logit foreign price mpg weight t3v0091
quietly regress price c.mpg##c.weight t3v0094, robust
quietly regress price mpg weight t3v0097 t3v0465, robust
quietly regress mpg weight length t3v0100, robust
quietly logit foreign price mpg weight t3v0103
quietly regress price c.mpg##c.weight t3v0106, robust
display as result "[MODEL] 0275 models estimated; last N=" e(N)
quietly regress price mpg weight t3v0109 t3v0493, robust
quietly regress mpg weight length t3v0112, robust
quietly logit foreign price mpg weight t3v0115
quietly regress price c.mpg##c.weight t3v0118, robust
quietly regress price mpg weight t3v0121 t3v0521, robust
quietly regress mpg weight length t3v0124, robust
quietly logit foreign price mpg weight t3v0127
quietly regress price c.mpg##c.weight t3v0130, robust
quietly regress price mpg weight t3v0133 t3v0549, robust
quietly regress mpg weight length t3v0136, robust
quietly logit foreign price mpg weight t3v0139
quietly regress price c.mpg##c.weight t3v0142, robust
quietly regress price mpg weight t3v0145 t3v0577, robust
quietly regress mpg weight length t3v0148, robust
quietly logit foreign price mpg weight t3v0151
quietly regress price c.mpg##c.weight t3v0154, robust
quietly regress price mpg weight t3v0157 t3v0605, robust
quietly regress mpg weight length t3v0160, robust
quietly logit foreign price mpg weight t3v0163
quietly regress price c.mpg##c.weight t3v0166, robust
quietly regress price mpg weight t3v0169 t3v0633, robust
quietly regress mpg weight length t3v0172, robust
quietly logit foreign price mpg weight t3v0175
quietly regress price c.mpg##c.weight t3v0178, robust
quietly regress price mpg weight t3v0181 t3v0661, robust
display as result "[MODEL] 0300 models estimated; last N=" e(N)
quietly regress mpg weight length t3v0184, robust
quietly logit foreign price mpg weight t3v0187
quietly regress price c.mpg##c.weight t3v0190, robust
quietly regress price mpg weight t3v0193 t3v0689, robust
quietly regress mpg weight length t3v0196, robust
quietly logit foreign price mpg weight t3v0199
quietly regress price c.mpg##c.weight t3v0202, robust
quietly regress price mpg weight t3v0205 t3v0717, robust
quietly regress mpg weight length t3v0208, robust
quietly logit foreign price mpg weight t3v0211
quietly regress price c.mpg##c.weight t3v0214, robust
quietly regress price mpg weight t3v0217 t3v0025, robust
quietly regress mpg weight length t3v0220, robust
quietly logit foreign price mpg weight t3v0223
quietly regress price c.mpg##c.weight t3v0226, robust
quietly regress price mpg weight t3v0229 t3v0053, robust
quietly regress mpg weight length t3v0232, robust
quietly logit foreign price mpg weight t3v0235
quietly regress price c.mpg##c.weight t3v0238, robust
quietly regress price mpg weight t3v0241 t3v0081, robust
quietly regress mpg weight length t3v0244, robust
quietly logit foreign price mpg weight t3v0247
quietly regress price c.mpg##c.weight t3v0250, robust
quietly regress price mpg weight t3v0253 t3v0109, robust
quietly regress mpg weight length t3v0256, robust
display as result "[MODEL] 0325 models estimated; last N=" e(N)
quietly logit foreign price mpg weight t3v0259
quietly regress price c.mpg##c.weight t3v0262, robust
quietly regress price mpg weight t3v0265 t3v0137, robust
quietly regress mpg weight length t3v0268, robust
quietly logit foreign price mpg weight t3v0271
quietly regress price c.mpg##c.weight t3v0274, robust
quietly regress price mpg weight t3v0277 t3v0165, robust
quietly regress mpg weight length t3v0280, robust
quietly logit foreign price mpg weight t3v0283
quietly regress price c.mpg##c.weight t3v0286, robust
quietly regress price mpg weight t3v0289 t3v0193, robust
quietly regress mpg weight length t3v0292, robust
quietly logit foreign price mpg weight t3v0295
quietly regress price c.mpg##c.weight t3v0298, robust
quietly regress price mpg weight t3v0301 t3v0221, robust
quietly regress mpg weight length t3v0304, robust
quietly logit foreign price mpg weight t3v0307
quietly regress price c.mpg##c.weight t3v0310, robust
quietly regress price mpg weight t3v0313 t3v0249, robust
quietly regress mpg weight length t3v0316, robust
quietly logit foreign price mpg weight t3v0319
quietly regress price c.mpg##c.weight t3v0322, robust
quietly regress price mpg weight t3v0325 t3v0277, robust
quietly regress mpg weight length t3v0328, robust
quietly logit foreign price mpg weight t3v0331
display as result "[MODEL] 0350 models estimated; last N=" e(N)
quietly regress price c.mpg##c.weight t3v0334, robust
quietly regress price mpg weight t3v0337 t3v0305, robust
quietly regress mpg weight length t3v0340, robust
quietly logit foreign price mpg weight t3v0343
quietly regress price c.mpg##c.weight t3v0346, robust
quietly regress price mpg weight t3v0349 t3v0333, robust
quietly regress mpg weight length t3v0352, robust
quietly logit foreign price mpg weight t3v0355
quietly regress price c.mpg##c.weight t3v0358, robust
quietly regress price mpg weight t3v0361 t3v0361, robust
estimates table t3m01 t3m02 t3m03 t3m04 t3m05, b(%9.3f) se stats(N r2)
display as result "<<< DONE Section 8: model marathon"
// #endregion ===== Section 8: model marathon =====


// #region ===== Section 9: preserve restore and reshape-like stress =====
display as text ">>> START Section 9: preserve restore and reshape-like stress"
preserve
keep make price mpg weight foreign group_id obs_id
tempfile slim
save `slim', replace
collapse (mean) price mpg weight, by(group_id foreign)
export delimited using "$docdir/taught_task3_collapsed.csv", replace
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
keep if group_id == 1
quietly count
display as text "[PRESERVE 0009] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0010] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0011] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0012] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0013] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0014] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0015] group count=" r(N)
restore
preserve
keep if group_id == 8
quietly count
display as text "[PRESERVE 0016] group count=" r(N)
restore
preserve
keep if group_id == 1
quietly count
display as text "[PRESERVE 0017] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0018] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0019] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0020] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0021] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0022] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0023] group count=" r(N)
restore
preserve
keep if group_id == 8
quietly count
display as text "[PRESERVE 0024] group count=" r(N)
restore
preserve
keep if group_id == 1
quietly count
display as text "[PRESERVE 0025] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0026] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0027] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0028] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0029] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0030] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0031] group count=" r(N)
restore
preserve
keep if group_id == 8
quietly count
display as text "[PRESERVE 0032] group count=" r(N)
restore
preserve
keep if group_id == 1
quietly count
display as text "[PRESERVE 0033] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0034] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0035] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0036] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0037] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0038] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0039] group count=" r(N)
restore
preserve
keep if group_id == 8
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
keep if group_id == 1
quietly count
display as text "[PRESERVE 0049] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0050] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0051] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0052] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0053] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0054] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0055] group count=" r(N)
restore
preserve
keep if group_id == 8
quietly count
display as text "[PRESERVE 0056] group count=" r(N)
restore
preserve
keep if group_id == 1
quietly count
display as text "[PRESERVE 0057] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0058] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0059] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0060] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0061] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0062] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0063] group count=" r(N)
restore
preserve
keep if group_id == 8
quietly count
display as text "[PRESERVE 0064] group count=" r(N)
restore
preserve
keep if group_id == 1
quietly count
display as text "[PRESERVE 0065] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0066] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0067] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0068] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0069] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0070] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0071] group count=" r(N)
restore
preserve
keep if group_id == 8
quietly count
display as text "[PRESERVE 0072] group count=" r(N)
restore
preserve
keep if group_id == 1
quietly count
display as text "[PRESERVE 0073] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0074] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0075] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0076] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0077] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0078] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0079] group count=" r(N)
restore
preserve
keep if group_id == 8
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
keep if group_id == 1
quietly count
display as text "[PRESERVE 0089] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0090] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0091] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0092] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0093] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0094] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0095] group count=" r(N)
restore
preserve
keep if group_id == 8
quietly count
display as text "[PRESERVE 0096] group count=" r(N)
restore
preserve
keep if group_id == 1
quietly count
display as text "[PRESERVE 0097] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0098] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0099] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0100] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0101] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0102] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0103] group count=" r(N)
restore
preserve
keep if group_id == 8
quietly count
display as text "[PRESERVE 0104] group count=" r(N)
restore
preserve
keep if group_id == 1
quietly count
display as text "[PRESERVE 0105] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0106] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0107] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0108] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0109] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0110] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0111] group count=" r(N)
restore
preserve
keep if group_id == 8
quietly count
display as text "[PRESERVE 0112] group count=" r(N)
restore
preserve
keep if group_id == 1
quietly count
display as text "[PRESERVE 0113] group count=" r(N)
restore
preserve
keep if group_id == 2
quietly count
display as text "[PRESERVE 0114] group count=" r(N)
restore
preserve
keep if group_id == 3
quietly count
display as text "[PRESERVE 0115] group count=" r(N)
restore
preserve
keep if group_id == 4
quietly count
display as text "[PRESERVE 0116] group count=" r(N)
restore
preserve
keep if group_id == 5
quietly count
display as text "[PRESERVE 0117] group count=" r(N)
restore
preserve
keep if group_id == 6
quietly count
display as text "[PRESERVE 0118] group count=" r(N)
restore
preserve
keep if group_id == 7
quietly count
display as text "[PRESERVE 0119] group count=" r(N)
restore
display as result "<<< DONE Section 9: preserve restore and reshape-like stress"
// #endregion ===== Section 9: preserve restore and reshape-like stress =====


// #region ===== Section 10: final graph regression after document output =====
display as text ">>> START Section 10: final graph regression after document output"
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T3 hist Graph 001: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t3 graph stress 001") name(t3post01, replace)
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T3 bar Graph 002: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t3 graph stress 002") name(t3post02, replace)
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T3 line Graph 003: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t3 graph stress 003") name(t3post03, replace)
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T3 qfit Graph 004: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t3 graph stress 004") name(t3post04, replace)
graph export "$figdir3/t3post04.svg", name(t3post04) replace
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T3 scatter Graph 005: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t3 graph stress 005") name(t3post05, replace)
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T3 hist Graph 006: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t3 graph stress 006") name(t3post06, replace)
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T3 bar Graph 007: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t3 graph stress 007") name(t3post07, replace)
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T3 line Graph 008: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t3 graph stress 008") name(t3post08, replace)
graph export "$figdir3/t3post08.svg", name(t3post08) replace
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T3 qfit Graph 009: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t3 graph stress 009") name(t3post09, replace)
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T3 scatter Graph 010: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t3 graph stress 010") name(t3post10, replace)
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T3 hist Graph 011: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t3 graph stress 011") name(t3post11, replace)
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T3 bar Graph 012: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t3 graph stress 012") name(t3post12, replace)
graph export "$figdir3/t3post12.svg", name(t3post12) replace
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T3 line Graph 013: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t3 graph stress 013") name(t3post13, replace)
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T3 qfit Graph 014: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t3 graph stress 014") name(t3post14, replace)
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T3 scatter Graph 015: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t3 graph stress 015") name(t3post15, replace)
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T3 hist Graph 016: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t3 graph stress 016") name(t3post16, replace)
graph export "$figdir3/t3post16.svg", name(t3post16) replace
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T3 bar Graph 017: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t3 graph stress 017") name(t3post17, replace)
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T3 line Graph 018: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t3 graph stress 018") name(t3post18, replace)
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T3 qfit Graph 019: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t3 graph stress 019") name(t3post19, replace)
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T3 scatter Graph 020: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t3 graph stress 020") name(t3post20, replace)
graph export "$figdir3/t3post20.svg", name(t3post20) replace
twoway (histogram price, freq color(eltblue%45)) ///
    (kdensity price, lcolor(red) lwidth(medium)), ///
    title("T3 hist Graph 021: Price Distribution") ///
    legend(order(1 "Histogram" 2 "Density")) ///
    note("t3 graph stress 021") name(t3post21, replace)
graph bar (mean) mpg price, over(price_quart) over(group_id) ///
    title("T3 bar Graph 022: Grouped Bar") ///
    ytitle("Mean value") ///
    note("t3 graph stress 022") name(t3post22, replace)
twoway (line price obs_id, sort lcolor(navy)) ///
    (line mpg obs_id, sort yaxis(2) lcolor(forest_green)), ///
    title("T3 line Graph 023: Dual Axis Line") ///
    ytitle("Price") ytitle("MPG", axis(2)) ///
    note("t3 graph stress 023") name(t3post23, replace)
twoway (qfit price weight, lcolor(maroon)) ///
    (scatter price weight, mcolor(gs8%30)), ///
    title("T3 qfit Graph 024: QFIT") ///
    xtitle("Weight") ytitle("Price") ///
    note("t3 graph stress 024") name(t3post24, replace)
graph export "$figdir3/t3post24.svg", name(t3post24) replace
twoway (scatter price mpg, mcolor(navy%35) msymbol(circle_hollow)) ///
    (lfit price mpg, lcolor(maroon) lwidth(medium)), ///
    title("T3 scatter Graph 025: Price vs MPG") ///
    subtitle("scatter + fitted line") ///
    xtitle("Miles per gallon") ytitle("Price") ///
    note("t3 graph stress 025") name(t3post25, replace)
display as result "<<< DONE Section 10: final graph regression after document output"
// #endregion ===== Section 10: final graph regression after document output =====


// #region ===== Section 11: trace output and low-latency sentinels =====
display as text ">>> START Section 11: trace output and low-latency sentinels"
quietly count if !missing(t3v0012)
display as text "[TRACE t3 0001] count for t3v0012 = " r(N)
quietly count if !missing(t3v0023)
display as text "[TRACE t3 0002] count for t3v0023 = " r(N)
quietly count if !missing(t3v0034)
display as text "[TRACE t3 0003] count for t3v0034 = " r(N)
quietly count if !missing(t3v0045)
display as text "[TRACE t3 0004] count for t3v0045 = " r(N)
quietly count if !missing(t3v0056)
display as text "[TRACE t3 0005] count for t3v0056 = " r(N)
quietly count if !missing(t3v0067)
display as text "[TRACE t3 0006] count for t3v0067 = " r(N)
quietly count if !missing(t3v0078)
display as text "[TRACE t3 0007] count for t3v0078 = " r(N)
quietly count if !missing(t3v0089)
display as text "[TRACE t3 0008] count for t3v0089 = " r(N)
quietly count if !missing(t3v0100)
display as text "[TRACE t3 0009] count for t3v0100 = " r(N)
quietly count if !missing(t3v0111)
display as text "[TRACE t3 0010] count for t3v0111 = " r(N)
quietly count if !missing(t3v0122)
display as text "[TRACE t3 0011] count for t3v0122 = " r(N)
quietly count if !missing(t3v0133)
display as text "[TRACE t3 0012] count for t3v0133 = " r(N)
quietly count if !missing(t3v0144)
display as text "[TRACE t3 0013] count for t3v0144 = " r(N)
quietly count if !missing(t3v0155)
display as text "[TRACE t3 0014] count for t3v0155 = " r(N)
quietly count if !missing(t3v0166)
display as text "[TRACE t3 0015] count for t3v0166 = " r(N)
quietly count if !missing(t3v0177)
display as text "[TRACE t3 0016] count for t3v0177 = " r(N)
quietly count if !missing(t3v0188)
display as text "[TRACE t3 0017] count for t3v0188 = " r(N)
quietly summarize t3v0188, detail
display as text "[TRACE-DETAIL t3 0017] p50=" %9.4f r(p50)
quietly count if !missing(t3v0199)
display as text "[TRACE t3 0018] count for t3v0199 = " r(N)
quietly count if !missing(t3v0210)
display as text "[TRACE t3 0019] count for t3v0210 = " r(N)
quietly count if !missing(t3v0221)
display as text "[TRACE t3 0020] count for t3v0221 = " r(N)
quietly count if !missing(t3v0232)
display as text "[TRACE t3 0021] count for t3v0232 = " r(N)
quietly count if !missing(t3v0243)
display as text "[TRACE t3 0022] count for t3v0243 = " r(N)
quietly count if !missing(t3v0254)
display as text "[TRACE t3 0023] count for t3v0254 = " r(N)
quietly count if !missing(t3v0265)
display as text "[TRACE t3 0024] count for t3v0265 = " r(N)
quietly count if !missing(t3v0276)
display as text "[TRACE t3 0025] count for t3v0276 = " r(N)
quietly count if !missing(t3v0287)
display as text "[TRACE t3 0026] count for t3v0287 = " r(N)
quietly count if !missing(t3v0298)
display as text "[TRACE t3 0027] count for t3v0298 = " r(N)
quietly count if !missing(t3v0309)
display as text "[TRACE t3 0028] count for t3v0309 = " r(N)
quietly count if !missing(t3v0320)
display as text "[TRACE t3 0029] count for t3v0320 = " r(N)
quietly count if !missing(t3v0331)
display as text "[TRACE t3 0030] count for t3v0331 = " r(N)
quietly count if !missing(t3v0342)
display as text "[TRACE t3 0031] count for t3v0342 = " r(N)
quietly count if !missing(t3v0353)
display as text "[TRACE t3 0032] count for t3v0353 = " r(N)
quietly count if !missing(t3v0364)
display as text "[TRACE t3 0033] count for t3v0364 = " r(N)
quietly count if !missing(t3v0375)
display as text "[TRACE t3 0034] count for t3v0375 = " r(N)
quietly summarize t3v0375, detail
display as text "[TRACE-DETAIL t3 0034] p50=" %9.4f r(p50)
quietly count if !missing(t3v0386)
display as text "[TRACE t3 0035] count for t3v0386 = " r(N)
quietly count if !missing(t3v0397)
display as text "[TRACE t3 0036] count for t3v0397 = " r(N)
quietly count if !missing(t3v0408)
display as text "[TRACE t3 0037] count for t3v0408 = " r(N)
quietly count if !missing(t3v0419)
display as text "[TRACE t3 0038] count for t3v0419 = " r(N)
quietly count if !missing(t3v0430)
display as text "[TRACE t3 0039] count for t3v0430 = " r(N)
quietly count if !missing(t3v0441)
display as text "[TRACE t3 0040] count for t3v0441 = " r(N)
quietly count if !missing(t3v0452)
display as text "[TRACE t3 0041] count for t3v0452 = " r(N)
quietly count if !missing(t3v0463)
display as text "[TRACE t3 0042] count for t3v0463 = " r(N)
quietly count if !missing(t3v0474)
display as text "[TRACE t3 0043] count for t3v0474 = " r(N)
quietly count if !missing(t3v0485)
display as text "[TRACE t3 0044] count for t3v0485 = " r(N)
quietly count if !missing(t3v0496)
display as text "[TRACE t3 0045] count for t3v0496 = " r(N)
quietly count if !missing(t3v0507)
display as text "[TRACE t3 0046] count for t3v0507 = " r(N)
quietly count if !missing(t3v0518)
display as text "[TRACE t3 0047] count for t3v0518 = " r(N)
quietly count if !missing(t3v0529)
display as text "[TRACE t3 0048] count for t3v0529 = " r(N)
quietly count if !missing(t3v0540)
display as text "[TRACE t3 0049] count for t3v0540 = " r(N)
quietly count if !missing(t3v0551)
display as text "[TRACE t3 0050] count for t3v0551 = " r(N)
quietly count if !missing(t3v0562)
display as text "[TRACE t3 0051] count for t3v0562 = " r(N)
quietly summarize t3v0562, detail
display as text "[TRACE-DETAIL t3 0051] p50=" %9.4f r(p50)
quietly count if !missing(t3v0573)
display as text "[TRACE t3 0052] count for t3v0573 = " r(N)
quietly count if !missing(t3v0584)
display as text "[TRACE t3 0053] count for t3v0584 = " r(N)
quietly count if !missing(t3v0595)
display as text "[TRACE t3 0054] count for t3v0595 = " r(N)
quietly count if !missing(t3v0606)
display as text "[TRACE t3 0055] count for t3v0606 = " r(N)
quietly count if !missing(t3v0617)
display as text "[TRACE t3 0056] count for t3v0617 = " r(N)
quietly count if !missing(t3v0628)
display as text "[TRACE t3 0057] count for t3v0628 = " r(N)
quietly count if !missing(t3v0639)
display as text "[TRACE t3 0058] count for t3v0639 = " r(N)
quietly count if !missing(t3v0650)
display as text "[TRACE t3 0059] count for t3v0650 = " r(N)
quietly count if !missing(t3v0661)
display as text "[TRACE t3 0060] count for t3v0661 = " r(N)
quietly count if !missing(t3v0672)
display as text "[TRACE t3 0061] count for t3v0672 = " r(N)
quietly count if !missing(t3v0683)
display as text "[TRACE t3 0062] count for t3v0683 = " r(N)
quietly count if !missing(t3v0694)
display as text "[TRACE t3 0063] count for t3v0694 = " r(N)
quietly count if !missing(t3v0705)
display as text "[TRACE t3 0064] count for t3v0705 = " r(N)
quietly count if !missing(t3v0716)
display as text "[TRACE t3 0065] count for t3v0716 = " r(N)
quietly count if !missing(t3v0007)
display as text "[TRACE t3 0066] count for t3v0007 = " r(N)
quietly count if !missing(t3v0018)
display as text "[TRACE t3 0067] count for t3v0018 = " r(N)
quietly count if !missing(t3v0029)
display as text "[TRACE t3 0068] count for t3v0029 = " r(N)
quietly summarize t3v0029, detail
display as text "[TRACE-DETAIL t3 0068] p50=" %9.4f r(p50)
quietly count if !missing(t3v0040)
display as text "[TRACE t3 0069] count for t3v0040 = " r(N)
quietly count if !missing(t3v0051)
display as text "[TRACE t3 0070] count for t3v0051 = " r(N)
quietly count if !missing(t3v0062)
display as text "[TRACE t3 0071] count for t3v0062 = " r(N)
quietly count if !missing(t3v0073)
display as text "[TRACE t3 0072] count for t3v0073 = " r(N)
quietly count if !missing(t3v0084)
display as text "[TRACE t3 0073] count for t3v0084 = " r(N)
quietly count if !missing(t3v0095)
display as text "[TRACE t3 0074] count for t3v0095 = " r(N)
quietly count if !missing(t3v0106)
display as text "[TRACE t3 0075] count for t3v0106 = " r(N)
quietly count if !missing(t3v0117)
display as text "[TRACE t3 0076] count for t3v0117 = " r(N)
quietly count if !missing(t3v0128)
display as text "[TRACE t3 0077] count for t3v0128 = " r(N)
quietly count if !missing(t3v0139)
display as text "[TRACE t3 0078] count for t3v0139 = " r(N)
quietly count if !missing(t3v0150)
display as text "[TRACE t3 0079] count for t3v0150 = " r(N)
quietly count if !missing(t3v0161)
display as text "[TRACE t3 0080] count for t3v0161 = " r(N)
quietly count if !missing(t3v0172)
display as text "[TRACE t3 0081] count for t3v0172 = " r(N)
quietly count if !missing(t3v0183)
display as text "[TRACE t3 0082] count for t3v0183 = " r(N)
quietly count if !missing(t3v0194)
display as text "[TRACE t3 0083] count for t3v0194 = " r(N)
quietly count if !missing(t3v0205)
display as text "[TRACE t3 0084] count for t3v0205 = " r(N)
quietly count if !missing(t3v0216)
display as text "[TRACE t3 0085] count for t3v0216 = " r(N)
quietly summarize t3v0216, detail
display as text "[TRACE-DETAIL t3 0085] p50=" %9.4f r(p50)
quietly count if !missing(t3v0227)
display as text "[TRACE t3 0086] count for t3v0227 = " r(N)
quietly count if !missing(t3v0238)
display as text "[TRACE t3 0087] count for t3v0238 = " r(N)
quietly count if !missing(t3v0249)
display as text "[TRACE t3 0088] count for t3v0249 = " r(N)
quietly count if !missing(t3v0260)
display as text "[TRACE t3 0089] count for t3v0260 = " r(N)
quietly count if !missing(t3v0271)
display as text "[TRACE t3 0090] count for t3v0271 = " r(N)
quietly count if !missing(t3v0282)
display as text "[TRACE t3 0091] count for t3v0282 = " r(N)
quietly count if !missing(t3v0293)
display as text "[TRACE t3 0092] count for t3v0293 = " r(N)
quietly count if !missing(t3v0304)
display as text "[TRACE t3 0093] count for t3v0304 = " r(N)
quietly count if !missing(t3v0315)
display as text "[TRACE t3 0094] count for t3v0315 = " r(N)
quietly count if !missing(t3v0326)
display as text "[TRACE t3 0095] count for t3v0326 = " r(N)
quietly count if !missing(t3v0337)
display as text "[TRACE t3 0096] count for t3v0337 = " r(N)
quietly count if !missing(t3v0348)
display as text "[TRACE t3 0097] count for t3v0348 = " r(N)
quietly count if !missing(t3v0359)
display as text "[TRACE t3 0098] count for t3v0359 = " r(N)
quietly count if !missing(t3v0370)
display as text "[TRACE t3 0099] count for t3v0370 = " r(N)
quietly count if !missing(t3v0381)
display as text "[TRACE t3 0100] count for t3v0381 = " r(N)
quietly count if !missing(t3v0392)
display as text "[TRACE t3 0101] count for t3v0392 = " r(N)
quietly count if !missing(t3v0403)
display as text "[TRACE t3 0102] count for t3v0403 = " r(N)
quietly summarize t3v0403, detail
display as text "[TRACE-DETAIL t3 0102] p50=" %9.4f r(p50)
quietly count if !missing(t3v0414)
display as text "[TRACE t3 0103] count for t3v0414 = " r(N)
quietly count if !missing(t3v0425)
display as text "[TRACE t3 0104] count for t3v0425 = " r(N)
quietly count if !missing(t3v0436)
display as text "[TRACE t3 0105] count for t3v0436 = " r(N)
quietly count if !missing(t3v0447)
display as text "[TRACE t3 0106] count for t3v0447 = " r(N)
quietly count if !missing(t3v0458)
display as text "[TRACE t3 0107] count for t3v0458 = " r(N)
quietly count if !missing(t3v0469)
display as text "[TRACE t3 0108] count for t3v0469 = " r(N)
quietly count if !missing(t3v0480)
display as text "[TRACE t3 0109] count for t3v0480 = " r(N)
quietly count if !missing(t3v0491)
display as text "[TRACE t3 0110] count for t3v0491 = " r(N)
quietly count if !missing(t3v0502)
display as text "[TRACE t3 0111] count for t3v0502 = " r(N)
quietly count if !missing(t3v0513)
display as text "[TRACE t3 0112] count for t3v0513 = " r(N)
quietly count if !missing(t3v0524)
display as text "[TRACE t3 0113] count for t3v0524 = " r(N)
quietly count if !missing(t3v0535)
display as text "[TRACE t3 0114] count for t3v0535 = " r(N)
quietly count if !missing(t3v0546)
display as text "[TRACE t3 0115] count for t3v0546 = " r(N)
quietly count if !missing(t3v0557)
display as text "[TRACE t3 0116] count for t3v0557 = " r(N)
quietly count if !missing(t3v0568)
display as text "[TRACE t3 0117] count for t3v0568 = " r(N)
quietly count if !missing(t3v0579)
display as text "[TRACE t3 0118] count for t3v0579 = " r(N)
quietly count if !missing(t3v0590)
display as text "[TRACE t3 0119] count for t3v0590 = " r(N)
quietly summarize t3v0590, detail
display as text "[TRACE-DETAIL t3 0119] p50=" %9.4f r(p50)
quietly count if !missing(t3v0601)
display as text "[TRACE t3 0120] count for t3v0601 = " r(N)
quietly count if !missing(t3v0612)
display as text "[TRACE t3 0121] count for t3v0612 = " r(N)
quietly count if !missing(t3v0623)
display as text "[TRACE t3 0122] count for t3v0623 = " r(N)
quietly count if !missing(t3v0634)
display as text "[TRACE t3 0123] count for t3v0634 = " r(N)
quietly count if !missing(t3v0645)
display as text "[TRACE t3 0124] count for t3v0645 = " r(N)
quietly count if !missing(t3v0656)
display as text "[TRACE t3 0125] count for t3v0656 = " r(N)
quietly count if !missing(t3v0667)
display as text "[TRACE t3 0126] count for t3v0667 = " r(N)
quietly count if !missing(t3v0678)
display as text "[TRACE t3 0127] count for t3v0678 = " r(N)
quietly count if !missing(t3v0689)
display as text "[TRACE t3 0128] count for t3v0689 = " r(N)
quietly count if !missing(t3v0700)
display as text "[TRACE t3 0129] count for t3v0700 = " r(N)
quietly count if !missing(t3v0711)
display as text "[TRACE t3 0130] count for t3v0711 = " r(N)
quietly count if !missing(t3v0002)
display as text "[TRACE t3 0131] count for t3v0002 = " r(N)
quietly count if !missing(t3v0013)
display as text "[TRACE t3 0132] count for t3v0013 = " r(N)
quietly count if !missing(t3v0024)
display as text "[TRACE t3 0133] count for t3v0024 = " r(N)
quietly count if !missing(t3v0035)
display as text "[TRACE t3 0134] count for t3v0035 = " r(N)
quietly count if !missing(t3v0046)
display as text "[TRACE t3 0135] count for t3v0046 = " r(N)
quietly count if !missing(t3v0057)
display as text "[TRACE t3 0136] count for t3v0057 = " r(N)
quietly summarize t3v0057, detail
display as text "[TRACE-DETAIL t3 0136] p50=" %9.4f r(p50)
quietly count if !missing(t3v0068)
display as text "[TRACE t3 0137] count for t3v0068 = " r(N)
quietly count if !missing(t3v0079)
display as text "[TRACE t3 0138] count for t3v0079 = " r(N)
quietly count if !missing(t3v0090)
display as text "[TRACE t3 0139] count for t3v0090 = " r(N)
quietly count if !missing(t3v0101)
display as text "[TRACE t3 0140] count for t3v0101 = " r(N)
quietly count if !missing(t3v0112)
display as text "[TRACE t3 0141] count for t3v0112 = " r(N)
quietly count if !missing(t3v0123)
display as text "[TRACE t3 0142] count for t3v0123 = " r(N)
quietly count if !missing(t3v0134)
display as text "[TRACE t3 0143] count for t3v0134 = " r(N)
quietly count if !missing(t3v0145)
display as text "[TRACE t3 0144] count for t3v0145 = " r(N)
quietly count if !missing(t3v0156)
display as text "[TRACE t3 0145] count for t3v0156 = " r(N)
quietly count if !missing(t3v0167)
display as text "[TRACE t3 0146] count for t3v0167 = " r(N)
quietly count if !missing(t3v0178)
display as text "[TRACE t3 0147] count for t3v0178 = " r(N)
quietly count if !missing(t3v0189)
display as text "[TRACE t3 0148] count for t3v0189 = " r(N)
quietly count if !missing(t3v0200)
display as text "[TRACE t3 0149] count for t3v0200 = " r(N)
quietly count if !missing(t3v0211)
display as text "[TRACE t3 0150] count for t3v0211 = " r(N)
quietly count if !missing(t3v0222)
display as text "[TRACE t3 0151] count for t3v0222 = " r(N)
quietly count if !missing(t3v0233)
display as text "[TRACE t3 0152] count for t3v0233 = " r(N)
quietly count if !missing(t3v0244)
display as text "[TRACE t3 0153] count for t3v0244 = " r(N)
quietly summarize t3v0244, detail
display as text "[TRACE-DETAIL t3 0153] p50=" %9.4f r(p50)
quietly count if !missing(t3v0255)
display as text "[TRACE t3 0154] count for t3v0255 = " r(N)
quietly count if !missing(t3v0266)
display as text "[TRACE t3 0155] count for t3v0266 = " r(N)
quietly count if !missing(t3v0277)
display as text "[TRACE t3 0156] count for t3v0277 = " r(N)
quietly count if !missing(t3v0288)
display as text "[TRACE t3 0157] count for t3v0288 = " r(N)
quietly count if !missing(t3v0299)
display as text "[TRACE t3 0158] count for t3v0299 = " r(N)
quietly count if !missing(t3v0310)
display as text "[TRACE t3 0159] count for t3v0310 = " r(N)
quietly count if !missing(t3v0321)
display as text "[TRACE t3 0160] count for t3v0321 = " r(N)
quietly count if !missing(t3v0332)
display as text "[TRACE t3 0161] count for t3v0332 = " r(N)
quietly count if !missing(t3v0343)
display as text "[TRACE t3 0162] count for t3v0343 = " r(N)
quietly count if !missing(t3v0354)
display as text "[TRACE t3 0163] count for t3v0354 = " r(N)
quietly count if !missing(t3v0365)
display as text "[TRACE t3 0164] count for t3v0365 = " r(N)
quietly count if !missing(t3v0376)
display as text "[TRACE t3 0165] count for t3v0376 = " r(N)
quietly count if !missing(t3v0387)
display as text "[TRACE t3 0166] count for t3v0387 = " r(N)
quietly count if !missing(t3v0398)
display as text "[TRACE t3 0167] count for t3v0398 = " r(N)
quietly count if !missing(t3v0409)
display as text "[TRACE t3 0168] count for t3v0409 = " r(N)
quietly count if !missing(t3v0420)
display as text "[TRACE t3 0169] count for t3v0420 = " r(N)
quietly count if !missing(t3v0431)
display as text "[TRACE t3 0170] count for t3v0431 = " r(N)
quietly summarize t3v0431, detail
display as text "[TRACE-DETAIL t3 0170] p50=" %9.4f r(p50)
quietly count if !missing(t3v0442)
display as text "[TRACE t3 0171] count for t3v0442 = " r(N)
quietly count if !missing(t3v0453)
display as text "[TRACE t3 0172] count for t3v0453 = " r(N)
quietly count if !missing(t3v0464)
display as text "[TRACE t3 0173] count for t3v0464 = " r(N)
quietly count if !missing(t3v0475)
display as text "[TRACE t3 0174] count for t3v0475 = " r(N)
quietly count if !missing(t3v0486)
display as text "[TRACE t3 0175] count for t3v0486 = " r(N)
quietly count if !missing(t3v0497)
display as text "[TRACE t3 0176] count for t3v0497 = " r(N)
quietly count if !missing(t3v0508)
display as text "[TRACE t3 0177] count for t3v0508 = " r(N)
quietly count if !missing(t3v0519)
display as text "[TRACE t3 0178] count for t3v0519 = " r(N)
quietly count if !missing(t3v0530)
display as text "[TRACE t3 0179] count for t3v0530 = " r(N)
quietly count if !missing(t3v0541)
display as text "[TRACE t3 0180] count for t3v0541 = " r(N)
quietly count if !missing(t3v0552)
display as text "[TRACE t3 0181] count for t3v0552 = " r(N)
quietly count if !missing(t3v0563)
display as text "[TRACE t3 0182] count for t3v0563 = " r(N)
quietly count if !missing(t3v0574)
display as text "[TRACE t3 0183] count for t3v0574 = " r(N)
quietly count if !missing(t3v0585)
display as text "[TRACE t3 0184] count for t3v0585 = " r(N)
quietly count if !missing(t3v0596)
display as text "[TRACE t3 0185] count for t3v0596 = " r(N)
quietly count if !missing(t3v0607)
display as text "[TRACE t3 0186] count for t3v0607 = " r(N)
quietly count if !missing(t3v0618)
display as text "[TRACE t3 0187] count for t3v0618 = " r(N)
quietly summarize t3v0618, detail
display as text "[TRACE-DETAIL t3 0187] p50=" %9.4f r(p50)
quietly count if !missing(t3v0629)
display as text "[TRACE t3 0188] count for t3v0629 = " r(N)
quietly count if !missing(t3v0640)
display as text "[TRACE t3 0189] count for t3v0640 = " r(N)
quietly count if !missing(t3v0651)
display as text "[TRACE t3 0190] count for t3v0651 = " r(N)
quietly count if !missing(t3v0662)
display as text "[TRACE t3 0191] count for t3v0662 = " r(N)
quietly count if !missing(t3v0673)
display as text "[TRACE t3 0192] count for t3v0673 = " r(N)
quietly count if !missing(t3v0684)
display as text "[TRACE t3 0193] count for t3v0684 = " r(N)
quietly count if !missing(t3v0695)
display as text "[TRACE t3 0194] count for t3v0695 = " r(N)
quietly count if !missing(t3v0706)
display as text "[TRACE t3 0195] count for t3v0706 = " r(N)
quietly count if !missing(t3v0717)
display as text "[TRACE t3 0196] count for t3v0717 = " r(N)
quietly count if !missing(t3v0008)
display as text "[TRACE t3 0197] count for t3v0008 = " r(N)
quietly count if !missing(t3v0019)
display as text "[TRACE t3 0198] count for t3v0019 = " r(N)
quietly count if !missing(t3v0030)
display as text "[TRACE t3 0199] count for t3v0030 = " r(N)
quietly count if !missing(t3v0041)
display as text "[TRACE t3 0200] count for t3v0041 = " r(N)
quietly count if !missing(t3v0052)
display as text "[TRACE t3 0201] count for t3v0052 = " r(N)
quietly count if !missing(t3v0063)
display as text "[TRACE t3 0202] count for t3v0063 = " r(N)
quietly count if !missing(t3v0074)
display as text "[TRACE t3 0203] count for t3v0074 = " r(N)
quietly count if !missing(t3v0085)
display as text "[TRACE t3 0204] count for t3v0085 = " r(N)
quietly summarize t3v0085, detail
display as text "[TRACE-DETAIL t3 0204] p50=" %9.4f r(p50)
quietly count if !missing(t3v0096)
display as text "[TRACE t3 0205] count for t3v0096 = " r(N)
quietly count if !missing(t3v0107)
display as text "[TRACE t3 0206] count for t3v0107 = " r(N)
quietly count if !missing(t3v0118)
display as text "[TRACE t3 0207] count for t3v0118 = " r(N)
quietly count if !missing(t3v0129)
display as text "[TRACE t3 0208] count for t3v0129 = " r(N)
quietly count if !missing(t3v0140)
display as text "[TRACE t3 0209] count for t3v0140 = " r(N)
quietly count if !missing(t3v0151)
display as text "[TRACE t3 0210] count for t3v0151 = " r(N)
quietly count if !missing(t3v0162)
display as text "[TRACE t3 0211] count for t3v0162 = " r(N)
quietly count if !missing(t3v0173)
display as text "[TRACE t3 0212] count for t3v0173 = " r(N)
quietly count if !missing(t3v0184)
display as text "[TRACE t3 0213] count for t3v0184 = " r(N)
quietly count if !missing(t3v0195)
display as text "[TRACE t3 0214] count for t3v0195 = " r(N)
quietly count if !missing(t3v0206)
display as text "[TRACE t3 0215] count for t3v0206 = " r(N)
quietly count if !missing(t3v0217)
display as text "[TRACE t3 0216] count for t3v0217 = " r(N)
quietly count if !missing(t3v0228)
display as text "[TRACE t3 0217] count for t3v0228 = " r(N)
quietly count if !missing(t3v0239)
display as text "[TRACE t3 0218] count for t3v0239 = " r(N)
quietly count if !missing(t3v0250)
display as text "[TRACE t3 0219] count for t3v0250 = " r(N)
quietly count if !missing(t3v0261)
display as text "[TRACE t3 0220] count for t3v0261 = " r(N)
quietly count if !missing(t3v0272)
display as text "[TRACE t3 0221] count for t3v0272 = " r(N)
quietly summarize t3v0272, detail
display as text "[TRACE-DETAIL t3 0221] p50=" %9.4f r(p50)
quietly count if !missing(t3v0283)
display as text "[TRACE t3 0222] count for t3v0283 = " r(N)
quietly count if !missing(t3v0294)
display as text "[TRACE t3 0223] count for t3v0294 = " r(N)
quietly count if !missing(t3v0305)
display as text "[TRACE t3 0224] count for t3v0305 = " r(N)
quietly count if !missing(t3v0316)
display as text "[TRACE t3 0225] count for t3v0316 = " r(N)
quietly count if !missing(t3v0327)
display as text "[TRACE t3 0226] count for t3v0327 = " r(N)
quietly count if !missing(t3v0338)
display as text "[TRACE t3 0227] count for t3v0338 = " r(N)
quietly count if !missing(t3v0349)
display as text "[TRACE t3 0228] count for t3v0349 = " r(N)
quietly count if !missing(t3v0360)
display as text "[TRACE t3 0229] count for t3v0360 = " r(N)
quietly count if !missing(t3v0371)
display as text "[TRACE t3 0230] count for t3v0371 = " r(N)
quietly count if !missing(t3v0382)
display as text "[TRACE t3 0231] count for t3v0382 = " r(N)
quietly count if !missing(t3v0393)
display as text "[TRACE t3 0232] count for t3v0393 = " r(N)
quietly count if !missing(t3v0404)
display as text "[TRACE t3 0233] count for t3v0404 = " r(N)
quietly count if !missing(t3v0415)
display as text "[TRACE t3 0234] count for t3v0415 = " r(N)
quietly count if !missing(t3v0426)
display as text "[TRACE t3 0235] count for t3v0426 = " r(N)
quietly count if !missing(t3v0437)
display as text "[TRACE t3 0236] count for t3v0437 = " r(N)
quietly count if !missing(t3v0448)
display as text "[TRACE t3 0237] count for t3v0448 = " r(N)
quietly count if !missing(t3v0459)
display as text "[TRACE t3 0238] count for t3v0459 = " r(N)
quietly summarize t3v0459, detail
display as text "[TRACE-DETAIL t3 0238] p50=" %9.4f r(p50)
quietly count if !missing(t3v0470)
display as text "[TRACE t3 0239] count for t3v0470 = " r(N)
quietly count if !missing(t3v0481)
display as text "[TRACE t3 0240] count for t3v0481 = " r(N)
quietly count if !missing(t3v0492)
display as text "[TRACE t3 0241] count for t3v0492 = " r(N)
quietly count if !missing(t3v0503)
display as text "[TRACE t3 0242] count for t3v0503 = " r(N)
quietly count if !missing(t3v0514)
display as text "[TRACE t3 0243] count for t3v0514 = " r(N)
quietly count if !missing(t3v0525)
display as text "[TRACE t3 0244] count for t3v0525 = " r(N)
quietly count if !missing(t3v0536)
display as text "[TRACE t3 0245] count for t3v0536 = " r(N)
quietly count if !missing(t3v0547)
display as text "[TRACE t3 0246] count for t3v0547 = " r(N)
quietly count if !missing(t3v0558)
display as text "[TRACE t3 0247] count for t3v0558 = " r(N)
quietly count if !missing(t3v0569)
display as text "[TRACE t3 0248] count for t3v0569 = " r(N)
quietly count if !missing(t3v0580)
display as text "[TRACE t3 0249] count for t3v0580 = " r(N)
quietly count if !missing(t3v0591)
display as text "[TRACE t3 0250] count for t3v0591 = " r(N)
quietly count if !missing(t3v0602)
display as text "[TRACE t3 0251] count for t3v0602 = " r(N)
quietly count if !missing(t3v0613)
display as text "[TRACE t3 0252] count for t3v0613 = " r(N)
quietly count if !missing(t3v0624)
display as text "[TRACE t3 0253] count for t3v0624 = " r(N)
quietly count if !missing(t3v0635)
display as text "[TRACE t3 0254] count for t3v0635 = " r(N)
quietly count if !missing(t3v0646)
display as text "[TRACE t3 0255] count for t3v0646 = " r(N)
quietly summarize t3v0646, detail
display as text "[TRACE-DETAIL t3 0255] p50=" %9.4f r(p50)
quietly count if !missing(t3v0657)
display as text "[TRACE t3 0256] count for t3v0657 = " r(N)
quietly count if !missing(t3v0668)
display as text "[TRACE t3 0257] count for t3v0668 = " r(N)
quietly count if !missing(t3v0679)
display as text "[TRACE t3 0258] count for t3v0679 = " r(N)
quietly count if !missing(t3v0690)
display as text "[TRACE t3 0259] count for t3v0690 = " r(N)
quietly count if !missing(t3v0701)
display as text "[TRACE t3 0260] count for t3v0701 = " r(N)
quietly count if !missing(t3v0712)
display as text "[TRACE t3 0261] count for t3v0712 = " r(N)
quietly count if !missing(t3v0003)
display as text "[TRACE t3 0262] count for t3v0003 = " r(N)
quietly count if !missing(t3v0014)
display as text "[TRACE t3 0263] count for t3v0014 = " r(N)
quietly count if !missing(t3v0025)
display as text "[TRACE t3 0264] count for t3v0025 = " r(N)
quietly count if !missing(t3v0036)
display as text "[TRACE t3 0265] count for t3v0036 = " r(N)
quietly count if !missing(t3v0047)
display as text "[TRACE t3 0266] count for t3v0047 = " r(N)
quietly count if !missing(t3v0058)
display as text "[TRACE t3 0267] count for t3v0058 = " r(N)
quietly count if !missing(t3v0069)
display as text "[TRACE t3 0268] count for t3v0069 = " r(N)
quietly count if !missing(t3v0080)
display as text "[TRACE t3 0269] count for t3v0080 = " r(N)
quietly count if !missing(t3v0091)
display as text "[TRACE t3 0270] count for t3v0091 = " r(N)
quietly count if !missing(t3v0102)
display as text "[TRACE t3 0271] count for t3v0102 = " r(N)
quietly count if !missing(t3v0113)
display as text "[TRACE t3 0272] count for t3v0113 = " r(N)
quietly summarize t3v0113, detail
display as text "[TRACE-DETAIL t3 0272] p50=" %9.4f r(p50)
quietly count if !missing(t3v0124)
display as text "[TRACE t3 0273] count for t3v0124 = " r(N)
quietly count if !missing(t3v0135)
display as text "[TRACE t3 0274] count for t3v0135 = " r(N)
quietly count if !missing(t3v0146)
display as text "[TRACE t3 0275] count for t3v0146 = " r(N)
quietly count if !missing(t3v0157)
display as text "[TRACE t3 0276] count for t3v0157 = " r(N)
quietly count if !missing(t3v0168)
display as text "[TRACE t3 0277] count for t3v0168 = " r(N)
quietly count if !missing(t3v0179)
display as text "[TRACE t3 0278] count for t3v0179 = " r(N)
quietly count if !missing(t3v0190)
display as text "[TRACE t3 0279] count for t3v0190 = " r(N)
quietly count if !missing(t3v0201)
display as text "[TRACE t3 0280] count for t3v0201 = " r(N)
quietly count if !missing(t3v0212)
display as text "[TRACE t3 0281] count for t3v0212 = " r(N)
quietly count if !missing(t3v0223)
display as text "[TRACE t3 0282] count for t3v0223 = " r(N)
quietly count if !missing(t3v0234)
display as text "[TRACE t3 0283] count for t3v0234 = " r(N)
quietly count if !missing(t3v0245)
display as text "[TRACE t3 0284] count for t3v0245 = " r(N)
quietly count if !missing(t3v0256)
display as text "[TRACE t3 0285] count for t3v0256 = " r(N)
quietly count if !missing(t3v0267)
display as text "[TRACE t3 0286] count for t3v0267 = " r(N)
quietly count if !missing(t3v0278)
display as text "[TRACE t3 0287] count for t3v0278 = " r(N)
quietly count if !missing(t3v0289)
display as text "[TRACE t3 0288] count for t3v0289 = " r(N)
quietly count if !missing(t3v0300)
display as text "[TRACE t3 0289] count for t3v0300 = " r(N)
quietly summarize t3v0300, detail
display as text "[TRACE-DETAIL t3 0289] p50=" %9.4f r(p50)
quietly count if !missing(t3v0311)
display as text "[TRACE t3 0290] count for t3v0311 = " r(N)
quietly count if !missing(t3v0322)
display as text "[TRACE t3 0291] count for t3v0322 = " r(N)
quietly count if !missing(t3v0333)
display as text "[TRACE t3 0292] count for t3v0333 = " r(N)
quietly count if !missing(t3v0344)
display as text "[TRACE t3 0293] count for t3v0344 = " r(N)
quietly count if !missing(t3v0355)
display as text "[TRACE t3 0294] count for t3v0355 = " r(N)
quietly count if !missing(t3v0366)
display as text "[TRACE t3 0295] count for t3v0366 = " r(N)
quietly count if !missing(t3v0377)
display as text "[TRACE t3 0296] count for t3v0377 = " r(N)
quietly count if !missing(t3v0388)
display as text "[TRACE t3 0297] count for t3v0388 = " r(N)
quietly count if !missing(t3v0399)
display as text "[TRACE t3 0298] count for t3v0399 = " r(N)
quietly count if !missing(t3v0410)
display as text "[TRACE t3 0299] count for t3v0410 = " r(N)
quietly count if !missing(t3v0421)
display as text "[TRACE t3 0300] count for t3v0421 = " r(N)
quietly count if !missing(t3v0432)
display as text "[TRACE t3 0301] count for t3v0432 = " r(N)
quietly count if !missing(t3v0443)
display as text "[TRACE t3 0302] count for t3v0443 = " r(N)
quietly count if !missing(t3v0454)
display as text "[TRACE t3 0303] count for t3v0454 = " r(N)
quietly count if !missing(t3v0465)
display as text "[TRACE t3 0304] count for t3v0465 = " r(N)
quietly count if !missing(t3v0476)
display as text "[TRACE t3 0305] count for t3v0476 = " r(N)
quietly count if !missing(t3v0487)
display as text "[TRACE t3 0306] count for t3v0487 = " r(N)
quietly summarize t3v0487, detail
display as text "[TRACE-DETAIL t3 0306] p50=" %9.4f r(p50)
quietly count if !missing(t3v0498)
display as text "[TRACE t3 0307] count for t3v0498 = " r(N)
quietly count if !missing(t3v0509)
display as text "[TRACE t3 0308] count for t3v0509 = " r(N)
quietly count if !missing(t3v0520)
display as text "[TRACE t3 0309] count for t3v0520 = " r(N)
quietly count if !missing(t3v0531)
display as text "[TRACE t3 0310] count for t3v0531 = " r(N)
quietly count if !missing(t3v0542)
display as text "[TRACE t3 0311] count for t3v0542 = " r(N)
quietly count if !missing(t3v0553)
display as text "[TRACE t3 0312] count for t3v0553 = " r(N)
quietly count if !missing(t3v0564)
display as text "[TRACE t3 0313] count for t3v0564 = " r(N)
quietly count if !missing(t3v0575)
display as text "[TRACE t3 0314] count for t3v0575 = " r(N)
quietly count if !missing(t3v0586)
display as text "[TRACE t3 0315] count for t3v0586 = " r(N)
quietly count if !missing(t3v0597)
display as text "[TRACE t3 0316] count for t3v0597 = " r(N)
quietly count if !missing(t3v0608)
display as text "[TRACE t3 0317] count for t3v0608 = " r(N)
quietly count if !missing(t3v0619)
display as text "[TRACE t3 0318] count for t3v0619 = " r(N)
quietly count if !missing(t3v0630)
display as text "[TRACE t3 0319] count for t3v0630 = " r(N)
quietly count if !missing(t3v0641)
display as text "[TRACE t3 0320] count for t3v0641 = " r(N)
quietly count if !missing(t3v0652)
display as text "[TRACE t3 0321] count for t3v0652 = " r(N)
quietly count if !missing(t3v0663)
display as text "[TRACE t3 0322] count for t3v0663 = " r(N)
quietly count if !missing(t3v0674)
display as text "[TRACE t3 0323] count for t3v0674 = " r(N)
quietly summarize t3v0674, detail
display as text "[TRACE-DETAIL t3 0323] p50=" %9.4f r(p50)
quietly count if !missing(t3v0685)
display as text "[TRACE t3 0324] count for t3v0685 = " r(N)
quietly count if !missing(t3v0696)
display as text "[TRACE t3 0325] count for t3v0696 = " r(N)
quietly count if !missing(t3v0707)
display as text "[TRACE t3 0326] count for t3v0707 = " r(N)
quietly count if !missing(t3v0718)
display as text "[TRACE t3 0327] count for t3v0718 = " r(N)
quietly count if !missing(t3v0009)
display as text "[TRACE t3 0328] count for t3v0009 = " r(N)
quietly count if !missing(t3v0020)
display as text "[TRACE t3 0329] count for t3v0020 = " r(N)
quietly count if !missing(t3v0031)
display as text "[TRACE t3 0330] count for t3v0031 = " r(N)
quietly count if !missing(t3v0042)
display as text "[TRACE t3 0331] count for t3v0042 = " r(N)
quietly count if !missing(t3v0053)
display as text "[TRACE t3 0332] count for t3v0053 = " r(N)
quietly count if !missing(t3v0064)
display as text "[TRACE t3 0333] count for t3v0064 = " r(N)
quietly count if !missing(t3v0075)
display as text "[TRACE t3 0334] count for t3v0075 = " r(N)
quietly count if !missing(t3v0086)
display as text "[TRACE t3 0335] count for t3v0086 = " r(N)
quietly count if !missing(t3v0097)
display as text "[TRACE t3 0336] count for t3v0097 = " r(N)
quietly count if !missing(t3v0108)
display as text "[TRACE t3 0337] count for t3v0108 = " r(N)
quietly count if !missing(t3v0119)
display as text "[TRACE t3 0338] count for t3v0119 = " r(N)
quietly count if !missing(t3v0130)
display as text "[TRACE t3 0339] count for t3v0130 = " r(N)
quietly count if !missing(t3v0141)
display as text "[TRACE t3 0340] count for t3v0141 = " r(N)
quietly summarize t3v0141, detail
display as text "[TRACE-DETAIL t3 0340] p50=" %9.4f r(p50)
quietly count if !missing(t3v0152)
display as text "[TRACE t3 0341] count for t3v0152 = " r(N)
quietly count if !missing(t3v0163)
display as text "[TRACE t3 0342] count for t3v0163 = " r(N)
quietly count if !missing(t3v0174)
display as text "[TRACE t3 0343] count for t3v0174 = " r(N)
quietly count if !missing(t3v0185)
display as text "[TRACE t3 0344] count for t3v0185 = " r(N)
quietly count if !missing(t3v0196)
display as text "[TRACE t3 0345] count for t3v0196 = " r(N)
quietly count if !missing(t3v0207)
display as text "[TRACE t3 0346] count for t3v0207 = " r(N)
quietly count if !missing(t3v0218)
display as text "[TRACE t3 0347] count for t3v0218 = " r(N)
quietly count if !missing(t3v0229)
display as text "[TRACE t3 0348] count for t3v0229 = " r(N)
quietly count if !missing(t3v0240)
display as text "[TRACE t3 0349] count for t3v0240 = " r(N)
quietly count if !missing(t3v0251)
display as text "[TRACE t3 0350] count for t3v0251 = " r(N)
quietly count if !missing(t3v0262)
display as text "[TRACE t3 0351] count for t3v0262 = " r(N)
quietly count if !missing(t3v0273)
display as text "[TRACE t3 0352] count for t3v0273 = " r(N)
quietly count if !missing(t3v0284)
display as text "[TRACE t3 0353] count for t3v0284 = " r(N)
quietly count if !missing(t3v0295)
display as text "[TRACE t3 0354] count for t3v0295 = " r(N)
quietly count if !missing(t3v0306)
display as text "[TRACE t3 0355] count for t3v0306 = " r(N)
quietly count if !missing(t3v0317)
display as text "[TRACE t3 0356] count for t3v0317 = " r(N)
quietly count if !missing(t3v0328)
display as text "[TRACE t3 0357] count for t3v0328 = " r(N)
quietly summarize t3v0328, detail
display as text "[TRACE-DETAIL t3 0357] p50=" %9.4f r(p50)
quietly count if !missing(t3v0339)
display as text "[TRACE t3 0358] count for t3v0339 = " r(N)
quietly count if !missing(t3v0350)
display as text "[TRACE t3 0359] count for t3v0350 = " r(N)
quietly count if !missing(t3v0361)
display as text "[TRACE t3 0360] count for t3v0361 = " r(N)
quietly count if !missing(t3v0372)
display as text "[TRACE t3 0361] count for t3v0372 = " r(N)
quietly count if !missing(t3v0383)
display as text "[TRACE t3 0362] count for t3v0383 = " r(N)
quietly count if !missing(t3v0394)
display as text "[TRACE t3 0363] count for t3v0394 = " r(N)
quietly count if !missing(t3v0405)
display as text "[TRACE t3 0364] count for t3v0405 = " r(N)
quietly count if !missing(t3v0416)
display as text "[TRACE t3 0365] count for t3v0416 = " r(N)
quietly count if !missing(t3v0427)
display as text "[TRACE t3 0366] count for t3v0427 = " r(N)
quietly count if !missing(t3v0438)
display as text "[TRACE t3 0367] count for t3v0438 = " r(N)
quietly count if !missing(t3v0449)
display as text "[TRACE t3 0368] count for t3v0449 = " r(N)
quietly count if !missing(t3v0460)
display as text "[TRACE t3 0369] count for t3v0460 = " r(N)
quietly count if !missing(t3v0471)
display as text "[TRACE t3 0370] count for t3v0471 = " r(N)
quietly count if !missing(t3v0482)
display as text "[TRACE t3 0371] count for t3v0482 = " r(N)
quietly count if !missing(t3v0493)
display as text "[TRACE t3 0372] count for t3v0493 = " r(N)
quietly count if !missing(t3v0504)
display as text "[TRACE t3 0373] count for t3v0504 = " r(N)
quietly count if !missing(t3v0515)
display as text "[TRACE t3 0374] count for t3v0515 = " r(N)
quietly summarize t3v0515, detail
display as text "[TRACE-DETAIL t3 0374] p50=" %9.4f r(p50)
quietly count if !missing(t3v0526)
display as text "[TRACE t3 0375] count for t3v0526 = " r(N)
quietly count if !missing(t3v0537)
display as text "[TRACE t3 0376] count for t3v0537 = " r(N)
quietly count if !missing(t3v0548)
display as text "[TRACE t3 0377] count for t3v0548 = " r(N)
quietly count if !missing(t3v0559)
display as text "[TRACE t3 0378] count for t3v0559 = " r(N)
quietly count if !missing(t3v0570)
display as text "[TRACE t3 0379] count for t3v0570 = " r(N)
quietly count if !missing(t3v0581)
display as text "[TRACE t3 0380] count for t3v0581 = " r(N)
quietly count if !missing(t3v0592)
display as text "[TRACE t3 0381] count for t3v0592 = " r(N)
quietly count if !missing(t3v0603)
display as text "[TRACE t3 0382] count for t3v0603 = " r(N)
quietly count if !missing(t3v0614)
display as text "[TRACE t3 0383] count for t3v0614 = " r(N)
quietly count if !missing(t3v0625)
display as text "[TRACE t3 0384] count for t3v0625 = " r(N)
quietly count if !missing(t3v0636)
display as text "[TRACE t3 0385] count for t3v0636 = " r(N)
quietly count if !missing(t3v0647)
display as text "[TRACE t3 0386] count for t3v0647 = " r(N)
quietly count if !missing(t3v0658)
display as text "[TRACE t3 0387] count for t3v0658 = " r(N)
quietly count if !missing(t3v0669)
display as text "[TRACE t3 0388] count for t3v0669 = " r(N)
quietly count if !missing(t3v0680)
display as text "[TRACE t3 0389] count for t3v0680 = " r(N)
quietly count if !missing(t3v0691)
display as text "[TRACE t3 0390] count for t3v0691 = " r(N)
quietly count if !missing(t3v0702)
display as text "[TRACE t3 0391] count for t3v0702 = " r(N)
quietly summarize t3v0702, detail
display as text "[TRACE-DETAIL t3 0391] p50=" %9.4f r(p50)
quietly count if !missing(t3v0713)
display as text "[TRACE t3 0392] count for t3v0713 = " r(N)
quietly count if !missing(t3v0004)
display as text "[TRACE t3 0393] count for t3v0004 = " r(N)
quietly count if !missing(t3v0015)
display as text "[TRACE t3 0394] count for t3v0015 = " r(N)
quietly count if !missing(t3v0026)
display as text "[TRACE t3 0395] count for t3v0026 = " r(N)
quietly count if !missing(t3v0037)
display as text "[TRACE t3 0396] count for t3v0037 = " r(N)
quietly count if !missing(t3v0048)
display as text "[TRACE t3 0397] count for t3v0048 = " r(N)
quietly count if !missing(t3v0059)
display as text "[TRACE t3 0398] count for t3v0059 = " r(N)
quietly count if !missing(t3v0070)
display as text "[TRACE t3 0399] count for t3v0070 = " r(N)
quietly count if !missing(t3v0081)
display as text "[TRACE t3 0400] count for t3v0081 = " r(N)
quietly count if !missing(t3v0092)
display as text "[TRACE t3 0401] count for t3v0092 = " r(N)
quietly count if !missing(t3v0103)
display as text "[TRACE t3 0402] count for t3v0103 = " r(N)
quietly count if !missing(t3v0114)
display as text "[TRACE t3 0403] count for t3v0114 = " r(N)
quietly count if !missing(t3v0125)
display as text "[TRACE t3 0404] count for t3v0125 = " r(N)
quietly count if !missing(t3v0136)
display as text "[TRACE t3 0405] count for t3v0136 = " r(N)
quietly count if !missing(t3v0147)
display as text "[TRACE t3 0406] count for t3v0147 = " r(N)
quietly count if !missing(t3v0158)
display as text "[TRACE t3 0407] count for t3v0158 = " r(N)
quietly count if !missing(t3v0169)
display as text "[TRACE t3 0408] count for t3v0169 = " r(N)
quietly summarize t3v0169, detail
display as text "[TRACE-DETAIL t3 0408] p50=" %9.4f r(p50)
quietly count if !missing(t3v0180)
display as text "[TRACE t3 0409] count for t3v0180 = " r(N)
quietly count if !missing(t3v0191)
display as text "[TRACE t3 0410] count for t3v0191 = " r(N)
quietly count if !missing(t3v0202)
display as text "[TRACE t3 0411] count for t3v0202 = " r(N)
quietly count if !missing(t3v0213)
display as text "[TRACE t3 0412] count for t3v0213 = " r(N)
quietly count if !missing(t3v0224)
display as text "[TRACE t3 0413] count for t3v0224 = " r(N)
quietly count if !missing(t3v0235)
display as text "[TRACE t3 0414] count for t3v0235 = " r(N)
quietly count if !missing(t3v0246)
display as text "[TRACE t3 0415] count for t3v0246 = " r(N)
quietly count if !missing(t3v0257)
display as text "[TRACE t3 0416] count for t3v0257 = " r(N)
quietly count if !missing(t3v0268)
display as text "[TRACE t3 0417] count for t3v0268 = " r(N)
quietly count if !missing(t3v0279)
display as text "[TRACE t3 0418] count for t3v0279 = " r(N)
quietly count if !missing(t3v0290)
display as text "[TRACE t3 0419] count for t3v0290 = " r(N)
quietly count if !missing(t3v0301)
display as text "[TRACE t3 0420] count for t3v0301 = " r(N)
quietly count if !missing(t3v0312)
display as text "[TRACE t3 0421] count for t3v0312 = " r(N)
quietly count if !missing(t3v0323)
display as text "[TRACE t3 0422] count for t3v0323 = " r(N)
quietly count if !missing(t3v0334)
display as text "[TRACE t3 0423] count for t3v0334 = " r(N)
quietly count if !missing(t3v0345)
display as text "[TRACE t3 0424] count for t3v0345 = " r(N)
quietly count if !missing(t3v0356)
display as text "[TRACE t3 0425] count for t3v0356 = " r(N)
quietly summarize t3v0356, detail
display as text "[TRACE-DETAIL t3 0425] p50=" %9.4f r(p50)
quietly count if !missing(t3v0367)
display as text "[TRACE t3 0426] count for t3v0367 = " r(N)
quietly count if !missing(t3v0378)
display as text "[TRACE t3 0427] count for t3v0378 = " r(N)
quietly count if !missing(t3v0389)
display as text "[TRACE t3 0428] count for t3v0389 = " r(N)
quietly count if !missing(t3v0400)
display as text "[TRACE t3 0429] count for t3v0400 = " r(N)
quietly count if !missing(t3v0411)
display as text "[TRACE t3 0430] count for t3v0411 = " r(N)
quietly count if !missing(t3v0422)
display as text "[TRACE t3 0431] count for t3v0422 = " r(N)
quietly count if !missing(t3v0433)
display as text "[TRACE t3 0432] count for t3v0433 = " r(N)
quietly count if !missing(t3v0444)
display as text "[TRACE t3 0433] count for t3v0444 = " r(N)
quietly count if !missing(t3v0455)
display as text "[TRACE t3 0434] count for t3v0455 = " r(N)
quietly count if !missing(t3v0466)
display as text "[TRACE t3 0435] count for t3v0466 = " r(N)
quietly count if !missing(t3v0477)
display as text "[TRACE t3 0436] count for t3v0477 = " r(N)
quietly count if !missing(t3v0488)
display as text "[TRACE t3 0437] count for t3v0488 = " r(N)
quietly count if !missing(t3v0499)
display as text "[TRACE t3 0438] count for t3v0499 = " r(N)
quietly count if !missing(t3v0510)
display as text "[TRACE t3 0439] count for t3v0510 = " r(N)
quietly count if !missing(t3v0521)
display as text "[TRACE t3 0440] count for t3v0521 = " r(N)
quietly count if !missing(t3v0532)
display as text "[TRACE t3 0441] count for t3v0532 = " r(N)
quietly count if !missing(t3v0543)
display as text "[TRACE t3 0442] count for t3v0543 = " r(N)
quietly summarize t3v0543, detail
display as text "[TRACE-DETAIL t3 0442] p50=" %9.4f r(p50)
quietly count if !missing(t3v0554)
display as text "[TRACE t3 0443] count for t3v0554 = " r(N)
quietly count if !missing(t3v0565)
display as text "[TRACE t3 0444] count for t3v0565 = " r(N)
quietly count if !missing(t3v0576)
display as text "[TRACE t3 0445] count for t3v0576 = " r(N)
quietly count if !missing(t3v0587)
display as text "[TRACE t3 0446] count for t3v0587 = " r(N)
quietly count if !missing(t3v0598)
display as text "[TRACE t3 0447] count for t3v0598 = " r(N)
quietly count if !missing(t3v0609)
display as text "[TRACE t3 0448] count for t3v0609 = " r(N)
quietly count if !missing(t3v0620)
display as text "[TRACE t3 0449] count for t3v0620 = " r(N)
quietly count if !missing(t3v0631)
display as text "[TRACE t3 0450] count for t3v0631 = " r(N)
quietly count if !missing(t3v0642)
display as text "[TRACE t3 0451] count for t3v0642 = " r(N)
quietly count if !missing(t3v0653)
display as text "[TRACE t3 0452] count for t3v0653 = " r(N)
quietly count if !missing(t3v0664)
display as text "[TRACE t3 0453] count for t3v0664 = " r(N)
quietly count if !missing(t3v0675)
display as text "[TRACE t3 0454] count for t3v0675 = " r(N)
quietly count if !missing(t3v0686)
display as text "[TRACE t3 0455] count for t3v0686 = " r(N)
quietly count if !missing(t3v0697)
display as text "[TRACE t3 0456] count for t3v0697 = " r(N)
quietly count if !missing(t3v0708)
display as text "[TRACE t3 0457] count for t3v0708 = " r(N)
quietly count if !missing(t3v0719)
display as text "[TRACE t3 0458] count for t3v0719 = " r(N)
quietly count if !missing(t3v0010)
display as text "[TRACE t3 0459] count for t3v0010 = " r(N)
quietly summarize t3v0010, detail
display as text "[TRACE-DETAIL t3 0459] p50=" %9.4f r(p50)
quietly count if !missing(t3v0021)
display as text "[TRACE t3 0460] count for t3v0021 = " r(N)
quietly count if !missing(t3v0032)
display as text "[TRACE t3 0461] count for t3v0032 = " r(N)
quietly count if !missing(t3v0043)
display as text "[TRACE t3 0462] count for t3v0043 = " r(N)
quietly count if !missing(t3v0054)
display as text "[TRACE t3 0463] count for t3v0054 = " r(N)
quietly count if !missing(t3v0065)
display as text "[TRACE t3 0464] count for t3v0065 = " r(N)
quietly count if !missing(t3v0076)
display as text "[TRACE t3 0465] count for t3v0076 = " r(N)
quietly count if !missing(t3v0087)
display as text "[TRACE t3 0466] count for t3v0087 = " r(N)
quietly count if !missing(t3v0098)
display as text "[TRACE t3 0467] count for t3v0098 = " r(N)
quietly count if !missing(t3v0109)
display as text "[TRACE t3 0468] count for t3v0109 = " r(N)
quietly count if !missing(t3v0120)
display as text "[TRACE t3 0469] count for t3v0120 = " r(N)
quietly count if !missing(t3v0131)
display as text "[TRACE t3 0470] count for t3v0131 = " r(N)
quietly count if !missing(t3v0142)
display as text "[TRACE t3 0471] count for t3v0142 = " r(N)
quietly count if !missing(t3v0153)
display as text "[TRACE t3 0472] count for t3v0153 = " r(N)
quietly count if !missing(t3v0164)
display as text "[TRACE t3 0473] count for t3v0164 = " r(N)
quietly count if !missing(t3v0175)
display as text "[TRACE t3 0474] count for t3v0175 = " r(N)
quietly count if !missing(t3v0186)
display as text "[TRACE t3 0475] count for t3v0186 = " r(N)
quietly count if !missing(t3v0197)
display as text "[TRACE t3 0476] count for t3v0197 = " r(N)
quietly summarize t3v0197, detail
display as text "[TRACE-DETAIL t3 0476] p50=" %9.4f r(p50)
quietly count if !missing(t3v0208)
display as text "[TRACE t3 0477] count for t3v0208 = " r(N)
quietly count if !missing(t3v0219)
display as text "[TRACE t3 0478] count for t3v0219 = " r(N)
quietly count if !missing(t3v0230)
display as text "[TRACE t3 0479] count for t3v0230 = " r(N)
quietly count if !missing(t3v0241)
display as text "[TRACE t3 0480] count for t3v0241 = " r(N)
quietly count if !missing(t3v0252)
display as text "[TRACE t3 0481] count for t3v0252 = " r(N)
quietly count if !missing(t3v0263)
display as text "[TRACE t3 0482] count for t3v0263 = " r(N)
quietly count if !missing(t3v0274)
display as text "[TRACE t3 0483] count for t3v0274 = " r(N)
quietly count if !missing(t3v0285)
display as text "[TRACE t3 0484] count for t3v0285 = " r(N)
quietly count if !missing(t3v0296)
display as text "[TRACE t3 0485] count for t3v0296 = " r(N)
quietly count if !missing(t3v0307)
display as text "[TRACE t3 0486] count for t3v0307 = " r(N)
quietly count if !missing(t3v0318)
display as text "[TRACE t3 0487] count for t3v0318 = " r(N)
quietly count if !missing(t3v0329)
display as text "[TRACE t3 0488] count for t3v0329 = " r(N)
quietly count if !missing(t3v0340)
display as text "[TRACE t3 0489] count for t3v0340 = " r(N)
quietly count if !missing(t3v0351)
display as text "[TRACE t3 0490] count for t3v0351 = " r(N)
quietly count if !missing(t3v0362)
display as text "[TRACE t3 0491] count for t3v0362 = " r(N)
quietly count if !missing(t3v0373)
display as text "[TRACE t3 0492] count for t3v0373 = " r(N)
quietly count if !missing(t3v0384)
display as text "[TRACE t3 0493] count for t3v0384 = " r(N)
quietly summarize t3v0384, detail
display as text "[TRACE-DETAIL t3 0493] p50=" %9.4f r(p50)
quietly count if !missing(t3v0395)
display as text "[TRACE t3 0494] count for t3v0395 = " r(N)
quietly count if !missing(t3v0406)
display as text "[TRACE t3 0495] count for t3v0406 = " r(N)
quietly count if !missing(t3v0417)
display as text "[TRACE t3 0496] count for t3v0417 = " r(N)
quietly count if !missing(t3v0428)
display as text "[TRACE t3 0497] count for t3v0428 = " r(N)
quietly count if !missing(t3v0439)
display as text "[TRACE t3 0498] count for t3v0439 = " r(N)
quietly count if !missing(t3v0450)
display as text "[TRACE t3 0499] count for t3v0450 = " r(N)
quietly count if !missing(t3v0461)
display as text "[TRACE t3 0500] count for t3v0461 = " r(N)
quietly count if !missing(t3v0472)
display as text "[TRACE t3 0501] count for t3v0472 = " r(N)
quietly count if !missing(t3v0483)
display as text "[TRACE t3 0502] count for t3v0483 = " r(N)
quietly count if !missing(t3v0494)
display as text "[TRACE t3 0503] count for t3v0494 = " r(N)
quietly count if !missing(t3v0505)
display as text "[TRACE t3 0504] count for t3v0505 = " r(N)
quietly count if !missing(t3v0516)
display as text "[TRACE t3 0505] count for t3v0516 = " r(N)
quietly count if !missing(t3v0527)
display as text "[TRACE t3 0506] count for t3v0527 = " r(N)
quietly count if !missing(t3v0538)
display as text "[TRACE t3 0507] count for t3v0538 = " r(N)
quietly count if !missing(t3v0549)
display as text "[TRACE t3 0508] count for t3v0549 = " r(N)
quietly count if !missing(t3v0560)
display as text "[TRACE t3 0509] count for t3v0560 = " r(N)
quietly count if !missing(t3v0571)
display as text "[TRACE t3 0510] count for t3v0571 = " r(N)
quietly summarize t3v0571, detail
display as text "[TRACE-DETAIL t3 0510] p50=" %9.4f r(p50)
quietly count if !missing(t3v0582)
display as text "[TRACE t3 0511] count for t3v0582 = " r(N)
quietly count if !missing(t3v0593)
display as text "[TRACE t3 0512] count for t3v0593 = " r(N)
quietly count if !missing(t3v0604)
display as text "[TRACE t3 0513] count for t3v0604 = " r(N)
quietly count if !missing(t3v0615)
display as text "[TRACE t3 0514] count for t3v0615 = " r(N)
quietly count if !missing(t3v0626)
display as text "[TRACE t3 0515] count for t3v0626 = " r(N)
quietly count if !missing(t3v0637)
display as text "[TRACE t3 0516] count for t3v0637 = " r(N)
quietly count if !missing(t3v0648)
display as text "[TRACE t3 0517] count for t3v0648 = " r(N)
quietly count if !missing(t3v0659)
display as text "[TRACE t3 0518] count for t3v0659 = " r(N)
quietly count if !missing(t3v0670)
display as text "[TRACE t3 0519] count for t3v0670 = " r(N)
quietly count if !missing(t3v0681)
display as text "[TRACE t3 0520] count for t3v0681 = " r(N)
quietly count if !missing(t3v0692)
display as text "[TRACE t3 0521] count for t3v0692 = " r(N)
quietly count if !missing(t3v0703)
display as text "[TRACE t3 0522] count for t3v0703 = " r(N)
quietly count if !missing(t3v0714)
display as text "[TRACE t3 0523] count for t3v0714 = " r(N)
quietly count if !missing(t3v0005)
display as text "[TRACE t3 0524] count for t3v0005 = " r(N)
quietly count if !missing(t3v0016)
display as text "[TRACE t3 0525] count for t3v0016 = " r(N)
quietly count if !missing(t3v0027)
display as text "[TRACE t3 0526] count for t3v0027 = " r(N)
quietly count if !missing(t3v0038)
display as text "[TRACE t3 0527] count for t3v0038 = " r(N)
quietly summarize t3v0038, detail
display as text "[TRACE-DETAIL t3 0527] p50=" %9.4f r(p50)
quietly count if !missing(t3v0049)
display as text "[TRACE t3 0528] count for t3v0049 = " r(N)
quietly count if !missing(t3v0060)
display as text "[TRACE t3 0529] count for t3v0060 = " r(N)
quietly count if !missing(t3v0071)
display as text "[TRACE t3 0530] count for t3v0071 = " r(N)
quietly count if !missing(t3v0082)
display as text "[TRACE t3 0531] count for t3v0082 = " r(N)
quietly count if !missing(t3v0093)
display as text "[TRACE t3 0532] count for t3v0093 = " r(N)
quietly count if !missing(t3v0104)
display as text "[TRACE t3 0533] count for t3v0104 = " r(N)
quietly count if !missing(t3v0115)
display as text "[TRACE t3 0534] count for t3v0115 = " r(N)
quietly count if !missing(t3v0126)
display as text "[TRACE t3 0535] count for t3v0126 = " r(N)
quietly count if !missing(t3v0137)
display as text "[TRACE t3 0536] count for t3v0137 = " r(N)
quietly count if !missing(t3v0148)
display as text "[TRACE t3 0537] count for t3v0148 = " r(N)
quietly count if !missing(t3v0159)
display as text "[TRACE t3 0538] count for t3v0159 = " r(N)
quietly count if !missing(t3v0170)
display as text "[TRACE t3 0539] count for t3v0170 = " r(N)
quietly count if !missing(t3v0181)
display as text "[TRACE t3 0540] count for t3v0181 = " r(N)
quietly count if !missing(t3v0192)
display as text "[TRACE t3 0541] count for t3v0192 = " r(N)
quietly count if !missing(t3v0203)
display as text "[TRACE t3 0542] count for t3v0203 = " r(N)
quietly count if !missing(t3v0214)
display as text "[TRACE t3 0543] count for t3v0214 = " r(N)
quietly count if !missing(t3v0225)
display as text "[TRACE t3 0544] count for t3v0225 = " r(N)
quietly summarize t3v0225, detail
display as text "[TRACE-DETAIL t3 0544] p50=" %9.4f r(p50)
quietly count if !missing(t3v0236)
display as text "[TRACE t3 0545] count for t3v0236 = " r(N)
quietly count if !missing(t3v0247)
display as text "[TRACE t3 0546] count for t3v0247 = " r(N)
quietly count if !missing(t3v0258)
display as text "[TRACE t3 0547] count for t3v0258 = " r(N)
quietly count if !missing(t3v0269)
display as text "[TRACE t3 0548] count for t3v0269 = " r(N)
quietly count if !missing(t3v0280)
display as text "[TRACE t3 0549] count for t3v0280 = " r(N)
quietly count if !missing(t3v0291)
display as text "[TRACE t3 0550] count for t3v0291 = " r(N)
quietly count if !missing(t3v0302)
display as text "[TRACE t3 0551] count for t3v0302 = " r(N)
quietly count if !missing(t3v0313)
display as text "[TRACE t3 0552] count for t3v0313 = " r(N)
quietly count if !missing(t3v0324)
display as text "[TRACE t3 0553] count for t3v0324 = " r(N)
quietly count if !missing(t3v0335)
display as text "[TRACE t3 0554] count for t3v0335 = " r(N)
quietly count if !missing(t3v0346)
display as text "[TRACE t3 0555] count for t3v0346 = " r(N)
quietly count if !missing(t3v0357)
display as text "[TRACE t3 0556] count for t3v0357 = " r(N)
quietly count if !missing(t3v0368)
display as text "[TRACE t3 0557] count for t3v0368 = " r(N)
quietly count if !missing(t3v0379)
display as text "[TRACE t3 0558] count for t3v0379 = " r(N)
quietly count if !missing(t3v0390)
display as text "[TRACE t3 0559] count for t3v0390 = " r(N)
quietly count if !missing(t3v0401)
display as text "[TRACE t3 0560] count for t3v0401 = " r(N)
quietly count if !missing(t3v0412)
display as text "[TRACE t3 0561] count for t3v0412 = " r(N)
quietly summarize t3v0412, detail
display as text "[TRACE-DETAIL t3 0561] p50=" %9.4f r(p50)
quietly count if !missing(t3v0423)
display as text "[TRACE t3 0562] count for t3v0423 = " r(N)
quietly count if !missing(t3v0434)
display as text "[TRACE t3 0563] count for t3v0434 = " r(N)
quietly count if !missing(t3v0445)
display as text "[TRACE t3 0564] count for t3v0445 = " r(N)
quietly count if !missing(t3v0456)
display as text "[TRACE t3 0565] count for t3v0456 = " r(N)
quietly count if !missing(t3v0467)
display as text "[TRACE t3 0566] count for t3v0467 = " r(N)
quietly count if !missing(t3v0478)
display as text "[TRACE t3 0567] count for t3v0478 = " r(N)
quietly count if !missing(t3v0489)
display as text "[TRACE t3 0568] count for t3v0489 = " r(N)
quietly count if !missing(t3v0500)
display as text "[TRACE t3 0569] count for t3v0500 = " r(N)
quietly count if !missing(t3v0511)
display as text "[TRACE t3 0570] count for t3v0511 = " r(N)
quietly count if !missing(t3v0522)
display as text "[TRACE t3 0571] count for t3v0522 = " r(N)
quietly count if !missing(t3v0533)
display as text "[TRACE t3 0572] count for t3v0533 = " r(N)
quietly count if !missing(t3v0544)
display as text "[TRACE t3 0573] count for t3v0544 = " r(N)
quietly count if !missing(t3v0555)
display as text "[TRACE t3 0574] count for t3v0555 = " r(N)
quietly count if !missing(t3v0566)
display as text "[TRACE t3 0575] count for t3v0566 = " r(N)
quietly count if !missing(t3v0577)
display as text "[TRACE t3 0576] count for t3v0577 = " r(N)
quietly count if !missing(t3v0588)
display as text "[TRACE t3 0577] count for t3v0588 = " r(N)
quietly count if !missing(t3v0599)
display as text "[TRACE t3 0578] count for t3v0599 = " r(N)
quietly summarize t3v0599, detail
display as text "[TRACE-DETAIL t3 0578] p50=" %9.4f r(p50)
quietly count if !missing(t3v0610)
display as text "[TRACE t3 0579] count for t3v0610 = " r(N)
quietly count if !missing(t3v0621)
display as text "[TRACE t3 0580] count for t3v0621 = " r(N)
quietly count if !missing(t3v0632)
display as text "[TRACE t3 0581] count for t3v0632 = " r(N)
quietly count if !missing(t3v0643)
display as text "[TRACE t3 0582] count for t3v0643 = " r(N)
quietly count if !missing(t3v0654)
display as text "[TRACE t3 0583] count for t3v0654 = " r(N)
quietly count if !missing(t3v0665)
display as text "[TRACE t3 0584] count for t3v0665 = " r(N)
quietly count if !missing(t3v0676)
display as text "[TRACE t3 0585] count for t3v0676 = " r(N)
quietly count if !missing(t3v0687)
display as text "[TRACE t3 0586] count for t3v0687 = " r(N)
quietly count if !missing(t3v0698)
display as text "[TRACE t3 0587] count for t3v0698 = " r(N)
quietly count if !missing(t3v0709)
display as text "[TRACE t3 0588] count for t3v0709 = " r(N)
quietly count if !missing(t3v0720)
display as text "[TRACE t3 0589] count for t3v0720 = " r(N)
quietly count if !missing(t3v0011)
display as text "[TRACE t3 0590] count for t3v0011 = " r(N)
quietly count if !missing(t3v0022)
display as text "[TRACE t3 0591] count for t3v0022 = " r(N)
quietly count if !missing(t3v0033)
display as text "[TRACE t3 0592] count for t3v0033 = " r(N)
quietly count if !missing(t3v0044)
display as text "[TRACE t3 0593] count for t3v0044 = " r(N)
quietly count if !missing(t3v0055)
display as text "[TRACE t3 0594] count for t3v0055 = " r(N)
quietly count if !missing(t3v0066)
display as text "[TRACE t3 0595] count for t3v0066 = " r(N)
quietly summarize t3v0066, detail
display as text "[TRACE-DETAIL t3 0595] p50=" %9.4f r(p50)
quietly count if !missing(t3v0077)
display as text "[TRACE t3 0596] count for t3v0077 = " r(N)
quietly count if !missing(t3v0088)
display as text "[TRACE t3 0597] count for t3v0088 = " r(N)
quietly count if !missing(t3v0099)
display as text "[TRACE t3 0598] count for t3v0099 = " r(N)
quietly count if !missing(t3v0110)
display as text "[TRACE t3 0599] count for t3v0110 = " r(N)
quietly count if !missing(t3v0121)
display as text "[TRACE t3 0600] count for t3v0121 = " r(N)
quietly count if !missing(t3v0132)
display as text "[TRACE t3 0601] count for t3v0132 = " r(N)
quietly count if !missing(t3v0143)
display as text "[TRACE t3 0602] count for t3v0143 = " r(N)
quietly count if !missing(t3v0154)
display as text "[TRACE t3 0603] count for t3v0154 = " r(N)
quietly count if !missing(t3v0165)
display as text "[TRACE t3 0604] count for t3v0165 = " r(N)
quietly count if !missing(t3v0176)
display as text "[TRACE t3 0605] count for t3v0176 = " r(N)
quietly count if !missing(t3v0187)
display as text "[TRACE t3 0606] count for t3v0187 = " r(N)
quietly count if !missing(t3v0198)
display as text "[TRACE t3 0607] count for t3v0198 = " r(N)
quietly count if !missing(t3v0209)
display as text "[TRACE t3 0608] count for t3v0209 = " r(N)
quietly count if !missing(t3v0220)
display as text "[TRACE t3 0609] count for t3v0220 = " r(N)
quietly count if !missing(t3v0231)
display as text "[TRACE t3 0610] count for t3v0231 = " r(N)
quietly count if !missing(t3v0242)
display as text "[TRACE t3 0611] count for t3v0242 = " r(N)
quietly count if !missing(t3v0253)
display as text "[TRACE t3 0612] count for t3v0253 = " r(N)
quietly summarize t3v0253, detail
display as text "[TRACE-DETAIL t3 0612] p50=" %9.4f r(p50)
quietly count if !missing(t3v0264)
display as text "[TRACE t3 0613] count for t3v0264 = " r(N)
quietly count if !missing(t3v0275)
display as text "[TRACE t3 0614] count for t3v0275 = " r(N)
quietly count if !missing(t3v0286)
display as text "[TRACE t3 0615] count for t3v0286 = " r(N)
quietly count if !missing(t3v0297)
display as text "[TRACE t3 0616] count for t3v0297 = " r(N)
quietly count if !missing(t3v0308)
display as text "[TRACE t3 0617] count for t3v0308 = " r(N)
quietly count if !missing(t3v0319)
display as text "[TRACE t3 0618] count for t3v0319 = " r(N)
quietly count if !missing(t3v0330)
display as text "[TRACE t3 0619] count for t3v0330 = " r(N)
quietly count if !missing(t3v0341)
display as text "[TRACE t3 0620] count for t3v0341 = " r(N)
quietly count if !missing(t3v0352)
display as text "[TRACE t3 0621] count for t3v0352 = " r(N)
quietly count if !missing(t3v0363)
display as text "[TRACE t3 0622] count for t3v0363 = " r(N)
quietly count if !missing(t3v0374)
display as text "[TRACE t3 0623] count for t3v0374 = " r(N)
quietly count if !missing(t3v0385)
display as text "[TRACE t3 0624] count for t3v0385 = " r(N)
quietly count if !missing(t3v0396)
display as text "[TRACE t3 0625] count for t3v0396 = " r(N)
quietly count if !missing(t3v0407)
display as text "[TRACE t3 0626] count for t3v0407 = " r(N)
quietly count if !missing(t3v0418)
display as text "[TRACE t3 0627] count for t3v0418 = " r(N)
quietly count if !missing(t3v0429)
display as text "[TRACE t3 0628] count for t3v0429 = " r(N)
quietly count if !missing(t3v0440)
display as text "[TRACE t3 0629] count for t3v0440 = " r(N)
quietly summarize t3v0440, detail
display as text "[TRACE-DETAIL t3 0629] p50=" %9.4f r(p50)
quietly count if !missing(t3v0451)
display as text "[TRACE t3 0630] count for t3v0451 = " r(N)
quietly count if !missing(t3v0462)
display as text "[TRACE t3 0631] count for t3v0462 = " r(N)
quietly count if !missing(t3v0473)
display as text "[TRACE t3 0632] count for t3v0473 = " r(N)
quietly count if !missing(t3v0484)
display as text "[TRACE t3 0633] count for t3v0484 = " r(N)
quietly count if !missing(t3v0495)
display as text "[TRACE t3 0634] count for t3v0495 = " r(N)
quietly count if !missing(t3v0506)
display as text "[TRACE t3 0635] count for t3v0506 = " r(N)
quietly count if !missing(t3v0517)
display as text "[TRACE t3 0636] count for t3v0517 = " r(N)
quietly count if !missing(t3v0528)
display as text "[TRACE t3 0637] count for t3v0528 = " r(N)
quietly count if !missing(t3v0539)
display as text "[TRACE t3 0638] count for t3v0539 = " r(N)
quietly count if !missing(t3v0550)
display as text "[TRACE t3 0639] count for t3v0550 = " r(N)
quietly count if !missing(t3v0561)
display as text "[TRACE t3 0640] count for t3v0561 = " r(N)
quietly count if !missing(t3v0572)
display as text "[TRACE t3 0641] count for t3v0572 = " r(N)
quietly count if !missing(t3v0583)
display as text "[TRACE t3 0642] count for t3v0583 = " r(N)
quietly count if !missing(t3v0594)
display as text "[TRACE t3 0643] count for t3v0594 = " r(N)
quietly count if !missing(t3v0605)
display as text "[TRACE t3 0644] count for t3v0605 = " r(N)
quietly count if !missing(t3v0616)
display as text "[TRACE t3 0645] count for t3v0616 = " r(N)
quietly count if !missing(t3v0627)
display as text "[TRACE t3 0646] count for t3v0627 = " r(N)
quietly summarize t3v0627, detail
display as text "[TRACE-DETAIL t3 0646] p50=" %9.4f r(p50)
quietly count if !missing(t3v0638)
display as text "[TRACE t3 0647] count for t3v0638 = " r(N)
quietly count if !missing(t3v0649)
display as text "[TRACE t3 0648] count for t3v0649 = " r(N)
quietly count if !missing(t3v0660)
display as text "[TRACE t3 0649] count for t3v0660 = " r(N)
quietly count if !missing(t3v0671)
display as text "[TRACE t3 0650] count for t3v0671 = " r(N)
quietly count if !missing(t3v0682)
display as text "[TRACE t3 0651] count for t3v0682 = " r(N)
quietly count if !missing(t3v0693)
display as text "[TRACE t3 0652] count for t3v0693 = " r(N)
quietly count if !missing(t3v0704)
display as text "[TRACE t3 0653] count for t3v0704 = " r(N)
quietly count if !missing(t3v0715)
display as text "[TRACE t3 0654] count for t3v0715 = " r(N)
quietly count if !missing(t3v0006)
display as text "[TRACE t3 0655] count for t3v0006 = " r(N)
quietly count if !missing(t3v0017)
display as text "[TRACE t3 0656] count for t3v0017 = " r(N)
quietly count if !missing(t3v0028)
display as text "[TRACE t3 0657] count for t3v0028 = " r(N)
quietly count if !missing(t3v0039)
display as text "[TRACE t3 0658] count for t3v0039 = " r(N)
quietly count if !missing(t3v0050)
display as text "[TRACE t3 0659] count for t3v0050 = " r(N)
quietly count if !missing(t3v0061)
display as text "[TRACE t3 0660] count for t3v0061 = " r(N)
quietly count if !missing(t3v0072)
display as text "[TRACE t3 0661] count for t3v0072 = " r(N)
quietly count if !missing(t3v0083)
display as text "[TRACE t3 0662] count for t3v0083 = " r(N)
quietly count if !missing(t3v0094)
display as text "[TRACE t3 0663] count for t3v0094 = " r(N)
quietly summarize t3v0094, detail
display as text "[TRACE-DETAIL t3 0663] p50=" %9.4f r(p50)
quietly count if !missing(t3v0105)
display as text "[TRACE t3 0664] count for t3v0105 = " r(N)
quietly count if !missing(t3v0116)
display as text "[TRACE t3 0665] count for t3v0116 = " r(N)
quietly count if !missing(t3v0127)
display as text "[TRACE t3 0666] count for t3v0127 = " r(N)
quietly count if !missing(t3v0138)
display as text "[TRACE t3 0667] count for t3v0138 = " r(N)
quietly count if !missing(t3v0149)
display as text "[TRACE t3 0668] count for t3v0149 = " r(N)
quietly count if !missing(t3v0160)
display as text "[TRACE t3 0669] count for t3v0160 = " r(N)
quietly count if !missing(t3v0171)
display as text "[TRACE t3 0670] count for t3v0171 = " r(N)
quietly count if !missing(t3v0182)
display as text "[TRACE t3 0671] count for t3v0182 = " r(N)
quietly count if !missing(t3v0193)
display as text "[TRACE t3 0672] count for t3v0193 = " r(N)
quietly count if !missing(t3v0204)
display as text "[TRACE t3 0673] count for t3v0204 = " r(N)
quietly count if !missing(t3v0215)
display as text "[TRACE t3 0674] count for t3v0215 = " r(N)
quietly count if !missing(t3v0226)
display as text "[TRACE t3 0675] count for t3v0226 = " r(N)
quietly count if !missing(t3v0237)
display as text "[TRACE t3 0676] count for t3v0237 = " r(N)
quietly count if !missing(t3v0248)
display as text "[TRACE t3 0677] count for t3v0248 = " r(N)
quietly count if !missing(t3v0259)
display as text "[TRACE t3 0678] count for t3v0259 = " r(N)
quietly count if !missing(t3v0270)
display as text "[TRACE t3 0679] count for t3v0270 = " r(N)
quietly count if !missing(t3v0281)
display as text "[TRACE t3 0680] count for t3v0281 = " r(N)
quietly summarize t3v0281, detail
display as text "[TRACE-DETAIL t3 0680] p50=" %9.4f r(p50)
quietly count if !missing(t3v0292)
display as text "[TRACE t3 0681] count for t3v0292 = " r(N)
quietly count if !missing(t3v0303)
display as text "[TRACE t3 0682] count for t3v0303 = " r(N)
quietly count if !missing(t3v0314)
display as text "[TRACE t3 0683] count for t3v0314 = " r(N)
quietly count if !missing(t3v0325)
display as text "[TRACE t3 0684] count for t3v0325 = " r(N)
quietly count if !missing(t3v0336)
display as text "[TRACE t3 0685] count for t3v0336 = " r(N)
quietly count if !missing(t3v0347)
display as text "[TRACE t3 0686] count for t3v0347 = " r(N)
quietly count if !missing(t3v0358)
display as text "[TRACE t3 0687] count for t3v0358 = " r(N)
quietly count if !missing(t3v0369)
display as text "[TRACE t3 0688] count for t3v0369 = " r(N)
quietly count if !missing(t3v0380)
display as text "[TRACE t3 0689] count for t3v0380 = " r(N)
quietly count if !missing(t3v0391)
display as text "[TRACE t3 0690] count for t3v0391 = " r(N)
quietly count if !missing(t3v0402)
display as text "[TRACE t3 0691] count for t3v0402 = " r(N)
quietly count if !missing(t3v0413)
display as text "[TRACE t3 0692] count for t3v0413 = " r(N)
quietly count if !missing(t3v0424)
display as text "[TRACE t3 0693] count for t3v0424 = " r(N)
quietly count if !missing(t3v0435)
display as text "[TRACE t3 0694] count for t3v0435 = " r(N)
quietly count if !missing(t3v0446)
display as text "[TRACE t3 0695] count for t3v0446 = " r(N)
quietly count if !missing(t3v0457)
display as text "[TRACE t3 0696] count for t3v0457 = " r(N)
quietly count if !missing(t3v0468)
display as text "[TRACE t3 0697] count for t3v0468 = " r(N)
quietly summarize t3v0468, detail
display as text "[TRACE-DETAIL t3 0697] p50=" %9.4f r(p50)
quietly count if !missing(t3v0479)
display as text "[TRACE t3 0698] count for t3v0479 = " r(N)
quietly count if !missing(t3v0490)
display as text "[TRACE t3 0699] count for t3v0490 = " r(N)
quietly count if !missing(t3v0501)
display as text "[TRACE t3 0700] count for t3v0501 = " r(N)
quietly count if !missing(t3v0512)
display as text "[TRACE t3 0701] count for t3v0512 = " r(N)
quietly count if !missing(t3v0523)
display as text "[TRACE t3 0702] count for t3v0523 = " r(N)
quietly count if !missing(t3v0534)
display as text "[TRACE t3 0703] count for t3v0534 = " r(N)
quietly count if !missing(t3v0545)
display as text "[TRACE t3 0704] count for t3v0545 = " r(N)
quietly count if !missing(t3v0556)
display as text "[TRACE t3 0705] count for t3v0556 = " r(N)
quietly count if !missing(t3v0567)
display as text "[TRACE t3 0706] count for t3v0567 = " r(N)
quietly count if !missing(t3v0578)
display as text "[TRACE t3 0707] count for t3v0578 = " r(N)
quietly count if !missing(t3v0589)
display as text "[TRACE t3 0708] count for t3v0589 = " r(N)
quietly count if !missing(t3v0600)
display as text "[TRACE t3 0709] count for t3v0600 = " r(N)
quietly count if !missing(t3v0611)
display as text "[TRACE t3 0710] count for t3v0611 = " r(N)
quietly count if !missing(t3v0622)
display as text "[TRACE t3 0711] count for t3v0622 = " r(N)
quietly count if !missing(t3v0633)
display as text "[TRACE t3 0712] count for t3v0633 = " r(N)
quietly count if !missing(t3v0644)
display as text "[TRACE t3 0713] count for t3v0644 = " r(N)
quietly count if !missing(t3v0655)
display as text "[TRACE t3 0714] count for t3v0655 = " r(N)
quietly summarize t3v0655, detail
display as text "[TRACE-DETAIL t3 0714] p50=" %9.4f r(p50)
quietly count if !missing(t3v0666)
display as text "[TRACE t3 0715] count for t3v0666 = " r(N)
quietly count if !missing(t3v0677)
display as text "[TRACE t3 0716] count for t3v0677 = " r(N)
quietly count if !missing(t3v0688)
display as text "[TRACE t3 0717] count for t3v0688 = " r(N)
quietly count if !missing(t3v0699)
display as text "[TRACE t3 0718] count for t3v0699 = " r(N)
quietly count if !missing(t3v0710)
display as text "[TRACE t3 0719] count for t3v0710 = " r(N)
quietly count if !missing(t3v0001)
display as text "[TRACE t3 0720] count for t3v0001 = " r(N)
quietly count if !missing(t3v0012)
display as text "[TRACE t3 0721] count for t3v0012 = " r(N)
quietly count if !missing(t3v0023)
display as text "[TRACE t3 0722] count for t3v0023 = " r(N)
quietly count if !missing(t3v0034)
display as text "[TRACE t3 0723] count for t3v0034 = " r(N)
quietly count if !missing(t3v0045)
display as text "[TRACE t3 0724] count for t3v0045 = " r(N)
quietly count if !missing(t3v0056)
display as text "[TRACE t3 0725] count for t3v0056 = " r(N)
quietly count if !missing(t3v0067)
display as text "[TRACE t3 0726] count for t3v0067 = " r(N)
quietly count if !missing(t3v0078)
display as text "[TRACE t3 0727] count for t3v0078 = " r(N)
quietly count if !missing(t3v0089)
display as text "[TRACE t3 0728] count for t3v0089 = " r(N)
quietly count if !missing(t3v0100)
display as text "[TRACE t3 0729] count for t3v0100 = " r(N)
quietly count if !missing(t3v0111)
display as text "[TRACE t3 0730] count for t3v0111 = " r(N)
quietly count if !missing(t3v0122)
display as text "[TRACE t3 0731] count for t3v0122 = " r(N)
quietly summarize t3v0122, detail
display as text "[TRACE-DETAIL t3 0731] p50=" %9.4f r(p50)
quietly count if !missing(t3v0133)
display as text "[TRACE t3 0732] count for t3v0133 = " r(N)
quietly count if !missing(t3v0144)
display as text "[TRACE t3 0733] count for t3v0144 = " r(N)
quietly count if !missing(t3v0155)
display as text "[TRACE t3 0734] count for t3v0155 = " r(N)
quietly count if !missing(t3v0166)
display as text "[TRACE t3 0735] count for t3v0166 = " r(N)
quietly count if !missing(t3v0177)
display as text "[TRACE t3 0736] count for t3v0177 = " r(N)
quietly count if !missing(t3v0188)
display as text "[TRACE t3 0737] count for t3v0188 = " r(N)
quietly count if !missing(t3v0199)
display as text "[TRACE t3 0738] count for t3v0199 = " r(N)
quietly count if !missing(t3v0210)
display as text "[TRACE t3 0739] count for t3v0210 = " r(N)
quietly count if !missing(t3v0221)
display as text "[TRACE t3 0740] count for t3v0221 = " r(N)
quietly count if !missing(t3v0232)
display as text "[TRACE t3 0741] count for t3v0232 = " r(N)
quietly count if !missing(t3v0243)
display as text "[TRACE t3 0742] count for t3v0243 = " r(N)
quietly count if !missing(t3v0254)
display as text "[TRACE t3 0743] count for t3v0254 = " r(N)
quietly count if !missing(t3v0265)
display as text "[TRACE t3 0744] count for t3v0265 = " r(N)
quietly count if !missing(t3v0276)
display as text "[TRACE t3 0745] count for t3v0276 = " r(N)
quietly count if !missing(t3v0287)
display as text "[TRACE t3 0746] count for t3v0287 = " r(N)
quietly count if !missing(t3v0298)
display as text "[TRACE t3 0747] count for t3v0298 = " r(N)
quietly count if !missing(t3v0309)
display as text "[TRACE t3 0748] count for t3v0309 = " r(N)
quietly summarize t3v0309, detail
display as text "[TRACE-DETAIL t3 0748] p50=" %9.4f r(p50)
quietly count if !missing(t3v0320)
display as text "[TRACE t3 0749] count for t3v0320 = " r(N)
quietly count if !missing(t3v0331)
display as text "[TRACE t3 0750] count for t3v0331 = " r(N)
quietly count if !missing(t3v0342)
display as text "[TRACE t3 0751] count for t3v0342 = " r(N)
quietly count if !missing(t3v0353)
display as text "[TRACE t3 0752] count for t3v0353 = " r(N)
quietly count if !missing(t3v0364)
display as text "[TRACE t3 0753] count for t3v0364 = " r(N)
quietly count if !missing(t3v0375)
display as text "[TRACE t3 0754] count for t3v0375 = " r(N)
quietly count if !missing(t3v0386)
display as text "[TRACE t3 0755] count for t3v0386 = " r(N)
quietly count if !missing(t3v0397)
display as text "[TRACE t3 0756] count for t3v0397 = " r(N)
quietly count if !missing(t3v0408)
display as text "[TRACE t3 0757] count for t3v0408 = " r(N)
quietly count if !missing(t3v0419)
display as text "[TRACE t3 0758] count for t3v0419 = " r(N)
quietly count if !missing(t3v0430)
display as text "[TRACE t3 0759] count for t3v0430 = " r(N)
quietly count if !missing(t3v0441)
display as text "[TRACE t3 0760] count for t3v0441 = " r(N)
quietly count if !missing(t3v0452)
display as text "[TRACE t3 0761] count for t3v0452 = " r(N)
quietly count if !missing(t3v0463)
display as text "[TRACE t3 0762] count for t3v0463 = " r(N)
quietly count if !missing(t3v0474)
display as text "[TRACE t3 0763] count for t3v0474 = " r(N)
quietly count if !missing(t3v0485)
display as text "[TRACE t3 0764] count for t3v0485 = " r(N)
quietly count if !missing(t3v0496)
display as text "[TRACE t3 0765] count for t3v0496 = " r(N)
quietly summarize t3v0496, detail
display as text "[TRACE-DETAIL t3 0765] p50=" %9.4f r(p50)
quietly count if !missing(t3v0507)
display as text "[TRACE t3 0766] count for t3v0507 = " r(N)
quietly count if !missing(t3v0518)
display as text "[TRACE t3 0767] count for t3v0518 = " r(N)
quietly count if !missing(t3v0529)
display as text "[TRACE t3 0768] count for t3v0529 = " r(N)
quietly count if !missing(t3v0540)
display as text "[TRACE t3 0769] count for t3v0540 = " r(N)
quietly count if !missing(t3v0551)
display as text "[TRACE t3 0770] count for t3v0551 = " r(N)
quietly count if !missing(t3v0562)
display as text "[TRACE t3 0771] count for t3v0562 = " r(N)
quietly count if !missing(t3v0573)
display as text "[TRACE t3 0772] count for t3v0573 = " r(N)
quietly count if !missing(t3v0584)
display as text "[TRACE t3 0773] count for t3v0584 = " r(N)
quietly count if !missing(t3v0595)
display as text "[TRACE t3 0774] count for t3v0595 = " r(N)
quietly count if !missing(t3v0606)
display as text "[TRACE t3 0775] count for t3v0606 = " r(N)
quietly count if !missing(t3v0617)
display as text "[TRACE t3 0776] count for t3v0617 = " r(N)
quietly count if !missing(t3v0628)
display as text "[TRACE t3 0777] count for t3v0628 = " r(N)
quietly count if !missing(t3v0639)
display as text "[TRACE t3 0778] count for t3v0639 = " r(N)
quietly count if !missing(t3v0650)
display as text "[TRACE t3 0779] count for t3v0650 = " r(N)
quietly count if !missing(t3v0661)
display as text "[TRACE t3 0780] count for t3v0661 = " r(N)
quietly count if !missing(t3v0672)
display as text "[TRACE t3 0781] count for t3v0672 = " r(N)
quietly count if !missing(t3v0683)
display as text "[TRACE t3 0782] count for t3v0683 = " r(N)
quietly summarize t3v0683, detail
display as text "[TRACE-DETAIL t3 0782] p50=" %9.4f r(p50)
quietly count if !missing(t3v0694)
display as text "[TRACE t3 0783] count for t3v0694 = " r(N)
quietly count if !missing(t3v0705)
display as text "[TRACE t3 0784] count for t3v0705 = " r(N)
quietly count if !missing(t3v0716)
display as text "[TRACE t3 0785] count for t3v0716 = " r(N)
quietly count if !missing(t3v0007)
display as text "[TRACE t3 0786] count for t3v0007 = " r(N)
quietly count if !missing(t3v0018)
display as text "[TRACE t3 0787] count for t3v0018 = " r(N)
quietly count if !missing(t3v0029)
display as text "[TRACE t3 0788] count for t3v0029 = " r(N)
quietly count if !missing(t3v0040)
display as text "[TRACE t3 0789] count for t3v0040 = " r(N)
quietly count if !missing(t3v0051)
display as text "[TRACE t3 0790] count for t3v0051 = " r(N)
quietly count if !missing(t3v0062)
display as text "[TRACE t3 0791] count for t3v0062 = " r(N)
quietly count if !missing(t3v0073)
display as text "[TRACE t3 0792] count for t3v0073 = " r(N)
quietly count if !missing(t3v0084)
display as text "[TRACE t3 0793] count for t3v0084 = " r(N)
quietly count if !missing(t3v0095)
display as text "[TRACE t3 0794] count for t3v0095 = " r(N)
quietly count if !missing(t3v0106)
display as text "[TRACE t3 0795] count for t3v0106 = " r(N)
quietly count if !missing(t3v0117)
display as text "[TRACE t3 0796] count for t3v0117 = " r(N)
quietly count if !missing(t3v0128)
display as text "[TRACE t3 0797] count for t3v0128 = " r(N)
quietly count if !missing(t3v0139)
display as text "[TRACE t3 0798] count for t3v0139 = " r(N)
quietly count if !missing(t3v0150)
display as text "[TRACE t3 0799] count for t3v0150 = " r(N)
quietly summarize t3v0150, detail
display as text "[TRACE-DETAIL t3 0799] p50=" %9.4f r(p50)
quietly count if !missing(t3v0161)
display as text "[TRACE t3 0800] count for t3v0161 = " r(N)
quietly count if !missing(t3v0172)
display as text "[TRACE t3 0801] count for t3v0172 = " r(N)
quietly count if !missing(t3v0183)
display as text "[TRACE t3 0802] count for t3v0183 = " r(N)
quietly count if !missing(t3v0194)
display as text "[TRACE t3 0803] count for t3v0194 = " r(N)
quietly count if !missing(t3v0205)
display as text "[TRACE t3 0804] count for t3v0205 = " r(N)
quietly count if !missing(t3v0216)
display as text "[TRACE t3 0805] count for t3v0216 = " r(N)
quietly count if !missing(t3v0227)
display as text "[TRACE t3 0806] count for t3v0227 = " r(N)
quietly count if !missing(t3v0238)
display as text "[TRACE t3 0807] count for t3v0238 = " r(N)
quietly count if !missing(t3v0249)
display as text "[TRACE t3 0808] count for t3v0249 = " r(N)
quietly count if !missing(t3v0260)
display as text "[TRACE t3 0809] count for t3v0260 = " r(N)
quietly count if !missing(t3v0271)
display as text "[TRACE t3 0810] count for t3v0271 = " r(N)
quietly count if !missing(t3v0282)
display as text "[TRACE t3 0811] count for t3v0282 = " r(N)
quietly count if !missing(t3v0293)
display as text "[TRACE t3 0812] count for t3v0293 = " r(N)
quietly count if !missing(t3v0304)
display as text "[TRACE t3 0813] count for t3v0304 = " r(N)
quietly count if !missing(t3v0315)
display as text "[TRACE t3 0814] count for t3v0315 = " r(N)
quietly count if !missing(t3v0326)
display as text "[TRACE t3 0815] count for t3v0326 = " r(N)
quietly count if !missing(t3v0337)
display as text "[TRACE t3 0816] count for t3v0337 = " r(N)
quietly summarize t3v0337, detail
display as text "[TRACE-DETAIL t3 0816] p50=" %9.4f r(p50)
quietly count if !missing(t3v0348)
display as text "[TRACE t3 0817] count for t3v0348 = " r(N)
quietly count if !missing(t3v0359)
display as text "[TRACE t3 0818] count for t3v0359 = " r(N)
quietly count if !missing(t3v0370)
display as text "[TRACE t3 0819] count for t3v0370 = " r(N)
quietly count if !missing(t3v0381)
display as text "[TRACE t3 0820] count for t3v0381 = " r(N)
quietly count if !missing(t3v0392)
display as text "[TRACE t3 0821] count for t3v0392 = " r(N)
quietly count if !missing(t3v0403)
display as text "[TRACE t3 0822] count for t3v0403 = " r(N)
quietly count if !missing(t3v0414)
display as text "[TRACE t3 0823] count for t3v0414 = " r(N)
quietly count if !missing(t3v0425)
display as text "[TRACE t3 0824] count for t3v0425 = " r(N)
quietly count if !missing(t3v0436)
display as text "[TRACE t3 0825] count for t3v0436 = " r(N)
quietly count if !missing(t3v0447)
display as text "[TRACE t3 0826] count for t3v0447 = " r(N)
quietly count if !missing(t3v0458)
display as text "[TRACE t3 0827] count for t3v0458 = " r(N)
quietly count if !missing(t3v0469)
display as text "[TRACE t3 0828] count for t3v0469 = " r(N)
quietly count if !missing(t3v0480)
display as text "[TRACE t3 0829] count for t3v0480 = " r(N)
quietly count if !missing(t3v0491)
display as text "[TRACE t3 0830] count for t3v0491 = " r(N)
quietly count if !missing(t3v0502)
display as text "[TRACE t3 0831] count for t3v0502 = " r(N)
quietly count if !missing(t3v0513)
display as text "[TRACE t3 0832] count for t3v0513 = " r(N)
quietly count if !missing(t3v0524)
display as text "[TRACE t3 0833] count for t3v0524 = " r(N)
quietly summarize t3v0524, detail
display as text "[TRACE-DETAIL t3 0833] p50=" %9.4f r(p50)
quietly count if !missing(t3v0535)
display as text "[TRACE t3 0834] count for t3v0535 = " r(N)
quietly count if !missing(t3v0546)
display as text "[TRACE t3 0835] count for t3v0546 = " r(N)
quietly count if !missing(t3v0557)
display as text "[TRACE t3 0836] count for t3v0557 = " r(N)
quietly count if !missing(t3v0568)
display as text "[TRACE t3 0837] count for t3v0568 = " r(N)
quietly count if !missing(t3v0579)
display as text "[TRACE t3 0838] count for t3v0579 = " r(N)
quietly count if !missing(t3v0590)
display as text "[TRACE t3 0839] count for t3v0590 = " r(N)
quietly count if !missing(t3v0601)
display as text "[TRACE t3 0840] count for t3v0601 = " r(N)
quietly count if !missing(t3v0612)
display as text "[TRACE t3 0841] count for t3v0612 = " r(N)
quietly count if !missing(t3v0623)
display as text "[TRACE t3 0842] count for t3v0623 = " r(N)
quietly count if !missing(t3v0634)
display as text "[TRACE t3 0843] count for t3v0634 = " r(N)
quietly count if !missing(t3v0645)
display as text "[TRACE t3 0844] count for t3v0645 = " r(N)
quietly count if !missing(t3v0656)
display as text "[TRACE t3 0845] count for t3v0656 = " r(N)
quietly count if !missing(t3v0667)
display as text "[TRACE t3 0846] count for t3v0667 = " r(N)
quietly count if !missing(t3v0678)
display as text "[TRACE t3 0847] count for t3v0678 = " r(N)
quietly count if !missing(t3v0689)
display as text "[TRACE t3 0848] count for t3v0689 = " r(N)
quietly count if !missing(t3v0700)
display as text "[TRACE t3 0849] count for t3v0700 = " r(N)
quietly count if !missing(t3v0711)
display as text "[TRACE t3 0850] count for t3v0711 = " r(N)
quietly summarize t3v0711, detail
display as text "[TRACE-DETAIL t3 0850] p50=" %9.4f r(p50)
quietly count if !missing(t3v0002)
display as text "[TRACE t3 0851] count for t3v0002 = " r(N)
quietly count if !missing(t3v0013)
display as text "[TRACE t3 0852] count for t3v0013 = " r(N)
quietly count if !missing(t3v0024)
display as text "[TRACE t3 0853] count for t3v0024 = " r(N)
quietly count if !missing(t3v0035)
display as text "[TRACE t3 0854] count for t3v0035 = " r(N)
quietly count if !missing(t3v0046)
display as text "[TRACE t3 0855] count for t3v0046 = " r(N)
quietly count if !missing(t3v0057)
display as text "[TRACE t3 0856] count for t3v0057 = " r(N)
quietly count if !missing(t3v0068)
display as text "[TRACE t3 0857] count for t3v0068 = " r(N)
quietly count if !missing(t3v0079)
display as text "[TRACE t3 0858] count for t3v0079 = " r(N)
quietly count if !missing(t3v0090)
display as text "[TRACE t3 0859] count for t3v0090 = " r(N)
quietly count if !missing(t3v0101)
display as text "[TRACE t3 0860] count for t3v0101 = " r(N)
quietly count if !missing(t3v0112)
display as text "[TRACE t3 0861] count for t3v0112 = " r(N)
quietly count if !missing(t3v0123)
display as text "[TRACE t3 0862] count for t3v0123 = " r(N)
quietly count if !missing(t3v0134)
display as text "[TRACE t3 0863] count for t3v0134 = " r(N)
quietly count if !missing(t3v0145)
display as text "[TRACE t3 0864] count for t3v0145 = " r(N)
quietly count if !missing(t3v0156)
display as text "[TRACE t3 0865] count for t3v0156 = " r(N)
quietly count if !missing(t3v0167)
display as text "[TRACE t3 0866] count for t3v0167 = " r(N)
quietly count if !missing(t3v0178)
display as text "[TRACE t3 0867] count for t3v0178 = " r(N)
quietly summarize t3v0178, detail
display as text "[TRACE-DETAIL t3 0867] p50=" %9.4f r(p50)
quietly count if !missing(t3v0189)
display as text "[TRACE t3 0868] count for t3v0189 = " r(N)
quietly count if !missing(t3v0200)
display as text "[TRACE t3 0869] count for t3v0200 = " r(N)
quietly count if !missing(t3v0211)
display as text "[TRACE t3 0870] count for t3v0211 = " r(N)
quietly count if !missing(t3v0222)
display as text "[TRACE t3 0871] count for t3v0222 = " r(N)
quietly count if !missing(t3v0233)
display as text "[TRACE t3 0872] count for t3v0233 = " r(N)
quietly count if !missing(t3v0244)
display as text "[TRACE t3 0873] count for t3v0244 = " r(N)
quietly count if !missing(t3v0255)
display as text "[TRACE t3 0874] count for t3v0255 = " r(N)
quietly count if !missing(t3v0266)
display as text "[TRACE t3 0875] count for t3v0266 = " r(N)
quietly count if !missing(t3v0277)
display as text "[TRACE t3 0876] count for t3v0277 = " r(N)
quietly count if !missing(t3v0288)
display as text "[TRACE t3 0877] count for t3v0288 = " r(N)
quietly count if !missing(t3v0299)
display as text "[TRACE t3 0878] count for t3v0299 = " r(N)
quietly count if !missing(t3v0310)
display as text "[TRACE t3 0879] count for t3v0310 = " r(N)
quietly count if !missing(t3v0321)
display as text "[TRACE t3 0880] count for t3v0321 = " r(N)
quietly count if !missing(t3v0332)
display as text "[TRACE t3 0881] count for t3v0332 = " r(N)
quietly count if !missing(t3v0343)
display as text "[TRACE t3 0882] count for t3v0343 = " r(N)
quietly count if !missing(t3v0354)
display as text "[TRACE t3 0883] count for t3v0354 = " r(N)
quietly count if !missing(t3v0365)
display as text "[TRACE t3 0884] count for t3v0365 = " r(N)
quietly summarize t3v0365, detail
display as text "[TRACE-DETAIL t3 0884] p50=" %9.4f r(p50)
quietly count if !missing(t3v0376)
display as text "[TRACE t3 0885] count for t3v0376 = " r(N)
quietly count if !missing(t3v0387)
display as text "[TRACE t3 0886] count for t3v0387 = " r(N)
quietly count if !missing(t3v0398)
display as text "[TRACE t3 0887] count for t3v0398 = " r(N)
quietly count if !missing(t3v0409)
display as text "[TRACE t3 0888] count for t3v0409 = " r(N)
quietly count if !missing(t3v0420)
display as text "[TRACE t3 0889] count for t3v0420 = " r(N)
quietly count if !missing(t3v0431)
display as text "[TRACE t3 0890] count for t3v0431 = " r(N)
quietly count if !missing(t3v0442)
display as text "[TRACE t3 0891] count for t3v0442 = " r(N)
quietly count if !missing(t3v0453)
display as text "[TRACE t3 0892] count for t3v0453 = " r(N)
quietly count if !missing(t3v0464)
display as text "[TRACE t3 0893] count for t3v0464 = " r(N)
quietly count if !missing(t3v0475)
display as text "[TRACE t3 0894] count for t3v0475 = " r(N)
quietly count if !missing(t3v0486)
display as text "[TRACE t3 0895] count for t3v0486 = " r(N)
quietly count if !missing(t3v0497)
display as text "[TRACE t3 0896] count for t3v0497 = " r(N)
quietly count if !missing(t3v0508)
display as text "[TRACE t3 0897] count for t3v0508 = " r(N)
quietly count if !missing(t3v0519)
display as text "[TRACE t3 0898] count for t3v0519 = " r(N)
quietly count if !missing(t3v0530)
display as text "[TRACE t3 0899] count for t3v0530 = " r(N)
quietly count if !missing(t3v0541)
display as text "[TRACE t3 0900] count for t3v0541 = " r(N)
display as result "<<< DONE Section 11: trace output and low-latency sentinels"
// #endregion ===== Section 11: trace output and low-latency sentinels =====


// #region ===== Section 12: final save export anchors =====
display as text ">>> START Section 12: final save export anchors"
export delimited using "$docdir/taught_task3_final.csv", replace
save "$tempdir/taught_task3_final.dta", replace
display as result "===== TAUGHT TASK 3 FINAL DONE ====="
display as result "Expected outputs: taught_task3_report.docx, taught_task3_summary.xlsx, taught_task3_final.dta/csv, graphs under figdir"
display as result "<<< DONE Section 12: final save export anchors"
// #endregion ===== Section 12: final save export anchors =====

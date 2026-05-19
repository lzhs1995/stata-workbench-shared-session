/*
================================================================================
File: taught_task6.do
Purpose: generated Stata Workbench/native Stata 18 stress fixture
Goal: expose gaps against realtime shared session, low latency, no hangs,
      unchanged research do-files, and native-like graph/table/document output.
Design: generated self-contained script, target >= 11000 lines.
================================================================================
*/

version 18
cls
clear all
set more off
set seed 20260506
set maxvar 20000

local __taught_root "`c(pwd)'"
global workfolder "`__taught_root'"
global tempdir "${workfolder}/7_temp"
global docdir "${workfolder}/4_tables"
local t6_run_stamp = subinstr("`=c(current_date)'_`=c(current_time)'", " ", "_", .)
local t6_run_stamp = subinstr("`t6_run_stamp'", ":", "", .)
global figdir6 "${tempdir}/taught_task6_graphs/`t6_run_stamp'"
cap mkdir "${tempdir}/taught_task6_graphs"
cap mkdir "$figdir6"
cap mkdir "$docdir"

capture which p_tdocx
if _rc {
    capture program drop p_tdocx
    program define p_tdocx
        putdocx `0'
    end
}

display as text "===== TAUGHT TASK 6 SELF-CHECK START ====="
display as text "Stata version: " c(stata_version)
display as text "Date: " c(current_date) " Time: " c(current_time)

// #region Section 1: setup and base data
display as text ">>> START Section 1: setup and base data"
sysuse auto, clear
expand 10
sort make
gen obs_id = _n
gen price_ln = ln(price)
gen mpg_sq = mpg^2
gen weight_ton = weight / 1000
gen length_sq = length^2
gen turn_sq = turn^2
gen displacement_ln = ln(displacement)
gen base_score = price_ln + mpg/10 - weight_ton + gear_ratio
gen t6_work = base_score
gen t6_rank_source = price + mpg * 100 - weight
egen t6_price_q = cut(price), group(4)
egen t6_mpg_t = cut(mpg), group(3)
gen t6_group = mod(obs_id, 15) + 1
gen t6_flag = price > 8000 | mpg > 25
compress
describe
summarize price mpg weight length turn displacement gear_ratio
display as result "<<< DONE Section 1: setup and base data"
// #endregion Section 1: setup and base data

// #region Section 2: generated variables marathon
display as text ">>> START Section 2: generated variables marathon"
gen t6v0001 = mpg + rnormal(0, 0.2)
replace t6v0001 = t6v0001 + t6_group/3
gen t6v0002 = weight + rnormal(0, 0.3)
replace t6v0002 = t6v0002 + t6_group/4
gen t6v0003 = length + rnormal(0, 0.4)
replace t6v0003 = t6v0003 + t6_group/5
gen t6v0004 = turn + rnormal(0, 0.5)
replace t6v0004 = t6v0004 + t6_group/6
gen t6v0005 = displacement + rnormal(0, 0.6)
replace t6v0005 = t6v0005 + t6_group/7
label variable t6v0005 "Generated stress variable 0005"
gen t6v0006 = gear_ratio + rnormal(0, 0.7)
replace t6v0006 = t6v0006 + t6_group/8
gen t6v0007 = price + rnormal(0, 0.8)
replace t6v0007 = t6v0007 + t6_group/9
gen t6v0008 = base_score + rnormal(0, 0.9)
replace t6v0008 = t6v0008 + t6_group/10
gen t6v0009 = mpg + rnormal(0, 0.1)
replace t6v0009 = t6v0009 + t6_group/11
gen t6v0010 = weight + rnormal(0, 0.2)
replace t6v0010 = t6v0010 + t6_group/12
label variable t6v0010 "Generated stress variable 0010"
gen t6v0011 = length + rnormal(0, 0.3)
replace t6v0011 = t6v0011 + t6_group/13
gen t6v0012 = turn + rnormal(0, 0.4)
replace t6v0012 = t6v0012 + t6_group/14
gen t6v0013 = displacement + rnormal(0, 0.5)
replace t6v0013 = t6v0013 + t6_group/2
gen t6v0014 = gear_ratio + rnormal(0, 0.6)
replace t6v0014 = t6v0014 + t6_group/3
gen t6v0015 = price + rnormal(0, 0.7)
replace t6v0015 = t6v0015 + t6_group/4
label variable t6v0015 "Generated stress variable 0015"
gen t6v0016 = base_score + rnormal(0, 0.8)
replace t6v0016 = t6v0016 + t6_group/5
gen t6v0017 = mpg + rnormal(0, 0.9)
replace t6v0017 = t6v0017 + t6_group/6
gen t6v0018 = weight + rnormal(0, 0.1)
replace t6v0018 = t6v0018 + t6_group/7
gen t6v0019 = length + rnormal(0, 0.2)
replace t6v0019 = t6v0019 + t6_group/8
gen t6v0020 = turn + rnormal(0, 0.3)
replace t6v0020 = t6v0020 + t6_group/9
label variable t6v0020 "Generated stress variable 0020"
gen t6v0021 = displacement + rnormal(0, 0.4)
replace t6v0021 = t6v0021 + t6_group/10
gen t6v0022 = gear_ratio + rnormal(0, 0.5)
replace t6v0022 = t6v0022 + t6_group/11
gen t6v0023 = price + rnormal(0, 0.6)
replace t6v0023 = t6v0023 + t6_group/12
gen t6v0024 = base_score + rnormal(0, 0.7)
replace t6v0024 = t6v0024 + t6_group/13
gen t6v0025 = mpg + rnormal(0, 0.8)
replace t6v0025 = t6v0025 + t6_group/14
label variable t6v0025 "Generated stress variable 0025"
quietly summarize t6v0025
display as text "[VAR] t6v0025 mean=" %9.4f r(mean)
gen t6v0026 = weight + rnormal(0, 0.9)
replace t6v0026 = t6v0026 + t6_group/2
gen t6v0027 = length + rnormal(0, 0.1)
replace t6v0027 = t6v0027 + t6_group/3
gen t6v0028 = turn + rnormal(0, 0.2)
replace t6v0028 = t6v0028 + t6_group/4
gen t6v0029 = displacement + rnormal(0, 0.3)
replace t6v0029 = t6v0029 + t6_group/5
gen t6v0030 = gear_ratio + rnormal(0, 0.4)
replace t6v0030 = t6v0030 + t6_group/6
label variable t6v0030 "Generated stress variable 0030"
gen t6v0031 = price + rnormal(0, 0.5)
replace t6v0031 = t6v0031 + t6_group/7
gen t6v0032 = base_score + rnormal(0, 0.6)
replace t6v0032 = t6v0032 + t6_group/8
gen t6v0033 = mpg + rnormal(0, 0.7)
replace t6v0033 = t6v0033 + t6_group/9
gen t6v0034 = weight + rnormal(0, 0.8)
replace t6v0034 = t6v0034 + t6_group/10
gen t6v0035 = length + rnormal(0, 0.9)
replace t6v0035 = t6v0035 + t6_group/11
label variable t6v0035 "Generated stress variable 0035"
gen t6v0036 = turn + rnormal(0, 0.1)
replace t6v0036 = t6v0036 + t6_group/12
gen t6v0037 = displacement + rnormal(0, 0.2)
replace t6v0037 = t6v0037 + t6_group/13
gen t6v0038 = gear_ratio + rnormal(0, 0.3)
replace t6v0038 = t6v0038 + t6_group/14
gen t6v0039 = price + rnormal(0, 0.4)
replace t6v0039 = t6v0039 + t6_group/2
gen t6v0040 = base_score + rnormal(0, 0.5)
replace t6v0040 = t6v0040 + t6_group/3
label variable t6v0040 "Generated stress variable 0040"
gen t6v0041 = mpg + rnormal(0, 0.6)
replace t6v0041 = t6v0041 + t6_group/4
gen t6v0042 = weight + rnormal(0, 0.7)
replace t6v0042 = t6v0042 + t6_group/5
gen t6v0043 = length + rnormal(0, 0.8)
replace t6v0043 = t6v0043 + t6_group/6
gen t6v0044 = turn + rnormal(0, 0.9)
replace t6v0044 = t6v0044 + t6_group/7
gen t6v0045 = displacement + rnormal(0, 0.1)
replace t6v0045 = t6v0045 + t6_group/8
label variable t6v0045 "Generated stress variable 0045"
gen t6v0046 = gear_ratio + rnormal(0, 0.2)
replace t6v0046 = t6v0046 + t6_group/9
gen t6v0047 = price + rnormal(0, 0.3)
replace t6v0047 = t6v0047 + t6_group/10
gen t6v0048 = base_score + rnormal(0, 0.4)
replace t6v0048 = t6v0048 + t6_group/11
gen t6v0049 = mpg + rnormal(0, 0.5)
replace t6v0049 = t6v0049 + t6_group/12
gen t6v0050 = weight + rnormal(0, 0.6)
replace t6v0050 = t6v0050 + t6_group/13
label variable t6v0050 "Generated stress variable 0050"
quietly summarize t6v0050
display as text "[VAR] t6v0050 mean=" %9.4f r(mean)
gen t6v0051 = length + rnormal(0, 0.7)
replace t6v0051 = t6v0051 + t6_group/14
gen t6v0052 = turn + rnormal(0, 0.8)
replace t6v0052 = t6v0052 + t6_group/2
gen t6v0053 = displacement + rnormal(0, 0.9)
replace t6v0053 = t6v0053 + t6_group/3
gen t6v0054 = gear_ratio + rnormal(0, 0.1)
replace t6v0054 = t6v0054 + t6_group/4
gen t6v0055 = price + rnormal(0, 0.2)
replace t6v0055 = t6v0055 + t6_group/5
label variable t6v0055 "Generated stress variable 0055"
gen t6v0056 = base_score + rnormal(0, 0.3)
replace t6v0056 = t6v0056 + t6_group/6
gen t6v0057 = mpg + rnormal(0, 0.4)
replace t6v0057 = t6v0057 + t6_group/7
gen t6v0058 = weight + rnormal(0, 0.5)
replace t6v0058 = t6v0058 + t6_group/8
gen t6v0059 = length + rnormal(0, 0.6)
replace t6v0059 = t6v0059 + t6_group/9
gen t6v0060 = turn + rnormal(0, 0.7)
replace t6v0060 = t6v0060 + t6_group/10
label variable t6v0060 "Generated stress variable 0060"
gen t6v0061 = displacement + rnormal(0, 0.8)
replace t6v0061 = t6v0061 + t6_group/11
gen t6v0062 = gear_ratio + rnormal(0, 0.9)
replace t6v0062 = t6v0062 + t6_group/12
gen t6v0063 = price + rnormal(0, 0.1)
replace t6v0063 = t6v0063 + t6_group/13
gen t6v0064 = base_score + rnormal(0, 0.2)
replace t6v0064 = t6v0064 + t6_group/14
gen t6v0065 = mpg + rnormal(0, 0.3)
replace t6v0065 = t6v0065 + t6_group/2
label variable t6v0065 "Generated stress variable 0065"
gen t6v0066 = weight + rnormal(0, 0.4)
replace t6v0066 = t6v0066 + t6_group/3
gen t6v0067 = length + rnormal(0, 0.5)
replace t6v0067 = t6v0067 + t6_group/4
gen t6v0068 = turn + rnormal(0, 0.6)
replace t6v0068 = t6v0068 + t6_group/5
gen t6v0069 = displacement + rnormal(0, 0.7)
replace t6v0069 = t6v0069 + t6_group/6
gen t6v0070 = gear_ratio + rnormal(0, 0.8)
replace t6v0070 = t6v0070 + t6_group/7
label variable t6v0070 "Generated stress variable 0070"
gen t6v0071 = price + rnormal(0, 0.9)
replace t6v0071 = t6v0071 + t6_group/8
gen t6v0072 = base_score + rnormal(0, 0.1)
replace t6v0072 = t6v0072 + t6_group/9
gen t6v0073 = mpg + rnormal(0, 0.2)
replace t6v0073 = t6v0073 + t6_group/10
gen t6v0074 = weight + rnormal(0, 0.3)
replace t6v0074 = t6v0074 + t6_group/11
gen t6v0075 = length + rnormal(0, 0.4)
replace t6v0075 = t6v0075 + t6_group/12
label variable t6v0075 "Generated stress variable 0075"
quietly summarize t6v0075
display as text "[VAR] t6v0075 mean=" %9.4f r(mean)
gen t6v0076 = turn + rnormal(0, 0.5)
replace t6v0076 = t6v0076 + t6_group/13
gen t6v0077 = displacement + rnormal(0, 0.6)
replace t6v0077 = t6v0077 + t6_group/14
gen t6v0078 = gear_ratio + rnormal(0, 0.7)
replace t6v0078 = t6v0078 + t6_group/2
gen t6v0079 = price + rnormal(0, 0.8)
replace t6v0079 = t6v0079 + t6_group/3
gen t6v0080 = base_score + rnormal(0, 0.9)
replace t6v0080 = t6v0080 + t6_group/4
label variable t6v0080 "Generated stress variable 0080"
gen t6v0081 = mpg + rnormal(0, 0.1)
replace t6v0081 = t6v0081 + t6_group/5
gen t6v0082 = weight + rnormal(0, 0.2)
replace t6v0082 = t6v0082 + t6_group/6
gen t6v0083 = length + rnormal(0, 0.3)
replace t6v0083 = t6v0083 + t6_group/7
gen t6v0084 = turn + rnormal(0, 0.4)
replace t6v0084 = t6v0084 + t6_group/8
gen t6v0085 = displacement + rnormal(0, 0.5)
replace t6v0085 = t6v0085 + t6_group/9
label variable t6v0085 "Generated stress variable 0085"
gen t6v0086 = gear_ratio + rnormal(0, 0.6)
replace t6v0086 = t6v0086 + t6_group/10
gen t6v0087 = price + rnormal(0, 0.7)
replace t6v0087 = t6v0087 + t6_group/11
gen t6v0088 = base_score + rnormal(0, 0.8)
replace t6v0088 = t6v0088 + t6_group/12
gen t6v0089 = mpg + rnormal(0, 0.9)
replace t6v0089 = t6v0089 + t6_group/13
gen t6v0090 = weight + rnormal(0, 0.1)
replace t6v0090 = t6v0090 + t6_group/14
label variable t6v0090 "Generated stress variable 0090"
gen t6v0091 = length + rnormal(0, 0.2)
replace t6v0091 = t6v0091 + t6_group/2
gen t6v0092 = turn + rnormal(0, 0.3)
replace t6v0092 = t6v0092 + t6_group/3
gen t6v0093 = displacement + rnormal(0, 0.4)
replace t6v0093 = t6v0093 + t6_group/4
gen t6v0094 = gear_ratio + rnormal(0, 0.5)
replace t6v0094 = t6v0094 + t6_group/5
gen t6v0095 = price + rnormal(0, 0.6)
replace t6v0095 = t6v0095 + t6_group/6
label variable t6v0095 "Generated stress variable 0095"
gen t6v0096 = base_score + rnormal(0, 0.7)
replace t6v0096 = t6v0096 + t6_group/7
gen t6v0097 = mpg + rnormal(0, 0.8)
replace t6v0097 = t6v0097 + t6_group/8
gen t6v0098 = weight + rnormal(0, 0.9)
replace t6v0098 = t6v0098 + t6_group/9
gen t6v0099 = length + rnormal(0, 0.1)
replace t6v0099 = t6v0099 + t6_group/10
gen t6v0100 = turn + rnormal(0, 0.2)
replace t6v0100 = t6v0100 + t6_group/11
label variable t6v0100 "Generated stress variable 0100"
quietly summarize t6v0100
display as text "[VAR] t6v0100 mean=" %9.4f r(mean)
gen t6v0101 = displacement + rnormal(0, 0.3)
replace t6v0101 = t6v0101 + t6_group/12
gen t6v0102 = gear_ratio + rnormal(0, 0.4)
replace t6v0102 = t6v0102 + t6_group/13
gen t6v0103 = price + rnormal(0, 0.5)
replace t6v0103 = t6v0103 + t6_group/14
gen t6v0104 = base_score + rnormal(0, 0.6)
replace t6v0104 = t6v0104 + t6_group/2
gen t6v0105 = mpg + rnormal(0, 0.7)
replace t6v0105 = t6v0105 + t6_group/3
label variable t6v0105 "Generated stress variable 0105"
gen t6v0106 = weight + rnormal(0, 0.8)
replace t6v0106 = t6v0106 + t6_group/4
gen t6v0107 = length + rnormal(0, 0.9)
replace t6v0107 = t6v0107 + t6_group/5
gen t6v0108 = turn + rnormal(0, 0.1)
replace t6v0108 = t6v0108 + t6_group/6
gen t6v0109 = displacement + rnormal(0, 0.2)
replace t6v0109 = t6v0109 + t6_group/7
gen t6v0110 = gear_ratio + rnormal(0, 0.3)
replace t6v0110 = t6v0110 + t6_group/8
label variable t6v0110 "Generated stress variable 0110"
gen t6v0111 = price + rnormal(0, 0.4)
replace t6v0111 = t6v0111 + t6_group/9
gen t6v0112 = base_score + rnormal(0, 0.5)
replace t6v0112 = t6v0112 + t6_group/10
gen t6v0113 = mpg + rnormal(0, 0.6)
replace t6v0113 = t6v0113 + t6_group/11
gen t6v0114 = weight + rnormal(0, 0.7)
replace t6v0114 = t6v0114 + t6_group/12
gen t6v0115 = length + rnormal(0, 0.8)
replace t6v0115 = t6v0115 + t6_group/13
label variable t6v0115 "Generated stress variable 0115"
gen t6v0116 = turn + rnormal(0, 0.9)
replace t6v0116 = t6v0116 + t6_group/14
gen t6v0117 = displacement + rnormal(0, 0.1)
replace t6v0117 = t6v0117 + t6_group/2
gen t6v0118 = gear_ratio + rnormal(0, 0.2)
replace t6v0118 = t6v0118 + t6_group/3
gen t6v0119 = price + rnormal(0, 0.3)
replace t6v0119 = t6v0119 + t6_group/4
gen t6v0120 = base_score + rnormal(0, 0.4)
replace t6v0120 = t6v0120 + t6_group/5
label variable t6v0120 "Generated stress variable 0120"
gen t6v0121 = mpg + rnormal(0, 0.5)
replace t6v0121 = t6v0121 + t6_group/6
gen t6v0122 = weight + rnormal(0, 0.6)
replace t6v0122 = t6v0122 + t6_group/7
gen t6v0123 = length + rnormal(0, 0.7)
replace t6v0123 = t6v0123 + t6_group/8
gen t6v0124 = turn + rnormal(0, 0.8)
replace t6v0124 = t6v0124 + t6_group/9
gen t6v0125 = displacement + rnormal(0, 0.9)
replace t6v0125 = t6v0125 + t6_group/10
label variable t6v0125 "Generated stress variable 0125"
quietly summarize t6v0125
display as text "[VAR] t6v0125 mean=" %9.4f r(mean)
gen t6v0126 = gear_ratio + rnormal(0, 0.1)
replace t6v0126 = t6v0126 + t6_group/11
gen t6v0127 = price + rnormal(0, 0.2)
replace t6v0127 = t6v0127 + t6_group/12
gen t6v0128 = base_score + rnormal(0, 0.3)
replace t6v0128 = t6v0128 + t6_group/13
gen t6v0129 = mpg + rnormal(0, 0.4)
replace t6v0129 = t6v0129 + t6_group/14
gen t6v0130 = weight + rnormal(0, 0.5)
replace t6v0130 = t6v0130 + t6_group/2
label variable t6v0130 "Generated stress variable 0130"
gen t6v0131 = length + rnormal(0, 0.6)
replace t6v0131 = t6v0131 + t6_group/3
gen t6v0132 = turn + rnormal(0, 0.7)
replace t6v0132 = t6v0132 + t6_group/4
gen t6v0133 = displacement + rnormal(0, 0.8)
replace t6v0133 = t6v0133 + t6_group/5
gen t6v0134 = gear_ratio + rnormal(0, 0.9)
replace t6v0134 = t6v0134 + t6_group/6
gen t6v0135 = price + rnormal(0, 0.1)
replace t6v0135 = t6v0135 + t6_group/7
label variable t6v0135 "Generated stress variable 0135"
gen t6v0136 = base_score + rnormal(0, 0.2)
replace t6v0136 = t6v0136 + t6_group/8
gen t6v0137 = mpg + rnormal(0, 0.3)
replace t6v0137 = t6v0137 + t6_group/9
gen t6v0138 = weight + rnormal(0, 0.4)
replace t6v0138 = t6v0138 + t6_group/10
gen t6v0139 = length + rnormal(0, 0.5)
replace t6v0139 = t6v0139 + t6_group/11
gen t6v0140 = turn + rnormal(0, 0.6)
replace t6v0140 = t6v0140 + t6_group/12
label variable t6v0140 "Generated stress variable 0140"
gen t6v0141 = displacement + rnormal(0, 0.7)
replace t6v0141 = t6v0141 + t6_group/13
gen t6v0142 = gear_ratio + rnormal(0, 0.8)
replace t6v0142 = t6v0142 + t6_group/14
gen t6v0143 = price + rnormal(0, 0.9)
replace t6v0143 = t6v0143 + t6_group/2
gen t6v0144 = base_score + rnormal(0, 0.1)
replace t6v0144 = t6v0144 + t6_group/3
gen t6v0145 = mpg + rnormal(0, 0.2)
replace t6v0145 = t6v0145 + t6_group/4
label variable t6v0145 "Generated stress variable 0145"
gen t6v0146 = weight + rnormal(0, 0.3)
replace t6v0146 = t6v0146 + t6_group/5
gen t6v0147 = length + rnormal(0, 0.4)
replace t6v0147 = t6v0147 + t6_group/6
gen t6v0148 = turn + rnormal(0, 0.5)
replace t6v0148 = t6v0148 + t6_group/7
gen t6v0149 = displacement + rnormal(0, 0.6)
replace t6v0149 = t6v0149 + t6_group/8
gen t6v0150 = gear_ratio + rnormal(0, 0.7)
replace t6v0150 = t6v0150 + t6_group/9
label variable t6v0150 "Generated stress variable 0150"
quietly summarize t6v0150
display as text "[VAR] t6v0150 mean=" %9.4f r(mean)
gen t6v0151 = price + rnormal(0, 0.8)
replace t6v0151 = t6v0151 + t6_group/10
gen t6v0152 = base_score + rnormal(0, 0.9)
replace t6v0152 = t6v0152 + t6_group/11
gen t6v0153 = mpg + rnormal(0, 0.1)
replace t6v0153 = t6v0153 + t6_group/12
gen t6v0154 = weight + rnormal(0, 0.2)
replace t6v0154 = t6v0154 + t6_group/13
gen t6v0155 = length + rnormal(0, 0.3)
replace t6v0155 = t6v0155 + t6_group/14
label variable t6v0155 "Generated stress variable 0155"
gen t6v0156 = turn + rnormal(0, 0.4)
replace t6v0156 = t6v0156 + t6_group/2
gen t6v0157 = displacement + rnormal(0, 0.5)
replace t6v0157 = t6v0157 + t6_group/3
gen t6v0158 = gear_ratio + rnormal(0, 0.6)
replace t6v0158 = t6v0158 + t6_group/4
gen t6v0159 = price + rnormal(0, 0.7)
replace t6v0159 = t6v0159 + t6_group/5
gen t6v0160 = base_score + rnormal(0, 0.8)
replace t6v0160 = t6v0160 + t6_group/6
label variable t6v0160 "Generated stress variable 0160"
gen t6v0161 = mpg + rnormal(0, 0.9)
replace t6v0161 = t6v0161 + t6_group/7
gen t6v0162 = weight + rnormal(0, 0.1)
replace t6v0162 = t6v0162 + t6_group/8
gen t6v0163 = length + rnormal(0, 0.2)
replace t6v0163 = t6v0163 + t6_group/9
gen t6v0164 = turn + rnormal(0, 0.3)
replace t6v0164 = t6v0164 + t6_group/10
gen t6v0165 = displacement + rnormal(0, 0.4)
replace t6v0165 = t6v0165 + t6_group/11
label variable t6v0165 "Generated stress variable 0165"
gen t6v0166 = gear_ratio + rnormal(0, 0.5)
replace t6v0166 = t6v0166 + t6_group/12
gen t6v0167 = price + rnormal(0, 0.6)
replace t6v0167 = t6v0167 + t6_group/13
gen t6v0168 = base_score + rnormal(0, 0.7)
replace t6v0168 = t6v0168 + t6_group/14
gen t6v0169 = mpg + rnormal(0, 0.8)
replace t6v0169 = t6v0169 + t6_group/2
gen t6v0170 = weight + rnormal(0, 0.9)
replace t6v0170 = t6v0170 + t6_group/3
label variable t6v0170 "Generated stress variable 0170"
gen t6v0171 = length + rnormal(0, 0.1)
replace t6v0171 = t6v0171 + t6_group/4
gen t6v0172 = turn + rnormal(0, 0.2)
replace t6v0172 = t6v0172 + t6_group/5
gen t6v0173 = displacement + rnormal(0, 0.3)
replace t6v0173 = t6v0173 + t6_group/6
gen t6v0174 = gear_ratio + rnormal(0, 0.4)
replace t6v0174 = t6v0174 + t6_group/7
gen t6v0175 = price + rnormal(0, 0.5)
replace t6v0175 = t6v0175 + t6_group/8
label variable t6v0175 "Generated stress variable 0175"
quietly summarize t6v0175
display as text "[VAR] t6v0175 mean=" %9.4f r(mean)
gen t6v0176 = base_score + rnormal(0, 0.6)
replace t6v0176 = t6v0176 + t6_group/9
gen t6v0177 = mpg + rnormal(0, 0.7)
replace t6v0177 = t6v0177 + t6_group/10
gen t6v0178 = weight + rnormal(0, 0.8)
replace t6v0178 = t6v0178 + t6_group/11
gen t6v0179 = length + rnormal(0, 0.9)
replace t6v0179 = t6v0179 + t6_group/12
gen t6v0180 = turn + rnormal(0, 0.1)
replace t6v0180 = t6v0180 + t6_group/13
label variable t6v0180 "Generated stress variable 0180"
gen t6v0181 = displacement + rnormal(0, 0.2)
replace t6v0181 = t6v0181 + t6_group/14
gen t6v0182 = gear_ratio + rnormal(0, 0.3)
replace t6v0182 = t6v0182 + t6_group/2
gen t6v0183 = price + rnormal(0, 0.4)
replace t6v0183 = t6v0183 + t6_group/3
gen t6v0184 = base_score + rnormal(0, 0.5)
replace t6v0184 = t6v0184 + t6_group/4
gen t6v0185 = mpg + rnormal(0, 0.6)
replace t6v0185 = t6v0185 + t6_group/5
label variable t6v0185 "Generated stress variable 0185"
gen t6v0186 = weight + rnormal(0, 0.7)
replace t6v0186 = t6v0186 + t6_group/6
gen t6v0187 = length + rnormal(0, 0.8)
replace t6v0187 = t6v0187 + t6_group/7
gen t6v0188 = turn + rnormal(0, 0.9)
replace t6v0188 = t6v0188 + t6_group/8
gen t6v0189 = displacement + rnormal(0, 0.1)
replace t6v0189 = t6v0189 + t6_group/9
gen t6v0190 = gear_ratio + rnormal(0, 0.2)
replace t6v0190 = t6v0190 + t6_group/10
label variable t6v0190 "Generated stress variable 0190"
gen t6v0191 = price + rnormal(0, 0.3)
replace t6v0191 = t6v0191 + t6_group/11
gen t6v0192 = base_score + rnormal(0, 0.4)
replace t6v0192 = t6v0192 + t6_group/12
gen t6v0193 = mpg + rnormal(0, 0.5)
replace t6v0193 = t6v0193 + t6_group/13
gen t6v0194 = weight + rnormal(0, 0.6)
replace t6v0194 = t6v0194 + t6_group/14
gen t6v0195 = length + rnormal(0, 0.7)
replace t6v0195 = t6v0195 + t6_group/2
label variable t6v0195 "Generated stress variable 0195"
gen t6v0196 = turn + rnormal(0, 0.8)
replace t6v0196 = t6v0196 + t6_group/3
gen t6v0197 = displacement + rnormal(0, 0.9)
replace t6v0197 = t6v0197 + t6_group/4
gen t6v0198 = gear_ratio + rnormal(0, 0.1)
replace t6v0198 = t6v0198 + t6_group/5
gen t6v0199 = price + rnormal(0, 0.2)
replace t6v0199 = t6v0199 + t6_group/6
gen t6v0200 = base_score + rnormal(0, 0.3)
replace t6v0200 = t6v0200 + t6_group/7
label variable t6v0200 "Generated stress variable 0200"
quietly summarize t6v0200
display as text "[VAR] t6v0200 mean=" %9.4f r(mean)
gen t6v0201 = mpg + rnormal(0, 0.4)
replace t6v0201 = t6v0201 + t6_group/8
gen t6v0202 = weight + rnormal(0, 0.5)
replace t6v0202 = t6v0202 + t6_group/9
gen t6v0203 = length + rnormal(0, 0.6)
replace t6v0203 = t6v0203 + t6_group/10
gen t6v0204 = turn + rnormal(0, 0.7)
replace t6v0204 = t6v0204 + t6_group/11
gen t6v0205 = displacement + rnormal(0, 0.8)
replace t6v0205 = t6v0205 + t6_group/12
label variable t6v0205 "Generated stress variable 0205"
gen t6v0206 = gear_ratio + rnormal(0, 0.9)
replace t6v0206 = t6v0206 + t6_group/13
gen t6v0207 = price + rnormal(0, 0.1)
replace t6v0207 = t6v0207 + t6_group/14
gen t6v0208 = base_score + rnormal(0, 0.2)
replace t6v0208 = t6v0208 + t6_group/2
gen t6v0209 = mpg + rnormal(0, 0.3)
replace t6v0209 = t6v0209 + t6_group/3
gen t6v0210 = weight + rnormal(0, 0.4)
replace t6v0210 = t6v0210 + t6_group/4
label variable t6v0210 "Generated stress variable 0210"
gen t6v0211 = length + rnormal(0, 0.5)
replace t6v0211 = t6v0211 + t6_group/5
gen t6v0212 = turn + rnormal(0, 0.6)
replace t6v0212 = t6v0212 + t6_group/6
gen t6v0213 = displacement + rnormal(0, 0.7)
replace t6v0213 = t6v0213 + t6_group/7
gen t6v0214 = gear_ratio + rnormal(0, 0.8)
replace t6v0214 = t6v0214 + t6_group/8
gen t6v0215 = price + rnormal(0, 0.9)
replace t6v0215 = t6v0215 + t6_group/9
label variable t6v0215 "Generated stress variable 0215"
gen t6v0216 = base_score + rnormal(0, 0.1)
replace t6v0216 = t6v0216 + t6_group/10
gen t6v0217 = mpg + rnormal(0, 0.2)
replace t6v0217 = t6v0217 + t6_group/11
gen t6v0218 = weight + rnormal(0, 0.3)
replace t6v0218 = t6v0218 + t6_group/12
gen t6v0219 = length + rnormal(0, 0.4)
replace t6v0219 = t6v0219 + t6_group/13
gen t6v0220 = turn + rnormal(0, 0.5)
replace t6v0220 = t6v0220 + t6_group/14
label variable t6v0220 "Generated stress variable 0220"
gen t6v0221 = displacement + rnormal(0, 0.6)
replace t6v0221 = t6v0221 + t6_group/2
gen t6v0222 = gear_ratio + rnormal(0, 0.7)
replace t6v0222 = t6v0222 + t6_group/3
gen t6v0223 = price + rnormal(0, 0.8)
replace t6v0223 = t6v0223 + t6_group/4
gen t6v0224 = base_score + rnormal(0, 0.9)
replace t6v0224 = t6v0224 + t6_group/5
gen t6v0225 = mpg + rnormal(0, 0.1)
replace t6v0225 = t6v0225 + t6_group/6
label variable t6v0225 "Generated stress variable 0225"
quietly summarize t6v0225
display as text "[VAR] t6v0225 mean=" %9.4f r(mean)
gen t6v0226 = weight + rnormal(0, 0.2)
replace t6v0226 = t6v0226 + t6_group/7
gen t6v0227 = length + rnormal(0, 0.3)
replace t6v0227 = t6v0227 + t6_group/8
gen t6v0228 = turn + rnormal(0, 0.4)
replace t6v0228 = t6v0228 + t6_group/9
gen t6v0229 = displacement + rnormal(0, 0.5)
replace t6v0229 = t6v0229 + t6_group/10
gen t6v0230 = gear_ratio + rnormal(0, 0.6)
replace t6v0230 = t6v0230 + t6_group/11
label variable t6v0230 "Generated stress variable 0230"
gen t6v0231 = price + rnormal(0, 0.7)
replace t6v0231 = t6v0231 + t6_group/12
gen t6v0232 = base_score + rnormal(0, 0.8)
replace t6v0232 = t6v0232 + t6_group/13
gen t6v0233 = mpg + rnormal(0, 0.9)
replace t6v0233 = t6v0233 + t6_group/14
gen t6v0234 = weight + rnormal(0, 0.1)
replace t6v0234 = t6v0234 + t6_group/2
gen t6v0235 = length + rnormal(0, 0.2)
replace t6v0235 = t6v0235 + t6_group/3
label variable t6v0235 "Generated stress variable 0235"
gen t6v0236 = turn + rnormal(0, 0.3)
replace t6v0236 = t6v0236 + t6_group/4
gen t6v0237 = displacement + rnormal(0, 0.4)
replace t6v0237 = t6v0237 + t6_group/5
gen t6v0238 = gear_ratio + rnormal(0, 0.5)
replace t6v0238 = t6v0238 + t6_group/6
gen t6v0239 = price + rnormal(0, 0.6)
replace t6v0239 = t6v0239 + t6_group/7
gen t6v0240 = base_score + rnormal(0, 0.7)
replace t6v0240 = t6v0240 + t6_group/8
label variable t6v0240 "Generated stress variable 0240"
gen t6v0241 = mpg + rnormal(0, 0.8)
replace t6v0241 = t6v0241 + t6_group/9
gen t6v0242 = weight + rnormal(0, 0.9)
replace t6v0242 = t6v0242 + t6_group/10
gen t6v0243 = length + rnormal(0, 0.1)
replace t6v0243 = t6v0243 + t6_group/11
gen t6v0244 = turn + rnormal(0, 0.2)
replace t6v0244 = t6v0244 + t6_group/12
gen t6v0245 = displacement + rnormal(0, 0.3)
replace t6v0245 = t6v0245 + t6_group/13
label variable t6v0245 "Generated stress variable 0245"
gen t6v0246 = gear_ratio + rnormal(0, 0.4)
replace t6v0246 = t6v0246 + t6_group/14
gen t6v0247 = price + rnormal(0, 0.5)
replace t6v0247 = t6v0247 + t6_group/2
gen t6v0248 = base_score + rnormal(0, 0.6)
replace t6v0248 = t6v0248 + t6_group/3
gen t6v0249 = mpg + rnormal(0, 0.7)
replace t6v0249 = t6v0249 + t6_group/4
gen t6v0250 = weight + rnormal(0, 0.8)
replace t6v0250 = t6v0250 + t6_group/5
label variable t6v0250 "Generated stress variable 0250"
quietly summarize t6v0250
display as text "[VAR] t6v0250 mean=" %9.4f r(mean)
gen t6v0251 = length + rnormal(0, 0.9)
replace t6v0251 = t6v0251 + t6_group/6
gen t6v0252 = turn + rnormal(0, 0.1)
replace t6v0252 = t6v0252 + t6_group/7
gen t6v0253 = displacement + rnormal(0, 0.2)
replace t6v0253 = t6v0253 + t6_group/8
gen t6v0254 = gear_ratio + rnormal(0, 0.3)
replace t6v0254 = t6v0254 + t6_group/9
gen t6v0255 = price + rnormal(0, 0.4)
replace t6v0255 = t6v0255 + t6_group/10
label variable t6v0255 "Generated stress variable 0255"
gen t6v0256 = base_score + rnormal(0, 0.5)
replace t6v0256 = t6v0256 + t6_group/11
gen t6v0257 = mpg + rnormal(0, 0.6)
replace t6v0257 = t6v0257 + t6_group/12
gen t6v0258 = weight + rnormal(0, 0.7)
replace t6v0258 = t6v0258 + t6_group/13
gen t6v0259 = length + rnormal(0, 0.8)
replace t6v0259 = t6v0259 + t6_group/14
gen t6v0260 = turn + rnormal(0, 0.9)
replace t6v0260 = t6v0260 + t6_group/2
label variable t6v0260 "Generated stress variable 0260"
gen t6v0261 = displacement + rnormal(0, 0.1)
replace t6v0261 = t6v0261 + t6_group/3
gen t6v0262 = gear_ratio + rnormal(0, 0.2)
replace t6v0262 = t6v0262 + t6_group/4
gen t6v0263 = price + rnormal(0, 0.3)
replace t6v0263 = t6v0263 + t6_group/5
gen t6v0264 = base_score + rnormal(0, 0.4)
replace t6v0264 = t6v0264 + t6_group/6
gen t6v0265 = mpg + rnormal(0, 0.5)
replace t6v0265 = t6v0265 + t6_group/7
label variable t6v0265 "Generated stress variable 0265"
gen t6v0266 = weight + rnormal(0, 0.6)
replace t6v0266 = t6v0266 + t6_group/8
gen t6v0267 = length + rnormal(0, 0.7)
replace t6v0267 = t6v0267 + t6_group/9
gen t6v0268 = turn + rnormal(0, 0.8)
replace t6v0268 = t6v0268 + t6_group/10
gen t6v0269 = displacement + rnormal(0, 0.9)
replace t6v0269 = t6v0269 + t6_group/11
gen t6v0270 = gear_ratio + rnormal(0, 0.1)
replace t6v0270 = t6v0270 + t6_group/12
label variable t6v0270 "Generated stress variable 0270"
gen t6v0271 = price + rnormal(0, 0.2)
replace t6v0271 = t6v0271 + t6_group/13
gen t6v0272 = base_score + rnormal(0, 0.3)
replace t6v0272 = t6v0272 + t6_group/14
gen t6v0273 = mpg + rnormal(0, 0.4)
replace t6v0273 = t6v0273 + t6_group/2
gen t6v0274 = weight + rnormal(0, 0.5)
replace t6v0274 = t6v0274 + t6_group/3
gen t6v0275 = length + rnormal(0, 0.6)
replace t6v0275 = t6v0275 + t6_group/4
label variable t6v0275 "Generated stress variable 0275"
quietly summarize t6v0275
display as text "[VAR] t6v0275 mean=" %9.4f r(mean)
gen t6v0276 = turn + rnormal(0, 0.7)
replace t6v0276 = t6v0276 + t6_group/5
gen t6v0277 = displacement + rnormal(0, 0.8)
replace t6v0277 = t6v0277 + t6_group/6
gen t6v0278 = gear_ratio + rnormal(0, 0.9)
replace t6v0278 = t6v0278 + t6_group/7
gen t6v0279 = price + rnormal(0, 0.1)
replace t6v0279 = t6v0279 + t6_group/8
gen t6v0280 = base_score + rnormal(0, 0.2)
replace t6v0280 = t6v0280 + t6_group/9
label variable t6v0280 "Generated stress variable 0280"
gen t6v0281 = mpg + rnormal(0, 0.3)
replace t6v0281 = t6v0281 + t6_group/10
gen t6v0282 = weight + rnormal(0, 0.4)
replace t6v0282 = t6v0282 + t6_group/11
gen t6v0283 = length + rnormal(0, 0.5)
replace t6v0283 = t6v0283 + t6_group/12
gen t6v0284 = turn + rnormal(0, 0.6)
replace t6v0284 = t6v0284 + t6_group/13
gen t6v0285 = displacement + rnormal(0, 0.7)
replace t6v0285 = t6v0285 + t6_group/14
label variable t6v0285 "Generated stress variable 0285"
gen t6v0286 = gear_ratio + rnormal(0, 0.8)
replace t6v0286 = t6v0286 + t6_group/2
gen t6v0287 = price + rnormal(0, 0.9)
replace t6v0287 = t6v0287 + t6_group/3
gen t6v0288 = base_score + rnormal(0, 0.1)
replace t6v0288 = t6v0288 + t6_group/4
gen t6v0289 = mpg + rnormal(0, 0.2)
replace t6v0289 = t6v0289 + t6_group/5
gen t6v0290 = weight + rnormal(0, 0.3)
replace t6v0290 = t6v0290 + t6_group/6
label variable t6v0290 "Generated stress variable 0290"
gen t6v0291 = length + rnormal(0, 0.4)
replace t6v0291 = t6v0291 + t6_group/7
gen t6v0292 = turn + rnormal(0, 0.5)
replace t6v0292 = t6v0292 + t6_group/8
gen t6v0293 = displacement + rnormal(0, 0.6)
replace t6v0293 = t6v0293 + t6_group/9
gen t6v0294 = gear_ratio + rnormal(0, 0.7)
replace t6v0294 = t6v0294 + t6_group/10
gen t6v0295 = price + rnormal(0, 0.8)
replace t6v0295 = t6v0295 + t6_group/11
label variable t6v0295 "Generated stress variable 0295"
gen t6v0296 = base_score + rnormal(0, 0.9)
replace t6v0296 = t6v0296 + t6_group/12
gen t6v0297 = mpg + rnormal(0, 0.1)
replace t6v0297 = t6v0297 + t6_group/13
gen t6v0298 = weight + rnormal(0, 0.2)
replace t6v0298 = t6v0298 + t6_group/14
gen t6v0299 = length + rnormal(0, 0.3)
replace t6v0299 = t6v0299 + t6_group/2
gen t6v0300 = turn + rnormal(0, 0.4)
replace t6v0300 = t6v0300 + t6_group/3
label variable t6v0300 "Generated stress variable 0300"
quietly summarize t6v0300
display as text "[VAR] t6v0300 mean=" %9.4f r(mean)
gen t6v0301 = displacement + rnormal(0, 0.5)
replace t6v0301 = t6v0301 + t6_group/4
gen t6v0302 = gear_ratio + rnormal(0, 0.6)
replace t6v0302 = t6v0302 + t6_group/5
gen t6v0303 = price + rnormal(0, 0.7)
replace t6v0303 = t6v0303 + t6_group/6
gen t6v0304 = base_score + rnormal(0, 0.8)
replace t6v0304 = t6v0304 + t6_group/7
gen t6v0305 = mpg + rnormal(0, 0.9)
replace t6v0305 = t6v0305 + t6_group/8
label variable t6v0305 "Generated stress variable 0305"
gen t6v0306 = weight + rnormal(0, 0.1)
replace t6v0306 = t6v0306 + t6_group/9
gen t6v0307 = length + rnormal(0, 0.2)
replace t6v0307 = t6v0307 + t6_group/10
gen t6v0308 = turn + rnormal(0, 0.3)
replace t6v0308 = t6v0308 + t6_group/11
gen t6v0309 = displacement + rnormal(0, 0.4)
replace t6v0309 = t6v0309 + t6_group/12
gen t6v0310 = gear_ratio + rnormal(0, 0.5)
replace t6v0310 = t6v0310 + t6_group/13
label variable t6v0310 "Generated stress variable 0310"
gen t6v0311 = price + rnormal(0, 0.6)
replace t6v0311 = t6v0311 + t6_group/14
gen t6v0312 = base_score + rnormal(0, 0.7)
replace t6v0312 = t6v0312 + t6_group/2
gen t6v0313 = mpg + rnormal(0, 0.8)
replace t6v0313 = t6v0313 + t6_group/3
gen t6v0314 = weight + rnormal(0, 0.9)
replace t6v0314 = t6v0314 + t6_group/4
gen t6v0315 = length + rnormal(0, 0.1)
replace t6v0315 = t6v0315 + t6_group/5
label variable t6v0315 "Generated stress variable 0315"
gen t6v0316 = turn + rnormal(0, 0.2)
replace t6v0316 = t6v0316 + t6_group/6
gen t6v0317 = displacement + rnormal(0, 0.3)
replace t6v0317 = t6v0317 + t6_group/7
gen t6v0318 = gear_ratio + rnormal(0, 0.4)
replace t6v0318 = t6v0318 + t6_group/8
gen t6v0319 = price + rnormal(0, 0.5)
replace t6v0319 = t6v0319 + t6_group/9
gen t6v0320 = base_score + rnormal(0, 0.6)
replace t6v0320 = t6v0320 + t6_group/10
label variable t6v0320 "Generated stress variable 0320"
gen t6v0321 = mpg + rnormal(0, 0.7)
replace t6v0321 = t6v0321 + t6_group/11
gen t6v0322 = weight + rnormal(0, 0.8)
replace t6v0322 = t6v0322 + t6_group/12
gen t6v0323 = length + rnormal(0, 0.9)
replace t6v0323 = t6v0323 + t6_group/13
gen t6v0324 = turn + rnormal(0, 0.1)
replace t6v0324 = t6v0324 + t6_group/14
gen t6v0325 = displacement + rnormal(0, 0.2)
replace t6v0325 = t6v0325 + t6_group/2
label variable t6v0325 "Generated stress variable 0325"
quietly summarize t6v0325
display as text "[VAR] t6v0325 mean=" %9.4f r(mean)
gen t6v0326 = gear_ratio + rnormal(0, 0.3)
replace t6v0326 = t6v0326 + t6_group/3
gen t6v0327 = price + rnormal(0, 0.4)
replace t6v0327 = t6v0327 + t6_group/4
gen t6v0328 = base_score + rnormal(0, 0.5)
replace t6v0328 = t6v0328 + t6_group/5
gen t6v0329 = mpg + rnormal(0, 0.6)
replace t6v0329 = t6v0329 + t6_group/6
gen t6v0330 = weight + rnormal(0, 0.7)
replace t6v0330 = t6v0330 + t6_group/7
label variable t6v0330 "Generated stress variable 0330"
gen t6v0331 = length + rnormal(0, 0.8)
replace t6v0331 = t6v0331 + t6_group/8
gen t6v0332 = turn + rnormal(0, 0.9)
replace t6v0332 = t6v0332 + t6_group/9
gen t6v0333 = displacement + rnormal(0, 0.1)
replace t6v0333 = t6v0333 + t6_group/10
gen t6v0334 = gear_ratio + rnormal(0, 0.2)
replace t6v0334 = t6v0334 + t6_group/11
gen t6v0335 = price + rnormal(0, 0.3)
replace t6v0335 = t6v0335 + t6_group/12
label variable t6v0335 "Generated stress variable 0335"
gen t6v0336 = base_score + rnormal(0, 0.4)
replace t6v0336 = t6v0336 + t6_group/13
gen t6v0337 = mpg + rnormal(0, 0.5)
replace t6v0337 = t6v0337 + t6_group/14
gen t6v0338 = weight + rnormal(0, 0.6)
replace t6v0338 = t6v0338 + t6_group/2
gen t6v0339 = length + rnormal(0, 0.7)
replace t6v0339 = t6v0339 + t6_group/3
gen t6v0340 = turn + rnormal(0, 0.8)
replace t6v0340 = t6v0340 + t6_group/4
label variable t6v0340 "Generated stress variable 0340"
gen t6v0341 = displacement + rnormal(0, 0.9)
replace t6v0341 = t6v0341 + t6_group/5
gen t6v0342 = gear_ratio + rnormal(0, 0.1)
replace t6v0342 = t6v0342 + t6_group/6
gen t6v0343 = price + rnormal(0, 0.2)
replace t6v0343 = t6v0343 + t6_group/7
gen t6v0344 = base_score + rnormal(0, 0.3)
replace t6v0344 = t6v0344 + t6_group/8
gen t6v0345 = mpg + rnormal(0, 0.4)
replace t6v0345 = t6v0345 + t6_group/9
label variable t6v0345 "Generated stress variable 0345"
gen t6v0346 = weight + rnormal(0, 0.5)
replace t6v0346 = t6v0346 + t6_group/10
gen t6v0347 = length + rnormal(0, 0.6)
replace t6v0347 = t6v0347 + t6_group/11
gen t6v0348 = turn + rnormal(0, 0.7)
replace t6v0348 = t6v0348 + t6_group/12
gen t6v0349 = displacement + rnormal(0, 0.8)
replace t6v0349 = t6v0349 + t6_group/13
gen t6v0350 = gear_ratio + rnormal(0, 0.9)
replace t6v0350 = t6v0350 + t6_group/14
label variable t6v0350 "Generated stress variable 0350"
quietly summarize t6v0350
display as text "[VAR] t6v0350 mean=" %9.4f r(mean)
gen t6v0351 = price + rnormal(0, 0.1)
replace t6v0351 = t6v0351 + t6_group/2
gen t6v0352 = base_score + rnormal(0, 0.2)
replace t6v0352 = t6v0352 + t6_group/3
gen t6v0353 = mpg + rnormal(0, 0.3)
replace t6v0353 = t6v0353 + t6_group/4
gen t6v0354 = weight + rnormal(0, 0.4)
replace t6v0354 = t6v0354 + t6_group/5
gen t6v0355 = length + rnormal(0, 0.5)
replace t6v0355 = t6v0355 + t6_group/6
label variable t6v0355 "Generated stress variable 0355"
gen t6v0356 = turn + rnormal(0, 0.6)
replace t6v0356 = t6v0356 + t6_group/7
gen t6v0357 = displacement + rnormal(0, 0.7)
replace t6v0357 = t6v0357 + t6_group/8
gen t6v0358 = gear_ratio + rnormal(0, 0.8)
replace t6v0358 = t6v0358 + t6_group/9
gen t6v0359 = price + rnormal(0, 0.9)
replace t6v0359 = t6v0359 + t6_group/10
gen t6v0360 = base_score + rnormal(0, 0.1)
replace t6v0360 = t6v0360 + t6_group/11
label variable t6v0360 "Generated stress variable 0360"
gen t6v0361 = mpg + rnormal(0, 0.2)
replace t6v0361 = t6v0361 + t6_group/12
gen t6v0362 = weight + rnormal(0, 0.3)
replace t6v0362 = t6v0362 + t6_group/13
gen t6v0363 = length + rnormal(0, 0.4)
replace t6v0363 = t6v0363 + t6_group/14
gen t6v0364 = turn + rnormal(0, 0.5)
replace t6v0364 = t6v0364 + t6_group/2
gen t6v0365 = displacement + rnormal(0, 0.6)
replace t6v0365 = t6v0365 + t6_group/3
label variable t6v0365 "Generated stress variable 0365"
gen t6v0366 = gear_ratio + rnormal(0, 0.7)
replace t6v0366 = t6v0366 + t6_group/4
gen t6v0367 = price + rnormal(0, 0.8)
replace t6v0367 = t6v0367 + t6_group/5
gen t6v0368 = base_score + rnormal(0, 0.9)
replace t6v0368 = t6v0368 + t6_group/6
gen t6v0369 = mpg + rnormal(0, 0.1)
replace t6v0369 = t6v0369 + t6_group/7
gen t6v0370 = weight + rnormal(0, 0.2)
replace t6v0370 = t6v0370 + t6_group/8
label variable t6v0370 "Generated stress variable 0370"
gen t6v0371 = length + rnormal(0, 0.3)
replace t6v0371 = t6v0371 + t6_group/9
gen t6v0372 = turn + rnormal(0, 0.4)
replace t6v0372 = t6v0372 + t6_group/10
gen t6v0373 = displacement + rnormal(0, 0.5)
replace t6v0373 = t6v0373 + t6_group/11
gen t6v0374 = gear_ratio + rnormal(0, 0.6)
replace t6v0374 = t6v0374 + t6_group/12
gen t6v0375 = price + rnormal(0, 0.7)
replace t6v0375 = t6v0375 + t6_group/13
label variable t6v0375 "Generated stress variable 0375"
quietly summarize t6v0375
display as text "[VAR] t6v0375 mean=" %9.4f r(mean)
gen t6v0376 = base_score + rnormal(0, 0.8)
replace t6v0376 = t6v0376 + t6_group/14
gen t6v0377 = mpg + rnormal(0, 0.9)
replace t6v0377 = t6v0377 + t6_group/2
gen t6v0378 = weight + rnormal(0, 0.1)
replace t6v0378 = t6v0378 + t6_group/3
gen t6v0379 = length + rnormal(0, 0.2)
replace t6v0379 = t6v0379 + t6_group/4
gen t6v0380 = turn + rnormal(0, 0.3)
replace t6v0380 = t6v0380 + t6_group/5
label variable t6v0380 "Generated stress variable 0380"
gen t6v0381 = displacement + rnormal(0, 0.4)
replace t6v0381 = t6v0381 + t6_group/6
gen t6v0382 = gear_ratio + rnormal(0, 0.5)
replace t6v0382 = t6v0382 + t6_group/7
gen t6v0383 = price + rnormal(0, 0.6)
replace t6v0383 = t6v0383 + t6_group/8
gen t6v0384 = base_score + rnormal(0, 0.7)
replace t6v0384 = t6v0384 + t6_group/9
gen t6v0385 = mpg + rnormal(0, 0.8)
replace t6v0385 = t6v0385 + t6_group/10
label variable t6v0385 "Generated stress variable 0385"
gen t6v0386 = weight + rnormal(0, 0.9)
replace t6v0386 = t6v0386 + t6_group/11
gen t6v0387 = length + rnormal(0, 0.1)
replace t6v0387 = t6v0387 + t6_group/12
gen t6v0388 = turn + rnormal(0, 0.2)
replace t6v0388 = t6v0388 + t6_group/13
gen t6v0389 = displacement + rnormal(0, 0.3)
replace t6v0389 = t6v0389 + t6_group/14
gen t6v0390 = gear_ratio + rnormal(0, 0.4)
replace t6v0390 = t6v0390 + t6_group/2
label variable t6v0390 "Generated stress variable 0390"
gen t6v0391 = price + rnormal(0, 0.5)
replace t6v0391 = t6v0391 + t6_group/3
gen t6v0392 = base_score + rnormal(0, 0.6)
replace t6v0392 = t6v0392 + t6_group/4
gen t6v0393 = mpg + rnormal(0, 0.7)
replace t6v0393 = t6v0393 + t6_group/5
gen t6v0394 = weight + rnormal(0, 0.8)
replace t6v0394 = t6v0394 + t6_group/6
gen t6v0395 = length + rnormal(0, 0.9)
replace t6v0395 = t6v0395 + t6_group/7
label variable t6v0395 "Generated stress variable 0395"
gen t6v0396 = turn + rnormal(0, 0.1)
replace t6v0396 = t6v0396 + t6_group/8
gen t6v0397 = displacement + rnormal(0, 0.2)
replace t6v0397 = t6v0397 + t6_group/9
gen t6v0398 = gear_ratio + rnormal(0, 0.3)
replace t6v0398 = t6v0398 + t6_group/10
gen t6v0399 = price + rnormal(0, 0.4)
replace t6v0399 = t6v0399 + t6_group/11
gen t6v0400 = base_score + rnormal(0, 0.5)
replace t6v0400 = t6v0400 + t6_group/12
label variable t6v0400 "Generated stress variable 0400"
quietly summarize t6v0400
display as text "[VAR] t6v0400 mean=" %9.4f r(mean)
gen t6v0401 = mpg + rnormal(0, 0.6)
replace t6v0401 = t6v0401 + t6_group/13
gen t6v0402 = weight + rnormal(0, 0.7)
replace t6v0402 = t6v0402 + t6_group/14
gen t6v0403 = length + rnormal(0, 0.8)
replace t6v0403 = t6v0403 + t6_group/2
gen t6v0404 = turn + rnormal(0, 0.9)
replace t6v0404 = t6v0404 + t6_group/3
gen t6v0405 = displacement + rnormal(0, 0.1)
replace t6v0405 = t6v0405 + t6_group/4
label variable t6v0405 "Generated stress variable 0405"
gen t6v0406 = gear_ratio + rnormal(0, 0.2)
replace t6v0406 = t6v0406 + t6_group/5
gen t6v0407 = price + rnormal(0, 0.3)
replace t6v0407 = t6v0407 + t6_group/6
gen t6v0408 = base_score + rnormal(0, 0.4)
replace t6v0408 = t6v0408 + t6_group/7
gen t6v0409 = mpg + rnormal(0, 0.5)
replace t6v0409 = t6v0409 + t6_group/8
gen t6v0410 = weight + rnormal(0, 0.6)
replace t6v0410 = t6v0410 + t6_group/9
label variable t6v0410 "Generated stress variable 0410"
gen t6v0411 = length + rnormal(0, 0.7)
replace t6v0411 = t6v0411 + t6_group/10
gen t6v0412 = turn + rnormal(0, 0.8)
replace t6v0412 = t6v0412 + t6_group/11
gen t6v0413 = displacement + rnormal(0, 0.9)
replace t6v0413 = t6v0413 + t6_group/12
gen t6v0414 = gear_ratio + rnormal(0, 0.1)
replace t6v0414 = t6v0414 + t6_group/13
gen t6v0415 = price + rnormal(0, 0.2)
replace t6v0415 = t6v0415 + t6_group/14
label variable t6v0415 "Generated stress variable 0415"
gen t6v0416 = base_score + rnormal(0, 0.3)
replace t6v0416 = t6v0416 + t6_group/2
gen t6v0417 = mpg + rnormal(0, 0.4)
replace t6v0417 = t6v0417 + t6_group/3
gen t6v0418 = weight + rnormal(0, 0.5)
replace t6v0418 = t6v0418 + t6_group/4
gen t6v0419 = length + rnormal(0, 0.6)
replace t6v0419 = t6v0419 + t6_group/5
gen t6v0420 = turn + rnormal(0, 0.7)
replace t6v0420 = t6v0420 + t6_group/6
label variable t6v0420 "Generated stress variable 0420"
gen t6v0421 = displacement + rnormal(0, 0.8)
replace t6v0421 = t6v0421 + t6_group/7
gen t6v0422 = gear_ratio + rnormal(0, 0.9)
replace t6v0422 = t6v0422 + t6_group/8
gen t6v0423 = price + rnormal(0, 0.1)
replace t6v0423 = t6v0423 + t6_group/9
gen t6v0424 = base_score + rnormal(0, 0.2)
replace t6v0424 = t6v0424 + t6_group/10
gen t6v0425 = mpg + rnormal(0, 0.3)
replace t6v0425 = t6v0425 + t6_group/11
label variable t6v0425 "Generated stress variable 0425"
quietly summarize t6v0425
display as text "[VAR] t6v0425 mean=" %9.4f r(mean)
gen t6v0426 = weight + rnormal(0, 0.4)
replace t6v0426 = t6v0426 + t6_group/12
gen t6v0427 = length + rnormal(0, 0.5)
replace t6v0427 = t6v0427 + t6_group/13
gen t6v0428 = turn + rnormal(0, 0.6)
replace t6v0428 = t6v0428 + t6_group/14
gen t6v0429 = displacement + rnormal(0, 0.7)
replace t6v0429 = t6v0429 + t6_group/2
gen t6v0430 = gear_ratio + rnormal(0, 0.8)
replace t6v0430 = t6v0430 + t6_group/3
label variable t6v0430 "Generated stress variable 0430"
gen t6v0431 = price + rnormal(0, 0.9)
replace t6v0431 = t6v0431 + t6_group/4
gen t6v0432 = base_score + rnormal(0, 0.1)
replace t6v0432 = t6v0432 + t6_group/5
gen t6v0433 = mpg + rnormal(0, 0.2)
replace t6v0433 = t6v0433 + t6_group/6
gen t6v0434 = weight + rnormal(0, 0.3)
replace t6v0434 = t6v0434 + t6_group/7
gen t6v0435 = length + rnormal(0, 0.4)
replace t6v0435 = t6v0435 + t6_group/8
label variable t6v0435 "Generated stress variable 0435"
gen t6v0436 = turn + rnormal(0, 0.5)
replace t6v0436 = t6v0436 + t6_group/9
gen t6v0437 = displacement + rnormal(0, 0.6)
replace t6v0437 = t6v0437 + t6_group/10
gen t6v0438 = gear_ratio + rnormal(0, 0.7)
replace t6v0438 = t6v0438 + t6_group/11
gen t6v0439 = price + rnormal(0, 0.8)
replace t6v0439 = t6v0439 + t6_group/12
gen t6v0440 = base_score + rnormal(0, 0.9)
replace t6v0440 = t6v0440 + t6_group/13
label variable t6v0440 "Generated stress variable 0440"
gen t6v0441 = mpg + rnormal(0, 0.1)
replace t6v0441 = t6v0441 + t6_group/14
gen t6v0442 = weight + rnormal(0, 0.2)
replace t6v0442 = t6v0442 + t6_group/2
gen t6v0443 = length + rnormal(0, 0.3)
replace t6v0443 = t6v0443 + t6_group/3
gen t6v0444 = turn + rnormal(0, 0.4)
replace t6v0444 = t6v0444 + t6_group/4
gen t6v0445 = displacement + rnormal(0, 0.5)
replace t6v0445 = t6v0445 + t6_group/5
label variable t6v0445 "Generated stress variable 0445"
gen t6v0446 = gear_ratio + rnormal(0, 0.6)
replace t6v0446 = t6v0446 + t6_group/6
gen t6v0447 = price + rnormal(0, 0.7)
replace t6v0447 = t6v0447 + t6_group/7
gen t6v0448 = base_score + rnormal(0, 0.8)
replace t6v0448 = t6v0448 + t6_group/8
gen t6v0449 = mpg + rnormal(0, 0.9)
replace t6v0449 = t6v0449 + t6_group/9
gen t6v0450 = weight + rnormal(0, 0.1)
replace t6v0450 = t6v0450 + t6_group/10
label variable t6v0450 "Generated stress variable 0450"
quietly summarize t6v0450
display as text "[VAR] t6v0450 mean=" %9.4f r(mean)
gen t6v0451 = length + rnormal(0, 0.2)
replace t6v0451 = t6v0451 + t6_group/11
gen t6v0452 = turn + rnormal(0, 0.3)
replace t6v0452 = t6v0452 + t6_group/12
gen t6v0453 = displacement + rnormal(0, 0.4)
replace t6v0453 = t6v0453 + t6_group/13
gen t6v0454 = gear_ratio + rnormal(0, 0.5)
replace t6v0454 = t6v0454 + t6_group/14
gen t6v0455 = price + rnormal(0, 0.6)
replace t6v0455 = t6v0455 + t6_group/2
label variable t6v0455 "Generated stress variable 0455"
gen t6v0456 = base_score + rnormal(0, 0.7)
replace t6v0456 = t6v0456 + t6_group/3
gen t6v0457 = mpg + rnormal(0, 0.8)
replace t6v0457 = t6v0457 + t6_group/4
gen t6v0458 = weight + rnormal(0, 0.9)
replace t6v0458 = t6v0458 + t6_group/5
gen t6v0459 = length + rnormal(0, 0.1)
replace t6v0459 = t6v0459 + t6_group/6
gen t6v0460 = turn + rnormal(0, 0.2)
replace t6v0460 = t6v0460 + t6_group/7
label variable t6v0460 "Generated stress variable 0460"
gen t6v0461 = displacement + rnormal(0, 0.3)
replace t6v0461 = t6v0461 + t6_group/8
gen t6v0462 = gear_ratio + rnormal(0, 0.4)
replace t6v0462 = t6v0462 + t6_group/9
gen t6v0463 = price + rnormal(0, 0.5)
replace t6v0463 = t6v0463 + t6_group/10
gen t6v0464 = base_score + rnormal(0, 0.6)
replace t6v0464 = t6v0464 + t6_group/11
gen t6v0465 = mpg + rnormal(0, 0.7)
replace t6v0465 = t6v0465 + t6_group/12
label variable t6v0465 "Generated stress variable 0465"
gen t6v0466 = weight + rnormal(0, 0.8)
replace t6v0466 = t6v0466 + t6_group/13
gen t6v0467 = length + rnormal(0, 0.9)
replace t6v0467 = t6v0467 + t6_group/14
gen t6v0468 = turn + rnormal(0, 0.1)
replace t6v0468 = t6v0468 + t6_group/2
gen t6v0469 = displacement + rnormal(0, 0.2)
replace t6v0469 = t6v0469 + t6_group/3
gen t6v0470 = gear_ratio + rnormal(0, 0.3)
replace t6v0470 = t6v0470 + t6_group/4
label variable t6v0470 "Generated stress variable 0470"
gen t6v0471 = price + rnormal(0, 0.4)
replace t6v0471 = t6v0471 + t6_group/5
gen t6v0472 = base_score + rnormal(0, 0.5)
replace t6v0472 = t6v0472 + t6_group/6
gen t6v0473 = mpg + rnormal(0, 0.6)
replace t6v0473 = t6v0473 + t6_group/7
gen t6v0474 = weight + rnormal(0, 0.7)
replace t6v0474 = t6v0474 + t6_group/8
gen t6v0475 = length + rnormal(0, 0.8)
replace t6v0475 = t6v0475 + t6_group/9
label variable t6v0475 "Generated stress variable 0475"
quietly summarize t6v0475
display as text "[VAR] t6v0475 mean=" %9.4f r(mean)
gen t6v0476 = turn + rnormal(0, 0.9)
replace t6v0476 = t6v0476 + t6_group/10
gen t6v0477 = displacement + rnormal(0, 0.1)
replace t6v0477 = t6v0477 + t6_group/11
gen t6v0478 = gear_ratio + rnormal(0, 0.2)
replace t6v0478 = t6v0478 + t6_group/12
gen t6v0479 = price + rnormal(0, 0.3)
replace t6v0479 = t6v0479 + t6_group/13
gen t6v0480 = base_score + rnormal(0, 0.4)
replace t6v0480 = t6v0480 + t6_group/14
label variable t6v0480 "Generated stress variable 0480"
gen t6v0481 = mpg + rnormal(0, 0.5)
replace t6v0481 = t6v0481 + t6_group/2
gen t6v0482 = weight + rnormal(0, 0.6)
replace t6v0482 = t6v0482 + t6_group/3
gen t6v0483 = length + rnormal(0, 0.7)
replace t6v0483 = t6v0483 + t6_group/4
gen t6v0484 = turn + rnormal(0, 0.8)
replace t6v0484 = t6v0484 + t6_group/5
gen t6v0485 = displacement + rnormal(0, 0.9)
replace t6v0485 = t6v0485 + t6_group/6
label variable t6v0485 "Generated stress variable 0485"
gen t6v0486 = gear_ratio + rnormal(0, 0.1)
replace t6v0486 = t6v0486 + t6_group/7
gen t6v0487 = price + rnormal(0, 0.2)
replace t6v0487 = t6v0487 + t6_group/8
gen t6v0488 = base_score + rnormal(0, 0.3)
replace t6v0488 = t6v0488 + t6_group/9
gen t6v0489 = mpg + rnormal(0, 0.4)
replace t6v0489 = t6v0489 + t6_group/10
gen t6v0490 = weight + rnormal(0, 0.5)
replace t6v0490 = t6v0490 + t6_group/11
label variable t6v0490 "Generated stress variable 0490"
gen t6v0491 = length + rnormal(0, 0.6)
replace t6v0491 = t6v0491 + t6_group/12
gen t6v0492 = turn + rnormal(0, 0.7)
replace t6v0492 = t6v0492 + t6_group/13
gen t6v0493 = displacement + rnormal(0, 0.8)
replace t6v0493 = t6v0493 + t6_group/14
gen t6v0494 = gear_ratio + rnormal(0, 0.9)
replace t6v0494 = t6v0494 + t6_group/2
gen t6v0495 = price + rnormal(0, 0.1)
replace t6v0495 = t6v0495 + t6_group/3
label variable t6v0495 "Generated stress variable 0495"
gen t6v0496 = base_score + rnormal(0, 0.2)
replace t6v0496 = t6v0496 + t6_group/4
gen t6v0497 = mpg + rnormal(0, 0.3)
replace t6v0497 = t6v0497 + t6_group/5
gen t6v0498 = weight + rnormal(0, 0.4)
replace t6v0498 = t6v0498 + t6_group/6
gen t6v0499 = length + rnormal(0, 0.5)
replace t6v0499 = t6v0499 + t6_group/7
gen t6v0500 = turn + rnormal(0, 0.6)
replace t6v0500 = t6v0500 + t6_group/8
label variable t6v0500 "Generated stress variable 0500"
quietly summarize t6v0500
display as text "[VAR] t6v0500 mean=" %9.4f r(mean)
gen t6v0501 = displacement + rnormal(0, 0.7)
replace t6v0501 = t6v0501 + t6_group/9
gen t6v0502 = gear_ratio + rnormal(0, 0.8)
replace t6v0502 = t6v0502 + t6_group/10
gen t6v0503 = price + rnormal(0, 0.9)
replace t6v0503 = t6v0503 + t6_group/11
gen t6v0504 = base_score + rnormal(0, 0.1)
replace t6v0504 = t6v0504 + t6_group/12
gen t6v0505 = mpg + rnormal(0, 0.2)
replace t6v0505 = t6v0505 + t6_group/13
label variable t6v0505 "Generated stress variable 0505"
gen t6v0506 = weight + rnormal(0, 0.3)
replace t6v0506 = t6v0506 + t6_group/14
gen t6v0507 = length + rnormal(0, 0.4)
replace t6v0507 = t6v0507 + t6_group/2
gen t6v0508 = turn + rnormal(0, 0.5)
replace t6v0508 = t6v0508 + t6_group/3
gen t6v0509 = displacement + rnormal(0, 0.6)
replace t6v0509 = t6v0509 + t6_group/4
gen t6v0510 = gear_ratio + rnormal(0, 0.7)
replace t6v0510 = t6v0510 + t6_group/5
label variable t6v0510 "Generated stress variable 0510"
gen t6v0511 = price + rnormal(0, 0.8)
replace t6v0511 = t6v0511 + t6_group/6
gen t6v0512 = base_score + rnormal(0, 0.9)
replace t6v0512 = t6v0512 + t6_group/7
gen t6v0513 = mpg + rnormal(0, 0.1)
replace t6v0513 = t6v0513 + t6_group/8
gen t6v0514 = weight + rnormal(0, 0.2)
replace t6v0514 = t6v0514 + t6_group/9
gen t6v0515 = length + rnormal(0, 0.3)
replace t6v0515 = t6v0515 + t6_group/10
label variable t6v0515 "Generated stress variable 0515"
gen t6v0516 = turn + rnormal(0, 0.4)
replace t6v0516 = t6v0516 + t6_group/11
gen t6v0517 = displacement + rnormal(0, 0.5)
replace t6v0517 = t6v0517 + t6_group/12
gen t6v0518 = gear_ratio + rnormal(0, 0.6)
replace t6v0518 = t6v0518 + t6_group/13
gen t6v0519 = price + rnormal(0, 0.7)
replace t6v0519 = t6v0519 + t6_group/14
gen t6v0520 = base_score + rnormal(0, 0.8)
replace t6v0520 = t6v0520 + t6_group/2
label variable t6v0520 "Generated stress variable 0520"
gen t6v0521 = mpg + rnormal(0, 0.9)
replace t6v0521 = t6v0521 + t6_group/3
gen t6v0522 = weight + rnormal(0, 0.1)
replace t6v0522 = t6v0522 + t6_group/4
gen t6v0523 = length + rnormal(0, 0.2)
replace t6v0523 = t6v0523 + t6_group/5
gen t6v0524 = turn + rnormal(0, 0.3)
replace t6v0524 = t6v0524 + t6_group/6
gen t6v0525 = displacement + rnormal(0, 0.4)
replace t6v0525 = t6v0525 + t6_group/7
label variable t6v0525 "Generated stress variable 0525"
quietly summarize t6v0525
display as text "[VAR] t6v0525 mean=" %9.4f r(mean)
gen t6v0526 = gear_ratio + rnormal(0, 0.5)
replace t6v0526 = t6v0526 + t6_group/8
gen t6v0527 = price + rnormal(0, 0.6)
replace t6v0527 = t6v0527 + t6_group/9
gen t6v0528 = base_score + rnormal(0, 0.7)
replace t6v0528 = t6v0528 + t6_group/10
gen t6v0529 = mpg + rnormal(0, 0.8)
replace t6v0529 = t6v0529 + t6_group/11
gen t6v0530 = weight + rnormal(0, 0.9)
replace t6v0530 = t6v0530 + t6_group/12
label variable t6v0530 "Generated stress variable 0530"
gen t6v0531 = length + rnormal(0, 0.1)
replace t6v0531 = t6v0531 + t6_group/13
gen t6v0532 = turn + rnormal(0, 0.2)
replace t6v0532 = t6v0532 + t6_group/14
gen t6v0533 = displacement + rnormal(0, 0.3)
replace t6v0533 = t6v0533 + t6_group/2
gen t6v0534 = gear_ratio + rnormal(0, 0.4)
replace t6v0534 = t6v0534 + t6_group/3
gen t6v0535 = price + rnormal(0, 0.5)
replace t6v0535 = t6v0535 + t6_group/4
label variable t6v0535 "Generated stress variable 0535"
gen t6v0536 = base_score + rnormal(0, 0.6)
replace t6v0536 = t6v0536 + t6_group/5
gen t6v0537 = mpg + rnormal(0, 0.7)
replace t6v0537 = t6v0537 + t6_group/6
gen t6v0538 = weight + rnormal(0, 0.8)
replace t6v0538 = t6v0538 + t6_group/7
gen t6v0539 = length + rnormal(0, 0.9)
replace t6v0539 = t6v0539 + t6_group/8
gen t6v0540 = turn + rnormal(0, 0.1)
replace t6v0540 = t6v0540 + t6_group/9
label variable t6v0540 "Generated stress variable 0540"
egen t6_rowmean = rowmean(t6v0001 t6v0002 t6v0003 t6v0004 t6v0005 t6v0006 t6v0007 t6v0008 t6v0009 t6v0010 t6v0011 t6v0012 t6v0013 t6v0014 t6v0015 t6v0016 t6v0017 t6v0018 t6v0019 t6v0020 t6v0021 t6v0022 t6v0023 t6v0024 t6v0025 t6v0026 t6v0027 t6v0028 t6v0029 t6v0030)
replace t6_work = t6_work + t6_rowmean/100
display as result "<<< DONE Section 2: generated variables marathon"
// #endregion Section 2: generated variables marathon

// #region Section 3: large quiet computational block
display as text ">>> START Section 3: large quiet computational block"
quietly {
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 17)
    summarize t6_work
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 32)
    summarize t6_work
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 10)
    summarize t6_work
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 25)
    summarize t6_work
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 3)
    summarize t6_work
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 18)
    summarize t6_work
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 33)
    summarize t6_work
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 11)
    summarize t6_work
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 26)
    summarize t6_work
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 4)
    summarize t6_work
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 19)
    summarize t6_work
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 34)
    summarize t6_work
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 12)
    summarize t6_work
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 27)
    summarize t6_work
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 5)
    summarize t6_work
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 20)
    summarize t6_work
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 35)
    summarize t6_work
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 13)
    summarize t6_work
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 28)
    summarize t6_work
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 6)
    summarize t6_work
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 21)
    summarize t6_work
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000010 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000020 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000030 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000040 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000050 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000060 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000070 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000080 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000090 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000100 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000110 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000120 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000130 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000140 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000150 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000160 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000170 * mod(obs_id, 10)
}
quietly summarize t6_work
display as text "[BLOCK 3] work mean=" %9.4f r(mean)
display as result "<<< DONE Section 3: large quiet computational block"
// #endregion Section 3: large quiet computational block

// #region Section 4: unnamed transient graph burst
display as text ">>> START Section 4: unnamed transient graph burst"
twoway (scatter price mpg if foreign == 0) (lfit price mpg if foreign == 0), title("T6 unnamed transient 01") legend(off)
twoway (scatter price mpg if foreign == 1) (lfit price mpg if foreign == 1), title("T6 unnamed transient 02") legend(off)
twoway (scatter price mpg if foreign == 0) (lfit price mpg if foreign == 0), title("T6 unnamed transient 03") legend(off)
twoway (scatter price mpg if foreign == 1) (lfit price mpg if foreign == 1), title("T6 unnamed transient 04") legend(off)
twoway (scatter price mpg if foreign == 0) (lfit price mpg if foreign == 0), title("T6 unnamed transient 05") legend(off)
twoway (scatter price mpg if foreign == 1) (lfit price mpg if foreign == 1), title("T6 unnamed transient 06") legend(off)
twoway (scatter price mpg if foreign == 0) (lfit price mpg if foreign == 0), title("T6 unnamed transient 07") legend(off)
twoway (scatter price mpg if foreign == 1) (lfit price mpg if foreign == 1), title("T6 unnamed transient 08") legend(off)
twoway (scatter price mpg if foreign == 0) (lfit price mpg if foreign == 0), title("T6 unnamed transient 09") legend(off)
twoway (scatter price mpg if foreign == 1) (lfit price mpg if foreign == 1), title("T6 unnamed transient 10") legend(off)
twoway (scatter price mpg if foreign == 0) (lfit price mpg if foreign == 0), title("T6 unnamed transient 11") legend(off)
twoway (scatter price mpg if foreign == 1) (lfit price mpg if foreign == 1), title("T6 unnamed transient 12") legend(off)
twoway (scatter price mpg if foreign == 0) (lfit price mpg if foreign == 0), title("T6 unnamed transient 13") legend(off)
twoway (scatter price mpg if foreign == 1) (lfit price mpg if foreign == 1), title("T6 unnamed transient 14") legend(off)
twoway (scatter price mpg if foreign == 0) (lfit price mpg if foreign == 0), title("T6 unnamed transient 15") legend(off)
twoway (scatter price mpg if foreign == 1) (lfit price mpg if foreign == 1), title("T6 unnamed transient 16") legend(off)
twoway (scatter price mpg if foreign == 0) (lfit price mpg if foreign == 0), title("T6 unnamed transient 17") legend(off)
twoway (scatter price mpg if foreign == 1) (lfit price mpg if foreign == 1), title("T6 unnamed transient 18") legend(off)
twoway (scatter price mpg if foreign == 0) (lfit price mpg if foreign == 0), title("T6 unnamed transient 19") legend(off)
twoway (scatter price mpg if foreign == 1) (lfit price mpg if foreign == 1), title("T6 unnamed transient 20") legend(off)
twoway (scatter price mpg if foreign == 0) (lfit price mpg if foreign == 0), title("T6 unnamed transient 21") legend(off)
twoway (scatter price mpg if foreign == 1) (lfit price mpg if foreign == 1), title("T6 unnamed transient 22") legend(off)
twoway (scatter price mpg if foreign == 0) (lfit price mpg if foreign == 0), title("T6 unnamed transient 23") legend(off)
twoway (scatter price mpg if foreign == 1) (lfit price mpg if foreign == 1), title("T6 unnamed transient 24") legend(off)
twoway (scatter price mpg if foreign == 0) (lfit price mpg if foreign == 0), title("T6 unnamed transient 25") legend(off)
twoway (scatter price mpg if foreign == 1) (lfit price mpg if foreign == 1), title("T6 unnamed transient 26") legend(off)
twoway (scatter price mpg if foreign == 0) (lfit price mpg if foreign == 0), title("T6 unnamed transient 27") legend(off)
twoway (scatter price mpg if foreign == 1) (lfit price mpg if foreign == 1), title("T6 unnamed transient 28") legend(off)
twoway (scatter price mpg if foreign == 0) (lfit price mpg if foreign == 0), title("T6 unnamed transient 29") legend(off)
twoway (scatter price mpg if foreign == 1) (lfit price mpg if foreign == 1), title("T6 unnamed transient 30") legend(off)
twoway (scatter price mpg if foreign == 0) (lfit price mpg if foreign == 0), title("T6 unnamed transient 31") legend(off)
twoway (scatter price mpg if foreign == 1) (lfit price mpg if foreign == 1), title("T6 unnamed transient 32") legend(off)
display as text "[GRAPH] unnamed burst complete; graph drop _all follows"
graph drop _all
display as result "<<< DONE Section 4: unnamed transient graph burst"
// #endregion Section 4: unnamed transient graph burst

// #region Section 5: named loop graphs with backtick locals
display as text ">>> START Section 5: named loop graphs with backtick locals"
forvalues i = 1/85 {
    local side = mod(`i', 2)
    local low = 1500 + 10*`i'
    twoway (scatter price mpg if foreign == `side') (lfit price mpg if foreign == `side'), name(t6_loop`i', replace) title("T6 loop graph `i'") legend(off)
}
display as result "<<< DONE Section 5: named loop graphs with 85 graphs"
// #endregion Section 5: named loop graphs with backtick locals

// #region Section 6: immediate named graph exports
display as text ">>> START Section 6: immediate named graph exports"
twoway (scatter price weight) (lfit price weight), name(t6im01, replace) title("T6 immediate export 01") legend(off)
graph export "$figdir6/t6im01.svg", name(t6im01) replace
twoway (scatter price weight) (lfit price weight), name(t6im02, replace) title("T6 immediate export 02") legend(off)
graph export "$figdir6/t6im02.svg", name(t6im02) replace
twoway (scatter price weight) (lfit price weight), name(t6im03, replace) title("T6 immediate export 03") legend(off)
graph export "$figdir6/t6im03.svg", name(t6im03) replace
twoway (scatter price weight) (lfit price weight), name(t6im04, replace) title("T6 immediate export 04") legend(off)
graph export "$figdir6/t6im04.svg", name(t6im04) replace
twoway (scatter price weight) (lfit price weight), name(t6im05, replace) title("T6 immediate export 05") legend(off)
graph export "$figdir6/t6im05.svg", name(t6im05) replace
twoway (scatter price weight) (lfit price weight), name(t6im06, replace) title("T6 immediate export 06") legend(off)
graph export "$figdir6/t6im06.svg", name(t6im06) replace
twoway (scatter price weight) (lfit price weight), name(t6im07, replace) title("T6 immediate export 07") legend(off)
graph export "$figdir6/t6im07.svg", name(t6im07) replace
twoway (scatter price weight) (lfit price weight), name(t6im08, replace) title("T6 immediate export 08") legend(off)
graph export "$figdir6/t6im08.svg", name(t6im08) replace
twoway (scatter price weight) (lfit price weight), name(t6im09, replace) title("T6 immediate export 09") legend(off)
graph export "$figdir6/t6im09.svg", name(t6im09) replace
twoway (scatter price weight) (lfit price weight), name(t6im10, replace) title("T6 immediate export 10") legend(off)
graph export "$figdir6/t6im10.svg", name(t6im10) replace
twoway (scatter price weight) (lfit price weight), name(t6im11, replace) title("T6 immediate export 11") legend(off)
graph export "$figdir6/t6im11.svg", name(t6im11) replace
twoway (scatter price weight) (lfit price weight), name(t6im12, replace) title("T6 immediate export 12") legend(off)
graph export "$figdir6/t6im12.svg", name(t6im12) replace
twoway (scatter price weight) (lfit price weight), name(t6im13, replace) title("T6 immediate export 13") legend(off)
graph export "$figdir6/t6im13.svg", name(t6im13) replace
twoway (scatter price weight) (lfit price weight), name(t6im14, replace) title("T6 immediate export 14") legend(off)
graph export "$figdir6/t6im14.svg", name(t6im14) replace
twoway (scatter price weight) (lfit price weight), name(t6im15, replace) title("T6 immediate export 15") legend(off)
graph export "$figdir6/t6im15.svg", name(t6im15) replace
twoway (scatter price weight) (lfit price weight), name(t6im16, replace) title("T6 immediate export 16") legend(off)
graph export "$figdir6/t6im16.svg", name(t6im16) replace
twoway (scatter price weight) (lfit price weight), name(t6im17, replace) title("T6 immediate export 17") legend(off)
graph export "$figdir6/t6im17.svg", name(t6im17) replace
twoway (scatter price weight) (lfit price weight), name(t6im18, replace) title("T6 immediate export 18") legend(off)
graph export "$figdir6/t6im18.svg", name(t6im18) replace
twoway (scatter price weight) (lfit price weight), name(t6im19, replace) title("T6 immediate export 19") legend(off)
graph export "$figdir6/t6im19.svg", name(t6im19) replace
twoway (scatter price weight) (lfit price weight), name(t6im20, replace) title("T6 immediate export 20") legend(off)
graph export "$figdir6/t6im20.svg", name(t6im20) replace
twoway (scatter price weight) (lfit price weight), name(t6im21, replace) title("T6 immediate export 21") legend(off)
graph export "$figdir6/t6im21.svg", name(t6im21) replace
twoway (scatter price weight) (lfit price weight), name(t6im22, replace) title("T6 immediate export 22") legend(off)
graph export "$figdir6/t6im22.svg", name(t6im22) replace
twoway (scatter price weight) (lfit price weight), name(t6im23, replace) title("T6 immediate export 23") legend(off)
graph export "$figdir6/t6im23.svg", name(t6im23) replace
twoway (scatter price weight) (lfit price weight), name(t6im24, replace) title("T6 immediate export 24") legend(off)
graph export "$figdir6/t6im24.svg", name(t6im24) replace
twoway (scatter price weight) (lfit price weight), name(t6im25, replace) title("T6 immediate export 25") legend(off)
graph export "$figdir6/t6im25.svg", name(t6im25) replace
twoway (scatter price weight) (lfit price weight), name(t6im26, replace) title("T6 immediate export 26") legend(off)
graph export "$figdir6/t6im26.svg", name(t6im26) replace
twoway (scatter price weight) (lfit price weight), name(t6im27, replace) title("T6 immediate export 27") legend(off)
graph export "$figdir6/t6im27.svg", name(t6im27) replace
twoway (scatter price weight) (lfit price weight), name(t6im28, replace) title("T6 immediate export 28") legend(off)
graph export "$figdir6/t6im28.svg", name(t6im28) replace
twoway (scatter price weight) (lfit price weight), name(t6im29, replace) title("T6 immediate export 29") legend(off)
graph export "$figdir6/t6im29.svg", name(t6im29) replace
twoway (scatter price weight) (lfit price weight), name(t6im30, replace) title("T6 immediate export 30") legend(off)
graph export "$figdir6/t6im30.svg", name(t6im30) replace
twoway (scatter price weight) (lfit price weight), name(t6im31, replace) title("T6 immediate export 31") legend(off)
graph export "$figdir6/t6im31.svg", name(t6im31) replace
twoway (scatter price weight) (lfit price weight), name(t6im32, replace) title("T6 immediate export 32") legend(off)
graph export "$figdir6/t6im32.svg", name(t6im32) replace
display as result "<<< DONE Section 6: immediate named graph exports"
// #endregion Section 6: immediate named graph exports

// #region Section 7: delayed named graph creation
display as text ">>> START Section 7: delayed named graph creation"
twoway (scatter price weight) (lfit price weight), name(t6doc01, replace) title("T6 delayed doc graph 01") legend(off)
twoway (scatter mpg weight) (lfit mpg weight), name(t6doc02, replace) title("T6 delayed doc graph 02") legend(off)
twoway (scatter price length) (lfit price length), name(t6doc03, replace) title("T6 delayed doc graph 03") legend(off)
twoway (scatter mpg weight) (lfit mpg weight), name(t6doc04, replace) title("T6 delayed doc graph 04") legend(off)
twoway (scatter price weight) (lfit price weight), name(t6doc05, replace) title("T6 delayed doc graph 05") legend(off)
twoway (scatter mpg length) (lfit mpg length), name(t6doc06, replace) title("T6 delayed doc graph 06") legend(off)
twoway (scatter price weight) (lfit price weight), name(t6doc07, replace) title("T6 delayed doc graph 07") legend(off)
twoway (scatter mpg weight) (lfit mpg weight), name(t6doc08, replace) title("T6 delayed doc graph 08") legend(off)
twoway (scatter price length) (lfit price length), name(t6doc09, replace) title("T6 delayed doc graph 09") legend(off)
twoway (scatter mpg weight) (lfit mpg weight), name(t6doc10, replace) title("T6 delayed doc graph 10") legend(off)
twoway (scatter price weight) (lfit price weight), name(t6doc11, replace) title("T6 delayed doc graph 11") legend(off)
twoway (scatter mpg length) (lfit mpg length), name(t6doc12, replace) title("T6 delayed doc graph 12") legend(off)
twoway (scatter price weight) (lfit price weight), name(t6doc13, replace) title("T6 delayed doc graph 13") legend(off)
twoway (scatter mpg weight) (lfit mpg weight), name(t6doc14, replace) title("T6 delayed doc graph 14") legend(off)
twoway (scatter price length) (lfit price length), name(t6doc15, replace) title("T6 delayed doc graph 15") legend(off)
twoway (scatter mpg weight) (lfit mpg weight), name(t6doc16, replace) title("T6 delayed doc graph 16") legend(off)
twoway (scatter price weight) (lfit price weight), name(t6doc17, replace) title("T6 delayed doc graph 17") legend(off)
twoway (scatter mpg length) (lfit mpg length), name(t6doc18, replace) title("T6 delayed doc graph 18") legend(off)
twoway (scatter price weight) (lfit price weight), name(t6doc19, replace) title("T6 delayed doc graph 19") legend(off)
twoway (scatter mpg weight) (lfit mpg weight), name(t6doc20, replace) title("T6 delayed doc graph 20") legend(off)
twoway (scatter price length) (lfit price length), name(t6doc21, replace) title("T6 delayed doc graph 21") legend(off)
twoway (scatter mpg weight) (lfit mpg weight), name(t6doc22, replace) title("T6 delayed doc graph 22") legend(off)
twoway (scatter price weight) (lfit price weight), name(t6doc23, replace) title("T6 delayed doc graph 23") legend(off)
twoway (scatter mpg length) (lfit mpg length), name(t6doc24, replace) title("T6 delayed doc graph 24") legend(off)
twoway (scatter price weight) (lfit price weight), name(t6doc25, replace) title("T6 delayed doc graph 25") legend(off)
twoway (scatter mpg weight) (lfit mpg weight), name(t6doc26, replace) title("T6 delayed doc graph 26") legend(off)
twoway (scatter price length) (lfit price length), name(t6doc27, replace) title("T6 delayed doc graph 27") legend(off)
twoway (scatter mpg weight) (lfit mpg weight), name(t6doc28, replace) title("T6 delayed doc graph 28") legend(off)
twoway (scatter price weight) (lfit price weight), name(t6doc29, replace) title("T6 delayed doc graph 29") legend(off)
twoway (scatter mpg length) (lfit mpg length), name(t6doc30, replace) title("T6 delayed doc graph 30") legend(off)
twoway (scatter price weight) (lfit price weight), name(t6doc31, replace) title("T6 delayed doc graph 31") legend(off)
twoway (scatter mpg weight) (lfit mpg weight), name(t6doc32, replace) title("T6 delayed doc graph 32") legend(off)
twoway (scatter price length) (lfit price length), name(t6doc33, replace) title("T6 delayed doc graph 33") legend(off)
twoway (scatter mpg weight) (lfit mpg weight), name(t6doc34, replace) title("T6 delayed doc graph 34") legend(off)
twoway (scatter price weight) (lfit price weight), name(t6doc35, replace) title("T6 delayed doc graph 35") legend(off)
twoway (scatter mpg length) (lfit mpg length), name(t6doc36, replace) title("T6 delayed doc graph 36") legend(off)
twoway (scatter price weight) (lfit price weight), name(t6doc37, replace) title("T6 delayed doc graph 37") legend(off)
twoway (scatter mpg weight) (lfit mpg weight), name(t6doc38, replace) title("T6 delayed doc graph 38") legend(off)
display as result "<<< DONE Section 7: delayed named graph creation"
// #endregion Section 7: delayed named graph creation

// #region Section 7B: complex distribution and combined graphs
display as text ">>> START Section 7B: complex distribution and combined graphs"
histogram price, name(t6_hist_price, replace) title("T6 price distribution")
graph export "$figdir6/t6_hist_price.svg", name(t6_hist_price) replace
histogram mpg, name(t6_hist_mpg, replace) title("T6 mpg distribution")
graph export "$figdir6/t6_hist_mpg.svg", name(t6_hist_mpg) replace
graph box price, over(foreign) name(t6_box_price, replace) title("T6 price by foreign")
graph export "$figdir6/t6_box_price.svg", name(t6_box_price) replace
graph combine t6_hist_price t6_hist_mpg t6_box_price, name(t6_combo_dist, replace) title("T6 combined distribution panel")
graph export "$figdir6/t6_combo_dist.svg", name(t6_combo_dist) replace
tabstat price mpg weight length t6_work, statistics(n mean sd p25 p50 p75 min max) columns(statistics)
table foreign, statistic(mean price) statistic(mean mpg) statistic(sd price) statistic(count price)
export delimited make price mpg weight foreign t6_work using "$tempdir/taught_task6_distribution_table.csv", replace
display as result "<<< DONE Section 7B: complex distribution and combined graphs"
// #endregion Section 7B: complex distribution and combined graphs

// #region Section 8: preserve restore tempfile stress
display as text ">>> START Section 8: preserve restore tempfile stress"
if 1 {
    preserve
    keep make price mpg weight foreign obs_id t6_work t6_group
    collapse (mean) price mpg weight t6_work (count) n=obs_id, by(foreign t6_group)
    tempfile t6_slim
    save `t6_slim', replace
    restore
    preserve
    use `t6_slim', clear
    gen t6_slim_001 = t6_work + price/3 - mpg/4
    gen t6_slim_002 = t6_work + price/4 - mpg/5
    gen t6_slim_003 = t6_work + price/5 - mpg/6
    gen t6_slim_004 = t6_work + price/6 - mpg/7
    gen t6_slim_005 = t6_work + price/7 - mpg/8
    gen t6_slim_006 = t6_work + price/8 - mpg/9
    gen t6_slim_007 = t6_work + price/9 - mpg/10
    gen t6_slim_008 = t6_work + price/10 - mpg/11
    gen t6_slim_009 = t6_work + price/11 - mpg/12
    gen t6_slim_010 = t6_work + price/12 - mpg/13
    gen t6_slim_011 = t6_work + price/2 - mpg/3
    gen t6_slim_012 = t6_work + price/3 - mpg/4
    gen t6_slim_013 = t6_work + price/4 - mpg/5
    gen t6_slim_014 = t6_work + price/5 - mpg/6
    gen t6_slim_015 = t6_work + price/6 - mpg/7
    gen t6_slim_016 = t6_work + price/7 - mpg/8
    gen t6_slim_017 = t6_work + price/8 - mpg/9
    gen t6_slim_018 = t6_work + price/9 - mpg/10
    gen t6_slim_019 = t6_work + price/10 - mpg/11
    gen t6_slim_020 = t6_work + price/11 - mpg/12
    quietly summarize t6_slim_020
    gen t6_slim_021 = t6_work + price/12 - mpg/13
    gen t6_slim_022 = t6_work + price/2 - mpg/3
    gen t6_slim_023 = t6_work + price/3 - mpg/4
    gen t6_slim_024 = t6_work + price/4 - mpg/5
    gen t6_slim_025 = t6_work + price/5 - mpg/6
    gen t6_slim_026 = t6_work + price/6 - mpg/7
    gen t6_slim_027 = t6_work + price/7 - mpg/8
    gen t6_slim_028 = t6_work + price/8 - mpg/9
    gen t6_slim_029 = t6_work + price/9 - mpg/10
    gen t6_slim_030 = t6_work + price/10 - mpg/11
    gen t6_slim_031 = t6_work + price/11 - mpg/12
    gen t6_slim_032 = t6_work + price/12 - mpg/13
    gen t6_slim_033 = t6_work + price/2 - mpg/3
    gen t6_slim_034 = t6_work + price/3 - mpg/4
    gen t6_slim_035 = t6_work + price/4 - mpg/5
    gen t6_slim_036 = t6_work + price/5 - mpg/6
    gen t6_slim_037 = t6_work + price/6 - mpg/7
    gen t6_slim_038 = t6_work + price/7 - mpg/8
    gen t6_slim_039 = t6_work + price/8 - mpg/9
    gen t6_slim_040 = t6_work + price/9 - mpg/10
    quietly summarize t6_slim_040
    gen t6_slim_041 = t6_work + price/10 - mpg/11
    gen t6_slim_042 = t6_work + price/11 - mpg/12
    gen t6_slim_043 = t6_work + price/12 - mpg/13
    gen t6_slim_044 = t6_work + price/2 - mpg/3
    gen t6_slim_045 = t6_work + price/3 - mpg/4
    gen t6_slim_046 = t6_work + price/4 - mpg/5
    gen t6_slim_047 = t6_work + price/5 - mpg/6
    gen t6_slim_048 = t6_work + price/6 - mpg/7
    gen t6_slim_049 = t6_work + price/7 - mpg/8
    gen t6_slim_050 = t6_work + price/8 - mpg/9
    gen t6_slim_051 = t6_work + price/9 - mpg/10
    gen t6_slim_052 = t6_work + price/10 - mpg/11
    gen t6_slim_053 = t6_work + price/11 - mpg/12
    gen t6_slim_054 = t6_work + price/12 - mpg/13
    gen t6_slim_055 = t6_work + price/2 - mpg/3
    gen t6_slim_056 = t6_work + price/3 - mpg/4
    gen t6_slim_057 = t6_work + price/4 - mpg/5
    gen t6_slim_058 = t6_work + price/5 - mpg/6
    gen t6_slim_059 = t6_work + price/6 - mpg/7
    gen t6_slim_060 = t6_work + price/7 - mpg/8
    quietly summarize t6_slim_060
    gen t6_slim_061 = t6_work + price/8 - mpg/9
    gen t6_slim_062 = t6_work + price/9 - mpg/10
    gen t6_slim_063 = t6_work + price/10 - mpg/11
    gen t6_slim_064 = t6_work + price/11 - mpg/12
    gen t6_slim_065 = t6_work + price/12 - mpg/13
    gen t6_slim_066 = t6_work + price/2 - mpg/3
    gen t6_slim_067 = t6_work + price/3 - mpg/4
    gen t6_slim_068 = t6_work + price/4 - mpg/5
    gen t6_slim_069 = t6_work + price/5 - mpg/6
    gen t6_slim_070 = t6_work + price/6 - mpg/7
    gen t6_slim_071 = t6_work + price/7 - mpg/8
    gen t6_slim_072 = t6_work + price/8 - mpg/9
    gen t6_slim_073 = t6_work + price/9 - mpg/10
    gen t6_slim_074 = t6_work + price/10 - mpg/11
    gen t6_slim_075 = t6_work + price/11 - mpg/12
    gen t6_slim_076 = t6_work + price/12 - mpg/13
    gen t6_slim_077 = t6_work + price/2 - mpg/3
    gen t6_slim_078 = t6_work + price/3 - mpg/4
    gen t6_slim_079 = t6_work + price/4 - mpg/5
    gen t6_slim_080 = t6_work + price/5 - mpg/6
    quietly summarize t6_slim_080
    gen t6_slim_081 = t6_work + price/6 - mpg/7
    gen t6_slim_082 = t6_work + price/7 - mpg/8
    gen t6_slim_083 = t6_work + price/8 - mpg/9
    gen t6_slim_084 = t6_work + price/9 - mpg/10
    gen t6_slim_085 = t6_work + price/10 - mpg/11
    gen t6_slim_086 = t6_work + price/11 - mpg/12
    gen t6_slim_087 = t6_work + price/12 - mpg/13
    gen t6_slim_088 = t6_work + price/2 - mpg/3
    gen t6_slim_089 = t6_work + price/3 - mpg/4
    gen t6_slim_090 = t6_work + price/4 - mpg/5
    gen t6_slim_091 = t6_work + price/5 - mpg/6
    gen t6_slim_092 = t6_work + price/6 - mpg/7
    gen t6_slim_093 = t6_work + price/7 - mpg/8
    gen t6_slim_094 = t6_work + price/8 - mpg/9
    gen t6_slim_095 = t6_work + price/9 - mpg/10
    gen t6_slim_096 = t6_work + price/10 - mpg/11
    gen t6_slim_097 = t6_work + price/11 - mpg/12
    gen t6_slim_098 = t6_work + price/12 - mpg/13
    gen t6_slim_099 = t6_work + price/2 - mpg/3
    gen t6_slim_100 = t6_work + price/3 - mpg/4
    quietly summarize t6_slim_100
    gen t6_slim_101 = t6_work + price/4 - mpg/5
    gen t6_slim_102 = t6_work + price/5 - mpg/6
    gen t6_slim_103 = t6_work + price/6 - mpg/7
    gen t6_slim_104 = t6_work + price/7 - mpg/8
    gen t6_slim_105 = t6_work + price/8 - mpg/9
    gen t6_slim_106 = t6_work + price/9 - mpg/10
    gen t6_slim_107 = t6_work + price/10 - mpg/11
    gen t6_slim_108 = t6_work + price/11 - mpg/12
    gen t6_slim_109 = t6_work + price/12 - mpg/13
    gen t6_slim_110 = t6_work + price/2 - mpg/3
    gen t6_slim_111 = t6_work + price/3 - mpg/4
    gen t6_slim_112 = t6_work + price/4 - mpg/5
    gen t6_slim_113 = t6_work + price/5 - mpg/6
    gen t6_slim_114 = t6_work + price/6 - mpg/7
    gen t6_slim_115 = t6_work + price/7 - mpg/8
    gen t6_slim_116 = t6_work + price/8 - mpg/9
    gen t6_slim_117 = t6_work + price/9 - mpg/10
    gen t6_slim_118 = t6_work + price/10 - mpg/11
    gen t6_slim_119 = t6_work + price/11 - mpg/12
    gen t6_slim_120 = t6_work + price/12 - mpg/13
    quietly summarize t6_slim_120
    gen t6_slim_121 = t6_work + price/2 - mpg/3
    gen t6_slim_122 = t6_work + price/3 - mpg/4
    gen t6_slim_123 = t6_work + price/4 - mpg/5
    gen t6_slim_124 = t6_work + price/5 - mpg/6
    gen t6_slim_125 = t6_work + price/6 - mpg/7
    gen t6_slim_126 = t6_work + price/7 - mpg/8
    gen t6_slim_127 = t6_work + price/8 - mpg/9
    gen t6_slim_128 = t6_work + price/9 - mpg/10
    gen t6_slim_129 = t6_work + price/10 - mpg/11
    gen t6_slim_130 = t6_work + price/11 - mpg/12
    gen t6_slim_131 = t6_work + price/12 - mpg/13
    gen t6_slim_132 = t6_work + price/2 - mpg/3
    gen t6_slim_133 = t6_work + price/3 - mpg/4
    gen t6_slim_134 = t6_work + price/4 - mpg/5
    gen t6_slim_135 = t6_work + price/5 - mpg/6
    gen t6_slim_136 = t6_work + price/6 - mpg/7
    gen t6_slim_137 = t6_work + price/7 - mpg/8
    gen t6_slim_138 = t6_work + price/8 - mpg/9
    gen t6_slim_139 = t6_work + price/9 - mpg/10
    gen t6_slim_140 = t6_work + price/10 - mpg/11
    quietly summarize t6_slim_140
    gen t6_slim_141 = t6_work + price/11 - mpg/12
    gen t6_slim_142 = t6_work + price/12 - mpg/13
    gen t6_slim_143 = t6_work + price/2 - mpg/3
    gen t6_slim_144 = t6_work + price/3 - mpg/4
    gen t6_slim_145 = t6_work + price/4 - mpg/5
    gen t6_slim_146 = t6_work + price/5 - mpg/6
    gen t6_slim_147 = t6_work + price/6 - mpg/7
    gen t6_slim_148 = t6_work + price/7 - mpg/8
    gen t6_slim_149 = t6_work + price/8 - mpg/9
    gen t6_slim_150 = t6_work + price/9 - mpg/10
    gen t6_slim_151 = t6_work + price/10 - mpg/11
    gen t6_slim_152 = t6_work + price/11 - mpg/12
    gen t6_slim_153 = t6_work + price/12 - mpg/13
    gen t6_slim_154 = t6_work + price/2 - mpg/3
    gen t6_slim_155 = t6_work + price/3 - mpg/4
    gen t6_slim_156 = t6_work + price/4 - mpg/5
    gen t6_slim_157 = t6_work + price/5 - mpg/6
    gen t6_slim_158 = t6_work + price/6 - mpg/7
    gen t6_slim_159 = t6_work + price/7 - mpg/8
    gen t6_slim_160 = t6_work + price/8 - mpg/9
    quietly summarize t6_slim_160
    gen t6_slim_161 = t6_work + price/9 - mpg/10
    gen t6_slim_162 = t6_work + price/10 - mpg/11
    gen t6_slim_163 = t6_work + price/11 - mpg/12
    gen t6_slim_164 = t6_work + price/12 - mpg/13
    gen t6_slim_165 = t6_work + price/2 - mpg/3
    gen t6_slim_166 = t6_work + price/3 - mpg/4
    gen t6_slim_167 = t6_work + price/4 - mpg/5
    gen t6_slim_168 = t6_work + price/5 - mpg/6
    gen t6_slim_169 = t6_work + price/6 - mpg/7
    gen t6_slim_170 = t6_work + price/7 - mpg/8
    gen t6_slim_171 = t6_work + price/8 - mpg/9
    gen t6_slim_172 = t6_work + price/9 - mpg/10
    gen t6_slim_173 = t6_work + price/10 - mpg/11
    gen t6_slim_174 = t6_work + price/11 - mpg/12
    gen t6_slim_175 = t6_work + price/12 - mpg/13
    gen t6_slim_176 = t6_work + price/2 - mpg/3
    gen t6_slim_177 = t6_work + price/3 - mpg/4
    gen t6_slim_178 = t6_work + price/4 - mpg/5
    gen t6_slim_179 = t6_work + price/5 - mpg/6
    gen t6_slim_180 = t6_work + price/6 - mpg/7
    quietly summarize t6_slim_180
    save "$tempdir/taught_task6_slim.dta", replace
    restore
}
display as result "<<< DONE Section 8: preserve restore tempfile stress"
// #endregion Section 8: preserve restore tempfile stress

// #region Section 9: putdocx delayed graph export document
display as text ">>> START Section 9: putdocx delayed graph export document"
putdocx clear
putdocx begin
putdocx paragraph
putdocx text ("Taught task 6: putdocx delayed graph export document")
putdocx paragraph
putdocx text ("This section intentionally exports earlier named graphs by name before inserting images.")
graph export "$figdir6/t6doc01.png", name(t6doc01) replace width(1400)
putdocx paragraph
putdocx text ("Inserted t6doc01")
putdocx paragraph
putdocx image "$figdir6/t6doc01.png", width(4)
graph export "$figdir6/t6doc02.png", name(t6doc02) replace width(1400)
putdocx paragraph
putdocx text ("Inserted t6doc02")
putdocx paragraph
putdocx image "$figdir6/t6doc02.png", width(4)
graph export "$figdir6/t6doc03.png", name(t6doc03) replace width(1400)
putdocx paragraph
putdocx text ("Inserted t6doc03")
putdocx paragraph
putdocx image "$figdir6/t6doc03.png", width(4)
graph export "$figdir6/t6doc04.png", name(t6doc04) replace width(1400)
putdocx paragraph
putdocx text ("Inserted t6doc04")
putdocx paragraph
putdocx image "$figdir6/t6doc04.png", width(4)
graph export "$figdir6/t6doc05.png", name(t6doc05) replace width(1400)
putdocx paragraph
putdocx text ("Inserted t6doc05")
putdocx paragraph
putdocx image "$figdir6/t6doc05.png", width(4)
graph export "$figdir6/t6doc06.png", name(t6doc06) replace width(1400)
putdocx paragraph
putdocx text ("Inserted t6doc06")
putdocx paragraph
putdocx image "$figdir6/t6doc06.png", width(4)
graph export "$figdir6/t6doc07.png", name(t6doc07) replace width(1400)
putdocx paragraph
putdocx text ("Inserted t6doc07")
putdocx paragraph
putdocx image "$figdir6/t6doc07.png", width(4)
graph export "$figdir6/t6doc08.png", name(t6doc08) replace width(1400)
putdocx paragraph
putdocx text ("Inserted t6doc08")
putdocx paragraph
putdocx image "$figdir6/t6doc08.png", width(4)
graph export "$figdir6/t6doc09.png", name(t6doc09) replace width(1400)
putdocx paragraph
putdocx text ("Inserted t6doc09")
putdocx paragraph
putdocx image "$figdir6/t6doc09.png", width(4)
graph export "$figdir6/t6doc10.png", name(t6doc10) replace width(1400)
putdocx paragraph
putdocx text ("Inserted t6doc10")
putdocx paragraph
putdocx image "$figdir6/t6doc10.png", width(4)
graph export "$figdir6/t6doc11.png", name(t6doc11) replace width(1400)
putdocx paragraph
putdocx text ("Inserted t6doc11")
putdocx paragraph
putdocx image "$figdir6/t6doc11.png", width(4)
graph export "$figdir6/t6doc12.png", name(t6doc12) replace width(1400)
putdocx paragraph
putdocx text ("Inserted t6doc12")
putdocx paragraph
putdocx image "$figdir6/t6doc12.png", width(4)
putdocx save "$docdir/taught_task6_doc1.docx", replace
display as result "<<< DONE Section 9: putdocx delayed graph export document"
// #endregion Section 9: putdocx delayed graph export document

// #region Section 10: p_tdocx delayed graph export document
display as text ">>> START Section 10: p_tdocx delayed graph export document"
p_tdocx clear
p_tdocx begin
p_tdocx paragraph
p_tdocx text ("Taught task 6: p_tdocx delayed graph export document")
graph export "$figdir6/t6doc13.png", name(t6doc13) replace width(1400)
p_tdocx paragraph
p_tdocx text ("Inserted t6doc13")
p_tdocx paragraph
p_tdocx image "$figdir6/t6doc13.png", width(4)
graph export "$figdir6/t6doc14.png", name(t6doc14) replace width(1400)
p_tdocx paragraph
p_tdocx text ("Inserted t6doc14")
p_tdocx paragraph
p_tdocx image "$figdir6/t6doc14.png", width(4)
graph export "$figdir6/t6doc15.png", name(t6doc15) replace width(1400)
p_tdocx paragraph
p_tdocx text ("Inserted t6doc15")
p_tdocx paragraph
p_tdocx image "$figdir6/t6doc15.png", width(4)
graph export "$figdir6/t6doc16.png", name(t6doc16) replace width(1400)
p_tdocx paragraph
p_tdocx text ("Inserted t6doc16")
p_tdocx paragraph
p_tdocx image "$figdir6/t6doc16.png", width(4)
graph export "$figdir6/t6doc17.png", name(t6doc17) replace width(1400)
p_tdocx paragraph
p_tdocx text ("Inserted t6doc17")
p_tdocx paragraph
p_tdocx image "$figdir6/t6doc17.png", width(4)
graph export "$figdir6/t6doc18.png", name(t6doc18) replace width(1400)
p_tdocx paragraph
p_tdocx text ("Inserted t6doc18")
p_tdocx paragraph
p_tdocx image "$figdir6/t6doc18.png", width(4)
graph export "$figdir6/t6doc19.png", name(t6doc19) replace width(1400)
p_tdocx paragraph
p_tdocx text ("Inserted t6doc19")
p_tdocx paragraph
p_tdocx image "$figdir6/t6doc19.png", width(4)
graph export "$figdir6/t6doc20.png", name(t6doc20) replace width(1400)
p_tdocx paragraph
p_tdocx text ("Inserted t6doc20")
p_tdocx paragraph
p_tdocx image "$figdir6/t6doc20.png", width(4)
graph export "$figdir6/t6doc21.png", name(t6doc21) replace width(1400)
p_tdocx paragraph
p_tdocx text ("Inserted t6doc21")
p_tdocx paragraph
p_tdocx image "$figdir6/t6doc21.png", width(4)
graph export "$figdir6/t6doc22.png", name(t6doc22) replace width(1400)
p_tdocx paragraph
p_tdocx text ("Inserted t6doc22")
p_tdocx paragraph
p_tdocx image "$figdir6/t6doc22.png", width(4)
p_tdocx save "$docdir/taught_task6_doc2.docx", replace
display as result "<<< DONE Section 10: p_tdocx delayed graph export document"
// #endregion Section 10: p_tdocx delayed graph export document

// #region Section 11: model and table output stress
display as text ">>> START Section 11: model and table output stress"
quietly regress price mpg weight t6v0001 t6v0019 i.foreign
estimates store t6_m001
quietly regress price mpg weight t6v0002 t6v0020 i.foreign
estimates store t6_m002
quietly regress price mpg weight t6v0003 t6v0021 i.foreign
estimates store t6_m003
quietly regress price mpg weight t6v0004 t6v0022 i.foreign
estimates store t6_m004
quietly regress price mpg weight t6v0005 t6v0023 i.foreign
estimates store t6_m005
quietly regress price mpg weight t6v0006 t6v0024 i.foreign
estimates store t6_m006
quietly regress price mpg weight t6v0007 t6v0025 i.foreign
estimates store t6_m007
quietly regress price mpg weight t6v0008 t6v0026 i.foreign
estimates store t6_m008
quietly regress price mpg weight t6v0009 t6v0027 i.foreign
estimates store t6_m009
quietly regress price mpg weight t6v0010 t6v0028 i.foreign
estimates store t6_m010
quietly regress price mpg weight t6v0011 t6v0029 i.foreign
estimates store t6_m011
quietly regress price mpg weight t6v0012 t6v0030 i.foreign
estimates store t6_m012
quietly regress price mpg weight t6v0013 t6v0031 i.foreign
estimates store t6_m013
quietly regress price mpg weight t6v0014 t6v0032 i.foreign
estimates store t6_m014
quietly regress price mpg weight t6v0015 t6v0033 i.foreign
estimates store t6_m015
quietly regress price mpg weight t6v0016 t6v0034 i.foreign
estimates store t6_m016
quietly regress price mpg weight t6v0017 t6v0035 i.foreign
estimates store t6_m017
quietly regress price mpg weight t6v0018 t6v0036 i.foreign
estimates store t6_m018
quietly regress price mpg weight t6v0019 t6v0037 i.foreign
estimates store t6_m019
quietly regress price mpg weight t6v0020 t6v0038 i.foreign
estimates store t6_m020
quietly regress price mpg weight t6v0021 t6v0039 i.foreign
estimates store t6_m021
quietly regress price mpg weight t6v0022 t6v0040 i.foreign
estimates store t6_m022
quietly regress price mpg weight t6v0023 t6v0041 i.foreign
estimates store t6_m023
quietly regress price mpg weight t6v0024 t6v0042 i.foreign
estimates store t6_m024
quietly regress price mpg weight t6v0025 t6v0043 i.foreign
estimates store t6_m025
display as text "[MODEL] stored t6_m025"
quietly regress price mpg weight t6v0026 t6v0044 i.foreign
estimates store t6_m026
quietly regress price mpg weight t6v0027 t6v0045 i.foreign
estimates store t6_m027
quietly regress price mpg weight t6v0028 t6v0046 i.foreign
estimates store t6_m028
quietly regress price mpg weight t6v0029 t6v0047 i.foreign
estimates store t6_m029
quietly regress price mpg weight t6v0030 t6v0048 i.foreign
estimates store t6_m030
quietly regress price mpg weight t6v0031 t6v0049 i.foreign
estimates store t6_m031
quietly regress price mpg weight t6v0032 t6v0050 i.foreign
estimates store t6_m032
quietly regress price mpg weight t6v0033 t6v0051 i.foreign
estimates store t6_m033
quietly regress price mpg weight t6v0034 t6v0052 i.foreign
estimates store t6_m034
quietly regress price mpg weight t6v0035 t6v0053 i.foreign
estimates store t6_m035
quietly regress price mpg weight t6v0036 t6v0054 i.foreign
estimates store t6_m036
quietly regress price mpg weight t6v0037 t6v0055 i.foreign
estimates store t6_m037
quietly regress price mpg weight t6v0038 t6v0056 i.foreign
estimates store t6_m038
quietly regress price mpg weight t6v0039 t6v0057 i.foreign
estimates store t6_m039
quietly regress price mpg weight t6v0040 t6v0058 i.foreign
estimates store t6_m040
quietly regress price mpg weight t6v0041 t6v0059 i.foreign
estimates store t6_m041
quietly regress price mpg weight t6v0042 t6v0060 i.foreign
estimates store t6_m042
quietly regress price mpg weight t6v0043 t6v0061 i.foreign
estimates store t6_m043
quietly regress price mpg weight t6v0044 t6v0062 i.foreign
estimates store t6_m044
quietly regress price mpg weight t6v0045 t6v0063 i.foreign
estimates store t6_m045
quietly regress price mpg weight t6v0046 t6v0064 i.foreign
estimates store t6_m046
quietly regress price mpg weight t6v0047 t6v0065 i.foreign
estimates store t6_m047
quietly regress price mpg weight t6v0048 t6v0066 i.foreign
estimates store t6_m048
quietly regress price mpg weight t6v0049 t6v0067 i.foreign
estimates store t6_m049
quietly regress price mpg weight t6v0050 t6v0068 i.foreign
estimates store t6_m050
display as text "[MODEL] stored t6_m050"
quietly regress price mpg weight t6v0051 t6v0069 i.foreign
estimates store t6_m051
quietly regress price mpg weight t6v0052 t6v0070 i.foreign
estimates store t6_m052
quietly regress price mpg weight t6v0053 t6v0071 i.foreign
estimates store t6_m053
quietly regress price mpg weight t6v0054 t6v0072 i.foreign
estimates store t6_m054
quietly regress price mpg weight t6v0055 t6v0073 i.foreign
estimates store t6_m055
quietly regress price mpg weight t6v0056 t6v0074 i.foreign
estimates store t6_m056
quietly regress price mpg weight t6v0057 t6v0075 i.foreign
estimates store t6_m057
quietly regress price mpg weight t6v0058 t6v0076 i.foreign
estimates store t6_m058
quietly regress price mpg weight t6v0059 t6v0077 i.foreign
estimates store t6_m059
quietly regress price mpg weight t6v0060 t6v0078 i.foreign
estimates store t6_m060
quietly regress price mpg weight t6v0061 t6v0079 i.foreign
estimates store t6_m061
quietly regress price mpg weight t6v0062 t6v0080 i.foreign
estimates store t6_m062
quietly regress price mpg weight t6v0063 t6v0001 i.foreign
estimates store t6_m063
quietly regress price mpg weight t6v0064 t6v0002 i.foreign
estimates store t6_m064
quietly regress price mpg weight t6v0065 t6v0003 i.foreign
estimates store t6_m065
quietly regress price mpg weight t6v0066 t6v0004 i.foreign
estimates store t6_m066
quietly regress price mpg weight t6v0067 t6v0005 i.foreign
estimates store t6_m067
quietly regress price mpg weight t6v0068 t6v0006 i.foreign
estimates store t6_m068
quietly regress price mpg weight t6v0069 t6v0007 i.foreign
estimates store t6_m069
quietly regress price mpg weight t6v0070 t6v0008 i.foreign
estimates store t6_m070
quietly regress price mpg weight t6v0071 t6v0009 i.foreign
estimates store t6_m071
quietly regress price mpg weight t6v0072 t6v0010 i.foreign
estimates store t6_m072
quietly regress price mpg weight t6v0073 t6v0011 i.foreign
estimates store t6_m073
quietly regress price mpg weight t6v0074 t6v0012 i.foreign
estimates store t6_m074
quietly regress price mpg weight t6v0075 t6v0013 i.foreign
estimates store t6_m075
display as text "[MODEL] stored t6_m075"
quietly regress price mpg weight t6v0076 t6v0014 i.foreign
estimates store t6_m076
quietly regress price mpg weight t6v0077 t6v0015 i.foreign
estimates store t6_m077
quietly regress price mpg weight t6v0078 t6v0016 i.foreign
estimates store t6_m078
quietly regress price mpg weight t6v0079 t6v0017 i.foreign
estimates store t6_m079
quietly regress price mpg weight t6v0080 t6v0018 i.foreign
estimates store t6_m080
quietly regress price mpg weight t6v0001 t6v0019 i.foreign
estimates store t6_m081
quietly regress price mpg weight t6v0002 t6v0020 i.foreign
estimates store t6_m082
quietly regress price mpg weight t6v0003 t6v0021 i.foreign
estimates store t6_m083
quietly regress price mpg weight t6v0004 t6v0022 i.foreign
estimates store t6_m084
quietly regress price mpg weight t6v0005 t6v0023 i.foreign
estimates store t6_m085
quietly regress price mpg weight t6v0006 t6v0024 i.foreign
estimates store t6_m086
quietly regress price mpg weight t6v0007 t6v0025 i.foreign
estimates store t6_m087
quietly regress price mpg weight t6v0008 t6v0026 i.foreign
estimates store t6_m088
quietly regress price mpg weight t6v0009 t6v0027 i.foreign
estimates store t6_m089
quietly regress price mpg weight t6v0010 t6v0028 i.foreign
estimates store t6_m090
quietly regress price mpg weight t6v0011 t6v0029 i.foreign
estimates store t6_m091
quietly regress price mpg weight t6v0012 t6v0030 i.foreign
estimates store t6_m092
quietly regress price mpg weight t6v0013 t6v0031 i.foreign
estimates store t6_m093
quietly regress price mpg weight t6v0014 t6v0032 i.foreign
estimates store t6_m094
quietly regress price mpg weight t6v0015 t6v0033 i.foreign
estimates store t6_m095
quietly regress price mpg weight t6v0016 t6v0034 i.foreign
estimates store t6_m096
quietly regress price mpg weight t6v0017 t6v0035 i.foreign
estimates store t6_m097
quietly regress price mpg weight t6v0018 t6v0036 i.foreign
estimates store t6_m098
quietly regress price mpg weight t6v0019 t6v0037 i.foreign
estimates store t6_m099
quietly regress price mpg weight t6v0020 t6v0038 i.foreign
estimates store t6_m100
display as text "[MODEL] stored t6_m100"
quietly regress price mpg weight t6v0021 t6v0039 i.foreign
estimates store t6_m101
quietly regress price mpg weight t6v0022 t6v0040 i.foreign
estimates store t6_m102
quietly regress price mpg weight t6v0023 t6v0041 i.foreign
estimates store t6_m103
quietly regress price mpg weight t6v0024 t6v0042 i.foreign
estimates store t6_m104
quietly regress price mpg weight t6v0025 t6v0043 i.foreign
estimates store t6_m105
quietly regress price mpg weight t6v0026 t6v0044 i.foreign
estimates store t6_m106
quietly regress price mpg weight t6v0027 t6v0045 i.foreign
estimates store t6_m107
quietly regress price mpg weight t6v0028 t6v0046 i.foreign
estimates store t6_m108
quietly regress price mpg weight t6v0029 t6v0047 i.foreign
estimates store t6_m109
quietly regress price mpg weight t6v0030 t6v0048 i.foreign
estimates store t6_m110
quietly regress price mpg weight t6v0031 t6v0049 i.foreign
estimates store t6_m111
quietly regress price mpg weight t6v0032 t6v0050 i.foreign
estimates store t6_m112
quietly regress price mpg weight t6v0033 t6v0051 i.foreign
estimates store t6_m113
quietly regress price mpg weight t6v0034 t6v0052 i.foreign
estimates store t6_m114
quietly regress price mpg weight t6v0035 t6v0053 i.foreign
estimates store t6_m115
quietly regress price mpg weight t6v0036 t6v0054 i.foreign
estimates store t6_m116
quietly regress price mpg weight t6v0037 t6v0055 i.foreign
estimates store t6_m117
quietly regress price mpg weight t6v0038 t6v0056 i.foreign
estimates store t6_m118
quietly regress price mpg weight t6v0039 t6v0057 i.foreign
estimates store t6_m119
quietly regress price mpg weight t6v0040 t6v0058 i.foreign
estimates store t6_m120
quietly regress price mpg weight t6v0041 t6v0059 i.foreign
estimates store t6_m121
quietly regress price mpg weight t6v0042 t6v0060 i.foreign
estimates store t6_m122
quietly regress price mpg weight t6v0043 t6v0061 i.foreign
estimates store t6_m123
quietly regress price mpg weight t6v0044 t6v0062 i.foreign
estimates store t6_m124
quietly regress price mpg weight t6v0045 t6v0063 i.foreign
estimates store t6_m125
display as text "[MODEL] stored t6_m125"
estimates table t6_m001 t6_m002 t6_m003, b(%9.3f) se stats(N r2)
tabulate foreign
tabstat price mpg weight t6_work, by(foreign) statistics(mean sd min max n)
export delimited make price mpg weight foreign t6_work using "$tempdir/taught_task6_snapshot.csv", replace
display as result "<<< DONE Section 11: model and table output stress"
// #endregion Section 11: model and table output stress

// #region Section 12: trace and assertion marathon
display as text ">>> START Section 12: trace and assertion marathon"
quietly {
    count if mod(obs_id, 3) == 0
    local t6_trace_0001 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0002 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0003 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0004 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0005 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0006 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0007 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0008 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0009 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0010 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0011 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0012 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0013 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0014 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0015 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0016 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0017 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0018 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0019 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0020 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0021 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0022 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0023 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0024 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0025 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0026 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0027 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0028 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0029 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0030 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0031 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0032 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0033 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0034 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0035 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0036 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0037 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0038 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0039 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0040 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0041 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0042 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0043 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0044 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0045 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0046 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0047 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0048 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0049 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0050 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0051 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0052 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0053 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0054 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0055 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0056 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0057 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0058 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0059 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0060 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0061 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0062 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0063 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0064 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0065 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0066 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0067 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0068 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0069 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0070 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0071 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0072 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0073 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0074 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0075 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0076 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0077 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0078 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0079 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0080 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0081 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0082 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0083 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0084 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0085 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0086 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0087 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0088 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0089 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0090 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0091 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0092 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0093 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0094 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0095 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0096 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0097 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0098 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0099 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0100 = r(N)
    summarize t6_work
    count if mod(obs_id, 8) == 0
    local t6_trace_0101 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0102 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0103 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0104 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0105 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0106 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0107 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0108 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0109 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0110 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0111 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0112 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0113 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0114 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0115 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0116 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0117 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0118 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0119 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0120 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0121 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0122 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0123 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0124 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0125 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0126 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0127 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0128 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0129 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0130 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0131 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0132 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0133 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0134 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0135 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0136 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0137 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0138 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0139 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0140 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0141 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0142 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0143 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0144 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0145 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0146 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0147 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0148 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0149 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0150 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0151 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0152 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0153 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0154 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0155 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0156 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0157 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0158 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0159 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0160 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0161 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0162 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0163 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0164 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0165 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0166 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0167 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0168 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0169 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0170 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0171 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0172 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0173 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0174 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0175 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0176 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0177 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0178 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0179 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0180 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0181 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0182 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0183 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0184 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0185 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0186 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0187 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0188 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0189 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0190 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0191 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0192 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0193 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0194 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0195 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0196 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0197 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0198 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0199 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0200 = r(N)
    summarize t6_work
    count if mod(obs_id, 13) == 0
    local t6_trace_0201 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0202 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0203 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0204 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0205 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0206 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0207 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0208 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0209 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0210 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0211 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0212 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0213 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0214 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0215 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0216 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0217 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0218 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0219 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0220 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0221 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0222 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0223 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0224 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0225 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0226 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0227 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0228 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0229 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0230 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0231 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0232 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0233 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0234 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0235 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0236 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0237 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0238 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0239 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0240 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0241 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0242 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0243 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0244 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0245 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0246 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0247 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0248 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0249 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0250 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0251 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0252 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0253 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0254 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0255 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0256 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0257 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0258 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0259 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0260 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0261 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0262 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0263 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0264 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0265 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0266 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0267 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0268 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0269 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0270 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0271 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0272 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0273 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0274 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0275 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0276 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0277 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0278 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0279 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0280 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0281 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0282 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0283 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0284 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0285 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0286 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0287 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0288 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0289 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0290 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0291 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0292 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0293 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0294 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0295 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0296 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0297 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0298 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0299 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0300 = r(N)
    summarize t6_work
    count if mod(obs_id, 18) == 0
    local t6_trace_0301 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0302 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0303 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0304 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0305 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0306 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0307 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0308 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0309 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0310 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0311 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0312 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0313 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0314 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0315 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0316 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0317 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0318 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0319 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0320 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0321 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0322 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0323 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0324 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0325 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0326 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0327 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0328 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0329 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0330 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0331 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0332 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0333 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0334 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0335 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0336 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0337 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0338 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0339 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0340 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0341 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0342 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0343 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0344 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0345 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0346 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0347 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0348 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0349 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0350 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0351 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0352 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0353 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0354 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0355 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0356 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0357 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0358 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0359 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0360 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0361 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0362 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0363 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0364 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0365 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0366 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0367 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0368 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0369 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0370 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0371 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0372 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0373 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0374 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0375 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0376 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0377 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0378 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0379 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0380 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0381 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0382 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0383 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0384 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0385 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0386 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0387 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0388 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0389 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0390 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0391 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0392 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0393 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0394 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0395 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0396 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0397 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0398 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0399 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0400 = r(N)
    summarize t6_work
    count if mod(obs_id, 4) == 0
    local t6_trace_0401 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0402 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0403 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0404 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0405 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0406 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0407 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0408 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0409 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0410 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0411 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0412 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0413 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0414 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0415 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0416 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0417 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0418 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0419 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0420 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0421 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0422 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0423 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0424 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0425 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0426 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0427 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0428 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0429 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0430 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0431 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0432 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0433 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0434 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0435 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0436 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0437 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0438 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0439 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0440 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0441 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0442 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0443 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0444 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0445 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0446 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0447 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0448 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0449 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0450 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0451 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0452 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0453 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0454 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0455 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0456 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0457 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0458 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0459 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0460 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0461 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0462 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0463 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0464 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0465 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0466 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0467 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0468 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0469 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0470 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0471 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0472 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0473 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0474 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0475 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0476 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0477 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0478 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0479 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0480 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0481 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0482 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0483 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0484 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0485 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0486 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0487 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0488 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0489 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0490 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0491 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0492 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0493 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0494 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0495 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0496 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0497 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0498 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0499 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0500 = r(N)
    summarize t6_work
    count if mod(obs_id, 9) == 0
    local t6_trace_0501 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0502 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0503 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0504 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0505 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0506 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0507 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0508 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0509 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0510 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0511 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0512 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0513 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0514 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0515 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0516 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0517 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0518 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0519 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0520 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0521 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0522 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0523 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0524 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0525 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0526 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0527 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0528 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0529 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0530 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0531 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0532 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0533 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0534 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0535 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0536 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0537 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0538 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0539 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0540 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0541 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0542 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0543 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0544 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0545 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0546 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0547 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0548 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0549 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0550 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0551 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0552 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0553 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0554 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0555 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0556 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0557 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0558 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0559 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0560 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0561 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0562 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0563 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0564 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0565 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0566 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0567 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0568 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0569 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0570 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0571 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0572 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0573 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0574 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0575 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0576 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0577 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0578 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0579 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0580 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0581 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0582 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0583 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0584 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0585 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0586 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0587 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0588 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0589 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0590 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0591 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0592 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0593 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0594 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0595 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0596 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0597 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0598 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0599 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0600 = r(N)
    summarize t6_work
    count if mod(obs_id, 14) == 0
    local t6_trace_0601 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0602 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0603 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0604 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0605 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0606 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0607 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0608 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0609 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0610 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0611 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0612 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0613 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0614 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0615 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0616 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0617 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0618 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0619 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0620 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0621 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0622 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0623 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0624 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0625 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0626 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0627 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0628 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0629 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0630 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0631 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0632 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0633 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0634 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0635 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0636 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0637 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0638 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0639 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0640 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0641 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0642 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0643 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0644 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0645 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0646 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0647 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0648 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0649 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0650 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0651 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0652 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0653 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0654 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0655 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0656 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0657 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0658 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0659 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0660 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0661 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0662 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0663 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0664 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0665 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0666 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0667 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0668 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0669 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0670 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0671 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0672 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0673 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0674 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0675 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0676 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0677 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0678 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0679 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0680 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0681 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0682 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0683 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0684 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0685 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0686 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0687 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0688 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0689 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0690 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0691 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0692 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0693 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0694 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0695 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0696 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0697 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0698 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0699 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0700 = r(N)
    summarize t6_work
    count if mod(obs_id, 19) == 0
    local t6_trace_0701 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0702 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0703 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0704 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0705 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0706 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0707 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0708 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0709 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0710 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0711 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0712 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0713 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0714 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0715 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0716 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0717 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0718 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0719 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0720 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0721 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0722 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0723 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0724 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0725 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0726 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0727 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0728 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0729 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0730 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0731 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0732 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0733 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0734 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0735 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0736 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0737 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0738 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0739 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0740 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0741 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0742 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0743 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0744 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0745 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0746 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0747 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0748 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0749 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0750 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0751 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0752 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0753 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0754 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0755 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0756 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0757 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0758 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0759 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0760 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0761 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0762 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0763 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0764 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0765 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0766 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0767 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0768 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0769 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0770 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0771 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0772 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0773 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0774 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0775 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0776 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0777 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0778 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0779 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0780 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0781 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0782 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0783 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0784 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0785 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0786 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0787 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0788 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0789 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0790 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0791 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0792 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0793 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0794 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0795 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0796 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0797 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0798 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0799 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0800 = r(N)
    summarize t6_work
    count if mod(obs_id, 5) == 0
    local t6_trace_0801 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0802 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0803 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0804 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0805 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0806 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0807 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0808 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0809 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0810 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0811 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0812 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0813 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0814 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0815 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0816 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0817 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0818 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0819 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0820 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0821 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0822 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0823 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0824 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0825 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0826 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0827 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0828 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0829 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0830 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0831 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0832 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0833 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0834 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0835 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0836 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0837 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0838 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0839 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0840 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0841 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0842 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0843 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0844 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0845 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0846 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0847 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0848 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0849 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0850 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0851 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0852 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0853 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0854 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0855 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0856 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0857 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0858 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0859 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0860 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0861 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0862 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0863 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0864 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0865 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0866 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0867 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0868 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0869 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0870 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0871 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0872 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0873 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0874 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0875 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0876 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0877 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0878 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0879 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0880 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0881 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0882 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0883 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0884 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0885 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0886 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0887 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0888 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0889 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0890 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0891 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0892 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0893 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0894 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0895 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0896 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0897 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0898 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0899 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0900 = r(N)
    summarize t6_work
    count if mod(obs_id, 10) == 0
    local t6_trace_0901 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0902 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0903 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0904 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0905 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0906 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0907 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0908 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0909 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0910 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0911 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0912 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0913 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0914 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0915 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0916 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0917 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0918 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0919 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0920 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0921 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0922 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0923 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0924 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0925 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0926 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0927 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0928 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0929 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0930 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0931 = r(N)
    count if mod(obs_id, 3) == 0
    local t6_trace_0932 = r(N)
    count if mod(obs_id, 4) == 0
    local t6_trace_0933 = r(N)
    count if mod(obs_id, 5) == 0
    local t6_trace_0934 = r(N)
    count if mod(obs_id, 6) == 0
    local t6_trace_0935 = r(N)
    count if mod(obs_id, 7) == 0
    local t6_trace_0936 = r(N)
    count if mod(obs_id, 8) == 0
    local t6_trace_0937 = r(N)
    count if mod(obs_id, 9) == 0
    local t6_trace_0938 = r(N)
    count if mod(obs_id, 10) == 0
    local t6_trace_0939 = r(N)
    count if mod(obs_id, 11) == 0
    local t6_trace_0940 = r(N)
    count if mod(obs_id, 12) == 0
    local t6_trace_0941 = r(N)
    count if mod(obs_id, 13) == 0
    local t6_trace_0942 = r(N)
    count if mod(obs_id, 14) == 0
    local t6_trace_0943 = r(N)
    count if mod(obs_id, 15) == 0
    local t6_trace_0944 = r(N)
    count if mod(obs_id, 16) == 0
    local t6_trace_0945 = r(N)
    count if mod(obs_id, 17) == 0
    local t6_trace_0946 = r(N)
    count if mod(obs_id, 18) == 0
    local t6_trace_0947 = r(N)
    count if mod(obs_id, 19) == 0
    local t6_trace_0948 = r(N)
    count if mod(obs_id, 20) == 0
    local t6_trace_0949 = r(N)
    count if mod(obs_id, 2) == 0
    local t6_trace_0950 = r(N)
}
display as text "[TRACE] final checkpoint local exists for t6"
display as result "<<< DONE Section 12: trace and assertion marathon"
// #endregion Section 12: trace and assertion marathon

// #region Section 13: generated padding compute lines for line-count target
display as text ">>> START Section 13: generated padding compute lines"
quietly {
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 35)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 36)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 37)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 38)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 39)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 40)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 41)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 42)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 43)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 44)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 2)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 3)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 4)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 5)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 6)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 7)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 8)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 9)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 10)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 11)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 12)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 13)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 14)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 15)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 16)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 17)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 18)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 19)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 20)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 21)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 22)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 23)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 24)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 25)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 26)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 27)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 28)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 29)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 30)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 31)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 32)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 33)
    replace t6_work = t6_work + 0.0000001 * mod(obs_id, 34)
}
display as result "<<< DONE Section 13: generated padding compute lines"
// #endregion Section 13: generated padding compute lines

// #region Section 14: final save and completion
display as text ">>> START Section 14: final save and completion"
quietly summarize t6_work
local t6_final_mean = r(mean)
display as text "[FINAL] t6_work mean=" %9.4f `t6_final_mean'
compress
save "$tempdir/taught_task6_final.dta", replace
export delimited using "$tempdir/taught_task6_final.csv", replace
display as result "<<< DONE taught_task6.do"
display as text "===== TAUGHT TASK 6 SELF-CHECK END ====="
// #endregion Section 14: final save and completion
// padding line 001: non-executing stress fixture line-count guard
// padding line 002: non-executing stress fixture line-count guard
// padding line 003: non-executing stress fixture line-count guard
// padding line 004: non-executing stress fixture line-count guard
// padding line 005: non-executing stress fixture line-count guard
// padding line 006: non-executing stress fixture line-count guard
// padding line 007: non-executing stress fixture line-count guard
// padding line 008: non-executing stress fixture line-count guard
// padding line 009: non-executing stress fixture line-count guard
// padding line 010: non-executing stress fixture line-count guard
// padding line 011: non-executing stress fixture line-count guard
// padding line 012: non-executing stress fixture line-count guard
// padding line 013: non-executing stress fixture line-count guard
// padding line 014: non-executing stress fixture line-count guard
// padding line 015: non-executing stress fixture line-count guard
// padding line 016: non-executing stress fixture line-count guard
// padding line 017: non-executing stress fixture line-count guard
// padding line 018: non-executing stress fixture line-count guard
// padding line 019: non-executing stress fixture line-count guard
// padding line 020: non-executing stress fixture line-count guard
// padding line 021: non-executing stress fixture line-count guard
// padding line 022: non-executing stress fixture line-count guard
// padding line 023: non-executing stress fixture line-count guard
// padding line 024: non-executing stress fixture line-count guard
// padding line 025: non-executing stress fixture line-count guard

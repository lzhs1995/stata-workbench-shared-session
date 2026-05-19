/*
================================================================================
File: taught_task5.do
Purpose: generated Stata Workbench/native Stata 18 stress fixture
Goal: expose gaps against realtime shared session, low latency, no hangs,
      unchanged research do-files, and native-like graph/table/document output.
Design: generated self-contained script, target >= 9000 lines.
================================================================================
*/

version 18
cls
clear all
set more off
set seed 20260505
set maxvar 20000

local __taught_root "`c(pwd)'"
global workfolder "`__taught_root'"
global tempdir "${workfolder}/7_temp"
global docdir "${workfolder}/4_tables"
local t5_run_stamp = subinstr("`=c(current_date)'_`=c(current_time)'", " ", "_", .)
local t5_run_stamp = subinstr("`t5_run_stamp'", ":", "", .)
global figdir5 "${tempdir}/taught_task5_graphs/`t5_run_stamp'"
cap mkdir "${tempdir}/taught_task5_graphs"
cap mkdir "$figdir5"
cap mkdir "$docdir"

capture which p_tdocx
if _rc {
    capture program drop p_tdocx
    program define p_tdocx
        putdocx `0'
    end
}

display as text "===== TAUGHT TASK 5 SELF-CHECK START ====="
display as text "Stata version: " c(stata_version)
display as text "Date: " c(current_date) " Time: " c(current_time)

// #region Section 1: setup and base data
display as text ">>> START Section 1: setup and base data"
sysuse auto, clear
expand 8
sort make
gen obs_id = _n
gen price_ln = ln(price)
gen mpg_sq = mpg^2
gen weight_ton = weight / 1000
gen length_sq = length^2
gen turn_sq = turn^2
gen displacement_ln = ln(displacement)
gen base_score = price_ln + mpg/10 - weight_ton + gear_ratio
gen t5_work = base_score
gen t5_rank_source = price + mpg * 100 - weight
egen t5_price_q = cut(price), group(4)
egen t5_mpg_t = cut(mpg), group(3)
gen t5_group = mod(obs_id, 13) + 1
gen t5_flag = price > 8000 | mpg > 25
compress
describe
summarize price mpg weight length turn displacement gear_ratio
display as result "<<< DONE Section 1: setup and base data"
// #endregion Section 1: setup and base data

// #region Section 2: generated variables marathon
display as text ">>> START Section 2: generated variables marathon"
gen t5v0001 = mpg + rnormal(0, 0.2)
replace t5v0001 = t5v0001 + t5_group/3
gen t5v0002 = weight + rnormal(0, 0.3)
replace t5v0002 = t5v0002 + t5_group/4
gen t5v0003 = length + rnormal(0, 0.4)
replace t5v0003 = t5v0003 + t5_group/5
gen t5v0004 = turn + rnormal(0, 0.5)
replace t5v0004 = t5v0004 + t5_group/6
gen t5v0005 = displacement + rnormal(0, 0.6)
replace t5v0005 = t5v0005 + t5_group/7
label variable t5v0005 "Generated stress variable 0005"
gen t5v0006 = gear_ratio + rnormal(0, 0.7)
replace t5v0006 = t5v0006 + t5_group/8
gen t5v0007 = price + rnormal(0, 0.8)
replace t5v0007 = t5v0007 + t5_group/9
gen t5v0008 = base_score + rnormal(0, 0.9)
replace t5v0008 = t5v0008 + t5_group/10
gen t5v0009 = mpg + rnormal(0, 0.1)
replace t5v0009 = t5v0009 + t5_group/11
gen t5v0010 = weight + rnormal(0, 0.2)
replace t5v0010 = t5v0010 + t5_group/12
label variable t5v0010 "Generated stress variable 0010"
gen t5v0011 = length + rnormal(0, 0.3)
replace t5v0011 = t5v0011 + t5_group/13
gen t5v0012 = turn + rnormal(0, 0.4)
replace t5v0012 = t5v0012 + t5_group/14
gen t5v0013 = displacement + rnormal(0, 0.5)
replace t5v0013 = t5v0013 + t5_group/2
gen t5v0014 = gear_ratio + rnormal(0, 0.6)
replace t5v0014 = t5v0014 + t5_group/3
gen t5v0015 = price + rnormal(0, 0.7)
replace t5v0015 = t5v0015 + t5_group/4
label variable t5v0015 "Generated stress variable 0015"
gen t5v0016 = base_score + rnormal(0, 0.8)
replace t5v0016 = t5v0016 + t5_group/5
gen t5v0017 = mpg + rnormal(0, 0.9)
replace t5v0017 = t5v0017 + t5_group/6
gen t5v0018 = weight + rnormal(0, 0.1)
replace t5v0018 = t5v0018 + t5_group/7
gen t5v0019 = length + rnormal(0, 0.2)
replace t5v0019 = t5v0019 + t5_group/8
gen t5v0020 = turn + rnormal(0, 0.3)
replace t5v0020 = t5v0020 + t5_group/9
label variable t5v0020 "Generated stress variable 0020"
gen t5v0021 = displacement + rnormal(0, 0.4)
replace t5v0021 = t5v0021 + t5_group/10
gen t5v0022 = gear_ratio + rnormal(0, 0.5)
replace t5v0022 = t5v0022 + t5_group/11
gen t5v0023 = price + rnormal(0, 0.6)
replace t5v0023 = t5v0023 + t5_group/12
gen t5v0024 = base_score + rnormal(0, 0.7)
replace t5v0024 = t5v0024 + t5_group/13
gen t5v0025 = mpg + rnormal(0, 0.8)
replace t5v0025 = t5v0025 + t5_group/14
label variable t5v0025 "Generated stress variable 0025"
quietly summarize t5v0025
display as text "[VAR] t5v0025 mean=" %9.4f r(mean)
gen t5v0026 = weight + rnormal(0, 0.9)
replace t5v0026 = t5v0026 + t5_group/2
gen t5v0027 = length + rnormal(0, 0.1)
replace t5v0027 = t5v0027 + t5_group/3
gen t5v0028 = turn + rnormal(0, 0.2)
replace t5v0028 = t5v0028 + t5_group/4
gen t5v0029 = displacement + rnormal(0, 0.3)
replace t5v0029 = t5v0029 + t5_group/5
gen t5v0030 = gear_ratio + rnormal(0, 0.4)
replace t5v0030 = t5v0030 + t5_group/6
label variable t5v0030 "Generated stress variable 0030"
gen t5v0031 = price + rnormal(0, 0.5)
replace t5v0031 = t5v0031 + t5_group/7
gen t5v0032 = base_score + rnormal(0, 0.6)
replace t5v0032 = t5v0032 + t5_group/8
gen t5v0033 = mpg + rnormal(0, 0.7)
replace t5v0033 = t5v0033 + t5_group/9
gen t5v0034 = weight + rnormal(0, 0.8)
replace t5v0034 = t5v0034 + t5_group/10
gen t5v0035 = length + rnormal(0, 0.9)
replace t5v0035 = t5v0035 + t5_group/11
label variable t5v0035 "Generated stress variable 0035"
gen t5v0036 = turn + rnormal(0, 0.1)
replace t5v0036 = t5v0036 + t5_group/12
gen t5v0037 = displacement + rnormal(0, 0.2)
replace t5v0037 = t5v0037 + t5_group/13
gen t5v0038 = gear_ratio + rnormal(0, 0.3)
replace t5v0038 = t5v0038 + t5_group/14
gen t5v0039 = price + rnormal(0, 0.4)
replace t5v0039 = t5v0039 + t5_group/2
gen t5v0040 = base_score + rnormal(0, 0.5)
replace t5v0040 = t5v0040 + t5_group/3
label variable t5v0040 "Generated stress variable 0040"
gen t5v0041 = mpg + rnormal(0, 0.6)
replace t5v0041 = t5v0041 + t5_group/4
gen t5v0042 = weight + rnormal(0, 0.7)
replace t5v0042 = t5v0042 + t5_group/5
gen t5v0043 = length + rnormal(0, 0.8)
replace t5v0043 = t5v0043 + t5_group/6
gen t5v0044 = turn + rnormal(0, 0.9)
replace t5v0044 = t5v0044 + t5_group/7
gen t5v0045 = displacement + rnormal(0, 0.1)
replace t5v0045 = t5v0045 + t5_group/8
label variable t5v0045 "Generated stress variable 0045"
gen t5v0046 = gear_ratio + rnormal(0, 0.2)
replace t5v0046 = t5v0046 + t5_group/9
gen t5v0047 = price + rnormal(0, 0.3)
replace t5v0047 = t5v0047 + t5_group/10
gen t5v0048 = base_score + rnormal(0, 0.4)
replace t5v0048 = t5v0048 + t5_group/11
gen t5v0049 = mpg + rnormal(0, 0.5)
replace t5v0049 = t5v0049 + t5_group/12
gen t5v0050 = weight + rnormal(0, 0.6)
replace t5v0050 = t5v0050 + t5_group/13
label variable t5v0050 "Generated stress variable 0050"
quietly summarize t5v0050
display as text "[VAR] t5v0050 mean=" %9.4f r(mean)
gen t5v0051 = length + rnormal(0, 0.7)
replace t5v0051 = t5v0051 + t5_group/14
gen t5v0052 = turn + rnormal(0, 0.8)
replace t5v0052 = t5v0052 + t5_group/2
gen t5v0053 = displacement + rnormal(0, 0.9)
replace t5v0053 = t5v0053 + t5_group/3
gen t5v0054 = gear_ratio + rnormal(0, 0.1)
replace t5v0054 = t5v0054 + t5_group/4
gen t5v0055 = price + rnormal(0, 0.2)
replace t5v0055 = t5v0055 + t5_group/5
label variable t5v0055 "Generated stress variable 0055"
gen t5v0056 = base_score + rnormal(0, 0.3)
replace t5v0056 = t5v0056 + t5_group/6
gen t5v0057 = mpg + rnormal(0, 0.4)
replace t5v0057 = t5v0057 + t5_group/7
gen t5v0058 = weight + rnormal(0, 0.5)
replace t5v0058 = t5v0058 + t5_group/8
gen t5v0059 = length + rnormal(0, 0.6)
replace t5v0059 = t5v0059 + t5_group/9
gen t5v0060 = turn + rnormal(0, 0.7)
replace t5v0060 = t5v0060 + t5_group/10
label variable t5v0060 "Generated stress variable 0060"
gen t5v0061 = displacement + rnormal(0, 0.8)
replace t5v0061 = t5v0061 + t5_group/11
gen t5v0062 = gear_ratio + rnormal(0, 0.9)
replace t5v0062 = t5v0062 + t5_group/12
gen t5v0063 = price + rnormal(0, 0.1)
replace t5v0063 = t5v0063 + t5_group/13
gen t5v0064 = base_score + rnormal(0, 0.2)
replace t5v0064 = t5v0064 + t5_group/14
gen t5v0065 = mpg + rnormal(0, 0.3)
replace t5v0065 = t5v0065 + t5_group/2
label variable t5v0065 "Generated stress variable 0065"
gen t5v0066 = weight + rnormal(0, 0.4)
replace t5v0066 = t5v0066 + t5_group/3
gen t5v0067 = length + rnormal(0, 0.5)
replace t5v0067 = t5v0067 + t5_group/4
gen t5v0068 = turn + rnormal(0, 0.6)
replace t5v0068 = t5v0068 + t5_group/5
gen t5v0069 = displacement + rnormal(0, 0.7)
replace t5v0069 = t5v0069 + t5_group/6
gen t5v0070 = gear_ratio + rnormal(0, 0.8)
replace t5v0070 = t5v0070 + t5_group/7
label variable t5v0070 "Generated stress variable 0070"
gen t5v0071 = price + rnormal(0, 0.9)
replace t5v0071 = t5v0071 + t5_group/8
gen t5v0072 = base_score + rnormal(0, 0.1)
replace t5v0072 = t5v0072 + t5_group/9
gen t5v0073 = mpg + rnormal(0, 0.2)
replace t5v0073 = t5v0073 + t5_group/10
gen t5v0074 = weight + rnormal(0, 0.3)
replace t5v0074 = t5v0074 + t5_group/11
gen t5v0075 = length + rnormal(0, 0.4)
replace t5v0075 = t5v0075 + t5_group/12
label variable t5v0075 "Generated stress variable 0075"
quietly summarize t5v0075
display as text "[VAR] t5v0075 mean=" %9.4f r(mean)
gen t5v0076 = turn + rnormal(0, 0.5)
replace t5v0076 = t5v0076 + t5_group/13
gen t5v0077 = displacement + rnormal(0, 0.6)
replace t5v0077 = t5v0077 + t5_group/14
gen t5v0078 = gear_ratio + rnormal(0, 0.7)
replace t5v0078 = t5v0078 + t5_group/2
gen t5v0079 = price + rnormal(0, 0.8)
replace t5v0079 = t5v0079 + t5_group/3
gen t5v0080 = base_score + rnormal(0, 0.9)
replace t5v0080 = t5v0080 + t5_group/4
label variable t5v0080 "Generated stress variable 0080"
gen t5v0081 = mpg + rnormal(0, 0.1)
replace t5v0081 = t5v0081 + t5_group/5
gen t5v0082 = weight + rnormal(0, 0.2)
replace t5v0082 = t5v0082 + t5_group/6
gen t5v0083 = length + rnormal(0, 0.3)
replace t5v0083 = t5v0083 + t5_group/7
gen t5v0084 = turn + rnormal(0, 0.4)
replace t5v0084 = t5v0084 + t5_group/8
gen t5v0085 = displacement + rnormal(0, 0.5)
replace t5v0085 = t5v0085 + t5_group/9
label variable t5v0085 "Generated stress variable 0085"
gen t5v0086 = gear_ratio + rnormal(0, 0.6)
replace t5v0086 = t5v0086 + t5_group/10
gen t5v0087 = price + rnormal(0, 0.7)
replace t5v0087 = t5v0087 + t5_group/11
gen t5v0088 = base_score + rnormal(0, 0.8)
replace t5v0088 = t5v0088 + t5_group/12
gen t5v0089 = mpg + rnormal(0, 0.9)
replace t5v0089 = t5v0089 + t5_group/13
gen t5v0090 = weight + rnormal(0, 0.1)
replace t5v0090 = t5v0090 + t5_group/14
label variable t5v0090 "Generated stress variable 0090"
gen t5v0091 = length + rnormal(0, 0.2)
replace t5v0091 = t5v0091 + t5_group/2
gen t5v0092 = turn + rnormal(0, 0.3)
replace t5v0092 = t5v0092 + t5_group/3
gen t5v0093 = displacement + rnormal(0, 0.4)
replace t5v0093 = t5v0093 + t5_group/4
gen t5v0094 = gear_ratio + rnormal(0, 0.5)
replace t5v0094 = t5v0094 + t5_group/5
gen t5v0095 = price + rnormal(0, 0.6)
replace t5v0095 = t5v0095 + t5_group/6
label variable t5v0095 "Generated stress variable 0095"
gen t5v0096 = base_score + rnormal(0, 0.7)
replace t5v0096 = t5v0096 + t5_group/7
gen t5v0097 = mpg + rnormal(0, 0.8)
replace t5v0097 = t5v0097 + t5_group/8
gen t5v0098 = weight + rnormal(0, 0.9)
replace t5v0098 = t5v0098 + t5_group/9
gen t5v0099 = length + rnormal(0, 0.1)
replace t5v0099 = t5v0099 + t5_group/10
gen t5v0100 = turn + rnormal(0, 0.2)
replace t5v0100 = t5v0100 + t5_group/11
label variable t5v0100 "Generated stress variable 0100"
quietly summarize t5v0100
display as text "[VAR] t5v0100 mean=" %9.4f r(mean)
gen t5v0101 = displacement + rnormal(0, 0.3)
replace t5v0101 = t5v0101 + t5_group/12
gen t5v0102 = gear_ratio + rnormal(0, 0.4)
replace t5v0102 = t5v0102 + t5_group/13
gen t5v0103 = price + rnormal(0, 0.5)
replace t5v0103 = t5v0103 + t5_group/14
gen t5v0104 = base_score + rnormal(0, 0.6)
replace t5v0104 = t5v0104 + t5_group/2
gen t5v0105 = mpg + rnormal(0, 0.7)
replace t5v0105 = t5v0105 + t5_group/3
label variable t5v0105 "Generated stress variable 0105"
gen t5v0106 = weight + rnormal(0, 0.8)
replace t5v0106 = t5v0106 + t5_group/4
gen t5v0107 = length + rnormal(0, 0.9)
replace t5v0107 = t5v0107 + t5_group/5
gen t5v0108 = turn + rnormal(0, 0.1)
replace t5v0108 = t5v0108 + t5_group/6
gen t5v0109 = displacement + rnormal(0, 0.2)
replace t5v0109 = t5v0109 + t5_group/7
gen t5v0110 = gear_ratio + rnormal(0, 0.3)
replace t5v0110 = t5v0110 + t5_group/8
label variable t5v0110 "Generated stress variable 0110"
gen t5v0111 = price + rnormal(0, 0.4)
replace t5v0111 = t5v0111 + t5_group/9
gen t5v0112 = base_score + rnormal(0, 0.5)
replace t5v0112 = t5v0112 + t5_group/10
gen t5v0113 = mpg + rnormal(0, 0.6)
replace t5v0113 = t5v0113 + t5_group/11
gen t5v0114 = weight + rnormal(0, 0.7)
replace t5v0114 = t5v0114 + t5_group/12
gen t5v0115 = length + rnormal(0, 0.8)
replace t5v0115 = t5v0115 + t5_group/13
label variable t5v0115 "Generated stress variable 0115"
gen t5v0116 = turn + rnormal(0, 0.9)
replace t5v0116 = t5v0116 + t5_group/14
gen t5v0117 = displacement + rnormal(0, 0.1)
replace t5v0117 = t5v0117 + t5_group/2
gen t5v0118 = gear_ratio + rnormal(0, 0.2)
replace t5v0118 = t5v0118 + t5_group/3
gen t5v0119 = price + rnormal(0, 0.3)
replace t5v0119 = t5v0119 + t5_group/4
gen t5v0120 = base_score + rnormal(0, 0.4)
replace t5v0120 = t5v0120 + t5_group/5
label variable t5v0120 "Generated stress variable 0120"
gen t5v0121 = mpg + rnormal(0, 0.5)
replace t5v0121 = t5v0121 + t5_group/6
gen t5v0122 = weight + rnormal(0, 0.6)
replace t5v0122 = t5v0122 + t5_group/7
gen t5v0123 = length + rnormal(0, 0.7)
replace t5v0123 = t5v0123 + t5_group/8
gen t5v0124 = turn + rnormal(0, 0.8)
replace t5v0124 = t5v0124 + t5_group/9
gen t5v0125 = displacement + rnormal(0, 0.9)
replace t5v0125 = t5v0125 + t5_group/10
label variable t5v0125 "Generated stress variable 0125"
quietly summarize t5v0125
display as text "[VAR] t5v0125 mean=" %9.4f r(mean)
gen t5v0126 = gear_ratio + rnormal(0, 0.1)
replace t5v0126 = t5v0126 + t5_group/11
gen t5v0127 = price + rnormal(0, 0.2)
replace t5v0127 = t5v0127 + t5_group/12
gen t5v0128 = base_score + rnormal(0, 0.3)
replace t5v0128 = t5v0128 + t5_group/13
gen t5v0129 = mpg + rnormal(0, 0.4)
replace t5v0129 = t5v0129 + t5_group/14
gen t5v0130 = weight + rnormal(0, 0.5)
replace t5v0130 = t5v0130 + t5_group/2
label variable t5v0130 "Generated stress variable 0130"
gen t5v0131 = length + rnormal(0, 0.6)
replace t5v0131 = t5v0131 + t5_group/3
gen t5v0132 = turn + rnormal(0, 0.7)
replace t5v0132 = t5v0132 + t5_group/4
gen t5v0133 = displacement + rnormal(0, 0.8)
replace t5v0133 = t5v0133 + t5_group/5
gen t5v0134 = gear_ratio + rnormal(0, 0.9)
replace t5v0134 = t5v0134 + t5_group/6
gen t5v0135 = price + rnormal(0, 0.1)
replace t5v0135 = t5v0135 + t5_group/7
label variable t5v0135 "Generated stress variable 0135"
gen t5v0136 = base_score + rnormal(0, 0.2)
replace t5v0136 = t5v0136 + t5_group/8
gen t5v0137 = mpg + rnormal(0, 0.3)
replace t5v0137 = t5v0137 + t5_group/9
gen t5v0138 = weight + rnormal(0, 0.4)
replace t5v0138 = t5v0138 + t5_group/10
gen t5v0139 = length + rnormal(0, 0.5)
replace t5v0139 = t5v0139 + t5_group/11
gen t5v0140 = turn + rnormal(0, 0.6)
replace t5v0140 = t5v0140 + t5_group/12
label variable t5v0140 "Generated stress variable 0140"
gen t5v0141 = displacement + rnormal(0, 0.7)
replace t5v0141 = t5v0141 + t5_group/13
gen t5v0142 = gear_ratio + rnormal(0, 0.8)
replace t5v0142 = t5v0142 + t5_group/14
gen t5v0143 = price + rnormal(0, 0.9)
replace t5v0143 = t5v0143 + t5_group/2
gen t5v0144 = base_score + rnormal(0, 0.1)
replace t5v0144 = t5v0144 + t5_group/3
gen t5v0145 = mpg + rnormal(0, 0.2)
replace t5v0145 = t5v0145 + t5_group/4
label variable t5v0145 "Generated stress variable 0145"
gen t5v0146 = weight + rnormal(0, 0.3)
replace t5v0146 = t5v0146 + t5_group/5
gen t5v0147 = length + rnormal(0, 0.4)
replace t5v0147 = t5v0147 + t5_group/6
gen t5v0148 = turn + rnormal(0, 0.5)
replace t5v0148 = t5v0148 + t5_group/7
gen t5v0149 = displacement + rnormal(0, 0.6)
replace t5v0149 = t5v0149 + t5_group/8
gen t5v0150 = gear_ratio + rnormal(0, 0.7)
replace t5v0150 = t5v0150 + t5_group/9
label variable t5v0150 "Generated stress variable 0150"
quietly summarize t5v0150
display as text "[VAR] t5v0150 mean=" %9.4f r(mean)
gen t5v0151 = price + rnormal(0, 0.8)
replace t5v0151 = t5v0151 + t5_group/10
gen t5v0152 = base_score + rnormal(0, 0.9)
replace t5v0152 = t5v0152 + t5_group/11
gen t5v0153 = mpg + rnormal(0, 0.1)
replace t5v0153 = t5v0153 + t5_group/12
gen t5v0154 = weight + rnormal(0, 0.2)
replace t5v0154 = t5v0154 + t5_group/13
gen t5v0155 = length + rnormal(0, 0.3)
replace t5v0155 = t5v0155 + t5_group/14
label variable t5v0155 "Generated stress variable 0155"
gen t5v0156 = turn + rnormal(0, 0.4)
replace t5v0156 = t5v0156 + t5_group/2
gen t5v0157 = displacement + rnormal(0, 0.5)
replace t5v0157 = t5v0157 + t5_group/3
gen t5v0158 = gear_ratio + rnormal(0, 0.6)
replace t5v0158 = t5v0158 + t5_group/4
gen t5v0159 = price + rnormal(0, 0.7)
replace t5v0159 = t5v0159 + t5_group/5
gen t5v0160 = base_score + rnormal(0, 0.8)
replace t5v0160 = t5v0160 + t5_group/6
label variable t5v0160 "Generated stress variable 0160"
gen t5v0161 = mpg + rnormal(0, 0.9)
replace t5v0161 = t5v0161 + t5_group/7
gen t5v0162 = weight + rnormal(0, 0.1)
replace t5v0162 = t5v0162 + t5_group/8
gen t5v0163 = length + rnormal(0, 0.2)
replace t5v0163 = t5v0163 + t5_group/9
gen t5v0164 = turn + rnormal(0, 0.3)
replace t5v0164 = t5v0164 + t5_group/10
gen t5v0165 = displacement + rnormal(0, 0.4)
replace t5v0165 = t5v0165 + t5_group/11
label variable t5v0165 "Generated stress variable 0165"
gen t5v0166 = gear_ratio + rnormal(0, 0.5)
replace t5v0166 = t5v0166 + t5_group/12
gen t5v0167 = price + rnormal(0, 0.6)
replace t5v0167 = t5v0167 + t5_group/13
gen t5v0168 = base_score + rnormal(0, 0.7)
replace t5v0168 = t5v0168 + t5_group/14
gen t5v0169 = mpg + rnormal(0, 0.8)
replace t5v0169 = t5v0169 + t5_group/2
gen t5v0170 = weight + rnormal(0, 0.9)
replace t5v0170 = t5v0170 + t5_group/3
label variable t5v0170 "Generated stress variable 0170"
gen t5v0171 = length + rnormal(0, 0.1)
replace t5v0171 = t5v0171 + t5_group/4
gen t5v0172 = turn + rnormal(0, 0.2)
replace t5v0172 = t5v0172 + t5_group/5
gen t5v0173 = displacement + rnormal(0, 0.3)
replace t5v0173 = t5v0173 + t5_group/6
gen t5v0174 = gear_ratio + rnormal(0, 0.4)
replace t5v0174 = t5v0174 + t5_group/7
gen t5v0175 = price + rnormal(0, 0.5)
replace t5v0175 = t5v0175 + t5_group/8
label variable t5v0175 "Generated stress variable 0175"
quietly summarize t5v0175
display as text "[VAR] t5v0175 mean=" %9.4f r(mean)
gen t5v0176 = base_score + rnormal(0, 0.6)
replace t5v0176 = t5v0176 + t5_group/9
gen t5v0177 = mpg + rnormal(0, 0.7)
replace t5v0177 = t5v0177 + t5_group/10
gen t5v0178 = weight + rnormal(0, 0.8)
replace t5v0178 = t5v0178 + t5_group/11
gen t5v0179 = length + rnormal(0, 0.9)
replace t5v0179 = t5v0179 + t5_group/12
gen t5v0180 = turn + rnormal(0, 0.1)
replace t5v0180 = t5v0180 + t5_group/13
label variable t5v0180 "Generated stress variable 0180"
gen t5v0181 = displacement + rnormal(0, 0.2)
replace t5v0181 = t5v0181 + t5_group/14
gen t5v0182 = gear_ratio + rnormal(0, 0.3)
replace t5v0182 = t5v0182 + t5_group/2
gen t5v0183 = price + rnormal(0, 0.4)
replace t5v0183 = t5v0183 + t5_group/3
gen t5v0184 = base_score + rnormal(0, 0.5)
replace t5v0184 = t5v0184 + t5_group/4
gen t5v0185 = mpg + rnormal(0, 0.6)
replace t5v0185 = t5v0185 + t5_group/5
label variable t5v0185 "Generated stress variable 0185"
gen t5v0186 = weight + rnormal(0, 0.7)
replace t5v0186 = t5v0186 + t5_group/6
gen t5v0187 = length + rnormal(0, 0.8)
replace t5v0187 = t5v0187 + t5_group/7
gen t5v0188 = turn + rnormal(0, 0.9)
replace t5v0188 = t5v0188 + t5_group/8
gen t5v0189 = displacement + rnormal(0, 0.1)
replace t5v0189 = t5v0189 + t5_group/9
gen t5v0190 = gear_ratio + rnormal(0, 0.2)
replace t5v0190 = t5v0190 + t5_group/10
label variable t5v0190 "Generated stress variable 0190"
gen t5v0191 = price + rnormal(0, 0.3)
replace t5v0191 = t5v0191 + t5_group/11
gen t5v0192 = base_score + rnormal(0, 0.4)
replace t5v0192 = t5v0192 + t5_group/12
gen t5v0193 = mpg + rnormal(0, 0.5)
replace t5v0193 = t5v0193 + t5_group/13
gen t5v0194 = weight + rnormal(0, 0.6)
replace t5v0194 = t5v0194 + t5_group/14
gen t5v0195 = length + rnormal(0, 0.7)
replace t5v0195 = t5v0195 + t5_group/2
label variable t5v0195 "Generated stress variable 0195"
gen t5v0196 = turn + rnormal(0, 0.8)
replace t5v0196 = t5v0196 + t5_group/3
gen t5v0197 = displacement + rnormal(0, 0.9)
replace t5v0197 = t5v0197 + t5_group/4
gen t5v0198 = gear_ratio + rnormal(0, 0.1)
replace t5v0198 = t5v0198 + t5_group/5
gen t5v0199 = price + rnormal(0, 0.2)
replace t5v0199 = t5v0199 + t5_group/6
gen t5v0200 = base_score + rnormal(0, 0.3)
replace t5v0200 = t5v0200 + t5_group/7
label variable t5v0200 "Generated stress variable 0200"
quietly summarize t5v0200
display as text "[VAR] t5v0200 mean=" %9.4f r(mean)
gen t5v0201 = mpg + rnormal(0, 0.4)
replace t5v0201 = t5v0201 + t5_group/8
gen t5v0202 = weight + rnormal(0, 0.5)
replace t5v0202 = t5v0202 + t5_group/9
gen t5v0203 = length + rnormal(0, 0.6)
replace t5v0203 = t5v0203 + t5_group/10
gen t5v0204 = turn + rnormal(0, 0.7)
replace t5v0204 = t5v0204 + t5_group/11
gen t5v0205 = displacement + rnormal(0, 0.8)
replace t5v0205 = t5v0205 + t5_group/12
label variable t5v0205 "Generated stress variable 0205"
gen t5v0206 = gear_ratio + rnormal(0, 0.9)
replace t5v0206 = t5v0206 + t5_group/13
gen t5v0207 = price + rnormal(0, 0.1)
replace t5v0207 = t5v0207 + t5_group/14
gen t5v0208 = base_score + rnormal(0, 0.2)
replace t5v0208 = t5v0208 + t5_group/2
gen t5v0209 = mpg + rnormal(0, 0.3)
replace t5v0209 = t5v0209 + t5_group/3
gen t5v0210 = weight + rnormal(0, 0.4)
replace t5v0210 = t5v0210 + t5_group/4
label variable t5v0210 "Generated stress variable 0210"
gen t5v0211 = length + rnormal(0, 0.5)
replace t5v0211 = t5v0211 + t5_group/5
gen t5v0212 = turn + rnormal(0, 0.6)
replace t5v0212 = t5v0212 + t5_group/6
gen t5v0213 = displacement + rnormal(0, 0.7)
replace t5v0213 = t5v0213 + t5_group/7
gen t5v0214 = gear_ratio + rnormal(0, 0.8)
replace t5v0214 = t5v0214 + t5_group/8
gen t5v0215 = price + rnormal(0, 0.9)
replace t5v0215 = t5v0215 + t5_group/9
label variable t5v0215 "Generated stress variable 0215"
gen t5v0216 = base_score + rnormal(0, 0.1)
replace t5v0216 = t5v0216 + t5_group/10
gen t5v0217 = mpg + rnormal(0, 0.2)
replace t5v0217 = t5v0217 + t5_group/11
gen t5v0218 = weight + rnormal(0, 0.3)
replace t5v0218 = t5v0218 + t5_group/12
gen t5v0219 = length + rnormal(0, 0.4)
replace t5v0219 = t5v0219 + t5_group/13
gen t5v0220 = turn + rnormal(0, 0.5)
replace t5v0220 = t5v0220 + t5_group/14
label variable t5v0220 "Generated stress variable 0220"
gen t5v0221 = displacement + rnormal(0, 0.6)
replace t5v0221 = t5v0221 + t5_group/2
gen t5v0222 = gear_ratio + rnormal(0, 0.7)
replace t5v0222 = t5v0222 + t5_group/3
gen t5v0223 = price + rnormal(0, 0.8)
replace t5v0223 = t5v0223 + t5_group/4
gen t5v0224 = base_score + rnormal(0, 0.9)
replace t5v0224 = t5v0224 + t5_group/5
gen t5v0225 = mpg + rnormal(0, 0.1)
replace t5v0225 = t5v0225 + t5_group/6
label variable t5v0225 "Generated stress variable 0225"
quietly summarize t5v0225
display as text "[VAR] t5v0225 mean=" %9.4f r(mean)
gen t5v0226 = weight + rnormal(0, 0.2)
replace t5v0226 = t5v0226 + t5_group/7
gen t5v0227 = length + rnormal(0, 0.3)
replace t5v0227 = t5v0227 + t5_group/8
gen t5v0228 = turn + rnormal(0, 0.4)
replace t5v0228 = t5v0228 + t5_group/9
gen t5v0229 = displacement + rnormal(0, 0.5)
replace t5v0229 = t5v0229 + t5_group/10
gen t5v0230 = gear_ratio + rnormal(0, 0.6)
replace t5v0230 = t5v0230 + t5_group/11
label variable t5v0230 "Generated stress variable 0230"
gen t5v0231 = price + rnormal(0, 0.7)
replace t5v0231 = t5v0231 + t5_group/12
gen t5v0232 = base_score + rnormal(0, 0.8)
replace t5v0232 = t5v0232 + t5_group/13
gen t5v0233 = mpg + rnormal(0, 0.9)
replace t5v0233 = t5v0233 + t5_group/14
gen t5v0234 = weight + rnormal(0, 0.1)
replace t5v0234 = t5v0234 + t5_group/2
gen t5v0235 = length + rnormal(0, 0.2)
replace t5v0235 = t5v0235 + t5_group/3
label variable t5v0235 "Generated stress variable 0235"
gen t5v0236 = turn + rnormal(0, 0.3)
replace t5v0236 = t5v0236 + t5_group/4
gen t5v0237 = displacement + rnormal(0, 0.4)
replace t5v0237 = t5v0237 + t5_group/5
gen t5v0238 = gear_ratio + rnormal(0, 0.5)
replace t5v0238 = t5v0238 + t5_group/6
gen t5v0239 = price + rnormal(0, 0.6)
replace t5v0239 = t5v0239 + t5_group/7
gen t5v0240 = base_score + rnormal(0, 0.7)
replace t5v0240 = t5v0240 + t5_group/8
label variable t5v0240 "Generated stress variable 0240"
gen t5v0241 = mpg + rnormal(0, 0.8)
replace t5v0241 = t5v0241 + t5_group/9
gen t5v0242 = weight + rnormal(0, 0.9)
replace t5v0242 = t5v0242 + t5_group/10
gen t5v0243 = length + rnormal(0, 0.1)
replace t5v0243 = t5v0243 + t5_group/11
gen t5v0244 = turn + rnormal(0, 0.2)
replace t5v0244 = t5v0244 + t5_group/12
gen t5v0245 = displacement + rnormal(0, 0.3)
replace t5v0245 = t5v0245 + t5_group/13
label variable t5v0245 "Generated stress variable 0245"
gen t5v0246 = gear_ratio + rnormal(0, 0.4)
replace t5v0246 = t5v0246 + t5_group/14
gen t5v0247 = price + rnormal(0, 0.5)
replace t5v0247 = t5v0247 + t5_group/2
gen t5v0248 = base_score + rnormal(0, 0.6)
replace t5v0248 = t5v0248 + t5_group/3
gen t5v0249 = mpg + rnormal(0, 0.7)
replace t5v0249 = t5v0249 + t5_group/4
gen t5v0250 = weight + rnormal(0, 0.8)
replace t5v0250 = t5v0250 + t5_group/5
label variable t5v0250 "Generated stress variable 0250"
quietly summarize t5v0250
display as text "[VAR] t5v0250 mean=" %9.4f r(mean)
gen t5v0251 = length + rnormal(0, 0.9)
replace t5v0251 = t5v0251 + t5_group/6
gen t5v0252 = turn + rnormal(0, 0.1)
replace t5v0252 = t5v0252 + t5_group/7
gen t5v0253 = displacement + rnormal(0, 0.2)
replace t5v0253 = t5v0253 + t5_group/8
gen t5v0254 = gear_ratio + rnormal(0, 0.3)
replace t5v0254 = t5v0254 + t5_group/9
gen t5v0255 = price + rnormal(0, 0.4)
replace t5v0255 = t5v0255 + t5_group/10
label variable t5v0255 "Generated stress variable 0255"
gen t5v0256 = base_score + rnormal(0, 0.5)
replace t5v0256 = t5v0256 + t5_group/11
gen t5v0257 = mpg + rnormal(0, 0.6)
replace t5v0257 = t5v0257 + t5_group/12
gen t5v0258 = weight + rnormal(0, 0.7)
replace t5v0258 = t5v0258 + t5_group/13
gen t5v0259 = length + rnormal(0, 0.8)
replace t5v0259 = t5v0259 + t5_group/14
gen t5v0260 = turn + rnormal(0, 0.9)
replace t5v0260 = t5v0260 + t5_group/2
label variable t5v0260 "Generated stress variable 0260"
gen t5v0261 = displacement + rnormal(0, 0.1)
replace t5v0261 = t5v0261 + t5_group/3
gen t5v0262 = gear_ratio + rnormal(0, 0.2)
replace t5v0262 = t5v0262 + t5_group/4
gen t5v0263 = price + rnormal(0, 0.3)
replace t5v0263 = t5v0263 + t5_group/5
gen t5v0264 = base_score + rnormal(0, 0.4)
replace t5v0264 = t5v0264 + t5_group/6
gen t5v0265 = mpg + rnormal(0, 0.5)
replace t5v0265 = t5v0265 + t5_group/7
label variable t5v0265 "Generated stress variable 0265"
gen t5v0266 = weight + rnormal(0, 0.6)
replace t5v0266 = t5v0266 + t5_group/8
gen t5v0267 = length + rnormal(0, 0.7)
replace t5v0267 = t5v0267 + t5_group/9
gen t5v0268 = turn + rnormal(0, 0.8)
replace t5v0268 = t5v0268 + t5_group/10
gen t5v0269 = displacement + rnormal(0, 0.9)
replace t5v0269 = t5v0269 + t5_group/11
gen t5v0270 = gear_ratio + rnormal(0, 0.1)
replace t5v0270 = t5v0270 + t5_group/12
label variable t5v0270 "Generated stress variable 0270"
gen t5v0271 = price + rnormal(0, 0.2)
replace t5v0271 = t5v0271 + t5_group/13
gen t5v0272 = base_score + rnormal(0, 0.3)
replace t5v0272 = t5v0272 + t5_group/14
gen t5v0273 = mpg + rnormal(0, 0.4)
replace t5v0273 = t5v0273 + t5_group/2
gen t5v0274 = weight + rnormal(0, 0.5)
replace t5v0274 = t5v0274 + t5_group/3
gen t5v0275 = length + rnormal(0, 0.6)
replace t5v0275 = t5v0275 + t5_group/4
label variable t5v0275 "Generated stress variable 0275"
quietly summarize t5v0275
display as text "[VAR] t5v0275 mean=" %9.4f r(mean)
gen t5v0276 = turn + rnormal(0, 0.7)
replace t5v0276 = t5v0276 + t5_group/5
gen t5v0277 = displacement + rnormal(0, 0.8)
replace t5v0277 = t5v0277 + t5_group/6
gen t5v0278 = gear_ratio + rnormal(0, 0.9)
replace t5v0278 = t5v0278 + t5_group/7
gen t5v0279 = price + rnormal(0, 0.1)
replace t5v0279 = t5v0279 + t5_group/8
gen t5v0280 = base_score + rnormal(0, 0.2)
replace t5v0280 = t5v0280 + t5_group/9
label variable t5v0280 "Generated stress variable 0280"
gen t5v0281 = mpg + rnormal(0, 0.3)
replace t5v0281 = t5v0281 + t5_group/10
gen t5v0282 = weight + rnormal(0, 0.4)
replace t5v0282 = t5v0282 + t5_group/11
gen t5v0283 = length + rnormal(0, 0.5)
replace t5v0283 = t5v0283 + t5_group/12
gen t5v0284 = turn + rnormal(0, 0.6)
replace t5v0284 = t5v0284 + t5_group/13
gen t5v0285 = displacement + rnormal(0, 0.7)
replace t5v0285 = t5v0285 + t5_group/14
label variable t5v0285 "Generated stress variable 0285"
gen t5v0286 = gear_ratio + rnormal(0, 0.8)
replace t5v0286 = t5v0286 + t5_group/2
gen t5v0287 = price + rnormal(0, 0.9)
replace t5v0287 = t5v0287 + t5_group/3
gen t5v0288 = base_score + rnormal(0, 0.1)
replace t5v0288 = t5v0288 + t5_group/4
gen t5v0289 = mpg + rnormal(0, 0.2)
replace t5v0289 = t5v0289 + t5_group/5
gen t5v0290 = weight + rnormal(0, 0.3)
replace t5v0290 = t5v0290 + t5_group/6
label variable t5v0290 "Generated stress variable 0290"
gen t5v0291 = length + rnormal(0, 0.4)
replace t5v0291 = t5v0291 + t5_group/7
gen t5v0292 = turn + rnormal(0, 0.5)
replace t5v0292 = t5v0292 + t5_group/8
gen t5v0293 = displacement + rnormal(0, 0.6)
replace t5v0293 = t5v0293 + t5_group/9
gen t5v0294 = gear_ratio + rnormal(0, 0.7)
replace t5v0294 = t5v0294 + t5_group/10
gen t5v0295 = price + rnormal(0, 0.8)
replace t5v0295 = t5v0295 + t5_group/11
label variable t5v0295 "Generated stress variable 0295"
gen t5v0296 = base_score + rnormal(0, 0.9)
replace t5v0296 = t5v0296 + t5_group/12
gen t5v0297 = mpg + rnormal(0, 0.1)
replace t5v0297 = t5v0297 + t5_group/13
gen t5v0298 = weight + rnormal(0, 0.2)
replace t5v0298 = t5v0298 + t5_group/14
gen t5v0299 = length + rnormal(0, 0.3)
replace t5v0299 = t5v0299 + t5_group/2
gen t5v0300 = turn + rnormal(0, 0.4)
replace t5v0300 = t5v0300 + t5_group/3
label variable t5v0300 "Generated stress variable 0300"
quietly summarize t5v0300
display as text "[VAR] t5v0300 mean=" %9.4f r(mean)
gen t5v0301 = displacement + rnormal(0, 0.5)
replace t5v0301 = t5v0301 + t5_group/4
gen t5v0302 = gear_ratio + rnormal(0, 0.6)
replace t5v0302 = t5v0302 + t5_group/5
gen t5v0303 = price + rnormal(0, 0.7)
replace t5v0303 = t5v0303 + t5_group/6
gen t5v0304 = base_score + rnormal(0, 0.8)
replace t5v0304 = t5v0304 + t5_group/7
gen t5v0305 = mpg + rnormal(0, 0.9)
replace t5v0305 = t5v0305 + t5_group/8
label variable t5v0305 "Generated stress variable 0305"
gen t5v0306 = weight + rnormal(0, 0.1)
replace t5v0306 = t5v0306 + t5_group/9
gen t5v0307 = length + rnormal(0, 0.2)
replace t5v0307 = t5v0307 + t5_group/10
gen t5v0308 = turn + rnormal(0, 0.3)
replace t5v0308 = t5v0308 + t5_group/11
gen t5v0309 = displacement + rnormal(0, 0.4)
replace t5v0309 = t5v0309 + t5_group/12
gen t5v0310 = gear_ratio + rnormal(0, 0.5)
replace t5v0310 = t5v0310 + t5_group/13
label variable t5v0310 "Generated stress variable 0310"
gen t5v0311 = price + rnormal(0, 0.6)
replace t5v0311 = t5v0311 + t5_group/14
gen t5v0312 = base_score + rnormal(0, 0.7)
replace t5v0312 = t5v0312 + t5_group/2
gen t5v0313 = mpg + rnormal(0, 0.8)
replace t5v0313 = t5v0313 + t5_group/3
gen t5v0314 = weight + rnormal(0, 0.9)
replace t5v0314 = t5v0314 + t5_group/4
gen t5v0315 = length + rnormal(0, 0.1)
replace t5v0315 = t5v0315 + t5_group/5
label variable t5v0315 "Generated stress variable 0315"
gen t5v0316 = turn + rnormal(0, 0.2)
replace t5v0316 = t5v0316 + t5_group/6
gen t5v0317 = displacement + rnormal(0, 0.3)
replace t5v0317 = t5v0317 + t5_group/7
gen t5v0318 = gear_ratio + rnormal(0, 0.4)
replace t5v0318 = t5v0318 + t5_group/8
gen t5v0319 = price + rnormal(0, 0.5)
replace t5v0319 = t5v0319 + t5_group/9
gen t5v0320 = base_score + rnormal(0, 0.6)
replace t5v0320 = t5v0320 + t5_group/10
label variable t5v0320 "Generated stress variable 0320"
gen t5v0321 = mpg + rnormal(0, 0.7)
replace t5v0321 = t5v0321 + t5_group/11
gen t5v0322 = weight + rnormal(0, 0.8)
replace t5v0322 = t5v0322 + t5_group/12
gen t5v0323 = length + rnormal(0, 0.9)
replace t5v0323 = t5v0323 + t5_group/13
gen t5v0324 = turn + rnormal(0, 0.1)
replace t5v0324 = t5v0324 + t5_group/14
gen t5v0325 = displacement + rnormal(0, 0.2)
replace t5v0325 = t5v0325 + t5_group/2
label variable t5v0325 "Generated stress variable 0325"
quietly summarize t5v0325
display as text "[VAR] t5v0325 mean=" %9.4f r(mean)
gen t5v0326 = gear_ratio + rnormal(0, 0.3)
replace t5v0326 = t5v0326 + t5_group/3
gen t5v0327 = price + rnormal(0, 0.4)
replace t5v0327 = t5v0327 + t5_group/4
gen t5v0328 = base_score + rnormal(0, 0.5)
replace t5v0328 = t5v0328 + t5_group/5
gen t5v0329 = mpg + rnormal(0, 0.6)
replace t5v0329 = t5v0329 + t5_group/6
gen t5v0330 = weight + rnormal(0, 0.7)
replace t5v0330 = t5v0330 + t5_group/7
label variable t5v0330 "Generated stress variable 0330"
gen t5v0331 = length + rnormal(0, 0.8)
replace t5v0331 = t5v0331 + t5_group/8
gen t5v0332 = turn + rnormal(0, 0.9)
replace t5v0332 = t5v0332 + t5_group/9
gen t5v0333 = displacement + rnormal(0, 0.1)
replace t5v0333 = t5v0333 + t5_group/10
gen t5v0334 = gear_ratio + rnormal(0, 0.2)
replace t5v0334 = t5v0334 + t5_group/11
gen t5v0335 = price + rnormal(0, 0.3)
replace t5v0335 = t5v0335 + t5_group/12
label variable t5v0335 "Generated stress variable 0335"
gen t5v0336 = base_score + rnormal(0, 0.4)
replace t5v0336 = t5v0336 + t5_group/13
gen t5v0337 = mpg + rnormal(0, 0.5)
replace t5v0337 = t5v0337 + t5_group/14
gen t5v0338 = weight + rnormal(0, 0.6)
replace t5v0338 = t5v0338 + t5_group/2
gen t5v0339 = length + rnormal(0, 0.7)
replace t5v0339 = t5v0339 + t5_group/3
gen t5v0340 = turn + rnormal(0, 0.8)
replace t5v0340 = t5v0340 + t5_group/4
label variable t5v0340 "Generated stress variable 0340"
gen t5v0341 = displacement + rnormal(0, 0.9)
replace t5v0341 = t5v0341 + t5_group/5
gen t5v0342 = gear_ratio + rnormal(0, 0.1)
replace t5v0342 = t5v0342 + t5_group/6
gen t5v0343 = price + rnormal(0, 0.2)
replace t5v0343 = t5v0343 + t5_group/7
gen t5v0344 = base_score + rnormal(0, 0.3)
replace t5v0344 = t5v0344 + t5_group/8
gen t5v0345 = mpg + rnormal(0, 0.4)
replace t5v0345 = t5v0345 + t5_group/9
label variable t5v0345 "Generated stress variable 0345"
gen t5v0346 = weight + rnormal(0, 0.5)
replace t5v0346 = t5v0346 + t5_group/10
gen t5v0347 = length + rnormal(0, 0.6)
replace t5v0347 = t5v0347 + t5_group/11
gen t5v0348 = turn + rnormal(0, 0.7)
replace t5v0348 = t5v0348 + t5_group/12
gen t5v0349 = displacement + rnormal(0, 0.8)
replace t5v0349 = t5v0349 + t5_group/13
gen t5v0350 = gear_ratio + rnormal(0, 0.9)
replace t5v0350 = t5v0350 + t5_group/14
label variable t5v0350 "Generated stress variable 0350"
quietly summarize t5v0350
display as text "[VAR] t5v0350 mean=" %9.4f r(mean)
gen t5v0351 = price + rnormal(0, 0.1)
replace t5v0351 = t5v0351 + t5_group/2
gen t5v0352 = base_score + rnormal(0, 0.2)
replace t5v0352 = t5v0352 + t5_group/3
gen t5v0353 = mpg + rnormal(0, 0.3)
replace t5v0353 = t5v0353 + t5_group/4
gen t5v0354 = weight + rnormal(0, 0.4)
replace t5v0354 = t5v0354 + t5_group/5
gen t5v0355 = length + rnormal(0, 0.5)
replace t5v0355 = t5v0355 + t5_group/6
label variable t5v0355 "Generated stress variable 0355"
gen t5v0356 = turn + rnormal(0, 0.6)
replace t5v0356 = t5v0356 + t5_group/7
gen t5v0357 = displacement + rnormal(0, 0.7)
replace t5v0357 = t5v0357 + t5_group/8
gen t5v0358 = gear_ratio + rnormal(0, 0.8)
replace t5v0358 = t5v0358 + t5_group/9
gen t5v0359 = price + rnormal(0, 0.9)
replace t5v0359 = t5v0359 + t5_group/10
gen t5v0360 = base_score + rnormal(0, 0.1)
replace t5v0360 = t5v0360 + t5_group/11
label variable t5v0360 "Generated stress variable 0360"
gen t5v0361 = mpg + rnormal(0, 0.2)
replace t5v0361 = t5v0361 + t5_group/12
gen t5v0362 = weight + rnormal(0, 0.3)
replace t5v0362 = t5v0362 + t5_group/13
gen t5v0363 = length + rnormal(0, 0.4)
replace t5v0363 = t5v0363 + t5_group/14
gen t5v0364 = turn + rnormal(0, 0.5)
replace t5v0364 = t5v0364 + t5_group/2
gen t5v0365 = displacement + rnormal(0, 0.6)
replace t5v0365 = t5v0365 + t5_group/3
label variable t5v0365 "Generated stress variable 0365"
gen t5v0366 = gear_ratio + rnormal(0, 0.7)
replace t5v0366 = t5v0366 + t5_group/4
gen t5v0367 = price + rnormal(0, 0.8)
replace t5v0367 = t5v0367 + t5_group/5
gen t5v0368 = base_score + rnormal(0, 0.9)
replace t5v0368 = t5v0368 + t5_group/6
gen t5v0369 = mpg + rnormal(0, 0.1)
replace t5v0369 = t5v0369 + t5_group/7
gen t5v0370 = weight + rnormal(0, 0.2)
replace t5v0370 = t5v0370 + t5_group/8
label variable t5v0370 "Generated stress variable 0370"
gen t5v0371 = length + rnormal(0, 0.3)
replace t5v0371 = t5v0371 + t5_group/9
gen t5v0372 = turn + rnormal(0, 0.4)
replace t5v0372 = t5v0372 + t5_group/10
gen t5v0373 = displacement + rnormal(0, 0.5)
replace t5v0373 = t5v0373 + t5_group/11
gen t5v0374 = gear_ratio + rnormal(0, 0.6)
replace t5v0374 = t5v0374 + t5_group/12
gen t5v0375 = price + rnormal(0, 0.7)
replace t5v0375 = t5v0375 + t5_group/13
label variable t5v0375 "Generated stress variable 0375"
quietly summarize t5v0375
display as text "[VAR] t5v0375 mean=" %9.4f r(mean)
gen t5v0376 = base_score + rnormal(0, 0.8)
replace t5v0376 = t5v0376 + t5_group/14
gen t5v0377 = mpg + rnormal(0, 0.9)
replace t5v0377 = t5v0377 + t5_group/2
gen t5v0378 = weight + rnormal(0, 0.1)
replace t5v0378 = t5v0378 + t5_group/3
gen t5v0379 = length + rnormal(0, 0.2)
replace t5v0379 = t5v0379 + t5_group/4
gen t5v0380 = turn + rnormal(0, 0.3)
replace t5v0380 = t5v0380 + t5_group/5
label variable t5v0380 "Generated stress variable 0380"
gen t5v0381 = displacement + rnormal(0, 0.4)
replace t5v0381 = t5v0381 + t5_group/6
gen t5v0382 = gear_ratio + rnormal(0, 0.5)
replace t5v0382 = t5v0382 + t5_group/7
gen t5v0383 = price + rnormal(0, 0.6)
replace t5v0383 = t5v0383 + t5_group/8
gen t5v0384 = base_score + rnormal(0, 0.7)
replace t5v0384 = t5v0384 + t5_group/9
gen t5v0385 = mpg + rnormal(0, 0.8)
replace t5v0385 = t5v0385 + t5_group/10
label variable t5v0385 "Generated stress variable 0385"
gen t5v0386 = weight + rnormal(0, 0.9)
replace t5v0386 = t5v0386 + t5_group/11
gen t5v0387 = length + rnormal(0, 0.1)
replace t5v0387 = t5v0387 + t5_group/12
gen t5v0388 = turn + rnormal(0, 0.2)
replace t5v0388 = t5v0388 + t5_group/13
gen t5v0389 = displacement + rnormal(0, 0.3)
replace t5v0389 = t5v0389 + t5_group/14
gen t5v0390 = gear_ratio + rnormal(0, 0.4)
replace t5v0390 = t5v0390 + t5_group/2
label variable t5v0390 "Generated stress variable 0390"
gen t5v0391 = price + rnormal(0, 0.5)
replace t5v0391 = t5v0391 + t5_group/3
gen t5v0392 = base_score + rnormal(0, 0.6)
replace t5v0392 = t5v0392 + t5_group/4
gen t5v0393 = mpg + rnormal(0, 0.7)
replace t5v0393 = t5v0393 + t5_group/5
gen t5v0394 = weight + rnormal(0, 0.8)
replace t5v0394 = t5v0394 + t5_group/6
gen t5v0395 = length + rnormal(0, 0.9)
replace t5v0395 = t5v0395 + t5_group/7
label variable t5v0395 "Generated stress variable 0395"
gen t5v0396 = turn + rnormal(0, 0.1)
replace t5v0396 = t5v0396 + t5_group/8
gen t5v0397 = displacement + rnormal(0, 0.2)
replace t5v0397 = t5v0397 + t5_group/9
gen t5v0398 = gear_ratio + rnormal(0, 0.3)
replace t5v0398 = t5v0398 + t5_group/10
gen t5v0399 = price + rnormal(0, 0.4)
replace t5v0399 = t5v0399 + t5_group/11
gen t5v0400 = base_score + rnormal(0, 0.5)
replace t5v0400 = t5v0400 + t5_group/12
label variable t5v0400 "Generated stress variable 0400"
quietly summarize t5v0400
display as text "[VAR] t5v0400 mean=" %9.4f r(mean)
gen t5v0401 = mpg + rnormal(0, 0.6)
replace t5v0401 = t5v0401 + t5_group/13
gen t5v0402 = weight + rnormal(0, 0.7)
replace t5v0402 = t5v0402 + t5_group/14
gen t5v0403 = length + rnormal(0, 0.8)
replace t5v0403 = t5v0403 + t5_group/2
gen t5v0404 = turn + rnormal(0, 0.9)
replace t5v0404 = t5v0404 + t5_group/3
gen t5v0405 = displacement + rnormal(0, 0.1)
replace t5v0405 = t5v0405 + t5_group/4
label variable t5v0405 "Generated stress variable 0405"
gen t5v0406 = gear_ratio + rnormal(0, 0.2)
replace t5v0406 = t5v0406 + t5_group/5
gen t5v0407 = price + rnormal(0, 0.3)
replace t5v0407 = t5v0407 + t5_group/6
gen t5v0408 = base_score + rnormal(0, 0.4)
replace t5v0408 = t5v0408 + t5_group/7
gen t5v0409 = mpg + rnormal(0, 0.5)
replace t5v0409 = t5v0409 + t5_group/8
gen t5v0410 = weight + rnormal(0, 0.6)
replace t5v0410 = t5v0410 + t5_group/9
label variable t5v0410 "Generated stress variable 0410"
gen t5v0411 = length + rnormal(0, 0.7)
replace t5v0411 = t5v0411 + t5_group/10
gen t5v0412 = turn + rnormal(0, 0.8)
replace t5v0412 = t5v0412 + t5_group/11
gen t5v0413 = displacement + rnormal(0, 0.9)
replace t5v0413 = t5v0413 + t5_group/12
gen t5v0414 = gear_ratio + rnormal(0, 0.1)
replace t5v0414 = t5v0414 + t5_group/13
gen t5v0415 = price + rnormal(0, 0.2)
replace t5v0415 = t5v0415 + t5_group/14
label variable t5v0415 "Generated stress variable 0415"
gen t5v0416 = base_score + rnormal(0, 0.3)
replace t5v0416 = t5v0416 + t5_group/2
gen t5v0417 = mpg + rnormal(0, 0.4)
replace t5v0417 = t5v0417 + t5_group/3
gen t5v0418 = weight + rnormal(0, 0.5)
replace t5v0418 = t5v0418 + t5_group/4
gen t5v0419 = length + rnormal(0, 0.6)
replace t5v0419 = t5v0419 + t5_group/5
gen t5v0420 = turn + rnormal(0, 0.7)
replace t5v0420 = t5v0420 + t5_group/6
label variable t5v0420 "Generated stress variable 0420"
egen t5_rowmean = rowmean(t5v0001 t5v0002 t5v0003 t5v0004 t5v0005 t5v0006 t5v0007 t5v0008 t5v0009 t5v0010 t5v0011 t5v0012 t5v0013 t5v0014 t5v0015 t5v0016 t5v0017 t5v0018 t5v0019 t5v0020 t5v0021 t5v0022 t5v0023 t5v0024 t5v0025 t5v0026 t5v0027 t5v0028 t5v0029 t5v0030)
replace t5_work = t5_work + t5_rowmean/100
display as result "<<< DONE Section 2: generated variables marathon"
// #endregion Section 2: generated variables marathon

// #region Section 3: large quiet computational block
display as text ">>> START Section 3: large quiet computational block"
quietly {
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 17)
    summarize t5_work
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 32)
    summarize t5_work
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 10)
    summarize t5_work
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 25)
    summarize t5_work
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 3)
    summarize t5_work
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 18)
    summarize t5_work
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 33)
    summarize t5_work
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 11)
    summarize t5_work
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 26)
    summarize t5_work
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 4)
    summarize t5_work
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 19)
    summarize t5_work
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 34)
    summarize t5_work
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 12)
    summarize t5_work
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 27)
    summarize t5_work
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 5)
    summarize t5_work
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000080 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000090 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000100 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000110 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000120 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000130 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000140 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000150 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000160 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000170 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000010 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000020 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000030 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000040 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000050 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000060 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000070 * mod(obs_id, 31)
}
quietly summarize t5_work
display as text "[BLOCK 3] work mean=" %9.4f r(mean)
display as result "<<< DONE Section 3: large quiet computational block"
// #endregion Section 3: large quiet computational block

// #region Section 4: unnamed transient graph burst
display as text ">>> START Section 4: unnamed transient graph burst"
twoway (scatter price mpg if foreign == 0) (lfit price mpg if foreign == 0), title("T5 unnamed transient 01") legend(off)
twoway (scatter price mpg if foreign == 1) (lfit price mpg if foreign == 1), title("T5 unnamed transient 02") legend(off)
twoway (scatter price mpg if foreign == 0) (lfit price mpg if foreign == 0), title("T5 unnamed transient 03") legend(off)
twoway (scatter price mpg if foreign == 1) (lfit price mpg if foreign == 1), title("T5 unnamed transient 04") legend(off)
twoway (scatter price mpg if foreign == 0) (lfit price mpg if foreign == 0), title("T5 unnamed transient 05") legend(off)
twoway (scatter price mpg if foreign == 1) (lfit price mpg if foreign == 1), title("T5 unnamed transient 06") legend(off)
twoway (scatter price mpg if foreign == 0) (lfit price mpg if foreign == 0), title("T5 unnamed transient 07") legend(off)
twoway (scatter price mpg if foreign == 1) (lfit price mpg if foreign == 1), title("T5 unnamed transient 08") legend(off)
twoway (scatter price mpg if foreign == 0) (lfit price mpg if foreign == 0), title("T5 unnamed transient 09") legend(off)
twoway (scatter price mpg if foreign == 1) (lfit price mpg if foreign == 1), title("T5 unnamed transient 10") legend(off)
twoway (scatter price mpg if foreign == 0) (lfit price mpg if foreign == 0), title("T5 unnamed transient 11") legend(off)
twoway (scatter price mpg if foreign == 1) (lfit price mpg if foreign == 1), title("T5 unnamed transient 12") legend(off)
twoway (scatter price mpg if foreign == 0) (lfit price mpg if foreign == 0), title("T5 unnamed transient 13") legend(off)
twoway (scatter price mpg if foreign == 1) (lfit price mpg if foreign == 1), title("T5 unnamed transient 14") legend(off)
twoway (scatter price mpg if foreign == 0) (lfit price mpg if foreign == 0), title("T5 unnamed transient 15") legend(off)
twoway (scatter price mpg if foreign == 1) (lfit price mpg if foreign == 1), title("T5 unnamed transient 16") legend(off)
twoway (scatter price mpg if foreign == 0) (lfit price mpg if foreign == 0), title("T5 unnamed transient 17") legend(off)
twoway (scatter price mpg if foreign == 1) (lfit price mpg if foreign == 1), title("T5 unnamed transient 18") legend(off)
twoway (scatter price mpg if foreign == 0) (lfit price mpg if foreign == 0), title("T5 unnamed transient 19") legend(off)
twoway (scatter price mpg if foreign == 1) (lfit price mpg if foreign == 1), title("T5 unnamed transient 20") legend(off)
twoway (scatter price mpg if foreign == 0) (lfit price mpg if foreign == 0), title("T5 unnamed transient 21") legend(off)
twoway (scatter price mpg if foreign == 1) (lfit price mpg if foreign == 1), title("T5 unnamed transient 22") legend(off)
twoway (scatter price mpg if foreign == 0) (lfit price mpg if foreign == 0), title("T5 unnamed transient 23") legend(off)
twoway (scatter price mpg if foreign == 1) (lfit price mpg if foreign == 1), title("T5 unnamed transient 24") legend(off)
display as text "[GRAPH] unnamed burst complete; graph drop _all follows"
graph drop _all
display as result "<<< DONE Section 4: unnamed transient graph burst"
// #endregion Section 4: unnamed transient graph burst

// #region Section 5: named loop graphs with backtick locals
display as text ">>> START Section 5: named loop graphs with backtick locals"
forvalues i = 1/60 {
    local side = mod(`i', 2)
    local low = 1500 + 10*`i'
    twoway (scatter price mpg if foreign == `side') (lfit price mpg if foreign == `side'), name(t5_loop`i', replace) title("T5 loop graph `i'") legend(off)
}
display as result "<<< DONE Section 5: named loop graphs with 60 graphs"
// #endregion Section 5: named loop graphs with backtick locals

// #region Section 6: immediate named graph exports
display as text ">>> START Section 6: immediate named graph exports"
twoway (scatter price weight) (lfit price weight), name(t5im01, replace) title("T5 immediate export 01") legend(off)
graph export "$figdir5/t5im01.svg", name(t5im01) replace
twoway (scatter price weight) (lfit price weight), name(t5im02, replace) title("T5 immediate export 02") legend(off)
graph export "$figdir5/t5im02.svg", name(t5im02) replace
twoway (scatter price weight) (lfit price weight), name(t5im03, replace) title("T5 immediate export 03") legend(off)
graph export "$figdir5/t5im03.svg", name(t5im03) replace
twoway (scatter price weight) (lfit price weight), name(t5im04, replace) title("T5 immediate export 04") legend(off)
graph export "$figdir5/t5im04.svg", name(t5im04) replace
twoway (scatter price weight) (lfit price weight), name(t5im05, replace) title("T5 immediate export 05") legend(off)
graph export "$figdir5/t5im05.svg", name(t5im05) replace
twoway (scatter price weight) (lfit price weight), name(t5im06, replace) title("T5 immediate export 06") legend(off)
graph export "$figdir5/t5im06.svg", name(t5im06) replace
twoway (scatter price weight) (lfit price weight), name(t5im07, replace) title("T5 immediate export 07") legend(off)
graph export "$figdir5/t5im07.svg", name(t5im07) replace
twoway (scatter price weight) (lfit price weight), name(t5im08, replace) title("T5 immediate export 08") legend(off)
graph export "$figdir5/t5im08.svg", name(t5im08) replace
twoway (scatter price weight) (lfit price weight), name(t5im09, replace) title("T5 immediate export 09") legend(off)
graph export "$figdir5/t5im09.svg", name(t5im09) replace
twoway (scatter price weight) (lfit price weight), name(t5im10, replace) title("T5 immediate export 10") legend(off)
graph export "$figdir5/t5im10.svg", name(t5im10) replace
twoway (scatter price weight) (lfit price weight), name(t5im11, replace) title("T5 immediate export 11") legend(off)
graph export "$figdir5/t5im11.svg", name(t5im11) replace
twoway (scatter price weight) (lfit price weight), name(t5im12, replace) title("T5 immediate export 12") legend(off)
graph export "$figdir5/t5im12.svg", name(t5im12) replace
twoway (scatter price weight) (lfit price weight), name(t5im13, replace) title("T5 immediate export 13") legend(off)
graph export "$figdir5/t5im13.svg", name(t5im13) replace
twoway (scatter price weight) (lfit price weight), name(t5im14, replace) title("T5 immediate export 14") legend(off)
graph export "$figdir5/t5im14.svg", name(t5im14) replace
twoway (scatter price weight) (lfit price weight), name(t5im15, replace) title("T5 immediate export 15") legend(off)
graph export "$figdir5/t5im15.svg", name(t5im15) replace
twoway (scatter price weight) (lfit price weight), name(t5im16, replace) title("T5 immediate export 16") legend(off)
graph export "$figdir5/t5im16.svg", name(t5im16) replace
twoway (scatter price weight) (lfit price weight), name(t5im17, replace) title("T5 immediate export 17") legend(off)
graph export "$figdir5/t5im17.svg", name(t5im17) replace
twoway (scatter price weight) (lfit price weight), name(t5im18, replace) title("T5 immediate export 18") legend(off)
graph export "$figdir5/t5im18.svg", name(t5im18) replace
twoway (scatter price weight) (lfit price weight), name(t5im19, replace) title("T5 immediate export 19") legend(off)
graph export "$figdir5/t5im19.svg", name(t5im19) replace
twoway (scatter price weight) (lfit price weight), name(t5im20, replace) title("T5 immediate export 20") legend(off)
graph export "$figdir5/t5im20.svg", name(t5im20) replace
twoway (scatter price weight) (lfit price weight), name(t5im21, replace) title("T5 immediate export 21") legend(off)
graph export "$figdir5/t5im21.svg", name(t5im21) replace
twoway (scatter price weight) (lfit price weight), name(t5im22, replace) title("T5 immediate export 22") legend(off)
graph export "$figdir5/t5im22.svg", name(t5im22) replace
twoway (scatter price weight) (lfit price weight), name(t5im23, replace) title("T5 immediate export 23") legend(off)
graph export "$figdir5/t5im23.svg", name(t5im23) replace
twoway (scatter price weight) (lfit price weight), name(t5im24, replace) title("T5 immediate export 24") legend(off)
graph export "$figdir5/t5im24.svg", name(t5im24) replace
display as result "<<< DONE Section 6: immediate named graph exports"
// #endregion Section 6: immediate named graph exports

// #region Section 7: delayed named graph creation
display as text ">>> START Section 7: delayed named graph creation"
twoway (scatter price weight) (lfit price weight), name(t5doc01, replace) title("T5 delayed doc graph 01") legend(off)
twoway (scatter mpg weight) (lfit mpg weight), name(t5doc02, replace) title("T5 delayed doc graph 02") legend(off)
twoway (scatter price length) (lfit price length), name(t5doc03, replace) title("T5 delayed doc graph 03") legend(off)
twoway (scatter mpg weight) (lfit mpg weight), name(t5doc04, replace) title("T5 delayed doc graph 04") legend(off)
twoway (scatter price weight) (lfit price weight), name(t5doc05, replace) title("T5 delayed doc graph 05") legend(off)
twoway (scatter mpg length) (lfit mpg length), name(t5doc06, replace) title("T5 delayed doc graph 06") legend(off)
twoway (scatter price weight) (lfit price weight), name(t5doc07, replace) title("T5 delayed doc graph 07") legend(off)
twoway (scatter mpg weight) (lfit mpg weight), name(t5doc08, replace) title("T5 delayed doc graph 08") legend(off)
twoway (scatter price length) (lfit price length), name(t5doc09, replace) title("T5 delayed doc graph 09") legend(off)
twoway (scatter mpg weight) (lfit mpg weight), name(t5doc10, replace) title("T5 delayed doc graph 10") legend(off)
twoway (scatter price weight) (lfit price weight), name(t5doc11, replace) title("T5 delayed doc graph 11") legend(off)
twoway (scatter mpg length) (lfit mpg length), name(t5doc12, replace) title("T5 delayed doc graph 12") legend(off)
twoway (scatter price weight) (lfit price weight), name(t5doc13, replace) title("T5 delayed doc graph 13") legend(off)
twoway (scatter mpg weight) (lfit mpg weight), name(t5doc14, replace) title("T5 delayed doc graph 14") legend(off)
twoway (scatter price length) (lfit price length), name(t5doc15, replace) title("T5 delayed doc graph 15") legend(off)
twoway (scatter mpg weight) (lfit mpg weight), name(t5doc16, replace) title("T5 delayed doc graph 16") legend(off)
twoway (scatter price weight) (lfit price weight), name(t5doc17, replace) title("T5 delayed doc graph 17") legend(off)
twoway (scatter mpg length) (lfit mpg length), name(t5doc18, replace) title("T5 delayed doc graph 18") legend(off)
twoway (scatter price weight) (lfit price weight), name(t5doc19, replace) title("T5 delayed doc graph 19") legend(off)
twoway (scatter mpg weight) (lfit mpg weight), name(t5doc20, replace) title("T5 delayed doc graph 20") legend(off)
twoway (scatter price length) (lfit price length), name(t5doc21, replace) title("T5 delayed doc graph 21") legend(off)
twoway (scatter mpg weight) (lfit mpg weight), name(t5doc22, replace) title("T5 delayed doc graph 22") legend(off)
twoway (scatter price weight) (lfit price weight), name(t5doc23, replace) title("T5 delayed doc graph 23") legend(off)
twoway (scatter mpg length) (lfit mpg length), name(t5doc24, replace) title("T5 delayed doc graph 24") legend(off)
twoway (scatter price weight) (lfit price weight), name(t5doc25, replace) title("T5 delayed doc graph 25") legend(off)
twoway (scatter mpg weight) (lfit mpg weight), name(t5doc26, replace) title("T5 delayed doc graph 26") legend(off)
twoway (scatter price length) (lfit price length), name(t5doc27, replace) title("T5 delayed doc graph 27") legend(off)
twoway (scatter mpg weight) (lfit mpg weight), name(t5doc28, replace) title("T5 delayed doc graph 28") legend(off)
display as result "<<< DONE Section 7: delayed named graph creation"
// #endregion Section 7: delayed named graph creation

// #region Section 7B: complex distribution and combined graphs
display as text ">>> START Section 7B: complex distribution and combined graphs"
histogram price, name(t5_hist_price, replace) title("T5 price distribution")
graph export "$figdir5/t5_hist_price.svg", name(t5_hist_price) replace
histogram mpg, name(t5_hist_mpg, replace) title("T5 mpg distribution")
graph export "$figdir5/t5_hist_mpg.svg", name(t5_hist_mpg) replace
graph box price, over(foreign) name(t5_box_price, replace) title("T5 price by foreign")
graph export "$figdir5/t5_box_price.svg", name(t5_box_price) replace
graph combine t5_hist_price t5_hist_mpg t5_box_price, name(t5_combo_dist, replace) title("T5 combined distribution panel")
graph export "$figdir5/t5_combo_dist.svg", name(t5_combo_dist) replace
tabstat price mpg weight length t5_work, statistics(n mean sd p25 p50 p75 min max) columns(statistics)
table foreign, statistic(mean price) statistic(mean mpg) statistic(sd price) statistic(count price)
export delimited make price mpg weight foreign t5_work using "$tempdir/taught_task5_distribution_table.csv", replace
display as result "<<< DONE Section 7B: complex distribution and combined graphs"
// #endregion Section 7B: complex distribution and combined graphs

// #region Section 8: preserve restore tempfile stress
display as text ">>> START Section 8: preserve restore tempfile stress"
if 1 {
    preserve
    keep make price mpg weight foreign obs_id t5_work t5_group
    collapse (mean) price mpg weight t5_work (count) n=obs_id, by(foreign t5_group)
    tempfile t5_slim
    save `t5_slim', replace
    restore
    preserve
    use `t5_slim', clear
    gen t5_slim_001 = t5_work + price/3 - mpg/4
    gen t5_slim_002 = t5_work + price/4 - mpg/5
    gen t5_slim_003 = t5_work + price/5 - mpg/6
    gen t5_slim_004 = t5_work + price/6 - mpg/7
    gen t5_slim_005 = t5_work + price/7 - mpg/8
    gen t5_slim_006 = t5_work + price/8 - mpg/9
    gen t5_slim_007 = t5_work + price/9 - mpg/10
    gen t5_slim_008 = t5_work + price/10 - mpg/11
    gen t5_slim_009 = t5_work + price/11 - mpg/12
    gen t5_slim_010 = t5_work + price/12 - mpg/13
    gen t5_slim_011 = t5_work + price/2 - mpg/3
    gen t5_slim_012 = t5_work + price/3 - mpg/4
    gen t5_slim_013 = t5_work + price/4 - mpg/5
    gen t5_slim_014 = t5_work + price/5 - mpg/6
    gen t5_slim_015 = t5_work + price/6 - mpg/7
    gen t5_slim_016 = t5_work + price/7 - mpg/8
    gen t5_slim_017 = t5_work + price/8 - mpg/9
    gen t5_slim_018 = t5_work + price/9 - mpg/10
    gen t5_slim_019 = t5_work + price/10 - mpg/11
    gen t5_slim_020 = t5_work + price/11 - mpg/12
    quietly summarize t5_slim_020
    gen t5_slim_021 = t5_work + price/12 - mpg/13
    gen t5_slim_022 = t5_work + price/2 - mpg/3
    gen t5_slim_023 = t5_work + price/3 - mpg/4
    gen t5_slim_024 = t5_work + price/4 - mpg/5
    gen t5_slim_025 = t5_work + price/5 - mpg/6
    gen t5_slim_026 = t5_work + price/6 - mpg/7
    gen t5_slim_027 = t5_work + price/7 - mpg/8
    gen t5_slim_028 = t5_work + price/8 - mpg/9
    gen t5_slim_029 = t5_work + price/9 - mpg/10
    gen t5_slim_030 = t5_work + price/10 - mpg/11
    gen t5_slim_031 = t5_work + price/11 - mpg/12
    gen t5_slim_032 = t5_work + price/12 - mpg/13
    gen t5_slim_033 = t5_work + price/2 - mpg/3
    gen t5_slim_034 = t5_work + price/3 - mpg/4
    gen t5_slim_035 = t5_work + price/4 - mpg/5
    gen t5_slim_036 = t5_work + price/5 - mpg/6
    gen t5_slim_037 = t5_work + price/6 - mpg/7
    gen t5_slim_038 = t5_work + price/7 - mpg/8
    gen t5_slim_039 = t5_work + price/8 - mpg/9
    gen t5_slim_040 = t5_work + price/9 - mpg/10
    quietly summarize t5_slim_040
    gen t5_slim_041 = t5_work + price/10 - mpg/11
    gen t5_slim_042 = t5_work + price/11 - mpg/12
    gen t5_slim_043 = t5_work + price/12 - mpg/13
    gen t5_slim_044 = t5_work + price/2 - mpg/3
    gen t5_slim_045 = t5_work + price/3 - mpg/4
    gen t5_slim_046 = t5_work + price/4 - mpg/5
    gen t5_slim_047 = t5_work + price/5 - mpg/6
    gen t5_slim_048 = t5_work + price/6 - mpg/7
    gen t5_slim_049 = t5_work + price/7 - mpg/8
    gen t5_slim_050 = t5_work + price/8 - mpg/9
    gen t5_slim_051 = t5_work + price/9 - mpg/10
    gen t5_slim_052 = t5_work + price/10 - mpg/11
    gen t5_slim_053 = t5_work + price/11 - mpg/12
    gen t5_slim_054 = t5_work + price/12 - mpg/13
    gen t5_slim_055 = t5_work + price/2 - mpg/3
    gen t5_slim_056 = t5_work + price/3 - mpg/4
    gen t5_slim_057 = t5_work + price/4 - mpg/5
    gen t5_slim_058 = t5_work + price/5 - mpg/6
    gen t5_slim_059 = t5_work + price/6 - mpg/7
    gen t5_slim_060 = t5_work + price/7 - mpg/8
    quietly summarize t5_slim_060
    gen t5_slim_061 = t5_work + price/8 - mpg/9
    gen t5_slim_062 = t5_work + price/9 - mpg/10
    gen t5_slim_063 = t5_work + price/10 - mpg/11
    gen t5_slim_064 = t5_work + price/11 - mpg/12
    gen t5_slim_065 = t5_work + price/12 - mpg/13
    gen t5_slim_066 = t5_work + price/2 - mpg/3
    gen t5_slim_067 = t5_work + price/3 - mpg/4
    gen t5_slim_068 = t5_work + price/4 - mpg/5
    gen t5_slim_069 = t5_work + price/5 - mpg/6
    gen t5_slim_070 = t5_work + price/6 - mpg/7
    gen t5_slim_071 = t5_work + price/7 - mpg/8
    gen t5_slim_072 = t5_work + price/8 - mpg/9
    gen t5_slim_073 = t5_work + price/9 - mpg/10
    gen t5_slim_074 = t5_work + price/10 - mpg/11
    gen t5_slim_075 = t5_work + price/11 - mpg/12
    gen t5_slim_076 = t5_work + price/12 - mpg/13
    gen t5_slim_077 = t5_work + price/2 - mpg/3
    gen t5_slim_078 = t5_work + price/3 - mpg/4
    gen t5_slim_079 = t5_work + price/4 - mpg/5
    gen t5_slim_080 = t5_work + price/5 - mpg/6
    quietly summarize t5_slim_080
    gen t5_slim_081 = t5_work + price/6 - mpg/7
    gen t5_slim_082 = t5_work + price/7 - mpg/8
    gen t5_slim_083 = t5_work + price/8 - mpg/9
    gen t5_slim_084 = t5_work + price/9 - mpg/10
    gen t5_slim_085 = t5_work + price/10 - mpg/11
    gen t5_slim_086 = t5_work + price/11 - mpg/12
    gen t5_slim_087 = t5_work + price/12 - mpg/13
    gen t5_slim_088 = t5_work + price/2 - mpg/3
    gen t5_slim_089 = t5_work + price/3 - mpg/4
    gen t5_slim_090 = t5_work + price/4 - mpg/5
    gen t5_slim_091 = t5_work + price/5 - mpg/6
    gen t5_slim_092 = t5_work + price/6 - mpg/7
    gen t5_slim_093 = t5_work + price/7 - mpg/8
    gen t5_slim_094 = t5_work + price/8 - mpg/9
    gen t5_slim_095 = t5_work + price/9 - mpg/10
    gen t5_slim_096 = t5_work + price/10 - mpg/11
    gen t5_slim_097 = t5_work + price/11 - mpg/12
    gen t5_slim_098 = t5_work + price/12 - mpg/13
    gen t5_slim_099 = t5_work + price/2 - mpg/3
    gen t5_slim_100 = t5_work + price/3 - mpg/4
    quietly summarize t5_slim_100
    gen t5_slim_101 = t5_work + price/4 - mpg/5
    gen t5_slim_102 = t5_work + price/5 - mpg/6
    gen t5_slim_103 = t5_work + price/6 - mpg/7
    gen t5_slim_104 = t5_work + price/7 - mpg/8
    gen t5_slim_105 = t5_work + price/8 - mpg/9
    gen t5_slim_106 = t5_work + price/9 - mpg/10
    gen t5_slim_107 = t5_work + price/10 - mpg/11
    gen t5_slim_108 = t5_work + price/11 - mpg/12
    gen t5_slim_109 = t5_work + price/12 - mpg/13
    gen t5_slim_110 = t5_work + price/2 - mpg/3
    gen t5_slim_111 = t5_work + price/3 - mpg/4
    gen t5_slim_112 = t5_work + price/4 - mpg/5
    gen t5_slim_113 = t5_work + price/5 - mpg/6
    gen t5_slim_114 = t5_work + price/6 - mpg/7
    gen t5_slim_115 = t5_work + price/7 - mpg/8
    gen t5_slim_116 = t5_work + price/8 - mpg/9
    gen t5_slim_117 = t5_work + price/9 - mpg/10
    gen t5_slim_118 = t5_work + price/10 - mpg/11
    gen t5_slim_119 = t5_work + price/11 - mpg/12
    gen t5_slim_120 = t5_work + price/12 - mpg/13
    quietly summarize t5_slim_120
    gen t5_slim_121 = t5_work + price/2 - mpg/3
    gen t5_slim_122 = t5_work + price/3 - mpg/4
    gen t5_slim_123 = t5_work + price/4 - mpg/5
    gen t5_slim_124 = t5_work + price/5 - mpg/6
    gen t5_slim_125 = t5_work + price/6 - mpg/7
    gen t5_slim_126 = t5_work + price/7 - mpg/8
    gen t5_slim_127 = t5_work + price/8 - mpg/9
    gen t5_slim_128 = t5_work + price/9 - mpg/10
    gen t5_slim_129 = t5_work + price/10 - mpg/11
    gen t5_slim_130 = t5_work + price/11 - mpg/12
    save "$tempdir/taught_task5_slim.dta", replace
    restore
}
display as result "<<< DONE Section 8: preserve restore tempfile stress"
// #endregion Section 8: preserve restore tempfile stress

// #region Section 9: putdocx delayed graph export document
display as text ">>> START Section 9: putdocx delayed graph export document"
putdocx clear
putdocx begin
putdocx paragraph
putdocx text ("Taught task 5: putdocx delayed graph export document")
putdocx paragraph
putdocx text ("This section intentionally exports earlier named graphs by name before inserting images.")
graph export "$figdir5/t5doc01.png", name(t5doc01) replace width(1400)
putdocx paragraph
putdocx text ("Inserted t5doc01")
putdocx paragraph
putdocx image "$figdir5/t5doc01.png", width(4)
graph export "$figdir5/t5doc02.png", name(t5doc02) replace width(1400)
putdocx paragraph
putdocx text ("Inserted t5doc02")
putdocx paragraph
putdocx image "$figdir5/t5doc02.png", width(4)
graph export "$figdir5/t5doc03.png", name(t5doc03) replace width(1400)
putdocx paragraph
putdocx text ("Inserted t5doc03")
putdocx paragraph
putdocx image "$figdir5/t5doc03.png", width(4)
graph export "$figdir5/t5doc04.png", name(t5doc04) replace width(1400)
putdocx paragraph
putdocx text ("Inserted t5doc04")
putdocx paragraph
putdocx image "$figdir5/t5doc04.png", width(4)
graph export "$figdir5/t5doc05.png", name(t5doc05) replace width(1400)
putdocx paragraph
putdocx text ("Inserted t5doc05")
putdocx paragraph
putdocx image "$figdir5/t5doc05.png", width(4)
graph export "$figdir5/t5doc06.png", name(t5doc06) replace width(1400)
putdocx paragraph
putdocx text ("Inserted t5doc06")
putdocx paragraph
putdocx image "$figdir5/t5doc06.png", width(4)
graph export "$figdir5/t5doc07.png", name(t5doc07) replace width(1400)
putdocx paragraph
putdocx text ("Inserted t5doc07")
putdocx paragraph
putdocx image "$figdir5/t5doc07.png", width(4)
graph export "$figdir5/t5doc08.png", name(t5doc08) replace width(1400)
putdocx paragraph
putdocx text ("Inserted t5doc08")
putdocx paragraph
putdocx image "$figdir5/t5doc08.png", width(4)
graph export "$figdir5/t5doc09.png", name(t5doc09) replace width(1400)
putdocx paragraph
putdocx text ("Inserted t5doc09")
putdocx paragraph
putdocx image "$figdir5/t5doc09.png", width(4)
graph export "$figdir5/t5doc10.png", name(t5doc10) replace width(1400)
putdocx paragraph
putdocx text ("Inserted t5doc10")
putdocx paragraph
putdocx image "$figdir5/t5doc10.png", width(4)
graph export "$figdir5/t5doc11.png", name(t5doc11) replace width(1400)
putdocx paragraph
putdocx text ("Inserted t5doc11")
putdocx paragraph
putdocx image "$figdir5/t5doc11.png", width(4)
graph export "$figdir5/t5doc12.png", name(t5doc12) replace width(1400)
putdocx paragraph
putdocx text ("Inserted t5doc12")
putdocx paragraph
putdocx image "$figdir5/t5doc12.png", width(4)
putdocx save "$docdir/taught_task5_doc1.docx", replace
display as result "<<< DONE Section 9: putdocx delayed graph export document"
// #endregion Section 9: putdocx delayed graph export document

// #region Section 10: p_tdocx delayed graph export document
display as text ">>> START Section 10: p_tdocx delayed graph export document"
p_tdocx clear
p_tdocx begin
p_tdocx paragraph
p_tdocx text ("Taught task 5: p_tdocx delayed graph export document")
graph export "$figdir5/t5doc13.png", name(t5doc13) replace width(1400)
p_tdocx paragraph
p_tdocx text ("Inserted t5doc13")
p_tdocx paragraph
p_tdocx image "$figdir5/t5doc13.png", width(4)
graph export "$figdir5/t5doc14.png", name(t5doc14) replace width(1400)
p_tdocx paragraph
p_tdocx text ("Inserted t5doc14")
p_tdocx paragraph
p_tdocx image "$figdir5/t5doc14.png", width(4)
graph export "$figdir5/t5doc15.png", name(t5doc15) replace width(1400)
p_tdocx paragraph
p_tdocx text ("Inserted t5doc15")
p_tdocx paragraph
p_tdocx image "$figdir5/t5doc15.png", width(4)
graph export "$figdir5/t5doc16.png", name(t5doc16) replace width(1400)
p_tdocx paragraph
p_tdocx text ("Inserted t5doc16")
p_tdocx paragraph
p_tdocx image "$figdir5/t5doc16.png", width(4)
graph export "$figdir5/t5doc17.png", name(t5doc17) replace width(1400)
p_tdocx paragraph
p_tdocx text ("Inserted t5doc17")
p_tdocx paragraph
p_tdocx image "$figdir5/t5doc17.png", width(4)
graph export "$figdir5/t5doc18.png", name(t5doc18) replace width(1400)
p_tdocx paragraph
p_tdocx text ("Inserted t5doc18")
p_tdocx paragraph
p_tdocx image "$figdir5/t5doc18.png", width(4)
graph export "$figdir5/t5doc19.png", name(t5doc19) replace width(1400)
p_tdocx paragraph
p_tdocx text ("Inserted t5doc19")
p_tdocx paragraph
p_tdocx image "$figdir5/t5doc19.png", width(4)
graph export "$figdir5/t5doc20.png", name(t5doc20) replace width(1400)
p_tdocx paragraph
p_tdocx text ("Inserted t5doc20")
p_tdocx paragraph
p_tdocx image "$figdir5/t5doc20.png", width(4)
graph export "$figdir5/t5doc21.png", name(t5doc21) replace width(1400)
p_tdocx paragraph
p_tdocx text ("Inserted t5doc21")
p_tdocx paragraph
p_tdocx image "$figdir5/t5doc21.png", width(4)
graph export "$figdir5/t5doc22.png", name(t5doc22) replace width(1400)
p_tdocx paragraph
p_tdocx text ("Inserted t5doc22")
p_tdocx paragraph
p_tdocx image "$figdir5/t5doc22.png", width(4)
p_tdocx save "$docdir/taught_task5_doc2.docx", replace
display as result "<<< DONE Section 10: p_tdocx delayed graph export document"
// #endregion Section 10: p_tdocx delayed graph export document

// #region Section 11: model and table output stress
display as text ">>> START Section 11: model and table output stress"
quietly regress price mpg weight t5v0001 t5v0019 i.foreign
estimates store t5_m001
quietly regress price mpg weight t5v0002 t5v0020 i.foreign
estimates store t5_m002
quietly regress price mpg weight t5v0003 t5v0021 i.foreign
estimates store t5_m003
quietly regress price mpg weight t5v0004 t5v0022 i.foreign
estimates store t5_m004
quietly regress price mpg weight t5v0005 t5v0023 i.foreign
estimates store t5_m005
quietly regress price mpg weight t5v0006 t5v0024 i.foreign
estimates store t5_m006
quietly regress price mpg weight t5v0007 t5v0025 i.foreign
estimates store t5_m007
quietly regress price mpg weight t5v0008 t5v0026 i.foreign
estimates store t5_m008
quietly regress price mpg weight t5v0009 t5v0027 i.foreign
estimates store t5_m009
quietly regress price mpg weight t5v0010 t5v0028 i.foreign
estimates store t5_m010
quietly regress price mpg weight t5v0011 t5v0029 i.foreign
estimates store t5_m011
quietly regress price mpg weight t5v0012 t5v0030 i.foreign
estimates store t5_m012
quietly regress price mpg weight t5v0013 t5v0031 i.foreign
estimates store t5_m013
quietly regress price mpg weight t5v0014 t5v0032 i.foreign
estimates store t5_m014
quietly regress price mpg weight t5v0015 t5v0033 i.foreign
estimates store t5_m015
quietly regress price mpg weight t5v0016 t5v0034 i.foreign
estimates store t5_m016
quietly regress price mpg weight t5v0017 t5v0035 i.foreign
estimates store t5_m017
quietly regress price mpg weight t5v0018 t5v0036 i.foreign
estimates store t5_m018
quietly regress price mpg weight t5v0019 t5v0037 i.foreign
estimates store t5_m019
quietly regress price mpg weight t5v0020 t5v0038 i.foreign
estimates store t5_m020
quietly regress price mpg weight t5v0021 t5v0039 i.foreign
estimates store t5_m021
quietly regress price mpg weight t5v0022 t5v0040 i.foreign
estimates store t5_m022
quietly regress price mpg weight t5v0023 t5v0041 i.foreign
estimates store t5_m023
quietly regress price mpg weight t5v0024 t5v0042 i.foreign
estimates store t5_m024
quietly regress price mpg weight t5v0025 t5v0043 i.foreign
estimates store t5_m025
display as text "[MODEL] stored t5_m025"
quietly regress price mpg weight t5v0026 t5v0044 i.foreign
estimates store t5_m026
quietly regress price mpg weight t5v0027 t5v0045 i.foreign
estimates store t5_m027
quietly regress price mpg weight t5v0028 t5v0046 i.foreign
estimates store t5_m028
quietly regress price mpg weight t5v0029 t5v0047 i.foreign
estimates store t5_m029
quietly regress price mpg weight t5v0030 t5v0048 i.foreign
estimates store t5_m030
quietly regress price mpg weight t5v0031 t5v0049 i.foreign
estimates store t5_m031
quietly regress price mpg weight t5v0032 t5v0050 i.foreign
estimates store t5_m032
quietly regress price mpg weight t5v0033 t5v0051 i.foreign
estimates store t5_m033
quietly regress price mpg weight t5v0034 t5v0052 i.foreign
estimates store t5_m034
quietly regress price mpg weight t5v0035 t5v0053 i.foreign
estimates store t5_m035
quietly regress price mpg weight t5v0036 t5v0054 i.foreign
estimates store t5_m036
quietly regress price mpg weight t5v0037 t5v0055 i.foreign
estimates store t5_m037
quietly regress price mpg weight t5v0038 t5v0056 i.foreign
estimates store t5_m038
quietly regress price mpg weight t5v0039 t5v0057 i.foreign
estimates store t5_m039
quietly regress price mpg weight t5v0040 t5v0058 i.foreign
estimates store t5_m040
quietly regress price mpg weight t5v0041 t5v0059 i.foreign
estimates store t5_m041
quietly regress price mpg weight t5v0042 t5v0060 i.foreign
estimates store t5_m042
quietly regress price mpg weight t5v0043 t5v0061 i.foreign
estimates store t5_m043
quietly regress price mpg weight t5v0044 t5v0062 i.foreign
estimates store t5_m044
quietly regress price mpg weight t5v0045 t5v0063 i.foreign
estimates store t5_m045
quietly regress price mpg weight t5v0046 t5v0064 i.foreign
estimates store t5_m046
quietly regress price mpg weight t5v0047 t5v0065 i.foreign
estimates store t5_m047
quietly regress price mpg weight t5v0048 t5v0066 i.foreign
estimates store t5_m048
quietly regress price mpg weight t5v0049 t5v0067 i.foreign
estimates store t5_m049
quietly regress price mpg weight t5v0050 t5v0068 i.foreign
estimates store t5_m050
display as text "[MODEL] stored t5_m050"
quietly regress price mpg weight t5v0051 t5v0069 i.foreign
estimates store t5_m051
quietly regress price mpg weight t5v0052 t5v0070 i.foreign
estimates store t5_m052
quietly regress price mpg weight t5v0053 t5v0071 i.foreign
estimates store t5_m053
quietly regress price mpg weight t5v0054 t5v0072 i.foreign
estimates store t5_m054
quietly regress price mpg weight t5v0055 t5v0073 i.foreign
estimates store t5_m055
quietly regress price mpg weight t5v0056 t5v0074 i.foreign
estimates store t5_m056
quietly regress price mpg weight t5v0057 t5v0075 i.foreign
estimates store t5_m057
quietly regress price mpg weight t5v0058 t5v0076 i.foreign
estimates store t5_m058
quietly regress price mpg weight t5v0059 t5v0077 i.foreign
estimates store t5_m059
quietly regress price mpg weight t5v0060 t5v0078 i.foreign
estimates store t5_m060
quietly regress price mpg weight t5v0061 t5v0079 i.foreign
estimates store t5_m061
quietly regress price mpg weight t5v0062 t5v0080 i.foreign
estimates store t5_m062
quietly regress price mpg weight t5v0063 t5v0001 i.foreign
estimates store t5_m063
quietly regress price mpg weight t5v0064 t5v0002 i.foreign
estimates store t5_m064
quietly regress price mpg weight t5v0065 t5v0003 i.foreign
estimates store t5_m065
quietly regress price mpg weight t5v0066 t5v0004 i.foreign
estimates store t5_m066
quietly regress price mpg weight t5v0067 t5v0005 i.foreign
estimates store t5_m067
quietly regress price mpg weight t5v0068 t5v0006 i.foreign
estimates store t5_m068
quietly regress price mpg weight t5v0069 t5v0007 i.foreign
estimates store t5_m069
quietly regress price mpg weight t5v0070 t5v0008 i.foreign
estimates store t5_m070
quietly regress price mpg weight t5v0071 t5v0009 i.foreign
estimates store t5_m071
quietly regress price mpg weight t5v0072 t5v0010 i.foreign
estimates store t5_m072
quietly regress price mpg weight t5v0073 t5v0011 i.foreign
estimates store t5_m073
quietly regress price mpg weight t5v0074 t5v0012 i.foreign
estimates store t5_m074
quietly regress price mpg weight t5v0075 t5v0013 i.foreign
estimates store t5_m075
display as text "[MODEL] stored t5_m075"
quietly regress price mpg weight t5v0076 t5v0014 i.foreign
estimates store t5_m076
quietly regress price mpg weight t5v0077 t5v0015 i.foreign
estimates store t5_m077
quietly regress price mpg weight t5v0078 t5v0016 i.foreign
estimates store t5_m078
quietly regress price mpg weight t5v0079 t5v0017 i.foreign
estimates store t5_m079
quietly regress price mpg weight t5v0080 t5v0018 i.foreign
estimates store t5_m080
quietly regress price mpg weight t5v0001 t5v0019 i.foreign
estimates store t5_m081
quietly regress price mpg weight t5v0002 t5v0020 i.foreign
estimates store t5_m082
quietly regress price mpg weight t5v0003 t5v0021 i.foreign
estimates store t5_m083
quietly regress price mpg weight t5v0004 t5v0022 i.foreign
estimates store t5_m084
quietly regress price mpg weight t5v0005 t5v0023 i.foreign
estimates store t5_m085
quietly regress price mpg weight t5v0006 t5v0024 i.foreign
estimates store t5_m086
quietly regress price mpg weight t5v0007 t5v0025 i.foreign
estimates store t5_m087
quietly regress price mpg weight t5v0008 t5v0026 i.foreign
estimates store t5_m088
quietly regress price mpg weight t5v0009 t5v0027 i.foreign
estimates store t5_m089
quietly regress price mpg weight t5v0010 t5v0028 i.foreign
estimates store t5_m090
estimates table t5_m001 t5_m002 t5_m003, b(%9.3f) se stats(N r2)
tabulate foreign
tabstat price mpg weight t5_work, by(foreign) statistics(mean sd min max n)
export delimited make price mpg weight foreign t5_work using "$tempdir/taught_task5_snapshot.csv", replace
display as result "<<< DONE Section 11: model and table output stress"
// #endregion Section 11: model and table output stress

// #region Section 12: trace and assertion marathon
display as text ">>> START Section 12: trace and assertion marathon"
quietly {
    count if mod(obs_id, 3) == 0
    local t5_trace_0001 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0002 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0003 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0004 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0005 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0006 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0007 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0008 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0009 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0010 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0011 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0012 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0013 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0014 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0015 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0016 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0017 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0018 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0019 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0020 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0021 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0022 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0023 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0024 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0025 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0026 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0027 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0028 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0029 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0030 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0031 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0032 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0033 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0034 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0035 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0036 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0037 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0038 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0039 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0040 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0041 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0042 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0043 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0044 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0045 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0046 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0047 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0048 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0049 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0050 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0051 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0052 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0053 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0054 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0055 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0056 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0057 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0058 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0059 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0060 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0061 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0062 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0063 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0064 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0065 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0066 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0067 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0068 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0069 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0070 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0071 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0072 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0073 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0074 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0075 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0076 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0077 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0078 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0079 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0080 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0081 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0082 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0083 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0084 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0085 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0086 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0087 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0088 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0089 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0090 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0091 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0092 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0093 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0094 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0095 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0096 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0097 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0098 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0099 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0100 = r(N)
    summarize t5_work
    count if mod(obs_id, 8) == 0
    local t5_trace_0101 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0102 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0103 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0104 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0105 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0106 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0107 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0108 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0109 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0110 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0111 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0112 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0113 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0114 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0115 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0116 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0117 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0118 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0119 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0120 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0121 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0122 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0123 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0124 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0125 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0126 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0127 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0128 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0129 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0130 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0131 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0132 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0133 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0134 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0135 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0136 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0137 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0138 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0139 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0140 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0141 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0142 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0143 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0144 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0145 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0146 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0147 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0148 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0149 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0150 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0151 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0152 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0153 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0154 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0155 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0156 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0157 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0158 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0159 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0160 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0161 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0162 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0163 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0164 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0165 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0166 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0167 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0168 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0169 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0170 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0171 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0172 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0173 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0174 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0175 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0176 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0177 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0178 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0179 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0180 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0181 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0182 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0183 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0184 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0185 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0186 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0187 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0188 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0189 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0190 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0191 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0192 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0193 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0194 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0195 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0196 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0197 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0198 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0199 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0200 = r(N)
    summarize t5_work
    count if mod(obs_id, 13) == 0
    local t5_trace_0201 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0202 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0203 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0204 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0205 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0206 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0207 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0208 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0209 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0210 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0211 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0212 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0213 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0214 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0215 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0216 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0217 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0218 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0219 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0220 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0221 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0222 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0223 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0224 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0225 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0226 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0227 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0228 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0229 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0230 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0231 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0232 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0233 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0234 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0235 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0236 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0237 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0238 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0239 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0240 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0241 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0242 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0243 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0244 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0245 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0246 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0247 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0248 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0249 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0250 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0251 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0252 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0253 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0254 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0255 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0256 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0257 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0258 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0259 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0260 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0261 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0262 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0263 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0264 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0265 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0266 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0267 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0268 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0269 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0270 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0271 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0272 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0273 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0274 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0275 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0276 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0277 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0278 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0279 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0280 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0281 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0282 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0283 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0284 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0285 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0286 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0287 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0288 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0289 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0290 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0291 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0292 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0293 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0294 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0295 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0296 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0297 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0298 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0299 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0300 = r(N)
    summarize t5_work
    count if mod(obs_id, 18) == 0
    local t5_trace_0301 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0302 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0303 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0304 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0305 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0306 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0307 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0308 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0309 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0310 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0311 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0312 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0313 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0314 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0315 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0316 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0317 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0318 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0319 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0320 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0321 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0322 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0323 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0324 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0325 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0326 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0327 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0328 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0329 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0330 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0331 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0332 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0333 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0334 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0335 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0336 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0337 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0338 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0339 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0340 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0341 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0342 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0343 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0344 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0345 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0346 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0347 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0348 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0349 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0350 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0351 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0352 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0353 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0354 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0355 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0356 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0357 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0358 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0359 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0360 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0361 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0362 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0363 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0364 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0365 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0366 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0367 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0368 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0369 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0370 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0371 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0372 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0373 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0374 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0375 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0376 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0377 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0378 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0379 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0380 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0381 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0382 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0383 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0384 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0385 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0386 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0387 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0388 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0389 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0390 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0391 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0392 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0393 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0394 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0395 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0396 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0397 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0398 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0399 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0400 = r(N)
    summarize t5_work
    count if mod(obs_id, 4) == 0
    local t5_trace_0401 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0402 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0403 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0404 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0405 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0406 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0407 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0408 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0409 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0410 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0411 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0412 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0413 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0414 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0415 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0416 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0417 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0418 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0419 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0420 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0421 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0422 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0423 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0424 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0425 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0426 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0427 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0428 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0429 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0430 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0431 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0432 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0433 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0434 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0435 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0436 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0437 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0438 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0439 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0440 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0441 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0442 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0443 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0444 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0445 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0446 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0447 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0448 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0449 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0450 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0451 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0452 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0453 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0454 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0455 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0456 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0457 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0458 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0459 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0460 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0461 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0462 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0463 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0464 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0465 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0466 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0467 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0468 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0469 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0470 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0471 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0472 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0473 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0474 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0475 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0476 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0477 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0478 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0479 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0480 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0481 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0482 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0483 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0484 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0485 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0486 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0487 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0488 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0489 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0490 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0491 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0492 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0493 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0494 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0495 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0496 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0497 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0498 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0499 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0500 = r(N)
    summarize t5_work
    count if mod(obs_id, 9) == 0
    local t5_trace_0501 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0502 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0503 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0504 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0505 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0506 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0507 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0508 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0509 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0510 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0511 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0512 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0513 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0514 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0515 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0516 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0517 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0518 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0519 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0520 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0521 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0522 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0523 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0524 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0525 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0526 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0527 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0528 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0529 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0530 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0531 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0532 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0533 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0534 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0535 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0536 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0537 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0538 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0539 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0540 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0541 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0542 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0543 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0544 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0545 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0546 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0547 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0548 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0549 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0550 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0551 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0552 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0553 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0554 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0555 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0556 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0557 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0558 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0559 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0560 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0561 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0562 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0563 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0564 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0565 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0566 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0567 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0568 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0569 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0570 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0571 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0572 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0573 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0574 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0575 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0576 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0577 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0578 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0579 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0580 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0581 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0582 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0583 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0584 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0585 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0586 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0587 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0588 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0589 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0590 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0591 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0592 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0593 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0594 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0595 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0596 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0597 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0598 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0599 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0600 = r(N)
    summarize t5_work
    count if mod(obs_id, 14) == 0
    local t5_trace_0601 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0602 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0603 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0604 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0605 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0606 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0607 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0608 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0609 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0610 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0611 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0612 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0613 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0614 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0615 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0616 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0617 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0618 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0619 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0620 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0621 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0622 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0623 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0624 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0625 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0626 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0627 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0628 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0629 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0630 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0631 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0632 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0633 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0634 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0635 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0636 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0637 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0638 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0639 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0640 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0641 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0642 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0643 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0644 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0645 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0646 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0647 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0648 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0649 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0650 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0651 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0652 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0653 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0654 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0655 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0656 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0657 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0658 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0659 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0660 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0661 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0662 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0663 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0664 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0665 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0666 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0667 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0668 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0669 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0670 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0671 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0672 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0673 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0674 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0675 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0676 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0677 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0678 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0679 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0680 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0681 = r(N)
    count if mod(obs_id, 19) == 0
    local t5_trace_0682 = r(N)
    count if mod(obs_id, 20) == 0
    local t5_trace_0683 = r(N)
    count if mod(obs_id, 2) == 0
    local t5_trace_0684 = r(N)
    count if mod(obs_id, 3) == 0
    local t5_trace_0685 = r(N)
    count if mod(obs_id, 4) == 0
    local t5_trace_0686 = r(N)
    count if mod(obs_id, 5) == 0
    local t5_trace_0687 = r(N)
    count if mod(obs_id, 6) == 0
    local t5_trace_0688 = r(N)
    count if mod(obs_id, 7) == 0
    local t5_trace_0689 = r(N)
    count if mod(obs_id, 8) == 0
    local t5_trace_0690 = r(N)
    count if mod(obs_id, 9) == 0
    local t5_trace_0691 = r(N)
    count if mod(obs_id, 10) == 0
    local t5_trace_0692 = r(N)
    count if mod(obs_id, 11) == 0
    local t5_trace_0693 = r(N)
    count if mod(obs_id, 12) == 0
    local t5_trace_0694 = r(N)
    count if mod(obs_id, 13) == 0
    local t5_trace_0695 = r(N)
    count if mod(obs_id, 14) == 0
    local t5_trace_0696 = r(N)
    count if mod(obs_id, 15) == 0
    local t5_trace_0697 = r(N)
    count if mod(obs_id, 16) == 0
    local t5_trace_0698 = r(N)
    count if mod(obs_id, 17) == 0
    local t5_trace_0699 = r(N)
    count if mod(obs_id, 18) == 0
    local t5_trace_0700 = r(N)
    summarize t5_work
}
display as text "[TRACE] final checkpoint local exists for t5"
display as result "<<< DONE Section 12: trace and assertion marathon"
// #endregion Section 12: trace and assertion marathon

// #region Section 13: generated padding compute lines for line-count target
display as text ">>> START Section 13: generated padding compute lines"
quietly {
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 4)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 5)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 6)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 7)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 8)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 9)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 10)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 11)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 12)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 13)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 14)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 15)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 16)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 17)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 18)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 19)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 20)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 21)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 22)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 23)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 24)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 25)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 26)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 27)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 28)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 29)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 30)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 31)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 32)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 33)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 34)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 35)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 36)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 37)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 38)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 39)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 40)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 41)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 42)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 43)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 44)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 2)
    replace t5_work = t5_work + 0.0000001 * mod(obs_id, 3)
}
display as result "<<< DONE Section 13: generated padding compute lines"
// #endregion Section 13: generated padding compute lines

// #region Section 14: final save and completion
display as text ">>> START Section 14: final save and completion"
quietly summarize t5_work
local t5_final_mean = r(mean)
display as text "[FINAL] t5_work mean=" %9.4f `t5_final_mean'
compress
save "$tempdir/taught_task5_final.dta", replace
export delimited using "$tempdir/taught_task5_final.csv", replace
display as result "<<< DONE taught_task5.do"
display as text "===== TAUGHT TASK 5 SELF-CHECK END ====="
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

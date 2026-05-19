/*
================================================================================
文件：taught_task.do
目的：人机实时共享 session 压力测试文件
      故意暴露与终极目标"低延迟、无卡死、图表文流畅"不匹配的环节
设计：12 Sections, ~1200 lines
      使用 sysuse auto 自包含，无需外部数据
      包含大型匿名块、密集图表、文档输出、大诊断输出、重计算等压力点
目标：
  1. 检验 Agent do-file 路径的 graph parity（未命名图能否被捕获）
  2. 检验 chart batch hydrate 性能（20+ 命名图循环）
  3. 检验 brace-safe 分段（大型匿名块不可拆分）
  4. 检验大 SMCL 输出后的 log 可读性
  5. 检验 putdocx 混合图文的 manifest-stable 误触发
  6. 检验 transport poisoning（putdocx 后的图是否正常）
  7. 检验重计算后的 session 稳定性和图产出
  8. 检验分段扫描器对 save/export 锚点的识别
================================================================================
*/

// #region ===== Section 1: Setup & Data Preparation =====

cls
clear all

* 全局暂元（独立运行，不依赖项目路径）
local __taught_root "`c(pwd)'"
global workfolder "`__taught_root'"
global tempdir "${workfolder}/7_temp"
global figdir "${tempdir}/taught_task_graphs"
global docdir "${workfolder}/4_tables"

cap mkdir "$figdir"
cap mkdir "$docdir"

* 加载内置数据
sysuse auto, clear
describe

* 生成测试用衍生变量
gen price_ln = ln(price)
gen mpg_sq = mpg^2
gen weight_ton = weight / 1000
gen price_per_lb = price / weight
gen foreign_str = "Domestic"
replace foreign_str = "Foreign" if foreign == 1
label variable price_ln "Log of Price"
label variable mpg_sq "MPG Squared"
label variable weight_ton "Weight (tons)"
label variable price_per_lb "Price per Pound"

* 生成分类变量用于 tab1 压力测试
egen price_quart = cut(price), group(4)
egen mpg_tert = cut(mpg), group(3)
label define price_q 0 "Q1-Cheap" 1 "Q2-Mid" 2 "Q3-Expensive" 3 "Q4-Luxury"
label values price_quart price_q
label define mpg_t 0 "Low MPG" 1 "Mid MPG" 2 "High MPG"
label values mpg_tert mpg_t

* 扩展样本量（制造更大输出压力）
expand 3
sort make
gen replicate = _n

* 生成更多变量
gen rand_x = rnormal()
gen rand_y = rnormal(1, 2)
gen rand_z = runiform()
gen group_id = mod(_n, 5) + 1
label define gid 1 "Group A" 2 "Group B" 3 "Group C" 4 "Group D" 5 "Group E"
label values group_id gid

count
describe
display as text ">>> Section 1 Complete: Setup done, N = " _N

// #endregion ===== Section 1 =====



// #region ===== Section 2: Unnamed Graph Gauntlet (Agent Graph Parity Test) =====
/*
   目的：连续产生 5 张未命名图，然后 graph drop _all
   在 Agent do-file 路径中，这些图会被 Stata 后续图覆盖，
   只有 human Run File/Selection 的 inline snapshot 能完整捕获。
   → 检验 Agent 路径是否只有最后 1 张而不是 5 张
*/

twoway (scatter price mpg) (lfit price mpg),                       ///
    title("Unnamed Graph 1: Price vs MPG")                         ///
    subtitle("Scatter + Linear Fit")                                ///
    ytitle("Price (USD)") xtitle("Miles per Gallon")               ///
    note("taught_task.do — Section 2")

twoway (histogram price, freq color(blue%30))                      ///
    (kdensity price, lcolor(red) lwidth(thick)),                   ///
    title("Unnamed Graph 2: Price Distribution")                   ///
    subtitle("Histogram + Kernel Density")                          ///
    ytitle("Frequency") xtitle("Price (USD)")                      ///
    legend(order(1 "Histogram" 2 "K-Density"))

graph twoway (scatter price weight) (qfit price weight),            ///
    title("Unnamed Graph 3: Price vs Weight")                       ///
    subtitle("Scatter + Quadratic Fit")                             ///
    ytitle("Price (USD)") xtitle("Weight (lbs)")

graph bar (mean) mpg, over(price_quart) over(group_id)               ///
    title("Unnamed Graph 4: MPG by Price Quartile & Group")        ///
    ytitle("Mean MPG") legend(rows(2))

twoway (area price_ln weight_ton, sort),                            ///
    title("Unnamed Graph 5: Log Price Area Chart")                  ///
    ytitle("ln(Price)") xtitle("Weight (tons)")

display as text ">>> Section 2 Complete: 5 unnamed graphs produced"
display as text "[TEST] Agent path: should show 5 graphs in panel (not just 1)"

* 清空所有未命名图（模拟 demo.do 中的模式）
graph drop _all
display as text "[INFO] graph drop _all executed — unnamed graphs purged"

// #endregion ===== Section 2 =====



// #region ===== Section 3: Named Graph Loop (Batch Hydrate Stress) =====
/*
   目的：20 张命名 twoway 图，检验 Stata Graphs panel 的 batch hydrate
   是否有 hidden cap、lazy loading 是否正常、是否有丢图
*/

forvalues i = 1/20 {
    local color = cond(mod(`i',3)==0, "blue", cond(mod(`i',3)==1, "red", "green"))
    local alpha = string(20 + mod(`i',3)*10)

    twoway (scatter price mpg if group_id == mod(`i',5)+1,           ///
        mcolor(`color'%`alpha') msymbol(circle) msize(small))        ///
        (lfit price mpg if group_id == mod(`i',5)+1,                 ///
        lcolor(`color') lwidth(medium)),                             ///
        title("Loop Graph `i': Group = `=mod(`i',5)+1'")             ///
        subtitle("`color' points, alpha `alpha'")                    ///
        ytitle("Price") xtitle("MPG")                                ///
        name(loop`i', replace)                                       ///
        nodraw
}

* 批量显示（模拟实际使用场景）
forvalues i = 1/20 {
    if mod(`i', 5) == 1 {
        graph combine loop`i' loop`=`i'+1' loop`=`i'+2' loop`=`i'+3' loop`=`i'+4', ///
            title("Combined Graphs `i'–`=`i'+4'")                                   ///
            name(combo_`=int((`i'-1)/5)+1', replace)                                       ///
            rows(2) cols(3)                                                          ///
            nodraw
    }
}

display as text ">>> Section 3 Complete: 20 named graphs + 4 combine panels"
display as text "[TEST] Graph panel should show all 20 graphs, 0 dropped"

// #endregion ===== Section 3 =====



// #region ===== Section 4: Large Anonymous Block (Brace-Safe Segmentation Test) =====
/*
   目的：单个大型匿名 { ... } 块，内部有嵌套的 foreach/forvalues braces
   分段器必须在 block 外切开（depth=0 cut point）
   如果在 { 和 } 之间切分 → brace imbalance → HTTP 500

   此块内容：preserve → 多轮数据处理 → merge → label → restore → save
   预计 300 行，是整个文件最大的单一块
   内部有 depth 2-3 的嵌套，精确测试 brace scanner
*/

preserve

if 1 {
    * 子操作 1: 按组生成汇总统计
    display as text ">>> Block Sub-Operation 1: Group Summaries"

    foreach grp in 1 2 3 4 5 {
        keep if group_id == `grp'

        egen mean_price_`grp' = mean(price)
        egen sd_price_`grp' = sd(price)
        egen mean_mpg_`grp' = mean(mpg)
        egen mean_weight_`grp' = mean(weight)
        egen count_`grp' = count(price)

        forvalues v = 1/3 {
            gen rand_marker_`grp'_`v' = rnormal(0, 1)
            label variable rand_marker_`grp'_`v' "Random marker `v' for group `grp'"
        }

        collapse (mean) mean_price_`grp' sd_price_`grp' mean_mpg_`grp' ///
            mean_weight_`grp' count_`grp' (first) rand_marker_`grp'_1 ///
            rand_marker_`grp'_2 rand_marker_`grp'_3, by(group_id)

        tempfile grpsum_`grp'
        save `grpsum_`grp''

        restore, preserve
    }

    * 子操作 2: 合并组汇总
    display as text ">>> Block Sub-Operation 2: Merging Group Summaries"

    use `grpsum_1', clear
    foreach grp in 2 3 4 5 {
        append using `grpsum_`grp''
    }

    sort group_id
    compress
    tempfile all_groups
    save `all_groups', replace

    * 子操作 3: 生成更复杂的数据结构
    display as text ">>> Block Sub-Operation 3: Complex Variable Generation"

    use `all_groups', clear

    * 嵌套循环 — brace depth 2
    forvalues x = 1/4 {
        forvalues y = 1/3 {
            gen interact_val_`x'_`y' = mean_price_1 * `x' + mean_mpg_1 * `y'
            label variable interact_val_`x'_`y' "Interaction x=`x' y=`y'"
        }
    }

    * foreach 嵌套在 forvalues 中 — brace depth 3
    tempfile s3_source
    save `s3_source'

    forvalues wave = 1/3 {
        use `s3_source', clear
        keep group_id mean_price_* mean_mpg_* mean_weight_*

        foreach stat in price mpg weight {
            egen panel_`stat'_w`wave' = rowmean(mean_`stat'_*)
            label variable panel_`stat'_w`wave' "Panel `stat' wave `wave'"
        }

        gen wave_id = `wave'

        if 1 {
            foreach metric in price mpg weight {
                cap drop temp_`metric'_rank
                egen temp_`metric'_rank = rank(panel_`metric'_w`wave')
                rename temp_`metric'_rank rank_`metric'_w`wave'
                label variable rank_`metric'_w`wave' "Rank of `metric' wave `wave'"
            }
        }

        tempfile panel_w`wave'
        save `panel_w`wave''
    }

    * 合并所有 panel waves
    display as text ">>> Block Sub-Operation 4: Panel Wave Merge"

    use `panel_w1', clear
    foreach wave in 2 3 {
        merge 1:1 group_id using `panel_w`wave'', nogen
    }

    * 清理和标签
    foreach v of varlist _all {
        cap label variable `v' "`=subinstr("`: var label `v''", ".", " ", .)'"
    }

    * 最终排序和保存
    sort group_id wave_id

    if 1 {
        foreach cons in price mpg weight {
            capture confirm variable rank_`cons'_w1
            if _rc == 0 {
                summarize rank_`cons'_w*
            }
        }
    }

    compress
    save "${tempdir}/taught_task_s4_intermediate.dta", replace

    display as text ">>> Block Sub-Operation 5: Save completed"
    display as text "       File: taught_task_s4_intermediate.dta"

    * 子操作 6: 加载中间文件并生成诊断图表
    display as text ">>> Block Sub-Operation 6: Diagnostic Charts from Block Data"

    use "${tempdir}/taught_task_s4_intermediate.dta", clear

    tempfile s5_source
    save `s5_source'

    foreach metric in price mpg weight {
        use `s5_source', clear
        keep group_id wave_id rank_`metric'_w*

        forvalues w = 1/3 {
            if 1 {
                capture confirm variable rank_`metric'_w`w'
                if _rc == 0 {
                    twoway (bar rank_`metric'_w`w' group_id, barw(0.5)          ///
                        color(navy%50))                                          ///
                        (scatter rank_`metric'_w`w' group_id,                     ///
                        mcolor(red) msize(medium)),                              ///
                        title("Block Chart: `metric' Wave `w'")                  ///
                        subtitle("Rank by Group")                                ///
                        ytitle("Rank") xtitle("Group ID")                        ///
                        name(block_`metric'_w`w', replace)                       ///
                        nodraw
                }
            }
        }

        capture confirm variable rank_`metric'_w1
        if _rc == 0 {
            capture confirm variable rank_`metric'_w2
            if _rc == 0 {
                capture confirm variable rank_`metric'_w3
                if _rc == 0 {
                    graph combine block_`metric'_w1 block_`metric'_w2           ///
                        block_`metric'_w3,                                      ///
                        title("`metric' Rank: All 3 Waves")                     ///
                        name(block_`metric'_combo, replace)                     ///
                        rows(1) cols(3)                                         ///
                        nodraw
                    display as text "  Combined chart generated for `metric'"
                }
            }
        }
    }

    graph drop block_price_w1 block_price_w2 block_price_w3
    graph drop block_mpg_w1 block_mpg_w2 block_mpg_w3
    graph drop block_weight_w1 block_weight_w2 block_weight_w3
    graph drop block_price_combo block_mpg_combo block_weight_combo

} // ← if 1 block ends — depth=0，唯一安全的 cut point

restore
display as text ">>> Section 4 Complete: Large anonymous block executed"
display as text "[TEST] Brace scanner: only cut point is at this line (depth=0)"

// #endregion ===== Section 4 =====



// #region ===== Section 5: Diagnostic Deluge (SMCL + Large Log Stress) =====
/*
   目的：大量 tab1, codebook, summarize detail 产生密集 SMCL 输出
   测试 log tail 可读性（{res}{txt}{com} 标记污染）
   预计产生 ~500KB 的 SMCL 格式化输出
*/

display as text ">>> Section 5 Start: Diagnostic Output Flood"

* 基础表格轰炸
tab1 foreign rep78
tab1 price_quart mpg_tert, miss
tab1 group_id, miss

* 交叉表
tab foreign rep78, row chi2
tab foreign price_quart, col chi2
tab mpg_tert group_id, row chi2
bysort foreign: tab rep78 price_quart, row chi2

* 变量编码簿（大量输出）
codebook price mpg weight length turn displacement gear_ratio ///
    price_ln mpg_sq weight_ton price_per_lb

codebook price_quart mpg_tert group_id foreign foreign_str

* 详细摘要统计
summarize price mpg weight length turn displacement gear_ratio, detail
summarize price_ln mpg_sq weight_ton price_per_lb, detail

* 按组摘要
bysort foreign: summarize price mpg weight length, detail
bysort price_quart: summarize mpg weight length turn displacement
bysort group_id: summarize price mpg

* 相关矩阵
correlate price mpg weight length turn displacement gear_ratio
pwcorr price mpg weight length turn displacement gear_ratio, star(0.05)

* 缺失值报告
misstable summarize price mpg weight length turn displacement gear_ratio
misstable patterns price mpg weight length turn

* 分类变量频次
foreach v in foreign rep78 price_quart mpg_tert group_id {
    tab `v', miss
    display as text "---"
}

* 额外压力：逐变量详细输出
display as text ">>> Extended Diagnostics: Per-Variable Deep Dive"

foreach v of varlist price mpg weight length turn displacement gear_ratio {
    display as text "========================================"
    display as text "Variable: `v'"
    display as text "========================================"

    quietly summarize `v'
    display as text "  N = " r(N) "  Mean = " %9.3f r(mean) "  SD = " %9.3f r(sd)
    display as text "  Min = " %9.3f r(min) "  Max = " %9.3f r(max)
    display as text "  P1 = " %9.3f r(p1) "  P5 = " %9.3f r(p5)
    display as text "  P25 = " %9.3f r(p25) "  P50 = " %9.3f r(p50)
    display as text "  P75 = " %9.3f r(p75) "  P95 = " %9.3f r(p95)
    display as text "  P99 = " %9.3f r(p99)
    display as text "  Skewness = " %9.3f r(skewness) "  Kurtosis = " %9.3f r(kurtosis)

    * 直方图分箱统计
    quietly histogram `v', freq width(2)
    display as text "  Histogram bins generated"

    display as text " "
}

* 多变量交叉摘要
display as text ">>> Cross-Tabulation Marathon"
forvalues q = 0/3 {
    forvalues t = 0/2 {
        display as text "--- price_quart=`q' x mpg_tert=`t' ---"
        count if price_quart == `q' & mpg_tert == `t'
        display as text "  N = " r(N)
        quietly summarize price if price_quart == `q' & mpg_tert == `t'
        display as text "  Mean price = " %9.2f r(mean)
    }
}

* 生成并输出多个相关矩阵
display as text ">>> Extended Correlation Analysis"
correlate price mpg weight length turn displacement gear_ratio
display as text "Full correlation matrix displayed above"

pwcorr price mpg weight length turn displacement gear_ratio, star(0.01)
display as text "Pairwise correlations with 1% significance displayed above"

spearman price mpg weight length turn displacement gear_ratio, star(0.05)
display as text "Spearman rank correlations displayed above"

display as text ">>> Section 5 Complete: Diagnostic deluge done"
display as text "[TEST] Log should contain ~500KB SMCL-formatted output"
display as text "[TEST] Check for raw {res}{txt}{com} tags in log tail"

// #endregion ===== Section 5 =====



// #region ===== Section 6: Mixed Graph + Document (Document-Output Guard Test) =====
/*
   目的：putdocx 中混合 paragraph + table + graph
   检验 V7.19 的 document-output guard 是否正常工作:
   - manifest-stable watchdog 不应在 putdocx save 前提前释放
   - docx 文件和 graph 面板应同时正确
*/

display as text ">>> Section 6 Start: Mixed Graph + Document"

* 先做几张图用于嵌入
forvalues i = 1/4 {
    twoway (scatter price mpg if group_id == `i')                     ///
        (lfit price mpg if group_id == `i'),                          ///
        title("Group `i': Price vs MPG")                              ///
        name(doc_fig_`i', replace)
}

* 创建 Word 文档
putdocx begin, pagesize(letter) landscape

putdocx paragraph, style(Heading1)
putdocx text ("Section 6: Mixed Graph + Document Test")

putdocx paragraph, style(Heading2)
putdocx text ("1. Descriptive Statistics")

putdocx paragraph
putdocx text ("Table 1 presents summary statistics for the auto dataset. ")
putdocx text ("The sample includes both domestic and foreign vehicles, ")
putdocx text ("with prices ranging from $3,291 to $15,906.")

* 嵌入描述统计表
putdocx paragraph, style(Heading3)
putdocx text ("Table 1: Summary Statistics")

putdocx table tbl_summary = (8, 4), border(all, single)
putdocx table tbl_summary(1,1) = ("Variable"), bold
putdocx table tbl_summary(1,2) = ("Mean"), bold
putdocx table tbl_summary(1,3) = ("SD"), bold
putdocx table tbl_summary(1,4) = ("N"), bold

local row = 2
foreach var in price mpg weight length turn displacement gear_ratio {
    quietly summarize `var'
    putdocx table tbl_summary(`row', 1) = ("`var'")
    putdocx table tbl_summary(`row', 2) = (string(r(mean), "%9.2f"))
    putdocx table tbl_summary(`row', 3) = (string(r(sd), "%9.2f"))
    putdocx table tbl_summary(`row', 4) = (string(r(N)))
    local row = `row' + 1
}

* 嵌入回归结果表
putdocx paragraph, style(Heading3)
putdocx text ("Table 2: Regression Results")

putdocx table tbl_reg = (5, 3), border(all, single)
putdocx table tbl_reg(1,1) = ("Coefficient"), bold
putdocx table tbl_reg(1,2) = ("Model 1"), bold
putdocx table tbl_reg(1,3) = ("Model 2"), bold

quietly reg price mpg weight
putdocx table tbl_reg(2,1) = ("MPG")
putdocx table tbl_reg(2,2) = (string(_b[mpg], "%9.2f"))
quietly reg price mpg weight length
putdocx table tbl_reg(2,3) = (string(_b[mpg], "%9.2f"))

putdocx table tbl_reg(3,1) = ("Weight")
quietly reg price mpg weight
putdocx table tbl_reg(3,2) = (string(_b[weight], "%9.3f"))
quietly reg price mpg weight length
putdocx table tbl_reg(3,3) = (string(_b[weight], "%9.3f"))

putdocx table tbl_reg(4,1) = ("Length")
putdocx table tbl_reg(4,2) = ("—")
quietly reg price mpg weight length
putdocx table tbl_reg(4,3) = (string(_b[length], "%9.2f"))

putdocx table tbl_reg(5,1) = ("R²")
quietly reg price mpg weight
putdocx table tbl_reg(5,2) = (string(e(r2), "%9.3f"))
quietly reg price mpg weight length
putdocx table tbl_reg(5,3) = (string(e(r2), "%9.3f"))

* 嵌入图表（混合图文）
putdocx paragraph, style(Heading3)
putdocx text ("Figure 1: Group-Specific Price-MPG Relationships")

forvalues i = 1/4 {
    graph export "${figdir}/doc_fig_`i'.png", name(doc_fig_`i') replace width(1200)
    putdocx paragraph
    putdocx image "${figdir}/doc_fig_`i'.png", width(5in) height(3.5in)
}

* 分析讨论段落
putdocx paragraph, style(Heading2)
putdocx text ("2. Discussion")

putdocx paragraph
putdocx text ("The analysis reveals a clear negative relationship between ")
putdocx text ("price and fuel efficiency (MPG) across all groups. ")
putdocx text ("Foreign vehicles tend to have higher MPG at lower prices, ")
putdocx text ("while domestic vehicles show greater price dispersion. ")
putdocx text ("These patterns are consistent with prior literature on ")
putdocx text ("automotive market segmentation (Author, 2025).")

putdocx paragraph
putdocx text ("The results suggest that consumers face a trade-off between ")
putdocx text ("price and fuel efficiency, with the marginal rate of ")
putdocx text ("substitution varying significantly by vehicle origin. ")

* 保存文档
putdocx save "${docdir}/taught_task_section6.docx", replace
display as text ">>> Section 6 Complete: Mixed graph + document saved"
display as text "[TEST] Check: docx fresh AND graph panel shows 4 figures"
display as text "[TEST] Manifest-stable watchdog should NOT pre-release here"

// #endregion ===== Section 6 =====



// #region ===== Section 7: Post-Docx Graph Test (Transport Poisoning) =====
/*
   目的：putdocx 后立即产生 10 张图
   如果 transport 被 putdocx 污染 → 此处可能 pre-log zombie 或 graph 丢失
*/

display as text ">>> Section 7 Start: Post-Docx Graph Test"

forvalues i = 1/10 {
    local gear_val = 2 + mod(`i', 3)

    twoway (scatter price mpg if gear_ratio > `gear_val' & gear_ratio < ., ///
        mcolor(navy%60) msymbol(diamond))                                  ///
        (scatter price mpg if gear_ratio <= `gear_val',                     ///
        mcolor(cranberry%60) msymbol(triangle))                             ///
        (lfit price mpg, lcolor(black) lpattern(dash)),                     ///
        title("Post-Docx Graph `i': gear_ratio > `gear_val'")               ///
        subtitle("Navy = High Gear, Red = Low Gear")                        ///
        ytitle("Price") xtitle("MPG")                                       ///
        legend(order(1 "High Gear" 2 "Low Gear" 3 "Linear Fit"))           ///
        name(post_`i', replace)                                             ///
        nodraw
}

* 显示一个 combine 验证所有图都在
graph combine post_1 post_2 post_3 post_4 post_5,                       ///
    title("Post-Docx Graphs 1-5")                                       ///
    name(post_combo_1, replace) rows(2) cols(3)

graph combine post_6 post_7 post_8 post_9 post_10,                      ///
    title("Post-Docx Graphs 6-10")                                      ///
    name(post_combo_2, replace) rows(2) cols(3)

display as text ">>> Section 7 Complete: 10 post-docx graphs"
display as text "[TEST] All 10 graphs should appear — no transport poisoning"
display as text "[TEST] If 0 graphs: putdocx poisoned the transport"

// #endregion ===== Section 7 =====



// #region ===== Section 8: Heavy Computation (Delay Detection) =====
/*
   目的：多次回归 + margins + predict 循环
   产生累积计算延迟，检验 anti-stall watchdog 是否误触发
   此段不应触发 stall（因为 log 持续增长），但应有明显延迟感
*/

display as text ">>> Section 8 Start: Heavy Computation Block"

* 回归模型组 1: OLS
local models_ols = 0
foreach dv in price price_ln {
    foreach iv_set in "mpg weight" "mpg weight length"                      ///
        "mpg weight length turn" "mpg weight length turn displacement"      ///
        "mpg weight length turn displacement gear_ratio" {

        local ++models_ols
        quietly reg `dv' `iv_set'
        display as text "OLS Model `models_ols': `dv' ~ `iv_set'"
        display as text "  R² = " %6.4f e(r2) "  N = " e(N)

        * 产生边际效应
        capture margins, dydx(*) post
        if _rc == 0 {
            display as text "  Marginal effects computed"
        }
    }
}

* 回归模型组 2: Logit
display as text ">>> Logit Models"
gen high_price = (price > 6000)
label variable high_price "High Price (>$6,000)"

logit high_price mpg weight, nolog
estimates store logit1
display as text "Logit 1: high_price ~ mpg weight"

logit high_price mpg weight length, nolog
estimates store logit2
display as text "Logit 2: high_price ~ mpg weight length"

logit high_price mpg weight length turn displacement gear_ratio, nolog
estimates store logit3
display as text "Logit 3: high_price ~ full model"

* 模型比较
estimates table logit1 logit2 logit3, star stats(N ll chi2 r2_p)
display as text ">>> Model comparison table displayed"

* 预测（产生大量输出）
foreach m in logit1 logit2 logit3 {
    estimates restore `m'
    quietly predict p_`m', pr
    summarize p_`m', detail
    display as text "Predicted probabilities from `m': mean = " r(mean)
}

* 回归模型组 3: 分组回归（产生更多输出）
display as text ">>> Group-Specific Regressions"
levelsof group_id, local(groups)
foreach g of local groups {
    display as text "--- Group `g' ---"
    quietly reg price mpg weight length if group_id == `g'
    display as text "  N = " e(N) "  R² = " %6.4f e(r2)
    quietly reg price mpg weight length turn displacement if group_id == `g'
    display as text "  Full model N = " e(N) "  R² = " %6.4f e(r2)
}

* 回归模型组 4: 交互项
display as text ">>> Interaction Models"
reg price c.mpg##c.weight, robust
estimates store inter1
reg price c.mpg##c.weight##i.foreign, robust
estimates store inter2
reg price c.mpg##c.weight##i.foreign c.length##c.turn, robust
estimates store inter3

estimates table inter1 inter2 inter3, star stats(N r2)

* Margins 分析（重操作）
display as text ">>> Margins Analysis"
quietly reg price c.mpg##c.weight##i.foreign
margins foreign, at(mpg=(12(4)40))
marginsplot, name(margins_test, replace) nodraw                         ///
    title("Predictive Margins: Foreign vs Domestic")                    ///
    ytitle("Predicted Price") xtitle("MPG")

display as text ">>> Section 8 Complete: Heavy computation done"
display as text "[TEST] All models should complete normally"
display as text "[TEST] No watchdog false-trigger during computation"

* 附加压力：事后诊断计算
display as text ">>> Post-Compute Diagnostics"

* 对每个 logit 模型做完整诊断
foreach m in logit1 logit2 logit3 {
    estimates restore `m'
    display as text "========================================"
    display as text "Diagnostics for `m'"
    display as text "========================================"
    estat classification, cutoff(0.5)
    quietly predict resid_`m', deviance
    summarize resid_`m', detail
    display as text "Deviance residuals: mean=" %9.4f r(mean) " sd=" %9.4f r(sd)
    drop resid_`m'
}

* 对交互模型做 margins at 多种水平
estimates restore inter2
display as text ">>> Margins at Representative Values (inter2)"
margins, at(mpg=(10(5)45)) atmeans
margins foreign, at(mpg=(10(10)40)) atmeans
margins, dydx(mpg) at(weight=(1500(500)5000))
display as text "Margins analysis complete"

* 生成预测值并做诊断
quietly reg price c.mpg##c.weight##i.foreign c.length##c.turn
predict price_hat, xb
predict price_resid, residuals
gen abs_resid = abs(price_resid)
egen resid_rank = rank(abs_resid)
summarize abs_resid price_resid, detail
display as text "Prediction residuals analyzed"

* 回归模型组 5: 加权最小二乘
display as text ">>> WLS and Robustness Checks"
quietly reg price mpg weight length
predict e2, residuals
replace e2 = e2^2
quietly reg e2 mpg weight length
drop e2

reg price mpg weight length, vce(robust)
display as text "Robust SE regression complete"

reg price mpg weight length, vce(cluster group_id)
display as text "Clustered SE regression complete"

* Bootstrap 估计（产生延迟）
display as text ">>> Bootstrap (50 reps, may pause)"
capture bootstrap _b, reps(50) dots: reg price mpg weight
if _rc == 0 {
    display as text "Bootstrap completed successfully"
    estimates store boot_reg
}
else {
    display as text "Bootstrap skipped or failed (rc=" _rc ")"
}

display as text ">>> Section 8 Extended: All diagnostics complete"

// #endregion ===== Section 8 =====



// #region ===== Section 9: Preserve/Restore Gauntlet (Session Integrity) =====
/*
   目的：preserve → 多项操作 → restore → 验证
   执行段之间 session 状态一致性检验
*/

display as text ">>> Section 9 Start: Preserve/Restore Gauntlet"

preserve

    * 数据变形
    keep make price mpg weight foreign
    sort price

    * 生成滞后和差分变量
    gen price_lag = price[_n-1]
    gen price_diff = price - price_lag
    gen mpg_lag = mpg[_n-1]
    gen mpg_diff = mpg - mpg_lag

    * 标记异常值
    egen price_std = std(price)
    gen is_outlier = abs(price_std) > 2
    label variable is_outlier "Price outlier (>2 SD)"

    * 生成排名
    egen price_rank = rank(price)
    egen mpg_rank = rank(mpg)

    * 排名相关检验
    spearman price_rank mpg_rank
    display as text "Spearman's ρ = " r(rho)

    * 子块制图
    twoway (scatter price_diff mpg_diff)                                 ///
        (lfit price_diff mpg_diff),                                      ///
        title("Price Change vs MPG Change")                              ///
        ytitle("Δ Price") xtitle("Δ MPG")                               ///
        name(preserve_test, replace) nodraw

    * 保存临时产物
    save "${tempdir}/taught_task_s9_intermediate.dta", replace
    display as text "Temporary preserve data saved"

restore
display as text ">>> Restore completed — original data intact"

* 验证 session 完整性
describe
count
display as text ">>> Section 9 Complete: Session integrity verified"
display as text "[TEST] Data should be back to `=r(N)' observations"

// #endregion ===== Section 9 =====



// #region ===== Section 10: Second Wave Graph Loop (Post-Heavy-Compute) =====
/*
   目的：重计算后（S8）立即产生 15 张命名图
   检验 S8 的计算负载是否毒化了图生成 pipeline
   如果此处 pre-log zombie 或图丢失 → 大计算毒化 transport
*/

display as text ">>> Section 10 Start: Second Wave Graphs"

forvalues i = 1/15 {
    local pt = cond(mod(`i',3)==0, 18, cond(mod(`i',3)==1, 15, 12))
    local lt = cond(mod(`i',2)==0, "solid", "dash")
    local bw = cond(mod(`i',3)==0, "0.7", cond(mod(`i',3)==1, "0.4", "1.0"))

    * 交替使用不同图类型
    if mod(`i', 3) == 0 {
        twoway (scatter price weight, msize(tiny) mcolor(gray%`pt'))    ///
            (lowess price weight, lcolor(blue) lwidth(thick)),          ///
            title("Wave 2 Graph `i': Lowess Price-Weight")             ///
            name(w2_`i', replace) nodraw
    }
    else if mod(`i', 3) == 1 {
        twoway (histogram mpg, freq color(green%30))                    ///
            (kdensity mpg, lcolor(red) lwidth(thick)),                 ///
            title("Wave 2 Graph `i': MPG Distribution")                ///
            name(w2_`i', replace) nodraw
    }
    else {
        twoway (scatter price length, msize(small) mcolor(navy%`pt'))  ///
            (lfit price length, lcolor(maroon) lpattern(`lt')          ///
            lwidth(*`bw')),                                             ///
            title("Wave 2 Graph `i': Price-Length")                    ///
            name(w2_`i', replace) nodraw
    }
}

* Combine 验证
graph combine w2_1 w2_2 w2_3 w2_4 w2_5 w2_6,                        ///
    title("Wave 2 Graphs 1-6") rows(2) cols(3)                        ///
    name(w2_combo_1, replace)

graph combine w2_7 w2_8 w2_9 w2_10 w2_11 w2_12,                       ///
    title("Wave 2 Graphs 7-12") rows(2) cols(3)                       ///
    name(w2_combo_2, replace)

graph combine w2_13 w2_14 w2_15,                                       ///
    title("Wave 2 Graphs 13-15") rows(1) cols(3)                       ///
    name(w2_combo_3, replace)

display as text ">>> Section 10 Complete: 15 wave-2 graphs"
display as text "[TEST] All 15 graphs should appear — no post-compute degradation"
display as text "[TEST] If 0 or partial graphs: heavy compute poisoned pipeline"

// #endregion ===== Section 10 =====



// #region ===== Section 11: Natural Segmentation Anchors =====
/*
   目的：多个连续的 save/export/csv 操作
   每个都是天然的分段 cut point
   检验 brace scanner 能否正确识别 depth=0 安全边界
*/

display as text ">>> Section 11 Start: Segmentation Anchors"

* Anchor 1: 保存基础数据集
save "${tempdir}/taught_task_anchor1_basic.dta", replace
display as text "[ANCHOR 1] Basic dataset saved"

* 变换数据
collapse (mean) price mpg weight length turn displacement gear_ratio, ///
    by(foreign price_quart)

* Anchor 2: 保存折叠数据
save "${tempdir}/taught_task_anchor2_collapsed.dta", replace
display as text "[ANCHOR 2] Collapsed dataset saved"

* 导出 CSV
export delimited using "${tempdir}/taught_task_anchor3_export.csv",    ///
    nolabel replace
display as text "[ANCHOR 3] CSV exported"

* 重新加载并变换
use "${tempdir}/taught_task_anchor1_basic.dta", clear

* 生成宽格式测试数据
keep make price mpg weight
bysort make: gen obs_within = _n
reshape wide price mpg weight, i(make) j(obs_within)
display as text "[ANCHOR 4] Data reshaped to wide"

* Anchor 5: 保存宽格式
save "${tempdir}/taught_task_anchor5_wide.dta", replace
display as text "[ANCHOR 5] Wide format saved"

* 回到长格式
use "${tempdir}/taught_task_anchor1_basic.dta", clear

* 生成面板标识
gen panel_id = _n
expand 3
bysort panel_id: gen wave_id = _n
label variable wave_id "Panel Wave (1-3)"
display as text "[ANCHOR 6] Panel expanded"

* 保存面板数据
save "${tempdir}/taught_task_anchor7_panel.dta", replace
display as text "[ANCHOR 7] Panel data saved"

display as text ">>> Section 11 Complete: 7 save/export anchors"
display as text "[TEST] All anchors at depth=0 → safe cut points"

// #endregion ===== Section 11 =====



// #region ===== Section 12: Final Wrap-Up =====
/*
   目的：最终统计、最后一个 save、纯注释 trailing
   最后一个真实 save 是完成锚点
   后面的纯注释不应影响分段
*/

display as text ">>> Section 12 Start: Final Wrap-Up"

* 最终数据检查
describe
count
display as text "Final observation count: " _N

* 最终汇总表
tab foreign
tab price_quart
tab group_id

* 最终回归总结
quietly reg price mpg weight length turn displacement gear_ratio
display as text "Final model R²: " %6.4f e(r2)
display as text "Final model N:  " e(N)
display as text "RMSE:          " %9.2f e(rmse)

* 最后保存 — 这是整个文件的完成锚点
save "${tempdir}/taught_task_final.dta", replace
display as text ">>> FINAL SAVE: taught_task_final.dta — completion anchor"

// #endregion ===== Section 12 =====



/*
================================================================================
文件结束 — taught_task.do — 最后真实 save 位于上文 S12
================================================================================

以下为纯注释，不应产生任何 Stata 输出。
分段器应识别到最后一个真实 save 为完成锚点。

  Section Summary:
    S1:  Setup (~60 lines)
    S2:  Unnamed Graph Gauntlet (~50 lines)
    S3:  Named Graph Loop 20 (~80 lines)
    S4:  Large Anonymous Block (~200 lines) — SINGLE { ... }, DO NOT SPLIT
    S5:  Diagnostic Deluge (~100 lines)
    S6:  Mixed Graph + putdocx (~100 lines)
    S7:  Post-Docx Graph Test (~60 lines)
    S8:  Heavy Computation (~130 lines)
    S9:  Preserve/Restore Gauntlet (~60 lines)
    S10: Second Wave Graphs 15 (~90 lines)
    S11: Natural Segmentation Anchors (~60 lines)
    S12: Final Wrap-Up (~40 lines)

  Pressure Test Checklist:
    ☐ Agent do-file path: unnamed graphs captured? (target: 5)
    ☐ Named graph batch: all 20 appear? 0 dropped?
    ☐ Brace scanner: S4 block has only 1 safe cut point
    ☐ Large SMCL log: readable without raw tags?
    ☐ putdocx mixed: docx fresh AND 4 graphs displayed?
    ☐ Post-docx graphs: 10 graphs, no transport poisoning
    ☐ Heavy compute: all models complete, no false watchdog trigger
    ☐ Session integrity: restore returns correct observation count
    ☐ Post-compute graphs: all 15 appear, no degradation
    ☐ Segmentation anchors: scanner recognizes 7 depth=0 cut points
    ☐ Final save anchor: last save at end of S12

  Expected log size: 2-4 MB
  Expected total graphs: 65+
  Expected execution time: 3-8 minutes (depends on Stata config)

================================================================================
*/

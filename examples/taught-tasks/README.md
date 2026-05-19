# Taught Task Examples

This folder contains nine public Stata do-files for demonstrating and stress-testing Stata Workbench Shared Session. They are self-contained and use Stata's built-in `auto` data or synthetic data derived from it. No private dataset is required.

The public copy of `taught_task1.do` is derived from the local file originally named `taught_task.do`. The original local file is not renamed; only the repository example is named consistently.

## Recommended Workspace Setting

The examples write temporary graphs to `7_temp/` and document/table outputs to `4_tables/` relative to the current Stata working directory. For portable runs, open this folder as the workspace or copy `.vscode/settings.example.json` to `.vscode/settings.json`:

```json
{
  "stataMcp.runFileWorkingDirectory": "${fileDir}",
  "stataMcp.maxOutputLines": 2000,
  "stataMcp.enableExecuteTimeout": false
}
```

## How to Run

1. Install the extension from Open VSX or the GitHub Release VSIX.
2. Configure `stataMcp.stataPath` to your local Stata executable.
3. Open this folder or the repository in VS Code.
4. Open `taught_task1.do`.
5. Run `Stata: Open Interactive Terminal`.
6. Run `Stata: Run Current File` or select a section and run `Stata: Run Selection/Current Line`.
7. Watch text output in `Stata Terminal` and graph output in `Stata Graphs`.

For task 5 and later, expect longer runtime and larger output. For task 8 and task 9, prefer segmented visible execution when using them as Workbench stress fixtures.

## Files

| File | Main Theme | Shows |
|---|---|---|
| `taught_task1.do` | Shared-session pressure smoke | setup, anonymous/named graphs, large SMCL output, `putdocx`, graph parity, session stability |
| `taught_task2.do` | Larger generated Workbench stress | expanded `auto` data, many generated variables, dense graph/table output, longer terminal lifecycle |
| `taught_task3.do` | Self-check stress script | Stata 18 syntax, generated variables, section progress markers, graph/table/document output |
| `taught_task4.do` | Larger self-check stress | bigger generated workload, section progress, graph routing, terminal output durability |
| `taught_task5.do` | Document and graph stress | `putdocx` helper compatibility, many generated variables, tables, graphs, document output |
| `taught_task6.do` | Heavier document/graph run | larger variable space, graph loops, regressions, document output, long visible run behavior |
| `taught_task7.do` | Applied-method diversity | DiD, IV-style variables, matching-style setup, mediation-style variables, event-study style code, coefplot-oriented stress |
| `taught_task8.do` | Extreme Workbench stress | 100+ graph/document style workload, nested braces, preserve/restore, merge-like workflows, event study, IV, matching, mediation |
| `taught_task9.do` | MI/document-heavy advanced fixture | synthetic longitudinal data, multiple imputation, survey/panel/document workflows; originally written as a native Stata 18 baseline stress file |

## Expected Effects

A healthy Workbench run should demonstrate these behaviors:

- The visible `Stata Terminal` receives commands and text output.
- The extension remains responsive after large output blocks.
- Ordinary image graph artifacts appear in the `Stata Graphs` panel.
- Generated graphs and document outputs are written under the configured working directory.
- Long runs can be diagnosed through bridge status and logs instead of relying only on terminal scrollback.

## Important Notes

- Start with `taught_task1.do`; do not use task 8 or task 9 as your first smoke test.
- These files intentionally stress the extension. Some are much larger than normal examples.
- `taught_task9.do` is an advanced MI stress fixture. It is useful for native Stata 18 baseline checks and Workbench pressure testing, but it is not a quick demo.
- If a long run appears stuck, check bridge status before sending another command.
- Do not commit generated `7_temp/`, `4_tables/`, logs, graphs, or data outputs from your local runs.

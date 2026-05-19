# Known Limitations

- The primary supported target is Windows with VS Code or an Open VSX-compatible editor and a locally licensed Stata 18 MP installation.
- Stata itself, Stata license files, private data, generated tables, graphs, logs, and run evidence are not included.
- The shared-session bridge listens on localhost and expects one visible Workbench session at a time.
- Long document, graph, MI, or regression-heavy `.do` files may need segmented visible execution and run-root verification.
- Multiple unnamed Stata graphs can overwrite the native `Graph` object; retained named graphs are more reliable for post-run routing.
- Open VSX and GitHub Release VSIX are the current public install channels. Visual Studio Marketplace publication is deferred.
- The taught task files are examples and stress fixtures, not formal statistical teaching material.
- `taught_task9.do` is an advanced native Stata 18 MI baseline/stress fixture and may require careful Workbench segmentation for visible shared-session pressure testing.

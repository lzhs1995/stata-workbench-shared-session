# Contributing

Contributions are welcome.

Before opening a pull request:

1. Do not include private data, Stata license files, logs, or generated research outputs.
2. Run:
   ```powershell
   npm install
   npm run check
   ```
3. If you change Workbench lifecycle, graph routing, terminal input, Run File, Run Selection, or recovery behavior, include a reproducible test description.
4. Preserve upstream attribution and license notices.

For issues, include:

- OS and VS Code version.
- Stata version.
- Extension version.
- Whether the problem happened in Run Selection, Run Current File, terminal input, or agent visible bridge.
- Relevant log tails with private paths/data removed.

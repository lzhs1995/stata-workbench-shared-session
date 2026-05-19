# Known Limitations

- The primary target is Windows with VS Code and a locally licensed Stata installation.
- The extension does not include Stata, a Stata license, private data, or research outputs.
- The shared-session bridge listens on localhost and expects one visible Workbench session at a time.
- Long document, graph, or MI-heavy `.do` files may need segmented execution and run-root verification.
- Multiple unnamed Stata graphs can overwrite the native `Graph` object; retained named graphs are more reliable for post-run routing.
- Marketplace and Open VSX installation are pending until the registries are published.


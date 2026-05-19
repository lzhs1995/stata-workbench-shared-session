# Architecture

The project keeps one visible Stata working site for both humans and agents:

1. Human runs selected code or a file through VS Code commands.
2. Agent-triggered execution goes through the visible bridge wrapper.
3. The Stata Terminal remains text-first.
4. Graph artifacts are routed to a separate `Stata Graphs` panel.
5. Recovery scripts handle stale UI, stopped session state, force reset, and panic-kill workflows.

The local verification model treats `ok:true` as insufficient by itself. A valid long run must also provide log evidence, output freshness, and true READY state.

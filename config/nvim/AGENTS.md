# AGENTS.md

## Scope
Contributor guidance for the Neovim config in this directory only.

## Structure
- `init.vim` is the main entrypoint and the top-level source of truth for editor behavior.
- `plug.vim` is the plugin manifest and plugin install/update surface.
- `after/plugin/` contains post-plugin configuration, with a mix of Vimscript (`*.vim`) and Lua (`*.lua`).
- `after/ftplugin/` contains filetype-specific overrides.
- `colors/` and `syntax/` contain embedded theme/syntax files and should be treated more cautiously than normal local config.

## Sources of truth
- Start in `init.vim` for global options, autocmds, runtime includes, colorscheme selection, and overall load order.
- `init.vim` explicitly references:
  - `plug.vim`
  - `maps.vim`
  - `macos.vim` on Darwin
- Use `plug.vim` when adding, removing, or grouping plugins.
- Use `after/plugin/` when changing configuration for an already-declared plugin.
- Use `after/ftplugin/` for language- or filetype-specific behavior instead of adding more conditionals to `init.vim`.

## How to change config safely
- Prefer the smallest-scope change:
  - global editor defaults → `init.vim`
  - plugin list/dependency presence → `plug.vim`
  - plugin setup/tuning → `after/plugin/`
  - per-language tweaks → `after/ftplugin/`
- Preserve the existing mixed Vimscript/Lua layout instead of rewriting files just for consistency.
- When adding plugin config, match the existing naming pattern in `after/plugin/` and keep plugin declaration in `plug.vim` aligned with its config file.
- Keep load-order-sensitive behavior in mind: this tree relies on runtime sourcing from `init.vim` plus Neovim's `after/` conventions.

## What not to touch casually
- Do not casually rewrite `colors/NeoSolarized.vim` or `syntax/ProtobufColors.vim`; these look like embedded upstream-style assets, not everyday editing surfaces.
- Do not fold unrelated refactors into `init.vim`; it is the load-bearing entrypoint.
- Do not remove references to `maps.vim` or `macos.vim` unless you have confirmed the replacement path and platform implications.
- Do not convert Vimscript files to Lua wholesale unless the change requires it and preserves behavior.

## Practical contributor notes
- Expect both legacy Vimscript and Neovim/Lua configuration in the same tree.
- If behavior appears plugin-specific, check `after/plugin/` before changing `init.vim`.
- If behavior appears language-specific, check `after/ftplugin/` before adding new global autocmds.

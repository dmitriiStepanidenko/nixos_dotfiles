# AGENTS.md

## Scope
Contributor guidance for the Alacritty config in this directory only.

## Structure
- `alacritty.toml` is the main terminal configuration entrypoint.
- `themes/` is the primary extension surface for color/theme variants.

## Sources of truth
- Use `alacritty.toml` for core terminal behavior and the active config shape.
- Use `themes/` for theme additions or edits; this directory is the maintained place for color variants.

## How to change config safely
- Put general terminal behavior changes in `alacritty.toml`.
- Prefer adding or editing theme files under `themes/` instead of hardcoding large color blocks into the main file.
- Keep theme naming and file format consistent with the existing `themes/*.toml` files.

## What not to touch casually
- Do not turn `alacritty.toml` into a dump of multiple theme definitions if `themes/` can hold them cleanly.
- Do not treat this directory like a generated cache or runtime state location; only maintained config belongs here.
- Do not introduce extra nested agent docs; this directory is small enough for one AGENTS file.

## Practical contributor notes
- Theme files are the main customization surface here.
- Keep the distinction clear between core config (`alacritty.toml`) and selectable appearance variants (`themes/`).

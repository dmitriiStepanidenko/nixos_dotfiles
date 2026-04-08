# Agent Guidelines for `timers`

## Scope
This guide applies to everything under `timers/`.

This subtree is a small script-oriented automation area. It mixes executable shell scripts with supporting assets and a nested `factorio/` automation folder.

## Structure
### Primary maintained files
Top-level maintained files include:
- `one-time.sh`
- `pomodoro.sh`
- `notification.wav`

Nested automation lives under:
- `factorio/`
  - `create_new.sh`
  - `shutdown.sh`
  - `start.sh`
  - `start_bare_server.sh`
  - `map_gen_settings.json`
  - `README.md`

### What this subtree is
Treat `timers/` as a practical automation/scripts area:
- top-level scripts handle timer-oriented workflows
- `notification.wav` is an asset used by the scripts
- `factorio/` contains service/game-server helper scripts plus supporting config/documentation

## Safe editing boundaries
### Safe to edit
- Shell scripts such as `one-time.sh`, `pomodoro.sh`, and scripts under `factorio/`
- Supporting maintained config like `factorio/map_gen_settings.json`
- Local documentation in `factorio/README.md` if the task explicitly requires it

### Edit carefully
- Asset references and filenames, because scripts may depend on exact paths
- `notification.wav` should generally be treated as a binary asset, not a text editing surface

## Practical working rules
- Preserve the script-oriented layout; avoid introducing unnecessary abstraction unless the task asks for it
- Keep changes narrow and practical: adjust script behavior, paths, flags, or small config values rather than reorganizing the subtree
- When modifying scripts, check for path coupling between top-level files and the `factorio/` subdirectory
- Treat assets and scripts as a mixed system: changing a filename or location may require corresponding script updates
- Prefer small, readable shell changes over broad rewrites

## Boundaries to avoid crossing
- Do not assume this subtree is part of a larger CI workflow
- Do not add generic automation guidance unrelated to the observed files
- Do not treat assets or generated runtime outputs as documentation surfaces unless the task explicitly asks for that

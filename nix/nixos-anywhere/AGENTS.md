# NixOS Anywhere Bootstrap Guidance

## Purpose
This subtree contains a separate bootstrap/install flake for NixOS Anywhere workflows. It is operationally distinct from normal remote host deployment under `remotes/nix`.

Use this subtree for install-image and bootstrap configuration work, not for day-to-day workstation or Colmena host changes.

## Entry Points
- `flake.nix` — bootstrap flake root
- `configuration.nix` — generic system composition for this bootstrap flow
- `hardware-configuration.nix` — machine/install-specific hardware input

## Commands
Run from `/home/dmitrii/shared/dotfiles/nix/nixos-anywhere`.
- `nix flake check`
- `alejandra .`
- `statix check`
- `deadnix`

## Boundaries
- Keep bootstrap/install concerns here.
- Do not use this subtree as the source of truth for normal remote hosts; those live in `../../remotes/nix` and `../hosts`.
- Do not treat hardware files here as reusable abstractions.

## Sensitive and Noisy Paths
Treat carefully:
- `hardware-configuration.nix`

## Conventions
- This subtree is its own flake root; validate it from here.
- Keep bootstrap-specific configuration separate from reusable modules and steady-state host composition.
- If a behavior is shared across multiple machines after installation, move it to `../modules` or `../hosts` rather than keeping it bootstrap-only.

# Local Workstation NixOS Guidance

## Purpose
This subtree is the **local workstation** NixOS root. Its flake at `etc/nixos/flake.nix` builds the `nixos` machine and wires in local home-manager configuration, overlays, and selected packages from `../../nix`.

This is the main root for desktop/laptop configuration work, not for remote server deployment.

## Entry Points
- `flake.nix` — local workstation flake root
- `configuration.nix` — main local system composition
- `home-manager/` — user home-manager entry points
- `modules/` — local-only modules used by the workstation config
- `overlays/` — local overlays
- `packages/` — local package helpers
- `rebuild.sh` — preferred local rebuild workflow

## Commands
Run from `/home/dmitrii/shared/dotfiles/etc/nixos` unless a command says otherwise.
- `alejandra .`
- `nix flake check`
- `statix check`
- `deadnix`
- `./rebuild.sh`

Use `./rebuild.sh` for actual workstation rebuilds; it formats first, runs `nixos-rebuild switch --flake .`, and writes `nixos-switch.log`.

## Boundaries
- This subtree owns the local workstation only.
- Do not use this subtree as the source of truth for remote hosts; those live under `remotes/nix/flake.nix` and `../../nix/hosts`.
- Keep host-agnostic reusable logic in `../../nix/modules` or `../../nix/packages` instead of growing `configuration.nix`.
- Do not document or maintain runtime logs as configuration.

## Sensitive and Noisy Paths
Treat as sensitive:
- `secrets/secrets.yaml`
- `secrets/`
- `keys/`

Treat as lock/log outputs, not maintained configuration:
- `flake.lock`
- `nixos-switch.log`

## Conventions
- Local flake outputs already import shared code from `../../nix/modules` and `../../nix/packages`; prefer extending those shared locations for reusable behavior.
- Keep workstation-only concerns here: desktop stack, local hardware, local home-manager wiring, local overlays.
- If a change could apply to multiple machines, move it out of `etc/nixos/modules` into `../../nix/modules`.
- Keep rebuild instructions aligned with the existing `rebuild.sh` workflow rather than inventing alternate root-level commands.

# Repository Guidance

## Purpose
This repository is a dotfiles + Nix monorepo with split ownership domains.

Important roots:
- local workstation NixOS root: `etc/nixos/flake.nix`
- remote/server infrastructure root: `remotes/nix/flake.nix`
- ARM-specific flake root: `arm/flake.nix`
- bootstrap/install flake root: `nix/nixos-anywhere/flake.nix`
- CI/container flake root: `nix/ci_containers/flake.nix`
- remote host definitions: `nix/hosts`
- shared NixOS/home-manager modules: `nix/modules`
- custom package expressions: `nix/packages`

This repository root is **not** a flake root. Do not assume `nix flake check` is valid from `/home/dmitrii/shared/dotfiles`.

## Entry Points
- `etc/nixos/flake.nix` — local workstation flake
- `remotes/nix/flake.nix` — remote infra + Colmena flake
- `arm/flake.nix` — ARM-specific flake centered on `nix/hosts/piwatch`
- `nix/nixos-anywhere/flake.nix` — bootstrap/install flake
- `nix/ci_containers/flake.nix` — CI container image flake
- `etc/nixos/configuration.nix` — local workstation system composition
- `nix/hosts/<name>/default.nix` — per-host remote definitions
- `nix/modules/*.nix` and subtree defaults — shared modules
- `nix/packages/*.nix` and `nix/packages/*/default.nix` — custom packages
- `config/nvim` / `config/alacritty` / `config/leftwm` — maintained app config trees
- `timers` — local automation scripts
- `remotes` — Terraform + nested Nix infra authoring

## Commands
Run commands from the correct subtree, not from repo root.
- Local workstation formatting/rebuild flow: `etc/nixos/rebuild.sh`
- Local workstation updates: `etc/nixos/update.sh` or repo-root `update.sh`
- Local workstation flake checks: `cd etc/nixos && nix flake check`
- Remote infra flake checks: `cd remotes/nix && nix flake check`
- Bootstrap flake checks: `cd nix/nixos-anywhere && nix flake check`
- CI container flake checks: `cd nix/ci_containers && nix flake check`
- Format Nix files where relevant: `alejandra .`
- Optional static checks when touching Nix code: `statix check`, `deadnix`
- Rekey SOPS files when needed: `./update_keys.sh`

## Boundaries
- Do not treat the repo root as the source of truth for evaluation.
- Do not add generic host-level guidance here; keep host specifics under `nix/hosts`.
- Do not treat runtime or cache-like outputs as maintained domains.
- Prefer changing shared logic in `nix/modules` or `nix/packages` before duplicating logic inside hosts.
- `config/discord` is checked-in runtime/cache noise, not a maintained config subtree.

## Sensitive and Noisy Paths
Handle carefully:
- `etc/nixos/secrets/secrets.yaml`
- `etc/nixos/secrets/`
- `etc/nixos/keys/`
- `nix/hosts/*/secrets.yaml`
- `nix/modules/usbguard/secrets.yaml`
- `remotes/.envrc`
- `remotes/terraform.tfstate*`

Avoid treating generated/noisy paths as primary editing targets:
- `etc/nixos/flake.lock`
- `etc/nixos/nixos-switch.log`
- `remotes/.terraform/`
- `remotes/.terraform.lock.hcl`
- `remotes/generated.tf`
- `remotes/nix/.direnv/`
- `nix/ci_containers/result`
- `config/discord/**`

## Conventions
- Keep guidance and changes anchored to the correct flake root.
- Reference hosts by their directory names under `nix/hosts`.
- Keep shared module code in `nix/modules` importable from multiple hosts.
- Keep package expressions in `nix/packages` focused on build/package logic, not deployment logic.
- Keep app-specific config conventions inside their local subtrees instead of expanding root guidance.

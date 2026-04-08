# Remote Host Definitions Guidance

## Purpose
This subtree contains per-host NixOS definitions for remote infrastructure. Each host directory is imported by `remotes/nix/flake.nix` into Colmena nodes and, in some cases, additional flake outputs such as install images or standalone configurations.

This subtree is for machine composition, deployment-specific wiring, and host secrets references.

## Entry Points
- `remotes/nix/flake.nix` — the deployment root that imports this subtree
- `*/default.nix` — primary entry point for each host
- sibling files such as `disk-config.nix`, `hardware-configuration.nix`, `restic.nix`, `uptime-kuma.nix`, `nix_builder.nix`, `rag-pipeline.nix`, `omniroute.nix` — host-scoped splits

Known host directories include:
`backup_local`, `backup`, `builder`, `dev_new`, `gitea_worker`, `grafana`, `isoimage`, `nginx_local`, `openobserve`, `piwatch`, `registry`, `smallNfs`, `tikv`, `vpn`, `wakapi`, `woodpecker_agent`, `woodpecker_server`.

## Commands
Validate from the remote infra root, not from this directory itself.
- `cd /home/dmitrii/shared/dotfiles/remotes/nix && nix flake check`
- `cd /home/dmitrii/shared/dotfiles/remotes/nix && alejandra .`
- `cd /home/dmitrii/shared/dotfiles/remotes/nix && statix check`
- `cd /home/dmitrii/shared/dotfiles/remotes/nix && deadnix`

If secrets were rotated or recipients changed:
- `cd /home/dmitrii/shared/dotfiles && ./update_keys.sh`

## Boundaries
- One directory here represents one deployable machine role or image input.
- Keep reusable service logic out of host files when it can live in `../modules`.
- Keep package build logic out of hosts; package that in `../packages`.
- Do not add child AGENTS files for every host unless there is a real repeated need.

## Sensitive and Noisy Paths
Treat as sensitive:
- `*/secrets.yaml`

Treat as generated machine-local inputs, not reusable abstractions:
- `*/hardware-configuration.nix`
- `*/disk-config.nix`

## Conventions
- `default.nix` is the canonical host entry point.
- Use host-local split files only for substantial host-specific concerns.
- Prefer imports from `../../nix/modules` for shared services such as Woodpecker or other reusable infrastructure building blocks.
- Keep deployment facts and machine-specific settings here: disks, networking, SOPS bindings, hostnames, service enablement, per-node overrides.
- Match names exactly with what `remotes/nix/flake.nix` imports; directory names are operational identifiers.

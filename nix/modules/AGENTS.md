# Shared Nix Modules Guidance

## Purpose
This subtree holds reusable NixOS and home-manager modules shared across hosts and flakes. It is the place for common behavior that should be imported by multiple machines instead of copied into `etc/nixos` or individual host directories.

Examples in this subtree include shared modules for `tmux`, `nix-ld`, `fpga_hardware`, `woodpecker_agent`, `gitea_action_runner`, `usbguard`, `nvf-configuration`, and `home-manager/dmitrii.nix`.

## Entry Points
- `*.nix` at subtree root — reusable modules
- `home-manager/dmitrii.nix` — shared home-manager module imported by remote builder setup
- `usbguard/default.nix` — module subtree with local secret reference
- `nvf-configuration.nix` — shared Neovim/nvf configuration used by both local and remote flakes

## Commands
Validate from the flake root that imports the module you changed.
- Local consumer: `cd /home/dmitrii/shared/dotfiles/etc/nixos && nix flake check`
- Remote consumer: `cd /home/dmitrii/shared/dotfiles/remotes/nix && nix flake check`
- Format relevant Nix code from the appropriate root with `alejandra .`
- Optional static checks: `statix check`, `deadnix`

## Boundaries
- This subtree is for reusable modules, not machine deployment definitions.
- Do not move host-specific IPs, disks, or deployment targets here.
- Do not turn package derivations into modules; keep package expressions in `../packages`.
- Keep secrets references abstract where possible, but respect modules that intentionally bind to subtree-local secrets.

## Sensitive and Noisy Paths
Treat as sensitive:
- `usbguard/secrets.yaml`

## Conventions
- Design modules to be imported from multiple roots (`etc/nixos/flake.nix` and `remotes/nix/flake.nix`).
- Prefer small focused modules with explicit imports and options over embedding large inline configs into hosts.
- `nvf-configuration.nix` is shared editor logic; avoid duplicating editor configuration elsewhere.
- Home-manager content that is reused across machines belongs under `home-manager/`.
- If a module only exists to support one host and is not reusable, keep it in that host directory instead.

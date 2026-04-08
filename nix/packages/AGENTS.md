# Custom Package Expressions Guidance

## Purpose
This subtree contains custom package expressions and package wrappers used by the local workstation and remote infrastructure. These files define how software is built or fetched; they are not deployment entry points.

Examples include standalone package files such as `friction.nix`, `ivms-4200.nix`, `wakapi.nix`, `woodpecker-agent.nix`, `woodpecker-server.nix`, and the `surrealist/` package subtree.

## Entry Points
- `*.nix` at subtree root — direct package expressions typically consumed via `callPackage`
- `surrealist/default.nix` — package subtree entry point
- consumers currently include:
  - `etc/nixos/configuration.nix` via `pkgs.callPackage ../../nix/packages/...`
  - flake package outputs in other roots where relevant

## Commands
Run validation from the flake that consumes the package.
- Local consumer path: `cd /home/dmitrii/shared/dotfiles/etc/nixos && nix flake check`
- Remote consumer path: `cd /home/dmitrii/shared/dotfiles/remotes/nix && nix flake check`
- Format relevant Nix code with `alejandra .`
- Optional static checks: `statix check`, `deadnix`

## Boundaries
- Keep only package/build logic here.
- Do not put deployment settings, host networking, SOPS declarations, or service enablement in this subtree.
- If logic configures a NixOS service or machine, it belongs in `../modules` or `../hosts`, not here.

## Conventions
- Prefer one package per file unless a package needs its own subtree.
- Use a package subtree like `surrealist/` only when the package has multiple supporting files or its own entry point.
- Keep package interfaces easy to consume with `pkgs.callPackage`.
- Avoid coupling package expressions to a single host unless the package is truly host-specific.
- When a package is only referenced from one flake today but is broadly reusable, still keep it generic.

## Sensitive and Noisy Paths
- No secrets should live here.
- If a package requires credentials at runtime, wire them from hosts/modules, not from the package definition.

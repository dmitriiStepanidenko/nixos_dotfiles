# CI Container Flake Guidance

## Purpose
This subtree contains a distinct flake for building CI/container images. It is separate from both the local workstation flake and the remote deployment flake.

Use this subtree when the task is about containerized build environments, layered images, or CI image definitions.

## Entry Points
- `flake.nix` — CI/container flake root
- `flake.lock` — pinned inputs for this flake
- image-definition files in this subtree — container-specific authoring surfaces

## Commands
Run from `/home/dmitrii/shared/dotfiles/nix/ci_containers`.
- `nix flake check`
- `alejandra .`
- `statix check`
- `deadnix`

## Boundaries
- Keep CI/container image logic here, not in host definitions.
- Do not treat `result` symlinks or build outputs as maintained source.
- Do not put workstation or remote deployment composition here unless it directly supports container-image authoring.

## Sensitive and Noisy Paths
Treat as generated/noisy:
- `result`

## Conventions
- This subtree is its own flake root; validate it from here.
- Keep image definitions focused on reproducible container/build environments.
- If logic becomes reusable across hosts or workstation configs, move it into `../modules` or `../packages` instead of duplicating it here.

# Agent Guidelines for `remotes`

## Scope
This guide applies to everything under `remotes/`.

This subtree is a mixed infrastructure area with two main authoring surfaces:
- top-level Terraform configuration:
  - `providers.tf`
  - `machines.tf`
  - `imports.tf`
- nested Nix configuration under `nix/`, especially:
  - `nix/flake.nix`

Treat those files as the primary maintained sources unless a task explicitly says otherwise.

## Structure
### Primary maintained files
- `providers.tf` — provider definitions and related Terraform configuration
- `machines.tf` — machine/resource declarations
- `imports.tf` — import-related Terraform declarations kept as source
- `nix/flake.nix` — primary Nix entrypoint for the nested Nix environment
- `nix/flake.lock` — lockfile; update only when the task specifically requires dependency/input refreshes
- `nix/justfile` — helper commands for the nested Nix workflow if a task explicitly targets them

### Generated, local, or stateful artifacts
These are **not primary authoring surfaces** and should not be edited by hand unless the user explicitly asks for artifact recovery/debug work:
- `.terraform/`
- `.terraform.lock.hcl`
- `terraform.tfstate`
- `terraform.tfstate.backup`
- `generated.tf`
- `nix/result/`
- `nix/.direnv/`

Assume these are derived, local, cached, or state-bearing outputs. Prefer changing the maintained source files and then regenerating/re-applying through the normal toolchain instead of patching artifacts directly.

## Safe editing boundaries
### Safe to edit
- Terraform source files that define intended infrastructure:
  - `providers.tf`
  - `machines.tf`
  - `imports.tf`
- Nix source files under `nix/`, especially `nix/flake.nix`
- Small supporting text/config files only when they are clearly maintained source and directly relevant to the task

### Do not edit by default
- Terraform state files: `terraform.tfstate*`
- Terraform working directory contents: `.terraform/`
- Derived outputs like `generated.tf` unless the task explicitly identifies it as maintained source
- Nix build/link artifacts such as `nix/result/`
- Direnv cache/state such as `.direnv/`

If a requested change appears to require editing state or generated output, stop and prefer changing the source that produces it.

## Secrets and environment handling
This subtree contains environment-related material such as `.envrc` files. Treat all environment files and provider credentials as sensitive.

- Never print secret values into summaries, diffs, or proposed file content
- Never invent placeholder secrets that look real
- Do not copy credentials from `.envrc`, Terraform variables, shell history, or state files into committed source
- Be especially careful because Terraform state may contain sensitive values; avoid reading or quoting it unless the task explicitly requires inspection

When documenting or proposing changes, refer to secrets abstractly, for example:
- “provider credentials are loaded from environment”
- “sensitive values should remain outside tracked source”

## Practical working rules
- Keep recommendations narrow and tied to the observed files in this subtree
- When updating infrastructure intent, prefer Terraform source files first
- When updating the nested Nix environment, work from `nix/flake.nix` and related maintained Nix files
- Do not describe this subtree as CI- or GitHub-Actions-driven
- Do not prescribe generic Terraform workflows unless the task directly requires them

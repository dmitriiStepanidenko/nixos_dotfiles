# Agent Guidelines for This Repository

## Build & Test Commands

### Core Commands
- `nix-build` - Build the project
- `nix-shell` - Enter development shell
- `nix-env -iA` - Install packages

### Linting & Formatting
- `nixpkgs-fmt .` - Format Nix files
- `statix check` - Check for Nix antipatterns
- `deadnix` - Find unused Nix code

### Testing
- `nix eval .#tests` - Run all tests
- `nix eval .#tests.<name>` - Run specific test
- `nix flake check` - Run all checks

## Code Style Guidelines

### General
- Prefer pure functions where possible
- Document public interfaces with comments
- Keep functions small and focused

### Imports
- Group imports by type (nixpkgs, local, etc)
- Alphabetize imports within groups

### Formatting
- 2 spaces for indentation
- 80 character line length
- Follow nixpkgs-fmt conventions

### Naming
- snake_case for variables and functions
- UPPER_CASE for constants
- descriptive_names over abbreviations

### Error Handling
- Use `assert` for input validation
- Provide helpful error messages
- Prefer built-in assertions to custom checks

### Types
- Annotate complex function arguments
- Use `// { }` for attribute set defaults
- Document expected types in comments

### Performance
- Avoid unnecessary string operations
- Memoize expensive computations
- Prefer attribute sets over lists for lookups
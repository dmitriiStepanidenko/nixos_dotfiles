#!/usr/bin/env bash

# cd to your config dir
pushd /home/dmitrii/shared/dotfiles/etc/nixos

# Get current generation metadata
current=$(nixos-rebuild list-generations | grep current)

# Commit all changes witih the generation metadata
git commit -am "$current"

# Back to where you were
popd

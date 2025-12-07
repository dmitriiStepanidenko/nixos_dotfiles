#!/usr/bin/env bash

# cd to your config dir
pushd /home/dmitrii/shared/dotfiles/etc/nixos

# Get current generation metadata
#current=$(nixos-rebuild list-generations | grep current)
current=$(nixos-rebuild list-generations | awk 'NR>1 && $NF=="True" {print $1, $2" "$3, $4, $5}')

# Commit all changes witih the generation metadata
git commit -am "$current"

# Back to where you were
popd

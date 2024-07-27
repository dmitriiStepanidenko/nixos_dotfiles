#!/usr/bin/env bash
cd etc/nixos
sudo nix-channel --update
nix-channel --update
nix flake update

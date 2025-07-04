#!/usr/bin/env bash
sops updatekeys etc/nixos/secrets/secrets.yaml --yes
sops updatekeys nix/hosts/nginx_local/secrets.yaml --yes
sops updatekeys nix/hosts/backup/secrets.yaml --yes
sops updatekeys nix/hosts/gitea_worker/secrets.yaml --yes
sops updatekeys nix/hosts/grafana/secrets.yaml --yes

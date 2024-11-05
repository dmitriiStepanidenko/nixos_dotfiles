# https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/neovim/utils.nix#L27
{
  pkgs,
  neovimUtils,
  wrapNeovimUnstable,
  ...
}: let
  config = pkgs.neovimUtils.makeNeovimConfig {
    extraLuaPackages = p: [p.magick];
    extraPackages = p: [p.imagemagick];
    enable = true;
    defaultEditor = true;
    # ... other config
  };
in {
  nixpkgs.overlays = [
    (_: super: {
      neovim-custom =
        pkgs.wrapNeovimUnstable
        (super.neovim-unwrapped.overrideAttrs (oldAttrs: {
          buildInputs = oldAttrs.buildInputs ++ [super.tree-sitter];
        }))
        config;
    })
  ];
  environment.systemPackages = with pkgs; [neovim-custom];
}
#{
#  pkgs,
#  inputs,
#  ...
#}: {
#  #nixpkgs.overlays = [
#  #  (import (
#  #    builtins.fetchTarball
#  #    # "https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz";
#  #    "https://github.com/nix-community/neovim-nightly-overlay/archive/1f54e89757bd951470a9dcc8d83474e363f130c5.tar.gz"
#  #  ))
#  #];
#  nixpkgs.overlays = [
#    inputs.neovim-nightly-overlay.overlays.default
#  ];
#
#  #rust_overlay = import (builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/a1b337569f334ff0a01b57627f17b201d746d24c.zip");
#
#  #programs.neovim = {
#  #  enable = true;
#  #  #package = pkgs.neovim-nightly;
#  #  #extraLuaPackages = ps: [ps.magick];
#  #  withNodeJs = true;
#  #};
#
#  #home.packages = with pkgs; [neovide];
#}


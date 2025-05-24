{pkgs, ...}: {
  imports = [
    ./tmux.nix
  ];

  environment.systemPackages = with pkgs; [
    mprocs
    just
    wiki-tui
    delta
  ];
}

{pkgs, ...}: {
  imports = [
    ./tmux.nix
  ];

  environment.systemPackages = with pkgs; [
    mprocs
    just
    wiki-tui
    delta
    bat
    xh
    zellij
    du-dust
    dua
    rusty-man
  ];

  programs.fish = {
    enable = true;
  };
  programs.direnv.enable = true;
}

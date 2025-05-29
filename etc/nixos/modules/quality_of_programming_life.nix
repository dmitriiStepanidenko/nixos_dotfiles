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
    xh # sending requests over web
    zellij # tmux analog
    du-dust # disk usage in useful output
    dua # disk usage like in du
    rusty-man
    scooter # find and replace in files via tui

    tokei # count all tokens
  ];
  programs.television = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fish = {
    enable = true;
  };
  programs.direnv.enable = true;
}

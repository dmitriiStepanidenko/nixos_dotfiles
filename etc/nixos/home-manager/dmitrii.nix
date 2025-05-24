{
  config,
  pkgs,
  ...
}: {
  home = {
    username = "dmitrii";
    homeDirectory = "/home/dmitrii";

    stateVersion = "25.05";
  };

  programs.git = {
    enable = true;
    delta.enable = true;
  };
  programs.home-manager.enable = true;
}

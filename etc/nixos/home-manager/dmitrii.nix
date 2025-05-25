{
  config,
  pkgs,
  ...
}: {
  home = {
    username = "dmitrii";
    #homeDirectory = "/home/dmitrii";

    stateVersion = "25.05";
  };
  programs = {
    git = {
      enable = true;
      delta.enable = true;
    };
    #home-manager.enable = true;
    fish = {
      enable = true;
    };
    starship = {
      enable = true;
      enableFishIntegration = true;
    };
    yazi = {
      enable = true;
      enableFishIntegration = true;
    };

    alacritty = {
      enable = true;
      settings = {
        window.opacity = 0.97;
        font = {
          normal = {
            family = "Fira Code";
            style = "Regular";
          };
          bold = {
            family = "Fira Code";
            style = "Bold";
          };
          italic = {
            family = "Fira Code";
            style = "Italic";
          };
        };
      };
      theme = "tokyo_night";
    };
  };
}

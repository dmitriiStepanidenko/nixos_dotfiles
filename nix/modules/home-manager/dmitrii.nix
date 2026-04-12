{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./opencode.nix
    #./yubikey.nix
  ];
  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  };
  home = {
    username = "dmitrii";
    homeDirectory = "/home/dmitrii";

    stateVersion = "25.11";

    packages = [
      pkgs.serpl
      pkgs.ast-grep
    ];

    sessionPath = [
      "$HOME/.cargo/bin"
    ];

    sessionVariables = {
      SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt";
    };
  };
  programs = {
    television = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        ui = {
          use_nerd_font_icons = true;
          theme = "tokyonight";
        };
      };
    };
    delta = {
      enable = true;
      enableGitIntegration = true;
    };
    git = {
      enable = true;
      lfs = {
        enable = true;
      };
      settings = {
        user = {
          name = "Dmitrii Stepanidenko";
          email = "dimitrij.stepanidenko@gmail.com";
        };
        core.editor = "nvim";
      };
    };
    home-manager.enable = true;
    fish = {
      enable = true;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true; # ← super useful on NixOS
      #enableFishIntegration = true;
    };
    starship = {
      enable = true;
      enableFishIntegration = true;
    };
    yazi = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}

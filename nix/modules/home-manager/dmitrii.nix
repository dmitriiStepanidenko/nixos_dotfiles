{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    #./yubikey.nix
    #{inherit inputs;}
  ];
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

    #file.".config/sops/age/age-yubikey-identity-default-c.txt" = {
    #  source = ../keys/users/age/age-yubikey-identity-default-c.txt;
    #};

    sessionVariables = {
      SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/age-yubikey-identity-default-c.txt";
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
    };
    home-manager.enable = true;
    fish = {
      enable = true;
    };
    direnv = {
      enable = true;
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
    halloy = {
      enable = true;
      package = null;
      settings = {
        #theme = "tokyo-night-storm";
        "buffer.channel.topic" = {
          enabled = true;
        };
        "servers.liberachat" = {
          channels = [
            "#halloy"
            "#nixos"
          ];
          nickname = "dmitrii_s";
          server = "irc.libera.chat";
        };
      };
    };
  };
}

{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hyprland.nix
    #{inherit inputs;}
  ];
  home = {
    username = "dmitrii";
    homeDirectory = "/home/dmitrii";

    stateVersion = "25.05";

    file."${config.home.homeDirectory}/.config/leftwm/" = {
      source = ../../../config/leftwm;
      recursive = true;
    };
  };
  xdg = {
    mime = {
      enable = true;
    };
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "application/pdf" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
        "inode/directory" = "yazi.desktop";
      };
    };
    #portal = {
    #  enable = false;
    #  extraPortals = [
    #    pkgs.xdg-desktop-portal-cosmic
    #    pkgs.xdg-desktop-portal-gnome
    #  ];
    #  config.common.default = ["cosmic"];
    #  xdgOpenUsePortal = true;
    #};
  };
  programs = {
    television = {
      settings = {
        ui = {
          use_nerd_font_icons = true;
          theme = "tokyonight";
        };
      };
    };
    git = {
      enable = true;
      delta.enable = true;
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
  services.easyeffects = {
    enable = true;
    extraPresets = {
      badSpeakers = {
        output = {
          "bass_enhancer#0" = {
            "amount" = 0.0;
            "blend" = 0.0;
            "bypass" = false;
            "floor" = 20.0;
            "floor-active" = false;
            "harmonics" = 8.5;
            "input-gain" = 0.0;
            "output-gain" = 0.0;
            "scope" = 150.0;
          };
          "blocklist" = [];
          "filter#0" = {
            "balance" = 0.0;
            "bypass" = false;
            "equal-mode" = "IIR";
            "frequency" = 150.0;
            "gain" = -30.0;
            "input-gain" = 0.0;
            "mode" = "RLC (BT)";
            "output-gain" = 0.0;
            "quality" = 0.0;
            "slope" = "x1";
            "type" = "High-pass";
            "width" = 4.0;
          };
          "plugins_order" = [
            "filter#0"
            "bass_enhancer#0"
            "stereo_tools#0"
          ];
          "stereo_tools#0" = {
            "balance-in" = 0.25;
            "balance-out" = 0.0;
            "bypass" = false;
            "delay" = 0.0;
            "input-gain" = 0.0;
            "middle-level" = 0.0;
            "middle-panorama" = 0.0;
            "mode" = "LR > LR (Stereo Default)";
            "mutel" = false;
            "muter" = false;
            "output-gain" = 0.0;
            "phasel" = false;
            "phaser" = false;
            "sc-level" = 1.0;
            "side-balance" = 0.0;
            "side-level" = 0.0;
            "softclip" = false;
            "stereo-base" = 0.0;
            "stereo-phase" = 0.0;
          };
        };
      };
    };
  };
  home.pointerCursor = {
    gtk.enable = true;
    # x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  gtk = {
    enable = true;

    theme = {
      package = pkgs.tokyonight-gtk-theme;
      name = "Tokyonight-Dark";
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    font = {
      name = "Fira Code";
      size = 12;
    };
  };
}

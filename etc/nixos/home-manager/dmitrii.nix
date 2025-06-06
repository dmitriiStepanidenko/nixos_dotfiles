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

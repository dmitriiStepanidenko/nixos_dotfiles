{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hyprland.nix
    #./yubikey.nix
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

    packages = [
      pkgs.serpl
      pkgs.ast-grep
    ];

    sessionPath = [
      "$HOME/.cargo/bin"
    ];

    file.".config/sops/age/age-yubikey-identity-default-c.txt" = {
      source = ../keys/users/age/age-yubikey-identity-default-c.txt;
    };

    sessionVariables = {
      SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/age-yubikey-identity-default-c.txt";
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
    halloy = {
      enable = true;
      package = null;
      settings = {
        theme = "tokyo-night-storm";
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
      #theme = "github_light";
    };
  };
  services.easyeffects = {
    enable = true;
    extraPresets = {
      microDefault = {
        input = {
          "blocklist" = [];
          "deepfilternet#0" = {
            "attenuation-limit" = 100.0;
            "max-df-processing-threshold" = 20.0;
            "max-erb-processing-threshold" = 30.0;
            "min-processing-buffer" = 2;
            "min-processing-threshold" = -10.0;
            "post-filter-beta" = 0.02;
          };
          "exciter#0" = {
            "amount" = 0.0;
            "blend" = 0.0;
            "bypass" = false;
            "ceil" = 16000.0;
            "ceil-active" = false;
            "harmonics" = 8.5;
            "input-gain" = 0.0;
            "output-gain" = 0.0;
            "scope" = 7500.0;
          };
          "plugins_order" = [
            "rnnoise#0"
            "deepfilternet#0"
            "speex#0"
            "exciter#0"
            "stereo_tools#0"
          ];
          "rnnoise#0" = {
            "bypass" = false;
            "enable-vad" = false;
            "input-gain" = 0.0;
            "model-name" = "";
            "output-gain" = 0.0;
            "release" = 20.0;
            "vad-thres" = 50.0;
            "wet" = 0.0;
          };
          "speex#0" = {
            "bypass" = false;
            "enable-agc" = false;
            "enable-denoise" = false;
            "enable-dereverb" = false;
            "input-gain" = 0.0;
            "noise-suppression" = -70;
            "output-gain" = 0.0;
            "vad" = {
              "enable" = false;
              "probability-continue" = 80;
              "probability-start" = 85;
            };
          };
          "stereo_tools#0" = {
            "balance-in" = 0.0;
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

{
  pkgs,
  lib,
  inputs,
  ...
}: {

  config.vim = {
    theme.enable = true;
    theme.name = "tokyonight";
    theme.style = "night";

    lineNumberMode = "number";

    options = {
        tabstop = 2;
    };

    filetree = {
      nvimTree = {
        enable = true;
        mappings = {
          toggle = "\\v";
        };
        setupOpts = {
          diagnostics = {
            debounce_delay = 500;
            show_on_dirs = true;
            enable = true;
          };
          hijack_cursor = true;
          renderer = {
            indent_markers.enable = true;
          };
          tab.sync.close = true;
          update_focused_file.enable = true;
          view.centralize_selection = true;
        };
      };
    };
    keymaps = [
      {
        key = "H";
        mode = "n";
        silent = true;
        action = "gT";
      }
      {
        key = "L";
        mode = "n";
        silent = true;
        action = "gt";
      }
      #{
      #  key = "\\v";
      #  mode = "n";
      #  silent = true;
      #  action = ":NvimTreeToggle<CR>";
      #}
    ];

    searchCase = "ignore";

    lsp = {
      mappings = {
        addWorkspaceFolder = "\\\\wa";
        format = "<space>f";
        goToDeclaration = "gD";
        goToDefinition = "gd";
        goToType = "gt";
        hover = "K";
        listImplementations = "gi";
        listReferences = "gr";
        nextDiagnostic = "]d";
        previousDiagnostic = "[d";
        codeAction = "\\\\ca";
        renameSymbol = "\\\\rn";
      };
      lightbulb.enable = true;
      lsplines.enable = true;
      # Currentrly does not work
      #lspsaga = {
      #  enable = true;
      #  mappings = {
      #    codeAction = "\\ca";
      #    rename = "\\rn";
      #  };
      #};
    };
    snippets = {
      luasnip = {
        #providers = [
        #  "rustaceanvim"
        #];
        enable = true;
      };
    };

    statusline.lualine.enable = true;
    telescope = {
      enable = true;
      mappings = {
        findFiles = ";f";
        liveGrep = ";r";
        buffers = "\\\\";
        helpTags = ";;";
      };
    };
    autocomplete.nvim-cmp.enable = true;
    languages = {
      enableLSP = true;
      enableTreesitter = true;

      nix = {
                                enable = true;
                                format.enable = true;
        };
      terraform.enable = true;
      bash.enable = true;

      markdown.enable = true;

      ts.enable = true;
      lua.enable = true;
      python.enable = true;
      rust = {
        enable = true;
        format.enable = true;
        treesitter.enable = true;
        crates.enable = true;
        lsp = {
          enable = true;
          #package =
          #  inputs.nixos_unstable.legacyPackages.${pkgs.system}.rust-analyzer;
        };
      };
      svelte = {
        enable = true;
        format.enable = true;
        treesitter.enable = true;
      };
    };
    utility = {
      preview = {
        markdownPreview = {
          enable = true;
        };
      };
      motion.leap = {
        enable = true;
        mappings = {
          leapForwardTo = "\\s";
          leapBackwardTo = "\\S";
        };
      };
      vim-wakatime.enable = true;
      outline = {
        aerial-nvim = {
          enable = true;
          mappings.toggle = "\\l";
        };
      };
    };
    visuals = {
      nvim-web-devicons.enable = true;
    };
    notify.nvim-notify.enable = true;
  };
}

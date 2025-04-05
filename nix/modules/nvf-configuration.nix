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
          filesystem_watchers.debounce_delay = 350;
          view.debounce_delay = 350;
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
      # Resize
      {
        key = "<A-Right>";
        mode = "n";
        silent = true;
        action = ":vertical resize +1<CR>";
      }
      {
        key = "<A-Left>";
        mode = "n";
        silent = true;
        action = ":vertical resize -1<CR>";
      }
      {
        key = "<A-Down>";
        mode = "n";
        silent = true;
        action = ":resize +1<CR>";
      }
      {
        key = "<A-Up>";
        mode = "n";
        silent = true;
        action = ":resize -1<CR>";
      }

      # Terminal keybinds
      {
        key = "<A-Esc>";
        mode = "t";
        silent = true;
        action = "<C-\\><C-n>";
      }
      {
        key = "<A-h>";
        mode = "t";
        silent = true;
        action = "<C-\\><C-N><C-w>h";
      }
      {
        key = "<A-j>";
        mode = "t";
        silent = true;
        action = "<C-\\><C-N><C-w>j";
      }
      {
        key = "<A-k>";
        mode = "t";
        silent = true;
        action = "<C-\\><C-N><C-w>k";
      }
      {
        key = "<A-l>";
        mode = "t";
        silent = true;
        action = "<C-\\><C-N><C-w>l";
      }
      {
        key = "<A-h>";
        mode = "i";
        silent = true;
        action = "<C-\\><C-N><C-w>h";
      }
      {
        key = "<A-j>";
        mode = "i";
        silent = true;
        action = "<C-\\><C-N><C-w>j";
      }
      {
        key = "<A-k>";
        mode = "i";
        silent = true;
        action = "<C-\\><C-N><C-w>k";
      }
      {
        key = "<A-l>";
        mode = "i";
        silent = true;
        action = "<C-\\><C-N><C-w>l";
      }
      {
        key = "<A-h>";
        mode = "n";
        silent = true;
        action = "<C-w>h";
      }
      {
        key = "<A-j>";
        mode = "n";
        silent = true;
        action = "<C-w>j";
      }
      {
        key = "<A-k>";
        mode = "n";
        silent = true;
        action = "<C-w>k";
      }
      {
        key = "<A-l>";
        mode = "n";
        silent = true;
        action = "<C-w>l";
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
    debugger = {
      nvim-dap = {
        enable = true;
        ui = {
          enable = true;
        };
      };
    };
    terminal.toggleterm = {
      enable = true;
      lazygit = {
        enable = true;
        #direction = "tab";
        mappings = {
          #open = "\\gg";
        };
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

      graphql = {
        enable = true;
        treesitter.enable = true;
      };

      nix = {
        enable = true;
        format.enable = true;
        format.type = "alejandra";
        extraDiagnostics.enable = true;
        lsp.enable = true;
        treesitter.enable = true;
      };
      terraform.enable = true;
      bash.enable = true;

      markdown.enable = true;

      ts.enable = true;
      lua.enable = true;
      python.enable = true;

      clang = {
        dap.debugger = "lldb-dap";
      };
      rust = {
        enable = true;
        format.enable = true;
        treesitter.enable = true;
        crates.enable = true;
        dap = {
          enable = true;
        };
        lsp = {
          enable = true;
          #package =
          #  inputs.nixos_unstable.legacyPackages.${pkgs.system}.rust-analyzer;
        };
      };
      svelte = {
        extraDiagnostics.enable = true;
        enable = true;
        format.enable = true;
        treesitter.enable = true;
        lsp.enable = true;
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

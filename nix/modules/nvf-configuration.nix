{
  pkgs,
  lib,
  inputs,
  ...
}: {
  config.vim = {
    theme = {
      enable = true;
      name = "tokyonight";
      style = "night";
      transparent = true;
    };

    lineNumberMode = "number";

    options = {
      tabstop = 2;
    };
    extraPlugins = {
      "lsp-file-operations" = {
        package = pkgs.fetchFromGitHub {
          owner = "antosha417";
          repo = "nvim-lsp-file-operations";
          rev = "9744b738183a5adca0f916527922078a965515ed";
          hash = "sha256-c56N0E6NA3g58IRgnTtvGmpJ+uZemdmoIsQmPcvbrHY=";
        };
        setup = "require('lsp-file-operations').setup {}";
        after = ["nvimTree"];
      };
      #replacer-nvim = {
      #  package = pkgs.fetchFromGitHub {
      #    owner = "gabrielpoca";
      #    repo = "replacer.nvim";
      #    rev = "32e1713230844fa52f7f0598c59295de3c90dc95";
      #    hash = "sha256-pY0BiclthomTdgJeBFmeVStRFexgsA5V1MU+YGL0OmI=";
      #  };
      #  #setup = "require('replacer').setup {}";
      #};
      "plenary-nvim" = {
        #     Needed for lsp-file-operations
        package = pkgs.vimPlugins."plenary-nvim";
      };
    };

    #lazy.plugins = {
    #  lsp-file-operations = {
    #    pacakge = pkgs.vimPlugins.lsp-file-operations;
    #    setupOpts = {
    #      debug = false;
    #      operations = {
    #        willRenameFiles = true;
    #        didRenameFiles = true;
    #        willCreateFiles = true;
    #        didCreateFiles = true;
    #        willDeleteFiles = true;
    #        didDeleteFiles = true;
    #      };
    #      timeout_ms = 10000;
    #    };
    #  };
    #};

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
      enable = true;
      formatOnSave = false;
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
      #lspconfig.enable = true;
      lspkind.enable = true; # vscode-like pictograms for neovim lsp completion items
      lspsaga.enable = true; #
      trouble.enable = true;
      #servers.svelte.filetypes = [
      #  "*.svelte.ts"
      #  "*.svelte.js"
      #];
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
    formatter.conform-nvim.enable = true;

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
    autocomplete.nvim-cmp = {
      enable = true;
    };
    treesitter.fold = true;
    languages = {
      enableTreesitter = true;
      enableFormat = true;

      #graphql = {
      #  enable = true;
      #  treesitter.enable = true;
      #  format.enable = true;
      #};

      nix = {
        enable = true;
        format.enable = true;
        format.type = "alejandra";
        extraDiagnostics.enable = true;
        lsp.enable = true;
        treesitter.enable = true;
      };
      terraform.enable = true;
      bash = {
        extraDiagnostics.enable = true;
        enable = true;
        format.enable = true;
        treesitter.enable = true;
        lsp.enable = true;
      };
      markdown = {
        enable = true;
        format.enable = true;
      };

      lua.enable = true;
      python = {
        enable = true;
        format.enable = true;
        treesitter.enable = true;
        lsp.enable = true;
      };

      clang = {
        dap.debugger = "lldb-dap";
      };
      rust = {
        enable = true;
        format = {
          #package = lib.mkDefault pkgs.rustfmt;
          enable = true;
        };
        treesitter.enable = true;
        crates.enable = true;
        dap = {
          enable = true;
        };
        lsp = {
          enable =
            true;
          #package =
          #  lib.mkDefault pkgs.rust-analyzer;
          # opts = ''
          #   ['rust-analyzer'] = {
          #     cargo = {allFeature = true},
          #     checkOnSave = true,
          #     check = {
          #       command = "clippy",
          #       extraArgs = { "--no-deps" }
          #     },
          #     procMacro = {
          #       enable = true,
          #     },
          #   },
          # '';
        };
      };
      svelte = {
        extraDiagnostics.enable = true;
        enable = true;
        format.enable = true;
        treesitter.enable = true;
        lsp.enable = true;
      };
      ts = {
        enable = true;
        extraDiagnostics.enable = true;
        format.enable = true;
        treesitter = {
          enable = true;
          tsPackage = pkgs.vimPlugins.nvim-treesitter.builtGrammars.typescript;
        };
        extensions.ts-error-translator.enable = true;
        lsp.enable = true;
        #lsp.server = "denols";
      };
      css = {
        enable = true;
        format.enable = true;
        treesitter.enable = true;
        lsp.enable = true;
      };
      html = {
        enable = true;
        treesitter.enable = true;
        treesitter.autotagHtml = true;
      };
    };
    utility = {
      sleuth.enable = true;
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
      nvim-scrollbar.enable = true;
    };
    notify.nvim-notify.enable = true;
  };
}

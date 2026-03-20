{
  inputs ? {},
  pkgs,
  lib ? pkgs.lib,
  nixos-unstable,
  ...
}: let
  unstable = import nixos-unstable {
    system = "x86_64-linux";
    config = {
      allowUnfree = true;
    };
  };
  # === At the top of your let ... in block (replace your old spadeQueries + spadefmt) ===
  treeSitterSpade = unstable.tree-sitter.buildGrammar {
    language = "spade";
    version = "unstable-2026-03-19";
    src = pkgs.fetchFromGitLab {
      owner = "spade-lang";
      repo = "tree-sitter-spade";
      rev = "1016b4eafabaa75728569b1ba1bfbf8a849a4ec4";
      hash = "sha256-P0lQ2BjplAGQv/4Kn4xqyajYD8yrQpjPfgVVmassY4Y=";
    };
    # generate = true; # uncomment ONLY if build fails (needs tree-sitter CLI in buildInputs)
  };
  spadeParserNvim = pkgs.runCommand "tree-sitter-spade-nvim" {} ''
    mkdir -p $out/parser
    cp ${unstable.tree-sitter-grammars.tree-sitter-spade}/parser $out/parser/spade.so
  '';
  #hasUnstable = unstable != null;
  # spadefmt (community formatter, not yet in nixpkgs)
  #  spadeQueries = pkgs.fetchFromGitLab {
  #    owner = "spade-lang";
  #    repo = "tree-sitter-spade";
  #    rev = "1016b4eafabaa75728569b1ba1bfbf8a849a4ec4"; # pin to a commit hash ideally
  #    hash = "sha256-P0lQ2BjplAGQv/4Kn4xqyajYD8yrQpjPfgVVmassY4Y=";
  #  };
  spadefmt = pkgs.rustPlatform.buildRustPackage {
    pname = "spadefmt";
    version = "unstable-2026-03-19";

    src = pkgs.fetchFromGitHub {
      owner = "ethanuppal";
      repo = "spadefmt";
      rev = "2238c2562517f92ffee59668d212529f1b798f9b";
      hash = "sha256-s0AwhkwB2d2gGCOfC7LXrRFtxP6ivWT3bZ6tTg3SF9s=";
    };

    cargoHash = "sha256-v268aDcw5bmJFgNNLejTiFyk7Rnr7zdP2zXZlU6Vp1E=";
    meta.mainProgram = "spadefmt";
  };
  spadeVimPlugin = pkgs.vimUtils.buildVimPlugin {
    name = "spade-vim";
    doInstallCheck = false;
    src = pkgs.fetchFromGitLab {
      owner = "spade-lang";
      repo = "spade-vim";
      rev = "1016b4eafabaa75728569b1ba1bfbf8a849a4ec4";
      hash = "sha256-U4LrO89wHRPQXjILI+tttbWk23TDS2kVPaJbSS33Xvc=";
    };
  };
in {
  config.vim = {
    luaConfigRC = {
      format-command = ''
        vim.api.nvim_create_user_command("Format", function(args)
          local range = nil
          if args.count ~= -1 then
            local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
            range = {
              start = { args.line1, 0 },
              ["end"] = { args.line2, end_line:len() },
            }
          end
          require("conform").format({ async = true, lsp_format = "fallback", range = range })
        end, { range = true })
      '';
    };

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
      "spade-vim" = {
        package = spadeVimPlugin;
      };
      "lsp-file-operations" = {
        package = unstable.vimPlugins.nvim-lsp-file-operations;
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
      neo-tree = {
        enable = true;
        setupOpts = {
          enable_cursor_hijack = true;
          enable_diagnostics = true;
          enable_git_status = true;
          git_status_async = true;
          enable_modified_markers = true;
          enable_opened_markers = true;
          filesystem.hijack_netrw_behavior = "open_current";
          buffers = {
            follow_current_file = {
              enabled = true; #-- This will find and focus the file in the active buffer every time
              #--              -- the current file is changed while the tree is open.
              leave_dirs_open = false; #-- `false` closes auto expanded dirs, such as with `:Neotree reveal`
            };
          };
        };
      };
      # nvimTree = {
      #   enable = true;
      #   mappings = {
      #     toggle = "\\v";
      #   };
      #   setupOpts = {
      #     filesystem_watchers.debounce_delay = 350;
      #     view.debounce_delay = 350;
      #     diagnostics = {
      #       debounce_delay = 500;
      #       show_on_dirs = true;
      #       enable = true;
      #     };
      #     hijack_cursor = true;
      #     renderer = {
      #       indent_markers.enable = true;
      #     };
      #     tab.sync.close = true;
      #     update_focused_file.enable = true;
      #     view.centralize_selection = true;
      #   };
      # };
    };
    keymaps = [
      # LSP MAPPING START
      #{ NONE!
      #  key = "\\wa";
      #  mode = "n";
      #  silent = true;
      #  action = "<Cmd>Lspsaga <CR>";
      #}
      #{
      #  key = "gD";
      #  mode = "n";
      #  silent = true;
      #  action = "<Cmd>Lspsaga goto_definition<CR>";
      #}
      #{
      #  key = "gd";
      #  mode = "n";
      #  silent = true;
      #  action = "<Cmd>Lspsaga goto_type_definition<CR>";
      #}
      #{
      #  key = "K";
      #  mode = "n";
      #  silent = true;
      #  atction = "<Cmd>Lspsaga hover_doc<CR>";
      #}
      {
        key = "\\ca";
        mode = "n";
        silent = true;
        action = "<Cmd>Lspsaga code_action<CR>";
      }
      {
        key = "\\rn";
        mode = "n";
        silent = true;
        action = "<Cmd>Lspsaga rename<CR>";
      }

      # lsp unique to saga

      # LSP END
      {
        key = "<space>f";
        mode = "n";
        silent = true;
        action = "<Cmd>Format<CR>";
      }
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
        action = "<Cmd>vertical resize +1<CR>";
      }
      {
        key = "<A-Left>";
        mode = "n";
        silent = true;
        action = "<Cmd>vertical resize -1<CR>";
      }
      {
        key = "<A-Down>";
        mode = "n";
        silent = true;
        action = "<Cmd>resize +1<CR>";
      }
      {
        key = "<A-Up>";
        mode = "n";
        silent = true;
        action = "<Cmd>resize -1<CR>";
      }

      {
        key = "\\v";
        mode = "n";
        silent = true;
        action = "<Cmd>Neotree toggle<CR>";
      }
      {
        key = "\\x";
        mode = "n";
        silent = true;
        action = "<Cmd>Neotree reveal<CR>";
      }
      {
        key = "\\z";
        mode = "n";
        silent = true;
        action = "<Cmd>Neotree focus<CR>";
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
      null-ls.enable = false;
      mappings = {
        addWorkspaceFolder = "\\\\wa";
        # format disabled due to custom format command
        ##format = "<space>f";
        goToDeclaration = "gD";
        goToDefinition = "gd";
        goToType = "gt";
        hover = "K";
        listImplementations = "gi";
        listReferences = "gr";
        nextDiagnostic = "]d";
        previousDiagnostic = "[d";
        #codeAction = "\\\\ca";
        #renameSymbol = "\\\\rn";
      };
      #lspconfig.enable = true;

      lspkind.enable = true; # vscode-like pictograms for neovim lsp completion items
      lspsaga.enable = true; #
      trouble.enable = true;
      harper-ls.enable = true;
      servers.svelte.filetypes = [
        "svelte"
        #"javascript"
        #"typescript"
        "html"
      ];
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
    autocomplete.nvim-cmp = {
      enable = true;
    };
    treesitter = {
      enable = true;
      fold = true;
      #grammars = [treeSitterSpade]; # ← this was the missing piece
      #grammars = lib.optionals hasUnstable [unstable.tree-sitter-grammars.tree-sitter-spade];
      #grammars = [
      #  unstable.tree-sitter-grammars.tree-sitter-spade
      #  unstable.python313Packages.tree-sitter-grammars.tree-sitter-spade
      #];
    };
    # All Spade tools in PATH
    extraPackages = [unstable.spade unstable.swim spadefmt];

    # LSP (cleaned)
    lsp.servers.spade = {
      enable = true;
      cmd = [(lib.getExe' unstable.spade "spade-language-server")];
      filetypes = ["spade"];
      root_markers = ["swim.toml"];
    };

    formatter.conform-nvim = {
      enable = true;
      setupOpts = {
        format_on_save = {
          timeout_ms = 500;
          lsp_fallback = false;
        };
        formatters_by_ft = {
          javascript = ["prettierd" "prettier"];
          typescript = ["prettierd" "prettier"];
          json = ["prettierd" "prettier"];
          spade = ["spadefmt"];
        };
        formatters = {
          spadefmt = {
            command = lib.getExe spadefmt;
            stdin = false; # ← important: run on the actual file
            args = ["$FILENAME"]; # ← passes the file path (conform magic)
          };
        };
      };
    };

    luaConfigRC.spade-setup = ''
      vim.filetype.add({ extension = { spade = "spade" } })
      vim.treesitter.language.register("spade", "spade")
      vim.opt.rtp:prepend("${spadeParserNvim}")

      -- -- Exact registration from Spade docs + Nix store path
      -- local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      -- parser_config.spade = {
      --   install_info = {
      --     url = "${treeSitterSpade}",  -- this is the magic Nix store path
      --     files = { "src/parser.c" },
      --     branch = "main",
      --     generate_requires_npm = false,
      --     requires_generate_from_grammar = false,
      --   },
      --   filetype = "spade",
      -- }


    '';

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
        format.type = ["alejandra"];
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
        extensions = {
          crates-nvim.enable = true;
        };
        dap = {
          enable = true;
        };
        lsp = {
          enable =
            true;
          package = ["rust-analyzer"];
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

      # ============================= FRONTEND =============================
      svelte = {
        extraDiagnostics.enable = true;
        enable = true;
        format.enable = true;
        treesitter.enable = true;
        lsp.enable = true;
      };
      tailwind = {
        enable = true;
        lsp = {
          enable = true;
        };
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
    ui = {
      colorizer = {
        enable = true;
        setupOpts = {
          user_default_options = {
            tailwind = true;
          };
          filetypes = {
            svelte = {
              tailwind = true;
            };
            javascript = {
            };
            typescript = {
            };
            css = {
            };
          };
        };
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

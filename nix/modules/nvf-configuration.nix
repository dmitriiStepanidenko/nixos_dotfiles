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

    filetree = {
      nvimTree = {
        enable = true;
        #mappings
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
      {
        key = "\\v";
        mode = "n";
        silent = true;
        action = ":NvimTreeToggle<CR>";
      }
    ];

    searchCase = "ignore";

    lsp = {
      mappings = {
        addWorkspaceFolder = "\\\\wa";
        format = "<space>f";
        codeAction = "\\\\ca";
        goToDeclaration = "gD";
        goToDefinition = "gd";
        goToType = "gt";
        hover = "K";
        listImplementations = "gi";
        listReferences = "gr";
        nextDiagnostic = "]d";
        previousDiagnostic = "[d";
        renameSymbol = "\\\\rn";
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

      nix.enable = true;
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

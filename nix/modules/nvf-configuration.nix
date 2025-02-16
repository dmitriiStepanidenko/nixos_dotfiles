{
  pkgs,
  lib,
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
    ];

    statusline.lualine.enable = true;
    telescope.enable = true;
    autocomplete.nvim-cmp.enable = true;
    languages = {
      enableLSP = true;
      enableTreesitter = true;

      nix.enable = true;
      terraform.enable = true;

      ts.enable = true;
      lua.enable = true;
      python.enable = true;
      rust.enable = true;
    };
  };
}

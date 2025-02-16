{
  pkgs,
  lib,
  ...
}: {
  vim.theme.enable = true;
  vim.theme.name = "tokyonight";
  vim.theme.style = "dark";

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
}

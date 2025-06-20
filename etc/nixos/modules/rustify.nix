{pkgs, ...}: {
  security.sudo.enable = false;
  security.sudo-rs.enable = true;

  programs.bat = {
    enable = true;
    extraPackages = with pkgs.bat-extras; [
      batdiff
      batman
      prettybat
      core
    ];
  };
}

{pkgs, ...}: {
  security.sudo.enable = true;
  security.sudo-rs.enable = false;

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

{pkgs, ...}: {
  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    meslo-lg
    (nerdfonts.override {fonts = ["FiraCode" "DroidSansMono"];})
    #nerd-fonts.symbols-only
    #nerd-fonts.meslo-lg
    #nerd-fonts.hurmit
    #nerd-fonts.iosevka-term
    #nerd-fonts.monoid
    font-awesome
    freefont_ttf
    corefonts # Times New Roman
  ];

  environment.systemPackages = with pkgs; [
    papirus-icon-theme
    #nerdfonts
    #terminus-nerdfont
    #nerd-fonts.symbols-only
    #nerd-fonts.meslo-lg
  ];
}

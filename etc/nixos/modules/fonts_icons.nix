{pkgs, ...}: {
  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    meslo-lg
    nerd-fonts.droid-sans-mono
    #nerd-fonts.symbols-only
    #nerd-fonts.meslo-lg
    #nerd-fonts.hurmit
    #nerd-fonts.iosevka-term
    #nerd-fonts.monoid
    weather-icons
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

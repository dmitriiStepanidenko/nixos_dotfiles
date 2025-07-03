{
  lib,
  pkgs,
  configVars,
  ...
}: {
  environment.systemPackages = with pkgs; [
    yubioath-flutter # gui
    yubikey-manager # cli
    pam_u2f # for yubikey with sudo

    age-plugin-yubikey # sops age
  ];
  services = {
    pcscd.enable = true;
    udev.packages = [pkgs.yubikey-personalization];

    yubikey-agent.enable = true;
  };

  security.pam = lib.optionalAttrs pkgs.stdenv.isLinux {
    sshAgentAuth.enable = true;
    #u2f = {
    #  enable = true;
    #  settings = {
    #    cue = false; # Tells to press the button
    #    authFile = "/home/dmitrii/.config/Yubico/u2f_keys";
    #  };
    #};
    #services = {
    #  login.u2fAuth = true;
    #  sudo = {
    #    u2fAuth = true;
    #    sshAgentAuth = true;
    #  };
    #};
  };
}

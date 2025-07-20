{
  lib,
  pkgs,
  configVars,
  config,
  inputs,
  ...
}: {
  config = {
    environment.systemPackages = with pkgs; [
      yubioath-flutter # gui
      yubikey-manager # cli
      yubikey-personalization
      pam_u2f # for yubikey with sudo
      pcsc-tools # pcsc_scan

      age-plugin-yubikey # sops age
    ];
    #sops = {
    #  #age.keyFile = ../keys/users/age/age-yubikey-identity-default-c.txt;
    #};
    programs.gnupg = {
      package = inputs.nixos-unstable.legacyPackages.${pkgs.system}.gnupg1;
      agent = {
        enable = true;
        enableSSHSupport = true;
        settings = {
        };
      };
    };
    programs.ssh.startAgent = false;
    hardware.gpgSmartcards.enable = true;

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
    services = {
      pcscd.enable = true;
      udev.packages = [pkgs.yubikey-personalization];

      yubikey-agent.enable = true;
    };
    #sops.secrets.foo = {};
    #system.activationScripts.setupSecrets.deps = ["setupYubikeyForSopsNix"];

    #system.activationScripts.AsetupYubikeyForSopsNix.text = ''
    #  PATH=$PATH:${lib.makeBinPath [pkgs.age-plugin-yubikey]}
    #  ${pkgs.runtimeShell} -c "mkdir -p /var/lib/pcsc && ln -sfn ${pkgs.ccid}/pcsc/drivers /var/lib/pcsc/drivers"
    #  ${pkgs.toybox}/bin/pgrep pcscd > /dev/null && ${pkgs.toybox}/bin/pkill pcscd
    #  ${pkgs.pcsclite}/bin/pcscd
    #'';
  };
}

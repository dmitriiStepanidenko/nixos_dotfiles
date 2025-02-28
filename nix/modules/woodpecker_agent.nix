{
  pkgs,
  lib,
  config,
  modulesPath,
  ...
}: {
  #options.woodpecker_agent.package = lib.mkOption {
  #  type = lib.types.package;
  #  default = pkgs.woodpecker_agent;
  #};
  imports = [
    (modulesPath + "/services/continuous-integration/woodpecker/agents.nix")
  ];
  config = {
    environment.systemPackages = with pkgs; [
      woodpecker-agent
    ];
    sops = {
      secrets."woodpecker_agent" = {
        #inherit (config.users.users.docker) group;
        group = "docker";
        mode = "0440";
      };
    };
    virtualisation = {
      oci-containers.backend = "docker";
      docker = {
        enable = true;
        autoPrune.enable = true;
        daemon.settings = {
          insecure-registries = ["10.252.1.8:5000"];
        };
      };
    };
    #users.extraGroups.docker.members = [ "root" ];
    users.users.dmitrii.extraGroups = ["docker"];
    users.groups.docker = {};

    networking.firewall.allowedUDPPorts = [
      3000
    ];
    networking.firewall.allowedTCPPorts = [
      22
      3000
    ];

    programs.ssh.knownHosts = {
      "|1|fSa3G/n6S9KfE+XZ3shwrcc+vH4=|9scMFOG3R2diQTfAJh3VaaodRvY=".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDH3xMGe0qowxs4f35zmUJd9aGFmlZ2ro0gEy1LlTCy4ybDGhpQHuw1YgmBKETGhCB8H+KOpkW4MXjgfz0rRLHmXweUXyzgRCUjHve4BUrbJcud6ITS2q9z0DK4kr0/8XeFwJjYxtgeR4gDVNFqLi8yFZxvoWOxpfgDIbFAWiEjhHvlcKR/20SvKY70eyMIuyV8NvgBjW0Cxa4zHPlzg+rVWdgq7kBrtgRS6c/O+sY6AeK/x7fSxZ0WLRi+JZz6RIwrInH+TqzBzYxbmGZNXOLDCQ/MSIQUkfVjKZzbgnJDH6I5iuFPPGHD5AJZ/ADdl4CvKdxBo193MGLOaIA5H0BAiZGx0cUwJP1j+1HEvz0MrzOfVXiJvGNVqd1ydDAORlM6UsytrlXWEBgoR8LgH/54cTzq0xtF/G40cpVV0EWfi4y29pFstOUWHQ678WuCtJJx/QQUgHi6y0SNSFRcNmOLsdFzCDv+aJkk9qzi5mjPihq1AlGEn6ilh4KF8elBOXs=";
      "|1|cd7mBWQs38O8/i9mPT7TRQ7A/Zg=|0vGpSWiHVz9BGYtS60sIByiD4Z4=".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK+b4/9eJ+kPevej20vBM4ns5FGzSAulECmpNNcmEb2B";
    };
  };
  config.services.woodpecker-agents.agents.woodpecker-agent = {
    enable = true;
    inherit (config.woodpecker_agent) package;
    environmentFile = [config.sops.secrets."woodpecker_agent".path];
    #extraGroups = [config.users.users.docker.group];
    extraGroups = ["docker"];
    path = [
      pkgs.bash
      pkgs.git
      pkgs.docker
      pkgs.openssh
      pkgs.nix
      pkgs.curl
      pkgs.gnutar
      pkgs.gzip
                        #pkgs.toybox # tar
    ];
  };
}

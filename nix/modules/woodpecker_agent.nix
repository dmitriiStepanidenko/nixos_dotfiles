{
  pkgs,
  lib,
  inputs,
  config,
  system,
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
      eza
    ];
    sops = {
      secrets."woodpecker_agent_local" = {
        #inherit (config.users.users.docker) group;
        restartUnits = ["woodpecker-agent-local.service"];
        group = "docker";
        mode = "0440";
      };
      secrets."woodpecker_agent_docker" = {
        #inherit (config.users.users.docker) group;
        restartUnits = ["woodpecker-agent-docker.service"];
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
    networking.firewall = {
      allowedUDPPorts = [
        3000
        3001
      ];
      allowedTCPPorts = [
        22
        3000
        3001
      ];
      interfaces.wg0 = {
        allowedUDPPorts = [
          3000
          3001
        ];
        allowedTCPPorts = [
          3000
          3001
        ];
      };
    };
    programs.ssh.knownHosts = {
      "|1|fSa3G/n6S9KfE+XZ3shwrcc+vH4=|9scMFOG3R2diQTfAJh3VaaodRvY=".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDH3xMGe0qowxs4f35zmUJd9aGFmlZ2ro0gEy1LlTCy4ybDGhpQHuw1YgmBKETGhCB8H+KOpkW4MXjgfz0rRLHmXweUXyzgRCUjHve4BUrbJcud6ITS2q9z0DK4kr0/8XeFwJjYxtgeR4gDVNFqLi8yFZxvoWOxpfgDIbFAWiEjhHvlcKR/20SvKY70eyMIuyV8NvgBjW0Cxa4zHPlzg+rVWdgq7kBrtgRS6c/O+sY6AeK/x7fSxZ0WLRi+JZz6RIwrInH+TqzBzYxbmGZNXOLDCQ/MSIQUkfVjKZzbgnJDH6I5iuFPPGHD5AJZ/ADdl4CvKdxBo193MGLOaIA5H0BAiZGx0cUwJP1j+1HEvz0MrzOfVXiJvGNVqd1ydDAORlM6UsytrlXWEBgoR8LgH/54cTzq0xtF/G40cpVV0EWfi4y29pFstOUWHQ678WuCtJJx/QQUgHi6y0SNSFRcNmOLsdFzCDv+aJkk9qzi5mjPihq1AlGEn6ilh4KF8elBOXs=";
      "|1|cd7mBWQs38O8/i9mPT7TRQ7A/Zg=|0vGpSWiHVz9BGYtS60sIByiD4Z4=".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK+b4/9eJ+kPevej20vBM4ns5FGzSAulECmpNNcmEb2B";

      "|1|a0cQ1Kgz85EuF0vd/MD9zNrjmrc=|zTRGVsvBt6hiFEc/R4WXHE4y+Oo=".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCiMy6RcI4bPA06yjOZcW2+ULNC25DvYFI7PBIxdAqD9g3VgYXdLHsI+dKJKJMhC7PIXQ9Rl8yyVPFGBJqRP4Nh2OyA20grnf2dzGxPQ5P53WX5vkxjULhr4DXZZbUATBCA0edlw0hHDurRpedkPeWHleW0QweHzkODbN9oJ69901bq/4X+x6lBQsSlFfJJe2Y7+uNUbDy60WriByT9N2OGavxMdfUX4teVpwYBLR3QnXrffTqH4QT/vxPeQPfsLJtBVKKpcCFjv6hYd3Ure1we5mmRV+XgO28P30iTTtJuoKcloOI2bnoeLAGN/IwrToOow0GXCnzUr8Rs7T2XAi8kKMkAjy3My0zk8mxVWKXYOe+FC2/9pxxggwce20YoFJVFdA6zaSNVNuo3IR9HyTj9PFq+hKmGdqe2gcLe7oMtgtz32YIGw84Mv2uIdK6xFIvO1wfAZCfU/t5UcxzqOX1Y4cbR8ggitipV6Xbtl2Yi7e3xKpMwFimHqUFyRGYpxI0=";
      "|1|dPXZQAbzb6tjmQBYcUsHa/4BNOw=|01L9s5ZON51QRzDXxqTvabGn9I8=".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILfxO4/rs/m27OGWxo4eZDvrDhA6IWPm0DfQGpauD0D/";
    };
    programs.ssh.startAgent = true;
  };
  config.services.woodpecker-agents.agents.local = {
    enable = true;
    environmentFile = [config.sops.secrets."woodpecker_agent_local".path];
    #extraGroups = [config.users.users.docker.group];
    #package = pkgs.callPackage ../packages/woodpecker-agent.nix {};
    package =
      inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.woodpecker-agent;
    extraGroups = ["docker" "trusted"];
    path = [
      pkgs.bash
      pkgs.git
      pkgs.git-lfs
      pkgs.docker
      pkgs.openssh # sftp + ssh clone
      pkgs.nix
      pkgs.curl
      pkgs.gnutar
      pkgs.gzip
      pkgs.zip
      pkgs.cargo-binstall
      pkgs.sd
      pkgs.alejandra
      pkgs.attic-client
      pkgs.eza
      pkgs.rsync
      pkgs.gnugrep
      inputs.sccache.packages.${system}.sccache
    ];
  };
  config.services.woodpecker-agents.agents.docker = {
    enable = true;
    environmentFile = [config.sops.secrets."woodpecker_agent_docker".path];
    #extraGroups = [config.users.users.docker.group];
    #package = pkgs.callPackage ../packages/woodpecker-agent.nix {};
    package = inputs.nixpkgs-master.legacyPackages.${system}.woodpecker-agent;
    extraGroups = ["docker"];
  };
}

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
  };
  config.services.woodpecker-agents.agents.woodpecker-agent = {
    enable = true;
    inherit (config.woodpecker_agent) package;
    environmentFile = [config.sops.secrets."woodpecker_agent".path];
    #extraGroups = [config.users.users.docker.group];
    extraGroups = ["docker"];

    #package = pkgs.gitea-actions-runner;
    #instances.action-runner-1 = {
    #  enable = true;
    #  name = "action_runner_1";
    #  tokenFile = config.sops.secrets."action_runner/token".path;
    #  url = "http://10.252.1.0:3000";
    #  labels = [
    #    "ubuntu-latest"
    #    "ubuntu-22.04"
    #    "ubuntu-20.04"
    #    "ubuntu-18.04"
    #  ];
    #};
  };
}

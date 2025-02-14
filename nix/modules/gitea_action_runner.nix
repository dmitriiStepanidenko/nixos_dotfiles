{
  pkgs,
  config,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/services/continuous-integration/gitea-actions-runner.nix")
  ];
  config = {
    environment.systemPackages = with pkgs; [
      gitea-actions-runner
    ];
    sops = {
      secrets."action_runner/token" = {
      };
    };
  };

  config.services.gitea-actions-runner = {
    package = pkgs.gitea-actions-runner;
    instances.action-runner-1 = {
      enable = true;
      name = "action_runner_1";
      tokenFile = config.sops.secrets."action_runner/token".path;
      url = "http://10.252.1.0:3000";
      labels = [
        "ubuntu-latest" 
        "ubuntu-22.04" 
        "ubuntu-20.04" 
        "ubuntu-18.04"
      ];
    };
  };
}

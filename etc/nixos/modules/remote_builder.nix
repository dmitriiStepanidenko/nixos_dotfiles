{pkgs, ...}: {
  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true; # Server can fetch its own substitutes (faster if it has better internet)

  nix.buildMachines = [
    {
      hostName = "192.168.0.192";
      #hostName = "10.252.1.22";
      sshUser = "nixremote";
      sshKey = "/root/.ssh/nix-remote-builder";
      system = "x86_64-linux"; # Or whatever your server uses (e.g. aarch64-linux)
      protocol = "ssh-ng"; # Modern Nix-over-SSH (faster transfers)
      supportedFeatures = ["nixos-test" "big-parallel" "kvm"];
      #maxJobs = 4;              # Adjust to your server's cores (or leave out for auto)
      speedFactor = 2; # Higher = prefer this builder (optional)
    }
  ];
}

{
  config,
  pkgs,
  modulesPath,
  lib,
  system,
  ...
}: {
  config = {
    #Provide a default hostname
    networking.hostName = "vpn";
  };
  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";
    age = {
      #keyFilePaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };
  };
}

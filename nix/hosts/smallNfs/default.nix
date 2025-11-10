{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  #dataDir = "/data/webserver/root";
  mountDir = "/mnt/small";
  dataDir = "/export/small";
  dataDirSubfolder = "/export/small/squirrels_remote";
in {
  config = {
    hardware.usbStorage.manageShutdown = true;
    users.users.moonfire = {
      createHome = false;
      isNormalUser = true;
      uid = 1001;
      group = "remote";
    };
    users.groups.remote = {
      gid = 1002;
    };
    services = {
      smartd.enable = false;
      alloy = {
        enable = false;
      };
      prometheus = {
        exporters = {
          node = {
            enable = false;
          };
        };
      };
      nfs.server = {
        enable = true;
        exports = ''
          ${dataDir}   192.168.0.200(rw,fsid=0,no_subtree_check,no_root_squash,anonuid=1001,anongid=1002) 192.168.0.145(rw,fsid=0,no_subtree_check,no_root_squash,anonuid=1001,anongid=1002)
        '';
        lockdPort = 4001;
        mountdPort = 4002;
        statdPort = 4000;
        #extraNfsdConfig = '''';
      };
    };
    environment.systemPackages = with pkgs; [ntfs3g smartmontools du-dust];
    fileSystems = {
      "${mountDir}" = {
        fsType = "ntfs-3g";
        device = "/dev/disk/by-uuid/968E1D048E1CDE95";
        options = [
          "rw"
          "uid=1001"
          "gid=1002"
          "dmask=0002"
          "fmask=0002"
          "nofail"
          "norecover"
          "big_writes"
          "windows_names"
        ];
      };
      "${dataDir}" = {
        device = "${mountDir}";
        options = ["bind"];
      };
    };
    boot.supportedFilesystems = ["ntfs"];
    networking = {
      hostName = "smallNfs";
      firewall = {
        #interfaces.wg0 = {
        #  allowedTCPPorts = [80 22 8080 2222];
        #  allowedUDPPorts = [80 22 8080 2222];
        #};
        allowedTCPPorts = [22 2049];
        allowedUDPPorts = [22 2049];
        enable = true;
      };
    };
    #sops = {
    #  defaultSopsFile = ./secrets.yaml;
    #  defaultSopsFormat = "yaml";
    #  age = {
    #    sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    #    keyFile = "/var/lib/sops-nix/key.txt";
    #    generateKey = true;
    #  };
    #};
  };
}

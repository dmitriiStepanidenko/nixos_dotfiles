{
  pkgs,
  config,
  ...
}: let
in {
  boot.kernelModules = ["wireguard"];

  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];
  networking.firewall.allowedUDPPorts = [51820];
  #networking.useNetworkd = true;

  #systemd.network = {
  #  enable = true;
  #  netdevs = {
  #    "wg0" = {
  #      netdevConfig = {
  #        Kind = "wireguard";
  #        Name = "wg0";
  #      };
  #    };
  #  };
  #  networks.wg0 = {
  #    matchConfig.Name = "wg0";
  #    address = ["10.252.1.1/32"];
  #    networkConfig = {
  #      IPMasquerade = "ipv4";
  #      IPv4Forwarding = true;
  #    };
  #  };
  #};

  systemd.services."wireguard-setup" = {
    description = "Setup WireGuard with secrets";
    wantedBy = ["multi-user.target"];
    after = ["network-online.target" "nss-lookup.target"]; #"sops-nix.service"];
    wants = ["network-online.target" "nss-lookup.target"]; #"sops-nix.service"];
    path = with pkgs; [kmod iproute2 wireguard-tools];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = config.users.users.root.name;
      NetworkInterface = "wg0";
    };

    script = ''
      # Check if the wg0 interface exists
      if ip link show wg0 &> /dev/null; then
          echo "wg0 interface exists. Deleting it..."
          sudo ip link delete wg0
          echo "wg0 interface deleted."
      else
          echo "wg0 interface does not exist."
      fi


      ip link add dev wg0 type wireguard
      ip address add dev wg0 10.252.1.1/24
      if ! ip link show wg0 > /dev/null 2>&1; then
        echo "WireGuard interface wg0 does not exist"
        exit 1
      fi
      ${pkgs.wireguard-tools}/bin/wg set wg0 \
        private-key ${config.sops.secrets."wireguard/private_key".path} \
        peer "grqz6c5gF9BUrm3pMVukCT1BN1MGt7pnI6xZOT0dUQ4=" \
        preshared-key ${config.sops.secrets."wireguard/preshared_key".path} \
        allowed-ips 10.252.1.0/24 \
        persistent-keepalive 7 \
        endpoint $(cat ${config.sops.secrets."wireguard/wireguard_ip".path}):51820
      ip link set up dev wg0
    '';
  };
  #networking.interfaces."wg0" = {
  #  useDHCP = false;
  #  ipv4.addresses = [
  #    {
  #      address = "10.252.1.1";
  #      prefixLength = 24;
  #    }
  #  ];
  #};

  # Базовая настройка сетевого интерфейса WireGuard
  #networking.wireguard.interfaces = {
  #  wg0 = {
  #    privateKeyFile = config.sops.secrets."wireguard/private_key".path;
  #  };
  #};

  #networking.wg-quick.interfaces = let
  #  server_ip = "176.123.169.17";
  #  publicKey = "grqz6c5gF9BUrm3pMVukCT1BN1MGt7pnI6xZOT0dUQ4=";
  #in {
  #  wg0 = {
  #    # IP address of this machine in the *tunnel network*
  #    address = [
  #      "10.252.1.1/32"
  #    ];

  #    # To match firewall allowedUDPPorts (without this wg
  #    # uses random port numbers).
  #    listenPort = 51820;

  #    # Path to the private key file.
  #    privateKeyFile = "/root/wireguard-keys/private.key";
  #    # this is what we use instead of persistentKeepalive, the resulting PostUp
  #    # script looks something like the following:
  #    #     wg set wg0 private-key <(cat /path/to/keyfile)
  #    #     wg set wg0 peer <public key> persistent-keepalive 25
  #    #postUp = ["wg set wgnet0 peer ${publicKey} persistent-keepalive 7"];

  #    peers = [
  #      {
  #        #publicKey = "grqz6c5gF9BUrm3pMVukCT1BN1MGt7pnI6xZOT0dUQ4=";
  #        inherit publicKey;
  #        presharedKeyFile = "/root/wireguard-keys/preshared.key";
  #        allowedIPs = ["10.252.1.0/24"];
  #        endpoint = "${server_ip}:51820";
  #        persistentKeepalive = 7;
  #      }
  #    ];
  #  };
  #};
  #networking.networkmanager.dns = "systemd-resolved";
  #services.resolved.enable = true;
}

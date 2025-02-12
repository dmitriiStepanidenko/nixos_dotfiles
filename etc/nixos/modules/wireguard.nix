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
  systemd.network.wait-online.ignoredInterfaces = ["wg0"];
}

{
  server_ip,
  publicKey,
  privateKeyFile,
  ...
}: {
  networking.wg-quick.interfaces = {
    wg0 = {
      # IP address of this machine in the *tunnel network*
      address = [
        "10.252.1.1/32"
      ];

      # To match firewall allowedUDPPorts (without this wg
      # uses random port numbers).
      listenPort = 51820;

      # Path to the private key file.
      inherit privateKeyFile;
      # this is what we use instead of persistentKeepalive, the resulting PostUp
      # script looks something like the following:
      #     wg set wg0 private-key <(cat /path/to/keyfile)
      #     wg set wg0 peer <public key> persistent-keepalive 25
      #postUp = ["wg set wgnet0 peer ${publicKey} persistent-keepalive 7"];

      peers = [
        {
          #publicKey = "grqz6c5gF9BUrm3pMVukCT1BN1MGt7pnI6xZOT0dUQ4=";
          inherit publicKey;
          presharedKeyFile = "/root/wireguard-keys/preshared.key";
          allowedIPs = ["10.252.1.0/24"];
          endpoint = "${server_ip}:51820";
          persistentKeepalive = 7;
        }
      ];
    };
  };
  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;
}

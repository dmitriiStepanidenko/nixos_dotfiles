{...}: {
  networking.wg-quick.interfaces = let
    server_ip = "176.123.169.17";
  in {
    wg0 = {
      # IP address of this machine in the *tunnel network*
      address = [
        "10.252.1.1/32"
      ];

      # To match firewall allowedUDPPorts (without this wg
      # uses random port numbers).
      listenPort = 51820;

      # Path to the private key file.
      privateKeyFile = "/root/wireguard-keys/private.key";

      peers = [
        {
          publicKey = "grqz6c5gF9BUrm3pMVukCT1BN1MGt7pnI6xZOT0dUQ4=";
          presharedKeyFile = "/root/wireguard-keys/preshared.key";
          allowedIPs = ["10.252.1.0/24"];
          endpoint = "${server_ip}:51820";
          persistentKeepalive = 15;
        }
      ];
    };
  };
}

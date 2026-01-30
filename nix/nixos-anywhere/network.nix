{ config, pkgs, ... }:

{
  # Disable automatic network configuration
  networking = {
    # Disable NetworkManager
    networkmanager.enable = false;
    
    # Disable systemd-networkd
    useNetworkd = false;
    
    # Disable DHCP globally
    useDHCP = false;
    
    # Configure the specific interface
    interfaces.ens3 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "x";
          prefixLength = 32;
        }
      ];
      ipv6.addresses = [
        {
          address = "y";
          prefixLength = 64;
        }
      ];
      # Set MAC address
      macAddress = "z";
    };
    
    # Set default gateway
    defaultGateway = {
      address = "10.0.0.1";
      interface = "ens3";
    };
    
    # DNS configuration
    nameservers = [ "8.8.8.8" "1.1.1.1" ];
    
    # Add static route to gateway (needed for /32 networks)
    localCommands = ''
      ${pkgs.iproute2}/bin/ip route add 10.0.0.1/32 dev ens3 || true
    '';
  };
  
  # Alternative approach using systemd-networkd (comment out the above networking block to use this)
  # systemd.network = {
  #   enable = true;
  #   networks."10-ens3" = {
  #     matchConfig.Name = "ens3";
  #     networkConfig = {
  #       DHCP = "no";
  #       Gateway = "10.0.0.1";
  #       DNS = [ "8.8.8.8" "1.1.1.1" ];
  #     };
  #     address = [ "176.123.169.226/32" ];
  #     routes = [
  #       { routeConfig.Destination = "10.0.0.1/32"; }
  #     ];
  #   };
  # };
  
  # Ensure the interface comes up properly
  systemd.services.network-addresses-ens3.after = [ "network-pre.target" ];
}

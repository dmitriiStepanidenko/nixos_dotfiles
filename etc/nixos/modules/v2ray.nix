{
  config,
  pkgs,
  sops,
  ...
}: {
  environment.systemPackages = with pkgs; [
    v2ray
    v2rayn
    xray
    sing-box
  ];
  #services.v2ray.enable = true;
}

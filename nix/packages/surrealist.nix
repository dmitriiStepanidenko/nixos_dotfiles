{
  appimageTools,
  fetchurl,
}: let
  pname = "surrealist";
  version = "3.5.2";

  src = fetchurl {
    url = "https://github.com/surrealdb/surrealist/releases/download/surrealist-v${version}/Surrealist_${version}_amd64.AppImage";
    hash = "sha256-q+ZIXksFNqU5N9bqzwQ58VgqAXnbnpL5/3z0Z6kyjE8=";
  };
in
  appimageTools.wrapType2 {
    inherit pname version src;
    extraPkgs = pkgs:
      with pkgs; [
        # OpenGL libraries
        libGL
        libGLU
        libglvnd
        mesa
        mesa.drivers

        # EGL/Wayland support
        wayland
        libxkbcommon

        # X11 libraries
        xorg.libX11
        xorg.libXext
        xorg.libXrender
        xorg.libXrandr
        xorg.libXinerama
        xorg.libXcursor
        xorg.libXi
        xorg.libXxf86vm
        xorg.libXfixes
        xorg.libXcomposite
        xorg.libXdamage

        # Additional graphics support
        vulkan-loader
        dbus
      ];
  }

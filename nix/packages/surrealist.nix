{
  appimageTools,
  fetchurl,
  glib-networking,
}: let
  pname = "surrealist";
  #version = "3.5.2";
  version = "3.2.4";

  src = fetchurl {
    url = "https://github.com/surrealdb/surrealist/releases/download/surrealist-v${version}/Surrealist_${version}_amd64.AppImage";
    #hash = "sha256-q+ZIXksFNqU5N9bqzwQ58VgqAXnbnpL5/3z0Z6kyjE8=";
    hash = "sha256-Yp74swJ7rOBubcChGh4ctabRtJdsYNCzS3Fmk5w9nUs=";
  };
in
  appimageTools.wrapType2 {
    inherit pname version src;
    extraPkgs = pkgs:
      with pkgs; [
        cairo
        gdk-pixbuf
        libsoup_3
        openssl
        pango
        webkitgtk_4_1

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

    postFixup = ''
      wrapProgram $out/bin/${pname} \
        --set GIO_EXTRA_MODULES ${glib-networking}/lib/gio/modules \
        --set WEBKIT_DISABLE_COMPOSITING_MODE 1 \
        --set MESA_GL_VERSION_OVERRIDE 3.3 \
        --set MESA_GLSL_VERSION_OVERRIDE 330
    '';
  }

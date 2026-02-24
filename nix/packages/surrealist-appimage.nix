{
  lib,
  appimageTools,
  fetchurl,
}: let
  version = "3.7.2";
  pname = "surrealist";

  src = fetchurl {
    #      https://github.com/surrealdb/surrealist/releases/download/surrealist-v3.7.2/Surrealist_3.7.2_amd64.AppImage
    url = "https://github.com/surrealdb/surrealist/releases/download/surrealist-v${version}/Surrealist_${version}_amd64.AppImage";
    hash = "sha256-Dahlt+NBmmn7hemaeyKRoDUlDU4Uo1pKm6VLTERqIKc=";
    #hash = lib.fakeHash;
  };
in
  appimageTools.wrapType2 {
    inherit pname version src;

    env = {
      OPENSSL_NO_VENDOR = 1;
    };

    extraPkgs = pkgs:
      with pkgs; [
        at-spi2-atk
        atkmm
        cairo
        gdk-pixbuf
        glib
        gtk3
        harfbuzz
        librsvg
        libsoup_3
        pango
        webkitgtk_4_1
        openssl
      ];
    #extraInstallCommands = pkgs: ''
    #  mkdir -p $out/bin
    #  mv $out/bin/${pname} $out/bin/.${pname}-wrapped
    #  cat > $out/bin/${pname} <<EOF
    #  #!${pkgs.runtimeShell}
    #  exec "$out/bin/.${pname}-wrapped" --disable-gpu "\$@"
    #  EOF
    #  chmod +x $out/bin/${pname}
    #'';
  }

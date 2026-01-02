{
  lib,
  stdenvNoCC,
  fetchurl,
  copyDesktopItems,
  makeDesktopItem,
  makeBinaryWrapper,
  wine64,
  requireFile
}: let
  # The icon is also from the winbox AUR package (see above).
  #icon = fetchurl {
  #  name = "winbox.png";
  #  url = "https://aur.archlinux.org/cgit/aur.git/plain/winbox.png?h=winbox";
  #  hash = "sha256-YD6u2N+1thRnEsXO6AHm138fRda9XEtUX5+EGTg004A=";
  #};
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "ivms-4200";
    version = "3.13.2.5";

    src = requireFile rec {
    name = "iVMS-4200V3.13.2.5_E.exe";
    hash = "sha256-iWqxSlCT6tzEnIZVW6ZIDUoWjzj4vQ9YV3r5jbKGdj0=";
    message = ''
      In order to install the ivms-4200 drivers, you must first
      comply with DisplayLink's EULA and download the binaries and
      sources from here:

      https://www.hikvision.com/en/support/download/software/ivms4200-series/



      nix hash to-sri --type sha256 $(nix-prefetch-url --type sha256 file:///home/dmitrii/Downloads/iVMS-4200V3.13.2.5_E.exe)


      Once you have downloaded the file, please use the following
      commands and re-run the installation:

      mv \$PWD/"DisplayLink USB Graphics Software for Ubuntu6.2-EXE.zip" \$PWD/${name}
      nix-prefetch-url file://\$PWD/${name}

      Alternatively, you can use the following command to download the
      file directly:

      nix-prefetch-url --name ${name} https://www.synaptics.com/sites/default/files/exe_files/2025-09/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu6.2-EXE.zip
    '';
  };


    #src = fetchurl (
    #  if (wine.meta.mainProgram == "wine64")
    #  then {
    #    url = "https://www.hikvision.com/content/dam/hikvision/en/support/download/vms/ivms4200-series/software-download/v3-13-2-5/iVMS-4200V3.13.2.5_E.exe";
    #    # https://www.hikvision.com/content/dam/hikvision/en/support/download/vms/ivms4200-series/software-download/v3-13-2-5/iVMS-4200V3.13.2.5_E.exe
    #    hash = "";
    #  }
    #  else {
    #    url = "https://www.hikvision.com/content/dam/hikvision/en/support/download/vms/ivms4200-series/software-download/v3-13-2-5/iVMS-4200V3.13.2.5_E.exe";
    #    hash = "";
    #  }
    #);

    dontUnpack = true;

    nativeBuildInputs = [
      makeBinaryWrapper
      copyDesktopItems
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/{bin,libexec,share/pixmaps}

      #ln -s "$${icon}" "$out/share/pixmaps/winbox.png"

      makeWrapper ${lib.getExe wine64} $out/bin/ivms-4200 \
        --add-flags $src

      runHook postInstall
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "ivms";
        desktopName = "Ivms";
        comment = "ivms-4200 HikVision";
        exec = "ivms";
        #icon = "winbox";
        categories = ["Utility"];
      })
    ];

    meta = {
      description = "ivms";
      #homepage = "https://mikrotik.com";
      #downloadPage = "https://mikrotik.com/download";
      #changelog = "https://wiki.mikrotik.com/wiki/Winbox_changelog";
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      license = lib.licenses.unfree;
      mainProgram = "ivms-4200";
      maintainers = with lib.maintainers; [yrd];
    };
  })

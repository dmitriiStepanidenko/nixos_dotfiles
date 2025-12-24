{
  lib,
  stdenvNoCC,
  fetchurl,
  copyDesktopItems,
  makeDesktopItem,
  makeBinaryWrapper,
  wine,
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

    src = fetchurl (
      if (wine.meta.mainProgram == "wine64")
      then {
        url = "https://www.hikvision.com/content/dam/hikvision/en/support/download/vms/ivms4200-series/software-download/v3-13-2-5/iVMS-4200V3.13.2.5_E.exe";
        # https://www.hikvision.com/content/dam/hikvision/en/support/download/vms/ivms4200-series/software-download/v3-13-2-5/iVMS-4200V3.13.2.5_E.exe
        hash = "";
      }
      else {
        url = "https://www.hikvision.com/content/dam/hikvision/en/support/download/vms/ivms4200-series/software-download/v3-13-2-5/iVMS-4200V3.13.2.5_E.exe";
        hash = "";
      }
    );

    dontUnpack = true;

    nativeBuildInputs = [
      makeBinaryWrapper
      copyDesktopItems
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/{bin,libexec,share/pixmaps}

      #ln -s "$${icon}" "$out/share/pixmaps/winbox.png"

      makeWrapper ${lib.getExe wine} $out/bin/winbox \
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
      mainProgram = "winbox";
      maintainers = with lib.maintainers; [yrd];
    };
  })

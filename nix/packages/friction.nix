{
  lib,
  appimageTools,
  fetchurl,
}: let
  version = "1.0.0-rc.3";
  pname = "friction";

  src = fetchurl {
    url = "https://github.com/friction2d/friction/releases/download/v${version}/Friction-${version}-x86_64.AppImage";
    hash = "sha256-MV+JoAtYG+06P1SDl4GarjxqevKNf5ycyiFb5LCYGss=";
    #hash = lib.fakeHash;
  };

  appimageContents = appimageTools.extractType1 {inherit pname version src;};
in
  appimageTools.wrapType2 {inherit pname version src;}
#appimageTools.wrapType2 rec {
#  inherit pname version src;
#
#  extraInstallCommands = ''
#    substituteInPlace $out/share/applications/${pname}.desktop \
#      --replace-fail 'Exec=AppRun' 'Exec=${meta.mainProgram}'
#  '';
#
#  meta = {
#    description = "Friction";
#      #homepage = "https://github.com/ZUGFeRD/quba-viewer";
#      #downloadPage = "https://github.com/ZUGFeRD/quba-viewer/releases";
#    license = lib.licenses.asl20;
#    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
#      #maintainers = with lib.maintainers; [ onny ];
#    platforms = [ "x86_64-linux" ];
#  };
#}


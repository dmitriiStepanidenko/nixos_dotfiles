{
  stdenvNoCC,
  fetchzip,
  gcc-unwrapped,
  glibc,
  autoPatchelfHook,
  lib,
  libxkbcommon,
  pipewire,
  pkg-config,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "cosmic-ext-applet-privacy-indicator";
  version = "0.1.2";

  src = fetchzip {
    url = "https://github.com/D-Brox/cosmic-ext-applet-privacy-indicator/releases/download/v${version}/cosmic-ext-applet-privacy-indicator-x86_64.tar.gz";
    hash = "sha256-sD7lhUMeQylZ78sa9DHL1KafDVziVJxiGn2N7K42Fuk=";
    inherit pname version;
  };
  #dontBuild = true;
  #dontConfigure = true;

  nativeBuildInputs = [
    glibc
    autoPatchelfHook
    libxkbcommon
    pipewire
    #pkg-config
    #rustPlatform.bindgenHook
    #wayland
  ];
  buildInputs = [
    gcc-unwrapped
  ];

  installPhase = ''
    runHook preInstall
    ls
    pwd
    mkdir -p $out/bin
    mkdir -p $out/share/applications
    mkdir -p $out/share/metainfo

    install -m755 cosmic-ext-applet-privacy-indicator/cosmic-ext-applet-privacy-indicator $out/bin
    cp cosmic-ext-applet-privacy-indicator/dev.DBrox.CosmicPrivacyIndicator.desktop $out/share/applications/CosmicPrivacyIndicator.desktop
    cp cosmic-ext-applet-privacy-indicator/dev.DBrox.CosmicPrivacyIndicator.metainfo.xml $out/share/metainfo/CosmicPrivacyIndicator.metainfo.xml
    runHook postInstall
  '';
  meta = {
    description = " Privacy indicator for the COSMIC DE";
    homepage = "https://github.com/D-Brox/cosmic-ext-applet-privacy-indicator";
    license = lib.licenses.gpl3;
  };
}

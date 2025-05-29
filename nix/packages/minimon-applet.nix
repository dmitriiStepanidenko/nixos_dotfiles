{
  stdenvNoCC,
  stdenv,
  fetchzip,
  gcc-unwrapped,
  glibc,
  autoPatchelfHook,
  lib,
  libxkbcommon,
  pipewire,
  wayland,
  libGL,
  pkg-config,
  makeWrapper,
  ...
}: let
  libPath = lib.makeLibraryPath [
    libGL
    libxkbcommon
    wayland
    pipewire
  ];
in
  stdenv.mkDerivation rec {
    pname = "minimon-applet";
    version = "0.5.2";

    src = fetchzip {
      url = "";
      hash = "";
      inherit pname version;
    };
    #dontBuild = true;
    #dontConfigure = true;

    nativeBuildInputs = [
      glibc
      autoPatchelfHook
      libxkbcommon
      pipewire
      wayland
      pkg-config
      makeWrapper
      #rustPlatform.bindgenHook
      #wayland
    ];
    buildInputs = [
      gcc-unwrapped
      wayland
      pipewire
      pkg-config
      makeWrapper
    ];
    propagatedBuildInputs = [
      pkg-config
      libGL
      pipewire
      libxkbcommon
      wayland
    ];
    #dontPatchELF = true;

    installPhase = ''
      runHook preInstall
      ls
      pwd
      mkdir -p $out/bin
      mkdir -p $out/share/applications
      mkdir -p $out/share/metainfo

      install -m755 cosmic-ext-applet-privacy-indicator/cosmic-ext-applet-privacy-indicator $out/bin
      cp cosmic-ext-applet-privacy-indicator/dev.DBrox.CosmicPrivacyIndicator.desktop $out/share/applications/CosmicPrivacyIndicator.desktop
      cp cosmic-ext-applet-privacy-indicator/dev.DBrox.CosmicPrivacyIndicator.metainfo.xml $out/share/applications/CosmicPrivacyIndicator.metainfo.xml

      wrapProgram $out/bin/cosmic-ext-applet-privacy-indicator \
        --prefix LD_LIBRARY_PATH : ${libPath}


      runHook postInstall
    '';
    shellHook = ''
      export LD_LIBRARY_PATH=${libPath}
    '';
    meta = {
      description = " Privacy indicator for the COSMIC DE";
      homepage = "https://github.com/D-Brox/cosmic-ext-applet-privacy-indicator";
      license = lib.licenses.gpl3;
    };
  }

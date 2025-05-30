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
    pname = "cosmic-ext-applet-system-monitor";
    version = "0.2.4";

    src = fetchzip {
      url = "https://github.com/D-Brox/cosmic-ext-applet-system-monitor/releases/download/v${version}/cosmic-ext-applet-system-monitor-x86_64.tar.gz";
      hash = "sha256-hfkkijNukqNGECfbmfVFmzasDZBjGxg3N4Qi89RKJvs=";
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

      install -m755 ${pname} $out/bin
      cp dev.DBrox.CosmicSystemMonitor.desktop $out/share/applications
      cp dev.DBrox.CosmicSystemMonitor.metainfo.xml $out/share/applications

      wrapProgram $out/bin/${pname} \
        --prefix LD_LIBRARY_PATH : ${libPath}


      runHook postInstall
    '';
    shellHook = ''
      export LD_LIBRARY_PATH=${libPath}
    '';
    meta = {
      description = "A highly configurable resource monitor applet for the COSMIC DE";
      homepage = "https://github.com/D-Brox/cosmic-ext-applet-system-monitor";
      license = lib.licenses.gpl3;
    };
  }

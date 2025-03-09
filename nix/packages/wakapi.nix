{
  stdenvNoCC,
  fetchzip,
  gcc-unwrapped,
  glibc,
  autoPatchelfHook,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "wakapi";
  version = "2.13.1";

  src = fetchzip {
    url = "https://github.com/muety/wakapi/releases/download/${version}/wakapi_linux_amd64.zip";
    hash = "sha256-doqKTniHo6Fl+wgL1dj+jq3P/ssESNO+sxiertk5+dQ=";
    stripRoot = false;
    inherit pname version;
  };
  dontBuild = true;
  dontConfigure = true;

  nativeBuildInputs = [
    autoPatchelfHook
  ];
  buildInputs = [
    glibc
    gcc-unwrapped
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 wakapi $out/bin
    runHook postInstall
  '';
}

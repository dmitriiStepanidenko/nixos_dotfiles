{
  stdenv,
  fetchzip,
  clang,
  gcc-unwrapped,
  glibc,
  mold,
  autoPatchelfHook,
  unzip,
  gnutar,
  glibcLocalesUtf8,
  ...
}:
stdenv.mkDerivation rec {
  pname = "woodpecker-server";
  version = "3.3.0";

  src = fetchzip {
    url = "https://github.com/woodpecker-ci/woodpecker/releases/download/v${version}/woodpecker-server_linux_amd64.tar.gz";
    hash = "sha256-ccQopuQ6Q+pKiPqRTRWR8xVcu/gYb4pryHxkHlV6PKA=";
    inherit pname version;
  };
  dontBuild = true;
  dontConfigure = true;

  nativeBuildInputs = [
    autoPatchelfHook
    unzip
    gnutar

    glibcLocalesUtf8

    glibc
    gcc-unwrapped
    clang
    mold
  ];
  buildInputs = [
    glibc
    gcc-unwrapped
    clang
    mold
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 woodpecker-server $out/bin
    runHook postInstall
  '';
}

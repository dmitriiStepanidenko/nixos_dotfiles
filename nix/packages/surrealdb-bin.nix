{
  stdenv,
  fetchzip,
  autoPatchelfHook,
  glibc,
  gcc-unwrapped,
}:
stdenv.mkDerivation rec {
  pname = "surrealdb-bin";
  version = "2.2.0";

  src = fetchzip {
    url = "https://github.com/surrealdb/surrealdb/releases/download/v${version}/surreal-v${version}.linux-amd64.tgz";
    hash = "";
  };

  nativeBuildInputs = [autoPatchelfHook];
  buildInputs = [
    glibc
    gcc-unwrapped
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 PACKAGE_BINARY_FILE_NAME $out/bin
    runHook postInstall
  '';
}


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
    hash = "sha256-mPH6NKg/wpizQ7CDbeA/U3zPIT0qmDywhgf4VDjVH9Q=";
  };

  nativeBuildInputs = [autoPatchelfHook];
  buildInputs = [
    glibc
    gcc-unwrapped
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 surreal $out/bin
    runHook postInstall
  '';
}


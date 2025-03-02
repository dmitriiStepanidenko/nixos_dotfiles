{
  stdenv,
  fetchzip,
  autoPatchelfHook,
  glibc,
  gcc-unwrapped,
}:
stdenv.mkDerivation rec {
  pname = "todo-backend";
  version = "0.0.1";

  src = fetchzip {
    url = "http://10.252.1.0:3000/api/packages/graph-learning/generic/todo/${version}/app.tgz";
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
    install -m755 app $out/bin
    runHook postInstall
  '';
}

{
  stdenv,
  fetchzip,
  autoPatchelfHook,
  glibc,
  gcc-unwrapped,
  ...
}:
stdenv.mkDerivation rec {
  pname = "todo-backend";
  version = "0.0.1";

  src = fetchzip {
    url = "http://10.252.1.0:3000/api/packages/graph-learning/generic/todo/${version}/todo-backend.tgz";
    hash = "sha256-FKJT7uPO7lhAVqSS5OEHCP23cz/gwgqOjHDR6cIDlnQ=";
  };
  dontConfigure = true;
  dontBuild = true;

  #nativeBuildInputs = [autoPatchelfHook];
  #buildInputs = [
  #  glibc
  #  gcc-unwrapped
  #];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 todo-backend $out/bin
    runHook postInstall
  '';
}

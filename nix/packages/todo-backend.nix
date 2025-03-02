{
  stdenv,
  lib,
  fetchzip,
  fetchurl,
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
  pname = "todo-backend-bin";
  version = "0.0.1";

  src = fetchzip {
    url = "http://10.252.1.0:3000/api/packages/graph-learning/generic/todo/${version}/todo-backend.tgz";
    hash = "sha256-/65B/0s6xbh+HjqchRFWs1s03o+PE9+IfjLezPsX3nM=";
    #curlOptsList = ["-OJ"];
    name = "todo-backend.tgz";
    inherit pname version;
  };
  dontBuild = true;
  dontConfigure = true;
  #unpackPhase = ''
  #  runHook preUnpack
  #  unpackFile todo-backend.tgz
  #  tar -xvzf todo-backend.tgz
  #  runHook postUnpack
  #'';

  nativeBuildInputs = [
    #autoPatchelfHook
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
    install -m755 todo-backend $out/bin
    runHook postInstall
  '';
}

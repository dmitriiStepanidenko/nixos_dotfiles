{ appimageTools, fetchurl }:
let
  pname = "surrealist";
  version = "3.5.2";

  src = fetchurl {
    url = "https://github.com/surrealdb/surrealist/releases/download/surrealist-v${version}/Surrealist_${version}_amd64.AppImage";
    hash = "sha256-q+ZIXksFNqU5N9bqzwQ58VgqAXnbnpL5/3z0Z6kyjE8=";
  };
in
appimageTools.wrapType2 { inherit pname version src; }
#{
#  stdenv,
#  fetchzip,
#  fetchurl,
#  clang,
#  gcc-unwrapped,
#  glibc,
#  mold,
#  autoPatchelfHook,
#  unzip,
#  gnutar,
#  glibcLocalesUtf8,
#  ...
#}:
#stdenv.mkDerivation rec {
#  pname = "surrealist";
#  version = "3.5.2";
#
#  src = fetchurl {
#    url = "https://github.com/surrealdb/surrealist/releases/download/surrealist-v${version}/Surrealist_${version}_amd64.AppImage";
#    #      https://github.com/surrealdb/surrealist/releases/download/surrealist-v3.5.2/Surrealist_3.5.2_amd64.AppImage
#    hash = "";
#  };
#}

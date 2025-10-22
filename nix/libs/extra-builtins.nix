{exec, ...}: rec {
  sopsFromNix = file: exec ["sops" "-d" file];

  # cmd is a wrapper for exec. Since exec will parse the output of
  # command as a Nix expression, cmd will escape the output in advance,
  # so that after exec parsing it later, the original output content of
  # the command can be returned
  cmd = args:
    exec [
      "sh"
      "-c"
      (''printf "\"%s\"" "$('' + (builtins.concatStringsSep " " (map (x: "'" + x + "'") args)) + ''| sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\$/\\$/g')"'')
    ];
  sopsDecrypt = file: cmd ["sops" "-d" file];
  sopsDecryptToJSON = file: cmd ["sops" "--output-type" "json" "-d" file];

  # Direct parsing json/yaml/toml through sops, using cmd to implement
  sopsFromJSON = file: builtins.fromJSON (sopsDecrypt file);
  sopsFromYAML = file: builtins.fromJSON (sopsDecryptToJSON file);
  sopsFromTOML = file: builtins.fromTOML (sopsDecrypt file);

  # Direct parsing json/yaml/toml through sops, using nix eval to
  # convert the output to nix format in advance to implement
  sopsFromJSON2 = file:
    exec [
      "sh"
      "-c"
      ("nix eval --expr \"builtins.fromJSON(''\$(sops --output-type json -d '" + file + "')'')\"")
    ];
  sopsFromYAML2 = file: sopsFromJSON2 file;
  sopsFromTOML2 = file:
    exec [
      "sh"
      "-c"
      ("nix eval --expr \"builtins.fromTOML(''\$(sops -d '" + file + "')'')\"")
    ];
}

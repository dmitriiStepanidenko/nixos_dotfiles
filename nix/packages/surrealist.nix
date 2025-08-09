{
  buildGoModule,
  cairo,
  cargo-tauri,
  cargo,
  esbuild,
  fetchFromGitHub,
  gdk-pixbuf,
  glib-networking,
  gobject-introspection,
  jq,
  lib,
  libsoup_3,
  makeBinaryWrapper,
  moreutils,
  nodejs,
  openssl,
  pango,
  pkg-config,
  pnpm_9,
  bun,
  typescript,
  nodejs-slim_latest,
  rustc,
  rustPlatform,
  stdenv,
  webkitgtk_4_1,
}: let
  esbuild_21-5 = let
    version = "0.21.5";
  in
    esbuild.override {
      buildGoModule = args:
        buildGoModule (
          args
          // {
            inherit version;
            src = fetchFromGitHub {
              owner = "evanw";
              repo = "esbuild";
              rev = "v${version}";
              hash = "sha256-FpvXWIlt67G8w3pBKZo/mcp57LunxDmRUaCU/Ne89B8=";
            };
            vendorHash = "sha256-+BfxCyg0KkDQpHt/wycy/8CTG6YBA/VJvJFhhzUnSiQ=";
          }
        );
    };
in
  stdenv.mkDerivation (finalAttrs: rec {
    pname = "surrealist";
    version = "3.5.2";

    src = fetchFromGitHub {
      owner = "surrealdb";
      repo = "surrealist";
      rev = "surrealist-v${finalAttrs.version}";
      hash = "sha256-KVPKXbdVcNZf0MWnV0tvNG2F1mxkyfXcY/9pMWZVEAw=";
    };

    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) src;
      sourceRoot = "${finalAttrs.src.name}/${finalAttrs.cargoRoot}";
      hash = "sha256-NhgSfiBb4FGEnirpDFWI3MIMElen8frKDFKmCBJlSBY=";
    };

    #pnpmDeps = pnpm_9.fetchDeps {
    #  inherit (finalAttrs) pname version src;
    #  fetcherVersion = 1;
    #  hash = "sha256-oreeV9g16/F7JGLApi0Uq+vTqNhIg7Lg1Z4k00RUOYI=";
    #};
    node_modules = stdenv.mkDerivation {
      inherit (finalAttrs) src version;
      pname = "surrealist-node_modules";
      impureEnvVars =
        lib.fetchers.proxyImpureEnvVars
        ++ ["GIT_PROXY_COMMAND" "SOCKS_SERVER"];
      nativeBuildInputs = [bun];
      dontConfigure = true;
      buildPhase = ''
        runHook preBuild
        ls
        bun install --no-progress --frozen-lockfile
        ls
        runHook postBuild
      '';
      installPhase = ''
        ls
        mkdir -p $out/node_modules

        cp -R ./node_modules $out
        ls $out
        pwd $out
      '';
      outputHash = "sha256-jBPhR5hdr/i7jiKF9y+sgmsgLsZUxi6v6zj01Amo2qE=";
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
    };

    nativeBuildInputs = [
      cargo
      cargo-tauri.hook
      gobject-introspection
      jq
      makeBinaryWrapper
      moreutils
      nodejs
      pkg-config
      #pnpm_9.configHook
      bun
      typescript
      rustc
      rustPlatform.cargoSetupHook
      node_modules
    ];

    buildInputs = [
      cairo
      gdk-pixbuf
      libsoup_3
      openssl
      pango
      webkitgtk_4_1
    ];

    env = {
      ESBUILD_BINARY_PATH = lib.getExe esbuild_21-5;
      OPENSSL_NO_VENDOR = 1;
    };

    cargoRoot = "src-tauri";
    buildAndTestSubdir = finalAttrs.cargoRoot;

    # Deactivate the upstream update mechanism
    postPatch = ''
      jq '
        .bundle.createUpdaterArtifacts = false |
        .plugins.updater = {"active": false, "pubkey": "", "endpoints": []}
      ' \
      src-tauri/tauri.conf.json | sponge src-tauri/tauri.conf.json
    '';

    postFixup = ''
      wrapProgram "$out/bin/surrealist" \
        --set GIO_EXTRA_MODULES ${glib-networking}/lib/gio/modules \
        --set WEBKIT_DISABLE_COMPOSITING_MODE 1
    '';

    configurePhase = ''
      runHook preConfigure

      # node modules need to be copied to substitute for reference
      # substitution step cannot be done before otherwise
      # nix complains about unallowed reference in FOD
      cp -R ${node_modules}/node_modules .
      # bun installs .bin package with a usr bin env ref to node
      # replace any ref for bin that are used
      #substituteInPlace node_modules/.bin/vite \
      #  --replace "/usr/bin/env node" "${nodejs}/bin/node"
      chmod -R u+rw node_modules
      chmod -R u+x node_modules/.bin
      patchShebangs node_modules

      export HOME=$TMPDIR
      export PATH="$PWD/node_modules/.bin:$PATH"

      runHook postConfigure
    '';

    preBuild = ''
      ls
    '';

    meta = with lib; {
      description = "Surrealist is the ultimate way to visually manage your SurrealDB database";
      homepage = "https://surrealdb.com/surrealist";
      license = licenses.mit;
      mainProgram = "surrealist";
      maintainers = with maintainers; [frankp];
      platforms = platforms.linux;
    };
  })
#{
#  appimageTools,
#  fetchurl,
#  glib-networking,
#}: let
#  pname = "surrealist";
#  #version = "3.5.2";
#  version = "3.2.4";
#
#  src = fetchurl {
#    url = "https://github.com/surrealdb/surrealist/releases/download/surrealist-v${version}/Surrealist_${version}_amd64.AppImage";
#    #hash = "sha256-q+ZIXksFNqU5N9bqzwQ58VgqAXnbnpL5/3z0Z6kyjE8=";
#    hash = "sha256-Yp74swJ7rOBubcChGh4ctabRtJdsYNCzS3Fmk5w9nUs=";
#  };
#in
#  appimageTools.wrapType2 {
#    inherit pname version src;
#    extraPkgs = pkgs:
#      with pkgs; [
#        cairo
#        gdk-pixbuf
#        libsoup_3
#        openssl
#        pango
#        webkitgtk_4_1
#
#        # OpenGL libraries
#        libGL
#        libGLU
#        libglvnd
#        mesa
#        mesa.drivers
#
#        # EGL/Wayland support
#        wayland
#        libxkbcommon
#
#        # X11 libraries
#        xorg.libX11
#        xorg.libXext
#        xorg.libXrender
#        xorg.libXrandr
#        xorg.libXinerama
#        xorg.libXcursor
#        xorg.libXi
#        xorg.libXxf86vm
#        xorg.libXfixes
#        xorg.libXcomposite
#        xorg.libXdamage
#
#        # Additional graphics support
#        vulkan-loader
#        dbus
#      ];
#
#    postFixup = ''
#      wrapProgram $out/bin/${pname} \
#        --set GIO_EXTRA_MODULES ${glib-networking}/lib/gio/modules \
#        --set WEBKIT_DISABLE_COMPOSITING_MODE 1 \
#        --set MESA_GL_VERSION_OVERRIDE 3.3 \
#        --set MESA_GLSL_VERSION_OVERRIDE 330
#    '';
#  }


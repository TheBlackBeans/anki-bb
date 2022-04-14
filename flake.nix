let
  version = "2.1.50";
  qt-version = "6";
  pname = "bb-anki";
  full-version = "${version}-qt${qt-version}";
in {
  inputs = {
    anki = {
      src = "https://github.com/ankitects/anki/releases/download/${version}/anki-${version}-linux-qt${qt-version}.tar.zst";
      flake = false;
    };
    nixpkgs.url = github:nixos/nixpkgs-unstable;
  };

  outputs = { anki, nixpkgs }: {
    defaultPackage.x86_64-linux =
      let
        inherit (nixpkgs) buildFHSUserEnv appimageTools writeShellScript stdenv;
        unpacked = stdenv.mkDerivation {
          inherit pname;
          version = full-version;
          src = anki;

          installPhase = ''
            runHook preInstall
            xdg-mime () {
              echo Stubbed!
            }
            export -f xdg-mime
            PREFIX=$out bash install.sh
            runHook postInstall
          '';
        };
        passthru.sources.linux = anki;
      in
        buildFHSUserEnv (appimageTools.defaultFhsEnvArgs // {
          inherit passthru;
          name = "anki";
          runScript = writeShellScript "anki-wrapper.sh" ''
            exec ${unpacked}/bin/anki
          '';

          extraInstallCommands = ''
            mkdir -p $out/share
            cp -R ${unpacked}/share/applications \
              ${unpacked}/share/man \
              ${unpacked}/share/pixmaps \
              $out/share
          '';
        });
  };
}

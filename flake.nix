{
  description = "An attempt at packaging `anki` 2.1.50 with Qt6";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
    anki = {
      url = "https://github.com/ankitects/anki/releases/download/2.1.50/anki-2.1.50-linux-qt6.tar.zst";
      flake = false;
    };
  };

  outputs = { self, anki, nixpkgs }: {
    defaultPackage.x86_64-linux =
      let
        actualNixpkgs = import nixpkgs { system = "x86_64-linux"; };
        inherit (actualNixpkgs) buildFHSUserEnv appimageTools writeShellScript stdenv;
        unpacked = stdenv.mkDerivation {
          pname = "anki-bb";
          version = "2.1.50-qt6";
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
            export DISABLE_QT5_COMPAT=1
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

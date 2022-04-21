{
  description = "Google Translate API bindings";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system; config.allowBroken = true;
        };
        haskellPackages = pkgs.haskell.packages.ghc8107;
        packageName = "google-translate";
      in {
        packages.${packageName} = haskellPackages.callCabal2nix packageName ./. {};
        defaultPackage = self.packages.${system}.${packageName};
        devShell =
          let
            ghcWithPkg =
              pkgs.lib.head (
                pkgs.lib.splitString "bin" (
                  self.packages.${system}.${packageName}.env.NIX_GHC));
            ghcBin = "${ghcWithPkg}/bin";
          in
          pkgs.mkShell {
          buildInputs = with haskellPackages; [
            pkgs.zlib
            cabal-install
          ];
          shellHook = ''export PATH=$PATH:${ghcBin}'';
        };
      });
}

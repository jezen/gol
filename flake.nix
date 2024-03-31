{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = { self, nixpkgs, flake-utils, pre-commit-hooks }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              self.overlays.default
            ];
          };
          hl = pkgs.haskell.lib;
        in
        {
          packages.gol = pkgs.haskellPackages.gol;
          packages.default = pkgs.lib.trivial.pipe pkgs.haskellPackages.gol
            [
              hl.dontHaddock
              hl.enableStaticLibraries
              hl.justStaticExecutables
              hl.disableLibraryProfiling
              hl.disableExecutableProfiling
            ];

          checks = {
            inherit (pkgs.haskellPackages) gol;

            pre-commit-check = pre-commit-hooks.lib.${system}.run {
              src = ./.;
              hooks = {
                cabal-fmt.enable = true;
                deadnix.enable = true;
                hlint.enable = true;
                markdownlint.enable = true;
                nixpkgs-fmt.enable = true;
                statix.enable = true;
                stylish-haskell.enable = true;
              };
            };
          };

          devShells.default = pkgs.haskellPackages.shellFor {
            packages =
              let
                devPkgs =
                  [
                    pkgs.haskellPackages.foreign-store
                    pkgs.haskellPackages.aeson-pretty
                  ];
              in
              p: [ (hl.addBuildDepends p.gol devPkgs) ];
            buildInputs = with pkgs.haskellPackages; [
              cabal-fmt
              cabal-install
              hlint
            ];
            inherit (self.checks.${system}.pre-commit-check) shellHook;
          };
        }) // {
      overlays.default = _: prev: {
        haskell = prev.haskell // {
          # override for all compilers
          packageOverrides = prev.lib.composeExtensions prev.haskell.packageOverrides (_: hprev: {
            gol =
              let
                haskellSourceFilter = prev.lib.sourceFilesBySuffices ./. [
                  ".cabal"
                  ".hs"
                ];
              in
              hprev.callCabal2nix "gol" haskellSourceFilter { };
          });
        };
      };
    };
}

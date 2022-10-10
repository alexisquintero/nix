{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in
        {
          devShells = {
            scala = import ./scala-shell.nix;
            terraform = import ./terraform-shell.nix;
            clojure = import ./clojure-shell.nix;
            haskell = import ./haskell-shell.nix;
            python = import ./python-shell.nix;
          }
        }
      );
}

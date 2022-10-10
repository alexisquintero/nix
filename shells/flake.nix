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
            scala = import ./scala-shell.nix { inherit pkgs; };
            terraform = import ./terraform-shell.nix { inherit pkgs; };
            clojure = import ./clojure-shell.nix { inherit pkgs; };
            haskell = import ./haskell-shell.nix { inherit pkgs; };
            python = import ./python-shell.nix { inherit pkgs; };
          };
        }
      );
}

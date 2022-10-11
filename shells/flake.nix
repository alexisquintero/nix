{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          devShells =
            builtins.foldl' (acc: ver: acc // { "scala${ver}" = import ./scala-shell.nix { inherit pkgs; ver = ver; }; })
              { } [ "8" "11" ]
            //
            builtins.foldl' (acc: env: acc // { ${env} = import ./${env}-shell.nix { inherit pkgs; }; })
              { } [ "scala" "terraform" "clojure" "haskell" "python" ];
        }
      );
}

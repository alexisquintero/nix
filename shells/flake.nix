{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem (builtins.filter (x: x != flake-utils.lib.system.i686-linux) flake-utils.lib.defaultSystems)
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          devShells =
            builtins.foldl' (acc: ver: acc // { "scala${ver}" = import ./scala-shell.nix { inherit pkgs; version = ver; }; })
              { } [ "" "8" "11" ]
            //
            builtins.foldl' (acc: ver: acc // { "terraform${ver}" = import ./terraform-shell.nix { inherit pkgs; version = ver; }; })
              { } [ "" "12" "13" "14" ]
            //
            builtins.foldl' (acc: env: acc // { ${env} = import ./${env}-shell.nix { inherit pkgs; }; })
              { } [ "terraform" "clojure" "haskell" "python" "bash" "cmake" "docker" "typescript" ];
        }
      );
}

{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        in
        builtins.foldl' (acc: ver: acc // { "scala${ver}" = import ./scala-shell.nix { inherit pkgs; version = ver; }; })
          { } [ "" "8" "11" ]
        //
        builtins.foldl' (acc: ver: acc // { "terraform${ver}" = import ./terraform-shell.nix { inherit pkgs; version = ver; }; })
          { } [ "" "12" "13" "14" ]
        //
        builtins.foldl' (acc: env: acc // { ${env} = import ./${env}-shell.nix { inherit pkgs; }; })
          { } [ "clojure" "haskell" "python" "bash" "cmake" "docker" "typescript" "rust" ]
      );
    };
}

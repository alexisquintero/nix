{
  description = "Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware";
    dotfiles = {
      url = "github:alexisquintero/dotfiles";
      flake = false;
    };
    vim-config = {
      url = "github:alexisquintero/.vim";
      flake = false;
    };
  };

  outputs = { nixpkgs, home-manager, dotfiles, vim-config, nixos-hardware, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations = {
        nixos-g14 = nixpkgs.lib.nixosSystem {
          inherit system;

          modules = [
            nixos-hardware.nixosModules.asus-zephyrus-ga401
            ./configuration/g14-config.nix
            nixos-hardware.nixosModules.asus-battery
            {
              hardware.asus.battery.chargeUpto = 60;
            }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.alexis = import ./home.nix;
              home-manager.extraSpecialArgs = { inherit dotfiles vim-config; generic-linux = false; };
            }
          ];
        };
      };

      homeConfigurations.alexis = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./home.nix
        ];
        extraSpecialArgs = { inherit dotfiles vim-config; generic-linux = true; };
      };
    };
}

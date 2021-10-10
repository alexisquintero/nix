{
  description = "Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    dotfiles = {
      url = "github:alexisquintero/dotfiles";
      flake = false;
    };
    vim-config = {
      url = "github:alexisquintero/.vim";
      flake = false;
    };
  };

  outputs = { nixpkgs, home-manager, dotfiles, vim-config, ... }: {
  nixosConfigurations = {
      nixos-g14 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration/g14-config.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.alexis = import ./home.nix;
            home-manager.extraSpecialArgs = { inherit dotfiles vim-config; };
          }
        ];
      };
    };
  };
}

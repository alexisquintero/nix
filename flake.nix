{
  description = "Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
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

  outputs = { nixpkgs, home-manager, dotfiles, vim-config, nixos-hardware, ... }: {
  nixosConfigurations = {
      nixos-g14 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.asus-zephyrus-ga401
          "${nixos-hardware}/asus/battery.nix"
          # "${nixos-hardware}/common/gpu/nvidia.disable.nix"
          ./configuration/g14-config.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.alexis = import ./home.nix;
            home-manager.extraSpecialArgs = { inherit dotfiles vim-config nixos-hardware; };
          }
        ];
      };
    };
  };
}

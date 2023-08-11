{
  description = "Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:nixos/nixos-hardware";

    nixgl = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dotfiles = {
      url = "github:alexisquintero/dotfiles";
      flake = false;
    };

    vim-config = {
      url = "github:alexisquintero/.vim";
      flake = false;
    };

    git-prompt = {
      url = "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh";
      flake = false;
    };

  };

  outputs = { nixpkgs, home-manager, dotfiles, vim-config, nixos-hardware, git-prompt, nixgl, ... }:
    let
      system = "x86_64-linux";
      pkgs-with-overlays = import nixpkgs {
        overlays = [ nixgl.oerlay ];
      };
      pkgs = pkgs-with-overlays.legacyPackages.${system};
    in
    {
      nixosConfigurations = {
        nixos-g14 = nixpkgs.lib.nixosSystem {
          inherit system;

          modules = [
            # nixos-hardware.nixosModules.asus-zephyrus-ga401
            ./configuration/g14/config.nix
            nixos-hardware.nixosModules.asus-battery
            {
              hardware.asus.battery.chargeUpto = 60;
            }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.alexis = import ./home/home-alexis.nix;
              home-manager.extraSpecialArgs = { inherit dotfiles vim-config git-prompt; };
            }
          ];
        };
      };

      homeConfigurations.alexis = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./home/home-alexis.nix
          {
            targets.genericLinux.enable = true;
          }
          # ./nixgl/pkgs.nix
        ];
        extraSpecialArgs = { inherit dotfiles vim-config git-prompt; };
      };


      homeConfigurations.alexisquintero = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./home/home-alexisquintero.nix
          # ./nixgl/pkgs.nix
        ];
        extraSpecialArgs = { inherit dotfiles vim-config git-prompt; };
      };
    };
}

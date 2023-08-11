# New Install

## Nixos

1. Format
1. Partition
1. Luks encryption
1. Install regular NIXOS // TODO
1. Clone repo to ~./config/nix
1. Switch to this repo/flake

## Home-Manager

1. Clone repo to ~/.config/nix
1. Create `private.nix`

    ````nix
    { ... }:
    
    {
      programs.git.userEmail = "user@email";
    } 
1. `nix shell -p home-manager`  
    1. 
        ```sh
        NIXPKGS_ALLOW_UNFREE=1 home-manager switch --flake .#{output} --extra-experimental-features "nix-command flakes"
        ```

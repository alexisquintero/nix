# New Install

## Nixos

TODO

## Home-Manager

0. Clone repo to ~/.config/nix
0. Create `private.nix`

```nix
{ ... }:

{
  programs.git.userEmail = "user@email";
}

```
0. Export var to allow unfree packages <!-- TODO -->
0. Home-Manager switch incantation <!-- TODO -->

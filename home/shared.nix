{ pkgs, nixpkgs, ... }:

let
  dev-shell = pkgs.writeShellScriptBin "dev-shell" ''
    #!${pkgs.bash}/bin/bash
    nix develop github:alexisquintero/config.nix?dir=shells#"$1"
  '';
in
{
  nix.registry.local.flake = nixpkgs;

  home = {
    stateVersion = "23.05";

    sessionVariables = {
      EDITOR = "vim";
      VISUAL = "vim";
      LESSHISTFILE = "-";
    };

    packages = with pkgs; [
      docker-compose
      ripgrep
      dev-shell
      dejavu_fonts
    ];

    sessionPath = [ "$HOME/.local/bin" ];
  };

  xdg.enable = true;

  imports = [
    ../programs/nvim.nix
    ../programs/git.nix
    ../programs/kitty.nix
    ../programs/tmux.nix
    ../programs/bash.nix
    ../programs/readline.nix
  ];

  programs = {
    home-manager.enable = true;

    fzf = {
      enable = true;
      defaultCommand = "rg --files --hidden -g '!.git/'";
    };

    gpg.enable = true;

    dircolors.enable = true;
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };
}

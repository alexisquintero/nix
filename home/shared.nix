{ pkgs, nixpkgs, ... }:

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
      dejavu_fonts
    ];

    sessionPath = [ "$HOME/.local/bin" ];
  };

  xdg.enable = true;

  imports = [
    ../programs/git.nix
    ../programs/kitty.nix
    ../programs/sbt.nix
    ../programs/tmux.nix
    ../programs/bash.nix
    ../programs/readline.nix
    ../programs/dev-shell.nix
  ];

  programs = {
    home-manager.enable = true;

    fzf = {
      enable = true;
      defaultCommand = "rg --files --hidden -g '!.git/'";
      defaultOptions = [ "--layout=reverse" ];
      changeDirWidget = {
        command = "fd --type d --search-path ~";
        options = [ "--scheme=path" ];
      };
    };

    gpg.enable = true;

    dircolors.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };
}

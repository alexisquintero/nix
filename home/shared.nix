{ pkgs, dotfiles, git-prompt, nixpkgs, ... }:

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

    file.".haskeline".text = ''
      editMode: Vi
    '';

    packages = with pkgs; [
      docker-compose
      ripgrep
      dev-shell
      dejavu_fonts
    ];

    sessionPath = [ "$HOME/.local/bin" ];
  };

  xdg = {
    enable = true;
    configFile."git/git-prompt.sh".source = "${git-prompt}";
  };

  imports = [
    ../programs/vim.nix
    ../programs/git.nix
    ../programs/kitty.nix
    ../programs/tmux.nix
    ../programs/bash.nix
  ];

  programs = {
    home-manager.enable = true;

    fzf = {
      enable = true;
      defaultCommand = "rg --files --hidden -g '!.git/'";
    };

    readline = {
      enable = true;
      extraConfig = builtins.readFile "${dotfiles}/.config/readline/inputrc";
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

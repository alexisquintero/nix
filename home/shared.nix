{ config, pkgs, dotfiles, git-prompt, nixpkgs, ... }:

let
  git-compl-nixos-path = "/etc/profiles/per-user/${config.home.username}/share/bash-completion/completions/git";
  git-compl-profile-path = "${config.home.homeDirectory}/.nix-profile/share/bash-completion/completions/git";
  git-compl-path = if pkgs.stdenv.isDarwin || config.targets.genericLinux.enable
                   then git-compl-profile-path
                   else git-compl-nixos-path;
  source-git-compl = "[ -f ${git-compl-path} ] && source ${git-compl-path}\n";
  kitty-ssh-alias = ''
    [ "$TERM" = "xterm-kitty" ] && alias ssh="kitty +kitten ssh"
  '';

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
  ];

  programs = {
    home-manager.enable = true;

    bash = {
      enable = true;
      historyFile = "${config.xdg.configHome}/bash/bash_history";
      initExtra =
        source-git-compl +
        kitty-ssh-alias +
        builtins.readFile "${dotfiles}/.bashrc";
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
      defaultCommand = "rg --files --hidden -g '!.git/'";
    };

    tmux = {
      enable = true;
      secureSocket = false;
      extraConfig = builtins.readFile "${dotfiles}/.tmux.conf";
    };

    readline = {
      enable = true;
      extraConfig = builtins.readFile "${dotfiles}/.config/readline/inputrc";
    };

    gpg.enable = true;

    dircolors = {
      enable = true;
      enableBashIntegration = true;
    };

    mise.enable = true;
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };
}

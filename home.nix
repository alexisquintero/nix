{ config, pkgs, lib, ... }:

let

  st = pkgs.st.override {
    conf = builtins.readFile ./dotfiles/st/config.h;
  };

  git-compl-path = "/nix/var/nix/profiles/per-user/${config.home.username}/profile/share/bash-completion/completions/git";

  is-wsl = "" != builtins.getEnv "WSL_DISTRO_NAME";

  create-shell = pkgs.writeShellScriptBin "create-shell" ''
    #!${pkgs.bash}/bin/bash
    # Takes an argument, the language, and creates a shell.nix file

    cp ${config.xdg.configHome}/nixpkgs/shells/"$1"-shell.nix ./shell.nix
  '';

in
{

  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))
  ];

  targets.genericLinux.enable = is-wsl;

  fonts.fontconfig.enable = true;

  home = {

    username = "alexis";
    homeDirectory = "/home/alexis";
    stateVersion = "21.03";

    keyboard = {
      layout = "us";
      variant = "altgr-intl";
    };

    sessionVariables =
    let
      wsl-env-vars = {
        LIBGL_ALWAYS_INDIRECT = "1";
        DISPLAY = "\$(awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null):0";
      };
      extra-env-vars = if is-wsl then wsl-env-vars else {};
    in
    {
      EDITOR = "vim";
      VISUAL = "vim";
      LESSHISTFILE = "-";
    }
    //
    extra-env-vars;

    file.".haskeline".text = ''
      editMode: Vi
    '';

    packages = (with pkgs; [
      dejavu_fonts
      keepass
      haskellPackages.xmobar
      rnix-lsp
      ripgrep
      scrot
      mpv
      xsel
      libnotify
      docker-compose
      pulsemixer
      playerctl
    ]) ++
    [
      st
      create-shell
    ];
  };

  xdg = {
    enable = true;
    configFile."dunst/dunstrc".source = ./dotfiles/.config/dunst/dunstrc;
    configFile."i3/i3status".source = ./dotfiles/.config/i3/i3status;
    configFile."xmobar/xmobarrc".source = ./dotfiles/.config/xmobar/xmobarrc;
    configFile."git/config".source = ./dotfiles/.config/git/config;
    configFile."git/git-prompt.sh".source = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh";
    };
  };

  imports = [
    ./vim.nix
  ];

  programs = {

    home-manager.enable = true;

    git = {
      enable = true;
      ignores = [
        "*.bloop"
        "*.metals"
        "*.metals.sbt"
        "*metals.sbt"
        "*.mill-version"
      ];
    };

    bash = {
      enable = true;
      historyFile = "${config.xdg.configHome}/bash/bash_history";
      initExtra =
        "[ -f ${git-compl-path} ] && source ${git-compl-path}\n" +
        builtins.readFile ./dotfiles/.bashrc;
      profileExtra = lib.mkIf is-wsl ''
        . ${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh
      '';
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
      defaultCommand = "rg";
    };

    tmux = {
      enable = true;
      secureSocket = false;
      extraConfig = builtins.readFile ./dotfiles/.tmux.conf;
    };

    readline = {
      enable = true;
      extraConfig = builtins.readFile ./dotfiles/.config/readline/inputrc;
    };

    gpg.enable = true;

    chromium.enable = true;

    firefox.enable = true;

    dircolors = {
      enable = true;
      enableBashIntegration = true;
    };

  };

  services = {

    gpg-agent = {
      enable = true;
      defaultCacheTtl = 1800;
      enableSshSupport = true;
    };

    dunst.enable = true;

    xscreensaver  = {
      enable = true;
      settings = {
        dpmsEnabled = true; dpmsQuickOff = true; dpmsStandby = "0:00:01"; dpmsSuspend = "0:00:01"; dpmsOff = "0:00:01";
        mode = "blank";
      };
    };

    redshift = {
      enable = true;
      brightness = {
        day = "0.7";
        night = "0.5";
      };
      latitude = "-32";
      longitude = "-60";
    };

    xsuspender.enable = true;

  };

  xsession =
    let

      wmi3 = {
        # enable = true;
        config = null;
        extraConfig = builtins.readFile ./dotfiles/.config/i3/config;
      };

      wmxmonad = {
        enable = true;
        config = ./dotfiles/.xmonad/xmonad.hs;
        extraPackages = haskellPackages: (with haskellPackages; [
          xmonad-contrib
          xmonad-extras
          xmonad
        ]);
      };

    in
    {

      enable = true;
      windowManager = {
        # i3 = wmi3;
        xmonad = wmxmonad;
      };

  };

}

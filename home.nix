{ config, pkgs, lib, dotfiles, vim-config, ... }:

let

  st = pkgs.st.override {
    conf = builtins.readFile "${dotfiles}/st/config.h";
  };

  git-compl-path = "/etc/profiles/per-user/${config.home.username}/share/bash-completion/completions/git";

  is-wsl = "" != builtins.getEnv "WSL_DISTRO_NAME";

  create-shell = pkgs.writeShellScriptBin "create-shell" ''
    #!${pkgs.bash}/bin/bash
    # Takes an argument, the language, and creates a shell.nix file

    cp ${config.xdg.configHome}/nixpkgs/shells/"$1"-shell.nix ./shell.nix
  '';

in
{

  targets.genericLinux.enable = is-wsl;

  fonts.fontconfig.enable = true;

  home = {

    username = "alexis";
    homeDirectory = "/home/alexis";
    stateVersion = "21.03";

    keyboard = {
      layout = "us";
      variant = "altgr-intl";
      options = [ "ctrl:nocaps" ];
    };

    sessionVariables =
    let
      wsl-env-vars = {
        LIBGL_ALWAYS_INDIRECT = "1";
        DISPLAY = "\$(awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null):0";
      };
      extra-env-vars = if is-wsl then wsl-env-vars else {};
      editor = "vim";
    in
    {
      EDITOR = editor;
      VISUAL = editor;
      LESSHISTFILE = "-";
    }
    //
    extra-env-vars;

    file.".haskeline".text = ''
      editMode: Vi
    '';

    packages = (with pkgs; [
      dejavu_fonts
      ipafont
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
      google-chrome
    ]) ++
    [
      st
      create-shell
    ];
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-mozc ];
  };

  xdg = {
    enable = true;
    configFile."dunst/dunstrc".source = "${dotfiles}/.config/dunst/dunstrc";
    configFile."i3/i3status".source = "${dotfiles}/.config/i3/i3status";
    configFile."xmobar/xmobarrc".source = "${dotfiles}/.config/xmobar/xmobarrc";
    configFile."git/config".source = "${dotfiles}/.config/git/config";
    configFile."git/git-prompt.sh".source = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh";
    };
    configFile."fcitx5/config".source = "${dotfiles}/.config/fcitx5/config";
    configFile."fcitx5/profile".source = "${dotfiles}/.config/fcitx5/profile";
    configFile."fcitx5/conf/xcb.conf".source = "${dotfiles}/.config/fcitx5/conf/xcb.conf";
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
        builtins.readFile "${dotfiles}/.bashrc";
      profileExtra = lib.mkIf is-wsl ''
        . ${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh
      '';
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

    # chromium.enable = true;

    firefox.enable = true;

    dircolors = {
      enable = true;
      enableBashIntegration = true;
    };

    ncspot.enable = true;

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
      settings.brightness = {
        day = "0.7";
        night = "0.5";
      };
      latitude = "-32";
      longitude = "-60";
    };

    xsuspender.enable = true;

    playerctld.enable = true;

    volnoti.enable = true;

    poweralertd.enable = true;

  };

  xsession =
    let

      wmi3 = {
        # enable = true;
        config = null;
        extraConfig = builtins.readFile "${dotfiles}/.config/i3/config";
      };

      wmxmonad = {
        enable = true;
        config = "${dotfiles}/.xmonad/xmonad.hs";
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

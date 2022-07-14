{ config
, pkgs
, lib
, dotfiles
, vim-config
, git-prompt
, generic-linux ? false
, user ? "alexis"
, homedir ? "alexis"
, ...
}:

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

  targets.genericLinux.enable = generic-linux;

  fonts.fontconfig.enable = true;

  home = {

    username = user;
    homeDirectory = "/home/${homedir}";
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
        extra-env-vars = if is-wsl then wsl-env-vars else { };
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
      rnix-lsp
      ripgrep
      scrot
      mpv
      xsel
      libnotify
      docker-compose
      pulsemixer
      google-chrome
      i3lock
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
    configFile."git/config".source = "${dotfiles}/.config/git/config";
    configFile."git/git-prompt.sh".source = "${git-prompt}";
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

    xmobar = {
      enable = true;
      extraConfig = builtins.readFile "${dotfiles}/.config/xmobar/xmobarrc";
    };

    # i3status = {
    #   enable = true;
    #   general = builtins.readFile "${dotfiles}/.config/i3/i3status";
    # };

  };

  services = {

    gpg-agent = {
      enable = true;
      defaultCacheTtl = 1800;
      enableSshSupport = true;
    };

    dunst = {
      enable = true;
      configFile = "${dotfiles}/.config/dunst/dunstrc";
    };

    screen-locker = {
      enable = true;
      inactiveInterval = 5;
      lockCmd = "${pkgs.i3lock}/bin/i3lock -c 000000 ;${pkgs.xorg.xset}/bin/xset dpms force off";
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

    cbatticon.enable = true;

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
        enableContribAndExtras = true;
        config = "${dotfiles}/.xmonad/xmonad.hs";
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

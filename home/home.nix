{ config, pkgs, lib, dotfiles, git-prompt, ... }:

let

  # st = pkgs.st.override {
  #   conf = builtins.readFile "${dotfiles}/st/config.h";
  # };

  git-compl-path = "/etc/profiles/per-user/${config.home.username}/share/bash-completion/completions/git";
  git-generic-compl-path = "/home/${config.home.username}/.nix-profile/share/bash-completion/completions/git";
  git-compl-fn = path: "[ -f ${path} ] && source ${path}\n";
  source-git-compl = git-compl-fn (if config.targets.genericLinux.enable then git-generic-compl-path else git-compl-path);
  kitty-ssh-alias = ''
    [ "$TERM" = "xterm-kitty" ] && alias ssh="kitty +kitten ssh"
  ''; # https://wiki.archlinux.org/title/Kitty

  is-wsl = "" != builtins.getEnv "WSL_DISTRO_NAME";

  dev-shell = pkgs.writeShellScriptBin "dev-shell" ''
    #!${pkgs.bash}/bin/bash
    # Takes an argument, the language, and calls nix develop

    nix develop github:alexisquintero/config.nix?dir=shells#"$1"
  '';

in
{
  fonts.fontconfig.enable = true;

  home = {
    stateVersion = "23.05";

    keyboard = {
      layout = "us";
      variant = "altgr-intl";
      options = [ "ctrl:nocaps" ];
    };

    # TODO: add `NIX_PATH = "local=${pkgs}";` (needs to be `nixpkgs` from the input)
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
      scrot
      mpv
      xsel
      libnotify
      docker-compose
      pulsemixer
      google-chrome
      ripgrep
      bluetuith
    ]) ++
    [
      dev-shell
    ];
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-mozc ];
  };

  xdg = {
    enable = true;
    configFile."git/git-prompt.sh".source = "${git-prompt}";
    configFile."fcitx5/config".source = "${dotfiles}/.config/fcitx5/config";
    configFile."fcitx5/profile".source = "${dotfiles}/.config/fcitx5/profile";
    configFile."fcitx5/conf/xcb.conf".source = "${dotfiles}/.config/fcitx5/conf/xcb.conf";
  };

  imports = [
    ../programs/vim.nix
    ../programs/git.nix
    ../programs/kitty.nix
    ../services/screen-locker.nix
    ../private.nix
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

    mise.enable = true;
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

    redshift = {
      enable = true;
      settings.brightness = {
        day = "0.7";
        night = "0.5";
      };
      latitude = "36";
      longitude = "140";
    };

    xsuspender.enable = true;

    playerctld.enable = true;

    poweralertd.enable = true;

    cbatticon.enable = true;


    sxhkd = {
      enable = true;
      keybindings = { # TODO: reference pkgs
        "XF86Audio{Raise,Lower}Volume" = "pulsemixer --change-volume {+,-}5";
        "XF86AudioMute" = "pulsemixer --toggle-mute";
        "XF86Audio{Play,Prev,Next}" = "playerctl {play-pause,previous,next}";
        "XF86TouchpadToggle" = "toggle-touchpad";
        "XF86MonBrightness{Up,Down}" = "light -{A,U} 10";
        "XF86KbdBrightness{Up,Down}" = "light -s sysfs/leds/asus::kbd_backlight -{A,U} 50"; # TODO: make laptop especific
        "print" = "scrot";
        "Control_L" = "sleep 0.2; scrot -s"; # TODO: make work with either control
        "Super_L + f" = "firefox";
        "Super_L + c" = "google-chrome-stable";
        "Super_L + y" = "i3lock -c 000000 ;xset dpms force off";
      };
    };
  };
}

{ config, pkgs, ... }:

let

  lib = pkgs.stdenv.lib;

  st = pkgs.st.override {
    conf = builtins.readFile ./dotfiles/st/config.h;
  };

  tmux-conf = builtins.readFile ./dotfiles/.tmux.conf;
  i3config = builtins.readFile ./dotfiles/.config/i3/config;
  readlinerc = builtins.readFile ./dotfiles/.config/readline/inputrc;
  bashrc = builtins.readFile ./dotfiles/.bashrc;

  home-dir = "${config.home.homeDirectory}";
  profile-path = "${home-dir}/.profile";
  git-compl-path = "/nix/var/nix/profiles/per-user/${config.home.username}/profile/share/bash-completion/completions/git";

  is-wsl = "" != builtins.getEnv "WSL_DISTRO_NAME";

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

    file.".xprofile".text = ''
      [ -f ${profile-path} ] && source ${profile-path}
    '';

    file.".haskeline".text = ''
      editMode: Vi
    '';

    packages = (with pkgs; [
      dmenu
      dejavu_fonts
      keepass
      haskellPackages.xmobar
      rnix-lsp
      scala
      sbt
      clojure
      clojure-lsp
      leiningen
      ripgrep
      scrot
      mpv
      openjdk
      xsel
      ghc
      stack
      libnotify
      docker-compose
      haskellPackages.haskell-language-server
      pulsemixer
    ]) ++
    [
      st
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

    home-manager = {
      enable = true;
    };

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
      historyFile = "${home-dir}/.config/bash/bash_history";
      initExtra =
        "[ -f ${git-compl-path} ] && source ${git-compl-path}\n" +
        bashrc;
      profileExtra = lib.mkIf is-wsl ''
        . ${home-dir}/.nix-profile/etc/profile.d/nix.sh
      '';
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
    };

    tmux = {
      enable = true;
      secureSocket = false;
      extraConfig = tmux-conf;
    };

    readline = {
      enable = true;
      extraConfig = readlinerc;
    };

    gpg = {
      enable = true;
    };

    chromium = {
      enable = true;
      extensions = [
        "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # Privacy badger
        "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark reader
        "gcbommkclmclpchllfjekcdonpmejbdp" # HTTPS everywhere
        "immpkjjlgappgfkkfieppnmlhakdmaab" # Imagus
        "kbmfpngjjgdllneeigpgjifpgocmfgmb" # Res
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock origin
        "dgogifpkoilgiofhhhodbodcfgomelhe" # wasavi
        "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
      ];
    };

    firefox = {
      enable = true;
    };

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

    dunst = {
      enable = true;
    };

    xscreensaver = {
      enable = true;
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

  };

  xsession =
    let

      wmi3 = {
        # enable = true;
        config = null;
        extraConfig = i3config;
      };

      wmxmonad = {
        enable = true;
        config = ./dotfiles/.xmonad/xmonad.hs;
        extraPackages = haskellPackages: [
          haskellPackages.xmonad-contrib
          haskellPackages.xmonad-extras
          haskellPackages.xmonad
        ];
      };

    in
    {

      windowManager = {
        # i3 = wmi3;
        xmonad = wmxmonad;
      };

  };

}

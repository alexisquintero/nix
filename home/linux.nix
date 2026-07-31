{ config, pkgs, lib, ... }:

let
  is-wsl = "" != builtins.getEnv "WSL_DISTRO_NAME";
in
{
  fonts.fontconfig.enable = true;

  home = {
    keyboard = {
      layout = "us";
      variant = "altgr-intl";
      options = [ "ctrl:nocaps" ];
    };

    sessionVariables = lib.mkIf is-wsl {
      LIBGL_ALWAYS_INDIRECT = "1";
      DISPLAY = "\$(awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null):0";
    };

    packages = with pkgs; [
      ipafont
      keepass
      mpv
      libnotify
      pulsemixer
      google-chrome
      bluetuith
      brightnessctl
    ];
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    # SKK: lowercase = hiragana, Shift+consonant = start kanji region (▽),
    # Space = convert/cycle candidates, Enter = confirm, Ctrl+g = cancel,
    # q = toggle katakana, l = switch to ASCII mode
    fcitx5.addons = with pkgs; [ fcitx5-mozc fcitx5-skk ];
  };

  xdg.configFile = {
    "fcitx5/conf/skk.conf".text = ''
      [General]

      [DictList]
      1\Type=file
      1\File=${pkgs.libskk}/share/skk/SKK-JISYO.L
      size=1
    '';
  };

  imports = [
    ../services/screen-locker.nix
    ../services/dunst.nix
    ../private.nix
  ];

  programs = {
    firefox = {
      enable = true;
      configPath = "${config.xdg.configHome}/mozilla/firefox";
    };

    bash = {
      shellAliases = {
        ls = "ls --color=auto";
        o = "xdg-open";
      };
      profileExtra = lib.mkIf is-wsl ''
        . ${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh
      '';
    };
  };

  services = {
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
    flameshot = {
      enable = true;
      settings.General = {
        useX11LegacyScreenshot = true;
        captureActiveMonitor   = true;
      };
    };

    sxhkd = {
      enable = true;
      keybindings = {
        "XF86Audio{Raise,Lower}Volume" = "${lib.getExe pkgs.pulsemixer} --change-volume {+,-}5";
        "XF86AudioMute" = "${lib.getExe pkgs.pulsemixer} --toggle-mute";
        "XF86Audio{Play,Prev,Next}" = "${lib.getExe config.services.playerctld.package} {play-pause,previous,next}";
        "XF86TouchpadToggle" = "toggle-touchpad";
        "XF86MonBrightness{Up,Down}" = "brightnessctl set 10%{+,-}";
        "Print" = "${lib.getExe config.services.flameshot.package} screen";
        "Control_L + Print" = "${lib.getExe config.services.flameshot.package} gui";
        "super + {f,c}" = "{firefox,google-chrome-stable}";
        "super + y" = "i3lock -c 000000 ;xset dpms force off";
      };
    };
  };
}

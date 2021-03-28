{ ... }:

let
  moz_overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
  nixpkgs = import <nixpkgs> { overlays = [ moz_overlay ]; };
  rustLatest = nixpkgs.latest.rustChannels.stable.rust;
  rustPlatform = nixpkgs.makeRustPlatform {
    cargo = rustLatest;
    rustc = rustLatest;
  };
  asus-nb-ctrl = rustPlatform.buildRustPackage rec {
    name = "ASUS-NB-Ctrl";

    src = builtins.fetchGit {
      url = "https://gitlab.com/asus-linux/asus-nb-ctrl";
      ref = "main";
      rev = "96ceef1bdbdef0341588cd4b60202e912948f064";
    };

    makeFlags = [
      "DESTDIR=${placeholder "out"}"
      "prefix="
    ];

    cargoSha256 = "sha256:1301bh1mfnryv6c7ccl03gldq657wb96q6s19b7ryx4aij2vvy31";

    nativeBuildInputs = with nixpkgs; [ pkg-config ];
    buildInputs = with nixpkgs; [ dbus udev ];

    # TODO: Fix systemctl call
    patchPhase = ''
      sed -i '1,2d' data/asusd.rules
    '';

    configurePhase = null;
    buildPhase = null;
    checkPhase = null;
    installPhase = null;

    meta = with nixpkgs.stdenv.lib; {
      description = "asusd is a utility for Linux to control many aspects of various ASUS laptops but can also be used with non-asus laptops with reduced features.";
      homepage = "https://gitlab.com/asus-linux/asus-nb-ctrl";
      platforms = platforms.linux;
    };
  };

in {

  environment.systemPackages = [ asus-nb-ctrl ];

  services = {

    dbus.packages = [ asus-nb-ctrl ];
    udev.packages = [ asus-nb-ctrl ];

    actkbd = {
      enable = true;
      bindings = [
        {
          keys = [ 203 ];
          events = [ "key" ];
          command = "${asus-nb-ctrl}/bin/asusctl profile -n";
        }
      ];
    };
  };

  # TODO: Use service files

  systemd = {
    user.services = {

      asus-notify = {
        unitConfig = {
          Description = "ASUS Notifications";
          StartLimitInterval = 200;
          StartLimitBurst = 2;
        };
        serviceConfig = {
          ExecStartPre = "/run/current-system/sw/bin/sleep 2";
          ExecStart = "${asus-nb-ctrl}/bin/asus-notify";
          Restart = "on-failure";
          RestartSec = 1;
          Type = "simple";
        };
        wantedBy = [ "default.target" ];
      };
    };

    services = {

      asusd-alt = {
        unitConfig = {
          Description = "ASUS Notebook Control";
          # After = [ "basic.target" "syslog.target" ];
          After = [ "basic.target" ];
        };
        serviceConfig = {
          ExecStart = "${asus-nb-ctrl}/bin/asusd";
          Restart = "on-failure";
          Type = "dbus";
          BusName = "org.asuslinux.Daemon";
        };
        wantedBy = [ "multi-user.target" ];
      };

      asusd = {
        unitConfig = {
          Description = "ASUS Notebook Control";
          StartLimitInterval = 200;
          StartLimitBurst = 2;
          Before = [ "display-manager.service" ];
        };
        serviceConfig = {
          ExecStart = "${asus-nb-ctrl}/bin/asusd";
          Restart = "always";
          RestartSec = 1;
          Type = "dbus";
          BusName = "org.asuslinux.Daemon";
        };
      };

    };

  };

}

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
      rev = "4eeacea83248a47873c6f1de3d19afa7cf0cccc0";
    };

    makeFlags = [
      "DESTDIR=${placeholder "out"}"
      "prefix="
    ];

    cargoSha256 = "sha256:0j41bqdgnhy9qr08mjpqd41vmcb50yzbwapjnwaiqac37dk599dj";

    nativeBuildInputs = with nixpkgs; [ pkg-config ];
    buildInputs = with nixpkgs; [ dbus udev ];

    # TODO: fix
    patchPhase = ''
      substituteInPlace data/asus-notify.service --replace /usr/bin/sleep ${nixpkgs.coreutils}/bin/sleep --replace /usr/bin/asus-notify $out/bin/asus-notify
      substituteInPlace data/asusd.rules --replace systemctl /run/current-system/systemd/bin/systemctl
      substituteInPlace data/asusd.service --replace /usr/bin/asusd $out/bin/asusd
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
    xserver.modules = [ asus-nb-ctrl ];

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

  # TODO: Fix
  # systemd.packages = [ asus-nb-ctrl ];

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

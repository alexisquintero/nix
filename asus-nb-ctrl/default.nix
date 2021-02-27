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
      rev = "6f81f86483497cd38c25d1c75dcc974f6a3639fd";
    };

    makeFlags = [
      "DESTDIR=${placeholder "out"}"
      "prefix="
    ];

    cargoSha256 = "sha256:1wm9n5zvybisai2671s0x9swqh555knd3k2sps3sjw1sinx4ni4j";

    nativeBuildInputs = with nixpkgs; [ pkg-config ];
    buildInputs = with nixpkgs; [ dbus udev ];

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

  services.actkbd = {
    enable = true;
    bindings = [
      {
        keys = [ 203 ];
        events = [ "key" ];
        command = "${asus-nb-ctrl}/bin/asusctl profile -n";
      }
    ];
  };

  systemd.services = {
    asusd = {
      serviceConfig = {
        ExecStart = "${asus-nb-ctrl}/bin/asusd";
        Restart = "always";
      };
      wantedBy = [ "multi-user.target" ];
    };

    asus-notify = {
      serviceConfig = {
        ExecStart = "${asus-nb-ctrl}/bin/asus-notify";
      };
      partOf = [ "asusd.service" ];
      wantedBy = [ "multi-user.target" ];
    };
  };

}

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
      rev = "bc46fa2b1eb05701125adf8674819cc82e02c413";
    };

    makeFlags = [
      "DESTDIR=${placeholder "out"}"
      "prefix="
    ];

    cargoSha256 = "sha256:1658shdq1p7p6gjpvik0w339516w18nnlf0f3bmnymgkksarfxf3";

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

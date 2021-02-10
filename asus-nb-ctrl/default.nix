{ ... }:

let
  moz_overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
  nixpkgs = import <nixpkgs> { overlays = [ moz_overlay ]; };
  rustPlatform = nixpkgs.rustPlatform;
  asus-nb-ctrl = rustPlatform.buildRustPackage rec {
    name = "ASUS-NB-Ctrl";

    src = builtins.fetchGit {
      url = "https://gitlab.com/asus-linux/asus-nb-ctrl";
      ref = "main";
      rev = "d61c180ee52a4162046adedb0e84a176d867dbb5"; # WORKING
      # rev = "f47bbd55973fdbb5f987d869efbd9f5793dcf261"; # LATEST
    };

    makeFlags = [
      "prefix=${placeholder "out"}"
    ];

    cargoSha256 = "sha256:1wrbhj3l1gqiw00nwkb138fwr7whd0inlhg6n6fg7qv23pjcbj0j";

    nativeBuildInputs = with nixpkgs; [ pkg-config ];
    buildInputs = with nixpkgs; [ dbus udev latest.rustChannels.stable.rust ];

    patchPhase = ''
      substituteInPlace Makefile --replace \
      "/etc/asusd/" \
      $out/etc/asusd/
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
    };
  };

}

{ pkgs ? import <nixpkgs> {}, ... }:

let
  rustPlatform = pkgs.rustPlatform;
  lib = pkgs.stdenv.lib;
  asus-nb-ctrl = rustPlatform.buildRustPackage rec {
    name = "ASUS-NB-Ctrl";

    src = builtins.fetchGit {
      url = "https://gitlab.com/asus-linux/asus-nb-ctrl";
      ref = "next";
      rev = "b496139063b6d83104c4e2908b3c2c8a5f06b926";
    };

    makeFlags = [
      "prefix=${placeholder "out"}"
    ];

    cargoSha256 = "sha256:1wrbhj3l1gqiw00nwkb138fwr7whd0inlhg6n6fg7qv23pjcbj0j";

    nativeBuildInputs = with pkgs; [ pkg-config ];
    buildInputs = with pkgs; [ dbus udev ];

    patchPhase = ''
      substituteInPlace Makefile --replace \
      "/etc/asusd/" \
      $out/etc/asusd/
    '';

    configurePhase = null;
    buildPhase = null;
    checkPhase = null;
    installPhase = null;

    meta = with lib; {
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
      {
        keys = [ 229 ];
        events = [ "key" ];
        command = "${asus-nb-ctrl}/bin/asusctl -k off";
      }
      {
        keys = [ 230 ];
        events = [ "key" ];
        command = "${asus-nb-ctrl}/bin/asusctl -k low";
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

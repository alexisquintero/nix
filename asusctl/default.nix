{ ... }:

let
  moz_overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
  nixpkgs = import <nixpkgs> { overlays = [ moz_overlay ]; };
  rustLatest = nixpkgs.latest.rustChannels.stable.rust;
  rustPlatform = nixpkgs.makeRustPlatform {
    cargo = rustLatest;
    rustc = rustLatest;
  };
  asusctl = rustPlatform.buildRustPackage rec {
    name = "asusctl";

    src = builtins.fetchGit {
      url = "https://gitlab.com/asus-linux/asusctl";
      ref = "main";
      rev = "ac880a0363f9fa58c101d17e4d366f544b573dc5";
    };

    makeFlags = [
      "DESTDIR=${placeholder "out"}"
      "prefix="
    ];

    cargoSha256 = "sha256:0wz04dp8x9vnr8fbidc7d3xjyix4qrpqwyi1m8dld3jimqkpznhn";

    nativeBuildInputs = with nixpkgs; [ pkg-config ];
    buildInputs = with nixpkgs; [ dbus udev ];

    doCheck = false;

    patchPhase = ''
      substituteInPlace data/asus-notify.service --replace /usr/bin/sleep ${nixpkgs.coreutils}/bin/sleep --replace /usr/bin/asus-notify $out/bin/asus-notify
      substituteInPlace data/asusd-alt.service --replace /usr/bin/asusd $out/bin/asusd
      substituteInPlace data/asusd-user.service --replace /usr/bin/asusd-user $out/bin/asusd-user --replace /usr/bin/sleep ${nixpkgs.coreutils}/bin/sleep
      substituteInPlace data/asusd.rules --replace systemctl /run/current-system/systemd/bin/systemctl
      substituteInPlace data/asusd.service --replace /usr/bin/asusd $out/bin/asusd
    '';

    configurePhase = null;
    buildPhase = ''
      make DESTDIR=${placeholder "out"} prefix=""
    '';
    checkPhase = null;
    installPhase = ''
      make install DESTDIR=${placeholder "out"} prefix=""
    '';

    meta = with nixpkgs.lib; {
      description = "asusd is a utility for Linux to control many aspects of various ASUS laptops but can also be used with non-asus laptops with reduced features.";
      homepage = "https://gitlab.com/asus-linux/asusctl";
      platforms = platforms.linux;
    };
  };

in {

  environment = {
    systemPackages = [ asusctl ];
    etc."asusd/asusd-ledmodes.toml" = {
      source = "${asusctl}/etc/asusd/asusd-ledmodes.toml";
      mode = "0644";
    };
  };

  systemd.packages = [ asusctl ];

  services = {

    dbus.packages = [ asusctl ];
    udev.packages = [ asusctl ];
    xserver.modules = [ asusctl ];

    actkbd = {
      enable = true;
      bindings = [
        {
          keys = [ 203 ];
          events = [ "key" ];
          command = "${asusctl}/bin/asusctl profile -n";
        }
      ];
    };
  };

}

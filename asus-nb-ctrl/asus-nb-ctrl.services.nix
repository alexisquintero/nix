{ pkgs ? import <nixpkgs> {}, ...}:

let

  asus-nb-ctrl = import ./default.nix { inherit pkgs; };

in {
  systemd.services.asusd = {
    serviceConfig = {
      ExecStart = "${asus-nb-ctrl}/bin/asusd";
    };

  };

  systemd.services.asusd = {
    enable = true;
  };

  systemd.services.asus-notify = {
    serviceConfig = {
      ExecStart = "${asus-nb-ctrl}/bin/asus-notify";
    };
  };

  systemd.services.asus-notify = {
    enable = true;
  };

}


{ pkgs, dotfiles, ... }:

{
  home = {
    packages = (with pkgs; [
      i3lock
    ]);
  };

  programs = {
    i3status = {
      enable = true;
    };
  };

  xsession = {
    enable = true;
    windowManager = {
      i3 = {
        enable = true;
        config = null;
        extraConfig = builtins.readFile "${dotfiles}/.config/i3/config";
      };
    };
  };
}

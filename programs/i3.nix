{ dotfiles, ... }:

{
  xdg = {
    enable = true;
    configFile."i3status/config".source = "${dotfiles}/.config/i3/i3status";
  };

  programs = {
    i3status.enable = true;
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

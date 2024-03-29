{ dotfiles, ... }:

{
  programs = {
    xmobar = {
      enable = true;
      extraConfig = builtins.readFile "${dotfiles}/.config/xmobar/xmobarrc";
    };
  };

  xsession = {
    enable = true;
    windowManager = {
      xmonad = {
        enable = true;
        enableContribAndExtras = true;
        config = "${dotfiles}/.xmonad/xmonad.hs";
      };
    };
  };
}

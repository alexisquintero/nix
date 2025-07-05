{  pkgs, vim-config, ... }:

{
  xdg.configFile."nvim" = {
    recursive = true;
    source = "${vim-config}";
  };

  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      nixd
      cmake
      gcc
    ];
    vimAlias = true;
    vimdiffAlias = true;
  };

}

{  pkgs, vim-config, ... }:

{
  xdg.configFile."nvim" = {
    recursive = true;
    source = "${vim-config}";
  };

  programs.neovim = {
    enable = true;
    withRuby = false;
    withPython3 = false;
    extraPackages = with pkgs; [
      nixd
      cmake
      gcc
      lua-language-server
      imagemagick
      curl
      tree-sitter
      xclip
    ];
    vimAlias = true;
    vimdiffAlias = true;
  };

}

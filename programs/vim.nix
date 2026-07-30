{ pkgs, ... }:

{
  programs.neovim = {
    withRuby = false;
    withPython3 = false;
    extraPackages = with pkgs; [ xclip ];
  };
}

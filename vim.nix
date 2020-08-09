{ pkgs, buildVimPlugin, ...}:

let
  # vim-substrata = {
  #   name = "vim-substrata";
  #   src = {
  #     url = "https://github.com/arzg/vim-substrata";
  #   };
  # };

  plugins = with pkgs.vimPlugins; [
    vim-gitgutter
    vim-scala
    vim-fugitive
    vim-cool
    coc-nvim
    vim-sexp
    vim-unimpaired
    vim-commentary
    vim-sandwich
    vim-fireplace
    vim-rhubarb
    vim-nix
    fzf-vim
    i3config-vim
    targets-vim

    # vim-printer

    # vim-substrata
    nord-vim

    coc-metals
    coc-json
  ];

  settings = builtins.readFile ./.vim/settings.vim;
  mappings = builtins.readFile ./.vim/mappings.vim;
  # colorscheme = builtins.readFile ./.vim/colorscheme.vim;
  extra = "colorscheme nord";

  coc-settings =            builtins.readFile ./.vim/pluginsettings/coc.vim;
  fzf-settings =            builtins.readFile ./.vim/pluginsettings/fzf.vim;
  gitgutter-settings =      builtins.readFile ./.vim/pluginsettings/gitgutter.vim;
  i3config-settings =       builtins.readFile ./.vim/pluginsettings/i3config.vim;
  netrw-settings =          builtins.readFile ./.vim/pluginsettings/netrw.vim;
  sandwich-settings =       builtins.readFile ./.vim/pluginsettings/sandwich.vim;
  sexp-settings =           builtins.readFile ./.vim/pluginsettings/sexp.vim;
  targets-settings =        builtins.readFile ./.vim/pluginsettings/targets.vim;
  vim-cool-settings =       builtins.readFile ./.vim/pluginsettings/vim-cool.vim;
  vim-scala-settings =      builtins.readFile ./.vim/pluginsettings/vim-scala.vim;
  vim-printer-settings =    builtins.readFile ./.vim/pluginsettings/vim-printer.vim;
  clojure-syntax-settings = builtins.readFile ./.vim/pluginsettings/clojure-syntax.vim;

  pluginSettings =
    coc-settings +
    fzf-settings +
    gitgutter-settings +
    i3config-settings +
    netrw-settings +
    sandwich-settings +
    sexp-settings +
    targets-settings +
    vim-cool-settings +
    vim-scala-settings +
    vim-printer-settings +
    clojure-syntax-settings;

in
{
  programs.neovim = {
    enable = true;
    plugins = plugins;
    extraConfig = settings + mappings + pluginSettings + extra;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
  };

  xdg.configFile = {
    "nvim/coc-settings.json".source = ./.vim/coc-settings.json;
  };
}

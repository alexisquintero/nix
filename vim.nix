{ pkgs, ...}:

let

  buildVimPlugin = pkgs.vimUtils.buildVimPluginFrom2Nix;

  vim-substrata = buildVimPlugin {
    name = "vim-substrata";
    src = builtins.fetchGit {
      url = "https://github.com/arzg/vim-substrata";
      ref = "master";
    };
    dependencies = [];
  };

  vim-printer = buildVimPlugin {
    name = "vim-printer";
    src = builtins.fetchGit {
      url = "https://github.com/meain/vim-printer";
      ref = "master";
    };
    dependencies = [];
  };

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
    vim-printer
    fzf-vim
    i3config-vim
    targets-vim

    vim-substrata
    # nord-vim

    coc-metals
    coc-json
  ];

  settings = builtins.readFile ./.vim/settings.vim;
  mappings = builtins.readFile ./.vim/mappings.vim;
  extra = "colorscheme substrata";

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
  # nord-vim-settings =       builtins.readFile ./.vim/pluginsettings/nord.vim;

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
    vim-printer-settings;

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

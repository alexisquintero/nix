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

  nvim-metals = buildVimPlugin {
    name = "nvim-metals";
    src = builtins.fetchGit {
      url = "https://github.com/scalameta/nvim-metals";
      ref = "main";
    };
  };

  nvim-lspconfig = buildVimPlugin {
    name = "nvim-lspconfig";
    src = builtins.fetchGit {
      url = "https://github.com/neovim/nvim-lspconfig";
      ref = "master";
    };
  };

  plugins = with pkgs.vimPlugins; [
    vim-gitgutter
    vim-scala
    vim-fugitive
    vim-cool
    vim-sexp
    vim-unimpaired
    vim-commentary
    vim-sandwich
    vim-fireplace
    vim-rhubarb
    vim-nix
    vim-printer
    fzf-vim
    targets-vim

    vim-substrata
    # nord-vim

    nvim-lspconfig
    nvim-metals
  ];

  settings = builtins.readFile ./.vim/settings.vim;
  mappings = builtins.readFile ./.vim/mappings.vim;
  extra = "colorscheme substrata";

  fzf-settings =         builtins.readFile ./.vim/pluginsettings/fzf.vim;
  gitgutter-settings =   builtins.readFile ./.vim/pluginsettings/gitgutter.vim;
  netrw-settings =       builtins.readFile ./.vim/pluginsettings/netrw.vim;
  sandwich-settings =    builtins.readFile ./.vim/pluginsettings/sandwich.vim;
  sexp-settings =        builtins.readFile ./.vim/pluginsettings/sexp.vim;
  targets-settings =     builtins.readFile ./.vim/pluginsettings/targets.vim;
  vim-cool-settings =    builtins.readFile ./.vim/pluginsettings/vim-cool.vim;
  vim-scala-settings =   builtins.readFile ./.vim/pluginsettings/vim-scala.vim;
  vim-printer-settings = builtins.readFile ./.vim/pluginsettings/vim-printer.vim;
  lsp-config-settings  = builtins.readFile ./.vim/pluginsettings/lsp-config.vim;
  metals-settings =      builtins.readFile ./.vim/pluginsettings/metals.vim;
  # nord-vim-settings =    builtins.readFile ./.vim/pluginsettings/nord.vim;

  pluginSettings =
    fzf-settings +
    gitgutter-settings +
    netrw-settings +
    sandwich-settings +
    sexp-settings +
    targets-settings +
    vim-cool-settings +
    vim-scala-settings +
    vim-printer-settings +
    lsp-config-settings +
    metals-settings;

in
{

  programs.neovim = {
    package = pkgs.neovim-nightly;
    enable = true;
    plugins = plugins;
    extraConfig = settings + mappings + pluginSettings + extra;
    vimAlias = true;
    vimdiffAlias = true;
  };

}

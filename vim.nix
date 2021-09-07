{ pkgs, ...}:

let
  cmp-settings =         builtins.readFile ./.vim/pluginsettings/cmp.vim;
  fzf-settings =         builtins.readFile ./.vim/pluginsettings/fzf.vim;
  gitgutter-settings =   builtins.readFile ./.vim/pluginsettings/gitgutter.vim;
  lsp-config-settings  = builtins.readFile ./.vim/pluginsettings/lsp-config.vim;
  metals-settings =      builtins.readFile ./.vim/pluginsettings/metals.vim;
  netrw-settings =       builtins.readFile ./.vim/pluginsettings/netrw.vim;
  sandwich-settings =    builtins.readFile ./.vim/pluginsettings/sandwich.vim;
  sexp-settings =        builtins.readFile ./.vim/pluginsettings/sexp.vim;
  targets-settings =     builtins.readFile ./.vim/pluginsettings/targets.vim;
  vim-cool-settings =    builtins.readFile ./.vim/pluginsettings/vim-cool.vim;
  vim-printer-settings = builtins.readFile ./.vim/pluginsettings/vim-printer.vim;
  vim-scala-settings =   builtins.readFile ./.vim/pluginsettings/vim-scala.vim;

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

  lsp-signature = buildVimPlugin {
    name = "lsp-signature";
    src = builtins.fetchGit {
      url = "https://github.com/ray-x/lsp_signature.nvim";
      ref = "master";
    };
  };

  plugins = with pkgs.vimPlugins; [
    {
      plugin = vim-gitgutter;
      config = gitgutter-settings;
    }
    {
      plugin = vim-scala;
      config = vim-scala-settings;
    }
    vim-fugitive
    {
      plugin = vim-cool;
      config = vim-cool-settings;
    }
    {
      plugin = vim-sexp;
      config = sexp-settings;
    }
    vim-unimpaired
    vim-commentary
    {
      plugin = vim-sandwich;
      config = sandwich-settings;
    }
    vim-fireplace
    vim-rhubarb
    vim-nix
    {
      plugin = vim-printer;
      config = vim-printer-settings;
    }
    {
      plugin = fzf-vim;
      config = fzf-settings;
    }
    {
      plugin = targets-vim;
      config = targets-settings;
    }
    vim-substrata
    {
      plugin = nvim-lspconfig;
      config = lsp-config-settings;
    }
    {
      plugin = nvim-metals;
      config = metals-settings;
    }
    {
      plugin = nvim-cmp;
      config = cmp-settings;
    }
    cmp-buffer
    cmp-nvim-lsp
    lsp-signature
  ];

  settings = builtins.readFile ./.vim/settings.vim;
  mappings = builtins.readFile ./.vim/mappings.vim;
  pluginSettings = netrw-settings;
  extra = "colorscheme substrata";

in
{

  programs.neovim = {
    enable = true;
    plugins = plugins;
    extraConfig = settings + mappings + pluginSettings + extra;
    vimAlias = true;
    vimdiffAlias = true;
  };

}

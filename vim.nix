{ config, pkgs, ... }:

let
  buildVimPlugin = pkgs.vimUtils.buildVimPluginFrom2Nix;

  substrata.nvim = buildVimPlugin {
    name = "substrata.nvim";
    src = builtins.fetchGit {
      url = "https://github.com/kvrohit/substrata.nvim";
      ref = "main";
    };
  };

  vim-printer = buildVimPlugin {
    name = "vim-printer";
    src = builtins.fetchGit {
      url = "https://github.com/meain/vim-printer";
      ref = "master";
    };
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
    cmp-buffer
    cmp-nvim-lsp
    fzf-vim
    lsp-signature
    nvim-cmp
    nvim-lspconfig
    nvim-metals
    plenary-nvim
    substrata.nvim
    targets-vim
    vim-commentary
    vim-cool
    vim-fireplace
    vim-fugitive
    vim-gitgutter
    vim-nix
    vim-printer
    vim-rhubarb
    vim-sandwich
    vim-scala
    vim-sexp
    vim-unimpaired
  ];

in
{

  xdg.configFile."nvim2" = {
    recursive = true;
    source = ./vim;
  };

  programs.neovim = {
    enable = true;
    plugins = plugins;
    extraConfig = ''
      set runtimepath^=${config.xdg.configHome}/nvim-git
      let g:ignore_plug=1
    '';
    vimAlias = true;
    vimdiffAlias = true;
  };

}

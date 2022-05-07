{ config, pkgs, vim-config, ... }:

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

  cmp-nvim-lsp-signature-help = buildVimPlugin {
    name = "cmp-nvim-lsp-signature-help";
    src = builtins.fetchGit {
      url = "https://github.com/hrsh7th/cmp-nvim-lsp-signature-help";
      ref = "main";
    };
  };

  plugins = with pkgs.vimPlugins; [
    (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))
    cmp-buffer
    cmp-nvim-lsp
    cmp-nvim-lsp-signature-help
    cmp_luasnip
    comment-nvim
    fidget-nvim
    fzf-vim
    luasnip
    nvim-cmp
    nvim-lspconfig
    nvim-metals
    plenary-nvim
    substrata.nvim
    targets-vim
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

  config-path = "${config.xdg.configHome}/nvim-git";

in
{

  xdg.configFile."nvim-git" = {
    recursive = true;
    source = "${vim-config}";
  };

  programs.neovim = {
    enable = true;
    plugins = plugins;
    extraConfig = ''
      let g:ignore_plug=1
      set runtimepath^=${config-path}
      source ${config-path}/init.vim
    '';
    vimAlias = true;
    vimdiffAlias = true;
  };

}

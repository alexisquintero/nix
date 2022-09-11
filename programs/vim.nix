{ config, pkgs, vim-config, ... }:

let

  plugins = with pkgs.vimPlugins; [
    (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))
    cmp-buffer
    cmp-nvim-lsp
    cmp-nvim-lsp-signature-help
    cmp_luasnip
    comment-nvim
    fidget-nvim
    luasnip
    nvim-cmp
    nvim-lspconfig
    nvim-metals
    plenary-nvim
    substrata-nvim
    targets-vim
    telescope-nvim
    telescope-fzf-native-nvim
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

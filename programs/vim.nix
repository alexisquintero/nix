{ config, pkgs, vim-config, ... }:

let

  plugins = with pkgs.vimPlugins; [
    nvim-treesitter.withAllGrammars
    cmp-buffer
    cmp-nvim-lsp
    cmp-nvim-lsp-signature-help
    cmp_luasnip
    comment-nvim
    fidget-nvim
    haskell-tools-nvim
    luasnip
    nvim-cmp
    nvim-lspconfig
    nvim-metals
    plenary-nvim
    rust-tools-nvim
    substrata-nvim
    targets-vim
    telescope-fzf-native-nvim
    telescope-nvim
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

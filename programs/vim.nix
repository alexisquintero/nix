{  pkgs, vim-config, ... }:

let

  plugins = with pkgs.vimPlugins; [
    cmp-buffer
    cmp-nvim-lsp
    cmp-nvim-lsp-signature-help
    cmp_luasnip
    comment-nvim
    diffview-nvim
    fidget-nvim
    flash-nvim
    gitsigns-nvim
    haskell-tools-nvim
    luasnip
    nvim-cmp
    nvim-lspconfig
    nvim-metals
    nvim-treesitter-textobjects
    nvim-treesitter.withAllGrammars
    plantuml-syntax
    plenary-nvim
    rust-tools-nvim
    substrata-nvim
    targets-vim
    telescope-fzf-native-nvim
    telescope-nvim
    telescope-ui-select-nvim
    vim-cool
    vim-fireplace
    vim-fugitive
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

  xdg.configFile."nvim" = {
    recursive = true;
    source = "${vim-config}";
  };

  programs.neovim = {
    enable = true;
    plugins = plugins;
    extraPackages = with pkgs; [
      nixd
    ];
    vimAlias = true;
    vimdiffAlias = true;
  };

}

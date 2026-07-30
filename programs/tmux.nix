{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    baseIndex = 1;
    shortcut = "a";
    secureSocket = false;
    plugins = with pkgs.tmuxPlugins; [ sensible yank ];
    extraConfig = ''
      set -g pane-base-index 1
      set -as terminal-features ",xterm-kitty:RGB"
      set-option -g renumber-windows on
      set-option -g status-bg "#0f2a3f"
      set-option -g status-fg "#c3a38a"
    '';
  };
}

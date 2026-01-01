{ ... }:

{
  programs.kitty = {
    enable = true;
    shellIntegration.mode = "no-cursor";
    settings = {
      font_family = "DejaVu Sans Mono Book";
      bold_font = "DejaVu Sans Mono Bold";
      italic_font = "DejaVu Sans Mono Oblique";
      bold_italic_font = "DejaVu Sans Mono Bold Oblique";
      font_size = "9";
      adjust_line_height = "1";
      scrollback_lines = "10000";
      mouse_hide_wait = "1.0";
      copy_on_select = "no";
      foreground = "#F8FA90";
      background = "#08141E";
      enable_audio_bell = "no";
      scrollback_pager = "less --chop-long-lines --RAW-CONTROL-CHARS +INPUT_LINE_NUMBER";
    };
    keybindings = {
      "alt+b" = "scroll_page_up";
      "alt+f" = "scroll_page_down";
      "alt+/" = "show_scrollback";
      "ctrl+shift+n" = "new_os_window_with_cwd";
    };
  };
}

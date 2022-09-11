{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;
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
    };
    keybindings = {
      "alt+b" = "scroll_page_up";
      "alt+f" = "scroll_page_down";
      "alt+/" = "show_scrollback";
    };
  };
}

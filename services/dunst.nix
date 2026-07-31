{ pkgs, lib, ... }:

{
  services.dunst = {
    enable = true;
    settings = {
      global = {
        markup             = "yes";
        format             = "<b>%s</b>\\n%b";
        sort               = "no";
        indicate_hidden    = "yes";
        alignment          = "center";
        word_wrap          = "yes";
        stack_duplicates   = "yes";
        hide_duplicate_count = "yes";
        width              = 300;
        height             = 50;
        transparency       = 5;
        sticky_history     = "no";
        history_length     = 15;
        show_indicators    = "yes";
        separator_height   = 2;
        padding            = 6;
        horizontal_padding = 6;
        separator_color    = "frame";
        browser            = "${lib.getExe pkgs.firefox} -new-tab";
        frame_width        = 3;
        frame_color        = "#4e495f";
      };
      shortcuts = {
        close     = "ctrl+space";
        close_all = "ctrl+shift+space";
        history   = "ctrl+grave";
        context   = "ctrl+shift+period";
      };
      urgency_low = {
        frame_color = "#4e495f";
        foreground  = "#f6d6bd";
        background  = "#0f2a3f";
        timeout     = 4;
      };
      urgency_normal = {
        frame_color = "#000000";
        foreground  = "#f6d6bd";
        background  = "#0f2a3f";
        timeout     = 6;
      };
      urgency_critical = {
        frame_color = "#816271";
        foreground  = "#08141e";
        background  = "#f6d6bd";
        timeout     = 8;
      };
    };
  };
}

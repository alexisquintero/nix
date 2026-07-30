{ ... }:

{
  programs.readline = {
    enable = true;
    variables = {
      "colored-stats"                    = true;
      "completion-ignore-case"           = true;
      "completion-prefix-display-length" = 2;
      "mark-symlinked-directories"       = true;
      "visible-stats"                    = true;
      "editing-mode"                     = "vi";
      "show-mode-in-prompt"              = true;
      "vi-cmd-mode-string"               = "\\1\\e[2 q\\2";
      "vi-ins-mode-string"               = "\\1\\e[6 q\\2";
      "keyseq-timeout"                   = 0;
      "show-all-if-ambiguous"            = true;
    };
  };

  home.file.".haskeline".text = ''
    editMode: Vi
  '';

  home.file.".config/jline/config.yaml".text = ''
    keymap: vi
  '';
}

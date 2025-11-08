{ ... }:

{
  # https://sw.kovidgoyal.net/kitty/binary/
  # curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
  # ln -s ~/.local/kitty.app/{kitty,kitten} ~/.local/bin
  programs.kitty.package = null;
}

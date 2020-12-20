{ stdenv, pkgs }:

stdenv.mkDerivation rec {
  name = "ASUS-NB-Ctrl";
  src = builtins.fetchGit {
    url = "https://gitlab.com/asus-linux/asus-nb-ctrl";
    ref = "next";
    rev = "b496139063b6d83104c4e2908b3c2c8a5f06b926";
  };

  buildInputs = with pkgs; [ cargo ];

  meta = with stdenv.lib; {
    description = "asusd is a utility for Linux to control many aspects of various ASUS laptops but can also be used with non-asus laptops with reduced features.";
    homepage = "https://gitlab.com/asus-linux/asus-nb-ctrl";
    platforms = platforms.linux;
  };
}

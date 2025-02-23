{
  pkgs,
  lib,
  ...
}:
lib.mkTypstDerivation {
  src = ./src;
  name = "mkTypstDerivationHTML";
  fonts = with pkgs; [roboto];
  pages = "2,3-";
  inputs = {
    lang = "de";
    hello = 12;
  };
  format = "html";
}
